package com.razerzone.store.sdk.engine.adobeair
{
	import flash.external.ExtensionContext;
	
	public class RazerSDKNativeInterface
	{
		private var context:ExtensionContext;
		
		public function RazerSDKNativeInterface()
		{
			if (!context) {
				context = ExtensionContext.createExtensionContext("com.razerzone.store.sdk.engine.adobeair.razersdknativecontext", null);
			}
		}
		
		public function GetExtensionContext():ExtensionContext {
			return context;
		}
		
		public function RazerSDKInit(developerId:String):void {
			context.call("razerSDKInit", developerId);
		}
		
		public function IsAnyConnected():Boolean {
			return context.call("razerSDKIsAnyConnected");
		}
		
		public function IsConnected(playerNum:int):Boolean {
			return context.call("razerSDKIsConnected", playerNum);
		}
		
		public function GetAxis(playerNum:int, axis:int):Number {
			return context.call("razerSDKGetAxis", playerNum, axis) as Number;
		}
		
		public function GetAnyButton(button:int):Boolean {
			return context.call("razerSDKGetAnyButton", button);
		}
		
		public function GetAnyButtonDown(button:int):Boolean {
			return context.call("razerSDKGetAnyButtonDown", button);
		}
		
		public function GetAnyButtonUp(button:int):Boolean {
			return context.call("razerSDKGetAnyButtonUp", button);
		}
		
		public function GetButton(playerNum:int, button:int):Boolean {
			return context.call("razerSDKGetButton", playerNum, button);
		}

		public function GetButtonDown(playerNum:int, button:int):Boolean {
			return context.call("razerSDKGetButtonDown", playerNum, button);
		}
		
		public function GetButtonUp(playerNum:int, button:int):Boolean {
			return context.call("razerSDKGetButtonUp", playerNum, button);
		}
		
		public function ClearButtonStatesPressedReleased():Boolean {
			return context.call("razerSDKClearButtonStatesPressedReleased");
		}
		
		public function GetTrackpadX():Number {
			return context.call("razerSDKGetTrackpadX") as Number;
		}
		
		public function GetTrackpadY():Number {
			return context.call("razerSDKGetTrackpadY") as Number;
		}
		
		public function GetTrackpadDown():Boolean {
			return context.call("razerSDKGetTrackpadDown");
		}
		
		public function LogInfo(message:String):void {
			context.call("razerSDKLogInfo", message);
		}
		
		public function LogError(message:String):void {
			context.call("razerSDKLogError", message);
		}
		
		public function ToggleInputLogging(toggle:Boolean):void {
			context.call("razerSDKToggleInputLogging", toggle);
		}
		
		public function SetSafeArea(percentage:Number):void {
			context.call("razerSDKSetSafeArea", percentage);
		}
		
		public function SetResolution(width:int, height:int):void {
			context.call("razerSDKSetResolution", width, height);
		}
		
		public function GetDeviceHardwareName():String {
			return context.call("razerSDKGetDeviceHardwareName") as String;
		}
		
		public function GetButtonName(button:int):String {
			return context.call("razerSDKGetButtonName", button) as String;
		}
		
		public function IsInitialized():Boolean {
			return context.call("razerSDKIsInitialized") as Boolean;
		}
		
		public function RequestProducts(jsonData:String):void {
			context.call("razerSDKRequestProducts", jsonData);
		}
		
		public function RequestPurchase(identifier:String):void {
			context.call("razerSDKRequestPurchase", identifier);
		}
		
		public function RequestReceipts():void {
			context.call("razerSDKRequestReceipts");
		}
		
		public function RequestGamerInfo():void {
			context.call("razerSDKRequestGamerInfo");
		}
		
		public function GetGameData(key:String):String {
			return context.call("razerSDKGetGameData", key) as String;
		}
		
		public function PutGameData(key:String, val:String):void {
			context.call("razerSDKPutGameData", key, val);
		}
		
		public function Shutdown():void {
			context.call("razerSDKShutdown");
		}
	}
}