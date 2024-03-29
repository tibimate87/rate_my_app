import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rate_my_app/starrating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'channel_calls.dart';
import 'constans.dart';

class RateDialog extends StatefulWidget {
  final int minimeRateIsGood;
  final bool afterStarRedirect;
  final Image image;
  final String emailAdmin;
  final Map<String, String> texts;
  final Function sendDataToFB;
  final Color backgroundColor;
  final Color textColor;
  final String androidAppId;
  final String iOSAppId;
  // final Map<String, Map<String, String>> langTexts;

  RateDialog({
    @required this.minimeRateIsGood,
    this.image,
    this.afterStarRedirect,
    this.emailAdmin = '',
    @required this.texts,
    @required this.sendDataToFB,
    @required this.backgroundColor,
    @required this.textColor,
    @required this.androidAppId,
    @required this.iOSAppId,
    // @required this.langTexts,
  });

  @override
  _RateDialogState createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  int isGood = 0;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int minimeRateIsGood;
  int ratedStars;

  String langArrayPosition = "en";
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool badAvaliationEmpty = false;

  @override
  void initState() {
    super.initState();
    // ChannelCall().getDeviceLang().then((value) {
    //   langArrayPosition = value;
    //   //Concatenating the two lists to add the language modifications
    //   Map<String, String> langText = {};
    //   // if (widget.langTexts != null) {
    //   //   LangTexts().text[langArrayPosition].forEach((key, value) {
    //   //     if (widget.langTexts[langArrayPosition] !=
    //   //         null) if (widget.langTexts[langArrayPosition][key] != null)
    //   //       langText.addAll(
    //   //           {key: widget.langTexts[langArrayPosition][key].toString()});
    //   //     else
    //   //       langText.addAll({key: value});
    //   //     else
    //   //       langText.addAll({key: value});
    //   //   });
    //   // } else
    //   //   langText = LangTexts().text["en"];

    //   // _langTexts = langText;
    //   // debugPrint("langs =======> ${_langTexts.toString()}");
    //   // setState(() {});
    // });

    // _langTexts = LangTexts().text[langArrayPosition];

    minimeRateIsGood = widget.minimeRateIsGood;
    ratedStars = 0;
    _prefs.then((SharedPreferences prefs) {
      ratedStars = prefs.getInt(Constants.table_rated_stars) ?? 0;
      setState(() {
        debugPrint("initState() $ratedStars");
        if (ratedStars >= minimeRateIsGood) isGood = 1;
        if (ratedStars < minimeRateIsGood && ratedStars != 0) isGood = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                //top: Constants.avatarRadius + Constants.padding,
                top: Constants.padding,
                bottom: Constants.padding,
                left: Constants.padding,
                right: Constants.padding,
              ),
              margin: EdgeInsets.only(top: Constants.avatarRadius),
              decoration: new BoxDecoration(
                color: widget.backgroundColor, //Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(Constants.padding),
              ),
              child: rateDialog()),
        ),
      ],
    );
  }

  rateDialog() {
    switch (isGood) {
      case 1:
        return _goodRequest();
        break;
      case 2:
        return _badRequest();
        break;
      default:
        return _initialRequest();
    }
  }

  Widget _initialRequest() {
    return Column(
      mainAxisSize: MainAxisSize.min, // To make the card compact
      children: <Widget>[
        Text(
          widget.texts['titleRate'],
          // DemoLocalizations.of(context).titleRate,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: widget.textColor),
        ),
        SizedBox(height: 16.0),
        Text(
          widget.texts['description'],
          // DemoLocalizations.of(context).description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0, color: widget.textColor),
        ),
        SizedBox(height: 24.0),
        Center(child: callRating()),
        SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // To close the dialog
            },
            child: Text(
              widget.texts['btnLater'],
              // DemoLocalizations.of(context).btnLater,
              style: TextStyle(color: widget.textColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _goodRequest() {
    return Column(
      mainAxisSize: MainAxisSize.min, // To make the card compact
      children: <Widget>[
        Text(
          widget.texts['titleRate'],
          // DemoLocalizations.of(context).titleRate,
          style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
              color: widget.textColor),
        ),
        SizedBox(height: 16.0),
        Container(
          child: Text(
            '',
            // _langTexts['goodRateDescription'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.textColor),
          ),
        ),
        SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              ChannelCall().openPlayStore(widget.androidAppId, widget.iOSAppId);

              var timeStamp = DateTime.now();
              var data = {
                "timeStamp": timeStamp,
                "rateStare": ratedStars,
                "feeback": "",
              };

              widget.sendDataToFB(data);
              // Firestore.instance.collection("AppFeedback").document().setData({
              //   "timeStamp": timeStamp,
              //   "rateStare": ratedStars,
              //   "feeback": "",
              //   "user": auth.user().uid,
              // });

              _updateRatedDatabase(rated: true);
              Navigator.pop(context);
            },
            child: Text(
              '',
              // _langTexts['goodBtnRate'],
              style: TextStyle(color: widget.textColor),
            ),
          ),
        )
      ],
    );
  }

  Widget _badRequest() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Text(
            widget.texts['title'],
            // DemoLocalizations.of(context).title,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: widget.textColor),
          ),
          SizedBox(height: 16.0),
          Center(child: callRating()),
          SizedBox(height: 16.0),
          Text(
            widget.texts['badRateDescription'],
            // DemoLocalizations.of(context).badRateDescription,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0, color: widget.textColor),
          ),
          SizedBox(height: 16.0),
          Align(
            alignment: Alignment.center,
            child: TextFormField(
              controller: _textController,
              maxLines: 4,
              validator: (value) {
                if (value.isEmpty) {
                  return widget.texts[
                      'badValidation']; //, DemoLocalizations.of(context).badValidation;
                }
                return null;
              },
              style: TextStyle(
                  color: widget.textColor, decorationColor: Colors.red),
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.textColor.withOpacity(0.8),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.textColor.withOpacity(0.8),
                    ),
                  ),
                  hintStyle: TextStyle(color: widget.textColor),
                  hintText: widget.texts[
                      'badRateTextAreaHinit']), //  DemoLocalizations.of(context).badRateTextAreaHinit),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  var timeStamp = DateTime.now();

                  var data = {
                    "timeStamp": timeStamp,
                    "rateStare": ratedStars,
                    "feeback": _textController.value.text,
                  };

                  widget.sendDataToFB(data);
                  // Firestore.instance
                  //     .collection("AppFeedback")
                  //     .document()
                  //     .setData({
                  //   "timeStamp": timeStamp,
                  //   "rateStare": ratedStars,
                  //   "feeback": _textController.value.text,
                  //   "user": auth.user().uid,
                  // });

                  // if (widget.emailAdmin.isNotEmpty) {
                  //   ChannelCall().sendEmail(
                  //       emailAdmin: widget.emailAdmin,
                  //       bodyEmail: _textController.value.text);
                  // }
                  Navigator.of(context).pop();
                  _updateRatedDatabase(rated: true);
                }
              },
              child: Text(
                widget.texts['badBtnSend'],
                // DemoLocalizations.of(context).badBtnSend,
                style: TextStyle(color: widget.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget callRating() => StarRating(
        rating: ratedStars.toDouble(),
        //isReadOnly: false,
        size: 40,
        filledIconData: Icons.star,
        halfFilledIconData: Icons.star_half,
        defaultIconData: Icons.star_border,
        color: Colors.amber,
        borderColor: Colors.amber,
        starCount: 5,
        allowHalfRating: false,
        spacing: 2.0,
        onRatingChanged: (value) {
          print("rating value -> ${value.toInt()} ==== $minimeRateIsGood");

          ratedStars = value.toInt();

          setState(() {});

          if (value.toInt() >= minimeRateIsGood) {
            Timer(Duration(milliseconds: 500), () {
              if (widget.afterStarRedirect) {
                debugPrint("forcedRedirect after stars");
                var timeStamp = DateTime.now();

                var data = {
                  "timeStamp": timeStamp,
                  "rateStare": ratedStars,
                  "feeback": "",
                };

                widget.sendDataToFB(data);

                // Firestore.instance
                //     .collection("AppFeedback")
                //     .document()
                //     .setData({
                //   "timeStamp": timeStamp,
                //   "rateStare": ratedStars,
                //   "feeback": "",
                //   "user": auth.user().uid,
                // });

                ChannelCall()
                    .openPlayStore(widget.androidAppId, widget.iOSAppId);
                _updateRatedDatabase(rated: true);
                setState(() {});
                Navigator.of(context).pop();
                return;
              }
              isGood = 1;
              _updateRateStarDatabase(intraterStar: value.toInt());
              setState(() {});
            });
            return;
          }

          if (value.toInt() < minimeRateIsGood) {
            isGood = 2;
            _updateRateStarDatabase(intraterStar: value.toInt());
            setState(() {});
          }
        },
      );

  Future<void> _updateRateStarDatabase({@required intraterStar}) async {
    final SharedPreferences prefs = await _prefs;
    prefs
        .setInt(Constants.table_rated_stars, intraterStar)
        .then((bool success) {
      return success;
    });
  }

  Future<void> _updateRatedDatabase({@required rated}) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(Constants.table_rated, rated).then((bool success) {
      return success;
    });
  }
}
