import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';

class CandidatureFormPage extends StatefulWidget {
  const CandidatureFormPage({
    required this.controller,
    this.initiale,
    super.key,
  });

  final CandidatureController controller;
  final Candidature? initiale;

  @override
  State<CandidatureFormPage> createState() => _CandidatureFormPageState();
}

class _CandidatureFormPageState extends State<CandidatureFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _entrepriseController;
  late final TextEditingController _posteController;
  late final TextEditingController _notesController;
  late final TextEditingController _urlController;
  late Statut _statut;
  DateTime? _prochaineRelance;
  bool _enregistrement = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    final initiale = widget.initiale;
    _entrepriseController =
        TextEditingController(text: initiale?.entreprise ?? '');
    _posteController = TextEditingController(text: initiale?.poste ?? '');
    _notesController = TextEditingController(text: initiale?.notes ?? '');
    _urlController = TextEditingController(text: initiale?.url ?? '');
    _statut = initiale?.statut ?? Statut.brouillon;
    _prochaineRelance = initiale?.prochaineRelance;
  }

  @override
  void dispose() {
    _entrepriseController.dispose();
    _posteController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initiale == null
              ? 'Nouvelle candidature'
              : 'Modifier la candidature',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _entrepriseController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Entreprise *',
                border: OutlineInputBorder(),
              ),
              validator: (valeur) => _validerObligatoire(
                valeur,
                'Indiquez le nom de l’entreprise.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _posteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Poste *',
                border: OutlineInputBorder(),
              ),
              validator: (valeur) =>
                  _validerObligatoire(valeur, 'Indiquez le poste visé.'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Statut>(
              value: _statut,
              decoration: const InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(),
              ),
              items: Statut.values
                  .map(
                    (statut) => DropdownMenuItem(
                      value: statut,
                      child: Text(statut.libelle),
                    ),
                  )
                  .toList(),
              onChanged: (valeur) {
                if (valeur != null) setState(() => _statut = valeur);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL de l’offre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _choisirRelance,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _prochaineRelance == null
                    ? 'Choisir une date de relance'
                    : 'Relance le ${_date(_prochaineRelance!)}',
              ),
            ),
            if (_prochaineRelance != null)
              TextButton(
                onPressed: () => setState(() => _prochaineRelance = null),
                child: const Text('Retirer la date de relance'),
              ),
            if (_erreur != null) ...[
              const SizedBox(height: 12),
              Text(
                _erreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _enregistrement ? null : _sauvegarder,
              child: _enregistrement
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validerObligatoire(String? valeur, String message) =>
      valeur == null || valeur.trim().isEmpty ? message : null;

  Future<void> _choisirRelance() async {
    final maintenant = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _prochaineRelance ?? maintenant,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() => _prochaineRelance = date);
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enregistrement = true;
      _erreur = null;
    });

    final maintenant = DateTime.now();
    final initiale = widget.initiale;
    final candidature = Candidature(
      id: initiale?.id,
      entreprise: _entrepriseController.text.trim(),
      poste: _posteController.text.trim(),
      statut: _statut,
      notes: _notesController.text.trim(),
      url: _urlController.text.trim(),
      dateCreation: initiale?.dateCreation ?? maintenant,
      dateModification: maintenant,
      prochaineRelance: _prochaineRelance,
    );

    try {
      await widget.controller.enregistrer(candidature);
      if (mounted) Navigator.of(context).pop();
    } catch (erreur) {
      if (!mounted) return;
      setState(() {
        _erreur = 'Enregistrement impossible : $erreur';
        _enregistrement = false;
      });
    }
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
