/*..............................................................................

    Programa: b1wgen0080tt.i
    Autor   : Guilherme
    Data    : Agosto/2011 

    Objetivo  : Definicao das Temp-Tables para tela de PARTICIPACAO EM OUTRAS
                                                       EMPRESAS - CONTAS

    Alteracoes: 
   
..............................................................................*/

                                                                                
DEFINE TEMP-TABLE tt-crapepa NO-UNDO LIKE crapepa
    FIELD cddconta AS CHARACTER
    FIELD dsvalida AS CHARACTER
    FIELD cdcpfcgc AS CHARACTER
    FIELD dsestcvl AS CHARACTER
    FIELD nrdrowid AS ROWID
    FIELD nmseteco LIKE craptab.dstextab
    FIELD dsnatjur LIKE gncdntj.dsnatjur
    FIELD dsrmativ LIKE gnrativ.nmrmativ.

DEFINE TEMP-TABLE tt-crapepa-b NO-UNDO LIKE tt-crapepa.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapepa-ant NO-UNDO LIKE tt-crapepa.

    DEFINE TEMP-TABLE tt-crapepa-atl NO-UNDO LIKE tt-crapepa-ant.

&ENDIF

DEFINE TEMP-TABLE tt-dados-jur NO-UNDO
    FIELD nmprimtl AS CHAR
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dspessoa AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dtcnscpf LIKE crapass.dtcnscpf
    FIELD cdsitcpf LIKE crapass.cdsitcpf
    FIELD dssitcpf AS CHAR
    FIELD nmfatasi LIKE crapjur.nmfansia
    FIELD cdnatjur LIKE crapjur.natjurid
    FIELD dsnatjur LIKE gncdntj.dsnatjur
    FIELD cdrmativ LIKE crapjur.cdrmativ
    FIELD dsendweb LIKE crapjur.dsendweb
    FIELD nmtalttl LIKE crapjur.nmtalttl
    FIELD qtfoltal LIKE crapass.qtfoltal
    FIELD qtfilial LIKE crapjur.qtfilial
    FIELD qtfuncio LIKE crapjur.qtfuncio
    FIELD dtiniatv LIKE crapjur.dtiniatv
    FIELD cdseteco LIKE crapjur.cdseteco
    FIELD nmseteco LIKE craptab.dstextab
    FIELD dsrmativ LIKE gnrativ.nmrmativ
    FIELD dtcadass LIKE crapass.dtmvtolt
    FIELD dtadmiss LIKE crapepa.dtadmiss
    FIELD persocio LIKE crapepa.persocio
    FIELD nrdrowid AS ROWID
    FIELD nrctasoc LIKE crapepa.nrctasoc
    FIELD vledvmto LIKE crapepa.vledvmto.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-dados-jur-ant NO-UNDO 
        FIELD qtfoltal LIKE crapass.qtfoltal
        FIELD dtcnscpf LIKE crapass.dtcnscpf
        FIELD cdsitcpf LIKE crapass.cdsitcpf
        FIELD nmfansia LIKE crapjur.nmfansia
        FIELD natjurid LIKE crapjur.natjurid
        FIELD dtiniatv LIKE crapjur.dtiniatv
        FIELD cdrmativ LIKE crapjur.cdrmativ
        FIELD qtfilial LIKE crapjur.qtfilial
        FIELD qtfuncio LIKE crapjur.qtfuncio
        FIELD dsendweb LIKE crapjur.dsendweb
        FIELD nmtalttl LIKE crapjur.nmtalttl
        FIELD cdseteco LIKE crapjur.cdseteco
        FIELD dtadmiss LIKE crapepa.dtadmiss
        FIELD persocio LIKE crapepa.persocio.

    DEFINE TEMP-TABLE tt-dados-jur-atl NO-UNDO LIKE tt-dados-jur-ant.

&ENDIF

/*............................................................................*/
