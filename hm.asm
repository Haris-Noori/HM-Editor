;-----------------------------------------------;
;                                               ;
;               HM-Editor                       ;
;                                               ;
;   A simulation of a simple text editor        ;
;   (just like vim, nano etc)                   ;
;   Which allows you to (1) Read a file         ;
;   (2) append into a read file                 ;
;   (3) creat and edit contents of a new file   ;
;-----------------------------------------------;
;                                               ;
;   Created By : Mubeen Ghauri P17-6107         ;
;                Haris Nooori  P17-6003         ;
;                                               ;
;        As our Semester Project for:           ;
;  Computer Organization And Assembly Language  ;
;                FTY Fall 2019                  ; 
;                                               ;
;-----------------------------------------------;

include irvine32.inc
include macros.inc
INCLUDELIB user32.lib


;________________________DATA SEGMENT_______________________________________|
.data

    MAX = 128                    ;max chars to read
    stringIn BYTE MAX+1 DUP (?)  ;room for null  
    msg BYTE "Code run time: ",0  
    t1 DWORD ?


    ;        DATA for output file

    BUFSIZE = 80
    buffer BYTE BUFSIZE DUP(0)
    buffer2 BYTE BUFSIZE DUP(0)
    tempBuff BYTE BUFSIZE*2 DUP(?)
    stdInHandle DWORD ?
    bytesRead DWORD ?

    errMsg BYTE "Cannot open file",0dh,0ah,0
    filename     BYTE "input.txt",0
    file2  BYTE "output.txt",0
    fileHandle   DWORD ?	    ; handle to output file
    byteCount    DWORD ?    	; number of bytes written
   
    bytesWritten DWORD ?

    ;Data for console write------------------------------
    outHandle DWORD ?
    cellsWritten DWORD 0
    xyPos COORD <0,4>

    key BYTE ?

;___________________________CODE SEGMENT_____________________________________
.code 
main PROC
    call GetMseconds
    mov t1, eax

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

    cmp key, "y"            ;READ OR WRITE
    je read_from_file
    jmp write_in_file

    write_in_file:
    ;WRITE FILE CODE STARTS HERE
      call ClrScr
      call initTextArea
      call GetInput

    

      jmp QuitNow
    ;WRITE FILE CODE ENDS HERE

    read_from_file:       
      call ClrScr
      call GetOutput
    

    QuitNow:
      mGotoxy 0, 18
      mWriteLn "Press Enter to exit the Program "
      call WaitMsg
      call ClrScr

    
      call crlf
      mov edx, OFFSET msg
      call WriteString

      mov ebx, t1
      call GetMseconds
      sub eax, ebx
      call WriteInt


    exit
main ENDP

initTextArea PROC

    ;-----------------------------------------
    ;  procedure to initialise the console   -      
    ;  with a starting text.                 -
    ;  procedure is used in this case to     -
    ;  keep a clean main procedure           -
    ;-----------------------------------------

	mGotoxy 30, 2
	mWrite "Start Entering Text !!!"
	mGotoxy 0, 5

	ret

initTextArea ENDP

GetInput PROC;.....................................................

    ;-------------------------------------
    ;  Read contents of the console      -
    ;  load the contents into 'buffer2'  -
    ;  call writeF to write the contents -
    ;  into a specified output file      - 
    ;-------------------------------------

	; Get handle to standard input
	INVOKE GetStdHandle, STD_INPUT_HANDLE
	mov stdInHandle,eax

	; Wait for user input
	INVOKE ReadConsole, stdInHandle, ADDR buffer2,
	  BUFSIZE, ADDR bytesRead, 0

    call writeF

	ret
GetInput ENDP;....................................................

