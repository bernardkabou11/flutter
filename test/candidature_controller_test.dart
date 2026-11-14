import 'package:flutter_test/flutter_test.dart';
import 'package:piste/models/candidature.dart';
import 'package:piste/state/candidature_controller.dart';

import 'fake_repository.dart';

void main() {
  late FakeCandidatureRepository repository;
  late CandidatureController controller;

  setUp(() {
    repository = FakeCandidatureRepository();
    controller = CandidatureController(repository);
  });

  tearDown(() {
    controller.dispose();
  });

  test('charge l’état vide et enregistre une candidature', () async {
    await controller.charger();
    expect(controller.etat, EtatChargement.empty);

    final maintenant = DateTime(2026, 1, 1);
    await controller.enregistrer(
      Candidature(
        entreprise: 'Nexora',
        poste: 'Développeur Flutter',
        statut: Statut.envoyee,
        dateCreation: maintenant,
        dateModification: maintenant,
      ),
    );

    expect(controller.etat, EtatChargement.success);
    expect(controller.elements, hasLength(1));
    expect(controller.elements.single.id, 1);
  });

  test('modifie puis supprime une candidature', () async {
    final maintenant = DateTime(2026, 1, 1);
    final creee = await repository.enregistrer(
      Candidature(
        entreprise: 'Nexora',
        poste: 'Développeur Flutter',
        statut: Statut.envoyee,
        dateCreation: maintenant,
        dateModification: maintenant,
      ),
    );
    await controller.charger();

    await controller.enregistrer(
      creee.copyWith(
        statut: Statut.entretien,
        dateModification: DateTime(2026, 1, 2),
      ),
    );
    expect(controller.elements.single.statut, Statut.entretien);

    await controller.supprimer(creee.id!);
    expect(controller.etat, EtatChargement.empty);
    expect(controller.elements, isEmpty);
  });

  test('recherche, filtre et bilan utilisent toutes les candidatures',
      () async {
    final maintenant = DateTime(2026, 1, 1);
    for (final (entreprise, statut) in [
      ('Nexora', Statut.envoyee),
      ('Asteria', Statut.entretien),
    ]) {
      await repository.enregistrer(
        Candidature(
          entreprise: entreprise,
          poste: 'Développeur',
          statut: statut,
          dateCreation: maintenant,
          dateModification: maintenant,
        ),
      );
    }
    await controller.charger();

    controller.definirRecherche('nexo');
    controller.definirFiltreStatut(Statut.envoyee);
    expect(controller.candidaturesFiltrees, hasLength(1));
    expect(controller.compteursParStatut[Statut.envoyee], 1);
    expect(controller.elements, hasLength(2));
  });

  test('signale une erreur de chargement', () async {
    repository.echecLecture = true;

    await controller.charger();

    expect(controller.etat, EtatChargement.error);
    expect(controller.erreur, contains('Impossible de charger'));
  });
}
