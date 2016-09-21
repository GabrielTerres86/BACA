/*.............................................................................

    Programa: b1wgen0091tt.i                  
    Autor   : André (DB1)
    Data    : Maio/2011                       Ultima atualizacao: 10/03/2015

    Dados referentes ao programa:

    Objetivo  : Temp-tables utlizadas na BO b1wgen0091.p
                Alteracao de Domicilio Bancario

    Alteracoes: 28/09/2011 - inclusao do campo cdagenci(pac) na temp-table
                             tt-log-process para ordernar por pac
                             (Vitor Inoue - GATI)
                            
                02/01/2012 - Criado a temp-table tt-cred_conta e incluido
                             o campo cdcooper na tt-rejeicoes (Adriano). 
                             
                11/01/2013 - Incluido os campos indresvi,dscresvi, dtcompvi,
                             dtprcomp na temp-table tt-benefic e o campo 
                             cdbloque na temp-table tt-rejeicoes.
                             Criado a temp-table tt-arquivo-comp-vida
                             (Adriano). 
                               
                22/05/2013 - Incluido as temp-tables tt-beneficiario,
                             tt-rubrica, tt-titulares, tt-creditos, 
                             tt-crawarq, tt-demonstrativo (Adriano).
                             
                26/09/2013 - Alterados campos da tt-titulares:
                             de crapttl.dsendres para crapenc.dsendere,
                             de crapttl.nmbairro para crapenc.nmbairro,
                             de crapttl.nmcidade para crapenc.nmcidade,
                             de crapttl.nrcepend para crapenc.nrcepend.
                             (Reinert)
                             
                10/03/2015 - Incluido o campo "stacadas" na temp-table 
                             tt-beneficiario devido a melhoria de 
                             Historico cadastral
                             (Adriano - Softdesk 231626).
                             
.............................................................................*/

DEFINE TEMP-TABLE tt-domins                                             NO-UNDO
    FIELD cdcooper LIKE crapttl.cdcooper
    FIELD nrdconta LIKE crapttl.nrdconta
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nmresage LIKE crapage.nmresage
    FIELD cdorgpag LIKE crapage.cdorgpag
    FIELD nrctacre LIKE crapass.nrdconta
    FIELD nmrecben LIKE crapcbi.nmrecben
    FIELD nrrecben LIKE crapcbi.nrrecben
    FIELD nrbenefi LIKE crapcbi.nrbenefi
    FIELD dsdircop LIKE crapcop.dsdircop
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD nmcidade LIKE crapage.nmcidade
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdagebcb LIKE crapcop.cdagebcb
    .


DEFINE TEMP-TABLE tt-benefic                                             NO-UNDO
    FIELD nmrecben LIKE crapcbi.nmrecben
    FIELD nrcpfcgc LIKE crapcbi.nrcpfcgc
    FIELD nrbenefi LIKE crapcbi.nrbenefi
    FIELD nrrecben LIKE crapcbi.nrrecben
    FIELD cdaginss LIKE crapcbi.cdaginss 
    FIELD dtatucad LIKE crapcbi.dtatucad 
    FIELD cdaltcad LIKE crapcbi.cdaltcad
    FIELD dtdenvio LIKE crapcbi.dtdenvio
    FIELD tpmepgto LIKE crapcbi.tpmepgto
    FIELD nrdconta LIKE crapcbi.nrdconta
    FIELD dtnasben LIKE crapcbi.dtnasben
    FIELD nmmaeben LIKE crapcbi.nmmaeben
    FIELD dsendben LIKE crapcbi.dsendben
    FIELD nmbairro LIKE crapcbi.nmbairro
    FIELD nrcepend LIKE crapcbi.nrcepend
    FIELD dtatuend LIKE crapcbi.dtatuend
    FIELD cdagenci LIKE crapcbi.cdagenci
    FIELD nmresage LIKE crapage.nmresage
    FIELD indresvi LIKE crapcbi.indresvi
    FIELD dscresvi AS CHAR
    FIELD dtcompvi LIKE crapcbi.dtcompvi
    FIELD dtprcomp LIKE crapcbi.dtcompvi.


