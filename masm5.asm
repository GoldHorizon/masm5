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

;*****************;
; *** STRUCTS *** ;
;*****************;
StringNode struct
	ptrNextNode		dword		0
	ptrHeap			dword		0
	ptrString		dword		0
StringNode ends

;****************;
; *** MACROS *** ;
;****************;

;
; mListAddNode
;
mListAddNode macro stringAddr:req, index:=<-1>
	local stringLength, return, insertNode, tempIndex
.data
	stringLength	dword	?
	tempIndex		dword	0
.code
	pushad
	;Create node
	mov tempIndex, index
	mov ebx, stringAddr
	mov ebp, 0
	
	.If (tempIndex != -1 && tempIndex != 0 && ptrListHead != 0 && ptrListTail != 0)
		mov ebp, ptrListHead
		mov ecx, tempIndex
		
		dec ecx
		
		.While (ecx > 0)
			.If ([StringNode ptr[ebp]].ptrNextNode == 0)
				jmp insertNode
			.EndIf
			dec ecx
			mov ebp, [StringNode ptr[ebp]].ptrNextNode
			
		.Endw
	.EndIf
	
insertNode:
	invoke HeapAlloc, hMainHeap, HEAP_ZERO_MEMORY, SIZEOF StringNode
	mov edi, eax
	.If (eax == 0)
		mWrite "ERROR: Cannot create new node. Aborting..."
		jmp return
	.ElseIf (ptrListHead == 0 && ptrListTail == 0)
		mov ptrListHead, eax
		mov ptrListTail, eax
	.Else
		.If (tempIndex == -1)
			mov esi, ptrListTail
			mov ptrListTail, eax
			mov ecx, [StringNode ptr [esi]].ptrNextNode
			mov [StringNode ptr [eax]].ptrNextNode, ecx
			mov [StringNode ptr [esi]].ptrNextNode, eax
		.ElseIf (tempIndex == 0)
			mov esi, ptrListHead
			mov ptrListHead, eax
			mov [StringNode ptr [eax]].ptrNextNode, esi
		.Else
			mov esi, [StringNode ptr [ebp]].ptrNextNode
			mov [StringNode ptr [ebp]].ptrNextNode, eax
			mov [StringNode ptr [eax]].ptrNextNode, esi
		.EndIf
	.EndIf
	mov esi, eax

	mStrLength ebx
	inc eax
	mov stringLength, eax

	invoke HeapCreate, 0, 0, stringLength

	.If (eax == 0)
		mWrite "ERROR: Cannot allocate heap for string linked list node. Aborting..."
		invoke HeapFree, hMainHeap, 0, edi
		jmp return
	.EndIf

	mov [StringNode ptr[esi]].ptrHeap, eax
	
	;Allocate the memory (DONE)
	invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, stringLength
	.If (eax == 0)
		mWrite "ERROR: Cannot allocate memory for string. Aborting..."
		invoke HeapFree, hMainHeap, 0, edi
		jmp return
	.EndIf
	mov [StringNode ptr [esi]].ptrString, eax
	mStrMove ebx, [StringNode ptr[esi]].ptrString
	
	inc listSize
	
return:
	popad
endm

;
; mListRemoveNode
;
mListRemoveNode macro index:req
	local return, nodePtr, outputError
.data
	nodePtr		dword		0							; Pointer to the current node
.code
	pushad
	
	mov ecx, index										;
	mov eax, ptrListHead								;
	mov nodePtr, eax									;
	mov esi, nodePtr									;
	mov edx, 0											;

	.While (ecx > 0)									;

		mov eax, [StringNode ptr [esi]].ptrNextNode		;
		mov nodePtr, eax								;
		
		.If (nodePtr == 0)								;
			jmp outputError								;
		.EndIf											;
		
		dec ecx											;
		mov edx, esi									;
		mov esi, nodePtr								;
	.Endw
	
	.If (esi == ptrListHead)							;
		mov edi, [StringNode ptr [esi]].ptrNextNode		;
		.If (esi == ptrListTail)						;
			mov ptrListTail, edi						;
		.EndIf
		mov ptrListHead, edi							;
	.ElseIf (esi == ptrListTail)						;
		mov [StringNode ptr [edx]].ptrNextNode, 0		;
		mov ptrListTail, edx							;
	.Else
		mov edi, [StringNode ptr [esi]].ptrNextNode		;
		mov [StringNode ptr [edx]].ptrNextNode, edi		;
		;mov ptrListTail, edx
	.EndIf
	
	;Free string memory as well
	invoke HeapFree, [StringNode ptr[esi]].ptrHeap, 0, [StringNode ptr[esi]].ptrString
	invoke HeapDestroy, [StringNode ptr[esi]].ptrHeap
	
	invoke HeapFree, hMainHeap, 0, esi	; Free memory on that address of the string
	
	dec listSize
	jmp return

