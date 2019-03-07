
/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank27.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007.                       Ultima atualizacao: 12/04/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Efetuar pagamentos pela Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
   
               10/04/2008 - Adaptacao para agendamento de pagamentos (David).
               
               03/11/2008 - Inclusao widget-pool (martin)
 
               06/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               04/06/2010 - Incluido paramentro Origem nas procedures
                            verifica_convenio, verifica_titulo, paga_convenio e
                            paga_titulo (Diego).
                           
               14/10/2010 - Inclusao dos parametros para cooperativa/pac/taa 
                            nas procedures paga_convenio e paga_titulo (Vitor).
                            
               27/04/2011 - Incluidos parametros do TAA na b1wgen0016 (Evandro).
               
               10/05/2011 - Incluso parametros cobranca registrada na
                            verifica_titutlo e paga_titulo (Guilherme).
                            
               05/10/2011 - Parametro cpf operador na verifica_operacao
                            Parametros operador na paga_convenio
                            (Guilherme).
                            
               29/12/2011 - Adiicionar parametros de par_versaldo e par_vlapagar
                            para verificar saldo do dia, para efetuar pagamento
                            do(s) boleto(s) (Jorge).
                            
               09/03/2012 - Adicionado os campos cdbcoctl e cdagectl.(Fabricio)
               
               14/05/2012 - Projeto TED Internet (David).
               
               13/11/2012 - Melhoria Multi Pagamentos (David).
               
               15/01/2013 - Nao validar saldo se for operador PJ (David).
               
               10/04/2013 - Projeto VR Boletos (Rafael).
               
               07/08/2013 - Ajuste de pagto de VR Boletos pelo DDA (Rafael).
               
               19/09/2014 - Adicionado parametros de saida xml_msgofatr e
                            xml_cdempcon. (Debito Facil - Fabricio).
                            
               04/11/2014 - (Chamado 161844)- Liberacao de agendamentos
                            para dia nao util. (Tiago Castro - RKAM)
                            
               19/01/2015 - Permitir informar o cedente nos convenios
                            (Chamado 235532). (Jonata - RKAM)             
               
               15/05/2015 - Adaptaçao fonte hibrido Progress -> Oracle 
                            SD280901 (Odirlei-AMcom)
                            
               24/06/2015 - Alterado parametro par_idtitdda no oracle para varchar
                           para não truncar numerico(Odirlei-AMcom)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)
                            
               13/08/2015 - incluido paramentro pr_tpcptdoc para verificar tipo
                            de captura 1=Leitora, 2=Linha digitavel Melhoria 51 
                            (Odirlei-AMcom)             
                            
               30/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
               
               28/03/2018 - Ajuste para que o caixa eletronico possa utilizar o mesmo
                            servico da conta online (PRJ 363 - Rafael Muniz Monteiro)

               12/04/2018 - Inclusao de novos campo para realizaçao 
                              de analise de fraude. 
                              PRJ381 - AntiFraude (Odirlei-AMcom)
                              
               16/02/2019 - Ajuste variável aux_nrrecid para DECI - Paulo Martins - Mouts
..............................................................................*/

 
CREATE WIDGET-POOL.
 
{ sistema/generico/includes/var_internet.i }  
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmconban AS CHAR                                           NO-UNDO.
DEF VAR aux_dslindig AS CHAR                                           NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                           NO-UNDO.
DEF VAR aux_cdbcoctl AS CHAR                                           NO-UNDO.
DEF VAR aux_cdagectl AS CHAR                                           NO-UNDO.

DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.

DEF VAR aux_cdseqfat AS DECI                                           NO-UNDO.
DEF VAR aux_vlrdocum AS DECI                                           NO-UNDO.
DEF VAR aux_nrcnvcob AS DECI                                           NO-UNDO.
DEF VAR aux_nrboleto AS DECI                                           NO-UNDO.

DEF VAR aux_nrdigfat AS INTE                                           NO-UNDO.
DEF VAR aux_nrctacob AS INTE                                           NO-UNDO.
DEF VAR aux_insittit AS INTE                                           NO-UNDO.
DEF VAR aux_intitcop AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                           NO-UNDO.

DEF VAR aux_dtdifere AS LOGI                                           NO-UNDO.
DEF VAR aux_vldifere AS LOGI                                           NO-UNDO.

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdorigem AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagenci AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrdcaixa AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dsorigem AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nmprogra AS CHAR                                  NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_idtitdda AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_idagenda AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_idtpdpag AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_lindigi1 AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_lindigi2 AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_lindigi3 AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_lindigi4 AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_lindigi5 AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_cdbarras AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_dscedent AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_dtmvtopg AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_dtvencto AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_vllanmto AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_vlpagame AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_cdseqfat AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_nrdigfat AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrcnvcob AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_nrboleto AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_nrctacob AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_insittit AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_intitcop AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrdctabb AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_vlapagar AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_versaldo AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF INPUT  PARAM par_tpcptdoc AS INTE                                  NO-UNDO. 
DEF INPUT  PARAM par_cdctrlcs AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_iptransa AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_iddispos AS CHAR                                  NO-UNDO.
/* Projeto 363 - Novo ATM */
DEF  INPUT PARAM par_cdcoptfn AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdagetfn AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrterfin AS INTE                                  NO-UNDO.
/* Projeto 363 - Novo ATM */

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_msgofatr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_cdempcon AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_cdsegmto AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsprotoc AS CHAR                                  NO-UNDO.
/*Projeto 363 - Novo ATM */
DEF OUTPUT PARAM xml_idlancto AS CHAR                                  NO-UNDO.

