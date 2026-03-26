import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:managerapp/app/constants/color_constant.dart';
import 'package:managerapp/app/constants/sizeConstant.dart';
import 'package:managerapp/app/constants/translation_keys.dart';
import 'package:managerapp/app/model/customer_list_model.dart';
import 'package:managerapp/app/modules/reservation_screen/controllers/reservation_screen_controller.dart';
import 'shared/common_text_field.dart';

class CustomerSearchFieldsWidget extends StatelessWidget {
  const CustomerSearchFieldsWidget({
    super.key,
    required this.controller,
    required this.onShowCountryPicker,
  });

  final ReservationScreenController controller;
  final VoidCallback onShowCountryPicker;

  static TextStyle _fieldLabelStyle() => TextStyle(
    fontSize: MySize.getHeight(13),
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static BoxDecoration _textFieldDecoration(bool readOnly) => BoxDecoration(
    color: readOnly ? Colors.grey.shade100 : Colors.white,
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(MySize.getHeight(8)),
  );

  Widget _buildLabel(String text) {
    return Text(text, style: _fieldLabelStyle());
  }

  Widget _buildTextField({
    required TextEditingController textController,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return CommonTextField(
      controller: textController,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
      placeholder: hint,
    );
  }

  Widget _buildCustomerResultTile(CustomerListItem customer) {
    final initial =
        (customer.name?.isNotEmpty == true)
            ? (customer.name!.substring(0, 1).toUpperCase())
            : '?';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectReservationCustomer(customer),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MySize.getWidth(8),
            vertical: MySize.getHeight(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: MySize.getHeight(14),
                backgroundColor: ColorConstants.primaryColor.withValues(
                  alpha: 0.85,
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MySize.getHeight(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: MySize.getWidth(8)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customer.name ?? '',
                      style: TextStyle(
                        fontSize: MySize.getHeight(13),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: MySize.getHeight(2)),
                    Row(
                      children: [
                        if (customer.email != null &&
                            customer.email!.isNotEmpty) ...[
                          Icon(
                            Icons.mail_outline,
                            size: MySize.getHeight(12),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: MySize.getWidth(4)),
                          Expanded(
                            child: Text(
                              customer.email!,
                              style: TextStyle(
                                fontSize: MySize.getHeight(11),
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.phoneNumber != null &&
                              customer.phoneNumber!.isNotEmpty)
                            SizedBox(width: MySize.getWidth(8)),
                        ],
                        if (customer.phoneNumber != null &&
                            customer.phoneNumber!.isNotEmpty) ...[
                          Icon(
                            Icons.phone_outlined,
                            size: MySize.getHeight(12),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: MySize.getWidth(4)),
                          Expanded(
                            child: Text(
                              customer.phoneNumber!,
                              style: TextStyle(
                                fontSize: MySize.getHeight(11),
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildLabel('${TranslationKeys.customerName.tr} *'),
            ),
            Obx(() {
              if (!controller.isReservationCustomerSelected) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: controller.clearReservationCustomer,
                child: Padding(
                  padding: EdgeInsets.all(MySize.getWidth(4)),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: MySize.getHeight(12),
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        SizedBox(height: MySize.getHeight(6)),
        Container(
          key: controller.reservationNameFieldKey,
          child: _buildTextField(
            textController: controller.customerNameController,
            hint: TranslationKeys.enterCustomerName.tr,
            keyboardType: TextInputType.name,
            readOnly: false,
            focusNode: controller.reservationNameFocusNode,
          ),
        ),
        Obx(() {
          if (controller.isReservationCustomerSelected) {
            return const SizedBox.shrink();
          }
          if (controller.customerSearchResults.isEmpty &&
              !controller.isCustomerSearching.value) {
            return const SizedBox.shrink();
          }
          return Container(
            margin: EdgeInsets.only(top: MySize.getHeight(4)),
            constraints: BoxConstraints(maxHeight: MySize.getHeight(200)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(MySize.getHeight(8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                controller.isCustomerSearching.value &&
                        controller.customerSearchResults.isEmpty
                    ? Padding(
                      padding: EdgeInsets.all(MySize.getHeight(16)),
                      child: const Center(
                        child: CupertinoActivityIndicator(radius: 10),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                        vertical: MySize.getHeight(6),
                      ),
                      itemCount: controller.customerSearchResults.length,
                      itemBuilder: (context, index) {
                        final customer =
                            controller.customerSearchResults[index];
                        return _buildCustomerResultTile(customer);
                      },
                    ),
          );
        }),
        SizedBox(height: MySize.getHeight(12)),
        _buildLabel('${TranslationKeys.customerPhone.tr} *'),
        SizedBox(height: MySize.getHeight(6)),
        Obx(
          () => Container(
            key: controller.reservationPhoneFieldKey,
            decoration: _textFieldDecoration(
              controller.isReservationCustomerSelected ||
                  controller.isEditingReservation,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                      controller.isReservationCustomerSelected ||
                              controller.isEditingReservation
                          ? null
                          : onShowCountryPicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MySize.getWidth(12),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.selectedCountryFlag.value,
                            style: TextStyle(fontSize: MySize.getHeight(18)),
                          ),
                          SizedBox(width: MySize.getWidth(4)),
                          Text(
                            controller.selectedCountryCode.value,
                            style: TextStyle(
                              fontSize: MySize.getHeight(12),
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => CommonTextField(
                      controller: controller.customerPhoneController,
                      focusNode: controller.reservationPhoneFocusNode,
                      keyboardType: TextInputType.phone,
                      readOnly: controller.isReservationCustomerSelected ||
                          controller.isEditingReservation,
                      onChanged: controller.validatePhone,
                      placeholder: TranslationKeys.enterPhoneNumber.tr,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: MySize.getWidth(12),
                        vertical: MySize.getHeight(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MySize.getHeight(12)),
        _buildLabel(TranslationKeys.customerEmail.tr),
        SizedBox(height: MySize.getHeight(6)),
        Obx(
          () => _buildTextField(
            textController: controller.customerEmailController,
            hint: TranslationKeys.enterCustomerEmail.tr,
            keyboardType: TextInputType.emailAddress,
            readOnly: controller.isReservationCustomerSelected ||
                controller.isEditingReservation,
          ),
        ),
      ],
    );
  }
}
