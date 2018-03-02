/*..............................................................................

    Programa: b1wgen0051tt.i
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 21/07/2017

    Objetivo  : Definicao das Temp-Tables

    Alteracoes: 28/05/2012 - Criado a temp-table tt-resp-legal, tt-bens,
                             tt-crapavt e criado os campos dtnasttl, inhabmen 
                             na table tt-cabec (Adriano).
   
                17/02/2015 - Incluido campo na tt-crapavt que indica que o
                             representante possui cartão.
                             (Renato Darosci - SUPERO).
                             
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).   
                
                24/11/2015 - Incluido campo idrspleg na tt-crapavt, 
                             PRJ. Ass. Conjunta (Jean Michel).        
                             
                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)             
                             
                21/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)               
                             
				02/10/2017 - Incluido campo tpregtrb na tt-cabec 
				            (Projeto 410 - RF 2 e 3 - Diogo - Mouts)		
                             
                06/02/2018 -  Incluido campo cdcatego na tt-cabec. PRJ366 (Lombardi)					 
..............................................................................*/


DEFINE TEMP-TABLE tt-cabec NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrmatric LIKE crapass.nrmatric
    FIELD cdagenci LIKE crapage.cdagenci
    FIELD dsagenci LIKE crapage.nmresage
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dspessoa AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD cdsexotl AS CHAR
    FIELD cdestcvl LIKE crapttl.cdestcvl
    FIELD dsestcvl LIKE gnetcvl.rsestcvl
    FIELD cdtipcta LIKE crapass.cdtipcta
    FIELD dstipcta LIKE craptip.dstipcta
    FIELD cdsitdct LIKE crapass.cdsitdct
    FIELD dssitdct AS CHAR
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD nmfansia AS CHAR
    FIELD dtnasttl AS DATE
    FIELD inhabmen AS INT
	FIELD tpregtrb AS INT
    FIELD cdcatego LIKE crapass.cdcatego.

DEFINE TEMP-TABLE tt-dados-ass NO-UNDO
    FIELD inpessoa LIKE crapass.inpessoa.

DEFINE TEMP-TABLE tt-titular NO-UNDO
    FIELD idseqttl LIKE crapttl.idseqttl  
    FIELD nmextttl LIKE crapttl.nmextttl.

DEFINE TEMP-TABLE tt-crapass NO-UNDO LIKE crapass
    FIELD dstipcta AS CHAR
    FIELD dsagenci AS CHAR
    FIELD cdcpfcgc AS CHAR
    FIELD cdcpfstl AS CHAR    
    FIELD dssitdct AS CHAR
    FIELD nmfansia AS CHAR
    FIELD dtaltera AS DATE.
    

DEFINE TEMP-TABLE tt-crapttl NO-UNDO LIKE crapttl
    FIELD dsgraupr AS CHAR
    FIELD dsestcvl AS CHAR
    FIELD tpsexotl AS CHAR. 

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
    FIELD fltemcrd AS INT  /* Indica que o representante possui cartão */
    FIELD idrspleg AS INT
    FIELD idorgexp AS CHAR 
    FIELD cdnacion LIKE crapavt.cdnacion.

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

/*............................................................................*/
