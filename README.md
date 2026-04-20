AI Inlämning 1 - Grupp 19
Oliwer Carpman, Rafal Galinski, Robin Karim

Instruktioner för att köra programmet.
Något om processing.

När programmet körs har man 3 knappar.
    
    1 startar en ai som automatiskt letar eftermotståendebasen. När den befinner sig med mer än 50% av sin egen längd i motståendebasen går den till A-star läge, och hittar en väg tillbaka till sin startpunkt.

    2 startar manuellt kontrolläge
        Knapp 'w' för att röra sig fram och 's' för bakåt
        Knappar 'a' och 'd' svänger tanken vänster och höger
    
    p pausar all rörelse, eller startar det igen. 
        Ifall det trycks först startar tanken i läge 1.
        Musknappen skapar nya träd där man klickar. Detta är endast för debuggning. (Ska uppdatera snart)

Saker vi inte fått till:

    En "debug mode" har inte lagts till, utan allt visas just nu. Funktioner i debug mode skulle inkludera vilka noder tanken åkt igenom, information om positionen, samt astar vägen.
    
    Tanken ska pausa i 3 sekunder för att "raportera" basen. I nuläget återupptar den patrulningen direkt.

    En tank ska hitta snabbaste vägen till hembasen, Dock hittar den nu snabbaste vägen till sin egen startpunkt

Kända buggar:
En tank i A-star läge svänger inte, utan direkt åker i rätt riktning

Det kan förekomma att en tank kan fastna i astar läge ifall den försöker åka för nära ett träd
