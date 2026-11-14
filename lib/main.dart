import 'dart:async';

import 'package:flutter/material.dart';

import 'data/candidature_repository.dart';
import 'models/candidature.dart';
import 'state/candidature_controller.dart';
import 'ui/accueil_page.dart';

const modeDemonstrationTp1 = bool.fromEnvironment(
  'DEMO_TP1',
  defaultValue: false,
);
const utiliserRepositoryMemoire = bool.fromEnvironment(
  'USE_MEMORY_REPOSITORY',
  defaultValue: false,
);

void main() {
  final CandidatureRepository repository;
  if (modeDemonstrationTp1) {
    repository = MemoryCandidatureRepository(
      initiales: _candidaturesDemoTp1,
    );
  } else if (utiliserRepositoryMemoire) {
    repository = MemoryCandidatureRepository();
  } else {
    repository = SqliteCandidatureRepository();
  }
  runApp(PisteApp(
    repository: repository,
    modeDemonstrationTp1: modeDemonstrationTp1,
  ));
}

final List<Candidature> _candidaturesDemoTp1 = List.unmodifiable([
  Candidature(
    id: 1,
    entreprise: 'Nexora',
    poste: 'Développeur Flutter',
    statut: Statut.envoyee,
    dateCreation: DateTime(2026, 1, 12),
    dateModification: DateTime(2026, 1, 12),
  ),
  Candidature(
    id: 2,
    entreprise: 'Asteria',
    poste: 'Développeur mobile junior',
    statut: Statut.entretien,
    dateCreation: DateTime(2026, 1, 18),
    dateModification: DateTime(2026, 1, 18),
  ),
]);

class PisteApp extends StatefulWidget {
  const PisteApp({
    required this.repository,
    this.modeDemonstrationTp1 = false,
    super.key,
  });

  final CandidatureRepository repository;
  final bool modeDemonstrationTp1;

  @override
  State<PisteApp> createState() => _PisteAppState();
}

class _PisteAppState extends State<PisteApp> {
  late final CandidatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CandidatureController(widget.repository);
    unawaited(_controller.charger());
  }

  @override
  void dispose() {
    _controller.dispose();
    unawaited(widget.repository.fermer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C54)),
      ),
      home: AccueilPage(
        controller: _controller,
        modeDemonstrationTp1: widget.modeDemonstrationTp1,
      ),
    );
  }
}
