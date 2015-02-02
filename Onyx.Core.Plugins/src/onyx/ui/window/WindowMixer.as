package onyx.ui.window {
	
	import flash.events.*;
	import flash.media.*;
	
	import onyx.core.*;
	import onyx.service.*;
	import onyx.ui.component.*;
	import onyx.ui.core.*;
	import onyx.ui.dialog.*;
	import onyx.ui.factory.*;
	import onyx.ui.file.*;
	import onyx.ui.window.mixer.*;
	import onyx.util.*;
	
	use namespace skinPart;
	
	[UIComponent(id='Onyx.UI.Desktop.Mixer', title='MIXER')]
	[UIConstraint(type='relative', bottom='0', left='310', width='240', height='240')]
	
	[UISkinPart(id='content',	type='skin', transform='transform::default', constraint='relative', left='0', top='18', bottom='0', right='0', skinClass='TabContent')]

	public final class WindowMixer extends UITabNavigator {
		
		/**
		 * 	@public
		 */
		override public function initialize(data:Object):void {
			
			// init
			super.initialize(data);
			
			// create the tabs
			super.createTabs(
				{	title:		'Mixer',
					factory:	new UIFactory(UIMixerDefaultView)
				},
				{
					title:		'Learn',
					factory:	new UIFactory(UIMixerLearnView)
				}
			);
			
		}
	}
}