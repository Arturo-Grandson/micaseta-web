import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micaseta_web/models/product.dart';
import 'package:micaseta_web/providers/products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final productsNotifier = ref.read(productsProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, productsNotifier),
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productsNotifier.loadProducts(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (state) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Buscar producto',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: productsNotifier.setSearchQuery,
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'all',
                              label: Text('Todos'),
                              icon: Icon(Icons.all_inclusive),
                            ),
                            ButtonSegment<String>(
                              value: 'food',
                              label: Text('Comida'),
                              icon: Icon(Icons.food_bank),
                            ),
                            ButtonSegment<String>(
                              value: 'drink',
                              label: Text('Bebida'),
                              icon: Icon(Icons.local_drink),
                            ),
                          ],
                          selected: {state.selectedType},
                          onSelectionChanged: (Set<String> newSelection) {
                            productsNotifier
                                .setSelectedType(newSelection.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Icon(
                                product.type == 'drink'
                                    ? Icons.local_drink
                                    : Icons.food_bank,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(product.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatPrice(product.price),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Editar',
                                  onPressed: () => _showEditProductDialog(
                                      context, product, productsNotifier),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.filteredProducts.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, ProductsNotifier notifier) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedProductType = 'drink';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Producto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Por favor ingrese un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedProductType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de producto',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'drink',
                    child: Text('Bebida'),
                  ),
                  DropdownMenuItem(
                    value: 'food',
                    child: Text('Comida'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedProductType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final price = priceController.text.isNotEmpty
                    ? double.parse(priceController.text)
                    : 0.0;

                if (price < 0) {
                  throw Exception('El precio no puede ser negativo');
                }

                await notifier.addProduct({
                  'name': nameController.text,
                  'type': selectedProductType,
                  'price': price,
                });
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(
      BuildContext context, Product product, ProductsNotifier notifier) {
    final editNameController = TextEditingController(text: product.name);
    final editPriceController =
        TextEditingController(text: product.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: editNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: editPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editNameController.text.isEmpty) {
                throw Exception('El nombre del producto no puede estar vacío');
              }

              final newName = editNameController.text;
              final newPrice = double.tryParse(editPriceController.text);

              if (newPrice == null) {
                throw Exception('Por favor, introduce un precio válido');
              }

              if (newPrice < 0) {
                throw Exception('El precio no puede ser negativo');
              }

              try {
                await notifier.editProduct(
                  product.id,
                  newName,
                  newPrice,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(2)}€';
  }
}
