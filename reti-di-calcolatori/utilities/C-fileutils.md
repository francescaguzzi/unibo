# Utilities per operazioni sui file C/S in C

---------
## PICCOLE COSE UTILI
---------

```c
    int isVowel(char c) {
        if (isalpha(c)) {
            if (c == 'a' || c == 'A' || c == 'e' || c == 'E' || c == 'i' ||
                c == 'I' || c == 'o' || c == 'O' || c == 'u' || c == 'U')
                return 1;
            else
                return 0;
        }
        else return 0;
    }
```

```c
    int isNumber(char c) {
        if(c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9')
            return 1;
        else return 0;
    }
```

```c
    int is_txt_file(char* nome_file) {
        int len = strlen(nome_file);
        if(nome_file[len-1] == 't' && nome_file[len-2] == 'x' && nome_file[len-3] == 't' && nome_file[len-4] == '.')
            return 1;
        else return 0;
    }
```


---------
## OPERAZIONI SUI FILE 
---------

> Elimina vocali da file (server udp)
>> 6 maggio 2019

```c
    printf("In attesa del nome del file...\n");
    if (recvfrom(udpfd, fileName, BASIC_DIM, 0,
                    (struct sockaddr *)&servaddr, &len) < 0) {
        perror("recvfrom");
        continue;
    }
    printf("Nome file arrivato: %s\n", fileName);
    fd = open(fileName, O_RDONLY);
    if (fd < 0) {
        printf("Errore nell'apertura del file\n");
        counter_vocali = -1;
        sendto(udpfd, &counter_vocali, sizeof(int), 0,
                (struct sockaddr *)&servaddr, len);
        continue;
    }

    counter_vocali = 0;
    fd_2 = creat("temp", 0666);
    if (fd_2 < 0) {
        printf("Errore nella creazione delfile temporaneo...\n");
        counter_vocali = -1;
        sendto(udpfd, &counter_vocali, sizeof(int), 0,
                (struct sockaddr *)&servaddr, len);
        continue;
    }
    while (read(fd, &c, sizeof(char)) > 0) {
        if (c != 'a' && c != 'A' && c != 'e' && c != 'E' && c != 'i' &&
            c != 'I' && c != 'o' && c != 'O' && c != 'u' && c != 'U')
            write(fd_2, &c, sizeof(char));
        else
            counter_vocali++;
    }

    close(fd);
    close(fd_2);

    if (remove(fileName) != 0) {
        printf("Errore nell'eliminazione del file %s...\n", fileName);
    }
    rename("temp", fileName);

    printf("Invio del counter_vocali: %d al client\n", counter_vocali);
    if (sendto(udpfd, &counter_vocali, sizeof(int), 0,
                (struct sockaddr *)&servaddr, len) < 0) {
        perror("sendto");
        continue;
    }

    printf("Invio effettuato!\n");
```

---------

> Elimina occorrenze di numeri da file
>> 8 gennaio 2020

```c
    Esito *
    elimina_occorrenze_1_svc(Stringa *s, struct svc_req *rqstp)
    {
        static Esito e;
        int fd, new_fd;
        char c;

        printf("Eliminiamo le occorrenze in %s\n", s->stringa);

        fd = open(s->stringa, O_RDONLY);
        if(fd < 0) {
            printf("Errore nell'apertura di %s\n", s->stringa);
            exit(-1);
        }
        new_fd = creat("temp", 0666);
        if(new_fd < 0) {
            printf("Errore nella creazione del file temporaneo\n");
            exit(-1);
        }

        e.esito = 0;
        while(read(fd, &c, sizeof(char)) > 0) {
            if(isNumber(c))
                e.esito++;
            else {
                if(write(new_fd, &c, sizeof(char)) < 0) {
                    perror("write");
                    exit(-1);
                }
            }
        }

        if(remove(s->stringa) == 0)
            printf("%s eliminato correttamente\n", s->stringa);
        else printf("Errore nell'eliminazione di %s\n", s->stringa);

        rename("temp", s->stringa);

        close(fd);
        close(new_fd);

        printf("Occorrenze eliminate: %d\n", e.esito);

        return &e;
    }
```

---------

> Conta occorrenze di una linea nel file
>> 9 gennaio 2017

