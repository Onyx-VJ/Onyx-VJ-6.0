package ikelos.core {
	
	import flash.display.*;
	import flash.events.*;
	
	import org.osmf.elements.*;
	import org.osmf.events.*;
	import org.osmf.media.*;
	import org.osmf.net.*;
	
	final public class PlayerHost extends Sprite {
		
		/**
		 * 	@private
		 */
		private const players:Array						= [];
		
		/**
		 * 	@private
		 */
		private var playerSprite:MediaPlayerSprite;
		
		/**
		 * 	@private
		 */
		private var player:MediaPlayer;
		
		/**
		 * 	@private
		 */
		private const host:JavascriptHost				= new JavascriptHost();
		
		/**
		 * 	@public
		 */
		private var resource:URLResource;
		
		/**
		 * 	@public
		 */
		private var id:String;
		
		/**
		 * 	@private
		 * 	We're overriding autoplay, because we want the first frame to load
		 */
		private var autoplay:Boolean					= false;
		
		/**
		 * 	@private
		 */
		private var loop:Boolean						= false;
		
		/**
		 * 	@private
		 */
		private var muted:Boolean						= false;
		
		/**
		 * 	@private
		 */
		private var autoRewind:Boolean					= false;
		
		/**
		 * 	@private
		 */
		private var bufferTime:Number					= 4.0;
		
		/**
		 * 	@private
		 */
		private var volume:Number						= 1.0;
		
		/**
		 * 	@private
		 */
		private var startTime:Number					= 0.0;
		
		/**
		 * 	@private
		 */
		private var endTime:Number						= NaN;
		
		/**
		 * 	@private
		 */
		private var useStreaming:Boolean				= false;
		
		/**
		 * 	@private
		 Whether to use: urlIncludesFMSApplicationInstance on streaming urls
		 */
		private var isFMSInstanceURL:Boolean			= false;
		
		/**
		 * 	@private
		 */
		private var canPlayThroughDispatched:Boolean	= false;
		
		/**
		 * 	@private
		 */
		private var options:Object;
		
		/**
		 * 	@private
		 */
		private function handleDisplay(e:Event):void {
			
			switch (e.type) {
				case Event.RESIZE:
					
					for each (var player:MediaPlayerSprite in players) {
					this.resizePlayer(player);
				}
					
					host.triggerType('resize');
					
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function initialize(options:Object, stage:Stage):void {
			
			CONFIG::LOCAL {
				options = {
					'source': 	'rtmp://54.175.163.78:1935/vod/mp4:timecode.mp4',
					'id':		'some_id',
					'autoplay':	true,
					'startTime':	5
				};
			}
				
				// set defaults
				this.id					= options.id;
			this.options			= options;
			
			CONFIG::DEBUG {
				Debug.Log('initialize', options.id);
			}
				
				if (!this.id) {
					CONFIG::DEBUG {
						Debug.Log('error', 'invalid id');
						throw new Error('Invalid ID');
					}
				}
				
				Debug.Log('xxx');
			
			// init host
			this.initHost();
			
			CONFIG::DEBUG {
				Debug.Log('host complete');
			}
				
				// set source last
				if (options.hasOwnProperty('source')) {
					this.setSource(options['source']);
				}
		}
		
		/**
		 * 	@private
		 */
		private function createPlayer():MediaPlayerSprite {
			
			var playerSprite:MediaPlayerSprite	= new MediaPlayerSprite();
			var player:MediaPlayer				= playerSprite.mediaPlayer;
			
			this.players.push(playerSprite);
			this.addChild(playerSprite);
			
			playerSprite.scaleMode	= 'letterbox';
			
			// set as current
			this.player					= player;
			this.playerSprite			= playerSprite;
			this.player.volume			= volume;
			this.player.muted			= muted;
			this.player.loop			= loop;
			this.player.autoRewind		= autoRewind;
			
			this.resizePlayer(playerSprite);
			this.initOptions();
			
			// we need to listen for specific events, and forward them
			player.addEventListener(AudioEvent.MUTED_CHANGE,							handlePlayerEvent);
			player.addEventListener(AudioEvent.VOLUME_CHANGE,							handlePlayerEvent);
			player.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,				handlePlayerEvent);
			player.addEventListener(MediaErrorEvent.MEDIA_ERROR,						handlePlayerEvent);
			player.addEventListener(TimeEvent.COMPLETE,									handlePlayerEvent);
			player.addEventListener(TimeEvent.CURRENT_TIME_CHANGE,						handlePlayerEvent);
			player.addEventListener(TimeEvent.DURATION_CHANGE,							handlePlayerEvent);
			player.addEventListener(BufferEvent.BUFFER_TIME_CHANGE,						handlePlayerEvent);
			player.addEventListener(BufferEvent.BUFFERING_CHANGE,						handlePlayerEvent);
			player.addEventListener(LoadEvent.BYTES_LOADED_CHANGE,						handlePlayerEvent);
			player.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE,						handlePlayerEvent);
			player.addEventListener(LoadEvent.LOAD_STATE_CHANGE,						handlePlayerEvent);
			player.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE,	handlePlayerEvent);
			player.addEventListener(PlayEvent.PLAY_STATE_CHANGE,						handlePlayerEvent);
			
			// retrn it
			return playerSprite;
		}
		
		
		private function initOptions():void {
			for (var i:String in options) {
				this.setOption(i, options[i]);
			}
		}
		
		private function resizePlayer(sprite:MediaPlayerSprite):void {
			sprite.width	= stage.stageWidth;
			sprite.height	= stage.stageHeight;
		}
		
		/**
		 *	@private
		 */
		private function setOption(name:String, value:String):void {
			
			CONFIG::DEBUG {
				Debug.Log('setOption', name, value);
			};
			
			// store it
			this.options[name] = value;
			this.triggerOption(name, value);
		}
		
		private function triggerOption(name:String, value:String):void {
			
			switch (name.toLowerCase()) {
				case 'autoplay':
					autoplay			= parseBoolean(value);
					break;
				case 'autorewind':
					autoRewind			= parseBoolean(value);
					if (player) {
						player.autoRewind = autoRewind;
					}
					break;
				case 'buffertime':
					bufferTime		= Number(value) || 4.0;
					if (player) {
						player.bufferTime = bufferTime;
					}
					break;
				case 'muted':
					this.setMuted(parseBoolean(value));
					break;
				case 'loop':
					loop			= parseBoolean(value);
					if (player) {
						player.loop = loop;
					}
					break;
				case 'starttime':
					startTime			= Number(value);
					break;
				case 'streaming':
					useStreaming		= parseBoolean(value);
					break;
				case 'isfmsinst':
					isFMSInstanceURL	= parseBoolean(value);
					break;
				case 'volume':
					volume				= Number(value) || 1.0;
					break;
			}
		}
		
		/**
		 * 	@public
		 */
		public function parseBoolean(input:*):Boolean {
			return String(input) === 'true';
		}
		
		/**
		 * 	@public
		 */
		public function getOption(id:String):String {
			return this.options[id] || null;
		}
		
		/**
		 * 	@public
		 */
		public function setVolume(value:Number):void {
			volume = value;
			if (player) {
				player.volume = volume;
			}
		}
		
		/**
		 * 	@public
		 */
		public function getVolume():Number {
			return volume;
		}
		
		/**
		 * 	@public
		 */
		public function setMuted(value:Boolean):void {
			muted = value;
			if (player) {
				player.muted = value;
			}
		}
		
		/**
		 * 	@public
		 */
		public function getMuted():Boolean {
			return muted;
		}
		
		/**
		 *	@public
		 */
		public function getCurrentTime():Number {
			return player ? player.currentTime + startTime : 0;
		}
		
		/**
		 *	@public
		 */
		public function getNativeTime():Number {
			return player ? player.currentTime : 0;
		}
		
		/**
		 *	@public
		 */
		public function setCurrentTime(time:Number):void {
			
			if (!player) {
				return;
			}
			
			if (this.player.canSeek) {
				this.player.seek(time);
			}	
		}
		
		/**
		 * 	@public
		 */
		public function getDuration():Number {
			return player ? player.duration : 0;
		}
		
		/**
		 * 	@public
		 */
		public function isRTMPUrl(url:String):Boolean {
			
			var protoIndex:int = url.indexOf(':/');
			
			return protoIndex && url.substr(0, Math.min(protoIndex, 4)) === 'rtmp';
		}
		
		/**
		 *	@private
		 */
		private function stopPlayer(player:MediaPlayer):void {
			
			// we need to listen for specific events, and forward them
			player.removeEventListener(AudioEvent.MUTED_CHANGE,								handlePlayerEvent);
			player.removeEventListener(AudioEvent.VOLUME_CHANGE,							handlePlayerEvent);
			player.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,				handlePlayerEvent);
			player.removeEventListener(MediaErrorEvent.MEDIA_ERROR,							handlePlayerEvent);
			player.removeEventListener(TimeEvent.COMPLETE,									handlePlayerEvent);
			player.removeEventListener(TimeEvent.CURRENT_TIME_CHANGE,						handlePlayerEvent);
			player.removeEventListener(TimeEvent.DURATION_CHANGE,							handlePlayerEvent);
			player.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE,						handlePlayerEvent);
			player.removeEventListener(BufferEvent.BUFFERING_CHANGE,						handlePlayerEvent);
			player.removeEventListener(LoadEvent.BYTES_LOADED_CHANGE,						handlePlayerEvent);
			player.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE,						handlePlayerEvent);
			player.removeEventListener(LoadEvent.LOAD_STATE_CHANGE,							handlePlayerEvent);
			player.removeEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE,	handlePlayerEvent);
			player.removeEventListener(PlayEvent.PLAY_STATE_CHANGE,							handlePlayerEvent);
			player.stop();
			
		}
		
		/**
		 * 	@public
		 */
		public function setSource(url:String, type:String = null):void {
			
			this.options['source'] = url;
			
			// stop the previous player
			if (player) {
				this.stopPlayer(player);
			}
			
			// ok, create a new player
			this.createPlayer();
			
			CONFIG::DEBUG {
				Debug.Log('setSource', url, type);
			}
				
				if (useStreaming || isRTMPUrl(url)) {
					resource = new StreamingURLResource(url, StreamType.LIVE_OR_RECORDED, startTime, endTime);
					(resource as StreamingURLResource).urlIncludesFMSApplicationInstance = isFMSInstanceURL;
					
					Debug.Log('using fms inst?', isFMSInstanceURL);
					
				} else {
					resource = new URLResource(url);
				}
				
				// we need to determine the type
				if (type === null) {
					
					type = 'video';
					
					//				This stuff below is for "auto" detection of mp3's
					//
					//				const slashIndex:int = url.lastIndexOf('/');
					//				const dotIndex:int = url.lastIndexOf('.');
					//
					//				// make sure the dot is after the slash -- means we probably have a file name
					//				if (dotIndex > slashIndex) {
					//
					//					// mp3s are audio, everything is video
					//					switch (url.substr(dotIndex).toLowerCase()) {
					//						case '.mp3':
					//							type = 'audio';
					//							break;
					//						default:
					//							type = 'video';
					//							break;
					//					}
					//				}
				}
				
				switch (type) {
					case 'video':
						
						var element:VideoElement = new VideoElement(resource);
						player.media	= element;
						
						resource.mediaType = MediaType.VIDEO;
						
						player.autoPlay 	= this.autoplay;
						player.bufferTime	= bufferTime;
						
						host.triggerType('play');
						
						break;
					case 'audio':
						
						host.triggerType('error', 'Does not support this currently');
						
						//					player.media		= new AudioElement(resource);
						//
						//					if (!autoplay) {
						//						player.pause();
						//					} else {
						//
						//						player.bufferTime	= bufferTime;
						//						player.play();
						//
						//						// trigger
						//						host.triggerType('play');
						//					}
						//					break;
				}
				
				// we need to reset canPlayThroughDispatched
				canPlayThroughDispatched	= false;
		}
		
		private function destroyOldPlayers():void {
			while (players.length > 1) {
				 var player:MediaPlayerSprite = this.players.shift();
				 removeChild(player);
			}
		}
		
		/**
		 * 	@private
		 */
		private function handlePlayerEvent(e:Event):void {
			
			switch (e.type) {
				case MediaErrorEvent.MEDIA_ERROR:
					
					CONFIG::DEBUG {
					Debug.Log('MediaError');
				}
					
					host.triggerType('error', (e as MediaErrorEvent).error.message);
					break;
				case LoadEvent.BYTES_LOADED_CHANGE:
					
					if (!canPlayThroughDispatched && player.bytesTotal && player.bytesLoaded === player.bytesTotal) {
						host.triggerType('canplaythrough');
						canPlayThroughDispatched = true;
					}
					
					break;
				case TimeEvent.COMPLETE:
					
					// this fires twice
					return host.triggerType('ended');
				case AudioEvent.MUTED_CHANGE:
				case AudioEvent.VOLUME_CHANGE:
					return host.triggerType('volumechange');
				case PlayEvent.PLAY_STATE_CHANGE:
					switch (player.state) {
						case 'paused':
							return host.triggerType('pause');
						default:
							return;
					}
				case MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE:
					if (player.canPlay) {
						host.triggerType('loadeddata');
						return host.triggerType('canplay');
					}
					return;
				case LoadEvent.LOAD_STATE_CHANGE:
					
					CONFIG::DEBUG {
						Debug.Log('Player State Change:', player.state);
					}
					
					switch (player.state) {
						case 'loading':
							return host.triggerType('loadstart')
						case 'ready':
							
							destroyOldPlayers();
							
							// see if we can remove the previous player
							
							return host.triggerType('loadedalldata');
						default:
							return;
					}
					break;
				
				
				case TimeEvent.CURRENT_TIME_CHANGE:
					return host.triggerType('timeupdate');
					
				case TimeEvent.DURATION_CHANGE:
					if (player.duration) {
						
						host.triggerType('loadedmetadata');
						
						return host.triggerType('durationchange');
					}
					break;
				default:
					
					host.triggerType(e.type.toLowerCase());
					break;
			}
		}
		
		/**
		 * 	@private
		 */
		private function handleHostEvent(e:Event):void {
			
			// we need to map actionscript events to javascript events (the names are a bit different)
			// for now just lowercase the event type
			
			var type:String	= e.type;
			switch (type) {
				case Event.MOUSE_LEAVE:
					
					// trigger javascript container
					host.triggerType('mouseout');
					
					break;
				default:
					
					// trigger javascript container
					host.triggerType(type.toLowerCase(), String(type));
					break;
				
			}
		}
		
		private function initHost():void {
			
			// initialize the host, only bind if it bound to the javascript container successfully
			if (!host.initialize(this.id)) {
				
				CONFIG::DEBUG {
					Debug.Log('ERROR INITIALIZATION CONTAINER!');
				}
					
					return;
			}
			
			CONFIG::DEBUG {
				Debug.Log('initializing');
			}
				
				// we need to listen for specific events, and forward them
				stage.addEventListener(Event.RESIZE,								handleDisplay);
			stage.addEventListener(MouseEvent.CLICK,							handleHostEvent);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,						handleHostEvent);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL,						handleHostEvent);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,						handleHostEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP,							handleHostEvent);
			stage.addEventListener(Event.ACTIVATE,								handleHostEvent);
			stage.addEventListener(Event.DEACTIVATE,							handleHostEvent);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,						handleHostEvent);
			stage.addEventListener(KeyboardEvent.KEY_UP,						handleHostEvent);
			stage.addEventListener(Event.MOUSE_LEAVE,							handleHostEvent);
			stage.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,			handleHostEvent);
			
			CONFIG::DEBUG {
				Debug.Log('a');
			}
				
				// bind methods
				host.bind('getNativeTime',	getNativeTime);
			host.bind('getCurrentTime', getCurrentTime);
			host.bind('setCurrentTime', setCurrentTime);
			host.bind('getDuration',	getDuration);
			host.bind('setOption',		setOption);
			host.bind('getOption',		getOption);
			host.bind('play',			function():void {
				
				if (!player) {
					return;
				}
				
				try {
					player.bufferTime = bufferTime;
					player.play();
					host.triggerType('play');
				} catch (e:Error) {
					trace(e);
				}
				
			});
			host.bind('pause',			function():void {
				if (!player) {
					return;
				}
				
				player.pause();
			});
			
			host.bind('stop',			function():void {
				if (!player) {
					return;
				}
				
				player.stop();
			});
			host.bind('setVolume',		setVolume);
			host.bind('getVolume',		getVolume);
			host.bind('setMuted',		setMuted);
			host.bind('getMuted',		getMuted);
			host.bind('setSource',		setSource);
			
			
			CONFIG::DEBUG {
				Debug.Log('b');
			}
				
				host.bind('isPlaying',		function():Boolean {
					return player ? player.playing : false;
				});
			host.bind('isBuffering',	function():Boolean {
				return player ? player.buffering : false;
			});
			host.bind('isPaused',		function():Boolean {
				return player ? player.paused : false;
			});
			host.bind('getBytesTotal',	function():Number {
				return player ? player.bytesTotal : 0;
			});
			host.bind('getBytesLoaded',	function():Number {
				return player ? player.bytesLoaded : 0;
			});
			host.bind('hasAudio',	function():Boolean {
				return player ? player.hasAudio : false;
			});
			// letterbox, none, stretch, zoom
			host.bind('setScaleMode',	function(value:String):void {
				if (!playerSprite) {
					return;
				}
				playerSprite.scaleMode = value;
			});
			host.bind('getScaleMode',	function():String {
				if (!playerSprite) {
					return null;
				}
				return playerSprite.scaleMode;
			});
			host.bind('getVideoWidth',		function():Number {
				return player ? player.mediaWidth : 0;
			});
			host.bind('getVideoHeight',		function():Number {
				return player ? player.mediaHeight : 0;
			});
			host.bind('getBuffered',		function():Number {
				return player ? player.bufferLength : 0;
			});
			host.bind('getBufferedPercent',		function():Number {
				if (!player || !player.duration) {
					return 0;
				}
				return player.bufferLength / player.duration;
			});
		}
	}
}