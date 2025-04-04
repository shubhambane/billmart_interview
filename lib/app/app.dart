import 'package:billmart_interview/presentation/screens/user_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/user_bloc.dart';
import '../repository/user_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(UserRepository())..add(FetchUsers()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shubham Bill Mart',
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurpleAccent,
          ),
          useMaterial3: true,
        ),
        home: const UserListScreenWithBloc(),
      ),
    );
  }
}
