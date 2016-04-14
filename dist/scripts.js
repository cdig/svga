(function() {
  var Arrow, ArrowsContainer, Edge, SVGAnimation, SVGMask, SVGTransform, Segment, getParentInverseTransform, invert, invertSVGMatrix,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Take(["PointerInput", "PureDom", "SVGTransform", "Vector", "DOMContentLoaded"], function(PointerInput, PureDom, SVGTransform, Vector) {
    var Draggable, getParentRect, mouseConversion, updateMousePos, vecFromEventGlobal;
    vecFromEventGlobal = function(e) {
      return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset());
    };
    getParentRect = function(element) {
      var height, parent, rect, width;
      parent = PureDom.querySelectorParent(element, "svg");
      rect = parent.getBoundingClientRect();
      width = rect.width;
      height = rect.height;
      return rect;
    };
    mouseConversion = function(instance, position, parentElement, width, height) {
      var diff, parentRect, x, xDiff, y, yDiff;
      parentRect = getParentRect(parentElement);
      xDiff = width / parentElement.getBoundingClientRect().width / instance.transform.scale;
      yDiff = height / parentElement.getBoundingClientRect().height / instance.transform.scale;
      diff = Math.max(xDiff, yDiff);
      x = position.x * diff;
      y = position.y * diff;
      return {
        x: x,
        y: y
      };
    };
    updateMousePos = function(e, mouse) {
      mouse.pos = vecFromEventGlobal(e);
      mouse.delta = Vector.subtract(mouse.pos, mouse.last);
      return mouse.last = mouse.pos;
    };
    return Make("Draggable", Draggable = function(instance, parent) {
      var scope;
      if (parent == null) {
        parent = null;
      }
      return scope = {
        mouse: null,
        dragging: false,
        setup: function() {
          var properties;
          if (parent != null) {
            properties = parent.getElement().getAttribute("viewBox").split(" ");
            scope.viewWidth = parseFloat(properties[2]);
            scope.viewHeight = parseFloat(properties[3]);
          }
          scope.mouse = {};
          scope.mouse.pos = {
            x: 0,
            y: 0
          };
          scope.mouse.delta = {
            x: 0,
            y: 0
          };
          scope.mouse.last = {
            x: 0,
            y: 0
          };
          PointerInput.addDown(instance.grabber.getElement(), scope.mouseDown);
          PointerInput.addMove(instance.getElement(), scope.mouseMove);
          if (parent != null) {
            PointerInput.addMove(parent.getElement(), scope.mouseMove);
          }
          PointerInput.addUp(instance.getElement(), scope.mouseUp);
          if (parent != null) {
            return PointerInput.addUp(parent.getElement(), scope.mouseUp);
          }
        },
        mouseDown: function(e) {
          updateMousePos(e, scope.mouse);
          if (e.button === 0) {
            return scope.dragging = true;
          }
        },
        mouseMove: function(e) {
          var newMouse;
          updateMousePos(e, scope.mouse);
          if (scope.dragging) {
            if (parent != null) {
              newMouse = mouseConversion(instance, scope.mouse.delta, parent.getElement(), scope.viewWidth, scope.viewHeight);
            } else {
              newMouse = {
                x: scope.mouse.x,
                y: scope.mouse.y
              };
            }
            instance.transform.x += newMouse.x;
            return instance.transform.y += newMouse.y;
          }
        },
        mouseUp: function(e) {
          return scope.dragging = false;
        }
      };
    });
  });

  (function() {
    return Take(["PointerInput", "PureDom", "Vector", "DOMContentLoaded"], function(PointerInput, PureDom, Vector) {
      var FloatingMenu, addMousePercentage, convertToPercentage, getElementPositionPercentage, getParentRect, styleValToNumWithPrecision, updateMousePos, vecFromEventGlobal;
      vecFromEventGlobal = function(e) {
        return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset());
      };
      getParentRect = function(element) {
        var height, parent, rect, width;
        parent = PureDom.querySelectorParent(element, "svg-activity");
        rect = parent.getBoundingClientRect();
        width = rect.width;
        height = rect.height;
        return rect;
      };
      styleValToNumWithPrecision = function(n, p) {
        return parseFloat(n).toFixed(p).replace(/\0+$/, "").replace(/\.$/, "");
      };
      getElementPositionPercentage = function(element) {
        var left, parent, style, top;
        parent = getParentRect(element);
        style = element.style;
        if (style.left === "") {
          style = window.getComputedStyle(element);
        }
        left = 100 * styleValToNumWithPrecision(style.left, 2) / parent.width;
        top = 100 * styleValToNumWithPrecision(style.top, 2) / parent.height;
        return {
          x: parseFloat(styleValToNumWithPrecision(style.left, 2)),
          y: parseFloat(styleValToNumWithPrecision(style.top, 2))
        };
      };
      convertToPercentage = function(element, position) {
        var parent, x, y;
        parent = getParentRect(element);
        x = 100 * position.x / parent.width;
        y = 100 * position.y / parent.height;
        return {
          x: x,
          y: y
        };
      };
      addMousePercentage = function(element, mouse) {
        var mouseChange, original;
        original = getElementPositionPercentage(element);
        mouseChange = convertToPercentage(element, mouse.delta);
        return {
          x: original.x + mouseChange.x,
          y: original.y + mouseChange.y
        };
      };
      updateMousePos = function(e, mouse) {
        mouse.pos = vecFromEventGlobal(e);
        mouse.delta = Vector.subtract(mouse.pos, mouse.last);
        return mouse.last = mouse.pos;
      };
      return Make("FloatingMenu", FloatingMenu = function(element) {
        var scope;
        return scope = {
          mouse: null,
          dragging: false,
          setup: function(svgActivity) {
            var posPercent;
            posPercent = getElementPositionPercentage(element);
            scope.mouse = {};
            scope.mouse.pos = {
              x: 0,
              y: 0
            };
            scope.mouse.delta = {
              x: 0,
              y: 0
            };
            scope.mouse.last = {
              x: 0,
              y: 0
            };
            PointerInput.addDown(element, scope.mouseDown);
            PointerInput.addMove(element, scope.mouseMove);
            PointerInput.addMove(svgActivity, scope.mouseMove);
            return PointerInput.addUp(element, scope.mouseUp);
          },
          mouseDown: function(e) {
            updateMousePos(e, scope.mouse);
            if (e.button === 0) {
              return scope.dragging = true;
            }
          },
          mouseMove: function(e) {
            var newPosition;
            updateMousePos(e, scope.mouse);
            if (scope.dragging) {
              newPosition = addMousePercentage(element, scope.mouse);
              element.style.left = newPosition.x + "%";
              return element.style.top = newPosition.y + "%";
            }
          },
          mouseUp: function(e) {
            return scope.dragging = false;
          }
        };
      });
    });
  })();

  Take("PointerInput", function(PointerInput) {
    var POI;
    return Make("POI", POI = function(control, camera) {
      var scope;
      return scope = {
        scale: 1,
        x: 0,
        y: 0,
        setup: function() {
          control.getElement().addEventListener("mouseenter", function() {
            return control.style.fill("white");
          });
          control.getElement().addEventListener("mouseleave", function() {
            return control.style.fill("");
          });
          return PointerInput.addClick(control.getElement(), scope.transform);
        },
        setTransformation: function(x, y, scale) {
          scope.x = x;
          scope.y = y;
          return scope.scale = scale;
        },
        transform: function() {
          return camera.zoomToPosition(scope.scale, scope.x, scope.y);
        }
      };
    });
  });

  Take(["PointerInput", "DOMContentLoaded"], function(PointerInput) {
    var SVGArrows;
    return Make("SVGArrows", SVGArrows = function(activity, arrows, controlButton) {
      var scope;
      return scope = {
        open: true,
        setup: function() {
          return PointerInput.addClick(controlButton.getElement(), scope.toggle);
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return scope.show();
          } else {
            return scope.hide();
          }
        },
        show: function() {
          scope.open = true;
          return arrows.show();
        },
        hide: function() {
          scope.open = false;
          return arrows.hide();
        }
      };
    });
  });

  Take("PureDom", function(PureDom) {
    var SVGBackground;
    return Make("SVGBackground", SVGBackground = function(parentElement, activity, control) {
      var scope;
      return scope = {
        currentBackground: 0,
        activity: null,
        setup: function() {
          scope.cycleBackground(activity);
          return control.getElement().addEventListener("click", function() {
            return scope.cycleBackground(activity);
          });
        },
        cycleBackground: function(activity) {
          var svgElement;
          scope.currentBackground++;
          scope.currentBackground %= 3;
          svgElement = activity.getElement();
          switch (scope.currentBackground) {
            case 0:
              return svgElement.style["background-color"] = "#666666";
            case 1:
              return svgElement.style["background-color"] = "#bbbbbb";
            case 2:
              return svgElement.style["background-color"] = "#ffffff";
          }
        }
      };
    });
  });

  Take([], function() {
    var SVGBOM;
    return Make("SVGBOM", SVGBOM = function(parentElement, activity, control) {
      var scope;
      return scope = {
        callbacks: [],
        setup: function() {
          return control.getElement().addEventListener("click", function() {
            var callback, k, len, ref, results;
            ref = scope.callbacks;
            results = [];
            for (k = 0, len = ref.length; k < len; k++) {
              callback = ref[k];
              results.push(callback());
            }
            return results;
          });
        },
        setCallback: function(callback) {
          return scope.callbacks.push(callback);
        }
      };
    });
  });

  Take(["Ease", "PointerInput"], function(Ease, PointerInput) {
    var SVGCamera, setupElementWithFunction;
    setupElementWithFunction = function(svgElement, element, behaviourCode, addBehaviour, releaseBehaviour) {
      var behaviourId, keyBehaviourId, keyDown, onUp;
      behaviourId = 0;
      onUp = function(e) {
        releaseBehaviour();
        clearInterval(behaviourId);
        PointerInput.removeUp(element, onUp);
        return PointerInput.removeUp(svgElement, onUp);
      };
      PointerInput.addDown(element, function(e) {
        behaviourId = setInterval(addBehaviour, 16);
        PointerInput.addUp(element, onUp);
        return PointerInput.addUp(svgElement, onUp);
      });
      keyBehaviourId = 0;
      keyDown = false;
      svgElement.addEventListener("keydown", function(e) {
        if (keyDown) {
          return;
        }
        if (e.keyCode === behaviourCode) {
          e.preventDefault();
          keyDown = true;
          return keyBehaviourId = setInterval(addBehaviour, 16);
        }
      });
      return svgElement.addEventListener("keyup", function(e) {
        if (e.keyCode === behaviourCode) {
          e.preventDefault();
          releaseBehaviour();
          clearInterval(keyBehaviourId);
          return keyDown = false;
        }
      });
    };
    return Make("SVGCamera", SVGCamera = function(svgElement, mainStage, navOverlay, control) {
      var scope;
      return scope = {
        baseX: 0,
        baseY: 0,
        centerX: 0,
        maxZoom: 8.0,
        minZoom: 1.0,
        acceleration: 0.125,
        centerY: 0,
        transX: 0,
        transY: 0,
        scaleAdjustY: 0,
        baseWidth: 0,
        baseHeight: 0,
        zoom: 1,
        open: false,
        currentTime: null,
        mainStage: null,
        transValue: 800,
        navOverlay: null,
        velocity: null,
        upKey: false,
        downKey: false,
        leftKey: false,
        rightKey: false,
        releaseInY: false,
        releaseInX: false,
        releaseInZ: false,
        setup: function() {
          var parent, properties;
          parent = mainStage.root;
          properties = parent.getElement().getAttribute("viewBox").split(" ");
          scope.viewWidth = parseFloat(properties[2]);
          scope.viewHeight = parseFloat(properties[3]);
          scope.velocity = {
            x: 0,
            y: 0,
            z: 0
          };
          scope.mainStage = mainStage;
          navOverlay.style.show(false);
          control.getElement().addEventListener("click", scope.toggle);
          navOverlay.reset.getElement().addEventListener("click", function() {
            return scope.zoomToPosition(1, 0, 0);
          });
          navOverlay.close.getElement().addEventListener("click", scope.toggle);
          setupElementWithFunction(svgElement, navOverlay.up.getElement(), 38, scope.up, function() {
            scope.velocity.y = 1.0;
            scope.upKey = false;
            if (!(scope.downKey || scope.upKey)) {
              return scope.releaseInY = true;
            }
          });
          setupElementWithFunction(svgElement, navOverlay.down.getElement(), 40, scope.down, function() {
            scope.velocity.y = -1.0;
            scope.downKey = false;
            if (!(scope.downKey || scope.upKey)) {
              return scope.releaseInY = true;
            }
          });
          setupElementWithFunction(svgElement, navOverlay.left.getElement(), 37, scope.left, function() {
            scope.velocity.x = 1.0;
            scope.leftKey = false;
            if (!(scope.leftKey || scope.rightKey)) {
              return scope.releaseInX = true;
            }
          });
          setupElementWithFunction(svgElement, navOverlay.right.getElement(), 39, scope.right, function() {
            scope.velocity.x = -1.0;
            scope.rightKey = false;
            if (!(scope.leftKey || scope.rightKey)) {
              return scope.releaseInX = true;
            }
          });
          setupElementWithFunction(svgElement, navOverlay.plus.getElement(), 187, scope.plus, function() {
            scope.plusKey = false;
            if (!(scope.plusKey || scope.minusKey)) {
              return scope.releaseInZ = true;
            }
          });
          setupElementWithFunction(svgElement, navOverlay.minus.getElement(), 189, scope.minus, function() {
            scope.minusKey = false;
            if (!(scope.plusKey || scope.minusKey)) {
              return scope.releaseInZ = true;
            }
          });
          svgElement.addEventListener("keydown", function(e) {
            if (e.keyCode === 88) {
              return console.log("setTransformation(" + scope.transX + ", " + scope.transY + ", " + scope.zoom + ")");
            }
          });
          scope.handleScaling();
          return requestAnimationFrame(scope.updateAnimation);
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return navOverlay.style.show(true);
          } else {
            return navOverlay.style.show(false);
          }
        },
        left: function() {
          return scope.leftKey = true;
        },
        right: function() {
          return scope.rightKey = true;
        },
        up: function() {
          return scope.upKey = true;
        },
        down: function() {
          return scope.downKey = true;
        },
        updateAnimation: function(time) {
          var dT;
          if (scope.currentTime === null) {
            scope.currentTime = time;
          }
          dT = (time - scope.currentTime) / 1000;
          scope.currentTime = time;
          if (scope.downKey) {
            if (scope.velocity.y > 0) {
              scope.velocity.y = 0;
            }
            if (Math.abs(scope.velocity.y) <= 1.0) {
              scope.velocity.y -= scope.acceleration;
            }
          }
          if (scope.upKey) {
            if (scope.velocity.y < 0) {
              scope.velocity.y = 0;
            }
            if (Math.abs(scope.velocity.y) <= 1.0) {
              scope.velocity.y += scope.acceleration;
            }
          }
          if (scope.rightKey) {
            if (scope.velocity.x > 0) {
              scope.velocity.x = 0;
            }
            if (Math.abs(scope.velocity.x) <= 1.0) {
              scope.velocity.x -= scope.acceleration;
            }
          }
          if (scope.leftKey) {
            if (scope.velocity.x < 0) {
              scope.velocity.x = 0;
            }
            if (Math.abs(scope.velocity.x) <= 1.0) {
              scope.velocity.x += scope.acceleration;
            }
          }
          if (scope.plusKey) {
            if (scope.velocity.x < 0) {
              scope.velocity.z = 0;
            }
            if (Math.abs(scope.velocity.z) <= 1.0) {
              scope.velocity.z += scope.acceleration;
            }
          }
          if (scope.minusKey) {
            if (scope.velocity.z > 0) {
              scope.velocity.z = 1;
            }
            if (Math.abs(scope.velocity.z) <= 1.0) {
              scope.velocity.z -= scope.acceleration;
            }
          }
          if ((scope.leftKey && scope.rightKey) || (scope.upKey && scope.downKey) || (scope.plusKey && scope.minusKey)) {
            scope.velocity.x = 0;
            scope.velocity.y = 0;
            scope.velocity.z = 0;
          }
          scope.updatePosition(dT);
          return requestAnimationFrame(scope.updateAnimation);
        },
        updatePosition: function(dT) {
          var leftStop, length, rightStop, vX, vY, vZ;
          rightStop = svgElement.getBoundingClientRect().width / 2;
          leftStop = -svgElement.getBoundingClientRect().width / 2;
          if (scope.releaseInX) {
            scope.releaseX(dT);
          }
          if (scope.releaseInY) {
            scope.releaseY(dT);
          }
          if (scope.releaseInZ) {
            scope.releaseZ(dT);
          }
          length = Math.sqrt(scope.velocity.x * scope.velocity.x + scope.velocity.y * scope.velocity.y);
          if (scope.velocity.x === 0 && scope.velocity.y === 0) {
            length = 1;
          }
          vX = scope.velocity.x;
          if (length > 1) {
            vX /= length;
          }
          scope.transX += (vX * scope.transValue * dT) / scope.zoom;
          vY = scope.velocity.y;
          if (length > 1) {
            vY /= length;
          }
          scope.transY += (vY * scope.transValue * dT) / scope.zoom;
          vZ = scope.velocity.z;
          scope.zoom += (vZ * scope.getZoomIncrease() * 75 * dT) / scope.zoom;
          scope.boundX();
          scope.boundY();
          return scope.boundZ();
        },
        boundX: function() {
          var leftStop, rightStop;
          rightStop = svgElement.getBoundingClientRect().width / 2;
          leftStop = -svgElement.getBoundingClientRect().width / 2;
          if (scope.transX < leftStop) {
            scope.transX = leftStop;
          }
          if (scope.transX > rightStop) {
            scope.transX = rightStop;
          }
          return scope.mainStage.transform.x = scope.transX;
        },
        boundY: function() {
          return scope.mainStage.transform.y = scope.transY;
        },
        boundZ: function() {
          if (scope.zoom < scope.minZoom) {
            scope.zoom = scope.minZoom;
          }
          if (scope.zoom > scope.maxZoom) {
            scope.zoom = scope.maxZoom;
          }
          return scope.mainStage.transform.scale = scope.zoom;
        },
        releaseX: function(dT) {
          if (scope.downKey || scope.upKey || scope.rightKey || scope.downKey) {
            scope.releaseInX = false;
            scope.velocity.x = 0;
            return;
          }
          if (scope.velocity.x < 0) {
            scope.velocity.x += scope.acceleration;
            if (scope.velocity.x >= 0) {
              scope.velocity.x = 0;
              return scope.releaseInX = false;
            }
          } else if (scope.velocity.x > 0) {
            scope.velocity.x -= scope.acceleration;
            if (scope.velocity.x <= 0) {
              scope.velocity.x = 0;
              return scope.releaseInX = false;
            }
          }
        },
        releaseY: function(dT) {
          if (scope.downKey || scope.upKey || scope.rightKey || scope.downKey) {
            scope.releaseInY = false;
            scope.velocity.y = 0;
            return;
          }
          if (scope.velocity.y < 0) {
            scope.velocity.y += scope.acceleration;
            if (scope.velocity.y >= 0) {
              scope.velocity.y = 0;
              return scope.releaseInY = false;
            }
          } else if (scope.velocity.y > 0) {
            scope.velocity.y -= scope.acceleration;
            if (scope.velocity.y <= 0) {
              scope.velocity.y = 0;
              return scope.releaseInY = false;
            }
          }
        },
        releaseZ: function(dT) {
          if (scope.plusKey || scope.minusKey) {
            scope.releaseInZ = false;
            scope.velocity.z = 0;
            return;
          }
          if (scope.velocity.z < 0) {
            scope.velocity.z += scope.acceleration;
            if (scope.velocity.z >= 0) {
              scope.velocity.z = 0;
              return scope.releaseInZ = false;
            }
          } else if (scope.velocity.z > 0) {
            scope.velocity.z -= scope.acceleration;
            if (scope.velocity.z <= 0) {
              scope.velocity.z = 0;
              return scope.releaseInZ = false;
            }
          }
        },
        plus: function() {
          return scope.plusKey = true;
        },
        minus: function() {
          return scope.minusKey = true;
        },
        transform: function(x, y, scale) {
          scope.zoom = scale;
          scope.mainStage.transform.scale = scope.zoom;
          scope.transX = x;
          scope.mainStage.transform.x = scope.transX;
          scope.transY = y;
          return scope.mainStage.transform.y = scope.transY;
        },
        smoothTransformProperty: function(property, start, end) {
          var currentTime, timeToTransform, totalTime, transformProperty;
          timeToTransform = 1;
          currentTime = null;
          totalTime = 0;
          transformProperty = function(time) {
            var newValue;
            if (currentTime == null) {
              currentTime = time;
            }
            totalTime += (time - currentTime) / 1000;
            currentTime = time;
            newValue = Ease.cubic(totalTime, 0, timeToTransform, start, end);
            scope[property] = newValue;
            scope.setViewBox();
            if (totalTime < timeToTransform) {
              return requestAnimationFrame(transformProperty);
            }
          };
          return requestAnimationFrame(transformProperty);
        },
        getZoomIncrease: function() {
          var zoomIncrease, zoomSpeed;
          zoomSpeed = 0.03;
          zoomIncrease = zoomSpeed * scope.zoom;
          return zoomIncrease;
        },
        setViewBox: function() {
          var ncX, ncY, ntX, ntY;
          if (scope.zoom < scope.maxZoom) {
            scope.zoom = scope.maxZoom;
          }
          if (scope.zoom > scope.minZoom) {
            scope.zoom = scope.minZoom;
          }
          ntX = scope.transX * scope.zoom;
          ntY = scope.transY * scope.zoom;
          ncX = (scope.centerX + scope.transX) - (scope.centerX + scope.transX) * scope.zoom;
          ncY = (scope.centerY + scope.transY) - (scope.centerY + scope.transY) * scope.zoom;
          return svgElement.setAttribute("viewBox", (ncX + ntX) + " " + (ncY + ntY) + " " + (scope.baseWidth * scope.zoom) + " " + (scope.baseHeight * scope.zoom));
        },
        zoomToPosition: function(newZoom, newX, newY) {
          var animateToPosition, currentTime, easeFunction, increaseScale, increaseTransform, scaleDiff, timeElapsed, xDiff, xDone, yDiff, yDone, zoomDone;
          currentTime = null;
          increaseScale = 2;
          increaseTransform = 80;
          timeElapsed = 0;
          xDiff = Math.abs(scope.transX - newX);
          yDiff = Math.abs(scope.transY - newY);
          scaleDiff = Math.abs(scope.zoom - newZoom);
          xDone = false;
          yDone = false;
          zoomDone = false;
          easeFunction = Ease.quartic;
          animateToPosition = function(time) {
            var delta;
            if (currentTime === null) {
              currentTime = time;
            }
            delta = (time - currentTime) / 1000;
            currentTime = time;
            timeElapsed += delta;
            scope.mainStage.transform.x = easeFunction(timeElapsed * increaseTransform, 0, xDiff, scope.transX, newX);
            if (timeElapsed * increaseTransform >= xDiff) {
              xDone = true;
              scope.transX = newX;
              scope.mainStage.transform.x = scope.transX;
            }
            scope.mainStage.transform.y = easeFunction(timeElapsed * increaseTransform, 0, yDiff, scope.transY, newY);
            if (timeElapsed * increaseTransform >= yDiff) {
              yDone = true;
              scope.transY = newY;
              scope.mainStage.transform.y = scope.transY;
            }
            scope.mainStage.transform.scale = easeFunction(timeElapsed * increaseScale, 0, scaleDiff, scope.zoom, newZoom);
            if (timeElapsed * increaseScale > scaleDiff) {
              zoomDone = true;
              scope.zoom = newZoom;
              scope.mainStage.transform.scale = scope.zoom;
            }
            if (!(xDone && yDone && zoomDone)) {
              return requestAnimationFrame(animateToPosition);
            }
          };
          return requestAnimationFrame(animateToPosition);
        },
        handleScaling: function() {
          var onResize;
          onResize = function() {
            var boundingRect, navBox, navScale, navScaleX, navScaleY, newMinZoom, rectHeight, transAmount;
            boundingRect = mainStage.root.getElement().getBoundingClientRect();
            rectHeight = boundingRect.height;
            navBox = navOverlay.getElement().getBoundingClientRect();
            navScaleX = window.innerWidth / 2 / navBox.width;
            navScaleY = window.innerHeight / 2 / navBox.height;
            navScale = Math.min(navScaleX, navScaleY);
            navOverlay.transform.scale *= navScale;
            newMinZoom = (rectHeight - mainStage.root._controls.panelHeight - 10) / rectHeight;
            newMinZoom = Math.abs(newMinZoom);
            if (scope.zoom === scope.minZoom) {
              scope.zoom = newMinZoom;
            }
            transAmount = (1.0 - newMinZoom) * scope.viewHeight / 2;
            scope.transY -= scope.scaleAdjustY;
            navOverlay.transform.y -= scope.scaleAdjustY;
            scope.scaleAdjustY = -transAmount;
            scope.transY += scope.scaleAdjustY;
            navOverlay.transform.y += scope.scaleAdjustY;
            return scope.minZoom = newMinZoom;
          };
          onResize();
          return window.addEventListener("resize", onResize);
        }
      };
    });
  });

  Take(["SVGArrows", "SVGBackground", "SVGBOM", "SVGCamera", "SVGControl", "SVGLabels", "SVGMimic", "SVGPOI", "SVGSchematic"], function(SVGArrows, SVGBackground, SVGBOM, SVGCamera, SVGControl, SVGLabels, SVGMimic, SVGPOI, SVGSchematic) {
    var SVGControlpanel;
    return Make("SVGControlPanel", SVGControlpanel = function(activity, controlPanel) {
      var scope;
      return scope = {
        camera: null,
        background: null,
        bom: null,
        poi: null,
        control: null,
        labels: null,
        panelHeight: 50,
        setup: function() {
          var activityElement;
          activityElement = activity.getElement();
          if (controlPanel.nav != null) {
            scope.camera = new SVGCamera(activityElement, activity.mainStage, activity.navOverlay, controlPanel.nav);
            scope.camera.setup();
            if ((controlPanel.poi != null) && (activity.poiPanel != null)) {
              scope.poi = new SVGPOI(activity.poiPanel, controlPanel.poi, activity, scope.camera);
              scope.poi.setup();
            }
          }
          if (controlPanel.bom != null) {
            scope.bom = new SVGBOM(document, activity, controlPanel.bom);
            scope.bom.setup();
          }
          if (controlPanel.background != null) {
            scope.background = new SVGBackground(document, activity, controlPanel.background);
            scope.background.setup();
          }
          if ((activity.ctrlPanel != null) && controlPanel.controls) {
            scope.control = new SVGControl(activity, activity.ctrlPanel, controlPanel.controls);
            scope.control.setup();
          }
          if ((activity.mimicPanel != null) && controlPanel.mimic) {
            scope.control = new SVGControl(activity, activity.mimicPanel, controlPanel.mimic);
            scope.control.setup();
          }
          if (controlPanel.labels != null) {
            scope.labels = new SVGLabels(activity, activity.mainStage.labelsContainer, controlPanel.labels);
            scope.labels.setup();
          }
          if (controlPanel.arrows != null) {
            scope.arrows = new SVGArrows(activity, activity.FlowArrows, controlPanel.arrows);
            scope.arrows.setup();
          }
          if (controlPanel.toggle && (controlPanel.toggle.schematicSelected != null) && (controlPanel.toggle.animateSelected != null)) {
            scope.schematicToggle = new SVGSchematic(controlPanel.toggle, controlPanel, activity.mainStage);
            scope.schematicToggle.setup();
          }
          return scope.handleScaling();
        },
        handleScaling: function() {
          var onResize;
          onResize = function() {
            var activityBox, controlPanelBox, scaleAmount;
            controlPanelBox = controlPanel.getElement().getBoundingClientRect();
            scaleAmount = scope.panelHeight / (controlPanelBox.height / controlPanel.transform.scale);
            controlPanel.transform.scale = scaleAmount;
            activity.ctrlPanel.transform.scale = scaleAmount;
            controlPanelBox = controlPanel.getElement().getBoundingClientRect();
            activityBox = activity.getElement().getBoundingClientRect();
            return controlPanel.transform.y += activityBox.height - controlPanelBox.top - 50;
          };
          window.addEventListener("resize", function() {
            onResize();
            return onResize();
          });
          onResize();
          return onResize();
        }
      };
    });
  });

  Take(["Draggable", "PointerInput", "DOMContentLoaded"], function(Draggable, PointerInput) {
    var SVGControl;
    return Make("SVGControl", SVGControl = function(activity, control, controlButton) {
      var scope;
      return scope = {
        activity: null,
        open: false,
        draggable: null,
        setup: function() {
          scope.draggable = new Draggable(control, activity);
          scope.draggable.setup();
          PointerInput.addClick(controlButton.getElement(), scope.toggle);
          if (control.closer != null) {
            PointerInput.addClick(control.closer.getElement(), scope.hide);
          } else {
            console.log("Error: Control does not have closer button");
          }
          return scope.hide();
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return scope.show();
          } else {
            return scope.hide();
          }
        },
        show: function() {
          scope.open = true;
          return control.style.show(true);
        },
        hide: function() {
          scope.open = false;
          return control.style.show(false);
        }
      };
    });
  });

  Take([], function() {
    var SVGControls;
    return Make("SVGControls", SVGControls = function(svgElement) {
      var scope;
      return scope = {
        controls: [],
        open: false,
        setup: function() {
          return svgElement.addEventListener("click", scope.click);
        },
        addControl: function(control) {
          return scope.controls.push(control);
        },
        click: function() {
          var control, k, len, ref, results;
          scope.open = !scope.open;
          ref = scope.controls;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            control = ref[k];
            if (scope.open) {
              results.push(control.show());
            } else {
              results.push(control.hide());
            }
          }
          return results;
        }
      };
    });
  });

  Take(["PointerInput", "DOMContentLoaded"], function(PointerInput) {
    var SVGLabels;
    return Make("SVGLabels", SVGLabels = function(activity, labels, controlButton) {
      var scope;
      return scope = {
        open: true,
        setup: function() {
          return PointerInput.addClick(controlButton.getElement(), scope.toggle);
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return scope.show();
          } else {
            return scope.hide();
          }
        },
        show: function() {
          scope.open = true;
          return labels.style.show(true);
        },
        hide: function() {
          scope.open = false;
          return labels.style.show(false);
        }
      };
    });
  });

  Take(["Draggable", "PointerInput", "DOMContentLoaded"], function(Draggable, PointerInput) {
    var SVGMimic;
    return Make("SVGMimic", SVGMimic = function(activity, control, controlButton) {
      var scope;
      return scope = {
        activity: null,
        open: false,
        draggable: null,
        setup: function() {
          scope.draggable = new Draggable(control, activity);
          scope.draggable.setup();
          PointerInput.addClick(controlButton.getElement(), scope.toggle);
          if (control.closer != null) {
            PointerInput.addClick(control.closer.getElement(), scope.hide);
          } else {
            console.log("Error: Control does not have closer button");
          }
          return scope.hide();
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return scope.show();
          } else {
            return scope.hide();
          }
        },
        show: function() {
          scope.open = true;
          return control.style.show(true);
        },
        hide: function() {
          scope.open = false;
          return control.style.show(false);
        }
      };
    });
  });

  Take(["Draggable", "POI", "PointerInput"], function(Draggable, POI, PointerInput) {
    var SVGPOI;
    return Make("SVGPOI", SVGPOI = function(control, controlButton, svgActivity, camera) {
      var scope;
      return scope = {
        open: false,
        pois: {},
        setup: function() {
          var name, poi, results;
          scope.draggable = new Draggable(control, svgActivity);
          scope.draggable.setup();
          PointerInput.addClick(controlButton.getElement(), scope.toggle);
          if (control.closer != null) {
            PointerInput.addClick(control.closer.getElement(), scope.hide);
          } else {
            console.log("Error: POI does not have closer button");
          }
          scope.hide();
          results = [];
          for (name in control) {
            poi = control[name];
            if (name.indexOf("poi") > -1) {
              scope.pois[name] = new POI(poi, camera);
              results.push(scope.pois[name].setup());
            } else if (name.indexOf("reset") > -1) {
              scope.pois[name] = new POI(poi, camera);
              results.push(scope.pois[name].setup());
            } else {
              results.push(void 0);
            }
          }
          return results;
        },
        toggle: function() {
          scope.open = !scope.open;
          if (scope.open) {
            return scope.show();
          } else {
            return scope.hide();
          }
        },
        show: function() {
          scope.open = true;
          return control.style.show(true);
        },
        hide: function() {
          scope.open = false;
          return control.style.show(false);
        }
      };
    });
  });

  Take(["PointerInput"], function(PointerInput) {
    var SVGSchematic;
    return Make("SVGSchematic", SVGSchematic = function(toggle, svgControlPanel, mainStage) {
      var scope;
      return scope = {
        modeToggle: false,
        setup: function() {
          if ((toggle.schematicSelected == null) || (toggle.animateSelected == null)) {
            return;
          }
          PointerInput.addClick(toggle.schematicSelected.getElement(), function() {
            if (!scope.modeToggle) {
              scope.animateMode();
            }
            return scope.modeToggle = true;
          });
          return PointerInput.addClick(toggle.animateSelected.getElement(), function() {
            if (scope.modeToggle) {
              scope.schematicMode();
            }
            return scope.modeToggle = false;
          });
        },
        schematicMode: function() {
          var child, k, len, ref, results;
          toggle.schematicSelected.style.show(true);
          toggle.animateSelected.style.show(false);
          scope.callSchematicMode(mainStage.root);
          ref = mainStage.root.children;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            scope.turnLinesBlack(child);
            results.push(scope.callSchematicMode(child));
          }
          return results;
        },
        callSchematicMode: function(instance) {
          var child, k, len, ref;
          ref = instance.children;
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            scope.callSchematicMode(child);
          }
          if (instance.schematicMode != null) {
            instance.schematicMode();
          }
          if (svgControlPanel.arrows != null) {
            svgControlPanel.arrows.getElement().setAttribute("filter", "url(#greyscaleMatrix");
          }
          if (svgControlPanel.controls != null) {
            svgControlPanel.controls.getElement().setAttribute("filter", "url(#greyscaleMatrix");
          }
          if (svgControlPanel.poi != null) {
            svgControlPanel.poi.getElement().setAttribute("filter", "url(#greyscaleMatrix");
          }
          if (svgControlPanel.mimic != null) {
            return svgControlPanel.mimic.getElement().setAttribute("filter", "url(#greyscaleMatrix");
          }
        },
        turnLinesBlack: function(instance) {
          var child, element, id, k, len, ref, results;
          element = instance.getElement();
          id = element.getAttribute("id");
          if (id != null) {
            if (id.indexOf("Line") > -1) {
              instance.getElement().setAttribute("filter", "url(#allblackMatrix)");
            }
          }
          if (instance.children == null) {
            return;
          }
          ref = instance.children;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            results.push(scope.turnLinesBlack(child));
          }
          return results;
        },
        animateMode: function() {
          var child, k, len, ref;
          toggle.schematicSelected.style.show(false);
          toggle.animateSelected.style.show(true);
          scope.callAnimateMode(mainStage.root);
          ref = mainStage.root.children;
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            scope.turnLinesBack(child);
            scope.callAnimateMode(child);
          }
          if (svgControlPanel.arrows != null) {
            svgControlPanel.arrows.getElement().removeAttribute("filter");
          }
          if (svgControlPanel.controls != null) {
            svgControlPanel.controls.getElement().removeAttribute("filter");
          }
          if (svgControlPanel.poi != null) {
            svgControlPanel.poi.getElement().removeAttribute("filter");
          }
          if (svgControlPanel.mimic != null) {
            return svgControlPanel.mimic.getElement().removeAttribute("filter");
          }
        },
        callAnimateMode: function(instance) {
          var child, k, len, ref;
          ref = instance.children;
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            scope.callAnimateMode(child);
          }
          if (instance.animateMode != null) {
            return instance.animateMode();
          }
        },
        turnLinesBack: function(instance) {
          var child, element, id, k, len, ref, results;
          element = instance.getElement();
          id = element.getAttribute("id");
          if (id != null) {
            if (id.indexOf("Line") > -1) {
              instance.getElement().removeAttribute("filter");
            }
          }
          if (instance.children == null) {
            return;
          }
          ref = instance.children;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            child = ref[k];
            results.push(scope.turnLinesBlack(child));
          }
          return results;
        }
      };
    });
  });

  invert = function(matrix) {
    var copy, dim, i, identity, ii, j, k, l, m, o, q, r, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, s, t, temp;
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
        for (ii = o = 0, ref3 = dim - 1; 0 <= ref3 ? o <= ref3 : o >= ref3; ii = 0 <= ref3 ? ++o : --o) {
          if (copy[ii][i] !== 0) {
            for (j = q = 0, ref4 = dim - 1; 0 <= ref4 ? q <= ref4 : q >= ref4; j = 0 <= ref4 ? ++q : --q) {
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
      }
      for (j = r = 0, ref5 = dim - 1; 0 <= ref5 ? r <= ref5 : r >= ref5; j = 0 <= ref5 ? ++r : --r) {
        copy[i][j] = copy[i][j] / temp;
        identity[i][j] = identity[i][j] / temp;
      }
      for (ii = s = 0, ref6 = dim - 1; 0 <= ref6 ? s <= ref6 : s >= ref6; ii = 0 <= ref6 ? ++s : --s) {
        if (ii === i) {
          continue;
        }
        temp = copy[ii][i];
        for (j = t = 0, ref7 = dim - 1; 0 <= ref7 ? t <= ref7 : t >= ref7; j = 0 <= ref7 ? ++t : --t) {
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
    matrix[0][1] = parseFloat(matches[2]);
    matrix[0][2] = parseFloat(matches[4]);
    matrix[1][0] = parseFloat(matches[1]);
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
    return Take(['crank', 'defaultElement', 'button', 'slider', 'Joystick', 'SVGActivity', 'DOMContentLoaded'], function(crank, defaultElement, button, slider, Joystick, SVGActivity) {
      var SVGActivities, activities, activityDefinitions, waitingActivities, waitingForRunningActivity;
      activityDefinitions = [];
      activities = [];
      waitingActivities = [];
      waitingForRunningActivity = [];
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
          if (activities[activityId] != null) {
            return;
          }
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
          activity.slider = slider;
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
          svgElement.style.opacity = 1.0;
          activities[id] = svgActivity;
          return Make(id, activities[id].root);
        }
      });
    });
  })();

  (function() {
    return Take(["defaultElement", "PureDom", "FlowArrows", "SVGControlPanel", "SVGTransform", "SVGStyle", "load"], function(defaultElement, PureDom, FlowArrows, SVGControlPanel, SVGTransform, SVGStyle) {
      var SVGActivity, getChildElements, setupColorMatrix, setupInstance;
      setupInstance = function(instance) {
        var child, k, len, ref;
        ref = instance.children;
        for (k = 0, len = ref.length; k < len; k++) {
          child = ref[k];
          setupInstance(child);
        }
        return instance.setup();
      };
      setupColorMatrix = function(defs, name, matrixValue) {
        var colorMatrix, filter;
        filter = document.createElementNS("http://www.w3.org/2000/svg", "filter");
        filter.setAttribute("id", name);
        colorMatrix = document.createElementNS("http://www.w3.org/2000/svg", "feColorMatrix");
        colorMatrix.setAttribute("in", "SourceGraphic");
        colorMatrix.setAttribute("type", "matrix");
        colorMatrix.setAttribute("values", matrixValue);
        filter.appendChild(colorMatrix);
        return defs.appendChild(filter);
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
          registerControl: function(controlName) {},
          setupDocument: function(activityName, contentDocument) {
            var child, childElements, defs, k, len;
            scope.registerInstance("default", defaultElement);
            scope.root = scope.instances["root"](contentDocument);
            scope.root.FlowArrows = new FlowArrows();
            scope.root.root = scope.root;
            scope.root.getElement = function() {
              return contentDocument;
            };
            defs = contentDocument.querySelector("defs");
            setupColorMatrix(defs, "highlightMatrix", "0.5 0.0 0.0 0.0 00 0.5 1.0 0.5 0.0 20 0.0 0.0 0.5 0.0 00 0.0 0.0 0.0 1.0 00");
            setupColorMatrix(defs, "greyscaleMatrix", "0.33 0.33 0.33 0.0 0 0.33 0.33 0.33 0.0 0 0.33 0.33 0.33 0.0 0 0.0 0.0 0.0 1.0 0");
            setupColorMatrix(defs, "allblackMatrix", "0 0.0 0.0 0.0 0 0.0 0.0 0.0 0.0 0 0.0 0.0 0.0 0.0 0 0.0 0.0 0.0 1.0 0");
            childElements = getChildElements(contentDocument);
            scope.root.children = [];
            for (k = 0, len = childElements.length; k < len; k++) {
              child = childElements[k];
              scope.setupElement(scope.root, child);
            }
            if (scope.root.controlPanel != null) {
              scope.root._controls = new SVGControlPanel(scope.root, scope.root.controlPanel);
              scope.root._controls.setup();
            }
            setupInstance(scope.root);
            if (scope.root.controlPanel != null) {
              return scope.root._controls.schematicToggle.schematicMode();
            }
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
            parent[id].getElement = function() {
              return element;
            };
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

  Take("DOMContentLoaded", function() {
    var k, len, results, svgActivities, svgActivity;
    svgActivities = document.querySelectorAll("svg-activity");
    results = [];
    for (k = 0, len = svgActivities.length; k < len; k++) {
      svgActivity = svgActivities[k];
      results.push(svgActivity.querySelector("object").style.opacity = 0);
    }
    return results;
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

  getParentInverseTransform = function(root, element, currentTransform) {
    var inv, inversion, matches, matrixString, newMatrix;
    if (element.nodeName === "svg" || element.getAttribute("id") === "mainStage") {
      return currentTransform;
    }
    newMatrix = root.getElement().createSVGMatrix();
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

  Make("SVGMask", SVGMask = function(root, maskInstance, maskedInstance, maskName) {
    var invertMatrix, mask, maskElement, maskedElement, maskedParent, newStyle, origMatrix, origStyle, rootElement, transString;
    maskElement = maskInstance.getElement();
    maskedElement = maskedInstance.getElement();
    rootElement = root.getElement();
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
    maskedInstance.transform.setBaseTransform();
    return maskedParent.setAttribute("style", newStyle);
  });

  Take(["PureDom", "HydraulicPressure"], function(PureDom, HydraulicPressure) {
    var SVGStyle;
    return Make("SVGStyle", SVGStyle = function(svgElement) {
      var scope;
      return scope = {
        pressure: 0,
        visible: function(isVisible) {
          if (isVisible) {
            return svgElement.style.opacity = 1.0;
          } else {
            return svgElement.style.opacity = 0.0;
          }
        },
        show: function(showElement) {
          if (showElement) {
            return svgElement.style.visibility = "visible";
          } else {
            return svgElement.style.visibility = "hidden";
          }
        },
        setPressure: function(val, alpha) {
          if (alpha == null) {
            alpha = 1.0;
          }
          scope.pressure = val;
          return scope.fill(HydraulicPressure(scope.pressure, alpha));
        },
        getPressure: function() {
          return scope.pressure;
        },
        getPressureColor: function(pressure) {
          return HydraulicPressure(pressure);
        },
        stroke: function(color) {
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
            return path.setAttributeNS(null, "stroke", color);
          }
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
        setCallback: function(callback) {
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
          sticky: true,
          setup: function() {
            scope.setTransforms();
            PointerInput.addDown(svgElement, scope.mouseDown);
            PointerInput.addMove(svgElement, scope.mouseMove);
            PointerInput.addMove(scope.root.getElement(), scope.mouseMove);
            PointerInput.addUp(svgElement, scope.mouseUp);
            return PointerInput.addUp(scope.root.getElement(), scope.mouseUp);
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
          setSticky: function(sticky) {
            return scope.sticky = sticky;
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
            if (!scope.moved || !scope.sticky) {
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
          setCallback: function(callback) {
            return scope.callbacks.push(callback);
          }
        };
      });
    });
  })();

  Take(["Ease", "PointerInput", "PureDom", "SVGTransform", "Vector", "DOMContentLoaded"], function(Ease, PointerInput, PureDom, SVGTransform, Vector) {
    var Slider, getParentRect, mouseConversion, updateMousePos, vecFromEventGlobal;
    vecFromEventGlobal = function(e) {
      return Vector.add(Vector.create(e.clientX, e.clientY), Vector.fromPageOffset());
    };
    getParentRect = function(element) {
      var height, parent, rect, width;
      parent = PureDom.querySelectorParent(element, "svg");
      rect = parent.getBoundingClientRect();
      width = rect.width;
      height = rect.height;
      return rect;
    };
    mouseConversion = function(instance, position, parentElement, width, height) {
      var diff, parentRect, x, xDiff, y, yDiff;
      parentRect = getParentRect(parentElement);
      xDiff = width / parentElement.getBoundingClientRect().width / instance.transform.scale;
      yDiff = height / parentElement.getBoundingClientRect().height / instance.transform.scale;
      diff = Math.max(xDiff, yDiff);
      x = position.x * diff;
      y = position.y * diff;
      return {
        x: x,
        y: y
      };
    };
    updateMousePos = function(e, mouse) {
      mouse.pos = vecFromEventGlobal(e);
      mouse.delta = Vector.subtract(mouse.pos, mouse.last);
      return mouse.last = mouse.pos;
    };
    return Make("slider", Slider = function(svgElement) {
      var scope;
      return scope = {
        mouse: null,
        horizontalSlider: true,
        domainMin: 0,
        domainMax: 359,
        transformX: 0,
        transformY: 0,
        rangeMin: -1,
        rangeMax: 1,
        progress: 0,
        dragging: false,
        callback: function() {},
        setup: function() {
          var properties;
          scope.mouse = {};
          scope.mouse.pos = {
            x: 0,
            y: 0
          };
          scope.mouse.delta = {
            x: 0,
            y: 0
          };
          scope.mouse.last = {
            x: 0,
            y: 0
          };
          properties = scope.root.getElement().getAttribute("viewBox").split(" ");
          scope.viewWidth = parseFloat(properties[2]);
          scope.viewHeight = parseFloat(properties[3]);
          return PointerInput.addDown(svgElement, scope.mouseDown);
        },
        setVertical: function() {
          return scope.horizontalSlider = false;
        },
        setHorizontal: function() {
          return scope.horizontalSlider = true;
        },
        setCallback: function(callBackFunction) {
          return scope.callback = callBackFunction;
        },
        getValue: function() {
          return Ease.linear(scope.transform.angle, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
        },
        setValue: function(input) {
          return scope.unmapped = Ease.linear(input, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
        },
        setDomain: function(min, max) {
          scope.domainMin = min;
          return scope.domainMax = max;
        },
        setRange: function(min, max) {
          scope.rangeMin = min;
          return scope.rangeMax = max;
        },
        update: function() {
          if (typeof callback !== "undefined" && callback !== null) {
            return callback();
          }
        },
        mouseDown: function(e) {
          PointerInput.addMove(scope.root.getElement(), scope.mouseMove);
          PointerInput.addUp(scope.root.getElement(), scope.mouseUp);
          PointerInput.addUp(window, scope.mouseUp);
          scope.dragging = true;
          return updateMousePos(e, scope.mouse);
        },
        mouseMove: function(e) {
          var callbackValue, newMouse;
          updateMousePos(e, scope.mouse);
          if (scope.dragging) {
            if (typeof parent !== "undefined" && parent !== null) {
              newMouse = mouseConversion(scope, scope.mouse.delta, scope.root.getElement(), scope.viewWidth, scope.viewHeight);
            } else {
              newMouse = {
                x: scope.mouse.pos.x,
                y: scope.mouse.y
              };
            }
            callbackValue = 0;
            if (scope.horizontalSlider) {
              scope.transformX += newMouse.x;
              scope.transform.x = scope.transformX;
              if (scope.transform.x < scope.domainMin) {
                scope.transform.x = scope.domainMin;
              }
              if (scope.transform.x > scope.domainMax) {
                scope.transform.x = scope.domainMax;
              }
              callbackValue = Ease.linear(scope.transform.x, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
            } else {
              scope.transformY += newMouse.y;
              scope.transform.y = scope.transformY;
              if (scope.transform.y < scope.domainMin) {
                scope.transform.y = scope.domainMin;
              }
              if (scope.transform.y > scope.domainMax) {
                scope.transform.y = scope.domainMax;
              }
              callbackValue = Ease.linear(scope.transform.y, scope.domainMin, scope.domainMax, scope.rangeMin, scope.rangeMax);
            }
            return scope.callback(callbackValue);
          }
        },
        mouseUp: function(e) {
          scope.dragging = true;
          PointerInput.removeMove(scope.root.getElement(), scope.mouseMove);
          PointerInput.removeUp(scope.root.getElement(), scope.mouseUp);
          return PointerInput.removeUp(window, scope.mouseUp);
        }
      };
    });
  });

  Arrow = (function() {
    var getScaleFactor;

    Arrow.prototype.edge = null;

    Arrow.prototype.element = null;

    Arrow.prototype.visible = true;

    Arrow.prototype.vector = null;

    function Arrow(parent1, target, segment1, position1, edgeIndex1, flowArrows1) {
      var self;
      this.parent = parent1;
      this.target = target;
      this.segment = segment1;
      this.position = position1;
      this.edgeIndex = edgeIndex1;
      this.flowArrows = flowArrows1;
      this.update = bind(this.update, this);
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

    Arrow.prototype.update = function(deltaFlow) {
      var angle, currentPosition, fadeLength, scaleFactor, scalingFactor, transString;
      if (deltaFlow === 0 || !this.visible) {
        this.element.style.visibility = "hidden";
      } else {
        this.element.style.visibility = "visible";
      }
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

    function ArrowsContainer(target) {
      this.target = target;
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
      var k, len, ref, results, segment;
      ref = this.segments;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        segment = ref[k];
        results.push(segment.visible(isVisible));
      }
      return results;
    };

    ArrowsContainer.prototype.reverse = function() {
      return this.direction *= -1;
    };

    ArrowsContainer.prototype.setColor = function(fillColor) {
      var k, len, ref, results, segment;
      ref = this.segments;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        segment = ref[k];
        results.push(segment.setColor(fillColor));
      }
      return results;
    };

    ArrowsContainer.prototype.update = function(deltaTime) {
      var k, len, ref, results, segment;
      deltaTime *= this.direction;
      ref = this.segments;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        segment = ref[k];
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

  (function() {
    return Take("Organizer", function(Organizer) {
      var FlowArrows, removeOriginalArrow, startAnimation;
      removeOriginalArrow = function(selectedSymbol) {
        var child, children, k, l, len, len1, ref, results;
        children = [];
        ref = selectedSymbol.childNodes;
        for (k = 0, len = ref.length; k < len; k++) {
          child = ref[k];
          children.push(child);
        }
        results = [];
        for (l = 0, len1 = children.length; l < len1; l++) {
          child = children[l];
          results.push(selectedSymbol.removeChild(child));
        }
        return results;
      };
      startAnimation = function(arrowsContainers) {
        var currentTime, elapsedTime, update;
        currentTime = null;
        elapsedTime = 0;
        update = function(time) {
          var arrowsContainer, dT, k, len;
          if (currentTime == null) {
            currentTime = time;
          }
          dT = (time - currentTime) / 1000;
          currentTime = time;
          elapsedTime += dT;
          for (k = 0, len = arrowsContainers.length; k < len; k++) {
            arrowsContainer = arrowsContainers[k];
            arrowsContainer.update(dT);
          }
          return requestAnimationFrame(update);
        };
        return requestAnimationFrame(update);
      };
      return Make("FlowArrows", FlowArrows = function() {
        var scope;
        return scope = {
          SPEED: 200,
          MIN_EDGE_LENGTH: 8,
          MIN_SEGMENT_LENGTH: 1,
          CONNECTED_DISTANCE: 1,
          ARROWS_PROPERTY: "arrows",
          scale: 0.75,
          SPACING: 600,
          FADE_LENGTH: 50,
          arrowsContainers: [],
          setup: function(parent, selectedSymbol, linesData) {
            var arrowsContainer, k, len, lineData;
            removeOriginalArrow(selectedSymbol);
            arrowsContainer = new ArrowsContainer(selectedSymbol);
            scope.arrowsContainers.push(arrowsContainer);
            for (k = 0, len = linesData.length; k < len; k++) {
              lineData = linesData[k];
              Organizer.build(parent, lineData.edges, arrowsContainer, this);
            }
            return arrowsContainer;
          },
          show: function() {
            var arrowsContainer, k, len, ref, results;
            ref = scope.arrowsContainers;
            results = [];
            for (k = 0, len = ref.length; k < len; k++) {
              arrowsContainer = ref[k];
              results.push(arrowsContainer.visible(true));
            }
            return results;
          },
          hide: function() {
            var arrowsContainer, k, len, ref, results;
            ref = scope.arrowsContainers;
            results = [];
            for (k = 0, len = ref.length; k < len; k++) {
              arrowsContainer = ref[k];
              results.push(arrowsContainer.visible(false));
            }
            return results;
          },
          start: function() {
            return startAnimation(scope.arrowsContainers);
          }
        };
      });
    });
  })();

  (function() {
    var Organizer, angle, cullShortEdges, cullShortSegments, cullUnusedPoints, distance, edgesToLines, finish, formSegments, isConnected, isInline, joinSegments;
    edgesToLines = function(edgesData) {
      var edge, i, k, linesData, ref;
      linesData = [];
      edge = [];
      for (i = k = 0, ref = edgesData.length - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
        edge = edgesData[i];
        linesData.push(edge[0], edge[2]);
      }
      return linesData;
    };
    formSegments = function(lineData, flowArrows) {
      var i, k, pointA, pointB, ref, segmentEdges, segments;
      segments = [];
      segmentEdges = null;
      for (i = k = 0, ref = lineData.length - 1; k <= ref; i = k += 2) {
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
      var edge, edges, i, j, k, l, ref, ref1, results, segPoints, segmentLength;
      results = [];
      for (i = k = 0, ref = segments.length - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
        segPoints = segments[i];
        segmentLength = 0;
        edges = [];
        for (j = l = 0, ref1 = segPoints.length - 2; 0 <= ref1 ? l <= ref1 : l >= ref1; j = 0 <= ref1 ? ++l : --l) {
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

    Segment.prototype.fillColor = "white";

    function Segment(parent1, edges1, arrowsContainer1, segmentLength1, flowArrows1) {
      var arrow, edge, edgeIndex, i, k, position, ref, segmentArrows, segmentSpacing, self;
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
      for (i = k = 0, ref = segmentArrows - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
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
      var arrow, k, len, ref, results;
      ref = this.arrows;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        arrow = ref[k];
        results.push(arrow.visible = isVisible);
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
      var arrow, arrowFlow, k, len, ref, results;
      arrowFlow = this.flow != null ? this.flow : ancestorFlow;
      if (this.flowArrows) {
        arrowFlow *= deltaTime * this.direction * this.flowArrows.SPEED;
      }
      ref = this.arrows;
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        arrow = ref[k];
        arrow.setColor(this.fillColor);
        results.push(arrow.update(arrowFlow));
      }
      return results;
    };

    return Segment;

  })();

}).call(this);