GetOutput PROC;..................................................................

    ;------------------------------------------
    ;  Read contents of file specified        -
    ;  load the contents into 'buffer'        -
    ;  call loadConsoleText to load contents  -
    ;  of buffer onto the console             -
    ;------------------------------------------

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
	    bufSize,		; number of bytes to read
	    ADDR byteCount,		; number of bytes read
	    0		; overlapped execution flag

    INVOKE CloseHandle, fileHandle

    mov esi,byteCount		; insert null terminator
    mov buffer[esi],0		; into buffer
    inc esi
    mov buffer[esi],0
    inc esi
    mov buffer[esi],0
    ;mov edx,OFFSET buffer		; display the buffer
    ;call WriteString

    call loadConsoleText

    call GetInput

    ret
GetOutput ENDP;.......................................................................


joinBuff PROC

    ;---------------------------------------
    ;  procedure to join the contents of   - 
    ;  buffer (inputFileContentsBuffer)    - 
    ;  and                                 - 
    ;  buffer2 (consoleContentsBuffer)     -
    ;  into tempBuff.                      - 
    ;  the contents of tempBuff are then   - 
    ;  written to output file              -
    ;---------------------------------------


    call crlf
    call crlf

    mov ecx, byteCount    ; number of bytes read from file

    
    mov ebx, 0
    mov edx, 0

    mov al,  buffer[edx]

    .IF al == 0
        jmp j2
    .ENDIF

    L1:
        mov al,  buffer[edx]
        mov tempBuff[ebx], al
        ;call writechar
        ;call crlf
        inc al
        inc ebx
        inc edx

        .IF al == 0
            jmp j2
        .ENDIF

        .IF ebx == byteCount
            jmp j2
        .ENDIF

        
    loop L1

    j2:
        mov al, buffer2
        mov edx, 0
        mov ecx, bytesRead          ; number of bytes read from console

        L2:
            mov al,  buffer2[edx]
            mov tempBuff[ebx], al
          ;  call writechar
            inc edx
            inc ebx


            .IF ebx == bytesRead
                jmp quitJoin
            .ENDIF

        loop l2

    quitJoin:

    mGotoxy 0,12
    mWrite "Text to be written into  output file : "
    mGotoxy 0,14

     mov edx, offset tempBuff
     call writestring
     call crlf

    ret

joinBuff ENDP

writeF PROC;---------------------------------------------
    
    ;----------------------------------------------
    ; procedure to write contents of buffer into  -
    ; a specified file                            -
    ; To be used with INVOKE directive            - 
    ;----------------------------------------------

    call joinBuff

    ; Creating file

    INVOKE CreateFile,
      ADDR file2, GENERIC_WRITE, DO_NOT_SHARE, NULL,
      CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0

    mov filehandle, eax

    ; check to see if file is created succesfuly
    ; if not then an error msg is printed to the screen

    .IF eax == INVALID_HANDLE_VALUE
      mov  edx,OFFSET errMsg        ; Display error message
      call WriteString
      jmp  QuitNow
    .ENDIF

    INVOKE WriteFile,       ; write text to file
        fileHandle,     ; file handle
        ADDR tempBuff,        ; buffer pointer
        bufSize*2,       ; number of bytes to write
        ADDR bytesWritten,      ; number of bytes written
        0       ; overlapped execution flag

    INVOKE CloseHandle, fileHandle
    
    QuitNow:

    ret

writeF ENDP

loadConsoleText PROC
    
    ;----------------------------------------------
    ; load contents of buffer to console          -
    ; used to load the contents read from file    -      
    ; to our console output                       -
    ;----------------------------------------------

    mGotoxy 30,2
    mWrite "Contents Of File : "
    

    ; Get the Console standard output handle:
    INVOKE GetStdHandle,STD_OUTPUT_HANDLE
    mov outHandle,eax

    ;Write contents of buffer to console
    INVOKE WriteConsoleOutputCharacter,
      outHandle, ADDR buffer, BufSize,
      xyPos, ADDR cellsWritten

    mGotoxy 0, 6
    mWrite "Enter Text to append into read file : "
    mGotoxy 0,8
      ret

loadConsoleText ENDP

end main