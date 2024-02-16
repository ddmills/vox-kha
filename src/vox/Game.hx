package vox;

import kha.math.Vector3;
import kha.math.Quaternion;
import kha.graphics4.Graphics;
import kha.Blob;
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
import kha.Shaders;
import kha.graphics5_.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.Framebuffer;

class Game
{
	var pipeline:PipelineState;
	var vp:FastMatrix4;
	var mvpId:ConstantLocation;
	var textureId:TextureUnit;
	var image:Image;
	
	var speed = 3.0; // 3 units / second
	var mouseSpeed = 0.005;

	var position:FastVector3 = new FastVector3(0, 0, 5); // Initial position: on +Z
	var horizontalAngle = 0.0; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none
	var cubeAngle = 0.0;

	var up = new Vector3(0, 1, 0);

	var isMouseDown:Bool;
	var mouseDeltaX:Int;
	var mouseDeltaY:Int;
	var mouseX:Int;
	var mouseY:Int;

	var moveForward:Bool;
	var moveBackward:Bool;
	var strafeLeft:Bool;
	var strafeRight:Bool;
	var rotateCube:Bool;

	var lastTime:Float;

	var projection:FastMatrix4;

	var scene:Object;
	var camera:Object;
	var cube1:Object;

	private function prettyMatrix(m:FastMatrix4) : String
	{
		var s1 = '┌${m._00}, ${m._10}, ${m._20}, ${m._30}┐\n';
		var s2 = '│${m._01}, ${m._11}, ${m._21}, ${m._31}│\n';
		var s3 = '└${m._02}, ${m._12}, ${m._22}, ${m._32}┘\n';
		var s4 = '└${m._03}, ${m._13}, ${m._23}, ${m._33}┘\n';
		return '\n' + s1 + s2 + s3 + s4;
	}

	public function new()
	{
		// create cube mesh
		var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		structure.add("uv", VertexData.Float2);
		
		var blob:Blob = Assets.blobs.cube_obj;
		var obj = new ObjLoader(blob);
		var mesh = new Mesh();
		mesh.vertices = obj.data;
		mesh.indices = obj.indices;
		mesh.structure = structure;
		mesh.updateBuffers();

		scene = new Object('scene');
		cube1 = new Object('cube1', scene);
		var cube2 = new Object('cube2', cube1);

		var d = scene.debug();
		trace(d);

		cube1.mesh = mesh;
		cube2.mesh = mesh;

		cube2.position.x = -2;
		cube2.position.z = 3;
		cube2.scale.y = 4;

		var ninetyDeg = Math.PI / 2;
		cube2.setEulerAngles(0, 0, ninetyDeg / 2);

		position = new FastVector3(0, 2, -4);

		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Keyboard.get().notify(onKeyDown, onKeyUp);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		// pipeline.cullMode = CullMode.Clockwise; // hide interior hidden faces. Important that verticies are in the right order
		// pipeline.colorAttachmentCount = 1;
		// pipeline.colorAttachments[0] = TextureFormat.RGBA32;
		// pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
		pipeline.compile();

		mvpId = pipeline.getConstantLocation("MVP");
		textureId = pipeline.getTextureUnit("myTextureSampler");

		image = Assets.images.uvmap;

		// Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
		projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);

		vp = FastMatrix4.identity();
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
		if (rotateCube) {
			var up = new Vector3(0, 1, 0);
			cubeAngle += .01;
			cube1.orientation = Quaternion.fromAxisAngle(up, cubeAngle);
		}

		var look = position.add(direction);
		var view = FastMatrix4.lookAt(
			position,
			look,
			up
		);

		vp = FastMatrix4.identity();
		vp = vp.multmat(projection);
		vp = vp.multmat(view);

		mouseDeltaX = 0;
		mouseDeltaY = 0;
	}

	public function render(frames:Array<Framebuffer>)
	{
		var fb = frames[0];
		var g = fb.g4;

		g.begin();
		g.setPipeline(pipeline);
		g.clear(Color.fromFloats(0.0, 0.0, 0.3), 1);
		g.setTexture(textureId, image);

		renderObject(g, scene);

		g.end();
	}

	function renderObject(g:Graphics, o:Object)
	{
		if (o.mesh != null) {
			var mvp = vp.multmat(o.getWorldTransformationMatrix());
			g.setMatrix(mvpId, mvp);
			g.setVertexBuffer(o.mesh.vertexBuffer);
			g.setIndexBuffer(o.mesh.indexBuffer);
			g.drawIndexedVertices();
		}

		for (c in o.children)
		{
			renderObject(g, c);
		}
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
		if (key == KeyCode.W)
			moveForward = true;
		else if (key == KeyCode.S)
			moveBackward = true;
		else if (key == KeyCode.A)
			strafeLeft = true;
		else if (key == KeyCode.D)
			strafeRight = true;
		else if (key == KeyCode.R)
			rotateCube = true;
	}

	function onKeyUp(key:KeyCode)
	{
		if (key == KeyCode.W)
			moveForward = false;
		else if (key == KeyCode.S)
			moveBackward = false;
		else if (key == KeyCode.A)
			strafeLeft = false;
		else if (key == KeyCode.D)
			strafeRight = false;
		else if (key == KeyCode.R)
			rotateCube = false;
	}
}
