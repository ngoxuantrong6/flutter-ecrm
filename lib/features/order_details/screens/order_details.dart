import 'dart:async';

import 'package:amazon_clone_tutorial/common/widgets/custom_button.dart';
import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/constants/utils.dart';
import 'package:amazon_clone_tutorial/features/admin/services/admin_services.dart';
import 'package:amazon_clone_tutorial/features/search/screens/search_screen.dart';
import 'package:amazon_clone_tutorial/models/order.dart';
import 'package:amazon_clone_tutorial/providers/user_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_event.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  final Order order;
  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int currentStep = 0;
  final AdminServices adminServices = AdminServices();
  TextEditingController searchTextController = TextEditingController();
  late StreamSubscription<SpeechRecognitionEvent> subscription;
  bool _isListening = false;
  String _text = '';
  String _hintText = 'Tìm kiếm';

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    currentStep = widget.order.status;
  }

  @override
  void dispose() {
    searchTextController.clear();
    super.dispose();
  }

  // !!! ONLY FOR ADMIN!!!
  void changeOrderStatus(int status) {
    adminServices.changeOrderStatus(
      context: context,
      status: status + 1,
      order: widget.order,
      onSuccess: () {
        setState(() {
          currentStep += 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    searchTextController.text = _text;
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: user.type == 'admin'
              ? const Text(
                  'Quản lý đơn hàng',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )
              : Row(
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xem chi tiết đơn hàng',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: GlobalVariables.primaryColor,
                    width: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 2,
                      color: GlobalVariables.primaryColor.withOpacity(0.25),
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: Colors.white,
                ),
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black12,
                //   ),
                // ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ngày đặt hàng:      ${DateFormat.yMMMMd('vi').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.order.orderedAt),
                    )}         ${DateFormat.Hms('vi').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.order.orderedAt),
                    )}'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giao đến:                '),
                        Expanded(child: Text(widget.order.address)),
                      ],
                    ),
                    Text(
                      'Tổng:                       ${formatPrice(widget.order.totalPrice)} đ',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // const Text(
              //   'Chi tiết mua hàng',
              //   style: TextStyle(
              //     fontSize: 22,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: GlobalVariables.primaryColor,
                    width: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 2,
                      color: GlobalVariables.primaryColor.withOpacity(0.25),
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: Colors.white,
                ),
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black12,
                //   ),
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < widget.order.products.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: widget.order.products[i].images[0],
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.order.products[i].name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Số lượng: ${widget.order.quantity[i]}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Theo dõi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: GlobalVariables.primaryColor,
                    width: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 2,
                      color: GlobalVariables.primaryColor.withOpacity(0.25),
                      offset: const Offset(2, 2),
                    ),
                  ],
                  color: Colors.white,
                ),
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.black12,
                //   ),
                // ),
                child: Stepper(
                  currentStep: currentStep,
                  controlsBuilder: (context, details) {
                    if (user.type == 'admin' && currentStep < 5) {
                      return CustomButton(
                        text: 'Xong',
                        onTap: () => changeOrderStatus(details.currentStep),
                      );
                    }
                    return const SizedBox();
                  },
                  steps: [
                    Step(
                      title: const Text('Đơn hàng đã được đặt'),
                      content: const Text(
                        'Đơn hàng của bạn đã được đặt.',
                      ),
                      isActive: currentStep > 0,
                      state: currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Sẵn sàng để vận chuyển'),
                      content: const Text(
                        'Đơn hàng của bạn đã được đóng gói và đang chờ hãng vận chuyển đến lấy.',
                      ),
                      isActive: currentStep > 1,
                      state: currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Đã lấy'),
                      content: const Text(
                        'Kiện hàng của bạn đã được lấy.',
                      ),
                      isActive: currentStep > 2,
                      state: currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Đang trên đường giao'),
                      content: const Text(
                        'Kiện hàng của bạn đang trên đường giao.',
                      ),
                      isActive: currentStep >= 3,
                      state: currentStep >= 3
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Tiến hành giao hàng'),
                      content: const Text(
                        'Kiện hàng của bạn sẽ sớm được giao, vui lòng chú ý đến thông tin giao hàng.',
                      ),
                      isActive: currentStep >= 4,
                      state: currentStep >= 4
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                    Step(
                      title: const Text('Đã giao'),
                      content: const Text(
                        'Kiện hàng của bạn đã được giao! Người nhận: Khách hàng.',
                      ),
                      isActive: currentStep >= 5,
                      state: currentStep >= 5
                          ? StepState.complete
                          : StepState.indexed,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
