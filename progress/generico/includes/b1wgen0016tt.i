/*..............................................................................

   Programa: b1wgen0016tt.i                  
   Autor   : David
   Data    : Abril/2008                         Ultima atualizacao: 21/09/2017
   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0016.p

   Alteracoes: 04/10/2011 - Adicionado em tt-dados-agendamento os campos:
                            nmprepos, nrcpfpre, nmoperad e nrcpfope (Jorge)
                            
               11/10/2011 - Incluir tt-transacoes_operadores 
                            Incluir tt-criticas_transacoes_oper (Guilherme)
                            
               09/01/2012 - Adicionado campo idtitdda em tt-dados-agendamento
                            (Jorge)
                            
               14/05/2012 - Projeto TED Internet (David).             
               
               12/11/2012 - Melhoria pagamento em lote Internet (David).
               
               05/04/2013 - Inclusão de campos da tt-convenios_aceitos para
                            horário dos convenios SICREDI (Lucas).
                            
               19/04/2013 - Transferencia intercooperativa (Gabriel)  
               
               22/10/2014 - Novos campos na tela PARMON. Chamado 198702.
                            (Jonata-RKAM).                                                     
                            
               18/12/2015 - Inclusao de nova temp-table tt-vlrdat, Prj.
                            Assinatura Conjunta (Jean Michel).

               04/05/2016 - Incluido novo campo na tabela tt-dados-agendamento
							              (Adriano - M117).
              
               24/05/2016 - Incluido o campo flmntage na tabela tt-parmon (Carlos)
               
               21/07/2016 - Incluso da TEMP-TABLE tt-tbpagto_darf_das_trans_pend (Jean Michel).
               
               27/07/2016 - Inclusao de novos campos na TEMP-TABLE tt-dados-agendamento, Prj.338
                            Pagamento DARF-DAS via Internet (Jean Michel).

               19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo 
                            InternetBanking (Projeto 338 - Lucas Lunelli)

               06/03/2017 - Adicionados campos nrddd, nrcelular e nmoperadora em 
                            tt-dados-agendamento (Projeto 321 - Lombardi).

			   06/03/2017 - Adicionados para o GPS (Previdência Social)
							(Prj 354.2 - Ricardo Linhares).

               21/09/2017 - Incluir campos referente a debaut na temp-table
                            tt-convenios_aceitos (David).

..............................................................................*/

DEF TEMP-TABLE tt-convenios_aceitos NO-UNDO
    FIELD nmextcon AS CHAR
    FIELD nmrescon AS CHAR
    FIELD cdempcon AS INTE
    FIELD cdsegmto AS INTE
    FIELD hhoraini AS CHAR
    FIELD hhorafim AS CHAR
    FIELD hhoracan AS CHAR
    FIELD fldebaut AS LOGI
    FIELD cdhisdeb LIKE crapcon.cdhistor
    FIELD dssegmto AS CHAR.
        
DEF TEMP-TABLE tt-dados-agendamento NO-UNDO
    FIELD dtmvtage AS DATE
    FIELD dtmvtopg AS DATE
    FIELD vllanaut AS DECI
    FIELD dttransa AS DATE
    FIELD hrtransa AS INTE
    FIELD nrdocmto AS INTE
    FIELD dssitlau AS CHAR
    FIELD dslindig AS CHAR
    FIELD dscedent AS CHAR
    FIELD dtvencto AS DATE
    FIELD dsageban AS CHAR
    FIELD nrctadst AS CHAR
    FIELD incancel AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nmprepos AS CHAR
    FIELD nrcpfpre AS DECI
    FIELD nmoperad AS CHAR
    FIELD nrcpfope AS DECI
    FIELD idtitdda AS DECI
	  FIELD cdageban AS CHAR  
    FIELD tpcaptur AS INTE    /* Prj. 338 */
    FIELD cdtiptra AS INTE
    FIELD dstiptra AS CHAR
    FIELD dtvendrf AS DATE    /* Prj. 338 */
    FIELD dtagenda AS DATE    /* Prj. 338 */
    FIELD dstipcat AS CHAR    /* Prj. 338 */
    FIELD dsidpgto AS CHAR    /* Prj. 338 */
    FIELD dsnomfon AS CHAR    /* Prj. 338 */
    FIELD dtperiod AS DATE    /* Prj. 338 */
    FIELD nrcpfcgc AS CHAR    /* Prj. 338 */
    FIELD cdreceit AS INT     /* Prj. 338 */
    FIELD nrrefere AS DECIMAL /* Prj. 338 */
    FIELD vlprinci AS DECIMAL /* Prj. 338 */
    FIELD vlrmulta AS DECIMAL /* Prj. 338 */
    FIELD vlrjuros AS DECIMAL /* Prj. 338 */
    FIELD vlrtotal AS DECIMAL /* Prj. 338 */
    FIELD vlrrecbr AS DECIMAL /* Prj. 338 */
    FIELD vlrperce AS DECIMAL /* Prj. 338 */
    FIELD nrddd    AS INT     /* Prj. 321 */
    FIELD nrcelular AS CHAR   /* Prj. 321 */
    FIELD nmoperadora AS CHAR /* Prj. 321 */
    FIELD gpscddpagto AS DECI
    FIELD gpsdscompet AS CHAR
    FIELD gpscdidenti AS DECI
    FIELD gpsvlrdinss AS DECI
    FIELD gpsvlrouent AS DECI
    FIELD gpsvlrjuros AS DECI.
    

