(function() {
  var Arrow, ArrowsContainer, Edge, Mask, Segment, getParentInverseTransform,
    slice = [].slice,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

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
      return Take(["TopBarReady", "ControlPanelReady"], function() {
        return svg.style.opacity = 1;
      });
    });
  });

  Take(["Animation", "FlowArrows", "Style", "Symbol", "Transform"], function(Animation, FlowArrows, Style, Symbol, Transform) {
    var ScopeBuilder, buildScope, getSymbol;
    Make("ScopeBuilder", ScopeBuilder = function(target, parentScope) {
      var len, m, ref, scope, subTarget;
      if (parentScope == null) {
        parentScope = null;
      }
      scope = buildScope(target.name, target.elm, parentScope);
      ref = target.sub;
      for (m = 0, len = ref.length; m < len; m++) {
        subTarget = ref[m];
        ScopeBuilder(subTarget, scope);
      }
      return scope;
    });
    buildScope = function(instanceName, element, parentScope) {
      var scope, symbol;
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
      scope.FlowArrows = FlowArrows;
      if (scope.getElement == null) {
        scope.getElement = function() {
          throw "scope.getElement() has been removed from SVGA. Please use scope.element instead.";
        };
      }
      if (scope.style == null) {
        scope.style = Style(scope);
      }
      Transform(scope);
      Animation(scope);
      if (parentScope == null) {
        if (scope.root == null) {
          scope.root = scope;
        }
      } else {
        if (scope.root == null) {
          scope.root = parentScope.root;
        }
        if (instanceName !== "DefaultElement") {
          if (parentScope[instanceName] == null) {
            parentScope[instanceName] = scope;
          }
        }
        parentScope.children.push(scope);
      }
      return scope;
    };
    return getSymbol = function(instanceName) {
      var symbol;
      if (symbol = Symbol.forInstanceName(instanceName)) {
        return symbol;
      } else if ((instanceName != null ? instanceName.indexOf("Line") : void 0) > -1) {
        return Symbol.forSymbolName("HydraulicLine");
      } else {
        return Symbol.forSymbolName("DefaultElement");
      }
    };
  });

  (function() {
    var SVGCrawler;
    return Make("SVGCrawler", SVGCrawler = function(elm) {
      var childElm, childNodes, len, m, name, ref, target;
      name = elm === document.rootElement ? "root" : (ref = elm.getAttribute("id")) != null ? ref.split("_")[0] : void 0;
      target = {
        name: name,
        elm: elm,
        sub: []
      };
      childNodes = Array.prototype.slice.call(elm.childNodes);
      for (m = 0, len = childNodes.length; m < len; m++) {
        childElm = childNodes[m];
        if (childElm instanceof SVGGElement) {
          target.sub.push(SVGCrawler(childElm));
        }
      }
      return target;
    });
  })();

  Take(["Action", "ControlPanel", "Dispatch", "Ease", "Global", "FlowArrows", "HydraulicPressure", "Mask", "PointerInput", "Reaction", "Symbol", "TopBar"], function(Action, ControlPanel, Dispatch, Ease, Global, FlowArrows, HydraulicPressure, Mask, PointerInput, Reaction, Symbol, TopBar) {
    var SVGA;
    Make("SVGAnimation", function() {
      throw "SVGAnimation is no longer a thing. Remove SVGAnimation from your Takes, and delete the word 'SVGAnimation' from your code. Stuff should work.";
    });
    Make("SVGMask", function() {
      throw "SVGMask is no longer a thing. Please Take \"SVGA\" and use SVGA.mask instead.";
    });
    Make("SVGA", SVGA = {
      action: Action,
      arrows: FlowArrows,
      control: ControlPanel.addControl,
      dispatch: Dispatch,
      ease: Ease,
      global: Global,
      input: PointerInput,
      mask: Mask,
      pressure: HydraulicPressure,
      reaction: Reaction,
      symbol: Symbol,
      topbar: TopBar.init
    });
    return Take("root", function(root) {
      return SVGA.root = root;
    });
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

  Take(["PointerInput", "Resize", "SVG", "TRS"], function(PointerInput, Resize, SVG, TRS) {
    var ControlPanel, bg, controlPanel, elements, resize, topbarHeight;
    topbarHeight = 48;
    elements = [];
    controlPanel = TRS(SVG.create("g", SVG.root, {
      "class": "ControlPanel"
    }));
    bg = SVG.create("rect", controlPanel, {
      "class": "BG"
    });
    Resize(resize = function() {
      var panelWidth;
      panelWidth = Math.ceil(5 * Math.sqrt(window.innerWidth));
      SVG.attr(bg, "width", panelWidth);
      SVG.attr(bg, "height", window.innerHeight - topbarHeight);
      TRS.move(controlPanel, window.innerWidth - panelWidth, topbarHeight);
      if (!Take("ControlPanelReady")) {
        return Make("ControlPanelReady");
      }
    });
    return Make("ControlPanel", ControlPanel = {
      addControl: function(props) {
        if (props.type != null) {
          return Take("Controls:" + props.type, function(fn) {
            var control;
            return control = fn(props);
          });
        } else {
          console.log(props);
          throw "^ You must include a 'type' property when creating an SVGA.control instance";
        }
      }
    });
  });

  Take(["PointerInput", "Resize", "SVG", "TRS"], function(PointerInput, Resize, SVG, TRS) {
    var TopBar, bg, buttonPad, construct, container, elements, iconPad, inited, offsetX, resize, topBar, topBarHeight;
    topBarHeight = 48;
    buttonPad = 30;
    iconPad = 6;
    elements = {};
    offsetX = 0;
    inited = false;
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
    resize = function() {
      var base, elm, len, m;
      SVG.attrs(bg, {
        width: window.innerWidth
      });
      TRS.move(container, window.innerWidth / 2 - offsetX / 2);
      for (m = 0, len = elements.length; m < len; m++) {
        elm = elements[m];
        if (typeof (base = elm.scope).resize === "function") {
          base.resize();
        }
      }
      if (!Take("TopBarReady")) {
        return Make("TopBarReady");
      }
    };
    construct = function(i, name, scope) {
      var buttonWidth, iconRect, iconScale, iconX, iconY, source, textRect, textX;
      source = document.getElementById(name.toLowerCase());
      if (source == null) {
        throw "TopBar icon not found for id: #" + name;
      }
      scope.element = TRS(SVG.create("g", container, {
        "class": "ui Element"
      }));
      elements[name] = {
        element: scope.element,
        i: i,
        name: name,
        scope: scope
      };
      if (scope.bg == null) {
        scope.bg = SVG.create("rect", scope.element, {
          "class": "BG",
          height: topBarHeight
        });
      }
      if (scope.icon == null) {
        scope.icon = TRS(SVG.clone(source, scope.element));
      }
      if (scope.text == null) {
        scope.text = TRS(SVG.create("text", scope.element, {
          "font-family": "Lato",
          "font-size": 14,
          fill: "#FFF",
          textContent: name.toUpperCase()
        }));
      }
      iconRect = scope.icon.getBoundingClientRect();
      textRect = scope.text.getBoundingClientRect();
      iconScale = Math.min((topBarHeight - iconPad * 2) / iconRect.width, (topBarHeight - iconPad * 2) / iconRect.height);
      iconX = buttonPad;
      iconY = topBarHeight / 2 - iconRect.height * iconScale / 2;
      textX = buttonPad + iconRect.width * iconScale + iconPad;
      buttonWidth = textX + textRect.width + buttonPad;
      TRS.abs(scope.icon, {
        x: iconX,
        y: iconY,
        scale: iconScale
      });
      TRS.move(scope.text, textX, topBarHeight / 2 + textRect.height / 2 - 3);
      SVG.attrs(scope.bg, {
        width: buttonWidth
      });
      TRS.move(scope.element, offsetX);
      offsetX += buttonWidth;
      if (typeof scope.setup === "function") {
        scope.setup(scope.element);
      }
      if (scope.click != null) {
        return PointerInput.addClick(scope.element, scope.click);
      }
    };
    return Make("TopBar", TopBar = {
      init: function() {
        var name, names, prefixedNames;
        names = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        if (inited) {
          throw "TopBar.init was called more than once.";
        }
        inited = true;
        prefixedNames = (function() {
          var len, m, results;
          results = [];
          for (m = 0, len = names.length; m < len; m++) {
            name = names[m];
            results.push("TopBar:" + name);
          }
          return results;
        })();
        return Take(prefixedNames, function() {
          var i, len, m, scopes;
          scopes = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          for (i = m = 0, len = names.length; m < len; i = ++m) {
            name = names[i];
            construct(i, name, scopes[i]);
          }
          return Resize(resize);
        });
      }
    });
  });

  Take("RAF", function(RAF) {
    var Animation;
    return Make("Animation", Animation = function(scope) {
      var dt, restart, running, startTime, time, update;
      if (scope.animation == null) {
        return;
      }
      scope._callback = scope.animation;
      running = false;
      restart = false;
      dt = 0;
      time = 0;
      startTime = 0;
      update = function(t) {
        var newTime;
        if (!running) {
          return;
        }
        if (restart) {
          restart = false;
          startTime = t / 1000;
          time = 0;
        } else {
          newTime = t / 1000 - startTime;
          dt = newTime - time;
          time = newTime;
          scope._callback(dt, time);
        }
        if (running) {
          return RAF(update);
        }
      };
      return scope.animation = {
        start: function() {
          if (!running) {
            RAF(update);
          }
          running = true;
          return restart = true;
        },
        stop: function() {
          return running = false;
        },
        toggle: function() {
          if (running) {
            return this.stop();
          } else {
            return this.start();
          }
        }
      };
    });
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

  Take("SVG", function(SVG) {
    var Highlighter, enabled;
    enabled = true;
    Make("Highlighter", Highlighter = {
      setup: function(highlighted) {
        var highlight, len, m, mouseLeave, mouseOver, results;
        if (highlighted == null) {
          highlighted = [];
        }
        mouseOver = function(e) {
          var highlight, len, m, results;
          if (enabled) {
            results = [];
            for (m = 0, len = highlighted.length; m < len; m++) {
              highlight = highlighted[m];
              results.push(SVG.attr(highlight, "filter", "url(#highlightMatrix)"));
            }
            return results;
          }
        };
        mouseLeave = function(e) {
          var highlight, len, m, results;
          results = [];
          for (m = 0, len = highlighted.length; m < len; m++) {
            highlight = highlighted[m];
            results.push(SVG.attr(highlight, "filter", null));
          }
          return results;
        };
        results = [];
        for (m = 0, len = highlighted.length; m < len; m++) {
          highlight = highlighted[m];
          highlight.addEventListener("mouseover", mouseOver);
          results.push(highlight.addEventListener("mouseleave", mouseLeave));
        }
        return results;
      },
      enable: function() {
        return enabled = true;
      },
      disable: function() {
        return enabled = true;
      }
    });
    return SVG.createColorMatrixFilter("highlightMatrix", ".5  0   0    0   0 .5  1   .5   0  20 0   0   .5   0   0 0   0   0    1   0");
  });

  Take(["Reaction", "SVG", "Symbol"], function(Reaction, SVG, Symbol) {
    Symbol("HydraulicLine", [], function(svgElement) {
      var scope;
      return scope = {
        setup: function() {
          Reaction("Schematic:Hide", function() {
            return SVG.attr(svgElement, "filter", null);
          });
          return Reaction("Schematic:Show", function() {
            return SVG.attr(svgElement, "filter", "url(#allblackMatrix)");
          });
        }
      };
    });
    return SVG.createColorMatrixFilter("allblackMatrix", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0");
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

  Take(["PureDom", "HydraulicPressure", "Global"], function(PureDom, HydraulicPressure, Global) {
    var Style;
    return Make("Style", Style = function(scope) {
      var element, ref, styleCache;
      element = scope.element;
      styleCache = {};
      return scope = {
        isLine: ((ref = element.getAttribute("id")) != null ? ref.indexOf("Line") : void 0) > -1,
        pressure: 0,
        visible: function(isVisible) {
          if (isVisible) {
            return element.style.opacity = 1.0;
          } else {
            return element.style.opacity = 0.0;
          }
        },
        show: function(showElement) {
          if (showElement) {
            return element.style.visibility = "visible";
          } else {
            return element.style.visibility = "hidden";
          }
        },
        setPressure: function(val, alpha) {
          if (alpha == null) {
            alpha = 1.0;
          }
          scope.pressure = val;
          if (scope.isLine && Global.enableHydraulicLines) {
            return scope.stroke(HydraulicPressure(scope.pressure, alpha));
          } else {
            return scope.fill(HydraulicPressure(scope.pressure, alpha));
          }
        },
        getPressure: function() {
          return scope.pressure;
        },
        getPressureColor: function(pressure) {
          return HydraulicPressure(pressure);
        },
        stroke: function(color) {
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
            return path.setAttributeNS(null, "stroke", color);
          }
        },
        fill: function(color) {
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
        },
        linearGradient: function(stops, x1, y1, x2, y2) {
          var fillUrl, gradient, gradientName, gradientStop, len, m, stop, useParent;
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
          for (m = 0, len = stops.length; m < len; m++) {
            stop = stops[m];
            gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop");
            gradientStop.setAttribute("offset", stop.offset);
            gradientStop.setAttribute("stop-color", stop.color);
            gradient.appendChild(gradientStop);
          }
          fillUrl = "url(#" + gradientName + ")";
          return scope.fill(fillUrl);
        },
        radialGradient: function(stops, cx, cy, radius) {
          var fillUrl, gradient, gradientName, gradientStop, len, m, stop, useParent;
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
          for (m = 0, len = stops.length; m < len; m++) {
            stop = stops[m];
            gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop");
            gradientStop.setAttribute("offset", stop.offset);
            gradientStop.setAttribute("stop-color", stop.color);
            gradient.appendChild(gradientStop);
          }
          fillUrl = "url(#" + gradientName + ")";
          return scope.fill(fillUrl);
        },
        setText: function(text) {
          var textElement;
          textElement = element.querySelector("text").querySelector("tspan");
          if (textElement != null) {
            return textElement.textContent = text;
          }
        },
        setProperty: function(key, val) {
          if (styleCache[key] !== val) {
            styleCache[key] = val;
            return element.style[key] = val;
          }
        },
        getElement: function() {
          throw "scope.style.getElement() has been removed from SVGA. Please use scope.element instead.";
        }
      };
    });
  });

  Take(["RAF", "DOMContentLoaded"], function(RAF) {
    var Transform;
    return Make("Transform", Transform = function(scope) {
      var applyTransform, denom, element, len, m, matrix, prop, ref, rotation, scaleX, scaleY, t, transform, transformBaseVal, x, y;
      element = scope.element;
      transformBaseVal = element.transform.baseVal;
      transform = document.rootElement.createSVGTransform();
      matrix = document.rootElement.createSVGMatrix();
      x = 0;
      y = 0;
      rotation = 0;
      scaleX = 1;
      scaleY = 1;
      ref = ["x", "y", "rotation", "scale", "scaleX", "scaleY"];
      for (m = 0, len = ref.length; m < len; m++) {
        prop = ref[m];
        if (scope[prop] != null) {
          console.log(element);
          throw "^ Transform will clobber scope." + prop + " on this element. Please find a different name for your child/property \"" + prop + "\".";
        }
      }
      if (transformBaseVal.numberOfItems === 1) {
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
      } else if (transformBaseVal.numberOfItems > 1) {
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
          throw "angle has been removed from the SVGA Transform system. Please use scope.rotation instead.";
        },
        set: function() {
          throw "angle has been removed from the SVGA Transform system. Please use scope.rotation instead.";
        }
      });
      Object.defineProperty(scope, 'turns', {
        get: function() {
          throw "turns has been removed from the SVGA Transform system. Please use scope.rotation instead.";
        },
        set: function() {
          throw "turns has been removed from the SVGA Transform system. Please use scope.rotation instead.";
        }
      });
      return Object.defineProperty(scope, "transform", {
        get: function() {
          throw "scope.transform has been removed from SVGA. You can just delete the .transform and things should work.";
        }
      });
    });
  });

  Take(["Action", "Dispatch", "Global", "Reaction", "SVGReady"], function(Action, Dispatch, Global, Reaction) {
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

  Take(["Action", "Dispatch", "Global", "Reaction", "root"], function(Action, Dispatch, Global, Reaction, root) {
    Reaction("ScopeReady", function() {
      return Action("Schematic:Show");
    });
    Reaction("Schematic:Toggle", function() {
      return Action(Global.animateMode ? "Schematic:Show" : "Schematic:Hide");
    });
    Reaction("Schematic:Hide", function() {
      Global.animateMode = true;
      return Dispatch(root, "animateMode");
    });
    return Reaction("Schematic:Show", function() {
      Global.animateMode = false;
      return Dispatch(root, "schematicMode");
    });
  });

  Take(["Dispatch", "Reaction", "root"], function(Dispatch, Reaction, root) {
    return Reaction("setup", function() {
      return Dispatch(root, "setup");
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

  (function() {
    var buildSubCache, cache, dispatchWithFn;
    cache = {};
    Make("Dispatch", function(node, action, sub) {
      var base, fn, len, m, nameCache, ref, results;
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
          nameCache = (base = cache[sub])[action] != null ? base[action] : base[action] = [];
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

  (function() {
    var Global, internal, readWrite;
    Make("Global", Global = {});
    internal = {};
    readWrite = function(name, initial) {
      internal[name] = initial;
      return Object.defineProperty(Global, name, {
        get: function() {
          return internal[name];
        },
        set: function(val) {
          return internal[name] = val;
        }
      });
    };
    readWrite("animateMode", false);
    Object.defineProperty(Global, "schematicMode", {
      get: function() {
        return !internal.animateMode;
      },
      set: function(val) {
        return internal.animateMode = !val;
      }
    });
    return readWrite("enableHydraulicLines");
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

  Take(["RAF"], function(RAF) {
    return Make("Resize", function(cb) {
      var r;
      (r = function() {
        return RAF(cb, true);
      })();
      return window.addEventListener("resize", r);
    });
  });

  Take(["SVGReady"], function() {
    var SVG, createStops, defs, props, root, svgNS, xlinkNS;
    root = document.rootElement;
    defs = root.querySelector("defs");
    svgNS = "http://www.w3.org/2000/svg";
    xlinkNS = "http://www.w3.org/1999/xlink";
    props = {
      textContent: true
    };
    Make("SVG", SVG = {
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
        SVG.attrs(elm, attrs);
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
        elm = document.createElementNS(svgNS, "g");
        ref = source.attributes;
        for (m = 0, len = ref.length; m < len; m++) {
          attr = ref[m];
          SVG.attr(elm, attr.name, attr.value);
        }
        SVG.attrs(elm, {
          id: null
        });
        SVG.attrs(elm, attrs);
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
        parent.appendChild(child);
        return child;
      },
      prepend: function(parent, child) {
        if (parent.hasChildNodes()) {
          parent.insertBefore(child, parent.firstChild);
        } else {
          parent.appendChild(child);
        }
        return child;
      },
      attrs: function(elm, attrs) {
        var k, v;
        for (k in attrs) {
          v = attrs[k];
          SVG.attr(elm, k, v);
        }
        return elm;
      },
      attr: function(elm, k, v) {
        var ns;
        if (v === void 0) {
          return elm.getAttribute(k);
        }
        if (elm._SVG == null) {
          elm._SVG = {};
        }
        if (elm._SVG[k] !== v) {
          elm._SVG[k] = v;
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
    });
    return createStops = function(gradient, stops) {
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
  });

  Take(["RAF", "SVG"], function(RAF, SVG) {
    var TRS, err, setup;
    err = function(elm, message) {
      console.log(elm);
      throw "^ " + message;
    };
    setup = function(wrapper, elm) {
      var v;
      return elm._trs = v = {
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
    };
    TRS = function(elm) {
      var wrapper;
      if (elm == null) {
        err(elm, "Null element passed to TRS(elm)");
      }
      if (elm.parentNode == null) {
        err(elm, "Element passed to TRS(elm) must have a parentNode");
      }
      wrapper = SVG.create("g", elm.parentNode, {
        "class": "TRS"
      });
      setup(wrapper, elm);
      SVG.append(wrapper, elm);
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
      RAF(elm._trs.apply, true, 1);
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
      RAF(elm._trs.apply, true, 1);
      return elm;
    };
    TRS.move = function(elm, x, y) {
      if (elm._trs == null) {
        err(elm, "Non-TRS element passed to TRS.move");
      }
      return TRS.abs(elm, {
        x: x,
        y: y
      });
    };
    TRS.rotate = function(elm, r) {
      if (elm._trs == null) {
        err(elm, "Non-TRS element passed to TRS.rotate");
      }
      return TRS.abs(elm, {
        r: r
      });
    };
    TRS.scale = function(elm, sx, sy) {
      if (sy == null) {
        sy = x;
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

  Arrow = (function() {
    var getScaleFactor;

    Arrow.prototype.edge = null;

    Arrow.prototype.element = null;

    Arrow.prototype.visible = false;

    Arrow.prototype.deltaFlow = 0;

    Arrow.prototype.vector = null;

    function Arrow(parent1, target1, segment1, position1, edgeIndex1, flowArrows1) {
      var self;
      this.parent = parent1;
      this.target = target1;
      this.segment = segment1;
      this.position = position1;
      this.edgeIndex = edgeIndex1;
      this.flowArrows = flowArrows1;
      this.update = bind(this.update, this);
      this.setVisibility = bind(this.setVisibility, this);
      this.updateVisibility = bind(this.updateVisibility, this);
      this.setColor = bind(this.setColor, this);
      this.createArrow = bind(this.createArrow, this);
      this.createArrow();
      this.edge = this.segment.edges[this.edgeIndex];
      self = this;
    }

    Arrow.prototype.createArrow = function() {
      var line, triangle;
      this.element = document.createElementNS("http://www.w3.org/2000/svg", "g");
      triangle = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
      triangle.setAttributeNS(null, "points", "0,-16 30,0 0,16");
      line = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
      line.setAttributeNS(null, "points", "0, 0, -23, 0");
      line.setAttributeNS(null, "fill", "#fff");
      line.setAttributeNS(null, "stroke-width", "11");
      this.element.appendChild(triangle);
      this.element.appendChild(line);
      this.target.appendChild(this.element);
      this.element.setAttributeNS(null, "fill", "blue");
      return this.element.setAttributeNS(null, "stroke", "blue");
    };

    Arrow.prototype.setColor = function(fillColor) {
      this.element.setAttributeNS(null, "fill", fillColor);
      return this.element.setAttributeNS(null, "stroke", fillColor);
    };

    Arrow.prototype.updateVisibility = function() {
      if (this.visible && this.deltaFlow !== 0) {
        if (this.element.style.visibility !== "visible") {
          return this.element.style.visibility = "visible";
        }
      } else {
        if (this.element.style.visibility !== "hidden") {
          return this.element.style.visibility = "hidden";
        }
      }
    };

    Arrow.prototype.setVisibility = function(isVisible) {
      this.visible = isVisible;
      return this.updateVisibility();
    };

    Arrow.prototype.update = function(deltaFlow) {
      var angle, currentPosition, fadeLength, scaleFactor, scalingFactor, transString;
      this.deltaFlow = deltaFlow;
      this.updateVisibility();
      this.position += deltaFlow;
      while (this.position > this.edge.length) {
        this.edgeIndex++;
        if (this.edgeIndex >= this.segment.edges.length) {
          this.edgeIndex = 0;
        }
        this.position -= this.edge.length;
        this.edge = this.segment.edges[this.edgeIndex];
      }
      while (this.position < 0) {
        this.edgeIndex--;
        if (this.edgeIndex < 0) {
          this.edgeIndex = this.segment.edges.length - 1;
        }
        this.edge = this.segment.edges[this.edgeIndex];
        this.position += this.edge.length;
      }
      scaleFactor = 0;
      fadeLength = this.flowArrows ? this.flowArrows.FADE_LENGTH : 50;
      scaleFactor = getScaleFactor(this.position, this.segment.edges, this.edgeIndex, fadeLength);
      scalingFactor = this.segment.scale * this.segment.arrowsContainer.scale;
      if (this.flowArrows) {
        scalingFactor *= this.flowArrows.scale;
      }
      scaleFactor = scaleFactor * scalingFactor;
      currentPosition = {
        x: 0,
        y: 0
      };
      currentPosition.x = Math.cos(this.edge.angle) * this.position + this.edge.x;
      currentPosition.y = Math.sin(this.edge.angle) * this.position + this.edge.y;
      angle = this.edge.angle * 180 / Math.PI + (deltaFlow < 0 ? 180 : 0);
      transString = "translate(" + currentPosition.x + ", " + currentPosition.y + ") scale(" + scaleFactor + ") rotate(" + angle + ")";
      return this.element.setAttribute('transform', transString);
    };

    getScaleFactor = function(position, edges, edgeIndex, fadeLength) {
      var edge, fadeEnd, fadeStart, firstHalf, scale;
      edge = edges[edgeIndex];
      firstHalf = position < edge.length / 2;
      fadeStart = (firstHalf || edges.length > 1) && edgeIndex === 0;
      fadeEnd = (!firstHalf || edges.length > 1) && edgeIndex === edges.length - 1;
      scale = 1;
      if (fadeStart) {
        scale = (position / edge.length) * edge.length / fadeLength;
      } else if (fadeEnd) {
        scale = 1.0 - (position - (edge.length - fadeLength)) / fadeLength;
      }
      return Math.min(1, scale);
    };

    return Arrow;

  })();

  ArrowsContainer = (function() {
    ArrowsContainer.prototype.segments = null;

    ArrowsContainer.prototype.fadeStart = true;

    ArrowsContainer.prototype.fadeEnd = true;

    ArrowsContainer.prototype.direction = 1;

    ArrowsContainer.prototype.scale = 1;

    ArrowsContainer.prototype.name = "";

    ArrowsContainer.prototype.flow = 1;

    function ArrowsContainer(target1) {
      this.target = target1;
      this.update = bind(this.update, this);
      this.setColor = bind(this.setColor, this);
      this.reverse = bind(this.reverse, this);
      this.visible = bind(this.visible, this);
      this.addSegment = bind(this.addSegment, this);
      this.segments = [];
    }

    ArrowsContainer.prototype.addSegment = function(segment) {
      this.segments.push(segment);
      return this[segment.name] = segment;
    };

    ArrowsContainer.prototype.visible = function(isVisible) {
      var len, m, ref, results, segment;
      ref = this.segments;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        segment = ref[m];
        results.push(segment.visible(isVisible));
      }
      return results;
    };

    ArrowsContainer.prototype.reverse = function() {
      return this.direction *= -1;
    };

    ArrowsContainer.prototype.setColor = function(fillColor) {
      var len, m, ref, results, segment;
      ref = this.segments;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        segment = ref[m];
        results.push(segment.setColor(fillColor));
      }
      return results;
    };

    ArrowsContainer.prototype.update = function(deltaTime) {
      var len, m, ref, results, segment;
      deltaTime *= this.direction;
      ref = this.segments;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        segment = ref[m];
        if (segment.visible) {
          results.push(segment.update(deltaTime, this.flow));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    return ArrowsContainer;

  })();

  Edge = (function() {
    Edge.prototype.x = null;

    Edge.prototype.y = null;

    Edge.prototype.angle = null;

    Edge.prototype.length = null;

    function Edge() {}

    return Edge;

  })();

  Take(["Organizer", "Reaction", "RAF"], function(Organizer, Reaction, RAF) {
    var FlowArrows, currentTime, removeOriginalArrow, update;
    currentTime = null;
    FlowArrows = {
      scale: 0.75,
      SPACING: 600,
      FADE_LENGTH: 50,
      MIN_SEGMENT_LENGTH: 1,
      SPEED: 200,
      MIN_EDGE_LENGTH: 8,
      CONNECTED_DISTANCE: 1,
      ARROWS_PROPERTY: "arrows",
      isVisible: false,
      arrowsContainers: [],
      setup: function(parent, selectedSymbol, linesData) {
        var arrowsContainer, len, lineData, m;
        removeOriginalArrow(selectedSymbol);
        arrowsContainer = new ArrowsContainer(selectedSymbol);
        FlowArrows.arrowsContainers.push(arrowsContainer);
        for (m = 0, len = linesData.length; m < len; m++) {
          lineData = linesData[m];
          Organizer.build(parent, lineData.edges, arrowsContainer, this);
        }
        RAF(update, true);
        return arrowsContainer;
      },
      show: function() {
        var arrowsContainer, len, m, ref, results;
        FlowArrows.isVisible = true;
        ref = FlowArrows.arrowsContainers;
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          arrowsContainer = ref[m];
          results.push(arrowsContainer.visible(true));
        }
        return results;
      },
      hide: function() {
        var arrowsContainer, len, m, ref, results;
        FlowArrows.isVisible = false;
        ref = FlowArrows.arrowsContainers;
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          arrowsContainer = ref[m];
          results.push(arrowsContainer.visible(false));
        }
        return results;
      },
      animateMode: function() {
        var arrowsContainer, len, m, ref, results;
        ref = FlowArrows.arrowsContainers;
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          arrowsContainer = ref[m];
          results.push(arrowsContainer.visible(FlowArrows.isVisible));
        }
        return results;
      },
      schematicMode: function() {
        var arrowsContainer, len, m, ref, results;
        ref = FlowArrows.arrowsContainers;
        results = [];
        for (m = 0, len = ref.length; m < len; m++) {
          arrowsContainer = ref[m];
          results.push(arrowsContainer.visible(false));
        }
        return results;
      },
      start: function() {
        return console.log("FlowArrows.start() is deprecated. Please remove it from your animation.");
      }
    };
    removeOriginalArrow = function(selectedSymbol) {
      var child, children, len, len1, m, n, ref, results;
      children = [];
      ref = selectedSymbol.childNodes;
      for (m = 0, len = ref.length; m < len; m++) {
        child = ref[m];
        children.push(child);
      }
      results = [];
      for (n = 0, len1 = children.length; n < len1; n++) {
        child = children[n];
        results.push(selectedSymbol.removeChild(child));
      }
      return results;
    };
    update = function(time) {
      var arrowsContainer, dT, len, m, ref, results;
      RAF(update);
      if (currentTime == null) {
        currentTime = time;
      }
      dT = (time - currentTime) / 1000;
      currentTime = time;
      if (!FlowArrows.isVisible) {
        return;
      }
      ref = FlowArrows.arrowsContainers;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        arrowsContainer = ref[m];
        results.push(arrowsContainer.update(dT));
      }
      return results;
    };
    Reaction("Schematic:Show", FlowArrows.schematicMode);
    Reaction("Schematic:Hide", FlowArrows.animateMode);
    return Make("FlowArrows", FlowArrows);
  });

  (function() {
    var Organizer, angle, cullShortEdges, cullShortSegments, cullUnusedPoints, distance, edgesToLines, finish, formSegments, isConnected, isInline, joinSegments;
    edgesToLines = function(edgesData) {
      var edge, i, linesData, m, ref;
      linesData = [];
      edge = [];
      for (i = m = 0, ref = edgesData.length - 1; 0 <= ref ? m <= ref : m >= ref; i = 0 <= ref ? ++m : --m) {
        edge = edgesData[i];
        linesData.push(edge[0], edge[2]);
      }
      return linesData;
    };
    formSegments = function(lineData, flowArrows) {
      var i, m, pointA, pointB, ref, segmentEdges, segments;
      segments = [];
      segmentEdges = null;
      for (i = m = 0, ref = lineData.length - 1; m <= ref; i = m += 2) {
        pointA = lineData[i];
        pointB = lineData[i + 1];
        if ((segmentEdges != null) && isConnected(pointA, segmentEdges[segmentEdges.length - 1], flowArrows)) {
          segmentEdges.push(pointB);
        } else if ((segmentEdges != null) && isConnected(pointB, segmentEdges[segmentEdges.length - 1], flowArrows)) {
          segmentEdges.push(pointA);
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointB, flowArrows)) {
          segmentEdges.unshift(pointA);
        } else if ((segmentEdges != null) && isConnected(segmentEdges[0], pointA, flowArrows)) {
          segmentEdges.unshift(pointB);
        } else {
          segmentEdges = [pointA, pointB];
          segments.push(segmentEdges);
        }
      }
      return segments;
    };
    joinSegments = function(segments, flowArrows) {
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
          if (isConnected(pointA, pointB, flowArrows)) {
            segB.reverse();
            segB.pop();
            segments[i] = segB.concat(segA);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[segA.length - 1];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB, flowArrows)) {
            segB.reverse();
            segB.unshift();
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[segA.length - 1];
          pointB = segB[0];
          if (isConnected(pointA, pointB, flowArrows)) {
            segments[i] = segA.concat(segB);
            segments.splice(j, 1);
            continue;
          }
          pointA = segA[0];
          pointB = segB[segB.length - 1];
          if (isConnected(pointA, pointB, flowArrows)) {
            segments[i] = segB.concat(segA);
            segments.splice(j, 1);
            continue;
          }
        }
      }
      return segments;
    };
    cullShortEdges = function(segments, flowArrows) {
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
          if (distance(pointA, pointB) < flowArrows.MIN_EDGE_LENGTH) {
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
    cullUnusedPoints = function(segments) {
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
    cullShortSegments = function(segments, flowArrows) {
      var i;
      i = segments.length;
      while (i--) {
        if (segments.length < flowArrows.MIN_SEGMENT_LENGTH) {
          segments.splice(i, 1);
        }
      }
      return segments;
    };
    finish = function(parent, segments, arrowsContainer, flowArrows) {
      var edge, edges, i, j, m, n, ref, ref1, results, segPoints, segmentLength;
      results = [];
      for (i = m = 0, ref = segments.length - 1; 0 <= ref ? m <= ref : m >= ref; i = 0 <= ref ? ++m : --m) {
        segPoints = segments[i];
        segmentLength = 0;
        edges = [];
        for (j = n = 0, ref1 = segPoints.length - 2; 0 <= ref1 ? n <= ref1 : n >= ref1; j = 0 <= ref1 ? ++n : --n) {
          edge = new Edge();
          edge.x = segPoints[j].x;
          edge.y = segPoints[j].y;
          edge.length = distance(segPoints[j], segPoints[j + 1]);
          edge.angle = angle(segPoints[j], segPoints[j + 1]);
          segmentLength += edge.length;
          edges.push(edge);
        }
        if (segmentLength < flowArrows.MIN_SEGMENT_LENGTH) {
          continue;
        }
        results.push(new Segment(parent, edges, arrowsContainer, segmentLength, flowArrows));
      }
      return results;
    };
    isConnected = function(a, b, flowArrows) {
      var dX, dY;
      dX = Math.abs(a.x - b.x);
      dY = Math.abs(a.y - b.y);
      return dX < flowArrows.CONNECTED_DISTANCE && dY < flowArrows.CONNECTED_DISTANCE;
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
    angle = function(a, b) {
      return Math.atan2(b.y - a.y, b.x - a.x);
    };
    return Make("Organizer", Organizer = {
      build: function(parent, edgesData, arrowsContainer, flowArrows) {
        var lineData, segments;
        lineData = edgesToLines(edgesData);
        segments = [];
        segments = formSegments(lineData, flowArrows);
        segments = joinSegments(segments, flowArrows);
        segments = cullShortEdges(segments, flowArrows);
        segments = cullUnusedPoints(segments);
        return finish(parent, segments, arrowsContainer, flowArrows);
      }
    });
  })();

  Segment = (function() {
    Segment.prototype.arrows = null;

    Segment.prototype.direction = 1;

    Segment.prototype.flow = null;

    Segment.prototype.name = "";

    Segment.prototype.scale = 1.0;

    Segment.prototype.fillColor = "transparent";

    function Segment(parent1, edges1, arrowsContainer1, segmentLength1, flowArrows1) {
      var arrow, edge, edgeIndex, i, m, position, ref, segmentArrows, segmentSpacing, self;
      this.parent = parent1;
      this.edges = edges1;
      this.arrowsContainer = arrowsContainer1;
      this.segmentLength = segmentLength1;
      this.flowArrows = flowArrows1;
      this.update = bind(this.update, this);
      this.setColor = bind(this.setColor, this);
      this.reverse = bind(this.reverse, this);
      this.visible = bind(this.visible, this);
      this.arrows = [];
      this.name = "segment" + this.arrowsContainer.segments.length;
      this.arrowsContainer.addSegment(this);
      self = this;
      segmentArrows = Math.max(1, Math.round(self.segmentLength / this.flowArrows.SPACING));
      segmentSpacing = self.segmentLength / segmentArrows;
      position = 0;
      edgeIndex = 0;
      edge = self.edges[edgeIndex];
      for (i = m = 0, ref = segmentArrows - 1; 0 <= ref ? m <= ref : m >= ref; i = 0 <= ref ? ++m : --m) {
        while (position > edge.length) {
          position -= edge.length;
          edge = self.edges[++edgeIndex];
        }
        arrow = new Arrow(self.parent, self.arrowsContainer.target, self, position, edgeIndex, this.flowArrows);
        arrow.name = "arrow" + i;
        self[arrow.name] = arrow;
        self.arrows.push(arrow);
        position += segmentSpacing;
      }
    }

    Segment.prototype.visible = function(isVisible) {
      var arrow, len, m, ref, results;
      ref = this.arrows;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        arrow = ref[m];
        results.push(arrow.setVisibility(isVisible));
      }
      return results;
    };

    Segment.prototype.reverse = function() {
      return this.direction *= -1;
    };

    Segment.prototype.setColor = function(fillColor) {
      return this.fillColor = fillColor;
    };

    Segment.prototype.update = function(deltaTime, ancestorFlow) {
      var arrow, arrowFlow, len, m, ref, results;
      arrowFlow = this.flow != null ? this.flow : ancestorFlow;
      if (this.flowArrows) {
        arrowFlow *= deltaTime * this.direction * this.flowArrows.SPEED;
      }
      ref = this.arrows;
      results = [];
      for (m = 0, len = ref.length; m < len; m++) {
        arrow = ref[m];
        arrow.setColor(this.fillColor);
        results.push(arrow.update(arrowFlow));
      }
      return results;
    };

    return Segment;

  })();

}).call(this);
