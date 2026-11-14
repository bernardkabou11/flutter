import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/candidature.dart';

abstract interface class CandidatureRepository {
  Future<List<Candidature>> toutes();

  Future<Candidature> enregistrer(Candidature candidature);

  Future<void> supprimer(int id);

  Future<void> fermer();
}

class MemoryCandidatureRepository implements CandidatureRepository {
  MemoryCandidatureRepository({List<Candidature> initiales = const []}) {
    for (final candidature in initiales) {
      final id = candidature.id ?? _prochainId;
      _elements[id] = candidature.copyWith(id: id);
      if (id >= _prochainId) _prochainId = id + 1;
    }
  }

  final Map<int, Candidature> _elements = {};
  int _prochainId = 1;

  @override
  Future<List<Candidature>> toutes() async {
    final result = _elements.values.toList()
      ..sort((a, b) {
        final dateComparaison =
            b.dateModification.compareTo(a.dateModification);
        return dateComparaison != 0
            ? dateComparaison
            : b.id!.compareTo(a.id!);
      });
    return List.unmodifiable(result);
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    final id = candidature.id;
    if (id != null && !_elements.containsKey(id)) return candidature;

    final nouvelId = id ?? _prochainId++;
    final enregistree = candidature.copyWith(id: nouvelId);
    _elements[nouvelId] = enregistree;
    return enregistree;
  }

  @override
  Future<void> supprimer(int id) async {
    _elements.remove(id);
  }

  @override
  Future<void> fermer() async {}
}

class SqliteCandidatureRepository implements CandidatureRepository {
  SqliteCandidatureRepository({
    Future<Database> Function()? ouvrirBase,
    String? cheminBase,
  }) : _ouvrirBase =
            ouvrirBase ?? (() => _ouvrirBaseLocale(cheminBase: cheminBase));

  final Future<Database> Function() _ouvrirBase;
  Future<Database>? _base;

  static Future<Database> _ouvrirBaseLocale({String? cheminBase}) async {
    final chemin = cheminBase ??
        p.join(await getDatabasesPath(), 'piste.db');
    return openDatabase(
      chemin,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE candidatures (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entreprise TEXT NOT NULL,
            poste TEXT NOT NULL,
            statut TEXT NOT NULL,
            notes TEXT NOT NULL,
            url TEXT NOT NULL,
            date_creation TEXT NOT NULL,
            date_modification TEXT NOT NULL,
            prochaine_relance TEXT
          )
        ''');
      },
      onUpgrade: (db, ancienneVersion, nouvelleVersion) async {
        if (ancienneVersion < 2) {
          await db.execute(
            'ALTER TABLE candidatures '
            'ADD COLUMN date_modification TEXT NOT NULL DEFAULT \'\'',
          );
          await db.execute(
            'UPDATE candidatures SET date_modification = date_creation '
            'WHERE date_modification = \'\'',
          );
        }
      },
    );
  }

  Future<Database> get _database => _base ??= _ouvrirBase();

  @override
  Future<List<Candidature>> toutes() async {
    final db = await _database;
    final lignes = await db.query(
      'candidatures',
      orderBy: 'date_modification DESC, id DESC',
    );
    return lignes.map(Candidature.fromDatabase).toList();
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    final db = await _database;
    final valeurs = candidature.toDatabase();
    final id = candidature.id;

    if (id == null) {
      final nouvelId = await db.insert('candidatures', valeurs);
      return candidature.copyWith(id: nouvelId);
    }

    await db.update(
      'candidatures',
      valeurs,
      where: 'id = ?',
      whereArgs: [id],
    );
    return candidature;
  }

  @override
  Future<void> supprimer(int id) async {
    final db = await _database;
    await db.delete(
      'candidatures',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> fermer() async {
    final db = await _base;
    if (db != null) {
      await (await db).close();
      _base = null;
    }
  }
}
