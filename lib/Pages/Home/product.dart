// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mediapro/Pages/Animateur/animateur.dart';
import 'package:mediapro/Pages/Home/ProductDetail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediapro/Pages/Home/home.dart';
import 'package:mediapro/Pages/User/user.dart';
// import '../home/product-detaille.dart'; // Import de l'écran d'inscription

class HomeProduct extends StatefulWidget {
  const HomeProduct({super.key});

  @override
  State<HomeProduct> createState() => _HomeProductState();
}

class _HomeProductState extends State<HomeProduct> {
  int _selectedIndex = 0;

  // List of widgets to display based on the selected index
  final List<Widget> _widgetOptions = [
    Home(),
    Animateur(),
    User(),
  ];

  // Handle bottom navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Définition des routes ici
      routes: {
        '/product-detaille': (context) => ProductDetailPage(),
      },

      home: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mic),
                label: 'Animateur',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Utilisateur',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color.fromARGB(255, 199, 68, 255),
            unselectedItemColor: Colors.grey,
          ),
          body: (_selectedIndex == 0)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Salut',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
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
                                onPressed: () {
                                  // Action lors du clic sur l'icône de recherche
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            'Sélectionnez un type de produit :',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Wrap(
                                  spacing: 10.0,
                                  children: [
                                    ChoiceChip(
                                      label: Text('Électronique'),
                                      selected: false,
                                      onSelected: (bool selected) {
                                        // Action lors de la sélection de ce produit
                                      },
                                    ),
                                    ChoiceChip(
                                      label: Text('Vêtements'),
                                      selected: true,
                                      onSelected: (bool selected) {
                                        // Action lors de la sélection de ce produit
                                      },
                                    ),
                                    ChoiceChip(
                                      label: Text('Maison'),
                                      selected: false,
                                      onSelected: (bool selected) {
                                        // Action lors de la sélection de ce produit
                                      },
                                    ),
                                    ChoiceChip(
                                      label: Text('Sports'),
                                      selected: false,
                                      onSelected: (bool selected) {
                                        // Action lors de la sélection de ce produit
                                      },
                                    ),
                                    ChoiceChip(
                                      label: Text('Beauté'),
                                      selected: false,
                                      onSelected: (bool selected) {
                                        // Action lors de la sélection de ce produit
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          child: GridView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/product-detaille',
                                    arguments:
                                        product, // Passing the product data
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
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
                                              BorderRadius.circular(15.0),
                                          child: Image.asset(
                                            product['image']!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              product['name']!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Center(
                                              child: Text(
                                                product['price']!,
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
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

// Données d'exemple de produits
final List<Map<String, String>> products = [
  {
    'name': 'Produit 1',
    'price': '\$20.00',
    'image': 'assets/images/product.jpg',
  },
  {
    'name': 'Produit 2',
    'price': '\$35.00',
    'image': 'assets/images/product.jpg',
  },
  {
    'name': 'Produit 3',
    'price': '\$50.00',
    'image': 'assets/images/product.jpg',
  },
  {
    'name': 'Produit 4',
    'price': '\$15.00',
    'image': 'assets/images/product.jpg',
  },
];
