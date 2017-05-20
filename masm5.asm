;***********************************************************************************************;
;						 																		;
;  	 Name: Nick Francke	and Jacqueline Kubiak													;
;   Class: CS3B MW 12 PM																		;
;     Lab: MASM5																				;
;    Date: 5/15/17																				;
; Purpose:																						;
;																								;
;***********************************************************************************************;

	.486								; Identifies program as 32-bit
	.model flat,stdcall					; Selects memory model (flat) and calling convention (stdcall) 
	.stack 4096							; Reserves 4096 bytes of memory on the stack
	;option casemap : none				; Forces code to be case-sensitive

	ExitProcess 		PROTO, dwExitCode:dword 									; Prototype for ExitProcess function
	intasc32 			PROTO, lpStringToHold:dword, dVal:dword						; Prototype for int to ascii 32 bit function
	intasc32Comma 		PROTO, lpStringToHold:dword, dVal:dword						; Like above, with commas where necessary
	ascint32 			PROTO, lpStringToConvert:dword								; ascii to int 32 bit function, stores in EAX
	putstring 			PROTO, lpStringToDisp:dword									; Displays string to console
	hexToChar 			PROTO, lpDestString:dword, lpSrcString:dword, lpLength:word	; Changes a string of hexes to characters
	getch 				PROTO														; Gets a single character from keyboard buffer
	getche 				PROTO														; Gets a character and writes it to the screen
	putch 				PROTO, bVal:byte											; Prints a character to the screen
	getstring			PROTO, lpStringToGet:dword, dLength:dword					; Gets a string from keyboard
	memoryallocBailey   PROTO, dNumBytes:dword

; Definitions using EQU for _string1.asm
String_equals EQU String_equals@0
String_equalsIgnoreCase EQU String_equalsIgnoreCase@0
String_copy EQU String_copy@0
String_substring_1 EQU String_substring_1@0
String_substring_2 EQU String_substring_2@0
String_charAt EQU String_charAt@0
String_startsWith_1 EQU String_startsWith_1@0
String_startsWith_2 EQU String_startsWith_2@0
String_endsWith EQU String_endsWith@0

; Definitions using EQU for _string2.asm
String_indexOf_1 EQU String_indexOf_1@0
String_indexOf_2 EQU String_indexOf_2@0
String_indexOf_3 EQU String_indexOf_3@0
String_lastIndexOf_1 EQU String_lastIndexOf_1@0
String_lastIndexOf_2 EQU String_lastIndexOf_2@0
String_lastIndexOf_3 EQU String_lastIndexOf_3@0
String_concat EQU String_concat@0
String_replace EQU String_replace@0
String_toUpperCase EQU String_toUpperCase@0
String_toLowerCase EQU String_toLowerCase@0

; Included libraries
include Irvine32.inc
include Macros.inc

;include /masm32/include/kernel32.inc
;include /masm32/include/masm32.inc
includelib /masm32/lib/kernel32.lib
includelib /masm32/lib/masm32.lib
includelib /masm32/lib/user32.lib
includelib Irvine32.lib

; Tell the program each of these procedures are found in a different file.
extern String_equals:Near32, String_equalsIgnoreCase:Near32, String_copy:Near32, String_substring_1:Near32, String_substring_2:Near32, String_charAt:Near32, String_startsWith_1:Near32, String_startsWith_2:Near32, String_endsWith:Near32

extern String_indexOf_1:Near32, String_indexOf_2:Near32, String_indexOf_3:Near32, String_lastIndexOf_1:Near32, String_lastIndexOf_2:Near32, String_lastIndexOf_3:Near32, String_concat:Near32, String_replace:Near32, String_toUpperCase:Near32, String_toLowerCase:Near32

;****************;
; *** MACROS *** ;
;****************;

;
; mPrintNumber
;
mPrintNumber macro num:req
	local strNum
	.data
	strNum				byte	16 dup(0)
	.code
	invoke intasc32, addr strNum, num
	invoke putstring, addr strNum
	
endm

;
; mGetLength
;
mStrLength macro string:req
	push offset string
	call String_length
	add esp, 4
endm

;
; mStrMove
;
mStrMove macro srcStr:req, dstStr:req
	push dstStr
	push srcStr
	call String_move
	add esp, 8
endm

;
; mGetNumber
;
mGetNumber macro number:req
	local strInputNum, strGetNumber, strError, begin, finish, strOOB
	.data
	strInputNum				byte	16 dup(0)
	strGetNumber			byte	"Please enter your choice: ",0
	strError				byte	13,10,"ERROR: Please enter a number: ",0
	strOOB					byte	13,10,"ERROR: Index out of bounds. Enter a number: ",0
	.code
