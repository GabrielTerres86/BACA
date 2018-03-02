/*.............................................................................

    Programa: b1wgen0074tt.i
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 12/01/2016

    Objetivo  : Definicao das Temp-Tables, CONTAS - CONTA CORRENTE

    Alteracoes: 29/07/2010 - Incluir cdbcoctl na tt-conta-corr (Guilherme).
    
                08/02/2013 - Incluir campo flgrestr em tt-conta-corr (Lucas R.)
                
                12/06/2013 - Consorcio (Gabriel).
                
                03/07/2013 - Incluido a temp-table tt-dados-beneficiario
                             (Adriano).
               
                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
                             'flgcrdpa' (Jaison) 
                             
                10/07/2014 - Criada tt-critica-excl-titulares para armazenar
                             criticas ao deletar titulares com propostas
                             em aberto (Lucas Lunelli - Projeto Bancoob)
                             
                28/08/2014 - Incluir dscadpos na tt-conta-corr
                             (Lucas R/Thiago Rodrigues - Projeto cadastro Posivo)
                             
                23/03/2015 - Incluido o campo stacadas na tt-dados-beneficiario
                             (Adriano).
                             
                11/08/2015 - Inclusao do campo indserma na tt-conta-corr 
                             (Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi)
                             
                27/10/2015 - Inclusao do campo idastcjt na tt-conta-corr 
                             (Projeto 131 - Assinatura Conjunta (Jean Michel)
                             
                12/01/2016 - Remoção dos campos flgcrdpa e cdoplcpa do 
                             tt-conta-corr (Anderson)
                18/03/2016 - Inclusao campos na tt-conta-corr
				             PRJ207 - Esteira (Odirlei-AMcom)    
                             
                06/02/2018 - Incluido campo FIELD cdcatego e flblqtal. PRJ366 (Lombardi)
                             
.............................................................................*/



/*...........................................................................*/

DEFINE TEMP-TABLE tt-conta-corr NO-UNDO 
    FIELD cdagepac LIKE crapass.cdagenci
    FIELD dsagepac LIKE crapage.nmresage
    FIELD cdsitdct LIKE crapass.cdsitdct
    FIELD dssitdct AS CHAR
    FIELD cdtipcta LIKE crapass.cdtipcta
    FIELD dstipcta LIKE craptip.dstipcta
    FIELD cdbcochq LIKE crapass.cdbcochq
    FIELD nrdctitg LIKE crapass.nrdctitg
    FIELD dssititg AS CHAR
    FIELD cdagedbb LIKE crapcop.cdagedbb
    FIELD cdbcoitg AS INTE
    FIELD flgiddep LIKE crapass.flgiddep
    FIELD tpavsdeb LIKE crapass.tpavsdeb
    FIELD dsavsdeb AS CHAR
    FIELD tpextcta LIKE crapass.tpextcta
    FIELD dsextcta AS CHAR
    FIELD cdsecext LIKE crapass.cdsecext
    FIELD dssecext LIKE crapdes.nmsecext
    FIELD dtcnsscr LIKE crapass.dtcnsscr
    FIELD dtcnsspc LIKE crapass.dtcnsspc
    FIELD dtdsdspc LIKE crapass.dtdsdspc
    FIELD inadimpl LIKE crapass.inadimpl
    FIELD inlbacen LIKE crapass.inlbacen
    FIELD dtabtcoo LIKE crapass.dtmvtolt
    FIELD dtelimin LIKE crapass.dtelimin
    FIELD dtabtcct LIKE crapass.dtabtcct
    FIELD dtdemiss LIKE crapass.dtdemiss
    FIELD flgctitg LIKE crapass.flgctitg
    FIELD flgtitul AS LOG
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD btsolitg AS LOG
    FIELD btaltera AS LOG
    FIELD btencitg AS LOG
    FIELD btexcttl AS LOG
    FIELD cdbcoctl LIKE crapcop.cdbcoctl
    FIELD nrdrowid AS ROWID
    FIELD flgrestr AS LOG
    FIELD nrctacns LIKE crapass.nrctacns
    FIELD dscadpos AS CHAR
    FIELD indserma LIKE crapass.indserma
    FIELD idastcjt LIKE crapass.idastcjt
	FIELD dtdscore LIKE crapass.dtdscore
	FIELD dsdscore LIKE crapass.dsdscore
    FIELD cdcatego LIKE crapass.cdcatego
    FIELD flblqtal LIKE crapass.flblqtal.

DEFINE TEMP-TABLE tt-titulares NO-UNDO 
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl.

