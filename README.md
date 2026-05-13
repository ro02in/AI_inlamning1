AI Inlämning 1 - Grupp 19
Oliwer Carpman, Rafal Galinski, Robin Karim

Instruktioner för att köra programmet.
Något om processing.

När programmet körs har man 3 knappar.
    
    1 startar alla tanks automatiskt som patrullerar världen och bygger individuella innre kartor av världen. När en tank ser en motstånadre   vänder den sig mot motståndaren och börjar skjuta, får den den slut på skott åter vänder sig tanken till sin egen bas med hjälp av Astar på delar av världen som är kända sen tidigare. Ifall att tank0 ser en motståndare och t.ex. tank1 befinner sig i sin egen bas eller mindre än 75px ifrån tank0 använder den Astar för att hitta en väg till tank0 för att hjälpa till i fighten (Radio funktion). Tanks användre ENDAST sina egna perceps och informations som den själv samalt in under spelet för att fatta vilka beslut som ska tas.  

    2 startar manuellt kontrolläge
        Knappar 'w' och 's' används för att röra sig fram och bak
        Knappar 'a' och 'd' används för att svänga tanken vänster och höger
    
    p pausar all rörelse, eller startar det igen. 
        Ifall det trycks först startar tanken i läge 1.
        Musknappen skapar nya träd där man klickar. Detta är endast för debuggning. (Ska uppdatera snart)

Saker vi inte fått till:

    En "debug mode" har inte lagts till. Funktioner i debug mode skulle inkludera vilka noder tanken åkt igenom, information om positionen, samt astar vägen. Just nu visas allt detta som default.
    
    Tanken ska pausa i 3 sekunder för att "raportera" basen. I nuläget återupptar den patrulningen direkt.

    En tank ska hitta snabbaste vägen till hembasen, Dock hittar den nu snabbaste vägen till sin egen startpunkt

    En motståndartank som hittas markeras på samma sätt som en vänlig tank men borde egentligen rapporteras

Kända buggar:
En tank i A-star läge svänger inte, utan direkt åker i rätt riktning

Om A-star inte hittar en väg tillbaka bland kända och okända celler kraschar programmet

Länk till Github repositorie:
    https://github.com/ro02in/AI_inlamning1.git