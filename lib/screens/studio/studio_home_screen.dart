import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import 'package:intl/intl.dart';

class StudioHomeScreen extends StatefulWidget {
  const StudioHomeScreen({super.key});

  @override
  State<StudioHomeScreen> createState() => _StudioHomeScreenState();
}

class _StudioHomeScreenState extends State<StudioHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context
            .read<BookingProvider>()
            .loadBookings(auth.currentUser!.id, isStudio: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _CalendarTab(),
      const _BookingsTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _showBookingDialog(BuildContext context, DateTime date, String timeSlot,
      SessionType sessionType) {
    showDialog(
      context: context,
      builder: (context) => _BookingDialog(
        date: date,
        timeSlot: timeSlot,
        sessionType: sessionType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule for ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _TimeSlot(
                    time: '9:00 AM - 12:00 PM',
                    sessionType: SessionType.recording,
                    status: 'Available',
                    color: AppTheme.successColor,
                    selectedDate: _selectedDay!,
                    onTap: () => _showBookingDialog(context, _selectedDay!,
                        '9:00 AM - 12:00 PM', SessionType.recording),
                  ),
                  _TimeSlot(
                    time: '2:00 PM - 5:00 PM',
                    sessionType: SessionType.jamming,
                    status: 'Booked',
                    color: AppTheme.recordingColor,
                    selectedDate: _selectedDay!,
                  ),
                  _TimeSlot(
                    time: '6:00 PM - 9:00 PM',
                    sessionType: SessionType.recording,
                    status: 'Blocked',
                    color: AppTheme.textHint,
                    selectedDate: _selectedDay!,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final SessionType sessionType;
  final String status;
  final Color color;
  final DateTime selectedDate;
  final VoidCallback? onTap;

  const _TimeSlot({
    required this.time,
    required this.sessionType,
    required this.status,
    required this.color,
    required this.selectedDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == 'Available';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: isAvailable,
        onTap: isAvailable ? onTap : null,
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(time),
        subtitle: Text(
          '${sessionType == SessionType.recording ? 'Recording' : 'Jamming'} Session',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: color.withOpacity(0.2),
            ),
            if (isAvailable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.pendingColor;
      case BookingStatus.confirmed:
        return AppTheme.confirmedColor;
      case BookingStatus.cancelled:
        return AppTheme.cancelledColor;
      case BookingStatus.completed:
        return AppTheme.completedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.bookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online, size: 64, color: AppTheme.textHint),
                SizedBox(height: 16),
                Text('No bookings yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.bookings.length,
          itemBuilder: (context, index) {
            final booking = provider.bookings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: booking.sessionType == SessionType.recording
                        ? AppTheme.recordingGradient
                        : AppTheme.jammingGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    booking.sessionType == SessionType.recording
                        ? Icons.mic
                        : Icons.music_note,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  '${booking.sessionType == SessionType.recording ? 'Recording' : 'Jamming'} Session',
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(booking.startTime),
                ),
                trailing: Chip(
                  label: Text(
                    booking.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor:
                      _getStatusColor(booking.status).withOpacity(0.2),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:'),
                            Text(
                              'BDT ${booking.totalAmount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Paid (1/3):'),
                            Text(
                              'BDT ${booking.paidAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.successColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Remaining:'),
                            Text(
                              'BDT ${booking.remainingAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ],
                        ),
                        if (booking.paymentMethod != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Payment Method:'),
                              Chip(
                                label: Text(booking.paymentMethod!),
                                avatar: const Icon(Icons.payment, size: 16),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (booking.status == BookingStatus.pending)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    provider.updateBookingStatus(
                                      booking.id,
                                      BookingStatus.cancelled,
                                    );
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Decline'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.updateBookingStatus(
                                      booking.id,
                                      BookingStatus.confirmed,
                                    );
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Confirm'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.business, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Studio Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: 'Dhaka, Bangladesh',
                    ),
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Contact',
                      value: '+880 1234567890',
                    ),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Hours',
                      value: '9 AM - 9 PM',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
              title: const Text('Logout',
                  style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textHint,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Booking Dialog for Creating New Bookings
class _BookingDialog extends StatefulWidget {
  final DateTime date;
  final String timeSlot;
  final SessionType sessionType;

  const _BookingDialog({
    required this.date,
    required this.timeSlot,
    required this.sessionType,
  });

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _artistNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController(text: '3000');
  final _advanceController = TextEditingController(text: '1000');
  String _paymentMethod = 'bKash';

  @override
  void dispose() {
    _artistNameController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  void _createBooking() {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();

      if (auth.currentUser == null) return;

      // Parse time slot (e.g., "9:00 AM - 12:00 PM")
      final timeParts = widget.timeSlot.split(' - ');
      final startTimeStr = timeParts[0];
      final endTimeStr = timeParts[1];

      // Create DateTime objects
      final startTime = _parseTimeWithDate(widget.date, startTimeStr);
      final endTime = _parseTimeWithDate(widget.date, endTimeStr);

      final booking = BookingModel(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        studioId: auth.currentUser!.id,
        artistId:
            'artist_${DateTime.now().millisecondsSinceEpoch}', // Temporary artist ID
        sessionType: widget.sessionType,
        startTime: startTime,
        endTime: endTime,
        totalAmount: double.parse(_amountController.text),
        paidAmount: double.parse(_advanceController.text),
        status: BookingStatus.confirmed,
        notes: _notesController.text,
        createdAt: DateTime.now(),
        paymentMethod: _paymentMethod,
        transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      );

      bookingProvider.createBooking(booking);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  DateTime _parseTimeWithDate(DateTime date, String timeStr) {
    // Parse time like "9:00 AM" or "2:00 PM"
    final parts = timeStr.trim().split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1].toUpperCase() == 'PM';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Book ${widget.sessionType == SessionType.recording ? 'Recording' : 'Jamming'} Session'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateFormat('MMMM dd, yyyy').format(widget.date)}  ${widget.timeSlot}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistNameController,
                decoration: const InputDecoration(
                  labelText: 'Artist Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Total Amount (BDT)',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _advanceController,
                decoration: const InputDecoration(
                  labelText: 'Advance Payment (BDT)',
                  prefixIcon: Icon(Icons.payment),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter advance amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                items: ['bKash', 'Nagad', 'Rocket', 'Bank Transfer', 'Cash']
                    .map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createBooking,
          child: const Text('Create Booking'),
        ),
      ],
    );
  }
}
