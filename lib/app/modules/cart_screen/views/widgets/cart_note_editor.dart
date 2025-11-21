import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import '../../controllers/cart_screen_controller.dart';

class CartNoteEditor extends StatefulWidget {
  final String itemId;

  const CartNoteEditor({super.key, required this.itemId});

  @override
  State<CartNoteEditor> createState() => _CartNoteEditorState();
}

class _CartNoteEditorState extends State<CartNoteEditor> {
  late TextEditingController _controller;
  late CartScreenController _controllerGet;

  @override
  void initState() {
    super.initState();
    _controllerGet = Get.find<CartScreenController>();
    final item = _controllerGet.cartItems.firstWhere(
      (e) => e.cartItemId == widget.itemId,
    );
    final String initialText = item.cartNoteDraft ?? item.cartNote ?? '';
    _controller = TextEditingController(text: initialText);
  }

  @override
  void didUpdateWidget(covariant CartNoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemId != widget.itemId) {
      final item = _controllerGet.cartItems.firstWhere(
        (e) => e.cartItemId == widget.itemId,
      );
      final String text = item.cartNoteDraft ?? item.cartNote ?? '';
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(fontSize: MySize.getHeight(12)),
              decoration: const InputDecoration(
                hintText:
                    'Special Instructions? (e.g., no onions, extra spicy)',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged:
                  (v) => _controllerGet.updateNoteDraft(widget.itemId, v),
              onSubmitted: (_) => _controllerGet.saveNote(widget.itemId),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _controllerGet.saveNote(widget.itemId),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _controllerGet.cancelEditingNote(widget.itemId),
            child: Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, color: Colors.black54, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
