import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_test_ai/core/di/service_locator.dart';
import 'package:mobile_test_ai/core/router/app_router.dart';

void main() {
  ServiceLocator.instance.setup();
  final sl = ServiceLocator.instance;
  final router = AppRouter(sl.authBloc).router;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl.authBloc),
        BlocProvider.value(value: sl.dashboardBloc),
        BlocProvider.value(value: sl.checkInBloc),
        BlocProvider.value(value: sl.customerBloc),
        BlocProvider.value(value: sl.activityBloc),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MobileTestAI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    ),
  );
}
