library rate_my_app;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constans.dart';
import 'rate_dialog.dart';

class RateAppDialog {
  final BuildContext context;
  final int minimeRateIsGood;
  final int minimeRequestToShow;
  final bool afterStarRedirect;
  final bool customDialogIOS;
  final int timeToShow;
  final String emailAdmin;
  final Map<String, String> texts;
  final Function sendDataToFB;
  final Color backgroundColor;
  final Color textcolor;
  final String androidAppId;
  final String iOSAppId;

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  RateAppDialog({
    this.context,
    this.minimeRateIsGood = 4,
    this.minimeRequestToShow = 4,
    this.afterStarRedirect = false,
    this.customDialogIOS = false,
    this.timeToShow = 0,
    this.emailAdmin = '',
    this.texts,
    @required this.sendDataToFB,
    @required this.backgroundColor,
    @required this.textcolor,
    @required this.androidAppId,
    @required this.iOSAppId,
  });

  requestRate() async {
    int numeroRequest = await _updateRateRequest();
    final SharedPreferences prefs = await _prefs;

    debugPrint(
        "rate_app_dialog:debugPrint | numberOfRequest: $numeroRequest minimeRequestToShow: $minimeRequestToShow");

    // if (Platform.isIOS) {
    //   isAvaliableRequest = await ChannelCall().isRequestAvaliable();
    // }

    if (!(prefs.getBool(Constants.table_rated) ?? false) &&
        numeroRequest >= minimeRequestToShow) {
      // if (customDialogIOS == false && isAvaliableRequest) {
      //   await ChannelCall().requestReview();
      //   _updateRatedDatabase(rated: true);
      //   return;
      // }

      Timer(
          Duration(seconds: timeToShow),
          () => showDialog(
              context: context,
              builder: (BuildContext context) => RateDialog(
                    androidAppId: androidAppId,
                    iOSAppId: iOSAppId,
                    backgroundColor: backgroundColor,
                    textColor: textcolor,
                    afterStarRedirect: afterStarRedirect,
                    minimeRateIsGood: minimeRateIsGood,
                    emailAdmin: emailAdmin,
                    texts: texts,
                    sendDataToFB: (data) => sendDataToFB(data),
                  )));
    } else
      debugPrint("rate_app_dialog:debugPrint | this user rated");
  }

  Future<int> _updateRateRequest() async {
    final SharedPreferences prefs = await _prefs;
    int minimeRequestToShow =
        (prefs.getInt(Constants.table_rate_minime_request) ?? 0) + 1;
    int saved = await prefs
        .setInt(Constants.table_rate_minime_request, minimeRequestToShow)
        .then((bool success) {
      return minimeRequestToShow;
    });
    return saved;
  }

  Future<void> _updateRatedDatabase({@required rated}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(Constants.table_rated, rated).then((bool success) {
      return success;
    });
  }

  /// Sugestion: Aakash Kumar | git: @kumar-aakash86
  /// https://github.com/kellvembarbosa/rate_app_dialog/issues/1
  /// for reset key/values SharedPreferences ideal to tests
  /// Call this method for testing only! It will reset the saved values so that you can test again and call the dialog.

  resetKeyAndValues() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(Constants.table_rated, false);
    prefs.setInt(Constants.table_rated_stars, 0);
    prefs.setInt(Constants.table_rate_minime_request, 0);
    debugPrint("Rate_App_Dialog | ========> Data key/values Reseted <=======");
  }
}
