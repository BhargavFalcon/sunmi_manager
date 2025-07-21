import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/table_reservation_screen_controller.dart';

class TableReservationScreenView
    extends GetView<TableReservationScreenController> {
  const TableReservationScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Reservation'), centerTitle: true),
    );
  }
}