```c
    Esito *conta_occorrenze_linea_1_svc(File_linea *fi_li, struct svc_req *rqstp) {
        static Esito esito;
        int fd, i;
        char c;
        char linea[BASIC_DIM];

        printf("Hai scelto conta_occorrenze_linea\n");
        printf("Dati: %s %s\n", fi_li->nome_file, fi_li->linea);

        fd = open(fi_li->nome_file, O_RDONLY);
        if (fd < 0) {
            printf("Errore nell'apertura di %s...\n", fi_li->nome_file);
            exit(-1);
        }
        printf("%s aperto correttamente\n", fi_li->nome_file);

        esito.esito = 0;
        i = 0;
        memset(linea, '\0', BASIC_DIM);
        printf("Contiamo le occorrenze\n");
        while (read(fd, &c, sizeof(char)) > 0) {
            if (c != '\n') {
                linea[i] = c;
                i++;
            } else {
                i = 0;
                if (strcmp(linea, fi_li->linea) == 0) {
                    esito.esito++;
                }
                memset(linea, '\0', BASIC_DIM);
            }
        }
        if (strcmp(linea, fi_li->linea) == 0) {
                    esito.esito++;
                }
        printf("Fine conteggio, occorrenze trovate: %d\n", esito.esito);

        return &esito;
    }
```

---------



---------
## OPERAZIONI SU DIRECTORY
---------

> Ritorna il numero di file contenuti in una directory (server)
>> 6 maggio 2019

```c
    int num_file(char *name) {

        DIR *dir;
        struct dirent *dd;
        char buff[BASIC_DIM];
        int result = 0, fd, condizione_v = 0, condizione_c = 0;
        char c;

        dir = opendir(name);
        if (dir == NULL) {
            printf("bruh\n");
            return -1;
        }
        while ((dd = readdir(dir)) != NULL) {
            if (dd->d_type == DT_REG) {
                memset(buff, '\0', BASIC_DIM);
                sprintf(buff, "%s/%s", name, dd->d_name);
                fd = open(buff, O_RDONLY);
                if (fd < 0) {
                    printf("Errore nel'apertura di %s\n", dd->d_name);
                    exit(-1);
                }
                while (read(fd, &c, sizeof(char)) > 0) {
                    if (is_vowel(c)) {
                        condizione_v = 1;
                        break;
                    }
                }
                close(fd);

                fd = open(buff, O_RDONLY);
                if (fd < 0) {
                    printf("Errore nel'apertura di %s\n", dd->d_name);
                    exit(-1);
                }
                while (read(fd, &c, sizeof(char)) > 0) {
                    if (!is_vowel(c)) {
                        condizione_c = 1;
                        break;
                    }
                }
                close(fd);

                if (condizione_c && condizione_v)
                    result++;
            }
        }
        closedir(dir);

        printf("Result: %d\n", result);
        return result;
    }
```

---------

> Trasferimento file (server TCP)
>> 6 maggio 2019

