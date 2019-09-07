/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL          |
  +------------------------------------------+------------------------------+
  | sistema/generico/includes/b1wgen0002tt.i | EMPR0001                     |
  +------------------------------------------+------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO) 

*******************************************************************************/






/*..............................................................................

   Programa: b1wgen0002tt.i
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 17/09/2018

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0002.p

   Alteracoes: 14/02/2008 - Incluir campo dtultpag na tt-saldo_epr (Guilherme).
   
               26/03/2008 - Utilizar tres digitos no campo qtpreemp (David).

               04/08/2008 - Incluir campo nrdconta na tt-dados-epr (David).
               
               07/05/2009 - Incluir campos cdlcremp e cdfinemp na tabela
                            tt-dados-epr (David).
               
               18/06/2009 - Substituido os campos dsdebens por dsrelbem e
                            vloutras por vldrendi nas TEMP-TABLES 
                            tt-impprop-epr e tt-proposta-epr (Elton). 
                            
               24/06/2010 - Incluir a tt-dados-gerais para trazer os dados
                            para a proposta de emprestimo (Gabriel).
                            
               09/07/2010 - Projeto de melhorias de operacoes (Gabriel).  
               
               10/01/2011 - Alterado o format do campo tt-dados-epr.qtprecal
                            para "zzz,zz9.9999-" (Adriano).
                            
               15/02/2011 - Tratamento no format do campo nmprimtl (Diego).
               
               21/03/2011 - Incluir nrcpfcgc na tt-dados-assoc (Guilherme).
               
               31/03/2011 - Incluídos qtpromis, flgimppr, flgimpnp e nrdrecid
                            na tt-dados-epr (André-DB1)
                            
               13/04/2011 - Incluídos nrendere, nrcxapst e complend na 
                            tt-interv-anuentes, necessário para
                            CEP integrado. (André - DB1)
                            
               29/04/2011 - Inclusao de campo bairro e endereco na 
                            tt-interv-anuente para facilitar leitura web.
                            (André - DB1)

               05/07/2011 - Implementacao para tratar novo calculo de 
                            emprestimo (taxa pre-fixada):
                            - Inclusao de campos na tt-proposta-epr: tpemprst,
                              cdtpempr, dstpempr (GATI - Diego/Eder). 
                              
               15/09/2011 - Inclusao dos campos  cdhistor e nrseqdig na 
                            temp-table tt-extrato_epr e inliquid na 
                            temp-table tt-dados-epr (Gabriel - DB1).
                            
               23/03/2012 - Inclusao do campo flgsaldo na temp-table             
                            tt-extrato_epr (Tiago).
                            
               04/04/2012 - Incluir campo dtlibera na tt-proposta-epr (Gabriel)

               08/10/2012 - Incluir campo dsextrat na tt-extrato_epr (Lucas R.) 

               10/12/2012 - Incluir temp-table tt-ge-epr Projeto GE (Lucas R.).

               30/01/2013 - Incluir campo flglista na tt-extrato_epr
                            (Lucas R.)

               31/01/2013 - Incluir dsidenti na tt-dados-epr (Lucas R.)

               26/02/2013 - Retirado tt-hisexibepar. Nao estava sendo usado.
                            (Irlan)

               04/04/2013 - Incluir * nas propostas do Price Pré fixado
                            (Gabriel).                  

               07/05/2013 - Adicionado campo da tt-dados-epr relativo a
                            digitalizaçao do documento (Lucas).

               12/07/2013 - Adicionado NO-UNDO nas temp-tables: tt-dados-coope,
                            tt-dados-assoc e tt-fiador. (Fabricio)

               08/10/2013 - Novas temp-tables para restruturaçao de contratos:
                            tt-fiadores, tt-intervenientes, tt-bens-contratos
                            (Lucas)

               31/01/2013 - Incluir uflicenc na tt-bens-alienacao
                            (Guilherme/SUPERO)

               07/01/2014 - Retirado inicializacao de variavel qtpromis 0.(Jorge)

               09/01/2014 - Incluir qtlemcal na tt-dados-epr (James).

               24/02/2014 - Criado tt-dados-epr-out, copia da tt-dados-epr. (Jorge)

               05/03/2014 - Incluido "qtlemcal","vlprvenc" e "vlpraven" na 
                            tt-dados-epr (James).
                          - Incluido idseqbem na tt-bens-alienacao 
                            (Guilherme/SUPERO)

               22/08/2014 - Projeto Automatizaçao de Consultas em Propostas
                            de Crédito (Jonata-RKAM).

               10/09/2014 - Incluido flgpreap na tt-dados-epr (James)

               25/09/2014 - Incluir campo na tt-proposta-epr inpessoa
                            (Lucas R.)

               03/11/2014 - Incluido as campos vlttmupr, vlttjmpr, vlpgmupr, 
                            vlpgjmpr na tt-dados-epr (Daniel).

               07/11/2014 - Incluido o campo cdorigem na tt-proposta-epr. 
                            (Jaison)

               24/11/2014 - Incluido o campo cdorigem na tt-dados-epr. 
                            (James)

               09/01/2015 - Projeto microcredito (Jonata-RKAM).

               20/01/2015 - Adicionado campo dstipbem em tt-bens-alienacao.
                            (Jorge/Gielow) - SD 241854

               18/01/2015 - Projeto Complemento de Análise de Propostas
                            Empréstimos e Financiamentos
                            (Tiago Castro - RKAM)

               19/05/2015 - Incluido nova temp-table para o projeto de cessao
                           de credito (James)  

               25/06/2015 - Projeto 215 - DV 3, incluso novo campo liquidia na 
                            tt-dados-epr (Daniel)    

               25/06/2015 - Criacao do FIELD portabil AS CHAR nas TEMP-TABLES
                            (tt-dados-epr,tt-proposta-epr) Projeto Portabilidade
                            de Credito (Carlos Rafael Tanholi). 

               07/07/2015 - Criacao do FIELD err_efet na tt-proposta-epr.
                            (Jaison/Diego - SD: 290027)

               05/10/2015 - Revisao de contratos (Gabriel-RKAM)  

               17/11/2015 - Incluso novo campo dtapgoib na tt-dados-epr e
                            cdorigem na tt-extrato_epr (Daniel) 

               22/03/2016 - Incluso novo campo dssitest na tt-proposta-epr 
                            (Projeto Esteira de Credito - Daniel/Oscar) 	

               23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-dados-epr-out (Oscar).
                            Correçao nas TEMP-TABLES colocar NO-UNDO, tt-intervenientes (Oscar).             

               07/07/2015 - Criacao do FIELD insitest na tt-proposta-epr.
                            (Jaison/Marcos Martini - PRJ337)

               20/09/2017 - Projeto 410 - Incluidos campos de indicacao de IOF, 
                            tarifa e valor total para demonstração do empréstimo (Diogo - Mouts)

               05/04/2017 - Adicionado parametros de carencia do produto Pos-Fixado. (Jaison/James - PRJ298)

               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom)

               15/12/2017 - Inserção do campo idcobope nas TEMP-TABLE tt-dados-epr
                            e tt-proposta-epr. PRJ404 (Lombardi)

               05/02/2018 - Inclusao do campo vlrdtaxa na tt tt-extrato_epr. (James)

               25/01/2018 - Inclusao do FIELD NIVRIORI na tt-proposta-epr.
                            (Reginaldo AMcom)

               21/02/2018 - Inclusao do FIELD IDENEMPR na tt-dados-epr.
                            (Simas AMcom)

               14/12/2017 - Inclusao de campos na tt tt-proposta-epr, campos
                            flintcdc e inintegra_cont,Prj. 402 (Jean Michel)

               04/07/2018 - P410 - Inclusao dos campos vltiofpr e vlpiofpr (Marcos-Envolti)

               17/09/2018 - P442 - Inclusao de campos dos bens da Proposta (Marcos-Envolti)

               22/10/2018 - P438 - Inclusao de campos alienaçao hipoteca (Paulo-Martins)

               13/05/2019 - P450 - Rating - Retorno Rating na tt-proposta-epr. 
                            Luiz Otavio Olinger Momm - AMcom.
.............................................................................*/
DEF TEMP-TABLE tt-extrato_epr NO-UNDO               
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dtmvtolt LIKE craplem.dtmvtolt
    FIELD cdagenci LIKE craplem.cdagenci
    FIELD cdbccxlt LIKE craplem.cdbccxlt
    FIELD nrdolote LIKE craplem.nrdolote
    FIELD dshistor AS   CHAR
    FIELD dshistoi AS   CHAR
    FIELD nrdocmto LIKE craplem.nrdocmto
    FIELD indebcre AS   CHAR FORMAT "x(01)"
    FIELD vllanmto LIKE craplem.vllanmto 
    FIELD txjurepr LIKE craplem.txjurepr 
    FIELD qtpresta AS   DECI FORMAT "zz9.9999"
    FIELD tpemprst LIKE crapepr.tpemprst
    FIELD nrparepr AS   CHAR
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD nrseqdig LIKE craplem.nrseqdig
    FIELD flgsaldo AS LOGICAL INITIAL TRUE
    FIELD dsextrat AS CHAR
    FIELD flglista AS LOGICAL INITIAL TRUE
    FIELD cdorigem AS INTE
    FIELD qtdiacal LIKE craplem.qtdiacal
	FIELD vlrdtaxa LIKE craplem.vltaxprd.

