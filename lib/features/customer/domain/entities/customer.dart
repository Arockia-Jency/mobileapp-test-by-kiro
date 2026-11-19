import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String fullName;
  final String companyName;
  final String? email;
  final String? phoneNumber;
  final String? notes;

  const Customer({
    required this.id,
    required this.fullName,
    required this.companyName,
    this.email,
    this.phoneNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [id, fullName, companyName, email, phoneNumber, notes];
}
