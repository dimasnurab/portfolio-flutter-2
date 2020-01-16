import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './produk.dart';

class Produks with ChangeNotifier {
  List<Produk> _items = [
    // Produk(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 50.000,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Produk(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 250.000,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Produk(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 100.000,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Produk(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 100.000,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String authToken;
  final String userId;

  Produks(this.authToken, this.userId, this._items);
  // var _showFavoritesOnly = false;
  List<Produk> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Produk> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Produk findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProduk([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'order"creatorId"&equalTo="$userId"' : '';
    var url =
        'https://updatewarung-ff0a3.firebaseio.com/produks.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://updatewarung-ff0a3.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Produk> loadedProduks = [];
      extractedData.forEach((prodId, prodData) {
        loadedProduks.add(Produk(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProduks;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduk(Produk produk) async {
    final url =
        'https://updatewarung-ff0a3.firebaseio.com/produks.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': produk.title,
          'description': produk.description,
          'imageUrl': produk.imageUrl,
          'price': produk.price,
          'creatorId': userId,
        }),
      );
      final newProduk = Produk(
        title: produk.title,
        description: produk.description,
        price: produk.price,
        imageUrl: produk.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduk);
      // _items.insert(0, newProduk);// dimulai dari list
      notifyListeners();
      // notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduk(String id, Produk newProduk) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://updatewarung-ff0a3.firebaseio.com/produks/$id.json?auth=$authToken';

      await http.patch(url,
          body: json.encode({
            'title': newProduk.title,
            'description': newProduk.description,
            'imageUrl': newProduk.imageUrl,
            'price': newProduk.price,
          }));
      _items[prodIndex] = newProduk;
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> deleteProduk(String id) async {
    final url =
        'https://updatewarung-ff0a3.firebaseio.com/produks/$id.json?auth=$authToken';
    final existingProdukIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduk = _items[existingProdukIndex];
    _items.removeAt(existingProdukIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProdukIndex, existingProduk);
      notifyListeners();
      throw HttpException('Produk tidak bisa dihapus');
    }
    existingProduk = null;
  }
}
