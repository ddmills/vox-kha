package vox;

import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Mesh {
    public var vertices: Array<Float>;
    public var indices: Array<Int>;
    public var structure: VertexStructure;

    public var vertexBuffer:VertexBuffer;
    public var indexBuffer:IndexBuffer;

    public function new() {
    }

    public function updateBuffers() {
        vertexBuffer = new VertexBuffer(Std.int(vertices.length / 3), structure, StaticUsage);

		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
		  vbData[i] = vertices[i];
		}
		vertexBuffer.unlock();

        indexBuffer = new IndexBuffer(indices.length, StaticUsage);

		var ibData = indexBuffer.lock();
		for (i in 0...ibData.length) {
		  ibData[i] = indices[i];
		}
		indexBuffer.unlock();
    }
}
