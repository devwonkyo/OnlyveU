import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/store/store_bloc.dart';
import 'package:onlyveyou/blocs/store/store_event.dart';
import 'package:onlyveyou/blocs/store/store_state.dart';

import 'package:onlyveyou/utils/styles.dart';

class PickupOrderInfo extends StatelessWidget {
  const PickupOrderInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                '배송 방법',
                style: AppStyles.headingStyle,
              ),
              const SizedBox(
                width: 15,
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      padding:
                          WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                      minimumSize: WidgetStateProperty.all<Size>(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          '픽업 서비스 안내',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.info_outline,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.05,
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('픽업 매장',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.22,
                    height: MediaQuery.of(context).size.height * 0.04,
                    child: ElevatedButton(
                        onPressed: () {
                          //alertdialog로 firestore에 있는 매장 목록을 가져오고 띄운다?
                          storeModalBottomSheet(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0))),
                        child: const Text(
                          '매장변경',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: Text(
                '아직 선택된 매장이 없습니다',
                style: AppStyles.bodyTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void storeModalBottomSheet(BuildContext context) {
  context.read<StoreBloc>().add(const FetchPickupStore());
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        color: Colors.white,
        height: 600,
        child: Center(child: BlocBuilder<StoreBloc, StoreState>(
          builder: (context, state) {
            if (state is StoreLoading) {
              return const CircularProgressIndicator();
            } else if (state is StoreLoaded) {
              return ListView.builder(
                itemCount: state.stores.length,
                itemBuilder: (context, index) {
                  final store = state.stores[index];
                  return ListTile(
                    title: Text(store.storeName),
                    subtitle: Text(store.address),
                  );
                },
              );
            }
            return const Text('No data available');
          },
        )),
      );
    },
  );
}
