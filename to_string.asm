#potprogram za konvertovanje internog oblika broja u string
#autor: Bojan Delic e11510

.section .data
.section .text
.globl in2out


#potprogram za konvertovanje internog ovlika broja u znakovni oblik
#potprogram radi za brojne osnove do 10
#radi sa oznacenim brojevima
#    int in2out(int broj, char *izlaz, int duzina_izlaza, int brojni_sistem)
#na kraj stringa se postavlja NUL
in2out:
    push %ebp
    movl %esp, %ebp
    subl $4, %esp      #promenljiva za smestanje flega da li je broj negativan ili pozitivan
    movl $0, -4(%ebp)        #na pocetku pretpostavljamo da je broj pozitivan

    movl 8(%ebp), %eax        #broj koji konvertujemo
    movl 12(%ebp), %esi    #adresa izlaznog stringa
    movl 16(%ebp), %ecx    #maximalna duzina stringa
    movl 20(%ebp), %ebx    #brojni sistem u kome radimo
    xorl %edx, %edx        #anuliramo edx

    cmpl $1, %ecx      #da li ima mesta bar za jednu cifru u stringu (1 znak se zauzima za NUL karakter)
    jbe in2out_greska

    andl %eax, %eax        #provera da li je broj jednak nuli
    jz in2out_nula


    testl $0x80000000, %eax    #provera da li je proslednjeni broj negativan
    jz in2out_provera        #ako nije nastavljamo normalno da konvertujemo
    movl $'-', (%esi)        #a ako jeste na prvo mesto smestamo kod znaka -
    incl %esi          #i pomeramo pokazivac za jedno mesto
    decl %ecx          #umanjujemo jedno mest jer smo ga zauzeli
    movl $1, -4(%ebp)        #postavljamo  fleg da je u pitanju negativan broj
    negl %eax          #i pretvaramo ga u pozitivan radi deljenja
in2out_provera:
    andl %eax, %eax        #ako je eax nula, zavrsili smo konverziju
    jz in2out_zavrsi
    andl %ecx, %ecx        #ako je ecx nula nema vise mesta u stringu i prijavljujemo gresku
    jz in2out_greska
    xorl %edx, %edx        #anuliramo edx svaki put, jer tu treba da nam bude ostatak
    divl %ebx          #delimo sa osnovom brojnog sistema
    addl $'0', %edx      #na ostatak dodajemo kod nule
    movb %dl, (%esi)        #postavljamo znak koji smo dobili na sledece mesto u stringu
    incl %esi          #pomeramo pokazivac za jedno mesto unapred
    decl %ecx          #umanjujemo broj preostalih mesta
    jmp in2out_provera        #i sve opet ispocetka

in2out_zavrsi:
    movl $0, (%esi)      #postavljamo NUL znak na kraj
    decl %esi          #vracamo se za jedno mesto unazad
    movl 12(%ebp), %edi    #u edx stavljamo pocetak adresu na pocetak niza
    xorl %eax, %eax        #anuliramo eax
    xorl %ebx, %ebx        #anuliramo ebx

    movl -4(%ebp), %ecx    #da li imamo minus na pocetku?
    andl %ecx, %ecx        #proveravamo pomocu flega koji smo postavili na pocetku potprograma
    jz in2out_obrni      #ako nema minusa obrcemo
    incl %edi          #a ako ima njega iskljucujemo iz obrtanja broja jer on treba da ostane na pocetku
in2out_obrni:
    cmpl %esi, %edi        # da li smo obrnuli ceo niz?
    jae in2out_kraj      #ako jesmo zavrsavamo
    movb (%edi), %bl        #ako nismo zamenimo poslednji clan sa prvim i tako idemo prema unutrasnjosti
    movb (%esi), %bh
    movb %bl, (%esi)
    movb %bh, (%edi)
    incl %edi          #pomeramo se na sledeci od pocetka
    decl %esi          #pomeramo se na prethodni od kraja
    jmp in2out_obrni        #i opet


in2out_nula:
    movl $'0', (%esi)        #ako je broj nula, moramo to i zapisati u ascii kodu
    incl %esi
    movl $0, (%esi)      #kraj stringa
    jmp in2out_kraj

in2out_greska:
    movl $1, %eax      #javila se greska
in2out_kraj:
    addl $4, %esp      #unistavanje lokalnih promenljivih
    pop %ebp
    ret        #zavrsetak protprograma
