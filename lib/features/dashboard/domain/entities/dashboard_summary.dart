import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final bool isCheckedInToday;
  final String? checkInTimeFormatted;
  final int totalCustomers;
  final int pendingActivities;

  const DashboardSummary({
    required this.isCheckedInToday,
    this.checkInTimeFormatted,
    required this.totalCustomers,
    required this.pendingActivities,
  });

  @override
  List<Object?> get props => [
        isCheckedInToday,
        checkInTimeFormatted,
        totalCustomers,
        pendingActivities,
      ];
}
