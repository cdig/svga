(function() {
  var base,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Take(["Registry", "Scene", "SVG"], function(Registry, Scene, SVG) {
    var svgData;
    svgData = Scene.crawl(SVG.root);
    Make("SVGReady");
    return setTimeout(function() {
      Registry.closeRegistration("ScopeProcessor");
      Make("ScopeReady");
      Registry.closeRegistration("Control");
      Make("ControlReady");
      Registry.closeRegistration("Symbol");
      Scene.build(svgData);
      svgData = null;
      Make("SceneReady");
      return Make("AllReady");
    });
  });

  Take(["Scope", "SVG", "Symbol"], function(Scope, SVG, Symbol) {
    var Scene, buildScopes, defs, deprecations, masks, processElm;
    deprecations = ["controlPanel", "ctrlPanel", "navOverlay"];
    masks = [];
    defs = {};
    Make("Scene", Scene = {
      crawl: function(elm) {
        var tree;
        tree = processElm(elm);
        if (masks.length) {
          console.log.apply(console, ["Please remove these mask elements from your SVG:"].concat(slice.call(masks)));
        }
        masks = null;
        defs = null;
        return tree;
      },
      build: function(tree) {
        var m, results, setup, setups;
        buildScopes(tree, setups = []);
        results = [];
        for (m = setups.length - 1; m >= 0; m += -1) {
          setup = setups[m];
          results.push(setup());
        }
        return results;
      }
    });
    processElm = function(elm) {
      var childElm, childNodes, clone, def, defId, len, m, ref, ref1, tree;
      tree = {
        elm: elm,
        sub: []
      };
      childNodes = Array.prototype.slice.call(elm.childNodes);
      for (m = 0, len = childNodes.length; m < len; m++) {
        childElm = childNodes[m];
        if ((ref = childElm.id, indexOf.call(deprecations, ref) >= 0)) {
          console.log("#" + childElm.id + " is obsolete. Please remove it from your FLA and re-export this SVG.");
          elm.removeChild(childElm);
        } else if (childElm.tagName === "clipPath") {
          elm.removeChild(childElm);
        } else if (childElm.tagName === "text") {
          if (typeof childElm.removeAttribute === "function") {
            childElm.removeAttribute("clip-path");
          }
        } else if (((ref1 = childElm.id) != null ? ref1.indexOf("Mask") : void 0) > -1) {
          masks.push(childElm.id);
          elm.removeChild(childElm);
        } else if (childElm instanceof SVGGElement) {
          tree.sub.push(processElm(childElm));
        } else if (childElm instanceof SVGUseElement) {
          defId = childElm.getAttribute("xlink:href");
          def = defs[defId] != null ? defs[defId] : defs[defId] = SVG.defs.querySelector(defId);
          clone = def.cloneNode(true);
          elm.replaceChild(clone, childElm);
          if (def.parentNode != null) {
            def.parentNode.removeChild(def);
          }
          if (clone instanceof SVGGElement) {
            tree.sub.push(processElm(clone));
          }
        }
      }
      return tree;
    };
    return buildScopes = function(tree, setups, parentScope) {
      var baseName, len, m, props, ref, ref1, results, scope, subTarget, symbol;
      if (parentScope == null) {
        parentScope = null;
      }
      props = {
        parent: parentScope
      };
      if (tree.elm.id.replace(/_FL/g, "").length > 0) {
        props.id = tree.elm.id.replace(/_FL/g, "");
      }
      baseName = (ref = tree.elm.id) != null ? ref.split("_")[0] : void 0;
      symbol = baseName.indexOf("Line") > -1 || baseName.indexOf("line") === 0 ? Symbol.forSymbolName("HydraulicLine") : baseName.indexOf("Field") > -1 || baseName.indexOf("field") === 0 ? Symbol.forSymbolName("HydraulicField") : Symbol.forInstanceName(props.id);
      if (symbol == null) {
        symbol = function() {
          return {};
        };
      }
      scope = Scope(tree.elm, symbol, props);
      if (scope.setup != null) {
        setups.push(scope.setup.bind(scope));
      }
      ref1 = tree.sub;
      results = [];
      for (m = 0, len = ref1.length; m < len; m++) {
        subTarget = ref1[m];
        results.push(buildScopes(subTarget, setups, scope));
      }
      return results;
    };
  });

  Take(["Mode", "Registry", "ScopeCheck", "Symbol"], function(Mode, Registry, ScopeCheck, Symbol) {
    var Scope, findParent;
    Make("Scope", Scope = function(element, symbol, props) {
      var attr, attrs, idCounter, len, len1, m, n, parentScope, ref, scope, scopeProcessor, tempID;
      if (props == null) {
        props = {};
      }
      if (!element instanceof SVGElement) {
        console.log(element);
        throw new Error("Scope() takes an element as the first argument. Got ^^^");
      }
      if ((symbol != null) && typeof symbol !== "function") {
        console.log(symbol);
        throw new Error("Scope() takes a function as the second arg. Got ^^^");
      }
      if (typeof props !== "object") {
        console.log(props);
        throw new Error("Scope() takes an optional object as the third arg. Got ^^^");
      }
      scope = symbol != null ? symbol(element, props) : {};
      parentScope = props.parent || findParent(element);
      ScopeCheck(scope, "_symbol", "children", "element", "id", "parent", "root");
      element._scope = scope;
      scope._symbol = symbol;
      scope.children = [];
      scope.element = element;
      scope.root = Scope.root != null ? Scope.root : Scope.root = scope;
      scope.id = props.id;
      if (parentScope != null) {
        scope.parent = parentScope;
        if (scope.id == null) {
          scope.id = "child" + (parentScope.children.length || 0);
        }
        if (parentScope[scope.id] != null) {
          tempID = scope.id;
          idCounter = 1;
          while (parentScope[tempID + idCounter] != null) {
            idCounter++;
          }
          scope.id = tempID + idCounter;
        }
        parentScope[scope.id] = scope;
        parentScope.children.push(scope);
      }
      if (Mode.dev && !(navigator.userAgent.indexOf("Trident") >= 0 || navigator.userAgent.indexOf("Edge") >= 0)) {
        element.setAttribute("SCOPE", scope.id || "");
        if ((symbol != null ? symbol.symbolName : void 0) != null) {
          element.setAttribute("SYMBOL", symbol.symbolName);
        }
        attrs = Array.prototype.slice.call(element.attributes);
        for (m = 0, len = attrs.length; m < len; m++) {
          attr = attrs[m];
          if (!(attr.name !== "SCOPE" && attr.name !== "SYMBOL")) {
            continue;
          }
          element.removeAttributeNS(attr.namespaceURI, attr.name);
          element.setAttributeNS(attr.namespaceURI, attr.name, attr.value);
        }
      }
      window.getComputedStyle(element);
      ref = Registry.all("ScopeProcessor");
      for (n = 0, len1 = ref.length; n < len1; n++) {
        scopeProcessor = ref[n];
        scopeProcessor(scope);
      }
      return scope;
    });
    return findParent = function(element) {
      while (element != null) {
        if (element._scope != null) {
          return element._scope;
        }
        element = element.parentNode;
      }
      return null;
    };
  });

  Take(["FlowArrows:Config", "SVG", "TRS"], function(Config, SVG, TRS) {
    return Make("FlowArrows:Arrow", function(parentElm, segmentData, segmentPosition, vectorPosition, vectorIndex) {
      var arrow, element, line, triangle, vector;
      vector = segmentData.vectors[vectorIndex];
      element = TRS(SVG.create("g", parentElm));
      triangle = SVG.create("polyline", element, {
        points: "0,-16 30,0 0,16"
      });
      line = SVG.create("line", element, {
        x1: -23,
        y1: 0,
        x2: 5,
        y2: 0,
        "stroke-width": 11,
        "stroke-linecap": "round"
      });
      return arrow = {
        update: function(parentFlow, parentScale) {
          var scale;
          vectorPosition += parentFlow;
          segmentPosition += parentFlow;
          while (vectorPosition > vector.dist) {
            vectorIndex++;
            if (vectorIndex >= segmentData.vectors.length) {
              vectorIndex = 0;
              segmentPosition -= segmentData.dist;
            }
            vectorPosition -= vector.dist;
            vector = segmentData.vectors[vectorIndex];
          }
          while (vectorPosition < 0) {
            vectorIndex--;
            if (vectorIndex < 0) {
              vectorIndex = segmentData.vectors.length - 1;
              segmentPosition += segmentData.dist;
            }
            vector = segmentData.vectors[vectorIndex];
            vectorPosition += vector.dist;
          }
          if (segmentPosition < segmentData.dist / 2) {
            scale = Math.max(0, Math.min(1, (segmentPosition / segmentData.dist) * segmentData.dist / Config.FADE_LENGTH));
          } else {
            scale = Math.max(0, Math.min(1, 1 - (segmentPosition - (segmentData.dist - Config.FADE_LENGTH)) / Config.FADE_LENGTH));
          }
          return TRS.abs(element, {
            x: Math.cos(vector.angle) * vectorPosition + vector.x,
            y: Math.sin(vector.angle) * vectorPosition + vector.y,
            scale: scale * parentScale,
            r: vector.angle / (2 * Math.PI) + (parentFlow < 0 ? 0.5 : 0)
          });
        }
      };
    });
  });

  (function() {
    var Config, defineProp;
    Make("FlowArrows:Config", Config = {
      SCALE: 0.5,
      SPACING: 600,
      FADE_LENGTH: 50,
      MIN_SEGMENT_LENGTH: 200,
      SPEED: 200,
      MIN_EDGE_LENGTH: 8,
      CONNECTED_DISTANCE: 1,
      wrap: function(obj) {
        var k;
        for (k in Config) {
          if (k !== "wrap") {
            defineProp(obj, k);
          }
        }
        return obj;
      }
    });
    return defineProp = function(obj, k) {
      return Object.defineProperty(obj, k, {
        get: function() {
          return Config[k];
        },
        set: function(v) {
          return Config[k] = v;
        }
      });
    };
  })();

  Take(["Pressure", "SVG"], function(Pressure, SVG) {
    return Make("FlowArrows:Containerize", function(parentElm, setupFn) {
      var active, children, direction, enabled, flow, pressure, scale, scope, updateActive, visible, volume;
      active = true;
      direction = 1;
      enabled = true;
      flow = 1;
      pressure = null;
      scale = 1;
      visible = true;
      volume = 1;
      scope = {
        element: SVG.create("g", parentElm),
        reverse: function() {
          return direction *= -1;
        },
        update: function(parentFlow, parentScale) {
          var child, f, len, m, results, s;
          if (active) {
            f = flow * direction * parentFlow;
            s = volume * scale * parentScale;
            results = [];
            for (m = 0, len = children.length; m < len; m++) {
              child = children[m];
              results.push(child.update(f, s));
            }
            return results;
          }
        }
      };
      children = setupFn(scope);
      updateActive = function() {
        active = enabled && visible && flow !== 0;
        return SVG.styles(scope.element, {
          display: active ? "inline" : "none"
        });
      };
      Object.defineProperty(scope, 'enabled', {
        set: function(val) {
          if (visible !== val) {
            return updateActive(visible = val);
          }
        }
      });
      Object.defineProperty(scope, 'flow', {
        get: function() {
          return flow;
        },
        set: function(val) {
          if (flow !== val) {
            return updateActive(flow = val);
          }
        }
      });
      Object.defineProperty(scope, "pressure", {
        get: function() {
          return pressure;
        },
        set: function(val) {
          var color;
          if (pressure !== val) {
            pressure = val;
            color = Pressure(val);
            return SVG.attrs(scope.element, {
              fill: color,
              stroke: color
            });
          }
        }
      });
      Object.defineProperty(scope, 'scale', {
        get: function() {
          return scale;
        },
        set: function(val) {
          if (scale !== val) {
            return scale = val;
          }
        }
      });
      Object.defineProperty(scope, 'visible', {
        get: function() {
          return visible;
        },
        set: function(val) {
          if (visible !== val) {
            return updateActive(visible = val);
          }
        }
      });
      Object.defineProperty(scope, 'volume', {
        get: function() {
          return volume;
        },
        set: function(val) {
          if (volume !== val) {
            return volume = val;
          }
        }
      });
      return scope;
    });
  });

  Take(["FlowArrows:Config", "FlowArrows:Process", "FlowArrows:Set", "Reaction", "Tick"], function(Config, Process, Set, Reaction, Tick) {
    var animateMode, enableAll, sets, visible;
    sets = [];
    visible = true;
    animateMode = true;
    enableAll = function() {
      var len, m, results, set;
      results = [];
      for (m = 0, len = sets.length; m < len; m++) {
        set = sets[m];
        results.push(set.enabled = visible && animateMode);
      }
      return results;
    };
    Tick(function(time, dt) {
      var f, len, m, results, s, set;
      if (visible && animateMode) {
        results = [];
        for (m = 0, len = sets.length; m < len; m++) {
          set = sets[m];
          if (set.parentScope.alpha > 0) {
            f = dt * Config.SPEED;
            s = Config.SCALE;
            results.push(set.update(f, s));
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    });
    Reaction("Schematic:Hide", function() {
      return setTimeout(function() {
        return enableAll(animateMode = true);
      });
    });
    Reaction("Schematic:Show", function() {
      return enableAll(animateMode = false);
    });
    Reaction("FlowArrows:Show", function() {
      return enableAll(visible = true);
    });
    Reaction("FlowArrows:Hide", function() {
      return enableAll(visible = false);
    });
    return Make("FlowArrows", Config.wrap(function() {
      var elm, lineData, parentScope, set, setData;
      parentScope = arguments[0], lineData = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (parentScope == null) {
        console.log(lineData);
        throw new Error("FlowArrows was called with a null target. ^^^ was the baked line data.");
      }
      elm = parentScope.element;
      if (elm.querySelector("[id^=markerBox]")) {
        while (elm.hasChildNodes()) {
          elm.removeChild(elm.firstChild);
        }
      }
      setData = Process(lineData);
      set = Set(elm, setData);
      set.parentScope = parentScope;
      sets.push(set);
      return set;
    }));
  });

  Take("FlowArrows:Config", function(Config) {
    var angle, cullInlinePoints, cullShortEdges, cullShortSegments, distance, formSegments, isConnected, isInline, joinSegments, log, reifySegments, reifyVectors, wrap;
    Make("FlowArrows:Process", function(lineData) {
      return wrap(lineData).process(formSegments).process(joinSegments).process(cullShortEdges).process(cullInlinePoints).process(reifyVectors).process(reifySegments).process(cullShortSegments).result;
    });
    log = function(a) {
      console.dir(a);
      return a;
    };
    formSegments = function(lineData) {
      var i, m, pointA, pointB, ref, segmentEdges, segments;
      segments = [];
      segmentEdges = null;
      for (i = m = 0, ref = lineData.length; m < ref; i = m += 2) {
        pointA = lineData[i];
        pointB = lineData[i + 1];
        if ((segmentEdges != null) && isConnected(pointA, segmentEdges[segmentEdges.length - 1])) {
          segmentEdges.push(pointB);
        } else if ((segmentEdges != null) && isConnected(pointB, segmentEdges[segmentEdges.length - 1])) {
          segmentEdges.push(pointA);
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointB)) {
          segmentEdges.unshift(pointA);
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointA)) {
          segmentEdges.unshift(pointB);
        } else {
          segments.push(segmentEdges = [pointA, pointB]);
        }
      }
      return segments;
    };
    joinSegments = function(segments) {
      var i, j, pointA, pointB, segA, segB;
      segA = null;
      segB = null;
      pointA = null;
      pointB = null;
      i = segments.length;
      while (i--) {
        j = segments.length;
        while (--j > i) {
          segA = segments[i];
          segB = segments[j];
          pointA = segA[0];
          pointB = segB[0];
          if (isConnected(pointA, pointB)) {
            segB.reverse();
            segB.pop();
            segments[i] = segB.concat(segA);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[segA.length - 1];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB)) {
            segB.reverse();
            segB.unshift();
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[segA.length - 1];
          pointB = segB[0];
          if (isConnected(pointA, pointB)) {
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[0];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB)) {
            segments[i] = segB.concat(segA);
            segments.splice(j, 1);
            continue;
          }
        }
      }
      return segments;
    };
    cullShortEdges = function(segments) {
      var i, j, pointA, pointB, seg;
      i = segments.length;
      seg = [];
      pointA = pointB = null;
      while (i--) {
        seg = segments[i];
        j = seg.length - 1;
        while (j-- > 0) {
          pointA = seg[j];
          pointB = seg[j + 1];
          if (distance(pointA, pointB) < Config.MIN_EDGE_LENGTH) {
            pointA.cull = true;
          }
        }
      }
      i = segments.length;
      while (i--) {
        seg = segments[i];
        j = seg.length - 1;
        while (j-- > 0) {
          if (seg[j].cull) {
            seg.splice(j, 1);
          }
        }
      }
      return segments;
    };
    cullInlinePoints = function(segments) {
      var i, j, pointA, pointB, pointC, seg;
      seg = [];
      pointA = null;
      pointB = null;
      pointC = null;
      i = segments.length;
      while (i--) {
        seg = segments[i];
        j = seg.length - 2;
        while (j-- > 0 && seg.length > 2) {
          pointA = seg[j];
          pointB = seg[j + 1];
          pointC = seg[j + 2];
          if (isInline(pointA, pointB, pointC)) {
            seg.splice(j + 1, 1);
          }
        }
      }
      return segments;
    };
    reifyVectors = function(segments) {
      var i, len, m, pointA, pointB, results, segment, vector;
      results = [];
      for (m = 0, len = segments.length; m < len; m++) {
        segment = segments[m];
        results.push((function() {
          var len1, n, results1;
          results1 = [];
          for (i = n = 0, len1 = segment.length; n < len1; i = ++n) {
            pointA = segment[i];
            if (pointB = segment[i + 1]) {
              results1.push(vector = {
                x: pointA.x,
                y: pointA.y,
                dist: distance(pointA, pointB),
                angle: angle(pointA, pointB)
              });
            }
          }
          return results1;
        })());
      }
      return results;
    };
    reifySegments = function(set) {
      var dist, len, len1, m, n, results, segment, segmentVectors, vector;
      results = [];
      for (m = 0, len = set.length; m < len; m++) {
        segmentVectors = set[m];
        dist = 0;
        for (n = 0, len1 = segmentVectors.length; n < len1; n++) {
          vector = segmentVectors[n];
          dist += vector.dist;
        }
        results.push(segment = {
          vectors: segmentVectors,
          dist: dist
        });
      }
      return results;
    };
    cullShortSegments = function(set) {
      return set.filter(function(segment) {
        return segment.dist >= Config.MIN_SEGMENT_LENGTH;
      });
    };
    wrap = function(data) {
      return {
        process: function(fn) {
          return wrap(fn(data));
        },
        result: data
      };
    };
    isConnected = function(a, b) {
      var dX, dY;
      dX = Math.abs(a.x - b.x);
      dY = Math.abs(a.y - b.y);
      return dX < Config.CONNECTED_DISTANCE && dY < Config.CONNECTED_DISTANCE;
    };
    isInline = function(a, b, c) {
      var crossproduct, dotproduct, squaredlengthba;
      crossproduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y);
      if (Math.abs(crossproduct) > 0.01) {
        return false;
      }
      dotproduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y) * (b.y - a.y);
      if (dotproduct < 0) {
        return false;
      }
      squaredlengthba = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y);
      if (dotproduct > squaredlengthba) {
        return false;
      }
      return true;
    };
    distance = function(a, b) {
      var dx, dy;
      dx = b.x - a.x;
      dy = b.y - a.y;
      return Math.sqrt(dx * dx + dy * dy);
    };
    return angle = function(a, b) {
      return Math.atan2(b.y - a.y, b.x - a.x);
    };
  });

  Take(["FlowArrows:Arrow", "FlowArrows:Config", "FlowArrows:Containerize", "Mode"], function(Arrow, Config, Containerize, Mode) {
    return Make("FlowArrows:Segment", function(parentElm, segmentData, segmentName) {
      return Containerize(parentElm, function(scope) {
        var arrow, arrowCount, i, m, ref, results, segmentPosition, segmentSpacing, vector, vectorIndex, vectorPosition;
        if (Mode.dev) {
          scope.element.addEventListener("mouseover", function() {
            return console.log(segmentName);
          });
        }
        arrowCount = Math.max(1, Math.round(segmentData.dist / Config.SPACING));
        segmentSpacing = segmentData.dist / arrowCount;
        segmentPosition = 0;
        vectorPosition = 0;
        vectorIndex = 0;
        vector = segmentData.vectors[vectorIndex];
        results = [];
        for (i = m = 0, ref = arrowCount; 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
          while (vectorPosition > vector.dist) {
            vectorPosition -= vector.dist;
            vector = segmentData.vectors[++vectorIndex];
          }
          arrow = Arrow(scope.element, segmentData, segmentPosition, vectorPosition, vectorIndex);
          vectorPosition += segmentSpacing;
          segmentPosition += segmentSpacing;
          results.push(arrow);
        }
        return results;
      });
    });
  });

  Take(["FlowArrows:Config", "FlowArrows:Containerize", "FlowArrows:Segment"], function(Config, Containerize, Segment) {
    return Make("FlowArrows:Set", function(parentElm, setData) {
      return Containerize(parentElm, function(scope) {
        var child, childName, i, len, m, results, segmentData;
        results = [];
        for (i = m = 0, len = setData.length; m < len; i = ++m) {
          segmentData = setData[i];
          if (segmentData.dist < Config.FADE_LENGTH * 2) {
            throw new Error("You have a FlowArrows segment that is only " + (Math.round(segmentData.dist)) + " units long, which is clashing with your fade length of " + Config.FADE_LENGTH + " units. Please don't set MIN_SEGMENT_LENGTH less than FADE_LENGTH * 2.");
          }
          childName = "segment" + i;
          child = Segment(scope.element, segmentData, childName);
          results.push(scope[childName] = child);
        }
        return results;
      });
    });
  });

  Take(["Action", "Mode", "ParentElement", "Reaction", "SVG"], function(Action, Mode, ParentElement, Reaction, SVG) {
    if (typeof Mode.background === "string") {
      return SVG.style(ParentElement, "background-color", Mode.background);
    } else if (Mode.background === true) {
      Reaction("Background:Set", function(v) {
        return SVG.style(ParentElement, "background-color", "hsl(227, 5%, " + (v * 100) + "%)");
      });
      return Take("SceneReady", function() {
        return Action("Background:Set", .70);
      });
    } else {
      return SVG.style(ParentElement, "background-color", "transparent");
    }
  });

  Take(["GUI", "Mode", "Resize", "SVG", "TRS", "SVGReady"], function(GUI, Mode, Resize, SVG, TRS) {
    var g, hide, show;
    if (!Mode.nav) {
      return;
    }
    g = TRS(SVG.create("g", GUI.elm));
    SVG.create("rect", g, {
      x: -200,
      y: -30,
      width: 400,
      height: 60,
      rx: 30,
      fill: "#222",
      "fill-opacity": 0.9
    });
    SVG.create("text", g, {
      y: 22,
      textContent: "Click To Focus",
      "font-size": 20,
      fill: "#FFF",
      "text-anchor": "middle"
    });
    show = function() {
      return SVG.attrs(g, {
        style: "display: block"
      });
    };
    hide = function() {
      return SVG.attrs(g, {
        style: "display: none"
      });
    };
    Resize(function() {
      return TRS.abs(g, {
        x: SVG.svg.offsetWidth / 2
      });
    });
    window.addEventListener("focus", hide);
    window.addEventListener("touchstart", hide);
    window.addEventListener("blur", show);
    window.addEventListener("mousedown", function() {
      if (document.activeElement === SVG.svg) {
        return window.focus();
      }
    });
    window.focus();
    return hide();
  });

  Take(["ControlPanelLayout", "Gradient", "GUI", "Mode", "SVG", "Scope"], function(ControlPanelLayout, Gradient, GUI, Mode, SVG, Scope) {
    var CP, ControlPanel, bg, config, g, panelElms, panelHeight, panelRadius, panelWidth, resize, showing, vertical;
    CP = GUI.ControlPanel;
    config = Mode.controlPanel != null ? Mode.controlPanel : Mode.controlPanel = {};
    showing = false;
    panelRadius = CP.borderRadius + CP.pad * 2;
    vertical = true;
    panelWidth = 0;
    panelHeight = 0;
    Gradient.linear("CPGradient", false, "#5175bd", "#35488d");
    g = SVG.create("g", GUI.elm, {
      xControls: "",
      fontSize: 16,
      textAnchor: "middle"
    });
    bg = SVG.create("rect", g, {
      rx: panelRadius,
      fill: "url(#CPGradient)"
    });
    panelElms = Scope(SVG.create("g", g));
    panelElms.x = panelElms.y = CP.pad * 2;
    Take("SceneReady", function() {
      if (!showing) {
        return GUI.elm.removeChild(g);
      }
    });
    ControlPanel = Scope(g, function() {
      return {
        createElement: function(parent) {
          var elm;
          if (parent == null) {
            parent = null;
          }
          showing = true;
          return elm = SVG.create("g", parent || panelElms.element);
        },
        claimSpace: function(rect) {
          resize();
          if (vertical) {
            return rect.w -= panelWidth;
          } else {
            return rect.h -= panelHeight;
          }
        }
      };
    });
    resize = function() {
      var heightPad, panelBgX, panelBgY, size, view, widthPad, x, y;
      view = {
        w: SVG.svg.offsetWidth,
        h: SVG.svg.offsetHeight
      };
      vertical = config.vertical != null ? config.vertical : view.w >= view.h * 1.3;
      size = vertical ? ControlPanelLayout.vertical(view) : ControlPanelLayout.horizontal(view);
      panelWidth = size.w + CP.pad * 4;
      panelHeight = size.h + CP.pad * 4;
      widthPad = Math.abs(config.x) === 1 ? panelRadius : config.x != null ? 0 : vertical ? panelRadius : 0;
      heightPad = Math.abs(config.y) === 1 ? panelRadius : config.y != null ? 0 : !vertical ? panelRadius : 0;
      panelBgX = config.x === -1 ? -panelRadius : 0;
      panelBgY = config.y === -1 ? -panelRadius : 0;
      SVG.attrs(bg, {
        x: panelBgX,
        y: panelBgY,
        width: panelWidth + widthPad,
        height: panelHeight + heightPad
      });
      if ((config.x != null) || (config.y != null)) {
        x = (config.x || 0) / 2 + 0.5;
        y = (config.y || 0) / 2 + 0.5;
        ControlPanel.x = x * view.w - x * panelWidth | 0;
        return ControlPanel.y = y * view.h - y * panelHeight | 0;
      } else if (vertical) {
        ControlPanel.x = view.w - panelWidth | 0;
        return ControlPanel.y = view.h / 2 - panelHeight / 2 | 0;
      } else {
        ControlPanel.x = view.w / 2 - panelWidth / 2 | 0;
        return ControlPanel.y = view.h - panelHeight | 0;
      }
    };
    return Make("ControlPanel", ControlPanel);
  });

  Take(["GUI"], function(arg) {
    var GUI, checkRowHeight, scopes;
    GUI = arg.ControlPanel;
    scopes = [];
    Make("ControlPanelLayout", {
      addScope: function(scope) {
        return scopes.push(scope);
      },
      vertical: function(view) {
        var approxColumnHeight, columnWidth, columns, fullHeight, i, len, len1, len2, m, n, newSize, oldSize, panelWidth, q, scope, size, sizes, tallestColumn, xOffset, yOffset;
        if (!(view.h > 0 && scopes.length > 0)) {
          return {
            w: 0,
            h: 0
          };
        }
        sizes = [];
        columnWidth = 0;
        for (m = 0, len = scopes.length; m < len; m++) {
          scope = scopes[m];
          size = scope.getPreferredSize(null, view, true);
          sizes.push(size);
          columnWidth = Math.max(columnWidth, size.w);
        }
        fullHeight = 0;
        for (i = n = 0, len1 = scopes.length; n < len1; i = ++n) {
          scope = scopes[i];
          oldSize = sizes[i];
          newSize = scope.resize({
            w: columnWidth,
            h: oldSize.h
          }, view, true);
          sizes[i] = newSize;
          fullHeight += newSize.h;
        }
        columns = Math.ceil(fullHeight / view.h);
        approxColumnHeight = Math.ceil(fullHeight / columns);
        xOffset = 0;
        yOffset = 0;
        tallestColumn = 0;
        panelWidth = 0;
        for (i = q = 0, len2 = scopes.length; q < len2; i = ++q) {
          scope = scopes[i];
          scope.x = xOffset;
          scope.y = yOffset;
          size = sizes[i];
          yOffset += size.h;
          if (yOffset > approxColumnHeight) {
            xOffset += columnWidth;
            if (yOffset > view.h && yOffset > size.h) {
              tallestColumn = Math.max(tallestColumn, yOffset - size.h);
              scope.x = xOffset;
              scope.y = 0;
              yOffset = size.h;
            } else {
              tallestColumn = Math.max(tallestColumn, yOffset);
              yOffset = 0;
            }
          }
        }
        tallestColumn = Math.max(tallestColumn, yOffset);
        return {
          w: scope.x + columnWidth,
          h: tallestColumn
        };
      },
      horizontal: function(view) {
        var col, columnWidth, columnWidths, i, i1, len, len1, len2, len3, len4, m, n, newSize, oldSize, q, rowHeight, scope, scopeHeight, size, sizes, totalWidth, u, xOffset, yOffset;
        if (!(view.w > 0 && scopes.length > 0)) {
          return {
            w: 0,
            h: 0
          };
        }
        sizes = [];
        rowHeight = 0;
        for (m = 0, len = scopes.length; m < len; m++) {
          scope = scopes[m];
          size = scope.getPreferredSize(null, view, false);
          sizes.push(size);
          rowHeight = Math.max(rowHeight, size.h);
        }
        while (!checkRowHeight(rowHeight, sizes, view)) {
          rowHeight += GUI.unit;
        }
        for (i = n = 0, len1 = scopes.length; n < len1; i = ++n) {
          scope = scopes[i];
          oldSize = sizes[i];
          newSize = scope.resize({
            w: oldSize.w,
            h: rowHeight
          }, view, false);
          sizes[i] = newSize;
          rowHeight = Math.max(rowHeight, size.h);
        }
        while (!checkRowHeight(rowHeight, sizes, view)) {
          rowHeight += GUI.unit;
        }
        columnWidths = [0];
        yOffset = 0;
        col = 0;
        for (q = 0, len2 = sizes.length; q < len2; q++) {
          size = sizes[q];
          yOffset += size.h;
          if (yOffset > rowHeight) {
            col++;
            columnWidths[col] = 0;
            yOffset = size.h;
          }
          columnWidths[col] = Math.max(size.w, columnWidths[col]);
        }
        totalWidth = 0;
        for (u = 0, len3 = columnWidths.length; u < len3; u++) {
          columnWidth = columnWidths[u];
          totalWidth += columnWidth;
        }
        xOffset = 0;
        yOffset = 0;
        col = 0;
        for (i = i1 = 0, len4 = scopes.length; i1 < len4; i = ++i1) {
          scope = scopes[i];
          scope.x = xOffset;
          scope.y = yOffset;
          scopeHeight = sizes[i].h;
          yOffset += scopeHeight;
          if (yOffset > rowHeight) {
            scope.x = xOffset += columnWidths[col];
            scope.y = 0;
            yOffset = scopeHeight;
            col++;
          }
          scope.resize({
            w: columnWidths[col],
            h: scopeHeight
          }, view, false);
        }
        return {
          w: totalWidth,
          h: rowHeight
        };
      }
    });
    return checkRowHeight = function(rowHeight, sizes, view) {
      var len, m, size, xOffset, yOffset;
      xOffset = 0;
      yOffset = 0;
      for (m = 0, len = sizes.length; m < len; m++) {
        size = sizes[m];
        yOffset += size.h;
        if (yOffset > rowHeight) {
          xOffset += size.w;
          yOffset = size.h;
        }
      }
      if (xOffset + size.w < view.w) {
        return true;
      } else if (rowHeight > view.h / 2) {
        return true;
      } else {
        return false;
      }
    };
  });

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function(arg, Input, Registry, SVG, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "button", function(elm, props) {
      var bg, bgFill, bgc, blueBG, handlers, label, labelFill, lightBG, orangeBG, scope, tickBG, toClicked, toClicking, toHover, toNormal;
      handlers = [];
      bgFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(227, 16%, 24%)";
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        rx: GUI.borderRadius,
        strokeWidth: 2,
        fill: bgFill
      });
      label = SVG.create("text", elm, {
        textContent: props.name,
        fill: labelFill
      });
      bgc = blueBG = {
        r: 34,
        g: 46,
        b: 89
      };
      lightBG = {
        r: 133,
        g: 163,
        b: 224
      };
      orangeBG = {
        r: 255,
        g: 196,
        b: 46
      };
      tickBG = function(_bgc) {
        bgc = _bgc;
        return SVG.attrs(bg, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      toNormal = function(e, state) {
        return Tween(bgc, blueBG, .2, {
          tick: tickBG
        });
      };
      toHover = function(e, state) {
        if (!state.touch) {
          return Tween(bgc, lightBG, 0, {
            tick: tickBG
          });
        }
      };
      toClicking = function(e, state) {
        return Tween(bgc, orangeBG, 0, {
          tick: tickBG
        });
      };
      toClicked = function(e, state) {
        return Tween(bgc, lightBG, .2, {
          tick: tickBG
        });
      };
      Input(elm, {
        moveIn: toHover,
        dragIn: function(e, state) {
          if (state.clicking) {
            return toClicking();
          }
        },
        down: toClicking,
        up: toHover,
        moveOut: toNormal,
        dragOut: toNormal,
        click: function() {
          var handler, len, m, results;
          toClicked();
          results = [];
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            results.push(handler());
          }
          return results;
        }
      });
      return scope = {
        attach: function(props) {
          if (props.click != null) {
            return handlers.push(props.click);
          }
        },
        getPreferredSize: function() {
          var buttonWidth, size;
          buttonWidth = Math.max(GUI.unit, label.getComputedTextLength() + GUI.pad * 8);
          return size = {
            w: buttonWidth,
            h: GUI.unit
          };
        },
        resize: function(size) {
          var height;
          height = Math.min(GUI.unit, size.h);
          SVG.attrs(bg, {
            width: size.w - GUI.pad * 2,
            height: height - GUI.pad * 2
          });
          SVG.attrs(label, {
            x: size.w / 2,
            y: height / 2 + 6
          });
          return {
            w: size.w,
            h: height
          };
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(bg, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "black"
            });
          } else {
            SVG.attrs(bg, {
              fill: bgFill
            });
            return SVG.attrs(label, {
              fill: labelFill
            });
          }
        }
      };
    });
  });

  Take(["GUI", "Registry", "SVG"], function(arg, Registry, SVG) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "divider", function(elm, props) {
      var g, height, scope;
      g = SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        height: GUI.pad * 2,
        rx: 2,
        fill: "hsl(227, 45%, 24%)"
      });
      height = GUI.pad * 4;
      return scope = {
        getPreferredSize: function(size, view, vertical) {
          return {
            w: 0,
            h: 0
          };
        },
        resize: function(size, view, vertical) {
          var width;
          if (this.alpha = vertical) {
            width = size.w - GUI.pad * 2;
            SVG.attrs(g, {
              width: width
            });
            return {
              w: width,
              h: height
            };
          } else {
            return {
              w: 0,
              h: 0
            };
          }
        }
      };
    });
  });

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function(arg, Input, Registry, SVG, Tween) {
    var GUI, buttonHeight, buttonWidth;
    GUI = arg.ControlPanel;
    buttonWidth = GUI.unit * 1.8;
    buttonHeight = GUI.unit * 1.8;
    return Registry.set("Control", "pushButton", function(elm, props) {
      var bg, bgFill, bgc, blueBG, label, labelFill, lightBG, offHandlers, onHandlers, orangeBG, scope, tickBG, toClicking, toHover, toNormal;
      onHandlers = [];
      offHandlers = [];
      bgFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(227, 16%, 24%)";
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm, {
        strokeWidth: 2,
        fill: bgFill
      });
      label = SVG.create("text", elm, {
        textContent: props.name,
        fill: labelFill
      });
      bgc = blueBG = {
        r: 34,
        g: 46,
        b: 89
      };
      lightBG = {
        r: 133,
        g: 163,
        b: 224
      };
      orangeBG = {
        r: 255,
        g: 196,
        b: 46
      };
      tickBG = function(_bgc) {
        bgc = _bgc;
        return SVG.attrs(bg, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      toNormal = function(e, state) {
        return Tween(bgc, blueBG, .2, {
          tick: tickBG
        });
      };
      toHover = function(e, state) {
        return Tween(bgc, lightBG, 0, {
          tick: tickBG
        });
      };
      toClicking = function(e, state) {
        return Tween(bgc, orangeBG, 0, {
          tick: tickBG
        });
      };
      Input(elm, {
        moveIn: toHover,
        down: function() {
          var len, m, onHandler, results;
          toClicking();
          results = [];
          for (m = 0, len = onHandlers.length; m < len; m++) {
            onHandler = onHandlers[m];
            results.push(onHandler());
          }
          return results;
        },
        up: function() {
          var len, m, offHandler, results;
          toHover();
          results = [];
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            results.push(offHandler());
          }
          return results;
        },
        miss: function() {
          var len, m, offHandler, results;
          toNormal();
          results = [];
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            results.push(offHandler());
          }
          return results;
        },
        moveOut: toNormal
      });
      return scope = {
        attach: function(props) {
          if (props.on != null) {
            onHandlers.push(props.on);
          }
          if (props.off != null) {
            return offHandlers.push(props.off);
          }
        },
        getPreferredSize: function() {
          var size;
          buttonWidth = Math.max(buttonWidth, label.getComputedTextLength() + GUI.pad * 8);
          size = Math.max(buttonWidth, buttonHeight);
          return {
            w: size,
            h: size
          };
        },
        resize: function(space) {
          var extra, size;
          size = Math.max(buttonWidth, buttonHeight);
          extra = {
            x: space.w - size,
            y: space.h - size
          };
          SVG.attrs(bg, {
            x: GUI.pad + extra.x / 2,
            y: GUI.pad + extra.y / 2,
            width: size - GUI.pad * 2,
            height: size - GUI.pad * 2,
            rx: size / 2 - GUI.pad
          });
          SVG.attrs(label, {
            x: space.w / 2,
            y: space.h / 2 + 6
          });
          return {
            w: size,
            h: size
          };
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(bg, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "black"
            });
          } else {
            SVG.attrs(bg, {
              fill: bgFill
            });
            return SVG.attrs(label, {
              fill: labelFill
            });
          }
        }
      };
    });
  });

  Take(["Registry", "GUI", "SelectorButton", "Scope", "SVG"], function(Registry, arg, SelectorButton, Scope, SVG) {
    var GUI, idCounter;
    GUI = arg.ControlPanel;
    idCounter = 0;
    return Registry.set("Control", "selector", function(elm, props) {
      var activeButton, borderRect, buttonPreferredSizes, buttons, buttonsContainer, clip, clipRect, id, label, labelHeight, preferredSize, scope, setActive;
      id = "Selector" + (idCounter++);
      labelHeight = 0;
      preferredSize = {
        w: GUI.pad * 2,
        h: GUI.unit
      };
      buttons = [];
      activeButton = null;
      buttonPreferredSizes = [];
      clip = SVG.create("clipPath", SVG.defs, {
        id: id
      });
      clipRect = SVG.create("rect", clip, {
        rx: GUI.borderRadius,
        fill: "#FFF"
      });
      if (props.name != null) {
        label = SVG.create("text", elm, {
          textContent: props.name,
          fontSize: 16,
          fill: "hsl(220, 10%, 92%)"
        });
        preferredSize.h += labelHeight = 22;
      }
      borderRect = SVG.create("rect", elm, {
        rx: GUI.borderRadius + 2,
        fill: "rgb(34, 46, 89)"
      });
      buttonsContainer = Scope(SVG.create("g", elm, {
        clipPath: "url(#" + id + ")"
      }));
      buttonsContainer.x = GUI.pad;
      buttonsContainer.y = labelHeight;
      setActive = function(unclick) {
        if (typeof activeButton === "function") {
          activeButton();
        }
        return activeButton = unclick;
      };
      return scope = {
        button: function(props) {
          var bps, buttonElm, buttonScope;
          props.setActive = setActive;
          buttonElm = SVG.create("g", buttonsContainer.element);
          buttonScope = Scope(buttonElm, SelectorButton, props);
          buttons.push(buttonScope);
          bps = buttonScope.getPreferredSize();
          buttonPreferredSizes.push(bps);
          preferredSize.w += bps.w;
          return buttonScope;
        },
        getPreferredSize: function() {
          var button, len, m, size, xOffset;
          xOffset = 0;
          for (m = 0, len = buttons.length; m < len; m++) {
            button = buttons[m];
            button.x = xOffset;
            xOffset += button.resize(1, xOffset);
          }
          return size = {
            w: xOffset,
            h: GUI.unit + labelHeight
          };
        },
        resize: function(arg1) {
          var button, h, innerHeight, innerWidth, len, m, upscale, w, xOffset;
          w = arg1.w, h = arg1.h;
          innerWidth = w - GUI.pad * 2;
          innerHeight = h - GUI.pad * 2;
          upscale = w / preferredSize.w;
          xOffset = 0;
          for (m = 0, len = buttons.length; m < len; m++) {
            button = buttons[m];
            button.x = xOffset;
            xOffset += button.resize(upscale, xOffset);
          }
          SVG.attrs(clipRect, {
            x: 1,
            y: GUI.pad + 1,
            width: innerWidth - 2,
            height: GUI.unit - GUI.pad * 2 - 2
          });
          SVG.attrs(borderRect, {
            x: GUI.pad - 1,
            y: GUI.pad + labelHeight - 1,
            width: innerWidth + 2,
            height: GUI.unit - GUI.pad * 2 + 2
          });
          if (label != null) {
            SVG.attrs(label, {
              x: w / 2,
              y: 18
            });
          }
          return {
            w: w,
            h: h
          };
        }
      };
    });
  });

  Take(["GUI", "Input", "SVG", "Tween"], function(arg, Input, SVG, Tween) {
    var GUI, active;
    GUI = arg.ControlPanel;
    active = null;
    return Make("SelectorButton", function(elm, props) {
      var attachClick, bg, blueBG, click, curBG, handlers, highlighting, isActive, label, labelFill, lightBG, orangeBG, preferredSize, scope, tickBG, toActive, toClicking, toHover, toNormal, unclick, whiteBG;
      preferredSize = {
        w: null,
        h: GUI.unit
      };
      handlers = [];
      isActive = false;
      highlighting = false;
      labelFill = "hsl(227, 16%, 24%)";
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm);
      label = SVG.create("text", elm, {
        textContent: props.name,
        fill: labelFill
      });
      curBG = whiteBG = {
        r: 233,
        g: 234,
        b: 237
      };
      lightBG = {
        r: 142,
        g: 196,
        b: 96
      };
      orangeBG = {
        r: 255,
        g: 196,
        b: 46
      };
      blueBG = {
        r: 183,
        g: 213,
        b: 255
      };
      tickBG = function(_curBG) {
        curBG = _curBG;
        if (highlighting) {
          if (isActive) {
            return SVG.attrs(bg, {
              fill: "url(#MidHighlightGradient)"
            });
          } else {
            return SVG.attrs(bg, {
              fill: "url(#LightHighlightGradient)"
            });
          }
        } else {
          return SVG.attrs(bg, {
            fill: "rgb(" + (curBG.r | 0) + "," + (curBG.g | 0) + "," + (curBG.b | 0) + ")"
          });
        }
      };
      tickBG(whiteBG);
      toNormal = function(e, state) {
        return Tween(curBG, whiteBG, .2, {
          tick: tickBG
        });
      };
      toHover = function(e, state) {
        if (!state.touch && !isActive) {
          return Tween(curBG, blueBG, 0, {
            tick: tickBG
          });
        }
      };
      toClicking = function(e, state) {
        return Tween(curBG, orangeBG, 0, {
          tick: tickBG
        });
      };
      toActive = function(e, state) {
        return Tween(curBG, lightBG, .2, {
          tick: tickBG
        });
      };
      unclick = function() {
        toNormal();
        return isActive = false;
      };
      click = function(e, state) {
        var handler, len, m, results;
        props.setActive(unclick);
        isActive = true;
        toActive();
        results = [];
        for (m = 0, len = handlers.length; m < len; m++) {
          handler = handlers[m];
          results.push(handler());
        }
        return results;
      };
      Input(elm, {
        moveIn: function(e, state) {
          if (!isActive) {
            return toHover(e, state);
          }
        },
        dragIn: function(e, state) {
          if (state.clicking && !isActive) {
            return toClicking(e, state);
          }
        },
        down: function(e, state) {
          if (!isActive) {
            return toClicking(e, state);
          }
        },
        up: function(e, state) {
          if (!isActive) {
            return toHover(e, state);
          }
        },
        moveOut: function(e, state) {
          if (!isActive) {
            return toNormal(e, state);
          }
        },
        dragOut: function(e, state) {
          if (!isActive) {
            return toNormal(e, state);
          }
        },
        click: function(e, state) {
          if (!isActive) {
            return click(e, state);
          }
        }
      });
      attachClick = function(cb) {
        return handlers.push(cb);
      };
      if (props.click != null) {
        attachClick(props.click);
      }
      Take("SceneReady", function() {
        if (props.active) {
          return click();
        }
      });
      return scope = {
        click: attachClick,
        getPreferredSize: function() {
          preferredSize.w = Math.max(GUI.unit, label.getComputedTextLength() + GUI.pad * 8);
          return preferredSize;
        },
        resize: function(upscale) {
          var innerHeight, innerWidth;
          innerWidth = Math.ceil(preferredSize.w * upscale);
          innerHeight = preferredSize.h - GUI.pad * 2;
          SVG.attrs(bg, {
            x: 1,
            y: GUI.pad + 1,
            width: innerWidth - 2,
            height: innerHeight - 2
          });
          SVG.attrs(label, {
            x: innerWidth / 2,
            y: innerHeight / 2 + 6 + GUI.pad
          });
          return innerWidth;
        },
        _highlight: function(enable) {
          if (highlighting = enable) {
            SVG.attrs(label, {
              fill: "black"
            });
          } else {
            SVG.attrs(label, {
              fill: labelFill
            });
          }
          return tickBG(curBG);
        }
      };
    });
  });

  Take(["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], function(Registry, arg, Input, SVG, TRS, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "slider", function(elm, props) {
      var bgc, blueBG, handleDrag, handlers, label, labelFill, lightBG, orangeBG, range, scope, startDrag, thumb, thumbBG, thumbBGFill, tickBG, toClicked, toClicking, toHover, toMissed, toNormal, track, trackFill, update, v;
      handlers = [];
      v = 0;
      range = 0;
      startDrag = 0;
      trackFill = "hsl(227, 45%, 24%)";
      thumbBGFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(227, 16%, 24%)";
      SVG.attrs(elm, {
        ui: true
      });
      track = TRS(SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        strokeWidth: 2,
        fill: trackFill,
        stroke: "hsl(227, 45%, 24%)"
      }));
      thumb = TRS(SVG.create("g", elm));
      thumbBG = SVG.create("rect", thumb, {
        x: GUI.pad,
        y: GUI.pad,
        strokeWidth: 2,
        fill: thumbBGFill
      });
      label = SVG.create("text", thumb, {
        textContent: props.name,
        fill: labelFill
      });
      bgc = blueBG = {
        r: 34,
        g: 46,
        b: 89
      };
      lightBG = {
        r: 133,
        g: 163,
        b: 224
      };
      orangeBG = {
        r: 255,
        g: 196,
        b: 46
      };
      tickBG = function(_bgc) {
        bgc = _bgc;
        return SVG.attrs(thumbBG, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      update = function(V) {
        if (V != null) {
          v = Math.max(0, Math.min(1, V));
        }
        return TRS.abs(thumb, {
          x: v * range
        });
      };
      toNormal = function(e, state) {
        return Tween(bgc, blueBG, .2, {
          tick: tickBG
        });
      };
      toHover = function(e, state) {
        if (!state.touch) {
          return Tween(bgc, lightBG, 0, {
            tick: tickBG
          });
        }
      };
      toClicking = function(e, state) {
        return Tween(bgc, orangeBG, 0, {
          tick: tickBG
        });
      };
      toClicked = function(e, state) {
        return Tween(bgc, lightBG, .2, {
          tick: tickBG
        });
      };
      toMissed = function(e, state) {
        return Tween(bgc, blueBG, .2, {
          tick: tickBG
        });
      };
      handleDrag = function(e, state) {
        var handler, len, m, results;
        if (state.clicking) {
          update(e.clientX / range - startDrag);
          results = [];
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            results.push(handler(v));
          }
          return results;
        }
      };
      Input(elm, {
        moveIn: toHover,
        dragIn: function(e, state) {
          if (state.clicking) {
            return toClicking();
          }
        },
        down: function(e) {
          toClicking();
          return startDrag = e.clientX / range - v;
        },
        moveOut: toNormal,
        miss: toMissed,
        drag: handleDrag,
        dragOther: handleDrag,
        click: toClicked
      });
      return scope = {
        attach: function(props) {
          if (props.change != null) {
            handlers.push(props.change);
          }
          if (props.value != null) {
            return update(props.value);
          }
        },
        getPreferredSize: function() {
          var size;
          return size = {
            w: GUI.width,
            h: GUI.unit
          };
        },
        resize: function(size) {
          var height, labelWidth;
          labelWidth = Math.max(GUI.unit, label.getComputedTextLength() + GUI.pad * 8);
          height = Math.min(GUI.unit, size.h);
          range = size.w - GUI.pad * 2 - labelWidth;
          update();
          SVG.attrs(track, {
            width: size.w - GUI.pad * 2,
            height: height - GUI.pad * 2,
            rx: (height - GUI.pad * 2) / 2
          });
          SVG.attrs(thumbBG, {
            width: labelWidth,
            height: height - GUI.pad * 2,
            rx: (height - GUI.pad * 2) / 2
          });
          SVG.attrs(label, {
            x: GUI.pad + labelWidth / 2,
            y: height / 2 + 6
          });
          return {
            w: size.w,
            h: height
          };
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(track, {
              fill: "url(#DarkHighlightGradient)"
            });
            SVG.attrs(thumbBG, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "black"
            });
          } else {
            SVG.attrs(track, {
              fill: trackFill
            });
            SVG.attrs(thumbBG, {
              fill: thumbBGFill
            });
            return SVG.attrs(label, {
              fill: labelFill
            });
          }
        }
      };
    });
  });

  Take(["Mode"], function(Mode) {
    if (!Mode.dev) {
      window.addEventListener("contextmenu", function(e) {
        return e.preventDefault();
      });
    }
    window.addEventListener("dragstart", function(e) {
      return e.preventDefault();
    });
    if (Mode.nav) {
      window.addEventListener("scroll", function(e) {
        return e.preventDefault();
      });
      return window.addEventListener("touchmove", function(e) {
        return e.preventDefault();
      });
    }
  });

  Take(["GUI", "Mode", "ParentElement", "SVG", "Tick", "SVGReady"], function(GUI, Mode, ParentElement, SVG, Tick) {
    var avgList, avgWindow, count, fps, freq, prev, ref, text, total;
    freq = .2;
    count = freq;
    avgWindow = 1;
    avgList = [];
    total = 0;
    fps = 1;
    text = null;
    Make("FPS", function() {
      return fps;
    });
    if (Mode.dev) {
      text = document.createElement("div");
      text.setAttribute("svga-fps", "true");
      if (ParentElement === document.body) {
        document.body.insertBefore(text, document.body.firstChild);
      } else {
        prev = ParentElement.previousSibling;
        if (prev != null ? typeof prev.hasAttribute === "function" ? prev.hasAttribute("svga-fps") : void 0 : void 0) {
          text = prev;
        } else {
          if ((ref = ParentElement.parentNode) != null) {
            ref.insertBefore(text, ParentElement);
          }
        }
      }
    }
    return Tick(function(time, dt) {
      var fpsDisplay;
      avgList.push(dt);
      total += dt;
      while (total > avgWindow && avgList.length > 0) {
        total -= avgList.shift();
      }
      fps = avgList.length / total;
      fps = Math.min(60, fps);
      if (isNaN(fps)) {
        fps = 2;
      }
      count += dt;
      if (Mode.dev && count >= freq) {
        count -= freq;
        fpsDisplay = fps < 30 ? fps.toFixed(1) : Math.ceil(fps);
        text.textContent = fpsDisplay;
        return text.style.color = fps <= 5 ? "#C00" : fps <= 10 ? "#E60" : "rgba(0,0,0,0.1)";
      }
    });
  });

  Take(["SVG", "SVGReady"], function(SVG) {
    var GUI;
    return Make("GUI", GUI = {
      elm: SVG.create("g", SVG.svg, {
        xGui: ""
      }),
      ControlPanel: {
        width: 200,
        unit: 42,
        pad: 3,
        borderRadius: 4,
        light: "hsl(220, 45%, 50%)",
        dark: "hsl(227, 45%, 35%)"
      }
    });
  });

  Take(["ControlPanel", "Mode", "Nav", "Resize", "SVG", "SceneReady"], function(ControlPanel, Mode, Nav, Resize, SVG) {
    return Resize(function() {
      var rect;
      rect = {
        x: 0,
        y: 0,
        w: SVG.svg.offsetWidth,
        h: SVG.svg.offsetHeight
      };
      ControlPanel.claimSpace(rect);
      if (Mode.nav) {
        return Nav.assignSpace(rect);
      }
    });
  });

  Take(["Reaction", "SVG", "SceneReady"], function(Reaction, SVG) {
    Reaction("Root:Show", function() {
      return SVG.root._scope.show(1);
    });
    return Reaction("Root:Hide", function() {
      return SVG.root._scope.hide(1);
    });
  });

  Take(["Mode", "RAF", "SVG", "Tween", "AllReady"], function(Mode, RAF, SVG, Tween) {
    if (Mode.dev) {
      return RAF(function() {
        return SVG.svg.style.opacity = 1;
      });
    } else {
      return Tween(0, 1, .5, function(v) {
        return SVG.svg.style.opacity = v;
      });
    }
  });

  Take(["Mode", "Nav"], function(Mode, Nav) {
    if (!Mode.nav) {
      return;
    }
    window.addEventListener("gesturestart", function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return Nav.startScale();
      }
    });
    return window.addEventListener("gesturechange", function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return Nav.scale(e.scale);
      }
    });
  });

  Take(["KeyMe", "Mode", "Nav", "Tick"], function(KeyMe, Mode, Nav, Tick) {
    var accel, decel, getAccel, maxVel, vel;
    if (!Mode.nav) {
      return;
    }
    decel = 1.25;
    maxVel = {
      xy: 10,
      z: 0.05
    };
    accel = {
      xy: 0.7,
      z: 0.004
    };
    vel = {
      a: 0,
      d: 0,
      z: 0
    };
    Tick(function() {
      var down, inputX, inputY, inputZ, left, minus, plus, right, up;
      left = KeyMe.pressing["left"];
      right = KeyMe.pressing["right"];
      up = KeyMe.pressing["up"];
      down = KeyMe.pressing["down"];
      plus = KeyMe.pressing["equals"];
      minus = KeyMe.pressing["minus"];
      inputX = getAccel(left, right);
      inputY = getAccel(up, down);
      inputZ = getAccel(plus, minus);
      if (inputZ === 0) {
        vel.z /= decel;
      }
      vel.z = Math.max(-maxVel.z, Math.min(maxVel.z, vel.z + accel.z * inputZ));
      if (inputX === 0 && inputY === 0) {
        vel.d /= decel;
      }
      if (inputY || inputX) {
        vel.a = Math.atan2(inputY, inputX);
      }
      vel.d = Math.min(maxVel.xy, vel.d + accel.xy * (Math.abs(inputX) + Math.abs(inputY)));
      if (!(Math.abs(vel.d) > 0.01 || Math.abs(vel.z) > 0.01)) {
        return;
      }
      return Nav.by({
        x: Math.cos(vel.a) * vel.d,
        y: Math.sin(vel.a) * vel.d,
        z: vel.z
      });
    });
    return getAccel = function(pos, neg) {
      if (pos && !neg) {
        return 1;
      }
      if (neg && !pos) {
        return -1;
      }
      return 0;
    };
  });

  Take(["Input", "Mode", "Nav"], function(Input, Mode, Nav) {
    var calls, down, drag, dragging, up;
    if (!Mode.nav) {
      return;
    }
    dragging = false;
    down = function(e) {
      e.preventDefault();
      if (Nav.eventInside(e)) {
        return dragging = true;
      }
    };
    drag = function(e, state) {
      if (dragging && state.down) {
        return Nav.by({
          x: state.deltaX,
          y: state.deltaY
        });
      }
    };
    up = function() {
      return dragging = false;
    };
    calls = {
      down: down,
      downOther: down,
      drag: drag,
      dragOther: drag,
      up: up,
      upOther: up
    };
    Input(document, calls, true, false);
    document.addEventListener("dblclick", function(e) {
      if (e.button !== 0) {
        return;
      }
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return Nav.to({
          x: 0,
          y: 0,
          z: 0
        });
      }
    });
    return document.addEventListener("wheel", function(e) {
      if (e.button !== 0) {
        return;
      }
      if (Nav.eventInside(e)) {
        e.preventDefault();
        if (e.deltaMode === WheelEvent.DOM_DELTA_PIXEL) {
          return Nav.by({
            z: -e.deltaY / 500
          });
        } else {
          return Nav.by({
            z: -e.deltaY / 20
          });
        }
      }
    });
  });

  Take(["Mode", "RAF", "Resize", "SVG", "Tween", "SceneReady"], function(Mode, RAF, Resize, SVG, Tween) {
    var Nav, center, dist, distTo, height, initialSize, limit, ox, oy, pos, render, requestRender, scaleStartPosZ, tween, width, xLimit, yLimit, zLimit;
    if (!Mode.nav) {
      Make("Nav", false);
      width = SVG.attr(SVG.svg, "width");
      height = SVG.attr(SVG.svg, "height");
      if (!((width != null) && (height != null))) {
        throw new Error("This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash.");
      }
      return Resize(function() {
        var hFrac, scale, wFrac, x, y;
        wFrac = SVG.svg.offsetWidth / width;
        hFrac = SVG.svg.offsetHeight / height;
        scale = Math.min(wFrac, hFrac);
        x = (SVG.svg.offsetWidth - width * scale) / (2 * scale);
        y = (SVG.svg.offsetHeight - height * scale) / (2 * scale);
        return SVG.attr(SVG.root, "transform", "scale(" + scale + ") translate(" + x + ", " + y + ")");
      });
    } else {
      SVG.attrs(SVG.svg, {
        width: null,
        height: null
      });
      pos = {
        x: 0,
        y: 0,
        z: 0
      };
      center = {
        x: 0,
        y: 0,
        z: 1
      };
      xLimit = {};
      yLimit = {};
      zLimit = {
        min: -0.5,
        max: 3
      };
      scaleStartPosZ = 0;
      tween = null;
      initialSize = root.getBoundingClientRect();
      if (!(initialSize.width > 0 && initialSize.height > 0)) {
        return;
      }
      ox = root._scope.x - initialSize.left - initialSize.width / 2;
      oy = root._scope.y - initialSize.top - initialSize.height / 2;
      xLimit.max = initialSize.width / 2;
      yLimit.max = initialSize.height / 2;
      xLimit.min = -xLimit.max;
      yLimit.min = -yLimit.max;
      requestRender = function() {
        return RAF(render, true);
      };
      render = function() {
        var z;
        z = center.z * Math.pow(2, pos.z);
        return SVG.attr(root, "transform", "translate(" + center.x + "," + center.y + ") scale(" + z + ") translate(" + (pos.x + ox) + "," + (pos.y + oy) + ")");
      };
      limit = function(l, v) {
        return Math.min(l.max, Math.max(l.min, v));
      };
      Make("Nav", Nav = {
        to: function(p) {
          var time, timeX, timeY, timeZ;
          if (tween != null) {
            Tween.cancel(tween);
          }
          timeX = .03 * Math.sqrt(Math.abs(p.x - pos.x)) || 0;
          timeY = .03 * Math.sqrt(Math.abs(p.y - pos.y)) || 0;
          timeZ = .7 * Math.sqrt(Math.abs(p.z - pos.z)) || 0;
          time = Math.sqrt(timeX * timeX + timeY * timeY + timeZ * timeZ);
          return tween = Tween(pos, p, time, {
            mutate: true,
            tick: render
          });
        },
        by: function(p) {
          var scale;
          if (tween != null) {
            Tween.cancel(tween);
          }
          if (p.z != null) {
            pos.z = limit(zLimit, pos.z + p.z);
          }
          scale = center.z * Math.pow(2, pos.z);
          if (p.x != null) {
            pos.x = limit(xLimit, pos.x + p.x / scale);
          }
          if (p.y != null) {
            pos.y = limit(yLimit, pos.y + p.y / scale);
          }
          return requestRender();
        },
        at: function(p) {
          var scale;
          if (tween != null) {
            Tween.cancel(tween);
          }
          if (p.z != null) {
            pos.z = limit(zLimit, p.z);
          }
          scale = center.z * Math.pow(2, pos.z);
          if (p.x != null) {
            pos.x = limit(xLimit, p.x / scale);
          }
          if (p.y != null) {
            pos.y = limit(yLimit, p.y / scale);
          }
          return requestRender();
        },
        startScale: function() {
          return scaleStartPosZ = pos.z;
        },
        scale: function(s) {
          if (tween != null) {
            Tween.cancel(tween);
          }
          pos.z = limit(zLimit, Math.log2(Math.pow(2, scaleStartPosZ) * s));
          return requestRender();
        },
        eventInside: function(e) {
          var ref;
          if (((ref = e.touches) != null ? ref.length : void 0) > 0) {
            e = e.touches[0];
          }
          return e.target === document.body || e.target === SVG.svg || SVG.root.contains(e.target);
        },
        assignSpace: function(rect) {
          var c, hFrac, wFrac;
          wFrac = rect.w / initialSize.width;
          hFrac = rect.h / initialSize.height;
          c = {
            x: rect.x + rect.w / 2,
            y: rect.y + rect.h / 2,
            z: .9 * Math.min(wFrac, hFrac)
          };
          if (center.x === 0) {
            center = c;
            return render();
          } else {
            return Tween(center, c, 0.5, {
              mutate: true,
              tick: render
            });
          }
        }
      });
      distTo = function(a, b) {
        var dx, dy, dz;
        dx = a.x - b.x;
        dy = a.y - b.y;
        return dz = 200 * a.z - b.z;
      };
      return dist = function(x, y, z) {
        if (z == null) {
          z = 0;
        }
        return Math.sqrt(x * x + y * y + z * z);
      };
    }
  });

  Take(["Mode", "Nav", "SVG"], function(Mode, Nav, SVG) {
    var gesture;
    if (!Mode.nav) {
      return;
    }
    if (!(navigator.msMaxTouchPoints && navigator.msMaxTouchPoints > 1)) {
      return;
    }
    gesture = new MSGesture();
    gesture.target = SVG.svg;
    gesture.target.addEventListener("pointerdown", function(e) {
      if (Nav.eventInside(e)) {
        return gesture.addPointer(e.pointerId);
      }
    });
    return gesture.target.addEventListener("MSGestureChange", function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return Nav.by({
          z: Math.log2(e.scale)
        });
      }
    });
  });

  Take(["Mode", "Nav"], function(Mode, Nav) {
    var cloneTouches, distTouches, lastTouches, touchMove, touchStart;
    if (!Mode.nav) {
      return;
    }
    lastTouches = null;
    window.addEventListener("touchstart", touchStart = function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return cloneTouches(e);
      }
    });
    window.addEventListener("touchmove", touchMove = function(e) {
      var a, b;
      if (Nav.eventInside(e)) {
        e.preventDefault();
        if (e.touches.length !== lastTouches.length) {

        } else if (e.touches.length > 1) {
          a = distTouches(lastTouches);
          b = distTouches(e.touches);
          Nav.by({
            z: (b - a) / 200
          });
        } else {
          Nav.by({
            x: e.touches[0].clientX - lastTouches[0].clientX,
            y: e.touches[0].clientY - lastTouches[0].clientY
          });
        }
        return cloneTouches(e);
      }
    });
    cloneTouches = function(e) {
      var t;
      return lastTouches = (function() {
        var len, m, ref, results;
        ref = e.touches;
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          t = ref[m];
          results.push({
            clientX: t.clientX,
            clientY: t.clientY
          });
        }
        return results;
      })();
    };
    return distTouches = function(touches) {
      var a, b, dx, dy;
      a = touches[0];
      b = touches[1];
      dx = a.clientX - b.clientX;
      dy = a.clientY - b.clientY;
      return Math.sqrt(dx * dx + dy * dy);
    };
  });

  if ((base = SVGElement.prototype).contains == null) {
    base.contains = function(node) {
      while (node != null) {
        if (this === node) {
          return true;
        }
        node = node.parentNode;
      }
      return false;
    };
  }

  if (Math.log2 == null) {
    Math.log2 = function(x) {
      return Math.log(x) / Math.LN2;
    };
  }

  Take(["Action", "ControlPanel", "Reaction"], function(Action, ControlPanel, Reaction) {
    var root, schematic, update;
    root = true;
    schematic = false;
    Reaction("ControlPanel:Hide", ControlPanel.hide);
    Reaction("ControlPanel:Hide", ControlPanel.show);
    update = function() {
      if (root && !schematic) {
        return Action("ControlPanel:Show");
      } else {
        return Action("ControlPanel:Hide");
      }
    };
    Reaction("Schematic:Hide", function() {
      return update(schematic = false);
    });
    Reaction("Schematic:Show", function() {
      return update(schematic = true);
    });
    Reaction("Root:Hide", function() {
      return update(root = false);
    });
    return Reaction("Root:Show", function() {
      return update(root = true);
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var showing;
    showing = false;
    Reaction("FlowArrows:Hide", function() {
      return showing = false;
    });
    Reaction("FlowArrows:Show", function() {
      return showing = true;
    });
    Reaction("FlowArrows:Toggle", function() {
      return Action(showing ? "FlowArrows:Hide" : "FlowArrows:Show");
    });
    return Take("AllReady", function() {
      return Action("FlowArrows:Show");
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var showing;
    showing = false;
    Reaction("Help:Hide", function() {
      return showing = false;
    });
    Reaction("Help:Show", function() {
      return showing = true;
    });
    Reaction("Help:Toggle", function() {
      return Action(showing ? "Help:Hide" : "Help:Show");
    });
    return Reaction("Settings:Show", function() {
      return Action("Help:Hide");
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var showing;
    showing = false;
    Reaction("Labels:Hide", function() {
      return showing = false;
    });
    Reaction("Labels:Show", function() {
      return showing = true;
    });
    return Reaction("Labels:Toggle", function() {
      return Action(showing ? "Labels:Hide" : "Labels:Show");
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var help, settings, update;
    help = false;
    settings = false;
    update = function() {
      if (help || settings) {
        return Action("Root:Hide");
      } else {
        return Action("Root:Show");
      }
    };
    Reaction("Help:Show", function() {
      return update(help = true);
    });
    Reaction("Help:Hide", function() {
      return update(help = false);
    });
    Reaction("Settings:Show", function() {
      return update(settings = true);
    });
    return Reaction("Settings:Hide", function() {
      return update(settings = false);
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var schematicMode;
    schematicMode = true;
    Reaction("Schematic:Hide", function() {
      return schematicMode = false;
    });
    Reaction("Schematic:Show", function() {
      return schematicMode = true;
    });
    Reaction("Schematic:Toggle", function() {
      return Action(schematicMode ? "Schematic:Hide" : "Schematic:Show");
    });
    return Take("AllReady", function() {
      return Action("Schematic:Hide");
    });
  });

  Take(["Action", "Reaction"], function(Action, Reaction) {
    var showing;
    showing = false;
    Reaction("Settings:Hide", function() {
      return showing = false;
    });
    Reaction("Settings:Show", function() {
      return showing = true;
    });
    Reaction("Settings:Toggle", function() {
      return Action(showing ? "Settings:Hide" : "Settings:Show");
    });
    return Reaction("Help:Show", function() {
      return Action("Settings:Hide");
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var alpha, element, placeholder;
      ScopeCheck(scope, "alpha");
      element = scope.element;
      placeholder = SVG.create("g");
      alpha = 1;
      return Object.defineProperty(scope, 'alpha', {
        get: function() {
          return alpha;
        },
        set: function(val) {
          if (val === true) {
            val = 1;
          }
          if (!val) {
            val = 0;
          }
          if (alpha !== val) {
            SVG.style(element, "opacity", alpha = val);
            if (alpha > 0) {
              if (placeholder.parentNode != null) {
                return placeholder.parentNode.replaceChild(element, placeholder);
              }
            } else {
              if (element.parentNode != null) {
                return element.parentNode.replaceChild(placeholder, element);
              }
            }
          }
        }
      });
    });
  });

  Take(["Reaction", "Registry", "Tick"], function(Reaction, Registry, Tick) {
    return Registry.add("ScopeProcessor", function(scope) {
      var animate, running, startTime;
      if (scope.animate == null) {
        return;
      }
      running = false;
      startTime = 0;
      animate = scope.animate;
      scope.animate = function() {
        throw new Error("@animate() is called by the system. Please don't call it yourself.");
      };
      Tick(function(time, dt) {
        if (!running) {
          return;
        }
        if (startTime == null) {
          startTime = time;
        }
        return animate.call(scope, time - startTime, dt);
      });
      Reaction("Schematic:Hide", function() {
        startTime = null;
        return running = true;
      });
      return Reaction("Schematic:Show", function() {
        return running = false;
      });
    });
  });

  Take(["Reaction", "Registry"], function(Reaction, Registry) {
    return Registry.add("ScopeProcessor", function(scope) {
      Reaction("Schematic:Hide", function() {
        return typeof scope.animateMode === "function" ? scope.animateMode() : void 0;
      });
      return Reaction("Schematic:Show", function() {
        return typeof scope.schematicMode === "function" ? scope.schematicMode() : void 0;
      });
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var paths;
      ScopeCheck(scope, "dash");
      paths = scope.element.querySelectorAll("path");
      scope.dash = function(v) {
        var len, m, path, results;
        results = [];
        for (m = 0, len = paths.length; m < len; m++) {
          path = paths[m];
          results.push(SVG.attrs(path, {
            "stroke-dasharray": v
          }));
        }
        return results;
      };
      scope.dash.manifold = function() {
        return scope.dash("50 5 10 5 10 5");
      };
      return scope.dash.pilot = function() {
        return scope.dash("6 6");
      };
    });
  });

  Take(["Mode", "Registry", "ScopeCheck", "Scope", "SVG"], function(Mode, Registry, ScopeCheck, Scope, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      ScopeCheck(scope, "debug");
      return Object.defineProperty(scope, 'debug', {
        get: function() {
          return {
            point: function(color) {
              var point;
              if (Mode.dev) {
                point = Scope(SVG.create("g", scope.element));
                if (color != null) {
                  SVG.create("rect", point.element, {
                    fill: "#000",
                    x: 0,
                    y: 0,
                    width: 10,
                    height: 10
                  });
                }
                if (color != null) {
                  SVG.create("rect", point.element, {
                    fill: color,
                    x: 0,
                    y: 0,
                    width: 9,
                    height: 9
                  });
                }
                SVG.create("rect", point.element, {
                  fill: "#000",
                  x: -1,
                  y: -1,
                  width: 2,
                  height: 2
                });
                SVG.create("rect", point.element, {
                  fill: "#FFF",
                  x: -.5,
                  y: -.5,
                  width: 1,
                  height: 1
                });
                SVG.create("rect", point.element, {
                  fill: "#FFF",
                  x: 1,
                  y: -1,
                  width: 48,
                  height: 2
                });
                SVG.create("rect", point.element, {
                  fill: "#F00",
                  x: 1,
                  y: -.5,
                  width: 48,
                  height: 1
                });
                SVG.create("rect", point.element, {
                  fill: "#000",
                  x: -1,
                  y: 1,
                  width: 2,
                  height: 48
                });
                SVG.create("rect", point.element, {
                  fill: "#0F0",
                  x: -.5,
                  y: 1,
                  width: 1,
                  height: 48
                });
                return point;
              }
            }
          };
        }
      });
    });
  });

  Take(["Registry"], function(Registry) {
    return Registry.add("ScopeProcessor", function(scope) {
      scope.getPressureColor = function() {
        throw new Error("@getPressureColor() has been removed. Please Take and use Pressure() instead.");
      };
      scope.setText = function() {
        throw new Error("@setText(x) has been removed. Please @text = x instead.");
      };
      Object.defineProperty(scope, "cx", {
        get: function() {
          throw new Error("cx has been removed.");
        }
      });
      Object.defineProperty(scope, "cy", {
        get: function() {
          throw new Error("cy has been removed.");
        }
      });
      return Object.defineProperty(scope, "turns", {
        get: function() {
          throw new Error("turns has been removed. Please use @rotation instead.");
        }
      });
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var childPathFill, childPathStroke, fill, stroke;
      ScopeCheck(scope, "stroke", "fill");
      childPathStroke = childPathFill = scope.element.querySelector("path");
      stroke = null;
      Object.defineProperty(scope, 'stroke', {
        get: function() {
          return stroke;
        },
        set: function(val) {
          if (stroke !== val) {
            SVG.attr(scope.element, "stroke", stroke = val);
            if (childPathStroke != null) {
              SVG.attr(childPathStroke, "stroke", null);
              return childPathStroke = null;
            }
          }
        }
      });
      fill = null;
      return Object.defineProperty(scope, 'fill', {
        get: function() {
          return fill;
        },
        set: function(val) {
          if (fill !== val) {
            SVG.attr(scope.element, "fill", fill = val);
            if (childPathFill != null) {
              SVG.attr(childPathFill, "fill", null);
              return childPathFill = null;
            }
          }
        }
      });
    });
  });

  Take(["Gradient", "Registry", "ScopeCheck"], function(Gradient, Registry, ScopeCheck) {
    var gradientCount;
    gradientCount = 0;
    return Registry.add("ScopeProcessor", function(scope) {
      var lGradAngle, lGradName, lGradStops, linearGradient, rGradName, rGradProps, rGradStops, radialGradient;
      ScopeCheck(scope, "linearGradient", "radialGradient");
      gradientCount++;
      linearGradient = null;
      radialGradient = null;
      lGradName = "LGradient" + gradientCount;
      lGradAngle = null;
      lGradStops = null;
      rGradName = "RGradient" + gradientCount;
      rGradProps = null;
      rGradStops = null;
      scope.linearGradient = function() {
        var angle, stops;
        angle = arguments[0], stops = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        if (linearGradient == null) {
          linearGradient = Gradient.linear(lGradName);
        }
        if (typeof angle === "string") {
          stops.push(angle);
          angle = 0;
        }
        if (lGradAngle !== angle) {
          lGradAngle = angle;
          Gradient.updateProps(linearGradient, {
            x2: Math.cos(angle * Math.PI / 180),
            y2: Math.sin(angle * Math.PI / 180)
          });
        }
        if (lGradStops !== stops) {
          lGradStops = stops;
          Gradient.updateStops.apply(Gradient, [linearGradient].concat(slice.call(stops)));
        }
        return scope.fill = "url(#" + lGradName + ")";
      };
      return scope.radialGradient = function() {
        var props, stops;
        props = arguments[0], stops = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        if (radialGradient == null) {
          radialGradient = Gradient.radial(rGradName);
        }
        if (typeof props === "string" || typeof props === "number") {
          stops.push(props);
          props = {
            r: 0.5
          };
        }
        if (rGradProps !== props) {
          rGradProps = props;
          Gradient.updateProps(radialGradient, props);
        }
        if (rGradStops !== stops) {
          rGradStops = stops;
          Gradient.updateStops.apply(Gradient, [radialGradient].concat(slice.call(stops)));
        }
        return scope.fill = "url(#" + rGradName + ")";
      };
    });
  });

  Take(["Registry", "ScopeCheck"], function(Registry, ScopeCheck) {
    return Registry.add("ScopeProcessor", function(scope) {
      var size;
      ScopeCheck(scope, "initialWidth", "initialHeight");
      size = scope.element.getBoundingClientRect();
      scope.initialWidth = size.width;
      return scope.initialHeight = size.height;
    });
  });

  Take(["Pressure", "Registry", "ScopeCheck", "SVG"], function(Pressure, Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var accessors, pressure;
      ScopeCheck(scope, "pressure");
      pressure = null;
      accessors = {
        get: function() {
          return pressure;
        },
        set: function(val) {
          if (pressure !== val) {
            pressure = val;
            if (scope._setPressure != null) {
              return scope._setPressure(pressure);
            } else {
              return scope.fill = Pressure(scope.pressure);
            }
          }
        }
      };
      return Object.defineProperty(scope, "pressure", accessors);
    });
  });

  Take(["Registry", "ScopeCheck", "Tween"], function(Registry, ScopeCheck, Tween) {
    return Registry.add("ScopeProcessor", function(scope) {
      var tick;
      ScopeCheck(scope, "show", "hide");
      tick = function(v) {
        return scope.alpha = v;
      };
      scope.show = function(d) {
        if (d == null) {
          d = 1;
        }
        return Tween(scope.alpha, 1, d, {
          tick: tick,
          ease: "linear"
        });
      };
      return scope.hide = function(d) {
        if (d == null) {
          d = 1;
        }
        return Tween(scope.alpha, 0, d, {
          tick: tick,
          ease: "linear"
        });
      };
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var alignment, element, text, textElement;
      ScopeCheck(scope, "text");
      element = scope.element;
      textElement = element.querySelector("tspan") || element.querySelector("text");
      text = textElement != null ? textElement.textContent : void 0;
      alignment = "left";
      Object.defineProperty(scope, 'align', {
        get: function() {
          return alignment;
        },
        set: function(val) {
          if (textElement == null) {
            throw new Error("You have " + scope.id + ".align = '" + val + "', but this scope doesn't contain any text or tspan elements.");
          }
          if (alignment !== val) {
            alignment = val;
            return SVG.attr(textElement, "textAnchor", val === "left" ? "start" : val === "center" ? "middle" : "end");
          }
        }
      });
      return Object.defineProperty(scope, 'text', {
        get: function() {
          return text;
        },
        set: function(val) {
          if (textElement == null) {
            throw new Error("You have " + scope.id + ".text = '" + val + "', but this scope doesn't contain any text or tspan elements.");
          }
          if (text !== val) {
            return SVG.attr(textElement, "textContent", text = val);
          }
        }
      });
    });
  });

  Take(["Registry", "Tick"], function(Registry, Tick) {
    return Registry.add("ScopeProcessor", function(scope) {
      var running, startTime, tick;
      if (scope.tick == null) {
        return;
      }
      running = true;
      startTime = null;
      tick = scope.tick;
      scope.tick = function() {
        throw new Error("@tick() is called by the system. Please don't call it yourself.");
      };
      Tick(function(time, dt) {
        if (!running) {
          return;
        }
        if (startTime == null) {
          startTime = time;
        }
        return tick.call(scope, time - startTime, dt);
      });
      scope.tick.start = function() {
        return running = true;
      };
      scope.tick.stop = function() {
        return running = false;
      };
      scope.tick.toggle = function() {
        if (running) {
          return scope.tick.stop();
        } else {
          return scope.tick.start();
        }
      };
      return scope.tick.restart = function() {
        return startTime = null;
      };
    });
  });

  Take(["RAF", "Registry", "ScopeCheck", "SVG"], function(RAF, Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var applyTransform, denom, element, matrix, ref, rotation, scaleX, scaleY, t, transform, transformBaseVal, x, y;
      ScopeCheck(scope, "x", "y", "rotation", "scale", "scaleX", "scaleY");
      element = scope.element;
      transformBaseVal = (ref = element.transform) != null ? ref.baseVal : void 0;
      transform = SVG.svg.createSVGTransform();
      matrix = SVG.svg.createSVGMatrix();
      x = 0;
      y = 0;
      rotation = 0;
      scaleX = 1;
      scaleY = 1;
      if ((transformBaseVal != null ? transformBaseVal.numberOfItems : void 0) === 1) {
        t = transformBaseVal.getItem(0);
        switch (t.type) {
          case SVGTransform.SVG_TRANSFORM_MATRIX:
            x = t.matrix.e;
            y = t.matrix.f;
            rotation = 180 / Math.PI * Math.atan2(t.matrix.b, t.matrix.a);
            denom = Math.pow(t.matrix.a, 2) + Math.pow(t.matrix.c, 2);
            scaleX = Math.sqrt(denom);
            scaleY = (t.matrix.a * t.matrix.d - t.matrix.b * t.matrix.c) / scaleX;
            break;
          default:
            throw new Error("^ Transform encountered an SVG element with a non-matrix transform");
        }
      } else if ((transformBaseVal != null ? transformBaseVal.numberOfItems : void 0) > 1) {
        console.log(element);
        throw new Error("^ Transform encountered an SVG element with more than one transform");
      }
      applyTransform = function() {
        matrix.a = scaleX;
        matrix.d = scaleY;
        matrix.e = x;
        matrix.f = y;
        transform.setMatrix(matrix.rotate(rotation));
        return element.transform.baseVal.initialize(transform);
      };
      Object.defineProperty(scope, 'x', {
        get: function() {
          return x;
        },
        set: function(val) {
          if (x !== val) {
            x = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
      Object.defineProperty(scope, 'y', {
        get: function() {
          return y;
        },
        set: function(val) {
          if (y !== val) {
            y = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
      Object.defineProperty(scope, 'rotation', {
        get: function() {
          return rotation;
        },
        set: function(val) {
          if (rotation !== val) {
            rotation = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
      Object.defineProperty(scope, 'scale', {
        get: function() {
          return (scaleX + scaleY) / 2;
        },
        set: function(val) {
          if (scaleX !== val || scaleY !== val) {
            scaleX = scaleY = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
      Object.defineProperty(scope, 'scaleX', {
        get: function() {
          return scaleX;
        },
        set: function(val) {
          if (scaleX !== val) {
            scaleX = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
      return Object.defineProperty(scope, 'scaleY', {
        get: function() {
          return scaleY;
        },
        set: function(val) {
          if (scaleY !== val) {
            scaleY = val;
            return RAF(applyTransform, true, 1);
          }
        }
      });
    });
  });

  Take(["Pressure", "Reaction", "Symbol"], function(Pressure, Reaction, Symbol) {
    return Symbol("HydraulicField", [], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          var isInsideOtherField, p;
          isInsideOtherField = false;
          p = this.parent;
          while ((p != null) && !isInsideOtherField) {
            isInsideOtherField = p._symbol === this._symbol;
            p = p.parent;
          }
          if (!isInsideOtherField) {
            this.pressure = 0;
            return Reaction("Schematic:Show", function() {
              return this.pressure = Pressure.white;
            });
          }
        }
      };
    });
  });

  Take(["Pressure", "Reaction", "SVG", "Symbol"], function(Pressure, Reaction, SVG, Symbol) {
    return Symbol("HydraulicLine", [], function(element) {
      var apply, fillElms, highlightActive, scope, strip, strokeElms;
      strokeElms = [];
      fillElms = [];
      highlightActive = false;
      strip = function(elm) {
        var child, len, m, ref, results;
        if ((typeof elm.hasAttribute === "function" ? elm.hasAttribute("fill") : void 0) && elm.getAttribute("fill") !== "none") {
          if (elm !== element) {
            fillElms.push(elm);
          }
          elm.removeAttribute("fill");
        }
        if ((typeof elm.hasAttribute === "function" ? elm.hasAttribute("stroke") : void 0) && elm.getAttribute("stroke") !== "none") {
          if (elm !== element) {
            strokeElms.push(elm);
          }
          elm.removeAttribute("stroke");
        }
        if (elm.childNodes.length) {
          ref = elm.childNodes;
          results = [];
          for (m = 0, len = ref.length; m < len; m++) {
            child = ref[m];
            results.push(strip(child));
          }
          return results;
        }
      };
      strip(element);
      element.setAttribute("fill", "transparent");
      apply = function(stroke, fill) {
        var elm, len, len1, m, n, results;
        if (fill == null) {
          fill = stroke;
        }
        for (m = 0, len = strokeElms.length; m < len; m++) {
          elm = strokeElms[m];
          SVG.attr(elm, "stroke", stroke);
        }
        results = [];
        for (n = 0, len1 = fillElms.length; n < len1; n++) {
          elm = fillElms[n];
          results.push(SVG.attr(elm, "fill", fill));
        }
        return results;
      };
      return scope = {
        _highlight: function(enable) {
          if (highlightActive = enable) {
            return apply("url(#MidHighlightGradient)", "url(#LightHighlightGradient)");
          } else {
            return apply(Pressure(scope.pressure));
          }
        },
        _setPressure: function(p) {
          if (!highlightActive) {
            return apply(Pressure(p));
          }
        },
        setup: function() {
          this.pressure = 0;
          return Reaction("Schematic:Show", function() {
            return this.pressure = Pressure.black;
          });
        }
      };
    });
  });

  Take(["Reaction", "Symbol", "SVG"], function(Reaction, Symbol, SVG) {
    return Symbol("Labels", ["labelsContainer"], function(svgElement) {
      var c, len, m, ref, scope;
      ref = svgElement.querySelectorAll("[fill]");
      for (m = 0, len = ref.length; m < len; m++) {
        c = ref[m];
        c.removeAttributeNS(null, "fill");
      }
      return scope = {
        setup: function() {
          Reaction("Labels:Hide", function() {
            return scope.alpha = false;
          });
          Reaction("Labels:Show", function() {
            return scope.alpha = true;
          });
          return Reaction("Background:Set", function(v) {
            var l;
            l = (v / 2 + .8) % 1;
            return SVG.attr(svgElement, "fill", "hsl(227, 4%, " + (l * 100) + "%)");
          });
        }
      };
    });
  });

  Take(["Mode", "ParentElement", "Resize", "SVG"], function(Mode, ParentElement, Resize, SVG) {
    var height, newWidth, resize, width;
    if (!Mode.autosize) {
      return;
    }
    width = SVG.attr(SVG.svg, "width");
    height = SVG.attr(SVG.svg, "height");
    newWidth = null;
    resize = function() {
      var newHeight;
      if (ParentElement.offsetWidth !== newWidth) {
        newWidth = ParentElement.offsetWidth;
        newHeight = height * newWidth / width | 0;
        return ParentElement.style.height = newHeight + "px";
      }
    };
    return Resize(resize);
  });

  Take(["Config", "ParentElement"], function(Config, ParentElement) {
    var Mode, fetchAttribute, ref;
    fetchAttribute = function(name) {
      var attrName, val;
      attrName = "x-" + name;
      if (ParentElement.hasAttribute(attrName)) {
        val = ParentElement.getAttribute(attrName);
        if (val === "" || val === "true") {
          return true;
        }
        if (val === "false") {
          return false;
        }
        if (val.charAt(0) === "{") {
          return JSON.parse(val);
        }
        return val;
      } else {
        return Config[name];
      }
    };
    return Make("Mode", Mode = {
      get: fetchAttribute,
      autosize: fetchAttribute("autosize"),
      background: fetchAttribute("background"),
      controlPanel: fetchAttribute("controlPanel"),
      dev: ((ref = window.top.location.port) != null ? ref.length : void 0) >= 4,
      nav: fetchAttribute("nav"),
      embed: window !== window.top
    });
  });

  (function() {
    var len, m, o, parentElement, ref;
    parentElement = null;
    ref = window.parent.document.querySelectorAll("object");
    for (m = 0, len = ref.length; m < len; m++) {
      o = ref[m];
      if (o.contentDocument === document) {
        parentElement = o;
        break;
      }
    }
    if (parentElement == null) {
      parentElement = document.body;
    }
    return Make("ParentElement", parentElement);
  })();

  (function() {
    var cbs;
    cbs = [];
    Make("Reaction", function(name, cb) {
      return (cbs[name] != null ? cbs[name] : cbs[name] = []).push(cb);
    });
    return Make("Action", function() {
      var args, cb, len, m, name, ref, results;
      name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (cbs[name] != null) {
        ref = cbs[name];
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          cb = ref[m];
          results.push(cb.apply(null, args));
        }
        return results;
      }
    });
  })();

  Take(["ControlPanel", "ControlPanelLayout", "Registry", "Scope", "ControlReady"], function(ControlPanel, ControlPanelLayout, Registry, Scope) {
    var Control, defn, instances, ref, setup, type;
    Control = {};
    instances = {};
    setup = function(type, defn) {
      return Control[type] = function(props) {
        var base1, elm, scope;
        if (props == null) {
          props = {};
        }
        if (typeof props !== "object") {
          console.log(props);
          throw new Error("Control." + type + "(props) takes a optional props object. Got ^^^, which is not an object.");
        }
        if (((props != null ? props.id : void 0) != null) && (instances[props.id] != null)) {
          if (typeof (base1 = instances[props.id]).attach === "function") {
            base1.attach(props);
          }
          return instances[props.id];
        } else {
          elm = ControlPanel.createElement(props != null ? props.parent : void 0);
          scope = Scope(elm, defn, props);
          if (typeof scope.attach === "function") {
            scope.attach(props);
          }
          ControlPanelLayout.addScope(scope);
          if ((props != null ? props.id : void 0) != null) {
            instances[props.id] = scope;
          }
          return scope;
        }
      };
    };
    ref = Registry.all("Control", true);
    for (type in ref) {
      defn = ref[type];
      setup(type, defn);
    }
    return Make("Control", Control);
  });

  (function() {
    var Ease;
    return Make("Ease", Ease = {
      sin: function(input, inputMin, inputMax, outputMin, outputMax, clip) {
        var cos, p;
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        if (inputMin === inputMax) {
          return outputMin;
        }
        if (clip) {
          input = Math.max(inputMin, Math.min(inputMax, input));
        }
        p = (input - inputMin) / (inputMax - inputMin);
        cos = Math.cos(p * Math.PI);
        return (.5 - cos / 2) * (outputMax - outputMin) + outputMin;
      },
      cubic: function(input, inputMin, inputMax, outputMin, outputMax, clip) {
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        return Ease.power(input, 3, inputMin, inputMax, outputMin, outputMax, clip);
      },
      linear: function(input, inputMin, inputMax, outputMin, outputMax, clip) {
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        if (inputMin === inputMax) {
          return outputMin;
        }
        if (clip) {
          input = Math.max(inputMin, Math.min(inputMax, input));
        }
        input -= inputMin;
        input /= inputMax - inputMin;
        input *= outputMax - outputMin;
        input += outputMin;
        return input;
      },
      power: function(input, power, inputMin, inputMax, outputMin, outputMax, clip) {
        var inputDiff, outputDiff, p;
        if (power == null) {
          power = 1;
        }
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        if (inputMin === inputMax) {
          return outputMin;
        }
        if (clip) {
          input = Math.max(inputMin, Math.min(inputMax, input));
        }
        outputDiff = outputMax - outputMin;
        inputDiff = inputMax - inputMin;
        p = (input - inputMin) / (inputDiff / 2);
        if (p < 1) {
          return outputMin + outputDiff / 2 * Math.pow(p, power);
        } else {
          return outputMin + outputDiff / 2 * (2 - Math.abs(Math.pow(p - 2, power)));
        }
      },
      quadratic: function(input, inputMin, inputMax, outputMin, outputMax, clip) {
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        return Ease.power(input, 2, inputMin, inputMax, outputMin, outputMax, clip);
      },
      quartic: function(input, inputMin, inputMax, outputMin, outputMax, clip) {
        if (inputMin == null) {
          inputMin = 0;
        }
        if (inputMax == null) {
          inputMax = 1;
        }
        if (outputMin == null) {
          outputMin = 0;
        }
        if (outputMax == null) {
          outputMax = 1;
        }
        if (clip == null) {
          clip = true;
        }
        return Ease.power(input, 4, inputMin, inputMax, outputMin, outputMax, clip);
      },
      ramp: function(current, target, rate, dT) {
        var delta;
        delta = target - current;
        return current + (delta >= 0 ? Math.min(rate * dT, delta) : Math.max(-rate * dT, delta));
      }
    });
  })();

  Take(["Pressure", "SVG"], function(Pressure, SVG) {
    var Gradient, existing;
    existing = {};
    return Make("Gradient", Gradient = {
      remove: function(name) {
        if (existing[name] != null) {
          SVG.defs.removeChild(existing[name]);
          return delete existing[name];
        }
      },
      updateStops: function() {
        var attrs, dirty, gradient, i, len, len1, m, n, ref, stop, stops;
        gradient = arguments[0], stops = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        if (gradient._stops != null) {
          dirty = false;
          ref = gradient._stops;
          for (i = m = 0, len = ref.length; m < len; i = ++m) {
            stop = ref[i];
            dirty = (stop.color != null) && (stops[i].color != null) ? stop.color !== stops[i].color || stop.offset !== stops[i].offset || stop.opacity !== stops[i].opacity : stop !== stops[i];
            if (dirty) {
              break;
            }
          }
          if (!dirty) {
            return;
          }
        }
        gradient._stops = stops;
        while (gradient.hasChildNodes()) {
          gradient.removeChild(gradient.lastChild);
        }
        stops = stops[0] instanceof Array ? stops[0] : stops;
        for (i = n = 0, len1 = stops.length; n < len1; i = ++n) {
          stop = stops[i];
          if (typeof stop === "string") {
            SVG.create("stop", gradient, {
              stopColor: stop,
              offset: (100 * i / (stops.length - 1)) + "%"
            });
          } else if (typeof stop === "number") {
            SVG.create("stop", gradient, {
              stopColor: Pressure(stop),
              offset: (100 * i / (stops.length - 1)) + "%"
            });
          } else {
            attrs = {
              stopColor: stop.color,
              offset: 100 * (stop.offset != null ? stop.offset : i / (stops.length - 1)) + "%"
            };
            if (stop.opacity != null) {
              attrs.stopOpacity = stop.opacity;
            }
            SVG.create("stop", gradient, attrs);
          }
        }
        return gradient;
      },
      updateProps: function(gradient, props) {
        return SVG.attrs(gradient, props);
      },
      linear: function() {
        var attrs, gradient, name, props, stops;
        name = arguments[0], props = arguments[1], stops = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        if (props == null) {
          props = {};
        }
        if (existing[name] != null) {
          throw new Error("Gradient named " + name + " already exists. Please don't create the same gradient more than once.");
        }
        attrs = typeof props === "object" ? (props.id = name, props) : props === true ? {
          id: name,
          x2: 0,
          y2: 1
        } : {
          id: name
        };
        gradient = existing[name] = SVG.create("linearGradient", SVG.defs, attrs);
        Gradient.updateStops(gradient, stops);
        return gradient;
      },
      radial: function() {
        var gradient, name, props, stops;
        name = arguments[0], props = arguments[1], stops = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        if (props == null) {
          props = {};
        }
        if (existing[name] != null) {
          throw new Error("Gradient named " + name + " already exists. Please don't create the same gradient more than once.");
        }
        existing[name] = true;
        props.id = name;
        gradient = existing[name] = SVG.create("radialGradient", SVG.defs, props);
        Gradient.updateStops(gradient, stops);
        return gradient;
      }
    });
  });

  Take(["Ease", "FPS", "Gradient", "Input", "RAF", "SVG", "Tick", "SVGReady"], function(Ease, FPS, Gradient, Input, RAF, SVG, Tick) {
    var activeHighlight, counter, dgradient, lgradient, mgradient, tgradient;
    activeHighlight = null;
    counter = 0;
    lgradient = Gradient.linear("LightHighlightGradient", {
      gradientUnits: "userSpaceOnUse"
    }, "#9FC", "#FF8", "#FD8");
    mgradient = Gradient.linear("MidHighlightGradient", {
      gradientUnits: "userSpaceOnUse"
    }, "#2F6", "#FF2", "#F72");
    dgradient = Gradient.linear("DarkHighlightGradient", {
      gradientUnits: "userSpaceOnUse"
    }, "#0B3", "#DD0", "#D50");
    tgradient = Gradient.linear("TextHighlightGradient", {
      gradientUnits: "userSpaceOnUse"
    }, "#091", "#BB0", "#B30");
    Tick(function(time) {
      var props;
      if ((activeHighlight != null) && FPS() > 20) {
        if (++counter % 3 === 0) {
          props = {
            x1: Math.cos(time * Math.PI) * -60 - 50,
            y1: Math.sin(time * Math.PI) * -60 - 50,
            x2: Math.cos(time * Math.PI) * 60 - 50,
            y2: Math.sin(time * Math.PI) * 60 - 50
          };
          Gradient.updateProps(lgradient, props);
          Gradient.updateProps(mgradient, props);
          Gradient.updateProps(dgradient, props);
          return Gradient.updateProps(tgradient, props);
        }
      }
    });
    return Make("Highlight", function() {
      var activate, active, deactivate, highlights, setup, targets, timeout;
      targets = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      highlights = [];
      active = false;
      timeout = null;
      setup = function(elm) {
        var doFill, doFunction, doStroke, e, fill, len, m, ref, ref1, results, stroke, width;
        fill = SVG.attr(elm, "fill");
        stroke = SVG.attr(elm, "stroke");
        doFill = (fill != null) && fill !== "none" && fill !== "transparent";
        doStroke = (stroke != null) && stroke !== "none" && stroke !== "transparent";
        doFunction = ((ref = elm._scope) != null ? ref._highlight : void 0) != null;
        if (doFunction) {
          highlights.push(e = {
            elm: elm,
            "function": elm._scope._highlight
          });
        } else if (doFill || doStroke) {
          highlights.push(e = {
            elm: elm,
            attrs: {}
          });
          if (doFill) {
            e.attrs.fill = fill;
          }
          if (doStroke) {
            e.attrs.stroke = stroke;
          }
          if (doStroke && ((width = SVG.attr(elm, "stroke-width")) != null)) {
            e.attrs.strokeWidth = width;
          }
        }
        if (!doFunction) {
          ref1 = elm.childNodes;
          results = [];
          for (m = 0, len = ref1.length; m < len; m++) {
            elm = ref1[m];
            if (elm.tagName === "g" || elm.tagName === "path" || elm.tagName === "text" || elm.tagName === "tspan" || elm.tagName === "rect" || elm.tagName === "circle") {
              results.push(setup(elm));
            } else {
              results.push(void 0);
            }
          }
          return results;
        }
      };
      activate = function() {
        var h, len, m;
        if (!active) {
          active = true;
          if (typeof activeHighlight === "function") {
            activeHighlight();
          }
          activeHighlight = deactivate;
          for (m = 0, len = highlights.length; m < len; m++) {
            h = highlights[m];
            if (h["function"] != null) {
              h["function"](true);
            } else {
              if (h.attrs.stroke != null) {
                if (h.elm.tagName === "text" || h.elm.tagName === "tspan") {
                  SVG.attrs(h.elm, {
                    stroke: "url(#TextHighlightGradient)",
                    strokeWidth: 3
                  });
                } else if (h.attrs.stroke === "#FFF" || h.attrs.stroke === "white") {
                  SVG.attrs(h.elm, {
                    stroke: "url(#LightHighlightGradient)",
                    strokeWidth: 3
                  });
                } else if (h.attrs.stroke === "#000" || h.attrs.stroke === "black") {
                  SVG.attrs(h.elm, {
                    stroke: "url(#DarkHighlightGradient)",
                    strokeWidth: 3
                  });
                } else {
                  SVG.attrs(h.elm, {
                    stroke: "url(#MidHighlightGradient)",
                    strokeWidth: 3
                  });
                }
              }
              if (h.attrs.fill != null) {
                if (h.elm.tagName === "text" || h.elm.tagName === "tspan") {
                  SVG.attrs(h.elm, {
                    fill: "url(#TextHighlightGradient)"
                  });
                } else if (h.attrs.fill === "#FFF" || h.attrs.fill === "white") {
                  SVG.attrs(h.elm, {
                    fill: "url(#LightHighlightGradient)"
                  });
                } else if (h.attrs.fill === "#000" || h.attrs.fill === "black") {
                  SVG.attrs(h.elm, {
                    fill: "url(#DarkHighlightGradient)"
                  });
                } else {
                  SVG.attrs(h.elm, {
                    fill: "url(#MidHighlightGradient)"
                  });
                }
              }
            }
          }
          return timeout = setTimeout(deactivate, 4000);
        }
      };
      deactivate = function() {
        var h, len, m, results;
        if (active) {
          active = false;
          clearTimeout(timeout);
          activeHighlight = null;
          results = [];
          for (m = 0, len = highlights.length; m < len; m++) {
            h = highlights[m];
            if (h["function"] != null) {
              results.push(h["function"](false));
            } else {
              results.push(SVG.attrs(h.elm, h.attrs));
            }
          }
          return results;
        }
      };
      return RAF(function() {
        var len, len1, m, mouseProps, n, results, t, target, touchProps;
        for (m = 0, len = targets.length; m < len; m++) {
          target = targets[m];
          if (target == null) {
            console.log(targets);
            throw new Error("Highlight called with a null element ^^^");
          }
          t = target.element || target;
          if (!t._HighlighterSetup) {
            t._HighlighterSetup = true;
            setup(t);
          }
        }
        results = [];
        for (n = 0, len1 = targets.length; n < len1; n++) {
          target = targets[n];
          t = target.element || target;
          if (!t._Highlighter) {
            t._Highlighter = true;
            mouseProps = {
              moveIn: activate,
              moveOut: deactivate
            };
            touchProps = {
              down: activate
            };
            Input(t, mouseProps, true, false);
            results.push(Input(t, touchProps, false, true));
          } else {
            results.push(void 0);
          }
        }
        return results;
      });
    });
  });

  Make("Input", function(elm, calls, mouse, touch) {
    var down, move, out, over, prepTouchEvent, state, up;
    if (mouse == null) {
      mouse = true;
    }
    if (touch == null) {
      touch = true;
    }
    state = {
      down: false,
      over: false,
      touch: false,
      clicking: false,
      captured: false,
      deltaX: 0,
      deltaY: 0,
      lastX: 0,
      lastY: 0
    };
    down = function(e) {
      state.lastX = e.clientX;
      state.lastY = e.clientY;
      state.deltaX = 0;
      state.deltaY = 0;
      if (!state.down) {
        state.down = true;
        if (state.over) {
          state.clicking = true;
          return typeof calls.down === "function" ? calls.down(e, state) : void 0;
        } else {
          return typeof calls.downOther === "function" ? calls.downOther(e, state) : void 0;
        }
      }
    };
    up = function(e) {
      if (state.down) {
        state.down = false;
        if (state.over) {
          if (typeof calls.up === "function") {
            calls.up(e, state);
          }
          if (state.clicking) {
            state.clicking = false;
            return typeof calls.click === "function" ? calls.click(e, state) : void 0;
          }
        } else {
          if (typeof calls.upOther === "function") {
            calls.upOther(e, state);
          }
          if (state.clicking) {
            state.clicking = false;
            return typeof calls.miss === "function" ? calls.miss(e, state) : void 0;
          }
        }
      }
    };
    move = function(e) {
      if (e.clientX === state.lastX && e.clientY === state.lastY) {
        return;
      }
      state.deltaX = e.clientX - state.lastX;
      state.deltaY = e.clientY - state.lastY;
      if (state.over) {
        if (state.down) {
          if (typeof calls.drag === "function") {
            calls.drag(e, state);
          }
        } else {
          if (typeof calls.move === "function") {
            calls.move(e, state);
          }
        }
      } else {
        if (state.down) {
          if (typeof calls.dragOther === "function") {
            calls.dragOther(e, state);
          }
        } else {
          if (typeof calls.moveOther === "function") {
            calls.moveOther(e, state);
          }
        }
      }
      state.lastX = e.clientX;
      return state.lastY = e.clientY;
    };
    out = function(e) {
      if (state.over) {
        state.over = false;
        if (state.down) {
          return typeof calls.dragOut === "function" ? calls.dragOut(e, state) : void 0;
        } else {
          return typeof calls.moveOut === "function" ? calls.moveOut(e, state) : void 0;
        }
      }
    };
    over = function(e) {
      state.lastX = e.clientX;
      state.lastY = e.clientY;
      if (!state.over) {
        state.over = true;
        if (state.down) {
          return typeof calls.dragIn === "function" ? calls.dragIn(e, state) : void 0;
        } else {
          return typeof calls.moveIn === "function" ? calls.moveIn(e, state) : void 0;
        }
      }
    };
    if (mouse) {
      document.addEventListener("mousedown", function(e) {
        if (e.button !== 0) {
          return;
        }
        if (state.touch) {
          return;
        }
        return down(e);
      });
      if ((calls.move != null) || (calls.drag != null) || (calls.moveOther != null) || (calls.dragOther != null)) {
        document.addEventListener("mousemove", function(e) {
          if (state.touch) {
            return;
          }
          return move(e);
        });
      }
      document.addEventListener("mouseup", function(e) {
        if (e.button !== 0) {
          return;
        }
        if (state.touch) {
          return;
        }
        return up(e);
      });
      if (elm != null) {
        elm.addEventListener("mouseleave", function(e) {
          if (state.touch) {
            return;
          }
          return out(e);
        });
      }
      if (elm != null) {
        elm.addEventListener("mouseenter", function(e) {
          if (state.touch) {
            return;
          }
          return over(e);
        });
      }
    }
    if (touch) {
      prepTouchEvent = function(e) {
        var newState, overChanged, pElm, ref, ref1;
        state.touch = true;
        e.clientX = (ref = e.touches[0]) != null ? ref.clientX : void 0;
        e.clientY = (ref1 = e.touches[0]) != null ? ref1.clientY : void 0;
        if ((elm != null) && (e.clientX != null) && (e.clientY != null) && (state.captured === null || state.captured === true)) {
          pElm = document.elementFromPoint(e.clientX, e.clientY);
          newState = elm === pElm || elm.contains(pElm);
          overChanged = newState !== state.over;
          if (overChanged) {
            if (newState) {
              if (state.captured == null) {
                state.captured = true;
              }
              over(e);
            } else {
              out(e);
            }
          }
        }
        return state.captured != null ? state.captured : state.captured = false;
      };
      document.addEventListener("touchstart", function(e) {
        state.captured = null;
        prepTouchEvent(e);
        return down(e);
      });
      if ((calls.move != null) || (calls.drag != null) || (calls.moveOther != null) || (calls.dragOther != null) || (calls.moveIn != null) || (calls.dragIn != null) || (calls.moveOut != null) || (calls.dragOut != null)) {
        document.addEventListener("touchmove", function(e) {
          prepTouchEvent(e);
          return move(e);
        });
      }
      document.addEventListener("touchend", function(e) {
        prepTouchEvent(e);
        up(e);
        return state.touch = false;
      });
      return document.addEventListener("touchcancel", function(e) {
        prepTouchEvent(e);
        up(e);
        return state.touch = false;
      });
    }
  });

  (function() {
    var KeyMe, KeyNames, actionize, downHandlers, getModifier, handleKey, keyDown, keyUp, runCallbacks, upHandlers;
    downHandlers = {};
    upHandlers = {};
    KeyMe = function(key, opts) {
      var name;
      if (key == null) {
        throw new Error("You must provide a key name or code for KeyMe(key, options)");
      }
      if (typeof opts !== "object") {
        throw new Error("You must provide an options object for KeyMe(key, options)");
      }
      name = typeof key === "string" ? key : KeyNames[key];
      return actionize(opts.down, opts.up, name, opts.modifier);
    };
    KeyMe.any = function(down, up) {
      return actionize(down, up, "any");
    };
    KeyMe.char = function(char, down, up) {
      return actionize(down, up, char);
    };
    KeyMe.shortcut = function(modifier, char, down, up) {
      return actionize(down, up, char, modifier);
    };
    KeyMe.pressing = {};
    KeyMe.lastPressed = null;
    actionize = function(down, up, name, modifier) {
      if (down != null) {
        (downHandlers[name] != null ? downHandlers[name] : downHandlers[name] = []).push({
          callback: down,
          modifier: modifier
        });
      }
      if (up != null) {
        return (upHandlers[name] != null ? upHandlers[name] : upHandlers[name] = []).push({
          callback: up,
          modifier: modifier
        });
      }
    };
    keyDown = function(e) {
      var code, name;
      code = e.which || e.keyCode;
      name = KeyNames[code];
      if (name == null) {
        return;
      }
      if (KeyMe.pressing[name]) {
        return;
      }
      KeyMe.pressing[name] = true;
      KeyMe.lastPressed = {
        name: name,
        code: code
      };
      return handleKey(name, e, downHandlers);
    };
    keyUp = function(e) {
      var code, name;
      code = e.keyCode;
      name = KeyNames[code];
      if (name == null) {
        return;
      }
      delete KeyMe.pressing[name];
      return handleKey(name, e, upHandlers);
    };
    handleKey = function(name, e, handlers) {
      var modifier;
      modifier = getModifier(e);
      if (name === modifier) {
        modifier = null;
      }
      runCallbacks(handlers.any, modifier);
      return runCallbacks(handlers[name], modifier);
    };
    getModifier = function(e) {
      if (e.ctrlKey) {
        return "meta";
      }
      if (e.altKey) {
        return "alt";
      }
      if (e.shiftKey) {
        return "shift";
      }
    };
    runCallbacks = function(callbacks, modifier) {
      var command, len, m, results;
      if (callbacks != null) {
        results = [];
        for (m = 0, len = callbacks.length; m < len; m++) {
          command = callbacks[m];
          if (command.modifier === modifier) {
            results.push(command.callback());
          }
        }
        return results;
      }
    };
    window.addEventListener("keydown", keyDown);
    window.addEventListener("keyup", keyUp);
    window.addEventListener("blur", function() {
      return KeyMe.pressing = {};
    });
    Make("KeyMe", KeyMe);
    return KeyNames = {
      3: "cancel",
      6: "help",
      8: "back_space",
      9: "tab",
      12: "clear",
      13: "return",
      14: "enter",
      16: "shift",
      17: "control",
      18: "alt",
      19: "pause",
      20: "caps_lock",
      27: "escape",
      32: "space",
      33: "page_up",
      34: "page_down",
      35: "end",
      36: "home",
      37: "left",
      38: "up",
      39: "right",
      40: "down",
      44: "printscreen",
      45: "insert",
      46: "delete",
      48: "0",
      49: "1",
      50: "2",
      51: "3",
      52: "4",
      53: "5",
      54: "6",
      55: "7",
      56: "8",
      57: "9",
      59: "semicolon",
      61: "equals",
      65: "a",
      66: "b",
      67: "c",
      68: "d",
      69: "e",
      70: "f",
      71: "g",
      72: "h",
      73: "i",
      74: "j",
      75: "k",
      76: "l",
      77: "m",
      78: "n",
      79: "o",
      80: "p",
      81: "q",
      82: "r",
      83: "s",
      84: "t",
      85: "u",
      86: "v",
      87: "w",
      88: "x",
      89: "y",
      90: "z",
      93: "context_menu",
      96: "numpad0",
      97: "numpad1",
      98: "numpad2",
      99: "numpad3",
      100: "numpad4",
      101: "numpad5",
      102: "numpad6",
      103: "numpad7",
      104: "numpad8",
      105: "numpad9",
      106: "multiply",
      107: "add",
      108: "separator",
      109: "subtract",
      110: "decimal",
      111: "divide",
      112: "f1",
      113: "f2",
      114: "f3",
      115: "f4",
      116: "f5",
      117: "f6",
      118: "f7",
      119: "f8",
      120: "f9",
      121: "f10",
      122: "f11",
      123: "f12",
      124: "f13",
      125: "f14",
      126: "f15",
      127: "f16",
      128: "f17",
      129: "f18",
      130: "f19",
      131: "f20",
      132: "f21",
      133: "f22",
      134: "f23",
      135: "f24",
      144: "num_lock",
      145: "scroll_lock",
      173: "minus",
      187: "equals",
      188: "comma",
      189: "minus",
      190: "period",
      191: "slash",
      192: "back_quote",
      219: "open_bracket",
      220: "back_slash",
      221: "close_bracket",
      222: "quote",
      224: "meta"
    };
  })();

  (function() {
    var Pressure, renderString;
    Pressure = function(pressure, alpha) {
      var green;
      if (alpha == null) {
        alpha = 1;
      }
      switch (false) {
        case typeof pressure !== "string":
          return pressure;
        case pressure !== Pressure.black:
          return renderString(0, 0, 0, alpha);
        case pressure !== Pressure.white:
          return renderString(255, 255, 255, alpha);
        case pressure !== Pressure.vacuum:
          return renderString(255, 0, 255, alpha);
        case pressure !== Pressure.atmospheric:
          return renderString(0, 153, 255, alpha);
        case pressure !== Pressure.drain:
          return renderString(0, 0, 255, alpha);
        case pressure !== Pressure.electric:
          return renderString(0, 218, 255, alpha);
        case pressure !== Pressure.magnetic:
          return renderString(141, 2, 155, alpha);
        case !(pressure < Pressure.med):
          green = Pressure.med - pressure;
          green *= 153 / (Pressure.med - 1);
          green += 102;
          return renderString(255, green | 0, 0, alpha);
        case !(pressure >= Pressure.med):
          green = Pressure.max - pressure;
          green *= 102 / Pressure.med;
          return renderString(255, green | 0, 0, alpha);
      }
    };
    Pressure.black = 101;
    Pressure.white = -101;
    Pressure.vacuum = -2;
    Pressure.atmospheric = -1;
    Pressure.drain = 0;
    Pressure.zero = 0;
    Pressure.min = 1;
    Pressure.med = 50;
    Pressure.max = 100;
    Pressure.electric = 1000;
    Pressure.magnetic = 1001;
    renderString = function(r, g, b, a) {
      if (a >= .99) {
        return "rgb(" + r + "," + g + "," + b + ")";
      } else {
        return "rgba(" + r + "," + g + "," + b + "," + a + ")";
      }
    };
    return Make("Pressure", Pressure);
  })();

  (function() {
    var callbacksByPriority, requested, run;
    requested = false;
    callbacksByPriority = [[], []];
    run = function(time) {
      var callbacks, cb, len, m, p, results;
      requested = false;
      results = [];
      for (p = m = 0, len = callbacksByPriority.length; m < len; p = ++m) {
        callbacks = callbacksByPriority[p];
        if (!(callbacks != null)) {
          continue;
        }
        callbacksByPriority[p] = [];
        results.push((function() {
          var len1, n, results1;
          results1 = [];
          for (n = 0, len1 = callbacks.length; n < len1; n++) {
            cb = callbacks[n];
            results1.push(cb(time));
          }
          return results1;
        })());
      }
      return results;
    };
    return Make("RAF", function(cb, ignoreDuplicates, p) {
      var c, len, m, ref;
      if (ignoreDuplicates == null) {
        ignoreDuplicates = false;
      }
      if (p == null) {
        p = 0;
      }
      if (cb == null) {
        throw new Error("RAF(null)");
      }
      ref = callbacksByPriority[p];
      for (m = 0, len = ref.length; m < len; m++) {
        c = ref[m];
        if (!(c === cb)) {
          continue;
        }
        if (ignoreDuplicates) {
          return;
        }
        console.log(cb);
        throw new Error("^ RAF was called more than once with this function. You can use RAF(fn, true) to drop duplicates and bypass this error.");
      }
      (callbacksByPriority[p] != null ? callbacksByPriority[p] : callbacksByPriority[p] = []).push(cb);
      if (!requested) {
        requested = true;
        requestAnimationFrame(run);
      }
      return cb;
    });
  })();

  (function() {
    var Registry, closed, named, unnamed;
    named = {};
    unnamed = {};
    closed = {};
    return Make("Registry", Registry = {
      add: function(type, item) {
        if (closed[type]) {
          console.log(item);
          throw new Error("^^^ This " + type + " was registered too late.");
        }
        return (unnamed[type] != null ? unnamed[type] : unnamed[type] = []).push(item);
      },
      all: function(type, byName) {
        if (byName == null) {
          byName = false;
        }
        if (byName) {
          return named[type];
        } else {
          return unnamed[type];
        }
      },
      set: function(type, name, item) {
        var ref;
        if (closed[type]) {
          console.log(item);
          throw new Error("^^^ This " + type + " named \"" + name + "\" was registered too late.");
        }
        if (((ref = named[type]) != null ? ref[name] : void 0) != null) {
          console.log(item);
          throw new Error("^^^ This " + type + " is using the name \"" + name + "\", which is already in use.");
        }
        return (named[type] != null ? named[type] : named[type] = {})[name] = item;
      },
      get: function(type, name) {
        var ref;
        return (ref = named[type]) != null ? ref[name] : void 0;
      },
      closeRegistration: function(type) {
        return closed[type] = true;
      }
    });
  })();

  Take(["RAF"], function(RAF) {
    return Make("Resize", function(cb, now) {
      var r;
      if (now == null) {
        now = false;
      }
      r = function() {
        return RAF(cb, true);
      };
      if (now) {
        cb();
      } else {
        r();
      }
      window.addEventListener("resize", r);
      return Take("load", function() {
        r();
        return setTimeout(r, 1000);
      });
    });
  });

  Make("ScopeCheck", function() {
    var len, m, prop, props, results, scope;
    scope = arguments[0], props = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    results = [];
    for (m = 0, len = props.length; m < len; m++) {
      prop = props[m];
      if (!(scope[prop] != null)) {
        continue;
      }
      console.log(scope.element);
      throw new Error("^ @" + prop + " is a reserved name. Please choose a different name for your child/property \"" + prop + "\".");
    }
    return results;
  });

  Take("DOMContentLoaded", function() {
    var CheckSVGReady, SVG, SVGReady, attrNames, defs, propNames, root, svg, svgNS, xlinkNS;
    svg = document.querySelector("svg#svga");
    defs = svg.querySelector("defs");
    root = svg.getElementById("root");
    svgNS = "http://www.w3.org/2000/svg";
    xlinkNS = "http://www.w3.org/1999/xlink";
    propNames = {
      textContent: true
    };
    attrNames = {
      gradientUnits: "gradientUnits",
      viewBox: "viewBox",
      SCOPE: "SCOPE",
      SYMBOL: "SYMBOL"
    };
    SVGReady = false;
    CheckSVGReady = function() {
      return SVGReady || (SVGReady = Take("SVGReady"));
    };
    return Make("SVG", SVG = {
      svg: svg,
      defs: defs,
      root: root,
      create: function(type, parent, attrs) {
        var elm;
        elm = document.createElementNS(svgNS, type);
        if (attrs != null) {
          SVG.attrs(elm, attrs);
        }
        if (parent != null) {
          SVG.append(parent, elm);
        }
        return elm;
      },
      clone: function(source, parent, attrs) {
        var attr, child, elm, len, len1, m, n, ref, ref1;
        if (source == null) {
          throw new Error("Clone source is undefined in SVG.clone(source, parent, attrs)");
        }
        if (!CheckSVGReady()) {
          throw new Error("SVG.clone() called before SVGReady");
        }
        elm = document.createElementNS(svgNS, "g");
        ref = source.attributes;
        for (m = 0, len = ref.length; m < len; m++) {
          attr = ref[m];
          SVG.attr(elm, attr.name, attr.value);
        }
        SVG.attrs(elm, {
          id: null
        });
        if (attrs != null) {
          SVG.attrs(elm, attrs);
        }
        ref1 = source.childNodes;
        for (n = 0, len1 = ref1.length; n < len1; n++) {
          child = ref1[n];
          SVG.append(elm, child.cloneNode(true));
        }
        if (parent != null) {
          SVG.append(parent, elm);
        }
        return elm;
      },
      append: function(parent, child) {
        if (!CheckSVGReady()) {
          throw new Error("SVG.append() called before SVGReady");
        }
        parent.appendChild(child);
        return child;
      },
      prepend: function(parent, child) {
        if (!CheckSVGReady()) {
          throw new Error("SVG.prepend() called before SVGReady");
        }
        if (parent.hasChildNodes()) {
          parent.insertBefore(child, parent.firstChild);
        } else {
          parent.appendChild(child);
        }
        return child;
      },
      attrs: function(elm, attrs) {
        var k, v;
        if (!elm) {
          throw new Error("SVG.attrs was called with a null element");
        }
        if (typeof attrs !== "object") {
          console.log(attrs);
          throw new Error("SVG.attrs requires an object as the second argument, got ^");
        }
        for (k in attrs) {
          v = attrs[k];
          SVG.attr(elm, k, v);
        }
        return elm;
      },
      attr: function(elm, k, v) {
        var base1, ns;
        if (!elm) {
          throw new Error("SVG.attr was called with a null element");
        }
        if (typeof k !== "string") {
          console.log(k);
          throw new Error("SVG.attr requires a string as the second argument, got ^^^");
        }
        if (typeof v === "number" && isNaN(v)) {
          console.log(elm, k);
          throw new Error("SVG.attr was called with a NaN value for ^^^");
        }
        if (elm._SVG_attr == null) {
          elm._SVG_attr = {};
        }
        if (v === void 0) {
          return (base1 = elm._SVG_attr)[k] != null ? base1[k] : base1[k] = elm.getAttribute(k);
        }
        if (elm._SVG_attr[k] === v) {
          return v;
        }
        elm._SVG_attr[k] = v;
        if (propNames[k] != null) {
          return elm[k] = v;
        }
        ns = k === "xlink:href" ? xlinkNS : null;
        k = attrNames[k] != null ? attrNames[k] : attrNames[k] = k.replace(/([A-Z])/g, "-$1").toLowerCase();
        if (v != null) {
          elm.setAttributeNS(ns, k, v);
        } else {
          elm.removeAttributeNS(ns, k);
        }
        return v;
      },
      styles: function(elm, styles) {
        var k, v;
        if (!elm) {
          throw new Error("SVG.styles was called with a null element");
        }
        if (typeof styles !== "object") {
          console.log(styles);
          throw new Error("SVG.styles requires an object as the second argument, got ^");
        }
        for (k in styles) {
          v = styles[k];
          SVG.style(elm, k, v);
        }
        return elm;
      },
      style: function(elm, k, v) {
        var base1;
        if (!elm) {
          throw new Error("SVG.style was called with a null element");
        }
        if (typeof k !== "string") {
          console.log(k);
          throw new Error("SVG.style requires a string as the second argument, got ^");
        }
        if (typeof v === "number" && isNaN(v)) {
          console.log(elm, k);
          throw new Error("SVG.style was called with a NaN value for ^^^");
        }
        if (elm._SVG_style == null) {
          elm._SVG_style = {};
        }
        if (v === void 0) {
          return (base1 = elm._SVG_style)[k] != null ? base1[k] : base1[k] = elm.style[k];
        }
        if (elm._SVG_style[k] !== v) {
          elm.style[k] = elm._SVG_style[k] = v;
        }
        return v;
      }
    });
  });

  Take("Registry", function(Registry) {
    var Symbol;
    Symbol = function(symbolName, instanceNames, symbol) {
      var instanceName, len, m, results;
      symbol.symbolName = symbolName;
      Registry.set("Symbols", symbolName, symbol);
      results = [];
      for (m = 0, len = instanceNames.length; m < len; m++) {
        instanceName = instanceNames[m];
        results.push(Registry.set("SymbolNames", instanceName, symbol));
      }
      return results;
    };
    Symbol.forSymbolName = function(symbolName) {
      return Registry.get("Symbols", symbolName);
    };
    Symbol.forInstanceName = function(instanceName) {
      return Registry.get("SymbolNames", instanceName);
    };
    return Make("Symbol", Symbol);
  });

  Take(["ParentElement", "RAF"], function(ParentElement, RAF) {
    var callbacks, internalTime, maximumDt, tick, wallTime;
    maximumDt = 0.5;
    callbacks = [];
    wallTime = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
    internalTime = 0;
    RAF(tick = function(t) {
      var cb, dt, len, m;
      dt = Math.min(t / 1000 - wallTime, maximumDt);
      wallTime = t / 1000;
      if (!ParentElement.disableSVGA) {
        internalTime += dt;
        for (m = 0, len = callbacks.length; m < len; m++) {
          cb = callbacks[m];
          cb(internalTime, dt);
        }
      }
      return RAF(tick);
    });
    return Make("Tick", function(cb, ignoreDuplicates) {
      var c, len, m;
      if (ignoreDuplicates == null) {
        ignoreDuplicates = false;
      }
      for (m = 0, len = callbacks.length; m < len; m++) {
        c = callbacks[m];
        if (!(c === cb)) {
          continue;
        }
        if (ignoreDuplicates) {
          return;
        }
        console.log(cb);
        throw new Error("^ Tick was called more than once with this function. You can use Tick(fn, true) to drop duplicates and bypass this error.");
      }
      callbacks.push(cb);
      return cb;
    });
  });

  Take(["RAF", "SVG"], function(RAF, SVG) {
    var TRS;
    TRS = function(elm, debugColor) {
      var v, wrapper;
      if (elm == null) {
        console.log(elm);
        throw new Error("^ Null element passed to TRS(elm)");
      }
      wrapper = SVG.create("g", elm.parentNode, {
        xTrs: ""
      });
      SVG.append(wrapper, elm);
      if (debugColor != null) {
        SVG.create("rect", wrapper, {
          "class": "Debug",
          x: -2,
          y: -2,
          width: 4,
          height: 4,
          fill: debugColor
        });
      }
      elm._trs = v = {
        x: 0,
        y: 0,
        r: 0,
        sx: 1,
        sy: 1,
        ox: 0,
        oy: 0,
        apply: function() {
          SVG.attr(wrapper, "transform", "translate(" + v.x + "," + v.y + ") rotate(" + (v.r * 360) + ") scale(" + v.sx + "," + v.sy + ")");
          return SVG.attr(elm, "transform", "translate(" + (-v.ox) + "," + (-v.oy) + ")");
        }
      };
      return elm;
    };
    TRS.abs = function(elm, attrs) {
      var delta;
      if ((elm != null ? elm._trs : void 0) == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.abs(elm, attrs)");
      }
      if (attrs == null) {
        console.log(elm);
        throw new Error("^ Null attrs passed to TRS.abs(elm, attrs)");
      }
      if (attrs.scale != null) {
        attrs.sx = attrs.sy = attrs.scale;
      }
      if (attrs.x != null) {
        elm._trs.x = attrs.x;
      }
      if (attrs.y != null) {
        elm._trs.y = attrs.y;
      }
      if (attrs.r != null) {
        elm._trs.r = attrs.r;
      }
      if (attrs.sx != null) {
        elm._trs.sx = attrs.sx;
      }
      if (attrs.sy != null) {
        elm._trs.sy = attrs.sy;
      }
      if (attrs.ox != null) {
        delta = attrs.ox - elm._trs.ox;
        elm._trs.ox = attrs.ox;
        elm._trs.x += delta;
      }
      if (attrs.oy != null) {
        delta = attrs.oy - elm._trs.oy;
        elm._trs.oy = attrs.oy;
        elm._trs.y += delta;
      }
      if (attrs.now) {
        elm._trs.apply();
      } else {
        RAF(elm._trs.apply, true, 1);
      }
      return elm;
    };
    TRS.rel = function(elm, attrs) {
      if ((elm != null ? elm._trs : void 0) == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.abs(elm, attrs)");
      }
      if (attrs == null) {
        console.log(elm);
        throw new Error("^ Null attrs passed to TRS.abs(elm, attrs)");
      }
      if (attrs.x != null) {
        elm._trs.x += attrs.x;
      }
      if (attrs.y != null) {
        elm._trs.y += attrs.y;
      }
      if (attrs.r != null) {
        elm._trs.r += attrs.r;
      }
      if (attrs.sx != null) {
        elm._trs.sx += attrs.sx;
      }
      if (attrs.sy != null) {
        elm._trs.sy += attrs.sy;
      }
      if (attrs.ox != null) {
        elm._trs.ox += attrs.ox;
        elm._trs.x += attrs.ox;
      }
      if (attrs.oy != null) {
        elm._trs.oy += attrs.oy;
        elm._trs.y += attrs.oy;
      }
      if (attrs.now) {
        elm._trs.apply();
      } else {
        RAF(elm._trs.apply, true, 1);
      }
      return elm;
    };
    TRS.move = function(elm, x, y) {
      if (x == null) {
        x = 0;
      }
      if (y == null) {
        y = 0;
      }
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.move");
      }
      return TRS.abs(elm, {
        x: x,
        y: y
      });
    };
    TRS.rotate = function(elm, r) {
      if (r == null) {
        r = 0;
      }
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.rotate");
      }
      return TRS.abs(elm, {
        r: r
      });
    };
    TRS.scale = function(elm, sx, sy) {
      if (sx == null) {
        sx = 1;
      }
      if (sy == null) {
        sy = sx;
      }
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.scale");
      }
      return TRS.abs(elm, {
        sx: sx,
        sy: sy
      });
    };
    TRS.origin = function(elm, ox, oy) {
      if (ox == null) {
        ox = 0;
      }
      if (oy == null) {
        oy = 0;
      }
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.origin");
      }
      return TRS.abs(elm, {
        ox: ox,
        oy: oy
      });
    };
    return Make("TRS", TRS);
  });

  Take(["Tick"], function(Tick) {
    var Tween, clone, dist, eases, gc, getEaseFn, getKeys, skipGC, tweens;
    tweens = [];
    skipGC = false;
    Tween = function(from, to, time, tween) {
      var keys;
      if (tween == null) {
        tween = {};
      }
      if (typeof tween === "function") {
        tween = {
          tick: tween
        };
      }
      tween.multi = typeof from === "object";
      if (tween.mutate == null) {
        tween.mutate = tween.tick == null;
      }
      tween.keys = keys = tween.multi ? getKeys(to) : ["v"];
      tween.from = tween.multi ? clone(from, keys) : {
        v: from
      };
      tween.to = tween.multi ? clone(to, keys) : {
        v: to
      };
      tween.delta = dist(tween.from, tween.to, keys);
      tween.value = tween.mutate && tween.multi ? from : clone(tween.from, keys);
      tween.time = Math.max(0, time);
      tween.ease = getEaseFn(tween.ease);
      tween.pos = Math.min(1, tween.pos || 0);
      tween.completed = false;
      tween.cancelled = false;
      gc(tween.tick, tween.from);
      tweens.push(tween);
      return tween;
    };
    getKeys = function(o) {
      var k, results;
      results = [];
      for (k in o) {
        results.push(k);
      }
      return results;
    };
    clone = function(i, keys) {
      var k, len, m, o;
      o = {};
      for (m = 0, len = keys.length; m < len; m++) {
        k = keys[m];
        o[k] = i[k];
      }
      return o;
    };
    dist = function(from, to, keys) {
      var k, len, m, o;
      o = {};
      for (m = 0, len = keys.length; m < len; m++) {
        k = keys[m];
        o[k] = to[k] - from[k];
      }
      return o;
    };
    getEaseFn = function(given) {
      if (typeof given === "string") {
        return eases[given] || (function() {
          throw new Error("Tween: \"" + given + "\" is not a value ease type.");
        })();
      } else if (typeof given === "function") {
        return given;
      } else {
        return eases.cubic;
      }
    };
    eases = {
      linear: function(v) {
        return v;
      },
      cubic: function(input) {
        input = 2 * Math.min(1, Math.abs(input));
        if (input < 1) {
          return 0.5 * Math.pow(input, 3);
        } else {
          return 1 - 0.5 * Math.abs(Math.pow(input - 2, 3));
        }
      }
    };
    gc = function(tick, from) {
      if (skipGC) {
        return;
      }
      return tweens = tweens.filter(function(tween) {
        if (tween.completed) {
          return false;
        }
        if (tween.cancelled) {
          return false;
        }
        if ((tick != null) && tick === tween.tick) {
          return false;
        }
        if ((from != null) && from === tween.from) {
          return false;
        }
        return true;
      });
    };
    Tween.cancel = function() {
      var len, m, tween, tweensToCancel;
      tweensToCancel = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      for (m = 0, len = tweensToCancel.length; m < len; m++) {
        tween = tweensToCancel[m];
        tween.cancelled = true;
      }
      return gc();
    };
    Tick(function(t, dt) {
      var e, k, len, len1, m, n, ref, tween, v;
      skipGC = true;
      for (m = 0, len = tweens.length; m < len; m++) {
        tween = tweens[m];
        if (!(!tween.cancelled)) {
          continue;
        }
        tween.pos = tween.time <= 0 ? 1 : Math.min(1, tween.pos + dt / tween.time);
        e = tween.ease(tween.pos);
        ref = tween.keys;
        for (n = 0, len1 = ref.length; n < len1; n++) {
          k = ref[n];
          tween.value[k] = tween.from[k] + tween.delta[k] * e;
        }
        v = tween.multi ? tween.value : tween.value.v;
        if (typeof tween.tick === "function") {
          tween.tick(v, tween);
        }
        if (tween.completed = tween.pos === 1) {
          if (typeof tween.then === "function") {
            tween.then(v, tween);
          }
        }
      }
      skipGC = false;
      return gc();
    });
    return Make("Tween", Tween);
  });

}).call(this);