DEF TEMP-TABLE tt-dados-epr   NO-UNDO  
    FIELD nrdconta AS INTE    FORMAT "zzzz,zzz,9"
    FIELD cdagenci AS INTE    FORMAT "zz9"
    FIELD nmprimtl AS CHAR    FORMAT "x(40)"
    FIELD nrctremp AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"
    FIELD vlemprst AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlpreemp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD txjuremp AS DECIMAL DECIMALS 7 FORMAT "zz,zz9.9999999"
    FIELD vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD vlprejuz AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD vlsdprej AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD dtprejuz AS DATE    FORMAT "99/99/9999"
    FIELD vljrmprj AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD vljraprj AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD inprejuz LIKE crapepr.inprejuz
    FIELD vlprovis AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD flgpagto AS LOGICAL FORMAT "Folha/Conta"
    FIELD dtdpagto AS DATE    FORMAT "99/99/9999"
    FIELD cdpesqui AS CHAR    FORMAT "x(25)"
    FIELD dspreapg AS CHAR    FORMAT "x(25)"
    FIELD cdlcremp LIKE crapepr.cdlcremp
    FIELD dslcremp AS CHAR    FORMAT "x(20)"
    FIELD cdfinemp LIKE crapepr.cdfinemp
    FIELD dsfinemp AS CHAR    FORMAT "x(20)"
    FIELD dsdaval1 AS CHAR    FORMAT "x(29)"
    FIELD dsdaval2 AS CHAR    FORMAT "x(29)"
    FIELD vlpreapg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD qtmesdec AS INTEGER FORMAT "99"
    FIELD qtprecal AS DECIMAL FORMAT "zzz,zz9.9999-"
    FIELD vlacresc AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlrpagos AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD slprjori AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD dtmvtolt AS DATE    FORMAT "99/99/9999"
    FIELD qtpreemp AS INTEGER FORMAT "zz9"
    FIELD dtultpag AS DATE    FORMAT "99/99/9999"
    FIELD vlrabono LIKE craplem.vllanmto
    FIELD qtaditiv AS INTE    FORMAT "zz9"
    FIELD dsdpagto AS CHAR    FORMAT "x(36)"
    FIELD dsdavali AS CHAR
    FIELD qtmesatr AS DECI
    FIELD qtpromis AS INTE
    FIELD flgimppr AS LOGI
    FIELD flgimpnp AS LOGI
    FIELD idseleca AS CHAR
    FIELD nrdrecid AS RECID
    FIELD tplcremp LIKE craplcr.tpctrato
    FIELD tpemprst LIKE crapepr.tpemprst
    FIELD cdtpempr AS CHAR
    FIELD dstpempr AS CHAR
    FIELD permulta AS DECI FORMAT "zz9.99"
    FIELD perjurmo LIKE craplcr.perjurmo
    FIELD dtpripgt LIKE crawepr.dtdpagto
    FIELD inliquid LIKE crapepr.inliquid
    FIELD txmensal LIKE crapepr.txmensal
    FIELD flgatras AS LOGI
    FIELD dsidenti AS CHAR FORMAT "x(1)"
    FIELD flgdigit AS LOGI
    FIELD tpdocged AS INTE
    FIELD qtlemcal AS DECI FORMAT "zzz,zz9.9999-"
    FIELD vlmrapar AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlmtapar AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vltotpag AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD vlprvenc AS DECI FORMAT "zzz,zzz,zzz,zz9.99-" /*Para uso tela LAUTOM*/
    FIELD vlpraven AS DECI FORMAT "zzz,zzz,zzz,zz9.99-" /*Para uso tela LAUTOM*/
    FIELD flgpreap AS LOGI INIT FALSE
    FIELD vlttmupr LIKE crapepr.vlttmupr 
    FIELD vlttjmpr LIKE crapepr.vlttjmpr
    FIELD vlpgmupr LIKE crapepr.vlpgmupr
    FIELD vlpgjmpr LIKE crapepr.vlpgjmpr
    FIELD vlsdpjtl AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
    FIELD cdorigem LIKE crapepr.cdorigem
    FIELD nrseqrrq AS INTE
    FIELD portabil AS CHAR	
    FIELD liquidia AS INTE
    FIELD tipoempr AS CHAR
    FIELD qtimpctr LIKE crapepr.qtimpctr
    FIELD dtapgoib AS DATE    FORMAT "99/99/9999"
	FIELD vliofcpl LIKE crapepr.vliofcpl
    FIELD idcobope AS INTE
    FIELD idenempr LIKE crapepr.tpemprst
    FIELD vltiofpr LIKE crapepr.vltiofpr
    FIELD vlpiofpr LIKE crapepr.vlpiofpr.
    
