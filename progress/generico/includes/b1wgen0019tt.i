/*..............................................................................

   Programa: b1wgen0019tt.i                  
   Autor   : Murilo/David
   Data    : Agosto/2007                      Ultima atualizacao: 06/03/2018 

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0019.p

   Alteracoes: 05/03/2008 - Inclusao de novas temp-tables (David).
    
               13/03/2008 - Continuar implementacao da BO 19 (David).
               
               01/07/2009 - Inclusao de campo dstitulo na temp-table
                            tt-cabec-limcredito (GATI - Eder).
                            
               10/12/2009 - Incluir campos novos para o Rating (Gabriel).
                          - Substituido campo vlopescr por vltotsfn nas 
                            TEMP-TABLE tt-dados-ctr e tt-dados-prp (Elton).
                            
               23/06/2010 - Incluir campo de envio a sede (Gabriel).
               
               21/10/2010 - Inclusao de campos de linha de credito nas 
                            temp-tables de informacoes do limite e de proposta
                            de limite (tt-cabec-limcredito e 
                            tt-proposta-limcredito) - (GATI - Eder).
                            
               11/01/2010 - Incluido o campo dsencfi3 nas temp-table 
                            tt-cabec-limcredito e tt-dados-ctr (Adriano).   
                            
               24/05/2011 - Incluir campo dsendav3 na tt-avais-ctr (David).
               
               25/05/2011 - Incluido o campo endeass3 na tt-dados-ctr. 
                            (Fabricio)
                
               12/11/2012 - Incluido temp-table tt-ge-limite , referente ao 
                            Projeto GE (Lucas R.).
                            
               18/03/2014 - Incluir campo flgdigit na temp-table 
                            tt-cabec-limcredito (Lucas R.)
                            
               02/07/2014 - Incluir campo de observacao (Chamado 169007) 
                            (Jonata - RKAM).   
                            
               07/07/2014 - Inclusao da include b1wgen0138tt para uso da
                            temp-table tt-grupo.(Tiago Castro - RKAM)       
                            
               22/08/2014 - Incluir campos dtinivig e cddlinha na temp-table
                            tt-dados-ctr Projeto CET (Lucas R./Gielow)
                            
               23/12/2014 - Incluir o campo qtrenova, dtrenova e tprenova na
                            temp-table tt-cabec-limcredito. (James)
							
               09/01/2015 - Incluido novos campos na tt-proposta-
                            nrgarope, nrinfcad, nrliquid, nrpatlvr, 
                            vltotsfn, nrperger. 
                            SD 237152 (Tiago/Gielow).
             
               06/04/2015 - Consultas automatizadas (Jonata-RKAM).   
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
               
               09/12/2015 - Adicionada nova temp-table da craplim. SD  353115 (Kelvin)
                                                
               05/12/2017 - Adicionado campo idcobope na temp-table tt-dados-prp. 
                            Projeto 404 (Lombardi)
                                                
               06/03/2018 - Adicionado campo idcobope na temp-table tt-cabec-limcredito.
                            (PRJ404 Reinert)
               21/03/2019 - Ajuste no Termo de Recisao para assinatura eletronica
                            Pj470 SM 1 - Ze Gracik - Mouts

			   09/07/2019 - Adicionado outras rendas do conjuge.
			                Rubens Lima - Mouts


..............................................................................*/

DEF TEMP-TABLE tt-limite-credito NO-UNDO
    FIELD vllimcre AS DECI.
    
