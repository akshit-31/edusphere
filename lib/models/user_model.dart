class AppUser {
  final String name;
  final String email;
  final String role;
  final String subtitle;
  final String avatarSeed;

  const AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.subtitle,
    required this.avatarSeed,
  });
}

const Map<String, Map<String, String>> kCredentials = {
  'student': {
    'email': '',
    'password': '',
    'name': '',
    'subtitle': 'Student'
  },
  'teacher': {
    'email': '',
    'password': '',
    'name': '',
    'subtitle': 'Teacher'
  },
};
