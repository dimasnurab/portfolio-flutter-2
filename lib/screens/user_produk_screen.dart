import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produks.dart';
import '../widgets/user_produk_item.dart';
import '../widgets/app_drawer.dart';
import './edit_produk_screen.dart';

class UserProdukScreen extends StatelessWidget {
  static const routeName = '/user-produks';

  Future<void> _refreshProduk(BuildContext context) async {
    await Provider.of<Produks>(context, listen: false).fetchAndSetProduk(true);
  }

  @override
  Widget build(BuildContext context) {
    // final produksData = Provider.of<Produks>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk Kamu'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProdukScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduk(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduk(context),
                    child: Consumer<Produks>(
                      builder: (ctx, produksData, _) => Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView.builder(
                          itemCount: produksData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProdukItem(
                                produksData.items[i].id,
                                produksData.items[i].title,
                                produksData.items[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