DEF VAR aux_cdcoptfn AS INTE                                           NO-UNDO.
DEF VAR aux_cdagetfn AS INTE                                           NO-UNDO.
DEF VAR aux_nrterfin AS INTE                                           NO-UNDO.

/* cobranca registrada */
DEF VAR par_cobregis AS LOGICAL                                        NO-UNDO.
DEF VAR par_msgalert AS CHARACTER                                      NO-UNDO.
DEF VAR par_vlrjuros AS DECIMAL                                        NO-UNDO.
DEF VAR par_vlrmulta AS DECIMAL                                        NO-UNDO.
DEF VAR par_vldescto AS DECIMAL                                        NO-UNDO.
DEF VAR par_vlabatim AS DECIMAL                                        NO-UNDO.
DEF VAR par_vloutdeb AS DECIMAL                                        NO-UNDO.
DEF VAR par_vloutcre AS DECIMAL                                        NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                                           NO-UNDO.
DEF VAR aux_nrrecid  AS DECI                                           NO-UNDO.


DEFINE VARIABLE aux_lindigit AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nmprepos AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nrcpfpre AS DECIMAL     NO-UNDO.

DEFINE VARIABLE aux_msgofatr AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_cdempcon AS INTEGER     NO-UNDO.

ASSIGN aux_dstransa = (IF  par_idagenda = 1  THEN
                           "Pagamento"
                       ELSE
                           "Agendamento para pagamento") +
                      " de " +
                      (IF  par_idtpdpag = 1  THEN
                           "convenio (fatura)"
                       ELSE
                           "titulo") +
                      (IF  par_idtitdda <> 0  THEN
                           " DDA"
                       ELSE
                           "").

  /* Procedimento do internetbank operaçao 27 - efetuar pagamento */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_InternetBank27
      aux_handproc = PROC-HANDLE NO-ERROR
      (INPUT par_cdcooper    /* Codigo da cooperativa  */
      ,INPUT par_nrdconta    /* Numero da conta        */
      ,INPUT par_idseqttl    /* Sequencial titular     */
      /* Projeto 363 - Novo ATM */
      ,INPUT par_cdorigem    /* --> Origem */ 
      ,INPUT par_cdagenci    /* --> Agencia */ 
      ,INPUT par_nrdcaixa    /* --> Caixa */ 
      ,INPUT par_dsorigem    /* --> Descricao Origem */ 
      ,INPUT par_nmprogra    /* --> Programa */ 
      /* Projeto 363 - Novo ATM */ 
      ,INPUT par_dtmvtolt    /* Data de movimento      */
      ,INPUT string(par_idtitdda)    /* Indicador DDA          */
      ,INPUT par_idagenda    /* Ind. agendamento/pagamento     */
      ,INPUT par_idtpdpag    /* Indicador de tipo de pagamento */  
      ,INPUT par_lindigi1    /* Linha digitavel 1      */
      ,INPUT par_lindigi2    /* Linha digitavel 2      */
      ,INPUT par_lindigi3    /* Linha digitavel 3      */   
      ,INPUT par_lindigi4    /* Linha digitavel 4      */
      ,INPUT par_lindigi5    /* Linha digitavel 5      */
      ,INPUT par_cdbarras    /* Codigo de barras       */  
      ,INPUT par_dscedent    /* Descriçao do cedente   */
      ,INPUT par_dtmvtopg    /* Data para pagamento    */
      ,INPUT par_dtvencto    /* Data do vencimento     */
      ,INPUT par_vllanmto    /* Valor Lancamentoico    */
      ,INPUT par_vlpagame    /* valor fatura           */
      ,INPUT string(par_cdseqfat) /* Codigo sequncial da fatura     */
      ,INPUT par_nrdigfat    /* Digito da fatura               */  
      ,INPUT par_nrcnvcob    /* Numero do convenio de cobrança */
      ,INPUT par_nrboleto    /* Numero do boleto               */
      ,INPUT par_nrctacob    /* Numero da conta de cobrança    */
      ,INPUT par_insittit    /* Situaçao do titulo             */
      ,INPUT par_intitcop    /* Titulo da coopeariva           */
      ,INPUT par_nrdctabb    /* Numero da conta BB             */ 
      ,INPUT par_nrcpfope    /* CPF do operador juridico       */
      ,INPUT par_vlapagar    /* Valor a pagar                  */ 
      ,INPUT par_versaldo    /* Indicador de ver saldo         */
      ,INPUT INTE(par_flmobile) /* Indicador que origem é Mobile */
      ,INPUT par_tpcptdoc    /* Indicador de tipo de captura */
      ,INPUT (par_cdctrlcs)  /* --> Numero de controle da consulta no NPC */
      ,INPUT par_iptransa    /* --> IP da transacao  IBank/mobile */
      ,INPUT par_iddispos    /* --> ID Dispositivo mobile         */
      /* Projeto 363 - Novo ATM */ 
      ,INPUT par_cdcoptfn    /* Cooperativa do Caixa Eletronico */ 
      ,INPUT par_cdagetfn    /* Agencia do Caixa Eletronico */ 
      ,INPUT par_nrterfin    /* Numero do Caixa Eletronico */  
      /* Projeto 363 - Novo ATM */ 
      ,OUTPUT ""             /* pr_xml_dsmsgerr */
      ,OUTPUT ""             /* pr_xml_msgofatr */
      ,OUTPUT ""             /* pr_xml_cdempcon */ 
      ,OUTPUT ""             /* pr_xml_cdsegmto */ 
      ,OUTPUT ""             /* pr_xml_dsprotoc */ 
      ,OUTPUT ""             /* pr_xml_idlancto */ /* Projeto 363 - Novo ATM */
      ,OUTPUT ""       ).    /* pr_dsretorn     */ 

  IF  ERROR-STATUS:ERROR  THEN DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + 
                                ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
          
      ASSIGN aux_dscritic = "pc_InternetBank27 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr> " + aux_dstransa + " não efetuado,"   + 
                              " tente novamente ou entre em contato com seu PA" +
                            "</dsmsgerr>".
                        
      RUN proc_geracao_log.
      RETURN "NOK".
      
  END. 

  CLOSE STORED-PROC pc_InternetBank27
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}
  
  ASSIGN aux_dsretorn = ""
         xml_dsmsgerr = ""
         xml_msgofatr = ""
         xml_cdempcon = ""
         xml_cdsegmto = ""         
         xml_idlancto = ""
         aux_dsretorn = pc_InternetBank27.pr_dsretorn 
                        WHEN pc_InternetBank27.pr_dsretorn <> ?
         xml_dsmsgerr = pc_InternetBank27.pr_xml_dsmsgerr 
                        WHEN pc_InternetBank27.pr_xml_dsmsgerr <> ?
         xml_msgofatr = pc_InternetBank27.pr_xml_msgofatr 
                        WHEN pc_InternetBank27.pr_xml_msgofatr <> ?
         xml_cdempcon = pc_InternetBank27.pr_xml_cdempcon 
                        WHEN pc_InternetBank27.pr_xml_cdempcon <> ?
         xml_cdsegmto = pc_InternetBank27.pr_xml_cdsegmto 
                        WHEN pc_InternetBank27.pr_xml_cdsegmto <> ?
         xml_dsprotoc = pc_InternetBank27.pr_xml_dsprotoc 
                        WHEN pc_InternetBank27.pr_xml_dsprotoc <> ?
         xml_idlancto = pc_InternetBank27.pr_xml_idlancto
                        WHEN pc_InternetBank27.pr_xml_idlancto <> ?.

  /* Verificar se retornou critica */
  IF aux_dsretorn = "NOK" THEN
     RETURN "NOK".
            
