import 'package:mobile_test_ai/features/activity/domain/entities/activity.dart';
import 'package:mobile_test_ai/features/auth/domain/entities/employee.dart';
import 'package:mobile_test_ai/features/check_in/domain/entities/check_in_record.dart';
import 'package:mobile_test_ai/features/customer/domain/entities/customer.dart';

class MockDataSource {
  MockDataSource._();
  static final MockDataSource instance = MockDataSource._();

  /// Set to true in tests to trigger error states.
  bool simulateError = false;

  // ── Auth ──────────────────────────────────────────────────────────────────
  final String demoEmail = 'demo@example.com';
  final String demoPassword = 'password123';
  final Employee currentEmployee = const Employee(
    id: 'emp_001',
    name: 'Alex Jordan',
    email: 'demo@example.com',
  );

  // ── Check-In ──────────────────────────────────────────────────────────────
  CheckInRecord? todayCheckIn;

  // ── Customers (12 records) ────────────────────────────────────────────────
  final List<Customer> customers = [
    const Customer(
      id: 'cust_001',
      fullName: 'Sarah Mitchell',
      companyName: 'Apex Solutions',
      email: 'sarah@apexsolutions.com',
      phoneNumber: '+1-555-0101',
      notes: 'Prefers morning calls.',
    ),
    const Customer(
      id: 'cust_002',
      fullName: 'James Okafor',
      companyName: 'Bright Innovations',
      email: 'james@brightinno.com',
      phoneNumber: '+1-555-0102',
    ),
    const Customer(
      id: 'cust_003',
      fullName: 'Lin Wei',
      companyName: 'CloudPath Inc.',
      email: 'lin@cloudpath.io',
      phoneNumber: '+1-555-0103',
      notes: 'Key account — escalate issues.',
    ),
    const Customer(
      id: 'cust_004',
      fullName: 'Priya Sharma',
      companyName: 'DataBridge Ltd.',
      phoneNumber: '+1-555-0104',
      notes: 'No email on file.',
    ),
    const Customer(
      id: 'cust_005',
      fullName: 'Carlos Rivera',
      companyName: 'EdgeWorks Corp.',
      email: 'carlos@edgeworks.com',
      notes: 'Site visit required.',
    ),
    const Customer(
      id: 'cust_006',
      fullName: 'Fatima Al-Hassan',
      companyName: 'FutureTech ME',
      email: 'fatima@futuretech.me',
      phoneNumber: '+1-555-0106',
    ),
    const Customer(
      id: 'cust_007',
      fullName: 'David Nguyen',
      companyName: 'GreenLeaf Systems',
      email: 'david@greenleaf.com',
      phoneNumber: '+1-555-0107',
      notes: 'Interested in upsell.',
    ),
    const Customer(
      id: 'cust_008',
      fullName: 'Amara Johnson',
      companyName: 'HorizonPlus',
      email: 'amara@horizonplus.net',
      phoneNumber: '+1-555-0108',
    ),
    const Customer(
      id: 'cust_009',
      fullName: 'Tomás García',
      companyName: 'InnoCo Spain',
      email: 'tomas@innocospain.es',
      phoneNumber: '+34-555-0109',
      notes: 'Spanish language preferred.',
    ),
    const Customer(
      id: 'cust_010',
      fullName: 'Yuki Tanaka',
      companyName: 'JapanDigital KK',
      email: 'yuki@japandigital.co.jp',
      phoneNumber: '+81-555-0110',
      notes: 'Follow up Q3.',
    ),
    const Customer(
      id: 'cust_011',
      fullName: 'Nadia Obi',
      companyName: 'KineticLabs',
      email: 'nadia@kineticlabs.com',
      phoneNumber: '+1-555-0111',
    ),
    const Customer(
      id: 'cust_012',
      fullName: 'Samuel Breit',
      companyName: 'LogicStream GmbH',
    ),
  ];

  // ── Activities ────────────────────────────────────────────────────────────
  late List<Activity> activities = _seedActivities();

  List<Activity> _seedActivities() {
    final today = DateTime.now();
    return [
      Activity(
        id: 'act_001',
        customerId: 'cust_001',
        customerName: 'Sarah Mitchell',
        title: 'Send proposal',
        dueDate: today.subtract(const Duration(days: 1)),
        status: ActivityStatus.pending,
      ),
      Activity(
        id: 'act_002',
        customerId: 'cust_002',
        customerName: 'James Okafor',
        title: 'Demo walkthrough',
        dueDate: today,
        status: ActivityStatus.pending,
      ),
      Activity(
        id: 'act_003',
        customerId: 'cust_003',
        customerName: 'Lin Wei',
        title: 'Contract review',
        dueDate: today.add(const Duration(days: 3)),
        status: ActivityStatus.pending,
      ),
      Activity(
        id: 'act_004',
        customerId: 'cust_004',
        customerName: 'Priya Sharma',
        title: 'Onboarding call',
        dueDate: today.add(const Duration(days: 7)),
        status: ActivityStatus.done,
      ),
      Activity(
        id: 'act_005',
        customerId: 'cust_005',
        customerName: 'Carlos Rivera',
        title: 'Site assessment',
        dueDate: today.subtract(const Duration(days: 5)),
        status: ActivityStatus.pending,
      ),
      Activity(
        id: 'act_006',
        customerId: 'cust_006',
        customerName: 'Fatima Al-Hassan',
        title: 'Quarterly review',
        dueDate: today.add(const Duration(days: 14)),
        status: ActivityStatus.pending,
      ),
    ];
  }

  int _activityIdCounter = 0;

  /// Returns a unique activity ID.
  String nextActivityId() {
    _activityIdCounter++;
    return 'act_${DateTime.now().millisecondsSinceEpoch}_$_activityIdCounter';
  }

  /// Resets mutable session state (used in tests to simulate a fresh session).
  void resetSession() {
    todayCheckIn = null;
    activities = _seedActivities();
    simulateError = false;
    _activityIdCounter = 0;
  }
}
