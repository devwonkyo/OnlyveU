import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onlyveyou/blocs/auth/auth_bloc.dart';
import 'package:onlyveyou/blocs/auth/auth_event.dart';
import 'package:onlyveyou/blocs/auth/auth_state.dart';

class CartItemsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String appTitle;
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  const CartItemsAppBar({super.key, required this.appTitle});

  @override
  State<CartItemsAppBar> createState() => _CartItemsAppBarState();
}

class _CartItemsAppBarState extends State<CartItemsAppBar> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetUserInfo());
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.appTitle,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  onPressed: () {
                    context.push('/cart');
                  },
                ),
                if (state is LoadedUserCartCount)
                  state.cartItemsCount > 0 ?
                  Positioned(
                    right: 8.w,
                    top: 8.h,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        state.cartItemsCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ) : SizedBox.shrink()
              ],
            ),
          ],
        );
      },
    );
  }
}
