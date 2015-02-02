package onyx.util.filesystem {
	
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	import onyx.core.*;
	import onyx.util.*;
	
	final public class RecursiveQuery {

		/**
		 * 	@private
		 */
		private var callback:Callback;
		
		/**
		 * 	@private
		 */
		private var filter:Callback;

		/**
		 * 	@private
		 */
		private var queue:Array					= [];
		
		/**
		 * 	@private
		 */
		private var list:Array					= [];
		
		/**
		 * 	@private
		 */
		private var protocol:IPluginProtocol;
		
		/**
		 * 	@public
		 */
		public function RecursiveQuery(protocol:IPluginProtocol):void {
			
			// store the protocol
			this.protocol	= protocol;
			
			// if we are doing memory profiling
			CONFIG::GC { GC.watch(this); }
		}
		
		/**
		 * 	@public
		 */
		public function initialize(ref:IFileReference, callback:Callback, filter:Callback):void {
			
			this.callback	= callback;
			this.filter		= filter;
			this.queue.push(ref);
			
			// load the first
			ref.protocol.query(ref, new Callback(handleFiles, [ref]), filter);

		}
		
		/**
		 * 	@private
		 */
		private function handleFiles(ref:IFileReference, files:Vector.<IFileReference>):void {
			
			for each (var file:IFileReference in files) {

				if (file.isDirectory) {
					
					// push
					queue.push(file);
					
					// load the first
					FileSystem.Query(file, new Callback(handleFiles, [file]), filter);
					
				} else {
					
					list.push(file);
					
				}
			}
			
			// remove
			queue.splice(queue.indexOf(ref), 1);
			if (queue.length === 0) {
				callback.exec(Vector.<IFileReference>(list));
			}
		}
	}
}