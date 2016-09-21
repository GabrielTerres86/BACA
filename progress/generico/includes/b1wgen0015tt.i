/*..............................................................................

   Programa: b1wgen0015tt.i                  
   Autor   : David
   Data    : Fevereiro/2008                    Ultima atualizacao: 10/02/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0015.p

   Alteracoes: 14/04/2008 - Adaptacao para agendamentos (David).

               19/06/2008 - Incluir temp-tables para rotina de Internet (David)
               
               05/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               10/01/2011 - Retirar tudo que for de COBRANCA da rotina
                            de INTERNET (Gabriel)             
                            
               11/10/2011 - Incluir idtpdpag na tt-limite (Guilherme)
               
               13/03/2012 - Alterações para rotina INTERNET trabalhar com 
                            a BO15 (Lucas).
                            
               14/05/2012 - Projeto TED Internet (David).    
               
               11/12/2012 - Incluso campos na Temp-Table tt-dados-titular (Daniel)
                            
               27/03/2013 - Incluir descricao da agencia nas contas cadastradas
                            (Gabriel)   
                            
               17/04/2013 - Incluso novos campos na tt-limites-internet,
                            tt-dados-habilitacao e tt-dados-titular
                            (David Kruger).
                            
               22/07/2013 - Adicionado campo dtblutsh em tt-dados-titular. (Jorge)
               
               30/01/2014 - Adicionado campo cdsitsnh para a tt-dados-ura.
                            (Reinert)
                            
               15/12/2014 - Melhorias Cadastro de Favorecidos TED
                            (André Santos - SUPERO)
                            
               15/04/2015 - Inclusão do campo nrispbif na temp-table
                            tt-bancos-favorecido e tt-autorizacao-favorecido
                            e criação da tt-crapban-ispb SD271603 FDR041 (Vanessa)
                            
               10/02/2016 - Inclusao do campo nmageban na tt tt-contas-cadastradas
                            (Jean Michel).

..............................................................................*/

DEF TEMP-TABLE tt-limite                                                NO-UNDO
    FIELD hrinipag AS CHAR
    FIELD hrfimpag AS CHAR
    FIELD idesthor AS INTE
    FIELD flsgproc AS LOGI
    FIELD qtmesagd AS INTE
    FIELD idtpdpag AS INTE /* 1 - Transf / 2 - Pagamento */
    FIELD iddiauti AS INTE /* 1 - Dia util / 2 - Dia nao util */
    FIELD nrhorini AS INTE
    FIELD nrhorfim AS INTE
    INDEX tt-limite1 idtpdpag.

DEF TEMP-TABLE tt-agenda-recorrente                                     NO-UNDO
    FIELD dtmvtopg LIKE craplau.dtmvtopg
    FIELD dtpagext AS CHAR
    FIELD flgtrans AS LOGI
    FIELD dscritic LIKE crapcri.dscritic.
    
DEF TEMP-TABLE tt-dados-ura                                             NO-UNDO
    FIELD nmopeura AS CHAR
    FIELD dtaltsnh AS CHAR
    FIELD cdsitsnh AS INTE.

DEF TEMP-TABLE tt-situacao-ura                                          NO-UNDO
    FIELD dssitura AS CHAR.

DEF TEMP-TABLE tt-situacao-internet                                     NO-UNDO
    FIELD dssitnet AS CHAR.

DEF TEMP-TABLE tt-represen-ctrnet NO-UNDO
    FIELD nrdctato AS INTE
    FIELD nmdavali AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD cdestcvl AS INTE
    FIELD dsestcvl AS CHAR
    FIELD dsproftl AS CHAR
    FIELD flgprepo AS LOGI
    FIELD dsendere AS CHAR
    FIELD nrendere AS CHAR
    FIELD complend AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufende AS CHAR.
                                       
DEF TEMP-TABLE tt-dados-ctrnet NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nmrescop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD dsendweb AS CHAR
    FIELD nrdconta AS INTE
    FIELD inpessoa AS INTE
    FIELD nmprimlt AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dsdiaace AS CHAR
    FIELD nmoperad AS CHAR
    FIELD dsrefere AS CHAR
    FIELD dsmvtolt AS CHAR.
    
