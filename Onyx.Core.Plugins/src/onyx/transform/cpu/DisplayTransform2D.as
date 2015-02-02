package onyx.transform.cpu {
	
	import flash.display.*;
	import flash.geom.Matrix;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.plugin.*;
	
	use namespace parameter;
	
	[PluginInfo(
		id			= 'Onyx.Core.Display.Transform.2D',
		name		= 'Transform::2D',
		vendor		= 'Daniel Hai',
		version		= '1.0',
		depends		= 'Onyx.Core.Display'
	)]
	
	[Parameter(id='scale',		target='transform/matrix',		type='matrix/scale')]
	[Parameter(id='translate',	target='transform/matrix',		type='matrix/translate')]
	[Parameter(id='rotation',	target='transform/rotation',	type='number',				clamp='-1,1',		reset='0',	loop='true')]
	[Parameter(id='anchor',		target='transform/anchor',		type='point',				clamp='0,1',		reset='0.5,0.5')]
	
	public final class DisplayTransform2D extends PluginBase implements IDisplayTransformCPU {
		
		/**
		 * 	@private
		 */
		parameter const transform:ContentTransform		= new ContentTransform();
		
		/**
		 * 	@private
		 */
		private const renderMatrix:Matrix				= new Matrix();
		
		/**
		 * 	@private
		 */
		private var dimensions:Dimensions;
		
		/**
		 * 	@private
		 */
		private var context:IDisplayContextCPU;
		
		/**
		 * 	@public
		 */
		public function initialize(context:IDisplayContextCPU, dimensions:Dimensions):PluginStatus {
			
			this.context	= context;
			
			// ok
			return PluginStatus.OK;
		}
		
		/**
		 * 	@public
		 */
		override protected function validate(invalidParameters:Object):void {
			
			// set the matrix
			transform.update(renderMatrix, context, dimensions);
			
		}
		
		/**
		 * 	@public
		 */
		public function render(context:IDisplayContextCPU, source:IBitmapDrawable, smoothing:Boolean = true, quality:String = null):void {
			
			// draw!
			context.draw(source, renderMatrix, null, null, null, smoothing, quality);
			
		}
	}
}