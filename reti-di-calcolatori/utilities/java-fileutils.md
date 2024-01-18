# Utilities per operazioni sui file in Java C/S

---------
## OPERAZIONI SU FILE
---------

> Funzione per contare le righe dispari in un file
>> 6 maggio 2019

```java
    public synchronized int numerazione_righe(String fileName) throws RemoteException, IOException {
		int result = 0, rawCounter = 1, fakeC;
		char c;

		if(!(new File(fileName)).exists()) {
			return -1;
		}
		
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		BufferedWriter bw = new BufferedWriter(new FileWriter("temp"));

		bw.write("1 ");
		while((fakeC = br.read()) > 0) {
			c = (char)fakeC;
			bw.write(c);
			if(c == '\n') {
				rawCounter++;
				if(rawCounter % 2 != 0) {
					bw.write(rawCounter + " ");
					result++;
				}
			}
		}

		br.close();
		bw.close();

		File oldFile = new File(fileName);
		File newFile = new File("temp");
		oldFile.delete();
		newFile.renameTo(oldFile);

		return result;
	}
```

---------

> Conta occorrenze di un carattere in ogni linea di un file (server)
>> 8 gennaio 2020

```java
    if (dato.equals("C")) {
        String dirName;
        char c;
        int numOcc, esito;
        File[] fileList;

        System.out.println("Hai scelto di contare le occorrenze");

        System.out.println("In attesa del nome della dir");
        dirName = inSock.readUTF();
        System.out.println("Nome dir ricevuto: " + dirName);

        System.out.println("In attesa del carattere");
        c = (char) inSock.read();
        System.out.println("Char ricevuto: " + c);

        System.out.println("In attesa del numero di occorrenze");
        numOcc = inSock.readInt();
        System.out.println("Numero di occorrenze ricevuto: " + numOcc);

        System.out.println("Inizio conteggio");
        esito = 0;
        if (!(new File(dirName)).exists()) {
            System.out.println("Dir non esistente...");
            esito = -1;
            outSock.writeInt(esito);
        }

        fileList = (new File(dirName)).listFiles();
        for (File f : fileList) {
            String path = dirName + "/" + f.getName();
            BufferedReader br = new BufferedReader(new FileReader(path));
            int fakeC, occInLine;
            char temp;

            occInLine = 0;
            while ((fakeC = br.read()) > 0) {
                temp = (char) fakeC;
                if (temp == c)
                    occInLine++;
                else if (temp == '\n') {
                    if(occInLine >= numOcc)
                        esito++;
                    occInLine = 0;
                }
            }
            if(occInLine >= numOcc)
                        esito++;
                    occInLine = 0;

            br.close();
        }
```

---------

> Elimina tutte le occorrenze di una parola da file e restituisce il numero di parole eliminato
>> 9 gennaio 2017

```java
    if (service.equals("E")) {
        String nomeFile, parola, buff;
        char c;
        int fakeC, numOcc;
        System.out.println("Hai scelto di contare le occorrenze!");

        System.out.println("In attesa del nome del file...");
        nomeFile = inSock.readUTF();
        System.out.println("Nome file arrivato: " + nomeFile);

        System.out.println("In attesa della parola...");
        parola = inSock.readUTF();
        System.out.println("Parola arrivata: " + parola);

        BufferedReader br = new BufferedReader(new FileReader(nomeFile));
        numOcc = 0;
        buff = "";
        System.out.println("Iniziamo il conteggio");
        while ((fakeC = br.read()) > 0) {
            c = (char) fakeC;
            if (c != '\n' && c != ' ' && c != ',' && c != '.')
                buff += c;
            else {
                if (buff.equalsIgnoreCase(parola))
                    numOcc++;
                buff = "";
            }
        }
        if (buff.equalsIgnoreCase(parola))
            numOcc++;
        br.close();

        System.out.println("Invio esito");
        outSock.writeInt(numOcc);
        System.out.println("Esito inviato: " + numOcc);

    }
```

---------

---------
## OPERAZIONI SU DIRECTORY
---------

> Funzione per listare tutti i file in una directory (con almeno 3 consonanti nel nome)
>> 6 maggio 2019

```java
    private boolean atLeast3Cons(String name) {
		int counter = 0;

		name = name.toLowerCase();
		for(int i = 0; i < name.length(); i++) {
			if(name.charAt(i) != 'a' && name.charAt(i) != 'e' && name.charAt(i) != 'i' &&
			name.charAt(i) != 'o' && name.charAt(i) != 'u')
				counter++;
		}

		if(counter < 3)
			return false;
		else return true;
	}

    public synchronized String lista_file(String dirName) throws RemoteException {
		String result = "";

		File dir = new File(dirName);
		File[] files = dir.listFiles();

		for(int i = 0; i < files.length; i++) {
			if(atLeast3Cons(files[i].getName())) {
				result += files[i].getName();
				if(files.length - i > 1)
					result += " ";
			}
		}

		return result;
	}
```

