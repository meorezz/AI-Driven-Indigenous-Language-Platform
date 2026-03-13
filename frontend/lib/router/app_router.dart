import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/welcome_screen.dart';
import '../screens/region_select_screen.dart';
import '../screens/language_select_screen.dart';
import '../screens/user_level_screen.dart';
import '../screens/native_intent_screen.dart';
import '../screens/quick_check_screen.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/concept_screen.dart';
import '../screens/practice_screen.dart';
import '../screens/contribute_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/region-select',
        builder: (context, state) => const RegionSelectScreen(),
      ),
      GoRoute(
        path: '/language-select',
        builder: (context, state) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: '/user-level',
        builder: (context, state) => const UserLevelScreen(),
      ),
      GoRoute(
        path: '/native-intent',
        builder: (context, state) => const NativeIntentScreen(),
      ),
      GoRoute(
        path: '/quick-check',
        builder: (context, state) => const QuickCheckScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/category/:id',
        builder: (context, state) => CategoryScreen(categoryId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/concept/:id',
        builder: (context, state) => ConceptScreen(conceptId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/practice/:id',
        builder: (context, state) => PracticeScreen(conceptId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/contribute',
        builder: (context, state) => const ContributeScreen(),
      ),
    ],
  );
});
