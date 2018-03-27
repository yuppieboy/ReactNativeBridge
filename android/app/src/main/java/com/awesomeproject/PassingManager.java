package com.awesomeproject;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import javax.annotation.Nullable;

import android.widget.Toast;

/**
 * Created by paul on 3/27/18.
 */

@ReactModule(name = "PassingManager")

public class PassingManager extends ReactContextBaseJavaModule {

    private ReactContext context;

    public PassingManager(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
        notifyReactNative();
    }

    @Override
    public String getName() {
        return "PassingManager";
    }

    @ReactMethod
    public void tellClient(ReadableMap map) {
        String finalMsg = "Received message from JS :" + map.toHashMap();
        Toast.makeText(getReactApplicationContext(), finalMsg, Toast.LENGTH_LONG).show();
    }


    private void sendEvent(String eventName,
                           @Nullable WritableMap params) {
        context
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    private void notifyReactNative(){
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(5 * 1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                WritableMap et= Arguments.createMap();
                WritableArray array = Arguments.createArray();
                array.pushString("1");
                array.pushString("2");
                array.pushString("3");
                et.putString("msg", "Hello ReactNative");
                et.putArray("array",array);
                sendEvent("EventReminder",et);
            }
        }).start();
    }
}