---------

> Trasferimento di tutti i file contenuti in una dir (server)
>> 8 gennaio 2020

```java
    String dirName;
    File dir;
    File[] fileList;
    int numFiles;

    System.out.println("Hai scelto il trasferimento dei file");

    System.out.println("In attesa del nome della dir...");
    dirName = inSock.readUTF();
    System.out.println("Nomedir arrivato: " + dirName);

    dir = new File(dirName);
    fileList = dir.listFiles();
    numFiles = fileList.length;
    System.out.println("Invio del numero di file presenti in " + dir.getName());
    outSock.writeInt(numFiles);
    System.out.println("Invio del numero di file: " + numFiles);

    for(int i = 0; i < numFiles; i++) {
        byte[] buff = new byte[128];
        String path = dir.getName() + "/" + fileList[i].getName();
        String visto;
        FileInputStream fin = new FileInputStream(path);
        int nread;

        System.out.println("Invio il nome del file");
        outSock.writeUTF(fileList[i].getName());
        System.out.println("Nome inviato: " + fileList[i].getName());

        System.out.println("Invio della dimensione del file");
        outSock.writeLong(fileList[i].length());
        System.out.println("Dimensione inviata: " + fileList[i].length());

        System.out.println("Invio del contenuto");
        while((nread = fin.read(buff)) != -1) {
            outSock.write(buff, 0, nread);
        }
        fin.close();
        System.out.println("Contenuto inviato");

        System.out.println("In attesa del visto");
        visto = inSock.readUTF();
        if(visto.equals("finito"))
            System.out.println("Visto ricevuto");
        else {
            System.out.println("VISTO ERRATO");
            System.exit(-1);
        }

        (new File(path)).delete();
    }
    System.out.println("Fine inviaggio");
```

---------

> Trasferimento dal server al client di tutti i file di una dir che contengono un numero di byte maggiore di una soglia
>> 9 gennaio 2017

```java
    if (service.equals("T")) {
        String dirName;
        int minDim, verifica, numFiles, count;
        File[] fileList;
        File[] bigFiles;
        File dir;

        System.out.println("Hai scelto il trasferimento dei file");

        System.out.println("In attesa del nome del direttorio...");
        dirName = inSock.readUTF();
        System.out.println("Nome dir arrivato: " + dirName);

        if (!(new File(dirName)).exists()) {
            verifica = 0;
            System.out.println("Dirnon trovata....");
            outSock.writeInt(verifica);
            continue;
        } else {
            verifica = 1;
            System.out.println("Dir trovata!");
            outSock.writeInt(verifica);
        }

        System.out.println("In attesa della dimensione minima...");
        minDim = inSock.readInt();
        System.out.println("Dimensione minima arrivata: " + minDim);

        dir = new File(dirName);
        fileList = dir.listFiles();
        numFiles = 0;
        for (int i = 0; i < fileList.length; i++) {
            if (fileList[i].length() > minDim)
                numFiles++;
        }
        System.out.println("numFiles: " + numFiles);
        bigFiles = new File[numFiles];
        count = 0;
        for (int i = 0; i < fileList.length; i++) {
            if (fileList[i].length() > minDim) {
                bigFiles[count] = fileList[i];
                count++;
            }
        }

        System.out.println("Invio del numero di file presenti in " + dir.getName());
        outSock.writeInt(numFiles);
        System.out.println("Invio del numero di file: " + numFiles);

        for (int i = 0; i < numFiles; i++) {
            byte[] buff = new byte[128];
            String path = dir.getName() + "/" + bigFiles[i].getName();
            String visto;
            FileInputStream fin = new FileInputStream(path);
            int nread;

            System.out.println("Invio il nome del file");
            outSock.writeUTF(bigFiles[i].getName());
            System.out.println("Nome inviato: " + bigFiles[i].getName());

            System.out.println("Invio della dimensione del file");
            outSock.writeLong(bigFiles[i].length());
            System.out.println("Dimensione inviata: " + bigFiles[i].length());

            System.out.println("Invio del contenuto");
            while ((nread = fin.read(buff)) != -1) {
                outSock.write(buff, 0, nread);
            }
            fin.close();
            System.out.println("Contenuto inviato");

            System.out.println("In attesa del visto");
            visto = inSock.readUTF();
            if (visto.equals("finito"))
                System.out.println("Visto ricevuto");
            else {
                System.out.println("VISTO ERRATO");
                System.exit(-1);
            }
        }
        System.out.println("Fine inviaggio");

    }
```

---------