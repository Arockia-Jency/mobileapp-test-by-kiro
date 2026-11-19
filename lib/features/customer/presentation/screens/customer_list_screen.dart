import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_event.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_state.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const CustomerLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              key: const Key('customer_search'),
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name or company…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
                filled: true,
              ),
              onChanged: (query) {
                context.read<CustomerBloc>().add(CustomerSearchChanged(query));
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading || state is CustomerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (state is CustomerLoaded) {
            final customers = state.displayedCustomers;
            final allEmpty = state.allCustomers.isEmpty;
            final searchEmpty = customers.isEmpty && !allEmpty;

            if (allEmpty) {
              return const Center(
                child: Text(
                  key: Key('empty_list_message'),
                  'No customers are available.',
                ),
              );
            }

            if (searchEmpty) {
              return const Center(
                child: Text(
                  key: Key('no_match_message'),
                  'No customers match your search.',
                ),
              );
            }

            return ListView.separated(
              itemCount: customers.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  key: Key('customer_item_${customer.id}'),
                  title: Text(customer.fullName),
                  subtitle: Text(customer.companyName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/customers/${customer.id}'),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
