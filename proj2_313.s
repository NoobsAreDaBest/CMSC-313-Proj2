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
        cmpb $0, (%rsi, %rdx)
        je exit
        inc %rdx
        jmp lengthLoop

exit:
        #Exit program
        mov $1, %rax
        mov $1, %rdi
        syscall

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
        xor %rbx, %rbx
        movb (%rsi,%rcx), %bl
        cmp $48, %bl
        jl end
        cmp $57, %bl
        jg end
        sub $48, %bl
        add %rbx, %rax
        mov $10, %rbx
        mul %rbx
        inc %rcx
        jmp loop
end:
        cmp $0, %rcx
        je pop
        mov $10, %rbx
        div %rbx
pop:
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
        div %rbx

        add $48, %dl
        dec %rdi
        mov %dl, (%rdi)

        test %rax, %rax
        jnz loop2

        mov %rdi, %rax

        pop %rdi
        pop %rdx
        pop %rcx
        pop %rbx
        ret