DEFINE TEMP-TABLE tt-lancred
    FIELD nrrecben LIKE craplbi.nrrecben
    FIELD nrbenefi LIKE craplbi.nrbenefi
    FIELD dtiniper LIKE craplbi.dtiniper
    FIELD dtfimper LIKE craplbi.dtfimper
    FIELD dtinipag LIKE craplbi.dtinipag
    FIELD dtfimpag LIKE craplbi.dtfimpag
    FIELD vlliqcre LIKE craplbi.vlliqcre
    FIELD tpmepgto AS CHAR
    FIELD nrdconta LIKE craplbi.nrdconta
    FIELD cdagenci LIKE craplbi.cdagenci
    FIELD dtdpagto LIKE craplbi.dtdpagto
    FIELD flgcredi AS CHAR
    FIELD dtflgcre AS DATE
    FIELD dsespeci AS CHAR

    FIELD cdcooper LIKE crappbi.cdcooper
    FIELD dtmvtolt LIKE crappbi.dtmvtolt
    FIELD nmprocur LIKE crappbi.nmprocur
    FIELD dsdocpcd LIKE crappbi.dsdocpcd
    FIELD nrdocpcd LIKE crappbi.nrdocpcd
    FIELD cdoedpcd LIKE crappbi.cdoedpcd
    FIELD cdufdpcd LIKE crappbi.cdufdpcd
    FIELD dtvalprc LIKE crappbi.dtvalprc
    FIELD cdorgpag LIKE crappbi.cdorgpag
    FIELD flgexist AS LOGI
    .

DEFINE TEMP-TABLE tt-crapcbi-ant NO-UNDO
    FIELD dtdenvio LIKE crapcbi.dtdenvio
    FIELD cdaltcad LIKE crapcbi.cdaltcad
    FIELD nrnovcta LIKE crapcbi.nrnovcta
    FIELD tpnovmpg LIKE crapcbi.tpnovmpg
    FIELD dtatucad LIKE crapcbi.dtatucad
    .

DEFINE TEMP-TABLE tt-crapcbi-atl NO-UNDO LIKE tt-crapcbi-ant.


DEF TEMP-TABLE tt-arquivos    NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR FORMAT "x(11)"
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD nmarquiv AS CHAR FORMAT "x(35)"
    FIELD qtnaopag AS INTE FORMAT "zzzz9"
    FIELD vlnaopag AS DECI FORMAT "zzz,zz9.99"
    FIELD qtbloque AS INTE FORMAT "zzzz9"
    FIELD vlbloque AS DECI FORMAT "zzz,zz9.99"
    FIELD dsstatus AS CHAR FORMAT "x(14)".

DEF TEMP-TABLE tt-craplbi     NO-UNDO     LIKE craplbi
    FIELD instatus AS INTE INIT 0
    FIELD cdoperac AS INTE INIT 0 /* 1-Credito/2-Bloqueio/3-Desbloqueio */
    FIELD cdocorre AS INTE INIT 0.

DEF TEMP-TABLE tt-crapcbi     NO-UNDO     LIKE crapcbi
    FIELD instatus AS INTE INIT 0
    FIELD cdocorre AS INTE INIT 0.

DEF TEMP-TABLE tt-crappbi     NO-UNDO     LIKE crappbi
    FIELD instatus AS INTE INIT 0.

DEF TEMP-TABLE tt-rejeicoes   NO-UNDO
    FIELD tpmepgto LIKE tt-craplbi.tpmepgto
    FIELD cdoperac LIKE tt-craplbi.cdoperac
    FIELD cdagenci LIKE tt-craplbi.cdagenci
    FIELD nrrecben LIKE tt-craplbi.nrrecben
    FIELD nrbenefi LIKE tt-craplbi.nrbenefi
    FIELD nmrecben LIKE tt-crapcbi.nmrecben
    FIELD dtinipag LIKE tt-craplbi.dtinipag
    FIELD dtfimpag LIKE tt-craplbi.dtfimpag
    FIELD vllanmto LIKE tt-craplbi.vllanmto
    FIELD dscritic AS CHAR
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdbloque LIKE tt-craplbi.cdbloque
    FIELD nrdconta LIKE tt-craplbi.nrdconta.