begin:
;	invoke putstring, addr strGetNumber				; output first input message
	invoke getstring, addr strInputNum, 15			; call getInput and store input in strSecondNum
	invoke ascint32, addr strInputNum
	jnc finish
	invoke putstring, addr strError
	jmp begin
	
finish:
	.if (eax < STRING_ARRAY_SIZE)
		mov number, eax	
		invoke putstring, addr _newl
	.else
		invoke putstring, addr strOOB
		jmp begin
	.endif
endm

;********************;
; *** END MACROS *** ;
;********************;

; *** CONSTANTS *** ;
STRING_ARRAY_SIZE = 200
BUFFER_SIZE 	  = 5000

	.data ; Start of the data for the driver
	
; *PROGRAM DATA*
; Heap
hHeap					handle	?
lpStrings				dword	STRING_ARRAY_SIZE	dup(?)

; file data

buffer 					BYTE BUFFER_SIZE DUP(?)
filename				BYTE "output.txt", 0
fileHandle				HANDLE ?


; Number variables
strFirst				byte	128 dup(?)
intSize					dword	?
dLimitNum				dword	127
tempPtr					dword	?		

; ###########

byteAnswer				byte	2 dup(?)
intAnswer				dword	?

strNewString			byte	128 dup(?)
strOutputStr			byte	31 dup(?)
newLine30				byte	30 dup(10,13),0

strGetFirstString		byte	"Enter your string: ", 0
strGetNewString			byte	"Enter your new string: ", 0
strShowInvalidInput		byte	"Error! Invalid input/No string found!",13,10,0
strShowFullMsg			byte 	"**ERROR String Manager is FULL, please delete a string before adding.",0
strAskNewInput			byte	"Would you like to enter a new input? Y/N: ",0
strGetTargetString		byte	"Please enter the target string: ",0
strConfirmDeletion		byte	" CONFIRM DELETION Y/N: ",0
strConfirmEdit			byte	" CONFIRM EDIT Y/N: ", 0
strContinue				byte 	10,"Press any key to continue...", 0
strShowFinalMsg			byte	13,10,"Thanks for using my program!",13,10,13,10,0

strMainMenu				byte 	"MENU",13,10,13,10,0
strMainMenu1			byte	"<1> View all strings",13,10,0
strMainMenu2			byte	"<2> Add string",13,10,0
strMainMenu3			byte	"<3> Delete string",13,10,0
strMainMenu4			byte	"<4> Edit string",13,10,0
strMainMenu5			byte	"<5> String search",13,10,0
strMainMenu6			byte	"<6> String Array Memory Consumption",13,10,0
strMainMenu7			byte 	"<7> Append File",13,10,0
strMainMenu8			byte	"<8> Quit",13,10,13,10,0

intInputNum				dword	?
intStringChoice			dword	?

; *HEADER DATA*
_header		byte	9," Name: Nick Francke and Jacqueline Kubiak",13,10,\	;_header - String for the program header.
					9,"Class: CS3B MW 12 PM",13,10,\
					9,"  Lab: MASM3",13,10,\
					9," Date: 4/19/17",13,10,10,0
_newl		byte	10,13,0									;_newl   - String for a new line (carriage return and line feed)
_tab		byte	9,0										;_tab	 - String for a tab character
_bksp		byte	8,32,8,0								;_bksp	 - String for a backspace character

	.code ; Start of program code
;*********************************************************************************
;
;	_start
;
;*********************************************************************************
_start: ; Beginning of main procedure

	mov eax, 0												; Set first line of code to move 0 into eax
	invoke putstring, addr _header							; Outputs the header at top of output

	; *PROGRAM CODE*
begin:
	mov eax,0												; eax will store our numbers for math operations
	mov ebx,0												; ebx holds the address we put our input into
	mov ecx,0												; ecx acts as our input loop counter
	mov edx,0												; edx will keep track of which input we are getting
	
	invoke HeapCreate, 0, 0, STRING_ARRAY_SIZE * 256
	mov hHeap, eax

	.if (eax == 0)
		mWrite "ERROR: Not enough memory! Quitting program..."
		jmp endProgram
	.endif

