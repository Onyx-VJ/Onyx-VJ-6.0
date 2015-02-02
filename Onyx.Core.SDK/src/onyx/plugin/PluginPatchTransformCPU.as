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
	public class PluginPatchTransformCPU extends PluginPatchCPU {
//		
//		/**
//		 * 	@parameter
//		 */
//		parameter var smoothing:Boolean;

		/**
		 * 	@private
		 */
		parameter const contentTransform:ContentTransform	= new ContentTransform();
		
		/**
		 * 	@private
		 */
		protected const renderMatrix:Matrix					= new Matrix(); 
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			if (invalidParameters.scale || invalidParameters.rotation || invalidParameters.translate || invalidParameters.anchor) {
				contentTransform.update(renderMatrix, context, dimensions);
			}
			
		}
	}
}