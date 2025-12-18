import 'package:flutter/material.dart';
import '../models/booking.dart';
import 'booking_form_page.dart';

class EditBookingPage extends StatelessWidget {
	final Booking booking;

	const EditBookingPage({super.key, required this.booking});

	@override
	Widget build(BuildContext context) {
		// Reuse BookingFormPage in editing mode with initialBooking provided
		// This will load all the existing booking data (mountain name, members, porter requirement, etc.)
		return BookingFormPage(
			initialBooking: booking,
			isEditing: true,
		);
	}
}
