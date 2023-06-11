; ------------------------------------------------------------
; Program Description : CMPR154 - Final Project
; Author: Mike Tellez, Tiffany Nguyen, Ulises Rodriguez
; Creation Date : 4/18/23
; Revisions:
; Modified by : Mike Tellez
; Collaboration: None
; Make sure to change the Config to x86
; ----------------------------------------------------------

INCLUDE Irvine32.inc

;============================================= Variables ===============================================================
.data 
									;variables go here
balance DWORD 0
MAX_ALLOWED EQU 20
amount DWORD 0
failsWithinGame DWORD 0

									;game numbers
randomNum DWORD ?   
userNum DWORD ?

									;game stats
playerNamePrompt BYTE "Enter your player name: ", 0
playerNameIs BYTE "Player: ", 0
MAX_NAME_LENGTH = 20
playerName db MAX_NAME_LENGTH dup(?)					; max charcter of 20 for player name


gamesPlayed DWORD 0
numCorrectGuess DWORD 0
numMissGuess DWORD 0
moneyWon DWORD 0
moneyLost DWORD 0

teamNameBanner BYTE "*** Team Name ***", 0
teamName BYTE "    Tapatillo     ", 0

mainMenu BYTE "*** Main Menu ***", 0
menuPrompt BYTE "Please Select one of the following: ", 0
receivePrompt BYTE "Option: ", 0

option1 BYTE "1: Display my available credits", 0
option2 BYTE "2: Add credits to my account", 0
option3 BYTE "3: Play the guessing game", 0
option4 BYTE "4: Display my statistics", 0
option5 BYTE "5: To exit", 0

error BYTE "Invalid Input!", 0

option1String	BYTE "=> Your available balance is $ ", 0
option2String	BYTE "=> Please enter the amount you would like to add: ", 0
promptBad		BYTE "Invalid input, please enter again", 0
outOfRangeString BYTE "Amount must be between $0 and $", 0
;============================================= Start of Code ===============================================================
.code
main proc
	;instructions go here

	mov edx, OFFSET teamNameBanner
	call WriteString
	call crlf
	mov edx, OFFSET teamName
	call WriteString
	call crlf
	call crlf

	;input player name
	mov edx, OFFSET playerNamePrompt
	call WriteString
	mov edx, OFFSET playerName
	mov ecx, MAX_NAME_LENGTH
	mov ebx, 0
	call ReadString
	call crlf

	call WaitMsg
	call crlf

	;------------------------------------------------- Start of end_switch ---------------------------------------------------------------------------
	;-------------------------------------------- This code displays the menu --------------------------------------------
	end_Switch: 
	mov edx, OFFSET teamNameBanner
	call WriteString
	call crlf
	mov edx, OFFSET teamName
	call WriteString
	call crlf
	call crlf

	mov edx, OFFSET playerNameIs
	call WriteString
	mov edx, OFFSET playerName
	call WriteString
	call crlf
	

	mov edx, OFFSET mainMenu
	call WriteString
	call crlf

	mov edx, OFFSET menuPrompt
	call WriteString
	call crlf
	call crlf

	; Menu options
	mov edx, OFFSET option1
	call WriteString
	call crlf
	mov edx, OFFSET option2
	call WriteString
	call crlf
	mov edx, OFFSET option3
	call WriteString
	call crlf
	mov edx, OFFSET option4
	call WriteString
	call crlf
	mov edx, OFFSET option5
	call WriteString
	call crlf
	
	mov edx, OFFSET receivePrompt
	call WriteString
	call ReadInt

	; ====================================== Start of switch case ==================================================

	cmp eax, 1					; compares eax register
	je case1
	cmp eax, 2
	je case2
	cmp eax, 3
	je case3
	cmp eax, 4
	je case4
	cmp eax, 5
	je case5
	jmp default_case

; ============================================ Cases ===============================================================

case1:
	mov edx, OFFSET option1String
	call WriteString
	mov eax, balance
	call writeInt
	call crlf
	call crlf
	jmp end_switch

case2:
	read:	
		mov edx, OFFSET option2String
		call WriteString 
		call ReadInt
		jno goodInput
		mov edx, OFFSET promptBad
		call WriteString
		call crlf
		jmp read 
	goodInput:
		mov amount, eax
		cmp eax, 0
		jl outOfRange
		cmp eax, MAX_ALLOWED
		jg outOfRange
		add balance, eax
		call crlf
		jmp end_switch
	outOfRange:
		mov edx, OFFSET outOfRangeString
		call WriteString
		mov eax, MAX_ALLOWED
		call WriteInt
		call crlf
		jmp read

case3:
	call crlf
	call gameStart				; calling game start function
	jmp end_switch

case4:
	call crlf
	call playOption4
	jmp end_switch

case5:
	call crlf
	jmp end_program

default_case:
	mov edx, OFFSET error
	call WriteString
	call crlf
	call crlf
	jmp end_switch
	
;-------------------------------------------- End of Main Code ------------------------------------------------------------------
	end_program:
	exit		; Exit the program
main endp

;**============================================= GameStart Procedure ===============================================================

gameStart PROC
    call gameBanner         ; displays the game banner

prompt: 
    mov edx, OFFSET playPrompt
    call WriteString
    call ReadChar
	
    cmp al, 'Y'            ; compares the choice to play the game
    je playGame
    cmp al, 'y'
    je playGame

    cmp al, 'N'
    je exitGame
    cmp al, 'n'
    je exitGame

