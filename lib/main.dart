import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/preload_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/plugin_management/plugins.dart';
import 'package:netshare/provider/app_provider.dart';
import 'package:netshare/provider/chat_provider.dart';
import 'package:netshare/provider/connection_provider.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/chat/chat_widget.dart';
import 'package:netshare/ui/client/scan_qr_widget.dart';
import 'package:netshare/ui/client/client_widget.dart';
import 'package:netshare/ui/send/send_widget.dart';
import 'package:netshare/ui/server/server_widget.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:provider/provider.dart';

import 'package:netshare/config/constants.dart';
import 'package:netshare/ui/send/uploading_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlugins();
  setupDI();
  await PreloadData.inject();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  final GoRouter _router = GoRouter(
    errorBuilder: (BuildContext context, GoRouterState state) => ErrorWidget(state.error!),
    routes: <GoRoute>[
      GoRoute(
        path: mRootPath,
          redirect: (context, state) {
            if(UtilityFunctions.isMobile) {
              return '/$mClientPath';
            } else {
              return '/$mServerPath';
            }
          },
      ),
      GoRoute(
        name: mServerPath,
        path: '/$mServerPath',
        builder: (context, state) => const ServerWidget(),
      ),
      GoRoute(
        name: mClientPath,
        path: '/$mClientPath',
        builder: (context, state) => const ClientWidget(),
          routes: [
            GoRoute(
              name: mSendPath,
              path: mSendPath,
              builder: (BuildContext context, GoRouterState state) => const SendWidget(),
              routes: [
                GoRoute(
                  name: mUploadingPath,
                  path: mUploadingPath,
                  builder: (context, state) => const UploadingWidget(),
                )
              ],
            ),
            GoRoute(
              name: mChatPath,
              path: mChatPath,
              builder: (BuildContext context, GoRouterState state) => const ChatWidget(),
            ),
            GoRoute(
              name: mScanningPath,
              path: mScanningPath,
              builder: (BuildContext context, GoRouterState state) => const ScanQRWidget(),
            ),
          ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FileProvider()),
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'NetShare',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(color: backgroundColor),
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor, background: backgroundColor),
          iconButtonTheme: const IconButtonThemeData(
            style: ButtonStyle(
              iconColor: MaterialStatePropertyAll<Color>(textIconButtonColor),
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
