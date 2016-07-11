/*
 * Copyright (C) 2012-2015 OUYA, Inc.
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
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class RazerSDKNativeFunctionInit implements FREFunction {
	
	private static final String TAG = RazerSDKNativeFunctionInit.class.getSimpleName();
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		String secretApiKey;
		if (args.length > 0) {
			try {
				secretApiKey = args[0].getAsString();
			} catch (Exception e) {
				Log.e(TAG, "Exception reading secretApiKey:String argument");
				return null;
			}
		} else {
			Log.e(TAG, "Missing secretApiKey:String argument");
			return null;
		}
		
		// save a reference to the context to make async calls
		Plugin.setFREContext(context);
		
		final Activity activity = context.getActivity();
		if (null == activity) {
			Log.e(TAG, "Activity is null!");
			return null;
		}

		Plugin.setActivity(activity);

        //Log.d(TAG, "SecretApiKey: "+secretApiKey);
		Plugin.initPlugin(secretApiKey);

		return null;
	}
}
