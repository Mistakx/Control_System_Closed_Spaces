; Display numbers
zero          EQU 0xC0
one           EQU 0xF9
two           EQU 0xA4
three         EQU 0xB0
four          EQU 0x99	
five          EQU 0x92
six           EQU 0x82
seven         EQU 0xF8
eight         EQU 0x80
nine          EQU 0x90

; LEDs (0 - LED Turned on)
greenLEDOff   EQU P1 ^ 0
redLEDOff     EQU P1 ^ 1
yellowLEDOff  EQU P1 ^ 2
display       EQU P2

; Counters
hundredMicroseconds EQU 0 ; R0 - Increments every 100 microseconds until reaching 100, then resets. 100 * 100 = 10 000.
tenThousandMicroseconds EQU 0 ; R1 - Increments every ten thousand microseconds until reaching 100, then resets. 10 000 * 100 = 1 000 000.
millionMicroseconds EQU 0 ; R2 - Increments every million microseconds (1 second), then resets.
threeSeconds EQU 0 ; R3 - Increments every second until reaching 3 seconds, then resets.
peopleLeft EQU 9 ; R4 - Amount of people that can still enter the establishment.

; Buttons
button1Pressed EQU 0 ; R5 - Button 1 state
button2Pressed EQU 0 ; R6 - Button 2 state


; Timer0Interruption
CSEG AT 000BH
JMP Timer0Interruption

; External Interruption 0 (Button 1)
CSEG AT 0003H
JMP ExternalInterruption0

; External Interruption 1 (Button 2)
CSEG AT 0013H
JMP ExternalInterruption1


CSEG AT 0000H
JMP Main

; Main
CSEG AT 1000H

    Main: 

    CALL Initialize

    For:

        SecondHasPassed: 

            CJNE R2, #1, EntryButtonPressed

                ; After each second, if the green LED is on, update timerCounter2
                ; The green LED stays on for 3 seconds
                GreenLEDon: 
                    JB greenLEDOff, If4OrLessPeopleCanEnter ; If greenLEDOff == 0
                    INC R3

                ; Yellow LED. Turns on if there's 5 or more people inside the establishment.
                ; 5 or more people inside the establishment = 4 people or less left to enter the establishment.

                If4OrLessPeopleCanEnter:

                FourPeopleLeft:
                    CJNE R4, #4, ThreePeopleLeft
                    CPL yellowLEDOff
                    JMP ResetMillionMicroseconds

                ThreePeopleLeft:
                    CJNE R4, #3, TwoPeopleLeft
                    CPL yellowLEDOff
                    JMP ResetMillionMicroseconds

                TwoPeopleLeft:
                    CJNE R4, #2, OnePersonLeft
                    CPL yellowLEDOff
                    JMP ResetMillionMicroseconds

                OnePersonLeft:
                    CJNE R4, #1, ZeroPeopleLeft
                    CPL yellowLEDOff
                    JMP ResetMillionMicroseconds

                ZeroPeopleLeft:
                    CJNE R4, #0, MoreThanFourPeople
                    CPL yellowLEDOff
                    JMP ResetMillionMicroseconds
                    
                ; Yellow LED. Usually off unless there's 5 or more people inside the establishment.
                MoreThanFourPeople:
                    SETB yellowLEDOff ; Turns LED off there's 4 or less people inside the establishment
                
                ResetMillionMicroseconds:
                MOV R2, #0 ; Reset millionMicroseconds


        ; Entry button Pressed
        EntryButtonPressed: 

            CJNE R5, #1, IntermedioThreeSecondsHavePassed

                EntryButtonPressedCase9:
                    CJNE R4, #9, EntryButtonPressedCase8
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #eight
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase8:
                    CJNE R4, #8, EntryButtonPressedCase7
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #seven
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase7:
                    CJNE R4, #7, EntryButtonPressedCase6
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #six
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase6:
                    CJNE R4, #6, EntryButtonPressedCase5
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #five
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase5:
                    CJNE R4, #5, EntryButtonPressedCase4
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #four
                    DEC R4
                    JMP EntryButtonSwitchEnd

                IntermedioThreeSecondsHavePassed: 
                JMP ThreeSecondsHavePassed

                IntermedioFor:
                JMP For

                EntryButtonPressedCase4:
                    CJNE R4, #4, EntryButtonPressedCase3
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #three
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase3:
                    CJNE R4, #3, EntryButtonPressedCase2
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #two
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase2:
                    CJNE R4, #2, EntryButtonPressedCase1
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #one
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase1:
                    CJNE R4, #1, EntryButtonPressedCase0
                    CLR greenLEDOff
                    SETB redLEDOff
                    MOV display, #zero
                    DEC R4
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCase0:
                    CJNE R4, #0, EntryButtonPressedCaseDefault
                    MOV display, #zero
                    JMP EntryButtonSwitchEnd

                EntryButtonPressedCaseDefault:
                    JMP EntryButtonSwitchEnd

                EntryButtonSwitchEnd:
                    MOV R5, #0 ; Resets button1 after it is pressed

        ; 3 seconds have passed after button 1 is pressed
        ThreeSecondsHavePassed: 

            CJNE R3, #3, ExitButtonPressed

                SETB greenLEDOff ; Turns green LED off
                CLR redLEDOff ; Turns red LED on
                MOV R3, #0 ; Reset threeSeconds

        ; Exit button pressed
        ExitButtonPressed: 

            CJNE R6, #1, IntermedioFor

                ExitButtonPressedCase0:
                    CJNE R4, #0, ExitButtonPressedCase1
                    MOV display, #one
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase1:
                    CJNE R4, #1, ExitButtonPressedCase2
                    MOV display, #two
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase2:
                    CJNE R4, #2, ExitButtonPressedCase3
                    MOV display, #three
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase3:
                    CJNE R4, #3, ExitButtonPressedCase4
                    MOV display, #four
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase4:
                    CJNE R4, #4, ExitButtonPressedCase5
                    MOV display, #five
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase5:
                    CJNE R4, #5, ExitButtonPressedCase6
                    MOV display, #six
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase6:
                    CJNE R4, #6, ExitButtonPressedCase7
                    MOV display, #seven
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase7:
                    CJNE R4, #7, ExitButtonPressedCase8
                    MOV display, #eight
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCase8:
                    CJNE R4, #8, ExitButtonPressedCaseDefault
                    MOV display, #nine
                    INC R4
                    JMP ExitButtonSwitchEnd

                ExitButtonPressedCaseDefault:
                    JMP ExitButtonSwitchEnd

                ExitButtonSwitchEnd:
                    MOV R6, #0 ; Resets button1 after it is pressed

    JMP IntermedioFor



