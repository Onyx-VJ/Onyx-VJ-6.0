package avmplus {
	
	/**
	 * 	@public
	 */
	public function describeObject(o:*, flags:uint):Object {
		return describeTypeJSON(o, flags).traits;
	}
	
}