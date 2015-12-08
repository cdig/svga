# SVG Activity Components
A framework for making activities/animations with SVGs. If looking to build an SVG Activity, please look at the [SVG-Activity-Starter](https://github.com/cdig/svg-activity-starter)

### Table of Contents
- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Adding in HTML] (#adding-in-html)

  
- [Making an Activity] (#making-an-activity)
  - [Symbol Definition]  (#symbol-definition)
  - [Root Element] (#root-element)
  - [Registering Symbols] (#registering-symbols)
  

- [Instance of a Symbol] (#instance-of-a-symbol)
  - [Properties of an instance] (#properties-of-an-instance)
  - [Transform] (#transform)
    - [Scaling] (#scaling)
    - [Rotation] (#rotation)
    - [Translation] (#translation)
  - [Style] (#style)
    - [Visibility] (#visibility)
    - [Fill Colour] (#fill-colour)
    - [Hydraulic Pressure] (#hydraulic-pressure)
    - [Gradients] (#gradients)
    - [Text] (#text)
  - [Animating] (#animating)
- [Built in Symbols] (#built-in-symbols)
  -  Joystick (#joystick)  
  -  Crank (#crank)
    
- [Flow Arrows] (#flow-arrows)
  -[Flow Arrow Properties] (#flow-arrow-properties)   
  -[Linking with symbol] (#linking-with-symbol)
  -[Animating arrows] (#animating-lines)
  -[Styling arrows] (#styling-lines)

- [Styling with CSS] (#styling-with-css)
- [HTML and SVG Activity]
  
  
# Overview
Traditionally we have done our animations and activities using ActionScript and Flash. Since we are now targeting the web and mobile devices, we have been forced to move away from Flash. The purpose of an SVG Activity is to provide methods in CoffeeScript to allow for interacting with and animating SVG files.


# Getting Started
Please download the [SVG Activity Starter](https://github.com/cdig/svg-activity-starter) to get going on making an SVG.


##Adding in HTML
An SVG Activity needs to contain an SVG file to animate and interact with. As well as containing an SVG, you need to use specific mark up to specify an SVG Activity, with th and a unique ID. . Shown below is what it would look like if we wanted to have an `svg-activity` **big-hose** with an id of "big-hose1". We give an id in case we want to have multiple copies of an SVG on a page.

```html
<svg-activity name="big-hose" id="big-hose1">
   <object type="image/svg+xml" data="image/big-hose.svg" id="big-hose-svg">Your browser does not support SVG</object>
</svg-activity>
```

**Note**: An SVG is embedded using ```<object>```. This allows us to query the DOM to find this SVG and access its contents. 

## Setup Activity
Discussed after this is specifics to coding an activity, but, to start, for any activity you will need to create a file with the same name as your ```svg-activity``` with ```-activity``` appended. So, in the case of *big-hose* the file name would become ```big-hose-activity.coffee```. Unlike most scripts, this file *has to be compiled* to the *public* directory. Inside of the public directory, compile this to ```big-hose-activity.js```.



# Making an Activity 
Creating an SVG Activity is different in some ways to creating an activity using Actionscript, though some steps may be the same. Essentially, how they work is by creating a series of **symbol definitions**, similar to ActionScript, *registering these* in an activity and to particular **symbol instances**. You then can apply events
An SVG Activity is made up a few different parts:
  *Files that contain symbol definitions
  *Animations and interactions on these symbols
  *A root element
  *Registrations of symbols with instances.

SVG Activities *heavily* use [Take and Make] (https://github.com/cdig/take-and-make). Before making an SVG Activity, if you are not familiar with Take and Make, or aware of their purpose, please read about them.

## Symbol Definition
A symbol definition works very similarly in an SVG Activity to how it works in ActionScript. You create a symbol definition, a piece of code, that will be attached to a symbol instance later. For each instance of a symbol, register with the activity what the symbol definition used with it will be. An example of a symbol definition called ```gauge``` with comments to explain:

```coffeescript
#the do operator allows us to create a function for execution that runs immediately
#also, for variables that are shared between all symbol definitions and are unchanged. Constants, for example, declare them above the symbol definition so they can be accessed within
do ->
  dummyValue = 100 

  #Each symbol definiton, when it is applied to a particular instance of an element, takes in an svgElement.
  #make sure to register this with activity.symbolDefinition
  activity.gauge = (svgElement)-> 
    #returning scope allows us to, within an object, refer to its properties using scope, but is not needed
    #when accessing from a parent class
    return scope =
      
      reading: 0 ##property of an object
      
      setup : ()-> ##each symbol definiton has to have a set up function. This is called on an 
        scope.reading = 5#set the reading value. Note that you need to use 'scope.reading'' and not 'reading'
        scope.reading += dummyValue ##notice that dummyValue is created above scope and so it does not require 'scope.dummyValue' and is declared with an equal sign
        
      ##example function on a gauge
      setPressureReading: (value)-> 
        scope.reading = value
  activity.registerInstance("gauge1", "gauge") #register our instance with the
```

## Root Element
Each SVG image has a root element and so, for an SVG Activity, declare a root element that exists above all instances of SVG Symbol definitions. Here is a simple example of a root file:
```coffeescript
do ->
  activity.root = (svgElement)->
    return scope = 
      gaugeCount: 0
      setup : ()->
  activity.registerInstance("root", "root") #register the root element with this root
```
It is worth noting that a root element will be able to access all elements/instances in an SVG, so it works as a very good place to control an SVG Activity and all of its children. By listening for mouse events on a particular element, it can easily then call functions on other instances based on those mouse events. **Note** you must have a "root" element for an SVG Activity 

## Registering Symbols with Instances
Each SVG has a series of instances, which are element names, and these have to be registered with your symbol definitions. To do this, you need to either use one of the files you've created in your file, or create an additional file where this registration is done. Anywhere in your code, the following code is for registering an instance ```activity.registerInstance("symbolDefinitionName", "instanceName")```. 

#Instance of a Symbol
For any one symbol definition, it can have many different instances. An instance of a symbol definition is an object containing the properties and methods defined in that symbol definition, but separate from all other instances. Function calls and property changes on that instance are separate from calls and property changes on other instances. 

##Properties of an instance
All functions and properties declared on an instance, when inside of an instance, are accessed using `scope`. To illustrate, here is a sample symbol definition.
```coffeescript```
do->

  activity.watch = (svgElement)->
    return scope =
      needleDefPos: 0 #remember, all properties and functions need to be declared with :
      needleMaxPos: 360
      needleSpeed: 60
      needlePos: 0
      setup: ()-> #each symbol definition has to have a "setup" function. This is called when instances are created
        scope.setNeedlePos(100)
          
      reset: ()->
        scope.needlePos = 0
      
      setNeedlePos: (value)->
        scope.needlePos = value
      
      getElement: ()->
        return svgElement
      
      getDisplacement: ()->
        return (scope.needlePos - scope.needleDefPos)/360
```
When you are inside of an instance, i.e. local code, you access any property using ```scope.yourProperty``` and call any function by ```scope.yourFunction(...)```. You can see this in the ```setup``` function. A thing to note is that the **svgElement** is passed into a symbol definition when creating an instance. This is **not** declared on scope. To access the **svgElement** inside of an instance, you just need to write ```svgElement```. It is **highly** recommended you create a function called ```getElement``` like in the example above so that you can access the **svgElement** of an instance outside of that instance.

All properties of an instance, or functions, can be accessed without **scope**. For example, say you have an instance of **watch** named *watch1* that is on the *root*. To access the ```getElement``` call: ```element = root.watch1.getElement()```

###Transform
When any instance of a symbol is created, a few things happen:
  -The **setup** function on that instance is called
  -A style object is added on scope
  -A transform object is added on scope.
The **transform** of an instance controls its position in the scene. You change this by changing properties on the transform.
####Scaling
To change the scale of an object, you can change the scale in both the x and y directions. To do this, assuming we are in the function of a symbol: ```scope.transform.scaleX = 2.0```. You can also look up this value: ```scaleX = scope.transform.scaleX```. The same applies to **scaleY**
####Rotation
The rotation of an object is set using the **angle** property on its transform, or by using **turns**. Angle ranges between *0 and 360 degrees*. Turns range between *0 and 1*. To set the angle, like in the example above: ```scope.transform.angle = 120```. Similarly, to set **turns** ```scope.transform.turns = 0.5```.

To rotate around a particular point, use the ```cx``` and ```cy``` values, which sets the center for rotation.
####Translation
The translation of an object has an *x and y* component. To set these: ```scope.transform.x = 100```, and ```scope.transform.y = 100``` respectively
###Style
Each element instance is given a ```style``` property. You call functions on the style property to change style properites of an object
####Visibility
To change the visibility call ```scope.style.visible(isVisible)``` and you call with a ```true``` or ```false``` value. 

####Fill colour
In order to change the colour of an element, you call a function to change the colour of an element.
```scope.style.fill(color)```. **Note** This is a function, and not a value you assign.

####Hydraulic Pressure
To set the colour to a Hydraulic Pressure, call ```scope.style.setPressure(pressureVal)```. You can also look up what the pressure value is by calling ```scope.style.getPressure()```. To compute a pressure colour, call ```scope.style.getPressureColor(pressureVal, alphaVal)```. The ```alphaVal``` is an optional parameter and this handles the amount of transparency (by default the alpha value is 1).

####Gradients
Gradients in SVG Activities are an abstraction on the internal [SVG Gradients](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Gradients). Both of the options below require ```stops``` as a parameter. 
#####Linear Gradients
To set a linear gradient on an element, call ```scope.style.linearGradient(stops, x1, y1, x2, y2)```. The last four values are optional. To understand these, look into an explanation of [linear gradients in SVGs] (https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Gradients).

```stops``` are the stops with a color in an svg and are of the form ```{offset: offsetValueFromCenter, color: colorForStop}```.

#####Radial Gradients
To set a radial gradient on an element, call ```scope.style.radialGradient(stops, cx, cy, radius)```. The ```cx, cy``` properties are the center for the radial gradient. This allows you to move the gradient from off center if you would like. The radius is how large the gradient will expand.

The stops work the same as in linear gradients.

###Masking
Masking in an SVG Activity works very similarly to how masks worked in Flash, with a mask being specified over a particular object. Here is a code example for a mask.

```coffeescript
  Take "SVGMask", (SVGMask)->
    activity.root = (svgElement)->
      setup: ()->
        SVGMask(scope, scope.maskElement, scope.elementToMask, "mask")
      return scope = 
        getElement: ()->
          return svgElement
```
The first property passed to an SVG Mask call is the root object for your entire scene. In the above scene it is the ```scope``` since we are in the root already. Next pass the element being used for masking, then the element to mask, and lastly give this a **unique** name. Make sure that the ```scope.maskElement``` is placed on the main stage in Flash; additionally, masks in an SVG Activity **have to be white** if they are to allow through all colours of the objects they are masking. This allows us to have masks of different colours, if so desired, or even gradient masks.

###Animating
Animating an object in an SVG involves using ```SVGAnimation``` which we ```Take``` the same as ```SVGMask```
```coffeescript
do ->
  Take ["SVGMask", "SVGAnimation"], (SVGMask, SVGAnimation)->
    activity.root = (svgElement)->
      animation: null

      return scope = 
        setup: ()->
          SVGMask(scope, scope.oilMask, scope.oilPour, "oilMask")
          scope.animation = new SVGAnimation(scope.animate)
          scope.animation.start()

        animate: (dT, time)->
          rotationSpeed = 10.0
          scope.oilPour.transform.angle += rotationSpeed * dT
```
To animate an object, you first create an animation function under scope that takes two properties, ```dt``` and ```time``` (the function here is ```animate: (dt, time)```. The ```dT``` is the time, in seconds, between draw calls. **Note** Whereas in Flash you could set a frame rate and animate based on that framerate consistently, with SVG Animations an animation call will be as fast as possible. This is known as [Time-based animation] (http://blog.sklambert.com/using-time-based-animation-implement/). Next, in order to animate, an animation object needs to be created (usually done in setup) where this animation is created using ```new SVGAnimation(scope.yourAnimationFunction)```. Lastly, this animation can be started and stopped by ```scope.animation.start()``` and ```scope.animation.stop()``` respectively. 



##Built-in Symbols
Hey, we've got some symbols built in for you! 

###Button 
Say you have a symbol and you want it to be a button, all you need to do is to register it as a button. For example ```activity.registerInstance("myButton", "button")```. Then, somewhere in your scene, when referencing ```myButton``` to take advantage of when it's pressed, create a callback function and then pass it to the button like ```scope.myButton.setCallback(callbackFunction())```, then, whenever that button is clicked, the callbackFunction will be called.

###Crank
To register an object as a crank: ```activity.registerInstance("myCrank", "crank")```. Then there are a series of functions on ```myCrank```
```scope.myCrank.setCallback(callbackFunction())```. This is what you will pass to the crank to receive a value for when the crank is turned.
```scope.myCrank.setDomain: (min, max)```
```scope.myCrank.setRange(min, max)```
```scope.myCrank.addDeadband(min, set, max)```

###Joystick
To register an object as a joystick: ```activity.registerInstance("myJoystick", "joystick")```
Joysticks have a series of functions on them.
```scope.myJoystick.registeCallback(callbackFunction)``` this is the same as in crank and button.
```scope.myJoystick.setDefault(defaultValue)``` sets the default starting position of a joystick
```scope.myJoystick.setRange(min, max)``` sets the range
```scope.myJoystick.setSticky(isSticky)``` if the joystick is not sticky, when it is released, it will return to its original position; otherwise, it will stay in place.


  
##Flow Arrows
Like in Flash, we have the ability to take Flow Arrows, link to these in code, and have them animate in our scene. 
###Flow Arrow Properties
By default, the ```root``` of every svg-activity has the ability to handle flow arrows. This is now built in to SVG Activity. By changing properties on flow arrows, this is for all arrows in an activity. They are changed by ```scope.root.FlowArrows.property = propertyValue``` where the possible properties are ```MIN_SEGMENT_LENGTH```,  ```scale```, ```SPACING```, and ```FADE_LENGTH```.
###Linking With Symbol
In order to link create a flow arrow, and link it with a line, make the following call from something like either the main stage or root, whichever hosts your flow arrows.
```scope.arrows = scope.root.FlowArrows.setup(svgElement, scope.arrowInScene.getElement(), flowArrowsData)``` where ```svgElement``` is the element of the parent. ```scope.arrowInScene``` is the arrow we will be replacing, and the ```flowArrowsData``` is the data being used to give the line's path. This looks something like this:
```coffeescript
        flowArrowsData = []
        flowArrowsData.push({path:[""], edges:[[{x: -116.15, y: 49.6},{x: -116.15, y: 98},{x: -116.15, y: 146.4}]]})
        flowArrowsData.push({path:[""], edges:[[{x: -116.15, y: -11.2},{x: -116.15, y: -57.05},{x: -116.15, y: -102.9}]]})
```
Once an arrow has been created, it has properties that can be changed. For example, ```scope.arrows.flow = 0.4``` or ```scope.arrows.reverse()``` will reverse the direction of the arrows. You can even specify which segment to animate by calling ```scope.arrows.segment0.reverse()```. You can also change the scale of an arrow by ```scope.arrows.scale = 0.4```

###Animating Arrows
In order to start animating a series of arrows, call ```scope.root.FlowArrows.start()```. This will start the scene animation.

###Styling Arrows
You can specify the colour of an arrow by setting the colour property. In order to do this, on an arrow, call ```scope.arrows.setColor("red")```
