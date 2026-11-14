import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:piste/data/candidature_repository.dart';
import 'package:piste/models/candidature.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory dossierTemporaire;
  late SqliteCandidatureRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dossierTemporaire =
        await Directory.systemTemp.createTemp('piste_sqlite_test_');
    repository = SqliteCandidatureRepository(
      cheminBase: p.join(dossierTemporaire.path, 'piste_test.db'),
    );
  });

  tearDown(() async {
    await repository.fermer();
    await dossierTemporaire.delete(recursive: true);
  });

  test('SQLite crée, lit, modifie et supprime une candidature', () async {
    final dateCreation = DateTime(2026, 2, 1);
    final candidatureCreee = await repository.enregistrer(
      Candidature(
        entreprise: 'Nexora',
        poste: 'Développeur Flutter',
        statut: Statut.envoyee,
        dateCreation: dateCreation,
        dateModification: dateCreation,
      ),
    );

    expect(candidatureCreee.id, isNotNull);
    var candidatures = await repository.toutes();
    expect(candidatures, hasLength(1));
    expect(candidatures.single.id, candidatureCreee.id);
    expect(candidatures.single.entreprise, 'Nexora');

    final candidatureModifiee = candidatureCreee.copyWith(
      poste: 'Développeur mobile',
      statut: Statut.entretien,
      dateModification: DateTime(2026, 2, 2),
    );
    await repository.enregistrer(candidatureModifiee);
    candidatures = await repository.toutes();
    expect(candidatures, hasLength(1));
    expect(candidatures.single.poste, 'Développeur mobile');
    expect(candidatures.single.statut, Statut.entretien);

    await repository.supprimer(candidatureCreee.id!);
    expect(await repository.toutes(), isEmpty);
  });

  test('le repository mémoire crée, lit, modifie et supprime', () async {
    final memoire = MemoryCandidatureRepository();
    final date = DateTime(2026, 2, 1);
    final creee = await memoire.enregistrer(
      Candidature(
        entreprise: 'Asteria',
        poste: 'Développeur mobile',
        statut: Statut.brouillon,
        dateCreation: date,
        dateModification: date,
      ),
    );

    expect((await memoire.toutes()).single.entreprise, 'Asteria');

    await memoire.enregistrer(
      creee.copyWith(
        statut: Statut.entretien,
        dateModification: DateTime(2026, 2, 2),
      ),
    );
    expect((await memoire.toutes()).single.statut, Statut.entretien);

    await memoire.supprimer(creee.id!);
    expect(await memoire.toutes(), isEmpty);
    await memoire.fermer();
  });
}
