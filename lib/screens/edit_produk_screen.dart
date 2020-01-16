import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/produk.dart';
import '../providers/produks.dart';

class EditProdukScreen extends StatefulWidget {
  static const routeName = '/edit-produk';
  @override
  _EditProdukScreenState createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends State<EditProdukScreen> {
  final _priceFocusNode = FocusNode();
  final _deskripsiFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduk = Produk(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final produkId = ModalRoute.of(context).settings.arguments as String;
      if (produkId != null) {
        _editedProduk =
            Provider.of<Produks>(context, listen: false).findById(produkId);
        _initValues = {
          'title': _editedProduk.title,
          'description': _editedProduk.description,
          'price': _editedProduk.price.toString(),
          // 'imageUrl': _editedProduk.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduk.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _deskripsiFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          _imageUrlController.text.startsWith('http') &&
              _imageUrlController.text.startsWith('https') ||
          _imageUrlController.text.endsWith('.png') &&
              _imageUrlController.text.endsWith('.jpg') &&
              _imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduk.id != null) {
      await Provider.of<Produks>(context, listen: false)
          .updateProduk(_editedProduk.id, _editedProduk);
      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Produks>(context, listen: false)
            .addProduk(_editedProduk);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Ada Sebuah Kesalahan'),
            content: Text('Telah terjadi kesalahan'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Produk'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Nama Dagangan'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Isi dengan nama produk kamu';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduk = Produk(
                          title: value,
                          price: _editedProduk.price,
                          description: _editedProduk.description,
                          imageUrl: _editedProduk.imageUrl,
                          id: _editedProduk.id,
                          isFavorite: _editedProduk.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Harga'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_deskripsiFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Isi harga yang akan dijual dan jangan dikosongkan';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Isi dengan nominal yang valid';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Jangan isi dengan nominal kosong';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduk = Produk(
                          title: _editedProduk.title,
                          price: double.parse(value),
                          description: _editedProduk.description,
                          imageUrl: _editedProduk.imageUrl,
                          id: _editedProduk.id,
                          isFavorite: _editedProduk.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Deskripsi'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _deskripsiFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Jangan dikosongkan';
                        }
                        if (value.length > 300) {
                          return 'Hanya bisa menampung kurang dari 300 kata';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduk = Produk(
                          title: _editedProduk.title,
                          price: _editedProduk.price,
                          description: value,
                          imageUrl: _editedProduk.imageUrl,
                          id: _editedProduk.id,
                          isFavorite: _editedProduk.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 80,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Masukkan URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Isi dengan nama produk kamu';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Masukkan Url yang benar';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Masukkan image url yang benar';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduk = Produk(
                                title: _editedProduk.title,
                                price: _editedProduk.price,
                                description: _editedProduk.description,
                                imageUrl: value,
                                id: _editedProduk.id,
                                isFavorite: _editedProduk.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
