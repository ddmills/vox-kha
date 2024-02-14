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
    var vertices:Array<Float>;
    var indices:Array<Int>;
    var vb:VertexBuffer;
    var ib:IndexBuffer;
    var pipeline:PipelineState;
    var mvp:FastMatrix4;
    var mvpId:ConstantLocation;

	public function new() {
        vertices = [
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0,
            0.0, 1.0, 0.0,
        ];
        indices = [
            0, 1, 2,
        ];

        var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);

        pipeline = new PipelineState();
        pipeline.inputLayout = [structure];
        pipeline.fragmentShader = Shaders.simple_frag;
        pipeline.vertexShader = Shaders.simple_vert;
        pipeline.colorAttachmentCount = 1;
        pipeline.colorAttachments[0] = TextureFormat.RGBA32;
        pipeline.depthStencilAttachment = DepthStencilFormat.Depth16;
        pipeline.compile();

        mvpId = pipeline.getConstantLocation("MVP");

        // Projection matrix: 45° Field of View, 4:3 ratio, 0.1-100 display range
        var projection = FastMatrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);

        // Camera matrix
        var view = FastMatrix4.lookAt(
            new FastVector3(4, 3, 3), // position in world space
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
        ib = new IndexBuffer(indices.length, StaticUsage);

        var vbData = vb.lock();
        for (i in 0...vertices.length) {
            vbData.set(i, vertices[i]);
        }
        vb.unlock();

        var ibData = ib.lock();
        for (i in 0...indices.length) {
            ibData.set(i, indices[i]);
        }
        ib.unlock();
    }

	public function update()
	{
		
	}

	public function render(frames:Array<Framebuffer>)
	{
        var fb = frames[0];
        var g = fb.g4;

        g.setMatrix(mvpId, mvp);

        g.begin();

        g.clear(Color.Black);

        g.setPipeline(pipeline);
        g.setVertexBuffer(vb);
        g.setIndexBuffer(ib);
        g.drawIndexedVertices();

        g.end();
	}
}