DEF TEMP-TABLE tt-dados-epr-out NO-UNDO LIKE tt-dados-epr.

DEF TEMP-TABLE tt-dados-coope NO-UNDO
    FIELD vlmaxleg LIKE crapcop.vlmaxleg
    FIELD vlmaxutl LIKE crapcop.vlmaxutl
    FIELD vlcnsscr LIKE crapcop.vlcnsscr
    FIELD vllimapv LIKE crapcop.vllimapv
    FIELD flgcmtlc LIKE crapcop.flgcmtlc
    FIELD vlminimo AS DECI
    FIELD vlemprst AS DECI
    FIELD inusatab AS INTE
    FIELD nrctremp AS INTE
    FIELD nralihip AS INTE
    FIELD lssemseg AS CHAR
    FIELD flginter AS LOGI
    FIELD flintcdc LIKE crapcop.flintcdc
    FIELD inintegra_cont AS INT.

DEF TEMP-TABLE tt-dados-assoc NO-UNDO
    FIELD inpessoa AS INTE
    FIELD inmatric AS INTE
    FIELD cdagenci AS INTE
    FIELD cdempres AS INTE
    FIELD flgpagto AS LOGI
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD nrcpfcjg AS DECI
    FIELD nrctacje AS INTE.

DEF TEMP-TABLE tt-proposta-epr NO-UNDO
    FIELD vlemprst LIKE crawepr.vlemprst
    FIELD vlpreemp LIKE crawepr.vlpreemp
    FIELD qtpreemp LIKE crawepr.qtpreemp
    FIELD nivrisco LIKE crawepr.dsnivris
    FIELD nivcalcu LIKE crawepr.dsnivcal
    FIELD cdlcremp LIKE crawepr.cdlcremp
    FIELD cdfinemp LIKE crawepr.cdfinemp
    FIELD qtdialib LIKE crawepr.qtdialib
    FIELD flgimppr LIKE crawepr.flgimppr
    FIELD flgimpnp LIKE crawepr.flgimpnp
    FIELD cdorigem LIKE crawepr.cdorigem
    FIELD flgpagto LIKE crawepr.flgpagto
    FIELD dtdpagto LIKE crawepr.dtdpagto
    FIELD dsctrliq AS CHAR               
    FIELD qtpromis LIKE crawepr.qtpromis              
    FIELD nmchefia LIKE crawepr.nmchefia                       
    FIELD vlsalari LIKE crapprp.vlsalari
    FIELD vlsalcon LIKE crapprp.vlsalcon
    FIELD vldrendi LIKE craprpr.vldrendi /* Para o ayllos caracter */
    FIELD dsobserv LIKE crawepr.dsobserv VIEW-AS EDITOR SIZE 76 BY 4 
                                         BUFFER-LINES 10 PFCOLOR 0    FIELD dsrelbem LIKE crapbem.dsrelbem
    FIELD tplcremp LIKE craplcr.tpctrato
    FIELD dslcremp LIKE craplcr.dslcremp
    FIELD dsfinemp LIKE crapfin.dsfinemp
    FIELD idquapro LIKE crawepr.idquapro
    FIELD dsquapro AS CHAR
    FIELD percetop LIKE crawepr.percetop
    FIELD dtmvtolt LIKE crawepr.dtmvtolt
    FIELD nrctremp AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"
    FIELD nrdrecid AS   RECID
    FIELD cdoperad LIKE crawepr.cdoperad
    FIELD flgenvio AS CHAR
    FIELD dtvencto AS DATE               /* Para o ayllos caracter */
    FIELD dsobscmt LIKE crawepr.dsobscmt VIEW-AS EDITOR SIZE 76 BY 4 
                                         BUFFER-LINES 10 PFCOLOR 0
    FIELD flgcrcta LIKE craplcr.flgcrcta
    FIELD tpemprst LIKE crawepr.tpemprst
    FIELD cdtpempr AS CHAR
    FIELD dstpempr AS CHAR
    FIELD dtlibera AS DATE
    FIELD dsidenti AS CHAR
    FIELD flexclui AS LOGI
    FIELD inpessoa AS INTE
    FIELD nrseqrrq AS INTE
    FIELD flgcescr AS LOGI
    FIELD portabil AS CHAR
    FIELD insitapr LIKE crawepr.insitapr
    FIELD err_efet AS INTE
	FIELD dssitest AS CHAR
    FIELD dssitapr AS CHAR
    FIELD insitest LIKE crawepr.insitest
    FIELD inobriga AS CHAR
	FIELD idfiniof AS INTE
    FIELD vliofepr LIKE crapepr.vliofepr
    FIELD vlrtarif AS DECI
    FIELD vlrtotal AS DECI
	FIELD idcarenc LIKE crawepr.idcarenc
    FIELD dtcarenc LIKE crawepr.dtcarenc
    FIELD idcobope AS INTE
    FIELD vlfinanc AS DECI
	FIELD nivriori LIKE crawepr.dsnivori
    FIELD flintcdc LIKE crapcop.flintcdc
    FIELD inintegra_cont AS INT
    FIELD tpfinali LIKE crapfin.tpfinali
    FIELD vlprecar LIKE crawepr.vlprecar
    FIELD inratnot AS INTE   /* vr_inrisco_rating  */
    FIELD inratori AS INTE   /* vr_origem_rating  */
    FIELD inratret AS INTE   /* vr_desc_sit  */
    FIELD inrisrat AS CHAR   /* P450   */
    FIELD origerat AS CHAR.  /* P450   */ 