```c
    printf("In attesa del nome della dir...\n");
    if (read(connfd, &dir_name, BASIC_DIM) < 0) {
        perror("read");
        exit(-1);
    }
    printf("Nome dir ricevuto: %s\n", dir_name);

    num_files = num_file(dir_name);
    printf("Numero di file di %s: %d\n", dir_name, num_files);

    printf("Invio del numero di file contenuti in %s\n",
            dir_name);
    if (write(connfd, &num_files, sizeof(int)) < 0) {
        perror("write");
        exit(-1);
    }
    printf("Numero di files mandato: %d\n", num_files);

    DIR *dir;
    struct dirent *dd;
    dir = opendir(dir_name);
    if (dir == NULL) {
        printf("Errore nell'apertura del dir\n");
        exit(-1);
    }
    while ((dd = readdir(dir)) != NULL) {
        condizione_v = 0;
        condizione_c = 0;
        if (dd->d_type == DT_REG) {
            memset(buff_2, '\0', BASIC_DIM);
            sprintf(buff_2, "%s/%s", dir_name, dd->d_name);
            fd = open(buff_2, O_RDONLY);
            if (fd < 0) {
                printf("Errore nel'apertura di %s\n",
                        dd->d_name);
                exit(-1);
            }
            while (read(fd, &c, sizeof(char)) > 0) {
                if (is_vowel(c)) {
                    condizione_v = 1;
                    break;
                }
            }
            close(fd);

            fd = open(buff_2, O_RDONLY);
            if (fd < 0) {
                printf("Errore nel'apertura di %s\n",
                        dd->d_name);
                exit(-1);
            }
            while (read(fd, &c, sizeof(char)) > 0) {
                if (!is_vowel(c)) {
                    condizione_c = 1;
                    break;
                }
            }
            close(fd);

            if (condizione_c && condizione_v) {
                printf("Invio del nome del file\n");
                if (write(connfd, &dd->d_name,
                            (strlen(dd->d_name) + 1)) < 0) {
                    perror("write");
                    exit(-1);
                }
                printf("Nome del file invato: %s\n", dd->d_name);

                printf("In attesa della verifica...\n");
                if (read(connfd, &verifica, sizeof(int)) < 0) {
                    perror("read");
                    exit(-1);
                }
                printf("Verifica sul nome ricevuta\n");

                stat(buff_2, &st);
                printf("Invio la dimensione del file\n");
                if (write(connfd, &st.st_size, sizeof(int)) <
                    0) {
                    perror("write");
                    exit(-1);
                }
                printf("Invio della dimensione effettuato: %d\n", st.st_size);

                printf("In attesa della verifica...\n");
                if (read(connfd, &verifica, sizeof(int)) < 0) {
                    perror("read");
                    exit(-1);
                }
                printf("Verifica sulla dimensione ricevuta\n");

                fd = open(buff_2, O_RDONLY);
                if (fd < 0) {
                    printf("Errore nel'apertura di %s\n",
                            dd->d_name);
                    exit(-1);
                }
                printf("Invio del contenuto del file\n");
                while (read(fd, &c, sizeof(char)) > 0) {
                    if(write(connfd, &c, sizeof(char)) < 0) {
                        perror("write");
                        exit(-1);
                    }
                }
                close(fd);
                printf("Fine invio conftenuto\n");

                printf("In attesa della verifica finale...\n");
                if (read(connfd, &verifica, sizeof(int)) < 0) {
                    perror("read");
                    exit(-1);
                }
                printf("Verifica finale ricevuta\n");
            }
        }
```

---------

> Conta tutte le occorrenze (dato un numero minimo) di un carattere nei file di una directory e restituisce la lista di file
>> 8 gennaio 2020

```c
    Lista_file *
    lista_file_carattere_1_svc(Nome_char_occ *nco, struct svc_req *rqstp)
    {
        static Lista_file lf;

        DIR *dir;
        struct dirent *dd;
        int count_occ, count_file;

        printf("Cerchiamo sti file in %s\n", nco->nome_file);
        dir = opendir(nco->nome_file);
        if(dir == NULL) {
            printf("Errore");
            exit(-1);
        }
        count_occ = 0;
        count_file = 0;
        while((dd = readdir(dir)) != NULL) {
            if(dd->d_type == DT_REG) {
                for(int i = 0; i < strlen(dd->d_name); i++) {
                    if(dd->d_name[i] == nco->c)
                        count_occ++;
                }
                if(count_occ >= nco->num_occ && is_txt_file(dd->d_name)) {
                    strcpy(lf.lista_file[count_file].stringa, dd->d_name);
                    count_file++;
                }
            }
            count_occ = 0;

            if(count_file == 6)
                break;
        }

        while(count_file < 6) {
            strcpy(lf.lista_file[count_file].stringa, "vuoto");
            count_file++;
        }

        closedir(dir);
        
        return &lf;
    }
```

---------

> Restituisce la lista di tutti i file di una dir i cui nomi iniziano per un prefisso
>> 9 gennaio 2017

```c
    Lista_file *lista_file_prefisso_1_svc(Dir_prefisso *dp,
                                      struct svc_req *rqstp) {
        static Lista_file lf;
        DIR *dir;
        struct dirent *dd;
        int count = 0;

        for(int i = 0; i < 6; i++)
            strcpy(lf.nome_file[i].stringa, "vuoto");

        dir = opendir(dp->nome_dir);
        if(dir == NULL) {
            printf("Cartella non trovata...\n");
            exit(-1);
        }
        while((dd = readdir(dir)) != NULL) {
            if(strncmp(dd->d_name, dp->prefisso, strlen(dp->prefisso)) == 0) {
                strcpy(lf.nome_file[count].stringa, dd->d_name);
                count++;
            }

            if(count == 6)
                break;
        }

        printf("Lista trovata:\n");
        for(int i = 0; i < 6; i++) {
            if(strcmp(lf.nome_file[i].stringa, "vuoto") != 0)
                printf("%s\n", lf.nome_file[i].stringa);
        }

        return &lf;
    }
```

---------


