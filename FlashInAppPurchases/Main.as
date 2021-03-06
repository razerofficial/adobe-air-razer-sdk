﻿package
{
	import com.razerzone.store.sdk.Controller;	
	import com.razerzone.store.sdk.engine.adobeair.RazerSDKNativeInterface;	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
    import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.system.System;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.text.TextField;

    public class Main extends MovieClip
    {
		static var SECRET_API_KEY:String = "eyJkZXZlbG9wZXJfaWQiOiIzMTBhOGY1MS00ZDZlLTRhZTUtYmRhMC1iOTM4NzhlNWY1ZDAiLCJkZXZlbG9wZXJfcHVibGljX2tleSI6Ik1JR2ZNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0R05BRENCaVFLQmdRRFYyd0RKRVdoRVNUdmtEcjBJWDNnUFc4N0pZMjgyT3ZqaGtsZWUwSUt6bFAzNVNtM1hlRGd4dU9SbkQzaUFta2YwRlo0L1VUWnBuTUhSVHhnNDBPTWZIYm4zSlVDUGdFdDJmTWZkL2ZVNU4vR2VqeTh2RE1nR092d2FlbUsvWU9NVHMyc2ZnTmduYVRJa3JFNVg5OFFKcGhaenlDY3cwUUZXaEdIczh1eCswUUlEQVFBQiJ9";
		
		var INTERVAL_MS_INPUT:Number = 10;
		
		var _mRazerSDKNativeInterface: RazerSDKNativeInterface;
		
		var _mInputTimer:Number = 0;
		
		var _mInitialized:Boolean = false;
		
		var _mBtnRequestLogin:Bitmap;		
		var _mBtnRequestProducts:Bitmap;
		var _mBtnRequestPurchase:Bitmap;
		var _mBtnRequestReceipts:Bitmap;
		var _mBtnRequestGamerInfo:Bitmap;
		var _mBtnGetGameData:Bitmap;
		var _mBtnPutGameData:Bitmap;
		var _mBtnExit:Bitmap;
		
		var _mButtonIndex:int = 0;
		
		var _mProducts:Array = null;
		
		var _mButtonPressed:Boolean = false;
		
		var _mProductLabels:Array = new Array();
		
		var _mProductIndex:int = -1;
		
		var _mReceipts:Array = null;
		
		var INDEX_REQUEST_LOGIN:int = 0;
		var INDEX_REQUEST_PRODUCTS:int = 1;
		var INDEX_REQUEST_PURCHASE:int = 2;
		var INDEX_REQUEST_RECEIPTS:int = 3;
		var INDEX_REQUEST_GAMERINFO:int = 4;
		var INDEX_GET_GAMEDATA:int = 5;
		var INDEX_PUT_GAMEDATA:int = 6;
		var INDEX_EXIT:int = 7;
		
		private function fl_EnterFrameHandler_1(event:Event):void
		{
			if (LblStatus.stage.focus == BtnRequestLogin) {
				_mButtonIndex = INDEX_REQUEST_LOGIN;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnRequestProducts) {
				_mButtonIndex = INDEX_REQUEST_PRODUCTS;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnRequestPurchase) {
				_mButtonIndex = INDEX_REQUEST_PURCHASE;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnRequestReceipts) {
				_mButtonIndex = INDEX_REQUEST_RECEIPTS;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnRequestGamerInfo) {
				_mButtonIndex = INDEX_REQUEST_GAMERINFO;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnGetGameData) {
				_mButtonIndex = INDEX_GET_GAMEDATA;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnPutGameData) {
				_mButtonIndex = INDEX_PUT_GAMEDATA;
				_mButtonPressed = true;
			} else if (LblStatus.stage.focus == BtnExit) {
				_mButtonIndex = INDEX_EXIT;
				_mButtonPressed = true;
			}
			
			var date:Date = new Date();
			if (_mInputTimer < date.getTime())
			{
				_mInputTimer = date.getTime() + INTERVAL_MS_INPUT;
				
				UpdateVisibility(_mBtnRequestLogin, _mButtonIndex == INDEX_REQUEST_LOGIN);
				UpdateVisibility(_mBtnRequestProducts, _mButtonIndex == INDEX_REQUEST_PRODUCTS);
				UpdateVisibility(_mBtnRequestPurchase, _mButtonIndex == INDEX_REQUEST_PURCHASE);
				UpdateVisibility(_mBtnRequestReceipts, _mButtonIndex == INDEX_REQUEST_RECEIPTS);
				UpdateVisibility(_mBtnRequestGamerInfo, _mButtonIndex == INDEX_REQUEST_GAMERINFO);
				UpdateVisibility(_mBtnGetGameData, _mButtonIndex == INDEX_GET_GAMEDATA);
				UpdateVisibility(_mBtnPutGameData, _mButtonIndex == INDEX_PUT_GAMEDATA);
				UpdateVisibility(_mBtnExit, _mButtonIndex == INDEX_EXIT);
				
				if (_mButtonIndex == INDEX_REQUEST_PRODUCTS ||
					_mButtonIndex == INDEX_REQUEST_PURCHASE) {
					DisplayProducts();
				} else if (_mButtonIndex == INDEX_REQUEST_RECEIPTS) {
					DisplayReceipts();
				} else {
					LblContent.text = "";
				}
			}
			
			if (!_mInitialized &&
				_mRazerSDKNativeInterface.IsInitialized()) {
				var deviceName:String = _mRazerSDKNativeInterface.GetDeviceHardwareName();
				_mRazerSDKNativeInterface.LogInfo("HardwareDevice: "+_mRazerSDKNativeInterface.GetDeviceHardwareName());
				LblHello.text = "Running on device: `"+deviceName+"`";
					
				var strButtonO:String = _mRazerSDKNativeInterface.GetButtonName(Controller.BUTTON_O);
				
				LblDirections.text = "Use DPAD to switch between buttons | Press '"+strButtonO+"' to click the button";
					
				_mInitialized = true;
			}
			
			if (_mButtonPressed) {
				_mButtonPressed = false;
				HandleButtonPress();
			}
		}
		
		private function Axis(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var axis:int = json.axis;
			var val:Number = json.value;
			//_mRazerSDKNativeInterface.LogInfo("Axis: playerNum:"+playerNum+" axis:"+axis+" value:"+val);
		}
		
		private function ButtonDown(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var button:int = json.button;
			//_mRazerSDKNativeInterface.LogInfo("ButtonDown: playerNum:"+playerNum+" button:"+button);
		}
		
		private function HandleButtonPress():void
		{
			if (_mButtonIndex == INDEX_REQUEST_LOGIN) {
				LblStatus.text = "STATUS: Requesting Login...";
				_mRazerSDKNativeInterface.RequestLogin();
			} else if (_mButtonIndex == INDEX_REQUEST_PRODUCTS) {
				LblStatus.text = "STATUS: Requesting Product List...";
				_mProductIndex = 0;
				var jsonData:String = "[\"long_sword\",\"sharp_axe\",\"__DECLINED__THIS_PURCHASE\"]";
				_mRazerSDKNativeInterface.RequestProducts(jsonData);
			} else if (_mButtonIndex == INDEX_REQUEST_PURCHASE) {
				var products:Array = _mProducts;
				if (_mProductIndex < products.length) {
					LblStatus.text = "STATUS: Requesting Purchase...";
					_mRazerSDKNativeInterface.RequestPurchase(products[_mProductIndex].identifier, "ENTITLEMENT");
				} else {
					LblStatus.text = "STATUS: Request products before making a purchase!";
				}
			} else if (_mButtonIndex == INDEX_REQUEST_RECEIPTS) {
				LblStatus.text = "STATUS: Requesting Receipts...";
				_mRazerSDKNativeInterface.RequestReceipts();
			} else if (_mButtonIndex == INDEX_REQUEST_GAMERINFO) {
				LblStatus.text = "STATUS: Requesting Gamer Info...";
				_mRazerSDKNativeInterface.RequestGamerInfo();
			} else if (_mButtonIndex == INDEX_GET_GAMEDATA) {
				LblStatus.text = "STATUS: Get Game Data...";
				var result:String = _mRazerSDKNativeInterface.GetGameData("FULL_GAME_UNLOCK");
				LblStatus.text = "STATUS: Get Game Data: "+result;
			} else if (_mButtonIndex == INDEX_PUT_GAMEDATA) {
				LblStatus.text = "STATUS: Put Game Data...";
				_mRazerSDKNativeInterface.PutGameData("FULL_GAME_UNLOCK", "DATA SET");
			} else if (_mButtonIndex == INDEX_EXIT) {
				LblStatus.text = "STATUS: Exiting...";
				_mRazerSDKNativeInterface.Shutdown();
			}
		}
		
		private function ButtonUp(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var playerNum:int = json.playerNum;
			var button:int = json.button;
			//_mRazerSDKNativeInterface.LogInfo("ButtonUp: playerNum:"+playerNum+" button:"+button);
			if (button == Controller.BUTTON_DPAD_LEFT) {
				if (_mButtonIndex > 0) {
					--_mButtonIndex;
				}
			} else if (button == Controller.BUTTON_DPAD_RIGHT) {
				if (_mButtonIndex < INDEX_EXIT) {
					++_mButtonIndex;
				}
			} else if (button == Controller.BUTTON_DPAD_DOWN) {
				var products:Array = _mProducts;
				if (null != products) {
					if ((_mProductIndex+1) < products.length) {
						++_mProductIndex;
					}
				}
			} else if (button == Controller.BUTTON_DPAD_UP) {
				if (_mProductIndex > 0) {
					--_mProductIndex;
				}
			} else if (button == Controller.BUTTON_O) {
				HandleButtonPress();
			}
		}
		
		private function OnGenericError(tag:String, jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			var errorCode:int = json.errorCode;
			var errorMessage:String = json.errorMessage;
			LblStatus.text = "STATUS: "+tag+" errorCode="+errorCode+" errorMessage="+errorMessage;
		}
		
		private function InitCompleteOnSuccess():void
		{
			LblStatus.text = "STATUS: InitCompleteOnSuccess";
		}
		
		private function RequestLoginOnSuccess():void
		{
			LblStatus.text = "STATUS: LoginOnSuccess";
		}
		
		private function RequestGamerInfoOnSuccess(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			LblGamerUUID.text = "Gamer UUID: "+json.uuid;
			LblUsername.text = "Gamer Username: "+json.username;
		}
		
		private function RequestProductsOnSuccess(jsonData:String):void
		{
			var i:int;
			for (i = 0; i < _mProductLabels.length; ++i) {
				removeChild(_mProductLabels[i]);
			}
			_mProducts = JSON.parse(jsonData) as Array;
			_mProductLabels.length = 0;
			for (i = 0; i < _mProducts.length; ++i) {
				var textField:TextField = new TextField();
				textField.text = "";
				textField.textColor = LblContent.textColor;
				textField.defaultTextFormat = LblContent.defaultTextFormat;
				textField.x = LblContent.x;
				textField.height = 100;
				textField.y = LblContent.y + (1+i) * textField.height;
				textField.width = LblContent.width;
				textField.selectable = false;
				addChild(textField);
				_mProductLabels.push(textField);
			}
		}
		
		private function RequestPurchaseOnSuccess(jsonData:String):void
		{
			var json:Object = JSON.parse(jsonData);
			LblContent.text = jsonData;
		}
		
		private function RequestReceiptsOnSuccess(jsonData:String):void
		{
			//LblContent.text = jsonData;
			_mReceipts = JSON.parse(jsonData) as Array;
		}
		
		private function ShutdownOnSuccess():void
		{
			LblStatus.text = "STATUS: ShutdownOnSuccess";
			NativeApplication.nativeApplication.exit();
		}
		
		private function onStatusEvent( _event : StatusEvent ) : void 
		{
			if (_event.code == "Axis") {
				Axis(_event.level);
				return;
			} else if (_event.code == "ButtonDown") {
				ButtonDown(_event.level);
				return;
			} else if (_event.code == "ButtonUp") {
				ButtonUp(_event.level);
				return;
			}
			
			LblStatus.text = "STATUS: "+_event.code;
			
			if (_event.code == "InitCompleteOnSuccess") {			
				InitCompleteOnSuccess();
			} else if (_event.code == "RequestLoginOnSuccess") {
				RequestLoginOnSuccess();				
			} else if (_event.code == "RequestGamerInfoOnSuccess") {
				RequestGamerInfoOnSuccess(_event.level);
			} else if (_event.code == "RequestLoginError" ||
				_event.code == "RequestGamerInfoError" ||
				_event.code == "RequestProductsError" ||
				_event.code == "RequestPurchaseError" ||
				_event.code == "RequestReceiptsError" ||
				_event.code == "InitCompleteOnFailure" ||
				_event.code == "RequestLoginOnFailure" ||
				_event.code == "RequestGamerInfoOnFailure" ||
				_event.code == "RequestProductsOnFailure" ||
				_event.code == "RequestPurchaseOnFailure" ||
				_event.code == "RequestReceiptsOnFailure" ||
				_event.code == "ShutdownOnFailure"||
				_event.code == "RequestLoginOnCancel" ||
				_event.code == "RequestGamerInfoOnCancel" ||
				_event.code == "RequestProductsOnCancel" ||
				_event.code == "RequestPurchaseOnCancel" ||
				_event.code == "RequestReceiptsOnCancel") {
				OnGenericError(_event.code, _event.level);
			} else if (_event.code == "RequestProductsOnSuccess") {
				RequestProductsOnSuccess(_event.level);
			} else if (_event.code == "RequestPurchaseOnSuccess") {
				RequestPurchaseOnSuccess(_event.level);
			} else if (_event.code == "RequestReceiptsOnSuccess") {
				RequestReceiptsOnSuccess(_event.level);
			} else if (_event.code == "ShutdownSuccess") {
				ShutdownOnSuccess();
			} else {
				_mRazerSDKNativeInterface.LogInfo("Code: " + _event.code );
				_mRazerSDKNativeInterface.LogInfo("Level: " + _event.level );
			}
		}
		
		private function AddBitmap(textField : TextField, bitmap : Bitmap) : Bitmap
		{
			var matrix:Matrix = new Matrix();
			matrix.scale(new Number(textField.width)/bitmap.width, new Number(textField.height)/bitmap.height);

			var resizedBitmapData:BitmapData = new BitmapData(textField.width, textField.height, true, 0x000000);
			resizedBitmapData.draw(bitmap, matrix, null, null, null, true);

			var resizedBitmap = new Bitmap(resizedBitmapData, PixelSnapping.NEVER, true);
			
			resizedBitmap.x = textField.x;
			resizedBitmap.y = textField.y;
			
			addChild(resizedBitmap);
			return resizedBitmap;
		}
		
		private function CreateButton(textField : TextField) : Bitmap
		{
			textField.selectable = false;
			
			AddBitmap(textField, new Bitmap(new ImageButtonInactive()));
			var result:Bitmap = AddBitmap(textField, new Bitmap(new ImageButtonActive()));
			
			// put the label on top of the sprites
			setChildIndex(textField, numChildren-1);
			
			return result;
		}
		
		private function UpdateVisibility(bitmap:Bitmap, show:Boolean) : void
		{
			if (show)
			{
				bitmap.alpha = 1;
			}
			else
			{
				bitmap.alpha = 0;
			}
		}
		
		private function DisplayProducts():void
		{
			if (null != _mProductLabels) {
				for (var i:int = 0; i < _mProductLabels.length; ++i) {
					if (LblStatus.stage.focus == _mProductLabels[i]) {
						_mProductIndex = i;
					}
					if (_mButtonIndex == INDEX_REQUEST_PRODUCTS ||
						_mButtonIndex == INDEX_REQUEST_PURCHASE) {
						var identifier:String = _mProducts[i].identifier;
						var name:String = _mProducts[i].name;
						var localPrice:Number = _mProducts[i].localPrice;
						var str = identifier;
						str += " localPrice="+localPrice;							
						if (_mProductIndex == i) {
							_mProductLabels[i].text = "* "+str;
						} else {
							_mProductLabels[i].text = str;
						}
					} else {
						_mProductLabels[i].text = "";
					}
				}
			}
		}
		
		private function DisplayReceipts():void
		{
			var json:Array = _mReceipts;
			var str:String = "";
			if (null != json) {
				for (var i:int = 0; i < json.length; ++i) {
					var currency:String = json[i].currency;
					var identifier:String = json[i].identifier;
					var generatedDate:String = json[i].generatedDate;
					var localPrice:Number = json[i].localPrice;
					str += "currency="+currency;
					str += " identifier="+identifier;
					str += " generatedDate="+generatedDate;
					str += " localPrice="+localPrice;
					str += "\n";
				}
			}
			LblContent.text = str;
		}
		
        public function Main()
        {
			_mRazerSDKNativeInterface = new RazerSDKNativeInterface();
			_mRazerSDKNativeInterface.RazerSDKInit(SECRET_API_KEY);
			
			_mBtnRequestLogin = CreateButton(BtnRequestLogin);
			_mBtnRequestProducts = CreateButton(BtnRequestProducts);
			_mBtnRequestPurchase = CreateButton(BtnRequestPurchase);
			_mBtnRequestReceipts = CreateButton(BtnRequestReceipts);
			_mBtnRequestGamerInfo = CreateButton(BtnRequestGamerInfo);
			_mBtnGetGameData = CreateButton(BtnGetGameData);
			_mBtnPutGameData = CreateButton(BtnPutGameData);
			_mBtnExit = CreateButton(BtnExit);
			
			UpdateVisibility(_mBtnRequestLogin, true);
			UpdateVisibility(_mBtnRequestProducts, false);
			UpdateVisibility(_mBtnRequestPurchase, false);
			UpdateVisibility(_mBtnRequestReceipts, false);
			UpdateVisibility(_mBtnRequestGamerInfo, false);
			UpdateVisibility(_mBtnGetGameData, false);
			UpdateVisibility(_mBtnPutGameData, false);
			UpdateVisibility(_mBtnExit, false);
			
			//_mRazerSDKNativeInterface.LogInfo("***** Add event listener...");			
			addEventListener(Event.ENTER_FRAME, fl_EnterFrameHandler_1);
			
			_mRazerSDKNativeInterface.GetExtensionContext().addEventListener( StatusEvent.STATUS, onStatusEvent );
        }
    }
}
