import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:micaseta_web/services/product_service.dart';
import 'package:micaseta_web/providers/penalties_provider.dart';

class PartnerDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> partner;
  const PartnerDetailScreen({super.key, required this.partner});

  @override
  ConsumerState<PartnerDetailScreen> createState() =>
      _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends ConsumerState<PartnerDetailScreen> {
  List<dynamic> _consumptions = [];
  bool _loadingConsumptions = true;
  String? _consumptionError;

  @override
  void initState() {
    super.initState();
    _loadConsumptions();
    // Cargar las sanciones usando el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(penaltiesProvider.notifier).loadPenalties(widget.partner['id']);
    });
  }

  Future<void> _loadConsumptions() async {
    setState(() {
      _loadingConsumptions = true;
      _consumptionError = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');
      if (boothId == null) throw Exception('No hay boothId asociado');
      final consumptions =
          await ProductService().getConsumptions(widget.partner['id'], boothId);
      if (!mounted) return;
      setState(() {
        _consumptions = consumptions;
        _loadingConsumptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _consumptionError = e.toString();
        _loadingConsumptions = false;
      });
    }
  }

  void _showAddPenaltyDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String festiveType = 'sj';
    int year = DateTime.now().year;
    double amount = 0;
    String reason = '';
    DateTime date = DateTime.now();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    final dateController =
        TextEditingController(text: date.toIso8601String().substring(0, 10));

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Sanción'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: festiveType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de fiesta',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'sj', child: Text('San Juan')),
                  DropdownMenuItem(value: 'f', child: Text('Feria')),
                ],
                onChanged: (value) {
                  if (value != null) festiveType = value;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: year.toString(),
                decoration: const InputDecoration(
                  labelText: 'Año',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => year = int.tryParse(v) ?? year,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (€)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Introduce una cantidad' : null,
                onChanged: (v) => amount = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motivo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Introduce un motivo' : null,
                onChanged: (v) => reason = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    date = picked;
                    dateController.text =
                        date.toIso8601String().substring(0, 10);
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
              final prefs = await SharedPreferences.getInstance();
              final boothId = prefs.getInt('boothId');
              if (!mounted) return;
              if (boothId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No hay boothId asociado'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              final penaltyData = {
                'festiveType': festiveType,
                'year': year,
                'amount': amount,
                'reason': reason,
                'date': dateController.text,
                'userId': widget.partner['id'],
                'boothId': boothId,
              };

              try {
                await ref
                    .read(penaltiesProvider.notifier)
                    .addPenalty(penaltyData);
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sanción añadida correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
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

  String _festiveTypeLabel(dynamic value) {
    if (value == 'sj' || value == 'SJ') return 'San Juan';
    if (value == 'f' || value == 'F') return 'Feria';
    return value.toString();
  }

  Widget _buildConsumptionsList(
      List<dynamic> consumptions, String festiveType) {
    final currentYear = DateTime.now().year;
    final filteredConsumptions = consumptions
        .where(
            (c) => c['festiveType'] == festiveType && c['year'] == currentYear)
        .toList();

    if (filteredConsumptions.isEmpty) {
      return const Center(
          child: Text('No hay consumiciones para este tipo de fiesta'));
    }

    double totalAmount = 0;
    for (var c in filteredConsumptions) {
      final price = double.parse(c['product']['price']['price']);
      totalAmount += price * c['quantity'];
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${totalAmount.toStringAsFixed(2)}€ Esta suma no es exacta debido a que puede haber productos que aun no tienen precio',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label:
                    Text('Enviar desglose ${_festiveTypeLabel(festiveType)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final boothId = prefs.getInt('boothId');
                    if (boothId == null) {
                      throw Exception('No hay boothId asociado');
                    }

                    final success =
                        await ProductService().sendConsumptionsEmail(
                      widget.partner['id'],
                      boothId,
                      festiveType,
                    );

                    if (!mounted) return;
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Desglose de ${_festiveTypeLabel(festiveType)} enviado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al enviar el desglose'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredConsumptions.length,
            itemBuilder: (context, index) {
              final c = filteredConsumptions[index];
              final price = double.parse(c['product']['price']['price']);
              final total = price * c['quantity'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    c['product']['type'] == 'drink'
                        ? Icons.local_drink
                        : Icons.food_bank,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(c['product']['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${c['quantity']}'),
                      Text('Precio unitario: ${price.toStringAsFixed(2)}€'),
                      Text('Total: ${total.toStringAsFixed(2)}€'),
                      Text('Fecha: ${c['date'].toString().substring(0, 10)}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final penaltiesAsync = ref.watch(penaltiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Socio'),
      ),
      body: Column(
        children: [
          // Información del socio
          Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.partner['name'] != null &&
                              widget.partner['name'].isNotEmpty
                          ? widget.partner['name'][0].toUpperCase()
                          : '',
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(
                      '${widget.partner['name']} ${widget.partner['lastname']}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: Text(
                      widget.partner['email'] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.blue),
                    title: Text(
                      widget.partner['phone'] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pestañas
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'San Juan'),
                      Tab(text: 'Feria'),
                      Tab(text: 'Sanciones'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Pestaña de San Juan
                        if (_loadingConsumptions)
                          const Center(child: CircularProgressIndicator())
                        else if (_consumptionError != null)
                          Center(
                              child: Text(_consumptionError!,
                                  style: const TextStyle(color: Colors.red)))
                        else
                          _buildConsumptionsList(_consumptions, 'sj'),
                        // Pestaña de Feria
                        if (_loadingConsumptions)
                          const Center(child: CircularProgressIndicator())
                        else if (_consumptionError != null)
                          Center(
                              child: Text(_consumptionError!,
                                  style: const TextStyle(color: Colors.red)))
                        else
                          _buildConsumptionsList(_consumptions, 'f'),
                        // Pestaña de Sanciones
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Sanciones',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Añadir Sanción'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        _showAddPenaltyDialog(context),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: penaltiesAsync.when(
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Center(
                                  child: Text(
                                    error.toString(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                data: (penalties) => penalties.isEmpty
                                    ? const Center(
                                        child: Text(
                                            'No hay sanciones para este socio.'))
                                    : ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        itemCount: penalties.length,
                                        itemBuilder: (context, index) {
                                          final p = penalties[index];
                                          return Card(
                                            color: Colors.red[50],
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: ListTile(
                                              leading: const Icon(Icons.warning,
                                                  color: Colors.red),
                                              title: Text(
                                                  '${_festiveTypeLabel(p.festiveType)} - ${p.year}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Cantidad: ${p.amount} €'),
                                                  Text('Motivo: ${p.reason}'),
                                                  Text('Fecha: ${p.date}'),
                                                ],
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                tooltip: 'Eliminar sanción',
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text(
                                                          'Eliminar sanción'),
                                                      content: const Text(
                                                          '¿Seguro que quieres eliminar esta sanción?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false),
                                                          child: const Text(
                                                              'Cancelar'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red),
                                                          child: const Text(
                                                              'Eliminar'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  if (confirm == true) {
                                                    await ref
                                                        .read(penaltiesProvider
                                                            .notifier)
                                                        .deletePenalty(
                                                            p.id,
                                                            widget
                                                                .partner['id']);
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