DEF TEMP-TABLE tt-bens-alienacao NO-UNDO
    FIELD lsbemfin AS CHAR
    FIELD dscatbem AS CHAR
    FIELD dsbemfin AS CHAR
    FIELD dscorbem AS CHAR
    FIELD dschassi AS CHAR
    FIELD nranobem AS INTE
    FIELD nrmodbem AS INTE
    FIELD nrdplaca AS CHAR
    FIELD nrrenava AS DECI
    FIELD tpchassi AS INTE INIT 2
    FIELD ufdplaca AS CHAR
    FIELD nrcpfbem AS DECI FORMAT "zzzzzzzzzzzzz9"
    FIELD dscpfbem AS CHAR FORMAT "x(18)"
    FIELD vlmerbem AS DECI
    FIELD idalibem AS INTE
    FIELD uflicenc AS CHAR
    FIELD idseqbem AS INTE
    FIELD dstipbem AS CHAR
    FIELD dsmarbem AS CHAR
    FIELD vlfipbem AS DECI
    FIELD dstpcomb AS CHAR
    FIELD dssitgrv AS CHAR
	FIELD nrnotanf AS CHAR  /* PRJ 438 - Sprint 4 */
    FIELD dsmarceq AS CHAR. /* PRJ 438 - Sprint 4 */
    
