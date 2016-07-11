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

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class RazerSDKNativeFunctionGetAxis implements FREFunction {
	
	private static final String TAG = RazerSDKNativeFunctionGetAxis.class.getSimpleName();
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		
		try {
			int playerNum;
			if (args.length > 0) {
				playerNum = args[0].getAsInt();
			} else {
				Log.e(TAG, "Missing playerNum:int argument");
				return FREObject.newObject((double)0);
			}
			
			int axis;
			if (args.length > 1) {
				axis = args[1].getAsInt();
			} else {
				Log.e(TAG, "Missing axis:int argument");
				return FREObject.newObject((double)0);
			}
			
			float result = InputView.getAxis(playerNum, axis);
			return FREObject.newObject((double)result);
		} catch (Exception e) {
			e.printStackTrace();
			Log.e(TAG, "Unexpected exception");
		}
		
		return null;
	}
}