mainMenu:

	invoke putstring, addr strMainMenu						; print main menu to screen
	invoke putstring, addr strMainMenu1						; 
	invoke putstring, addr strMainMenu2						;
	invoke putstring, addr strMainMenu3						;
	invoke putstring, addr strMainMenu4						;
	invoke putstring, addr strMainMenu5						;
	invoke putstring, addr strMainMenu6						;
	invoke putstring, addr strMainMenu7						;
	invoke putstring, addr strMainMenu8						;
	
	mWrite "Please enter your choice: "						; prompts user to enter index of string to edit 
	mGetNumber intInputNum
	
	.If (intInputNum == 1)                                  ; if user enters 1: call view all strings
		invoke putstring, addr strMainMenu1                 ;
		call ViewAllStrings                                 ;
	.ElseIf (intInputNum == 2)                              ; if user enters 2: call add string
		invoke putstring, addr strMainMenu2                 ;
		call AddString                		
	.ElseIf (intInputNum == 3)                              ; if user enters 3: call view remove string
		invoke putstring, addr strMainMenu3                 ;
		call RemoveString                                   ;
	.ElseIf (intInputNum == 4)                              ; if user enters 4: call edit string
		invoke putstring, addr strMainMenu4                 ;
		call EditString                                     ;
	.ElseIf (intInputNum == 5)                              ; if user enters 5: call search string
		invoke putstring, addr strMainMenu5                 ;
		call SearchString
	.ElseIf (intInputNum == 6)                              ; if user enters 6: call string array memory consumption
		invoke putstring, addr strMainMenu6                 ;
		call MemoryConsumption                              ;
	.ElseIf (intInputNum == 7)                              ; if user enters 7: call append file
		invoke putstring, addr strMainMenu7                 ;
		call AppendFile		                            	;
	.ElseIf (intInputNum == 8)                              ; if user enters 8: end program
		invoke putstring, addr strMainMenu8                 ;
		jmp endProgram                                      ;
	.Endif                                                  ;
	
	invoke putstring, addr strContinue						; prompts user to press any key to continue
	invoke getch											; 
	invoke putstring, addr newLine30						; prints 30 new lines
	jmp mainMenu
		
endProgram:
	invoke HeapDestroy, hHeap
	invoke putstring, addr strShowFinalMsg 					; output final goodbye message

	; *END PROGRAM CODE*

	invoke ExitProcess,0		; Send exit process message to OS
	public _start				; Makes _start a public entry point

;************************************************
;
;	String_length
;		+String_length(string1:String):int	
;
;	Find the length of the string passed in, and
;	returns the length of it into eax. Searches
;	for the strings null terminator to determine
;	it's length.
;
;************************************************
String_length proc

string EQU [ebp+8]

	enter 0, 0				; Push ebp
	; push ebp				; Save esp into ebp
	; mov ebp, esp			;
	; sub esp, 0			;
	push esi				; Save esi

	mov esi, string			; Move address of string into esi
	mov eax, 0				; Initialize eax with 0

checkChar:
	cmp byte ptr [esi], 0	; Check if the character is a null terminator
	je returnLength			; 	If so, return the length of the string
	inc esi					; If not, increment the string pointer
	inc eax					; ... and increment the character counter
	jmp checkChar			; loop back to check next character
	
returnLength:
	pop esi					; Restore esi
	leave					; Restore ebp
	; pop ebp
	ret 
String_length endp

;****************************************************************
;* Name: String_move								            *
;* Purpose:														*
;*		The purpose of the method is to move a string from one  *
;*	address to another, assuming they're the same size.			*
;* Date created: Apri1 26, 2017									*
;* Date last modified: April 26, 2017							*
;*																*
;****************************************************************%
String_move PROC

	enter 0,0						;pushes EBP and saves ESP into EBP
	pushad
	
	mov  esi, [ebp+8]
	mov  edi, [ebp+12]	
	
copyChar:
	cmp byte ptr [esi], 0			;compares character in string to check for null terminator
	je  returnString				;if it is, jumps to returnString
	
	mov bl, byte ptr [esi]			;moves the character into its own byte register bl
	mov byte ptr [edi], bl			;moves contents of bl to make copy of string
	
	inc esi							;increments esi
	inc edi							;increments edi
	jmp copyChar					;loops back to copy next character in string
	
returnString:
	mov byte ptr [edi], 0

	popad
	leave
	ret

String_move ENDP

;****************************************************************
;* Name: ViewAllStrings								            *
;* Purpose:														*
;*		The purpose of the method is to view all strings		*
;*																*
;* Date created: May 03, 2017									*
;* Date last modified: May 03, 2017								*
;****************************************************************%
ViewAllStrings PROC

	enter 0,0

	push eax										; How many strings have already been printed
	push ebx									 	; pushes registers being used 
	push ecx										;

	mov eax, 0
	mov ebx, 0										; moves 0 in to ebx, used for string counter
	mov ecx, 0										; moves 0 in to ecx for while loop
	
	invoke putstring, addr _newl					; output new line
		
	.WHILE (ecx < (STRING_ARRAY_SIZE * 4))								; start while, output line for each string 
	
	mWrite "["
	mPrintNumber ebx
	mWrite "] "
	
	.If ([lpStrings+ecx] != 0)						; will only output string if it exists
	invoke putstring, dword ptr [lpStrings+ecx]		; output string
	.Endif
	inc eax
	
	invoke putstring, addr _newl					; output new line

	.If (eax >= 30)
		invoke putstring, addr strContinue						; prompts user to press any key to continue
		invoke getch											; 
		invoke putstring, addr _newl
		mov eax, 0
	.Endif
		
	
	add ecx, 4										; increments ecx by 4
	inc ebx											; increments count for output
	
	.ENDW											; end while

	pop ecx											; pops all registers we use to bring them back
	pop ebx											;
	pop eax

	leave
	ret

