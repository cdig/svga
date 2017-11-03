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
      Registry.closeRegistration("SettingType");
      Make("ControlReady");
      Registry.closeRegistration("Symbols");
      Registry.closeRegistration("SymbolNames");
      Scene.build(svgData);
      svgData = null;
      Make("SceneReady");
      return Make("AllReady");
    });
  });

  Take(["Mode", "Scope", "SVG", "Symbol"], function(Mode, Scope, SVG, Symbol) {
    var Scene, buildScopes, cleanupIds, defs, deprecations, masks, processElm;
    deprecations = ["controlPanel", "ctrlPanel", "navOverlay"];
    masks = [];
    defs = {};
    Make("Scene", Scene = {
      crawl: function(elm) {
        var tree;
        cleanupIds(elm);
        tree = processElm(elm);
        if (masks.length) {
          console.log.apply(console, ["Please remove these mask elements from your SVG:"].concat(slice.call(masks)));
        }
        masks = null;
        defs = null;
        return tree;
      },
      build: function(tree) {
        var m, setup, setups;
        buildScopes(tree, setups = []);
        for (m = setups.length - 1; m >= 0; m += -1) {
          setup = setups[m];
          setup();
        }
        return void 0;
      }
    });
    cleanupIds = function(elm) {
      var element, len, m, ref;
      if (!Mode.dev) {
        return;
      }
      ref = elm.querySelectorAll("[id]");
      for (m = 0, len = ref.length; m < len; m++) {
        element = ref[m];
        if (window[element.id] != null) {
          (function(element) {
            var handlers;
            handlers = {
              get: function() {
                console.log(element);
                throw "You forgot to use an @ when accessing the scope for this element ^^^";
              },
              set: function(val) {
                console.log(element);
                throw "You forgot to use an @ when accessing the scope for this element ^^^";
              }
            };
            return window[element.id] = new Proxy({}, handlers);
          })(element);
        }
      }
      return void 0;
    };
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
      var baseName, len, m, props, ref, ref1, scope, subTarget, symbol;
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
      symbol = baseName.indexOf("Line") > -1 || baseName.indexOf("line") === 0 ? Symbol.forSymbolName("HydraulicLine") : baseName.indexOf("Field") > -1 || baseName.indexOf("field") === 0 ? Symbol.forSymbolName("HydraulicField") : props.id != null ? Symbol.forInstanceName(props.id) : void 0;
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
      for (m = 0, len = ref1.length; m < len; m++) {
        subTarget = ref1[m];
        buildScopes(subTarget, setups, scope);
      }
      return void 0;
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
          var child, f, len, m, s;
          if (active) {
            f = flow * direction * parentFlow;
            s = volume * scale * parentScale;
            for (m = 0, len = children.length; m < len; m++) {
              child = children[m];
              child.update(f, s);
            }
          }
          return void 0;
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
      var len, m, set;
      for (m = 0, len = sets.length; m < len; m++) {
        set = sets[m];
        set.enabled = visible && animateMode;
      }
      return void 0;
    };
    Tick(function(time, dt) {
      var f, len, m, s, set;
      if (visible && animateMode) {
        for (m = 0, len = sets.length; m < len; m++) {
          set = sets[m];
          if (set.parentScope.alpha > 0) {
            f = dt * Config.SPEED;
            s = Config.SCALE;
            set.update(f, s);
          }
        }
      }
      return void 0;
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
    Reaction("Background:Set", function(v) {
      return SVG.style(ParentElement, "background-color", v);
    });
    Reaction("Background:Lightness", function(v) {
      return Action("Background:Set", "hsl(227, 5%, " + (v * 100 | 0) + "%)");
    });
    if (typeof Mode.background === "string") {
      return Action("Background:Set", Mode.background);
    } else if (Mode.background === true) {
      return Take("SceneReady", function() {
        return Action("Background:Lightness", .7);
      });
    } else {
      return Action("Background:Set", "transparent");
    }
  });

  Take(["GUI", "Mode", "Resize", "SVG", "TRS", "SVGReady"], function(GUI, Mode, Resize, SVG, TRS) {
    var g, hide, show;
    return;
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
        x: SVG.svg.getBoundingClientRect().width / 2
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

  Take(["ControlPanelLayout", "Gradient", "GUI", "Mode", "Reaction", "SVG", "Scope", "TRS", "ControlReady"], function(ControlPanelLayout, Gradient, GUI, Mode, Reaction, SVG, Scope, TRS, ControlReady) {
    var CP, ControlPanel, columnsElm, config, groups, makePanelInfo, panelBg, panelElm, showing;
    CP = GUI.ControlPanel;
    config = Mode.controlPanel != null ? Mode.controlPanel : Mode.controlPanel = {};
    showing = false;
    groups = [];
    panelElm = SVG.create("g", GUI.elm, {
      xControls: "",
      fontSize: 16,
      textAnchor: "middle"
    });
    panelBg = SVG.create("rect", panelElm, {
      xPanelBg: "",
      rx: CP.panelBorderRadius,
      fill: "hsl(220, 45%, 45%)"
    });
    columnsElm = SVG.create("g", panelElm, {
      xColumns: "",
      transform: "translate(" + CP.panelPadding + "," + CP.panelPadding + ")"
    });
    Take("SceneReady", function() {
      if (!showing) {
        return GUI.elm.removeChild(panelElm);
      }
    });
    makePanelInfo = function(vertical, panelSize, view) {
      var controlPanelScale, controlPanelX, controlPanelY, marginedViewHeight, marginedViewWidth, normalizedX, normalizedY, panelInfo, scaledPanelH, scaledPanelW, signedXPosition, signedYPosition;
      controlPanelScale = vertical && (panelSize.w > view.w / 2 || panelSize.h > view.h) ? Math.max(0.7, Math.min(view.w / panelSize.w / 2, view.h / panelSize.h)) : !vertical && (panelSize.h > view.h / 2 || panelSize.w > view.w) ? Math.max(0.7, Math.min(view.w / panelSize.w, view.h / panelSize.h / 2)) : 1;
      scaledPanelW = panelSize.w * controlPanelScale;
      scaledPanelH = panelSize.h * controlPanelScale;
      if ((config.x != null) || (config.y != null)) {
        signedXPosition = config.x || 0;
        signedYPosition = config.y || 0;
      } else if (vertical) {
        signedXPosition = 1;
        signedYPosition = 0;
      } else {
        signedXPosition = 0;
        signedYPosition = 1;
      }
      marginedViewWidth = view.w - scaledPanelW;
      marginedViewHeight = view.h - scaledPanelH;
      normalizedX = signedXPosition / 2 + 0.5;
      normalizedY = signedYPosition / 2 + 0.5;
      controlPanelX = CP.panelMargin + normalizedX * marginedViewWidth | 0;
      controlPanelY = CP.panelMargin + normalizedY * marginedViewHeight | 0;
      return panelInfo = {
        controlPanelScale: controlPanelScale,
        controlPanelX: controlPanelX,
        controlPanelY: controlPanelY,
        vertical: vertical,
        signedX: signedXPosition,
        signedY: signedYPosition,
        w: scaledPanelW + CP.panelMargin * 2,
        h: scaledPanelH + CP.panelMargin * 2
      };
    };
    Make("ControlPanel", ControlPanel = Scope(panelElm, function() {
      return {
        registerGroup: function(group) {
          return groups.push(group);
        },
        createItemElement: function(parent) {
          showing = true;
          return SVG.create("g", parent);
        },
        getPanelLayoutInfo: function(horizontalIsBetter) {
          var horizontalPanelInfo, horizontalPanelSize, outerBounds, panelInfo, panelSize, vertical, verticalPanelInfo, verticalPanelSize, view;
          outerBounds = SVG.svg.getBoundingClientRect();
          view = {
            w: outerBounds.width - CP.panelMargin * 2,
            h: outerBounds.height - CP.panelMargin * 2
          };
          if (config.vertical === true) {
            vertical = true;
            panelSize = ControlPanelLayout.vertical(groups, view, columnsElm);
          } else if (config.vertical === false) {
            vertical = false;
            panelSize = ControlPanelLayout.horizontal(groups, view, columnsElm);
          } else {
            horizontalPanelSize = ControlPanelLayout.horizontal(groups, view, columnsElm);
            verticalPanelSize = ControlPanelLayout.vertical(groups, view, columnsElm);
            horizontalPanelInfo = makePanelInfo(false, horizontalPanelSize, view);
            verticalPanelInfo = makePanelInfo(true, verticalPanelSize, view);
            if (horizontalIsBetter(horizontalPanelInfo, verticalPanelInfo)) {
              vertical = false;
              panelSize = ControlPanelLayout.horizontal(groups, view, columnsElm);
            } else {
              vertical = true;
              panelSize = verticalPanelSize;
            }
          }
          panelInfo = makePanelInfo(vertical, panelSize, view);
          SVG.attrs(panelBg, {
            width: panelSize.w,
            height: panelSize.h
          });
          ControlPanel.scale = panelInfo.controlPanelScale;
          ControlPanel.x = panelInfo.controlPanelX;
          ControlPanel.y = panelInfo.controlPanelY;
          return panelInfo;
        }
      };
    }));
    Reaction("ControlPanel:Show", function() {
      return ControlPanel.show(.7);
    });
    return Reaction("ControlPanel:Hide", function() {
      return ControlPanel.hide(.3);
    });
  });

  Take(["GUI", "Mode", "SVG"], function(arg, Mode, SVG) {
    var GUI, checkPanelSize, columns, getColumn, performLayout;
    GUI = arg.ControlPanel;
    columns = [];
    getColumn = function(index, panelElm) {
      return columns[index] != null ? columns[index] : columns[index] = {
        x: index * (GUI.colInnerWidth + GUI.groupPad * 2 + GUI.columnMargin),
        groups: [],
        height: 0,
        visible: false,
        element: SVG.create("g", panelElm)
      };
    };
    performLayout = function(groups, panelElm, desiredColumnHeight) {
      var column, currentColumnIndex, group, len, len1, len2, len3, m, n, panelHeight, panelWidth, q, tallestColumnHeight, u, y;
      for (m = 0, len = columns.length; m < len; m++) {
        column = columns[m];
        column.groups = [];
        column.height = 0;
        column.visible = false;
      }
      currentColumnIndex = 0;
      column = getColumn(currentColumnIndex, panelElm);
      for (n = 0, len1 = groups.length; n < len1; n++) {
        group = groups[n];
        if (column.height > desiredColumnHeight) {
          column = getColumn(++currentColumnIndex, panelElm);
        }
        if (column.groups.length > 0) {
          column.height += GUI.groupMargin;
        }
        column.groups.push(group);
        SVG.append(column.element, group.scope.element);
        group.scope.y = column.height;
        column.height += group.height;
        column.visible = true;
      }
      tallestColumnHeight = 0;
      for (q = 0, len2 = columns.length; q < len2; q++) {
        column = columns[q];
        if (column.visible) {
          tallestColumnHeight = Math.max(tallestColumnHeight, column.height);
        }
      }
      for (u = 0, len3 = columns.length; u < len3; u++) {
        column = columns[u];
        if (!column.visible) {
          continue;
        }
        y = tallestColumnHeight / 2 - column.height / 2;
        SVG.attrs(column.element, {
          transform: "translate(" + column.x + "," + y + ")"
        });
      }
      panelWidth = GUI.panelPadding * 2 + (currentColumnIndex + 1) * (GUI.colInnerWidth + GUI.groupPad * 2) + currentColumnIndex * GUI.columnMargin;
      panelHeight = GUI.panelPadding * 2 + tallestColumnHeight;
      return {
        w: panelWidth,
        h: panelHeight
      };
    };
    Make("ControlPanelLayout", {
      vertical: function(groups, availableSpace, panelElm) {
        var availableSpaceInsidePanel, desiredColumnHeight, group, len, m, nColumns, totalHeight;
        if (!(availableSpace.h > 0 && groups.length > 0)) {
          return {
            w: 0,
            h: 0
          };
        }
        totalHeight = 0;
        for (m = 0, len = groups.length; m < len; m++) {
          group = groups[m];
          totalHeight += group.height;
        }
        totalHeight += GUI.groupMargin * (groups.length - 1);
        availableSpaceInsidePanel = availableSpace.h - GUI.panelPadding * 2;
        nColumns = Mode.embed ? 1 : Math.ceil(totalHeight / availableSpaceInsidePanel);
        desiredColumnHeight = Math.max(GUI.unit, Math.floor(totalHeight / nColumns));
        return performLayout(groups, panelElm, desiredColumnHeight);
      },
      horizontal: function(groups, availableSpace, panelElm) {
        var desiredColumnHeight, group, len, m;
        if (!(availableSpace.w > 0 && groups.length > 0)) {
          return {
            w: 0,
            h: 0
          };
        }
        desiredColumnHeight = 0;
        for (m = 0, len = groups.length; m < len; m++) {
          group = groups[m];
          desiredColumnHeight = Math.max(desiredColumnHeight, group.height);
        }
        while (!checkPanelSize(desiredColumnHeight, groups, availableSpace)) {
          desiredColumnHeight += GUI.unit / 2;
        }
        return performLayout(groups, panelElm, desiredColumnHeight);
      }
    });
    return checkPanelSize = function(columnHeight, groups, availableSpace) {
      var consumedHeight, consumedWidth, group, len, m, nthGroupInColumn;
      consumedWidth = GUI.colInnerWidth + GUI.panelPadding * 2;
      consumedHeight = GUI.panelPadding * 2;
      nthGroupInColumn = 0;
      for (m = 0, len = groups.length; m < len; m++) {
        group = groups[m];
        if (consumedHeight > columnHeight) {
          consumedWidth += GUI.colInnerWidth + GUI.columnMargin;
          consumedHeight = GUI.panelPadding * 2;
          nthGroupInColumn = 0;
        }
        if (nthGroupInColumn > 0) {
          consumedHeight += GUI.groupMargin;
        }
        consumedHeight += group.height;
        nthGroupInColumn++;
      }
      return consumedWidth < availableSpace.w || columnHeight > availableSpace.h / 2;
    };
  });

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function(arg, Input, Registry, SVG, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "button", function(elm, props) {
      var bg, bgFill, bgc, blocked, blueBG, handlers, label, labelFill, lightBG, orangeBG, scope, strokeWidth, tickBG, toClicked, toClicking, toHover, toNormal;
      handlers = [];
      bgFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(227, 16%, 24%)";
      strokeWidth = 2;
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm, {
        x: strokeWidth / 2,
        y: strokeWidth / 2,
        width: GUI.colInnerWidth - strokeWidth,
        height: GUI.unit - strokeWidth,
        rx: GUI.borderRadius,
        strokeWidth: strokeWidth,
        fill: bgFill
      });
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: GUI.colInnerWidth / 2,
        y: (props.fontSize || 16) + GUI.unit / 5,
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal",
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
      blocked = false;
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
          var handler, len, m;
          if (blocked) {
            return;
          }
          blocked = true;
          setTimeout((function() {
            return blocked = false;
          }), 100);
          toClicked();
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            handler();
          }
          return void 0;
        }
      });
      return scope = {
        height: GUI.unit,
        attach: function(props) {
          if (props.click != null) {
            return handlers.push(props.click);
          }
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
      throw "Error: Control.divider() has been removed.";
    });
  });

  Take(["Registry", "GUI", "Scope", "SVG"], function(Registry, arg, Scope, SVG) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "label", function(elm, props) {
      var height, label, labelFill, labelY, scope;
      labelY = GUI.labelPad + (props.fontSize || 16) * 0.75;
      height = GUI.labelPad + (props.fontSize || 16);
      labelFill = "hsl(220, 10%, 92%)";
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: GUI.colInnerWidth / 2,
        y: labelY,
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal",
        fill: labelFill
      });
      return scope = {
        height: height
      };
    });
  });

  Take(["GUI", "Input", "PopoverButton", "RAF", "Registry", "Resize", "Scope", "SVG", "Tween"], function(arg, Input, PopoverButton, RAF, Registry, Resize, Scope, SVG, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "popover", function(elm, props) {
      var activeButtonCancelCb, activeLabel, bgc, blocked, blueBG, buttonContainer, buttons, controlPanelScale, desiredPanelX, desiredPanelY, height, itemElm, label, labelFill, labelHeight, labelTriangle, labelY, lightBG, nextButtonOffsetY, orangeBG, panel, panelInner, panelIsVertical, panelRect, panelTriangle, rect, rectFill, reposition, requestReposition, resize, scope, setActive, showing, strokeWidth, tickBG, toClicked, toClicking, toHover, toNormal, triangleFill, triangleSize, update, windowHeight;
      labelFill = "hsl(220, 10%, 92%)";
      rectFill = "hsl(227, 45%, 25%)";
      triangleFill = "hsl(220, 35%, 80%)";
      triangleSize = 24;
      strokeWidth = 2;
      showing = false;
      panelIsVertical = true;
      buttons = [];
      nextButtonOffsetY = 0;
      activeButtonCancelCb = null;
      labelY = 0;
      labelHeight = 0;
      height = 0;
      desiredPanelX = null;
      desiredPanelY = null;
      controlPanelScale = null;
      windowHeight = null;
      if (props.name != null) {
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75;
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2;
      } else {
        labelHeight = 0;
      }
      height = labelHeight + GUI.unit;
      itemElm = SVG.create("g", elm, {
        ui: true
      });
      if (props.name != null) {
        label = SVG.create("text", itemElm, {
          textContent: props.name,
          x: GUI.colInnerWidth / 2,
          y: labelY,
          fontSize: props.fontSize || 16,
          fontWeight: props.fontWeight || "normal",
          fontStyle: props.fontStyle || "normal",
          fill: labelFill
        });
      }
      rect = SVG.create("rect", itemElm, {
        rx: GUI.borderRadius + 2,
        fill: rectFill,
        x: 0,
        y: labelHeight,
        width: GUI.colInnerWidth,
        height: GUI.unit,
        strokeWidth: strokeWidth
      });
      activeLabel = SVG.create("text", itemElm, {
        y: labelHeight + 21,
        fill: "hsl(92, 46%, 57%)"
      });
      labelTriangle = SVG.create("polyline", itemElm, {
        points: "6,-6 13,0 6,6",
        transform: "translate(0, " + (labelHeight + GUI.unit / 2) + ")",
        stroke: triangleFill,
        strokeWidth: 4,
        strokeLinecap: "round",
        fill: "none"
      });
      panel = Scope(SVG.create("g", elm));
      panel.hide(0);
      panelTriangle = SVG.create("polyline", panel.element, {
        points: "0," + (-triangleSize / 2) + " " + (triangleSize * 4 / 7) + ",0 0," + (triangleSize / 2),
        fill: triangleFill
      });
      panelInner = SVG.create("g", panel.element);
      panelRect = SVG.create("rect", panelInner, {
        width: GUI.colInnerWidth,
        rx: GUI.panelBorderRadius,
        fill: triangleFill
      });
      buttonContainer = SVG.create("g", panelInner, {
        transform: "translate(" + GUI.panelPadding + "," + GUI.panelPadding + ")"
      });
      resize = function() {
        if (panelIsVertical) {
          desiredPanelX = -GUI.colInnerWidth - 6;
          desiredPanelY = labelHeight + GUI.unit / 2 - nextButtonOffsetY / 2;
          SVG.attrs(panelTriangle, {
            transform: "translate(-7," + (labelHeight + GUI.unit / 2) + ")"
          });
        } else {
          desiredPanelX = 0;
          desiredPanelY = panelInner.y = -nextButtonOffsetY - triangleSize + labelHeight + 9;
          SVG.attrs(panelTriangle, {
            transform: "translate(" + (GUI.colInnerWidth / 2) + "," + (labelHeight - 7) + ") rotate(90)"
          });
        }
        SVG.attrs(panelInner, {
          transform: "translate(" + desiredPanelX + ", " + desiredPanelY + ")"
        });
        return requestReposition();
      };
      requestReposition = function() {
        return RAF(reposition, true);
      };
      reposition = function() {
        var bounds, moveToBottom, moveToTop, newPanelY, offBottom, offTop, panelScale, tooTall;
        bounds = panelInner.getBoundingClientRect();
        tooTall = bounds.height > windowHeight - GUI.panelMargin * 2;
        offTop = bounds.top / controlPanelScale < GUI.panelMargin;
        offBottom = bounds.bottom / controlPanelScale > windowHeight - GUI.panelMargin;
        moveToTop = desiredPanelY - bounds.top / controlPanelScale + GUI.panelMargin;
        moveToBottom = desiredPanelY - (bounds.bottom / controlPanelScale) / controlPanelScale + (windowHeight - GUI.panelMargin);
        if (tooTall) {
          panelScale = Math.min(1, (windowHeight - GUI.panelMargin * 2) / bounds.height);
          newPanelY = moveToTop;
        } else if (offTop) {
          newPanelY = moveToTop;
          panelScale = 1;
        } else if (offBottom) {
          newPanelY = moveToBottom;
          panelScale = 1;
        } else {
          newPanelY = desiredPanelY;
          panelScale = 1;
        }
        return SVG.attrs(panelInner, {
          transform: "translate(" + (desiredPanelX * panelScale) + ", " + newPanelY + ") scale(" + panelScale + ")"
        });
      };
      setActive = function(name, unclick) {
        SVG.attrs(activeLabel, {
          textContent: name,
          x: GUI.colInnerWidth / 2 + (name.length > 14 ? 8 : 0)
        });
        if (typeof activeButtonCancelCb === "function") {
          activeButtonCancelCb();
        }
        activeButtonCancelCb = unclick;
        if (showing) {
          showing = false;
          return update();
        }
      };
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
        return SVG.attrs(rect, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      update = function() {
        if (showing) {
          panel.show(0);
          return resize();
        } else {
          return panel.hide(0.2);
        }
      };
      blocked = false;
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
      Input(itemElm, {
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
        upOther: function(e, state) {
          if (showing) {
            showing = false;
            return update();
          }
        },
        click: function() {
          if (blocked) {
            return;
          }
          blocked = true;
          setTimeout((function() {
            return blocked = false;
          }), 100);
          showing = !showing;
          return update();
        }
      });
      Resize(function(info) {
        windowHeight = info.window.height;
        controlPanelScale = info.panel.scale;
        panelIsVertical = info.panel.vertical;
        desiredPanelY = null;
        return resize();
      });
      return scope = {
        height: height,
        button: function(props) {
          var buttonElm, buttonScope;
          props.setActive = setActive;
          buttonElm = SVG.create("g", buttonContainer);
          buttonScope = Scope(buttonElm, PopoverButton, props);
          buttons.push(buttonScope);
          buttonScope.y = nextButtonOffsetY;
          nextButtonOffsetY += GUI.unit + GUI.itemMargin;
          SVG.attrs(panelRect, {
            height: nextButtonOffsetY + GUI.panelPadding * 2 - GUI.itemMargin
          });
          return buttonScope;
        },
        _highlight: function(enable) {
          var button, len, m, results;
          if (enable) {
            SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
            SVG.attrs(rect, {
              fill: "url(#DarkHighlightGradient)"
            });
          } else {
            SVG.attrs(label, {
              fill: labelFill
            });
            SVG.attrs(rect, {
              fill: rectFill
            });
          }
          results = [];
          for (m = 0, len = buttons.length; m < len; m++) {
            button = buttons[m];
            results.push(button._highlight(enable));
          }
          return results;
        }
      };
    });
  });

  Take(["GUI", "Input", "SVG", "Tween"], function(arg, Input, SVG, Tween) {
    var GUI, active;
    GUI = arg.ControlPanel;
    active = null;
    return Make("PopoverButton", function(elm, props) {
      var activeBG, attachClick, bg, blueBG, click, curBG, handlers, highlighting, isActive, label, labelFill, orangeBG, scope, tickBG, toActive, toClicking, toHover, toNormal, unclick, whiteBG;
      handlers = [];
      isActive = false;
      highlighting = false;
      labelFill = "hsl(227, 16%, 24%)";
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm, {
        width: GUI.colInnerWidth - GUI.panelPadding * 2,
        height: GUI.unit,
        rx: GUI.groupBorderRadius
      });
      label = SVG.create("text", elm, {
        x: GUI.colInnerWidth / 2 - GUI.panelPadding,
        y: (props.fontSize || 16) + GUI.unit / 5,
        textContent: props.name,
        fill: labelFill,
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal"
      });
      curBG = null;
      whiteBG = {
        h: 220,
        s: 10,
        l: 92
      };
      blueBG = {
        h: 215,
        s: 100,
        l: 86
      };
      orangeBG = {
        h: 43,
        s: 100,
        l: 59
      };
      activeBG = {
        h: 92,
        s: 46,
        l: 57
      };
      tickBG = function(_curBG) {
        curBG = _curBG;
        if (highlighting && isActive) {
          return SVG.attrs(bg, {
            fill: "url(#MidHighlightGradient)"
          });
        } else {
          return SVG.attrs(bg, {
            fill: "hsl(" + (curBG.h | 0) + "," + (curBG.s | 0) + "%," + (curBG.l | 0) + "%)"
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
        return Tween(curBG, activeBG, .2, {
          tick: tickBG
        });
      };
      unclick = function() {
        toNormal();
        return isActive = false;
      };
      click = function(e, state) {
        var handler, len, m;
        props.setActive(props.name, unclick);
        isActive = true;
        toActive();
        for (m = 0, len = handlers.length; m < len; m++) {
          handler = handlers[m];
          handler();
        }
        return void 0;
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

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function(arg, Input, Registry, SVG, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "pushButton", function(elm, props) {
      var bgFill, blueBG, bsc, button, height, hit, label, labelFill, lightBG, offHandlers, onHandlers, orangeBG, radius, scope, strokeWidth, tickBG, toClicking, toHover, toNormal;
      onHandlers = [];
      offHandlers = [];
      strokeWidth = 2;
      radius = GUI.unit * 0.6;
      height = Math.max(radius * 2, props.fontSize || 16);
      bgFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(220, 10%, 92%)";
      SVG.attrs(elm, {
        ui: true
      });
      hit = SVG.create("rect", elm, {
        width: GUI.colInnerWidth,
        height: height,
        fill: "transparent"
      });
      button = SVG.create("circle", elm, {
        cx: radius,
        cy: radius,
        r: radius - strokeWidth / 2,
        strokeWidth: strokeWidth,
        fill: bgFill
      });
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: radius * 2 + GUI.labelMargin,
        y: radius + (props.fontSize || 16) * 0.375,
        textAnchor: "start",
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal",
        fill: labelFill
      });
      bsc = blueBG = {
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
      tickBG = function(_bsc) {
        bsc = _bsc;
        return SVG.attrs(button, {
          stroke: "rgb(" + (bsc.r | 0) + "," + (bsc.g | 0) + "," + (bsc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      toNormal = function(e, state) {
        return Tween(bsc, blueBG, .2, {
          tick: tickBG
        });
      };
      toHover = function(e, state) {
        return Tween(bsc, lightBG, 0, {
          tick: tickBG
        });
      };
      toClicking = function(e, state) {
        return Tween(bsc, orangeBG, 0, {
          tick: tickBG
        });
      };
      Input(elm, {
        moveIn: toHover,
        down: function() {
          var len, m, onHandler;
          toClicking();
          for (m = 0, len = onHandlers.length; m < len; m++) {
            onHandler = onHandlers[m];
            onHandler();
          }
          return void 0;
        },
        up: function() {
          var len, m, offHandler;
          toHover();
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            offHandler();
          }
          return void 0;
        },
        miss: function() {
          var len, m, offHandler;
          toNormal();
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            offHandler();
          }
          return void 0;
        },
        moveOut: toNormal
      });
      return scope = {
        height: height,
        attach: function(props) {
          if (props.on != null) {
            onHandlers.push(props.on);
          }
          if (props.off != null) {
            return offHandlers.push(props.off);
          }
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(button, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
          } else {
            SVG.attrs(button, {
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
      var activeButton, borderFill, borderRect, buttons, buttonsContainer, clip, clipRect, height, id, label, labelFill, labelHeight, labelY, scope, setActive;
      id = "Selector" + (idCounter++);
      buttons = [];
      activeButton = null;
      if (props.name != null) {
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75;
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2;
      } else {
        labelHeight = 0;
      }
      height = labelHeight + GUI.unit;
      labelFill = "hsl(220, 10%, 92%)";
      borderFill = "rgb(34, 46, 89)";
      clip = SVG.create("clipPath", SVG.defs, {
        id: id
      });
      clipRect = SVG.create("rect", clip, {
        x: 2,
        y: 2,
        width: GUI.colInnerWidth - 4,
        height: GUI.unit - 4,
        rx: GUI.borderRadius,
        fill: "#FFF"
      });
      if (props.name != null) {
        label = SVG.create("text", elm, {
          textContent: props.name,
          x: GUI.colInnerWidth / 2,
          y: labelY,
          fontSize: props.fontSize || 16,
          fontWeight: props.fontWeight || "normal",
          fontStyle: props.fontStyle || "normal",
          fill: labelFill
        });
      }
      borderRect = SVG.create("rect", elm, {
        rx: GUI.borderRadius + 2,
        fill: borderFill,
        x: 0,
        y: labelHeight,
        width: GUI.colInnerWidth,
        height: GUI.unit
      });
      buttonsContainer = Scope(SVG.create("g", elm, {
        clipPath: "url(#" + id + ")"
      }));
      buttonsContainer.x = 0;
      buttonsContainer.y = labelHeight;
      setActive = function(unclick) {
        if (typeof activeButton === "function") {
          activeButton();
        }
        return activeButton = unclick;
      };
      return scope = {
        height: height,
        button: function(props) {
          var button, buttonElm, buttonScope, buttonWidth, i, len, m;
          props.setActive = setActive;
          buttonElm = SVG.create("g", buttonsContainer.element);
          buttonScope = Scope(buttonElm, SelectorButton, props);
          buttons.push(buttonScope);
          buttonWidth = GUI.colInnerWidth / buttons.length;
          for (i = m = 0, len = buttons.length; m < len; i = ++m) {
            button = buttons[i];
            button.resize(buttonWidth);
            button.x = buttonWidth * i;
          }
          return buttonScope;
        },
        _highlight: function(enable) {
          var button, len, m, results;
          if (enable) {
            SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
            SVG.attrs(borderRect, {
              fill: "url(#DarkHighlightGradient)"
            });
          } else {
            SVG.attrs(label, {
              fill: labelFill
            });
            SVG.attrs(borderRect, {
              fill: borderFill
            });
          }
          results = [];
          for (m = 0, len = buttons.length; m < len; m++) {
            button = buttons[m];
            results.push(button._highlight(enable));
          }
          return results;
        }
      };
    });
  });

  Take(["GUI", "Input", "SVG", "Tween"], function(arg, Input, SVG, Tween) {
    var GUI, active;
    GUI = arg.ControlPanel;
    active = null;
    return Make("SelectorButton", function(elm, props) {
      var attachClick, bg, blueBG, click, curBG, handlers, highlighting, isActive, label, labelFill, lightBG, orangeBG, scope, strokeWidth, tickBG, toActive, toClicking, toHover, toNormal, unclick, whiteBG;
      handlers = [];
      isActive = false;
      highlighting = false;
      labelFill = "hsl(227, 16%, 24%)";
      strokeWidth = 2;
      SVG.attrs(elm, {
        ui: true
      });
      bg = SVG.create("rect", elm, {
        x: strokeWidth / 2,
        y: strokeWidth / 2,
        height: GUI.unit - strokeWidth
      });
      label = SVG.create("text", elm, {
        y: (props.fontSize || 16) + GUI.unit / 5,
        textContent: props.name,
        fill: labelFill,
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal"
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
        if (highlighting && isActive) {
          return SVG.attrs(bg, {
            fill: "url(#MidHighlightGradient)"
          });
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
        var handler, len, m;
        props.setActive(unclick);
        isActive = true;
        toActive();
        for (m = 0, len = handlers.length; m < len; m++) {
          handler = handlers[m];
          handler();
        }
        return void 0;
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
        resize: function(width) {
          SVG.attrs(bg, {
            width: width - strokeWidth
          });
          return SVG.attrs(label, {
            x: width / 2
          });
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
      var bgc, blueBG, handleDrag, handlers, height, hit, label, labelFill, labelHeight, labelY, lightBG, lightDot, normalDot, orangeBG, range, scope, snap, snapElms, snapTolerance, startDrag, strokeWidth, thumb, thumbBGFill, thumbSize, tickBG, toClicked, toClicking, toHover, toMissed, toNormal, track, trackFill, update, v;
      handlers = [];
      snapElms = [];
      v = 0;
      startDrag = 0;
      strokeWidth = 2;
      snapTolerance = 0.05;
      if (props.name != null) {
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75;
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2;
      } else {
        labelHeight = 0;
      }
      thumbSize = GUI.thumbSize;
      height = labelHeight + thumbSize;
      range = GUI.colInnerWidth - thumbSize;
      trackFill = "hsl(227, 45%, 24%)";
      thumbBGFill = "hsl(220, 10%, 92%)";
      labelFill = "hsl(220, 10%, 92%)";
      lightDot = "hsl(92, 46%, 57%)";
      normalDot = "hsl(220, 10%, 92%)";
      SVG.attrs(elm, {
        ui: true
      });
      hit = SVG.create("rect", elm, {
        width: GUI.colInnerWidth,
        height: height,
        fill: "transparent"
      });
      track = TRS(SVG.create("rect", elm, {
        x: strokeWidth / 2,
        y: labelHeight + strokeWidth / 2,
        width: GUI.colInnerWidth - strokeWidth,
        height: thumbSize - strokeWidth,
        strokeWidth: strokeWidth,
        fill: trackFill,
        stroke: "hsl(227, 45%, 24%)",
        rx: thumbSize / 2
      }));
      thumb = TRS(SVG.create("circle", elm, {
        cx: thumbSize / 2,
        cy: labelHeight + thumbSize / 2,
        strokeWidth: strokeWidth,
        fill: thumbBGFill,
        r: thumbSize / 2 - strokeWidth / 2
      }));
      if (props.snaps != null) {
        snapElms = (function() {
          var len, m, ref, results;
          ref = props.snaps;
          results = [];
          for (m = 0, len = ref.length; m < len; m++) {
            snap = ref[m];
            results.push(SVG.create("circle", elm, {
              cx: thumbSize / 2 + (GUI.colInnerWidth - thumbSize) * snap,
              cy: labelHeight + thumbSize / 2,
              fill: "transparent",
              strokeWidth: 4
            }));
          }
          return results;
        })();
      }
      if (props.name != null) {
        label = SVG.create("text", elm, {
          textContent: props.name,
          x: GUI.colInnerWidth / 2,
          y: labelY,
          fontSize: props.fontSize || 16,
          fontWeight: props.fontWeight || "normal",
          fontStyle: props.fontStyle || "normal",
          fill: labelFill
        });
      }
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
        return SVG.attrs(thumb, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      update = function(V) {
        var i, len, m, ref;
        if (V != null) {
          v = Math.max(0, Math.min(1, V));
        }
        if (props.snaps != null) {
          ref = props.snaps;
          for (i = m = 0, len = ref.length; m < len; i = ++m) {
            snap = ref[i];
            if (v > snap - snapTolerance && v < snap + snapTolerance) {
              v = snap;
              SVG.attrs(snapElms[i], {
                r: 3,
                stroke: lightDot
              });
            } else {
              SVG.attrs(snapElms[i], {
                r: 2,
                stroke: normalDot
              });
            }
          }
        }
        return TRS.abs(thumb, {
          x: v * range
        });
      };
      update(props.value || 0);
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
        var handler, len, m;
        if (state.clicking) {
          update(e.clientX / range - startDrag);
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            handler(v);
          }
          return void 0;
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
        height: height,
        attach: function(props) {
          if (props.change != null) {
            handlers.push(props.change);
          }
          if (props.value != null) {
            return update(props.value);
          }
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(track, {
              fill: "url(#DarkHighlightGradient)"
            });
            SVG.attrs(thumb, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
          } else {
            SVG.attrs(track, {
              fill: trackFill
            });
            SVG.attrs(thumb, {
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

  Take(["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], function(Registry, arg, Input, SVG, TRS, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Registry.set("Control", "switch", function(elm, props) {
      var active, bgc, blocked, blueBG, handlers, height, label, lightBG, lightTrack, normalTrack, orangeBG, scope, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toNormal, toggle, track, trackWidth;
      handlers = [];
      strokeWidth = 2;
      thumbSize = GUI.thumbSize;
      trackWidth = thumbSize * 2;
      active = false;
      height = thumbSize;
      normalTrack = "hsl(227, 45%, 24%)";
      lightTrack = "hsl(92, 46%, 57%)";
      SVG.attrs(elm, {
        ui: true
      });
      track = SVG.create("rect", elm, {
        x: strokeWidth / 2,
        y: strokeWidth / 2,
        width: trackWidth - strokeWidth,
        height: thumbSize - strokeWidth,
        strokeWidth: strokeWidth,
        fill: normalTrack,
        stroke: normalTrack,
        rx: thumbSize / 2
      });
      thumb = TRS(SVG.create("circle", elm, {
        cx: thumbSize / 2,
        cy: thumbSize / 2,
        strokeWidth: strokeWidth,
        fill: "hsl(220, 10%, 92%)",
        r: thumbSize / 2 - strokeWidth / 2
      }));
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: trackWidth + GUI.labelMargin,
        y: 21,
        textAnchor: "start",
        fill: "hsl(220, 10%, 92%)"
      });
      toggle = function() {
        active = !active;
        TRS.abs(thumb, {
          x: active ? thumbSize : 0
        });
        SVG.attrs(track, {
          fill: active ? lightTrack : normalTrack
        });
        return props.click(active);
      };
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
        return SVG.attrs(thumb, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      blocked = false;
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
          if (blocked) {
            return;
          }
          blocked = true;
          setTimeout((function() {
            return blocked = false;
          }), 100);
          toClicked();
          toggle();
          return void 0;
        }
      });
      return scope = {
        height: height,
        attach: function(props) {
          if (props.change != null) {
            handlers.push(props.change);
          }
          if (props.active) {
            return toggle();
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

  Take(["SVG", "SVGReady"], function(SVG) {
    var GUI, colInnerWidth, colUnits, groupBorderRadius, unit;
    return Make("GUI", GUI = {
      elm: SVG.create("g", SVG.svg, {
        xGui: ""
      }),
      ControlPanel: {
        borderRadius: 4,
        groupBorderRadius: groupBorderRadius = 6,
        panelBorderRadius: 8,
        panelMargin: 4,
        panelPadding: 6,
        columnMargin: 5,
        groupMargin: 4,
        groupPad: 3,
        itemMargin: 3,
        labelPad: 3,
        labelMargin: 6,
        unit: unit = 32,
        thumbSize: unit - 4,
        colUnits: colUnits = 5,
        colInnerWidth: colInnerWidth = unit * colUnits
      },
      Settings: {
        unit: 32,
        itemWidth: 300,
        itemMargin: 8,
        panelPad: 8,
        panelBorderRadius: 24
      }
    });
  });

  Take(["FPS", "HUD", "Mode", "Tick", "SVGReady"], function(FPS, HUD, Mode, Tick) {
    if (!Mode.dev) {
      return;
    }
    return Tick(function() {
      var color, fps, fpsDisplay;
      fps = FPS();
      fpsDisplay = fps < 30 ? fps.toFixed(1) : Math.ceil(fps);
      color = fps <= 10 ? "#C00" : fps <= 20 ? "#E608" : "#0003";
      return HUD("FPS", fpsDisplay, color);
    });
  });

  Take(["Mode", "ParentElement", "Tick", "SVGReady"], function(Mode, ParentElement, Tick) {
    var HUD, colors, elapsed, elm, needsUpdate, prev, rate, ref, values;
    if (!Mode.dev) {
      return;
    }
    rate = .1;
    elapsed = rate;
    needsUpdate = true;
    colors = {};
    values = {};
    elm = document.createElement("div");
    elm.setAttribute("svga-hud", "true");
    if (!Mode.embed) {
      document.body.insertBefore(elm, document.body.firstChild);
    } else {
      prev = ParentElement.previousSibling;
      if (prev != null ? typeof prev.hasAttribute === "function" ? prev.hasAttribute("svga-hud") : void 0 : void 0) {
        elm = prev;
      } else {
        if ((ref = ParentElement.parentNode) != null) {
          ref.insertBefore(elm, ParentElement);
        }
      }
    }
    Tick(function(time, dt) {
      var html, k, v;
      elapsed += dt;
      if (elapsed >= rate) {
        elapsed -= rate;
        if (needsUpdate) {
          needsUpdate = false;
          html = "";
          for (k in values) {
            v = values[k];
            html += "<div style='color:" + colors[k] + "'>" + k + ": " + v + "</div>";
          }
          return elm.innerHTML = html;
        }
      }
    });
    return Make("HUD", HUD = function(k, v, c) {
      var _k, _v;
      if (c == null) {
        c = "#0008";
      }
      if (typeof k === "object") {
        for (_k in k) {
          _v = k[_k];
          HUD(_k, _v, v);
        }
      } else {
        if (values[k] !== v || (values[k] == null)) {
          values[k] = v;
          colors[k] = c;
          needsUpdate = true;
        }
      }
      return void 0;
    });
  });

  Take(["HUD", "Mode", "ParentElement", "SVGReady"], function(HUD, Mode, ParentElement) {
    var nodeCountElm;
    if (!Mode.dev) {
      return;
    }
    nodeCountElm = document.querySelector("[node-count]");
    if (nodeCountElm != null) {
      return HUD("Nodes", nodeCountElm.getAttribute("node-count"), "#0003");
    }
  });

  Take(["Reaction", "SVG", "SceneReady"], function(Reaction, SVG) {
    Reaction("Root:Show", function() {
      return SVG.root._scope.show(.7);
    });
    return Reaction("Root:Hide", function() {
      return SVG.root._scope.hide(.3);
    });
  });

  Take(["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], function(Registry, arg, Input, SVG, TRS, Tween) {
    var GUI;
    GUI = arg.Settings;
    return Registry.set("SettingType", "slider", function(elm, props) {
      var bgc, blueBG, handleDrag, label, labelPad, labelWidth, lightBG, lightDot, normalDot, orangeBG, range, snap, snapElms, snapTolerance, startDrag, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toMissed, toNormal, track, trackWidth, update, v;
      snapElms = [];
      v = 0;
      startDrag = 0;
      strokeWidth = 2;
      snapTolerance = 0.05;
      labelPad = 10;
      labelWidth = GUI.itemWidth / 2;
      trackWidth = GUI.itemWidth - labelWidth;
      thumbSize = GUI.unit;
      range = trackWidth - thumbSize;
      lightDot = "hsl(92, 46%, 57%)";
      normalDot = "hsl(220, 10%, 92%)";
      SVG.attrs(elm, {
        ui: true
      });
      track = SVG.create("rect", elm, {
        x: strokeWidth / 2 + labelWidth,
        y: strokeWidth / 2,
        width: trackWidth - strokeWidth,
        height: thumbSize - strokeWidth,
        strokeWidth: strokeWidth,
        fill: "hsl(227, 45%, 24%)",
        stroke: "hsl(227, 45%, 24%)",
        rx: thumbSize / 2
      });
      thumb = TRS(SVG.create("circle", elm, {
        cx: thumbSize / 2 + labelWidth,
        cy: thumbSize / 2,
        strokeWidth: strokeWidth,
        fill: "hsl(220, 10%, 92%)",
        r: thumbSize / 2 - strokeWidth / 2
      }));
      if (props.snaps != null) {
        snapElms = (function() {
          var len, m, ref, results;
          ref = props.snaps;
          results = [];
          for (m = 0, len = ref.length; m < len; m++) {
            snap = ref[m];
            results.push(SVG.create("circle", elm, {
              cx: thumbSize / 2 + labelWidth + (trackWidth - thumbSize) * snap,
              cy: thumbSize / 2,
              fill: "transparent",
              strokeWidth: 4
            }));
          }
          return results;
        })();
      }
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: labelWidth - labelPad,
        y: 21,
        textAnchor: "end",
        fill: "hsl(220, 10%, 92%)"
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
        return SVG.attrs(thumb, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      update = function(V) {
        var i, len, m, ref;
        if (V != null) {
          v = Math.max(0, Math.min(1, V));
        }
        if (props.snaps != null) {
          ref = props.snaps;
          for (i = m = 0, len = ref.length; m < len; i = ++m) {
            snap = ref[i];
            if (v > snap - snapTolerance && v < snap + snapTolerance) {
              v = snap;
              SVG.attrs(snapElms[i], {
                r: 3,
                stroke: lightDot
              });
            } else {
              SVG.attrs(snapElms[i], {
                r: 2,
                stroke: normalDot
              });
            }
          }
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
        if (state.clicking) {
          update(e.clientX / range - startDrag);
          props.update(v);
          return void 0;
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
      return update(props.value || 0);
    });
  });

  Take(["Registry", "GUI", "Input", "SVG", "TRS", "Tween"], function(Registry, arg, Input, SVG, TRS, Tween) {
    var GUI;
    GUI = arg.Settings;
    return Registry.set("SettingType", "switch", function(elm, props) {
      var active, bgc, blocked, blueBG, label, labelPad, labelWidth, lightBG, lightTrack, normalTrack, orangeBG, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toNormal, toggle, track;
      strokeWidth = 2;
      labelPad = 10;
      labelWidth = GUI.itemWidth / 2;
      thumbSize = GUI.unit;
      active = false;
      normalTrack = "hsl(227, 45%, 24%)";
      lightTrack = "hsl(92, 46%, 57%)";
      SVG.attrs(elm, {
        ui: true
      });
      track = SVG.create("rect", elm, {
        x: strokeWidth / 2 + labelWidth,
        y: strokeWidth / 2,
        width: thumbSize * 2 - strokeWidth,
        height: thumbSize - strokeWidth,
        strokeWidth: strokeWidth,
        fill: normalTrack,
        stroke: normalTrack,
        rx: thumbSize / 2
      });
      thumb = TRS(SVG.create("circle", elm, {
        cx: thumbSize / 2 + labelWidth,
        cy: thumbSize / 2,
        strokeWidth: strokeWidth,
        fill: "hsl(220, 10%, 92%)",
        r: thumbSize / 2 - strokeWidth / 2
      }));
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: labelWidth - labelPad,
        y: 21,
        textAnchor: "end",
        fill: "hsl(220, 10%, 92%)"
      });
      toggle = function() {
        active = !active;
        TRS.abs(thumb, {
          x: active ? thumbSize : 0
        });
        SVG.attrs(track, {
          fill: active ? lightTrack : normalTrack
        });
        return props.update(active);
      };
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
        return SVG.attrs(thumb, {
          stroke: "rgb(" + (bgc.r | 0) + "," + (bgc.g | 0) + "," + (bgc.b | 0) + ")"
        });
      };
      tickBG(blueBG);
      blocked = false;
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
          if (blocked) {
            return;
          }
          blocked = true;
          setTimeout((function() {
            return blocked = false;
          }), 100);
          toClicked();
          toggle();
          return void 0;
        }
      });
      if (props.value) {
        return toggle();
      }
    });
  });

  Take(["GUI", "Reaction", "Registry", "Resize", "Scope", "SVG", "ControlReady"], function(GUI, Reaction, Registry, Resize, Scope, SVG) {
    var Settings, bg, elm, height, items, panelWidth;
    height = 0;
    panelWidth = GUI.Settings.itemWidth + GUI.Settings.panelPad * 2;
    elm = SVG.create("g", GUI.elm);
    bg = SVG.create("rect", elm, {
      width: panelWidth,
      rx: GUI.Settings.panelBorderRadius,
      fill: "hsl(220, 45%, 45%)"
    });
    items = SVG.create("g", elm, {
      transform: "translate(" + GUI.Settings.panelPad + "," + GUI.Settings.panelPad + ")"
    });
    Settings = Scope(elm, function() {
      return {
        addSetting: function(type, props) {
          var builder, instance;
          instance = Scope(SVG.create("g", items));
          builder = Registry.get("SettingType", type);
          builder(instance.element, props);
          instance.y = height;
          height += GUI.Settings.unit + GUI.Settings.itemMargin;
          return SVG.attrs(bg, {
            height: height + GUI.Settings.panelPad * 2 - GUI.Settings.itemMargin
          });
        }
      };
    });
    Settings.hide(0);
    Make("Settings", Settings);
    Resize(function() {
      var svgRect;
      svgRect = SVG.svg.getBoundingClientRect();
      Settings.x = svgRect.width / 2 - panelWidth / 2;
      return Settings.y = 60;
    });
    Reaction("Settings:Show", function() {
      return Settings.show(.7);
    });
    return Reaction("Settings:Hide", function() {
      return Settings.hide(.3);
    });
  });

  Take(["Action", "GUI", "Input", "Reaction", "Scope", "SVG", "ScopeReady"], function(Action, GUI, Input, Reaction, Scope, SVG) {
    var bg, elm, label, scope;
    elm = SVG.create("g", GUI.elm, {
      ui: true
    });
    scope = Scope(elm);
    bg = SVG.create("rect", elm, {
      x: GUI.ControlPanel.panelMargin,
      y: GUI.ControlPanel.panelMargin,
      width: 72,
      height: 30,
      rx: 4,
      fill: "hsl(220, 45%, 45%)"
    });
    label = SVG.create("text", elm, {
      textContent: "Settings",
      x: 36 + GUI.ControlPanel.panelMargin,
      y: 25,
      fontSize: 16,
      textAnchor: "middle",
      fill: "hsl(220, 10%, 92%)"
    });
    Input(elm, {
      click: function() {
        return Action("Settings:Toggle");
      }
    });
    Reaction("Settings:Hide", function() {
      return SVG.attrs(label, {
        textContent: "Settings"
      });
    });
    return Reaction("Settings:Show", function() {
      return SVG.attrs(label, {
        textContent: "Back"
      });
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
    Tick(function(time, dt) {
      var down, inputX, inputY, inputZ, left, minus, plus, right, scaledDt, up;
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
      scaledDt = (dt * 1000) / 16;
      return Nav.by({
        x: scaledDt * Math.cos(vel.a) * vel.d,
        y: scaledDt * Math.sin(vel.a) * vel.d,
        z: scaledDt * vel.z
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

  Take(["ControlPanel", "Mode", "ParentElement", "RAF", "Resize", "SVG", "Tween", "SceneReady"], function(ControlPanel, Mode, ParentElement, RAF, Resize, SVG, Tween) {
    var Nav, applyLimit, center, centerInverse, checkHorizontalIsBetter, computeResizeInfo, contentHeight, contentWidth, dist, distTo, initialRootRect, limit, parentRect, pos, render, requestRender, resize, scaleStartPosZ, totalSpace, tween, windowScale;
    contentWidth = +SVG.attr(SVG.svg, "width");
    contentHeight = +SVG.attr(SVG.svg, "height");
    if (!((contentWidth != null) && (contentHeight != null))) {
      throw new Error("This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash.");
    }
    if (Mode.embed) {
      parentRect = ParentElement.getBoundingClientRect();
      ParentElement.style.height = Math.round(contentHeight * parentRect.width / contentWidth) + "px";
    }
    initialRootRect = SVG.root.getBoundingClientRect();
    if (!(initialRootRect.width > 0 && initialRootRect.height > 0)) {
      return;
    }
    pos = {
      x: 0,
      y: 0,
      z: 0
    };
    center = {
      x: 0,
      y: 0
    };
    centerInverse = {
      x: 0,
      y: 0
    };
    limit = {
      x: {
        min: -contentWidth / 2,
        max: contentWidth / 2
      },
      y: {
        min: -contentHeight / 2,
        max: contentHeight / 2
      },
      z: {
        min: -0.5,
        max: 3
      }
    };
    windowScale = 1;
    scaleStartPosZ = 0;
    tween = null;
    totalSpace = null;
    render = function() {
      return SVG.attr(SVG.root, "transform", "translate(" + center.x + "," + center.y + ") scale(" + (windowScale * Math.pow(2, pos.z)) + ") translate(" + (pos.x - centerInverse.x) + "," + (pos.y - centerInverse.y) + ")");
    };
    computeResizeInfo = function(panelInfo) {
      var availableSpaceH, availableSpaceW, availableSpaceX, availableSpaceY, hFrac, panelClaimedH, panelClaimedW, resizeInfo, wFrac;
      panelClaimedW = Math.abs(panelInfo.signedX) >= 0.9 ? panelInfo.w : 0;
      panelClaimedH = Math.abs(panelInfo.signedY) >= 0.9 ? panelInfo.h : 0;
      if (panelClaimedW > 0 && panelClaimedH > 0) {
        if (panelClaimedW < panelClaimedH) {
          panelClaimedH = 0;
        } else {
          panelClaimedW = 0;
        }
      }
      availableSpaceW = totalSpace.width - panelClaimedW;
      availableSpaceH = totalSpace.height - panelClaimedH;
      availableSpaceX = panelInfo.signedX < 0 ? panelInfo.w : 0;
      availableSpaceY = panelInfo.signedY < 0 ? panelInfo.h : 0;
      wFrac = availableSpaceW / contentWidth;
      hFrac = availableSpaceH / contentHeight;
      windowScale = Math.min(wFrac, hFrac);
      return resizeInfo = {
        panelClaimedW: panelClaimedW,
        panelClaimedH: panelClaimedH,
        windowScale: windowScale,
        availableSpaceW: availableSpaceW,
        availableSpaceH: availableSpaceH,
        availableSpaceX: availableSpaceX,
        availableSpaceY: availableSpaceY
      };
    };
    checkHorizontalIsBetter = function(horizontalPanelInfo, verticalPanelInfo) {
      var horizontalResizeInfo, verticalResizeInfo;
      horizontalResizeInfo = computeResizeInfo(horizontalPanelInfo);
      verticalResizeInfo = computeResizeInfo(verticalPanelInfo);
      if (Mode.embed) {
        return verticalResizeInfo.windowScale < 1 && horizontalResizeInfo.windowScale > verticalResizeInfo.windowScale;
      } else {
        return horizontalResizeInfo.windowScale > verticalResizeInfo.windowScale;
      }
    };
    resize = function() {
      var aspectAdjustedHeight, computedHeight, panelInfo, resizeInfo;
      totalSpace = SVG.svg.getBoundingClientRect();
      panelInfo = ControlPanel.getPanelLayoutInfo(checkHorizontalIsBetter);
      resizeInfo = computeResizeInfo(panelInfo);
      if (Mode.embed) {
        parentRect = ParentElement.getBoundingClientRect();
        aspectAdjustedHeight = resizeInfo.panelClaimedH + contentHeight * (parentRect.width - resizeInfo.panelClaimedW) / contentWidth;
        computedHeight = Math.max(aspectAdjustedHeight, panelInfo.h);
        ParentElement.style.height = Math.round(computedHeight) + "px";
      }
      windowScale = resizeInfo.windowScale;
      center.x = resizeInfo.availableSpaceX + resizeInfo.availableSpaceW / 2;
      center.y = resizeInfo.availableSpaceY + resizeInfo.availableSpaceH / 2;
      centerInverse.x = contentWidth / 2;
      centerInverse.y = contentHeight / 2;
      render();
      return Resize._fire({
        window: totalSpace,
        panel: {
          scale: panelInfo.controlPanelScale,
          vertical: panelInfo.vertical,
          x: panelInfo.controlPanelX,
          y: panelInfo.controlPanelY,
          width: panelInfo.w,
          height: panelInfo.h
        },
        content: {
          width: contentWidth,
          height: contentHeight
        }
      });
    };
    window.addEventListener("resize", function() {
      return RAF(resize, true);
    });
    Take("AllReady", function() {
      return RAF(resize, true);
    });
    if (!Mode.nav) {
      Make("Nav", false);
      return;
    }
    requestRender = function() {
      return RAF(render, true);
    };
    applyLimit = function(l, v) {
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
          pos.z = applyLimit(limit.z, pos.z + p.z);
        }
        scale = windowScale * Math.pow(2, pos.z);
        if (p.x != null) {
          pos.x = applyLimit(limit.x, pos.x + p.x / scale);
        }
        if (p.y != null) {
          pos.y = applyLimit(limit.y, pos.y + p.y / scale);
        }
        return requestRender();
      },
      at: function(p) {
        var scale;
        if (tween != null) {
          Tween.cancel(tween);
        }
        if (p.z != null) {
          pos.z = applyLimit(limit.z, p.z);
        }
        scale = windowScale * Math.pow(2, pos.z);
        if (p.x != null) {
          pos.x = applyLimit(limit.x, p.x / scale);
        }
        if (p.y != null) {
          pos.y = applyLimit(limit.y, p.y / scale);
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
        pos.z = applyLimit(limit.z, Math.log2(Math.pow(2, scaleStartPosZ) * s));
        return requestRender();
      },
      eventInside: function(e) {
        var ref;
        if (((ref = e.touches) != null ? ref.length : void 0) > 0) {
          e = e.touches[0];
        }
        return e.target === document.body || e.target === SVG.svg || SVG.root.contains(e.target);
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

  (function() {
    var Resize, cbs;
    cbs = [];
    Resize = function(cb) {
      return cbs.push(cb);
    };
    Resize._fire = function(info) {
      var cb, len, m;
      for (m = 0, len = cbs.length; m < len; m++) {
        cb = cbs[m];
        cb(info);
      }
      return void 0;
    };
    return Make("Resize", Resize);
  })();

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
      lastTouches = (function() {
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
      return void 0;
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
    return Reaction("Settings:Toggle", function() {
      return Action(showing ? "Settings:Hide" : "Settings:Show");
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
        var len, m, path;
        for (m = 0, len = paths.length; m < len; m++) {
          path = paths[m];
          SVG.attrs(path, {
            "stroke-dasharray": v
          });
        }
        return void 0;
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
              } else {
                "Warning: @debug.point() is disabled unless you're in dev";
                return {};
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
      var childPathFills, childPathStrokes, fill, stroke;
      ScopeCheck(scope, "stroke", "fill");
      childPathStrokes = childPathFills = scope.element.querySelectorAll("path");
      stroke = null;
      Object.defineProperty(scope, 'stroke', {
        get: function() {
          return stroke;
        },
        set: function(val) {
          var childPathStroke, len, m;
          if (stroke !== val) {
            SVG.attr(scope.element, "stroke", stroke = val);
            if (childPathStrokes.length > 0) {
              for (m = 0, len = childPathStrokes.length; m < len; m++) {
                childPathStroke = childPathStrokes[m];
                SVG.attr(childPathStroke, "stroke", null);
              }
              return childPathStrokes = [];
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
          var childPathFill, len, m;
          if (fill !== val) {
            SVG.attr(scope.element, "fill", fill = val);
            if (childPathFills.length > 0) {
              for (m = 0, len = childPathFills.length; m < len; m++) {
                childPathFill = childPathFills[m];
                SVG.attr(childPathFill, "fill", null);
              }
              return childPathFills = [];
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

  Take(["Action", "Settings"], function(Action, Settings) {
    return Settings.addSetting("slider", {
      name: "Background",
      value: .7,
      snaps: [.7],
      update: function(v) {
        return Action("Background:Lightness", v);
      }
    });
  });

  Take(["Action", "Settings"], function(Action, Settings) {
    return Settings.addSetting("switch", {
      name: "Highlights",
      value: true,
      update: function(active) {
        return Action("Highlights:Set", active);
      }
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
        var child, len, m, ref;
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
          for (m = 0, len = ref.length; m < len; m++) {
            child = ref[m];
            strip(child);
          }
        }
        return void 0;
      };
      strip(element);
      element.setAttribute("fill", "transparent");
      apply = function(stroke, fill) {
        var elm, len, len1, m, n;
        if (fill == null) {
          fill = stroke;
        }
        for (m = 0, len = strokeElms.length; m < len; m++) {
          elm = strokeElms[m];
          SVG.attr(elm, "stroke", stroke);
        }
        for (n = 0, len1 = fillElms.length; n < len1; n++) {
          elm = fillElms[n];
          SVG.attr(elm, "fill", fill);
        }
        return void 0;
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
    Mode = {
      get: fetchAttribute,
      background: fetchAttribute("background"),
      controlPanel: fetchAttribute("controlPanel"),
      dev: ((ref = window.top.location.port) != null ? ref.length : void 0) >= 4,
      nav: fetchAttribute("nav"),
      embed: window !== window.top
    };
    if (Mode.embed) {
      Mode.nav = false;
    }
    return Make("Mode", Mode);
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
      if (cb != null) {
        return (cbs[name] != null ? cbs[name] : cbs[name] = []).push(cb);
      } else {
        throw "Null reference passed to Reaction() with name: " + name;
      }
    });
    return Make("Action", function() {
      var args, cb, len, m, name, ref;
      name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (cbs[name] != null) {
        ref = cbs[name];
        for (m = 0, len = ref.length; m < len; m++) {
          cb = ref[m];
          cb.apply(null, args);
        }
      }
      return void 0;
    });
  })();

  Take(["ControlPanel", "ControlPanelLayout", "GUI", "Registry", "Scope", "SVG", "ControlReady"], function(ControlPanel, ControlPanelLayout, arg, Registry, Scope, SVG) {
    var Control, GUI, addItemToGroup, currentGroup, defn, getGroup, instances, ref, setup, type;
    GUI = arg.ControlPanel;
    Control = {};
    instances = {};
    currentGroup = null;
    getGroup = function(color) {
      var bg, elm;
      if ((currentGroup == null) || (color == null) || color !== currentGroup.color) {
        elm = SVG.create("g", null);
        bg = SVG.create("rect", elm, {
          width: GUI.colInnerWidth + GUI.groupPad * 2,
          rx: GUI.groupBorderRadius,
          fill: color || "transparent"
        });
        ControlPanel.registerGroup(currentGroup = {
          scope: Scope(elm),
          bg: bg,
          color: color,
          itemScopes: [],
          height: GUI.groupPad * 2
        });
      }
      return currentGroup;
    };
    addItemToGroup = function(group, scope) {
      if (group.itemScopes.length > 0) {
        group.height += GUI.itemMargin;
      }
      scope.x = GUI.groupPad;
      scope.y = group.height - GUI.groupPad;
      group.height += scope.height;
      SVG.attrs(group.bg, {
        height: group.height
      });
      return group.itemScopes.push(scope);
    };
    setup = function(type, defn) {
      return Control[type] = function(props) {
        var base1, elm, group, scope;
        if (props == null) {
          props = {};
        }
        if (typeof props !== "object") {
          console.log(props);
          throw new Error("Control." + type + "(props) takes a optional props object. Got ^^^, which is not an object.");
        }
        if ((props.id != null) && (instances[props.id] != null)) {
          if (typeof (base1 = instances[props.id]).attach === "function") {
            base1.attach(props);
          }
          return instances[props.id];
        } else {
          group = getGroup(props.group);
          elm = ControlPanel.createItemElement(props.parent || group.scope.element);
          scope = Scope(elm, defn, props);
          addItemToGroup(group, scope);
          if (typeof scope.attach === "function") {
            scope.attach(props);
          }
          scope._dontHighlightOnHover = true;
          if (props.id != null) {
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

  Take(["Tick", "SVGReady"], function(Tick) {
    var avgList, avgWindow, fps, total;
    avgWindow = 1;
    avgList = [];
    total = 0;
    fps = 1;
    Make("FPS", function() {
      return fps;
    });
    return Tick(function(time, dt) {
      avgList.push(dt);
      total += dt;
      while (total > avgWindow && avgList.length > 0) {
        total -= avgList.shift();
      }
      fps = avgList.length / total;
      fps = Math.min(60, fps);
      if (isNaN(fps)) {
        return fps = 2;
      }
    });
  });

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

  Take(["Ease", "FPS", "Gradient", "Input", "RAF", "Reaction", "SVG", "Tick", "SVGReady"], function(Ease, FPS, Gradient, Input, RAF, Reaction, SVG, Tick) {
    var activeHighlight, counter, dgradient, enabled, lgradient, mgradient, tgradient;
    enabled = true;
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
    Make("Highlight", function() {
      var activate, active, deactivate, highlights, setup, targets, timeout;
      targets = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      highlights = [];
      active = false;
      timeout = null;
      setup = function(elm) {
        var doFill, doFunction, doStroke, e, fill, len, m, ref, ref1, ref2, ref3, stroke, width;
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
          e.dontHighlightOnHover = ((ref1 = elm._scope) != null ? ref1._dontHighlightOnHover : void 0) != null;
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
          e.dontHighlightOnHover = ((ref2 = elm._scope) != null ? ref2._dontHighlightOnHover : void 0) != null;
        }
        if (!doFunction) {
          ref3 = elm.childNodes;
          for (m = 0, len = ref3.length; m < len; m++) {
            elm = ref3[m];
            if (elm.tagName === "g" || elm.tagName === "path" || elm.tagName === "text" || elm.tagName === "tspan" || elm.tagName === "rect" || elm.tagName === "circle") {
              setup(elm);
            }
          }
        }
        return void 0;
      };
      activate = function(currentTarget) {
        return function() {
          var h, len, m;
          if (active || !enabled) {
            return;
          }
          active = true;
          if (typeof activeHighlight === "function") {
            activeHighlight();
          }
          activeHighlight = deactivate;
          timeout = setTimeout(deactivate, 4000);
          for (m = 0, len = highlights.length; m < len; m++) {
            h = highlights[m];
            if (h.dontHighlightOnHover && currentTarget.element === h.elm) {

            } else if (h["function"] != null) {
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
          return void 0;
        };
      };
      deactivate = function() {
        var h, len, m;
        if (active) {
          active = false;
          clearTimeout(timeout);
          activeHighlight = null;
          for (m = 0, len = highlights.length; m < len; m++) {
            h = highlights[m];
            if (h["function"] != null) {
              h["function"](false);
            } else {
              SVG.attrs(h.elm, h.attrs);
            }
          }
        }
        return void 0;
      };
      return RAF(function() {
        var len, len1, m, mouseProps, n, t, target, touchProps;
        for (m = 0, len = targets.length; m < len; m++) {
          target = targets[m];
          if (target == null) {
            console.log(targets.map(function(e) {
              return e != null ? e.element : void 0;
            }));
            throw new Error("Highlight called with a null element ^^^");
          }
          t = target.element || target;
          if (!t._HighlighterSetup) {
            t._HighlighterSetup = true;
            setup(t);
          }
        }
        for (n = 0, len1 = targets.length; n < len1; n++) {
          target = targets[n];
          t = target.element || target;
          if (!t._Highlighter) {
            t._Highlighter = true;
            mouseProps = {
              moveIn: activate(target),
              moveOut: deactivate
            };
            touchProps = {
              down: activate(target)
            };
            Input(t, mouseProps, true, false);
            Input(t, touchProps, false, true);
          }
        }
        return void 0;
      });
    });
    return Reaction("Highlights:Set", function(v) {
      return enabled = v;
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
      var command, len, m;
      if (callbacks != null) {
        for (m = 0, len = callbacks.length; m < len; m++) {
          command = callbacks[m];
          if (command.modifier === modifier) {
            command.callback();
          }
        }
      }
      return void 0;
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
      var callbacks, cb, len, len1, m, n, priority;
      requested = false;
      for (priority = m = 0, len = callbacksByPriority.length; m < len; priority = ++m) {
        callbacks = callbacksByPriority[priority];
        if (!(callbacks != null)) {
          continue;
        }
        callbacksByPriority[priority] = [];
        for (n = 0, len1 = callbacks.length; n < len1; n++) {
          cb = callbacks[n];
          cb(time);
        }
      }
      return void 0;
    };
    return Make("RAF", function(cb, ignoreDuplicates, priority) {
      var c, len, m, ref;
      if (ignoreDuplicates == null) {
        ignoreDuplicates = false;
      }
      if (priority == null) {
        priority = 0;
      }
      if (cb == null) {
        throw new Error("RAF(null)");
      }
      ref = callbacksByPriority[priority];
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
      (callbacksByPriority[priority] != null ? callbacksByPriority[priority] : callbacksByPriority[priority] = []).push(cb);
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
        if (!closed[type]) {
          throw new Error("Registry.all(" + type + ", " + byName + ") was called before registration closed.");
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
        if (!closed[type]) {
          throw new Error("Registry.get(" + type + ", " + name + ") was called before registration closed.");
        }
        return named[type][name];
      },
      closeRegistration: function(type) {
        return closed[type] = true;
      }
    });
  })();

  Make("ScopeCheck", function() {
    var len, m, prop, props, scope;
    scope = arguments[0], props = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    for (m = 0, len = props.length; m < len; m++) {
      prop = props[m];
      if (!(scope[prop] != null)) {
        continue;
      }
      console.log(scope.element);
      throw new Error("^ @" + prop + " is a reserved name. Please choose a different name for your child/property \"" + prop + "\".");
    }
    return void 0;
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
      var instanceName, len, m;
      symbol.symbolName = symbolName;
      Registry.set("Symbols", symbolName, symbol);
      for (m = 0, len = instanceNames.length; m < len; m++) {
        instanceName = instanceNames[m];
        Registry.set("SymbolNames", instanceName, symbol);
      }
      return void 0;
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
