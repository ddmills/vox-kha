package vox;

import kha.graphics4.Graphics;
import kha.graphics4.ConstantLocation;
import kha.Image;
import kha.graphics4.TextureUnit;
import kha.math.FastMatrix4;
import kha.graphics4.CompareMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.PipelineState;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class Mesh {
    public var vertices: Array<Float>;
    public var indices: Array<Int>;
    public var structure: VertexStructure;

    public var vertexBuffer:VertexBuffer;
    public var indexBuffer:IndexBuffer;

    public var pipeline:PipelineState;
    public var vertexShader:VertexShader;
    public var fragementShader:FragmentShader;

	public var image:Image;
    private var textureId:TextureUnit;
    private var mvpId:ConstantLocation;

    public function new() {
    }

    public function compile() {
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

        pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = fragementShader;
		pipeline.vertexShader = vertexShader;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		// pipeline.cullMode = CullMode.Clockwise; // hide interior hidden faces. Important that verticies are in the right order
		// pipeline.colorAttachmentCount = 1;
		// pipeline.colorAttachments[0] = TextureFormat.RGBA32;
		// pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
		pipeline.compile();

		textureId = pipeline.getTextureUnit("myTextureSampler");
		mvpId = pipeline.getConstantLocation("MVP");
    }

    public function draw(g:Graphics, mvp:FastMatrix4) 
    {
        g.setPipeline(pipeline);
		g.setTexture(textureId, image);
        g.setMatrix(mvpId, mvp);
        g.setVertexBuffer(vertexBuffer);
        g.setIndexBuffer(indexBuffer);
        g.drawIndexedVertices();
    }
}
