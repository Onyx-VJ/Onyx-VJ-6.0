package onyx.display {
	
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.system.System;
	import flash.utils.*;
	
	import onyx.core.*;
	import onyx.display.*;
	import onyx.geom.Rect;
	import onyx.plugin.*;
	
	public final class DisplayContextCPU extends PluginBase implements IDisplayContextCPU {
		
		/**
		 * 	@public
		 */
		public var quality:String						= StageQuality.MEDIUM;
		
		/**
		 * 	@public
		 */
		public var smoothing:uint						= DisplaySurface.SMOOTH_LINEAR;
		
		/**
		 * 	@private
		 */
		private var alphaBuffer:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var matteBuffer:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var alphaTemp:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private var matteTemp:DisplaySurface;
		
		/**
		 * 	@internal
		 */
		internal var internalTarget:DisplaySurface;
		
		/**
		 * 	@private	Stores the bound display channel.  When unbound, the surface will get returned to it
		 */
		private var boundChannel:IChannelCPU;
		
		/**
		 * 	@private	Stores the bound display channel.  When unbound, the surface will get returned to it
		 */
		private var boundSurface:DisplaySurface;
		
		/**
		 * 	@private
		 */
		private const RECT:Rect				= new Rect();
		
		/**
		 * 	@private
		 */
		private const surfaceCacheAlpha:Array	= [];
		private const surfaceCacheMatte:Array	= [];
		
		/**
		 * 	@public
		 */
		public function initialize(width:int, height:int):void {
			
			// store rect
			RECT.width		= width;
			RECT.height		= height;
			
			// store a buffer
			matteBuffer		= new DisplaySurface(width, height, false,	0x00);
			alphaBuffer		= new DisplaySurface(width, height, true,	0x00);

		}

		/**
		 * 	@public
		 */
		public function getTempSurface(alpha:Boolean):DisplaySurface {
			return alpha ? alphaTemp : matteTemp;
		}
		
		/**
		 * 	@public	Does not automatically clear
		 */
		public function requestSurface(transparent:Boolean):DisplaySurface {
			
			const target:Array = transparent ? surfaceCacheAlpha : surfaceCacheMatte;
			if (target.length) {
				return target.pop();
			}
			
			// return
			return new DisplaySurface(RECT.width, RECT.height, transparent, 0x00);
		}
		
		/**
		 * 	@public
		 */
		public function releaseSurface(surface:DisplaySurface):void {
			
			if (!surface) {
				return;
			}
			
			const target:Array = surface.transparent ? surfaceCacheAlpha : surfaceCacheMatte;
			if (target.length < 10) {
				target.push(surface);
			} else {
				surface.dispose();
			}
		}
		
		/**
		 * 	@public
		 */
		public function get frameRate():Number {
			return 24;
		}
		
		/**
		 * 	@public
		 */
		public function get width():int {
			return RECT.width;
		}
		
		/**
		 * 	@public
		 */
		public function get rect():Rect {
			return RECT;
		}
		
		/**
		 * 	@public
		 */
		public function get height():int {
			return RECT.height;
		}
		
		/**
		 * 	@public
		 */
		public function draw(source:IBitmapDrawable, matrix:Matrix = null, transform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = true, quality:String = null):void {
			internalTarget.drawWithQuality(source, matrix, transform, blendMode, clipRect, smoothing, quality || this.quality);
		}
		
		/**
		 * 	@public
		 */
		public function applyFilter(filter:BitmapFilter, source:BitmapData = null, rect:Rectangle = null, position:Point = null):void {
			internalTarget.applyFilter(source || internalTarget, rect || RECT, position || CONST_IDENTITY, filter);
		}
		
		/**
		 * 	@public
		 */
		public function copyPixels(source:BitmapData, merge:Boolean = false, rect:Rectangle = null, position:Point = null, alphaBitmap:BitmapData = null, alphaPoint:Point = null):void {
			internalTarget.copyPixels(source, rect || RECT, position || CONST_IDENTITY, null, null, merge);
		}
		
		/**
		 * 	@public
		 */
		public function clear(color:uint = 0x00):void {
			internalTarget.fillRect(RECT, color);
		}
		
		/**
		 * 	@public
		 */
		public function paletteMap(red:Array = null, green:Array = null, blue:Array = null, alpha:Array = null, source:BitmapData = null, rect:Rectangle = null, point:Point = null):void {
			internalTarget.paletteMap(source || internalTarget, rect || RECT, point || CONST_IDENTITY, red, green, blue, alpha);
		}
		
		/**
		 * 	@public
		 */
		public function bindChannel(channel:IChannelCPU):void {
			
			CONFIG::DEBUG {
				if (boundChannel) {
					throw new Error('Channel already bound!');
				}
			}
			
			// bind!
			boundChannel		= channel;
			boundSurface		= channel.surface;
			
			// set internal target
			internalTarget		= boundSurface.transparent ? alphaBuffer : matteBuffer;
			
			// clear it
			internalTarget.clear();
			
			// lock the bitmaps
			boundSurface.lock();
			internalTarget.lock();
			
		}
		
		/**
		 * 	@internal
		 */
		public function swapBuffer():void {
			
			// swap the surfaces?
			var temp:DisplaySurface			= boundSurface;
			boundSurface					= internalTarget;
			internalTarget					= temp;
			
		}
		
		/**
		 * 	@internal
		 */
		public function unbind():void {
			
			if (internalTarget.transparent) {
				alphaBuffer = internalTarget;
			} else {
				matteBuffer	= internalTarget;
			}
			
			// unlock the channel for rendering
			boundChannel.swapSurface(boundSurface);
			boundSurface.unlock();
			boundSurface = null;
			boundChannel = null;
		}
		
		/**
		 * 	@publci
		 */
		public function get target():DisplaySurface {
			return internalTarget;
		}
		
		/**
		 * 	@public
		 */
		public function get surface():DisplaySurface {
			return boundSurface;
		}
		
		/**
		 * 	@public
		 * 	This does a clean up pass.  Maxtime is the maximum time it should take before exiting
		 * 	
		 */
		public function cleanup(maxTime:int):void {
			
			if (surfaceCacheAlpha.length === 0 && surfaceCacheMatte.length === 0) {
				return;
			}
			
			var time:int = TimeStamp + maxTime;
			while (surfaceCacheAlpha.length && getTimer() < time) {
				var surface:DisplaySurface = surfaceCacheAlpha.pop();
				surface.dispose();
			}
			
			while (surfaceCacheMatte.length && getTimer() < time) {
				surface = surfaceCacheMatte.pop();
				surface.dispose();
			}
			
			flash.system.System.gc();
			
		}
	}
}