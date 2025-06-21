import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Pages/Animateur/animateur.dart';
import 'package:mediapro/Pages/Home/ProductDetail.dart';
import 'package:mediapro/Pages/Home/home.dart';
import 'package:mediapro/Pages/User/user.dart';

class HomeProduct extends StatefulWidget {
  const HomeProduct({super.key});

  @override
  State<HomeProduct> createState() => _HomeProductState();
}

class _HomeProductState extends State<HomeProduct> {
  int _selectedIndex = 0;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  bool _isCategoryLoading = true;
  String _errorMessage = '';

  final List<Widget> _widgetOptions = [
    Home(),
    Animateur(),
    User(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchProducts();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://back-end-of-mediapro-1.onrender.com/cateproduct/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
          _isCategoryLoading = false;
        });
      } else {
        setState(() {
          _isCategoryLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  Future<void> _fetchProducts({String? categoryId}) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
    });

    try {
      final response = await http.get(
        Uri.parse('https://back-end-of-mediapro-1.onrender.com/product/list'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> allProducts = json.decode(response.body);

        // Filtrer les produits par catégorie si une catégorie est sélectionnée
        List<dynamic> filteredProducts = categoryId != null
            ? allProducts
                .where((product) => product['category'] == categoryId)
                .toList()
            : allProducts;

        setState(() {
          _products = filteredProducts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Erreur de chargement des produits: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur réseau: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: (_selectedIndex == 0)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      title: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFFB993D6), Color(0xFF8CA6DB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          'Product',
                          style: GoogleFonts.lobster(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/animateur.jpg'),
                            radius: 20,
                          ),
                        ),
                      ],
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher un produit...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.search),
                                iconSize: 30,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            'Sélectionnez une catégorie :',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Liste des catégories
                        if (_isCategoryLoading)
                          Center(child: CircularProgressIndicator())
                        else
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  _categories.length + 1, // +1 pour "Tous"
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Option "Tous"
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: ChoiceChip(
                                      label: Text('Tous'),
                                      selected: _selectedCategoryId == null,
                                      onSelected: (selected) {
                                        if (selected) {
                                          _fetchProducts();
                                        }
                                      },
                                    ),
                                  );
                                }

                                final categoryIndex = index - 1;
                                final category = _categories[categoryIndex];

                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0,
                                      right: categoryIndex ==
                                              _categories.length - 1
                                          ? 16.0
                                          : 0),
                                  child: ChoiceChip(
                                    label: Text(category['name'] ??
                                        'Catégorie inconnue'),
                                    selected:
                                        _selectedCategoryId == category['_id'],
                                    onSelected: (selected) {
                                      if (selected) {
                                        _fetchProducts(
                                            categoryId: category['_id']);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            'Produits disponibles :',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : _errorMessage.isNotEmpty
                                  ? Center(child: Text(_errorMessage))
                                  : _products.isEmpty
                                      ? Center(
                                          child:
                                              Text('Aucun produit disponible'))
                                      : GridView.builder(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10.0,
                                            mainAxisSpacing: 10.0,
                                            childAspectRatio: 0.75,
                                          ),
                                          itemCount: _products.length,
                                          itemBuilder: (context, index) {
                                            final product = _products[index];
                                            final imageUrl = product[
                                                        'images'] !=
                                                    null
                                                ? 'https://back-end-of-mediapro-1.onrender.com/uploads/product/${product['images']}'
                                                : 'assets/images/placeholder.jpg';

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailPage(
                                                            productId:
                                                                product['_id']),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 5,
                                                      spreadRadius: 2,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        child:
                                                            imageUrl.startsWith(
                                                                    'http')
                                                                ? Image.network(
                                                                    imageUrl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return Image
                                                                          .asset(
                                                                        'assets/images/placeholder.jpg',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      );
                                                                    },
                                                                  )
                                                                : Image.asset(
                                                                    imageUrl,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            product['name'] ??
                                                                'Nom inconnu',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16.0,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          SizedBox(height: 5.0),
                                                          Center(
                                                            child: Text(
                                                              '\$${product['price']?.toString() ?? '0.00'}',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                )
              : _widgetOptions[_selectedIndex]),
    );
  }
}
