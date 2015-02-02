package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.parameter.*;
	
	use namespace onyx_ns;
	use namespace parameter;
	
	[Parameter(id='scale',		target='contentTransform/matrix',	type='matrix/scale')]
	[Parameter(id='translate',	target='contentTransform/matrix',	type='matrix/translate')]
	[Parameter(id='rotation',	target='contentTransform/rotation',	type='number',				clamp='-1,1',		reset='0',	loop='true')]
	[Parameter(id='anchor',		target='contentTransform/anchor',	type='point',				clamp='0,1',		reset='0.5,0.5')]
	
	// TODO
	// PUT THIS IN THE APPLICATION
	public class PluginPatchTransformGPU extends PluginPatchGPU implements IPluginGeneratorGPU {
		
		/**
		 * 	@private
		 */
		parameter const contentTransform:ContentTransform	= new ContentTransform(0, 0);
		
		/**
		 * 	@public
		 */
		parameter const matrix:Vector.<Number>	= Vector.<Number>([
			1.0,	0.0,	0.0,	0.0,
			0.0,	1.0,	0.0,	0.0,
			0.0,	0.0,	1.0,	0.0,
			0.0,	0.0,	0.0,	1.0
		]);
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			if (invalidParameters.scale || invalidParameters.rotation || invalidParameters.translate || invalidParameters.anchor) {
				var renderMatrix:Matrix	= new Matrix();
				contentTransform.update(renderMatrix, context, dimensions);
				
				matrix[0]	= renderMatrix.a;
				matrix[1]	= renderMatrix.b;
				matrix[4]	= renderMatrix.c;
				matrix[5]	= renderMatrix.d;
				matrix[3]	= renderMatrix.tx / context.width;
				matrix[7]	= renderMatrix.ty / context.height;
			}
		}
	}
}