DEF TEMP-TABLE tt-transacoes_operadores NO-UNDO
    FIELD dtmvtolt AS DATE
    FIELD dtmvtopg AS DATE
    FIELD vllantra AS DECI
    FIELD dscedent AS CHAR
    FIELD nrcpfope AS DECI
    FIELD nmoperad AS CHAR
    FIELD insittra AS INTE
    FIELD idagenda AS INTE
    FIELD dtaltsit AS DATE
    FIELD idtpdpag AS INTE
    FIELD cdtiptra AS INTE
    FIELD cddbanco AS INTE
    FIELD dsdbanco AS CHAR
    FIELD cdageban AS INTE
    FIELD dsageban AS CHAR
    FIELD nrctadst AS CHAR
    FIELD nmtitdst AS CHAR
    FIELD nrcpfdst AS CHAR
    FIELD dttransa AS DATE
    FIELD hrtransa AS INTE
    FIELD dslindig AS CHAR
    FIELD dscodbar AS CHAR
    FIELD dscritic AS CHAR
    FIELD dtcritic AS DATE
    FIELD nrcpfpre AS DECI
    FIELD nmprepos AS CHAR
    FIELD vlrdocto AS DECI
    FIELD dtvencto AS DATE
    FIELD cdfinali AS INTE
    FIELD dsfinali AS CHAR
    FIELD dstransf AS CHAR
    FIELD nrdrowid AS ROWID
    FIELD dsoperac AS CHAR
    INDEX tt-transacoes_operadores1 dttransa DESC hrtransa DESC.

DEF TEMP-TABLE tt-criticas_transacoes_oper NO-UNDO
    FIELD dtcritic AS CHAR
    FIELD vllantra AS DECI
    FIELD dscedent AS CHAR
    FIELD dstiptra AS CHAR
    FIELD dscritic AS CHAR
    FIELD flgtrans AS LOGICAL
    FIELD nrdrowid AS CHAR
    FIELD cdtransa AS INTE
    FIELD dsprotoc AS CHAR.

DEF TEMP-TABLE tt-parmon
    FIELD vlinimon LIKE crapcop.vlinimon
    FIELD vllmonip LIKE crapcop.vllmonip
    FIELD vlinisaq LIKE crapcop.vlinisaq
    FIELD vlinitrf LIKE crapcop.vlinitrf
    FIELD vlsaqind LIKE crapcop.vlsaqind
    FIELD insaqlim LIKE crapcop.insaqlim
    FIELD inaleblq LIKE crapcop.inaleblq
    FIELD vlmnlmtd LIKE crapcop.vlmnlmtd
    FIELD vlinited LIKE crapcop.vlinited
    FIELD flmstted LIKE crapcop.flmstted
    FIELD flnvfted LIKE crapcop.flnvfted
    FIELD flmobted LIKE crapcop.flmobted
    FIELD dsestted LIKE crapcop.dsestted
    FIELD flmntage LIKE crapcop.flmntage.

DEF TEMP-TABLE tt-vlrdat NO-UNDO
    FIELD dattrans AS DATE
    FIELD vlronlin AS DEC.

DEF TEMP-TABLE tt-tbpagto_darf_das_trans_pend NO-UNDO
  FIELD cdtransacao_pendente AS DECIMAL
  FIELD cdcooper             AS DECIMAL
  FIELD nrdconta             AS DECIMAL
  FIELD tppagamento          AS DECIMAL
  FIELD tpcaptura            AS DECIMAL
  FIELD dsidentif_pagto      AS CHAR
  FIELD dsnome_fone          AS CHAR
  FIELD dscod_barras         AS CHAR
  FIELD dslinha_digitavel    AS CHAR
  FIELD dtapuracao           AS DATE
  FIELD nrcpfcgc             AS CHAR
  FIELD cdtributo            AS CHAR
  FIELD nrrefere             AS DECIMAL
  FIELD vlprincipal          AS DECIMAL
  FIELD vlmulta              AS DECIMAL
  FIELD vljuros              AS DECIMAL
  FIELD vlreceita_bruta      AS DECIMAL
  FIELD vlpercentual         AS DECIMAL
  FIELD dtvencto             AS DATE
  FIELD tpleitura_docto      AS DECIMAL
  FIELD vlpagamento          AS DECIMAL
  FIELD dtdebito             AS DATE
  FIELD idagendamento        AS DECIMAL
  FIELD idrowid              AS CHAR.  

/*............................................................................*/
