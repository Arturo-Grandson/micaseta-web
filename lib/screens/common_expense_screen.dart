import 'package:flutter/material.dart';
import 'package:micaseta_web/models/common_expense.dart';
import 'package:micaseta_web/services/common_expenses_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonExpenseScreen extends StatefulWidget {
  const CommonExpenseScreen({super.key});

  @override
  State<CommonExpenseScreen> createState() => _CommonExpenseScreenState();
}

class _CommonExpenseScreenState extends State<CommonExpenseScreen> {
  final commonExpensesService = CommonExpensesService();
  List<CommonExpense> _commonExpense = [];
  bool _isLoading = true;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  String _selectedFestiveType = 'sj';
  final _yearController = '2025';
  final _descriptionController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _dateController = DateTime.now();
  double totalAmount = 0.0;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  String _formatPrice(double totalAmount) {
    return '${totalAmount.toStringAsFixed(2)}€';
  }

  Future<void> _addCommonExpense() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');

      if (boothId == null) {
        throw Exception('No hay Caseta asociada');
      }

      final response = await commonExpensesService.addCommonExpense({
        'festiveType': _selectedFestiveType,
        'year': _yearController,
        'description': _descriptionController.text,
        'totalAmount': double.parse(_totalAmountController.text),
        'boothId': boothId,
        'date': _dateController.toIso8601String(),
      });

      if (response) {
        _descriptionController.clear();
        _totalAmountController.clear();
        _loadCommonExpenses();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showAddCommonExpenseDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Añadir Gastos Comunes'),
                content: Form(
                    key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor añade una descripción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _totalAmountController,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor añade un precio';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Por favor añade un precio válido';
                            }
                            return null;
                          }),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                          value: _selectedFestiveType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de festividad',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'sj',
                              child: Text('San Juan'),
                            ),
                            DropdownMenuItem(
                              value: 'f',
                              child: Text('Feria'),
                            )
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedFestiveType = value;
                              });
                            }
                          })
                    ])),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                      onPressed: _addCommonExpense, child: const Text('Añadir'))
                ]));
  }

  @override
  void initState() {
    super.initState();
    _loadCommonExpenses();
  }

  Future<void> _loadCommonExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boothId = prefs.getInt('boothId');
      final year = DateTime.now().year;

      if (boothId == null) {
        throw Exception('No hay Caseta asociada');
      }

      final commonExpenses =
          await commonExpensesService.getCommonExpenses(boothId, year);
      setState(() {
        _commonExpense = commonExpenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 16),
      ]));
    }

    double totalAmount =
        _commonExpense.fold(0.0, (sum, expense) => sum + expense.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('Total: ${_formatPrice(totalAmount)}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommonExpenseDialog,
        child: const Icon(Icons.add),
      ),
      body: Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _commonExpense.length,
          itemBuilder: (context, index) {
            final expense = _commonExpense[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.monetization_on, color: Colors.white),
                ),
                title: Text(expense.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatPrice(expense.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () => {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
