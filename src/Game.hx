import kha.Blob;
import kha.graphics4.CullMode;
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
		structure.add("uv", VertexData.Float2);
		var structureLength = 5;

		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Keyboard.get().notify(onKeyDown, onKeyUp);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = CullMode.Clockwise; // hide interior hidden faces. Important that verticies are in the right order
		// pipeline.colorAttachmentCount = 1;
		// pipeline.colorAttachments[0] = TextureFormat.RGBA32;
		// pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
		pipeline.compile();

		mvpId = pipeline.getConstantLocation("MVP");
		textureId = pipeline.getTextureUnit("myTextureSampler");

		image = Assets.images.uvmap;

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

		var blob:Blob = Assets.blobs.cube_obj;
		var obj = new ObjLoader(blob);
		var data = obj.data;
		var indices = obj.indices;

		vb = new VertexBuffer(Std.int(data.length / 3), structure, StaticUsage);

		var vbData = vb.lock();
		for (i in 0...vbData.length) {
		  vbData[i] = data[i];
		}
		vb.unlock();

		ib = new IndexBuffer(indices.length, StaticUsage);

		var ibData = ib.lock();
		for (i in 0...ibData.length) {
		  ibData[i] = indices[i];
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
