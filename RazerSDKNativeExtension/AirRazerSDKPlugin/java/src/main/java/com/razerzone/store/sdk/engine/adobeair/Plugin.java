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
import android.graphics.Color;
import android.graphics.Point;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.razerzone.store.sdk.CancelIgnoringResponseListener;
import com.razerzone.store.sdk.Controller;
import com.razerzone.store.sdk.GamerInfo;
import com.razerzone.store.sdk.PurchaseResult;
import com.razerzone.store.sdk.ResponseListener;
import com.razerzone.store.sdk.StoreFacade;
import com.razerzone.store.sdk.purchases.Product;
import com.razerzone.store.sdk.purchases.Purchasable;
import com.razerzone.store.sdk.purchases.Receipt;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.security.InvalidParameterException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Created by tgraupmann on 7/11/2016.
 */
public class Plugin {
    private static final String TAG = Plugin.class.getSimpleName();

    private static final boolean sEnableLogging = false;

    private static Activity sActivity = null;
    private static Bundle sSavedInstanceState = null;
    private static InputView sInputView = null;
    private static StoreFacade sStoreFacade = null;
    private static boolean sInitialized = false;
    private static FREContext sFREContext = null;

    // listener for init complete
    private static CancelIgnoringResponseListener<Bundle> sInitCompleteListener = null;

    // listener for requesting login
    private static ResponseListener<Void> sRequestLoginListener = null;

    // listener for requesting gamer info
    private static ResponseListener<GamerInfo> sRequestGamerInfoListener = null;

    // listener for getting products
    private static ResponseListener<List<Product>> sRequestProductsListener = null;

    // listener for requesting purchase
    private static ResponseListener<PurchaseResult> sRequestPurchaseListener = null;

    // listener for getting receipts
    private static ResponseListener<Collection<Receipt>> sRequestReceiptsListener = null;

    // listener for shutdown
    private static CancelIgnoringResponseListener sShutdownListener = null;

    public static Activity getActivity() {
        return sActivity;
    }

    public static void setActivity(Activity activity) {
        sActivity = activity;
    }

    public static Bundle getSavedInstanceState() {
        return sSavedInstanceState;
    }

    public static void setSavedInstanceState(Bundle savedInstanceState) {
        sSavedInstanceState = savedInstanceState;
    }

    public static InputView getInputView() { return sInputView; }

    public static FREContext getFREContext() { return sFREContext; }
    public static void setFREContext(FREContext freContext) {
        sFREContext = freContext;
    }

    private static void abort() {
        Log.e(TAG, "Plugin failed to load and stopped application!");
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    public static void initPlugin(final String secretApiKey) {
        final Activity activity = getActivity();
        if (null == activity) {
            Log.e(TAG, "initPlugin: Activity is null!");
        }
        if (secretApiKey == null) {
            Log.e(TAG, "initPlugin: secretApiKey is null!");
            return;
        }
        Runnable runnable = new Runnable() {
            public void run() {
                if (null == getActivity()) {
                    Log.e(TAG, "initPlugin: activity is null!");
                    abort();
                    return;
                }

                /*
                sInputView = new InputView(activity);

                if (sEnableLogging) {
                    Log.d(TAG, "Disable screensaver");
                }
                sInputView.setKeepScreenOn(true);

                FrameLayout content = (FrameLayout) activity.findViewById(android.R.id.content);
                if (null != content) {
                    Button button = new Button(activity);
                    button.setOnClickListener(sInputView);
                    button.setVisibility(View.VISIBLE);
                    button.setText("");
                    button.setBackgroundColor(Color.TRANSPARENT);
                    content.addView(button);
                } else {
                    Log.e(TAG, "initPlugin: Content view is missing");
                }

                Controller.init(activity);
                */

                if (null == sStoreFacade) {

                    sInitCompleteListener = new CancelIgnoringResponseListener<Bundle>() {
                        @Override
                        public void onSuccess(Bundle bundle) {
                            sendResult("InitCompleteOnSuccess", "");
                        }

                        @Override
                        public void onFailure(int errorCode, String errorMessage, Bundle bundle) {
                            Log.e(TAG, "Error initializing StoreFacade errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            sendError("InitCompleteOnFailure", errorCode, errorMessage);
                        }
                    };

                    sRequestLoginListener = new ResponseListener<Void>() {
                        @Override
                        public void onSuccess(Void result) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestLoginListener: onSuccess");
                            }
                            sendResult("RequestLoginOnSuccess", "");
                        }

                        @Override
                        public void onFailure(final int errorCode, final String errorMessage, final Bundle optionalData) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestLoginListener: onFailure errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            }
                            sendError("RequestLoginOnFailure", errorCode, errorMessage);
                        }

                        @Override
                        public void onCancel() {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestLoginListener: onCancel");
                            }
                            sendError("RequestLoginOnCancel", 0, "Request Login was cancelled!");
                        }
                    };

                    sRequestGamerInfoListener = new ResponseListener<GamerInfo>() {
                        @Override
                        public void onSuccess(final GamerInfo info) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestGamerInfoListener: onSuccess");
                            }
                            JSONObject result = new JSONObject();
                            try {
                                result.put("username", info.getUsername());
                                result.put("uuid", info.getUuid());
                            } catch (JSONException e) {
                                sendError("RequestGamerInfoOnFailure", 0, "Failed to create results!");
                                return;
                            }
                            sendResult("RequestGamerInfoOnSuccess", result.toString());
                        }

