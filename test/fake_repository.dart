import 'package:piste/data/candidature_repository.dart';
import 'package:piste/models/candidature.dart';

class FakeCandidatureRepository implements CandidatureRepository {
  final List<Candidature> elements = [];
  bool echecLecture = false;
  int _prochainId = 1;

  @override
  Future<List<Candidature>> toutes() async {
    if (echecLecture) {
      throw StateError('Échec de lecture simulé.');
    }
    return List.unmodifiable(elements);
  }

  @override
  Future<Candidature> enregistrer(Candidature candidature) async {
    final id = candidature.id ?? _prochainId++;
    final enregistree = candidature.copyWith(id: id);
    elements.removeWhere((item) => item.id == id);
    elements.add(enregistree);
    return enregistree;
  }

  @override
  Future<void> supprimer(int id) async {
    elements.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> fermer() async {}
}
