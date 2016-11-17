/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0102tt.i
    Autor(a): Gabriel Capoia dos Santos (DB1)
    Data    : Julho/2011                        Ultima atualizacao: 22/11/2013

    Dados referentes ao programa:

    Objetivo  : Include com Temp-Tables para a BO b1wgen0102.

    Alteracoes: 
        22/11/2013 - GRAVAMES - Novos campos tpinclus/dtatugrv/cdsitgrv na
                     tt-aliena (Guilherme/SUPERO)

.............................................................................*/ 

DEF TEMP-TABLE tt-infoepr NO-UNDO 
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dtmvtolt LIKE crapepr.dtmvtolt.

DEF TEMP-TABLE tt-aliena NO-UNDO 
    FIELD cdcooper LIKE crapbpr.cdcooper
    FIELD nrdconta LIKE crapbpr.nrdconta
    FIELD tpctrpro LIKE crapbpr.tpctrpro
    FIELD nrctrpro LIKE crapbpr.nrctrpro
    FIELD idseqbem LIKE crapbpr.idseqbem
    FIELD dscatbem LIKE crapbpr.dscatbem
    FIELD dsbemfin LIKE crapbpr.dsbemfin
    FIELD flgalfid LIKE crapbpr.flgalfid
    FIELD dtvigseg LIKE crapbpr.dtvigseg
    FIELD flglbseg LIKE crapbpr.flglbseg
    FIELD flgrgcar LIKE crapbpr.flgrgcar
    FIELD tpinclus LIKE crapbpr.tpinclus
    FIELD dtatugrv LIKE crapbpr.dtatugrv
    FIELD cdsitgrv LIKE crapbpr.cdsitgrv
    FIELD flgperte AS LOGICAL.

DEF TEMP-TABLE tt-mensagens NO-UNDO
    FIELD nrsequen AS INTE
    FIELD dsmensag AS CHAR
    INDEX tt-mensagens-aliena1 AS PRIMARY nrsequen.