ViewAllStrings ENDP

;****************************************************************
;* Name: AddString									            *
;* Purpose:														*
;*		Allows the user to pick a string to insert into, and 	*
;*	then type the string they want to add.						*
;*																*
;* Date created: May 03, 2017									*
;* Date last modified: May 07, 2017								*
;****************************************************************%
AddString PROC
	enter 0, 0										; pushes ebp and moves esp into ebp
	pushad											; push all registers to save them
	
	mov ebx, 0										; moves 0 in to ebx 
	
	.WHILE(ebx < STRING_ARRAY_SIZE)					; loops through each index of string array to check if empty
		.If([lpStrings + (ebx * 4)] == 0)			; if string is empty, jumps to input new string
			jmp inputString							;	
		.Else										; else, increment ebx to check next string
			inc ebx									;
		.EndIf
	.ENDW
	
	invoke putstring, addr strShowFullMsg			; outputs string full error message
	jmp return										; jump to return
	
inputString:
	mWrite "Enter new string (Max 127 characters): "; prompts user to enter index to add string
	invoke getstring, addr strNewString, dLimitNum	; call getInput and store input in strSecondNum
	invoke putstring, addr _newl					; print a newline
	
	mStrLength strNewString							; get the length of the new string
	inc eax											; increment the size of the string to include null terminator

	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax	; allocate that many bytes of memory on the main heap
	mov [lpStrings + (ebx * 4)], eax				; copy the address of the memory location allocated into appropriate array index

	push eax										; 
	push offset strNewString						; 
	call String_move								; call string move to move our new string into the new memory location
	add esp, 8										;
		
return:
	popad											; restore all registers from the stack
	leave											; restore esp and pop ebp
	ret
AddString ENDP

;****************************************************************
;* Name: RemoveString								            *
;* Purpose:														*
;*		Asks the user to select a string, and allows them to	*
;*	delete the string if they wish.								*
;*																*
;* Date created: May 03, 2017									*
;* Date last modified: May 07 , 2017							*
;****************************************************************%
RemoveString PROC
	enter 0, 0												; push ebp and move esp into ebp
	pushad													; push all registers to save them
	
chooseNumber:
	invoke putstring, addr _newl							; print a newline 
	mWrite "Please enter string index to delete: "			; prompts user to enter index of string to delete
	mGetNumber intStringChoice								; get a single number as input from the user
	mov ebx, eax											; copy the input number into ebx
	mov ecx, ebx											; ...as well as ecx
	push ecx

	mov eax, [lpStrings + (ebx * 4)]						; copies the address of the specified string into eax

	.If (eax == 0)											; if the string they chose does not exist
		
		invoke putstring, addr strShowInvalidInput			; Output error message 
		invoke putstring, addr strAskNewInput				; Ask if they want to choose a different number
getInput1:
		invoke getch										; Wait for user input
		.If (al == 'y' || al == 'Y')						; if user inputs a 'y' or 'Y'
			invoke putch, al
			pop ecx
			jmp chooseNumber								; 	then jmp to choose another number
		.Elseif (al == 'n' || al == 'N')					; if user inputs a 'n' or 'N'
			invoke putch, al
			pop ecx
			jmp return										;	then jmp to return to the main function
		.Else												; otherwise...
			jmp getInput1									;   continue to wait for input
		.Endif
	.Else
		mWrite "Deleting: ["								; 
		invoke putch, cl                            		; print the number of string we're deleting
		mWrite "] "                                 		;
		invoke putstring, [lpStrings + (ebx * 4)]   		; print the string
		invoke putstring, addr strConfirmDeletion   		; print a message to confirm deletion of string
getInput2:
		invoke getch										; Wait for user input
		.If (al == 'y' || al == 'Y')                		; if user inputs a 'y' or 'Y'
			jmp delete                              		; 	then jmp to delete the string
		.Elseif (al == 'n' || al == 'N')            		; if user inputs a 'n' or 'N'
			pop ecx
			jmp chooseNumber                        		;	then jmp to return to the main function
		.Else
			jmp getInput2
		.Endif                                      
delete:
		invoke HeapFree, hHeap, 0, [lpStrings + (ebx * 4)]	; Free memory on that address of the string
		mov [lpStrings + (ebx * 4)], 0              		; move a zero into the pointer to that string
                     
		invoke putstring, addr _newl
		mWrite "SUCCESSFULLY DELETE STRING ["       		;
		pop ecx
		mPrintNumber ecx                          		; print that we successfully deleted the string (with string number)
		mWrite "] "                                 		;
		invoke putstring, addr _newl

	.Endif

