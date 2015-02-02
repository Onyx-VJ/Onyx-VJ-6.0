package avmplus {
	
	/**
	 * 	@private
	 * 	346 = INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS | USE_ITRAITS
	 */
	public function describeObject(c:Object):Object {
		return describeTypeJSON(c, INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_METADATA | INCLUDE_TRAITS).traits;
	}
	
}