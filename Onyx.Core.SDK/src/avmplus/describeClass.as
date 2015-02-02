package avmplus {
	
	/**
	 * 	@private
	 * 	346 = INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS | USE_ITRAITS
	 */
	public function describeClass(c:Class, flags:uint = 0x0346):Object {
		return describeTypeJSON(c, flags).traits;
	}

}