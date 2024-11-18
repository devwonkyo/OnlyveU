import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_bloc.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_event.dart';
import 'package:onlyveyou/blocs/mypage/order_status/order_status_state.dart';

Widget _buildStatusDropdown(BuildContext context) {
  return BlocBuilder<OrderStatusBloc, OrderStatusState>(
    builder: (context, state) {
      List<String> statusOptions = [];
      String? selectedStatus;

      if (state is OrderStatusInitial) {
        statusOptions = state.statusOptions;
        selectedStatus = state.selectedStatus;
      } else if (state is PurchaseTypeSelected) {
        statusOptions = state.statusOptions;
        selectedStatus = state.statusOptions[0]; // 기본값 설정
      } else if (state is StatusSelected) {
        statusOptions = state.statusOptions;
        selectedStatus = state.selectedStatus;
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          items: statusOptions
              .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
              .toList(),
          value: selectedStatus,
          onChanged: (value) {
            if (value != null) {
              context.read<OrderStatusBloc>().add(SelectStatus(value));
            }
          },
          buttonStyleData: const ButtonStyleData(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
