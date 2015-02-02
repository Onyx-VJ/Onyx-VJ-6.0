package com.ru {

    import flash.display.*;
    import flash.geom.*;
    
    /**
	 * 
	 * Adapted from
	 * http://code.google.com/p/in-spirit/source/browse/trunk/projects/FlashSURF/src/DistortImage.as
     * Simple image (plane) distortion class
     * 
     * @author Eugene Zatepyakin
	 * 
     */
    final public class DistortImage  {
		
        protected var vertices:Vector.<Number>;  
        protected var indices:Vector.<int>;    
        protected var uvtData:Vector.<Number>;
		
		private var precision:uint;

        /**
         * Tesselates the area into triangles.
         */
        public function initialize(w:uint, h:uint, res:uint = 10):void { 
		
            var indStep:int = 0;            
            var hStep:Number = w / res;                   
            var vStep:Number = h / res;

            var vi:int = -1;
            var ui:int = -1;
            var ii:int = -1;
			
			if (res !== precision) {

				vertices = new Vector.<Number>( res * res * 8, true );
				uvtData = new Vector.<Number>( res * res * 8, true );                  
				indices = new Vector.<int>( res * res * 6, true );
				
				precision = res;
			}
        
            for (var j:int = 0; j < res; ++j) {
                for (var i:int = 0; i < res; ++i) {
                    vertices[++vi] = i*hStep;
                    vertices[++vi] = j*vStep;
                    vertices[++vi] = (i+1)*hStep;
                    vertices[++vi] = j*vStep;
                    vertices[++vi] = (i+1)*hStep;
                    vertices[++vi] = (j+1)*vStep;
                    vertices[++vi] = i*hStep;
                    vertices[++vi] = (j+1)*vStep;
                    
                    uvtData[++ui] = i/res;
                    uvtData[++ui] = j/res;
                    uvtData[++ui] = (i+1)/res;
                    uvtData[++ui] = j/res;
                    uvtData[++ui] = (i+1)/res;
                    uvtData[++ui] = (j+1)/res;
                    uvtData[++ui] = i/res;
                    uvtData[++ui] = (j+1)/res;
            
                    indices[++ii] = indStep;
                    indices[++ii] = indStep+1;
                    indices[++ii] = indStep+3;
                    indices[++ii] = indStep+1;
                    indices[++ii] = indStep+2;
                    indices[++ii] = indStep+3;
                    
                    indStep += 4;
                }                                                       
            }
        }


        /**
         * Distorts the provided BitmapData according to the provided Point instances and draws it onto the provided Graphics.
         *
         * @param       graphics        Graphics on which to draw the distorted BitmapData
         * @param       bmd                     The undistorted BitmapData
         * @param       tl                      Point specifying the coordinates of the top-left corner of the distortion
         * @param       tr                      Point specifying the coordinates of the top-right corner of the distortion
         * @param       br                      Point specifying the coordinates of the bottom-right corner of the distortion
         * @param       bl                      Point specifying the coordinates of the bottom-left corner of the distortion
         *
         */
        public function setTransform(tl:Point, tr:Point, br:Point, bl:Point):void {
			
			trace('invalidate transform');

            var len:int = vertices.length >> 1;
            var ni:int = -1;
            var vi:int = -1;
                                    
            var verVecLeftX:Number = bl.x - tl.x;
            var verVecLeftY:Number = bl.y - tl.y;
            
            var verVecRightX:Number = br.x - tr.x;
            var verVecRightY:Number = br.y - tr.y;
                    
            var curVert:Point = new Point();
            var curPointLeft:Point = new Point();
            var curPointRight:Point = new Point();
            var newVert:Point = new Point();
            var curYCoeff:Number;
            var curXCoeff:Number;
            var newVertices:Vector.<Number> = new Vector.<Number>(len << 1, true);
            
            for(var k:int = 0; k < len; ++k) {
                    curVert.x = vertices[++vi];
                    curXCoeff = uvtData[vi];
                    curVert.y = vertices[++vi];
                    curYCoeff = uvtData[vi];
                    
                    curPointLeft.x = tl.x + curYCoeff*verVecLeftX;
                    curPointLeft.y = tl.y + curYCoeff*verVecLeftY;
                    
                    curPointRight.x = tr.x + curYCoeff*verVecRightX;
                    curPointRight.y = tr.y + curYCoeff*verVecRightY;
                    
                    newVert.x = curPointLeft.x + (curPointRight.x - curPointLeft.x)*curXCoeff;                                              
                    newVert.y = curPointLeft.y + (curPointRight.y - curPointLeft.y)*curXCoeff;
                    
                    newVertices[++ni] = newVert.x;
                    newVertices[++ni] = newVert.y;                                          
            }
            
            vertices = newVertices.concat();
        }

		/**
		 * 	@public
		 */
        public function render(graphics:Graphics, bmd:BitmapData, matrix:Matrix, smoothing:Boolean, culling:String):void  {
			graphics.clear();
            graphics.beginBitmapFill(bmd, matrix, false, smoothing);
            graphics.drawTriangles(vertices, indices, uvtData, culling);
            graphics.endFill();
        }
    }
}