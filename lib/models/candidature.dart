enum Statut {
  brouillon,
  envoyee,
  entretien,
  acceptee,
  refusee,
}

extension StatutPresentation on Statut {
  String get libelle => switch (this) {
        Statut.brouillon => 'Brouillon',
        Statut.envoyee => 'Envoyée',
        Statut.entretien => 'Entretien',
        Statut.acceptee => 'Acceptée',
        Statut.refusee => 'Refusée',
      };
}

enum EtatChargement { loading, success, empty, error }

class Candidature {
  const Candidature({
    this.id,
    required this.entreprise,
    required this.poste,
    required this.statut,
    required this.dateCreation,
    required this.dateModification,
    this.notes = '',
    this.url = '',
    this.prochaineRelance,
  });

  final int? id;
  final String entreprise;
  final String poste;
  final Statut statut;
  final String notes;
  final String url;
  final DateTime dateCreation;
  final DateTime dateModification;
  final DateTime? prochaineRelance;

  Candidature copyWith({
    int? id,
    String? entreprise,
    String? poste,
    Statut? statut,
    String? notes,
    String? url,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? prochaineRelance,
    bool supprimerRelance = false,
  }) {
    return Candidature(
      id: id ?? this.id,
      entreprise: entreprise ?? this.entreprise,
      poste: poste ?? this.poste,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
      url: url ?? this.url,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      prochaineRelance:
          supprimerRelance ? null : prochaineRelance ?? this.prochaineRelance,
    );
  }

  Map<String, Object?> toDatabase() => {
        'entreprise': entreprise,
        'poste': poste,
        'statut': statut.name,
        'notes': notes,
        'url': url,
        'date_creation': dateCreation.toIso8601String(),
        'date_modification': dateModification.toIso8601String(),
        'prochaine_relance': prochaineRelance?.toIso8601String(),
      };

  factory Candidature.fromDatabase(Map<String, Object?> row) {
    final statutName = row['statut'] as String;
    final statut = Statut.values.where((value) => value.name == statutName);
    if (statut.isEmpty) {
      throw FormatException('Statut de candidature inconnu : $statutName');
    }

    return Candidature(
      id: row['id'] as int?,
      entreprise: row['entreprise'] as String,
      poste: row['poste'] as String,
      statut: statut.first,
      notes: row['notes'] as String? ?? '',
      url: row['url'] as String? ?? '',
      dateCreation: DateTime.parse(row['date_creation'] as String),
      dateModification: DateTime.parse(
        row['date_modification'] as String? ??
            row['date_creation'] as String,
      ),
      prochaineRelance: row['prochaine_relance'] == null
          ? null
          : DateTime.parse(row['prochaine_relance'] as String),
    );
  }
}
