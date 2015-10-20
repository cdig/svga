(function() {
  var SVGAnimation, SVGMask, SVGTransform, invert, invertSVGMatrix;

  invert = function(matrix) {
    var copy, dim, i, identity, ii, j, k, l, m, n, o, p, q, r, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, temp;
    if (matrix.length !== matrix[0].length) {
      return;
    }
    identity = [];
    copy = [];
    dim = matrix.length;
    for (i = k = 0, ref = dim - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
      identity[i] = [];
      copy[i] = [];
      for (j = l = 0, ref1 = dim - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; j = 0 <= ref1 ? ++l : --l) {
        if (i === j) {
          identity[i][j] = 1;
        } else {
          identity[i][j] = 0;
        }
        copy[i][j] = matrix[i][j];
      }
    }
    for (i = m = 0, ref2 = dim - 1; 0 <= ref2 ? m <= ref2 : m >= ref2; i = 0 <= ref2 ? ++m : --m) {
      temp = copy[i][i];
      if (temp === 0) {
        for (ii = n = 0, ref3 = dim - 1; 0 <= ref3 ? n <= ref3 : n >= ref3; ii = 0 <= ref3 ? ++n : --n) {
          for (j = o = 0, ref4 = dim - 1; 0 <= ref4 ? o <= ref4 : o >= ref4; j = 0 <= ref4 ? ++o : --o) {
            if (copy[ii][i] !== 0) {
              temp = copy[i][j];
              copy[i][j] = copy[ii][j];
              copy[ii][j] = temp;
              temp = identity[i][j];
              identity[i][j] = identity[ii][j];
              identity[ii][j] = temp;
            }
            break;
          }
        }
        temp = copy[i][i];
        if (temp === 0) {
          console.log("not invertible");
          return;
        }
      }
      for (j = p = 0, ref5 = dim - 1; 0 <= ref5 ? p <= ref5 : p >= ref5; j = 0 <= ref5 ? ++p : --p) {
        copy[i][j] = copy[i][j] / temp;
        identity[i][j] = identity[i][j] / temp;
      }
      for (ii = q = 0, ref6 = dim - 1; 0 <= ref6 ? q <= ref6 : q >= ref6; ii = 0 <= ref6 ? ++q : --q) {
        if (ii === i) {
          continue;
        }
        temp = copy[ii][i];
        for (j = r = 0, ref7 = dim - 1; 0 <= ref7 ? r <= ref7 : r >= ref7; j = 0 <= ref7 ? ++r : --r) {
          copy[ii][j] -= temp * copy[i][j];
          identity[ii][j] -= temp * identity[i][j];
        }
      }
    }
    return identity;
  };

  invertSVGMatrix = function(matrixString) {
    var i, k, matches, matrix, newMatrix;
    matches = matrixString.match(/[+-]?\d+(\.\d+)?/g);
    matrix = [];
    for (i = k = 0; k <= 2; i = ++k) {
      matrix.push([0, 0, 0]);
    }
    matrix[0][0] = parseFloat(matches[0]);
    matrix[0][1] = parseFloat(matches[1]);
    matrix[0][2] = parseFloat(matches[4]);
    matrix[1][0] = parseFloat(matches[2]);
    matrix[1][1] = parseFloat(matches[3]);
    matrix[1][2] = parseFloat(matches[5]);
    matrix[2][0] = 0;
    matrix[2][1] = 0;
    matrix[2][2] = 1;
    newMatrix = invert(matrix);
    matrixString = "matrix(" + newMatrix[0][0] + ", " + newMatrix[0][1] + ", " + newMatrix[1][0] + ", " + newMatrix[1][1] + ", " + newMatrix[0][2] + ", " + newMatrix[1][2] + ")";
    return matrixString;
  };

  (function() {
    return Take(['crank', 'defaultElement', 'button', 'Joystick', 'SVGActivity'], function(crank, defaultElement, button, Joystick, SVGActivity) {
      var SVGActivities, activities, activityDefinitions, waitingActivities;
      activityDefinitions = [];
      activities = [];
      waitingActivities = [];
      return Make("SVGActivities", SVGActivities = {
        registerActivityDefinition: function(activity) {
          var k, l, len, len1, remove, results, toRemove, waitingActivity;
          activityDefinitions[activity._name] = activity;
          toRemove = [];
          for (k = 0, len = waitingActivities.length; k < len; k++) {
            waitingActivity = waitingActivities[k];
            if (waitingActivity.name === activity._name) {
              setTimeout(function() {
                return SVGActivities.runActivity(waitingActivity.name, waitingActivity.id, waitingActivity.svg);
              });
              toRemove.push(waitingActivity);
            }
          }
          results = [];
          for (l = 0, len1 = toRemove.length; l < len1; l++) {
            remove = toRemove[l];
            results.push(waitingActivities.splice(waitingActivities.indexOf(remove), 1));
          }
          return results;
        },
        getActivity: function(activityID) {
          return activities[activityName];
        },
        startActivity: function(activityName, activityId, svgElement) {
          if (!activityDefinitions[activityName]) {
            return waitingActivities.push({
              name: activityName,
              id: activityId,
              svg: svgElement
            });
          } else {
            return setTimeout(function() {
              return SVGActivities.runActivity(activityName, activityId, svgElement);
            });
          }
        },
        runActivity: function(activityName, id, svgElement, waitingActivity) {
          var activity, k, len, pair, ref, svg, svgActivity;
          activity = activityDefinitions[activityName];
          activity.registerInstance('joystick', 'joystick');
          activityName = activity._name;
          activity.crank = crank;
          activity.button = button;
          activity.defaultElement = defaultElement;
          activity.joystick = Joystick;
          svgActivity = SVGActivity();
          ref = activity._instances;
          for (k = 0, len = ref.length; k < len; k++) {
            pair = ref[k];
            svgActivity.registerInstance(pair.name, activity[pair.instance]);
          }
          svgActivity.registerInstance('default', activity.defaultElement);
          svg = svgElement.contentDocument.querySelector('svg');
          svgActivity.setupDocument(activityName, svg);
          return activities[id] = svgActivity;
        }
      });
    });
  })();

  (function() {
    return Take(["defaultElement", "PureDom", "SVGTransform", "SVGStyle"], function(defaultElement, PureDom, SVGTransform, SVGStyle) {
      var SVGActivity, getChildElements, setupHighlighter, setupInstance;
      setupInstance = function(instance) {
        var child, k, len, ref;
        ref = instance.children;
        for (k = 0, len = ref.length; k < len; k++) {
          child = ref[k];
          setupInstance(child);
        }
        return instance.setup();
      };
      setupHighlighter = function(defs) {
        var colorMatrix, highlighter;
        highlighter = document.createElementNS("http://www.w3.org/2000/svg", "filter");
        highlighter.setAttribute("id", "highlightMatrix");
        colorMatrix = document.createElementNS("http://www.w3.org/2000/svg", "feColorMatrix");
        colorMatrix.setAttribute("in", "SourceGraphic");
        colorMatrix.setAttribute("type", "matrix");
        colorMatrix.setAttribute("values", "0.5 0.0 0.0 0.0 00 0.5 1.0 0.5 0.0 20 0.0 0.0 0.5 0.0 00 0.0 0.0 0.0 1.0 00");
        highlighter.appendChild(colorMatrix);
        return defs.appendChild(highlighter);
      };
      getChildElements = function(element) {
        var child, childElements, childNum, childRef, children, k, len;
        children = PureDom.querySelectorAllChildren(element, "g");
        childElements = [];
        childNum = 0;
        for (k = 0, len = children.length; k < len; k++) {
          child = children[k];
          if (child.getAttribute("id") == null) {
            childNum++;
            childRef = "child" + childNum;
            child.setAttribute("id", childRef);
          }
          childElements.push(child);
        }
        return childElements;
      };
      return Make("SVGActivity", SVGActivity = function() {
        var scope;
        return scope = {
          functions: {},
          instances: {},
          root: null,
          registerInstance: function(instanceName, instance) {
            return scope.instances[instanceName] = instance;
          },
          setupDocument: function(activityName, contentDocument) {
            var child, childElements, k, len;
            scope.registerInstance("default", defaultElement);
            console.log(scope.instances);
            scope.root = scope.instances["root"](contentDocument);
            setupHighlighter(contentDocument.querySelector("defs"));
            childElements = getChildElements(contentDocument);
            scope.root.children = [];
            for (k = 0, len = childElements.length; k < len; k++) {
              child = childElements[k];
              scope.setupElement(scope.root, child);
            }
            return setupInstance(scope.root);
          },
          getRootElement: function() {
            return scope.root.getRootElement();
          },
          setupElement: function(parent, element) {
            var child, childElements, id, instance, k, len, results;
            id = element.getAttribute("id");
            id = id.split("_")[0];
            instance = scope.instances[id];
            if (instance == null) {
              instance = scope.instances["default"];
            }
            parent[id] = instance(element);
            parent[id].transform = SVGTransform(element);
            parent[id].transform.setup();
            parent[id].style = SVGStyle(element);
            parent.children.push(parent[id]);
            parent[id].children = [];
            parent[id].root = scope.root;
            childElements = getChildElements(element);
            results = [];
            for (k = 0, len = childElements.length; k < len; k++) {
              child = childElements[k];
              results.push(scope.setupElement(parent[id], child));
            }
            return results;
          }
        };
      });
    });
  })();

  Make("SVGAnimation", SVGAnimation = function(callback) {
    var scope;
    return scope = {
      running: false,
      restart: false,
      time: 0,
      startTime: 0,
      dT: 0,
      runAnimation: function(currTime) {
        var dT, newTime;
        if (scope.restart) {
          scope.startTime = currTime;
          scope.time = 0;
          scope.restart = false;
        } else {
          newTime = currTime - scope.startTime;
          dT = (newTime - scope.time) / 1000;
          scope.time = newTime;
          callback(dT, scope.time);
        }
        if (scope.running) {
          return requestAnimationFrame(scope.runAnimation);
        }
      },
      start: function() {
        var startAnimation;
        if (scope.running) {
          scope.restart = true;
          return;
        }
        scope.running = true;
        startAnimation = function(currTime) {
          scope.startTime = currTime;
          scope.time = 0;
          return requestAnimationFrame(scope.runAnimation);
        };
        return requestAnimationFrame(startAnimation);
      },
      stop: function() {
        return scope.running = false;
      }
    };
  });

  (function() {
    var Highlighter, enabled;
    enabled = true;
    return Make("Highlighter", Highlighter = {
      setup: function(highlighted) {
        var highlight, k, len, mouseLeave, mouseOver, results;
        if (highlighted == null) {
          highlighted = [];
        }
        mouseOver = function(e) {
          var highlight, k, len, results;
          if (enabled) {
            results = [];
            for (k = 0, len = highlighted.length; k < len; k++) {
              highlight = highlighted[k];
              results.push(highlight.setAttribute("filter", "url(#highlightMatrix)"));
            }
            return results;
          }
        };
        mouseLeave = function(e) {
          var highlight, k, len, results;
          results = [];
          for (k = 0, len = highlighted.length; k < len; k++) {
            highlight = highlighted[k];
            results.push(highlight.removeAttribute("filter"));
          }
          return results;
        };
        results = [];
        for (k = 0, len = highlighted.length; k < len; k++) {
          highlight = highlighted[k];
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
  })();

  Make("SVGMask", SVGMask = function(root, maskInstance, maskedInstance, maskName) {
    var invertMatrix, mask, maskElement, maskedElement, maskedParent, newStyle, origMatrix, origStyle, rootElement, transString;
    maskElement = maskInstance.style.getElement();
    maskedElement = maskedInstance.style.getElement();
    rootElement = root.getElement();
    mask = document.createElementNS("http://www.w3.org/2000/svg", "mask");
    mask.setAttribute("id", maskName);
    mask.setAttribute("maskContentUnits", "userSpaceOnUse");
    mask.setAttribute("height", "100%");
    maskedParent = document.createElementNS("http://www.w3.org/2000/svg", "g");
    maskedParent.setAttribute('transform', maskedElement.getAttribute('transform'));
    maskedElement.parentNode.insertBefore(maskedParent, maskedElement);
    maskedElement.parentNode.removeChild(maskedElement);
    maskedParent.appendChild(maskedElement);
    mask.appendChild(maskElement);
    rootElement.querySelector('defs').insertBefore(mask, null);
    invertMatrix = invertSVGMatrix(maskedElement.getAttribute("transform"));
    origMatrix = maskElement.getAttribute("transform");
    transString = invertMatrix + " " + origMatrix;
    maskElement.setAttribute('transform', transString);
    origStyle = maskedElement.getAttribute('style');
    if (origStyle != null) {
      newStyle = origStyle + ("; mask: url(#" + maskName + ");");
    } else {
      newStyle = "mask: url(#" + maskName + ");";
    }
    maskedElement.setAttribute('transform', "matrix(1, 0, 0, 1, 0 0)");
    maskedInstance.transform.setBaseTransform();
    return maskedParent.setAttribute("style", newStyle);
  });

  Take(["PureDom", "HydraulicPressure"], function(PureDom, HydraulicPressure) {
    var SVGStyle;
    return Make("SVGStyle", SVGStyle = function(svgElement) {
      var scope;
      return scope = {
        visible: function(isVisible) {
          if (isVisible) {
            return svgElement.style.visibility = "visible";
          } else {
            return svgElement.style.visibility = "hidden";
          }
        },
        pressure: 0,
        setPressure: function(val) {
          scope.pressure = val;
          return scope.fill(HydraulicPressure(scope.pressure));
        },
        getPressure: function() {
          return scope.pressure;
        },
        getPressureColor: function(pressure) {
          return HydraulicPressure(pressure);
        },
        fill: function(color) {
          var clone, defs, link, parent, path, use, useParent;
          path = svgElement.querySelector("path");
          use = svgElement.querySelector("use");
          if ((path == null) && (use != null)) {
            useParent = PureDom.querySelectorParent(use, "g");
            parent = PureDom.querySelectorParent(svgElement, "svg");
            defs = parent.querySelector("defs");
            link = defs.querySelector(use.getAttribute("xlink:href"));
            clone = link.cloneNode(true);
            useParent.appendChild(clone);
            useParent.removeChild(use);
          }
          path = svgElement.querySelector("path");
          if (path != null) {
            return path.setAttributeNS(null, "fill", color);
          }
        },
        linearGradient: function(stops, x1, y1, x2, y2) {
          var fillUrl, gradient, gradientName, gradientStop, k, len, stop, useParent;
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
          useParent = PureDom.querySelectorParent(svgElement, "svg");
          gradientName = "Gradient_" + svgElement.getAttributeNS(null, "id");
          gradient = document.createElementNS("http://www.w3.org/2000/svg", "linearGradient");
          useParent.querySelector("defs").appendChild(gradient);
          gradient.setAttribute("id", gradientName);
          gradient.setAttributeNS(null, "x1", x1);
          gradient.setAttributeNS(null, "y1", y1);
          gradient.setAttributeNS(null, "x2", x2);
          gradient.setAttributeNS(null, "y2", y2);
          for (k = 0, len = stops.length; k < len; k++) {
            stop = stops[k];
            gradientStop = document.createElementNS("http://www.w3.org/2000/svg", "stop");
            gradientStop.setAttribute("offset", stop.offset);
            gradientStop.setAttribute("stop-color", stop.color);
            gradient.appendChild(gradientStop);
          }
          fillUrl = "url(#" + gradientName + ")";
          return scope.fill(fillUrl);
        },
        radialGradient: function(stops, cx, cy, radius) {
          var fillUrl, gradient, gradientName, gradientStop, k, len, oldGradient, stop, useParent;
          useParent = PureDom.querySelectorParent(svgElement, "svg");
          gradientName = "Gradient_" + svgElement.getAttributeNS(null, "id");
          oldGradient = useParent.querySelector("defs").querySelector("#" + gradientName);
          if (oldGradient) {
            useParent.querySelector("defs").removeChild(oldGradient);
          }
          gradient = document.createElementNS("http://www.w3.org/2000/svg", "radialGradient");
          useParent.querySelector("defs").appendChild(gradient);
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
          for (k = 0, len = stops.length; k < len; k++) {
            stop = stops[k];
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
          textElement = svgElement.querySelector("text").querySelector("tspan");
          if (textElement != null) {
            return textElement.textContent = text;
          }
        },
        setProperty: function(propertyName, propertyValue) {
          return svgElement.style[propertyName] = propertyValue;
        },
        getElement: function() {
          return svgElement;
        }
      };
    });
  });

  Make("SVGTransform", SVGTransform = function(svgElement) {
    var scope;
    return scope = {
      angleVal: 0,
      xVal: 0,
      yVal: 0,
      cxVal: 0,
      cyVal: 0,
      scaleVal: 1,
      scaleXVal: 1,
      scaleYVal: 1,
      turnsVal: 0,
      scaleString: "",
      translateString: "",
      rotationString: "",
      baseTransform: svgElement.getAttribute("transform"),
      setup: function() {
        Object.defineProperty(scope, 'angle', {
          get: function() {
            return scope.angleVal;
          },
          set: function(val) {
            scope.angleVal = val;
            scope.turnsVal = scope.angleVal / 360;
            return scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal);
          }
        });
        Object.defineProperty(scope, 'x', {
          get: function() {
            return scope.xVal;
          },
          set: function(val) {
            scope.xVal = val;
            return scope.translate(val, scope.y);
          }
        });
        Object.defineProperty(scope, 'y', {
          get: function() {
            return scope.yVal;
          },
          set: function(val) {
            scope.yVal = val;
            return scope.translate(scope.x, val);
          }
        });
        Object.defineProperty(scope, 'scale', {
          get: function() {
            return scope.scaleVal;
          },
          set: function(val) {
            scope.scaleVal = val;
            return scope.scaling(val);
          }
        });
        Object.defineProperty(scope, 'scaleX', {
          get: function() {
            return scope.scaleXVal;
          },
          set: function(val) {
            scope.scaleXVal = val;
            return scope.scaling(scope.scaleXVal, scope.scaleYVal);
          }
        });
        Object.defineProperty(scope, 'scaleY', {
          get: function() {
            return scope.scaleYVal;
          },
          set: function(val) {
            scope.scaleYVal = val;
            return scope.scaling(scope.scaleXVal, scope.scaleYVal);
          }
        });
        Object.defineProperty(scope, 'turns', {
          get: function() {
            return scope.turnsVal;
          },
          set: function(val) {
            scope.turnsVal = val;
            scope.angleVal = scope.turnsVal * 360;
            return scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal);
          }
        });
        Object.defineProperty(scope, 'cx', {
          get: function() {
            return scope.cxVal;
          },
          set: function(val) {
            scope.cxVal = val;
            return scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal);
          }
        });
        return Object.defineProperty(scope, 'cy', {
          get: function() {
            return scope.cyVal;
          },
          set: function(val) {
            scope.cyVal = val;
            return scope.rotate(scope.angleVal, scope.cxVal, scope.cyVal);
          }
        });
      },
      rotate: function(angle, cx, cy) {
        scope.rotationString = "rotate(" + angle + ", " + cx + ", " + cy + ")";
        return scope.setTransform();
      },
      translate: function(x, y) {
        scope.translateString = "translate(" + x + ", " + y + ")";
        return scope.setTransform();
      },
      scaling: function(scaleX, scaleY) {
        if (scaleY == null) {
          scaleY = scaleX;
        }
        scope.scaleString = "scale(" + scaleX + ", " + scaleY + ")";
        return scope.setTransform();
      },
      setBaseTransform: function() {
        return scope.baseTransform = svgElement.getAttribute("transform");
      },
      setBaseIdentity: function() {
        return scope.baseTransform = "matrix(1,0,0,1,0,0)";
      },
      setTransform: function() {
        var newTransform;
        newTransform = scope.baseTransform + " " + scope.rotationString + " " + scope.scaleString + " " + scope.translateString;
        return svgElement.setAttribute('transform', newTransform);
      }
    };
  });

  (function() {
    var Button;
    return Make("button", Button = function(svgElement) {
      var scope;
      return scope = {
        callbacks: [],
        setup: function() {
          return svgElement.addEventListener("click", scope.clicked);
        },
        getElement: function() {
          return svgElement;
        },
        addCallback: function(callback) {
          return scope.callbacks.push(callback);
        },
        clicked: function() {
          var callback, k, len, ref, results;
          ref = scope.callbacks;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            callback = ref[k];
            results.push(callback());
          }
          return results;
        }
      };
    });
  })();

  (function() {
    return Take(["Ease", "Vector", "PointerInput"], function(Ease, Vector, PointerInput) {
      var Crank;
      return Make("crank", Crank = function(svgElement) {
        var scope;
        return scope = {
          deadbands: [],
          unmapped: 0,
          domainMin: 0,
          domainMax: 359,
          rangeMin: -1,
          rangeMax: 1,
          oldAngle: 0,
          newAngle: 0,
          progress: 0,
          rotation: 0,
          callback: function() {},
          setup: function() {
            return PointerInput.addDown(svgElement, scope.mouseDown);
          },
          setCallback: function(callBackFunction) {
            return scope.callback = callBackFunction;
          },
          getElement: function() {
            return svgElement;
          },
          getValue: function() {
            return Ease.linear(scope.transform.angle, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
          },
          setValue: function(input) {
            return scope.unmapped = Ease.linear(input, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
          },
          setDomain: function(min, max) {
            scope.domainMin = min;
            scope.domainMax = max;
            if (scope.transform.angle < scope.domainMin) {
              return scope.transform.angle = scope.rotation = scope.unmapped = scope.domainMin;
            } else if (scope.transform.angle > scope.domainMax) {
              return scope.transform.angle = scope.rotation = scope.unmapped = scope.domainMax;
            }
          },
          setRange: function(min, max) {
            scope.rangeMin = min;
            return scope.rangeMax = max;
          },
          addDeadband: function(min, set, max) {
            var deadband;
            deadband = {
              min: min,
              set: set,
              max: max
            };
            scope.deadbands.push(deadband);
            return deadband;
          },
          begin: function(e) {
            var clientRect, mousePos;
            clientRect = svgElement.getBoundingClientRect();
            scope.position = Vector.fromRectPos(clientRect);
            scope.position.x += clientRect.width / 2;
            scope.position.y += clientRect.height / 2;
            mousePos = Vector.fromEventClient(e);
            return scope.oldAngle = Math.atan2(mousePos.y - scope.position.y, mousePos.x - scope.position.x);
          },
          compute: function(e) {
            var mousePos, progress;
            mousePos = Vector.fromEventClient(e);
            scope.newAngle = Math.atan2(mousePos.y - scope.position.y, mousePos.x - scope.position.x);
            progress = scope.newAngle - scope.oldAngle;
            if (progress > Math.PI) {
              progress += -2 * Math.PI;
            } else {
              if (progress < -Math.PI) {
                progress += 2 * Math.PI;
              } else {
                progress += 0;
              }
            }
            scope.unmapped += progress * 180 / Math.PI;
            return scope.update();
          },
          update: function() {
            var band, k, len, ref, rotation;
            scope.unmapped = Math.max(scope.domainMin, Math.min(scope.domainMax, scope.unmapped));
            rotation = scope.unmapped;
            ref = scope.deadbands;
            for (k = 0, len = ref.length; k < len; k++) {
              band = ref[k];
              if (rotation > band.min && rotation < band.max) {
                rotation = band.set;
              }
            }
            scope.transform.angle = rotation;
            scope.oldAngle = scope.newAngle;
            if (typeof callback !== "undefined" && callback !== null) {
              return callback();
            }
          },
          mouseDown: function(e) {
            PointerInput.addMove(scope.root.getElement(), scope.mouseMove);
            PointerInput.addUp(scope.root.getElement(), scope.mouseUp);
            PointerInput.addUp(window, scope.mouseUp);
            scope.begin(e);
            return scope.compute(e);
          },
          mouseMove: function(e) {
            return scope.compute(e);
          },
          mouseUp: function(e) {
            PointerInput.removeMove(scope.root.getElement(), scope.mouseMove);
            PointerInput.removeUp(scope.root.getElement(), scope.mouseUp);
            return PointerInput.removeUp(window, scope.mouseUp);
          }
        };
      });
    });
  })();

  (function() {
    var defaultElement;
    return Make("defaultElement", defaultElement = function(svgElement) {
      var scope;
      return scope = {
        setup: function() {},
        getElement: function() {
          return svgElement;
        },
        setText: function(text) {
          var textElement;
          textElement = svgElement.querySelector("text").querySelector("tspan");
          if (textElement != null) {
            return textElement.textContent = text;
          }
        },
        animate: function(dT, time) {}
      };
    });
  })();

  (function() {
    return Take(["Ease", "PointerInput", "Vector"], function(Ease, PointerInput, Vector) {
      var joystick, knobMaxScale, knobMaxY, middleMaxY, stemMaxY, topMaxY;
      knobMaxY = -30.1;
      knobMaxScale = 0.84;
      stemMaxY = -7.1;
      topMaxY = -8;
      middleMaxY = -4;
      return Make("Joystick", joystick = function(svgElement) {
        var scope;
        return scope = {
          movement: 0.0,
          "default": 0.0,
          down: false,
          mousePos: {
            x: 0,
            y: 0
          },
          moved: false,
          callbacks: [],
          rangeMin: 0,
          rangeMax: 1,
          setup: function() {
            scope.setTransforms();
            PointerInput.addDown(svgElement, scope.mouseDown);
            PointerInput.addMove(svgElement, scope.mouseMove);
            PointerInput.addMove(scope.root.getElement(), scope.mouseMove);
            PointerInput.addUp(svgElement, scope.mouseUp);
            return PointerInput.addUp(scope.root.getElement(), scope.mouseUp);
          },
          getElement: function() {
            return svgElement;
            return activity.registerInstance("joystick", "joystick");
          },
          setDefault: function(pos) {
            scope["default"] = Ease.linear(pos, scope.rangeMin, scope.rangeMax, 0, 1, true);
            scope.movement = scope["default"];
            return scope.setTransforms();
          },
          setTransforms: function() {
            scope.knob.child5.transform.y = scope.movement * knobMaxY;
            scope.knob.child5.transform.scaleY = (1.0 - scope.movement) + scope.movement * knobMaxScale;
            scope.knob.child4.transform.y = scope.movement * stemMaxY;
            scope.knob.child3.transform.y = scope.movement * topMaxY;
            return scope.knob.child2.transform.y = scope.movement * middleMaxY;
          },
          setRange: function(rMin, rMax) {
            scope.rangeMin = rMin;
            return scope.rangeMax = rMax;
          },
          mouseClick: function(e) {
            scope.movement = scope["default"];
            return scope.setTransforms();
          },
          mouseDown: function(e) {
            scope.down = true;
            return scope.mousePos = Vector.fromEventClient(e);
          },
          mouseMove: function(e) {
            var callback, distance, k, len, newPos, ref, results;
            if (scope.down) {
              scope.moved = true;
              newPos = Vector.fromEventClient(e);
              distance = (newPos.y - scope.mousePos.y) / 100;
              scope.mousePos = newPos;
              scope.movement -= distance;
              if (scope.movement > 1.0) {
                scope.movement = 1.0;
              } else if (scope.movement < 0.0) {
                scope.movement = 0.0;
              }
              scope.setTransforms();
              ref = scope.callbacks;
              results = [];
              for (k = 0, len = ref.length; k < len; k++) {
                callback = ref[k];
                results.push(callback(Ease.linear(scope.movement, 0, 1, scope.rangeMin, scope.rangeMax)));
              }
              return results;
            }
          },
          mouseUp: function() {
            var callback, k, len, ref;
            if (!scope.down) {
              return;
            }
            scope.down = false;
            if (!scope.moved) {
              scope.movement = scope["default"];
              scope.setTransforms();
              ref = scope.callbacks;
              for (k = 0, len = ref.length; k < len; k++) {
                callback = ref[k];
                callback(Ease.linear(scope.movement, 0, 1, scope.rangeMin, scope.rangeMax));
              }
            }
            return scope.moved = false;
          },
          registerCallback: function(callback) {
            return scope.callbacks.push(callback);
          }
        };
      });
    });
  })();

}).call(this);