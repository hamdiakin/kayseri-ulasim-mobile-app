import 'dart:async';
import 'package:kayseri_ulasim/toast_animation.dart';
import 'package:flutter/material.dart';

class ToastUtils {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;

  static void showCustomToast(BuildContext context, String message) {
    if (toastTimer == null || !toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, message);
      Overlay.of(context).insert(_overlayEntry);
      toastTimer = Timer(Duration(seconds: 5), () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    } 

    /* if (toastTimer == null || !toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, message);
      Overlay.of(context).insert(_overlayEntry);
      toastTimer =  Timer.periodic(Duration(seconds: 1), (timer) { 
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    } */
  }

  static OverlayEntry createOverlayEntry(BuildContext context, String message) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        width: MediaQuery.of(context).size.width - 20,
        left: 10,
        child: SlideInToastMessageAnimation(Material(
          elevation: 10.0,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 13, bottom: 10),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10)),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Image.asset(
                    'assets/pinch.gif',
                    height: 50,
                    width: 50,
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