outputError:
	mWrite "ERROR: index out of bounds. Aborting..."

return:
	popad
endm

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
; mStrLength
;
mStrLength macro stringAddr:req
	push stringAddr
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
; mGetMenuNumber
;
mGetMenuNumber macro number:req
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
	.if (eax < 9)
		mov number, eax	
		invoke putstring, addr _newl
	.else
		invoke putstring, addr strOOB
		jmp begin
	.endif
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
	.if (eax < listSize)
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

; Pure Dynamic Heap
hMainHeap				handle	?
ptrListHead				dword	?
ptrListTail				dword	?
listSize				dword	0
; file data

buffer 					BYTE BUFFER_SIZE DUP(?)
filename				BYTE "input.txt", 0
fileHandle				HANDLE ?

; output file data 

bufSize 	 	 DWORD ($-buffer)
errMsg 			 BYTE "Cannot create file",0dh,0ah,0
outputFilename   BYTE "output.txt",0
outputFileHandle DWORD ?		; handle to output file
bytesWritten 	 DWORD ?    	; number of bytes written


; Number variables
strFirst				byte	128 dup(?)
intSize					dword	?
dLimitNum				dword	127
tempPtr					dword	?		

; ###########

byteAnswer				byte	2 dup(?)
intAnswer				dword	?

strOutput				byte 	?
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
strMainMenu6			byte	"<6> String List Memory Consumption",13,10,0
strMainMenu7			byte 	"<7> Append File",13,10,0
strMainMenu8			byte	"<8> Quit",13,10,13,10,0

intInputNum				dword	?
intStringChoice			dword	?

; *HEADER DATA*
_header		byte	9," Name: Nick Francke and Jacqueline Kubiak",13,10,\			;_header - String for the program header.
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

	invoke GetProcessHeap
	mov hMainHeap, eax
	.If (eax == 0)
		mWrite "ERROR: Couldn't get process heap (for linked list heap)! Quitting program..."
		jmp endProgram
	.EndIf

	;invoke HeapCreate, 0, 0, 4000000
	;mov hMainHeap, eax
	;.if (eax == 0)
	;	mWrite "ERROR: Not enough memory (for linked list heap)! Quitting program..."
	;	jmp endProgram
	;.endif

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
	mGetMenuNumber intInputNum
	
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
	.ElseIf (intInputNum == 6)                              ; if user enters 6: call string list memory consumption
		invoke putstring, addr strMainMenu6                 ;
		call MemoryConsumption                              ;
	.ElseIf (intInputNum == 7)                              ; if user enters 7: call append file
		invoke putstring, addr strMainMenu7                 ;
		call AppendFile		                            	;
	.ElseIf (intInputNum == 8)                              ; if user enters 8: end program
		invoke putstring, addr strMainMenu8                 ;
		call OutputFile
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
	push esi										;

	mov eax, 0
	mov ebx, 0										; moves 0 in to ebx, used for string counter
	mov ecx, 0										; moves 0 in to ecx for while loop
	
	.If (ptrListHead == 0 && ptrListTail == 0)
		mWrite "List is empty!"
		invoke putstring, addr _newl
		jmp return
	.EndIf
	
	invoke putstring, addr _newl					; output new line
	
	mov eax, 0
	
	;PURE MEMORY STUFF
	mov esi, ptrListHead
	.While (esi != 0)

		mWrite "["
		mPrintNumber ecx
		inc ecx
		mWrite "] "
		
		invoke putstring, [StringNode ptr[esi]].ptrString
		invoke putstring, addr _newl
		
		mov esi, [StringNode ptr[esi]].ptrNextNode
		
		inc eax

		.If (eax >= 30 && esi != 0)
			invoke putstring, addr strContinue						; prompts user to press any key to continue
			invoke getch											; 
			invoke putstring, addr _newl
			mov eax, 0
		.Endif

	.Endw

	pop esi
	pop ecx											; pops all registers we use to bring them back
	pop ebx											;
	pop eax
