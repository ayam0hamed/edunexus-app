import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_bloc.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_event.dart';
import 'package:grad_project/features/meetings/presentation/bloc/meeting_state.dart';
import 'package:intl/intl.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meetingTitleController = TextEditingController();
  final _courseTitleController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _meetingTitleController.dispose();
    _courseTitleController.dispose();
    _durationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime!.format(context);

    context.read<MeetingBloc>().add(
          CreateMeetingEvent(
            meetingTitle: _meetingTitleController.text.trim(),
            courseTitle: _courseTitleController.text.trim(),
            date: dateStr,
            time: timeStr,
            duration: _durationController.text.trim(),
            maxAttendees: _maxAttendeesController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule New Meeting',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocListener<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state is MeetingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Trigger a refresh before navigating back
            context.read<MeetingBloc>().add(const RefreshMeetingsEvent());
            Navigator.pop(context, true);
          } else if (state is MeetingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: BlocBuilder<MeetingBloc, MeetingState>(
          builder: (context, state) {
            final isLoading = state is MeetingLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meeting Title
                        _buildLabel('Meeting Title', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _meetingTitleController,
                          decoration: _inputDecoration(
                            'e.g.,Chapter tow of Fundamentals of AI',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Meeting title is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Course Title
                        _buildLabel('Course Title', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _courseTitleController,
                          decoration: _inputDecoration(
                            'e.g., Introduction to Fundamentals of AI',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Course title is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Date & Time row
                        Row(
                          children: [
                            // Date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16,
                                          color: Colors.black.withOpacity(0.7)),
                                      const SizedBox(width: 4),
                                      _buildLabel('Date', isRequired: true),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _selectedDate != null
                                            ? DateFormat('yyyy-MM-dd')
                                                .format(_selectedDate!)
                                            : 'Pick a date',
                                        style: TextStyle(
                                          color: _selectedDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Time
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 16,
                                          color: Colors.black.withOpacity(0.7)),
                                      const SizedBox(width: 4),
                                      _buildLabel('Time', isRequired: true),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: _pickTime,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _selectedTime != null
                                                ? _selectedTime!
                                                    .format(context)
                                                : '--:-- --',
                                            style: TextStyle(
                                              color: _selectedTime != null
                                                  ? Colors.black
                                                  : Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(Icons.access_time,
                                              size: 16,
                                              color: Colors.grey.shade400),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Duration & Max Attendees row
                        Row(
                          children: [
                            // Duration
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined,
                                          size: 16,
                                          color: Colors.black.withOpacity(0.7)),
                                      const SizedBox(width: 4),
                                      _buildLabel('Duration',
                                          isRequired: true),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _durationController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                        'write a duration'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Duration is required';
                                      }
                                      if (int.tryParse(val.trim()) == null) {
                                        return 'Must be numeric';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Max Attendees
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.groups_outlined,
                                          size: 16,
                                          color: Colors.black.withOpacity(0.7)),
                                      const SizedBox(width: 4),
                                      _buildLabel('Max Attendees',
                                          isRequired: true),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _maxAttendeesController,
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        _inputDecoration('e.g., 50'),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Max attendees is required';
                                      }
                                      if (int.tryParse(val.trim()) == null) {
                                        return 'Must be numeric';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Create Meeting button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF163D69),
                                  Color(0xFFE56C00),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _submitForm,
                              icon: const Icon(Icons.add,
                                  color: Colors.white),
                              label: const Text(
                                'Create Meeting',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cancel button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.black54),
                            label: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF163D69),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF163D69)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
