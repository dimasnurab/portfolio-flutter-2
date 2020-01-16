import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produks.dart';

class ProdukDetailsScreen extends StatelessWidget {
  // final double price;
  // final String title;

  // ProdukDetailsScreen(
  //   this.title,
  //   this.price
  // );
  static const routeName = '/produk-detail';

  @override
  Widget build(BuildContext context) {
    final produkId =
        ModalRoute.of(context).settings.arguments as String; // mengambil id
    final loadedProduk = Provider.of<Produks>(
      context,
      listen: false,
    ).findById(produkId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduk.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduk.title),
              background: Hero(
                tag: loadedProduk.id,
                child: Image.network(
                  loadedProduk.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'IDR. ${loadedProduk.price.toStringAsFixed(3)}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduk.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
