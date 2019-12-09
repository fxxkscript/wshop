package com.meizizi.doraemon;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.sch.share.Options;
import com.sch.share.WXShareMultiImageHelper;
import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends FlutterActivity {
    private static String[] PERMISSIONS_STORAGE = {
        Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    };


    private static final String CHANNEL = "com.meizizi.doraemon/door";
    private static final int REQUEST_PERMISSION_CODE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(this)
            .build();
        ImageLoader.getInstance().init(config);
        GeneratedPluginRegistrant.registerWith(this);


        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("weixin")) {
                    share(call.arguments);
                }
            });


        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, PERMISSIONS_STORAGE, REQUEST_PERMISSION_CODE);
            }
        }

        UMConfigure.init(this, "5db850a63fc19576a8000ffb", "android", UMConfigure.DEVICE_TYPE_PHONE, "");
    }

    @SuppressWarnings("unchecked")
    protected void share(Object params) {
        HashMap<String, Object> map = (HashMap<String, Object>) params;

        this.loadImage((List<String>) map.get("pics"), bitmapList -> share(bitmapList, (String) map.get("text")));
    }

    @Override
    public void onResume() {
        super.onResume();
        MobclickAgent.onResume(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        MobclickAgent.onPause(this);
    }

    // 分享到朋友圈。
    private void share(List<Bitmap> bitmapList, String text) {
        // 分享图片和文字，并设置本次分享是否，是否自动发布
        Options options = new Options();

        options.setAutoFill(true);
        options.setText(text);
        options.setAutoPost(false);

        Bitmap[] arr = new Bitmap[bitmapList.size()];
        arr = bitmapList.toArray(arr);
        WXShareMultiImageHelper.shareToTimeline(this, arr, options);
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
            requestStoragePermission();
        }
    }

    @Override
    protected void onDestroy() {
        // 清理临时文件。
        WXShareMultiImageHelper.clearTmpFile(this);
        super.onDestroy();
    }

    private void requestStoragePermission() {
        // 申请内存权限。
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
        }
    }

    private void loadImage(List<String> imgUrls, final OnLoadImageEndCallback callback) {
        final ProgressDialog dialog = new ProgressDialog(this);
        dialog.setMessage("正在准备分享图片...");
        dialog.show();
        new Thread(() -> {
            List<Bitmap> bitmapList = new ArrayList<>();

            for (String url : imgUrls) {
                Bitmap bitmap = ImageLoader.getInstance().loadImageSync(url);

                if (bitmap != null) {
                    bitmapList.add(bitmap);
                }
            }
            runOnUiThread(dialog::cancel);
            callback.onEnd(bitmapList);
        }).start();
    }


    private interface OnLoadImageEndCallback {
        void onEnd(List<Bitmap> bitmapList);
    }
}
