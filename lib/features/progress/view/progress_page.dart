import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/template_field.dart';
import '../cubit/progress_cubit.dart';
import '../cubit/progress_state.dart';
import 'progress_chart.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  final String patientId;
  final String patientName;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().loadChartableFields(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientName} — Progress'),
      ),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state.status == ProgressStatus.loading &&
              state.chartableFields.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProgressStatus.error &&
              state.chartableFields.isEmpty) {
            return Center(
              child: Text(
                state.error ?? 'Failed to load data',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }

          if (state.chartableFields.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No chartable fields found.\n\n'
                  'Create templates with frequency or percentage '
                  'fields and complete sessions to see progress.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FieldSelector(
                fields: state.chartableFields,
                selectedField: state.selectedField,
                onSelected: (field) {
                  context.read<ProgressCubit>().selectField(field);
                },
              ),
              const SizedBox(height: 16),
              _SessionFilterBar(
                currentFilter: state.sessionFilter,
                onChanged: (filter) {
                  context.read<ProgressCubit>().setSessionFilter(filter);
                },
              ),
              const SizedBox(height: 24),
              if (state.selectedField == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text('Select a behavior to view progress'),
                  ),
                )
              else if (state.status == ProgressStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.dataPoints.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text('No data available'),
                  ),
                )
              else
                ProgressChart(
                  dataPoints: state.dataPoints,
                  fieldType: state.selectedField!.type,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldSelector extends StatelessWidget {
  const _FieldSelector({
    required this.fields,
    required this.selectedField,
    required this.onSelected,
  });

  final List<TemplateField> fields;
  final TemplateField? selectedField;
  final ValueChanged<TemplateField> onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TemplateField>(
      initialValue: selectedField,
      decoration: const InputDecoration(
        labelText: 'Behavior',
        border: OutlineInputBorder(),
      ),
      items: fields.map((field) {
        return DropdownMenuItem(
          value: field,
          child: Text('${field.label} (${field.type.name})'),
        );
      }).toList(),
      onChanged: (field) {
        if (field != null) onSelected(field);
      },
    );
  }
}

class _SessionFilterBar extends StatelessWidget {
  const _SessionFilterBar({
    required this.currentFilter,
    required this.onChanged,
  });

  final SessionFilter currentFilter;
  final ValueChanged<SessionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SessionFilter>(
      segments: const [
        ButtonSegment(
          value: SessionFilter.last7,
          label: Text('Last 7'),
        ),
        ButtonSegment(
          value: SessionFilter.last30,
          label: Text('Last 30'),
        ),
        ButtonSegment(
          value: SessionFilter.all,
          label: Text('All'),
        ),
      ],
      selected: {currentFilter},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}
