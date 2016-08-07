(function() {
  var base,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  Take(["Registry", "SVGPreprocessor", "DOMContentLoaded"], function(Registry, SVGPreprocessor) {
    var svgData;
    svgData = SVGPreprocessor.crawl(document.getElementById("root"));
    Make("SVGReady");
    return setTimeout(function() {
      Registry.closeRegistration();
      SVGPreprocessor.build(svgData);
      svgData = null;
      Make("ScopeReady");
      return Make("AllReady");
    });
  });

  Take(["Dev", "Registry", "ScopeCheck", "Symbol"], function(Dev, Registry, ScopeCheck, Symbol) {
    var Scope, findParent;
    Make("Scope", Scope = function(element, symbol, props) {
      var attr, attrs, len, len1, m, n, name1, parentScope, ref, scope, scopeProcessor;
      if (props == null) {
        props = {};
      }
      if (!element instanceof SVGElement) {
        console.log(element);
        throw "Scope() takes an element as the first argument. Got ^^^";
      }
      if ((symbol != null) && typeof symbol !== "function") {
        console.log(symbol);
        throw "Scope() takes a function as the second arg. Got ^^^";
      }
      if (typeof props !== "object") {
        console.log(props);
        throw "Scope() takes an optional object as the third arg. Got ^^^";
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
          console.log(parentScope);
          throw "^ Has a child or property with the id \"" + scope.id + "\". This is conflicting with a child scope that wants to use that instance name.";
        }
        if (parentScope[name1 = scope.id] == null) {
          parentScope[name1] = scope;
        }
        parentScope.children.push(scope);
      }
      if (Dev) {
        element.setAttribute("x-scope", scope.id || "");
        attrs = Array.prototype.slice.call(element.attributes);
        for (m = 0, len = attrs.length; m < len; m++) {
          attr = attrs[m];
          if (!(attr.name !== "x-scope")) {
            continue;
          }
          element.removeAttributeNS(attr.namespaceURI, attr.name);
          element.setAttributeNS(attr.namespaceURI, attr.name, attr.value);
        }
      }
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

  Take(["Scope", "SVG", "Symbol"], function(Scope, SVG, Symbol) {
    var SVGPreprocessor, buildScopes, defs, deprecations, processElm;
    deprecations = ["controlPanel", "ctrlPanel", "navOverlay"];
    defs = {};
    Make("SVGPreprocessor", SVGPreprocessor = {
      crawl: function(elm) {
        var tree;
        tree = processElm(elm);
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
        if ((ref = childElm.id, indexOf.call(deprecations, ref) >= 0) || ((ref1 = childElm.id) != null ? ref1.indexOf("Mask") : void 0) > -1) {
          console.log("#" + childElm.id + " is obsolete. Please remove it from your FLA and re-export this SVG.");
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
      if (tree.elm.id.replace("_FL", "").length > 0) {
        props.id = tree.elm.id.replace("_FL", "");
      }
      baseName = (ref = tree.elm.id) != null ? ref.split("_")[0] : void 0;
      symbol = baseName.indexOf("Line") > -1 ? Symbol.forSymbolName("HydraulicLine") : baseName.indexOf("Field") > -1 ? Symbol.forSymbolName("HydraulicField") : Symbol.forInstanceName(tree.elm.id);
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
          if (Config.SPACING < 60 * parentScale) {
            throw "Your flow arrows are overlapping. What the devil are you trying? You need to convince Ivan that what you are doing is okay.";
          }
          if (parentScale < 0.1) {
            throw "Your arrows are so small that they might not be visible. If this is necessary, then you are doing something suspicious and need to convince Ivan that what you are doing is okay.";
          }
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
      SCALE: 1,
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
      var active, children, direction, enabled, flow, pressure, scale, scope, updateActive, visible;
      direction = 1;
      flow = 1;
      pressure = null;
      scale = 1;
      active = true;
      enabled = true;
      visible = true;
      scope = {
        element: SVG.create("g", parentElm),
        reverse: function() {
          return direction *= -1;
        },
        update: function(parentFlow, parentScale) {
          var child, f, len, m, results, s;
          if (active) {
            f = flow * direction * parentFlow;
            s = scale * parentScale;
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
          display: active ? null : "none"
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
      Object.defineProperty(scope, 'pressure', {
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
        throw "FlowArrows was called with a null target. ^^^ was the baked line data.";
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

  Take(["FlowArrows:Arrow", "FlowArrows:Config", "FlowArrows:Containerize"], function(Arrow, Config, Containerize) {
    return Make("FlowArrows:Segment", function(parentElm, segmentData) {
      return Containerize(parentElm, function(scope) {
        var arrow, arrowCount, i, m, ref, results, segmentPosition, segmentSpacing, vector, vectorIndex, vectorPosition;
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

  Take(["Dev", "FlowArrows:Config", "FlowArrows:Containerize", "FlowArrows:Segment"], function(Dev, Config, Containerize, Segment) {
    return Make("FlowArrows:Set", function(parentElm, setData) {
      return Containerize(parentElm, function(scope) {
        var child, childName, i, len, m, results, segmentData;
        results = [];
        for (i = m = 0, len = setData.length; m < len; i = ++m) {
          segmentData = setData[i];
          if (segmentData.dist < Config.FADE_LENGTH * 2) {
            throw "You have a FlowArrows segment that is only " + (Math.round(segmentData.dist)) + " units long, which is clashing with your fade length of " + Config.FADE_LENGTH + " units. Please don't set MIN_SEGMENT_LENGTH less than FADE_LENGTH * 2.";
          }
          childName = "segment" + i;
          child = Segment(scope.element, segmentData);
          if (Dev) {
            child.element.addEventListener("click", function() {
              return console.log(parentElm._scope.instanceName + "." + childName);
            });
          }
          results.push(scope[childName] = child);
        }
        return results;
      });
    });
  });

  Take(["GUI", "Resize", "SVG", "TopBar", "TRS", "SVGReady"], function(GUI, Resize, SVG, TopBar, TRS) {
    var g, hide, show;
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
        x: window.innerWidth / 2,
        y: GUI.TopBar.height
      });
    });
    window.addEventListener("focus", hide);
    window.addEventListener("touchstart", hide);
    window.addEventListener("blur", show);
    window.addEventListener("mousedown", function() {
      if (document.activeElement === SVG.root) {
        return window.focus();
      }
    });
    window.focus();
    return hide();
  });

  Take(["ControlPanel", "ControlPanelLayout", "Scope"], function(ControlPanel, ControlPanelLayout, Scope) {
    var Control, instances;
    instances = {};
    return Make("Control", Control = function(type, defn) {
      return Control[type] = function(props) {
        var base, elm, scope;
        if (props == null) {
          props = {};
        }
        if (typeof props !== "object") {
          console.log(props);
          throw "Control." + type + "(props) takes a optional props object. Got ^^^, which is not an object.";
        }
        if (((props != null ? props.id : void 0) != null) && (instances[props.id] != null)) {
          return typeof (base = instances[props.id]).attach === "function" ? base.attach(props) : void 0;
        } else {
          elm = ControlPanel.createElement(props != null ? props.parent : void 0);
          scope = Scope(elm, defn, props);
          if (typeof scope.attach === "function") {
            scope.attach(props);
          }
          ControlPanelLayout.addScope(scope);
          if ((props != null ? props.id : void 0) != null) {
            return instances[props.id] = scope;
          }
        }
      };
    });
  });

  (function() {
    window.addEventListener("touchmove", function(e) {
      return e.preventDefault();
    });
    window.addEventListener("scroll", function(e) {
      return e.preventDefault();
    });
    return window.addEventListener("dragstart", function(e) {
      return e.preventDefault();
    });
  })();

  Take(["Dev", "GUI", "Resize", "SVG", "Tick", "SVGReady"], function(Dev, GUI, Resize, SVG, Tick) {
    var avgLength, avgList, count, freq, text, total;
    if (!Dev) {
      return;
    }
    count = 60;
    freq = 1;
    avgLength = 10;
    avgList = [];
    total = 0;
    text = SVG.create("text", GUI.elm, {
      fill: "#666"
    });
    Resize(function() {
      return SVG.attrs(text, {
        x: 10,
        y: 70
      });
    });
    return Tick(function(time, dt) {
      var fps;
      avgList.push(1 / dt);
      total += 1 / dt;
      if (avgList.length > avgLength) {
        total -= avgList.shift();
      }
      fps = Math.min(60, Math.ceil(total / avgList.length));
      if (++count / fps >= freq) {
        count = 0;
        return SVG.attrs(text, {
          textContent: "FPS: " + fps
        });
      }
    });
  });

  Take(["ControlPanel", "Nav", "RAF", "Resize", "TopBar"], function(ControlPanel, Nav, RAF, Resize, TopBar) {
    return Resize(function() {
      var rect;
      rect = {
        x: 0,
        y: 0,
        w: window.innerWidth,
        h: window.innerHeight
      };
      TopBar.claimSpace(rect);
      ControlPanel.claimSpace(rect);
      return Nav.assignSpace(rect);
    });
  });

  Take(["SVG", "SVGReady"], function(SVG) {
    var GUI;
    return Make("GUI", GUI = {
      elm: SVG.create("g", SVG.root, {
        xGui: ""
      }),
      TopBar: {
        buttonPadCustom: 16,
        buttonPadStandard: 24,
        height: 48,
        iconPad: 6,
        Help: {
          inset: 88
        },
        Menu: {
          inset: -4
        },
        Settings: {
          inset: 200
        }
      },
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

  Take(["GUI", "Pressure", "Reaction", "Resize", "SVG", "TRS", "Tween", "SVGReady"], function(GUI, Pressure, Reaction, Resize, SVG, TRS, Tween) {
    var alpha, atmLabel, atmRect, g, maxLabel, maxRect, medLabel, medRect, minLabel, minRect, pressures, tick, title, u, vacLabel, vacRect;
    u = 36;
    g = TRS(SVG.create("g", GUI.elm));
    pressures = TRS(SVG.create("g", g));
    TRS.move(pressures, -84, 0);
    title = SVG.create("text", pressures, {
      x: 84,
      y: 0,
      "text-anchor": "middle",
      textContent: "What do the colors mean?",
      "font-size": 24
    });
    vacRect = SVG.create("rect", pressures, {
      x: 0,
      y: 0 * u + 20,
      width: u,
      height: u,
      fill: Pressure(Pressure.vacuum)
    });
    atmRect = SVG.create("rect", pressures, {
      x: 0,
      y: 1 * u + 20,
      width: u,
      height: u,
      fill: Pressure(Pressure.drain)
    });
    minRect = SVG.create("rect", pressures, {
      x: 0,
      y: 2 * u + 20,
      width: u,
      height: u,
      fill: Pressure(Pressure.min)
    });
    medRect = SVG.create("rect", pressures, {
      x: 0,
      y: 3 * u + 20,
      width: u,
      height: u,
      fill: Pressure(Pressure.med)
    });
    maxRect = SVG.create("rect", pressures, {
      x: 0,
      y: 4 * u + 20,
      width: u,
      height: u,
      fill: Pressure(Pressure.max)
    });
    vacLabel = SVG.create("text", pressures, {
      x: u + 8,
      y: 1 * u + 10,
      "text-anchor": "start",
      textContent: "Suction Pressure"
    });
    atmLabel = SVG.create("text", pressures, {
      x: u + 8,
      y: 2 * u + 10,
      "text-anchor": "start",
      textContent: "Drain Pressure"
    });
    minLabel = SVG.create("text", pressures, {
      x: u + 8,
      y: 3 * u + 10,
      "text-anchor": "start",
      textContent: "Low Pressure"
    });
    medLabel = SVG.create("text", pressures, {
      x: u + 8,
      y: 4 * u + 10,
      "text-anchor": "start",
      textContent: "Medium Pressure"
    });
    maxLabel = SVG.create("text", pressures, {
      x: u + 8,
      y: 5 * u + 10,
      "text-anchor": "start",
      textContent: "High Pressure"
    });
    Resize(function() {
      var x, y;
      x = window.innerWidth / 2;
      y = GUI.TopBar.height * 2;
      return TRS.abs(g, {
        x: x,
        y: y
      });
    });
    alpha = 1;
    (tick = function(v) {
      alpha = v;
      return SVG.styles(g, {
        opacity: v * 2 - 1
      });
    })(0);
    Reaction("Help:Show", function() {
      return Tween(alpha, 1, 1.2, tick);
    });
    return Reaction("Help:Hide", function() {
      return Tween(alpha, 0, 1.2, tick);
    });
  });

  (function() {
    return Make("Input", function(elm, calls) {
      var down, mouseleave, mouseup, move, out, over, prepTouchEvent, state, touchend, touchmove, up;
      state = {
        down: false,
        over: false,
        touch: false
      };
      over = function(e) {
        state.over = true;
        if (typeof calls.over === "function") {
          calls.over(e, state);
        }
        if (state.down) {
          return typeof calls.down === "function" ? calls.down(e, state) : void 0;
        }
      };
      down = function(e) {
        state.down = true;
        return typeof calls.down === "function" ? calls.down(e, state) : void 0;
      };
      move = function(e) {
        if (!state.over) {
          over(e);
        }
        if (state.down && (calls.drag != null)) {
          return calls.drag(e, state);
        } else {
          return typeof calls.move === "function" ? calls.move(e, state) : void 0;
        }
      };
      up = function(e) {
        state.down = false;
        if (state.over) {
          if (typeof calls.click === "function") {
            calls.click(e, state);
          }
        } else {
          if (typeof calls.miss === "function") {
            calls.miss(e, state);
          }
        }
        return typeof calls.up === "function" ? calls.up(e, state) : void 0;
      };
      out = function(e) {
        state.over = false;
        return typeof calls.out === "function" ? calls.out(e, state) : void 0;
      };
      elm.addEventListener("mouseenter", function(e) {
        if (state.touch) {
          return;
        }
        over(e);
        return elm.addEventListener("mouseleave", mouseleave);
      });
      elm.addEventListener("mousedown", function(e) {
        if (state.touch) {
          return;
        }
        down(e);
        return window.addEventListener("mouseup", mouseup);
      });
      elm.addEventListener("mousemove", function(e) {
        if (state.touch) {
          return;
        }
        return move(e);
      });
      mouseup = function(e) {
        if (state.touch) {
          return;
        }
        up(e);
        return window.removeEventListener("mouseup", mouseup);
      };
      mouseleave = function(e) {
        if (state.touch) {
          return;
        }
        out(e);
        return elm.removeEventListener("mouseleave", mouseleave);
      };
      prepTouchEvent = function(e) {
        var ref, ref1;
        state.touch = true;
        e.clientX = (ref = e.touches[0]) != null ? ref.clientX : void 0;
        return e.clientY = (ref1 = e.touches[0]) != null ? ref1.clientY : void 0;
      };
      elm.addEventListener("touchstart", function(e) {
        prepTouchEvent(e);
        over(e);
        down(e);
        elm.addEventListener("touchmove", touchmove);
        elm.addEventListener("touchend", touchend);
        return elm.addEventListener("touchcancel", touchend);
      });
      touchmove = function(e) {
        var isOver;
        prepTouchEvent(e);
        isOver = true;
        if (isOver && !state.over) {
          over(e);
        }
        if (isOver) {
          move(e);
        }
        if (!isOver && state.over) {
          return out(e);
        }
      };
      return touchend = function(e) {
        prepTouchEvent(e);
        up(e);
        elm.removeEventListener("touchmove", touchmove);
        elm.removeEventListener("touchend", touchend);
        return elm.removeEventListener("touchcancel", touchend);
      };
    });
  })();

  Take(["Reaction", "ScopeReady"], function(Reaction) {
    var root;
    root = document.querySelector("#root");
    Reaction("Root:Show", function() {
      return root._scope.show(1);
    });
    return Reaction("Root:Hide", function() {
      return root._scope.hide(1);
    });
  });

  Take(["GUI", "Reaction", "Resize", "Scope", "SVG", "ScopeReady"], function(GUI, Reaction, Resize, Scope, SVG) {
    var g, sliders;
    g = Scope(SVG.create("g", GUI.elm));
    g.alpha = 0;
    sliders = Scope(SVG.create("g", g.element, {
      "text-anchor": "middle"
    }));
    sliders.x = -128;
    Resize(function() {
      g.x = window.innerWidth / 2;
      return g.y = GUI.TopBar.height * 2;
    });
    Reaction("Settings:Show", function() {
      return g.show();
    });
    return Reaction("Settings:Hide", function() {
      return g.hide();
    });
  });

  Take(["Registry", "Gradient", "GUI", "Input", "Reaction", "Resize", "SVG", "TRS", "SVGReady"], function(Registry, Gradient, GUI, Input, Reaction, Resize, SVG, TRS) {
    var TopBar, bg, construct, container, help, instances, menu, offsetX, requested, resize, settings, topBar;
    requested = [];
    instances = {};
    menu = null;
    settings = null;
    help = null;
    offsetX = 0;
    topBar = SVG.create("g", GUI.elm, {
      "class": "TopBar"
    });
    bg = SVG.create("rect", topBar, {
      height: GUI.TopBar.height,
      fill: "url(#TopBarGradient)"
    });
    Gradient.createLinear("TopBarGradient", false, "#35488d", "#5175bd", "#35488d");
    container = TRS(SVG.create("g", topBar, {
      "class": "Elements"
    }));
    Take("ScopeReady", function() {
      return SVG.append(GUI.elm, topBar);
    });
    TopBar = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (typeof args[1] === "object") {
        return Registry.set.apply(Registry, ["TopBar"].concat(slice.call(args)));
      } else {
        return requested.push.apply(requested, args);
      }
    };
    TopBar.claimSpace = function(rect) {
      rect.y += GUI.TopBar.height;
      return rect.h -= GUI.TopBar.height;
    };
    Take("ScopeReady", function() {
      var i, len, m, name;
      for (i = m = 0, len = requested.length; m < len; i = ++m) {
        name = requested[i];
        construct(i, name, Registry.get("TopBar", name));
      }
      menu = construct(-1, "Menu", Registry.get("TopBar", "Menu"));
      settings = construct(-1, "Settings", Registry.get("TopBar", "Settings"));
      help = construct(-1, "Help", Registry.get("TopBar", "Help"));
      return Resize(resize);
    });
    resize = function() {
      var base, instance, len, m;
      SVG.attrs(bg, {
        width: window.innerWidth
      });
      TRS.move(container, window.innerWidth / 2 - offsetX / 2);
      for (m = 0, len = instances.length; m < len; m++) {
        instance = instances[m];
        if (typeof (base = instance.api).resize === "function") {
          base.resize();
        }
      }
      TRS.move(menu.element, GUI.TopBar.Menu.inset);
      TRS.move(help.element, window.innerWidth - GUI.TopBar.Help.inset);
      return TRS.move(settings.element, window.innerWidth - GUI.TopBar.Settings.inset);
    };
    construct = function(i, name, api) {
      var buttonPad, buttonWidth, custom, iconRect, iconX, iconY, instance, source, textRect, textX;
      if (api == null) {
        throw "Unknown TopBar button name: " + name;
      }
      source = document.getElementById(name.toLowerCase());
      if (source == null) {
        throw "TopBar icon not found for id: #" + name;
      }
      custom = i === -1;
      buttonPad = custom ? GUI.TopBar.buttonPadCustom : GUI.TopBar.buttonPadStandard;
      if (custom) {
        api.element = TRS(SVG.create("g", topBar, {
          "class": "Element",
          ui: true
        }));
      } else {
        api.element = TRS(SVG.create("g", container, {
          "class": "Element",
          ui: true
        }));
      }
      instance = {
        element: api.element,
        i: i,
        name: name,
        api: api
      };
      if (!custom) {
        instances[name] = instance;
      }
      if (api.bg == null) {
        api.bg = SVG.create("rect", api.element, {
          "class": "BG",
          height: GUI.TopBar.height,
          fill: "transparent"
        });
      }
      if (api.icon == null) {
        api.icon = TRS(SVG.clone(source, api.element));
      }
      if (api.text == null) {
        api.text = TRS(SVG.create("text", api.element, {
          "font-size": 14,
          fill: "#FFF",
          textContent: api.label || name
        }));
      }
      iconRect = api.icon.getBoundingClientRect();
      textRect = api.text.getBoundingClientRect();
      iconX = buttonPad;
      iconY = 0;
      textX = buttonPad + iconRect.width + GUI.TopBar.iconPad;
      buttonWidth = textX + textRect.width + buttonPad;
      TRS.abs(api.icon, {
        x: iconX,
        y: iconY
      });
      TRS.move(api.text, textX, GUI.TopBar.height / 2 + textRect.height / 2 - 4);
      SVG.attrs(api.bg, {
        width: buttonWidth
      });
      if (!custom) {
        TRS.move(api.element, offsetX);
        offsetX += buttonWidth;
      }
      if (typeof api.setup === "function") {
        api.setup(api.element);
      }
      Input(api.element, {
        over: function() {
          if (api.over != null) {
            return api.over();
          }
        },
        down: function() {
          if (api.down != null) {
            return api.down();
          }
        },
        move: function() {
          if (api.move != null) {
            return api.move();
          }
        },
        click: function() {
          if (api.click != null) {
            return api.click();
          }
        },
        up: function() {
          if (api.up != null) {
            return api.up();
          }
        },
        out: function() {
          if (api.out != null) {
            return api.out();
          }
        }
      });
      return instance;
    };
    return Make("TopBar", TopBar);
  });

  Take(["Dev", "RAF", "Tween", "AllReady"], function(Dev, RAF, Tween) {
    if (Dev) {
      return RAF(function() {
        return document.rootElement.style.opacity = 1;
      });
    } else {
      return Tween(0, 1, .5, function(v) {
        return document.rootElement.style.opacity = v;
      });
    }
  });

  Take("SVG", function(SVG) {
    var Highlighter;
    return Make("Highlighter", Highlighter = {
      setup: function() {
        throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.setup() from your animation.";
      },
      enable: function() {
        throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.enable() from your animation.";
      },
      disable: function() {
        throw "Highligher has been removed from SVGA. Please remove the calls to Highligher.disable() from your animation.";
      }
    });
  });

  (function() {
    return Make("Mask", function() {
      throw "Mask() has been removed. Please find a different way to acheive your desired effect.";
    });
  })();

  Take(["Nav"], function(Nav) {
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

  Take(["KeyMe", "Nav", "Tick"], function(KeyMe, Nav, Tick) {
    var accel, decel, getAccel, maxVel, vel;
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

  Take(["Nav"], function(Nav) {
    var down, lastX, lastY;
    lastX = 0;
    lastY = 0;
    down = false;
    window.addEventListener("mousedown", function(e) {
      e.preventDefault();
      down = true;
      lastX = e.clientX;
      return lastY = e.clientY;
    });
    window.addEventListener("mousemove", function(e) {
      if (down && (e.clientX !== lastX || e.clientY !== lastY) && Nav.eventInside(e)) {
        Nav.by({
          x: e.clientX - lastX,
          y: e.clientY - lastY
        });
        lastX = e.clientX;
        return lastY = e.clientY;
      }
    });
    window.addEventListener("mouseup", function(e) {
      return down = false;
    });
    window.addEventListener("dblclick", function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return Nav.to({
          x: 0,
          y: 0,
          z: 0
        });
      }
    });
    return window.addEventListener("wheel", function(e) {
      if (Nav.eventInside(e)) {
        e.preventDefault();
        if (e.deltaMode === WheelEvent.DOM_DELTA_PIXEL) {
          if (e.ctrlKey) {
            return Nav.by({
              z: -e.deltaY / 100
            });
          } else if (e.metaKey) {
            return Nav.by({
              z: -e.deltaY / 200
            });
          } else {
            return Nav.by({
              x: -e.deltaX,
              y: -e.deltaY,
              z: -e.deltaZ
            });
          }
        } else {
          return Nav.by({
            z: -e.deltaY / 200
          });
        }
      }
    });
  });

  Take(["RAF", "SVG", "Tween", "ScopeReady"], function(RAF, SVG, Tween) {
    var Nav, center, dist, distTo, initialSize, limit, ox, oy, pos, render, requestRender, root, scaleStartPosZ, tween, xLimit, yLimit, zLimit;
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
      min: 0,
      max: 3
    };
    scaleStartPosZ = 0;
    tween = null;
    root = document.getElementById("root");
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
        return e.target === document.rootElement || root.contains(e.target);
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
  });

  Take(["Nav"], function(Nav) {
    var gesture;
    if (!(navigator.msMaxTouchPoints && navigator.msMaxTouchPoints > 1)) {
      return;
    }
    gesture = new MSGesture();
    gesture.target = document.rootElement;
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

  Take(["Nav"], function(Nav) {
    var cloneTouches, distTouches, lastTouches, touchMove, touchStart;
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

  Take(["Action", "Reaction"], function(Action, Reaction) {
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

  Take(["Dev", "AllReady"], function(Dev) {
    var elm, len, m, nodes, results;
    if (!Dev) {
      return;
    }
    nodes = Array.prototype.slice.call(document.querySelectorAll("#root [id]"));
    results = [];
    for (m = 0, len = nodes.length; m < len; m++) {
      elm = nodes[m];
      results.push(elm.removeAttribute("id"));
    }
    return results;
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
          if (val === false) {
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
        throw "@animate() is called by the system. Please don't call it yourself.";
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

  Take(["Registry"], function(Registry) {
    return Registry.add("ScopeProcessor", function(scope) {
      scope.getPressureColor = function() {
        throw "@getPressureColor() has been removed. Please Take and use Pressure() instead.";
      };
      scope.setText = function() {
        throw "@setText(x) has been removed. Please @text = x instead.";
      };
      Object.defineProperty(scope, "cx", {
        get: function() {
          throw "cx has been removed.";
        }
      });
      Object.defineProperty(scope, "cy", {
        get: function() {
          throw "cy has been removed.";
        }
      });
      return Object.defineProperty(scope, "turns", {
        get: function() {
          throw "turns has been removed. Please use @rotation instead.";
        }
      });
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

  Take(["Pressure", "Registry", "ScopeCheck", "SVG"], function(Pressure, Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var element, fillPath, isLine, pressure, ref, strokePath;
      ScopeCheck(scope, "style", "pressure", "stroke", "fill", "linearGradient", "radialGradient");
      element = scope.element;
      strokePath = fillPath = element.querySelector("path");
      isLine = ((ref = element.getAttribute("id")) != null ? ref.indexOf("Line") : void 0) > -1;
      scope.style = function() {
        throw "@style is up for debate. Please show Ivan what you're using it to do.";
      };
      pressure = null;
      Object.defineProperty(scope, 'pressure', {
        get: function() {
          return pressure;
        },
        set: function(val) {
          if (pressure !== val) {
            pressure = val;
            if (isLine && !scope.root.BROKEN_LINES) {
              return scope.stroke(Pressure(scope.pressure));
            } else {
              return scope.fill(Pressure(scope.pressure));
            }
          }
        }
      });
      scope.stroke = function(color) {
        if (strokePath != null) {
          SVG.attr(strokePath, "stroke", null);
          strokePath = null;
        }
        return SVG.attr(element, "stroke", color);
      };
      scope.fill = function(color) {
        if (fillPath != null) {
          SVG.attr(fillPath, "fill", null);
          fillPath = null;
        }
        return SVG.attr(element, "fill", color);
      };
      scope.linearGradient = function(stops, x1, y1, x2, y2) {
        if (x1 == null) {
          x1 = 0;
        }
        if (y1 == null) {
          y1 = 0;
        }
        if (x2 == null) {
          x2 = 1;
        }
        if (y2 == null) {
          y2 = 0;
        }
      };
      return scope.radialGradient = function(stops, cx, cy, radius) {};
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var element, text, textElement;
      ScopeCheck(scope, "text");
      element = scope.element;
      textElement = element.querySelector("tspan" || element.querySelector("text"));
      text = textElement != null ? textElement.textContent : void 0;
      return Object.defineProperty(scope, 'text', {
        get: function() {
          return text;
        },
        set: function(val) {
          if (text !== val) {
            return SVG.attr("textContent", text = val);
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
      running = false;
      startTime = null;
      tick = scope.tick;
      scope.tick = function() {
        throw "@tick() is called by the system. Please don't call it yourself.";
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

  Take(["RAF", "Registry", "ScopeCheck", "DOMContentLoaded"], function(RAF, Registry, ScopeCheck) {
    return Registry.add("ScopeProcessor", function(scope) {
      var applyTransform, denom, element, matrix, ref, rotation, scaleX, scaleY, t, transform, transformBaseVal, x, y;
      ScopeCheck(scope, "x", "y", "rotation", "scale", "scaleX", "scaleY", "skewX", "skewY");
      element = scope.element;
      transformBaseVal = (ref = element.transform) != null ? ref.baseVal : void 0;
      transform = document.rootElement.createSVGTransform();
      matrix = document.rootElement.createSVGMatrix();
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
          p = scope.parent;
          while ((p != null) && !isInsideOtherField) {
            isInsideOtherField = p._symbol === scope._symbol;
            p = p.parent;
          }
          if (!isInsideOtherField) {
            return Reaction("Schematic:Show", function() {
              return scope.pressure = Pressure.white;
            });
          }
        }
      };
    });
  });

  Take(["Pressure", "Reaction", "SVG", "Symbol"], function(Pressure, Reaction, SVG, Symbol) {
    return Symbol("HydraulicLine", [], function(svgElement) {
      var scope, strip;
      strip = function(elm) {
        var child, len, m, ref, results;
        if (typeof elm.removeAttributeNS === "function") {
          elm.removeAttributeNS(null, "fill");
        }
        if (typeof elm.removeAttributeNS === "function") {
          elm.removeAttributeNS(null, "stroke");
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
      strip(svgElement);
      svgElement.setAttributeNS(null, "fill", "transparent");
      return scope = {
        pilot: function(name) {
          var len, m, path, ref, results;
          if (scope[name] == null) {
            throw scope.name + ".pilot(\"" + name + "\") failed: " + name + " is not a child of " + scope.name;
          }
          ref = scope[name].element.querySelectorAll("path");
          results = [];
          for (m = 0, len = ref.length; m < len; m++) {
            path = ref[m];
            results.push(SVG.attrs(path, {
              "stroke-dasharray": "6 6"
            }));
          }
          return results;
        },
        setup: function() {
          return Reaction("Schematic:Show", function() {
            return scope.pressure = Pressure.black;
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

  Make("Dev", window.top.location.hostname === "localhost");

  Take("SVG", function(SVG) {
    var Gradient, createStops, existing;
    existing = {};
    Make("Gradient", Gradient = {
      createLinear: function() {
        var attrs, gradient, name, stops, vertical;
        name = arguments[0], vertical = arguments[1], stops = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        if (existing[name] != null) {
          throw "Gradient named " + name + " already exists. Please don't create the same gradient more than once.";
        }
        existing[name] = true;
        attrs = vertical ? {
          id: name,
          x2: 0,
          y2: 1
        } : {
          id: name
        };
        gradient = SVG.create("linearGradient", SVG.defs, attrs);
        createStops(gradient, stops);
        return null;
      },
      createRadial: function() {
        var gradient, name, stops;
        name = arguments[0], stops = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        if (existing[name] != null) {
          throw "Gradient named " + name + " already exists. Please don't create the same gradient more than once.";
        }
        existing[name] = true;
        gradient = SVG.create("radialGradient", SVG.defs, {
          id: name
        });
        createStops(gradient, stops);
        return null;
      }
    });
    return createStops = function(gradient, stops) {
      var attrs, i, len, m, stop;
      stops = stops[0] instanceof Array ? stops[0] : stops;
      for (i = m = 0, len = stops.length; m < len; i = ++m) {
        stop = stops[i];
        if (typeof stop === "string") {
          SVG.create("stop", gradient, {
            stopColor: stop,
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
      return null;
    };
  });

  Take(["KeyNames"], function(KeyNames) {
    var KeyMe, actionize, downHandlers, getModifier, handleKey, keyDown, keyUp, runCallbacks, upHandlers;
    downHandlers = {};
    upHandlers = {};
    KeyMe = function(key, opts) {
      var name;
      if (key == null) {
        throw "You must provide a key name or code for KeyMe(key, options)";
      }
      if (typeof opts !== "object") {
        throw "You must provide an options object for KeyMe(key, options)";
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
    return Make("KeyMe", KeyMe);
  });

  (function() {
    return Make("KeyNames", {
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
    });
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
        throw "RAF(null)";
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
        throw "^ RAF was called more than once with this function. You can use RAF(fn, true) to drop duplicates and bypass this error.";
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
    var Registry, named, tooLate, unnamed;
    named = {};
    unnamed = {};
    tooLate = false;
    return Make("Registry", Registry = {
      add: function(type, item) {
        if (tooLate) {
          console.log(item);
          throw "^ Registry.add was called after registration closed. Please make this " + type + " init faster.";
        }
        return (unnamed[type] != null ? unnamed[type] : unnamed[type] = []).push(item);
      },
      all: function(type) {
        return unnamed[type];
      },
      set: function(type, name, item) {
        var ref;
        if (tooLate) {
          console.log(item);
          throw "^ Registry.set was called after registration closed. Please make " + type + ": " + name + " init faster.";
        }
        if (((ref = named[type]) != null ? ref[name] : void 0) != null) {
          console.log(item);
          throw "^ Registry.add(" + type + ", ^^^, " + name + ") is a duplicate. Please pick a different name.";
        }
        return (named[type] != null ? named[type] : named[type] = {})[name] = item;
      },
      get: function(type, name) {
        var ref;
        return (ref = named[type]) != null ? ref[name] : void 0;
      },
      closeRegistration: function() {
        return tooLate = true;
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
      return window.addEventListener("resize", r);
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
      throw "^ @" + prop + " is a reserved name. Please choose a different name for your child/property \"" + prop + "\".";
    }
    return results;
  });

  (function() {
    var CheckSVGReady, SVG, SVGReady, attrNames, defs, propNames, root, svgNS, xlinkNS;
    root = document.rootElement;
    defs = root.querySelector("defs");
    svgNS = "http://www.w3.org/2000/svg";
    xlinkNS = "http://www.w3.org/1999/xlink";
    propNames = {
      textContent: true
    };
    attrNames = {
      viewBox: "viewBox"
    };
    SVGReady = false;
    CheckSVGReady = function() {
      return SVGReady || (SVGReady = Take("SVGReady"));
    };
    return Make("SVG", SVG = {
      root: root,
      defs: defs,
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
          throw "Clone source is undefined in SVG.clone(source, parent, attrs)";
        }
        if (!CheckSVGReady()) {
          throw "SVG.clone() called before SVGReady";
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
          throw "SVG.append() called before SVGReady";
        }
        parent.appendChild(child);
        return child;
      },
      prepend: function(parent, child) {
        if (!CheckSVGReady()) {
          throw "SVG.prepend() called before SVGReady";
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
          throw "SVG.attrs was called with a null element";
        }
        if (typeof attrs !== "object") {
          console.log(attrs);
          throw "SVG.attrs requires an object as the second argument, got ^";
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
          throw "SVG.attr was called with a null element";
        }
        if (typeof k !== "string") {
          console.log(k);
          throw "SVG.attr requires a string as the second argument, got ^^^";
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
          throw "SVG.styles was called with a null element";
        }
        if (typeof styles !== "object") {
          console.log(styles);
          throw "SVG.styles requires an object as the second argument, got ^";
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
          throw "SVG.style was called with a null element";
        }
        if (typeof k !== "string") {
          console.log(k);
          throw "SVG.style requires a string as the second argument, got ^";
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
  })();

  Take("Registry", function(Registry) {
    var Symbol;
    Symbol = function(symbolName, instanceNames, symbol) {
      var instanceName, len, m, results;
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

  Take("RAF", function(RAF) {
    var callbacks, tick, time;
    callbacks = [];
    time = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
    RAF(tick = function(t) {
      var cb, dt, len, m;
      dt = Math.max(t / 1000 - time, 0.25);
      time += dt;
      for (m = 0, len = callbacks.length; m < len; m++) {
        cb = callbacks[m];
        cb(time, dt);
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
        throw "^ Tick was called more than once with this function. You can use Tick(fn, true) to drop duplicates and bypass this error.";
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
        throw "^ Null element passed to TRS(elm)";
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
        throw "^ Non-TRS element passed to TRS.abs(elm, attrs)";
      }
      if (attrs == null) {
        console.log(elm);
        throw "^ Null attrs passed to TRS.abs(elm, attrs)";
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
        throw "^ Non-TRS element passed to TRS.abs(elm, attrs)";
      }
      if (attrs == null) {
        console.log(elm);
        throw "^ Null attrs passed to TRS.abs(elm, attrs)";
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
        throw "^ Non-TRS element passed to TRS.move";
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
        throw "^ Non-TRS element passed to TRS.rotate";
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
        throw "^ Non-TRS element passed to TRS.scale";
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
        throw "^ Non-TRS element passed to TRS.origin";
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
          throw "Tween: \"" + given + "\" is not a value ease type.";
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
        tween.pos = Math.min(1, tween.pos + dt / tween.time);
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

  Take(["ControlPanelLayout", "Gradient", "GUI", "Resize", "SVG", "Scope"], function(ControlPanelLayout, Gradient, GUI, Resize, SVG, Scope) {
    var CP, ControlPanelView, bg, g, panelElms, panelHeight, panelRadius, panelWidth, resize, vertical;
    CP = GUI.ControlPanel;
    panelRadius = CP.borderRadius + CP.pad * 2;
    vertical = true;
    panelWidth = 0;
    panelHeight = 0;
    Gradient.createLinear("CPGradient", false, "#5175bd", "#35488d");
    g = Scope(SVG.create("g", GUI.elm, {
      xControls: "",
      fontSize: 16,
      textAnchor: "middle"
    }));
    bg = SVG.create("rect", g.element, {
      rx: panelRadius,
      fill: "url(#CPGradient)"
    });
    panelElms = Scope(SVG.create("g", g.element));
    panelElms.x = panelElms.y = CP.pad * 2;
    resize = function() {
      var size, view;
      view = {
        w: window.innerWidth,
        h: window.innerHeight
      };
      vertical = view.w >= view.h * 1.3;
      size = vertical ? ControlPanelLayout.vertical(view) : ControlPanelLayout.horizontal(view);
      panelWidth = size.w + CP.pad * 4;
      panelHeight = size.h + CP.pad * 4;
      if (vertical) {
        g.x = view.w - panelWidth | 0;
        g.y = view.h / 2 - panelHeight / 2 | 0;
        return SVG.attrs(bg, {
          width: panelWidth + panelRadius,
          height: panelHeight
        });
      } else {
        g.x = view.w / 2 - panelWidth / 2 | 0;
        g.y = view.h - panelHeight | 0;
        return SVG.attrs(bg, {
          width: panelWidth,
          height: panelHeight + panelRadius
        });
      }
    };
    Take("ScopeReady", function() {
      return Resize(resize, true);
    });
    return Make("ControlPanel", ControlPanelView = {
      createElement: function(parent) {
        var elm;
        if (parent == null) {
          parent = null;
        }
        return elm = SVG.create("g", parent || panelElms.element);
      },
      claimSpace: function(rect) {
        if (vertical) {
          return rect.w -= panelWidth;
        } else {
          return rect.h -= panelHeight;
        }
      }
    });
  });

  Take(["GUI"], function(arg) {
    var GUI;
    GUI = arg.ControlPanel;
    return Make("LayoutRow", function() {
      var api, consumedHeight, consumedWidth, elements;
      consumedWidth = 0;
      consumedHeight = 0;
      elements = [];
      return api = {
        hasSpace: function(size) {
          return consumedWidth + size.w <= GUI.width;
        },
        add: function(scope, size) {
          elements.push({
            scope: scope,
            size: size
          });
          consumedWidth += size.w;
          return consumedHeight = Math.max(consumedHeight, size.h);
        },
        getSize: function() {
          return {
            w: consumedWidth,
            h: consumedHeight
          };
        },
        resize: function(arg1, view, vertical) {
          var actual, consumedX, consumedY, element, extraSpace, h, len, m, w, x, y;
          x = arg1.x, y = arg1.y;
          extraSpace = (GUI.width - consumedWidth) / elements.length;
          consumedX = 0;
          consumedY = 0;
          for (m = 0, len = elements.length; m < len; m++) {
            element = elements[m];
            w = element.size.w + extraSpace;
            h = consumedHeight;
            actual = element.scope.resize({
              w: w,
              h: h,
              x: x,
              y: y
            }, view, vertical);
            element.scope.x = x + consumedX;
            element.scope.y = y;
            consumedX += actual.w;
            consumedY = Math.max(consumedY, actual.h);
          }
          return {
            w: consumedX,
            h: consumedY
          };
        }
      };
    });
  });

  Take(["GUI", "LayoutRow"], function(arg, LayoutRow) {
    var GUI, attemptHorizontalLayout, rows;
    GUI = arg.ControlPanel;
    rows = [LayoutRow()];
    Make("ControlPanelLayout", {
      addScope: function(scope) {
        var currentRow, size;
        size = scope.getPreferredSize();
        currentRow = rows[rows.length - 1];
        if (currentRow.hasSpace(size)) {
          return currentRow.add(scope, size);
        } else {
          rows.push(currentRow = LayoutRow());
          return currentRow.add(scope, size);
        }
      },
      vertical: function(view) {
        var len, m, row, s, size;
        size = {
          w: 0,
          h: 0
        };
        for (m = 0, len = rows.length; m < len; m++) {
          row = rows[m];
          s = row.resize({
            x: 0,
            y: size.h
          }, view, true);
          size.w = s.w;
          size.h += s.h;
        }
        return size;
      },
      horizontal: function(view) {
        var result, rowsPerCol;
        if (!(view.w > 1)) {
          return {
            w: 0,
            h: 0
          };
        }
        rowsPerCol = 0;
        result = null;
        while (result == null) {
          rowsPerCol++;
          result = attemptHorizontalLayout(view, false, rowsPerCol);
        }
        return result;
      }
    });
    return attemptHorizontalLayout = function(view, vertical, rowsPerCol) {
      var consumedRows, h, i, len, m, row, s, xOffset, yOffset;
      xOffset = 0;
      yOffset = 0;
      h = 0;
      consumedRows = 0;
      for (i = m = 0, len = rows.length; m < len; i = ++m) {
        row = rows[i];
        if (consumedRows >= rowsPerCol) {
          consumedRows = 0;
          xOffset += GUI.width;
          if (xOffset + GUI.width >= view.w) {
            return null;
          }
          h = Math.max(h, yOffset);
          yOffset = 0;
        }
        s = row.resize({
          x: xOffset,
          y: yOffset
        }, view, vertical);
        yOffset += s.h;
        if (s.h > 0) {
          consumedRows++;
        }
      }
      return {
        w: xOffset + GUI.width,
        h: Math.max(h, yOffset)
      };
    };
  });

  Take(["Control", "GUI", "Input", "Scope", "SVG", "Tween"], function(Control, arg, Input, Scope, SVG, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Control("button", function(elm, props) {
      var bg, bgFill, blueBG, h, handlers, label, lightBG, orangeBG, scope, w;
      handlers = [];
      SVG.attrs(elm, {
        ui: true
      });
      bg = Scope(SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        rx: GUI.borderRadius,
        strokeWidth: 2,
        fill: "hsl(220, 10%, 92%)"
      }));
      label = SVG.create("text", elm, {
        textContent: props.name,
        fill: "hsl(227, 16%, 24%)"
      });
      w = Math.max(GUI.unit, label.getComputedTextLength() + GUI.pad * 8);
      h = GUI.unit;
      blueBG = {
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
      bgFill = function(arg1) {
        var b, g, r;
        r = arg1.r, g = arg1.g, b = arg1.b;
        return SVG.attrs(bg.element, {
          stroke: "rgb(" + (r | 0) + "," + (g | 0) + "," + (b | 0) + ")"
        });
      };
      bgFill(blueBG);
      Input(elm, {
        over: function() {
          return bgFill(lightBG);
        },
        down: function() {
          return bgFill(orangeBG);
        },
        out: function() {
          return Tween(lightBG, blueBG, .2, {
            tick: bgFill
          });
        },
        click: function() {
          var handler, len, m;
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            handler();
          }
          return Tween(orangeBG, lightBG, .2, {
            tick: bgFill
          });
        }
      });
      return scope = {
        attach: function(props) {
          if (props.click != null) {
            return handlers.push(props.click);
          }
        },
        getPreferredSize: function() {
          return {
            w: w,
            h: h
          };
        },
        resize: function(arg1) {
          var h, w;
          w = arg1.w, h = arg1.h;
          SVG.attrs(bg.element, {
            width: w - GUI.pad * 2,
            height: h - GUI.pad * 2
          });
          SVG.attrs(label, {
            x: w / 2,
            y: h / 2 + 6
          });
          return {
            w: w,
            h: h
          };
        }
      };
    });
  });

  Take(["Control", "GUI", "SVG"], function(Control, arg, SVG) {
    var GUI;
    GUI = arg.ControlPanel;
    return Control("divider", function(elm, props) {
      var g, scope;
      g = SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        width: GUI.width - GUI.pad * 2,
        height: GUI.pad * 3,
        rx: GUI.pad,
        fill: "hsl(227, 45%, 24%)"
      });
      return scope = {
        attach: function(props) {},
        getPreferredSize: function() {
          return {
            w: GUI.width,
            h: GUI.pad * 5
          };
        },
        resize: function(arg1, view, vertical) {
          var h, w, x, y;
          w = arg1.w, h = arg1.h, x = arg1.x, y = arg1.y;
          return {
            w: GUI.width,
            h: GUI.pad * 5
          };
        }
      };
    });
  });

  Take(["Control", "GUI", "Input", "SVG", "TRS", "Tween"], function(Control, arg, Input, SVG, TRS, Tween) {
    var GUI;
    GUI = arg.ControlPanel;
    return Control("slider", function(elm, props) {
      var bgFill, blueBG, handlers, label, labelWidth, lightBG, orangeBG, range, scope, startDrag, thumb, thumbBG, track, update, v;
      handlers = [];
      v = 0;
      range = 0;
      startDrag = 0;
      track = TRS(SVG.create("rect", elm, {
        x: GUI.pad,
        y: GUI.pad,
        strokeWidth: 2,
        fill: "hsl(227, 45%, 24%)",
        stroke: "hsl(227, 45%, 24%)"
      }));
      thumb = TRS(SVG.create("g", elm));
      thumbBG = SVG.create("rect", thumb, {
        x: GUI.pad,
        y: GUI.pad,
        strokeWidth: 2,
        fill: "hsl(220, 10%, 92%)"
      });
      label = SVG.create("text", thumb, {
        textContent: props.name,
        fill: "hsl(227, 16%, 24%)",
        y: GUI.unit / 2 + 6
      });
      labelWidth = Math.max(GUI.unit, label.getComputedTextLength() + GUI.pad * 8);
      SVG.attrs(thumbBG, {
        width: labelWidth
      });
      SVG.attrs(label, {
        x: GUI.pad + labelWidth / 2
      });
      blueBG = {
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
      bgFill = function(arg1) {
        var b, g, r;
        r = arg1.r, g = arg1.g, b = arg1.b;
        return SVG.attrs(thumbBG, {
          stroke: "rgb(" + (r | 0) + "," + (g | 0) + "," + (b | 0) + ")"
        });
      };
      bgFill(blueBG);
      update = function(V) {
        v = V;
        return TRS.abs(thumb, {
          x: v * range
        });
      };
      Input(elm, {
        over: function() {
          return bgFill(lightBG);
        },
        down: function(e) {
          startDrag = e.clientX / range - v;
          return bgFill(orangeBG);
        },
        out: function(e, state) {
          if (!state.down) {
            return Tween(lightBG, blueBG, .1, {
              tick: bgFill
            });
          }
        },
        miss: function() {
          return Tween(orangeBG, blueBG, .1, {
            tick: bgFill
          });
        },
        drag: function(e) {
          var handler, len, m, results;
          update(Math.max(0, Math.min(1, e.clientX / range - startDrag)));
          results = [];
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            results.push(handler(v));
          }
          return results;
        },
        click: function() {
          return Tween(orangeBG, lightBG, .2, {
            tick: bgFill
          });
        }
      });
      return scope = {
        attach: function(props) {
          if (props.change != null) {
            return handlers.push(props.change);
          }
        },
        getPreferredSize: function() {
          return {
            w: GUI.width,
            h: GUI.unit
          };
        },
        resize: function(arg1) {
          var h, w;
          w = arg1.w, h = arg1.h;
          range = w - GUI.pad * 2 - labelWidth;
          SVG.attrs(track, {
            width: w - GUI.pad * 2,
            height: h - GUI.pad * 2,
            rx: (h - GUI.pad * 2) / 2
          });
          SVG.attrs(thumbBG, {
            height: h - GUI.pad * 2,
            rx: (h - GUI.pad * 2) / 2
          });
          return {
            w: w,
            h: h
          };
        }
      };
    });
  });

  Take(["Action", "Reaction", "SVG", "DOMContentLoaded"], function(Action, Reaction, SVG) {
    var len, m, o, ref, setBackground, target;
    target = null;
    ref = window.parent.document.querySelectorAll("object");
    for (m = 0, len = ref.length; m < len; m++) {
      o = ref[m];
      if (o.contentDocument = document) {
        target = o;
        break;
      }
    }
    setBackground = function(v) {
      var c;
      c = "hsl(227, 5%, " + (v * 100) + "%)";
      return SVG.style(target, "background-color", c);
    };
    Reaction("Background:Set", setBackground);
    return Take("ScopeReady", function() {
      return Action("Background:Set", .70);
    });
  });

}).call(this);
