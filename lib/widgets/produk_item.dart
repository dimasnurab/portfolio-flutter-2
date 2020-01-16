import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/produk_detail_screen.dart';
import '../providers/produk.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProdukItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProdukItem(
  //   this.id,
  //   this.title,
  //   this.imageUrl,
  // );

  @override
  Widget build(BuildContext context) {
    final produk = Provider.of<Produk>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProdukDetailsScreen.routeName, arguments: produk.id);
          },
          child: Hero(
            tag: produk.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(produk.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black,
          title: Text(
            produk.title,
            textAlign: TextAlign.start,
          ),
          trailing: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () {
                  cart.addItem(produk.id, produk.price, produk.title);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Produk ditambahkan ke keranjang'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(produk.id);
                        },
                      ),
                    ),
                  );
                },
              ),
              Consumer<Produk>(
                builder: (ctx, produk, _) => IconButton(
                  icon: Icon(
                    produk.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () {
                    produk.toogleFavoriteStatus(
                        authData.token, authData.userId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
