#include <reg51.h>

// 12/12 = 1 instruction per microsecond. 
// Interruption per 200 microseconds.
// 5000 * 200 microseconds = 1 second.
#define oneSecond 5000 

// Display numbers
#define zero	0xC0
#define one		0xF9
#define two	    0xA4
#define three   0xB0
#define four	0x99	
#define five	0x92
#define six	    0x82
#define seven	0xF8
#define eight	0x80
#define nine	0x90

// LEDs (0 - LED Turned on)
sbit greenLEDOff =  P1 ^ 0;
sbit redLEDOff =    P1 ^ 1;
sbit yellowLEDOff = P1 ^ 2; 

// Counters
unsigned int timerCounter1 = 0; // Increments every 200 microseconds. 5000 = 1 second has passed. Resets after a second. Yellow LED blinks every second.
unsigned int timerCounter2 = 0; // Increments every second.
unsigned int peopleLeft = 9; // Amount of people that can still enter the establishment.

// Buttons
bit button1Pressed = 0;	// Button 1 state
bit button2Pressed = 0; // Button 2 state

void Timer0Interruption(void) interrupt 1 {
	
	timerCounter1++; // Increments every 200 microseconds.
	button2Timer++; // Increments every 200 microseconds.
	
}


// External interruptions (Buttons)
void Button1Interruption (void) interrupt 0 {
		
	button1Pressed = 1;
	
}

void Button2Interruption(void) interrupt 2 {

	button2Pressed = 1;
	
}


void Initialize(void) {

	// IE Register
	EA = 1;		// Allows all interruptions
	ET0 = 1;	// Activates timer0 interruptions
	EX0 = 1;	// Activates external interruption 0
	EX1 = 1;	// Activates external interruption 1

	// TMOD Register
	TMOD &= 0xF0;	// Cleans the 4 bits from timer0 
	TMOD |= 0x02;	// Activates mode 2 from timer0 (8 bits - autoreload)

	// Timer0 Configuration
	// 256 microseconds - 56 microseconds = 200 microseconds
	// 56 = 0x38
	TH0 = 0x38;
	TL0 = 0x38;

	// TCON Register
	IT0 = 1; // Interruptions activate in falling edge
	IT1 = 1;

	// Initialize peripherals
	greenLEDOff = 1;	// Turns green LED off
	redLEDOff = 0;	// Turns red LED on
	yellowLEDOff = 0;	// Turns yellow LED on
	P2 = nine;	// Shows the number 9 on the display

	// Timer0 start
	TR0 = 1; // Starts the timer0
}


void main(void) {

	Initialize();

	for (;;) {

		if (timerCounter1 >= oneSecond) {
			
			// After each second, if the green LED is on, update timerCounter2
			// The green LED stays on for 3 seconds
			if (greenLEDOff == 0) {
				
				timerCounter2++;
			
			}
			
			// Yellow LED. Turns on if there's 5 or more people inside the establishment.
			// 5 or more people inside the establishment = 4 people or less left to enter the establishment.
			if (peopleLeft <= 4) {

				yellowLEDOff = !yellowLEDOff; // Alternates the yellow LED each second if there's more than 5 people inside the establishment.
			
			}


			// Yellow LED. Usually off unless there's 5 or more people inside the establishment.
			else {
				
				yellowLEDOff = 1; // Turns LED off there's 4 or less people inside the establishment
			
			}
			
			timerCounter1 = 0; // Reset timerCounter1

		}
		

		// Entry button pressed
		if (button1Pressed == 1) {

			switch (peopleLeft) {

				case (9):
					greenLEDOff = 0;
					redLEDOff = 1;
					P2 = eight;
					peopleLeft--;
					break;
				
				case (8):
					greenLEDOff = 0;
					redLEDOff = 1;
					P2 = seven;
					peopleLeft--;
					break;
				
				case (7):
					greenLEDOff = 0;
					redLEDOff = 1;
					P2 = six;
					peopleLeft--;
					break;

				case (6):
					greenLEDOff = 0;
					redLEDOff = 1;
					P2 = five;
					peopleLeft--;
					break;

				case (5):
					greenLEDOff = 0;	
					redLEDOff = 1;
					P2 = four;
					peopleLeft--;
					break;
				
				case (4):
					greenLEDOff = 0;	
					redLEDOff = 1;	
					P2 = three;
					peopleLeft--;
					break;
				
				case (3):
					greenLEDOff = 0;	
					redLEDOff = 1;	
					P2 = two;
					peopleLeft--;
					break;
				
				case (2):
					greenLEDOff = 0;	
					redLEDOff = 1;	
					P2 = one;
					peopleLeft--;
					break;
				
				case (1):
					greenLEDOff = 0;
					redLEDOff = 1;
					P2 = zero;
					peopleLeft--;
					break;

				case (0):
					P2 = zero;
					break;

				default:
					break;
			
		
			}
			
			button1Pressed = 0;	// Resets button1 after it is pressed

		}


		// 3 seconds have passed after button1 is pressed
		if (timerCounter2 >= 3) {

			greenLEDOff = 1; // Turns green LED off
			redLEDOff = 0; // Turns red LED on
			timerCounter2 = 0; // Reset timerCounter2

		}


		// Exit button pressed
		if (button2Pressed == 1) {

			switch (peopleLeft) {

				case (0) :
					P2 = one;
					peopleLeft++;
					break;
				
				case (1):
					P2 = two;
					peopleLeft++;
					break;

				case (2):
					P2 = three;
					peopleLeft++;
					break;
				
				case (3):
					P2 = four;
					peopleLeft++;
					break;
				
				case (4):
					P2 = five;
					peopleLeft++;
					break;
				
				case (5):
					P2 = six;
					peopleLeft++;
					break;
				
				case (6):
					P2 = seven;
					peopleLeft++;
					break;
				
				case (7):
					P2 = eight;
					peopleLeft++;
					break;
				
				case (8):
					P2 = nine;
					peopleLeft++;
					break;

				default:
					break;
		
			}

			button2Pressed = 0;	// Resets button2 after it is pressed.

		}

	}

}