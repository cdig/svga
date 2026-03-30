class Panel3d
    constructor: (@options, @scopes, @fullscreenModelContainer, @runningOnWebkit) ->
        @definedObjects = new Map()
        @animations = new Map()
        @highlightedObjects = new Set()
        @currentlyPressedTargets = new Set()
        @currentlyOverTargets = new Set()
        @morphingMeshes = []
        @rawHoverTarget = null
        @oldLogicalTarget = null
        @popovers = new Map()

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

    animatePopovers: () ->
        for [key, value] from @popovers
            if value.opts.show
                coords = @getScreenCoordinates value.opts.targetObject
                value.div.style.left = coords.x+'px'
                value.div.style.top = coords.y+'px'

    showPopover: (name) ->
        p = @popovers.get(name)
        if not p
            console.warn("popver",name,"does not exist")
            return
        p.opts.show = true
        p.div.style.display = 'unset'

    hidePopover: (name) ->
        p = @popovers.get(name)
        if not p
            console.warn("popver",name,"does not exist")
            return
        p.opts.show = false
        p.div.style.display = 'none'

    togglePopover: (name) ->
        p = @popovers.get(name)
        if not p
            console.warn("popver",name,"does not exist")
            return
        if p.opts.show
            @hidePopover name
        else
            @showPopover name

    getScreenCoordinates: (object) ->
        # 1. Get the geometric center of the object
        box = new THREE.Box3().setFromObject object
        center = new THREE.Vector3()
        box.getCenter center

        # 2. Project the world-space center to NDC (-1 to +1)
        center.project @camera
        
        x = (center.x + 1) * @canvas.clientWidth / 2
        y = (-center.y + 1) * @canvas.clientHeight / 2

        return { x: x, y: y }

    setupCanvas: () ->
        return new Promise (resolve, reject) =>

            try
                # Create the ForeignObject wrapper
                # This is the "container" that lets HTML live inside SVG

                @container = document.createElementNS 'http://www.w3.org/2000/svg', 'foreignObject'
                @container.id = '3d'
                if not @options.panelSettings.fullscreen
                    @container.setAttribute 'width', @options.panelSettings.width
                    @container.setAttribute 'height', @options.panelSettings.height
                    unless @runningOnWebkit
                        @container.setAttribute 'x', @options.panelSettings.x # Adjust these to position it within the SVG space
                        @container.setAttribute 'y', @options.panelSettings.y
                
                @renderer = new THREE.WebGLRenderer(antialias: true, alpha: true)
                @renderer.setSize @options.panelSettings.width, @options.panelSettings.height
                @renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
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

            @popoverLayer = document.createElement 'div'
            @popoverLayer.style.position = 'absolute'
            @popoverLayer.style.top = '0'
            @popoverLayer.style.left = '0'
            @popoverLayer.style.width = '100%'
            @popoverLayer.style.height = '100%'
            @popoverLayer.style.pointerEvents = 'none'

            # Assemble the tree: Root -> ForeignObject -> Wrapper -> (Canvas + Loader)
            @wrapper = document.createElement 'div'

            @wrapper.style.position = 'absolute'

            @wrapper.style.left = '0px'
            @wrapper.style.top = '0px'

            @wrapper.appendChild @canvas
            @wrapper.appendChild @loaderDiv
            @wrapper.appendChild @popoverLayer

            @container.appendChild @wrapper # Append wrapper instead of just canvas

            if @options.panelSettings.fullscreen
                @fullscreenModelContainer.prepend @container
                @scopes.Resize ()=>
                    @updateContainerSize()
            else
                @scopes.SVG.root.appendChild @container
            
            if @options.blockNav then @canvas.setAttribute 'block-nav', true
            # Remove absolute positioning since it's now inside the SVG flow
            @canvas.style.display = 'block'

            # Scene Setup
            @scene = new THREE.Scene()
            @textureLoader = new THREE.TextureLoader()
            @camera = new THREE.PerspectiveCamera(45, @options.panelSettings.width / @options.panelSettings.height, 0.1, 10000)
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

            if @options.panelSettings.fullscreen
                @updateContainerSize()

            @updateMouse = (event) =>
                @mouse.x = (event.offsetX / @canvas.clientWidth) * 2 - 1;
                @mouse.y = -(event.offsetY / @canvas.clientHeight) * 2 + 1;
                @raycaster.setFromCamera @mouse, @camera
                intersects = @raycaster.intersectObjects @scene.children, true
                
                # 1. Find the "Logical" owner of the hit mesh
                newLogicalTarget = null
                if intersects.length > 0
                    search = intersects[0].object
                    while search
                        # Check if this specific name has registered mouse methods
                        if @definedObjects.has(search.name)
                            newLogicalTarget = search
                            break
                        search = search.parent
                else
                    newLogicalTarget = null


                if newLogicalTarget isnt @rawHoverTarget
                    if newLogicalTarget
                        p = @definedObjects.get(newLogicalTarget.name)
                        if p?.methods?.mouseEnter
                            p.methods.mouseEnter p

                    if @oldLogicalTarget
                        p = @definedObjects.get(@oldLogicalTarget.name)
                        if p?.methods?.mouseExit
                            p.methods.mouseExit p

                # 3. Update the persistent state
                @oldLogicalTarget = newLogicalTarget
                @rawHoverTarget = newLogicalTarget

                for target from @currentlyPressedTargets
                    p = @definedObjects.get(target.name)
                    if p?.methods?.drag
                        p.methods.drag 2


            @onMouseDown = (event) =>
                @mouse.x = (event.offsetX / @canvas.clientWidth) * 2 - 1;
                @mouse.y = -(event.offsetY / @canvas.clientHeight) * 2 + 1;

                @raycaster.setFromCamera @mouse, @camera
                intersects = @raycaster.intersectObjects @scene.children, true
                
                if intersects.length > 0
                    target = intersects[0].object
                    @log "clicked on:",target.name
                    # Bubble up to find a registered name
                    while target
                        p = @definedObjects.get(target.name)
                        if p?.methods
                            @currentlyPressedTargets.add(target);
                            p.methods.mouseDown?(target)
                            return # Stop looking once found
                        target = target.parent

            @onMouseUp = (event) =>

                for target from @currentlyPressedTargets
                    p = @definedObjects.get(target.name)
                    if p?.methods
                        p.methods.mouseUp?(target)
                
                @currentlyPressedTargets.clear()
            
            @canvas.addEventListener 'mousemove', @updateMouse
            @canvas.addEventListener 'pointerdown', @onMouseDown
            @canvas.addEventListener 'pointerup', @onMouseUp

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
                        if @runningOnWebkit and not @options.panelSettings.fullscreen then @syncInternalTransform()
                        delta = @clock.getDelta();
                        @mixer?.update(delta)
                        @controls.update()
                        @animatePopovers()
                        @renderer.render @scene, @camera

                        @rainbowMaterial.uniforms.uTime.value = (Date.now()%20000)/800
                    
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
            if not @options.useCustomLighting
                @scene.add new THREE.AmbientLight(0xffffff, 3)
                sun = new THREE.DirectionalLight(0xffffff, 1)
                sun.position.set(5, 5, 5)
                sun2 = new THREE.DirectionalLight(0xffffff, 1)
                sun2.position.set(100, 100, 100) # Move it out
                sun3 = new THREE.DirectionalLight(0xffffff, 1)
                sun3.position.set(-100, -100, -100) # Move it out
                @scene.add sun
                @scene.add sun2
                @scene.add sun3

    syncInternalTransform: () ->
        matrix = @container.getScreenCTM()
        return unless matrix

        # 1. Extract scale (a) and translation (e, f)
        # e and f are the absolute screen X and Y of the element's origin
        currentScale = matrix.a
        screenX = matrix.e
        screenY = matrix.f

        # 2. Apply Position
        # We add the local panel offsets, but they must be scaled!
        # If panelSettings.x is 10, and zoom is 2x, it should move 20px.
        offsetX = @options.panelSettings.x * currentScale
        offsetY = @options.panelSettings.y * currentScale

        @wrapper.style.left = (screenX + offsetX) + "px"
        @wrapper.style.top  = (screenY + offsetY) + "px"

        # 3. Apply Scale and Dimensions
        @wrapper.style.width  = @options.panelSettings.width + "px"
        @wrapper.style.height = @options.panelSettings.height + "px"
        
        # Use transform for the scale so the browser doesn't struggle
        @wrapper.style.transform = "scale(#{currentScale})"
        @wrapper.style.transformOrigin = "top left"
        

    updateContainerSize: ()->
        @container.setAttribute "width", window.innerWidth
        @container.setAttribute "height", window.innerHeight
        @canvas.setAttribute "width", window.innerWidth
        @canvas.setAttribute "height", window.innerHeight
        @renderer.setSize @canvas.width, @canvas.height
        if @camera
            @camera.aspect = @canvas.width / @canvas.height
            @camera.updateProjectionMatrix()

    createMaterial: (opts) ->
        baseColorTex = @textureLoader.load @expandResourceName opts.baseColorTexture
        normalTex    = @textureLoader.load @expandResourceName opts.normalTexture
        ormTex       = @textureLoader.load @expandResourceName opts.oclusionRoughnessMetalicTexture

        baseColorTex.colorSpace = THREE.SRGBColorSpace
        baseColorTex.flipY = false 
        normalTex.flipY = false
        ormTex.flipY = false

        # IMPORTANT: ORM textures must NOT be sRGB. They are raw data.
        ormTex.colorSpace = THREE.NoColorSpace 

        mat = new THREE.MeshStandardMaterial
            map: baseColorTex
            normalMap: normalTex
            roughnessMap: ormTex
            metalnessMap: ormTex
            # # These scalars multiply against the map. 
            # # If the map is dark, 1.0 ensures you actually see the effect.
            roughness: 1.0 
            metalness: 1.0
            envMapIntensity: 0.5 # Crank this up to see if HDR is working!
            normalScale: new THREE.Vector2(1, 1)
        
        return mat

    useMaterialForAll: (mat) ->
        @scene.traverse (child) =>
            if child.isMesh
                child.material = mat

    useHDR: (hdrName) ->
        loader = new RGBELoader() 
        loader.setDataType(THREE.HalfFloatType)

        url = @expandResourceName hdrName

        loader.load url, (texture) =>
            texture.mapping = THREE.EquirectangularReflectionMapping

            @renderer.toneMapping = THREE.ACESFilmicToneMapping
            @renderer.toneMappingExposure = 2.0 # Try 2.0 if it's too dark
            @renderer.outputColorSpace = THREE.SRGBColorSpace

            @scene.environment = texture
            # @scene.background = texture # If you want to see the skybox

            @log "HDR Loaded: #{hdrName}"
            @scene.traverse (node) =>
                if node.isMesh
                    node.material.needsUpdate = true

    pauseOrbit: () ->
        @controls.enablePan = false
        @controls.enableRotate = false
        @controls.enableZoom = false

    resumeOrbit: () ->
        @controls.enablePan = true
        @controls.enableRotate = true
        @controls.enableZoom = true

    resetCamera: () ->
        # 1. Reset the focal point of the orbit (the center of rotation)
        @controls.enableDamping = false
        @controls.target.set(0, 0, 0)

        # 2. Reset the physical position of the camera
        @camera.position.set(
            @options.initialCameraPosition.x, 
            @options.initialCameraPosition.y, 
            @options.initialCameraPosition.z
        )

        # 3. Tell the controls to sync up
        @controls.update()
        @controls.enableDamping = true

    setCursor: (cursorType) ->
        @canvas.style.cursor = cursorType
        
    getObject: (meshName, methods) ->
        target = @scene.getObjectByName meshName
        p = @_wrapInProxy(target, methods) if target

        @definedObjects.set meshName, p
        return p

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
    _wrapInProxy: (object, methods) ->
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
            
            methods: methods

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

    createPopover: (name, opts) ->
        # Create the container
        div = document.createElement 'div'
        id = "P-"+Math.floor(10000+Math.random()*10000)
        
        # Apply Styles
        Object.assign div.style,
            position: 'absolute'
            left: '200px'
            top: '200px'
            backgroundColor: 'white'
            color: 'black'
            borderRadius: '8px'
            padding: '15px'
            boxShadow: '0 4px 12px rgba(0,0,0,0.1)' # Added a subtle shadow since there's no border
            width: '200px'
            zIndex: '1000'
            display: 'none'

        title = document.createElement 'h3'
        title.innerText = opts.title
        title.style.margin = '0 0 8px 0'
        title.style.fontSize = '16px'

        body = document.createElement 'p'
        body.innerText = opts.body
        body.style.margin = '0'
        body.style.fontSize = '14px'

        div.appendChild title
        div.appendChild body
        div.setAttribute "id", id

        @popoverLayer.appendChild div

        popover =
            div: div,
            opts: opts
        @popovers.set name, popover

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
        @svgaRestructured = false

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
        { RGBELoader } = await import('three/addons/loaders/RGBELoader.js')

        # Attach these to window so Panel can see them
        window.GLTFLoader = GLTFLoader
        window.OrbitControls = OrbitControls
        window.RGBELoader = RGBELoader
        
        @librariesReadyState = 2

    restructureSVGALayers: ->
        return if @svgaRestructured
        
        # Clone the SVG root element without children
        # clone = @options.SVG.cloneNode(false);
        svgaClone = @scopes.SVG.svg.cloneNode false
        svgaClone.id = 'svga-gui-layer'
        svgaClone.style.position = 'absolute'
        svgaClone.style.left = '0px'
        svgaClone.style.top = '0px'
        svgaClone.setAttribute 'width', window.innerWidth
        svgaClone.setAttribute 'height', window.innerHeight
        svgaClone.style.background = 'none';
        @scopes.SVG.svg.after svgaClone

        # Move the x-gui group into the other one
        svgaClone.appendChild @scopes.GUI.elm

        # Shallow copy the GUI back into the original svga, this will house the 3d model if full screen
        @fullscreenModelContainer = @scopes.GUI.elm.cloneNode false
        @scopes.SVG.root.after @fullscreenModelContainer

        # Add the resize method to the svgaClone
        @scopes.Resize ()=>
            svgaClone.setAttribute 'width', window.innerWidth
            svgaClone.setAttribute 'height', window.innerHeight

        # Enable pointer events if neccesary
        svgaClone.style.pointerEvents = 'none'
        # @scopes.GUI.elm.style.pointerEvents = 'none'
        for ele in @scopes.GUI.elm.querySelectorAll ':scope > g'
            ele.style.pointerEvents = 'all'

        @svgaRestructured = true

    # Change this to an async method
    createPanel: (options) ->
        await @ensureLibrariesImported()
        runningOnWebkit = @isWebKit()
        await @restructureSVGALayers()
        # Now THREE and OrbitControls are guaranteed to exist
        panel = new Panel3d options, @scopes, @fullscreenModelContainer, runningOnWebkit
        await panel.setupCanvas()

        return panel

    isWebKit: ->
        # Check for the vendor or the engine string
        # 'Apple Computer, Inc.' is the vendor for all iOS browsers and Safari
        isAppleVendor = navigator.vendor? and navigator.vendor.indexOf('Apple') > -1
        # Also check the User Agent for the engine name
        isWebKitEngine = /AppleWebKit/i.test(navigator.userAgent) and not /Chrome/i.test(navigator.userAgent)
        
        # On iOS, even Chrome reports as 'Apple Computer, Inc.'
        return isAppleVendor or isWebKitEngine

Take ["Pressure", "GUI" ,"Resize", "SVG"],(Pressure, GUI, Resize, SVG)->
    Make "Model", new Model({Pressure, GUI, Resize, SVG})