/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0052tt.i
    Autor(a): Jose Luis Marchezoni (DB1)
    Data    : Junho/2010                      Ultima atualizacao: 15/09/2017
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0052.
  
    Alteracoes: 18/10/2010 - Inclusao do campo tt-relat-rep.nrdconta(Joao-RKAM)
                
                27/01/2011 - Inclusao tabela tt-prod_serv_ativos (Jorge)
                
                14/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                             (Adriano).
                             
                25/04/2013 - Incluir campo cdufnatu na tt-relat-fis.
                           - Incluir campo cdufnatu na tt-crapass.
                           - Alterado dsnatura para usar like crapttl.dsnatura 
                             (Lucas R.)
                             
                08/11/2013 - Adicionado campo dsnatura na tt-crapass e 
                             nrfonres na tt-crapass-ant e tt-crapass-atl. 
                             (Reinert)
                             
                05/02/2014 - Inclusao de dtdemiss em tt-relat-cab (Carlos)
                
                15/05/2014 - Inclusao de cdestcv2, dsestcv2 em tt-crapass 
                             pois os campos cdestcvl, dsestcvl serao removidos
                             da tabelas crapass (Douglas - Chamado 131253)
                             
                10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                             (Tiago Castro - RKAM).

                07/08/2014 - Adicionar as colunas de estado civil na temp table
                             tt-crapass-ant (Douglas)

                13/08/2014 - Adicionar o campo nmconjug na tt-crapass
                             (Douglas)
                             
                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
                09/02/2015 - Incluido campo na tt-crapavt que indica que o
                             representante possui cartão. (Renato Darosci - SUPERO).

                13/07/2015 - Reformulacao cadastral (Gabriel-RKAM). 
                
                14/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
                19/11/2015 - Incluido campo idrspleg na tt-crapavt, 
                             PRJ. Ass. Conjunta (Jean Michel).  
                             
                04/01/2016 - Alterado o tipo dos campos tt-crapass.nrtelres, 
                             tt-crapass.nrtelcel de inteiro para decimal
                             (Adriano).
                
                28/01/2016 - Incluidos campos referentes a origem do endereco
                             e licenca ambiental na tt-crapass
                             Melhoria 147 (Heitor - RKAM)
							 
				15/09/2017 - Alterações referente a melhoria 339 (Kelvin).
.............................................................................*/

/* DEFINICOES PARA MATRIC[N].P */
DEFINE TEMP-TABLE tt-crapass NO-UNDO LIKE crapass
    FIELD cdagepac LIKE crapass.cdagenci
    FIELD cddempre LIKE crapttl.cdempres
    FIELD dtaltera LIKE crapalt.dtaltera
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD complend LIKE crapenc.complend
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcxapst LIKE crapenc.nrcxapst
    FIELD tpnacion LIKE crapttl.tpnacion
    FIELD cdocpttl LIKE crapttl.cdocpttl
    FIELD nrtelefo LIKE craptfc.nrtelefo
    FIELD nrdddtfc LIKE craptfc.nrdddtfc
    FIELD nmfansia LIKE crapjur.nmfansia
    FIELD nrinsest LIKE crapjur.nrinsest
    FIELD natjurid LIKE crapjur.natjurid FORMAT "zzz9"
    FIELD dtiniatv LIKE crapjur.dtiniatv
    FIELD cdseteco LIKE crapjur.cdseteco
    FIELD cdrmativ LIKE crapjur.cdrmativ
    FIELD cddconta AS CHAR
    FIELD rowidass AS ROWID
    FIELD dspessoa AS CHAR
    FIELD dssitcpf AS CHAR
    FIELD dsmotdem AS CHAR
    FIELD nmresage AS CHAR
    FIELD destpnac AS CHAR
    FIELD nmresemp AS CHAR
    FIELD dsocpttl AS CHAR
    FIELD rsnatjur AS CHAR
    FIELD nmseteco AS CHAR
    FIELD dsrmativ AS CHAR
    FIELD dtmvtoan AS DATE
    FIELD dthabmen AS DATE
    FIELD nrdeanos AS INT
    FIELD nrdmeses AS INT
    FIELD dsdidade AS CHAR
    FIELD idseqttl AS INT
    FIELD cdufnatu LIKE crapttl.cdufnatu
    FIELD dsnatura LIKE crapttl.dsnatura
    FIELD cdestcv2 AS INTE
    FIELD dsestcv2 AS CHAR
    FIELD nmconjug LIKE crapcje.nmconjug
    FIELD rowidcem AS ROWID
    FIELD nrdddres AS INTE
    FIELD nrtelres AS DEC
    FIELD nrdddcel AS INTE
    FIELD nrtelcel AS DEC
    FIELD cdopetfn AS INTE
    FIELD idorigee AS INTE
    FIELD nrlicamb AS DECI
	FIELD nrcepcor LIKE crapenc.nrcepend
	FIELD dsendcor LIKE crapenc.dsendere
	FIELD nrendcor LIKE crapenc.nrendere
	FIELD complcor LIKE crapenc.complend
	FIELD nmbaicor LIKE crapenc.nmbairro
	FIELD nmcidcor LIKE crapenc.nmcidade
	FIELD cdufcorr LIKE crapenc.cdufende
	FIELD nrpstcor LIKE crapenc.nrcxapst
	FIELD idoricor AS INTE.
	
	
    
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
    FIELD cdoeddoc LIKE crapavt.cdoeddoc
    FIELD cdufddoc LIKE crapavt.cdufddoc
    FIELD dtemddoc LIKE crapavt.dtemddoc
    FIELD dsproftl LIKE crapavt.dsproftl
    FIELD dtnascto LIKE crapavt.dtnascto
    FIELD cdsexcto LIKE crapavt.cdsexcto
    FIELD cdestcvl LIKE crapavt.cdestcvl
    FIELD dsestcvl AS CHAR
    FIELD dsnacion LIKE crapavt.dsnacion
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
    FIELD idrspleg AS INT.

