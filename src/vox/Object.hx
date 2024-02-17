package vox;

import kha.math.Vector3;
import kha.math.FastMatrix4;
import kha.math.Quaternion;
import kha.math.FastVector3;

class Object
{
	public var position:FastVector3;
	public var orientation:Quaternion;
	public var scale:FastVector3;
	public var renderable:Renderable;

	public var children:Array<Object>;
	var parent:Object;

	var name:String;

	public function new(name:String, ?parent:Object)
	{
		this.name = name;
		children = [];
		position = new FastVector3();
		orientation = new Quaternion();
		scale = new FastVector3(1, 1, 1);

		if (parent != null)
		{
			parent.addChild(this);
		}
	}

	public function addChild(object:Object)
	{
		children.push(object);
		object.parent = this;
	}

	public function debug():String
	{
		if (children.length > 0)
		{
			var c = children.map(c -> c.debug()).join(',');
			return '${name}(${c})';
		}
		return name;
	}

	public function getLocalTranslationMatrix():FastMatrix4
	{
		return FastMatrix4.translation(position.x, position.y, position.z);
	}

	public function getLocalScaleMatrix():FastMatrix4
	{
		return FastMatrix4.scale(scale.x, scale.y, scale.z);
	}

	public function getLocalRotationMatrix():FastMatrix4
	{
		var x = orientation.x;
		var y = orientation.y;
		var z = orientation.z;
		var w = orientation.w;
		var s:Float = 2.0;
		var xs:Float = x * s;
		var ys:Float = y * s;
		var zs:Float = z * s;
		var wx:Float = w * xs;
		var wy:Float = w * ys;
		var wz:Float = w * zs;
		var xx:Float = x * xs;
		var xy:Float = x * ys;
		var xz:Float = x * zs;
		var yy:Float = y * ys;
		var yz:Float = y * zs;
		var zz:Float = z * zs;

		return new FastMatrix4(1 - (yy + zz), xy - wz, xz + wy, 0, xy + wz, 1 - (xx + zz), yz - wx, 0, xz - wy, yz + wx, 1 - (xx + yy), 0, 0, 0, 0, 1);
	}

	public function setEulerAngles(x:Float, y:Float, z:Float)
	{
		var qx = Math.sin(x / 2) * Math.cos(y / 2) * Math.cos(z / 2) - Math.cos(x / 2) * Math.sin(y / 2) * Math.sin(z / 2);
		var qy = Math.cos(x / 2) * Math.sin(y / 2) * Math.cos(z / 2) + Math.sin(x / 2) * Math.cos(y / 2) * Math.sin(z / 2);
		var qz = Math.cos(x / 2) * Math.cos(y / 2) * Math.sin(z / 2) - Math.sin(x / 2) * Math.sin(y / 2) * Math.cos(z / 2);
		var qw = Math.cos(x / 2) * Math.cos(y / 2) * Math.cos(z / 2) + Math.sin(x / 2) * Math.sin(y / 2) * Math.sin(z / 2);

		orientation = new Quaternion(qx, qy, qz, qw);
	}

	public function getEulerAngles():Vector3
	{
		return orientation.getEulerAngles(0, 1, 2);
	}

	public function getLocalTransformationMatrix():FastMatrix4
	{
		var tM = getLocalTranslationMatrix();
		var sM = getLocalScaleMatrix();
		var rM = getLocalRotationMatrix();
		return tM.multmat(rM).multmat(sM);
	}

	public function getWorldTransformationMatrix():FastMatrix4 
	{
		var p = parent == null ? FastMatrix4.identity() : parent.getWorldTransformationMatrix();
		var local = getLocalTransformationMatrix();

		return p.multmat(local);
	}
}
