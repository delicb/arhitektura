#potprogram za stepenovanje realnog broja u masinskoj normalizovanoj formi
#autor: Bojan Delic e11510
.section .data
.section .text
.globl StepenMNF

#makro koji registarski par edx:eax pomera u desno n puta
.macro pomeri n=0
    push %ecx          #cuvamo ecx na stek
    movl \n, %ecx

1:
    shrl $1, %edx      #pomeranje u dvostrukoj preciznosti za jedno mesto u desno
    rcrl $1, %eax
    loopl 1b          #dok god je ecx razlicit on nule

    pop %ecx          #vracamo ecx sa steka
.endm


StepenMNF:
    push %ebp
    movl %esp, %ebp


    #uzimanje argumenata
    movl 8(%ebp), %ebx        #broj koji stepenujemo
    movl 12(%ebp), %ecx    #stepen

    cmpl $0, %ecx      #proveravamo ispravnost stepena
    jl greska_stepen

    jnz izdvajanja      #proveravamo da li je stepen 0
    movl 16(%ebp), %esi
    movl $0x40000000, (%esi)    #postavljamo kod jedinice (u MNF) u rezultat
    xorl %eax, %eax        #u ovom slucaju je greska 0 (nema greske)
    jmp kraj          #i zavrsavamo


izdvajanja:
    #postavljanje maski za izdvajanje frakcije i ekponenta i njihovo izdvajanje
    movl $0x1FFFFF, %esi
    andl %ebx, %esi        #izdvajamo frakciju
    orl $0x200000, %esi        #dodavanje jedinice koja se podrazumeva

    movl $0x7FE00000, %eax
    andl %ebx, %eax        #izdvajamo exponent
    shrl $21, %eax      #postavljamo exponent na pocetak registra
    subl $0x200, %eax        #oduzimamo konstatnu podesavanja


    xorl %edx, %edx
    mull %ecx          #mnozimo exponent stepenom
    movl %eax, %edi        #sad nam je exponent u edi

    movl %esi, %eax        #stavljamo frakciju u eax zbog mnozenja
    decl %ecx          #smanjujemo stepen za 1 jer smo vec jedan dodali u rezultat
mnozi:
    andl %ecx, %ecx        #proveravamo da li smo zavrsili sa mnozenjem
    jz normalizovanje        #ako jesmo moramo da normalizujemo rezultat
    mull %esi          #ako nismo mnozimo ponovo

    pomeri $21      #svaki put pomeramo u desno 21 mesto da odbacimo nepotrebne cifre

    decl %ecx          #smanjujemo stepen za jedan
    jmp mnozi          #i ponovo proveravamo

normalizovanje:
    testl $0xFFC00000, %eax    #proveravamo da li ima cifara razlicitih od nule u delu u kom ne bi smelo da ih bude
    jz sredi          #ako nema prelazimo da pravljenje konacnog rezultata
    shrl $1, %eax      #a ako ima pomeramo frakciju u desno
    decl %edi          #i smanjujemo exponent
    jmp normalizovanje        #vracanje na proveru

sredi:
    xorl %edx, %edx        #ovo nije neophodno jer je edx ionako 0, ali ne skodi

    andl $0xFFDFFFFF, %eax    #ponostavamo jedinicu koja se podrazumeva i koja se ne pise u konacnom rezultatu
    orl %eax, %edx      #postavljamo frakciju u konacan rezultat

    addl $0x200, %edi        #na eksponent dodajemo konstatnu podesavanja
    cmpl $0x3FF, %edi        #proveravamo da li je stepen prevelik
    ja greska_overflow        #ako jeste prijavljujemo gresku, a ako nije mozemo da nastavimo
    shll $21, %edi      #postavljamo eksponent na mesto gde treba da bude u rezultatu
    orl %edi, %edx      #i postavljamo ga u rezultat

    testl $0x80000000, 8(%ebp)      #proveravamo da li je broj koji smo stepenovali pozitivan ili negativan
    jz pozitivan      #ako je pozitivan i rezultat je sigurno pozitivan
    testl $0x1, 12(%ebp)        #a ako je negativan proveravamo da li je stepen paran ili neparan
    jz pozitivan      #i ako je stepen paran rezultat je pozitivan

 orl $0x80000000, %edx    #u suprotnom rezultat je negativan i to postavljamo postavljamo najznacajniji bit na 1

pozitivan:
    movl 16(%ebp), %esi        #adresa rezultata

    movl %edx, (%esi)        #rezultat na mesto
    xorl %eax, %eax        #ako smo stigli dovde nije bilo greske
    jmp kraj

greska_overflow:
    movl $1, %eax      #kod greske 1 (overflow)
    jmp kraj

greska_stepen:
    movl $2, %eax      #kod greske 2 (ne valja stepen)

kraj:
    pop %ebp
    ret