DEF TEMP-TABLE tt-cabec-limcredito NO-UNDO
    FIELD vllimite AS DECI
    FIELD dslimcre AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dsfimvig AS CHAR
    FIELD dtfimvig AS DATE
    FIELD nrctrlim AS INTE
    FIELD qtdiavig AS INTE   
    FIELD dsencfi1 AS CHAR
    FIELD dsencfi2 AS CHAR
    FIELD dsencfi3 AS CHAR
    FIELD dssitlli AS CHAR
    FIELD dsmotivo AS CHAR
    FIELD nmoperad AS CHAR
    FIELD flgpropo AS LOGI
    FIELD nrctrpro AS INTE
    FIELD cdlinpro AS INTE
    FIELD vllimpro AS DECI
    FIELD dstitulo AS CHAR
    FIELD nmopelib AS CHAR
    FIELD flgenvio AS CHAR
    FIELD flgenpro AS LOGI
    FIELD cddlinha AS INTE
    FIELD dsdlinha AS CHAR
    FIELD flgdigit AS LOGI
    FIELD dsobserv AS CHAR
    FIELD qtrenova LIKE craplim.qtrenova
    FIELD dtrenova LIKE craplim.dtrenova
    FIELD tprenova LIKE craplim.tprenova
    FIELD dstprenv AS CHAR
    FIELD dslimpro AS CHAR
    FIELD idcobope AS INTE
    FIELD dsdtxfix AS CHAR
    FIELD nivrisco AS CHAR.

DEF TEMP-TABLE tt-ultimas-alteracoes NO-UNDO
    FIELD nrctrlim AS INTE  
    FIELD dtinivig AS DATE
    FIELD dtfimvig AS DATE  
    FIELD vllimite AS DECI
    FIELD dssitlli AS CHAR      
    FIELD dsmotivo AS CHAR.

DEF TEMP-TABLE tt-proposta-limcredito NO-UNDO
    FIELD nrctrpro AS INTE
    FIELD vllimpro AS DECI
    FIELD flgimpnp AS LOGI
    FIELD cddlinha AS INTE
    FIELD dsdlinha AS CHAR
    FIELD nrgarope AS INTE
    FIELD nrinfcad AS INTE
    FIELD nrliquid AS INTE
    FIELD nrpatlvr AS INTE
    FIELD vltotsfn AS DECI
    FIELD nrperger LIKE craplim.nrperger
    FIELD nrcpfcjg AS DECI 
    FIELD nrctacje AS INTE
    FIELD dtconbir AS DATE
    FIELD dsdtxfix AS CHAR
    FIELD nivrisco AS CHAR
    FIELD inconcje AS INTE.

DEF TEMP-TABLE tt-dados-ctr NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nmrescop AS CHAR
    FIELD nrdocnpj AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD dsendcop AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD inpessoa AS INTE
    FIELD nrcpfcgc AS CHAR
    FIELD nrdrgass AS CHAR
    FIELD endeass1 AS CHAR
    FIELD endeass2 AS CHAR
    FIELD endeass3 AS CHAR
    FIELD cdagenci AS INTE
    FIELD nmcidpac AS CHAR
    FIELD nrctrlim AS INTE
    FIELD dsctrlim AS CHAR
    FIELD vllimite AS DECI
    FIELD qtdiavig AS INTE
    FIELD dsencfi1 AS CHAR
    FIELD dsencfi2 AS CHAR
    FIELD dsencfi3 AS CHAR
    FIELD dsvllim1 AS CHAR
    FIELD dsvllim2 AS CHAR
    FIELD dsemsctr AS CHAR
    FIELD nmoperad AS CHAR
    FIELD ddmvtolt AS INTE
    FIELD aamvtolt AS INTE
    FIELD dsdtmvt1 AS CHAR
    FIELD dsdtmvt2 AS CHAR
    FIELD dsvlnpr1 AS CHAR
    FIELD dsvlnpr2 AS CHAR
    FIELD dsmesref AS CHAR
    FIELD dsdmoeda AS CHAR
    FIELD nrgarope AS INTE
    FIELD nrinfcad AS INTE
    FIELD nrliquid AS INTE
    FIELD nrpatlvr AS INTE
    FIELD vltotsfn AS INTE 
    FIELD perfatcl AS DECI
    FIELD dtinivig LIKE craplim.dtinivig
    FIELD cddlinha LIKE craplim.cddlinha 
    FIELD txcetano AS DECI
    FIELD txcetmes AS DECI
    FIELD dtfimvig LIKE craplim.dtfimvig
    FIELD dtrenova LIKE craplim.dtrenova.