return:
	popad													; restore all registers from the stack
	leave                                           		; restore esp and pop ebp
	ret
RemoveString ENDP

;****************************************************************
;* Name: MemoryConsumption							            *
;* Purpose:														*
;*		Shows the user how many bytes of memory are consumed	*
;*	by the strings in the program.								*
;* Date created: May 03, 2017									*
;* Date last modified: May 07 , 2017							*
;****************************************************************%
MemoryConsumption PROC
	enter 0, 0										; push ebp and move esp into ebp
	pushad											; push all registers to save them
	
	mov ecx, 0										; which string we're looking at
	mov ebx, 0										; how many bytes we've counted so far

	.while (ecx < STRING_ARRAY_SIZE)								; while our index < array size...
		.if ([lpStrings + (ecx * 4)] != 0)			; if the string we're looking at isn't empty...
			inc ebx									; then, inc ebx to count the null terminator

			push [lpStrings + (ecx * 4)]			; 
			call String_length						; also find the length of that string
			add esp,4								;

			add ebx, eax							; ...and add it to the total as well
		.endif

		inc ecx										; then increment which string we're looking at with ecx
	.endw

	invoke intasc32, addr strNewString, ebx			; convert the number of bytes to a string

	mWrite "The String Array size: "				;
	invoke putstring, addr strNewString				; prints the string of how many bytes are reserved
	mWrite " bytes."								;

return:
	popad											; restore all registers from the stack
	leave                                           ; restore esp and pop ebp
	ret
  
MemoryConsumption ENDP

;****************************************************************
;* Name: EditString									            *
;* Purpose:														*
;*		Allows the user to pick a string to edit, and 			*
;*	then type the new string									*
;*																*
;* Date created: May 07, 2017									*
;* Date last modified: May 08, 2017								*
;****************************************************************%
EditString PROC
	enter 0, 0											; pushes ebp and moves esp into ebp
	pushad												; push all registers to save them
		
chooseNumber:	
	invoke putstring, addr _newl	
	mWrite "Please enter string index to edit: "		; prompts user to enter index of string to edit 
	mGetNumber intStringChoice							; get a single number as input from the user
	mov ebx, eax										; copy the input number into ebx
	mov ecx, ebx										; ...as well as ecx
	push ecx	
	
	mov eax, [lpStrings + (ebx * 4)]					; copies the address of the specified string into eax
	
	.If (eax == 0)										; if the string they chose does not exist
		invoke putstring, addr strShowInvalidInput		; Output error message 
		invoke putstring, addr strAskNewInput			; Ask if they want to choose a different number
getInput1:	
		invoke getche									; Wait for user input
		.If (al == 'y' || al == 'Y')					; if user inputs a 'y' or 'Y'
			pop ecx	
			jmp chooseNumber							; 	then jmp to choose another number
		.Elseif (al == 'n' || al == 'N')				; if user inputs a 'n' or 'N'
			pop ecx	
			jmp return									;	then jmp to return to the main function
		.Else											; otherwise...
			jmp getInput1								;   continue to wait for input
		.Endif	
	.Else	
		mWrite "["										;
		mPrintNumber ecx
		mWrite "] "                                 	;
		invoke putstring, [lpStrings + (ebx * 4)]   	; print the string
		invoke putstring, addr strConfirmEdit  			; print a message to confirm edit of string
getInput2:	
		invoke getch									; Wait for user input
		.If (al == 'y' || al == 'Y')                	; if user inputs a 'y' or 'Y'
			invoke putch, al
			jmp edit                              		; 	then jmp to edit the string
		.Elseif (al == 'n' || al == 'N')            	; if user inputs a 'n' or 'N'
			invoke putch, al
			pop ecx	
			jmp chooseNumber                        	;	then jmp to return to the main function
		.Else
			jmp getInput2
		.Endif                                      	                                
edit:	
	invoke putstring, addr _newl						
	mWrite "["											;
	pop ecx												;
	mPrintNumber ecx
	push ecx											;
	mWrite "] "                               			;
		
	push [lpStrings + (ebx * 4)]						; push the addres of the string to edit
	call getInput										; begin editing the string
	add esp, 4											;
	
	;invoke getstring, addr strNewString, dLimitNum	   	; call getInput and store input in strSecondNum
		
	invoke putstring, addr _newl					   	; print a newline
	
	
	mov esi, [lpStrings + (ebx * 4)]
	invoke HeapFree, hHeap, 0, [lpStrings + (ebx * 4)] 	; free memory 
	
	mStrLength strNewString							   	; get the length of the new string
	inc eax											   	; increment the size of the string to include null terminator
		
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax	   	; allocate that many bytes of memory on the main heap
	mov [lpStrings + (ebx * 4)], eax				   	; copy the address of the memory location allocated into appropriate array index
					
	push eax		                                   	                                     
	push offset strNewString						   	; 
	call String_move								   	; call string move to move our new string into the new memory location
	add esp, 8	                                       	
														
	pop ecx 	
			
	invoke putstring, addr _newl							
	mWrite "SUCCESSFULLY EDITED STRING ["   	       	;  
	mPrintNumber ecx
	mWrite "] "                              	       	;  
														
	.Endif                                             	
														
