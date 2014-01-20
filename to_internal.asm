#potprogram za konverziju znakovnog oblika celog broja u interni oblik
#autor: Bojan Delic e11510

.section .data
.section .text
.globl out2in


#potprogram za konvertovanje znakovnog oblika broja u interni
#potprogram radi za brojne osnove do 10
#radi sa oznacenim brojevima
#    int out2in (char *ulaz, int brojni_sistem)
#podrazumeva se da na kraju ulaznog stringa se nalazi NUL
#program vraca u edx 1 ako je doslo do prekoracenja ili 2 ako se u stringu pojavljuju nedozvoljeni znaci
#ako je sve u redu potprogram vraca nulu u edx, a u eax vrednst broja
out2in:
    push %ebp
    movl %esp, %ebp
    subl $4, %esp          #fleg koji nam govori da li je broj negativan
    movl $0, -4(%ebp)      #na pocetku pretpostavljamo da je broj pozitivan


    movl 8(%ebp), %esi      #adresa ulaznog stringa
    movl 12(%ebp), %ebx        #osnova brojnog sistema
    xorl %eax, %eax      #rezultat ide ovde, anuliramo ga
    xorl %edx, %edx      #redi kontrole prekoracenja
    xorl %ecx, %ecx      #u ecx-u ce biti kod svakog znaka

    cmpb $'-', (%esi)      #da li je negativan broj
    jne out2in_sledeci_znak        #GRESKA! USLOVNI SKOK NE RADI KAKO TREBA
    movl $1, -4(%ebp)
    incl %esi
out2in_sledeci_znak:
    movb (%esi), %cl      #smestamo kod znaka u najmanje znacajan deo ecx-a
    andl %ecx, %ecx      #da li smo zavrsili
    jz out2in_zavrsi
    subb $'0', %cl          #izdvajamo vrednost znaka
    cmpl $0, %ecx          #proveravamo da li se u stringu pojavljuju nedozvoljeni znaci
    jb out2in_greska_znak
    cmpl %ebx, %ecx
    jae out2in_greska_znak

    mull %ebx        #mnozimo rezultat sa osnovom brojnog sistema
    andl %edx, %edx      #da li je doslo do prekoracenja
    jnz out2in_greska_prekoracenje

    addl %ecx, %eax      #dodajemo broj na rezultat
    incl %esi        #pomeramo pokazivac na sledeci broj
    jmp out2in_sledeci_znak        #i opet ispocetka

out2in_zavrsi:
    movl -4(%ebp), %ebx        #da li je broj negativan?
    andl %ebx, %ebx      #to pamtimo u flegu koji smo odredili na pocetku
    jz out2in_kraj
    negl %eax        #ako jeste sada ga negiramo
    jmp out2in_kraj          #avrsavamo program




out2in_greska_prekoracenje:
    movl $1, %edx          #kod greske 1
    jmp out2in_kraj
out2in_greska_znak:
    movl $2, %edx          #kod greske 2
out2in_kraj:
    addl $4, %esp
    pop %ebp
    ret
