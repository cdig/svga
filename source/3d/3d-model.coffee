class Panel3d
    constructor: (@options, @scopes) ->
        @objectMethods = new Map()
        @animations = new Map()
        @highlightedObjects = new Set()
        @currentlyPressedTargets = new Set()
        @currentlyOverTargets = new Set()
        @morphingMeshes = []

        # For highlights
        @rainbowMaterial = new THREE.ShaderMaterial
            uniforms:
                uTime: { value: 0 }
                uColor1: { value: new THREE.Color("#2F6") }
                uColor2: { value: new THREE.Color("#FF2") }
                uColor3: { value: new THREE.Color("#F72") }
            vertexShader: """
                varying vec2 vUv;
                void main() {
                    vUv = uv;
                    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                }
            """
            fragmentShader: """
                varying vec2 vUv;
                uniform float uTime;
                uniform vec3 uColor1;
                uniform vec3 uColor2;
                uniform vec3 uColor3;
                void main() {
                    // This mimics your cos/sin rotation logic
                    float angle = uTime * 3.14159;
                    vec2 dir = vec2(cos(angle), sin(angle));
                    
                    // Project UV onto the rotating direction
                    float grad = dot(vUv - 0.5, dir) + 0.5;
                    
                    // Create a 3-stop gradient mix
                    vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, grad));
                    color = mix(color, uColor3, smoothstep(0.5, 1.0, grad));
                    
                    gl_FragColor = vec4(color, 1.0);
                }
            """

    log: (...args) ->
        if @options.debug then console.log "[#{@options.model}]", ...args

    expandResourceName: (name) ->
        host = window.location.host

        if host.indexOf(".com") > -1 or host.indexOf(".ca") > -1
            "https://cdn.lunchboxsessions.com/v4-1/models/#{name}"
        else
            "svga-models/#{name}"

    setupCanvas: () ->
        return new Promise (resolve, reject) =>

            try
                # Target the SVG and the Root Group
                @rootGroup = document.getElementById 'root'

                # Create the ForeignObject wrapper
                # This is the "container" that lets HTML live inside SVG
                @container = document.createElementNS 'http://www.w3.org/2000/svg', 'foreignObject'
                @container.setAttribute 'width', @options.panelSettings.width
                @container.setAttribute 'height', @options.panelSettings.height
                @container.setAttribute 'x', @options.panelSettings.x # Adjust these to position it within the SVG space
                @container.setAttribute 'y', @options.panelSettings.y
                
                @renderer = new THREE.WebGLRenderer(antialias: true, alpha: true)
                @renderer.setSize @options.panelSettings.width, @options.panelSettings.height
                @renderer.setPixelRatio 1
                @renderer.shadowMap.enabled = false;
            
            catch e
                console.warn("Could not create 3d components in this browser. Try turning on graphics acceleration in chrome settings: chrome://settings/?search=graphics+acceleration");
                reject(e)
            
            @canvas = @renderer.domElement
            @canvas.style.backgroundColor = @options.panelSettings.backgroundColor
            @canvas.style.borderRadius = @options.panelSettings.borderRadius

            @loaderDiv = document.createElement 'div'
            @loaderDiv.style.position = 'absolute'
            @loaderDiv.style.top = '0'
            @loaderDiv.style.left = '0'
            @loaderDiv.style.width = '100%'
            @loaderDiv.style.height = '100%'
            @loaderDiv.style.display = 'flex'
            @loaderDiv.style.justifyContent = 'center'
            @loaderDiv.style.alignItems = 'center'
            @loaderDiv.style.color = 'black'
            @loaderDiv.style.fontFamily = 'lato'
            @loaderDiv.style.fontSize = '20px'
            @loaderDiv.style.pointerEvents = 'none' # Clicks go through to OrbitControls
            @loaderDiv.innerHTML = "Initializing Engine..."

            # Assemble the tree: Root -> ForeignObject -> Wrapper -> (Canvas + Loader)
            @wrapper = document.createElement 'div'
            @wrapper.style.position = 'relative'
            @wrapper.appendChild @canvas
            @wrapper.appendChild @loaderDiv

            @container.appendChild @wrapper # Append wrapper instead of just canvas
            @rootGroup.appendChild @container
            
            if @options.blockNav then @canvas.setAttribute 'block-nav', true
            # Remove absolute positioning since it's now inside the SVG flow
            @canvas.style.display = 'block'

            # Scene Setup
            @scene = new THREE.Scene()
            @camera = new THREE.PerspectiveCamera(45, @options.panelSettings.width / @options.panelSettings.height, 0.1, 1000)
            @camera.position.set(@options.initialCameraPosition.x, @options.initialCameraPosition.y, @options.initialCameraPosition.z)

            @controls = new OrbitControls(@camera, @canvas)
            @controls.enableDamping = true
            @controls.enabled = @options.orbitAndZoom

            @mixer = null
            @actions = {}
            @clock = new THREE.Clock()
            @raycaster = new THREE.Raycaster()
            @mouse = new THREE.Vector2(-1, -1)

            pmremGenerator = new THREE.PMREMGenerator(@renderer)
            @scene.environment = pmremGenerator.fromScene(new THREE.Scene()).texture

            # Robust mouse mapping for SVG coordinates
            @updateMouse = (event) =>
                rect = @canvas.getBoundingClientRect()
                @mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
                @mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

            @onMouseDown = (event) =>
                rect = @canvas.getBoundingClientRect()
                @mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
                @mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

                @raycaster.setFromCamera @mouse, @camera
                intersects = @raycaster.intersectObjects @scene.children, true
                
                if intersects.length > 0
                    target = intersects[0].object
                    @log "clicked on:",target.name
                    # console.log target.name
                    # Bubble up to find a registered name
                    while target
                        methods = @objectMethods.get target.name
                        if methods
                            @currentlyPressedTargets.add(target);
                            methods.mouseDown?(target)
                            return # Stop looking once found
                        target = target.parent

            @onMouseUp = (event) =>

                for target from @currentlyPressedTargets
                    methods = @objectMethods.get target.name
                    if methods
                        methods.mouseUp?(target)
                
                @currentlyPressedTargets.clear()
            
            @canvas.addEventListener 'mousemove', @updateMouse
            @canvas.addEventListener 'mousedown', @onMouseDown
            @canvas.addEventListener 'mouseup', @onMouseUp

            # Load Model
            @loader = new GLTFLoader()

            @loader.setCrossOrigin('use-credentials')
            @loader.setWithCredentials true

            @loader.load (@expandResourceName @options.model), 
                (gltf) =>
                    @loaderDiv.style.display = 'none'
                    model = gltf.scene
                    model.traverse (node) =>

                        if node.isMesh
                            node.material.depthWrite = true
                            node.material.needsUpdate = true

                            if node.geometry and node.geometry.morphAttributes
                                node.material.morphTargets = true # Required for older Three.js
                                node.material.needsUpdate = true  # Forces shader recompilation

                                if node.morphTargetInfluences
                                    @log "Found morphable object:", node.name
                                    @morphingMeshes.push node

                    @scene.add model
                    
                    # Setup Mixer
                    if gltf.animations?.length > 0
                        @mixer = new THREE.AnimationMixer(model)
                        gltf.animations.forEach (clip) =>
                            action = @mixer.clipAction(clip)
                            @animations.set(clip.name, action)
                            @log("Found animation:", clip.name)

                    # Center logic
                    box = new THREE.Box3().setFromObject(model)
                    center = box.getCenter(new THREE.Vector3())
                    model.position.sub(center)

                    animate = =>
                        requestAnimationFrame animate
                        delta = @clock.getDelta();
                        @mixer?.update(delta)
                        @controls.update()
                        @renderer.render @scene, @camera

                        @rainbowMaterial.uniforms.uTime.value = (Date.now()%20000)/800

                        console.log(@renderer.info.render.calls)
                    
                    animate()

                    resolve(this)

                # 2. Progress Callback (onProgress)
                (xhr) =>
                    loadedMB = (xhr.loaded / 1024 / 1024).toFixed(2)
                    # If total is 0, just show MB. If total exists, show %
                    if xhr.total > 0
                        percent = Math.round(xhr.loaded / xhr.total * 100)
                        @loaderDiv.innerHTML = "Loading Model: #{percent}%"
                    else
                        @loaderDiv.innerHTML = "Loading 3D: #{loadedMB} MB"

                # 3. Error Callback (onError)
                (error) =>
                    console.warn("Failed to set up 3d panel. Model #{@options.resource} not found")
                    reject(error) # This triggers the .catch() on your createPanel call


            # Lighting
            @scene.add new THREE.AmbientLight(0xffffff, 3)
            sun = new THREE.DirectionalLight(0xffffff, 1.5)
            sun.position.set(5, 5, 5)
            sun2 = new THREE.DirectionalLight(0xffffff, 1.5)
            sun2.position.set(100, 100, 100) # Move it out
            @scene.add sun
            @scene.add sun2
    
    getObject: (meshName, methods) ->
        @objectMethods.set meshName, methods

        target = @scene.getObjectByName meshName
        return @_wrapInProxy target if target

    getObjects: (meshNames, methods) ->
        objects = meshNames.map((name) => @getObject(name, methods)).filter (obj) -> obj?

        return new Proxy objects,
            # Handles function calls: @group.morph(1)
            get: (target, prop) =>
                if prop in target then return target[prop]
                
                # We return a function that, when called, loops through the meshes
                return (args...) =>
                    for obj in target
                        if typeof obj[prop] is 'function'
                            obj[prop](args...)
                    return

            # Handles assignments: @group.pressure = 1
            # CRITICAL for Tweens and Sliders!
            set: (target, prop, value) =>
                for obj in target
                    obj[prop] = value
                return true # Standard Proxy requirement
        

    # Export objects in a wrapper so we can use the Highlight class on it like any other GUI element or SVG symbol
    _wrapInProxy: (object) ->
        # 1. Define the custom logic for your specific "virtual" properties
        proxyStorage =
            element: null # Will be set below
            _scope:
                _highlight: (state) => @setHighlight object, state
                _dontHighlightOnHover: false
            
            # Keep your custom methods
            morph: (val, target=0) ->
                unless object.morphTargetInfluences
                    console.warn "Object #{object.name} has no morph targets"
                    return
                if target >= object.morphTargetInfluences.length
                    console.warn "Target index out of bounds"
                    return
                object.morphTargetInfluences[target] = val

            # Required DOM mocks for Highlight class compatibility
            getAttribute: (name) -> null
            addEventListener: (name, cb) -> null
            tagName: "custom"
            childNodes: []

        proxyStorage.element = proxyStorage

        # 2. Create the Handler to bridge the Proxy and the Real Object
        handler = 
            get: (target, prop) ->
                # Priority 1: Check our custom proxyStorage (morph, element, etc)
                if prop of target then return target[prop]
                # Priority 2: Check the special 'pressure' logic
                if prop is 'pressure' then return target.__pressure
                # Priority 3: Fallback to the real THREE.js object
                return object[prop]

            set: (target, prop, value) =>
                if prop is 'pressure'
                    target.__pressure = value
                    @setColor object, @scopes.Pressure value
                    return true
                
                # CRITICAL: This line forwards material, position, etc. to the REAL mesh
                object[prop] = value
                return true

        # 3. Return the dynamic Proxy
        return new Proxy proxyStorage, handler

    getAnimation: (name) ->
        return @animations.get(name)

    setHighlight: (target, state) ->
        if target and target.isMesh
            if state
                target.userData.originalMaterial ?= target.material
                target.material = @rainbowMaterial
            else
                if target.userData.originalMaterial
                    target.material = target.userData.originalMaterial
    
    setColor: (target, color) ->
        # 1. Ensure we have a valid mesh and color
        return unless target and target.isMesh and color

        # 2. Check if the material is already 'unique' to this mesh.
        # If not, clone it so we don't colorize every other object in the scene.
        unless target.userData.isCloned
            target.material = target.material.clone()
            target.userData.isCloned = true
            # Store the 'original' color so you can revert it later if needed
            target.userData.originalColor = target.material.color.clone()

        # 3. Apply the new color
        # .set() handles hex strings, names, or other Color objects
        target.material.color.set(color)

    logCameraPosition: () ->
        console.log "[#{@options.model}] Camera pos:", @camera.position

