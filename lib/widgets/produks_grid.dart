import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produks.dart';
import './produk_item.dart';

class ProduksGrid extends StatelessWidget {
  final bool showFavs;

  ProduksGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final produksData = Provider.of<Produks>(context);
    final produks = showFavs ? produksData.favoriteItems : produksData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: produks.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: produks[i],
        // builder: (c) => produks[i],
        child: ProdukItem(
            // produks[i].id,
            // produks[i].title,
            // produks[i].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1 / 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
    );
  }
}