/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    IF  par_nrcpfope > 0  THEN
        ASSIGN aux_dstransa = aux_dstransa + " - operador".


    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT "996"           /* pr_cdoperad */
        ,INPUT aux_dscritic    /* pr_dscritic */
        ,INPUT par_dsorigem    /* pr_dsorigem */ /* Projeto 363 - Novo ATM -> extava fixo "INTERNET" */
        ,INPUT aux_dstransa    /* pr_dstransa */
        ,INPUT aux_datdodia    /* pr_dttransa */
        ,INPUT 0 /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT par_nmprogra    /* pr_nmdatela */ /* Projeto 363 - Novo ATM -> estava fixo "INTERNETBANK" */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */


    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
            
        ASSIGN aux_dscritic = "InternetBank27.pc_gera_log_prog ' --> '"  +
                              "Erro ao executar Stored Procedure: '" +
                              aux_msgerora.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + aux_dscritic +  "' >> log/proc_batch.log").
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
        
    END. 
    
    CLOSE STORED-PROC pc_gera_log_prog
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl}}
    
    
     ASSIGN aux_nrrecid = pc_gera_log_prog.pr_nrrecid
                              WHEN pc_gera_log_prog.pr_nrrecid <> ?.       
    
END PROCEDURE.


/*............................................................................*/ 