class Model
    # The constructor runs when you call 'new Model()'
    constructor: (@scopes) ->
        @importMap = {
            imports: {
                "three": "https://unpkg.com/three@0.160.0/build/three.module.js",
                "three/addons/": "https://unpkg.com/three@0.160.0/examples/jsm/"
            }
        }
        @librariesReadyState = 0

    ensureLibrariesImported: ->
        # Return immediately if already loaded or loading
        if @librariesReadyState == 2 then return true
        if @librariesReadyState == 1 
            # Optional: logic to wait for existing loading process
            return 
            
        @librariesReadyState = 1
        
        # Inject Import Map
        imTag = document.createElement 'script'
        imTag.type = 'importmap'
        imTag.textContent = JSON.stringify @importMap
        document.head.appendChild imTag

        # We must assign to the outer THREE variable
        # Note: Use window.THREE if you want it globally accessible
        module = await import('three')
        window.THREE = module
        
        # Destructure addons
        { GLTFLoader } = await import('three/addons/loaders/GLTFLoader.js')
        { OrbitControls } = await import('three/addons/controls/OrbitControls.js')
        
        # Attach these to window so Panel can see them
        window.GLTFLoader = GLTFLoader
        window.OrbitControls = OrbitControls
        
        @librariesReadyState = 2

    # Change this to an async method
    createPanel: (options) ->
        await @ensureLibrariesImported()
        # Now THREE and OrbitControls are guaranteed to exist
        panel = new Panel3d options, @scopes
        await panel.setupCanvas()

        return panel

Take ["Pressure"],(Pressure)->
    Make "Model", new Model({Pressure})