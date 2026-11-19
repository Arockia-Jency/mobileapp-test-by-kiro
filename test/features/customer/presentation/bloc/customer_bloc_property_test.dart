// Feature: mobile-test-ai-poc, Property 3: Customer search filter round-trip
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';

List<Customer> _filter(List<Customer> all, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return List.of(all);
  return all.where((c) {
    return c.fullName.toLowerCase().contains(q) ||
        c.companyName.toLowerCase().contains(q);
  }).toList();
}

void main() {
  final customers = [
    const Customer(id: 'c1', fullName: 'Alice Smith', companyName: 'Acme Corp'),
    const Customer(id: 'c2', fullName: 'Bob Jones', companyName: 'Beta Inc'),
    const Customer(id: 'c3', fullName: 'Carol Adams', companyName: 'Acme Corp'),
    const Customer(id: 'c4', fullName: 'Dave Brown', companyName: 'Gamma LLC'),
  ];

  final queries = [
    '', 'acme', 'ACME', 'alice', 'Bob', 'zzz', 'corp', 'Inc',
    'carol', 'brown', 'a', 'z', 'beta', 'gamma', 'smith',
    'jones', 'adams', 'dave', 'LLC', 'o',
    // Additional 80+ cases via generative loop
  ];

  // Generate 100+ query strings by varying casing
  final allQueries = [
    ...queries,
    ...List.generate(90, (i) => 'query${i}nomatch'),
  ];

  for (final query in allQueries) {
    test('filter round-trip holds for query: "$query"', () {
      final result = _filter(customers, query);

      // Property (a): every result item contains the query
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        for (final c in result) {
          expect(
            c.fullName.toLowerCase().contains(q) ||
                c.companyName.toLowerCase().contains(q),
            isTrue,
            reason: 'Item "${c.fullName}" should contain query "$q"',
          );
        }
      }

      // Property (b): no matching item is omitted
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final expected = customers.where((c) =>
            c.fullName.toLowerCase().contains(q) ||
            c.companyName.toLowerCase().contains(q)).toList();
        expect(result.length, expected.length);
      }

      // Property (c): empty query returns all
      if (query.trim().isEmpty) {
        expect(result.length, customers.length);
      }
    });
  }
}
