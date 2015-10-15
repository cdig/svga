# SVG Activity
A library for making activities/animations with SVGs.

### Table of Contents
- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Bower and Scripts](#bower-and-scripts)
  - [Compiling with gulp] (#compiling-with-gulp)
  - [Adding in HTML] (#adding-in-html)
  - [Setup Activity] (#setup-activity)
    - [Folder Structure] (#folder-structure)
  
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
  - [Animating] (#animating)
  - [Default Symbol] (#default-symbol)
  
  
# Overview
Traditionally we have done our animations and activities using ActionScript and Flash. Since we are now targeting the web and mobile devices, we have been forced to move away from Flash. The purpose of SVG Activity is to provide methods in CoffeeScript to allow for interacting with and animating SVG files.


# Getting Started
Creating an SVG Activity involves a few steps:
* Adding a reference to SVG Activity in your bower file
* Having an SVG Activity on a cd-page with an embedded SVG
* Writing code to interact with an SVG

## Bower and Scripts
Similarly to [cd-module](https://github.com/cdig/cd-module), you need to include a reference to SVG Activity in your *bower.json* file. Inside of your ```"dependencies"``` include ```"svg-activity": "cdig/svg-activity"```. **Note** SVG-Activity now has a dependency of [Flow Arrows] (https://github.com/cdig/flow-arrows), so they are no longer required as a dependency for your project. 

You will also have to install Gulp ([Here is a guide] (https://travismaynard.com/writing/getting-started-with-gulp)). 

Along with including a reference to SVG Activity in your *bower.json* file, inside of your *scripts.coffee* you need to include a reference to SVG Activity: ```# @codekit-prepend '../bower_components/svg-activity/dist/scripts.coffee'```.

## Compiling with Gulp
When you do a bower update in the ```bower-components/svg-activity``` folder, there is a folder named ```gulp```. Copy all of the files from here into the main folder of your project. The very first time you do this you need to run the following command: ```npm install``` from the command line inside of your folder (**Note** you may need to be a root administrator for this, so, if the command doesn't work, use ```sudo npm install``` and then enter your password if required. This will get all of your dependencies ready.

Whenever you want to compile your coffee, go to the command line and run the following command ```gulp svgActivity --name="your-activity-name"```, where "your-activity-name" is what you will be compiling. It will be "big-hose" for the examples here. Gulp will compile and combine all of your files into one, based on their directory, with no need for specifying which files to include. Cool, eh?

##Adding in HTML
An SVG Activity needs to contain an SVG file to animate and interact with. As well as containing an SVG, you need to use specific mark up to specify an SVG Activity, with a specific ID. Shown below is what it would look like if we wanted to have an `svg-activity` **big-hose** with an SVG file located at the location ```image/big-hose.svg```

```html
<svg-activity id="big-hose">
   <object type="image/svg+xml" data="image/big-hose.svg" id="big-hose-svg">Your browser does not support SVG</object>
</svg-activity>
```

**Note**: An SVG is embedded using ```<object>```. This allows us to query the DOM to find this SVG and access its contents. The names for the activity id, the image name, and the id **have** to be done in this form now.

## Setup Activity
Discussed after this is specifics to coding an activity, but, to start, for any activity you will need to create a file with the same name as your ```svg-activity``` with ```-activity``` appended. So, in the case of *big-hose* the file name would become ```big-hose-activity.coffee```. Unlike most scripts, this file *has to be compiled* to the *public* directory. Inside of the public directory, compile this to ```big-hose-activity.js```.



###Folder Structure
Inside of your ```source``` directory, for all of your activities, you now need to make a folder ```activity```. For each activity you have, for example, ```big-hose```, make a folder inside of ```activity```. 


# Making an Activity 
Creating an SVG Activity is different in some ways to creating an activity using Actionscript, though some steps may be the same. Essentially, how they work is by creating a series of **symbol definitions**, similar to ActionScript, *registering these* in an activity and to particular **symbol instances**. You then can apply events
An SVG Activity is made up a few different parts:
  *Files that contain symbol definitions
  *Animations and interactions on these symbols
  *A root element
  *Registrations of symbols with instances.

SVG Activities *heavily* use [Take and Make] (https://github.com/cdig/take-and-make). Before making an SVG Activity, if you are not familiar with Take and Make, or aware of their purpose, please read about them.

## Symbol Definition
A symbol definition works very similarly in an SVG Activity to how it works in ActionScript. You create a symbol definition, a piece of code, that will be attached to a symbol instance later. Each one of these is created using *Make* and works as an *object* that contains functions and variables on the *scope* of that symbol definition, that will be used for a specific instance. An example of a symbol definition called ```gauge``` with comments to explain:

```coffeescript
#the do operator allows us to create a function for execution that runs immediately
#also, for variables that are shared between all symbol definitions and are unchanged. Constants, for example, declare them above the symbol definition so they can be accessed within
do ->
  dummyValue = 100 
  #every symbol definition is made using a call to ns with the name, to create a namespaced version of this symbol definition
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
```

## Root Element
Each SVG image has a root element and so, for an SVG Activity, we declare a root element that exists above all instances of SVG Symbol definitions. Here is a simple example of a root file:
```coffeescript
do ->
  activity.root = (svgElement)->
    return scope = 
      gaugeCount: 0
      setup : ()->
  activity.registerInstance("root", "root") #register the root element with this root
```
It is worth noting that a root element will be able to access all elements/instances in an SVG, so it works as a very good place to control an SVG Activity and all of its children. By listening for mouse events on a particular element, it can easily then call functions on other instances based on those mouse events.

## Registering Symbols with Instances
Each SVG has a series of instances, which are element names, and these have to be registered with your symbol definitions. To do this, you need to either use one of the files you've created in your file, or create an additional file where this registration is done. Anywhere in your code, the following code is for registering an instance ```activity.registerInstance('symbolDefinitionName', 'instanceName')```. 



#Instance of a Symbol
When you are creating a symbol definition, these will eventually be applied to an element inside of an SVG. For any one symbol definition, it can have many different instances. An instance of a symbol definition is an object containing the properties and methods defined in that symbol definition, but separate from all other instances. Function calls and property changes on that instance are separate from calls and property changes on other instances. 

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
####Translation
The translation of an object has an *x and y* component. To set these: ```scope.transform.x = 100```, and ```scope.transform.y = 100``` respectively
###Style
####Visibility
###Animating

  

