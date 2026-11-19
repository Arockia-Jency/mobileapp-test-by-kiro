import 'package:equatable/equatable.dart';

enum ActivityStatus { pending, done }

class Activity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final DateTime dueDate;
  final ActivityStatus status;

  const Activity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.dueDate,
    required this.status,
  });

  Activity copyWith({ActivityStatus? status}) {
    return Activity(
      id: id,
      customerId: customerId,
      customerName: customerName,
      title: title,
      dueDate: dueDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, customerId, customerName, title, dueDate, status];
}
