import 'dart:async';

import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/features/home/widgets/address_box.dart';
import 'package:amazon_clone_tutorial/features/home/widgets/carousel_image.dart';
import 'package:amazon_clone_tutorial/features/home/widgets/deal_of_day.dart';
import 'package:amazon_clone_tutorial/features/home/widgets/top_categories.dart';
import 'package:amazon_clone_tutorial/features/search/screens/search_screen.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_event.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchTextController = TextEditingController();
  late StreamSubscription<SpeechRecognitionEvent> subscription;
  bool _isListening = false;
  String _text = '';
  String _hintText = 'Tìm kiếm';

  @override
  void dispose() {
    searchTextController.clear();
    super.dispose();
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  @override
  Widget build(BuildContext context) {
    searchTextController.text = _text;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      controller: searchTextController,
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(
                              left: 6,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: _hintText,
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AvatarGlow(
                animate: _isListening,
                glowColor: Theme.of(context).primaryColor,
                endRadius: 25.0,
                duration: const Duration(milliseconds: 2000),
                repeatPauseDuration: const Duration(milliseconds: 100),
                child: GestureDetector(
                  onTap: _listen,
                  child: Container(
                    color: Colors.transparent,
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.black, size: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            AddressBox(),
            SizedBox(height: 10),
            TopCategories(),
            CarouselImage(),
            DealOfDay(),
          ],
        ),
      ),
    );
  }

  void _listen() {
    GlobalVariables.speechProvider.listen(
        pauseFor: const Duration(seconds: 5),
        // localeId: 'en-us',
        listenFor: const Duration(seconds: 5));
    subscription = GlobalVariables.speechProvider.stream.listen(
      (event) {
        // on listening starts
        if (event.eventType == SpeechRecognitionEventType.statusChangeEvent) {
          _hintText = 'Đang nghe';
          if (mounted) {
            setState(() => _isListening = true);
          }
        }
        // on every change it update
        if (event.eventType ==
            SpeechRecognitionEventType.partialRecognitionEvent) {
          if (mounted) {
            setState(
              () {
                _text = GlobalVariables.speechProvider.lastResult!
                    .recognizedWords; // the textField or Text Widget Will be updated
              },
            );
          }
        }
        //on error
        else if (event.eventType == SpeechRecognitionEventType.errorEvent) {
          ///on error if some error occurs then close the dilog box here . or stop the listner
          print('onError');
        }

        //on done
        else if (event.eventType == SpeechRecognitionEventType.doneEvent) {
          //when the user stop speaking.
          subscription.cancel();
          setState(() => _isListening = false);
          navigateToSearchScreen(_text);
        }
      },
    );
  }
}
