/*..............................................................................

    Programa: b1wgen0058tt.i
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 18/04/2017

    Objetivo  : Definicao das Temp-Tables para tela de PROCURADORES

    Alteracoes: 17/08/2011 - Incluido campo dsdrendi na tt-crapavt (Guilherme).
    
                16/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                             (Adriano).
                             
                25/06/2013 - Inclusão de poderes Procurador/Representante
                             (Jean Michel).
                             
                09/02/2015 - Incluido campo na tt-crapavt que indica que o
                             representante possui cartão. (Renato Darosci - SUPERO).

                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
                
                17/11/2015 - Incluido campo idrspleg na tt-crapavt, 
                             PRJ. Ass. Conjunta (Jean Michel).

                18/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
..............................................................................*/

                  
DEFINE TEMP-TABLE tt-crapavt NO-UNDO 
    FIELD cdcooper LIKE crapavt.cdcooper 
    FIELD cddconta AS CHAR
    FIELD dsvalida AS CHAR
    FIELD cdcpfcgc AS CHAR
    FIELD nrdrowid AS ROWID
    FIELD dsdrendi AS CHAR EXTENT 6 /* descricao dos rendimentos */
    FIELD nrdeanos AS INT
    FIELD deletado AS LOG
    FIELD cddopcao AS CHAR
    FIELD dhinclus AS DATETIME
    FIELD cddctato AS CHAR
    FIELD dstipcta AS CHAR
    FIELD rowidavt AS ROWID
    FIELD dtmvtolt LIKE crapavt.dtmvtolt
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD tpdocava LIKE crapavt.tpdocava
    FIELD nrdocava LIKE crapavt.nrdocava
    FIELD cdoeddoc AS CHAR 
    FIELD cdufddoc LIKE crapavt.cdufddoc
    FIELD dtemddoc LIKE crapavt.dtemddoc
    FIELD dsproftl LIKE crapavt.dsproftl
    FIELD dtnascto LIKE crapavt.dtnascto
    FIELD cdsexcto LIKE crapavt.cdsexcto
    FIELD cdestcvl LIKE crapavt.cdestcvl
    FIELD dsestcvl AS CHAR
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD dsnatura LIKE crapavt.dsnatura
    FIELD nmmaecto LIKE crapavt.nmmaecto
    FIELD nmpaicto LIKE crapavt.nmpaicto
    FIELD nrcepend LIKE crapavt.nrcepend
    FIELD dsendres LIKE crapavt.dsendres
    FIELD nrendere LIKE crapavt.nrendere
    FIELD complend LIKE crapavt.complend
    FIELD nmbairro LIKE crapavt.nmbairro
    FIELD nmcidade LIKE crapavt.nmcidade
    FIELD cdufresd LIKE crapavt.cdufresd
    FIELD nrcxapst LIKE crapavt.nrcxapst
    FIELD dtvalida LIKE crapavt.dtvalida
    FIELD dtadmsoc LIKE crapavt.dtadmsoc
    FIELD flgdepec LIKE crapavt.flgdepec
    FIELD persocio LIKE crapavt.persocio
    FIELD vledvmto LIKE crapavt.vledvmto
    FIELD inhabmen LIKE crapavt.inhabmen
    FIELD dthabmen LIKE crapavt.dthabmen
    FIELD dshabmen AS CHAR
    FIELD nrctremp LIKE crapavt.nrctremp
    FIELD nrdctato LIKE crapavt.nrdctato
    FIELD nrdconta LIKE crapavt.nrdconta
    FIELD nrcpfcgc LIKE crapavt.nrcpfcgc
    FIELD vloutren LIKE crapavt.vloutren
    FIELD dsoutren LIKE crapavt.dsoutren
    FIELD dsrelbem LIKE crapavt.dsrelbem
    FIELD persemon LIKE crapavt.persemon
    FIELD qtprebem LIKE crapavt.qtprebem
    FIELD vlprebem LIKE crapavt.vlprebem
    FIELD vlrdobem LIKE crapavt.vlrdobem
    FIELD tpctrato LIKE crapavt.tpctrato
    FIELD fltemcrd AS INT /*  Indica que o representante possui cartão */
    FIELD idrspleg AS INT
    FIELD idorgexp LIKE crapavt.idorgexp
    FIELD cdnacion LIKE crapnac.cdnacion.

DEFINE TEMP-TABLE tt-crapavt-b NO-UNDO LIKE tt-crapavt.

DEF TEMP-TABLE tt-bens 
    FIELD dsrelbem LIKE crapbem.dsrelbem
    FIELD persemon LIKE crapbem.persemon
    FIELD qtprebem LIKE crapbem.qtprebem
    FIELD vlprebem LIKE crapbem.vlprebem
    FIELD vlrdobem LIKE crapbem.vlrdobem
    FIELD cdsequen AS INTE
    FIELD cddopcao AS CHAR
    FIELD deletado AS LOGICAL
    FIELD nrdrowid AS ROWID
    FIELD cpfdoben AS CHAR
    INDEX tt-bens1 cdsequen.

DEFINE TEMP-TABLE tt-crappod NO-UNDO LIKE crappod.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapavt-ant NO-UNDO LIKE tt-crapavt.

    DEFINE TEMP-TABLE tt-crapavt-atl NO-UNDO LIKE tt-crapavt-ant.

&ENDIF

/*............................................................................*/