DEF TEMP-TABLE tt-interv-anuentes NO-UNDO
    FIELD nrctaava LIKE crapavt.nrdconta
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD nrcpfcgc LIKE crapavt.nrcpfcgc
    FIELD tpdocava LIKE crapavt.tpdocava
    FIELD nrdocava LIKE crapavt.nrdocava
    FIELD dsnacion LIKE crapnac.dsnacion
    FIELD nmconjug LIKE crapavt.nmconjug
    FIELD nrcpfcjg LIKE crapavt.nrcpfcjg
    FIELD tpdoccjg LIKE crapavt.tpdoccjg
    FIELD nrdoccjg LIKE crapavt.nrdoccjg
    FIELD dsendres LIKE crapavt.dsendres
    FIELD nrfonres LIKE crapavt.nrfonres
    FIELD dsdemail LIKE crapavt.dsdemail
    FIELD nmcidade LIKE crapavt.nmcidade
    FIELD cdufresd LIKE crapavt.cdufresd
    FIELD nrcepend LIKE crapavt.nrcepend
    FIELD nrdindic AS   INTE
    FIELD nrendere LIKE crapavt.nrendere
    FIELD complend LIKE crapavt.complend
    FIELD nrcxapst LIKE crapavt.nrcxapst
    FIELD dsendlog AS   CHAR
    FIELD dsbarlog AS   CHAR
    FIELD cdnacion LIKE crapnac.cdnacion
    FIELD inpessoa LIKE crapavt.inpessoa
    FIELD dtnascto LIKE crapavt.dtnascto. /*PRJ438*/
       
