#program za konverziju iz internog razlomljenog u znakovni oblik (oktalni brojni sistem)
#Autor: Bojan Delic e11510
.section .data
.section .text
.globl conv4
in2okt_razl:
    push %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax  #broj za konverziju
    movl 12(%ebp), %esi  #adresa stringa
    movl 16(%ebp), %ecx  #duzina
    cmpl $1, %ecx
    jle greska
    movl $8, %ebx      #baza
    movl $100000000, %edi
okt_br:
    andl %eax, %eax
    jz kraj
    xorl %edx, %edx      # 0->edx
    mull %ebx
    divl %edi
    addb $'0', %al
    cmpl $1, %ecx
    jz kraj
    decl %ecx
    movb %al, (%esi)
    movl %edx, %eax
    incl %esi
    jmp okt_br
greska:
    movl $1, %eax
kraj:
    movb $0, (%esi)
    pop %ebp
    ret