DEF TEMP-TABLE tt-dados-preposto NO-UNDO
    FIELD nrdctato AS INTE
    FIELD nmdavali AS CHAR
    FIELD nrcpfcgc AS DECI
    FIELD dscpfcgc AS CHAR
    FIELD dsproftl AS CHAR
    FIELD flgatual AS LOGI.
    
DEF TEMP-TABLE tt-dados-habilitacao NO-UNDO
    FIELD vllimweb AS DECI
    FIELD vllimtrf AS DECI
    FIELD vllimpgo AS DECI
    FIELD inpessoa AS INTE
    FIELD vllimted AS DECI
    FIELD vllimvrb AS DECI.

DEF TEMP-TABLE tt-dados-titular NO-UNDO
    FIELD idseqttl AS INTE
    FIELD nmextttl AS CHAR
    FIELD nmprepos AS CHAR
    FIELD dssitsnh AS CHAR
    FIELD dtlibera AS DATE
    FIELD hrlibera AS CHAR
    FIELD dtaltsnh AS DATE
    FIELD dtaltsit AS DATE
    FIELD dtultace AS DATE
    FIELD hrultace AS CHAR
    FIELD nmoperad AS CHAR
    FIELD vllimweb AS DECI
    FIELD vllimtrf AS DECI
    FIELD vllimpgo AS DECI
    FIELD nrcpfcgc AS DECI
    FIELD vllimted AS DECI
    FIELD dtlimweb AS DATE
    FIELD dtlimted AS DATE
    FIELD dtlimpgo AS DATE
    FIELD dtlimtrf AS DATE
    FIELD vllimvrb AS DECI 
    FIELD dtlimvrb AS DATE
    FIELD dtblutsh AS DATE.

DEF TEMP-TABLE tt-contas-pendentes NO-UNDO
    FIELD flgselec AS LOGICAL
    FIELD cddbanco LIKE crapcti.cddbanco
    FIELD nrispbif LIKE crapcti.nrispbif
    FIELD cdageban LIKE crapcti.cdageban
    FIELD nrctatrf LIKE crapcti.nrctatrf
    FIELD nmtitula LIKE crapcti.nmtitula
    FIELD nrcpfcgc AS CHAR
    FIELD dstransa AS CHAR
    FIELD dsprotoc LIKE crapcti.dsprotoc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD idseqreg AS INT
    FIELD dsctatrf AS CHAR
    FIELD insitfav LIKE crapcti.insitfav
    FIELD dssitfav AS CHAR
    FIELD dstipfav AS CHAR.

DEF TEMP-TABLE tt-contas-pendentes-pag NO-UNDO LIKE tt-contas-pendentes. 

DEF TEMP-TABLE tt-contas-cadastradas NO-UNDO
    FIELD intipdif LIKE crapcti.intipdif
    FIELD cddbanco LIKE crapcti.cddbanco
    FIELD cdageban LIKE crapcti.cdageban
    FIELD nrctatrf LIKE crapcti.nrctatrf
    FIELD nmtitula LIKE crapcti.nmtitula
    FIELD nrcpfcgc LIKE crapcti.nrcpfcgc
    FIELD dscpfcgc AS CHAR
    FIELD dstransa AS CHAR
    FIELD dsoperad AS CHAR
    FIELD insitcta LIKE crapcti.insitcta
    FIELD dssitcta AS CHAR
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD dsctatrf AS CHAR
    FIELD nmextbcc LIKE crapban.nmextbcc
    FIELD nrseqcad LIKE crapcti.nrseqcad
    FIELD dstipcta AS CHAR
    FIELD intipcta LIKE crapcti.intipcta
    FIELD dsageban AS CHAR
    FIELD nrispbif LIKE crapcti.nrispbif
    FIELD nmageban AS CHAR.

DEF TEMP-TABLE tt-bancos-favorecido NO-UNDO
    FIELD cddbanco LIKE crapban.cdbccxlt
    FIELD nmresbcc LIKE crapban.nmresbcc
    FIELD nrispbif LIKE crapban.nrispbif.

