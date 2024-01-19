import 'dart:async';

import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/address/screens/address_screen.dart';
import 'package:flutter_ecrm/features/cart/widgets/cart_product.dart';
import 'package:flutter_ecrm/features/cart/widgets/cart_subtotal.dart';
import 'package:flutter_ecrm/features/home/widgets/address_box.dart';
import 'package:flutter_ecrm/features/search/screens/search_screen.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_event.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  void navigateToAddress(int sum) {
    Navigator.pushNamed(
      context,
      AddressScreen.routeName,
      arguments: sum.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    searchTextController.text = _text;
    final user = context.watch<UserProvider>().user;
    int sum = 0;
    user.cart
        .map((e) => sum += e['quantity'] * e['product']['price'] as int)
        .toList();

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
      body: Column(
        children: [
          const AddressBox(),
          const CartSubtotal(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomButton(
              text: 'Thanh toán tất cả (${user.cart.length} items)',
              onTap: () => navigateToAddress(sum),
              color: Colors.yellow[600],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            color: Colors.black12.withOpacity(0.08),
            height: 1,
          ),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
              itemCount: user.cart.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return CartProduct(
                  index: index,
                );
              },
            ),
          ),
        ],
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
