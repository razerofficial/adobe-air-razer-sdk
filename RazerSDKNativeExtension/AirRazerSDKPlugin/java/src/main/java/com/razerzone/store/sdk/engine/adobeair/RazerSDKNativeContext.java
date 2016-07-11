/*
 * Copyright (C) 2012-2016 Razer, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.razerzone.store.sdk.engine.adobeair;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.util.Log;
import com.adobe.air.ActivityResultCallback;
import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.AndroidActivityWrapper.ActivityState;
import com.adobe.air.StateChangeCallback;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import java.util.HashMap;
import java.util.Map;

public class RazerSDKNativeContext extends FREContext implements ActivityResultCallback, StateChangeCallback {
	
	private static final String TAG = RazerSDKNativeContext.class.getSimpleName();
	
	private AndroidActivityWrapper mAndroidActivityWrapper;
	
	private boolean mDetectedStop = false;
	
	public RazerSDKNativeContext() {
        mAndroidActivityWrapper = AndroidActivityWrapper.GetAndroidActivityWrapper();  
        mAndroidActivityWrapper.addActivityResultListener(this);  
        mAndroidActivityWrapper.addActivityStateChangeListner(this);  
    }
	
	@Override  
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        Log.d(TAG, "***** onActivityResult requestCode="+requestCode+" resultCode="+resultCode);
        Plugin.processActivityResult(requestCode, requestCode, intent);
    }
	
	@Override   
    public void onActivityStateChanged(ActivityState state) {
		Log.d(TAG, "***** onActivityStateChanged state="+state);
    }
	
	@Override  
    public void onConfigurationChanged(Configuration paramConfiguration) {
		if (null != mAndroidActivityWrapper) {  
            mAndroidActivityWrapper.removeActivityResultListener(this);  
            mAndroidActivityWrapper.removeActivityStateChangeListner(this);  
            mAndroidActivityWrapper = null;  
        }  
    }
	
	@Override
	public void dispose() {
	}
	
	@Override
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> map = new HashMap<String, FREFunction>();
		
		map.put("razerSDKInit", new RazerSDKNativeFunctionInit());
		map.put("razerSDKIsAnyConnected", new RazerSDKNativeFunctionIsAnyConnected());
		map.put("razerSDKIsConnected", new RazerSDKNativeFunctionIsConnected());
		map.put("razerSDKGetAxis", new RazerSDKNativeFunctionGetAxis());
		map.put("razerSDKGetAnyButton", new RazerSDKNativeFunctionGetAnyButton());
		map.put("razerSDKGetAnyButtonDown", new RazerSDKNativeFunctionGetAnyButtonDown());
		map.put("razerSDKGetAnyButtonUp", new RazerSDKNativeFunctionGetAnyButtonUp());
		map.put("razerSDKGetButton", new RazerSDKNativeFunctionGetButton());
		map.put("razerSDKGetButtonDown", new RazerSDKNativeFunctionGetButtonDown());
		map.put("razerSDKGetButtonUp", new RazerSDKNativeFunctionGetButtonUp());
		map.put("razerSDKClearButtonStatesPressedReleased", new RazerSDKNativeFunctionClearButtonStatesPressedReleased());
		map.put("razerSDKGetTrackpadX", new RazerSDKNativeFunctionGetTrackpadX());
		map.put("razerSDKGetTrackpadY", new RazerSDKNativeFunctionGetTrackpadY());
		map.put("razerSDKGetTrackpadDown", new RazerSDKNativeFunctionGetTrackpadDown());
		
		map.put("razerSDKLogInfo", new RazerSDKNativeFunctionLogInfo());
		map.put("razerSDKLogError", new RazerSDKNativeFunctionLogError());
		
		map.put("razerSDKToggleInputLogging", new RazerSDKNativeFunctionToggleInputLogging());
		
		map.put("razerSDKSetResolution", new RazerSDKNativeFunctionSetResolution());
		map.put("razerSDKSetSafeArea", new RazerSDKNativeFunctionSetSafeArea());
		
		map.put("razerSDKGetDeviceHardwareName", new RazerSDKNativeFunctionGetDeviceHardwareName());
		map.put("razerSDKGetButtonName", new RazerSDKNativeFunctionGetButtonName());
		
		map.put("razerSDKIsInitialized", new RazerSDKNativeFunctionIsInitialized());
		
		map.put("razerSDKRequestProducts", new RazerSDKNativeFunctionRequestProducts());
		map.put("razerSDKRequestPurchase", new RazerSDKNativeFunctionRequestPurchase());
		map.put("razerSDKRequestReceipts", new RazerSDKNativeFunctionRequestReceipts());
		map.put("razerSDKRequestGamerInfo", new RazerSDKNativeFunctionRequestGamerInfo());
		map.put("razerSDKGetGameData", new RazerSDKNativeFunctionGetGameData());
		map.put("razerSDKPutGameData", new RazerSDKNativeFunctionPutGameData());
		map.put("razerSDKShutdown", new RazerSDKNativeFunctionShutdown());
		
		return map;
	}
}
