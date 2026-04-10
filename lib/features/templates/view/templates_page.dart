import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/template.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/template_list_cubit.dart';
import '../cubit/template_list_state.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<TemplateListCubit>()
          .loadTemplates(authState.user.organizationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/templates/create'),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TemplateListCubit, TemplateListState>(
        builder: (context, state) {
          return switch (state) {
            TemplateListInitial() => const SizedBox.shrink(),
            TemplateListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            TemplateListLoaded(:final templates) => templates.isEmpty
                ? const Center(child: Text('No templates found'))
                : ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _TemplateCard(template: template);
                    },
                  ),
            TemplateListError(:final message) => Center(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          };
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    final fieldCount = template.fields.length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(template.name),
        subtitle: Text(
          '$fieldCount ${fieldCount == 1 ? 'field' : 'fields'}',
        ),
      ),
    );
  }
}
