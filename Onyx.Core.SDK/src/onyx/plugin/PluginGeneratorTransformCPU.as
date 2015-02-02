package onyx.plugin {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.event.*;
	import onyx.plugin.*;
	import onyx.util.*;
	
	use namespace parameter;
	
	[Parameter(id='scale',		target='transform/matrix',		type='matrix/scale')]
	[Parameter(id='translate',	target='transform/matrix',		type='matrix/translate')]
	[Parameter(id='rotation',	target='transform/rotation',	type='number',				clamp='-1,1',		reset='0',	loop='true')]
	[Parameter(id='anchor',		target='transform/anchor',		type='point',				clamp='0,1',		reset='0.5,0.5')]

	public class PluginGeneratorTransformCPU extends PluginGeneratorCPU {
		
		/**
		 * 	@private
		 */
		parameter const transform:ContentTransform			= new ContentTransform();
		
		/**
		 * 	@private
		 */
		protected const renderMatrix:Matrix					= new Matrix(); 
		
		/**
		 * 	@parameter
		 */
		parameter var smoothing:Boolean;
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			if (invalidParameters.scale || invalidParameters.rotation || invalidParameters.translate || invalidParameters.anchor) {
				transform.update(renderMatrix, context, dimensions);
			}
			
		}
	}
}