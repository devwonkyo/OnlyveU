import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/store/store_bloc.dart';
import 'package:onlyveyou/blocs/store/store_event.dart';
import 'package:onlyveyou/blocs/store/store_state.dart';
import 'package:onlyveyou/config/color.dart';
import 'package:onlyveyou/models/store_model.dart';

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
          BlocBuilder<StoreBloc, StoreState>(
            builder: (context, state) {
              if (state is StoreSelected) {
                final selectedStore = state.selectedStore;

                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Image.network(
                        selectedStore.imageUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedStore.storeName,
                              style: AppStyles.headingStyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              selectedStore.address,
                              style: AppStyles.bodyTextStyle,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                ),
                                Text(
                                  selectedStore.phone,
                                  style: AppStyles.bodyTextStyle,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              "영업시간 ${selectedStore.businessHours}",
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        selectedStore.isActive
                            ? const Text(
                                '영업중',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                ),
                              )
                            : const Text(
                                '영업종료',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                ),
                              ),
                      ],
                    ),
                  ],
                );
              } else {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Center(
                    child: Text(
                      '아직 선택된 매장이 없습니다',
                      style: AppStyles.bodyTextStyle,
                    ),
                  ),
                );
              }
            },
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
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // 선택한 store를 checkStoreDialog로 전달
                        checkStoreDialog(context, store);
                      },

                      child: ListTile(
                        title: Text(store.storeName),
                        subtitle: Text(store.address),
                        trailing: Text(store.phone),
                      ), // 클릭 시 강조 효과 색상
                    ),
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

void checkStoreDialog(BuildContext context, StoreModel store) {
  showDialog(
      context: context,
      //barrierDismissible - Dialog를 제외한 다른 화면 터치 x

      builder: (BuildContext context) {
        return AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //Dialog Main Title
          title: Column(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "픽업 서비스 안내",
                    style: AppStyles.headingStyle,
                  ),
                  Divider(height: 1, color: Colors.grey[300])
                ],
              ),
            ],
          ),
          //
          content:
              BlocBuilder<StoreBloc, StoreState>(builder: (context, state) {
            if (state is StoreLoading) {
              return const CircularProgressIndicator();
            } else if (state is StoreLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      text: store.storeName,
                      style: const TextStyle(
                        color: AppsColor.pastelGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "으로 픽업하시겠습니까?",
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                //모서리를 둥글게
                                borderRadius: BorderRadius.circular(0)),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: ElevatedButton(
                          onPressed: () {
                            //해당 매장 선택되게 해야한다.
                            context.read<StoreBloc>().add(SelectStore(store));
                            context.pop();
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppsColor.pastelGreen,
                            shape: RoundedRectangleBorder(
                                //모서리를 둥글게
                                borderRadius: BorderRadius.circular(0)),
                          ),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Text('No data available');
          }),
        );
      });
}
