# Struct utili per i file.x

```
    struct Esito {
        int esito
    };
```

```
    const BASIC_DIM = 256;

    struct Stringa {
        char stringa[BASIC_DIM];
    };
```

```
    struct Lista_file {
    Stringa lista_file[6];
    };
```

```
    struct File_linea {
        char nome_file[BASIC_DIM];
        char linea[BASIC_DIM];
    };

    struct Esito {
        int esito;
    };

    struct Dir_prefisso {
        char nome_dir[BASIC_DIM];
        char prefisso[BASIC_DIM];
    };

    struct Stringa {
        char stringa[BASIC_DIM];
    };

    struct Lista_file {
        Stringa nome_file[6];  
    };
```