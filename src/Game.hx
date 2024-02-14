import kha.Scheduler;
import kha.input.KeyCode;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.Image;
import kha.Assets;
import kha.graphics4.TextureUnit;
import kha.graphics5_.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.math.FastVector3;
import kha.math.FastMatrix4;
import kha.Color;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.Shaders;
import kha.graphics5_.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.Framebuffer;

class Game
{
	// An array of vertices to form a cube
	static var vertices:Array<Float> = [
		-1.0, -1.0, -1.0, -1.0, -1.0,  1.0, -1.0,  1.0,  1.0,
		 1.0,  1.0, -1.0, -1.0, -1.0, -1.0, -1.0,  1.0, -1.0,
		 1.0, -1.0,  1.0, -1.0, -1.0, -1.0,  1.0, -1.0, -1.0,
		 1.0,  1.0, -1.0,  1.0, -1.0, -1.0, -1.0, -1.0, -1.0,
		-1.0, -1.0, -1.0, -1.0,  1.0,  1.0, -1.0,  1.0, -1.0,
		 1.0, -1.0,  1.0, -1.0, -1.0,  1.0, -1.0, -1.0, -1.0,
		-1.0,  1.0,  1.0, -1.0, -1.0,  1.0,  1.0, -1.0,  1.0,
		 1.0,  1.0,  1.0,  1.0, -1.0, -1.0,  1.0,  1.0, -1.0,
		 1.0, -1.0, -1.0,  1.0,  1.0,  1.0,  1.0, -1.0,  1.0,
		 1.0,  1.0,  1.0,  1.0,  1.0, -1.0, -1.0,  1.0, -1.0,
		 1.0,  1.0,  1.0, -1.0,  1.0, -1.0, -1.0,  1.0,  1.0,
		 1.0,  1.0,  1.0, -1.0,  1.0,  1.0,  1.0, -1.0,  1.0
	];

	// Array of colors for each cube vertex
	static var colors:Array<Float> = [
		0.583, 0.771, 0.014, 0.609, 0.115, 0.436, 0.327, 0.483, 0.844,
		0.822, 0.569, 0.201, 0.435, 0.602, 0.223, 0.310, 0.747, 0.185,
		0.597, 0.770, 0.761, 0.559, 0.436, 0.730, 0.359, 0.583, 0.152,
		0.483, 0.596, 0.789, 0.559, 0.861, 0.639, 0.195, 0.548, 0.859,
		0.014, 0.184, 0.576, 0.771, 0.328, 0.970, 0.406, 0.615, 0.116,
		0.676, 0.977, 0.133, 0.971, 0.572, 0.833, 0.140, 0.616, 0.489,
		0.997, 0.513, 0.064, 0.945, 0.719, 0.592, 0.543, 0.021, 0.978,
		0.279, 0.317, 0.505, 0.167, 0.620, 0.077, 0.347, 0.857, 0.137,
		0.055, 0.953, 0.042, 0.714, 0.505, 0.345, 0.783, 0.290, 0.734,
		0.722, 0.645, 0.174, 0.302, 0.455, 0.848, 0.225, 0.587, 0.040,
		0.517, 0.713, 0.338, 0.053, 0.959, 0.120, 0.393, 0.621, 0.362,
		0.673, 0.211, 0.457, 0.820, 0.883, 0.371, 0.982, 0.099, 0.879
	];

	// Array of texture coords for each cube vertex
	static var uvs:Array<Float> = [
		0.000059, 0.000004, 0.000103, 0.336048, 0.335973, 0.335903,
		1.000023, 0.000013, 0.667979, 0.335851, 0.999958, 0.336064,
		0.667979, 0.335851, 0.336024, 0.671877, 0.667969, 0.671889,
		1.000023, 0.000013, 0.668104, 0.000013, 0.667979, 0.335851,
		0.000059, 0.000004, 0.335973, 0.335903, 0.336098, 0.000071,
		0.667979, 0.335851, 0.335973, 0.335903, 0.336024, 0.671877,
		1.000004, 0.671847, 0.999958, 0.336064, 0.667979, 0.335851,
		0.668104, 0.000013, 0.335973, 0.335903, 0.667979, 0.335851,
		0.335973, 0.335903, 0.668104, 0.000013, 0.336098, 0.000071,
		0.000103, 0.336048, 0.000004, 0.671870, 0.336024, 0.671877,
		0.000103, 0.336048, 0.336024, 0.671877, 0.335973, 0.335903,
		0.667969, 0.671889, 1.000004, 0.671847, 0.667979, 0.335851
	];

	var vb:VertexBuffer;
	var ib:IndexBuffer;
	var pipeline:PipelineState;
	var mvp:FastMatrix4;
	var mvpId:ConstantLocation;
	var textureId:TextureUnit;
	var image:Image;
	
	var speed = 3.0; // 3 units / second
	var mouseSpeed = 0.005;

	var position:FastVector3 = new FastVector3(0, 0, 5); // Initial position: on +Z
	var horizontalAngle = 3.14; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none

	var isMouseDown:Bool;
	var mouseDeltaX:Int;
	var mouseDeltaY:Int;
	var mouseX:Int;
	var mouseY:Int;

