// ignore_for_file: unused_field

import 'package:mobile_test_ai/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:mobile_test_ai/features/activity/domain/repositories/activity_repository.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/add_activity_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/get_activities_usecase.dart';
import 'package:mobile_test_ai/features/activity/domain/usecases/mark_activity_done_usecase.dart';
import 'package:mobile_test_ai/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:mobile_test_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_test_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_test_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:mobile_test_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile_test_ai/features/check_in/data/repositories/check_in_repository_impl.dart';
import 'package:mobile_test_ai/features/check_in/domain/repositories/check_in_repository.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_in_usecase.dart';
import 'package:mobile_test_ai/features/check_in/domain/usecases/check_out_usecase.dart';
import 'package:mobile_test_ai/features/check_in/presentation/bloc/check_in_bloc.dart';
import 'package:mobile_test_ai/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:mobile_test_ai/features/customer/domain/repositories/customer_repository.dart';
import 'package:mobile_test_ai/features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:mobile_test_ai/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:mobile_test_ai/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:mobile_test_ai/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile_test_ai/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile_test_ai/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:mobile_test_ai/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile_test_ai/features/mock_data/mock_data_source.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  // Data
  late final MockDataSource mockDataSource;

  // Repositories
  late final AuthRepository authRepository;
  late final DashboardRepository dashboardRepository;
  late final CheckInRepository checkInRepository;
  late final CustomerRepository customerRepository;
  late final ActivityRepository activityRepository;

  // UseCases
  late final LoginUseCase loginUseCase;
  late final GetDashboardSummaryUseCase getDashboardSummaryUseCase;
  late final CheckInUseCase checkInUseCase;
  late final CheckOutUseCase checkOutUseCase;
  late final GetCustomersUseCase getCustomersUseCase;
  late final GetCustomerByIdUseCase getCustomerByIdUseCase;
  late final GetActivitiesUseCase getActivitiesUseCase;
  late final AddActivityUseCase addActivityUseCase;
  late final MarkActivityDoneUseCase markActivityDoneUseCase;

  // BLoCs
  late final AuthBloc authBloc;
  late final DashboardBloc dashboardBloc;
  late final CheckInBloc checkInBloc;
  late final CustomerBloc customerBloc;
  late final ActivityBloc activityBloc;

  void setup() {
    mockDataSource = MockDataSource.instance;

    authRepository = AuthRepositoryImpl(mockDataSource);
    dashboardRepository = DashboardRepositoryImpl(mockDataSource);
    checkInRepository = CheckInRepositoryImpl(mockDataSource);
    customerRepository = CustomerRepositoryImpl(mockDataSource);
    activityRepository = ActivityRepositoryImpl(mockDataSource);

    loginUseCase = LoginUseCase(authRepository);
    getDashboardSummaryUseCase = GetDashboardSummaryUseCase(dashboardRepository);
    checkInUseCase = CheckInUseCase(checkInRepository);
    checkOutUseCase = CheckOutUseCase(checkInRepository);
    getCustomersUseCase = GetCustomersUseCase(customerRepository);
    getCustomerByIdUseCase = GetCustomerByIdUseCase(customerRepository);
    getActivitiesUseCase = GetActivitiesUseCase(activityRepository);
    addActivityUseCase = AddActivityUseCase(activityRepository);
    markActivityDoneUseCase = MarkActivityDoneUseCase(activityRepository);

    authBloc = AuthBloc(loginUseCase);
    dashboardBloc = DashboardBloc(getDashboardSummaryUseCase);
    checkInBloc = CheckInBloc(checkInUseCase, checkOutUseCase);
    customerBloc = CustomerBloc(getCustomersUseCase);
    activityBloc = ActivityBloc(getActivitiesUseCase, addActivityUseCase, markActivityDoneUseCase);
  }
}
