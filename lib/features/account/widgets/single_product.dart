import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:intl/intl.dart';

class SingleProduct extends StatelessWidget {
  final String image;
  final Order? order;
  const SingleProduct({
    Key? key,
    required this.image,
    this.order,
  }) : super(key: key);

  String _getOrderStatus(int status) {
    switch (status) {
      case 0:
        return 'Đơn hàng đã được đặt';
      case 1:
        return 'Sẵn sàng để vận chuyển';
      case 2:
        return 'Đã lấy';
      case 3:
        return 'Đang trên đường giao';
      case 4:
        return 'Tiến hành giao hàng';
      case 5:
        return 'Đã giao';
      default:
        return 'Không xác định';
    }
  }

  Color _getOrderStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.teal;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.indigo;
      case 5:
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: GlobalVariables.primaryColor,
            width: 0.2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              blurRadius: 3,
              color: GlobalVariables.primaryColor.withOpacity(0.15),
              offset: const Offset(1, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: order != null
                      ? const BorderRadius.vertical(top: Radius.circular(8))
                      : BorderRadius.circular(8),
                  child: isUrl(image)
                      ? CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.fitHeight,
                        )
                      : imageFromBase64String(
                          image,
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                        ),
                ),
              ),
              if (order != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng: ${order!.id.length >= 8 ? order!.id.substring(order!.id.length - 8).toUpperCase() : order!.id.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                            .format(order!.totalPrice),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getOrderStatus(order!.status),
                        style: TextStyle(
                          color: _getOrderStatusColor(order!.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
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
}