DEF TEMP-TABLE tt-autorizacao-favorecido NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD cdbcoctl LIKE crapcop.cdbcoctl
    FIELD nrispbif LIKE crapcti.nrispbif
    FIELD nmbcoctl LIKE crapban.nmextbcc
    FIELD cdagectl LIKE crapcop.cdagectl
    FIELD dttransa LIKE crapcti.dttransa
    FIELD hrtransa LIKE crapcti.hrtransa
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nmsegttl LIKE crapass.nmprimtl
    FIELD cddbanco LIKE crapcti.cddbanco
    FIELD nmdbanco LIKE crapban.nmextbcc
    FIELD cdageban LIKE crapcti.cdageban
    FIELD nrctatrf LIKE crapcti.nrctatrf
    FIELD nmtitula LIKE crapcti.nmtitula
    FIELD dsprotoc LIKE crapcti.dsprotoc
    FIELD nrtelfax LIKE crapage.nrtelfax
    FIELD dsdemail LIKE crapage.dsdemail
    FIELD nmopecad AS CHAR
    FIELD idsequen AS INTE
    FIELD intipcta AS INTE
    FIELD inpessoa AS INTE
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD indrecid AS RECID.

DEF TEMP-TABLE tt-tp-contas NO-UNDO
    FIELD nmtipcta AS CHAR 
    FIELD intipcta AS CHAR.

DEF TEMP-TABLE tt-finted NO-UNDO
    FIELD cdfinali AS INTE
    FIELD dsfinali AS CHAR
    FIELD flgselec AS LOGI.

DEF TEMP-TABLE tt-limites-internet NO-UNDO
    FIELD idseqttl LIKE crapsnh.idseqttl
    /* Limite totais */
    FIELD vllimweb LIKE crapsnh.vllimweb
    FIELD vllimpgo LIKE crapsnh.vllimpgo
    FIELD vllimtrf LIKE crapsnh.vllimtrf
    FIELD vllimted LIKE crapsnh.vllimted
    FIELD vllimvrb LIKE crapsnh.vllimvrb
    /* Limite utilizado */
    FIELD vlutlweb LIKE crapsnh.vllimweb
    FIELD vlutlpgo LIKE crapsnh.vllimpgo
    FIELD vlutltrf LIKE crapsnh.vllimtrf
    FIELD vlutlted LIKE crapsnh.vllimted
    /* Limite disponivel */
    FIELD vldspweb LIKE crapsnh.vllimweb
    FIELD vldsppgo LIKE crapsnh.vllimpgo
    FIELD vldsptrf LIKE crapsnh.vllimtrf
    FIELD vldspted LIKE crapsnh.vllimted
    /* Limite operacional cadastrado pela cooperativa */
    FIELD vlwebcop LIKE crapsnh.vllimweb
    FIELD vlpgocop LIKE crapsnh.vllimpgo
    FIELD vltrfcop LIKE crapsnh.vllimtrf
    FIELD vltedcop LIKE crapsnh.vllimted
    FIELD vlvrbcop LIKE crapsnh.vllimvrb
    INDEX tt-limites-internet1 AS PRIMARY idseqttl.

DEF TEMP-TABLE tt-protocolo-ted NO-UNDO
    FIELD cdtippro LIKE crappro.cdtippro
    FIELD dtmvtolt LIKE crappro.dtmvtolt
    FIELD dttransa LIKE crappro.dttransa
    FIELD hrautent LIKE crappro.hrautent
    FIELD vldocmto LIKE crappro.vldocmto
    FIELD nrdocmto LIKE crappro.nrdocmto
    FIELD nrseqaut LIKE crappro.nrseqaut
    FIELD dsinform LIKE crappro.dsinform
    FIELD dsprotoc LIKE crappro.dsprotoc
    FIELD nmprepos LIKE crappro.nmprepos
    FIELD nrcpfpre LIKE crappro.nrcpfpre
    FIELD nmoperad LIKE crapopi.nmoperad
    FIELD nrcpfope LIKE crappro.nrcpfope
    FIELD cdbcoctl LIKE crapcop.cdbcoctl
    FIELD cdagectl LIKE crapcop.cdagectl.

DEFINE TEMP-TABLE tt-crapban-ispb NO-UNDO LIKE crapban.

/*............................................................................*/