DEF TEMP-TABLE tt-mensagens   NO-UNDO
    FIELD nrseqmsg AS INTE
    FIELD dsmensag AS CHAR.

DEF TEMP-TABLE tt-log-process NO-UNDO
    FIELD cdcooper AS INTE
    FIELD nmrescop AS CHAR
    FIELD nrseqlog AS INTE
    FIELD dslinlog AS CHAR FORMAT "x(78)"
    FIELD cdagenci AS INT.

DEF TEMP-TABLE tt-log-envio   NO-UNDO
    FIELD nrseqlog AS INTE
    FIELD dslinlog AS CHAR FORMAT "x(78)".

DEF TEMP-TABLE tt-extrato     NO-UNDO
    FIELD nrseqdig AS INTE
    FIELD cdtplote AS INTE
    FIELD iddobanc AS INTE
    FIELD dtgralot AS DATE
    FIELD nrseqlot AS INTE
    FIELD dtcomext AS CHAR 
    FIELD nmemiten AS CHAR FORMAT "x(40)"
    FIELD nrcnpjem AS DECI FORMAT "zzzzzzzzzzzzzz9"
    FIELD filler1  AS INTE 
    FIELD filler2  AS INTE 
    FIELD filler3  AS INTE 
    FIELD filler4  AS INTE 
    FIELD filler5  AS INTE 
    FIELD nrctrltr AS INTE
    FIELD dsclinha AS CHAR FORMAT "x(40)" EXTENT 3
    FIELD nrrecben AS DECI
    FIELD nrbenefi AS DECI FORMAT "zzzzzzzzz9"
    FIELD dtfimper AS DATE FORMAT "99/99/9999"
    FIELD dtiniper AS DATE FORMAT "99/99/9999"
    FIELD nrseqcre AS INTE
    FIELD nrespeci AS INTE
    FIELD dtinival AS DATE
    FIELD dtfimval AS DATE
    FIELD cdorgpag AS INTE
    FIELD tpmepgto AS INTE
    FIELD nrcpfcgc AS DECI FORMAT "zzzzzzzzzzzzzz9"
    FIELD dsdconta AS CHAR FORMAT "zzzzzzzz9.9"
    FIELD imprimsg AS INTE
    FIELD nmrecben AS CHAR FORMAT "x(28)"
    FIELD idregcmp AS INTE
    FIELD cdlanmto AS INTE EXTENT 33
    FIELD vllanmto AS DECI EXTENT 33
    FIELD vlrbruto AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlrdesco AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD vlrliqui AS DECI FORMAT "zzz,zzz,zz9.99"
    FIELD qtregdet AS INTE
    FIELD vlbrtdet AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vldscdet AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD vlliqdet AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
    FIELD instatus AS INTE
    FIELD cdocorre AS INTE
    FIELD cdagenci AS INTE
    INDEX tt-extrato1 cdorgpag.

DEF TEMP-TABLE tt-arq-cooper  NO-UNDO
    FIELD nmrescop AS CHAR  
    FIELD dsmensag AS CHAR FORMAT "X(40)".

DEF TEMP-TABLE tt-dif-import  NO-UNDO
    FIELD cdagenci AS INTE FORMAT "zz9"
    FIELD nmarquiv AS CHAR FORMAT "x(35)"
    FIELD qtnaopag AS INTE FORMAT "zzzz9"
    FIELD vlnaopag AS DECI FORMAT "zzz,zz9.99"
    FIELD qtbloque AS INTE FORMAT "zzzz9"
    FIELD vlbloque AS DECI FORMAT "zzz,zz9.99"
    FIELD dsstatus AS CHAR FORMAT "x(14)"
    FIELD qttotcre AS INTE FORMAT "zzzz9"     
    FIELD vltotcre AS DECI FORMAT "zzz,zz9.99"
    FIELD qttotblq AS INTE FORMAT "zzzz9"     
    FIELD vltotblq AS DECI FORMAT "zzz,zz9.99".


DEF TEMP-TABLE tt-cred_conta NO-UNDO
    LIKE tt-craplbi
    FIELD nrdrowid AS ROWID
    FIELD flgenvio AS LOG.

