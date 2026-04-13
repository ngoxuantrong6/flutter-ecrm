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
    searchTextController.dispose();
    super.dispose();
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName,
        arguments: query); // điều hướng đến search Screen
  }

  void navigateToAddress(int sum) {
    // điều hướng đến địa chỉ để thanh toán
    if (sum == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🛒 Giỏ hàng của bạn đang trống!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
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

    // ✅ Tính tổng tiền an toàn
    int sum = user.cart.fold(
      0,
      (previousValue, item) {
        final price = item['product']['price'];
        final quantity = item['quantity'];

        // 🔥 Kiểm tra giá trị hợp lệ trước khi cộng
        if (price is int && quantity is int) {
          return previousValue + (quantity * price);
        } else {
          return previousValue;
        }
      },
    );

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
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child:
                              Icon(Icons.search, color: Colors.black, size: 23),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide:
                              const BorderSide(color: Colors.black38, width: 1),
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
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.black,
                      size: 25,
                    ),
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
          if (user.cart.isNotEmpty && sum > 0) ...[
            const CartSubtotal(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellow[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => navigateToAddress(sum),
                  child: Text(
                    'Thanh toán tất cả (${user.cart.length} items)',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(color: Colors.black12.withOpacity(0.08), height: 1),
          const SizedBox(height: 5),
          Expanded(
            child: user.cart.isEmpty
                ? const Center(
                    child: Text(
                      "🛒 Giỏ hàng của bạn đang trống!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.builder(
                    itemCount: user.cart.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CartProduct(index: index);
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
      listenFor: const Duration(seconds: 5),
    );
    subscription = GlobalVariables.speechProvider.stream.listen(
      (event) {
        if (event.eventType == SpeechRecognitionEventType.statusChangeEvent) {
          _hintText = 'Đang nghe';
          if (mounted) setState(() => _isListening = true);
        } else if (event.eventType ==
            SpeechRecognitionEventType.partialRecognitionEvent) {
          if (mounted) {
            setState(() {
              _text =
                  GlobalVariables.speechProvider.lastResult!.recognizedWords;
            });
          }
        } else if (event.eventType == SpeechRecognitionEventType.errorEvent) {
          print('onError');
        } else if (event.eventType == SpeechRecognitionEventType.doneEvent) {
          subscription.cancel();
          setState(() => _isListening = false);
          navigateToSearchScreen(_text);
        }
      },
    );
  }
}
