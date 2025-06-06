/**
* This code was generated by [react-native-codegen](https://www.npmjs.com/package/react-native-codegen).
*
* Do not edit this file as changes may cause incorrect behavior and will be lost
* once the code is regenerated.
*
* @generated by codegen project: GeneratePropsJavaDelegate.js
*/

package com.facebook.react.viewmanagers;

import android.view.View;
import androidx.annotation.Nullable;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.uimanager.BaseViewManagerDelegate;
import com.facebook.react.uimanager.BaseViewManagerInterface;

public class RNPDFPdfViewManagerDelegate<T extends View, U extends BaseViewManagerInterface<T> & RNPDFPdfViewManagerInterface<T>> extends BaseViewManagerDelegate<T, U> {
  public RNPDFPdfViewManagerDelegate(U viewManager) {
    super(viewManager);
  }

  public void setProperty(T view, String propName, @Nullable Object value) {
    switch (propName) {
      case "path":
        mViewManager.setPath(view, value == null ? null : (String) value);
        break;
      case "page":
        mViewManager.setPage(view, value == null ? 0 : ((Double) value).intValue());
        break;
      case "scale":
        mViewManager.setScale(view, value == null ? 0f : ((Double) value).floatValue());
        break;
      case "minScale":
        mViewManager.setMinScale(view, value == null ? 0f : ((Double) value).floatValue());
        break;
      case "maxScale":
        mViewManager.setMaxScale(view, value == null ? 0f : ((Double) value).floatValue());
        break;
      case "horizontal":
        mViewManager.setHorizontal(view, value == null ? false : (boolean) value);
        break;
      case "showsHorizontalScrollIndicator":
        mViewManager.setShowsHorizontalScrollIndicator(view, value == null ? false : (boolean) value);
        break;
      case "showsVerticalScrollIndicator":
        mViewManager.setShowsVerticalScrollIndicator(view, value == null ? false : (boolean) value);
        break;
      case "scrollEnabled":
        mViewManager.setScrollEnabled(view, value == null ? false : (boolean) value);
        break;
      case "enablePaging":
        mViewManager.setEnablePaging(view, value == null ? false : (boolean) value);
        break;
      case "enableRTL":
        mViewManager.setEnableRTL(view, value == null ? false : (boolean) value);
        break;
      case "enableAnnotationRendering":
        mViewManager.setEnableAnnotationRendering(view, value == null ? false : (boolean) value);
        break;
      case "enableDoubleTapZoom":
        mViewManager.setEnableDoubleTapZoom(view, value == null ? false : (boolean) value);
        break;
      case "enableAntialiasing":
        mViewManager.setEnableAntialiasing(view, value == null ? false : (boolean) value);
        break;
      case "fitPolicy":
        mViewManager.setFitPolicy(view, value == null ? 0 : ((Double) value).intValue());
        break;
      case "spacing":
        mViewManager.setSpacing(view, value == null ? 0 : ((Double) value).intValue());
        break;
      case "password":
        mViewManager.setPassword(view, value == null ? null : (String) value);
        break;
      case "singlePage":
        mViewManager.setSinglePage(view, value == null ? false : (boolean) value);
        break;
         case "initialXOffset":
        mViewManager.setInitialXOffset(view, value == null ? 0 : ((Double) value).floatValue());
        break;
         case "initialYOffset":
        mViewManager.setInitialYOffset(view, value == null ? 0 : ((Double) value).floatValue());
        break;
      default:
        super.setProperty(view, propName, value);
    }
  }

  public void receiveCommand(T view, String commandName, ReadableArray args) {
    switch (commandName) {
      case "setNativePage":
        mViewManager.setNativePage(view, args.getInt(0));
        break;
      case "moveToNative":
        mViewManager.moveToNative(view, args.getDouble(0), args.getDouble(1), args.getDouble(2));
        break;
      case "resetZoom":
        mViewManager.resetZoom(view);
        break;
    }
  }
}
