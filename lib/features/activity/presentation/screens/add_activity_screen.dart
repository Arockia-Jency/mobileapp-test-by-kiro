import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_test_ai/core/validation/activity_validator.dart';
import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_event.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCustomerId;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      // Trigger re-validation if form already attempted
      _formKey.currentState?.validate();
    }
  }

  void _submit(BuildContext context, List<Customer> customers) {
    if (!_formKey.currentState!.validate()) return;

    final id = MockDataSource.instance.nextActivityId();
    final customer = customers.firstWhere((c) => c.id == _selectedCustomerId);

    final activity = Activity(
      id: id,
      customerId: customer.id,
      customerName: customer.fullName,
      title: _titleController.text.trim(),
      dueDate: _selectedDate!,
      status: ActivityStatus.pending,
    );

    context.read<ActivityBloc>().add(ActivityAdded(activity));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = context.watch<CustomerBloc>().state;
    final customers =
        customerState is CustomerLoaded ? customerState.allCustomers : <Customer>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Add Follow-Up Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('activity_title'),
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: ActivityValidator.validateTitle,
              ),
              const SizedBox(height: 16),
              // Due date picker
              FormField<DateTime>(
                key: const Key('activity_due_date'),
                initialValue: _selectedDate,
                validator: (_) => ActivityValidator.validateDueDate(_selectedDate),
                builder: (fieldState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? 'Select Due Date'
                              : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        ),
                      ),
                      if (fieldState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 12),
                          child: Text(
                            fieldState.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('activity_customer_selector'),
                initialValue: _selectedCustomerId,
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select a customer'),
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.fullName),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCustomerId = value),
                validator: ActivityValidator.validateCustomer,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('save_activity_button'),
                onPressed: () => _submit(context, customers),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
