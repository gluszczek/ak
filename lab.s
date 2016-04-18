.data
	STDIN = 0
	STDOUT = 1
	SYSREAD = 0
	SYSWRITE = 1
	SYSEXIT = 60
.bss
	.comm first, 100
	.comm second, 100
	.comm action, 100
	.comm added, 100

.text
	.global _start

_start:

	call load_parameters

bp:
	mov first, %rbx
	mov second, %rax
	mov action, %rcx
	
	cmp $'d', %rcx
	je dodaj
	cmp $'o', %rcx
	je odejmij
	cmp $'m', %rcx
	je mnoz
	cmp $'x', %rcx
	je dziel

policzone:



	mov $added, %rcx
	call toASCII

	mov $SYSWRITE, %rax
	mov $STDOUT, %rdi
	mov $added, %rsi
	mov %r11, %rdx
	syscall

#------EXIT
	mov $SYSEXIT, %rax
	syscall
#===================================================
#===================================================
#---------------
#dodawanie
#--------------
dodaj:
	add %rbx, %rax

	jmp policzone
#---------------
#odejmowanie
#--------------
odejmij:
	xchg %rbx, %rax
	sub %rbx, %rax

	jmp policzone
#---------------
#mnozenie
#--------------
mnoz:
	imul %rbx, %rax

	jmp policzone

#---------------
#dzielenie
#--------------
dziel:
	xchg %rbx, %rax
	div %rbx

	jmp policzone

#--------------------------
#wczytaj parametry
#------------------------
load_parameters:

        pop %r8
        pop %r9
        pop %r10

        pop %rcx
        call count_len
        call toNumber
        movq %r10, first 

        pop %rcx
	call count_len
        call toNumber
        mov %r10, second

        pop %rcx
        movb (%rcx), %bl
	movb %bl, action

        push %r10
        push %r9
        push %r8

        ret
#------------------------------
#sprawdz dlugosc parametru
#----------------------------
count_len:
	mov $0, %rax
count_loop:
	inc %rax
	inc %rcx
	cmpb $0, (%rcx)
	jne count_loop
	
	sub %rax, %rcx
	ret

#---------------------------------------------------------------------------
#Konwersja z ASCII na liczbe.
#RCX - adres ciagu znakow, RAX - ilosc cyfr, R10 - uzyskana liczba
#-------------------------------------------------------------------------
toNumber:

	mov %rax, %rbx		#rbx-ilosc cyfr
	dec %rax
	add %rax, %rcx		#przejscie do adresu ostatniej cyfry
	mov $0, %r10		#r10-wartosc liczby
	mov $1, %rdi		#rdi-wartosc dziesietna cyfry

petla:
	mov $0, %rax
	movb (%rcx), %al
	sub $'0', %rax
	imul %rdi, %rax
	add %rax, %r10
 
	dec %rcx
	imul $10, %rdi
	dec %rbx
	cmp $0, %rbx
	jne petla

	ret
#-------------------------------------------------------------------
#Konwersja liczby na ASCII. 
#RCX - adres decelowy. RAX - liczba do konwersji. R11-zwracana ilosc znakow
#------------------------------------------------------------------
toASCII:

	mov $0, %rdx
	mov $0, %r11
	movl %ecx, %edi

loop:
	mov $0, %rdx
	mov $10, %rbx
	div %rbx
	add $'0', %rdx
	cmp $0, %r11
	jne movedigits
moved:
	movb %dl, (%rcx)
	inc %r11
	inc %rdi
	cmp $0, %rax
	jne loop

	ret

#przesuniecie znakow o jeden bajt, utworzenie miejsca na poczatku
movedigits:
	push %rdi
	mov $0, %r12
loopmove:
	dec %rdi
	movb (%rdi), %r12b
	inc %rdi
	movb %r12b, (%rdi)
	dec %rdi
	cmpl %ecx, %edi
	jne loopmove
	pop %rdi
	jmp moved
#-----------------------------------


