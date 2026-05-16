import 'package:flutter/material.dart';
import 'package:prueba_proyecto/api/train_api.dart';
import 'package:prueba_proyecto/models/workout_models.dart';
import 'package:prueba_proyecto/screens/create_workout_modal.dart';
import 'package:prueba_proyecto/screens/workout_detail_screen.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api, required this.store});

  final TrainApi api;
  final WorkoutStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _fabExpanded = false;
  String _welcome = 'Bienvenido';

  @override
  void initState() {
    super.initState();
    _loadWelcome();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _loadWelcome() async {
    final name = await widget.api.loadUserDisplayName();
    if (!mounted) return;
    setState(() {
      _welcome = name == null || name.isEmpty ? 'Bienvenido' : 'Hola, $name';
    });
  }

  Future<void> _reload() async {
    await widget.store.refreshFromApi();
    if (!mounted) return;
    if (widget.store.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar los workouts: ${widget.store.lastError}')),
      );
    }
  }

  Future<void> _logout() async {
    await widget.api.clearSession();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  Future<void> _openCreateModal() async {
    final created = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.82),
      builder: (context) => CreateWorkoutModal(store: widget.store),
    );
    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrenamiento creado.'),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final workouts = widget.store.workouts;
        final loading = widget.store.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _welcome,
              style: const TextStyle(
                color: AppColors.neon,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.neon,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: _logout,
                icon: const Icon(Icons.person_outline, color: AppColors.neon, size: 28),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, color: AppColors.neon, size: 28),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: loading && workouts.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.neon))
              : workouts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 56,
                              color: AppColors.neon.withOpacity(0.35),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Aún no hay entrenamientos',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.neon.withOpacity(0.85),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pulsa los tres puntos y crea tu primer workout.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.neon.withOpacity(0.55),
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.neon,
                      onRefresh: _reload,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: workouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final w = workouts[index];
                          return _WorkoutListTile(
                            workout: w,
                      onTap: () async {
                        final deleted = await Navigator.of(context).push<bool>(
                          MaterialPageRoute<bool>(
                            builder: (_) => WorkoutDetailScreen(
                              workout: w,
                              store: widget.store,
                            ),
                          ),
                        );
                        if (!mounted) return;
                        if (deleted == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Entrenamiento eliminado.'),
                              backgroundColor: AppColors.card,
                            ),
                          );
                        }
                      },
                          );
                        },
                      ),
                    ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_fabExpanded) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() => _fabExpanded = false);
                      _openCreateModal();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.neon, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neon.withOpacity(0.35),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Create workout',
                        style: TextStyle(
                          color: AppColors.neon,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                GestureDetector(
                  onTap: () => setState(() => _fabExpanded = !_fabExpanded),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neon, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neon.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.more_horiz, color: AppColors.neon, size: 32),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutListTile extends StatelessWidget {
  const _WorkoutListTile({
    required this.workout,
    required this.onTap,
  });

  final Workout workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.neon, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withOpacity(0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                    color: AppColors.neon,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  workout.dateLabel,
                  style: TextStyle(
                    color: AppColors.neon.withOpacity(0.75),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.neon.withOpacity(0.45)),
                const SizedBox(height: 8),
                Text(
                  '${workout.blocks.length} bloque${workout.blocks.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: AppColors.neon.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
