package onyx.util.tween {
	
	import onyx.util.tween.easing.*;

	public const Easing:Object = {
		back:		new Back(),
		bounce:		new Bounce(),
		circ:		new Circular(),
		cubic:		new Cubic(),
		elastic:	new Elastic(),
		expo:		new Exponential(),
		linear:		new Linear(),
		quad:		new Quadratic(),
		quart:		new Quartic(),
		quin:		new Quintic(),
		sine:		new Sine()
	};
}