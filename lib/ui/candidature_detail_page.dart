import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_form_page.dart';

class CandidatureDetailPage extends StatelessWidget {
  const CandidatureDetailPage({
    required this.controller,
    required this.candidature,
    super.key,
  });

  final CandidatureController controller;
  final Candidature candidature;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final actuelle = controller.trouverParId(candidature.id) ?? candidature;
        return Scaffold(
          appBar: AppBar(title: const Text('Détail de la candidature')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                actuelle.poste,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                actuelle.entreprise,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _ligne('Statut', actuelle.statut.libelle),
              _ligne('Créée le', _date(actuelle.dateCreation)),
              _ligne('Modifiée le', _date(actuelle.dateModification)),
              if (actuelle.prochaineRelance != null)
                _ligne('Prochaine relance', _date(actuelle.prochaineRelance!)),
              if (actuelle.url.isNotEmpty) _ligne('URL', actuelle.url),
              if (actuelle.notes.isNotEmpty) _ligne('Notes', actuelle.notes),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _supprimer(context, actuelle),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _modifier(context, actuelle),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ligne(String titre, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(valeur),
        ],
      ),
    );
  }

  Future<void> _modifier(
    BuildContext context,
    Candidature actuelle,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CandidatureFormPage(
          controller: controller,
          initiale: actuelle,
        ),
      ),
    );
  }

  Future<void> _supprimer(
    BuildContext context,
    Candidature actuelle,
  ) async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la candidature ?'),
        content: Text(
          'La candidature chez ${actuelle.entreprise} sera supprimée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true || !context.mounted || actuelle.id == null) return;
    try {
      await controller.supprimer(actuelle.id!);
      if (context.mounted) Navigator.of(context).pop();
    } catch (erreur) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.erreur ?? 'Suppression impossible : $erreur',
          ),
        ),
      );
    }
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