DEF TEMP-TABLE tt-dados-prp NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD nmcidade AS CHAR
    FIELD nrdconta AS INTE
    FIELD nrmatric AS INTE
    FIELD nrcpfcgc AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nmsegntl AS CHAR
    FIELD dtadmiss AS DATE
    FIELD nmresage AS CHAR
    FIELD dsempres AS CHAR
    FIELD nrdofone AS CHAR
    FIELD dstipcta AS CHAR
    FIELD dssitdct AS CHAR
    FIELD nrctrlim AS INTE
    FIELD vllimite AS DECI
    FIELD vllimcre AS DECI
    FIELD vlsalari AS DECI
    FIELD vlsalcon AS DECI
    FIELD vloutras AS DECI
    FIELD vlrencjg AS DECI
    FIELD vlalugue AS DECI
    FIELD dsobser1 AS CHAR
    FIELD dsobser2 AS CHAR
    FIELD dsobser3 AS CHAR
    FIELD vlutiliz AS DECI
    FIELD vlaplica AS DECI
    FIELD vlsmdtri AS DECI DECIMALS 2
    FIELD vlcaptal AS DECI
    FIELD vlprepla AS DECI
    FIELD vltotccr AS DECI
    FIELD vltotemp AS DECI
    FIELD vltotpre AS DECI
    FIELD nmoperad AS CHAR
    FIELD dsemsprp AS CHAR
    FIELD nrgarope AS INTE
    FIELD nrinfcad AS INTE
    FIELD nrliquid AS INTE
    FIELD nrpatlvr AS INTE
    FIELD vltotsfn AS DECI
    FIELD perfatcl AS DECI
    FIELD tpregist AS INTE
    FIELD nrctaav1 AS INTE
    FIELD nrctaav2 AS INTE
    FIELD dsobserv AS CHAR
    FIELD inconcje AS INTE
    FIELD nrcpfav1 AS DECI
    FIELD nrcpfav2 AS DECI
    FIELD nrcpfcjg AS DECI
    FIELD nrctacje AS INTE
    FIELD inpesso1 AS INTE
    FIELD inpesso2 AS INTE
    FIELD idcobope AS INTE
    FIELD inpessoa AS INTE
    FIELD dtiniatv AS DATE
    FIELD dsrmativ AS CHAR
    FIELD vlfatmes AS DECI.

DEF TEMP-TABLE tt-dados-rescisao NO-UNDO
    FIELD nmextcop AS CHAR
    FIELD nmexcop1 AS CHAR
    FIELD nmexcop2 AS CHAR
    FIELD nmcidade AS CHAR
    FIELD cdufdcop AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrctrlim AS INTE
    FIELD vllimite AS DECI
    FIELD dtmvtolt AS DATE
    FIELD nmoperad AS CHAR
    FIELD dsfrass1 AS CHAR  /* Pj470 SM 1 - Ze Gracik - Mouts */
    FIELD dsfrass2 AS CHAR  /* Pj470 SM 1 - Ze Gracik - Mouts */
    FIELD dsfrass3 AS CHAR  /* Pj470 SM 1 - Ze Gracik - Mouts */
    FIELD dsfrcop1 AS CHAR  /* Pj470 SM 1 - Ze Gracik - Mouts */
    FIELD dsfrcop2 AS CHAR. /* Pj470 SM 1 - Ze Gracik - Mouts */
           
DEF TEMP-TABLE tt-avais-ctr NO-UNDO    
    FIELD nmdavali AS CHAR
    FIELD cpfavali AS CHAR
    FIELD dsdocava AS CHAR
    FIELD nmconjug AS CHAR
    FIELD nrcpfcjg AS CHAR
    FIELD dsdoccjg AS CHAR
    FIELD dsendav1 AS CHAR
    FIELD dsendav2 AS CHAR
    FIELD dsendav3 AS CHAR.
    
DEF TEMP-TABLE tt-repres-ctr NO-UNDO
    FIELD nmrepres AS CHAR
    FIELD nrcpfrep AS CHAR
    FIELD dsdocrep AS CHAR
    FIELD cdoedrep AS CHAR.

DEF TEMP-TABLE tt-craplim NO-UNDO LIKE craplim.
 
/*............................................................................*/