DEF TEMP-TABLE tt-arquivos-comp-vida NO-UNDO
    FIELD cdcooepr LIKE crapcop.cdcooper
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmarquiv AS CHAR
    FIELD dscsitua AS CHAR.

DEF TEMP-TABLE tt-beneficiario NO-UNDO
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


DEFINE TEMP-TABLE tt-titulares NO-UNDO 
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapttl.nrdconta
    FIELD nrcpfcgc LIKE crapttl.nrcpfcgc
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nmbairro LIKE crapenc.nmbairro
    FIELD nmcidade LIKE crapenc.nmcidade
    FIELD nrcepend LIKE crapenc.nrcepend
    FIELD cdufdttl LIKE crapttl.cdufdttl
    FIELD dsendres LIKE crapenc.dsendere
    FIELD nrendere LIKE crapenc.nrendere
    FIELD cdorgins AS INT
    FIELD cdagepac AS INT
    FIELD cdagesic LIKE crapcop.cdagesic
    FIELD nmresage LIKE crapage.nmresage
    FIELD nrdddtfc LIKE craptfc.nrdddtfc
    FIELD nrtelefo LIKE craptfc.nrtelefo
    FIELD nmmaettl LIKE crapttl.nmmaettl
    FIELD cdsexotl LIKE crapttl.cdsexotl
    FIELD dtnasttl LIKE crapttl.dtnasttl.
    

DEF TEMP-TABLE tt-rubrica NO-UNDO
    FIELD nrbenefi AS DEC
    FIELD nrrecben AS DEC
    FIELD cdrubric AS CHAR FORMAT "X(3)"
    FIELD vlrubric AS DEC  FORMAT "zzz,zz9.99-"
    FIELD nmrubric AS CHAR FORMAT "X(25)"
    FIELD tpnature AS CHAR FORMAT "X(1)".

DEF TEMP-TABLE tt-crawarq NO-UNDO
    FIELD nrsequen AS INT
    FIELD nmarquiv AS CHAR
    INDEX crawarq1 AS PRIMARY
          nrsequen nmarquiv.

DEF TEMP-TABLE tt-creditos NO-UNDO
    FIELD cdcooper AS INT
    FIELD cdagenci AS INT
    FIELD cdagesic AS INT
    FIELD cdagepac AS INT 

    FIELD dtdpagto AS DATE
    FIELD natdocre AS CHAR
    FIELD vldescto AS DEC 
    FIELD vlrbruto AS DEC 
    FIELD postoorg AS CHAR
    FIELD cdorgblq AS CHAR
    FIELD dtdcadas AS DATE
    FIELD nmbenefi AS CHAR
    FIELD dtdnasci AS DATE
    FIELD nrrecben AS DEC
    FIELD tpnrbene AS CHAR
    FIELD cdorgpag AS INT
    FIELD cdorgins AS INT
    /* Beneficio */
    FIELD cdbenefi AS DECI
    FIELD dtinicio AS DATE
    FIELD datfinal AS DATE
    FIELD sitbenef AS CHAR
    FIELD dscespec AS CHAR
    FIELD tpdpagto AS CHAR
    FIELD dtvalini AS DATE
    FIELD dtvalfin AS DATE
    FIELD vlrbenef AS DEC 
    /* Dados Conta Corrente Ass*/
    FIELD dscsitua AS CHAR
    FIELD nrdconta AS INT
    FIELD nrcpfcgc AS DEC
    FIELD idbenefi AS DECI
    FIELD cddigver AS CHAR
    FIELD geracred AS LOG
    FIELD inpessoa AS INTE.

DEF TEMP-TABLE tt-demonstrativo NO-UNDO
    FIELD cnpjemis AS CHAR
    FIELD nomeemis AS CHAR
    FIELD cdorgins AS INT 
    FIELD nrbenefi AS DEC
    FIELD nrrecben AS DEC
    FIELD dtdcompe AS CHAR
    FIELD nmbenefi AS CHAR 
    FIELD dtiniprd AS DATE
    FIELD dtfinprd AS DATE
    FIELD vlrbruto AS DEC
    FIELD vldescto AS DEC
    FIELD vlliquid AS DEC
    FIELD dscdamsg AS CHAR.
  

/*...........................................................................*/

