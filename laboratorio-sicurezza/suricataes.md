# Esercizio netflix suricata 1 - tipo facebook

domini alternativi trovati: (da wireshark)
- netflix.com
- fp2e7a.wpc.phicdn.net
- assets.nflxext.com
- cdn.cookielaw.org
- occ-0-784-778.1.nflxso.net

## regole:

alert tls any any -> any any (msg:"SURICATA TRAFFIC-ID: netflix"; tls_sni; content:"netflix.com"; isdataat:!1,relative; flow:to_server,established; flowbits: set,traffic/id/netflix; flowbits:set,traffic/label/social-network; sid:300000003; rev:1;)

alert tls any any -> any any (msg:"SURICATA TRAFFIC-ID: netflix (assets)"; tls_sni; content:"assets.nflxext.com"; isdataat:!1,relative; flow:to_server,established; flowbits: set,traffic/id/netflix; flowbits:set,traffic/label/social-network; sid:300000004; rev:1;)

alert tls any any -> any any (msg:"SURICATA TRAFFIC-ID: netflix (cookie)"; tls_sni; content:"cdn.cookielaw.org"; isdataat:!1,relative; flow:to_server,established; flowbits: set,traffic/id/netflix; flowbits:set,traffic/label/social-network; sid:300000005; rev:1;)

### PASSI DA FARE
1. Aprire wireshark 
2. collegarsi a sito che si deve insomma fare ecco (no refresh: cerca direttamente nella barra!)
3. su wireshark vedere i domini alternativi che escono
4. segnarli! 
5. copiareincollare la regola di facebook e sostituire con domini (dentro content) e il sid 
6. testare et voilà 

----------------------------------

# Esercizio suricata 2 - file pcap

Il file di tipo pcap assegnato è il tracciato di un traffico mqtt tra un subscriber e un publisher sul broker mosquitto.
( Per informazioni su mqtt e mosquitto riprendere le slide su TLS)
Vostro compito è quello di creare una regola suricata che scateni un alert ogni volta che nel contenuto del pacchetto MQTT ci sia il contenuto “flag”
Se predisposta correttamente, nei log di suricata dovreste essere in grado di vedere il contenuto dei pacchetti
Nel contenuto dei pacchetti è possibile trovare “pezzi” di una flag nel formato SEC{qualcosa}, che potete ricostruire e sottomettere (insieme alla regola!) sul portale virtuale.


## regola: 

alert tcp any any -> any any (msg:"Flag found"; content:"flag"; sid:999999921; rev:1;)

## dopo per fare il parsing della flag
1. abilitare "payload-printable" in suricata.yaml
2. installare jq con sudo apt install jq

output=$(cat eve.json | jq 'select(.event_type="alert")')