DEF TEMP-TABLE tt-hipoteca NO-UNDO
    FIELD lsbemfin AS CHAR
    FIELD dscatbem AS CHAR /* Para o ayllos caracter */
    FIELD dsbemfin AS CHAR VIEW-AS EDITOR SIZE 50 BY 2 BUFFER-LINES 2 PFCOLOR 1 
    FIELD dscorbem AS CHAR VIEW-AS EDITOR SIZE 50 BY 2 BUFFER-LINES 2 PFCOLOR 1 
    FIELD idseqhip AS INTE
    FIELD vlmerbem AS DECI
    FIELD vlrdobem AS DECI 
    FIELD cdufende LIKE crapbpr.cdufende 
    FIELD dscompend LIKE crapbpr.dscompend 
    FIELD dsendere LIKE crapbpr.dsendere
    FIELD nmbairro LIKE crapbpr.nmbairro 
    FIELD nmcidade LIKE crapbpr.nmcidade 
    FIELD nrcepend LIKE crapbpr.nrcepend 
    FIELD nrendere LIKE crapbpr.nrendere 
    FIELD dsclassi LIKE crapbpr.dsclassi 
    FIELD vlareuti LIKE crapbpr.vlareuti 
    FIELD vlaretot LIKE crapbpr.vlaretot 
    FIELD nrmatric LIKE crapbpr.nrmatric
    FIELD idseqbem LIKE crapbpr.idseqbem. /*PRJ438 - BUG 13721 - Paulo Martins*/

DEF TEMP-TABLE tt-impprop-epr NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nmrescop AS CHAR EXTENT 2
    FIELD nrdocnpj AS CHAR 
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl AS CHAR    FORMAT "x(40)"
    FIELD nrmatric LIKE crapass.nrmatric
    FIELD dtadmemp LIKE crapass.dtadmemp
    FIELD dtadmiss LIKE crapass.dtadmiss
    FIELD vllimcre LIKE crapass.vllimcre
    FIELD nmempres LIKE crapemp.nmextemp
    FIELD nrcpfcgc AS CHAR
    FIELD dstipcta AS CHAR
    FIELD dssitdct AS CHAR
    FIELD nrranfon AS CHAR
    FIELD dsdrisco LIKE crawepr.dsnivris
    FIELD percentu AS DECI
    FIELD risccalc AS CHAR
    FIELD perccalc AS DECI
    FIELD vlsmdtri AS DECI
    FIELD vlcaptal AS DECI
    FIELD vlprepla AS DECI
    FIELD vlaplica AS DECI
    FIELD vldctitu AS DECI
    FIELD vldscchq AS DECI
    FIELD vlutiliz AS DECI
    FIELD vltotdev AS DECI  
    FIELD vltotpre AS DECI
    FIELD vldsaque AS DECI
    FIELD dsobserv LIKE crawepr.dsobserv
    FIELD nmchefia LIKE crawepr.nmchefia
    FIELD vlsalari LIKE crapprp.vlsalari
    FIELD vlsalcon LIKE crapprp.vlsalcon
    FIELD vldrendi LIKE craprpr.vldrendi
    FIELD dsformap AS CHAR
    FIELD dtlibera AS DATE
    FIELD ddmvtolt AS INTE
    FIELD dsmesref AS CHAR
    FIELD aamvtolt AS INTE
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD dsrelbem LIKE crapbem.dsrelbem 
    FIELD nrctremp AS INTE EXTENT 5
    FIELD vlemprst AS DECI EXTENT 5
    FIELD qtpreemp AS INTE EXTENT 5
    FIELD vlpreemp AS DECI EXTENT 5
    FIELD dslcremp AS CHAR EXTENT 5
    FIELD dsfinemp AS CHAR EXTENT 5.
    