return:

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
	
inputString:
	mWrite "Enter new string (Max 127 characters): "; prompts user to enter index to add string
	invoke getstring, addr strNewString, dLimitNum	; call getInput and store input in strSecondNum
	invoke putstring, addr _newl					; print a newline
	
	; PURE MEMORY STUFF
	mListAddNode <offset strNewString>
		
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
	
	.If (ptrListHead == 0 && ptrListTail == 0)
		mWrite "ERROR: Cannot delete from empty list. Aborting..."
		invoke putstring, addr _newl
		jmp return
	.EndIf
	
chooseNumber:
	invoke putstring, addr _newl							; print a newline 
	mWrite "Please enter string index to delete: "			; prompts user to enter index of string to delete
	mGetNumber intStringChoice								; get a single number as input from the user
	mov intAnswer, eax

	mov ebx, eax											; copy the input number into ebx
	mov ecx, ebx											; ...as well as ecx
	push ecx

	mov esi, ptrListHead
	
	.while (eax > 0)
		.If ([StringNode ptr [esi]].ptrNextNode == 0)
			jmp error
		.EndIf
		mov esi, [StringNode ptr [esi]].ptrNextNode
		dec eax
	.endw

	jmp confirm
;	mov eax, [lpStrings + (ebx * 4)]						; copies the address of the specified string into eax
;	
;	.If (eax == 0)											; if the string they chose does not exist
error:
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

confirm:

		mWrite "Deleting: ["								;
		pop ecx
		mPrintNumber ecx                          		; print that we successfully deleted the string (with string number)
		push ecx
		mWrite "] "                                 		;
;		invoke putstring, [lpStrings + (ebx * 4)]   		; print the string
		invoke putstring, [StringNode ptr[esi]].ptrString
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
	mListRemoveNode intAnswer
		
                 
	invoke putstring, addr _newl
	mWrite "SUCCESSFULLY DELETED STRING ["       		;
	pop ecx
	mPrintNumber ecx                          		; print that we successfully deleted the string (with string number)
	mWrite "] "                                 		;
	invoke putstring, addr _newl
;	.Endif


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

	mov esi, ptrListHead
	.While (esi != 0)
		inc ebx
		
		mStrLength <[StringNode ptr [esi]].ptrString>
		add ebx, eax
		
		mov esi, [StringNode ptr[esi]].ptrNextNode
		
	.Endw

	invoke intasc32, addr strNewString, ebx			; convert the number of bytes to a string

	mWrite "The String List size: "				;
	invoke putstring, addr strNewString				; prints the string of how many bytes are reserved
	mWrite " bytes."								;
	
	invoke putstring, addr _newl

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
	
	.If (ptrListHead == 0 && ptrListTail == 0)
		mWrite "ERROR: List is empty, cannot edit empty list. Aborting..."
		invoke putstring, addr _newl
		jmp return
	.EndIf
	
chooseNumber:	
	invoke putstring, addr _newl	
	mWrite "Please enter string index to edit: "		; prompts user to enter index of string to edit 
	mGetNumber intStringChoice							; get a single number as input from the user
	mov ebx, eax										; copy the input number into ebx
	mov ecx, ebx										; ...as well as ecx


;	push ecx
	mov esi, ptrListHead
	
	.while (eax > 0)
		.If ([StringNode ptr [esi]].ptrNextNode == 0)
			jmp error
		.EndIf
		mov esi, [StringNode ptr [esi]].ptrNextNode
		dec eax
	.endw

	jmp confirm

;	.If (eax == 0)										; if the string they chose does not exist
error:
		invoke putstring, addr strShowInvalidInput		; Output error message 
		invoke putstring, addr strAskNewInput			; Ask if they want to choose a different number
