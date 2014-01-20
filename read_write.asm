#makroi za ispis u upis sa terminala
#autor: Bojan Delic e11510

.section .data
    uvodna_poruka: .ascii "\9***Program koji racuna zbir dva broja!*** \0"
    poruka1: .ascii "Unesite prvi broj: \0"
    poruka2: .ascii "Unesite drugi broj: \0"
    zbir_je: .ascii "Zbir brojeva je: \0"
    razlika_je: .ascii "Razlika brojeva je: \0"
    greska_prekoracenje: .ascii "Uneli ste prevelik broj! \0"
    greska_nedozvoljen_znak: .ascii "Uneli ste nedozvoljen znak! Smete da unoste samo cifre! \0"
    greska_program: .ascii "Doslo je do greske u programu! \0"

    broj1: .fill 20, 1, 0
    broj2: .fill 20, 1, 0
    zbir: .fill 20, 1, 0
    razlika: .fill 20, 1, 0
    novi_red: .ascii "\12\0"
    broj: .fill 20, 1, 0
    potpis: .ascii "\9\9\9\9\9Made by del-boy \0"
    povlaka: .ascii "-\0"
    greska_zvuk: .ascii "\7\0"
.section .text
.globl main


#makro separator ispisuje - proizvoljan broj puta
#ukoliko se ne navede broj, podrazumevani je 60
.macro separator broj=$60
    push %eax        #stavljamo na stek da ne bi izgubili vrednost
    push %ebx
    push %ecx
    push %edx
    push %esi

    print $novi_red

    movl \broj, %esi
1:
    movl $4, %eax
    movl $1, %ebx
    movl $povlaka, %ecx
    movl $1, %edx
    int $0x80
    decl %esi
    andl %esi, %esi
    jnz 1b


    print $novi_red

    pop %esi
    pop %edx      #vracamo registre
    pop %ecx
    pop %ebx
    pop %eax
.endm


#makro kraj ima samo jedan argument, a to je kod greske koji se vraca opetarivnom sistemu
#ukoliko se ne navede kod greske podrazumevani je 0
.macro kraj greska=$0
    movl $1, %eax
    movl \greska, %ebx
    int $0x80
.endm


#makro print ima samo jedan argument, a to je adresa pocetka stringa koji treba ispisati
#duzina stringa se odredjuje u makrou
#podrazumeva se da se string zavrsava sa NUL
.macro print adresa
    push %eax        #cuvamo na steku vrednosti registara da ne pokvarimo glavni program
    push %ebx
    push %ecx
    push %edx

    movl \adresa, %ecx    #adresa pocetka stringa
    xorl %edx, %edx    #anuliramo edx
    xorl %eax, %eax    #anuliramo eax
1:        #brojimo koliko ima nakova u stringu
    movb (%ecx), %al    #prebacujemo znak u registar eax
    andl %eax, %eax    #proveravamo da li je nula, odnosno da li smo dosli do kraja stringa
    jz 2f          #ako jesmo idemo na ispis
    incl %ecx      #a ako nismo pomeramo pokazivac na sledeci elemenat stringa
    incl %edx      #i povecavamo broj znakova za 1
    jmp 1b      #i opet
2:
    movl $4, %eax        #podesavamo registre za ispis na ekran
    movl $1, %ebx        #u edx-u nam se vec nalazi duzina stringa, tako da to ne diramo
    movl \adresa, %ecx
    int $0x80      #interupt (ispis na ekran)


    pop %edx      #vracamo sa steka vrednosti registara
    pop %ecx
    pop %ebx
    pop %eax

.endm


#makro scan ima dva argumenta, a to je adresa stringa na koji treba upisati unete podatke i maximalna duzina tog stringa
#makro na kraj stringa ubacuje NUL
.macro scan adresa, duzina
    push %eax        #ostavljamo vrednosti registara na stek da ne bi uticali na tok programa
    push %ebx
    push %ecx
    push %edx

    movl $3, %eax        #ucitavanje stringa sa terminala
    movl $0, %ebx
    movl \adresa, %ecx
    movl \duzina, %edx
    int $0x80

    movl \adresa, %ebx
    addl %eax, %ebx    #pomeramo se na kraj stringa
    decl %ebx      #sad smo na poslednjem karakteru u stringu (kod entera)
    movb $0, (%ebx)

    pop %edx      #vracamo vrednosti registara sa steka da bi program mogao normalno da nastavi da radi
    pop %ecx
    pop %ebx
    pop %eax

.endm

main:
    separator
    print $uvodna_poruka
    separator

    print $poruka1        #unos prvog broja
    scan $broj1, $20
    push $10      #konvertovanje broja u interni oblik
    push $broj1
    call out2in
    addl $8, %esp
    cmpl $1, %edx        #provera gresaka
    jz greska1
    cmpl $2, %edx
    jz greska2
    push %eax

    print $poruka2        #unos drugog broja
    scan $broj2, $20
    push $10      #konvertovanje broja u interni oblik
    push $broj2
    call out2in
    addl $8, %esp
    cmpl $1, %edx        #provera gresaka
    jz greska1
    cmpl $2, %edx
    jz greska2

    pop %ebx      #vracamo prvi broj da bi izacunali zbir
    push %ebx        #ponovo postavljamo brojeve da bi kasnije mogli da izracunamo razliku
    push %eax
    addl %ebx, %eax    #sabiramo dva broja u internom obliku


    #pretvaramo zbir u znakovni oblik
    push $10      #brojni sistem
    push $20      #maximalna duzina izlaza
    push $zbir      #adresa za rezultat
    push %eax        #broj za konverziju
    call in2out      #konvernovanje broja u znakovni oblik
    addl $16, %esp

    pop %eax      #vracamo brojeve sa steka da bi ih oduzeli
    pop %ebx
    subl %eax, %ebx

    #pretvaramo razliku u znakovni oblik
    push $10      #brojni sistem
    push $20      #maximalna duzina izlaza
    push $razlika        #adresa za rezultat
    push %ebx        #broj za konverziju
    call in2out      #konvernovanje broja u znakovni oblik
    addl $16, %esp


    separator

    #ispisujemo zbir
    print $zbir_je
    print $zbir
    print $novi_red

    #ispisujemo razliku
    print $razlika_je
    print $razlika


    separator

    print $novi_red
    print $novi_red


    jmp bez_greske


greska1:
    print $greska_prekoracenje
    print $greska_zvuk
    print $novi_red
    kraj $1
greska2:
    print $greska_nedozvoljen_znak
    print $greska_zvuk
    print $novi_red
    kraj $2
greska3:
    print $greska_program
    print $greska_zvuk
    print $novi_red
    kraj $3

bez_greske:
print $potpis
print $novi_red
separator
print $novi_red
kraj