return:                                                	
	popad											   	; restore all registers from the stack
	leave											   	; restore esp and pop ebp
	ret                                                
	
EditString ENDP

;****************************************************************
;* Name: SearchString								            *
;* Purpose:														*
;*		Allows the user to search for a specific substring in	*
;*	all strings.												*
;*																*
;* Date created: May 03, 2017									*
;* Date last modified: May 07 , 2017							*
;****************************************************************%
SearchString PROC
	enter 0, 0										; push ebp and move esp into ebp
	pushad											; push all registers to save them

	mov ecx, 0										; sets our counter to 0
	mov edx, STRING_ARRAY_SIZE						; sets which string we're looking at in the array
	dec edx
	
	invoke putstring, addr strGetTargetString		; print prompt to get a substring to search for
	invoke getstring, addr strNewString, dLimitNum	; call getInput and store input in strSecondNum
	invoke putstring, addr _newl					; print a newline

	mov esi, esp

	.while (edx <= STRING_ARRAY_SIZE)								; while we're looking at one of the strings....
		.if ([lpStrings + (edx * 4)] != 0)			; ...if the string isn't empty... 
			push offset strNewString				;
			push [lpStrings + (edx * 4)]			; ... then we search through it for the substring using String_find
			call String_find						;
			add esp,8								;

			.if (ebx > 0)							; if we found the substring at least once,
				add ecx, ebx						;	then we add number found to total counter
				push eax							;	and we store the string number and string for later
				push edx							;
			.endif									;
		.endif										;

		dec edx										; decrement edx to look at the previous string.
	.endw											;

	mWrite """"										;
	invoke putstring, addr strNewString				; print the substring in quotes
	mWrite """"										;

	.if (ecx == 0)									; if ecx is 0, we found no strings
		mWrite " was not found in any of the strings!"
		invoke putstring, addr _newl
	.else
		mWrite " successfully found "				; otherwise, output how many strings we found.
		mPrintNumber ecx
		mWrite " times:"							;
		invoke putstring, addr _newl				;
		
		.while (esi != esp)							; while there is still something on the stack...
			pop edx									; pop edx to print the string number
			mWrite "["								;
			mPrintNumber edx
			mWrite "] "								;
			pop eax									; pop eax to get the address for the string
			invoke putstring, eax					; print the string to the screen, with capitalized substrings found
			invoke putstring, addr _newl			; 
		.endw										;
	.endif
	
return:
	popad											; restore all registers from the stack
	leave                                           ; restore esp and pop ebp
	ret
SearchString ENDP

;******************************************
;
;	getInput
;
;	This procedure takes in an address from ebx, which holds the address
;	of the variable we want to input into.  The character types until a
;	max limit is hit, dLimitNum for numeric strings, and returns the
;	user input through edx.
;
;******************************************
getInput proc												; Start of the GetInput procedure

	stringInitial EQU [ebp+8]
	
	enter 0,0
	push eax												; push eax to stack to save current value
	push ecx												; push ecx to stack to save current value
	push esi												; push esi
	
	mov esi, stringInitial									; move the initial string into esi
	
	mov ecx, 0
		
	invoke putstring, stringInitial							; print the string so it can be edited
	
	.WHILE (byte ptr [esi+ecx] != 0)						; for each character in the string,
		mov al, byte ptr [esi+ecx]							; copy the character into al
		push eax											; and push the character to the stack to save it.
		inc ecx												; then increment ecx to go to next character
	.ENDW
		
input:
	invoke getch											; use getch to get a single character (WITHOUT PRINTING)
	cmp al, 08h												; check if our input is a backspace
	jz addOnBS												; ...if it is, jump to handle the backspace
	cmp al, 0Dh												; check if our input is an enter
	jz addOnEnter											; ...if it is, jump to handle the enter
	cmp ecx, dLimitNum										; check the length of our current string
	jz input												; ...if it is 10 characters long, do nothing, wait for more input
	invoke putch, AL										; now, output the regular character we typed it
	inc cl													; add 1 to the counter of the string length
	push eax												; push our inputted character to the stack
	jmp input												; go back to wait for more input
	
