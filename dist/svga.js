(function() {
  var Storage,
    indexOf = [].indexOf;

  Take(["Registry", "Scene", "SVG", "ParentData"], function(Registry, Scene, SVG) {
    var checkBounds, svgData;
    // We don't use ParentData, but we need it to exist before we can safely continue

    // This is the very first code that changes the DOM. It crawls the entire DOM and:
    // 1. Makes structural changes to prepare things for animation.
    // 2. Returns a tree of DOM references that we'll link Symbols to.
    svgData = Scene.crawl(SVG.root);
    // We're done the initial traversal of the SVG. It's now safe for systems to mutate it.
    Make("SVGReady");
    // We need to wait a bit for ScopeProcessors
    setTimeout(function() {
      // By now, we're assuming all ScopeProcessors are ready.
      Registry.closeRegistration("ScopeProcessor");
      // Inform all systems that it's now safe to use Scope.
      Make("ScopeReady");
      // By now, we're assuming all Controls are ready.
      Registry.closeRegistration("Control");
      // Inform all systems that we've just finished setting up Controls.
      Make("ControlReady");
      // We need to wait a bit for Symbols
      return setTimeout(function() {
        // By now, we're assuming all Symbols are ready.
        Registry.closeRegistration("Symbols");
        Registry.closeRegistration("SymbolNames");
        // Use the DOM references collected earlier to build our Scene tree.
        Scene.build(svgData);
        svgData = null; // Free this memory
        
        // We also need to wait until we're properly displayed on screen.
        return checkBounds();
      });
    });
    return checkBounds = function() {
      var initialRootRect;
      // If we don't do this check, we can get divide by zero errors in Nav.
      // The root bounds will be zero if the export from Flash was bad, or if this SVGA is loaded in Chrome with display: none.
      initialRootRect = SVG.root.getBoundingClientRect();
      if (initialRootRect.width < 1 || initialRootRect.height < 1) {
        return setTimeout(checkBounds, 500); // Keep re-checking until whatever loaded this SVGA is ready to display it.
      } else {
        // Inform all systems that we've just finished setting up the scene.
        Make("SceneReady");
        // Inform all systems that bloody everything is done.
        return Make("AllReady");
      }
    };
  });

  // This system is mainly in charge of crawling the DOM, doing some initial cleanup,
  // and building a tree of important elements for animation.
  Take(["Mode", "Scope", "SVG", "Symbol"], function(Mode, Scope, SVG, Symbol) {
    var Scene, buildScopes, cleanupIds, defs, deprecations, masks, processElm, removeUselessLayers;
    deprecations = ["controlPanel", "ctrlPanel", "navOverlay"];
    masks = [];
    defs = {};
    Make("Scene", Scene = {
      crawl: function(elm) {
        var tree;
        cleanupIds(elm);
        tree = processElm(elm);
        if (masks.length) {
          console.log("Please remove these mask elements from your SVG:", ...masks);
        }
        masks = null; // Avoid dangling references
        defs = null; // Avoid dangling references
        return tree;
      },
      build: function(tree) {
        var m, setup, setups;
        buildScopes(tree, setups = []);
// loop backwards, to set up children before parents
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
      // By default, elements with an ID are added to the window object.
      // For the sake of better typo handling, we replace those references with a proxy.
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
    removeUselessLayers = function(containerElm) {
      var childElm, isGroup, isUselessLayer, layerSuspect, layerSuspects, len, len1, m, n, ref, ref1, results;
      // In recent versions of Adobe Animate, groups are sometimes created to house layer contents,
      // where previous versions wouldn't do this. This creates a weird mismatch between new and old code.
      // To work around this, we detect these extra layer elements, and remove them before building
      // the scope tree.
      layerSuspects = Array.prototype.slice.call(containerElm.childNodes);
      results = [];
      for (m = 0, len = layerSuspects.length; m < len; m++) {
        layerSuspect = layerSuspects[m];
        isGroup = layerSuspect instanceof SVGGElement;
        isUselessLayer = ((ref = layerSuspect.id) != null ? ref.search(/L_\d+/) : void 0) >= 0;
        if (isGroup && isUselessLayer) {
          ref1 = Array.prototype.slice.call(layerSuspect.childNodes);
          for (n = 0, len1 = ref1.length; n < len1; n++) {
            childElm = ref1[n];
            containerElm.insertBefore(childElm, layerSuspect);
          }
          results.push(containerElm.removeChild(layerSuspect));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    processElm = function(elm) {
      var childElm, childNodes, clone, def, defId, len, m, ref, ref1, tree;
      tree = {
        elm: elm,
        sub: []
      };
      removeUselessLayers(elm);
      childNodes = Array.prototype.slice.call(elm.childNodes);
      for (m = 0, len = childNodes.length; m < len; m++) {
        childElm = childNodes[m];
        if ((ref = childElm.id, indexOf.call(deprecations, ref) >= 0)) {
          console.log(`#${childElm.id} is obsolete. Please remove it from your FLA and re-export this SVG.`);
          elm.removeChild(childElm);
        // clipPath masks are generated by Flash to wrap text, for some reason
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
          // We make a clone of the use'd element in defs, so that we can reach in and change (eg) strokes/fills.
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
    // BUILD SCOPES ##################################################################################
    return buildScopes = function(tree, setups, parentScope = null) {
      var baseName, len, m, props, ref, ref1, scope, subTarget, symbol;
      props = {
        parent: parentScope
      };
      if (tree.elm.id.replace(/_FL/g, "").length > 0) {
        props.id = tree.elm.id.replace(/_FL/g, "");
      }
      // This is a bit of a legacy hack, where symbols are given names in Flash so that our code can hook up with them.
      baseName = (ref = tree.elm.id) != null ? ref.split("_")[0] : void 0;
      symbol = baseName.indexOf("Line") > -1 || baseName.indexOf("line") === 0 ? Symbol.forSymbolName("HydraulicLine") : baseName.indexOf("Field") > -1 || baseName.indexOf("field") === 0 ? Symbol.forSymbolName("HydraulicField") : baseName.indexOf("BackgroundCover") > -1 ? Symbol.forSymbolName("BackgroundCover") : props.id != null ? Symbol.forInstanceName(props.id) : void 0;
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
    findParent = function(element) {
      while (element != null) {
        if (element._scope != null) {
          return element._scope;
        }
        element = element.parentNode;
      }
      return null;
    };
    return Make("Scope", Scope = function(element, symbol, props = {}) {
      var attr, attrs, len, len1, m, n, parentScope, ref, scope, scopeProcessor;
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
      // Private APIs
      element._scope = scope;
      scope._symbol = symbol;
      // Public APIs
      scope.children = [];
      scope.element = element;
      scope.root = Scope.root != null ? Scope.root : Scope.root = scope; // It is assumed that the very first scope created is the root scope.
      scope.id = props.id;
      // Set up parent-child relationship
      if (parentScope != null) {
        parentScope.attachScope(scope);
      }
      // Add some info to help devs locate scope elements in the DOM
      if (!(navigator.userAgent.indexOf("Edge") >= 0)) {
        // Add some helpful dev names to the element
        element.setAttribute("SCOPE", scope.id || "");
        if ((symbol != null ? symbol.symbolName : void 0) != null) {
          element.setAttribute("SYMBOL", symbol.symbolName);
        }
        attrs = Array.prototype.slice.call(element.attributes);
// Sort attrs so that dev names come first
        for (m = 0, len = attrs.length; m < len; m++) {
          attr = attrs[m];
          if (!(attr.name !== "SCOPE" && attr.name !== "SYMBOL")) {
            continue;
          }
          element.removeAttributeNS(attr.namespaceURI, attr.name);
          element.setAttributeNS(attr.namespaceURI, attr.name, attr.value);
        }
      }
      ref = Registry.all("ScopeProcessor");
      for (n = 0, len1 = ref.length; n < len1; n++) {
        scopeProcessor = ref[n];
        // Forcing a reflow fixes an IE bug — disabled, not deleted, until we can verify this doesn't affect Edge
        // window.getComputedStyle element

        // Run this scope through all the processors, which add special properties, callbacks, and other fanciness
        scopeProcessor(scope, props);
      }
      return scope;
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
          // if Config.SPACING < 30 * parentScale then throw new Error "Your flow arrows are overlapping. What the devil are you trying? You need to convince Ivan that what you are doing is okay."
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
    defineProp = function(obj, k) {
      return Object.defineProperty(obj, k, {
        get: function() {
          return Config[k];
        },
        set: function(v) {
          return Config[k] = v;
        }
      });
    };
    return Make("FlowArrows:Config", Config = {
      SCALE: 0.5, // Visible size of arrows is multiplied by this value — it's not factored in to any of the other size/distance/speed values
      SPACING: 600, // APPROXIMATELY how far apart should arrows be spaced? (+/-)50%
      FADE_LENGTH: 50, // Over how great a distance do Arrows fade in/out?
      MIN_SEGMENT_LENGTH: 200, // How long must a segment be before we put arrows on it?
      SPEED: 200, // The speed Arrows move per second when flow is 1
      MIN_EDGE_LENGTH: 8, // How long must an edge be to survive being culled?
      CONNECTED_DISTANCE: 1, // How close must two physically-disconnected points be to be treated as part of the same line?
      wrap: function(obj) {
        var k;
        for (k in Config) {
          if (k !== "wrap") {
            defineProp(obj, k);
          }
        }
        return obj; // Composable
      }
    });
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
      
      // This is used by FlowArrows when toggling
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
    var enableAll, sets, visible;
    sets = [];
    visible = true; // Default to true, in case we don't have an arrows button
    enableAll = function() {
      var len, m, set;
      for (m = 0, len = sets.length; m < len; m++) {
        set = sets[m];
        set.enabled = visible;
      }
      return void 0;
    };
    Tick(function(time, dt) {
      var f, len, m, s, set;
      if (visible) {
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
    Reaction("FlowArrows:Show", function() {
      return enableAll(visible = true);
    });
    Reaction("FlowArrows:Hide", function() {
      return enableAll(visible = false);
    });
    return Make("FlowArrows", Config.wrap(function(parentScope, ...lineData) {
      var elm, set, setData;
      if (parentScope == null) {
        console.log(lineData);
        throw new Error("FlowArrows was called with a null target. ^^^ was the baked line data.");
      }
      elm = parentScope.element;
      // This removes invisible lines (which have a child named markerBox)
      if (elm.querySelector("[id^=markerBox]")) { // ^= matches values by prefix, so we can match IDs like markerBox_FL
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

  Take(["FlowArrows:Config", "Vec"], function(Config, Vec) {
    var cullInlinePoints, cullShortEdges, cullShortSegments, formSegments, isConnected, isInline, joinSegments, log, reifySegments, reifyVectors, wrap;
    // PROCESSING STEPS ##############################################################################
    log = function(a) {
      console.dir(a);
      return a;
    };
    formSegments = function(lineData) {
      var i, m, pointA, pointB, ref, segmentEdges, segments;
      segments = []; // array of segments
      segmentEdges = null; // array of edges in the current segment

      // loop in pairs, since lineData is alternating start/end points of edges
      for (i = m = 0, ref = lineData.length; m < ref; i = m += 2) {
        pointA = lineData[i];
        pointB = lineData[i + 1];
        // if we're already making a segment, and the new edge is a continuation of the last edge
        if ((segmentEdges != null) && isConnected(pointA, segmentEdges[segmentEdges.length - 1])) {
          segmentEdges.push(pointB); // this edge is a continuation of the last edge
        } else if ((segmentEdges != null) && isConnected(pointB, segmentEdges[segmentEdges.length - 1])) {
          segmentEdges.push(pointA); // this edge is a continuation of the last edge
        
        // if we're already making a segment, and the new edge comes before the first edge
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointB)) {
          segmentEdges.unshift(pointA); // the first edge is a continuation of this edge
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointA)) {
          segmentEdges.unshift(pointB); // the first edge is a continuation of this edge
        } else {
          
          // we're not yet making a segment, or the new edge isn't connected to the current segment
          segments.push(segmentEdges = [
            pointA,
            pointB // this edge is for a new segment
          ]);
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
            // they're connected startA-to-startB, so flip B and merge B->A
            segB.reverse();
            segB.pop();
            segments[i] = segB.concat(segA);
            segments.splice(j, 1);
            continue;
          }
          // test the two segment ends
          pointA = segA[segA.length - 1];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB)) {
            // they're connected endA-to-endB, so flip B and merge A->B
            segB.reverse();
            segB.unshift();
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          // test endA-to-startB
          pointA = segA[segA.length - 1];
          pointB = segB[0];
          if (isConnected(pointA, pointB)) {
            // they're connected endA-to-startB, so merge A->B
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          // test startA-to-endB
          pointA = segA[0];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB)) {
            // they're connected startA-to-endB, so merge B->A
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
          if (Vec.distance(pointA, pointB) < Config.MIN_EDGE_LENGTH) {
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
      // find all points that are inline with the points on either side of it, and cull them
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
                dist: Vec.distance(pointA, pointB),
                angle: Vec.angle(pointA, pointB)
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
    // HELPERS #######################################################################################
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
    // MAIN ##########################################################################################
    return Make("FlowArrows:Process", function(lineData) {
      return wrap(lineData).process(formSegments).process(joinSegments).process(cullShortEdges).process(cullInlinePoints).process(reifyVectors).process(reifySegments).process(cullShortSegments).result; // Wrap our data into a format suitable for the below processing pipeline // organize the points into an array of segment groups // combine segments that are visibly connected but whose points were listed in the wrong order // remove points that constitute an unusably short edge // remove points that lie on a line // create vectors with a position, dist, and angle // create segments with a dist and edges // remove vectors that are unusably short // return the result after all the above processing steps
    });
  });

  Take(["FlowArrows:Arrow", "FlowArrows:Config", "FlowArrows:Containerize", "Mode"], function(Arrow, Config, Containerize, Mode) {
    return Make("FlowArrows:Segment", function(parentElm, segmentData, segmentName, topElm) {
      return Containerize(parentElm, function(scope) { // This function must return an array of children
        var arrow, arrowCount, i, m, ref, results, segmentPosition, segmentSpacing, vector, vectorIndex, vectorPosition;
        if (Mode.dev) {
          scope.element.addEventListener("mouseover", function() {
            var counter, currentElm, ids;
            ids = [];
            currentElm = topElm;
            counter = 0;
            while ((currentElm != null) && currentElm.id !== "root") {
              counter++;
              if (currentElm.id != null) {
                ids.unshift(currentElm.id);
              }
              currentElm = currentElm.parentElement;
              if (counter > 50) {
                throw "FlowArrows:Segment while loop counter overflow — tell Ivan";
              }
            }
            return console.log(`${segmentName} in the arrows for @${ids.join('.')}`);
          });
        }
        arrowCount = Math.max(1, Math.round(segmentData.dist / Config.SPACING));
        segmentSpacing = segmentData.dist / arrowCount;
        segmentPosition = 0;
        vectorPosition = 0;
        vectorIndex = 0;
        vector = segmentData.vectors[vectorIndex];
        results = [];
        for (i = m = 0, ref = arrowCount; (0 <= ref ? m < ref : m > ref); i = 0 <= ref ? ++m : --m) {
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
      return Containerize(parentElm, function(scope) { // This function must return an array of children
        var child, childName, i, len, m, results, segmentData;
        results = [];
        for (i = m = 0, len = setData.length; m < len; i = ++m) {
          segmentData = setData[i];
          if (segmentData.dist < Config.FADE_LENGTH * 2) {
            throw new Error(`You have a FlowArrows segment that is only ${Math.round(segmentData.dist)} units long, which is clashing with your fade length of ${Config.FADE_LENGTH} units. Please don't set MIN_SEGMENT_LENGTH less than FADE_LENGTH * 2.`);
          }
          childName = "segment" + i;
          child = Segment(scope.element, segmentData, childName, parentElm);
          results.push(scope[childName] = child);
        }
        return results;
      });
    });
  });

  Take(["Action", "Ease", "Reaction", "SVG"], function(Action, Ease, Reaction, SVG) {
    Reaction("Background:Set", function(v) {
      SVG.style(document.body, "background-color", v);
      // We need to give the SVG element a background color,
      // or else the background will be black when fullscreen
      return SVG.style(SVG.svg, "background-color", v);
    });
    return Reaction("Background:Lightness", function(v) {
      var hue;
      hue = Ease.linear(v, 0, 1, 227, 218);
      return Action("Background:Set", `hsl(${hue}, 5%, ${v * 100 | 0}%)`);
    });
  });

  Take(["GUI", "Mode", "Resize", "SVG", "TRS", "SVGReady"], function(GUI, Mode, Resize, SVG, TRS) {
    var g, hide, show;
    return;
    // We're just going to disable this for now,
    // since keyboard input is not well-known
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
    return window.focus(); // Focus by default
  });

  Take(["ControlPanelLayout", "Gradient", "GUI", "SVG", "Scope", "TRS", "ControlReady"], function(ControlPanelLayout, Gradient, GUI, SVG, Scope, TRS, ControlReady) {
    var CP, ControlPanel, columnElms, columnsElm, getColumnElm, groups, panelBg, panelElm, showing;
    // Aliases
    CP = GUI.ControlPanel;
    // State
    showing = false;
    groups = [];
    columnElms = [];
    // Elements
    panelElm = SVG.create("g", GUI.elm, {
      xControls: "",
      fontSize: 16,
      textAnchor: "middle"
    });
    panelBg = SVG.create("rect", panelElm, {
      xPanelBg: "",
      rx: CP.panelBorderRadius,
      fill: GUI.Colors.bg.l
    });
    columnsElm = SVG.create("g", panelElm, {
      xColumns: "",
      transform: `translate(${CP.panelPadding},${CP.panelPadding})`
    });
    getColumnElm = function(index) {
      return columnElms[index] != null ? columnElms[index] : columnElms[index] = SVG.create("g", columnsElm);
    };
    Take("SceneReady", function() {
      if (!showing) {
        // It'd be simpler to just not add the CP unless we need it,
        // rather than what we're doing here (remove it if it's unused).
        // But we need to do it this way to avoid an IE bug.
        return GUI.elm.removeChild(panelElm);
      }
    });
    return Make("ControlPanel", ControlPanel = Scope(panelElm, function() {
      return {
        registerGroup: function(group) {
          return groups.push(group);
        },
        createItemElement: function(parent) {
          showing = true;
          return SVG.create("g", parent);
        },
        computeLayout: function(vertical, totalAvailableSpace) {
          var consumedSpace, innerPanelSize, layout, marginedSpace, outerPanelSize, panelInfo, scale;
          marginedSpace = {
            w: totalAvailableSpace.w - CP.panelMargin * 2,
            h: totalAvailableSpace.h - CP.panelMargin * 2
          };
          [innerPanelSize, layout] = vertical ? ControlPanelLayout.vertical(groups, marginedSpace) : ControlPanelLayout.horizontal(groups, marginedSpace);
          // If the panel is still way the hell too big, scale down
          scale = vertical && (innerPanelSize.w > marginedSpace.w / 2 || innerPanelSize.h > marginedSpace.h) ? Math.max(0.8, Math.min(marginedSpace.w / innerPanelSize.w / 2, marginedSpace.h / innerPanelSize.h)) : !vertical && (innerPanelSize.w > marginedSpace.w || innerPanelSize.h > marginedSpace.h / 2) ? Math.max(0.8, Math.min(marginedSpace.w / innerPanelSize.w, marginedSpace.h / innerPanelSize.h / 2)) : 1;
          outerPanelSize = {
            w: innerPanelSize.w * scale + CP.panelMargin * 2,
            h: innerPanelSize.h * scale + CP.panelMargin * 2
          };
          // How much of the available content space does the panel use up?
          consumedSpace = {
            w: 0,
            h: 0
          };
          if (showing && vertical) {
            consumedSpace.w = outerPanelSize.w;
          }
          if (showing && !vertical) {
            consumedSpace.h = outerPanelSize.h;
          }
          return panelInfo = {
            showing: showing,
            vertical: vertical,
            consumedSpace: consumedSpace,
            innerPanelSize: innerPanelSize,
            outerPanelSize: outerPanelSize,
            scale: scale,
            layout: layout
          };
        },
        applyLayout: function(resizeInfo, totalAvailableSpace) {
          if (!resizeInfo.panelInfo.showing) {
            return;
          }
          // Now that we know which layout we're using, apply it to the SVG
          ControlPanelLayout.applyLayout(resizeInfo.panelInfo.layout, getColumnElm);
          if (resizeInfo.panelInfo.vertical) {
            ControlPanel.x = Math.round(totalAvailableSpace.w - resizeInfo.panelInfo.outerPanelSize.w + CP.panelMargin);
            ControlPanel.y = Math.round(totalAvailableSpace.h / 2 - resizeInfo.panelInfo.outerPanelSize.h / 2 + CP.panelMargin);
          } else {
            ControlPanel.x = Math.round(totalAvailableSpace.w / 2 - resizeInfo.panelInfo.outerPanelSize.w / 2 + CP.panelMargin);
            ControlPanel.y = Math.round(totalAvailableSpace.h - resizeInfo.panelInfo.outerPanelSize.h + CP.panelMargin);
          }
          ControlPanel.scale = resizeInfo.panelInfo.scale;
          // Apply the final size to our background elm
          return SVG.attrs(panelBg, {
            width: resizeInfo.panelInfo.innerPanelSize.w,
            height: resizeInfo.panelInfo.innerPanelSize.h
          });
        }
      };
    }));
  });

  Take(["GUI", "Mode", "SVG"], function({
      ControlPanel: GUI
    }, Mode, SVG) {
    var checkPanelSize, constructLayout;
    constructLayout = function(groups, desiredColumnHeight, vertical) {
      var column, columns, group, innerPanelSize, len, len1, len2, m, n, q, tallestColumnHeight;
      columns = [];
      column = null;

      // Whether we're in horizontal or vertical, our layout is built of columns.
// Controls may be grouped together with a color, and a color group is never split across columns.
      for (m = 0, len = groups.length; m < len; m++) {
        group = groups[m];
        
        // Start a new column if we need one
        if ((column == null) || column.height > desiredColumnHeight) {
          columns.push(column = {
            x: columns.length * (GUI.colInnerWidth + GUI.groupPad * 2 + GUI.columnMargin),
            y: 0, // This will be computed once we know how tall all our columns are
            height: 0,
            groups: []
          });
        }
        if (column.groups.length > 0) {
          
          // Add some margin between this group and the previous
          column.height += GUI.groupMargin;
        }
        
        // Attach this group to the column, and assign it a position
        column.groups.push({
          scope: group.scope,
          y: column.height
        });
        
        // Add this group's height to our running total
        column.height += group.height;
      }
      
      // Figure out which column is tallest, so we know how tall to make the panel
      tallestColumnHeight = 0;
      for (n = 0, len1 = columns.length; n < len1; n++) {
        column = columns[n];
        tallestColumnHeight = Math.max(tallestColumnHeight, column.height);
      }

      // Set the y position for each column
      for (q = 0, len2 = columns.length; q < len2; q++) {
        column = columns[q];
        // In vertical orientation, center-align
        // In horizontal orientation, bottom-align
        column.y = vertical ? tallestColumnHeight / 2 - column.height / 2 : tallestColumnHeight - column.height;
      }
      
      // Figure out how big to make the panel, so it fits all our columns
      innerPanelSize = {
        w: GUI.panelPadding * 2 + columns.length * (GUI.colInnerWidth + GUI.groupPad * 2) + (columns.length - 1) * GUI.columnMargin,
        h: GUI.panelPadding * 2 + tallestColumnHeight
      };
      return [innerPanelSize, columns];
    };
    Make("ControlPanelLayout", {
      vertical: function(groups, marginedSpace) {
        var desiredColumnHeight, desiredNumberOfColumns, group, len, m, maxHeight;
        if (!(marginedSpace.h > 0 && groups.length > 0)) { // Bail if the screen is too small or we have no controls
          return [
            {
              w: 0,
              h: 0
            },
            []
          ];
        }
        
        // First, get the height of the panel if it was just 1 column wide
        maxHeight = 0;
        for (m = 0, len = groups.length; m < len; m++) {
          group = groups[m];
          maxHeight += group.height;
        }
        maxHeight += GUI.groupMargin * (groups.length - 1); // Add padding between all groups
        
        // Figure out how many columns we need to fit this much height.
        desiredNumberOfColumns = Mode.embed ? 1 : Math.ceil(maxHeight / (marginedSpace.h - GUI.panelPadding * 2)); // If we're in embed mode, we'll force it to only ever have 1 column, because that's nicer.
        desiredColumnHeight = Math.max(GUI.unit, Math.floor(maxHeight / desiredNumberOfColumns));
        return constructLayout(groups, desiredColumnHeight, true);
      },
      horizontal: function(groups, marginedSpace) {
        var desiredColumnHeight;
        if (!(marginedSpace.w > 0 && groups.length > 0)) { // Bail if the screen is too small or we have no controls
          return [
            {
              w: 0,
              h: 0
            },
            []
          ];
        }
        desiredColumnHeight = GUI.unit / 2;
        
          // Increase the column height until everything fits on screen
        while (!checkPanelSize(desiredColumnHeight, groups, marginedSpace)) {
          desiredColumnHeight += GUI.unit / 4;
        }
        return constructLayout(groups, desiredColumnHeight, false);
      },
      applyLayout: function(columns, getColumnElm) {
        var c, column, columnElm, groupInfo, len, m, results;
        results = [];
        for (c = m = 0, len = columns.length; m < len; c = ++m) {
          column = columns[c];
          columnElm = getColumnElm(c);
          SVG.attrs(columnElm, {
            transform: `translate(${column.x},${column.y})`
          });
          results.push((function() {
            var len1, n, ref, results1;
            ref = column.groups;
            results1 = [];
            for (n = 0, len1 = ref.length; n < len1; n++) {
              groupInfo = ref[n];
              SVG.append(columnElm, groupInfo.scope.element);
              results1.push(groupInfo.scope.y = groupInfo.y);
            }
            return results1;
          })());
        }
        return results;
      }
    });
    return checkPanelSize = function(columnHeight, groups, marginedSpace) {
      var consumedHeight, consumedWidth, group, len, m, nthGroupInColumn;
      // We'll always have at least 1 column's worth of width, plus padding on both sides
      consumedWidth = GUI.colInnerWidth + GUI.panelPadding * 2;
      consumedHeight = GUI.panelPadding * 2;
      nthGroupInColumn = 0;
      for (m = 0, len = groups.length; m < len; m++) {
        group = groups[m];
        // Move to the next column if needed
        if (consumedHeight > columnHeight) {
          consumedWidth += GUI.colInnerWidth + GUI.columnMargin;
          consumedHeight = GUI.panelPadding * 2;
          nthGroupInColumn = 0;
        }
        if (nthGroupInColumn > 0) {
          consumedHeight += GUI.groupMargin;
        }
        // Add the current group height to our current column height
        consumedHeight += group.height;
        nthGroupInColumn++;
      }
      
      // We're done if we fit within the available width, or our column height gets out of hand
      return consumedWidth < marginedSpace.w || columnHeight > marginedSpace.h / 2;
    };
  });

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function({
      ControlPanel: GUI
    }, Input, Registry, SVG, Tween) {
    return Registry.set("Control", "button", function(elm, props) {
      var bg, bgFill, bgc, blueBG, click, handlers, input, label, labelFill, lightBG, orangeBG, outerWidth, scope, strokeWidth, tickBG, toClicked, toClicking, toHover, toNormal;
      // An array to hold all the click functions that have been attached to this button
      handlers = [];
      bgFill = props.bgColor || "hsl(220, 10%, 92%)";
      labelFill = props.fontColor || "hsl(227, 16%, 24%)";
      outerWidth = props.width || GUI.colInnerWidth;
      strokeWidth = 2;
      // Enable pointer cursor, other UI features
      SVG.attrs(elm, {
        ui: true
      });
      // Button background element
      bg = SVG.create("rect", elm, {
        x: strokeWidth / 2,
        y: strokeWidth / 2,
        width: outerWidth - strokeWidth,
        height: GUI.unit - strokeWidth,
        rx: GUI.borderRadius,
        strokeWidth: strokeWidth,
        fill: bgFill
      });
      // Button text label
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: outerWidth / 2,
        y: props.valign || ((props.fontSize || 16) + GUI.unit / 5),
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal",
        fill: labelFill
      });
      // Setup the bg stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      // Input event handling
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
      input = Input(elm, {
        moveIn: toHover,
        dragIn: function(e, state) {
          if (state.clicking) {
            return toClicking();
          }
        },
        down: toClicking,
        up: toHover,
        moveOut: toNormal,
        dragOut: toNormal
      });
      // Hack around bugginess in chrome
      click = function() {
        var handler, len, m, results;
        if (input.state.clicking) {
          toClicked();
          results = [];
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            results.push(handler());
          }
          return results;
        }
      };
      elm.addEventListener("mouseup", click);
      elm.addEventListener("touchend", click);
      // Our scope just has the 3 mandatory control functions, nothing special.
      return scope = {
        height: GUI.unit,
        input: input,
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

  Take(["GUI", "Registry", "SVG"], function({
      ControlPanel: GUI
    }, Registry, SVG) {
    return Registry.set("Control", "divider", function(elm, props) {
      throw "Error: Control.divider() has been removed.";
    });
  });

  Take(["Registry", "GUI", "Scope", "SVG"], function(Registry, {
      ControlPanel: GUI
    }, Scope, SVG) {
    return Registry.set("Control", "label", function(elm, props) {
      var height, label, labelFill, labelY, scope;
      // Remember: SVG text element position is ALWAYS relative to the text baseline.
      // So, we position our baseline a certain distance from the top, based on the font size.
      labelY = GUI.labelPad + (props.fontSize || 16) * 0.75; // Lato's baseline is about 75% down from the top of the caps
      height = GUI.labelPad + (props.fontSize || 16);
      labelFill = props.fontColor || "hsl(220, 10%, 92%)";
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

  Take(["GUI", "Input", "PopoverButton", "RAF", "Registry", "Resize", "Scope", "SVG", "Tween"], function({
      ControlPanel: GUI
    }, Input, PopoverButton, RAF, Registry, Resize, Scope, SVG, Tween) {
    return Registry.set("Control", "popover", function(elm, props) {
      var activeButtonCancelCb, activeFill, activeLabel, bgc, blueBG, buttonContainer, buttons, controlPanelScale, desiredPanelX, desiredPanelY, height, input, itemElm, label, labelFill, labelHeight, labelTriangle, labelY, lightBG, nextButtonOffsetY, orangeBG, panel, panelInner, panelIsVertical, panelRect, panelTriangle, rect, rectFill, reposition, requestReposition, resize, scope, setActive, showing, strokeWidth, tickBG, toClicked, toClicking, toHover, toNormal, triangleFill, triangleSize, update, windowHeight;
      // Config
      labelFill = props.fontColor || "hsl(220, 10%, 92%)";
      rectFill = "hsl(227, 45%, 25%)";
      triangleFill = "hsl(220, 35%, 80%)";
      activeFill = "hsl(92, 46%, 57%)";
      triangleSize = 24;
      strokeWidth = 2;
      // State
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
      // Init label size values
      if (props.name != null) {
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75; // Lato's baseline is about 75% down from the top of the caps
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2; // Lato's descenders are about 120% down from the top of the caps
      } else {
        labelHeight = 0;
      }
      height = labelHeight + GUI.unit;
      // This is the "item" in the main control panel
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
        fill: activeFill
      });
      labelTriangle = SVG.create("polyline", itemElm, {
        points: "6,-6 13,0 6,6",
        transform: `translate(0, ${labelHeight + GUI.unit / 2})`,
        stroke: triangleFill,
        strokeWidth: 4,
        strokeLinecap: "round",
        fill: "none"
      });
      // This is the panel that pops open when you click the item
      panel = Scope(SVG.create("g", elm));
      panel.hide(0);
      panelTriangle = SVG.create("polyline", panel.element, {
        points: `0,${-triangleSize / 2} ${triangleSize * 4 / 7},0 0,${triangleSize / 2}`,
        fill: triangleFill
      });
      panelInner = SVG.create("g", panel.element);
      panelRect = SVG.create("rect", panelInner, {
        width: GUI.colInnerWidth,
        rx: GUI.panelBorderRadius,
        fill: triangleFill
      });
      buttonContainer = SVG.create("g", panelInner, {
        transform: `translate(${GUI.panelPadding},${GUI.panelPadding})`
      });
      resize = function() {
        if (panelIsVertical) {
          desiredPanelX = -GUI.colInnerWidth - 6;
          desiredPanelY = labelHeight + GUI.unit / 2 - nextButtonOffsetY / 2;
          SVG.attrs(panelTriangle, {
            transform: `translate(-7,${labelHeight + GUI.unit / 2})`
          });
        } else {
          desiredPanelX = 0;
          desiredPanelY = panelInner.y = -nextButtonOffsetY - triangleSize + labelHeight + 9;
          SVG.attrs(panelTriangle, {
            transform: `translate(${GUI.colInnerWidth / 2},${labelHeight - 7}) rotate(90)`
          });
        }
        SVG.attrs(panelInner, {
          transform: `translate(${desiredPanelX}, ${desiredPanelY})`
        });
        // We have to wait 1 tick for a layout operation to happen.
        // This causes some flickering, but I can't find a way to avoid that.
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
          transform: `translate(${desiredPanelX * panelScale}, ${newPanelY}) scale(${panelScale})`
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
        return activeButtonCancelCb = unclick;
      };
      // Setup the bg stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      update = function() {
        var button, len, m;
        if (showing) {
          panel.show(0);
          resize();
          for (m = 0, len = buttons.length; m < len; m++) {
            button = buttons[m];
            button.enable(true);
          }
        } else {
          panel.hide(0.2);
          requestAnimationFrame(function() {
            var len1, n, results;
            results = [];
            for (n = 0, len1 = buttons.length; n < len1; n++) {
              button = buttons[n];
              results.push(button.enable(false));
            }
            return results;
          });
        }
        return void 0;
      };
      // Input event handling
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
      input = Input(itemElm, {
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
          if (showing && !panel.element.contains(e.target)) {
            showing = false;
            return update();
          }
        },
        click: function() {
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
        input: input,
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
          if (enable) {
            SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
            SVG.attrs(activeLabel, {
              fill: "url(#LightHighlightGradient)"
            });
            SVG.attrs(labelTriangle, {
              stroke: "url(#LightHighlightGradient)"
            });
            SVG.attrs(panelTriangle, {
              fill: "url(#LightHighlightGradient)"
            });
            SVG.attrs(panelRect, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(rect, {
              fill: "url(#DarkHighlightGradient)"
            });
          } else {
            SVG.attrs(label, {
              fill: labelFill
            });
            SVG.attrs(activeLabel, {
              fill: activeFill
            });
            SVG.attrs(labelTriangle, {
              stroke: triangleFill
            });
            SVG.attrs(panelTriangle, {
              fill: triangleFill
            });
            SVG.attrs(panelRect, {
              fill: triangleFill
            });
            return SVG.attrs(rect, {
              fill: rectFill
            });
          }
        }
      };
    });
  });

  Take(["GUI", "Input", "SVG", "Tween"], function({
      ControlPanel: GUI
    }, Input, SVG, Tween) {
    var active;
    active = null;
    return Make("PopoverButton", function(elm, props) {
      var activeBG, attachClick, bg, blueBG, click, curBG, handlers, highlighting, input, isActive, label, labelFill, orangeBG, scope, tickBG, toActive, toClicking, toHover, toNormal, unclick, whiteBG;
      handlers = [];
      isActive = false;
      highlighting = false;
      labelFill = props.fontColor || "hsl(227, 16%, 24%)";
      // Enable pointer cursor, other UI features
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
      // Setup the bg stroke color for tweening
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
            fill: `hsl(${curBG.h | 0},${curBG.s | 0}%,${curBG.l | 0}%)`
          });
        }
      };
      tickBG(whiteBG);
      // Input event handling
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
        if (e !== false) {
          for (m = 0, len = handlers.length; m < len; m++) {
            handler = handlers[m];
            handler();
          }
        }
        return void 0;
      };
      input = Input(elm, {
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
      // Set up click handling
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
        input: input,
        enable: function(v) {
          input.enable(v);
          if (v === false && !isActive) {
            return toNormal();
          }
        },
        doClick: click, // Trigger a click from outside code
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

  Take(["GUI", "Input", "Registry", "SVG", "Tween"], function({
      ControlPanel: GUI
    }, Input, Registry, SVG, Tween) {
    return Registry.set("Control", "pushButton", function(elm, props) {
      var bgFill, blueBG, bsc, button, height, hit, input, isActive, label, labelFill, lightBG, offHandlers, onHandlers, orangeBG, radius, scope, strokeWidth, tickBG, toClicking, toHover, toNormal;
      // Arrays to hold all the functions that have been attached to this control
      onHandlers = [];
      offHandlers = [];
      isActive = false;
      strokeWidth = 2;
      radius = GUI.unit * 0.6;
      height = Math.max(radius * 2, props.fontSize || 16);
      bgFill = "hsl(220, 10%, 92%)";
      labelFill = props.fontColor || "hsl(220, 10%, 92%)";
      // Enable pointer cursor, other UI features
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
      // Setup the button stroke color for tweening
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
          stroke: `rgb(${bsc.r | 0},${bsc.g | 0},${bsc.b | 0})`
        });
      };
      tickBG(blueBG);
      // Input event handling
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
      input = Input(elm, {
        moveIn: function() {
          if (!isActive) {
            return toHover();
          }
        },
        down: function() {
          var len, m, onHandler;
          if (isActive) {
            return;
          }
          isActive = true;
          toClicking();
          for (m = 0, len = onHandlers.length; m < len; m++) {
            onHandler = onHandlers[m];
            onHandler();
          }
          return void 0;
        },
        up: function() {
          var len, m, offHandler;
          if (!isActive) {
            return;
          }
          isActive = false;
          toHover();
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            offHandler();
          }
          return void 0;
        },
        miss: function() {
          var len, m, offHandler;
          if (!isActive) {
            return;
          }
          isActive = false;
          toNormal();
          for (m = 0, len = offHandlers.length; m < len; m++) {
            offHandler = offHandlers[m];
            offHandler();
          }
          return void 0;
        },
        moveOut: function() {
          if (!isActive) {
            return toNormal;
          }
        }
      });
      // Our scope just has the 3 mandatory control functions, nothing special.
      return scope = {
        height: height,
        input: input,
        setValue: function(activate, runHandlers = true) {
          var len, len1, m, n, offHandler, onHandler;
          if (activate && !isActive) {
            isActive = true;
            toClicking();
            if (runHandlers) {
              for (m = 0, len = onHandlers.length; m < len; m++) {
                onHandler = onHandlers[m];
                onHandler();
              }
            }
          } else if (isActive && !activate) {
            isActive = false;
            if (input.over) {
              toHover();
            } else {
              toNormal();
            }
            if (runHandlers) {
              for (n = 0, len1 = offHandlers.length; n < len1; n++) {
                offHandler = offHandlers[n];
                offHandler();
              }
            }
          }
          return void 0;
        },
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

  Take(["Registry", "GUI", "SelectorButton", "Scope", "SVG"], function(Registry, {
      ControlPanel: GUI
    }, SelectorButton, Scope, SVG) {
    var idCounter;
    idCounter = 0;
    return Registry.set("Control", "selector", function(elm, props) {
      var activeButton, borderFill, borderRect, buttons, buttonsContainer, clip, clipRect, height, id, label, labelFill, labelHeight, labelY, scope, setActive;
      id = `Selector${idCounter++}`;
      buttons = [];
      activeButton = null;
      if (props.name != null) {
        // Remember: SVG text element position is ALWAYS relative to the text baseline.
        // So, we position our baseline a certain distance from the top, based on the font size.
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75; // Lato's baseline is about 75% down from the top of the caps
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2; // Lato's descenders are about 120% down from the top of the caps
      } else {
        labelHeight = 0;
      }
      height = labelHeight + GUI.unit;
      labelFill = props.fontColor || "hsl(220, 10%, 92%)";
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
        clipPath: `url(#${id})`
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
          // We check for this property in some control-specific scope-processors
          props._isControl = true;
          buttonElm = SVG.create("g", buttonsContainer.element);
          buttonScope = Scope(buttonElm, SelectorButton, props);
          buttons.push(buttonScope);
          // We don't want controls to highlight when they're hovered over,
          // so we flag them in a way that highlight can see.
          buttonScope._dontHighlightOnHover = true;
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
            if (label != null) {
              SVG.attrs(label, {
                fill: "url(#LightHighlightGradient)"
              });
            }
            SVG.attrs(borderRect, {
              fill: "url(#DarkHighlightGradient)"
            });
          } else {
            if (label != null) {
              SVG.attrs(label, {
                fill: labelFill
              });
            }
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

  Take(["GUI", "Input", "SVG", "Tween"], function({
      ControlPanel: GUI
    }, Input, SVG, Tween) {
    var active;
    active = null;
    return Make("SelectorButton", function(elm, props) {
      var attachClick, bg, blueBG, click, curBG, handlers, highlighting, input, isActive, label, labelFill, lightBG, orangeBG, scope, strokeWidth, tickBG, toActive, toClicking, toHover, toNormal, unclick, whiteBG;
      handlers = [];
      isActive = false;
      highlighting = false;
      labelFill = props.fontColor || "hsl(227, 16%, 24%)";
      strokeWidth = 2;
      // Enable pointer cursor, other UI features
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
      // Setup the bg stroke color for tweening
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
            fill: `rgb(${curBG.r | 0},${curBG.g | 0},${curBG.b | 0})`
          });
        }
      };
      tickBG(whiteBG);
      // Input event handling
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
      click = function() {
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
      input = Input(elm, {
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
      // Set up click handling
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
        input: input,
        setValue: function(activate, runHandlers = true) {
          var handler, len, m;
          if (activate && !isActive) {
            props.setActive(unclick);
            isActive = true;
            toActive();
            if (runHandlers) {
              for (m = 0, len = handlers.length; m < len; m++) {
                handler = handlers[m];
                handler();
              }
            }
          } else if (isActive && !activate) {
            unclick();
          }
          return void 0;
        },
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

  Take(["Ease", "GUI", "Input", "Registry", "SVG", "TRS", "Tween"], function(Ease, {
      ControlPanel: GUI
    }, Input, Registry, SVG, TRS, Tween) {
    return Registry.set("Control", "slider", function(elm, props) {
      var bgc, blueBG, changeHandlers, downHandlers, handleDown, handleDrag, handleUp, height, hit, input, inputCalls, label, labelFill, labelHeight, labelY, leftLabel, lightBG, lightDot, normalDot, orangeBG, range, rightLabel, scope, snap, snapElms, snapTolerance, startDrag, strokeWidth, thumb, thumbBGFill, thumbSize, tickBG, toClicked, toClicking, toHover, toMissed, toNormal, track, trackFill, upHandlers, update, updateSnaps, v;
      // An array to hold all the callbacks that have been attached to this slider
      changeHandlers = [];
      downHandlers = [];
      upHandlers = [];
      snapElms = [];
      // Some local variables used to manage the slider position
      v = 0;
      startDrag = 0;
      strokeWidth = 2;
      snapTolerance = 0.033;
      if (props.name != null) {
        // Remember: SVG text element position is ALWAYS relative to the text baseline.
        // So, we position our baseline a certain distance from the top, based on the font size.
        labelY = GUI.labelPad + (props.fontSize || 16) * 0.75; // Lato's baseline is about 75% down from the top of the caps
        labelHeight = GUI.labelPad + (props.fontSize || 16) * 1.2; // Lato's descenders are about 120% down from the top of the caps
      } else {
        labelHeight = 0;
      }
      thumbSize = GUI.thumbSize;
      height = labelHeight + thumbSize;
      range = GUI.colInnerWidth - thumbSize;
      trackFill = "hsl(227, 45%, 24%)";
      thumbBGFill = "hsl(220, 10%, 92%)";
      labelFill = props.fontColor || "hsl(220, 10%, 92%)";
      lightDot = "hsl(92, 46%, 57%)";
      normalDot = "hsl(220, 10%, 92%)";
      // Enable pointer cursor, other UI features
      SVG.attrs(elm, {
        ui: true
      });
      hit = SVG.create("rect", elm, {
        width: GUI.colInnerWidth,
        height: height,
        fill: "transparent"
      });
      // Slider background element
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
      // The labels for left and right ends
      if (props.leftLabel != null) {
        leftLabel = SVG.create("text", elm, {
          textContent: props.leftLabel.toUpperCase(),
          x: strokeWidth + 5,
          y: labelHeight + thumbSize / 2 + 3,
          fontSize: 10,
          textAnchor: "start",
          fill: "hsl(220, 25%, 75%)"
        });
      }
      if (props.rightLabel != null) {
        rightLabel = SVG.create("text", elm, {
          textContent: props.rightLabel.toUpperCase(),
          x: GUI.colInnerWidth - strokeWidth - 5,
          y: labelHeight + thumbSize / 2 + 3,
          fontSize: 10,
          textAnchor: "end",
          fill: "hsl(220, 25%, 75%)"
        });
      }
      // The thumb graphic
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
      // The text label
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
      // Setup the thumb stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      updateSnaps = function(input) {
        var i, inMax, inMin, len, len1, m, n, outMax, outMin, ref, ref1;
        ref = props.snaps;
        // Reset all snaps
        for (i = m = 0, len = ref.length; m < len; i = ++m) {
          snap = ref[i];
          SVG.attrs(snapElms[i], {
            r: 2,
            stroke: normalDot
          });
        }
        ref1 = props.snaps;
        // Map our input to the right position, move the slider, and highlight the proper dot if needed
        for (i = n = 0, len1 = ref1.length; n < len1; i = ++n) {
          snap = ref1[i];
          // Input is inside this snap point
          if (input >= snap - snapTolerance && input <= snap + snapTolerance) {
            SVG.attrs(snapElms[i], {
              r: 3,
              stroke: lightDot
            });
            TRS.abs(thumb, {
              x: snap * range
            });
            return snap;
          // Input is below this snap point
          } else if (input < snap - snapTolerance) {
            TRS.abs(thumb, {
              x: input * range
            });
            inMin = i > 0 ? props.snaps[i - 1] + snapTolerance : 0;
            inMax = snap - snapTolerance;
            outMin = i > 0 ? props.snaps[i - 1] : 0;
            outMax = snap;
            return Ease.linear(input, inMin, inMax, outMin, outMax);
          }
        }
        // Snap is above the last snap point
        TRS.abs(thumb, {
          x: input * range
        });
        inMin = props.snaps[props.snaps.length - 1] + snapTolerance;
        inMax = 1;
        outMin = props.snaps[props.snaps.length - 1];
        outMax = 1;
        return Ease.linear(input, inMin, inMax, outMin, outMax);
      };
      // Update and save the thumb position
      update = function(V) {
        if (V != null) {
          v = Math.max(0, Math.min(1, V));
        }
        if (props.snaps != null) {
          return v = updateSnaps(v);
        } else {
          return TRS.abs(thumb, {
            x: v * range
          });
        }
      };
      update(props.value || 0);
      // Input event handling
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
      handleDown = function(e, state) {
        var downHandler, len, m;
        startDrag = e.clientX / range - v;
        for (m = 0, len = downHandlers.length; m < len; m++) {
          downHandler = downHandlers[m];
          downHandler(v);
        }
        return void 0;
      };
      handleDrag = function(e, state) {
        var changeHandler, len, m;
        if (state.clicking) {
          update(e.clientX / range - startDrag);
          for (m = 0, len = changeHandlers.length; m < len; m++) {
            changeHandler = changeHandlers[m];
            changeHandler(v);
          }
          return void 0;
        }
      };
      handleUp = function(e, state) {
        var len, m, upHandler;
        for (m = 0, len = upHandlers.length; m < len; m++) {
          upHandler = upHandlers[m];
          upHandler(v);
        }
        return void 0;
      };
      inputCalls = {
        moveIn: toHover,
        dragIn: function(e, s) {
          if (s.clicking) {
            return toClicking();
          }
        },
        down: function(e, s) {
          toClicking(e, s);
          return handleDown(e, s);
        },
        moveOut: toNormal,
        miss: function(e, s) {
          toMissed(e, s);
          return handleUp(e, s);
        },
        drag: handleDrag,
        dragOther: handleDrag,
        click: function(e, s) {
          toClicked(e, s);
          return handleUp(e, s);
        }
      };
      input = Input(elm, inputCalls, true, true, {
        blockScroll: true
      });
      return scope = {
        height: height,
        input: input,
        setValue: function(v, runHandlers = true) {
          var changeHandler, len, m;
          update(v);
          if (runHandlers) {
            for (m = 0, len = changeHandlers.length; m < len; m++) {
              changeHandler = changeHandlers[m];
              changeHandler(v);
            }
          }
          return void 0;
        },
        attach: function(props) {
          if (props.change != null) {
            changeHandlers.push(props.change);
          }
          if (props.down != null) {
            downHandlers.push(props.down);
          }
          if (props.up != null) {
            upHandlers.push(props.up);
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

  Take(["Registry", "GUI", "Input", "RAF", "SVG", "TRS", "Tween"], function(Registry, {
      ControlPanel: GUI
    }, Input, RAF, SVG, TRS, Tween) {
    return Registry.set("Control", "switch", function(elm, props) {
      var bgc, blueBG, handlers, height, input, isActive, label, labelFill, lightBG, lightFill, lightTrack, normalTrack, orangeBG, scope, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toNormal, toggle, track, trackWidth;
      // An array to hold all the change functions that have been attached to this slider
      handlers = [];
      strokeWidth = 2;
      thumbSize = GUI.thumbSize;
      trackWidth = thumbSize * 2;
      isActive = false;
      height = thumbSize;
      normalTrack = "hsl(227, 45%, 24%)";
      lightTrack = "hsl(92, 46%, 57%)";
      lightFill = "hsl(220, 10%, 92%)";
      labelFill = props.fontColor || lightFill;
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
        fill: lightFill,
        r: thumbSize / 2 - strokeWidth / 2
      }));
      label = SVG.create("text", elm, {
        textContent: props.name,
        x: trackWidth + GUI.labelMargin,
        y: (props.fontSize || 16) + GUI.unit / 16,
        fontSize: props.fontSize || 16,
        fontWeight: props.fontWeight || "normal",
        fontStyle: props.fontStyle || "normal",
        textAnchor: "start",
        fill: labelFill
      });
      toggle = function() {
        isActive = !isActive;
        TRS.abs(thumb, {
          x: isActive ? thumbSize : 0
        });
        SVG.attrs(track, {
          fill: isActive ? lightTrack : normalTrack
        });
        return props.click(isActive);
      };
      // Setup the thumb stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      // Input event handling
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
      input = Input(elm, {
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
          toClicked();
          toggle();
          return void 0;
        }
      });
      return scope = {
        height: height,
        input: input,
        isActive: function() {
          return isActive;
        },
        setValue: function(v = null) {
          if ((v == null) || v !== isActive) {
            return toggle();
          }
        },
        attach: function(props) {
          if (props.change != null) {
            handlers.push(props.change);
          }
          if (props.active) {
            return RAF(toggle, true);
          }
        },
        _highlight: function(enable) {
          if (enable) {
            SVG.attrs(track, {
              fill: isActive ? "url(#MidHighlightGradient)" : "url(#DarkHighlightGradient)"
            });
            SVG.attrs(thumb, {
              fill: "url(#LightHighlightGradient)"
            });
            return SVG.attrs(label, {
              fill: "url(#LightHighlightGradient)"
            });
          } else {
            SVG.attrs(track, {
              fill: isActive ? lightTrack : normalTrack
            });
            SVG.attrs(thumb, {
              fill: lightFill
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
      // Disable the content menu, so that we can use long-press on touch Windows for pushButtons
      window.addEventListener("contextmenu", function(e) {
        return e.preventDefault();
      });
    }
    // Block drag-to-copy on Windows
    window.addEventListener("dragstart", function(e) {
      return e.preventDefault();
    });
    if (Mode.nav) {
      // Block scrolling on desktops
      window.addEventListener("scroll", function(e) {
        return e.preventDefault();
      });
      // Block scrolling on iOS
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
        panelMargin: 4, // Space between the panel and the edge of the window
        panelPadding: 6, // Padding inside the panel
        columnMargin: 5, // Horizontal space between two columns
        groupMargin: 4, // Vertical space between two groups
        groupPad: 3, // Padding inside groups
        itemMargin: 3, // Vertical space between two items
        labelPad: 3, // Padding above text labels
        labelMargin: 6, // Horizontal space around labels for push buttons and switches
        unit: unit = 32,
        thumbSize: unit - 4,
        colUnits: colUnits = 5,
        colInnerWidth: colInnerWidth = unit * colUnits // Width of items in a column
      },
      Panel: {
        unit: 32,
        itemWidth: 360,
        itemMargin: 8, // Vertical space between two items
        panelPad: 8, // Space between the sides of the panel and items in the panel
        panelMargin: 16, // Minimum space between the outside of the panel and the edge of the window
        panelBorderRadius: 8
      },
      Colors: {
        bg: {
          xxl: "hsl(217, 70%, 70%)",
          xl: "hsl(219, 60%, 57%)",
          l: "hsl(220, 50%, 50%)",
          m: "hsl(224, 47%, 45%)",
          d: "hsl(227, 45%, 40%)",
          xd: "hsl(230, 50%, 30%)"
        },
        // SHADE
        mist: "hsl(220, 10%, 92%)",
        silver: "hsl(220, 15%, 80%)",
        grey: "hsl(220, 9%, 52%)",
        smoke: "hsl(227, 15%, 25%)",
        tar: "hsl(233, 30%, 17%)",
        onyx: "hsl(240, 50%, 5%)",
        // KEY
        red: "hsl(358, 80%, 55%)",
        orange: "hsl(24, 100%, 60%)",
        yellow: "hsl(43, 100%, 50%)",
        green: "hsl(130, 85%, 35%)",
        blue: "hsl(223, 45%, 45%)",
        indigo: "hsl(270, 50%, 58%)",
        violet: "hsl(330, 55%, 50%)",
        // SPECIAL
        blueberry: "hsl(259, 65%, 65%)",
        bronze: "hsl(43,  50%, 70%)",
        mint: "hsl(153, 80%, 41%)",
        navy: "hsl(235, 52%, 22%)",
        navydark: "hsl(227, 65%, 14%)",
        olive: "hsl(166, 90%, 20%)",
        purple: "hsl(255, 49%, 37%)",
        teal: "hsl(180, 100%, 32%)",
        fuscha: "hsl(340, 60%, 50%)",
        ghost: "rgba(255, 255, 255, 0.05)",
        demon: "rgba(0, 0, 0, 0.05)"
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

  Take(["Mode", "Tick", "SVG", "SVGReady"], function(Mode, Tick, SVG) {
    var HUD, colors, elapsed, elm, needsUpdate, rate, values;
    if (!Mode.dev) {
      Make("HUD", function() {}); // Noop
      return;
    }
    rate = 1 / 8; // Update every nth of a second
    elapsed = rate; // Run the first update immediately
    needsUpdate = true;
    colors = {};
    values = {};
    elm = document.createElement("div");
    elm.setAttribute("svga-hud", "true");
    document.body.insertBefore(elm, SVG.svg);
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
            html += `<div style='color:${colors[k]}'>${k}: ${v}</div>`;
          }
          return elm.innerHTML = html;
        }
      }
    });
    return Make("HUD", HUD = function(k, v, c = "#000") {
      var _k, _v;
      
      // Allow passing an object of k-v pairs, with the 2nd arg as the optional color
      if (typeof k === "object") {
        for (_k in k) {
          _v = k[_k];
          HUD(_k, _v, v);
        }
      
      // Pretty-print nested objects (and avoid infinite loops if there's a reference cycle)
      } else if (typeof v === "object" && !v._hud_visited) {
        v._hud_visited = true;
        for (_k in v) {
          _v = v[_k];
          if (_k !== "_hud_visited") {
            HUD(`${k}.${_k}`, _v, v);
          }
        }
        v._hud_visited = false;
      } else {
        if (values[k] !== v || (values[k] == null)) {
          values[k] = v;
          colors[k] = c;
          needsUpdate = true;
        }
      }
      return v; // Pass-through whenever possible
    });
  });

  Take(["HUD", "Mode", "SVGReady"], function(HUD, Mode) {
    var nodeCountElm;
    if (!Mode.dev) {
      return;
    }
    nodeCountElm = document.querySelector("[node-count]");
    if (nodeCountElm != null) {
      return HUD("Nodes", nodeCountElm.getAttribute("node-count"), "#0003");
    }
  });

  Take(["DOOM", "GUI", "Resize", "SVG", "Wait", "SVGReady"], function(DOOM, GUI, Resize, SVG, Wait) {
    var foreignObject, inner, outer;
    foreignObject = SVG.create("foreignObject", GUI.elm, {
      id: "message"
    });
    outer = DOOM.create("div", foreignObject, {
      id: "message-outer"
    });
    inner = DOOM.create("div", outer, {
      id: "message-inner"
    });
    Resize(function() {
      return SVG.attrs(foreignObject, {
        width: window.innerWidth,
        height: window.innerHeight
      });
    });
    return Make("Message", function(html, time = 2) {
      DOOM(inner, {
        innerHTML: html
      });
      return DOOM(outer, {
        opacity: 1
      });
    });
  });

  // Wait time, ()-> DOOM outer, opacity: 0
  Take(["Action", "DOOM", "Ease", "GUI", "Input", "Resize", "SVG", "SVGReady"], function(Action, DOOM, Ease, GUI, Input, Resize, SVG) {
    var Panel, close, cover, foreignObject, frame, g, hideCallback, inner, outer;
    hideCallback = null;
    foreignObject = SVG.create("foreignObject", GUI.elm, {
      id: "panel"
    });
    outer = DOOM.create("div", foreignObject, {
      id: "panel-outer"
    });
    cover = DOOM.create("div", outer, {
      id: "panel-cover"
    });
    frame = DOOM.create("div", outer, {
      id: "panel-frame"
    });
    close = DOOM.create("svg", frame, {
      id: "panel-close"
    });
    inner = DOOM.create("div", frame);
    g = SVG.create("g", close, {
      ui: true,
      transform: "translate(16,16)"
    });
    SVG.create("circle", g, {
      r: 16,
      fill: "#F00"
    });
    SVG.create("path", g, {
      d: "M-6,-6 L6,6 M6,-6 L-6,6",
      stroke: "#FFF",
      strokeWidth: 3,
      strokeLinecap: "round"
    });
    Input(cover, {
      click: function() {
        return Action("Panel:Hide");
      }
    });
    Input(close, {
      click: function() {
        return Action("Panel:Hide");
      }
    });
    window.addEventListener("keydown", function(e) {
      if (e.keyCode === 27) { // esc
        return Action("Panel:Hide");
      }
    });
    Resize(function() {
      return SVG.attrs(foreignObject, {
        width: window.innerWidth,
        height: window.innerHeight
      });
    });
    // Elements inside foreignObject don't inherit scaling, so to shrink the panel on narrow screens
    // we need to apply scaling using CSS transform to the HTML elements. Due to the CSS grid layout
    // pushing the panel off the right side, we introduce a negative offset to keep it centered.
    Resize(function(info) {
      var offset, panelWidth, scale;
      panelWidth = frame.offsetWidth;
      offset = Math.max(0, (panelWidth - window.innerWidth) / 2);
      scale = Ease.linear(info.window.w, 0, panelWidth, 0, 1);
      return DOOM(frame, {
        transform: `translateX(-${offset}px) scale(${scale})`
      });
    });
    Panel = function(id, html) {
      DOOM(inner, {
        id: id
      });
      inner.innerHTML = html; // Force the panel to be re-built from scratch, rather than using DOOM's caching, since code following this call will expect fresh DOM nodes to add event handlers to
      Action("Panel:Show");
      return inner;
    };
    Panel.show = function() {
      DOOM(foreignObject, {
        pointerEvents: "auto"
      });
      return DOOM(outer, {
        opacity: 1
      });
    };
    Panel.hide = function() {
      DOOM(foreignObject, {
        pointerEvents: null
      });
      DOOM(outer, {
        opacity: 0
      });
      if (typeof hideCallback === "function") {
        hideCallback();
      }
      return hideCallback = null;
    };
    Panel.alert = function(msg, cb) {
      hideCallback = cb;
      inner = Panel("Alert", `<h3>${msg}</h3>
<div><button>Okay</button></div>`);
      return inner.querySelector("button").addEventListener("click", function() {
        return Action("Panel:Hide");
      });
    };
    Panel.hide();
    return Make("Panel", Panel);
  });

  Take(["Action", "ControlPanel", "Panel", "Reaction", "SVG", "SVGReady"], function(Action, ControlPanel, Panel, Reaction, SVG) {
    // It'd be better if this logic were in some sort of state machine with purview
    // over the entire GUI, but things aren't complex enough to warrant that yet.
    // Something like a router, I guess.
    Reaction("Panel:Hide", function() {
      return Panel.hide();
    });
    return Reaction("Panel:Show", function() {
      return Panel.show();
    });
  });

  Take(["Ease", "GUI", "Input", "SVG", "TRS", "Tween"], function(Ease, {
      Panel: GUI
    }, Input, SVG, TRS, Tween) {
    var SettingsSlider;
    return Make("SettingsSlider", SettingsSlider = function(elm, props) {
      var bgc, blueBG, handleDrag, label, labelPad, labelWidth, lightBG, lightDot, normalDot, orangeBG, range, snap, snapElms, snapTolerance, startDrag, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toMissed, toNormal, track, trackWidth, update, updateSnaps, v;
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
      // Setup the thumb stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      updateSnaps = function(input) {
        var i, inMax, inMin, len, len1, m, n, outMax, outMin, ref, ref1;
        ref = props.snaps;
        // Reset all snaps
        for (i = m = 0, len = ref.length; m < len; i = ++m) {
          snap = ref[i];
          SVG.attrs(snapElms[i], {
            r: 2,
            stroke: normalDot
          });
        }
        ref1 = props.snaps;
        // Map our input to the right position, move the slider, and highlight the proper dot if needed
        for (i = n = 0, len1 = ref1.length; n < len1; i = ++n) {
          snap = ref1[i];
          // Input is inside this snap point
          if (input >= snap - snapTolerance && input <= snap + snapTolerance) {
            SVG.attrs(snapElms[i], {
              r: 3,
              stroke: lightDot
            });
            TRS.abs(thumb, {
              x: snap * range
            });
            return snap;
          // Input is below this snap point
          } else if (input < snap - snapTolerance) {
            TRS.abs(thumb, {
              x: input * range
            });
            inMin = i > 0 ? props.snaps[i - 1] + snapTolerance : 0;
            inMax = snap - snapTolerance;
            outMin = i > 0 ? props.snaps[i - 1] : 0;
            outMax = snap;
            return Ease.linear(input, inMin, inMax, outMin, outMax);
          }
        }
        // Snap is above the last snap point
        TRS.abs(thumb, {
          x: input * range
        });
        inMin = props.snaps[props.snaps.length - 1] + snapTolerance;
        inMax = 1;
        outMin = props.snaps[props.snaps.length - 1];
        outMax = 1;
        return Ease.linear(input, inMin, inMax, outMin, outMax);
      };
      // Update and save the thumb position
      update = function(V) {
        if (V != null) {
          v = Math.max(0, Math.min(1, V));
        }
        if (props.snaps != null) {
          return v = updateSnaps(v);
        } else {
          return TRS.abs(thumb, {
            x: v * range
          });
        }
      };
      // Input event handling
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
      // Init
      return update(props.value || 0);
    });
  });

  Take(["GUI", "Input", "SVG", "TRS", "Tween"], function({
      Panel: GUI
    }, Input, SVG, TRS, Tween) {
    var SettingsSwitch;
    return Make("SettingsSwitch", SettingsSwitch = function(elm, props) {
      var bgc, blueBG, isActive, label, labelPad, labelWidth, lightBG, lightTrack, normalTrack, orangeBG, scope, strokeWidth, thumb, thumbSize, tickBG, toClicked, toClicking, toHover, toNormal, toggle, track;
      strokeWidth = 2;
      labelPad = 10;
      labelWidth = GUI.itemWidth / 2;
      thumbSize = GUI.unit;
      isActive = false;
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
        isActive = !isActive;
        TRS.abs(thumb, {
          x: isActive ? thumbSize : 0
        });
        SVG.attrs(track, {
          fill: isActive ? lightTrack : normalTrack
        });
        return props.update(isActive);
      };
      // Setup the thumb stroke color for tweening
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
          stroke: `rgb(${bgc.r | 0},${bgc.g | 0},${bgc.b | 0})`
        });
      };
      tickBG(blueBG);
      // Input event handling
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
          toClicked();
          toggle();
          return void 0;
        }
      });
      if (props.value) {
        // Init
        toggle();
      }
      return scope = {
        isActive: function() {
          return isActive;
        },
        setValue: function(v = null) {
          if ((v == null) || v !== isActive) {
            return toggle();
          }
        }
      };
    });
  });

  Take(["Action", "DOOM", "GUI", "Input", "Mode", "Panel", "Scope", "SVG", "ScopeReady"], function(Action, DOOM, GUI, Input, Mode, Panel, Scope, SVG) {
    var Settings, bg, controls, elm, height, hit, label, scope, width;
    controls = [];
    Make("Settings", Settings = {
      addSetting: function(type, index, props) {
        var builder, controlApi, controlScope, elm;
        if (controls[index] != null) {
          return;
        }
        elm = DOOM.create("svg", null);
        controls[index] = elm;
        controlScope = Scope(SVG.create("g", elm));
        builder = Take(`Settings${type}`);
        controlApi = builder(controlScope.element, props);
        return controlApi;
      }
    });
    if (!Mode.settings) {
      return;
    }
    // Create the Settings button

    // Eventually, the settings button at the top should be part of an HTML-based HUD so that we don't need all this nonsense
    elm = SVG.create("g", GUI.elm, {
      ui: true
    });
    scope = Scope(elm);
    scope.x = GUI.ControlPanel.panelMargin;
    scope.y = GUI.ControlPanel.panelMargin;
    width = 60;
    height = 22;
    hit = SVG.create("rect", elm, {
      x: -GUI.ControlPanel.panelMargin,
      y: -GUI.ControlPanel.panelMargin,
      width: width + 16,
      height: height + 16,
      fill: "transparent"
    });
    bg = SVG.create("rect", elm, {
      width: width,
      height: height,
      rx: 3,
      fill: GUI.Colors.bg.l
    });
    label = SVG.create("text", elm, {
      textContent: "Settings",
      x: width / 2,
      y: height * 0.7,
      fontSize: 14,
      textAnchor: "middle",
      fill: "hsl(220, 10%, 92%)"
    });
    return Input(elm, {
      click: function() {
        var control, controlsElm, info, infoLines, len, line, m, panel, ref, ref1, results, title;
        title = (ref = Mode.get("meta")) != null ? ref.title : void 0;
        if ((title == null) && !Mode.embed) {
          title = document.title.replace("| ", "").replace("LunchBox Sessions", "");
        }
        if (infoLines = (ref1 = Mode.get("meta")) != null ? ref1.info : void 0) {
          info = ((function() {
            var len, m, results;
            results = [];
            for (m = 0, len = infoLines.length; m < len; m++) {
              line = infoLines[m];
              results.push(`<p>${line}</p>`);
            }
            return results;
          })()).join("");
        }
        panel = Panel("settings", `<div settings-controls></div>
<h3 settings-title>${title || ""}</h3>
<div settings-info>${info || ""}</div>
<small settings-copyright>© CD Industrial Group Inc.</small>`);
        controlsElm = panel.querySelector("[settings-controls]");
        results = [];
        for (m = 0, len = controls.length; m < len; m++) {
          control = controls[m];
          if (control != null) {
            results.push(DOOM.append(controlsElm, control));
          }
        }
        return results;
      }
    });
  });

  // The SVG starts off hidden. We unhide it when the time comes.
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
    
    // This only works in Safari and Mobile Safari
    // On Mobile Safari, it fights a bit with touchmove.
    // One of them will win and overwrite the other. Not a big deal.
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
      z: 0.05 // xy polar, z cartesian
    };
    accel = {
      xy: 0.7,
      z: 0.004 // xy polar, z cartesian
    };
    vel = {
      a: 0,
      d: 0,
      z: 0 // xy polar (angle, displacement), z cartesian
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
        
        // Do z first, so we can scale xy based on z
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
      
      // Scale the speed of nav so that it's somewhat framerate independent
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
    var blockDbl, calls, down, drag, dragging, up, wheel;
    if (!Mode.nav) {
      return;
    }
    dragging = false;
    down = function(e) {
      e.preventDefault(); // Without this, shift-drag pans the ENTIRE SVG! What the hell?
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
    blockDbl = function(elm) {
      while ((elm != null) && elm !== document) {
        if (elm.hasAttribute("block-dbl")) {
          return elm;
        }
        elm = elm.parentNode;
      }
      return null;
    };
    document.addEventListener("dblclick", function(e) {
      if (e.button !== 0) {
        return;
      }
      if (blockDbl(e.target)) {
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
    wheel = function(e) {
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
    };
    // Old code which was nice but sucked with mice
    // # Is this a pixel-precise input device (eg: magic trackpad)?
    // if e.deltaMode is WheelEvent.DOM_DELTA_PIXEL
    //   if e.ctrlKey # Chrome, pinch to zoom
    //     Nav.by z: -e.deltaY / 100
    //   else if e.metaKey # Other browsers, meta+scroll to zoom
    //     Nav.by z: -e.deltaY / 200
    //   else
    //     Nav.by
    //       x: -e.deltaX
    //       y: -e.deltaY
    //       z: -e.deltaZ

    // # This is probably a scroll wheel # DOESN'T WORK! :(
    // else
    //   Nav.by z: -e.deltaY / 500
    return document.addEventListener("wheel", wheel, {
      passive: false
    });
  });

  Take(["ControlPanel", "Fullscreen", "Mode", "ParentData", "RAF", "Resize", "SVG", "Tween", "SceneReady"], function(ControlPanel, Fullscreen, Mode, ParentData, RAF, Resize, SVG, Tween) {
    var Nav, applyLimit, center, centerInverse, computeResizeInfo, contentHeight, contentScale, contentWidth, dist, distTo, limit, pickBestLayout, pos, render, requestRender, resize, rootScale, runResize, scaleStartPosZ, tween;
    // Turn this on if we need to debug resizing
    // debugBox = SVG.create "rect", SVG.root, fill:"none", stroke:"#0F0A", strokeWidth: 6

    // Our SVGs don't have a viewbox, which means they render at 1:1 scale with surrounding content,
    // and are cropped when resized. We use their specified width and height as the desired bounding rect for the content.
    contentWidth = +SVG.attr(SVG.svg, "width");
    contentHeight = +SVG.attr(SVG.svg, "height");
    if (!((contentWidth != null) && (contentHeight != null))) {
      throw new Error("This SVG is missing the required 'width' and 'height' attributes. Please re-export it from Flash.");
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
        min: -1,
        max: 6
      }
    };
    contentScale = 1;
    scaleStartPosZ = 0;
    tween = null;
    rootScale = function() {
      return contentScale * Math.pow(2, pos.z);
    };
    render = function() {
      // First, we move SVG.root so the top left corner is in the middle of our available space.
      // ("Available space" means the size of the window, minus the space occupied by the control panel.)
      // Then, we scale to fit to the available space (contentScale) and desired zoom level (Math.pow 2, pos.z).
      // Then we shift back up and to the left to compensate for the first step (centerInverse), and then move to the desired nav position (pos).
      return SVG.attr(SVG.root, "transform", `translate(${center.x},${center.y}) scale(${rootScale()}) translate(${pos.x - centerInverse.x},${pos.y - centerInverse.y})`);
    };
    pickBestLayout = function(totalAvailableSpace, horizontalResizeInfo, verticalResizeInfo) {
      var contentHeightWhenHorizontal, panelHeightWhenHorizontal;
      if (Mode.embed) {
        if (verticalResizeInfo.scale.min >= 1) {
          // Prefer vertical, if that doesn't cause our content to shrink
          return verticalResizeInfo;
        }
        // Failing that, prefer hozitontal, if there's enough screen height
        contentHeightWhenHorizontal = contentHeight * horizontalResizeInfo.scale.min;
        panelHeightWhenHorizontal = horizontalResizeInfo.panelInfo.consumedSpace.h;
        if (totalAvailableSpace.h > contentHeightWhenHorizontal + panelHeightWhenHorizontal) {
          return horizontalResizeInfo;
        }
      }
      // Take whichever panel layout leaves more room for content
      if (horizontalResizeInfo.scale.min > verticalResizeInfo.scale.min) {
        return horizontalResizeInfo;
      } else {
        return verticalResizeInfo;
      }
    };
    computeResizeInfo = function(totalAvailableSpace, panelInfo) {
      var claimedH, idealContentHeight, idealHeight, resizeInfo, scale, totalAvailableContentSpace;
      // Figure out how much space remains for our main graphic
      totalAvailableContentSpace = {
        w: totalAvailableSpace.w - panelInfo.consumedSpace.w,
        h: totalAvailableSpace.h - panelInfo.consumedSpace.h
      };
      // Scale the graphic so it fits inside our available space
      scale = {
        x: totalAvailableContentSpace.w / contentWidth,
        y: totalAvailableContentSpace.h / contentHeight
      };
      scale.min = Math.min(scale.x, scale.y);
      idealHeight = Mode.embed ? (idealContentHeight = scale.x * contentHeight, claimedH = idealContentHeight + panelInfo.consumedSpace.h, Math.min(totalAvailableSpace.h, Math.max(claimedH, panelInfo.outerPanelSize.h))) : totalAvailableSpace.h;
      return resizeInfo = {
        panelInfo: panelInfo,
        totalAvailableContentSpace: totalAvailableContentSpace,
        idealHeight: idealHeight,
        scale: scale
      };
    };
    resize = function() {
      var horizontalPanelInfo, horizontalResizeInfo, resizeInfo, totalAvailableSpace, verticalPanelInfo, verticalResizeInfo;
      // This is the largest our SVGA can ever be
      totalAvailableSpace = {
        w: SVG.svg.getBoundingClientRect().width,
        h: window.top.innerHeight
      };
      // When deployed, account for the floating header
      if (!Mode.dev && !Fullscreen.active()) {
        totalAvailableSpace.h -= 48;
      }
      // Build two layouts — we'll figure out which one is best for the current content, controls, and screen size.
      verticalPanelInfo = ControlPanel.computeLayout(true, totalAvailableSpace);
      horizontalPanelInfo = ControlPanel.computeLayout(false, totalAvailableSpace);
      // Measure both layouts
      verticalResizeInfo = computeResizeInfo(totalAvailableSpace, verticalPanelInfo);
      horizontalResizeInfo = computeResizeInfo(totalAvailableSpace, horizontalPanelInfo);
      // Pick the best layout
      resizeInfo = pickBestLayout(totalAvailableSpace, horizontalResizeInfo, verticalResizeInfo);
      // If we're embedded into a cd-module, resize our embedding object.
      if (Mode.embed) {
        ParentData.send("height", Math.round(resizeInfo.idealHeight) + "px");
        totalAvailableSpace.h = resizeInfo.idealHeight;
      }
      // Apply the chosen layout to the ControlPanel
      ControlPanel.applyLayout(resizeInfo, totalAvailableSpace);
      // Save our window scale for future nav actions
      contentScale = resizeInfo.scale.min;
      // Before we do any scale operations, we need to move the top left corner of the graphic to the center of the available space
      center.x = resizeInfo.totalAvailableContentSpace.w / 2;
      center.y = resizeInfo.idealHeight / 2 - resizeInfo.panelInfo.consumedSpace.h / 2;
      // After we do any scale operations, we need to move the top left corner of the graphic up and left, so the center of the graphic is aligned with the center of the consumed space
      centerInverse.x = contentWidth / 2;
      centerInverse.y = contentHeight / 2;
      render();
      // Turn this on if we need to debug resizing
      // SVG.attrs debugBox, width: contentWidth, height: contentHeight
      return Resize._fire({
        window: totalAvailableSpace,
        panel: {
          scale: resizeInfo.panelInfo.scale,
          vertical: resizeInfo.panelInfo.vertical,
          x: resizeInfo.panelInfo.x,
          y: resizeInfo.panelInfo.y,
          width: resizeInfo.panelInfo.outerPanelSize.w,
          height: resizeInfo.panelInfo.outerPanelSize.h
        },
        content: {
          width: contentWidth,
          height: contentHeight
        }
      });
    };
    // Init
    runResize = function() {
      return RAF(resize, true);
    };
    window.addEventListener("resize", runResize);
    window.top.addEventListener("resize", runResize);
    Take("AllReady", runResize);
    // BAIL IF WE'RE NOT NAV-ING
    if (!Mode.nav) {
      Make("Nav", false);
      return;
    }
    requestRender = function() {
      return RAF(render, true);
    };
    applyLimit = function(l, v, a = 0) {
      return Math.min(l.max + a, Math.max(l.min - a, v));
    };
    Make("Nav", Nav = {
      center: function() {
        return center;
      },
      pos: function() {
        return pos;
      },
      rootScale: rootScale,
      runResize: runResize,
      reset: function(time) {
        return Nav.to({
          x: 0,
          y: 0,
          z: 0
        }, time);
      },
      to: function(p, time) {
        if (tween != null) {
          Tween.cancel(tween);
        }
        if (time == null) {
          time = Nav.tweenTime(p);
        }
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
        scale = rootScale();
        if (p.x != null) {
          pos.x += p.x / scale;
        }
        if (p.y != null) {
          pos.y += p.y / scale;
        }
        pos.x = applyLimit(limit.x, pos.x, center.x / scale * .8);
        pos.y = applyLimit(limit.y, pos.y, center.y / scale * .8);
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
        scale = rootScale();
        if (p.x != null) {
          pos.x = p.x / scale;
        }
        if (p.y != null) {
          pos.y = p.y / scale;
        }
        pos.x = applyLimit(limit.x, pos.x, center.x / scale * .8);
        pos.y = applyLimit(limit.y, pos.y, center.y / scale * .8);
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
      tweenTime: function(p) {
        var timeX, timeY, timeZ;
        timeX = .03 * Math.sqrt(Math.abs(p.x - pos.x)) || 0;
        timeY = .03 * Math.sqrt(Math.abs(p.y - pos.y)) || 0;
        timeZ = .7 * Math.sqrt(Math.abs(p.z - pos.z)) || 0;
        return Math.sqrt(timeX * timeX + timeY * timeY + timeZ * timeZ);
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
    return dist = function(x, y, z = 0) {
      return Math.sqrt(x * x + y * y + z * z);
    };
  });

  // Enable this to debug nav repaints
  // Take "Tick", (Tick)->
  //   Tick (t)->
  //     Nav.at z: Math.sin(t)/10 - .1
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

  Take(["Mode", "Nav", "TouchAcceleration"], function(Mode, Nav, TouchAcceleration) {
    var cloneTouches, distTouches, dragging, lastTouches, touchEnd, touchMove, touchStart;
    if (!Mode.nav) {
      return;
    }
    lastTouches = null;
    dragging = false;
    touchStart = function(e) {
      dragging = false;
      TouchAcceleration.move({
        x: 0,
        y: 0 // Stop any momentum scrolling
      });
      if (Nav.eventInside(e)) {
        e.preventDefault();
        return cloneTouches(e);
      }
    };
    touchMove = function(e) {
      var a, b;
      if (Nav.eventInside(e)) {
        e.preventDefault();
        if (e.touches.length !== lastTouches.length) {

        // noop
        } else if (e.touches.length > 1) {
          a = distTouches(lastTouches);
          b = distTouches(e.touches);
          Nav.by({
            z: (b - a) / 200
          });
        } else {
          dragging = true;
          TouchAcceleration.move({
            x: e.touches[0].clientX - lastTouches[0].clientX,
            y: e.touches[0].clientY - lastTouches[0].clientY
          });
        }
        return cloneTouches(e);
      }
    };
    touchEnd = function(e) {
      if (dragging) {
        dragging = false;
        return TouchAcceleration.up();
      }
    };
    
    // We are safe to use passive: false, because we only do nav when standalone
    window.addEventListener("touchstart", touchStart, {
      passive: false
    });
    window.addEventListener("touchmove", touchMove, {
      passive: false
    });
    window.addEventListener("touchend", touchEnd);
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

  Take(["Nav", "Tick"], function(Nav, Tick) {
    var running, vel;
    vel = {
      x: 0,
      y: 0
    };
    running = false;
    Tick(function(t, dt) {
      if (!running) {
        return;
      }
      if (Math.abs(vel.x) > 0.1 || Math.abs(vel.y) > 0.1) {
        Nav.by(vel);
        vel.x /= 1.15;
        return vel.y /= 1.15;
      } else {
        return running = false;
      }
    });
    return Make("TouchAcceleration", {
      move: function(accel) {
        vel.x = accel.x;
        vel.y = accel.y;
        Nav.by(vel);
        return running = false;
      },
      up: function() {
        if (Math.abs(vel.x) > 2 || Math.abs(vel.y) > 2) {
          return running = true;
        }
      }
    });
  });

  Take(["Ease", "Registry", "ScopeCheck", "SVG"], function(Ease, Registry, ScopeCheck, SVG) {
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
            SVG.style(element, "opacity", alpha = Ease.clip(val));
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

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      // These functions don't change the DOM — they just control the scope hierarchy.
      ScopeCheck(scope, "attachScope", "detachScope", "detachAllScopes");
      // These functions change both the DOM and scope hierarchy.
      // They're named to be compatable with the SVG tools.
      ScopeCheck(scope, "append", "prepend", "remove", "removeAllChildren");
      scope.attachScope = function(child, prepend = false) {
        var idCounter, tempID;
        child.parent = scope;
        if (child.id == null) {
          child.id = "child" + (scope.children.length || 0);
        }
        if (scope[child.id] != null) {
          tempID = child.id.replace(/\d/g, "");
          idCounter = 1;
          while (scope[tempID + idCounter] != null) {
            idCounter++;
          }
          child.id = tempID + idCounter;
        }
        scope[child.id] = child;
        if (prepend) {
          return scope.children.unshift(child);
        } else {
          return scope.children.push(child);
        }
      };
      scope.detachScope = function(child) {
        var c, i, m, ref;
        ref = scope.children;
        for (i = m = ref.length - 1; m >= 0; i = m += -1) {
          c = ref[i];
          if (c === child) {
            scope.children.splice(i, 1);
          }
        }
        delete scope[child.id];
        if (child.id.indexOf("child") !== -1) {
          delete child.id;
        }
        return delete child.parent;
      };
      scope.detachAllScopes = function() {
        var child, len, m, ref;
        ref = scope.children;
        for (m = 0, len = ref.length; m < len; m++) {
          child = ref[m];
          delete scope[child.id];
          if (child.id.indexOf("child") !== -1) {
            delete child.id;
          }
          delete child.parent;
        }
        return scope.children = [];
      };
      scope.append = function(child) {
        SVG.append(scope.element, child.element);
        return scope.attachScope(child);
      };
      scope.prepend = function(child) {
        SVG.prepend(scope.element, child.element);
        return scope.attachScope(child, true);
      };
      scope.remove = function(child) {
        SVG.remove(scope.element, child.element);
        return scope.detachScope(child);
      };
      return scope.removeAllChildren = function() {
        SVG.removeAllChildren(scope.element);
        return scope.detachAllScopes();
      };
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

  // This is a special scope processor just for controls,
  // allowing them to be enabled and disabled by animation code.
  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope, props) {
      var enabled;
      if (!props._isControl) {
        return;
      }
      ScopeCheck(scope, "enabled");
      enabled = true;
      Object.defineProperty(scope, 'enabled', {
        get: function() {
          return enabled;
        },
        set: function(val) {
          var ref;
          if (enabled !== val) {
            enabled = val;
            if ((ref = scope.input) != null) {
              ref.enable(enabled);
            }
            if (enabled) {
              scope.alpha = 1;
              return SVG.attrs(scope.element, {
                disabled: null
              });
            } else {
              scope.alpha = 0.3;
              return SVG.attrs(scope.element, {
                disabled: ""
              });
            }
          }
        }
      });
      if (props.enabled === false) {
        return scope.enabled = false;
      }
    });
  });

  Take(["Registry", "ScopeCheck", "SVG"], function(Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var childPathFills, childPathStrokeWidths, childPathStrokes, fill, stroke, strokeWidth;
      ScopeCheck(scope, "stroke", "strokeWidth", "fill");
      childPathStrokes = childPathStrokeWidths = childPathFills = scope.element.querySelectorAll("path");
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
      strokeWidth = null;
      Object.defineProperty(scope, 'strokeWidth', {
        get: function() {
          return strokeWidth;
        },
        set: function(val) {
          var childPathStrokeWidth, len, m;
          if (strokeWidth !== val) {
            SVG.attr(scope.element, "strokeWidth", strokeWidth = val);
            if (childPathStrokeWidths.length > 0) {
              for (m = 0, len = childPathStrokeWidths.length; m < len; m++) {
                childPathStrokeWidth = childPathStrokeWidths[m];
                SVG.attr(childPathStrokeWidth, "strokeWidth", null);
              }
              return childPathStrokeWidths = [];
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

  // Depends on style
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
      scope.linearGradient = function(angle, ...stops) {
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
          Gradient.updateStops(linearGradient, ...stops);
        }
        return scope.fill = `url(#${lGradName})`;
      };
      return scope.radialGradient = function(props, ...stops) {
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
          Gradient.updateStops(radialGradient, ...stops);
        }
        return scope.fill = `url(#${rGradName})`;
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

  // Depends on style
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
            if (scope._setColor != null) {
              return scope._setColor(pressure);
            } else {
              return scope.fill = Pressure(scope.pressure);
            }
          }
        }
      };
      return Object.defineProperty(scope, "pressure", accessors);
    });
  });

  // This processor depends on the Style processor
  Take(["Registry", "ScopeCheck", "Tween"], function(Registry, ScopeCheck, Tween) {
    return Registry.add("ScopeProcessor", function(scope) {
      var tick;
      ScopeCheck(scope, "show", "hide");
      tick = function(v) {
        return scope.alpha = v;
      };
      scope.show = function(duration = 1, target = 1) {
        return Tween(scope.alpha, target, duration, {
          tick: tick,
          ease: "linear"
        });
      };
      return scope.hide = function(duration = 1, target = 0) {
        return Tween(scope.alpha, target, duration, {
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
            throw new Error(`You have ${scope.id}.align = '${val}', but this scope doesn't contain any text or tspan elements.`);
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
            throw new Error(`You have ${scope.id}.text = '${val}', but this scope doesn't contain any text or tspan elements.`);
          }
          if (text !== val) {
            return SVG.attr(textElement, "textContent", text = val);
          }
        }
      });
    });
  });

  // scope.tick
  // An every-frame update function that can be turned on and off by the content creator.
  Take(["Registry", "Tick"], function(Registry, Tick) {
    return Registry.add("ScopeProcessor", function(scope) {
      var running, startTime, tick;
      if (scope.tick == null) {
        return;
      }
      running = true;
      startTime = null;
      
      // Replace the actual scope tick function with a warning
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
      
      // Extract the existing transform value from the element
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
            // skewX = 180/Math.PI * Math.atan2 t.matrix.a * t.matrix.b + t.matrix.c * t.matrix.d, denom
            throw new Error("^ Transform encountered an SVG element with a non-matrix transform");
        }
      } else if ((transformBaseVal != null ? transformBaseVal.numberOfItems : void 0) > 1) {
        console.log(element);
        throw new Error("^ Transform encountered an SVG element with more than one transform");
      }
      applyTransform = function() {
        // TODO: introduce a guard here to check if the value has changed
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

  // Depends on style
  Take(["Voltage", "Registry", "ScopeCheck", "SVG"], function(Voltage, Registry, ScopeCheck, SVG) {
    return Registry.add("ScopeProcessor", function(scope) {
      var accessors, voltage;
      ScopeCheck(scope, "voltage");
      voltage = null;
      accessors = {
        get: function() {
          return voltage;
        },
        set: function(val) {
          if (voltage !== val) {
            voltage = val;
            if (scope._setColor != null) {
              return scope._setColor(voltage);
            } else {
              return scope.fill = Voltage(scope.voltage);
            }
          }
        }
      };
      return Object.defineProperty(scope, "voltage", accessors);
    });
  });

  Take(["Action", "Ease", "Fullscreen", "Mode", "Settings", "Storage"], function(Action, Ease, Fullscreen, Mode, Settings, Storage) {
    var Background, applyLightness, defaultLightness, lightness;
    defaultLightness = .7;
    lightness = defaultLightness;
    applyLightness = function() {
      return Action("Background:Lightness", Ease.linear(lightness, 0, 1, 0.25, 1));
    };
    if (Mode.background === true && Mode.settings) {
      lightness = +Storage("Background");
      if (isNaN(lightness)) {
        lightness = defaultLightness;
      }
      Settings.addSetting("Slider", 1, {
        name: "Background Color",
        value: lightness,
        snaps: [defaultLightness],
        update: function(v) {
          Storage("Background", lightness = v);
          return applyLightness();
        }
      });
    }
    Background = function() {
      if (typeof Mode.background === "string") { // Use a specific color
        return Action("Background:Set", Mode.background);
      } else if (Mode.background === true) { // Use lightness-based background
        return applyLightness();
      } else if (Fullscreen.active()) { // Default — fullscreen
        return Action("Background:Set", "white"); // Default — windowed
      } else {
        return Action("Background:Set", "transparent");
      }
    };
    Make("Background", Background);
    // Run after the scene is ready, to set the initial color for ManifoldBackground
    return Take("SceneReady", Background);
  });

  Take(["Action", "Settings"], function(Action, Settings) {
    var update;
    update = function(active) {
      if (active) {
        return Action("FlowArrows:Show");
      } else {
        return Action("FlowArrows:Hide");
      }
    };
    Settings.addSetting("Switch", 2, {
      name: "Flow Arrows",
      value: true,
      update: update
    });
    return Take("AllReady", function() {
      return update(true);
    });
  });

  Take(["Action", "Settings", "SVG"], function(Action, Settings, SVG) {
    var Background, enterFullscreen, exitFullscreen, fullScreenSwitch, isFullscreen, switchChanged, update;
    // Break circular dependency
    Background = null;
    Take("Background", function(b) {
      return Background = b;
    });
    isFullscreen = function() {
      return (document.fullscreenElement != null) || (document.webkitFullscreenElement != null);
    };
    Make("Fullscreen", {
      active: isFullscreen
    });
    // If we support fullscreen in this browser, add a switch for it
    if (document.fullscreenEnabled || document.webkitFullscreenEnabled) {
      // We can't use the ?() shorthand for these functions because that doesn't work in Safari (possibly elsewhere)
      enterFullscreen = function() {
        if (SVG.svg.requestFullscreen != null) {
          return SVG.svg.requestFullscreen();
        }
        if (SVG.svg.webkitRequestFullscreen != null) {
          return SVG.svg.webkitRequestFullscreen();
        }
      };
      exitFullscreen = function() {
        if (document.exitFullscreen != null) {
          return document.exitFullscreen();
        }
        if (document.webkitExitFullscreen != null) {
          return document.webkitExitFullscreen();
        }
      };
      update = function(e) {
        // Make sure the switch matches the new state
        fullScreenSwitch.setValue(isFullscreen());
        return typeof Background === "function" ? Background() : void 0;
      };
      window.addEventListener("fullscreenchange", update);
      window.addEventListener("webkitfullscreenchange", update);
      // Whenever the switch state changes, update the fullscreen state to match
      switchChanged = function(switchActive) {
        if (switchActive === isFullscreen()) {

        // NOOP — the fullscreen state already matches the switch state
        } else if (switchActive) {
          return enterFullscreen();
        } else {
          return exitFullscreen();
        }
      };
      // Create the switch
      return fullScreenSwitch = Settings.addSetting("Switch", 5, {
        name: "Full Screen",
        value: false,
        update: switchChanged
      });
    }
  });

  Take(["Action", "Settings"], function(Action, Settings) {
    var update;
    update = function(active) {
      return Action("Highlights:Set", active);
    };
    Settings.addSetting("Switch", 3, {
      name: "Highlights",
      value: true,
      update: update
    });
    return Take("AllReady", function() {
      return update(true);
    });
  });

  Take(["Action", "Settings"], function(Action, Settings) {
    var update;
    update = function(active) {
      if (active) {
        return Action("Labels:Show");
      } else {
        return Action("Labels:Hide");
      }
    };
    Settings.addSetting("Switch", 4, {
      name: "Labels",
      value: true,
      update: update
    });
    return Take("AllReady", function() {
      return update(true);
    });
  });

  Take(["Pressure", "Reaction", "Symbol"], function(Pressure, Reaction, Symbol) {
    return Symbol("BackgroundCover", [], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          return Reaction("Background:Set", function(v) {
            return scope.fill = v;
          });
        }
      };
    });
  });

  Take(["Reaction", "Symbol", "SVG"], function(Reaction, Symbol, SVG) {
    return Symbol("ColorContainer", ["colorContainer"], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          return Reaction("Background:Set", function(v) {
            var c, current, l, len, len1, m, n, ref, ref1, ref2, results;
            l = (ref = v.split(", ")[2]) != null ? ref.split("%")[0] : void 0;
            l /= 100;
            l = (l / 2 + .8) % 1;
            ref1 = svgElement.querySelectorAll("[fill]");
            for (m = 0, len = ref1.length; m < len; m++) {
              c = ref1[m];
              current = SVG.attr(c, "fill");
              if (current !== "none" && current !== "transparent") {
                SVG.attr(c, "fill", `hsl(227, 4%, ${l * 100}%)`);
              }
            }
            ref2 = svgElement.querySelectorAll("[stroke]");
            results = [];
            for (n = 0, len1 = ref2.length; n < len1; n++) {
              c = ref2[n];
              current = SVG.attr(c, "stroke");
              if (current !== "none" && current !== "transparent") {
                results.push(SVG.attr(c, "stroke", `hsl(227, 4%, ${l * 100}%)`));
              } else {
                results.push(void 0);
              }
            }
            return results;
          });
        }
      };
    });
  });

  Take(["Pressure", "Symbol"], function(Pressure, Symbol) {
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
            return this.pressure = 0;
          }
        }
      };
    });
  });

  Take(["Pressure", "SVG", "Symbol", "Voltage"], function(Pressure, SVG, Symbol, Voltage) {
    return Symbol("HydraulicLine", [], function(element) {
      var applyColor, fillElms, highlightActive, scope, strip, strokeElms;
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
      applyColor = function(stroke, fill = stroke) {
        var elm, len, len1, m, n;
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
            return applyColor("url(#MidHighlightGradient)", "url(#LightHighlightGradient)");
          } else if (scope.voltage != null) {
            return applyColor(Voltage(scope.voltage));
          } else {
            return applyColor(Pressure(scope.pressure));
          }
        },
        _setColor: function(p) {
          if (highlightActive) {

          // Do nothing
          } else if (scope.voltage != null) {
            return applyColor(Voltage(p));
          } else {
            return applyColor(Pressure(p));
          }
        },
        setup: function() {
          var ref;
          this.pressure = 0;
          // If there's a dashed child of this HydraulicLine, turn it into a pilot line
          return (ref = this.dashed) != null ? ref.dash.pilot() : void 0;
        }
      };
    });
  });

  Take(["Reaction", "Symbol", "SVG"], function(Reaction, Symbol, SVG) {
    return Symbol("Labels", ["labelsContainer"], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          Reaction("Labels:Hide", function() {
            return scope.alpha = false;
          });
          Reaction("Labels:Show", function() {
            return scope.alpha = true;
          });
          return Reaction("Background:Set", function(v) {
            var c, current, l, len, len1, m, n, ref, ref1, ref2, results;
            l = (ref = v.split(", ")[2]) != null ? ref.split("%")[0] : void 0;
            l /= 100;
            l = (l / 2 + .8) % 1;
            ref1 = svgElement.querySelectorAll("[fill]");
            for (m = 0, len = ref1.length; m < len; m++) {
              c = ref1[m];
              current = SVG.attr(c, "fill");
              if (current !== "none" && current !== "transparent") {
                SVG.attr(c, "fill", `hsl(227, 4%, ${l * 100}%)`);
              }
            }
            ref2 = svgElement.querySelectorAll("[stroke]");
            results = [];
            for (n = 0, len1 = ref2.length; n < len1; n++) {
              c = ref2[n];
              current = SVG.attr(c, "stroke");
              if (current !== "none" && current !== "transparent") {
                results.push(SVG.attr(c, "stroke", `hsl(227, 4%, ${l * 100}%)`));
              } else {
                results.push(void 0);
              }
            }
            return results;
          });
        }
      };
    });
  });

  Take(["Ease", "Reaction", "Symbol"], function(Ease, Reaction, Symbol) {
    return Symbol("ManifoldBackground", ["ManifoldBackground"], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          return Reaction("Background:Lightness", function(v) {
            var hue, lightness;
            hue = Ease.linear(v, 0, 1, 227, 218);
            lightness = v * 100;
            lightness += lightness > 50 ? -7 : 7;
            return scope.fill = `hsl(${hue}, 5%, ${lightness}%)`;
          });
        }
      };
    });
  });

  // Config is defined in the config.coffee in every SVGA
  Take(["Config", "ParentData"], function(Config, ParentData) {
    var Mode, embedded, fetchAttribute, isDev;
    embedded = window !== window.top;
    fetchAttribute = function(name) {
      var val;
      if (embedded && (val = ParentData.get(name))) {
        if (val === "" || val === "true") {
          // This isn't ideal, but it is good enough for now
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
    isDev = function() {
      var loc, ref;
      loc = window.top.location;
      if (loc.search.indexOf("dev=false") > 0) {
        // Allow turning off dev mode when running locally
        return false;
      }
      if (loc.search.indexOf("dev=true") > 0) {
        // Allow turning on dev mode when running in prod
        return true;
      }
      // By default, dev mode is active when we have a URL with a port number
      return ((ref = loc.port) != null ? ref.length : void 0) >= 4;
    };
    Mode = {
      get: fetchAttribute,
      background: fetchAttribute("background"),
      dev: isDev(),
      nav: fetchAttribute("nav"),
      embed: embedded,
      settings: fetchAttribute("settings")
    };
    if (Mode.embed) {
      
      // We always disallow nav in embed mode
      Mode.nav = false;
    }
    return Make("Mode", Mode);
  });

  (function() {
    var channel, finishSetup, id, inbox, k, listeners, outbox, port, v;
    if (window === window.top) {
      Make("ParentData", null); // Make sure you check Mode.embed before using ParentData, hey?
      return;
    }
    channel = new MessageChannel();
    port = channel.port1;
    inbox = {};
    outbox = {};
    listeners = [];
    id = window.location.pathname.replace(/^\//, "") + window.location.hash;
    finishSetup = function() {
      finishSetup = null;
      return Make("ParentData", {
        send: function(k, v) {
          if (outbox[k] !== v) {
            outbox[k] = v;
            return port.postMessage(`${k}:${v}`);
          }
        },
        get: function(k) {
          return inbox[k];
        },
        listen: function(cb) {
          listeners.push(cb);
          return cb(inbox);
        }
      });
    };
    port.addEventListener("message", function(e) {
      var cb, len, m, parts, results;
      if (e.data === "INIT") {
        return typeof finishSetup === "function" ? finishSetup() : void 0;
      } else {
        parts = e.data.split(":");
        if (parts.length > 0) {
          inbox[parts[0]] = parts[1];
        }
        results = [];
        for (m = 0, len = listeners.length; m < len; m++) {
          cb = listeners[m];
          results.push(cb(inbox));
        }
        return results;
      }
    });
    window.top.postMessage(`Channel:${id}`, "*", [channel.port2]);
    for (k in outbox) {
      v = outbox[k];
      port.postMessage(`${k}:${v}`);
    }
    return port.start();
  })();

  Take(["Control", "Input", "Resize", "Scope", "SVG", "Vec"], function(Control, Input, Resize, Scope, SVG, Vec) {
    var Nav, Tracer, activeConfig, buildGlow, buildHit, cancelClick, checkForSolution, clickPath, cloneChild, editClick, editing, editingSetupDone, gameClick, getFullPathId, getReaction, hitDefn, hitMoveIn, hitMoveOut, incPath, initializePath, saveConfiguration, setupEditing, setupGame, setupPaths, startClick, stylePath;
    // Nav doesn't exist until after Symbol registration closes, so if we added it to Take,
    // Symbols (like root, in the animation code) wouldn't be able to take Tracer.
    Nav = null;
    Take("Nav", function(N) {
      return Nav = N;
    });
    editing = false;
    editingSetupDone = false;
    activeConfig = null;
    // HELPERS #########################################################################################
    getFullPathId = function(path) {
      var fullId, parent;
      fullId = path.id;
      parent = path.parent;
      while ((parent != null) && parent.id !== "root") {
        fullId = parent.id + "." + fullId;
        parent = parent.parent;
      }
      return `@${fullId}`;
    };
    // SETUP #########################################################################################
    setupPaths = function() {
      var colorIndex, len, len1, len2, m, n, path, q, ref, ref1, set, setIndex;
      ref = activeConfig.paths;
      for (m = 0, len = ref.length; m < len; m++) {
        path = ref[m];
        if (path == null) {
          throw "One of the paths given to Tracer is null";
        }
        if (path.tracer == null) {
          initializePath(path);
        }
        stylePath(path);
      }
      ref1 = activeConfig.solution;
      // For the paths that are part of a solution, set them to the correct color
      for (setIndex = n = 0, len1 = ref1.length; n < len1; setIndex = ++n) {
        set = ref1[setIndex];
        colorIndex = setIndex + 1;
        for (q = 0, len2 = set.length; q < len2; q++) {
          path = set[q];
          path.tracer.desiredClicks = colorIndex;
          if (editing) {
            path.tracer.clickCount = colorIndex;
          }
          stylePath(path);
        }
      }
      return null;
    };
    initializePath = function(path) {
      var calls, child, len, m, ref;
      if (path.tracer != null) {
        return;
      }
      path.tracer = {
        glows: [],
        hits: [],
        clicking: false,
        hovering: false,
        clickCount: 0,
        desiredClicks: 0
      };
      // Sort to top
      path.element.parentNode.appendChild(path.element);
      // Block double-click nav reset
      path.element.setAttribute("block-dbl", true);
      ref = path.children;
      // Build decorations
      for (m = 0, len = ref.length; m < len; m++) {
        child = ref[m];
        buildGlow(path, child);
        buildHit(path, child);
      }
      calls = {
        down: startClick(path),
        drag: cancelClick(path),
        click: clickPath(path)
      };
      return Input(path.element, calls, true, false);
    };
    buildGlow = function(path, child) {
      var scope;
      scope = cloneChild(path, child);
      path.tracer.glows.push(scope);
      return scope.strokeWidth = 3;
    };
    buildHit = function(path, child) {
      var calls, scope;
      scope = cloneChild(path, child, hitDefn);
      path.tracer.hits.push(scope);
      scope.strokeWidth = 10;
      calls = {
        moveIn: hitMoveIn(path),
        moveOut: hitMoveOut(path)
      };
      return Input(scope.element, calls, true, false);
    };
    cloneChild = function(path, child, defn) {
      var elm;
      elm = child.element.cloneNode(true);
      path.element.appendChild(elm);
      return Scope(elm, defn);
    };
    hitDefn = function(elm) {
      var hitTick;
      return {
        tick: hitTick = function() {
          if (Nav != null) {
            return this.strokeWidth = Math.max(3, 20 / Nav.rootScale());
          }
        }
      };
    };
    // STYLE #########################################################################################
    stylePath = function(path) {
      var child, color, colorIndex, glow, hit, isDefault, isHover, isUncolored, len, len1, len2, m, n, q, ref, ref1, ref2, results;
      colorIndex = path.tracer.clickCount % activeConfig.colors.length;
      color = activeConfig.colors[colorIndex] || "#000";
      isUncolored = colorIndex === 0;
      isHover = path.tracer.hovering;
      isDefault = isUncolored && !isHover;
      path.stroke = color;
      ref = path.children;
      for (m = 0, len = ref.length; m < len; m++) {
        child = ref[m];
        child.alpha = (function() {
          switch (false) {
            case !(isUncolored && !isHover):
              return 0;
            case !(isUncolored && isHover):
              return 0;
            case !(!isUncolored && isHover):
              return 1;
            case !(!isUncolored && !isHover):
              return 1;
          }
        })();
      }
      ref1 = path.tracer.glows;
      for (n = 0, len1 = ref1.length; n < len1; n++) {
        glow = ref1[n];
        glow.stroke = color;
        glow.alpha = (function() {
          switch (false) {
            case !(isUncolored && !isHover):
              return .08;
            case !(isUncolored && isHover):
              return .3;
            case !(!isUncolored && isHover):
              return 0;
            case !(!isUncolored && !isHover):
              return 0;
          }
        })();
      }
      ref2 = path.tracer.hits;
      results = [];
      for (q = 0, len2 = ref2.length; q < len2; q++) {
        hit = ref2[q];
        hit.stroke = color;
        hit.alpha = isHover ? .2 : 0.001;
        results.push(hit.alpha = (function() {
          switch (false) {
            case !(isUncolored && !isHover):
              return .001;
            case !(isUncolored && isHover):
              return .07;
            case !(!isUncolored && isHover):
              return .15;
            case !(!isUncolored && !isHover):
              return .001;
          }
        })());
      }
      return results;
    };
    // EVENTS ########################################################################################
    hitMoveIn = function(path) {
      return function() {
        if (!activeConfig) {
          return;
        }
        path.tracer.hovering = true;
        return stylePath(path);
      };
    };
    hitMoveOut = function(path) {
      return function() {
        if (!activeConfig) {
          return;
        }
        path.tracer.hovering = false;
        return stylePath(path);
      };
    };
    startClick = function(path) {
      return function(e) {
        if (!activeConfig) {
          return;
        }
        return path.tracer.clicking = {
          x: e.clientX,
          y: e.clientY
        };
      };
    };
    cancelClick = function(path) {
      return function(e) {
        var d;
        if (!activeConfig) {
          return;
        }
        if (path.tracer.clicking != null) {
          d = Vec.distance(path.tracer.clicking, {
            x: e.clientX,
            y: e.clientY
          });
          if (d >= 5) {
            return path.tracer.clicking = null;
          }
        }
      };
    };
    clickPath = function(path) {
      return function(e) {
        var id;
        if (!activeConfig) {
          return;
        }
        if (path.tracer.clicking == null) {
          return;
        }
        id = getFullPathId(path);
        if (editing) {
          return editClick(path, id, e);
        } else {
          return gameClick(path, id);
        }
      };
    };
    editClick = function(path, id, e) {
      if (e.altKey) {
        return console.log(`Clicked ${id}`);
      } else {
        return incPath(path);
      }
    };
    gameClick = function(path, id) {
      var reaction;
      if (reaction = getReaction(path)) {
        return reaction(path, id);
      } else {
        incPath(path);
        if (checkForSolution(path)) {
          return activeConfig.onWin();
        }
      }
    };
    getReaction = function(path) {
      var len, m, reaction, ref, ref1;
      if (((ref = activeConfig.reactions) != null ? ref.length : void 0) > 0) {
        ref1 = activeConfig.reactions;
        for (m = 0, len = ref1.length; m < len; m++) {
          reaction = ref1[m];
          if (indexOf.call(reaction.paths, path) >= 0) {
            return reaction.fn;
          }
        }
      }
      return null;
    };
    incPath = function(path) {
      path.tracer.clickCount++;
      return stylePath(path);
    };
    // GAMEPLAY ######################################################################################
    setupGame = function() {
      return null;
    };
    checkForSolution = function() {
      var incorrectPaths, len, m, nSets, path, ref;
      incorrectPaths = [];
      nSets = activeConfig.colors.length;
      ref = activeConfig.paths;
      for (m = 0, len = ref.length; m < len; m++) {
        path = ref[m];
        if (path.tracer.clickCount % nSets !== path.tracer.desiredClicks) {
          incorrectPaths.push(path);
        }
      }
      return incorrectPaths.length === 0;
    };
    // EDITING #######################################################################################
    setupEditing = function() {
      var debugPoint;
      editing = true;
      if (editingSetupDone) {
        return;
      }
      editingSetupDone = true;
      Control.label({
        name: "Path Tracer Edit Mode",
        group: "#F80"
      });
      Control.button({
        name: "Copy Solution",
        group: "#F80",
        click: saveConfiguration
      });
      if (Nav != null) {
        Nav.runResize(); // This is needed to make the new panel buttons appear
      }
      debugPoint = Scope(SVG.create("g", SVG.svg));
      debugPoint.debug.point();
      debugPoint.hide(0);
      Resize(function() {
        debugPoint.x = Nav.center().x;
        return debugPoint.y = Nav.center().y;
      });
      window.addEventListener("keydown", function(e) {
        if (e.keyCode === 32) {
          return debugPoint.show(0);
        }
      });
      return window.addEventListener("keyup", function(e) {
        if (e.keyCode === 32) {
          debugPoint.hide(0);
          return console.log(Nav.pos());
        }
      });
    };
    saveConfiguration = function() {
      var c, colorIndex, len, m, nSets, path, ref, solution, text;
      // Sort all selected paths into solution sets
      nSets = activeConfig.colors.length;
      solution = (function() {
        var m, ref, results;
        results = [];
        for (c = m = 0, ref = nSets; (0 <= ref ? m < ref : m > ref); c = 0 <= ref ? ++m : --m) {
          results.push([]);
        }
        return results;
      })();
      ref = activeConfig.paths;
      for (m = 0, len = ref.length; m < len; m++) {
        path = ref[m];
        colorIndex = path.tracer.clickCount % nSets;
        solution[colorIndex].push(path);
      }
      // We don't care about the paths in the default / un-clicked set
      solution.shift();
      // Format the solution sets into coffeescript text
      text = JSON.stringify({
        solution: solution.map(function(paths) {
          return paths.map(getFullPathId);
        })
      });
      // Put the solution coffeescript text onto the clipboard
      return navigator.clipboard.writeText(text).then(function() {
        return console.log("Copied current configuration to clipboard");
      });
    };
    // MAIN ##########################################################################################
    return Make("Tracer", Tracer = {
      edit: function(config) {
        Tracer.stop();
        activeConfig = config; // We should probably clone the config, so we can mutate it without fear
        setupEditing();
        return setupPaths();
      },
      play: function(config) {
        Tracer.stop();
        activeConfig = config; // We should probably clone the config, so we can mutate it without fear
        setupPaths();
        return setupGame();
      },
      stop: function() {
        var len, m, needsStyle, path, ref;
        if (activeConfig != null) {
          if (editing) {
            editing = false;
          }
          ref = activeConfig.paths;
          for (m = 0, len = ref.length; m < len; m++) {
            path = ref[m];
            needsStyle = path.tracer.clickCount !== 0;
            path.tracer.clicking = false;
            path.tracer.hovering = false;
            path.tracer.clickCount = 0;
            path.tracer.desiredClicks = 0;
            if (needsStyle) {
              stylePath(path);
            }
          }
        }
        return activeConfig = null;
      }
    });
  });

  (function() {
    var cbs;
    cbs = [];
    Make("Reaction", function(name, cb) {
      if (cb != null) {
        return (cbs[name] != null ? cbs[name] : cbs[name] = []).push(cb);
      } else {
        throw `Null reference passed to Reaction() with name: ${name}`;
      }
    });
    return Make("Action", function(name, ...args) {
      var cb, len, m, ref;
      if (cbs[name] != null) {
        ref = cbs[name];
        for (m = 0, len = ref.length; m < len; m++) {
          cb = ref[m];
          cb(...args);
        }
      }
      return void 0;
    });
  })();

  Take(["ControlPanel", "ControlPanelLayout", "GUI", "Registry", "Scope", "SVG", "ControlReady"], function(ControlPanel, ControlPanelLayout, {
      ControlPanel: GUI
    }, Registry, Scope, SVG) {
    var Control, addItemToGroup, currentGroup, defn, getGroup, instances, ref, setup, type;
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
      return Control[type] = function(props = {}) {
        var base, elm, group, scope;
        if (typeof props !== "object") {
          console.log(props);
          throw new Error(`Control.${type}(props) takes a optional props object. Got ^^^, which is not an object.`);
        }
        
        // Re-using an existing ID? Just attach to the existing control.
        if ((props.id != null) && (instances[props.id] != null)) {
          if (typeof (base = instances[props.id]).attach === "function") {
            base.attach(props);
          }
          return instances[props.id];
        } else {
          
          // Create a new control
          group = getGroup(props.group);
          elm = ControlPanel.createItemElement(props.parent || group.scope.element);
          
          // We check for this property in some control-specific scope-processors
          props._isControl = true;
          scope = Scope(elm, defn, props);
          addItemToGroup(group, scope);
          if (typeof scope.attach === "function") {
            scope.attach(props);
          }
          
          // We don't want controls to highlight when they're hovered over,
          // so we flag them in a way that highlight can see.
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

  // Ease
  // Unlike other easing functions you'll find through Google, these easing functions are ALMOST human-
  // readable (typographic pun intended). Also, they get called with lots of arguments, rather than the
  // usual four. The reason being.. the four-argument version of these functions assumes your input
  // value never goes below zero, and that you want to pass in deltas (like the duration) rather than
  // specify explicit min and max values (like start-time and end-time). But if you are smart, and go
  // with min/max ranges, then you get to use the easing functions for all sorts of stuff than purely
  // "easing", which is awesome. These functions also take an optional final argument that clips the
  // input between 0 and 1, which is often very helpful.
  (function() {
    var Ease;
    return Make("Ease", Ease = {
      clip: function(input, min = 0, max = 1) {
        return Math.max(min, Math.min(max, input));
      },
      sin: function(input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        var cos, p;
        if (inputMin === inputMax) { // Avoids a divide by zero
          return outputMin;
        }
        if (clip) {
          input = Ease.clip(input, inputMin, inputMax);
        }
        p = (input - inputMin) / (inputMax - inputMin);
        cos = Math.cos(p * Math.PI);
        return (.5 - cos / 2) * (outputMax - outputMin) + outputMin;
      },
      cubic: function(input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        return Ease.power(input, 3, inputMin, inputMax, outputMin, outputMax, clip);
      },
      linear: function(input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        if (inputMin === inputMax) { // Avoids a divide by zero
          return outputMin;
        }
        if (clip) {
          input = Ease.clip(input, inputMin, inputMax);
        }
        input -= inputMin;
        input /= inputMax - inputMin;
        input *= outputMax - outputMin;
        input += outputMin;
        return input;
      },
      power: function(input, power = 1, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        var inputDiff, outputDiff, p;
        if (inputMin === inputMax) { // Avoids a divide by zero
          return outputMin;
        }
        if (clip) {
          input = Ease.clip(input, inputMin, inputMax);
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
      quadratic: function(input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        return Ease.power(input, 2, inputMin, inputMax, outputMin, outputMax, clip);
      },
      quartic: function(input, inputMin = 0, inputMax = 1, outputMin = 0, outputMax = 1, clip = true) {
        return Ease.power(input, 4, inputMin, inputMax, outputMin, outputMax, clip);
      },
      // This is a special easing helper for moving from one value to another.
      // It's sorta halfway between a tween and an ease, so it lives here.
      // You pass in the current value, target value, rate of change (per second), and dT.
      // It returns the new "current" value.
      ramp: function(current, target, rate, dT) {
        var delta;
        delta = target - current;
        return current + (delta >= 0 ? Math.min(rate * dT, delta) : Math.max(-rate * dT, delta));
      }
    });
  })();

  Take(["Tick", "SVGReady"], function(Tick) {
    var avgList, avgWindow, fps, total;
    avgWindow = 1; // average over the past n seconds
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
      fps = avgList.length / total; // will be artifically low for the first second — that's fine
      fps = Math.min(60, fps); // our method is slightly inexact, so sometimes you get numbers over 60 — cap to 60
      if (isNaN(fps)) { // If we drop too low we get NaN — cap to 2
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
      updateStops: function(gradient, ...stops) {
        var attrs, dirty, i, len, len1, m, n, ref, stop;
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
        return gradient; // Composable
      },
      updateProps: function(gradient, props) {
        return SVG.attrs(gradient, props);
      },
      linear: function(name, props = {}, ...stops) {
        var attrs, gradient;
        if (existing[name] != null) {
          throw new Error(`Gradient named ${name} already exists. Please don't create the same gradient more than once.`);
        }
        attrs = typeof props === "object" ? (props.id = name, props) : props === true ? { // Vertical
          id: name,
          x2: 0,
          y2: 1
        } : {
          id: name
        };
        gradient = existing[name] = SVG.create("linearGradient", SVG.defs, attrs);
        Gradient.updateStops(gradient, stops);
        return gradient; // Composable
      },
      radial: function(name, props = {}, ...stops) {
        var gradient;
        if (existing[name] != null) {
          throw new Error(`Gradient named ${name} already exists. Please don't create the same gradient more than once.`);
        }
        existing[name] = true;
        props.id = name;
        gradient = existing[name] = SVG.create("radialGradient", SVG.defs, props);
        Gradient.updateStops(gradient, stops);
        return gradient; // Composable
      }
    });
  });

  Take(["FPS", "Gradient", "Input", "RAF", "Reaction", "SVG", "Tick", "SVGReady"], function(FPS, Gradient, Input, RAF, Reaction, SVG, Tick) {
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
      var props, step;
      if (activeHighlight == null) {
        return;
      }
      step = Math.max(1, Math.round(60 / FPS()));
      if (++counter % step !== 0) {
        return;
      }
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
    });
    Make("Highlight", function(...targets) {
      var activate, active, deactivate, highlights, setup, timeout;
      highlights = [];
      active = false;
      timeout = null;
      setup = function(elm) {
        var doFill, doFunction, doStroke, e, fill, len, m, ref, ref1, ref2, ref3, stroke, width;
        fill = SVG.attr(elm, "fill");
        stroke = SVG.attr(elm, "stroke");
        width = SVG.attr(elm, "stroke-width");
        doFill = (fill != null) && fill !== "none" && fill !== "transparent";
        doStroke = (stroke != null) && stroke !== "none" && stroke !== "transparent";
        doFunction = ((ref = elm._scope) != null ? ref._highlight : void 0) != null;
        if (doFunction) {
          highlights.push(e = {
            elm: elm,
            function: elm._scope._highlight
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
          if (doStroke) {
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
          activeHighlight = deactivate; // Set this to be the new active highlight
          timeout = setTimeout(deactivate, 4000);
          for (m = 0, len = highlights.length; m < len; m++) {
            h = highlights[m];
            if (h.dontHighlightOnHover && currentTarget.element === h.elm) {

            // skip
            } else if (h.function != null) {
              h.function(true);
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
            if (h.function != null) {
              h.function(false);
            } else {
              SVG.attrs(h.elm, h.attrs);
            }
          }
        }
        return void 0;
      };
      // Delay running the Highlight setup code by one frame so that if fills / strokes are changed
      // by the @tick() function (eg: an @linearGradient is created), we can capture those changes.
      // See: https://github.com/cdig/svga/issues/133
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
          t = target.element || target; // Support both scopes and elements
          
          // Since setting up Highlight has a cost to it, we do some extra bookkeeping to make sure it's not happening every frame.
          if (t._HighlighterSetupCount == null) {
            t._HighlighterSetupCount = 0;
          }
          if (t._HighlighterSetupCount < 100) { // If we see this element more than 100 times, we're probably inside a tick
            t._HighlighterSetupCount++;
            setup(t);
          } else if (!t._HighlighterSetupCountWarned) {
            t._HighlighterSetupCountWarned = true;
            console.log("Warning: it looks like you're setting up Highlighter every frame. Don't do that.");
          }
        }
        for (n = 0, len1 = targets.length; n < len1; n++) {
          target = targets[n];
          t = target.element || target; // Support both scopes and elements
          if (!t._Highlighter) {
            t._Highlighter = true;
            // Handle Mouse and Touch separately, for better perf
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

  Take("SVG", function(SVG) {
    return Make("Input", function(elm, calls, mouse = true, touch = true, options = {}) {
      var api, down, enabled, eventInside, move, out, over, prepTouchEvent, resetState, state, touchListenerOptions, touchmove, touchstart, up;
      enabled = true;
      state = null;
      // Thanks, Chrome..v_v
      touchListenerOptions = {
        passive: !options.blockScroll
      };
      // Thanks, iOS.. v_v
      eventInside = function(e) {
        var ref;
        if (((ref = e.touches) != null ? ref.length : void 0) > 0) {
          e = e.touches[0];
        }
        return e.target === SVG.svg || SVG.svg.contains(e.target);
      };
      resetState = function() {
        return state = {
          down: false,
          over: false,
          touch: false,
          clicking: false,
          captured: false,
          deltaX: 0,
          deltaY: 0,
          lastX: 0, // These are used to compute deltas..
          lastY: 0 // and to avoid repeat unchanged move events on IE
        };
      };
      resetState();
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
            if (options.blockScroll && state.touch) {
              e.preventDefault();
            }
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
      // MOUSE #####################################################################################
      if (mouse) {
        document.addEventListener("mousedown", function(e) {
          if (!enabled) {
            return;
          }
          if (e.button !== 0) {
            return;
          }
          if (state.touch) {
            return;
          }
          return down(e);
        });
        // Windows fires this event every tick when touch-dragging, even when the input doesn't move?
        // Only add the move listener if we need it, to avoid the perf cost
        if ((calls.move != null) || (calls.drag != null) || (calls.moveOther != null) || (calls.dragOther != null)) {
          document.addEventListener("mousemove", function(e) {
            if (!enabled) {
              return;
            }
            if (state.touch) {
              return;
            }
            return move(e);
          });
        }
        document.addEventListener("mouseup", function(e) {
          if (!enabled) {
            return;
          }
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
            if (!enabled) {
              return;
            }
            if (state.touch) {
              return;
            }
            return out(e);
          });
        }
        if (elm != null) {
          elm.addEventListener("mouseenter", function(e) {
            if (!enabled) {
              return;
            }
            if (state.touch) {
              return;
            }
            return over(e);
          });
        }
      }
      // TOUCH #####################################################################################
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
        touchstart = function(e) {
          if (!enabled) {
            return;
          }
          state.captured = null;
          prepTouchEvent(e);
          return down(e);
        };
        document.addEventListener("touchstart", touchstart, touchListenerOptions);
        // Windows fires this event every tick when touch-dragging, even when the input doesn't move?
        // Only add the move listener if we need it, to avoid the perf cost
        if ((calls.move != null) || (calls.drag != null) || (calls.moveOther != null) || (calls.dragOther != null) || (calls.moveIn != null) || (calls.dragIn != null) || (calls.moveOut != null) || (calls.dragOut != null)) {
          touchmove = function(e) {
            if (!enabled) {
              return;
            }
            prepTouchEvent(e);
            return move(e);
          };
          document.addEventListener("touchmove", touchmove, touchListenerOptions);
        }
        document.addEventListener("touchend", function(e) {
          if (!enabled) {
            return;
          }
          if (!eventInside(e)) { // Without this, the Back To Menu button breaks due to our preventDefault call below
            return;
          }
          prepTouchEvent(e);
          e.preventDefault(); // This avoids redundant mouse events, which double-fire click handlers
          up(e);
          return state.touch = false;
        });
        document.addEventListener("touchcancel", function(e) {
          if (!enabled) {
            return;
          }
          prepTouchEvent(e);
          up(e);
          return state.touch = false;
        });
      }
      return api = {
        state: state,
        resetState: resetState,
        enable: function(_enabled) {
          enabled = _enabled;
          if (!enabled) {
            return resetState();
          }
        }
      };
    });
  });

  // KeyMe is a quick way to add keyboard actions without having to manage events.
  // It also exposes a nice map of currently pressed keys with the "pressing" property.
  // You can add handlers for "any"-key presses/releases, too.
  // And it automatically circumvents the key repeat rate, so you only get one call per press. Presto!
  // Hey, maybe also does shortcuts (aka: chords) too? Woo!
  // Note — shortcuts only work with 1 modifier. Command-g, perfect. Command-shift-g, no.
  (function() {
    var KeyMe, KeyNames, actionize, downHandlers, getModifier, handleKey, keyDown, keyUp, runCallbacks, upHandlers;
    downHandlers = {};
    upHandlers = {};
    
    // Give a keyname or keycode, and an options object with props for down, up, and/or modifier
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
    
    // Register a down/up handler for when you press any key
    KeyMe.any = function(down, up) {
      return actionize(down, up, "any");
    };
    
    // Register a down/up handler for a given character
    KeyMe.char = function(char, down, up) {
      return actionize(down, up, char);
    };
    
    // Register a down/up handler for a given modifier+character
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
    
    // NOT SURE IF WE STILL NEED THIS:
    // keyUp e if e.ctrlKey # Pressing a Command key shortcut doesn't release properly, so we need to release it now
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
      if (e.shiftKey) { // If we support shift, then uppercase chars might not work — need to test
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
      61: "equals", // FF
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
      173: "minus", // FF
      187: "equals", // Safari/Chrome
      188: "comma",
      189: "minus", // Safari/Chrome
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
    Pressure = function(pressure, alpha = 1) {
      var green;
      switch (false) {
        
          // Pass-through for string values
        case typeof pressure !== "string":
          return pressure;
        
          // Schematic — black
        case pressure !== Pressure.black:
          return renderString(0, 0, 0, alpha);
        
          // Schematic — white
        case pressure !== Pressure.white:
          return renderString(255, 255, 255, alpha);
        // Vacuum pressure - purple
        case pressure !== Pressure.vacuum:
          return renderString(255, 0, 255, alpha);
        
          // Zero pressure - light blue - also non-charged drain lines
        case pressure !== Pressure.atmospheric:
          return renderString(0, 153, 255, alpha);
        
          // Zero pressure - blue - also charged drain lines
        case pressure !== Pressure.drain:
          return renderString(0, 0, 255, alpha);
        
          // Electric
        case pressure !== Pressure.electric:
          return renderString(0, 218, 255, alpha);
        
          // Magnetic
        case pressure !== Pressure.magnetic:
          return renderString(141, 2, 155, alpha);
        
          // Normal - yellow to orange (102 green)
        case !(pressure < Pressure.med):
          green = Pressure.med - pressure;
          green *= 153 / (Pressure.med - 1);
          green += 102;
          return renderString(255, green | 0, 0, alpha);
        
          // Normal - orange (102 green) to red
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
        return `rgb(${r},${g},${b})`;
      } else {
        return `rgba(${r},${g},${b},${a})`;
      }
    };
    return Make("Pressure", Pressure);
  })();

  // RAF is used for 1-time requestAnimationFrame callbacks.
  // For every-frame requestAnimationFrame callbacks, use system/tick.coffee
  (function() {
    var aboutToRun, allReady, attemptToRun, callbacksByPriority, run, runRequested;
    allReady = false;
    runRequested = false;
    aboutToRun = false;
    callbacksByPriority = [[], []]; // Assume 2 priorities will be used in most cases
    run = function(time) {
      var callbacks, cb, len, len1, m, n, priority;
      aboutToRun = false;
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
    attemptToRun = function() {
      if (allReady && runRequested) {
        if (!aboutToRun) {
          aboutToRun = true;
          return requestAnimationFrame(run);
        }
      }
    };
    Take("AllReady", function() {
      allReady = true;
      return attemptToRun();
    });
    return Make("RAF", function(cb, ignoreDuplicates = false, priority = 0) {
      var c, len, m, ref;
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
      runRequested = true;
      attemptToRun();
      return cb; // Composable
    });
  })();

  
    // The Registry allows us to advertise the existence of global maps and arrays of stuff,
  // with explicit control over when things can be registered and when they can be requested.
  // If you register something after registration closes, or request something before it closes,
  // you get slapped on the wrist.
  (function() {
    var Registry, closed, named, unnamed;
    named = {};
    unnamed = {};
    closed = {};
    return Make("Registry", Registry = {
      add: function(type, item) {
        if (closed[type]) {
          console.log(item);
          throw new Error(`^^^ This ${type} was registered too late.`);
        }
        return (unnamed[type] != null ? unnamed[type] : unnamed[type] = []).push(item);
      },
      all: function(type, byName = false) {
        if (!closed[type]) {
          throw new Error(`Registry.all(${type}, ${byName}) was called before registration closed.`);
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
          throw new Error(`^^^ This ${type} named \"${name}\" was registered too late.`);
        }
        if (((ref = named[type]) != null ? ref[name] : void 0) != null) {
          console.log(item);
          throw new Error(`^^^ This ${type} is using the name \"${name}\", which is already in use.`);
        }
        return (named[type] != null ? named[type] : named[type] = {})[name] = item;
      },
      get: function(type, name) {
        if (!closed[type]) {
          throw new Error(`Registry.get(${type}, ${name}) was called before registration closed.`);
        }
        return named[type][name];
      },
      closeRegistration: function(type) {
        return closed[type] = true;
      }
    });
  })();

  Make("ScopeCheck", function(scope, ...props) {
    var len, m, prop;
    for (m = 0, len = props.length; m < len; m++) {
      prop = props[m];
      if (!(scope[prop] != null)) {
        continue;
      }
      console.log(scope.element);
      throw new Error(`^ @${prop} is a reserved name. Please choose a different name for your child/property \"${prop}\".`);
    }
    return void 0;
  });

  // This is a very minimal wrapper around localStorage.
  // You are expected to do your own type conversions when getting values back.
  Make("Storage", Storage = function(k, v) {
    if (v != null) {
      return window.top.localStorage["SVGA-" + k] = v.toString();
    } else {
      return window.top.localStorage["SVGA-" + k];
    }
  });

  // These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
  // They're not to be used by content, since they might endure breaking changes at any time.
  Take("DOMContentLoaded", function() {
    var CheckSVGReady, SVG, SVGReady, attrNames, defs, propNames, root, svg, svgNS, xlinkNS;
    
    // We give the main SVG an id in cd-core's gulpfile, so that we know which SVG to target.
    // There's only ever one SVGA in the current context, but there might be other SVGs
    // (eg: the header logo if this is a standalone deployed SVGA).
    // Also, we can't use getElementById because gulp-rev-all thinks it's a URL *facepalm*
    svg = document.querySelector("svg#svga");
    defs = svg.querySelector("defs");
    root = svg.getElementById("root");
    svgNS = "http://www.w3.org/2000/svg";
    xlinkNS = "http://www.w3.org/1999/xlink";
    
    // This is used to distinguish props from attrs, so we can set both with SVG.attr
    propNames = {
      textContent: true
    };
    // additional prop names will be listed here as needed

    // This is used to cache normalized keys, and to provide defaults for keys that shouldn't be normalized
    attrNames = {
      gradientUnits: "gradientUnits",
      viewBox: "viewBox",
      SCOPE: "SCOPE",
      SYMBOL: "SYMBOL"
    };
    // additional attr names will be listed here as needed

    // We want to wait until SVGReady fires before we change the structure of the DOM.
    // However, we can't just Take "SVGReady" at the top, because other systems want
    // to use these SVG tools in safe, non-structural ways before SVGReady has fired.
    // So we do this:
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
        return elm; // Composable
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
        return elm; // Composable
      },
      append: function(parent, child) {
        if (!CheckSVGReady()) {
          throw new Error("SVG.append() called before SVGReady");
        }
        parent.appendChild(child);
        return child; // Composable
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
        return child; // Composable
      },
      remove: function(parent, child) {
        if (!CheckSVGReady()) {
          throw new Error("SVG.remove() called before SVGReady");
        }
        parent.removeChild(child);
        return child;
      },
      removeAllChildren: function(parent) {
        var results;
        if (!CheckSVGReady()) {
          throw new Error("SVG.removeAllChildren() called before SVGReady");
        }
        results = [];
        while (parent.children.length > 0) {
          results.push(parent.removeChild(parent.firstChild));
        }
        return results;
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
        return elm; // Composable
      },
      attr: function(elm, k, v) {
        var base, ns;
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
        if (v === void 0) { // Read
          // Note that we only do DOM->cache on a read call (not on a write call),
          // to slightly avoid intermingling DOM reads and writes, which causes thrashing.
          return (base = elm._SVG_attr)[k] != null ? base[k] : base[k] = elm.getAttribute(k);
        }
        if (elm._SVG_attr[k] === v) { // cache hit — bail
          return v;
        }
        elm._SVG_attr[k] = v; // update cache
        if (propNames[k] != null) {
          return elm[k] = v;
        }
        ns = k === "xlink:href" ? xlinkNS : null;
        k = attrNames[k] != null ? attrNames[k] : attrNames[k] = k.replace(/([A-Z])/g, "-$1").toLowerCase(); // Normalize camelCase into kebab-case
        if (v != null) {
          elm.setAttributeNS(ns, k, v); // set DOM attribute
// v is explicitly set to null (not undefined)
        } else {
          elm.removeAttributeNS(ns, k); // remove DOM attribute
        }
        return v; // Not Composable
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
        return elm; // Composable
      },
      style: function(elm, k, v) {
        var base;
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
          return (base = elm._SVG_style)[k] != null ? base[k] : base[k] = elm.style[k];
        }
        if (elm._SVG_style[k] !== v) {
          elm.style[k] = elm._SVG_style[k] = v;
        }
        return v; // Not Composable
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

  // Tick is used for every-frame requestAnimationFrame callbacks.
  // For 1-time requestAnimationFrame callbacks, use system/raf.coffee
  Take(["Mode", "ParentData", "RAF"], function(Mode, ParentData, RAF) {
    var callbacks, internalTime, maximumDt, tick, wallTime;
    // We go all the way down to 2 FPS, but no lower, to avoid weirdness if the JS thread is paused.
    // Below 2 FPS, we'll start to get temporal skew where the internal time and the wall time diverge.
    maximumDt = 0.5;
    callbacks = [];
    wallTime = ((typeof performance !== "undefined" && performance !== null ? performance.now() : void 0) || 0) / 1000;
    internalTime = 0;
    RAF(tick = function(t) {
      var cb, dt, len, m;
      dt = Math.min(t / 1000 - wallTime, maximumDt);
      wallTime = t / 1000;
      if (!(Mode.embed && ParentData.get("disabled") === "true")) {
        internalTime += dt;
        for (m = 0, len = callbacks.length; m < len; m++) {
          cb = callbacks[m];
          cb(internalTime, dt);
        }
      }
      return RAF(tick);
    });
    return Make("Tick", function(cb, ignoreDuplicates = false) {
      var c, len, m;
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
      return cb; // Composable
    });
  });

  
  // These are Ivan's SVG tools. They're private APIs, part of the implementation of SVGA.
  // They're not to be used by content, since they might endure breaking changes at any time.
  // They may be used by Controls, since those are a more advanced feature of SVGA.
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
          class: "Debug",
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
          SVG.attr(wrapper, "transform", `translate(${v.x},${v.y}) rotate(${v.r * 360}) scale(${v.sx},${v.sy})`);
          return SVG.attr(elm, "transform", `translate(${-v.ox},${-v.oy})`);
        }
      };
      return elm; // Composable
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
        // The order in which these are applied is super important.
        // If we change the order, it'll change the outcome of everything that uses this to do more than one operation per call.
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
      return elm; // Composable
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
        // The order in which these are applied is super important.
        // If we change the order, it'll change the outcome of everything that uses this to do more than one operation per call.
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
      return elm; // Composable
    };
    TRS.move = function(elm, x = 0, y = 0) {
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.move");
      }
      return TRS.abs(elm, {
        x: x,
        y: y // Composable
      });
    };
    TRS.rotate = function(elm, r = 0) {
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.rotate");
      }
      return TRS.abs(elm, {
        r: r // Composable
      });
    };
    TRS.scale = function(elm, sx = 1, sy = sx) {
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.scale");
      }
      return TRS.abs(elm, {
        sx: sx,
        sy: sy // Composable
      });
    };
    TRS.origin = function(elm, ox = 0, oy = 0) {
      if (elm._trs == null) {
        console.log(elm);
        throw new Error("^ Non-TRS element passed to TRS.origin");
      }
      return TRS.abs(elm, {
        ox: ox,
        oy: oy // Composable
      });
    };
    return Make("TRS", TRS);
  });

  // Keep this in sync with Tween in LBS
  Take(["Ease", "Tick"], function(Ease, Tick) {
    var Tween, clone, dist, gc, getEaseFn, getKeys, skipGC, timeScale, tweens;
    timeScale = 1;
    tweens = [];
    skipGC = false;
    Make("Tween", Tween = function(from, to, time, props = {}) {
      var k, keys, tween, v;
      // This object will hold all the state for this tween
      tween = {};
      // The 4th arg can be a tick function or an options object
      if (typeof props === "function") {
        tween.tick = props;
      } else {
// Copy to avoid mutating props, since we don't own it
        for (k in props) {
          v = props[k];
          tween[k] = v;
        }
      }
      
      // from/to can be numbers or objects. Internally, we'll work with objects.
      tween.multi = typeof from === "object";
      // If you don't provide a tick function, we'll assume we're mutating the from object.
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
      tween.delay = Math.max(0, tween.delay || 0);
      tween.completed = false;
      tween.cancelled = false;
      // Scale all time-affecting values
      tween.time *= timeScale;
      tween.pos *= timeScale;
      tween.delay *= timeScale;
      // Now is a great time to do some GC
      gc(tween.tick, tween.from);
      tweens.push(tween);
      return tween; // Composable
    });
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
        return Ease[given] || (function() {
          throw new Error(`Tween: \"${given}\" is not a valid ease type.`);
        })();
      } else if (typeof given === "function") {
        return given;
      } else {
        return Ease.cubic;
      }
    };
    gc = function(tick, from) {
      if (skipGC) { // Don't GC if we're in the middle of a tick!
        return;
      }
      tweens = tweens.filter(function(tween) {
        if (tween.completed) {
          return false;
        }
        if (tween.cancelled) {
          return false;
        }
        if ((tick != null) && tick === tween.tick) { // this makes interruptions work normally
          return false;
        }
        if ((from != null) && from === tween.from) { // this makes interruptions work with mutate
          return false;
        }
        return true;
      });
      return null;
    };
    Tween.cancel = function(...tweensToCancel) {
      var len, m, tween;
      for (m = 0, len = tweensToCancel.length; m < len; m++) {
        tween = tweensToCancel[m];
        if (tween != null) {
          tween.cancelled = true;
        }
      }
      return gc(); // Aww sure, let's do a GC!
    };
    Tween.timeScale = function(ts) {
      if (ts != null) {
        timeScale = ts;
      }
      return timeScale;
    };
    return Tick(function(t, dt) {
      var e, k, len, len1, m, n, ref, remainingDt, tween, v;
      skipGC = true; // It's probably not safe to GC in the middle of our tick loop
      for (m = 0, len = tweens.length; m < len; m++) {
        tween = tweens[m];
        if (!(!tween.cancelled)) {
          continue;
        }
        remainingDt = dt;
        if (tween.delay > 0) {
          tween.delay -= dt;
          if (tween.delay < 0) {
            remainingDt = -tween.delay;
          }
        }
        if (tween.delay <= 0) {
          tween.pos = tween.time <= 0 ? 1 : Math.min(1, tween.pos + remainingDt / tween.time);
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
      }
      // Hey, another great time to do some GC!
      skipGC = false;
      return gc();
    });
  });

  Take([], function() {
    var Vec;
    return Make("Vec", Vec = {
      angle: function(a, b) {
        return Math.atan2(b.y - a.y, b.x - a.x);
      },
      distance: function(a, b) {
        var dx, dy;
        dx = b.x - a.x;
        dy = b.y - a.y;
        return Math.sqrt(dx * dx + dy * dy);
      }
    });
  });

  Take("Ease", function(Ease) {
    var Voltage, renderHSLString, renderString;
    Voltage = function(voltage, alpha = 1) {
      var h;
      switch (false) {
        // Pass-through for string values
        case typeof voltage !== "string":
          return voltage;
        // Schematic — black
        case voltage !== Voltage.black:
          return renderString(0, 0, 0, alpha);
        // Schematic — white
        case voltage !== Voltage.white:
          return renderString(255, 255, 255, alpha);
        // Legacy Electric
        case voltage !== Voltage.electric:
          return renderString(0, 218, 255, alpha);
        // Magnetic
        case voltage !== Voltage.magnetic:
          return renderString(141, 2, 155, alpha);
        // Zero voltage
        case voltage !== Voltage.zero:
          return renderString(0, 0, 0, alpha);
        default:
          // Normal — green to blue
          h = Ease.linear(voltage, Voltage.min, Voltage.max, 100, 180);
          return renderHSLString(h, 100, 50, alpha);
      }
    };
    Voltage.black = 101;
    Voltage.white = -101;
    Voltage.ground = 0;
    Voltage.zero = 0;
    Voltage.min = 1;
    Voltage.med = 50;
    Voltage.max = 100;
    Voltage.electric = 1000;
    Voltage.magnetic = 1001;
    renderString = function(r, g, b, a) {
      if (a >= .99) {
        return `rgb(${r},${g},${b})`;
      } else {
        return `rgba(${r},${g},${b},${a})`;
      }
    };
    renderHSLString = function(h, s, l, a) {
      if (a >= .99) {
        return `hsl(${h},${s}%,${l}%)`;
      } else {
        return `hsla(${h},${s}%,${l}%,${a})`;
      }
    };
    return Make("Voltage", Voltage);
  });

  Take("Tween", function(Tween) {
    return Make("Wait", function(delay, next) {
      return Tween(0, 0, 0, {
        delay: delay,
        then: next
      });
    });
  });

  (function() {
    var WrapText;
    // This is a basic text-wrapping utility that works fine for monospace,
    // but does not account for text metrics with variable width fonts.
    return Make("WrapText", WrapText = function(string, maxLineLength) {
      var currentLine, currentWord, i, len, line, lineLength, lines, m, words;
      if (!((string != null) && string.length > 0)) {
        return [];
      }
      lines = [];
      currentLine = 0;
      lineLength = 0;
      words = string.split(" ");
      while (words.length > 0) {
        currentWord = words.shift();
        // If there's already stuff on the current line,
        // and the current word would push us past the right edge,
        // start a new line
        if ((lines[currentLine] != null) && lineLength + currentWord.length > maxLineLength) {
          currentLine++;
        }
        // If the current line is empty, set it up
        if (!lines[currentLine]) {
          lines[currentLine] = [];
          lineLength = 0;
        }
        // Add the current word to the current line
        lines[currentLine].push(currentWord);
        // Update the length of the current line
        lineLength += currentWord.length;
        if (lines[currentLine].length > 1) {
          // Also count spaces between words
          lineLength += 1;
        }
      }
      for (i = m = 0, len = lines.length; m < len; i = ++m) {
        line = lines[i];
        lines[i] = line.join(" ");
      }
      return lines;
    });
  })();

}).call(this);
