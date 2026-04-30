        .section .data
promptForInput:
        .string "Enter a number to double it!: "
outputResult:
        .string "The double is: "
newline:
        .byte 10, 0

        .section .bss
input_buffer:
        .skip 10

        .section .text
        .globl _start
_start:
        #Prompt user
        movq $1, %rax   #sys_write
        movq $1, %rdi #stdout
        leaq promptForInput(%rip), %rsi #prompt user for a number
        movq $30, %rdx
        syscall

        #Read user input
        movq $0, %rax #syscall number for sys_read
        movq $0, %rdi
        leaq input_buffer(%rip), %rsi #buffer to store input
        movq $10, %rdx
        syscall

        mov %rax, %rbx #store num of bytes read

        #output message
        movq $1, %rax
        movq $1, %rdi
        leaq outputResult(%rip), %rsi
        movq $15, %rdx
        syscall

        #output result
        lea input_buffer(%rip), %rax
        call convertToInt #convert the ascii to int

        add %rax, %rax #double the num

        call convertToAscii #convert the double num back to ascii

        mov %rax, %rsi
        xor %rdx, %rdx

lengthLoop:
        #increase rdx to output enough info
        cmpb $0, (%rsi, %rdx)
        je exit
        inc %rdx
        jmp lengthLoop

exit:
        mov $1, %rax
        mov $1, %rdi
        syscall

        #newline
        movq $1, %rax
        movq $1, %rdi
        leaq newline(%rip), %rsi
        movq $1, %rdx
        syscall

        #Exit program
        mov $60, %rax
        xor %rdi, %rdi
        syscall
convertToInt:
        push %rbx
        push %rcx
        push %rdx
        push %rsi
        mov %rax, %rsi
        mov $0, %rax
        mov $0, %rcx
loop:
        #For each character in the number
        #convert the ascii representation
        #to an integer so it can be doubled
        xor %rbx, %rbx
        movb (%rsi,%rcx), %bl
        cmp $0x30, %bl  #compare the digit to ascii val of 0
        jl check
        cmp $0x39, %bl  #compare the digit to ascii val of 9
        jg check
        sub $0x30, %bl
        add %rbx, %rax  #store
        mov $10, %rbx
        mul %rbx        #Multiply by 10 to make sure its spot is saved in next loop
        inc %rcx        #cycle to next digit
        jmp loop
check:
        cmp $0, %rcx    #never looped case
        je restore
        mov $10, %rbx   #get rid of uneeded multiplication
        div %rbx
restore:
        pop %rsi
        pop %rdx
        pop %rcx
        pop %rbx
        ret
convertToAscii:
        push %rbx
        push %rcx
        push %rdx
        push %rdi

        lea input_buffer+9(%rip), %rdi
        movb $0, (%rdi) #null byte
        mov $10, %rbx
loop2:
        xor %rdx, %rdx
        div %rbx        #divide the current num in rax by 10

        add $0x30, %dl #add 0 in ascii to convert back to ascii
        dec %rdi
        mov %dl, (%rdi) #store the ascii representation

        test %rax, %rax
        jnz loop2       #keep going while not zero

        mov %rdi, %rax

        pop %rdi
        pop %rdx
        pop %rcx
        pop %rbx
        ret