addOnBS:
	cmp cl, 0												; if our string has no characters in it (length of 0)
	jz input												; ...then do nothing, jump back to grab more input
	invoke putstring, addr _bksp							; output a backspace character
	dec cl													; subtract the length of the string by 1
	pop eax													; pop the last character that was on the stack
	jmp input												; go back to wait for more input

addOnEnter:
	add cl, 1												; increase our string length by 1
	push 0													; push a 0 to the stack (to be on the back of the string)
	invoke putstring, addr _newl							; output a newline

decode:
	pop eax													; pop the stack, store last chracter into eax
	mov byte ptr [strNewString + ecx - 1], al						; move the character byte from al to the location in memory
															;   pointed to by ebx, plus the length of the string
	loop decode												; loop through until the string has no characters left
	
	pop esi
	pop ecx													; restore original value of ecx from stack
	pop eax													; restore original value of eax from stack

	leave
	ret														; return back to calling procedure
getInput endp												; End of getInput procedure

;************************************************
;
;	String_indexOf_3
;		+String_indexOf_3(string:String,str:String):int  
;
;	Returns the index within this string of the
;	first occurrence of the specified substring.
;	Returns the size of the string if not found.
;
;************************************************
String_find proc

string  EQU [ebp+8]
charStr EQU [ebp+12]

	enter 0, 0

	push esi						; Src-string pointer
	push edi						; Sub-string pointer
	push ecx						; Temp main string pointer
	push edx						; length of string

	mov esi, string					; moves the main string into esi		
	mov edi, charStr				; moves the substring into edi
	
	mov ebx, 0
	
	push esi						; push main string
	call String_length				; ... so we can get the length of it
	add esp,4						;
	inc eax							; add one for null terminator
	
	invoke memoryAllocBailey, eax	; allocate memory for temporary string to print
	mStrMove esi, eax				; copy the original string into the new allocated memory
	mov esi, eax					; make esi point to the new string as well now
	
	push edi						; push substring
	call String_length              ; ... so we can get the length of it
	add esp,4                       ;
	mov dl, al                      ; move the length into dl
	
	mov eax, esi
	
checkFirstChar:
	mov ecx, esi											; copy the pointer of the string into ecx
	mov bl, byte ptr [edi]									; move the character of the first index of substring into bl
	.If (byte ptr [esi] >= 97 && byte ptr [esi] <= 122)		; check if the current character of the main string is not capitalized
		.If (bl >= 65 && bl <= 90)							; 	if it is, and our substring character isn't...
			add bl, 32										;	...change it to match
		.EndIf												;
	.ElseIf (byte ptr [esi] >= 65 && byte ptr [esi] <= 90)	; otherwise if the current character IS capitalized...
		.If (bl >= 97 && bl <= 122)							;	then we check if the substring isn't
			sub bl, 32										;	...if it isn't, make it match
		.EndIf												;
	.EndIf													;	this way, comparisons are all case IN-sensitive
	
	.If (byte ptr [esi] == 0)								; if the byte in the main string is zero...
		jmp returnResults									;	we are at the end, so return
	.ElseIf (byte ptr [esi] == bl)							; if the byte matches the substring character...
		jmp checkNext										;	jump to check the next character
	.EndIf													; if these aren't true, nothing matches so far....
	inc esi													; ... so we increment the main string to look at next character
	jmp checkFirstChar										; jmp back to begin again

checkNext:
	inc esi													; inc esi, look at next char in main string
	inc edi													; inc edi, look at next char in substring
	mov bl, byte ptr [edi]									; move the character of the first index of substring into bl          
	.If (byte ptr [esi] >= 97 && byte ptr [esi] <= 122)		; check if the current character of the main string is not capitalized
		.If (bl >= 65 && bl <= 90)							; 	if it is, and our substring character isn't...                  
			add bl, 32										;	...change it to match                                            
		.EndIf												;                                                                     
	.ElseIf (byte ptr [esi] >= 65 && byte ptr [esi] <= 90)	; otherwise if the current character IS capitalized...                
		.If (bl >= 97 && bl <= 122)							;	then we check if the substring isn't                             
			sub bl, 32										;	...if it isn't, make it match                                    
		.EndIf												;                                                                     
	.EndIf													;	this way, comparisons are all case IN-sensitive                  
	
	.If (byte ptr [edi] == 0)								;	if the substring char is a null terminator, we found a substring!
		inc bh												; increase counter
		jmp substringFound									; jump to deal with the substring found
	.ElseIf (byte ptr [esi] == bl)							;	otherwise if the characters at least match, we still MIGHT have a match
		jmp checkNext										; so jump to check the next chaaracter
	.EndIf													;
	mov edi, charStr										; if we didn't find a match, we mov edi back to the beginning of the sub string
	jmp checkFirstChar										; then jump back to check the first character again
			
