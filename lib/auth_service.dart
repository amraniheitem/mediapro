class AuthService {
  // Simule l'état d'authentification
  bool _isAuthenticated = false;

  // Stream pour écouter les changements d'authentification
  Stream<bool> get authStateChanges => Stream<bool>.value(_isAuthenticated);

  // Méthode pour se connecter
  Future<void> login() async {
    // Simule une connexion réussie
    await Future.delayed(Duration(seconds: 2));
    _isAuthenticated = true;
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    // Simule une déconnexion
    await Future.delayed(Duration(seconds: 2));
    _isAuthenticated = false;
  }
}
