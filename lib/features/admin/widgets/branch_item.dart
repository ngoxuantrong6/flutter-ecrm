import 'package:flutter/material.dart';
import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BranchItem extends StatefulWidget {
  const BranchItem({
    Key? key,
    required this.index,
    required this.branches,
    required this.onDeleteBranch,
  }) : super(key: key);

  final int index;
  final List<User> branches;
  final VoidCallback onDeleteBranch;

  @override
  State<BranchItem> createState() => _BranchItemState();
}

class _BranchItemState extends State<BranchItem> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Slidable(
        key: const ValueKey(0),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) {
                PopupNotificationCustom.showMessgae(
                  context: context,
                  title: "XÓA CHI NHÁNH",
                  message:
                      "Bạn có chắc muốn xóa ${widget.branches[widget.index].name}?",
                  pressButtonLeft: widget.onDeleteBranch,
                  barrierDismissible: true,
                );
              },
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: const BorderSide(
                width: 0.5,
                color: GlobalVariables.primaryColor,
              ),
              bottom: BorderSide(
                width: 0.5,
                color: widget.branches.indexOf(widget.branches[widget.index]) ==
                        widget.branches.length - 1
                    ? GlobalVariables.primaryColor
                    : Colors.transparent,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.branches[widget.index].name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.branches[widget.index].email,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                const Icon(Icons.edit),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
