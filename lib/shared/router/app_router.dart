import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/main_layout/presentation/main_layout.dart';
import '../../features/requests/presentation/create_request_wizard.dart';
import '../../features/requests/presentation/proposals_screen.dart';
import '../../features/profile/presentation/provider_profile_screen.dart';
import '../../features/messages/presentation/chat_screen.dart';
import '../../features/requests/presentation/appointment_tracking_screen.dart';
import '../../features/requests/presentation/review_screen.dart';
import '../../features/provider/presentation/provider_main_layout.dart';
import '../../features/provider/presentation/provider_submit_proposal_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // --- CLIENT ROUTES ---
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/create-request',
        builder: (context, state) => const CreateRequestWizard(),
      ),
      GoRoute(
        path: '/proposals',
        builder: (context, state) => const ProposalsScreen(),
      ),
      GoRoute(
        path: '/provider-profile',
        builder: (context, state) => const ProviderProfileScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/appointment-tracking',
        builder: (context, state) => const AppointmentTrackingScreen(),
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) => const ReviewScreen(),
      ),
      
      // --- PROVIDER ROUTES ---
      GoRoute(
        path: '/provider-home',
        builder: (context, state) => const ProviderMainLayout(),
      ),
      GoRoute(
        path: '/submit-proposal',
        builder: (context, state) => const ProviderSubmitProposalScreen(),
      ),
    ],
  );
});