/* MENSAGENS DE ALERTA CONF. A CONTA */
DEFINE TEMP-TABLE tt-alertas NO-UNDO
    FIELD cdalerta AS INTE
    FIELD dsalerta AS CHAR
    FIELD qtdpausa AS INTE
    FIELD tpalerta AS CHAR INITIAL "I".

/* PARCELAMENTO DE CAPITAL MATRIC_PC.P */
DEFINE TEMP-TABLE tt-parccap NO-UNDO
    FIELD dtrefere AS DATE
    FIELD vlparcel AS DEC
    FIELD nrseqdig AS INTE.

/* RELATORIO - DEFINICOES PARA IMPMATRIC.P */
DEFINE TEMP-TABLE tt-relat-cab NO-UNDO
    /* f_cabecalho - f_cooperativa */
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD dsendcop LIKE crapcop.dsendcop
    FIELD nrdocnpj AS CHAR
    FIELD nrmatric AS CHAR
    FIELD nrdconta AS CHAR
    /* f_termo */
    FIELD dtadmiss LIKE crapass.dtadmiss
    /* f_assina */
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmcidade LIKE crapcop.nmcidade
    FIELD dtmvtolt AS DATE FORMAT "99/99/9999"
    FIELD nmrescop AS CHAR EXTENT 2
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dtdemiss LIKE crapass.dtdemiss.

DEFINE TEMP-TABLE tt-relat-par NO-UNDO
    /* f_autoriza */
    FIELD nrdconta AS CHAR
    FIELD nrmatric AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD dsdprazo AS CHAR FORMAT "x(2)"
    FIELD vlparcel /*LIKE crapsdc.vllanmto*/ AS CHAR
    FIELD dsparcel AS CHAR EXTENT 2
    FIELD dtdebito LIKE crapsdc.dtrefere.

DEFINE TEMP-TABLE tt-relat-fis NO-UNDO
    /* f_fisica */
    FIELD cdagenci LIKE crapass.cdagenci 
    FIELD nmresage LIKE crapage.nmresage
    FIELD nrdconta AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD nrdocptl LIKE crapass.nrdocptl
    FIELD cdoedptl LIKE crapass.cdoedptl
    FIELD cdufdptl LIKE crapass.cdufdptl
    FIELD dtemdptl LIKE crapass.dtemdptl
    FIELD nmmaettl LIKE crapttl.nmmaettl
    FIELD nmpaittl LIKE crapttl.nmpaittl        
    FIELD dtnasctl LIKE crapass.dtnasctl
    FIELD cdsexotl AS CHAR FORMAT "X"
    FIELD dsnacion LIKE crapass.dsnacion
    FIELD dsnatura LIKE crapttl.dsnatura 
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere AS CHAR
    FIELD complend LIKE crapenc.complend
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende
    FIELD nrcepend AS CHAR
    FIELD dsocpttl AS CHAR FORMAT "x(50)" 
    FIELD nmempres AS CHAR FORMAT "x(35)"
    FIELD cdturnos LIKE crapttl.cdturnos
    FIELD nrcadast AS CHAR
    FIELD dsestcvl AS CHAR FORMAT "x(30)"
    FIELD nmconjug LIKE crapcje.nmconjug
    FIELD cdufnatu LIKE crapttl.cdufnatu.

