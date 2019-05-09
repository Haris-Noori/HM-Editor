;GHAURI        HARIS
;BufSize       BUFSIZE
;buffer        buffer
;stdInHandle   fileHnadle
;bytesRead     bytesRead 


include irvine32.inc
include macros.inc
INCLUDELIB user32.lib
;includelib irvine32.lib

;________________________DATA SEGMENT_______________________________________|
.data

    MAX = 128                    ;max chars to read
    stringIn BYTE MAX+1 DUP (?)  ;room for null  
    msg BYTE "Code run time: ",0  


    ;DATA for output file..................................
    BUFSIZE = 5000
    buffer BYTE BUFSIZE DUP(?)
    stdInHandle DWORD ?
    bytesRead DWORD ?

    errMsg BYTE "Cannot open file",0dh,0ah,0
    filename     BYTE "haris.txt",0
    fileHandle   DWORD ?	; handle to output file
    byteCount    DWORD ?    	; number of bytes written
    ;.....................................................

    key BYTE ?

;___________________________CODE SEGMENT_____________________________________|
.code 
main PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    call GetMseconds
    mov ebx, eax

    call ClrScr
    mGotoxy 30, 8
    mWrite "|------------------------------|"
    mGotoxy 30, 9
    mWrite "| HM Editor                    |"
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
    ;mGotoxy 50, 20

    ;program loading....
    mGotoxy 35, 15   
    mov  eax,1000 
    call Delay
    mWrite "Loading ."
    mov  eax,1000 
    call Delay
    mWrite " ."
    call Delay
    call ClrScr

    mGotoxy 15, 1
    mWriteLn "Do you want to read from file- (Y/N) ?"
    call ReadChar
    mov key, al

    cmp key, "Y"            ;READ OR WRITE
    je read_from_file
    jmp write_in_file




    write_in_file:
    ;...WRITE FILE CODE STARTS HERE.......................................................
      call initTextArea
      call GetInput


      jmp QuitNow
    ;...WRITE FILE CODE ENDS HERE.......................................................

    read_from_file:       
    ;READ FILE CODE STARTS HERE.......................................................
      call GetOutput
    
    ;............READ FILE CODE ENDS HERE........................................................

    QuitNow:
    mGotoxy 0, 18
    mWriteLn "Press Enter to exit the Program "
    call WaitMsg
    call ClrScr

    
    call crlf
    mov edx, OFFSET msg
    call WriteString

    call GetMseconds
    sub eax, ebx
    call WriteInt


exit
main ENDP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

initTextArea PROC;..................................

	mGotoxy 30, 2
	mWrite "Start Entering Text !!!"
	mGotoxy 0, 5

	ret

initTextArea ENDP;.......................................

GetInput PROC;.....................................................

	; Get handle to standard input
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdInHandle,eax

	; Wait for user input
	INVOKE ReadConsole, stdInHandle, ADDR buffer,
	  BUFSIZE, ADDR bytesRead, 0

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
GetInput ENDP;....................................................

GetOutput PROC;..................................................................

  INVOKE CreateFile,
	  ADDR filename, GENERIC_READ, DO_NOT_SHARE, NULL,
	  OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0

    mov fileHandle,eax		; save file handle
    .IF eax == INVALID_HANDLE_VALUE
      mov  edx,OFFSET errMsg		; Display error message
      call WriteString
      ret
      ;jmp  QuitNow
    .ENDIF

    INVOKE ReadFile,		; write text to file
	    fileHandle,		; file handle
	    ADDR buffer,		; buffer pointer
	    bufSize,		; number of bytes to write
	    ADDR byteCount,		; number of bytes written
	    0		; overlapped execution flag

    INVOKE CloseHandle, fileHandle

    mov esi,byteCount		; insert null terminator
    mov buffer[esi],0		; into buffer
    mov edx,OFFSET buffer		; display the buffer
    call WriteString

    ret
GetOutput ENDP;.......................................................................

end main