DEF TEMP-TABLE tt-dividas NO-UNDO
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD vlsdeved LIKE crapepr.vlsdeved
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD dspreapg AS CHAR
    FIELD dsfinemp AS CHAR
    FIELD dslcremp AS CHAR
    FIELD dsliqant AS CHAR.

DEF TEMP-TABLE tt-promis-epr NO-UNDO
    FIELD nmrescop LIKE crapcop.nmrescop
    FIELD nmextcop LIKE crapcop.nmextcop
    FIELD nrdocnpj AS CHAR
    FIELD nrdconta LIKE crapass.nrdconta  
    FIELD nmprimtl AS CHAR    FORMAT "x(40)"       
    FIELD dscpfcgc AS CHAR
    FIELD dsctremp AS CHAR
    FIELD nmdaval1 LIKE crawepr.nmdaval1
    FIELD nmdaval2 LIKE crawepr.nmdaval2
    FIELD nmcjgav1 LIKE crawepr.nmcjgav1 
    FIELD nmcjgav2 LIKE crawepr.nmcjgav2 
    FIELD dscpfav1 LIKE crawepr.dscpfav1
    FIELD dscpfav2 LIKE crawepr.dscpfav2
    FIELD dscfcav1 LIKE crawepr.dscfcav1
    FIELD dscfcav2 LIKE crawepr.dscfcav2
    FIELD dsemsnot AS CHAR
    FIELD dsdmoeda AS CHAR
    FIELD vlpreemp LIKE crawepr.vlpreemp
    FIELD vencimto AS CHAR
    FIELD dsendres AS CHAR EXTENT 2
    FIELD dsendav1 LIKE crawepr.dsendav1
    FIELD dsendav2 LIKE crawepr.dsendav2
    FIELD dspreemp AS CHAR EXTENT 2
    FIELD dsvencto AS CHAR EXTENT 2.

DEF TEMP-TABLE tt-ctr01-epr NO-UNDO
    FIELD nmextcop LIKE crapcop.nmextcop  
    FIELD nmrescop LIKE crapcop.nmrescop 
    FIELD nmcopdiv AS CHAR EXTENT 2
    FIELD nrdocnpj AS CHAR
    FIELD dsendcop LIKE crapcop.dsendcop 
    FIELD nrendcop LIKE crapcop.nrendcop
    FIELD nmbaicop LIKE crapcop.nmbairro 
    FIELD nrcepcop LIKE crapcop.nrcepend
    FIELD nmcidcop LIKE crapcop.nmcidade 
    FIELD cdufdcop LIKE crapcop.cdufdcop
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl AS CHAR    FORMAT "x(40)"
    FIELD nrcpfcgc AS CHAR
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD txnrdcid AS CHAR
    FIELD nmextemp LIKE crapemp.nmextemp 
    FIELD nmresemp LIKE crapemp.nmresemp     
    FIELD dsendemp LIKE crapemp.dsendemp
    FIELD nrendemp LIKE crapemp.nrendemp
    FIELD nmbaiemp LIKE crapemp.nmbairro
    FIELD nrcepemp LIKE crapemp.nrcepend
    FIELD nmcidemp LIKE crapemp.nmcidade
    FIELD cdufdemp LIKE crapemp.cdufdemp 
    FIELD nrctremp LIKE crawepr.nrctremp
    FIELD vlemprst LIKE crawepr.vlemprst
    FIELD vlpreemp LIKE crawepr.vlpreemp
    FIELD qtpreemp LIKE crawepr.qtpreemp
    FIELD dslcremp LIKE craplcr.dslcremp
    FIELD dsfinemp LIKE crapfin.dsfinemp
    FIELD dtmvtepr LIKE crawepr.dtmvtolt
    FIELD nmdaval1 LIKE crawepr.nmdaval1
    FIELD nmcjgav1 LIKE crawepr.nmcjgav1
    FIELD dscpfav1 LIKE crawepr.dscpfav1
    FIELD dscfcav1 LIKE crawepr.dscfcav1
    FIELD nmdaval2 LIKE crawepr.nmdaval2
    FIELD nmcjgav2 LIKE crawepr.nmcjgav2
    FIELD dscpfav2 LIKE crawepr.dscpfav2
    FIELD dscfcav2 LIKE crawepr.dscfcav2
    FIELD dsdmoeda AS CHAR
    FIELD dsjurvar AS CHAR
    FIELD nmoperad LIKE crapope.nmoperad
    FIELD dtmvtolt LIKE crapdat.dtmvtolt
    FIELD nmcidade AS CHAR
    FIELD dsliquid AS CHAR EXTENT 2
    FIELD dsminima AS CHAR EXTENT 2
    FIELD dsjurfix AS CHAR EXTENT 2
    FIELD dsdpagto AS CHAR EXTENT 2.

