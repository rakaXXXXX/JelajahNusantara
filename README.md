# Jelajah Nusantara

[![Flutter](https://flutter.dev/images/flutter-logo-sharing.png)](https://flutter.dev/)

**Jelajah Nusantara** adalah aplikasi Flutter cross-platform untuk eksplorasi dan berbagi artikel tentang Nusantara (Indonesia). Pengguna dapat mendaftar, login, mengelola profil (termasuk upload foto), melihat artikel semua pengguna, mengelola artikel pribadi (CRUD), dengan UI responsif menggunakan grid dan bottom navigation.

## Fitur Utama
- Autentikasi: Login/Register/Profile/Edit Profile dengan foto.
- Artikel: Lihat semua/saya, detail, buat/edit/hapus dengan gambar.
- UI: Splash, Home dengan bottom nav, reusable grids, image input.
- Platform: Android/iOS/Web/Desktop/Linux/macOS/Windows.

## Arsitektur dan Implementasi Kode Detail

App mengikuti pola **Separation of Concerns** (Models-Views-Controllers-Services):

### 1. **Models** (`lib/screens/models/`)
Definisi data:
- `user_model.dart`: Class `User` dengan fields `id`, `username`, `email`, `photoUrl`.
- `artikel_model.dart`: Class `Artikel` dengan `id`, `judul`, `isi`, `gambar`, `userId`, `tanggal`.

Digunakan untuk parse JSON dari API.

### 2. **Services** (`lib/screens/services/`) - Layer API dengan `http` package.
**auth_services.dart**:
```dart
Future<Map<String, dynamic>> login(String username, String password) async {
  final response = await http.post(
    Uri.parse('API_URL/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'username': username, 'password': password}),
  );
  // if (response.statusCode == 200) { save token to SharedPreferences }
}
```
- Fungsi: `login()`, `register()`, `getProfile()`, `updateProfile(file)`.
- Implementasi: POST JSON, Bearer token untuk protected routes.

**artikel_services.dart**:
```dart
Future<List<Artikel>> getAllArtikels() async {
  final response = await http.get(
    Uri.parse('API_URL/artikel'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return (jsonDecode(response.body) as List).map((e) => Artikel.fromJson(e)).toList();
}
```
- Fungsi: `getAll()`, `getMy()`, `create()`, `update()`, `delete(id)`.
- Image: Multipart untuk upload.

### 3. **Controllers** (`lib/screens/controllers/`) - Logic bisnis & state.
**auth_controller.dart**:
- `login()`, `logout()` → service call + prefs.setString('token', token).
**artikel_controllers.dart**:
- `fetchAllArtikels()` → FutureBuilder notify.

### 4. **Screens** (`lib/screens/`) - UI & Navigation.
- `splash_screen.dart`: Timer 2s → check prefs token → login/home.
- `login_screen.dart` / `register_screen.dart`: Form validation → controller.login() → Navigator.pushReplacement.
- `home.dart`: IndexedStack dengan `bottom_navbar.dart` → switch to articles screens.
- `articles/form_screen.dart`: TextFields + `image_input.dart` → controller.create().
- Grids (`grid_artikel.dart`): `FutureBuilder<List<Artikel>>` + `GridView.builder` (itemCount: snapshot.data?.length).

### 5. **Widgets** (`lib/screens/widgets/`).
- `bottom_navbar.dart`: Custom `BottomNavigationBar` dengan icons.
- `image_input.dart`: `ImagePicker.pickImage()` → `path_provider.getApplicationDocumentsDirectory()` save → base64 or multipart upload.
- `grid_my_artikel.dart` etc.: Card dengan Image.network(gambar), Text(judul), GestureDetector to detail.

### 6. **Entry Point** (`lib/main.dart`):
```dart
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen());
  }
}
```

## Dependencies Penting (pubspec.yaml)
```
dependencies:
  flutter:
  http: ^1.1.0  # API calls
  shared_preferences: ^2.2.2  # Token
  path_provider: ^2.1.2  # File save
  image_picker: ^1.0.4  # Photo
```

## Setup dan Running
1. `git clone .`
2. `flutter pub get`
3. Konfigurasi API base URL di services (ganti `$url`).
4. `flutter run` (pilih device).

## API Endpoints (Backend dibutuhkan)
| Method | Endpoint | Auth | Body |
|--------|----------|------|------|
| POST | /login | No | `{username, password}` |
| POST | /register | No | `{username, password, email}` |
| GET | /artikel | Yes | - |
| POST | /artikel | Yes | `{judul, isi, gambar base64}` |

## Screenshot
- Tambahkan folder `screenshots/` dan ![login](screenshots/login.png) etc.

## Kontribusi
1. Fork project.
2. Buat branch `feature/xxx`.
3. PR.

Lisensi: MIT.

--- 

README selesai dengan penjelasan lengkap fungsi dan kode!"
