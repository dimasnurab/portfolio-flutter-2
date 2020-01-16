import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/cart_screen.dart';
import './screens/produk_screen.dart';
import './screens/produk_detail_screen.dart';
import './screens/splash_screen.dart';
import './providers/produks.dart';
import './providers/cart.dart';
import './providers/order.dart';
import './providers/auth.dart';
import './screens/order_screen.dart';
import './screens/user_produk_screen.dart';
import './screens/edit_produk_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Produks>(
          builder: (ctx, auth, previousProduks) => Produks(
              auth.token,
              auth.userId,
              previousProduks == null ? [] : previousProduks.items),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.green,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProdukScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (
                    ctx,
                    authResultSnapshot,
                  ) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProdukDetailsScreen.routeName: (ctx) => ProdukDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProdukScreen.routeName: (ctx) => UserProdukScreen(),
            EditProdukScreen.routeName: (ctx) => EditProdukScreen(),
          },
        ),
      ),
    );
  }
}
