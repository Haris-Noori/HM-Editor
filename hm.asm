

include irvine32.inc
include macros.inc
INCLUDELIB user32.lib
;includelib irvine32.lib

BufSize = 80		; defining buffer size

.data
	buffer BYTE BufSize DUP(?),0,0
	stdInHandle DWORD ?
	bytesRead   DWORD ?

.code 

main PROC

    call ClrScr
    mGotoxy 30, 8
    mWrite "|------------------------------|"
    mGotoxy 30, 9
    mWrite "| HM Text Editor                    |"
    mGotoxy 30, 10
    mWrite "| Developed by:                |"
    mGotoxy 30, 11
    mWrite "|                              |" 
    mGotoxy 30, 12
    mWrite "| M.Haris Noori P17-6003       |"
    mGotoxy 30, 13
    mWrite "| Mubeen Ghauri P17-6107       |"
    mGotoxy 30, 14
    mWrite "|------------------------------|"
    mGotoxy 50, 20

    call WaitMsg
    call ClrScr

    call initTextArea
    call GetInput

exit

main endp

initTextArea PROC 

	mGotoxy 30, 2
	mWrite "Start Entering Text !!!"
	mGotoxy 0, 5

	ret

initTextArea ENDP

; GetKeyInput PROC 

; 	; Taking input using readkey

; 	mov ecx, BufSize
; 	mov ebx, 0

; 	getInput:

; 		;call readkey
; 		jz nextKey

; 		mov buffer[ebx], al
; 		call writechar
; 		call crlf


; 		nextKey:


; 	loop getInput

; GetKeyInput ENDP

GetInput PROC

	; Get handle to standard input
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdInHandle,eax

	; Wait for user input
	INVOKE ReadConsole, stdInHandle, ADDR buffer,
	  BufSize, ADDR bytesRead, 0

	; Display the buffer
	;mov  esi,OFFSET buffer
	;mov  ecx,16	; 16 bytes
	;mov  ebx,TYPE buffer
	;call DumpMem


	;printing buffer

	call crlf 
	call crlf

	mov edx, offset buffer
	call writestring
	call crlf
	mov eax, bytesRead
	call writedec

	ret
GetInput ENDP

end main