getInput1:	
		invoke getch									; Wait for user input
		.If (al == 'y' || al == 'Y')					; if user inputs a 'y' or 'Y'
			invoke putch, al
			pop ecx	
			jmp chooseNumber							; 	then jmp to choose another number
		.Elseif (al == 'n' || al == 'N')				; if user inputs a 'n' or 'N'
			invoke putch, al
			pop ecx	
			jmp return									;	then jmp to return to the main function
		.Else											; otherwise...
			jmp getInput1								;   continue to wait for input
		.Endif	
;	.Else	
confirm:
		mWrite "["										;
		mPrintNumber ebx
		mWrite "] "                                 	;
		invoke putstring, [StringNode ptr [esi]].ptrString
		invoke putstring, addr strConfirmEdit  			; print a message to confirm edit of string
getInput2:	
		invoke getch									; Wait for user input
		.If (al == 'y' || al == 'Y')                	; if user inputs a 'y' or 'Y'
			invoke putch, al
			jmp newString                             		; 	then jmp to edit the string
		.Elseif (al == 'n' || al == 'N')            	; if user inputs a 'n' or 'N'
			invoke putch, al
			pop ecx	
			jmp chooseNumber                        	;	then jmp to return to the main function
		.Else
			jmp getInput2
		.Endif                                      	                                

;edit:	
;	invoke putstring, addr _newl						
;	mWrite "["											;
;	pop ecx												;
;	mPrintNumber ecx
;	push ecx											;
;	mWrite "] "                               			;
;		
;	push [lpStrings + (ebx * 4)]						; push the addres of the string to edit
;	call getInput										; begin editing the string
;	add esp, 4											;

newString:

	invoke putstring, addr _newl
	mWrite "Enter new string: "
	invoke getstring, addr strNewString, dLimitNum	   	; call getInput and store input in strSecondNum

	mListRemoveNode ebx
	mListAddNode <offset strNewString>, ebx
	
;	invoke putstring, addr _newl					   	; print a newline
;	
;	
;	mov esi, [lpStrings + (ebx * 4)]
;	invoke HeapFree, hHeap, 0, [lpStrings + (ebx * 4)] 	; free memory 
;	
;	mStrLength <offset strNewString>				   	; get the length of the new string
;	inc eax											   	; increment the size of the string to include null terminator
;		
;	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, eax	   	; allocate that many bytes of memory on the main heap
;	mov [lpStrings + (ebx * 4)], eax				   	; copy the address of the memory location allocated into appropriate array index
;					
;	push eax		                                   	                                     
;	push offset strNewString						   	; 
;	call String_move								   	; call string move to move our new string into the new memory location
;	add esp, 8	                                       	
;														
;	pop ecx 	
;			
;	invoke putstring, addr _newl							
;	mWrite "SUCCESSFULLY EDITED STRING ["   	       	;  
;	mPrintNumber ecx
;	mWrite "] "                              	       	;  
														