                        @Override
                        public void onFailure(final int errorCode, final String errorMessage, final Bundle optionalData) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestGamerInfoListener: onFailure errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            }
                            sendError("RequestGamerInfoOnFailure", errorCode, errorMessage);
                        }

                        @Override
                        public void onCancel() {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestGamerInfoListener: onCancel");
                            }
                            sendError("RequestGamerInfoOnCancel", 0, "Request GamerInfo was cancelled!");
                        }
                    };

                    sRequestProductsListener = new ResponseListener<List<Product>>() {
                        @Override
                        public void onSuccess(final List<Product> products) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestProductsListener: onSuccess");
                            }
                            JSONArray result = new JSONArray();
                            try {
                                int i = 0;
                                for (Product product : products) {
                                    JSONObject jsonObject = new JSONObject();
                                    jsonObject.put("description", product.getDescription());
                                    jsonObject.put("identifier", product.getIdentifier());
                                    jsonObject.put("name", product.getName());
                                    jsonObject.put("localPrice", product.getLocalPrice());
                                    result.put(i, jsonObject);
                                    ++i;
                                }
                            } catch (JSONException e) {
                                sendError("RequestProductsOnFailure", 0, "Failed to create results!");
                                return;
                            }
                            sendResult("RequestProductsOnSuccess", result.toString());
                        }

                        @Override
                        public void onFailure(final int errorCode, final String errorMessage, final Bundle optionalData) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestProductsListener: onFailure errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            }
                            sendError("RequestProductsOnFailure", errorCode, errorMessage);
                        }

                        @Override
                        public void onCancel() {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestProductsListener: onCancel");
                            }
                            sendError("RequestProductsOnCancel", 0, "Request Products was cancelled!");
                        }
                    };

                    sRequestPurchaseListener = new ResponseListener<PurchaseResult>() {

                        @Override
                        public void onSuccess(final PurchaseResult purchaseResult) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestPurchaseListener: onSuccess");
                            }
                            JSONObject result = new JSONObject();
                            try {
                                result.put("productIdentifier", purchaseResult.getProductIdentifier());
                                result.put("orderId", purchaseResult.getOrderId());
                            } catch (JSONException e) {
                                sendError("RequestPurchaseOnFailure", 0, "Failed to set productIdentifier!");
                                return;
                            }
                            sendResult("RequestPurchaseOnSuccess", result.toString());
                        }

                        @Override
                        public void onFailure(final int errorCode, final String errorMessage, final Bundle optionalData) {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestPurchaseListener: onFailure errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            }
                            sendError("RequestPurchaseOnFailure", errorCode, errorMessage);
                        }

                        @Override
                        public void onCancel() {
                            if (sEnableLogging) {
                                Log.d(TAG, "sRequestPurchaseListener: onCancel");
                            }
                            sendError("RequestPurchaseOnCancel", 0, "Purchase was cancelled!");
                        }
                    };

                    sRequestReceiptsListener = new ResponseListener<Collection<Receipt>>() {

                        @Override
                        public void onSuccess(final Collection<Receipt> receipts) {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestReceipts onSuccess: received " + receipts.size() + " receipts");
                            }
                            JSONArray result = new JSONArray();
                            try {
                                int i = 0;
                                for (Receipt receipt : receipts) {
                                    JSONObject jsonObject = new JSONObject();
                                    jsonObject.put("currency", receipt.getCurrency());
                                    jsonObject.put("generatedDate", receipt.getGeneratedDate());
                                    jsonObject.put("identifier", receipt.getIdentifier());
                                    jsonObject.put("localPrice", receipt.getLocalPrice());
                                    result.put(i, jsonObject);
                                    ++i;
                                }
                            } catch (JSONException e) {
                                sendError("RequestReceiptsOnFailure", 0, "Failed to create results!");
                                return;
                            }
                            sendResult("RequestReceiptsOnSuccess", result.toString());
                        }

                        @Override
                        public void onFailure(final int errorCode, final String errorMessage, final Bundle optionalData) {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestReceipts onFailure: errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            }
                            sendError("RequestReceiptsOnFailure", errorCode, errorMessage);
                        }

                        @Override
                        public void onCancel() {
                            if (sEnableLogging) {
                                Log.d(TAG, "requestReceiptsListener: onCancel");
                            }
                            sendError("RequestReceiptsOnCancel", 0, "Request Receipts was cancelled!");
                        }
                    };

                    sShutdownListener = new CancelIgnoringResponseListener() {
                        @Override
                        public void onSuccess(Object o) {
                            Log.d(TAG, "ShutdownListener onSuccess: finishing activity...");
                            sendResult("ShutdownOnSuccess", "");
                        }

                        @Override
                        public void onFailure(int errorCode, String errorMessage, Bundle bundle) {
                            Log.e(TAG, "ShutdownListener onFailure failed to shutdown! errorCode=" + errorCode + " errorMessage=" + errorMessage);
                            sendError("ShutdownOnFailure", errorCode, errorMessage);
                        }
                    };

                    sStoreFacade = StoreFacade.getInstance();

                    Bundle developerInfo = null;
                    try {
                        developerInfo = StoreFacade.createInitBundle(secretApiKey);
                    } catch (InvalidParameterException e) {
                        Log.e(TAG, e.getMessage());
                        abort();
                        return;
                    }

                    if (sEnableLogging) {
                        Log.d(TAG, "developer_id=" + developerInfo.getString(StoreFacade.DEVELOPER_ID));
                    }

                    if (sEnableLogging) {
                        Log.d(TAG, "developer_public_key length=" + developerInfo.getByteArray(StoreFacade.DEVELOPER_PUBLIC_KEY).length);
                    }

                    try {
                        sStoreFacade.init(activity, developerInfo, sInitCompleteListener);
                    } catch (Exception e) {
                        e.printStackTrace();
                        return;
                    }

                    if (sEnableLogging) {
                        Log.d(TAG, "Initialized StoreFacade.");
                    }

                    sendResult("RazerSDKInitialized", "");

                    sInitialized = true;
                }
            }
        };
        activity.runOnUiThread(runnable);
    }

    private static int getDisplayWidth() {
        final Activity activity = getActivity();
        if (null != activity) {
            WindowManager windowManager = activity.getWindowManager();
            Display display = windowManager.getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            return size.x;
        } else {
            return 0;
        }
    }

    private static int getDisplayHeight() {
        final Activity activity = getActivity();
        if (null != activity) {
            WindowManager windowManager = activity.getWindowManager();
            Display display = windowManager.getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);
            return size.y;
        } else {
            return 0;
        }
    }

    private static void updateSafeArea(float progress) {
        final Activity activity = getActivity();
        if (null != activity) {
            //Log.d(TAG, "updateSafeArea: progress="+progress);
            // bring in by %
            float percent = 0.1f;
            float ratio = 1 - (1 - progress) * percent;
            float halfRatio = 1 - (1 - progress) * percent * 0.5f;
            float maxWidth = getDisplayWidth();
            float maxHeight = getDisplayHeight();
            FrameLayout content = (FrameLayout) activity.findViewById(android.R.id.content);
            ViewGroup.LayoutParams layout = content.getLayoutParams();
            layout.width = (int) (maxWidth * ratio);
            layout.height = (int) (maxHeight * ratio);
            content.setLayoutParams(layout);
            content.setX(maxWidth - maxWidth * halfRatio);
            content.setY(maxHeight - maxHeight * halfRatio);
        }
    }

    public static void setResolution(final int width, final int height) {
        try {
            //Log.d(TAG, "setResolution: width="+width+" height="+height);
            final Activity activity = getActivity();
            if (null != activity) {
                Runnable runnable = new Runnable() {
                    public void run() {

                    }
                };
                activity.runOnUiThread(runnable);
            }
        } catch (Exception e) {
            Log.e(TAG, "setResolution: exception=" + e.toString());
        }
    }

    public static void setSafeArea(final float percentage) {
        try {
            //Log.d(TAG, "setSafeArea: percentage="+percentage);
            final Activity activity = getActivity();
            if (null != activity) {
                Runnable runnable = new Runnable() {
                    public void run() {
                        updateSafeArea(percentage);
                    }
                };
                activity.runOnUiThread(runnable);
            }
        } catch (Exception e) {
            Log.e(TAG, "setSafeArea: exception=" + e.toString());
        }
    }

    public static boolean isInitialized() {
        return sInitialized;
    }

    public static boolean processActivityResult(final int requestCode, final int resultCode, final Intent data) {
        if (null == sStoreFacade) {
            Log.e(TAG, "processActivityResult: StoreFacade is null!");
            return false;
        }
        return (sStoreFacade.processActivityResult(requestCode, resultCode, data));
    }

    private static void sendResult(final String tag, final String jsonData) {
        if (null == sFREContext) {
            return;
        }
        sFREContext.dispatchStatusEventAsync(tag, jsonData);
    }

    private static void sendError(final String tag, final int errorCode, final String errorMessage) {
        if (null == sFREContext) {
            return;
        }
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("errorCode", errorCode);
            jsonObject.put("errorMessage", errorMessage);
        } catch (JSONException e) {
        }
        sFREContext.dispatchStatusEventAsync(tag, jsonObject.toString());
    }

    public static void requestProducts(String jsonData) {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("RequestProductsError", 0, "Activity is null!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("RequestProductsError", 0, "requestProducts sStoreFacade is null!");
            return;
        }
        if (sEnableLogging) {
            Log.d(TAG, "requestProducts");
        }
        if (null == sRequestProductsListener) {
            sendError("RequestProductsError", 0, "requestProducts: sRequestProductsListener is null");
            return;
        }
        JSONArray jsonArray = null;
        try {
            jsonArray = new JSONArray(jsonData);
        } catch (JSONException e) {
            sendError("RequestProductsError", 0, "requestProducts Failed to create product list!");
            return;
        }
        List<String> products = new ArrayList<String>();
        try {
            for (int i = 0; i < jsonArray.length(); ++i) {
                String identifier = jsonArray.getString(i);
                products.add(identifier);
            }
        } catch (JSONException e) {
            sendError("RequestProductsError", 0, "requestProducts Failed to create product list!");
            return;
        }
        String[] purchasables = new String[products.size()];
        purchasables = products.toArray(purchasables);
        sStoreFacade.requestProductList(activity, purchasables, sRequestProductsListener);
    }

    public static void requestPurchase(String identifier, String productType) {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("RequestReceiptsError", 0, "Activity is null!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("RequestReceiptsError", 0, "requestProducts sStoreFacade is null!");
            return;
        }
        if (null == sRequestPurchaseListener) {
            sendError("RequestPurchaseError", 0, "requestPurchase: sRequestPurchaseListener is null");
            return;
        }
        Product product = new Product(identifier, "", 0, 0, "", 0, 0, "", "", Product.Type.valueOf(productType));
        Purchasable purchasable = product.createPurchasable();
        sStoreFacade.requestPurchase(activity, purchasable, sRequestPurchaseListener);
    }

    public static void requestReceipts() {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("RequestReceiptsError", 0, "Activity is null!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("RequestReceiptsError", 0, "requestProducts sStoreFacade is null!");
            return;
        }
        if (null == sRequestReceiptsListener) {
            sendError("RequestReceiptsError", 0, "requestReceipts: sRequestReceiptsListener is null");
            return;
        }
        sStoreFacade.requestReceipts(activity, sRequestReceiptsListener);
    }

    public static void requestLogin() {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("RequestLoginError", 0, "Activity is null!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("RequestLoginError", 0, "requestProducts sStoreFacade is null!");
            return;
        }
        if (sEnableLogging) {
            Log.i(TAG, "requestLogin");
        }
        if (null == sRequestLoginListener) {
            sendError("RequestLoginError", 0, "requestLogin: sRequestLoginListener is null");
            return;
        }
        sStoreFacade.requestLogin(activity, sRequestLoginListener);
    }

    public static void requestGamerInfo() {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("RequestGamerInfoError", 0, "Activity is null!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("RequestGamerInfoError", 0, "requestProducts sStoreFacade is null!");
            return;
        }
        if (sEnableLogging) {
            Log.i(TAG, "requestGamerInfo");
        }
        if (null == sRequestGamerInfoListener) {
            sendError("RequestGamerInfoError", 0, "requestGamerInfo: sRequestGamerInfoListener is null");
            return;
        }
        sStoreFacade.requestGamerInfo(activity, sRequestGamerInfoListener);
    }

    public static String getGameData(String key) {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return null;
        }
        final Activity activity = getActivity();
        if (null == activity) {
            sendError("GetGameData", 0, "getGameData: Activity is null!");
            return null;
        }
        if (null == sStoreFacade) {
            sendError("GetGameData", 0, "getGameData: StoreFacade is null!");
            return null;
        }
        if (sEnableLogging) {
            Log.i(TAG, "GetGameData");
        }
        if (null == key) {
            sendError("GetGameData", 0, "getGameData: key is null");
            return null;
        }
        return sStoreFacade.getGameData(key);
    }

    public static void putGameData(String key, String val) {
        if (null == sFREContext) {
            Log.e(TAG, "Context is not set!");
            return;
        }
        if (null == sStoreFacade) {
            sendError("PutGameData", 0, "putGameData sStoreFacade is null!");
            return;
        }
        if (sEnableLogging) {
            Log.i(TAG, "PutGameData");
        }
        if (null == key) {
            sendError("PutGameData", 0, "putGameData: key is null");
            return;
        }
        if (null == val) {
            sendError("PutGameData", 0, "putGameData: value is null");
            return;
        }
        sStoreFacade.putGameData(key, val);
    }

    public static void shutdown() {

        final Activity activity = getActivity();
        if (null == activity) {
            Log.e(TAG, "Activity instance is null!");
            sendError("ShutdownError", 0, "shutdown: Activity is null!");
            return;
        }

        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if (sEnableLogging) {
                    Log.d(TAG, "Shutdown");
                }
                if (null != sStoreFacade) {
                    sStoreFacade.shutdown(sShutdownListener);
                    sStoreFacade = null;
                }
                if (null != sFREContext) {
                    Activity activity = sFREContext.getActivity();
                    if (null != activity) {
                        activity.finish();
                    }
                }

                // with multiple activities, make sure application exits
                if (sEnableLogging) {
                    Log.i(TAG, "*** Forced Shutdown!");
                }
                android.os.Process.killProcess(android.os.Process.myPid());
            }
        };
        activity.runOnUiThread(runnable);
    }
}
