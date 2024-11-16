import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/Screens/IndividualServices.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_ecrm/constants/global_variables.dart';

class IndividualPageProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;
  late IO.Socket socket;
  ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;
  IndividualServices individualServices = IndividualServices();
  BranchServices branchServices = BranchServices();

  IndividualPageProvider(
      BuildContext context, IndividualPageArguments individualPageArguments) {
    User user = Provider.of<UserProvider>(context, listen: false).user;
    _loadMessages(context, user, individualPageArguments);
    connect(context, user);
  }

  @override
  void dispose() {
    socket.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages(BuildContext context, User user,
      IndividualPageArguments individualPageArguments) async {
    if (user.type == "branch") {
      var messages = await branchServices.getMessages(
          context: context, chatUserId: individualPageArguments.receiver.id);
      setMessages(messages);
    } else {
      var messages = await individualServices.getMessages(
          context: context, chatUserId: individualPageArguments.receiver.id);
      setMessages(messages);
      if (individualPageArguments.productDetail != null) {
        individualServices
            .sendMessage(
              context: context,
              receiverId: individualPageArguments.receiver.id,
              message: individualPageArguments.productDetail!.name,
              product: individualPageArguments.productDetail,
            )
            .then((value) => setMessage(value));
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Kiểm tra nếu _scrollController đã được gắn với ScrollView
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void connect(BuildContext context, User user) {
    socket = IO.io(uri, <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
      'query': {'userId': user.id},
    });
    socket.connect();
    // socket.emit("signin", widget.sourchat.id);
    socket.onConnect((data) {
      print("Connected");
      socket.on("newMessage", (msg) {
        print("vào newMessage ${MessageModel.fromMap(msg).toJson()}");
        // setMessage(msg["message"]);
        setMessage(MessageModel.fromMap(msg));
        SchedulerBinding.instance.addPostFrameCallback((_) {
          // Kiểm tra nếu _scrollController đã được gắn với ScrollView
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
            );
          }
        });
        notifyListeners();
      });
    });
    print(socket.connected);

    // Kiểm tra lỗi kết nối
    socket.onConnectError((error) => print("Connect Error: $error"));
    socket.onDisconnect((_) => print("Disconnected from server"));
  }

  void sendMessage(BuildContext context,
      {required User user,
      required TextEditingController messageController,
      XFile? image,
      required User receiver,
      bool fromCameraView = false}) async {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      if (user.type == "branch") {
        branchServices
            .sendMessage(
          context: context,
          receiverId: receiver.id,
          message: message,
          image: image,
        )
            .then((value) {
          if (fromCameraView) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
          setMessage(value);
        });
      } else {
        individualServices
            .sendMessage(
          context: context,
          receiverId: receiver.id,
          message: message,
          image: image,
        )
            .then((value) {
          if (fromCameraView) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
          setMessage(value);
        });
      }
      messageController.clear();
      // Có thể gọi lại API lấy tin nhắn mới nếu cần
    }
  }

  void setMessages(List<MessageModel> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }

  void setMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
    print("qua setMessage ${message.toJson()}");
  }
}
