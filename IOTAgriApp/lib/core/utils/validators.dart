/// Cac quy tac validate o client duoc dong bo voi rang buoc ben backend:
///  - Password toi thieu 8 ky tu (RegisterRequest.cs: [MinLength(8)],
///    Program.cs: options.Password.RequiredLength = 8)
///  - Email dung dinh dang ([EmailAddress])
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui long nhap email.';
    if (!_emailRegex.hasMatch(value.trim())) return 'Email khong hop le.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui long nhap mat khau.';
    if (value.length < 8) return 'Mat khau phai co it nhat 8 ky tu.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Vui long nhap lai mat khau.';
    if (value != original) return 'Mat khau nhap lai khong khop.';
    return null;
  }

  static String? required(String? value, {String message = 'Truong nay la bat buoc.'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? deviceName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui long nhap ten thiet bi.';
    if (value.trim().length > 100) return 'Ten thiet bi qua dai.';
    return null;
  }
}
