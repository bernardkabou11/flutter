import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piste/data/candidature_repository.dart';
import 'package:piste/main.dart';
import 'package:piste/models/candidature.dart';

import 'fake_repository.dart';

void main() {
  testWidgets('affiche l’état vide et refuse un formulaire vide',
      (tester) async {
    final repository = FakeCandidatureRepository();
    await tester.pumpWidget(PisteApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucune candidature pour le moment.\n'
        'Ajoutez votre première candidature.'), findsOneWidget);

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Indiquez le nom de l’entreprise.'), findsOneWidget);
    expect(find.text('Indiquez le poste visé.'), findsOneWidget);
    expect(repository.elements, isEmpty);
  });

  testWidgets('ouvre le formulaire et signale une entreprise vide',
      (tester) async {
    final repository = FakeCandidatureRepository();
    await tester.pumpWidget(PisteApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle candidature'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Développeur Flutter',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Indiquez le nom de l’entreprise.'), findsOneWidget);
    expect(repository.elements, isEmpty);
  });

  testWidgets('le mode TP1 conserve ses deux candidatures statiques',
      (tester) async {
    final date = DateTime(2026, 1, 1);
    final repository = MemoryCandidatureRepository(
      initiales: [
        Candidature(
          id: 1,
          entreprise: 'Nexora',
          poste: 'Développeur Flutter',
          statut: Statut.envoyee,
          dateCreation: date,
          dateModification: date,
        ),
        Candidature(
          id: 2,
          entreprise: 'Asteria',
          poste: 'Développeur mobile',
          statut: Statut.entretien,
          dateCreation: date,
          dateModification: date,
        ),
      ],
    );
    await tester.pumpWidget(
      PisteApp(repository: repository, modeDemonstrationTp1: true),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(find.text('Le mode TP1 affiche deux candidatures statiques.'),
        findsOneWidget);
    expect(await repository.toutes(), hasLength(2));
  });
}
