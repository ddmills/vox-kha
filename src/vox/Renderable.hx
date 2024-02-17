package vox;

import kha.math.FastMatrix4;
import kha.graphics4.Graphics;

interface Renderable {
    public function render(g:Graphics, mvp:FastMatrix4):Void;
}
