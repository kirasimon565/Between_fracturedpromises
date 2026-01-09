# File Map

| Path | Description |
|---|---|
| **Root** | |
| `firebase.json` | Firebase configuration |
| `firestore.rules` | Firestore security rules |
| `storage.rules` | Firebase Storage security rules |
| `analysis_options.yaml` | Linter rules |
| `pubspec.yaml` | Dependencies and assets configuration |
| `README.md` | Project documentation |
| **lib/app** | |
| `lib/app/constants.dart` | Application constants (Assets, Strings) |
| `lib/app/routes.dart` | Navigation routes and page definitions |
| **lib/models** | |
| `lib/models/chat_thread.dart` | Chat thread data model |
| `lib/models/choice.dart` | User choice data model |
| `lib/models/ending.dart` | Game ending data model |
| `lib/models/episode.dart` | Story episode data model |
| `lib/models/message.dart` | Chat message data model |
| **lib/screens/admin** | |
| `lib/screens/admin/admin_dashboard.dart` | Admin control panel |
| `lib/screens/admin/dialpad_screen.dart` | Secret admin access screen (*#77*#) |
| `lib/screens/admin/episode_uploader.dart` | Tool to upload episodes |
| `lib/screens/admin/admin_auth.dart` | Admin authentication logic |
| **lib/screens/endgame** | |
| `lib/screens/endgame/endgame_screen.dart` | Game over/Ending display screen |
| `lib/screens/endgame/ending_controller.dart` | Logic for determining endings |
| `lib/screens/endgame/ending_summary.dart` | Summary widget for endings |
| **lib/screens/gallery** | |
| `lib/screens/gallery/gallery_screen.dart` | Image gallery screen |
| `lib/screens/gallery/gallery_controller.dart` | Logic for unlocked images |
| `lib/screens/gallery/gallery_viewer.dart` | Fullscreen image viewer |
| **lib/screens/home** | |
| `lib/screens/home/home_screen.dart` | Main desktop/home screen |
| `lib/screens/home/app_icon.dart` | Desktop app icon widget |
| `lib/screens/home/status_bar.dart` | Fake phone status bar |
| **lib/screens/makelove** | |
| `lib/screens/makelove/makelove_list_screen.dart` | Dating app match list (Secret Theme) |
| `lib/screens/makelove/makelove_chat_screen.dart` | Dating app chat interface |
| `lib/screens/makelove/makelove_bubble.dart` | Chat bubble for dating app |
| **lib/screens/messenger** | |
| `lib/screens/messenger/messenger_list_screen.dart` | Messenger app list (Safe Theme) |
| `lib/screens/messenger/messenger_chat_screen.dart` | Messenger chat interface |
| `lib/screens/messenger/messenger_bubble.dart` | Chat bubble for messenger |
| **lib/screens/profile** | |
| `lib/screens/profile/profile_screen.dart` | User profile display |
| `lib/screens/profile/profile_edit_screen.dart` | Profile editing screen |
| `lib/screens/profile/profile_controller.dart` | Profile state management |
| `lib/screens/profile/verification_badge.dart` | Verified user badge widget |
| `lib/screens/profile/profile_info_card.dart` | Profile info widget |
| **lib/screens/secret** | |
| `lib/screens/secret/secret_chat_screen.dart` | Encrypted/Secret chat screen |
| **lib/screens/settings** | |
| `lib/screens/settings/settings_screen.dart` | Settings app (contains admin trigger) |
| **lib/screens/splash** | |
| `lib/screens/splash/splash_screen.dart` | App launch splash screen |
| **lib/screens/welcome** | |
| `lib/screens/welcome/welcome_screen.dart` | Onboarding screen |
| `lib/screens/welcome/welcome_widgets.dart` | Reusable welcome widgets |
| **lib/services** | |
| `lib/services/audio_service.dart` | Audio playback management |
| `lib/services/auth_service.dart` | User authentication |
| `lib/services/episode_service.dart` | Episode fetching and management |
| `lib/services/firestore_service.dart` | Firestore database interaction |
| `lib/services/notification_service.dart` | Local notifications |
| `lib/services/save_service.dart` | Game progress saving |
| `lib/services/state_service.dart` | Global game state (variables) |
| `lib/services/storage_service.dart` | Local storage wrapper |
| `lib/services/story_engine.dart` | Core logic for playing the story |
| **lib/theme** | |
| `lib/theme/colors.dart` | Color palette definitions |
| `lib/theme/spacing.dart` | Layout spacing constants |
| `lib/theme/text_styles.dart` | Typography styles |
| `lib/theme/theme.dart` | Theme switching logic (Safe/Secret) |
| **lib/utils** | |
| `lib/utils/animations.dart` | Custom animations |
| `lib/utils/delays.dart` | Story pacing timing constants |
| `lib/utils/dialpad_codes.dart` | Secret codes |
| `lib/utils/helpers.dart` | General utility functions |