DEFINE TEMP-TABLE tt-critica-excl-titulares NO-UNDO 
    FIELD tipconfi AS INTE
    FIELD cdcritic AS INTE    
    FIELD dscritic AS CHAR.

DEFINE TEMP-TABLE tt-critica-cabec NO-UNDO 
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdconta AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD cdoperad LIKE crapope.cdoperad
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dtmvtolt AS DATE.

DEFINE TEMP-TABLE tt-critica-cadas NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR
    FIELD nmdatela AS CHAR.

DEFINE TEMP-TABLE tt-critica-ident NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-ident:HANDLE:PRIVATE-DATA = "IDENTIFICACAO".

DEFINE TEMP-TABLE tt-critica-filia NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-filia:HANDLE:PRIVATE-DATA = "FILIACAO".

DEFINE TEMP-TABLE tt-critica-ender NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-ender:HANDLE:PRIVATE-DATA = "ENDERECO".

DEFINE TEMP-TABLE tt-critica-comer NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-comer:HANDLE:PRIVATE-DATA = "COMERCIAL".

DEFINE TEMP-TABLE tt-critica-telef NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-telef:HANDLE:PRIVATE-DATA = "TELEFONES".

DEFINE TEMP-TABLE tt-critica-conju NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-conju:HANDLE:PRIVATE-DATA = "CONJUGE".

DEFINE TEMP-TABLE tt-critica-ctato NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-ctato:HANDLE:PRIVATE-DATA = "CONTATOS".

DEFINE TEMP-TABLE tt-critica-respo NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-respo:HANDLE:PRIVATE-DATA = "RESPONSAVEL LEGAL".

DEFINE TEMP-TABLE tt-critica-ctcor NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-ctcor:HANDLE:PRIVATE-DATA = "CONTA-CORRENTE".

/* usadas somente para conta pessoa juridica */
DEFINE TEMP-TABLE tt-critica-regis NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-regis:HANDLE:PRIVATE-DATA = "REGISTRO".

DEFINE TEMP-TABLE tt-critica-procu NO-UNDO 
    FIELD idseqttl AS INTE
    FIELD nmdcampo AS CHAR.

TEMP-TABLE tt-critica-procu:HANDLE:PRIVATE-DATA = "REPRESENTANTES/PROCURADORES".

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-conta-corr-ant NO-UNDO LIKE crapass.

    DEFINE TEMP-TABLE tt-conta-corr-atl NO-UNDO LIKE tt-conta-corr-ant.

&ENDIF


DEF TEMP-TABLE tt-dados-beneficiario NO-UNDO
    FIELD idbenefi AS INT       
    FIELD dtdcadas AS DATE                                    
    FIELD nmbenefi AS CHAR                                    
    FIELD dtdnasci AS DATE                                    
    FIELD tpdosexo AS CHAR                                    
    FIELD dtutirec AS INT                                     
    FIELD dscsitua AS CHAR                                    
    FIELD dtdvenci AS DATE                                    
    FIELD dtcompvi AS DATE                                    
    FIELD tpdpagto AS CHAR                                    
    FIELD cdorgins AS INT                                    
    FIELD nomdamae AS CHAR                                    
    FIELD nrdddtfc AS INT                                     
    FIELD nrtelefo AS INT                                     
    FIELD nrrecben AS DEC                      
    FIELD tpnrbene AS CHAR                                    
    FIELD cdcooper AS INT   
    FIELD cdcopsic AS INT
    FIELD nruniate AS INT                                     
    FIELD nrcepend AS INT                                     
    FIELD dsendere AS CHAR   
    FIELD nrendere AS INT
    FIELD nmbairro AS CHAR                                    
    FIELD nmcidade AS CHAR                                     
    FIELD cdufende AS CHAR                                     
    FIELD nrcpfcgc AS CHAR
    FIELD resdesde AS DATE
    FIELD dscespec AS CHAR
    FIELD nrdconta AS CHAR
    FIELD digdacta AS CHAR
    FIELD nmprocur AS CHAR
    FIELD cdagesic AS INT
    FIELD cdagepac AS INT
    FIELD nrdocpro AS CHAR
    FIELD nmresage AS CHAR
    FIELD razaosoc AS CHAR
    FIELD nmextttl AS CHAR
    FIELD idseqttl AS INT
    FIELD copvalid AS INT
    
    FIELD nrcpfttl AS DEC
    FIELD dsendttl AS CHAR
    FIELD nrendttl AS INT
    FIELD nrcepttl AS INT
    FIELD nmbaittl AS CHAR
    FIELD nmcidttl AS CHAR
    FIELD ufendttl AS CHAR
    FIELD nrdddttl AS INT
    FIELD nrtelttl AS INT
    FIELD stacadas AS CHAR.
