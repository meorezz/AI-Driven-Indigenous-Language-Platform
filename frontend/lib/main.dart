import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ooennfcrqjgybixamntn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9vZW5uZmNycWpneWJpeGFtbnRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3OTgxMTIsImV4cCI6MjA4NzM3NDExMn0.Msx_7BY6GR--GfMNkMZefHpnkLrwyWHBOnCmJKnPOi0',
  );

  runApp(const ProviderScope(child: IndigenousLanguageApp()));
}