;	.Endif                                             	
														
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
	mov edx, 0										;
	
	.If (ptrListHead == 0 && ptrListTail == 0)
		mWrite "ERROR: List is empty, cannot search empty list. Aborting..."
		invoke putstring, addr _newl
		jmp return
	.EndIf
	
	invoke putstring, addr strGetTargetString		; print prompt to get a substring to search for
	invoke getstring, addr strNewString, dLimitNum	; call getInput and store input in strSecondNum
	invoke putstring, addr _newl					; print a newline

	;mov esi, esp
	;
	;.while (edx <= STRING_ARRAY_SIZE)				; while we're looking at one of the strings....
	;	.if ([lpStrings + (edx * 4)] != 0)			; ...if the string isn't empty... 
	;		push offset strNewString				;
	;		push [lpStrings + (edx * 4)]			; ... then we search through it for the substring using String_find
	;		call String_find						;
	;		add esp,8								;
    ;
	;		.if (ebx > 0)							; if we found the substring at least once,
	;			add ecx, ebx						;	then we add number found to total counter
	;			push eax							;	and we store the string number and string for later
	;			push edx							;
	;		.endif									;
	;	.endif										;
    ;
	;	dec edx										; decrement edx to look at the previous string.
	;.endw											;
	
	mov esi, ptrListHead
	
	push esp
	mov ebp, esp
	mov edi, esp
	
	.While (esi != 0)
		push offset strNewString
		push [StringNode ptr [esi]].ptrString
		call String_find
		add esp, 8
		
		.if (ebx > 0)
			add ecx, ebx
			push edx
			push eax
		.endif
		
		mov esi, [StringNode ptr [esi]].ptrNextNode
		inc edx
	.Endw

	mWrite """"										;
	invoke putstring, addr strNewString				; print the substring in quotes
	mWrite """"										;

	mov esi, 0

	.if (ecx == 0)									; if ecx is 0, we found no strings
		mWrite " was not found in any of the strings!"
		invoke putstring, addr _newl
	.else
		mWrite " successfully found "				; otherwise, output how many strings we found.
		mPrintNumber ecx
		mWrite " times:"							;
		invoke putstring, addr _newl				;
		
		.while (ebp != esp)							; while there is still something on the stack...
			mov edx, [ebp - 4]						;
			mWrite "["								;
			mPrintNumber edx
			mWrite "] "								;
			mov eax, [ebp - 8]
			invoke putstring, eax					; print the string to the screen, with capitalized substrings found
			invoke putstring, addr _newl			; 
			
			inc esi

			.If (esi >= 30 && ebp != esp)
				invoke putstring, addr strContinue						; prompts user to press any key to continue
				invoke getch											; 
				invoke putstring, addr _newl
				mov esi, 0
			.Endif

			sub ebp, 8
		.endw										;
	.endif
	
	mov esp, edi
	pop esp
	
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
				
		.If (byte ptr[[esi]+edx] == 0dh || byte ptr[[esi]+edx] == 0ah)					; if return character
			mov byte ptr[[esi]+edx], 0						; null terminator
			
			inc  edx										; increments edx for null terminator
			
			mListAddNode esi
			
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


;****************************************************************
;* Name: OutputFile							            		*
;* Purpose:														*
;*		Outputs file											*
;* Date created: May 19, 2017									*
;* Date last modified: May 21, 2017								*
;****************************************************************%
OutputFile PROC
	enter 0, 0							; push ebp and move esp into ebp
	pushad								; push all registers to save them
	
get_file_size:
	mov ebx, 1
	mov ecx, 0
	
	mov esi, ptrListHead
	.While (esi != 0)
		
		mStrLength <[StringNode ptr [esi]].ptrString>
		add ebx, eax
		add ebx, 2
		mov esi, [StringNode ptr[esi]].ptrNextNode
		
	.Endw

	invoke HeapAlloc, hMainHeap, HEAP_ZERO_MEMORY, ebx
	mov edx, eax
	push edx
	
write_to_buffer:
	mov ecx, ebx											; move file size in to buffer
	mov esi, edx											; esi: pointer to the top of the buffer
	
	mov edi, ptrListHead									; edi: pointer to the head of the list
	
	mov edx, 0												; counter
	
	.while(edi != 0)										; while 
	
		mStrMove [StringNode ptr[edi]].ptrString, esi		; source string, destination string
		mov edi, [StringNode ptr[edi]].ptrNextNode			; edi points to the next node
		
		mStrLength esi										; returns size of string in eax
		add esi, eax
		mov byte ptr [esi], 0dh
		inc esi
		mov byte ptr [esi], 0ah
		inc esi
		
	.endw													; end while
	
	mov esi, 0
	
write_to_file:

	INVOKE CreateFile,
	ADDR outputFilename, GENERIC_WRITE, DO_NOT_SHARE, NULL,
	CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0

	mov outputFileHandle,eax			; save file handle
	.If eax == INVALID_HANDLE_VALUE
	  mov  edx,OFFSET errMsg		    ; Display error message
	  call WriteString
	  pop edx
	  jmp  return
	.EndIf

	pop edx
	INVOKE WriteFile,		; write text to file
	outputFileHandle,		; file handle
	edx,					; lpStrings pointer	
    ebx,					; number of bytes to write
	ADDR bytesWritten,		; number of bytes written
	0						; overlapped execution flag

	INVOKE CloseHandle, outputFileHandle

	
return:
	INVOKE HeapFree, hMainHeap, 0, edx
	popad													; restore all registers from the stack
	leave                              						; restore esp and pop ebp
	ret					
  
OutputFile ENDP

end			; End of program