; External Interruption 0 (Button 1)
ExternalInterruption0:
    MOV R5, #1
    RETI

; External Interruption 1 (Button 2)
ExternalInterruption1:
    MOV R6, #1
    RETI

; Timer0 Interruption
Timer0Interruption:

    INC R0 ; Increments hundredMicroseconds every 100 microseconds.

    ; If hundredMicroseconds hasn't reached 100, exit interruption
    CJNE R0, #100, Timer0InterruptionEnd

    ; If hundredMicroseconds has reached 100, reset it, and increment tenThousandMicroseconds
    MOV R0, #0
    INC R1 ; Increment tenThousandMicroseconds

    ; If tenThousandMicroseconds hasn't reached 100, exit interruption
    CJNE R1, #100, Timer0InterruptionEnd

    ; If tenThousandMicroseconds has reached 100, reset it, and increment millionMicroseconds
    MOV R1, #0
    INC R2 ; Increment millionMicroseconds

    Timer0InterruptionEnd: 
    RETI

; Initialize
Initialize:

    MOV R0, #hundredMicroseconds
    MOV R1, #tenThousandMicroseconds
    MOV R2, #millionMicroseconds
    MOV R3, #threeSeconds
    MOV R4, #peopleLeft
    MOV R5, #button1Pressed
    MOV R6, #button2Pressed

	; IE Register
    MOV IE, #10000111b


    ; TMOD Register
    MOV TMOD, #00000010b

    ; Timer0 Configuration
	; 256 microseconds - 156 microseconds = 100 microseconds
	; 156 = 0x9C
    MOV TH0, #0x9C
    MOV TL0, #0x9C

	; TCON Register
    SETB IT0 ; Interruptions activate in falling edge
    SETB IT1

    ; Initialize peripherals
	SETB greenLEDOff ; Turns green LED off
	CLR redLEDOff ; Turns red LED on
	CLR yellowLEDOff ; Turns yellow LED on
	MOV display, #nine ; Shows the number 9 on the display

    ; Timer0 start
	SETB TR0 ; Starts the timer0

    RET



END