substringFound:
	mov dh, dl
	.while (dh > 0)											; since we found our substring, copy dl (length of substring) into dh
		.if (byte ptr [ecx] >= 97 && byte ptr [ecx] <= 122)	; loop through dh, and check if the character is lowercase
			sub byte ptr [ecx], 32							;	if so, subtract 32, to make characters in substring uppercase!
		.endif												;
		inc ecx												; increment ecx (which character in main string we're changing)
		dec dh												; decrement dh to say we changed another character in the substring
	.endw
	
	mov edi, charStr										; when we changed the whole substring, reset edi back to beginning of substring
	jmp checkFirstChar										; jmp to go check the first character of the string again.

returnResults:
	mov bl, bh												; copy the amount of substrings found into bl
	mov bh, 0												; reset bh to 0

	pop edx
	pop ecx
	pop edi
	pop esi
	
	leave
	ret
String_find endp

;****************************************************************
;* Name: AppendFile							            		*
;* Purpose:														*
;*		Appends file											*
;* Date created: May 17, 2017									*
;* Date last modified: May 17 , 2017							*
;****************************************************************%
AppendFile PROC
	enter 0, 0							; push ebp and move esp into ebp
	pushad								; push all registers to save them
	
	mov ecx, 0							; which string we're looking at
	mov ebx, 0							; how many bytes we've counted so far
;	mov edx, 0

; Let user input a filename.
;	mWrite "Enter an input filename: "
;	mov	edx,OFFSET filename
;	mov	ecx,SIZEOF filename
;	call	ReadString

; Open the file for input.
	mov	edx, OFFSET filename								;
	call	 OpenInputFile									;
	mov	fileHandle,eax										;
					
; Check for errors.					
	cmp	eax, INVALID_HANDLE_VALUE							; error opening file?
	jne	file_ok												; no: skip
	mWrite <"Cannot open file",0dh,0ah>					
	jmp	return												; and quit
	
file_ok:										
; Read the file into a buffer.					
	mov	edx, OFFSET buffer									;
	mov	ecx, BUFFER_SIZE									;
	call	 ReadFromFile									;
	jnc	check_buffer_size									; error reading?
	mWrite "Error reading file. "							; yes: show error message
	call	WriteWindowsMsg					
	jmp	close_file					
						
check_buffer_size:					
	cmp	eax,BUFFER_SIZE										; buffer large enough?
	jb	buf_size_ok											; yes
	mWrite <"Error: Buffer too small for the file",0dh,0ah>	;
	jmp	close_file											; and quit
						
buf_size_ok:						
	mov	buffer[eax],0										; insert null terminator
	invoke putstring, addr _newl							; insert new line
	mWrite "File size: "									;
	call	WriteDec										; display file size
	call	Crlf					
					
; Display the buffer.					
	mWrite <"Buffer:",0dh,0ah,0dh,0ah>						;
	mov	edx, OFFSET buffer									; display the buffer
	call	 WriteString									;
	call	 Crlf	

; Add string
	mov ecx, eax
	
	mov eax, offset buffer
	mov esi, eax
	
	mov edx, 0
	mov ebx, 0
	
	.while(edx <= ecx)										; while counter is less than or equal to file size
	
		.while(ebx < STRING_ARRAY_SIZE)						; loops through each index of string array to check if empty
			.If([lpStrings + (ebx * 4)] == 0)				; if string is empty, jumps to input new string
				jmp inputString								;	
			.Else											; else, increment ebx to check next string
				inc ebx										;
			.EndIf
		.endw
		
		invoke putstring, addr strShowFullMsg				; outputs string full error message
		jmp close_file										; jump to return
		
		inputString:
		.If (byte ptr[[esi]+edx] == 0dh || byte ptr[[esi]+edx] == 0ah)					; if return character
			mov byte ptr[[esi]+edx], 0						; null terminator
			
			inc  edx										; increments edx for null terminator
			push edx
			invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, edx	; allocate that many bytes of memory on the main heap
			mov [lpStrings + (ebx * 4)], eax				; copy the address of the memory location allocated into appropriate array 
			
			push eax										; 
			push esi										; 
			call String_move								; call string move to move our new string into the new memory location
			add esp, 8										;	
		
			pop edx
			.If (byte ptr [[esi] + edx] == 0ah)
				inc esi
			.EndIf
			add esi, edx
			mov edx, 0
		.ElseIf (byte ptr[[esi]+edx] == 0)
			jmp close_file
		.Else 												;	
			inc edx											; increment edx
		.EndIf												;
	.endw													; end while
	
	
close_file:					
	mov	eax, fileHandle										; 
	call	 CloseFile										;
					
return:					
	popad													; restore all registers from the stack
	leave                              						; restore esp and pop ebp
	ret					
  
AppendFile ENDP

end			; End of program
