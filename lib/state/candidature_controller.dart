import 'package:flutter/foundation.dart';

import '../data/candidature_repository.dart';
import '../models/candidature.dart';

class CandidatureController extends ChangeNotifier {
  CandidatureController(this._repository);

  final CandidatureRepository _repository;
  List<Candidature> _elements = [];
  EtatChargement _etat = EtatChargement.loading;
  String? _erreur;
  String _recherche = '';
  Statut? _filtreStatut;

  List<Candidature> get elements => List.unmodifiable(_elements);
  EtatChargement get etat => _etat;
  String? get erreur => _erreur;
  String get recherche => _recherche;
  Statut? get filtreStatut => _filtreStatut;

  List<Candidature> get candidaturesFiltrees {
    final rechercheNormalisee = _recherche.trim().toLowerCase();
    return _elements.where((candidature) {
      final correspondRecherche = rechercheNormalisee.isEmpty ||
          candidature.entreprise.toLowerCase().contains(rechercheNormalisee) ||
          candidature.poste.toLowerCase().contains(rechercheNormalisee);
      final correspondStatut =
          _filtreStatut == null || candidature.statut == _filtreStatut;
      return correspondRecherche && correspondStatut;
    }).toList();
  }

  Map<Statut, int> get compteursParStatut => {
        for (final statut in Statut.values)
          statut: _elements.where((item) => item.statut == statut).length,
      };

  Future<void> charger() async {
    _etat = EtatChargement.loading;
    _erreur = null;
    notifyListeners();
    try {
      _elements = await _repository.toutes();
      _etat =
          _elements.isEmpty ? EtatChargement.empty : EtatChargement.success;
    } catch (erreur) {
      _erreur = 'Impossible de charger les candidatures : $erreur';
      _etat = EtatChargement.error;
    } finally {
      notifyListeners();
    }
  }

  void definirRecherche(String valeur) {
    _recherche = valeur;
    notifyListeners();
  }

  void definirFiltreStatut(Statut? statut) {
    _filtreStatut = statut;
    notifyListeners();
  }

  Candidature? trouverParId(int? id) {
    if (id == null) return null;
    for (final candidature in _elements) {
      if (candidature.id == id) return candidature;
    }
    return null;
  }

  Future<void> enregistrer(Candidature candidature) async {
    try {
      await _repository.enregistrer(candidature);
      await charger();
    } catch (erreur, trace) {
      _erreur = 'Impossible d’enregistrer la candidature : $erreur';
      _etat = EtatChargement.error;
      notifyListeners();
      Error.throwWithStackTrace(erreur, trace);
    }
  }

  Future<void> supprimer(int id) async {
    try {
      await _repository.supprimer(id);
      await charger();
    } catch (erreur, trace) {
      _erreur = 'Impossible de supprimer la candidature : $erreur';
      _etat = EtatChargement.error;
      notifyListeners();
      Error.throwWithStackTrace(erreur, trace);
    }
  }

}
