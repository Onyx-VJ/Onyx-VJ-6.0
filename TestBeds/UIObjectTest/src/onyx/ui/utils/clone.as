package onyx.ui.utils {
	
	/**
	 * 	@public
	 */
	public function clone(o:Object):Object {
		return JSON.parse(JSON.stringify(o));
	}
}