DEFINE TEMP-TABLE tt-relat-jur NO-UNDO
    /* f_juridica */
    FIELD nmresage LIKE crapage.nmresage
    FIELD nrdconta AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmfansia LIKE crapjur.nmfansia
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD nrinsest AS CHAR FORMAT "x(17)"
    FIELD dtiniatv LIKE crapjur.dtiniatv
    FIELD rsnatjur AS CHAR FORMAT "x(15)"
    FIELD cdrmativ LIKE crapjur.cdrmativ
    FIELD dsrmativ AS CHAR FORMAT "x(40)"
    FIELD dsendere LIKE crapenc.dsendere
    FIELD nrendere AS CHAR
    FIELD complend LIKE crapenc.complend
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD cdufende LIKE crapenc.cdufende 
    FIELD nrcepend AS CHAR
    FIELD nrdddtfc LIKE craptfc.nrdddtfc
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrtelefo LIKE craptfc.nrtelefo.

DEFINE TEMP-TABLE tt-relat-rep NO-UNDO
    /* f_repres */
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD dsproftl LIKE crapavt.dsproftl
    FIELD nrdconta AS CHAR.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapass-ant NO-UNDO LIKE crapass
        /* campos crapenc, craptfc */
        FIELD nrcepend LIKE crapenc.nrcepend
        FIELD nrendere LIKE crapenc.nrendere
        FIELD dsendere LIKE crapenc.dsendere
        FIELD complend LIKE crapenc.complend
        FIELD nmbairro LIKE crapenc.nmbairro
        FIELD nmcidade LIKE crapenc.nmcidade
        FIELD cdufende LIKE crapenc.cdufende
        FIELD nrcxapst LIKE crapenc.nrcxapst
        FIELD nrtelefo LIKE craptfc.nrtelefo
        FIELD nrdddtfc LIKE craptfc.nrdddtfc
        /* campos crapttl */
        FIELD tpnacion LIKE crapttl.tpnacion
        FIELD cdocpttl LIKE crapttl.cdocpttl
        FIELD cdoperad LIKE crapttl.cdoperad
        /* campos crapjur */
        FIELD nmfansia LIKE crapjur.nmfansia
        FIELD nrinsest LIKE crapjur.nrinsest
        FIELD natjurid LIKE crapjur.natjurid FORMAT "zzz9"
        FIELD dtiniatv LIKE crapjur.dtiniatv
        FIELD cdseteco LIKE crapjur.cdseteco
        FIELD cdrmativ LIKE crapjur.cdrmativ
        FIELD nrfonres AS CHAR
        FIELD cdestcvl LIKE gnetcvl.cdestcvl
        FIELD dsestcvl LIKE gnetcvl.dsestcvl.

    DEFINE TEMP-TABLE tt-crapass-atl NO-UNDO LIKE tt-crapass-ant.

&ENDIF


/* Produtos e Servicos Ativos */
DEFINE TEMP-TABLE tt-prod_serv_ativos NO-UNDO
    FIELD cdseqcia AS INTE
    FIELD nmproser AS CHAR
    INDEX tt-prod_serv_ativos AS PRIMARY nmproser.

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

/*
DEF TEMP-TABLE tt-crapcrl  NO-UNDO
    FIELD cdcooper AS INT
    FIELD nrctamen AS INT
    FIELD nrcpfmen AS DEC
    FIELD idseqmen AS INT
    FIELD nrdconta AS INT
    FIELD nrcpfcgc AS DEC
    FIELD nmrespon AS CHAR
    FIELD nridenti AS CHAR
    FIELD tpdeiden AS CHAR
    FIELD dsorgemi AS CHAR
    FIELD cdufiden AS CHAR
    FIELD dtemiden AS DATE
    FIELD dtnascin AS DATE
    FIELD cddosexo AS INT
    FIELD cdestciv AS INT
    FIELD dsnacion AS CHAR
    FIELD dsnatura AS CHAR
    FIELD cdcepres AS DEC
    FIELD dsendres AS CHAR
    FIELD nrendres AS INT
    FIELD dscomres AS CHAR
    FIELD dsbaires AS CHAR
    FIELD nrcxpost AS INT
    FIELD dscidres AS CHAR
    FIELD dsdufres AS CHAR
    FIELD nmpairsp AS CHAR
    FIELD nmmaersp AS CHAR
    FIELD deletado AS LOG
    FIELD cddopcao AS CHAR
    FIELD nrdrowid AS ROWID
    FIELD cddctato AS INT
    FIELD dsestcvl AS CHAR
    FIELD dtmvtolt AS DATE.
  */
/*...........................................................................*/


