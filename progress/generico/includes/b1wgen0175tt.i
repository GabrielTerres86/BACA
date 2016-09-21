/*..............................................................................

    Programa: b1wgen0175tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andre Santos - Supero
    Data    : Setembro/2013                        Ultima atualizacao: /  /

    Dados referentes ao programa:

    Objetivo  : Arquivo com variáveis ultizadas na BO b1wgen0175.p
               
    Alteracoes: 
                            
..............................................................................*/

DEF TEMP-TABLE tt-devolu NO-UNDO
    FIELD cdbccxlt LIKE crapdev.cdbccxlt
    FIELD cdagechq LIKE crapdev.cdagechq
    FIELD nrdconta LIKE crapdev.nrdconta
    FIELD nrcheque LIKE crapdev.nrcheque
    FIELD vllanmto LIKE crapdev.vllanmto
    FIELD cdalinea LIKE crapdev.cdalinea
    FIELD insitdev LIKE crapdev.insitdev
    FIELD dssituac AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad.

DEF TEMP-TABLE tt-lancto NO-UNDO
    FIELD cdcooper AS INT
    FIELD dsbccxlt AS CHAR FORMAT               "x(8)"
    FIELD nrdocmto AS DECI FORMAT         "zz,zzz,zz9"
    FIELD nrdctitg AS CHAR FORMAT        "9.999.999-X"
    FIELD cdbanchq AS INT  FORMAT              "z,zz9"
    FIELD banco    AS INT  FORMAT              "z,zz9"
    FIELD cdagechq AS INT  FORMAT              "z,zz9"
    FIELD nrctachq AS DEC
    FIELD vllanmto AS DECI FORMAT  "zz,zzz,zzz,zz9.99"
    FIELD dssituac AS CHAR FORMAT              "x(10)"
    FIELD cdalinea AS INTE FORMAT                "zz9"
    FIELD nmoperad AS CHAR FORMAT              "x(18)"
    FIELD cddsitua AS INTE FORMAT                "zz9"
    FIELD flag     AS LOGI
    FIELD nrdrecid AS RECID.
 
DEF TEMP-TABLE tt-relchdv NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta     
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD cdpesqui LIKE crapdev.cdpesqui
    FIELD nrcheque LIKE crapdev.nrcheque
    FIELD vllanmto LIKE crapdev.vllanmto
    FIELD cdalinea LIKE crapdev.cdalinea
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD dsorigem AS CHAR FORMAT "x(13)"
    FIELD dstipcta AS CHAR FORMAT "x(15)"
    INDEX nrdconta IS PRIMARY nrdconta
          nrcheque. 