playGame: 
	inc gamesPlayed			; increment games played
	
    call crlf
	mov failsWithinGame, 0

    mov ebx, [balance]                   
	cmp ebx, 0                            ; If balance is less than or equal to zero, go back to the  menu
    jle noFunds
    sub ebx, 1                            ; subtract balance if balance is greater than zero
	mov [balance], ebx
	inc moneyLost						  ;increment money lost Tracker 

    mov edx, OFFSET balanceCheck          ; display current balance
    call WriteString

    mov eax, [balance]
    call WriteInt
    call crlf
	
    mov eax, 10                         ; create a random number from 0-10
    call RandomRange
	inc eax
    mov [randomNum], eax				
	
guessNumber:
    mov edx, OFFSET enterNumber         ; retrieve user's answer
    call WriteString

    call ReadInt
    mov userNum, eax

    mov eax, userNum
    cmp eax, randomNum                    ; compare the user's guess (in eax) with the random number
    jne lostGame                          ; jump to the main menu if the guess is incorrect

    jmp gameWon

;----------------------------------------- Reveal Random Number --------------------------------------------------------------------
revealRandomNumber:
	call crlf
	mov edx, OFFSET checkRandomNum            
    call WriteString                    ; display randNum for testing *CAN MOVE LATER
    mov eax, [randomNum]                    
    call WriteDec
	jmp exitGame

;----------------------------------------- Lost Game --------------------------------------------------------------------
lostGame:
	inc numMissGuess					;increment miss guesses
	
	inc failsWithinGame
	cmp failsWithinGame, 1

	jg revealRandomNumber                 ; jump to revealRandomNumber if they failed more than 1 time
   
    mov edx, OFFSET incorrectGuess
    call WriteString
    call crlf
    call crlf
    jmp guessNumber

;----------------------------------------- No Funds --------------------------------------------------------------------
noFunds:
    call crlf
    mov edx, OFFSET noFundsPrompt
    call WriteString
    call crlf
    call crlf

    jmp exitGame

;----------------------------------------- Game Won --------------------------------------------------------------------
gameWon:
	inc numCorrectGuess				; increment correct guesses
	
	call crlf
    mov edx, OFFSET correctGuess
    call WriteString
    add [balance], 2                    ; Add 2 to the balance (in ebx)
	add moneyWon, 2

    call crlf
    jmp exitGame

;-------------------------------------------------- Exit Condition ---------------------------------------------------------
exitGame:
    call crlf
    call crlf
    mov edx, OFFSET exitMessage
    call WriteString
    call crlf
    call crlf
    ret

exitMessage BYTE "Going back to the main menu...", 0

;------------------------------------------------- GameStart Variables ------------------------------------------------------
playPrompt BYTE "Do you want to play the game? (Y/N): ", 0
enterNumber BYTE "Enter your number guess here: ", 0
balanceCheck BYTE "Your balance is $", 0

checkRandomNum BYTE "You lost the round. The random number was ",0
noFundsPrompt BYTE "Your balance has insufficient funds, going back to the main menu...", 0

correctGuess BYTE "Congratulations! You guessed the number correctly. $2 got added to your balance.", 0
incorrectGuess BYTE "You have one more try to guess the number!", 0

gameStart ENDP


;================================================== Game Banner ============================================================
gameBanner PROC

mov edx, OFFSET ruleTitle
	call WriteString
	call crlf

mov edx, OFFSET guessPrompt
	call WriteString
	call crlf

mov edx, OFFSET gameRules1
	call WriteString
	call crlf

mov edx, OFFSET gameRules2
	call WriteString
	call crlf

mov edx, OFFSET gameRules3
	call WriteString
	call crlf
	call crlf

										; after displaying the rules ask for option
mov edx, OFFSET balanceAmt
	call WriteString
	mov eax, balance
	call WriteInt
	call crlf
	call crlf

	ret									;Return procedure


;------------------------------------------------- GameBanner Variables ------------------------------------------------------------
ruleTitle BYTE "These are the game Rules: ", 0
guessPrompt BYTE "Program will generate a random number between (1-10), you must guess the correct number to win!", 0
gameRules1 BYTE "- Pay $1 to play the game.", 0
gameRules2 BYTE "- For a correct guess, user wins $2.", 0
gameRules3 BYTE "If you run out of money you lose the game.", 0

balanceAmt BYTE "Your balance is: ", 0

gameBanner ENDP

;================================================== End of Game Banner ============================================================

;================================================== play Option 4 ============================================================

playOption4 PROC


mov edx, OFFSET nameDisplay
call WriteString
mov edx, OFFSET playerName
call WriteString
call crlf

mov edx, OFFSET creditDisplay
call WriteString
mov eax, balance
call WriteInt
call crlf

mov edx, OFFSET gamesPlayedDisplay
call WriteString
mov eax, gamesPlayed
call WriteInt
call crlf

mov edx, OFFSET correctDisplay
call WriteString
mov eax, numCorrectGuess
call WriteInt
call crlf

mov edx, OFFSET missesDisplay
call WriteString
mov eax, numMissguess
call WriteInt
call crlf

mov edx, OFFSET moneyWonDisplay
call WriteString
mov eax, moneyWon
call WriteInt
call crlf

mov edx, OFFSET moneyLostDisplay
call WriteString
mov eax, moneyLost
call WriteInt
call crlf
call crlf



call WaitMsg
call ClrScr                   ; Clear the screen if needed


ret
;---------------------------------------------------- Option4 Variables -----------------------------------------------------------


nameDisplay BYTE "Player Name: ", 0	
creditDisplay BYTE "Total Credit: ", 0	
gamesPlayedDisplay BYTE "Games Played: ", 0
correctDisplay BYTE "Correct Guesses: ", 0 
missesDisplay BYTE "Missed Guesses: ", 0 
moneyWonDisplay BYTE "Money Won: $", 0
moneyLostDisplay BYTE "Money Lost: $", 0

playOption4 ENDP

END main
;============================================= End of Program ===============================================================
