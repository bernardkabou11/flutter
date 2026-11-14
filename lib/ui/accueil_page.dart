import 'package:flutter/material.dart';

import '../models/candidature.dart';
import '../state/candidature_controller.dart';
import 'candidature_detail_page.dart';
import 'candidature_form_page.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({
    required this.controller,
    this.modeDemonstrationTp1 = false,
    super.key,
  });

  final CandidatureController controller;
  final bool modeDemonstrationTp1;

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final _rechercheController = TextEditingController();
  int _onglet = 0;

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _ouvrirFormulaire() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CandidatureFormPage(controller: widget.controller),
      ),
    );
  }

  void _informerModeDemonstration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Le mode TP1 affiche deux candidatures statiques.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piste'),
        centerTitle: false,
      ),
      body: _onglet == 0 ? _construireListe() : _construireBilan(),
      floatingActionButton: _onglet == 0
          ? FloatingActionButton.extended(
              onPressed: widget.modeDemonstrationTp1
                  ? _informerModeDemonstration
                  : _ouvrirFormulaire,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (index) => setState(() => _onglet = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            label: 'Candidatures',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Bilan',
          ),
        ],
      ),
    );
  }

  Widget _construireListe() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _rechercheController,
                onChanged: widget.controller.definirRecherche,
                decoration: InputDecoration(
                  labelText: 'Rechercher une entreprise ou un poste',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _rechercheController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Effacer la recherche',
                          onPressed: () {
                            _rechercheController.clear();
                            widget.controller.definirRecherche('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: widget.controller.filtreStatut?.name ?? 'tous',
                decoration: const InputDecoration(labelText: 'Filtrer par statut'),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'tous',
                    child: Text('Tous les statuts'),
                  ),
                  ...Statut.values.map(
                    (statut) => DropdownMenuItem<String>(
                      value: statut.name,
                      child: Text(statut.libelle),
                    ),
                  ),
                ],
                onChanged: (valeur) {
                  final statut = Statut.values.where(
                    (element) => element.name == valeur,
                  );
                  widget.controller.definirFiltreStatut(
                    statut.isEmpty ? null : statut.first,
                  );
                },
              ),
            ),
            Expanded(child: _contenuListe(context)),
          ],
        );
      },
    );
  }

  Widget _contenuListe(BuildContext context) {
    return switch (widget.controller.etat) {
      EtatChargement.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      EtatChargement.error => _etatErreur(),
      EtatChargement.empty => _etatVide(),
      EtatChargement.success => _listeChargee(context),
    };
  }

  Widget _etatErreur() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(
              widget.controller.erreur ?? 'Une erreur est survenue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _reessayer,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reessayer() async {
    await widget.controller.charger();
  }

  Widget _etatVide() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucune candidature pour le moment.\nAjoutez votre première candidature.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _listeChargee(BuildContext context) {
    final candidatures = widget.controller.candidaturesFiltrees;
    if (candidatures.isEmpty) {
      return const Center(
        child: Text('Aucune candidature ne correspond à ces critères.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: candidatures.length,
      itemBuilder: (context, index) {
        final candidature = candidatures[index];
        return Card(
          child: ListTile(
            title: Text(
              candidature.poste,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${candidature.entreprise} • ${candidature.statut.libelle}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: widget.modeDemonstrationTp1
                ? null
                : () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => CandidatureDetailPage(
                        controller: widget.controller,
                        candidature: candidature,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _construireBilan() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final compteurs = widget.controller.compteursParStatut;
        final total = widget.controller.elements.length;
        final relances = widget.controller.elements
            .where((item) =>
                item.prochaineRelance != null &&
                !item.prochaineRelance!.isBefore(DateUtils.dateOnly(DateTime.now())))
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('Total des candidatures'),
                trailing: Text(
                  '$total',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Relances à venir'),
                trailing: Text(
                  '$relances',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 4),
              child: Text('Par statut'),
            ),
            ...Statut.values.map(
              (statut) => Card(
                child: ListTile(
                  title: Text(statut.libelle),
                  trailing: Text('${compteurs[statut] ?? 0}'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
