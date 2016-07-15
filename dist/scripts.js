(function() {
  var Mask, getParentInverseTransform,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  Take(["Action", "RAF", "ScopeBuilder", "SVGCrawler", "DOMContentLoaded"], function(Action, RAF, ScopeBuilder, SVGCrawler) {
    var crawlerData, svg;
    svg = document.rootElement;
    crawlerData = SVGCrawler(svg);
    Make("SVGReady");
    return setTimeout(function() {
      var rootScope;
      rootScope = ScopeBuilder(crawlerData);
      Make("root", rootScope);
      Action("setup");
      Action("ScopeReady");
      return Take(["ControlsReady", "TopBarReady", "NavReady"], function() {
        return svg.style.opacity = 1;
      });
    });
  });

  Take(["Style", "Symbol", "Transform"], function(Style, Symbol, Transform) {
    var ScopeBuilder, buildScope, getSymbol, processors, tooLate;
    processors = [];
    tooLate = false;
    ScopeBuilder = function(target, parentScope) {
      var len, m, ref, scope, subTarget;
      if (parentScope == null) {
        parentScope = null;
      }
      tooLate = true;
      scope = buildScope(target.name, target.elm, parentScope);
      ref = target.sub;
      for (m = 0, len = ref.length; m < len; m++) {
        subTarget = ref[m];
        ScopeBuilder(subTarget, scope);
      }
      return scope;
    };
    ScopeBuilder.process = function(fn) {
      if (tooLate) {
        console.log(fn);
        throw "^ ScopeBuilder.process fn was too late. Please make it init faster.";
      }
      return processors.push(fn);
    };
    Make("ScopeBuilder", ScopeBuilder);
    buildScope = function(instanceName, element, parentScope) {
      var fn, len, m, name, scope, symbol;
      if (parentScope == null) {
        parentScope = null;
      }
      symbol = getSymbol(instanceName);
      scope = symbol.create(element);
      if (scope.children == null) {
        scope.children = [];
      }
      if (scope.element == null) {
        scope.element = element;
      }
      if (scope.parent == null) {
        scope.parent = parentScope;
      }
      Object.defineProperty(scope, "FlowArrows", {
        get: function() {
          throw "root.FlowArrows has been removed. Please use FlowArrows instead.";
        }
      });
      if (scope.getElement == null) {
        scope.getElement = function() {
          throw "@getElement() has been removed. Please use @element instead.";
        };
      }
      Style(scope);
      Transform(scope);
      for (m = 0, len = processors.length; m < len; m++) {
        fn = processors[m];
        fn(scope);
      }
      if (parentScope != null) {
        if (scope.root == null) {
          scope.root = parentScope.root;
        }
        name = (instanceName != null) && instanceName !== "DefaultElement" ? instanceName : "child" + parentScope.children.length;
        if (element.getAttributeNS(null, "class") == null) {
          element.setAttributeNS(null, "class", name);
        }
        if (parentScope.name === "mainStage") {
          console.log(name);
        }
        if (parentScope[name] != null) {
          throw "Duplicate instance name detected in " + parentScope.name + ": " + name;
        }
        parentScope[name] = scope;
        parentScope.children.push(scope);
        scope.instanceName = instanceName;
        scope.name = name;
      } else {
        if (scope.root == null) {
          scope.root = scope;
        }
      }
      return scope;
    };
    return getSymbol = function(instanceName) {
      var symbol;
      if (symbol = Symbol.forInstanceName(instanceName)) {
        return symbol;
      } else if ((instanceName != null ? instanceName.indexOf("Line") : void 0) > -1) {
        return Symbol.forSymbolName("HydraulicLine");
      } else if ((instanceName != null ? instanceName.indexOf("Field") : void 0) > -1) {
        return Symbol.forSymbolName("HydraulicField");
      } else {
        return Symbol.forSymbolName("DefaultElement");
      }
    };
  });

  Take(["PureDom", "SVG", "DOMContentLoaded"], function(PureDom, SVG) {
    var SVGCrawler, deprecations;
    deprecations = ["controlPanel", "ctrlPanel", "navOverlay"];
    return Make("SVGCrawler", SVGCrawler = function(elm) {
      var childElm, childNodes, clone, len, link, m, ref, ref1, target, useParent;
      target = {
        name: elm === document.rootElement ? "root" : (ref = elm.getAttribute("id")) != null ? ref.split("_")[0] : void 0,
        elm: elm,
        sub: []
      };
      childNodes = Array.prototype.slice.call(elm.childNodes);
      for (m = 0, len = childNodes.length; m < len; m++) {
        childElm = childNodes[m];
        if (ref1 = childElm.id, indexOf.call(deprecations, ref1) >= 0) {
          console.log("#" + childElm.id + " is obsolete. Please remove it from your FLA and re-export this SVG.");
          elm.removeChild(childElm);
        } else if (childElm instanceof SVGGElement) {
          target.sub.push(SVGCrawler(childElm));
        } else if (childElm instanceof SVGUseElement) {
          useParent = childElm.parentNode;
          link = SVG.defs.querySelector(childElm.getAttribute("xlink:href"));
          clone = link.cloneNode(true);
          useParent.replaceChild(clone, childElm);
        }
      }
      return target;
    });
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
          if (set.parentScope.visible) {
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
      return enableAll(animateMode = true);
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

  Take(["Config", "FlowArrows:Config", "FlowArrows:Containerize", "FlowArrows:Segment"], function(CDConfig, Config, Containerize, Segment) {
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
          if (CDConfig("dev")) {
            child.element.addEventListener("mouseover", function() {
              return console.log(childName);
            });
          }
          results.push(scope[childName] = child);
        }
        return results;
      });
    });
  });

  Take(["Resize", "root", "SVG", "TopBar", "TRS", "SVGReady"], function(Resize, root, SVG, TopBar, TRS) {
    var g, hide, show;
    g = TRS(SVG.create("g", SVG.root));
    SVG.create("rect", g, {
      x: -200,
      y: -30,
      width: 400,
      height: 60,
      rx: 30,
      ry: 30,
      fill: "#222",
      "fill-opacity": 0.9
    });
    SVG.create("text", g, {
      y: 15,
      textContent: "Click To Focus",
      "font-size": 20,
      fill: "#FFF",
      "alignment-baseline": "middle",
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
        y: TopBar.height
      });
    });
    window.addEventListener("focus", hide);
    window.addEventListener("touchstart", hide);
    window.addEventListener("blur", show);
    show();
    return window.focus();
  });

  Take(["Component", "PointerInput", "Reaction", "Resize", "SVG", "TopBar", "TRS", "Tween1", "SVGReady"], function(Component, PointerInput, Reaction, Resize, SVG, TopBar, TRS, Tween1) {
    var Control, bg, g, instancesByNameByType, instantiate, pad, panelX, positionPanel, resize, tick;
    pad = 5;
    panelX = 0;
    instancesByNameByType = {};
    g = TRS(SVG.create("g", SVG.root, {
      "class": "Controls",
      "font-size": 20,
      "text-anchor": "middle"
    }));
    bg = SVG.create("rect", g, {
      "class": "BG"
    });
    Control = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (typeof args[0] === "string") {
        return Component.make.apply(Component, ["Control"].concat(slice.call(args)));
      } else {
        return instantiate.apply(null, args);
      }
    };
    Control.panelWidth = 0;
    Control.panelShowing = false;
    resize = function() {
      var control, height, instancesByName, name, offset, panelWidth, results, type;
      panelWidth = Control.panelWidth = Math.ceil(3 * Math.sqrt(window.innerWidth));
      SVG.attr(bg, "width", panelWidth);
      SVG.attr(bg, "height", window.innerHeight - TopBar.height);
      positionPanel();
      offset = pad;
      results = [];
      for (type in instancesByNameByType) {
        instancesByName = instancesByNameByType[type];
        results.push((function() {
          var results1;
          results1 = [];
          for (name in instancesByName) {
            control = instancesByName[name];
            height = control.api.resize(panelWidth - pad * 2);
            if (typeof height !== "number") {
              console.log(control);
              throw "Control api.resize() function must return a height";
            }
            TRS.move(control.element, pad, offset);
            results1.push(offset += height + pad);
          }
          return results1;
        })());
      }
      return results;
    };
    instantiate = function(props) {
      var api, defn, element, instancesByName, name, type;
      name = props.name;
      type = props.type;
      defn = Component.take("Control", type);
      if (name == null) {
        console.log(props);
        throw "^ You must include a \"name\" property when creating a Control instance";
      }
      if (type == null) {
        console.log(props);
        throw "^ You must include a \"type\" property when creating a Control instance";
      }
      if (defn == null) {
        console.log(props);
        throw "^ Unknown Control type: \"" + type + "\". First, check for typos. If everything looks good, this Control may have failed to load on time, which would mean there's a bug in the Control component.";
      }
      instancesByName = instancesByNameByType[type] != null ? instancesByNameByType[type] : instancesByNameByType[type] = {};
      if (!instancesByName[name]) {
        element = TRS(SVG.create("g", g, {
          "class": name + " " + type,
          ui: true
        }));
        api = defn(name, element);
        if (typeof api.setup === "function") {
          api.setup();
        }
        instancesByName[name] = {
          element: element,
          api: api
        };
      }
      instancesByName[name].api.attach(props);
      return instancesByName[name].api;
    };
    positionPanel = function() {
      return TRS.move(g, window.innerWidth - Control.panelWidth * panelX, TopBar.height);
    };
    tick = function(v) {
      panelX = v;
      return positionPanel();
    };
    Reaction("Schematic:Show", function() {
      Tween1(panelX, -1, 0.7, tick);
      return Control.panelShowing = false;
    });
    Reaction("Schematic:Hide", function() {
      Tween1(panelX, 1, 0.7, tick);
      return Control.panelShowing = true;
    });
    Reaction("ScopeReady", function() {
      Resize(resize);
      return Make("ControlsReady");
    });
    return Make("Control", Control);
  });

  Take(["Config", "Resize", "SVG", "Tick", "TopBarReady"], function(Config, Resize, SVG, Tick) {
    var avgLength, avgList, count, freq, text, total;
    if (!Config("dev")) {
      return;
    }
    count = 0;
    freq = 1;
    avgLength = 10;
    avgList = [];
    total = 0;
    text = SVG.create("text", SVG.root);
    Resize(function() {
      return SVG.attrs(text, {
        x: 7,
        y: 68
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
      if (count++ / fps > freq) {
        count = 0;
        return SVG.attrs(text, {
          textContent: "FPS: " + fps
        });
      }
    });
  });

  Take(["Component", "PointerInput", "Reaction", "Resize", "SVG", "TRS", "SVGReady"], function(Component, PointerInput, Reaction, Resize, SVG, TRS) {
    var TopBar, bg, buttonPad, construct, container, help, iconPad, instances, menu, offsetX, requested, resize, settings, topBar, topBarHeight;
    topBarHeight = 48;
    buttonPad = 20;
    iconPad = 6;
    requested = [];
    instances = {};
    menu = null;
    settings = null;
    help = null;
    offsetX = 0;
    topBar = SVG.create("g", SVG.root, {
      "class": "TopBar"
    });
    bg = SVG.create("rect", topBar, {
      height: 48,
      fill: "url(#TopBarGradient)"
    });
    SVG.createGradient("TopBarGradient", false, "#35488d", "#5175bd", "#35488d");
    container = TRS(SVG.create("g", topBar, {
      "class": "Elements"
    }));
    TopBar = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (typeof args[1] === "object") {
        return Component.make.apply(Component, ["TopBar"].concat(slice.call(args)));
      } else {
        return requested.push.apply(requested, args);
      }
    };
    TopBar.height = topBarHeight;
    Reaction("ScopeReady", function() {
      var definitions, i, len, m, name;
      definitions = Component.take("TopBar");
      for (i = m = 0, len = requested.length; m < len; i = ++m) {
        name = requested[i];
        construct(i, name, definitions[name]);
      }
      menu = construct(-1, "Menu", definitions["Menu"]);
      settings = construct(-1, "Settings", definitions["Settings"]);
      help = construct(-1, "Help", definitions["Help"]);
      return Resize(resize);
    });
    Take("ControlsReady", function() {
      return SVG.append(SVG.root, topBar);
    });
    resize = function() {
      var base1, instance, len, m;
      SVG.attrs(bg, {
        width: window.innerWidth
      });
      TRS.move(container, window.innerWidth / 2 - offsetX / 2);
      for (m = 0, len = instances.length; m < len; m++) {
        instance = instances[m];
        if (typeof (base1 = instance.api).resize === "function") {
          base1.resize();
        }
      }
      TRS.move(menu.element, 0);
      TRS.move(help.element, window.innerWidth - 122);
      TRS.move(settings.element, window.innerWidth - 264);
      if (!Take("TopBarReady")) {
        return Make("TopBarReady");
      }
    };
    construct = function(i, name, api) {
      var buttonWidth, custom, iconRect, iconX, iconY, instance, source, textRect, textX;
      if (api == null) {
        throw "Unknown TopBar button name: " + name;
      }
      source = document.getElementById(name.toLowerCase());
      if (source == null) {
        throw "TopBar icon not found for id: #" + name;
      }
      custom = i === -1;
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
          height: topBarHeight,
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
          textContent: api.label || name.toUpperCase()
        }));
      }
      iconRect = api.icon.getBoundingClientRect();
      textRect = api.text.getBoundingClientRect();
      iconX = buttonPad;
      iconY = 0;
      textX = buttonPad + iconRect.width + iconPad;
      buttonWidth = textX + textRect.width + buttonPad;
      TRS.abs(api.icon, {
        x: iconX,
        y: iconY
      });
      TRS.move(api.text, textX, topBarHeight / 2 + textRect.height / 2 - 3);
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
      if (api.click != null) {
        PointerInput.addClick(api.element, api.click);
      }
      if (api.move != null) {
        PointerInput.addMove(api.element, api.move);
      }
      if (api.down != null) {
        PointerInput.addDown(api.element, api.down);
      }
      if (api.up != null) {
        PointerInput.addUp(api.element, api.up);
      }
      if (api.over != null) {
        PointerInput.addOver(api.element, api.over);
      }
      if (api.out != null) {
        PointerInput.addOut(api.element, api.our);
      }
      return instance;
    };
    return Make("TopBar", TopBar);
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

  getParentInverseTransform = function(root, element, currentTransform) {
    var inv, inversion, matches, matrixString, newMatrix;
    if (element.nodeName === "svg" || element.getAttribute("id") === "mainStage") {
      return currentTransform;
    }
    newMatrix = root.element.createSVGMatrix();
    matrixString = element.getAttribute("transform");
    matches = matrixString.match(/[+-]?\d+(\.\d+)?/g);
    newMatrix.a = matches[0];
    newMatrix.b = matches[1];
    newMatrix.c = matches[2];
    newMatrix.d = matches[3];
    newMatrix.e = matches[4];
    newMatrix.f = matches[5];
    inv = newMatrix.inverse();
    inversion = "matrix(" + inv.a + ", " + inv.b + ", " + inv.c + ", " + inv.d + ", " + inv.e + ", " + inv.f + ")";
    currentTransform = currentTransform + " " + inversion;
    return getParentInverseTransform(root, element.parentNode, currentTransform);
  };

  Make("Mask", Mask = function(root, maskInstance, maskedInstance, maskName) {
    var invertMatrix, mask, maskElement, maskedElement, maskedParent, newStyle, origMatrix, origStyle, rootElement, transString;
    maskElement = maskInstance.element;
    maskedElement = maskedInstance.element;
    rootElement = root.element;
    mask = document.createElementNS("http://www.w3.org/2000/svg", "mask");
    mask.setAttribute("id", maskName);
    mask.setAttribute("maskContentUnits", "userSpaceOnUse");
    maskedParent = document.createElementNS("http://www.w3.org/2000/svg", "g");
    maskedParent.setAttribute('transform', maskedElement.getAttribute('transform'));
    maskedElement.parentNode.insertBefore(maskedParent, maskedElement);
    maskedElement.parentNode.removeChild(maskedElement);
    maskedParent.appendChild(maskedElement);
    mask.appendChild(maskElement);
    rootElement.querySelector('defs').insertBefore(mask, null);
    invertMatrix = getParentInverseTransform(root, maskedElement.parentNode, "");
    origMatrix = maskElement.getAttribute("transform");
    transString = invertMatrix + " " + origMatrix + " ";
    maskElement.setAttribute('transform', transString);
    origStyle = maskedElement.getAttribute('style');
    if (origStyle != null) {
      newStyle = origStyle + ("; mask: url(#" + maskName + ");");
    } else {
      newStyle = "mask: url(#" + maskName + ");";
    }
    maskedElement.setAttribute('transform', "matrix(1, 0, 0, 1, 0, 0)");
    return maskedParent.setAttribute("style", newStyle);
  });

  Take(["Symbol"], function(Symbol) {
    return Symbol("DefaultElement", [], function(svgElement) {
      var ref, scope, textElement;
      textElement = (ref = svgElement.querySelector("text")) != null ? ref.querySelector("tspan") : void 0;
      return scope = {
        setText: function(text) {
          return textElement != null ? textElement.textContent = text : void 0;
        }
      };
    });
  });

  Take(["Pressure", "Reaction", "Symbol"], function(Pressure, Reaction, Symbol) {
    return Symbol("HydraulicField", [], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          return Reaction("Schematic:Show", function() {
            return scope.pressure = Pressure.white;
          });
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

  Take(["Reaction"], function(Reaction) {
    var Component, definitions, instantiatedStarted;
    definitions = {};
    instantiatedStarted = false;
    return Make("Component", Component = {
      make: function() {
        var args, name, type;
        type = arguments[0], name = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        if (instantiatedStarted) {
          throw "The component \"" + name + "\" arrived after setup started. Please figure out a way to make it initialize faster.";
        }
        return (definitions[type] != null ? definitions[type] : definitions[type] = {})[name] = args.length === 1 ? args[0] : args;
      },
      take: function(type, name) {
        var ofType;
        instantiatedStarted = true;
        ofType = definitions[type] || {};
        if (name != null) {
          return ofType[name];
        } else {
          return ofType;
        }
      }
    });
  });

  (function() {
    var buildSubCache, cache, dispatchWithFn;
    cache = {};
    Make("Dispatch", function(node, action, sub) {
      var base1, fn, len, m, nameCache, ref, results;
      if (sub == null) {
        sub = "children";
      }
      if (typeof action === "function") {
        return dispatchWithFn(node, action, sub);
      } else {
        if (cache[sub] == null) {
          cache[sub] = {};
        }
        if (cache[sub][action] == null) {
          nameCache = (base1 = cache[sub])[action] != null ? base1[action] : base1[action] = [];
          buildSubCache(node, action, sub, nameCache);
        }
        ref = cache[sub][action];
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          fn = ref[m];
          results.push(fn());
        }
        return results;
      }
    });
    buildSubCache = function(node, name, sub, nameCache) {
      var child, len, m, ref, results;
      if (typeof node[name] === "function") {
        nameCache.push(node[name].bind(node));
      }
      ref = node[sub];
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        child = ref[m];
        results.push(buildSubCache(child, name, sub, nameCache));
      }
      return results;
    };
    return dispatchWithFn = function(node, fn, sub) {
      var child, len, m, ref, results;
      fn(node);
      ref = node[sub];
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        child = ref[m];
        results.push(dispatchWithFn(child, fn, sub));
      }
      return results;
    };
  })();

  Take(["KeyCodes", "KeyNames"], function(KeyCodes, KeyNames) {
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
      code = e.keyCode;
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
    return Make("KeyMe", KeyMe);
  });

  (function() {
    var KeyCodes, KeyNames, k, v;
    KeyCodes = {
      cancel: 3,
      help: 6,
      back_space: 8,
      tab: 9,
      clear: 12,
      "return": 13,
      enter: 14,
      shift: 16,
      control: 17,
      alt: 18,
      pause: 19,
      caps_lock: 20,
      escape: 27,
      space: 32,
      page_up: 33,
      page_down: 34,
      end: 35,
      home: 36,
      left: 37,
      up: 38,
      right: 39,
      down: 40,
      printscreen: 44,
      insert: 45,
      "delete": 46,
      0: 48,
      1: 49,
      2: 50,
      3: 51,
      4: 52,
      5: 53,
      6: 54,
      7: 55,
      8: 56,
      9: 57,
      semicolon: 59,
      a: 65,
      b: 66,
      c: 67,
      d: 68,
      e: 69,
      f: 70,
      g: 71,
      h: 72,
      i: 73,
      j: 74,
      k: 75,
      l: 76,
      m: 77,
      n: 78,
      o: 79,
      p: 80,
      q: 81,
      r: 82,
      s: 83,
      t: 84,
      u: 85,
      v: 86,
      w: 87,
      x: 88,
      y: 89,
      z: 90,
      context_menu: 93,
      numpad0: 96,
      numpad1: 97,
      numpad2: 98,
      numpad3: 99,
      numpad4: 100,
      numpad5: 101,
      numpad6: 102,
      numpad7: 103,
      numpad8: 104,
      numpad9: 105,
      multiply: 106,
      add: 107,
      separator: 108,
      subtract: 109,
      decimal: 110,
      divide: 111,
      f1: 112,
      f2: 113,
      f3: 114,
      f4: 115,
      f5: 116,
      f6: 117,
      f7: 118,
      f8: 119,
      f9: 120,
      f10: 121,
      f11: 122,
      f12: 123,
      f13: 124,
      f14: 125,
      f15: 126,
      f16: 127,
      f17: 128,
      f18: 129,
      f19: 130,
      f20: 131,
      f21: 132,
      f22: 133,
      f23: 134,
      f24: 135,
      num_lock: 144,
      scroll_lock: 145,
      equals: 187,
      comma: 188,
      minus: 189,
      period: 190,
      slash: 191,
      back_quote: 192,
      open_bracket: 219,
      back_slash: 220,
      close_bracket: 221,
      quote: 222,
      meta: 224
    };
    KeyNames = {};
    for (k in KeyCodes) {
      v = KeyCodes[k];
      KeyNames[v] = k;
    }
    Make("KeyCodes", KeyCodes);
    return Make("KeyNames", KeyNames);
  })();

  Take(["Control", "KeyMe", "Reaction", "RAF", "Resize", "root", "SVG", "TopBar", "TRS", "Tween"], function(Control, KeyMe, Reaction, RAF, Resize, root, SVG, TopBar, TRS, Tween) {
    var accel, alreadyRan, base, cloneTouches, dblclick, decel, dist, distTo, distTouches, eventInside, getAccel, initialSize, maxVel, maxZoom, minVel, minZoom, ms, nav, pos, registrationOffset, render, rerun, resize, run, to, touchEnd, touchMove, touchStart, touches, vel, wheel, zoom;
    minVel = 0.1;
    maxVel = {
      xy: 10,
      z: 0.05
    };
    minZoom = 0;
    maxZoom = 3;
    accel = {
      xy: 0.7,
      z: 0.004
    };
    decel = {
      xy: 1.25,
      z: 1.001
    };
    vel = {
      a: 0,
      d: 0,
      z: 0
    };
    pos = {
      x: 0,
      y: 0,
      z: 0
    };
    registrationOffset = {
      x: 0,
      y: 0
    };
    base = {
      x: 0,
      y: 0,
      z: 0
    };
    ms = null;
    nav = null;
    zoom = null;
    initialSize = null;
    alreadyRan = false;
    Reaction("ScopeReady", function() {
      var mid;
      if (ms = root.mainStage) {
        nav = TRS(ms.element);
        mid = SVG.create("g", SVG.root);
        SVG.append(mid, nav.parentNode);
        zoom = TRS(mid);
        SVG.prepend(SVG.root, zoom.parentNode);
        initialSize = ms.element.getBoundingClientRect();
        registrationOffset.x = -ms.x + initialSize.left + initialSize.width / 2;
        registrationOffset.y = -ms.y + initialSize.top + initialSize.height / 2;
        TRS.abs(nav, {
          ox: registrationOffset.x,
          oy: registrationOffset.y
        });
        Resize(resize);
        KeyMe("up", {
          down: run
        });
        KeyMe("down", {
          down: run
        });
        KeyMe("left", {
          down: run
        });
        KeyMe("right", {
          down: run
        });
        KeyMe("equals", {
          down: run
        });
        KeyMe("minus", {
          down: run
        });
        window.addEventListener("touchstart", touchStart);
        window.addEventListener("dblclick", dblclick);
        window.addEventListener("wheel", wheel);
      }
      return Make("NavReady");
    });
    resize = function() {
      var hFrac, height, wFrac, width;
      width = window.innerWidth - Control.panelWidth;
      height = window.innerHeight - TopBar.height;
      wFrac = width / initialSize.width;
      hFrac = height / initialSize.height;
      base.x = width / 2;
      base.y = TopBar.height + height / 2;
      base.z = .9 * Math.min(wFrac, hFrac);
      TRS.abs(zoom, {
        x: base.x,
        y: base.y,
        scale: base.z
      });
      return run();
    };
    run = function() {
      var down, inputX, inputY, inputZ, left, minus, plus, right, up;
      if (alreadyRan) {
        return;
      }
      alreadyRan = true;
      RAF(rerun);
      left = KeyMe.pressing["left"];
      right = KeyMe.pressing["right"];
      up = KeyMe.pressing["up"];
      down = KeyMe.pressing["down"];
      minus = KeyMe.pressing["minus"];
      plus = KeyMe.pressing["equals"];
      inputX = getAccel(right, left);
      inputY = getAccel(down, up);
      inputZ = getAccel(minus, plus);
      if (inputZ === 0) {
        vel.z /= decel.z;
      }
      vel.z = Math.max(-maxVel.z, Math.min(maxVel.z, vel.z + accel.z * inputZ));
      pos.z += vel.z;
      pos.z = Math.min(maxZoom, Math.max(minZoom, pos.z));
      if (inputX === 0 && inputY === 0) {
        vel.d /= decel.xy;
      }
      if (inputY || inputX) {
        vel.a = Math.atan2(inputY, inputX);
      }
      vel.d = Math.min(maxVel.xy, vel.d + accel.xy * (Math.abs(inputX) + Math.abs(inputY)));
      pos.x += Math.cos(vel.a) * vel.d / (1 + pos.z);
      pos.y += Math.sin(vel.a) * vel.d / (1 + pos.z);
      return render();
    };
    rerun = function() {
      var p;
      alreadyRan = false;
      p = KeyMe.pressing;
      if (vel.d > minVel || vel.z > minVel || p["left"] || p["right"] || p["up"] || p["down"] || p["equals"] || p["minus"]) {
        return run();
      } else {
        return vel.d = vel.z = 0;
      }
    };
    render = function() {
      pos.z = Math.min(maxZoom, Math.max(minZoom, pos.z));
      TRS.abs(nav, {
        x: pos.x,
        y: pos.y
      });
      return TRS.abs(zoom, {
        scale: base.z * Math.pow(2, pos.z)
      });
    };
    getAccel = function(neg, pos) {
      if (neg && !pos) {
        return -1;
      }
      if (pos && !neg) {
        return 1;
      }
      return 0;
    };
    wheel = function(e) {
      if (!eventInside(e.clientX, e.clientY)) {
        return;
      }
      e.preventDefault();
      if (e.ctrlKey) {
        pos.z -= e.deltaY / 100;
      } else if (e.metaKey) {
        pos.z -= e.deltaY / 200;
      } else {
        pos.x -= e.deltaX / (base.z * Math.pow(2, pos.z));
        pos.y -= e.deltaY / (base.z * Math.pow(2, pos.z));
        pos.z -= e.deltaZ;
      }
      return RAF(render, true);
    };
    touches = null;
    touchStart = function(e) {
      if (!eventInside(e.touches[0].clientX, e.touches[0].clientY)) {
        return;
      }
      e.preventDefault();
      touches = cloneTouches(e);
      vel.d = vel.z = 0;
      window.addEventListener("touchmove", touchMove);
      return window.addEventListener("touchend", touchEnd);
    };
    touchMove = function(e) {
      var a, b;
      e.preventDefault();
      if (e.touches.length !== touches.length) {

      } else if (e.touches.length > 1) {
        a = distTouches(touches);
        b = distTouches(e.touches);
        pos.z += (b - a) / 200;
        pos.z = Math.min(maxZoom, Math.max(minZoom, pos.z));
      } else {
        pos.x += (e.touches[0].clientX - touches[0].clientX) / (base.z * Math.pow(2, pos.z));
        pos.y += (e.touches[0].clientY - touches[0].clientY) / (base.z * Math.pow(2, pos.z));
      }
      touches = cloneTouches(e);
      return RAF(render, true);
    };
    touchEnd = function(e) {
      if (touches.length <= 1) {
        window.removeEventListener("touchmove", touchMove);
        return window.removeEventListener("touchend", touchEnd);
      }
    };
    cloneTouches = function(e) {
      var len, m, ref, results, t;
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
    };
    dblclick = function(e) {
      if (eventInside(e.clientX, e.clientY)) {
        e.preventDefault();
        return to(0, 0, 0);
      }
    };
    to = function(x, y, z) {
      var target, time;
      target = {
        x: x != null ? x : pos.x,
        y: y != null ? y : pos.y,
        z: z != null ? z : pos.z
      };
      time = Math.sqrt(distTo(pos, target)) / 30;
      if (time > 0) {
        return Tween({
          on: pos,
          to: target,
          time: time,
          tick: render
        });
      }
    };
    distTouches = function(touches) {
      var a, b, dx, dy;
      a = touches[0];
      b = touches[1];
      dx = a.clientX - b.clientX;
      dy = a.clientY - b.clientY;
      return dist(dx, dy);
    };
    distTo = function(a, b) {
      var dx, dy, dz;
      dx = a.x - b.x;
      dy = a.y - b.y;
      dz = 200 * a.z - b.z;
      return dist(dx, dy, dz);
    };
    dist = function(x, y, z) {
      if (z == null) {
        z = 0;
      }
      return Math.sqrt(x * x + y * y + z * z);
    };
    return eventInside = function(x, y) {
      var insidePanel, insideTopBar, panelHidden;
      panelHidden = !Control.panelShowing;
      insidePanel = x < window.innerWidth - Control.panelWidth;
      insideTopBar = y > TopBar.height;
      return insideTopBar && (panelHidden || insidePanel);
    };
  });

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

  Take(["RAF"], function(RAF) {
    return Make("Resize", function(cb) {
      var r;
      (r = function() {
        return RAF(cb, true);
      })();
      return window.addEventListener("resize", r);
    });
  });

  Take(["PureDom", "Pressure", "SVG"], function(PureDom, Pressure, SVG) {
    var Style;
    return Make("Style", Style = function(scope) {
      var alpha, element, isLine, len, m, pressure, prop, ref, ref1, styleCache, t, text, textElement, visible;
      element = scope.element;
      styleCache = {};
      isLine = ((ref = element.getAttribute("id")) != null ? ref.indexOf("Line") : void 0) > -1;
      textElement = element.querySelector("text");
      if ((t = textElement != null ? textElement.querySelector("tspan") : void 0) != null) {
        textElement = t;
      }
      ref1 = ["pressure", "visible", "alpha", "stroke", "fill", "linearGradient", "radialGradient", "text", "style"];
      for (m = 0, len = ref1.length; m < len; m++) {
        prop = ref1[m];
        if (scope[prop] != null) {
          console.log("ERROR ############################################");
          console.log("scope:");
          console.log(scope);
          console.log("element:");
          console.log(element);
          throw "^ SVGA will overwrite @" + prop + " on this element. Please find a different name for your child/property named \"" + prop + "\".";
        }
      }
      scope.style = function(key, val) {
        if (styleCache[key] !== val) {
          styleCache[key] = val;
          return element.style[key] = val;
        }
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
      text = textElement != null ? textElement.textContent : void 0;
      Object.defineProperty(scope, 'text', {
        get: function() {
          return text;
        },
        set: function(val) {
          if ((textElement != null) && text !== val) {
            return textElement.textContent = text;
          }
        }
      });
      visible = true;
      Object.defineProperty(scope, 'visible', {
        get: function() {
          return visible;
        },
        set: function(val) {
          if (visible !== val) {
            visible = val;
            return element.style.opacity = visible ? alpha : 0;
          }
        }
      });
      alpha = 1;
      Object.defineProperty(scope, 'alpha', {
        get: function() {
          return alpha;
        },
        set: function(val) {
          if (alpha !== val) {
            alpha = val;
            return element.style.opacity = visible ? alpha : 0;
          }
        }
      });
      scope.stroke = function(color) {
        return SVG.attr(element, "stroke", color);
      };
      scope.fill = function(color) {
        var clone, defs, link, parent, path, use, useParent;
        path = element.querySelector("path");
        use = element.querySelector("use");
        if ((path == null) && (use != null)) {
          useParent = PureDom.querySelectorParent(use, "g");
          parent = PureDom.querySelectorParent(element, "svg");
          defs = parent.querySelector("defs");
          link = defs.querySelector(use.getAttribute("xlink:href"));
          clone = link.cloneNode(true);
          useParent.appendChild(clone);
          useParent.removeChild(use);
        }
        path = element.querySelector("path");
        if (path != null) {
          return path.setAttributeNS(null, "fill", color);
        }
      };
      scope.linearGradient = function(stops, x1, y1, x2, y2) {
        var fillUrl, gradient, gradientName, gradientStop, len1, n, stop, useParent;
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
        useParent = PureDom.querySelectorParent(element, "svg");
        gradientName = "Gradient_" + element.getAttributeNS(null, "id");
        gradient = useParent.querySelector("defs").querySelector("#" + gradientName);
        if (gradient == null) {
          gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient");
          useParent.querySelector("defs").appendChild(gradient);
        }
        gradient.setAttribute("id", gradientName);
        gradient.setAttributeNS(null, "x1", x1);
        gradient.setAttributeNS(null, "y1", y1);
        gradient.setAttributeNS(null, "x2", x2);
        gradient.setAttributeNS(null, "y2", y2);
        while (gradient.hasChildNodes()) {
          gradient.removeChild(gradient.firstChild);
        }
        for (n = 0, len1 = stops.length; n < len1; n++) {
          stop = stops[n];
          gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop");
          gradientStop.setAttribute("offset", stop.offset);
          gradientStop.setAttribute("stop-color", stop.color);
          gradient.appendChild(gradientStop);
        }
        fillUrl = "url(#" + gradientName + ")";
        return scope.fill(fillUrl);
      };
      scope.radialGradient = function(stops, cx, cy, radius) {
        var fillUrl, gradient, gradientName, gradientStop, len1, n, stop, useParent;
        useParent = PureDom.querySelectorParent(element, "svg");
        gradientName = "Gradient_" + element.getAttributeNS(null, "id");
        gradient = useParent.querySelector("defs").querySelector("#" + gradientName);
        if (gradient == null) {
          gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient");
          useParent.querySelector("defs").appendChild(gradient);
        }
        gradient.setAttribute("id", gradientName);
        if (cx != null) {
          gradient.setAttributeNS(null, "cx", cx);
        }
        if (cy != null) {
          gradient.setAttributeNS(null, "cy", cy);
        }
        if (radius != null) {
          gradient.setAttributeNS(null, "r", radius);
        }
        while (gradient.hasChildNodes()) {
          gradient.removeChild(gradient.firstChild);
        }
        for (n = 0, len1 = stops.length; n < len1; n++) {
          stop = stops[n];
          gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop");
          gradientStop.setAttribute("offset", stop.offset);
          gradientStop.setAttribute("stop-color", stop.color);
          gradient.appendChild(gradientStop);
        }
        fillUrl = "url(#" + gradientName + ")";
        return scope.fill(fillUrl);
      };
      scope.getPressure = function() {
        throw "@getPressure() has been removed. Please use @pressure instead.";
      };
      scope.setPressure = function() {
        throw "@setPressure(x) has been removed. Please use @pressure = x instead.";
      };
      scope.getPressureColor = function(pressure) {
        throw "@getPressureColor() has been removed. Please Take and use Pressure() instead.";
      };
      return scope.setText = function(text) {
        throw "@setText(x) has been removed. Please @text = x instead.";
      };
    });
  });

  Take([], function() {
    var SVG, SVGReady, SVGReadyForMutation, createStops, defs, props, root, svgNS, xlinkNS;
    root = document.rootElement;
    defs = root.querySelector("defs");
    svgNS = "http://www.w3.org/2000/svg";
    xlinkNS = "http://www.w3.org/1999/xlink";
    props = {
      textContent: true
    };
    SVGReady = false;
    SVG = {
      root: root,
      defs: defs,
      move: function(elm, x, y) {
        if (y == null) {
          y = 0;
        }
        throw "MOVE";
      },
      rotate: function(elm, r) {
        throw "ROTATE";
      },
      origin: function(elm, ox, oy) {
        throw "ORIGIN";
      },
      scale: function(elm, x, y) {
        if (y == null) {
          y = x;
        }
        throw "SCALE";
      },
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
        if (!SVGReadyForMutation()) {
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
        if (!SVGReadyForMutation()) {
          throw "SVG.append() called before SVGReady";
        }
        parent.appendChild(child);
        return child;
      },
      prepend: function(parent, child) {
        if (!SVGReadyForMutation()) {
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
        var ns;
        if (!elm) {
          throw "SVG.attr was called with a null element";
        }
        if (typeof k !== "string") {
          console.log(k);
          throw "SVG.attr requires a string as the second argument, got ^";
        }
        if (v === void 0) {
          return elm.getAttribute(k);
        }
        if (elm._SVG_attr == null) {
          elm._SVG_attr = {};
        }
        if (elm._SVG_attr[k] !== v) {
          elm._SVG_attr[k] = v;
          if (props[k] != null) {
            elm[k] = v;
          } else if (v != null) {
            ns = k === "xlink:href" ? xlinkNS : null;
            elm.setAttributeNS(ns, k, v);
          } else {
            ns = k === "xlink:href" ? xlinkNS : null;
            elm.removeAttributeNS(ns, k);
          }
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
      },
      grey: function(elm, l) {
        SVG.attr(elm, "fill", "hsl(0, 0%, " + (l * 100) + "%)");
        return elm;
      },
      hsl: function(elm, h, s, l) {
        SVG.attr(elm, "fill", "hsl(" + (h * 360) + ", " + (s * 100) + "%, " + (l * 100) + "%)");
        return elm;
      },
      createGradient: function() {
        var attrs, gradient, name, stops, vertical;
        name = arguments[0], vertical = arguments[1], stops = 3 <= arguments.length ? slice.call(arguments, 2) : [];
        attrs = vertical ? {
          id: name,
          x2: 0,
          y2: 1
        } : {
          id: name
        };
        gradient = SVG.create("linearGradient", defs, attrs);
        createStops(gradient, stops);
        return gradient;
      },
      createRadialGradient: function() {
        var gradient, name, stops;
        name = arguments[0], stops = 2 <= arguments.length ? slice.call(arguments, 1) : [];
        gradient = SVG.create("radialGradient", defs, {
          id: name
        });
        createStops(gradient, stops);
        return gradient;
      },
      createColorMatrixFilter: function(name, values) {
        var filter;
        filter = SVG.create("filter", defs, {
          id: name
        });
        SVG.create("feColorMatrix", filter, {
          "in": "SourceGraphic",
          type: "matrix",
          values: values
        });
        return filter;
      }
    };
    createStops = function(gradient, stops) {
      var attrs, i, len, m, stop;
      stops = stops[0] instanceof Array ? stops[0] : stops;
      for (i = m = 0, len = stops.length; m < len; i = ++m) {
        stop = stops[i];
        attrs = typeof stop === "string" ? {
          "stop-color": stop,
          offset: (100 * i / (stops.length - 1)) + "%"
        } : {
          "stop-color": stop.color,
          offset: (100 * stop.offset) + "%"
        };
        SVG.create("stop", gradient, attrs);
      }
      return null;
    };
    SVGReadyForMutation = function() {
      return SVGReady || (SVGReady = Take("SVGReady"));
    };
    return Make("SVG", SVG);
  });

  (function() {
    var Symbol, byInstanceName, bySymbolName, tooLate;
    bySymbolName = {};
    byInstanceName = {};
    tooLate = false;
    Symbol = function(symbolName, instanceNames, symbolFn) {
      var instanceName, len, m, results, symbol;
      if (bySymbolName[symbolName] != null) {
        throw "The symbol \"" + symbolName + "\" is defined more than once. You'll need to change one of the definitions to use a more unique name.";
      }
      if (tooLate) {
        throw "The symbol \"" + symbolName + "\" arrived after setup started. Please figure out a way to make it initialize faster.";
      }
      symbol = {
        create: symbolFn,
        name: symbolName
      };
      bySymbolName[symbolName] = symbol;
      results = [];
      for (m = 0, len = instanceNames.length; m < len; m++) {
        instanceName = instanceNames[m];
        if (byInstanceName[instanceName] != null) {
          throw "The instance \"" + instanceName + "\" is defined more than once, by Symbol \"" + byInstanceName[instanceName].symbolName + "\" and Symbol \"" + symbolName + "\". You'll need to change one of these instances to use a more unique name. You might need to change your FLA. This is a shortcoming of SVGA — sorry!";
        }
        results.push(byInstanceName[instanceName] = symbol);
      }
      return results;
    };
    Symbol.forSymbolName = function(symbolName) {
      tooLate = true;
      return bySymbolName[symbolName];
    };
    Symbol.forInstanceName = function(instanceName) {
      tooLate = true;
      return byInstanceName[instanceName];
    };
    return Make("Symbol", Symbol);
  })();

  Take("RAF", function(RAF) {
    var callbacks, tick, time;
    callbacks = [];
    time = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
    RAF(tick = function(t) {
      var cb, dt, len, m;
      dt = t / 1000 - time;
      time += dt;
      for (m = 0, len = callbacks.length; m < len; m++) {
        cb = callbacks[m];
        cb(time, dt);
      }
      return RAF(tick);
    });
    return Make("Tick", function(cb) {
      callbacks.push(cb);
      return cb;
    });
  });

  Take(["RAF", "DOMContentLoaded"], function(RAF) {
    var Transform;
    return Make("Transform", Transform = function(scope) {
      var applyTransform, denom, element, len, m, matrix, prop, ref, ref1, rotation, scaleX, scaleY, t, transform, transformBaseVal, x, y;
      element = scope.element;
      transformBaseVal = (ref = element.transform) != null ? ref.baseVal : void 0;
      transform = document.rootElement.createSVGTransform();
      matrix = document.rootElement.createSVGMatrix();
      x = 0;
      y = 0;
      rotation = 0;
      scaleX = 1;
      scaleY = 1;
      ref1 = ["x", "y", "rotation", "scale", "scaleX", "scaleY"];
      for (m = 0, len = ref1.length; m < len; m++) {
        prop = ref1[m];
        if (scope[prop] != null) {
          console.log(element);
          throw "^ Transform will clobber @" + prop + " on this element. Please find a different name for your child/property \"" + prop + "\".";
        }
      }
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
      Object.defineProperty(scope, 'scaleY', {
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
      Object.defineProperty(scope, 'cx', {
        get: function() {
          throw "cx has been removed from the SVGA Transform system.";
        },
        set: function() {
          throw "cx has been removed from the SVGA Transform system.";
        }
      });
      Object.defineProperty(scope, 'cy', {
        get: function() {
          throw "cy has been removed from the SVGA Transform system.";
        },
        set: function() {
          throw "cy has been removed from the SVGA Transform system.";
        }
      });
      Object.defineProperty(scope, 'angle', {
        get: function() {
          throw "angle has been removed from the SVGA Transform system. Please use @rotation instead.";
        },
        set: function() {
          throw "angle has been removed from the SVGA Transform system. Please use @rotation instead.";
        }
      });
      Object.defineProperty(scope, 'turns', {
        get: function() {
          throw "turns has been removed from the SVGA Transform system. Please use @rotation instead.";
        },
        set: function() {
          throw "turns has been removed from the SVGA Transform system. Please use @rotation instead.";
        }
      });
      return Object.defineProperty(scope, "transform", {
        get: function() {
          throw "@transform has been removed. You can just delete the \"transform.\" and things should work.";
        }
      });
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
      if (elm.parentNode == null) {
        console.log(elm);
        throw "^ Element passed to TRS(elm) must have a parentNode";
      }
      wrapper = SVG.create("g", elm.parentNode, {
        "class": "TRS"
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
        err(elm, "Non-TRS element passed to TRS.abs(elm, attrs)");
      }
      if (attrs == null) {
        err(elm, "Null attrs passed to TRS.abs(elm, attrs)");
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
        err(elm, "Non-TRS element passed to TRS.abs(elm, attrs)");
      }
      if (attrs == null) {
        err(elm, "Null attrs passed to TRS.abs(elm, attrs)");
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
        err(elm, "Non-TRS element passed to TRS.move");
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
        err(elm, "Non-TRS element passed to TRS.rotate");
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
        err(elm, "Non-TRS element passed to TRS.scale");
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
        err(elm, "Non-TRS element passed to TRS.origin");
      }
      return TRS.abs(elm, {
        ox: ox,
        oy: oy
      });
    };
    return Make("TRS", TRS);
  });

  Take(["Ease", "RAF"], function(Ease, RAF) {
    var Tween, cloneObj, diffObj, tweens, update, updateTween;
    tweens = [];
    Tween = function(tween) {
      if (tween.on == null) {
        tween.on = cloneObj(tween.from);
      }
      if (tween.from == null) {
        tween.from = cloneObj(tween.on);
      }
      tween.delta = diffObj(tween.to, tween.from);
      tweens.push(tween);
      RAF(update, true);
      return tween;
    };
    Tween.cancel = function(tween) {
      return tween != null ? tween.cancelled = true : void 0;
    };
    update = function(t) {
      var tween;
      tweens = ((function() {
        var len, m, results;
        results = [];
        for (m = 0, len = tweens.length; m < len; m++) {
          tween = tweens[m];
          results.push(updateTween(tween, t / 1000));
        }
        return results;
      })()).filter(function(t) {
        return t != null;
      });
      if (tweens.length > 0) {
        return RAF(update, true);
      }
    };
    updateTween = function(tween, time) {
      var k, pos, ref, v;
      if (tween.started == null) {
        tween.started = time;
      }
      pos = Math.min(1, (time - tween.started) / tween.time);
      ref = tween.delta;
      for (k in ref) {
        v = ref[k];
        tween.on[k] = v * Ease.cubic(pos) + tween.from[k];
      }
      if (typeof tween.tick === "function") {
        tween.tick(pos, tween);
      }
      if (pos < 1 && !tween.cancelled) {
        return tween;
      }
    };
    cloneObj = function(obj) {
      var k, out, v;
      out = {};
      for (k in obj) {
        v = obj[k];
        out[k] = obj[k];
      }
      return out;
    };
    diffObj = function(a, b) {
      var diff, k, v;
      diff = {};
      for (k in a) {
        v = a[k];
        diff[k] = a[k] - b[k];
      }
      return diff;
    };
    return Make("Tween", Tween);
  });

  Take(["Ease", "Tick"], function(Ease, Tick) {
    var Tween1, gc, tweens;
    tweens = [];
    Tween1 = function(from, to, time, tick, next) {
      var tween;
      gc(tick);
      tweens = tweens.filter(function(tween) {
        if (tween.pos >= 1) {
          return false;
        }
        if (tween.cancelled) {
          return false;
        }
        if (tween.tick === tick) {
          return false;
        }
        if (tween === next) {
          return false;
        }
        return true;
      });
      tweens.push(tween = {
        from: from,
        to: to,
        time: time,
        tick: tick,
        cancelled: false,
        pos: 0,
        value: from,
        delta: to - from,
        next: next
      });
      return tween;
    };
    Tick(function(t, dt) {
      var len, m, results, tween;
      results = [];
      for (m = 0, len = tweens.length; m < len; m++) {
        tween = tweens[m];
        if (!tween.cancelled) {
          if (tween.pos < 1) {
            tween.pos += dt / tween.time;
            tween.value = tween.from + tween.delta * Ease.cubic(Math.min(1, tween.pos));
            results.push(tween.tick(tween.value, tween));
          } else if (tween.next != null) {
            tweens.push(tween.next);
            results.push(tween.next = null);
          } else {
            results.push(void 0);
          }
        }
      }
      return results;
    });
    gc = function() {
      var ticks;
      ticks = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return tweens = tweens.filter(function(tween) {
        var ref;
        if (tween.pos >= 1) {
          return false;
        }
        if (tween.cancelled) {
          return false;
        }
        if (ref = tween.tick, indexOf.call(ticks, ref) >= 0) {
          return false;
        }
        return true;
      });
    };
    Tween1.cancel = gc;
    return Make("Tween1", Tween1);
  });

  Take(["Action", "Reaction", "root"], function(Action, Reaction, root) {
    var showing;
    showing = false;
    Reaction("ScopeReady", function() {
      return Action("FlowArrows:Show");
    });
    Reaction("FlowArrows:Toggle", function() {
      return Action(showing ? "FlowArrows:Show" : "FlowArrows:Hide");
    });
    Reaction("FlowArrows:Hide", function() {
      return showing = true;
    });
    return Reaction("FlowArrows:Show", function() {
      return showing = false;
    });
  });

  Take(["Action", "Dispatch", "Reaction", "SVGReady"], function(Action, Dispatch, Reaction) {
    var colors, current, setColor;
    colors = ["#666", "#bbb", "#fff"];
    current = 1;
    setColor = function(index) {
      return document.rootElement.style["background-color"] = colors[index % colors.length];
    };
    Reaction("setup", function() {
      return setColor(1);
    });
    return Reaction("cycleBackgroundColor", function() {
      return setColor(++current);
    });
  });

  Take(["Action", "Reaction", "root"], function(Action, Reaction, root) {
    var labels, ref;
    if (!(labels = (ref = root.mainStage) != null ? ref.labelsContainer : void 0)) {
      return;
    }
    Reaction("Labels:Hide", function() {
      return labels.visible = false;
    });
    Reaction("Labels:Show", function() {
      return labels.visible = true;
    });
    return Reaction("Labels:Toggle", function() {
      return Action(labels.visible ? "Labels:Hide" : "Labels:Show");
    });
  });

  Take(["Action", "Dispatch", "Reaction", "root"], function(Action, Dispatch, Reaction, root) {
    var animateMode;
    animateMode = false;
    Reaction("ScopeReady", function() {
      return Action("Schematic:Show");
    });
    Reaction("Schematic:Toggle", function() {
      return Action(animateMode ? "Schematic:Show" : "Schematic:Hide");
    });
    Reaction("Schematic:Hide", function() {
      animateMode = true;
      return Dispatch(root, "animateMode");
    });
    return Reaction("Schematic:Show", function() {
      animateMode = false;
      return Dispatch(root, "schematicMode");
    });
  });

  Take(["Dispatch", "Reaction", "root"], function(Dispatch, Reaction, root) {
    return Reaction("setup", function() {
      return Dispatch(root, "setup");
    });
  });

  Take(["Reaction", "ScopeBuilder", "Tick"], function(Reaction, ScopeBuilder, Tick) {
    return ScopeBuilder.process(function(scope) {
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
        return animate.call(scope, dt, time - startTime);
      });
      Reaction("Schematic:Hide", function() {
        startTime = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
        return running = true;
      });
      return Reaction("Schematic:Show", function() {
        return running = false;
      });
    });
  });

  Take(["ScopeBuilder", "Tick"], function(ScopeBuilder, Tick) {
    return ScopeBuilder.process(function(scope) {
      var running, startTime, update;
      if (scope.update == null) {
        return;
      }
      running = false;
      startTime = null;
      update = scope.update;
      scope.update = function() {
        throw "@update() is called by the system. Please don't call it yourself.";
      };
      Tick(function(time, dt) {
        if (!running) {
          return;
        }
        return update.call(scope, dt, time - startTime);
      });
      scope.update.start = function() {
        if (startTime == null) {
          startTime = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
        }
        return running = true;
      };
      scope.update.stop = function() {
        return running = false;
      };
      scope.update.toggle = function() {
        if (running) {
          return scope.update.stop();
        } else {
          return scope.update.start();
        }
      };
      return scope.update.restart = function() {
        return startTime = null;
      };
    });
  });

}).call(this);
