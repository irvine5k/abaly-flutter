import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/template_field.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import '../cubit/create_template_cubit.dart';
import '../cubit/create_template_state.dart';

class CreateTemplatePage extends StatefulWidget {
  const CreateTemplatePage({super.key});

  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddFieldDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => _AddFieldDialog(
        onAdd: (field) => context.read<CreateTemplateCubit>().addField(field),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<CreateTemplateCubit>().createTemplate(
          name: _nameController.text,
          organizationId: authState.user.organizationId,
          createdBy: authState.user.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTemplateCubit, CreateTemplateState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CreateTemplateStatus.success) {
          context.pop();
        } else if (state.status == CreateTemplateStatus.error &&
            state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Template')),
        body: BlocBuilder<CreateTemplateCubit, CreateTemplateState>(
          builder: (context, state) {
            final isLoading = state.status == CreateTemplateStatus.loading;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Template name is required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fields',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: isLoading ? null : _showAddFieldDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Field'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.fields.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('No fields added yet')),
                    )
                  else
                    ...state.fields.asMap().entries.map((entry) {
                      final index = entry.key;
                      final field = entry.value;
                      return _FieldListItem(
                        field: field,
                        onDelete: isLoading
                            ? null
                            : () => context
                                .read<CreateTemplateCubit>()
                                .removeField(index),
                      );
                    }),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Template'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldListItem extends StatelessWidget {
  const _FieldListItem({
    required this.field,
    required this.onDelete,
  });

  final TemplateField field;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(field.label),
        subtitle: Text(field.type.name),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _AddFieldDialog extends StatefulWidget {
  const _AddFieldDialog({required this.onAdd});

  final ValueChanged<TemplateField> onAdd;

  @override
  State<_AddFieldDialog> createState() => _AddFieldDialogState();
}

class _AddFieldDialogState extends State<_AddFieldDialog> {
  final _labelController = TextEditingController();
  FieldType _selectedType = FieldType.text;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAdd(
      TemplateField(label: _labelController.text.trim(), type: _selectedType),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Field'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Field Label',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Label is required';
                }
                return null;
              },
              autofocus: true,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FieldType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Field Type',
                border: OutlineInputBorder(),
              ),
              items: FieldType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) setState(() => _selectedType = type);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
