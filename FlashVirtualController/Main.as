package
{
	import com.razerzone.store.sdk.Controller;	
	import com.razerzone.store.sdk.engine.adobeair.RazerSDKNativeInterface;	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.StatusEvent;

    public class Main extends MovieClip
    {
		static var SECRET_API_KEY:String = "ew0KICAgICJkZXZlbG9wZXJfaWQiOiAiMzEwYThmNTEtNGQ2ZS00YWU1LWJkYTAtYjkzODc4ZTVmNWQwIiwNCiAgICAiZGV2ZWxvcGVyX3B1YmxpY19rZXkiOiAiTUlHZk1BMEdDU3FHU0liM0RRRUJBUVVBQTRHTkFEQ0JpUUtCZ1FDNjJ1VkRDN2dRRkZ0cGlnTHVhRXZYUlg0cStRT0R0SlA2V1dyTHdzKzAwU1VRSjUyYWw3VkRibXBza1Eycks5OHYzY0VUMnJ6S0RkdGJ3N3RKaGhPNlV6NG5qN2Y0NEs4dThpK1BpWmcxWEpBUWVCclF3NWpVNW92akZoNzFobUhRMThnOUladW41ZjBZbjB3RjIvT0NwdGkwcGpMWVlyZi8zbk9lQUxUZS9RSURBUUFCIg0KfQ==";
		
		var INTERVAL_MS_INPUT:Number = 10;
		
		var _mRazerSDKNativeInterface: RazerSDKNativeInterface;
		var _mVirtualController1: VirtualController;
		var _mVirtualController2: VirtualController;
		var _mVirtualController3: VirtualController;
		var _mVirtualController4: VirtualController;
		
		var _mInputTimer:Number = 0;
		
		var _mInitialized:Boolean = false;
		
		private function fl_EnterFrameHandler_1(event:Event):void
		{
			var date:Date = new Date();
			if (_mInputTimer < date.getTime())
			{
				_mInputTimer = date.getTime() + INTERVAL_MS_INPUT;
				
				_mVirtualController1.Update();
				_mVirtualController2.Update();
				_mVirtualController3.Update();
				_mVirtualController4.Update();
			}
			
			if (!_mInitialized &&
				_mRazerSDKNativeInterface.IsInitialized()) {
				var deviceName:String = _mRazerSDKNativeInterface.GetDeviceHardwareName();
				_mRazerSDKNativeInterface.LogInfo("HardwareDevice: "+_mRazerSDKNativeInterface.GetDeviceHardwareName());
				LblHello.text = "Flash Virtual Controller On: "+deviceName;
				
				_mRazerSDKNativeInterface.LogInfo("BUTTON_O Name: "+_mRazerSDKNativeInterface.GetButtonName(Controller.BUTTON_O));
				_mRazerSDKNativeInterface.LogInfo("BUTTON_U Name: "+_mRazerSDKNativeInterface.GetButtonName(Controller.BUTTON_U));
				_mRazerSDKNativeInterface.LogInfo("BUTTON_Y Name: "+_mRazerSDKNativeInterface.GetButtonName(Controller.BUTTON_Y));
				_mRazerSDKNativeInterface.LogInfo("BUTTON_A Name: "+_mRazerSDKNativeInterface.GetButtonName(Controller.BUTTON_A));
					
				_mInitialized = true;
			}
		}
		
		private function GetVirtualController(playerNum:int):VirtualController
		{
			if (playerNum == 0) {
				return _mVirtualController1;
			} else if (playerNum == 1) {
				return _mVirtualController2;
			} else if (playerNum == 2) {
				return _mVirtualController3;
			} else {
				return _mVirtualController4;
			}
		}
		
		private function Axis(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var axis:int = json.axis;
			var val:Number = json.value;
			//_mRazerSDKNativeInterface.LogInfo("Axis: playerNum:"+playerNum+" axis:"+axis+" value:"+val);
			GetVirtualController(playerNum).Axis(axis, val);
		}
		
		private function ButtonDown(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var button:int = json.button;
			//_mRazerSDKNativeInterface.LogInfo("ButtonDown: playerNum:"+playerNum+" button:"+button);
			GetVirtualController(playerNum).ButtonDown(button);
		}
		
		private function ButtonUp(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var button:int = json.button;
			//_mRazerSDKNativeInterface.LogInfo("ButtonUp: playerNum:"+playerNum+" button:"+button);
			GetVirtualController(playerNum).ButtonUp(button);
		}
		
		private function onStatusEvent( _event : StatusEvent ) : void 
		{
			//_mRazerSDKNativeInterface.LogInfo("Code: " + _event.code );
			//_mRazerSDKNativeInterface.LogInfo("Level: " + _event.level );
			
			if (_event.code == "Axis") {
				Axis(_event.level);
			} else if (_event.code == "ButtonDown") {
				ButtonDown(_event.level);
			} else if (_event.code == "ButtonUp") {
				ButtonUp(_event.level);
			}
		}
		
        public function Main()
        {
			_mRazerSDKNativeInterface = new RazerSDKNativeInterface();
			_mRazerSDKNativeInterface.RazerSDKInit(SECRET_API_KEY);
			
			_mVirtualController1 = new VirtualController(this, _mRazerSDKNativeInterface, 0, 15.65, -75.1);
			_mVirtualController2 = new VirtualController(this, _mRazerSDKNativeInterface, 1, 1232.55, -75.1);
			_mVirtualController3 = new VirtualController(this, _mRazerSDKNativeInterface, 2, 15.65, 495.75);
			_mVirtualController4 = new VirtualController(this, _mRazerSDKNativeInterface, 3, 1232.55, 495.75);
			
			// put the label on top of the sprites
			setChildIndex(LblHello, numChildren-1);
			
			//_mRazerSDKNativeInterface.LogInfo("***** Add event listener...");			
			addEventListener(Event.ENTER_FRAME, fl_EnterFrameHandler_1);
			
			_mRazerSDKNativeInterface.GetExtensionContext().addEventListener( StatusEvent.STATUS, onStatusEvent );
        }
    }
}
