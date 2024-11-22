import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/mypage/profile_edit/profile_edit_event.dart';
import 'package:onlyveyou/models/extensions/product_model_extension.dart';
import 'package:onlyveyou/screens/special/debate/chat/chat_model.dart';

import '../../../blocs/home/home_bloc.dart';
import '../../../blocs/mypage/profile_edit/profile_edit_bloc.dart';
import '../../../blocs/mypage/profile_edit/profile_edit_state.dart';
import '../../../models/product_model.dart';
import 'chat/bloc/chat_bloc.dart';
import 'vote/bloc/vote_bloc.dart';

class DebateScreen extends StatefulWidget {
  const DebateScreen({super.key});

  @override
  State<DebateScreen> createState() => _DebateScreenState();
}

class _DebateScreenState extends State<DebateScreen> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    context.read<VoteBloc>().add(LoadVotes());
    context.read<ProfileBloc>().add(LoadProfileImage());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('=====$runtimeType=====');
    return BlocListener<VoteBloc, VoteState>(
      listener: (context, state) {
        if (state is VoteError) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('확인'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('VS 투표', style: TextStyle(color: Colors.black87)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              _buildVoteBar(),
              _buildProductComparison(),
              Expanded(child: _buildChatSection(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoteBar() {
    return BlocBuilder<VoteBloc, VoteState>(
      builder: (context, state) {
        print(state);
        if (state is VotesLoaded) {
          final product1Votes =
              state.votes.where((vote) => vote.productId == 'product1').length;
          final product2Votes =
              state.votes.where((vote) => vote.productId == 'product2').length;
          final totalVotes = product1Votes + product2Votes;
          final product1Percentage =
              totalVotes == 0 ? 0 : (product1Votes / totalVotes) * 100;
          final product2Percentage =
              totalVotes == 0 ? 0 : (product2Votes / totalVotes) * 100;

          return Container(
            height: 40.h,
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: product1Percentage.toInt(), // Left product percentage
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade300],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${product1Percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: product2Percentage.toInt(), // Right product percentage
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [Colors.red.shade300, Colors.red.shade400],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${product2Percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildProductComparison() {
    return BlocSelector<HomeBloc, HomeState, List<ProductModel>>(
      selector: (state) => state is HomeLoaded ? state.popularProducts : [],
      builder: (context, products) {
        return Container(
          height: 250.h, // Reduced from 280.h
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                  child: _buildProductCard(
                      context: context, isLeft: true, product: products.first)),
              SizedBox(
                width: 30.w, // Reduced from 40.w
                child: Center(
                  child: Container(
                    width: 30.w, // Reduced from 40.w
                    height: 30.w, // Reduced from 40.w
                    decoration: const BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp, // Reduced from 16.sp
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: _buildProductCard(
                      context: context, isLeft: false, product: products.last)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
      {required BuildContext context,
      required bool isLeft,
      required ProductModel product}) {
    // 가격 포맷팅 메서드 추가
    String formatPrice(String price) {
      try {
        return price.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      } catch (e) {
        return '0';
      }
    }

    return GestureDetector(
      onTap: () {
        context.push("/product-detail", extra: product.productId);
      },
      child: Card(
        elevation: 2, // Reduced from 4
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                height: 120.h, // Reduced from 160.h
                color: Colors.grey.shade100,
                child: Image.network(
                  product.productImageList.first,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w), // Reduced from 12.w
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14.sp, // Reduced from 16.sp
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1, // Reduced from 2
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h), // Reduced from 4.h
                  Row(
                    children: [
                      Text(
                        '${product.discountPercent}%',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp, // Reduced from 14.sp
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w), // Reduced from 8.w
                      Text(
                        '₩${formatPrice(product.discountedPrice.toString())}',
                        style: TextStyle(
                          fontSize: 12.sp, // Reduced from 14.sp
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₩${formatPrice(product.price)}',
                    style: TextStyle(
                      fontSize: 10.sp, // Reduced from 12.sp
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  SizedBox(
                    width: 150.w,
                    height: 40.h,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        _showVoteDialog(context, isLeft);
                      },
                      label: const Text('투표하기'),
                      icon: const Icon(Icons.how_to_vote),
                      backgroundColor: isLeft ? Colors.blue : Colors.red,
                      heroTag: isLeft ? 'voteButtonLeft' : 'voteButtonRight',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoteDialog(BuildContext context, bool isLeft) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('투표하기'),
          content: const Text('한번만 투표할 수 있습니다. 정말로 투표하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _submitVote(context, isLeft ? 'product1' : 'product2');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _submitVote(BuildContext context, String productId) {
    context.read<VoteBloc>().add(SubmitVote(productId: productId));
    Navigator.of(context).pop();
  }

  Widget _buildChatSection(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  reverse: true, // 새 메시지가 아래에서 위로 쌓임
                  itemCount: state.chats.length,
                  itemBuilder: (context, index) {
                    final chat = state.chats[index];
                    final profileImageUrl = chat.profileImageUrl;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : null,
                            child: profileImageUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                chat.msg,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileImageUrlLoaded) {
                    return IconButton(
                      onPressed: () {
                        print("msg: ${controller.text}");
                        if (controller.text.trim().isNotEmpty) {
                          final chat = ChatModel(
                            profileImageUrl: state.imageUrl,
                            msg: controller.text,
                            timestamp: Timestamp.now(),
                          );
                          controller.clear();
                          context.read<ChatBloc>().add(SendChat(chat: chat));
                        }
                        FocusScope.of(context).unfocus();
                      },
                      icon: const Icon(Icons.send, color: Colors.blue),
                    );
                  } else {
                    return IconButton(
                      onPressed: () {
                        print("msg: ${controller.text}");
                        if (controller.text.trim().isNotEmpty) {
                          final chat = ChatModel(
                            profileImageUrl: '',
                            msg: controller.text,
                            timestamp: Timestamp.now(),
                          );
                          controller.clear();
                          context.read<ChatBloc>().add(SendChat(chat: chat));
                        }
                        FocusScope.of(context).unfocus();
                      },
                      icon: const Icon(Icons.send, color: Colors.blue),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