	var moveForward:Bool;
	var moveBackward:Bool;
	var strafeLeft:Bool;
	var strafeRight:Bool;

	var lastTime:Float;

	var projection:FastMatrix4;

	public function new()
	{
		var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		structure.add("col", VertexData.Float3);
		structure.add("uv", VertexData.Float2);
		var structureLength = 8;

		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Keyboard.get().notify(onKeyDown, onKeyUp);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		// pipeline.colorAttachmentCount = 1;
		// pipeline.colorAttachments[0] = TextureFormat.RGBA32;
		// pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
		pipeline.compile();

		mvpId = pipeline.getConstantLocation("MVP");
		textureId = pipeline.getTextureUnit("myTextureSampler");

		image = Assets.images.uvtemplate;
		// var px = image.getPixels();
		// trace(px.length);

		// Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
		projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);

		// Camera matrix
		var view = FastMatrix4.lookAt(new FastVector3(3, 2, 2), // position in world space
			new FastVector3(0, 0, 0), // look at the origin
			new FastVector3(0, 1, 0), // "Y" is UP
		);

		// Model matrix
		var model = FastMatrix4.identity(); // model will be at the origin

		// multiplication order matters on matrices!
		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		vb = new VertexBuffer(Std.int(vertices.length / 3), structure, StaticUsage);
		var vbData = vb.lock();
		for (i in 0...Std.int(vbData.length / structureLength))
		{
			vbData.set(i * structureLength, vertices[i * 3]);
			vbData.set(i * structureLength + 1, vertices[i * 3 + 1]);
			vbData.set(i * structureLength + 2, vertices[i * 3 + 2]);
			vbData.set(i * structureLength + 3, colors[i * 3]);
			vbData.set(i * structureLength + 4, colors[i * 3 + 1]);
			vbData.set(i * structureLength + 5, colors[i * 3 + 2]);
			vbData.set(i * structureLength + 6, uvs[i * 2]);
			vbData.set(i * structureLength + 7, uvs[i * 2 + 1]);
		}
		vb.unlock();

		var indices:Array<Int> = [];
		for (i in 0...Std.int(vertices.length / 3))
		{
			indices.push(i);
		}

		ib = new IndexBuffer(indices.length, StaticUsage);

		var ibData = ib.lock();
		for (i in 0...indices.length)
		{
			ibData.set(i, indices[i]);
		}
		ib.unlock();
	}

	public function update() {
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();

		if (isMouseDown) {
			horizontalAngle += mouseSpeed * mouseDeltaX * -1;
			verticalAngle += mouseSpeed * mouseDeltaY * -1;
		}

		var direction = new FastVector3(
			Math.cos(verticalAngle) * Math.sin(horizontalAngle),
			Math.sin(verticalAngle),
			Math.cos(verticalAngle) * Math.cos(horizontalAngle)
		);

		var right = new FastVector3(
			Math.sin(horizontalAngle - 3.13 / 2.0),
			0,
			Math.cos(horizontalAngle - 3.14 / 2.0)
		);

		var up = right.cross(direction);

		if (moveForward) {
			var v = direction.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (moveBackward) {
			var v = direction.mult(deltaTime * speed * -1);
			position = position.add(v);
		}
		if (strafeRight) {
			var v = right.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (strafeLeft) {
			var v = right.mult(deltaTime * speed * -1);
			position = position.add(v);
		}

		var look = position.add(direction);

		var view = FastMatrix4.lookAt(
			position,
			look,
			up
		);
		var model = FastMatrix4.identity();

		mvp = FastMatrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		mouseDeltaX = 0;
		mouseDeltaY = 0;
	}

	public function render(frames:Array<Framebuffer>)
	{
		var fb = frames[0];
		var g = fb.g4;

		g.setMatrix(mvpId, mvp);
		g.setTexture(textureId, image);

		g.begin();

		g.clear(Color.fromFloats(0.0, 0.0, 0.3), 1);

		g.setPipeline(pipeline);
		g.setVertexBuffer(vb);
		g.setIndexBuffer(ib);
		g.drawIndexedVertices();

		g.end();
	}

	function onMouseDown(button:Int, x:Int, y:Int)
	{
		isMouseDown = true;
	}

	function onMouseUp(button:Int, x:Int, y:Int)
	{
		isMouseDown = false;
	}

	function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int)
	{
		mouseDeltaX = x - mouseX;
		mouseDeltaY = y - mouseY;

		mouseX = x;
		mouseY = y;
	}

	function onKeyDown(key:KeyCode)
	{
		trace('key down', key);
		if (key == KeyCode.Up)
			moveForward = true;
		else if (key == KeyCode.Down)
			moveBackward = true;
		else if (key == KeyCode.Left)
			strafeLeft = true;
		else if (key == KeyCode.Right)
			strafeRight = true;
	}

	function onKeyUp(key:KeyCode)
	{
		if (key == KeyCode.Up)
			moveForward = false;
		else if (key == KeyCode.Down)
			moveBackward = false;
		else if (key == KeyCode.Left)
			strafeLeft = false;
		else if (key == KeyCode.Right)
			strafeRight = false;
	}
}
