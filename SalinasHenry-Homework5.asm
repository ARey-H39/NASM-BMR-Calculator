extern printf
extern scanf

        global      _start
        
        section     .text
_start:
        ;prompt for user's weight
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, weightPropmt
        mov     rdx, weightPromptLength
        syscall

        ;get user's weight
        mov     rdi, inputFormat
        mov     rsi, weight
        mov     rax, rax
        call scanf

        ;prompt for user's height
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, heightPrompt
        mov     rdx, heightPromptLength
        syscall

        ;get user's height
        mov     rdi, inputFormat
        mov     rsi, height
        mov     rax, rax
        call scanf

        ;prompt for user's age
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, agePrompt
        mov     rdx, agePromptLength
        syscall

        ;get user's age
        mov     rdi, inputFormat
        mov     rsi, age
        mov     rax, rax
        call scanf

        ;prompt for user's sex
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, sexPrompt
        mov     rdx, sexPromptLength
        syscall

        ;get user's sex
        mov     rdi, inputFormat
        mov     rsi, sex
        mov     rax, rax
        call scanf

        ;Move user input for sex into register
        mov     r12, [sex]      

        ;Check if user input equals 1, male
        mov     r13, male       ; Move male (1) to register    
        cmp     r12, r13        ; Compare user input with value 1
        je      maleBMR         ; calculate BMR for male if user input is 1

        ;Check if user input equals 2, female
        mov     r13, female     ; Move female (2) to register
        cmp     r12, r13        ; Compare user input with value 2
        je      femaleBMR       ; calculate BMR for female if user inpute is 2

        ;Jump to invalidSex if user input does not equal 1 or 0
        jmp invalidSex

; Section that sets up registers for male BMR equation and output message
maleBMR:
        ;Copy initial value of male BMR to result register
        movsd   xmm0, [INITIAL_VALUE_MALE]      ; 66

        ;Copy constants from male BMR equation to registers
        movsd   xmm4, [WEIGHT_CALC_MALE]        ; 6.3
        movsd   xmm5, [HEIGHT_CALC_MALE]        ; 12.9
        movsd   xmm6, [AGE_CALC_MALE]           ; 6.8

        ;Pass correct output message to rdi for printf later
        mov     rdi, outputMale         ; "As a male,..."

        ;Jump to BMR calculations
        jmp bmrCalc

; Section that sets up registers for female BMR equation
femaleBMR:
        ;Copy initial value of female BMR to result register
        movsd   xmm0, [INITIAL_VALUE_FEMALE]    ; 655

        ;Copy constants from female BMR equation to registers
        movsd   xmm4, [WEIGHT_CALC_FEMALE]      ; 4.3
        movsd   xmm5, [HEIGHT_CALC_FEMALE]      ; 4.7
        movsd   xmm6, [AGE_CALC_FEMALE]         ; 4.7

        ;Pass correct output message to rdi for printf later
        mov     rdi, outputFemale       ; "As a female,..."

        ;Jump to BMR calculations
        jmp bmrCalc

; Section where all BMR calculations are done
bmrCalc:
        ;convert user inouts to double values
        cvtsi2sd    xmm1, [weight]
        cvtsi2sd    xmm2, [height]
        cvtsi2sd    xmm3, [age]

        ;multiply all user inputs with their respective constants
        mulsd   xmm4, xmm1      ; ((6.3 or 4.3) * weight)
        mulsd   xmm5, xmm2      ; ((12.9 or 4.7) * height)
        mulsd   xmm6, xmm3      ; ((6.8 or 4.7) * age)

        ;Add/Subtract all numbers together
        addsd   xmm0, xmm4      ; BMI = (66 or 655) + ((6.3 or 4.3) * weight)
        addsd   xmm0, xmm5      ; BMI = BMI + ((12.9 or 4.7) * height)
        subsd   xmm0, xmm6      ; BMI = BMI - ((6.8 or 4.7) * age)

        ;Jump to output result
        jmp bmrOutput

; Section to output BMR
bmrOutput:
        mov     rsi, [height]
        mov     rdx, [weight]
        mov     rcx, [age]
        mov     rax, 1
        call printf

        jmp exitProgram

; Section for error message if user does not select male or female
invalidSex:
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, invalidInput
        xor     rdx, invalidInputLength
        syscall

        jmp exitProgram

; Section to end the program
exitProgram:
        mov     rax, SYS_EXIT
        xor     rdi, rdi
        syscall


        section     .data
;Prompts and their lengths
weightPropmt            db      "Enter your weight (lbs): "
weightPromptLength      equ     $-weightPropmt
heightPrompt            db      "Enter your height (in): "
heightPromptLength      equ     $-heightPrompt
agePrompt               db      "Enter your age: "
agePromptLength         equ     $-agePrompt
sexPrompt               db      "Enter your sex (1 for Male, 2 for Female): "
sexPromptLength         equ     $-sexPrompt

;Error message
invalidInput            db      "! Invalid input: Enter 1 for male, 2 for female", 10
invalidInputLength      equ     $-invalidInput

;User input format
inputFormat     db      "%d"

;User sex options
male    equ     1
female  equ     2

;BMR fromula constant values for females
INITIAL_VALUE_FEMALE    dq      655.0
WEIGHT_CALC_FEMALE      dq      4.3
HEIGHT_CALC_FEMALE      dq      4.7
AGE_CALC_FEMALE         dq      4.7

;BMR fomula constant values for males
INITIAL_VALUE_MALE      dq      66.0
WEIGHT_CALC_MALE        dq      6.3
HEIGHT_CALC_MALE        dq      12.9
AGE_CALC_MALE           dq      6.8

;Output messages for each sex
outputMale      db      "As a male, you would need to consume %.1f calories to maintain your weight based on your given height %d, weight %d, and age %d", 10, 0
outputFemale    db      "As a female, you would need to consume %.1f calories to maintain your weight based on your given height %d, weight %d, and age %d", 10, 0

;Identifiers for system calls
SYS_EXIT    equ     60
SYS_WRITE   equ     1
STDOUT      equ     1

        section     .bss
weight  resb    8
height  resb    8
age     resb    8
sex     resb    8
