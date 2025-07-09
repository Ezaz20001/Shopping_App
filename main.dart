import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter email'
                                    : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.length < 6
                                    ? 'Minimum 6 characters'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          }
                        },
                        child: const Text('Sign In'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to register page
                        },
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Product> _cartItems = [];

  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  double _calculateTotal() =>
      _cartItems.fold(0, (sum, item) => sum + item.price);

  void _showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Shopping Cart'),
            content:
                _cartItems.isEmpty
                    ? const Text('Your cart is empty')
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ..._cartItems.map(
                          (item) => ListTile(
                            leading: Image.network(
                              item.image,
                              width: 40,
                              height: 40,
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              '\\${item.price.toStringAsFixed(2)}',
                            ),
                          ),
                        ),
                        const Divider(),
                        Text(
                          'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text('Confirm Purchase'),
                                        content: Text(
                                          'Proceed with payment of \$${_calculateTotal().toStringAsFixed(2)}?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _clearCart();
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Order placed successfully!',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: const Text('Checkout'),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanel()),
                ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCartDialog(context),
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    child: Text(_cartItems.length.toString()),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: const [_BannerSection(), Expanded(child: ProductCatalog())],
      ),
    );
  }
}

class Product {
  final String name;
  final String image;
  final String description;
  final double price;

  Product({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
  });
}

class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eid Mubarak!',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
            Text(
              'Up to 50% off',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCatalog extends StatelessWidget {
  const ProductCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    addToCart(Product product) {
      // Access using context.findAncestorStateOfType
      final state = context.findAncestorStateOfType<_HomeScreenState>();
      state?._addToCart(product);
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('products')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading products'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products =
            snapshot.data!.docs.map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return Product(
                name: data['name'] ?? 'Unnamed',
                image: data['image'] ?? '',
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                description: data['description'] ?? '',
              );
            }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder:
              (context, index) =>
                  _ProductItem(product: products[index], addToCart: addToCart),
        );
      },
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;
  final void Function(Product) addToCart;

  const _ProductItem({required this.product, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ProductDetails(product: product, addToCart: addToCart),
            ),
          ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder:
                      (_, __, ___) => const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final Product product;
  final void Function(Product) addToCart;

  const ProductDetails({
    super.key,
    required this.product,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              product.image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, color: Colors.green),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(product.description),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Add to Cart'),
                      onPressed: () {
                        addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added ${product.name} to cart'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;
    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,
      'price': double.parse(_priceController.text),
      'image': _imageController.text,
      'description': _descController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameController.clear();
    _priceController.clear();
    _imageController.clear();
    _descController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product created successfully')),
    );
  }

  Future<void> _deleteProduct(String docId) async {
    try {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Delete Product'),
              content: const Text(
                'Are you sure you want to delete this product?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(docId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Delete error: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Product', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createProduct,
                    child: const Text('Create Product'),
                  ),
                  const Divider(height: 40),
                  const Text(
                    'Existing Products',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('products')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading products'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data()! as Map<String, dynamic>;
                      return ListTile(
                        leading: Image.network(
                          data['image'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.error),
                        ),
                        title: Text(data['name'] ?? 'Unnamed'),
                        subtitle: Text(
                          '\$${(data['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(doc.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
