import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Meeting());
  }
}

class Meeting extends StatefulWidget {
  @override
  _MeetingState createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final roomText = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        body: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        "assets/c58babb3219cd748d1e28a2184b64441.png",
                      ),
                      fit: BoxFit.fill)),
              child: kIsWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width * 0.30,
                          child: meetConfig(),
                        ),
                        Container(
                            width: width * 0.70,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                  color: Colors.white.withOpacity(.4),
                                  child: SizedBox(
                                    width: width * 0.60 * 0.60,
                                    height: height * 0.7 * 0.7,
                                    child: JitsiMeetConferencing(
                                      extraJS: [
                                        // extraJs setup example
                                        '<script>function echo(){console.log("echo!!!")};</script>',
                                        '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                      ],
                                    ),
                                  )),
                            ))
                      ],
                    )
                  : meetConfig(),
            ),
          ),
        ),
      ),
    );
  }

  Widget meetConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 45,
          margin: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xffF0F3F8),
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            autofocus: false,
            controller: roomText,
            style: TextStyle(fontSize: 12, color: Color(0xff3762CC)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter Valid Name';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.only(
                left: 47,
                right: 3,
                top: 15,
              ),
              errorStyle: TextStyle(
                  height: 0,
                  fontSize: 12,
                  color: Colors.white,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400),
              hintText: "Room Name",
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffC5CEE0),
                  fontSize: 12),
              prefixIcon: Container(
                height: 15,
                width: 15,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(
                    "assets/2437037-200.png",
                    height: 10,
                    width: 10,
                    color: Color(0xff3762CC),
                  ),
                ),
              ),

              //Icon(icon,size: 15,color: blueColor,),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            height: 45,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(40)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: MaterialButton(
                  onPressed: () {
                    if (_formkey.currentState.validate()) {
                      showInSnackBar("LogIn Successfully");
                      new Future.delayed(const Duration(seconds: 2), () {
                        _joinMeeting();
                      });

                      return;
                    } else {
                      showInSnackBar("Please Enter Valid Credentials");
                    }
                  },
                  child: Center(
                    child: Text("Join Meeting",
                        style: TextStyle(color: Colors.white)),
                  )),
            )),
      ],
    );
  }

  _joinMeeting() async {
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: true,
    };
    if (!kIsWeb) {
      featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
      featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = false;
      featureFlags[FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED] = false;
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
        featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = false;
        featureFlags[FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
        featureFlags[FeatureFlagEnum.CHAT_ENABLED] = false;
        featureFlags[FeatureFlagEnum.RAISE_HAND_ENABLED] = false;
        featureFlags[FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(room: roomText.text)
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
      };
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
          genericListeners: [
            JitsiGenericListener(
                eventName: 'readyToClose',
                callback: (dynamic message) {
                  debugPrint("readyToClose callback");
                }),
          ]),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        // ignore: deprecated_member_use
        .showSnackBar(new SnackBar(content: new Text(value)));
  }
}
