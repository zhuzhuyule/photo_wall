import 'package:flutter/material.dart';
import 'package:photo_wall/src/common/empty.dart';
import 'package:photo_wall/src/explorer/explorer_view.dart';
import 'package:photo_wall/src/main/wall_view.dart';
import 'package:provider/provider.dart';

import 'favorite/favorite_state.dart';
import 'settings/settings_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return ChangeNotifierProvider(
          create: (context) => FavoriteState(),
          child: MaterialApp(
            restorationScopeId: 'app',
            supportedLocales: const [Locale('en', '')],
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  var favoriteState = context.watch<FavoriteState>();
                  if (favoriteState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  switch (routeSettings.name) {
                    case ExplorerView.routeName:
                      return const ExplorerView();
                    default:
                      return favoriteState.favorites.isNotEmpty
                          ? WallView(images: favoriteState.favorites)
                          : const Empty();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
