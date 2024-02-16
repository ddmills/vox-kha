package vox;

import kha.math.Quaternion;
import kha.math.FastVector3;

typedef Transform = {
    var position: FastVector3;
	var orientation: Quaternion;
	var scale: FastVector3;
}
