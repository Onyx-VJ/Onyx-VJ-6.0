package onyx.util.algo {
	
	import flash.utils.*;
	
	final public class DependencyTree {
		
		/**
		 * 	@private
		 */
		private const nodes:Array	= [];
		
		/**
		 * 	@private
		 */
		private const toc:Object		= {};
		
		/**
		 * 	@public
		 */
		public function addNode(target:Object):void {
			
			var index:int = toc[target]	= nodes.length;
			var node:DependencyTreeNode	= new DependencyTreeNode();
			node.target					= target;
			nodes.push(node);
			
		}
		
		/**
		 * 	@public
		 */
		public function getNodes():Array {
			return nodes;
		}
		
		/**
		 * 	@public
		 */
		public function addEdge(target:Object, depends:Object):void {
			
			var nodeIndex:int 		= toc[target];
			var edgeIndex:int		= toc[depends];
			
			// increment the edge length
			++nodes[nodeIndex].edges;
			
			// add the edges from target->depends
			nodes[edgeIndex].push(nodeIndex);

		}
		
		/**
		 * 	@public
		 */
		public function sort():Array  {
			
			const sorted:Array	= [];
			const edges:Array	= [];

			// add no incoming
			for (var index:int = nodes.length - 1; index >= 0;--index) {
				if (!nodes[index].edges) {
					edges.push(index);
				}
			}
			
			// loopy loopy
			while (edges.length) {
				
				index = edges.shift();
				
				var node:DependencyTreeNode = nodes[index];
				sorted.push(node.target);
				
				// test edges
				for each (var edgeIndex:int in node) {
					if (--nodes[edgeIndex].edges === 0) {
						edges.push(edgeIndex);
					}
				}
			}
			
			// test cyclical
			for each (node in nodes) {
				if (node.edges) {
					return null;
				}
			}
			
			return sorted;
		}
	}
}

/**
 * 	Dynamic
 */
dynamic final class DependencyTreeNode extends Array {
	
	/**
	 * 	@public
	 */
	public var target:Object;
	
	/**
	 * 	@public
	 */
	public var edges:uint;
	
	/**
	 * 	@public
	 */
	public function toString():String {
		return '[Node: ' + target + ']';
	}
}