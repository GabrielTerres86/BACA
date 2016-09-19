/*.............................................................................

    Programa: b1wgen0093tt.i                  
    Autor   : André (DB1)
    Data    : Maio/2011                       Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0093.p
                Cadastramento Guias Previdencia

    Alteracoes:
                            
.............................................................................*/ 

DEFINE TEMP-TABLE tt-cadgps NO-UNDO
    FIELD cdcooper LIKE crapcgp.cdcooper
    FIELD cdidenti LIKE crapcgp.cdidenti
    FIELD cddpagto LIKE crapcgp.cddpagto
    FIELD nrctadeb LIKE crapcgp.nrctadeb
    FIELD nmctadeb AS CHAR
    FIELD nrdconta LIKE crapcgp.nrdconta
    FIELD nmprimtl LIKE crapcgp.nmprimtl
    FIELD nrcpfcgc LIKE crapcgp.nrcpfcgc
    FIELD dsendres LIKE crapcgp.dsendres
    FIELD nmbairro LIKE crapcgp.nmbairro
    FIELD nrcepend LIKE crapcgp.nrcepend
    FIELD nrdddres LIKE crapcgp.nrdddres
    FIELD nrfonres LIKE crapcgp.nrfonres
    FIELD nmcidade LIKE crapcgp.nmcidade
    FIELD cdufresd LIKE crapcgp.cdufresd
    FIELD nrendres LIKE crapcgp.nrendres
    FIELD nrcxapst LIKE crapcgp.nrcxapst
    FIELD complend LIKE crapcgp.complend
    FIELD inpessoa LIKE crapcgp.inpessoa
    FIELD dspessoa AS CHAR
    FIELD nmextttl LIKE crapttl.nmextttl 
    FIELD tpcontri LIKE crapcgp.tpcontri
    FIELD idseqttl LIKE crapcgp.idseqttl
    FIELD flgrgatv LIKE crapcgp.flgrgatv
    FIELD flgdbaut LIKE crapcgp.flgdbaut
    FIELD vlrdinss LIKE crapcgp.vlrdinss
    FIELD vloutent LIKE crapcgp.vloutent
    FIELD vlrjuros LIKE crapcgp.vlrjuros
    FIELD vlrtotal AS DECI
    .
    
