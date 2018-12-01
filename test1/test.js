let sceneWidth;
let sceneHeight;
let camera;
let scene;
let renderer;
let dom;
let hero;
let sun;
let ground;
let orbitControl;


init();

function init() {
    createScene();
    update();
}

function createScene() {
    sceneWidth = window.innerWidth;
    sceneHeight = window.innerHeight;

    scene = new THREE.Scene();

    camera = new THREE.PerspectiveCamera(60, sceneWidth/sceneHeight,0.1,1000);
    renderer = new THREE.WebGLRenderer({alpha:true});
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.setSize(sceneWidth, sceneHeight);
    dom = document.getElementById('TutContainer');
    
    dom.appendChild(renderer.domElement)

    // add items to scene
    let heroGeometry = new THREE.BoxGeometry(1,1,1)
    let heroMaterial = new THREE.MeshStandardMaterial({color: 0x883333})
    hero = new THREE.Mesh(heroGeometry , heroMaterial)
    hero.castShadow = true;
    hero.receiveShadow = false;
    hero.position.y=2;
    scene.add( hero );
    var planeGeometry = new THREE.PlaneGeometry( 5, 5, 4, 4 );
    var planeMaterial = new THREE.MeshStandardMaterial( { color: 0x00ff00 } )
    
    ground = new THREE.Mesh( planeGeometry, planeMaterial );
	ground.receiveShadow = true;
	ground.castShadow=false;
	ground.rotation.x=-Math.PI/2;
	scene.add( ground );

	camera.position.z = 5;
	camera.position.y = 1;
	
	sun = new THREE.DirectionalLight( 0xffffff, 0.8);
	sun.position.set( 0,4,1 );
	sun.castShadow = true;
	scene.add(sun);
	//Set up shadow properties for the sun light
	sun.shadow.mapSize.width = 256;
	sun.shadow.mapSize.height = 256;
	sun.shadow.camera.near = 0.5;
	sun.shadow.camera.far = 50 ;
	
	orbitControl = new THREE.OrbitControls( camera, renderer.domElement );//helper to rotate around in scene
	orbitControl.addEventListener( 'change', render );
	//orbitControl.enableDamping = true;
	//orbitControl.dampingFactor = 0.8;
	orbitControl.enableZoom = false;
	
	//var helper = new THREE.CameraHelper( sun.shadow.camera );
	//scene.add( helper );// enable to see the light cone
	
	window.addEventListener('resize', onWindowResize, false);//resize callback

}

function update() {
    hero.rotation.x += 0.01;
    hero.rotation.y += 0.01;
    render();
	requestAnimationFrame(update);//request next update
}

function render() {
    renderer.render(scene, camera);//draw
}

function onWindowResize() {
//resize & align
sceneHeight = window.innerHeight;
sceneWidth = window.innerWidth;
renderer.setSize(sceneWidth, sceneHeight);
camera.aspect = sceneWidth/sceneHeight;
camera.updateProjectionMatrix();
}