DEF TEMP-TABLE tt-dados-gerais NO-UNDO
    FIELD lscatbem AS CHAR
    FIELD lscathip AS CHAR
    FIELD ddmesnov AS INTE
    FIELD dtdpagto AS DATE.
                 
DEF TEMP-TABLE tt-contas NO-UNDO
    FIELD nrdconta LIKE crapass.nrdconta.

DEF TEMP-TABLE tt-fiador NO-UNDO
    FIELD nrdconta AS INTE
    FIELD nrctremp AS INTE
    FIELD dtmvtolt AS DATE
    FIELD vlemprst AS DECI
    FIELD qtpreemp AS INTE
    FIELD vlpreemp AS DECI
    FIELD vlsdeved AS DECI.

DEF TEMP-TABLE tt-ge-epr NO-UNDO LIKE crapgrp
    FIELD vlendivi AS DECI
    FIELD vlendigp AS DECI.

/************************************************************************
          NOVAS TEMP-TABLES - RESTRUTURACAO DE CONTRATOS EMPR.          
*************************************************************************/

DEF TEMP-TABLE tt-fiadores NO-UNDO
    FIELD nrctaava LIKE crapavt.nrdconta
    FIELD nmdavali LIKE crapavt.nmdavali
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrcpfcgc AS CHAR
    FIELD tpdocava LIKE crapavt.tpdocava
    FIELD nrdocava LIKE crapavt.nrdocava
    FIELD nmconjug LIKE crapavt.nmconjug
    FIELD nrcpfcjg AS CHAR
    FIELD tpdoccjg LIKE crapavt.tpdoccjg
    FIELD nrdoccjg LIKE crapavt.nrdoccjg
    FIELD dsendres AS CHAR
    FIELD nmcidade LIKE crapavt.nmcidade
    FIELD nmbairro LIKE crapavt.nmbairro
    FIELD cdufresd LIKE crapavt.cdufresd
    FIELD nrcepend LIKE crapavt.nrcepend
    FIELD nrendere AS CHAR
    FIELD inavalis AS INTE
    FIELD dsestcvl AS CHAR.

DEF TEMP-TABLE tt-intervenientes  NO-UNDO LIKE tt-fiadores.

DEF TEMP-TABLE tt-bens-contratos NO-UNDO
    FIELD cdcooper LIKE crapbpr.cdcooper
    FIELD dscatbem LIKE crapbpr.dscatbem
    FIELD dsbemfin LIKE crapbpr.dsbemfin
    FIELD dsrenava AS CHAR
    FIELD nmpropri AS CHAR
    FIELD dschassi LIKE crapbpr.dschassi
    FIELD nrdplaca LIKE crapbpr.nrdplaca
    FIELD uflicenc LIKE crapbpr.uflicenc
    FIELD dsanobem AS CHAR
    FIELD dsmodbem AS CHAR
    FIELD dscorbem LIKE crapbpr.dscorbem.
    
DEF TEMP-TABLE tt-xml-parecer    NO-UNDO
    FIELD dsparecer    AS CHAR
    FIELD nrdconta     AS CHAR
    FIELD dstippes     AS CHAR
    FIELD dsstatus     AS CHAR  
    FIELD dsmensag_pos AS CHAR 
    FIELD dsmensag_ate AS CHAR.
     
DEF TEMP-TABLE tt-dados-proposta-fin NO-UNDO
    FIELD dsnivris LIKE crawepr.dsnivris
    FIELD dtdpagto LIKE crawepr.dtdpagto
    FIELD nrinfcad LIKE crapttl.nrinfcad
    FIELD dsinfcad AS CHAR
    FIELD nrgarope AS INTE
    FIELD dsgarope AS CHAR
    FIELD nrperger AS INTE
    FIELD dsperger AS CHAR
    FIELD nrliquid AS INTE
    FIELD dsliquid AS CHAR
    FIELD nrpatlvr AS INTE
    FIELD dspatlvr AS CHAR
    FIELD flgcescr AS LOGICAL INIT FALSE.
/*............................................................................*/



