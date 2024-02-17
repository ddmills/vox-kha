package vox;

import kha.graphics4.VertexBuffer;
import kha.graphics4.Graphics2;
import kha.graphics5_.CullMode;
import kha.graphics4.IndexBuffer;
import kha.math.FastVector4;
import kha.graphics4.CompareMode;
import kha.graphics5_.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.ConstantLocation;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.math.FastMatrix4;
import kha.graphics4.Graphics;
import kha.Color;
import kha.math.FastVector3;

class Line implements Renderable
{
    public var a:FastVector3;
    public var b:FastVector3;
    public var color:Color;

    private var pipeline:PipelineState;
    private var vertexBuffer:VertexBuffer;
    private var indexBuffer:IndexBuffer;
    private var mvpId:ConstantLocation;
    private var colorId:ConstantLocation;

    public function new(a:FastVector3, b:FastVector3, color:Color)
    {
        this.a = a;
        this.b = b;
        this.color = color;

        compile();
    }

    public function compile() {
        var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);

        vertexBuffer = new VertexBuffer(2, structure, StaticUsage);
        var vbData = vertexBuffer.lock();
        vbData[0] = a.x;
        vbData[1] = a.y;
        vbData[2] = a.z;
        vbData[3] = b.x;
        vbData[4] = b.y;
        vbData[5] = b.z;
		vertexBuffer.unlock();

        indexBuffer = new IndexBuffer(2, StaticUsage);
        var ibData = indexBuffer.lock();
        ibData[0] = 0;
        ibData[1] = 1;
		indexBuffer.unlock();

        pipeline = new PipelineState();
        pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.line_frag;
		pipeline.vertexShader = Shaders.line_vert;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
        pipeline.cullMode = CullMode.None;
        pipeline.compile();

        mvpId = pipeline.getConstantLocation("MVP");
        // colorId = pipeline.getConstantLocation("color");
    }
    
    public function render(g:Graphics, mvp:FastMatrix4) {
        g.setPipeline(pipeline);
        g.setMatrix(mvpId, mvp);
        // g.setVector4(colorId, new FastVector4(1, 0, 0, 1));
        g.setVertexBuffer(vertexBuffer);
        g.setIndexBuffer(indexBuffer);
        g.drawIndexedVertices();
    }
}