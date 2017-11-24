/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank26.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Junho/2007                        Ultima atualizacao: 24/06/2015

   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Verifica dados para efetuar pagamentos pela Internet.
   
   Alteracoes: 09/10/2007 - Gerar log com data TODAY e nao dtmvtolt (David).
   
               10/03/2008 - Utilizar include var_ibank.i (David).
               
               09/04/2008 - Adaptacao para agendamento de pagamentos (David).
   
               03/11/2008 - Inclusao widget-pool (martin)

               25/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               04/06/2010 - Incluido parametro Origem nas procedures
                            verifica_titulo e verifica_convenio (Diego).
                            
               10/05/2011 - Incluso parametros cobranca registrada na
                            verifica_titutlo (Guilherme).
                            
               05/10/2011 - Parametro cpf operador na verifica_operacao
                          - Validacao pagamento por operador
                            (Guilherme).
                            
               14/05/2012 - Projeto TED Internet (David).
               
               13/11/2012 - Melhoria Multi Pagamentos (David).
               
               10/04/2013 - Projeto VR Boletos (Rafael).
               
               06/11/2014 - (Chamado 161844) Permitir agendamento de pagamentos
                            para dia nao util (Tiago Castro - RKAM).
                            
               15/05/2015 - Adaptaçao fonte hibrido Progress -> Oracle 
                            SD280901 (Odirlei-AMcom)             
                            
               24/06/2015 - Alterado parametro par_idtitdda no oracle para varchar
                           para não truncar numerico(Odirlei-AMcom)
                            
               28/07/2015 - Adição de parâmetro flmobile para indicar que a origem
                            da chamada é do mobile (Dionathan)

			   07/02/2017 - Incluir código de controle de consulta CIP como 
			                parametro. (Odirlei)

			   01/11/2017 -  Ajustes diversos para projeto de DDA Mobile
							 PRJ356.4 - DDA (Ricardo Linhares)
..............................................................................*/

CREATE WIDGET-POOL.
 
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0016 AS HANDLE                                         NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dstrans1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmconban AS CHAR                                           NO-UNDO.

DEF VAR aux_vlrdocum AS DECI                                           NO-UNDO.
DEF VAR aux_cdseqfat AS DECI                                           NO-UNDO.
DEF VAR aux_nrcnvcob AS DECI                                           NO-UNDO.
DEF VAR aux_nrboleto AS DECI                                           NO-UNDO.

DEF VAR aux_nrdigfat AS INTE                                           NO-UNDO.
DEF VAR aux_nrctacob AS INTE                                           NO-UNDO.
DEF VAR aux_insittit AS INTE                                           NO-UNDO.
DEF VAR aux_intitcop AS INTE                                           NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                           NO-UNDO.

DEF VAR aux_dtdifere AS LOGI                                           NO-UNDO.
DEF VAR aux_vldifere AS LOGI                                           NO-UNDO.
    
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                    NO-UNDO.
DEF  INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                    NO-UNDO.
DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF  INPUT PARAM par_idtitdda AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_idtpdpag AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_lindigi1 AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_lindigi2 AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_lindigi3 AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_lindigi4 AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_lindigi5 AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdbarras AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_vllanmto AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_idagenda AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_dtmvtopg AS DATE                                  NO-UNDO.
DEF  INPUT PARAM par_dscedent AS CHAR                                  NO-UNDO.
DEF  INPUT PARAM par_nrcpfope LIKE crapopi.nrcpfope                    NO-UNDO.
DEF INPUT  PARAM par_flmobile AS LOGI                                  NO-UNDO.
DEF  INPUT PARAM par_cdctrlcs AS CHAR                                  NO-UNDO. 
DEF  INPUT PARAM par_vlapagar AS DECI                                  NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao26.

/* cobranca registrada */
DEF VAR par_cobregis AS LOGICAL                  NO-UNDO.
DEF VAR par_msgalert AS CHARACTER                NO-UNDO.
DEF VAR par_vlrjuros AS DECIMAL                  NO-UNDO.
DEF VAR par_vlrmulta AS DECIMAL                  NO-UNDO.
DEF VAR par_vldescto AS DECIMAL                  NO-UNDO.
DEF VAR par_vlabatim AS DECIMAL                  NO-UNDO.
DEF VAR par_vloutdeb AS DECIMAL                  NO-UNDO.
DEF VAR par_vloutcre AS DECIMAL                  NO-UNDO.
DEF VAR aux_dsretorn AS CHAR                     NO-UNDO.  
DEF VAR aux_nrrecid  AS INTE                     NO-UNDO.
   
/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE               NO-UNDO.   
DEF VAR xRoot         AS HANDLE               NO-UNDO.  
DEF VAR xRoot2        AS HANDLE               NO-UNDO.  
DEF VAR xField        AS HANDLE               NO-UNDO. 
DEF VAR xText         AS HANDLE               NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER              NO-UNDO. 
DEF VAR aux_cont      AS INTEGER              NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR               NO-UNDO.
DEF VAR aux_xml_operacao26 AS LONGCHAR           NO-UNDO.

ASSIGN aux_dstransa = "Valida " +
                      (IF  par_idtpdpag = 1  THEN
                           "convenio (fatura)"
                       ELSE
                           "titulo") +
                      " para " +
                      (IF  par_idagenda = 1  THEN
                           ""
                       ELSE
                           "agendamento de ") +
                      "pagamento".

  /* Procedimento do internetbank operaçao 26 - Validar pagamento */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_InternetBank26
      aux_handproc = PROC-HANDLE NO-ERROR
      (INPUT par_cdcooper    /* --> Codigo da cooperativa */
      ,INPUT par_nrdconta    /* --> Numero da conta       */
      ,INPUT par_idseqttl    /* --> Sequencial titular    */
      ,INPUT par_dtmvtolt    /* --> Data de movimento     */
      ,INPUT STRING(par_idtitdda)    /* --> Indicador DDA         */
      ,INPUT par_idtpdpag    /* --> Indicador de tipo de pagamento */
      ,INPUT par_lindigi1    /* --> Linha digitavel 1     */  
      ,INPUT par_lindigi2    /* --> Linha digitavel 2     */
      ,INPUT par_lindigi3    /* --> Linha digitavel 3     */
      ,INPUT par_lindigi4    /* --> Linha digitavel 4     */   
      ,INPUT par_lindigi5    /* --> Linha digitavel 5     */
      ,INPUT par_cdbarras    /* --> Codigo de barras      */
      ,INPUT par_vllanmto    /* --> Valor Lancamento      */  
      ,INPUT par_idagenda    /* --> Indicador agendamento */
      ,INPUT par_dtmvtopg    /* --> Data de pagamento    */
      ,INPUT par_dscedent    /* --> Descriçao do cedente */
      ,INPUT par_nrcpfope    /* --> CPF do operador juridico      */
      ,INPUT INTE(par_flmobile) /* Indicador que origem é Mobile */
      ,INPUT par_cdctrlcs    /* --> Numero de controle da consulta no NPC */
	  ,INPUT par_vlapagar	 /* --> Valor Total a pagar (soma de vários boletos) */
      ,OUTPUT ""             /* --> Retorno XML de critica        */
      ,OUTPUT ""             /* --> Retorno XML da operaçao 26    */
      ,OUTPUT ""       ).    /* --> Retorno de critica (OK ou NOK)*/ 
      

  IF  ERROR-STATUS:ERROR  THEN DO:
      DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
          ASSIGN aux_msgerora = aux_msgerora + 
                                ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
      END.
          
      ASSIGN aux_dscritic = "pc_InternetBank26 --> "  +
                            "Erro ao executar Stored Procedure: " +
                            aux_msgerora.
      
      ASSIGN xml_dsmsgerr = "<dsmsgerr> Pagamento não registrado,"   + 
                              " tente novamente ou entre em contato com seu PA" +
                            "</dsmsgerr>".
                        
      RUN proc_geracao_log.
      RETURN "NOK".
      
  END. 

  CLOSE STORED-PROC pc_InternetBank26
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

  ASSIGN aux_dsretorn       = ""
         xml_dsmsgerr       = ""
         aux_xml_operacao26 = ""
         aux_dsretorn = pc_InternetBank26.pr_dsretorn 
                        WHEN pc_InternetBank26.pr_dsretorn <> ?
         xml_dsmsgerr = pc_InternetBank26.pr_xml_dsmsgerr 
                        WHEN pc_InternetBank26.pr_xml_dsmsgerr <> ?
         aux_xml_operacao26 = pc_InternetBank26.pr_xml_operacao26 
                              WHEN pc_InternetBank26.pr_xml_operacao26 <> ?               .

  /* Verificar se retornou critica */
  IF aux_dsretorn = "NOK" THEN
     RETURN "NOK".

  /**********************************************/
  /**LER XML RETORNADO DO PROCEDIMENTO ORACLE **/ 
  /**********************************************/
  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

  /***************************************/
  /* Efetuar a leitura do XML operacao26 */ 
  /***************************************/
  SET-SIZE(ponteiro_xml) = LENGTH(aux_xml_operacao26) + 1. 
  PUT-STRING(ponteiro_xml,1) = aux_xml_operacao26. 


  IF ponteiro_xml <> ? THEN  
  DO:
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).       
    
    xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 
        
        IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN 
             NEXT. 
        
        /* Limpar variaveis  */ 
        ASSIGN aux_nmconban = ""
               aux_vlrdocum = 0
               aux_cdseqfat = 0
               aux_nrdigfat = 0
               aux_nrcnvcob = 0
               aux_nrboleto = 0 
               aux_nrctacob = 0
               aux_insittit = 0    
               aux_intitcop = 0    
               aux_nrdctabb = 0.    
        
        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 
            
            xRoot2:GET-CHILD(xField,aux_cont) NO-ERROR. 

            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
            
            xField:GET-CHILD(xText,1) NO-ERROR. 
            
            /* Se nao vier conteudo na TAG */ 
            IF ERROR-STATUS:ERROR             OR  
               ERROR-STATUS:NUM-MESSAGES > 0  THEN
               NEXT.
            
            ASSIGN par_lindigi1 = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "lindigi1"
                   par_lindigi2 = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "lindigi2"
                   par_lindigi3 = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "lindigi3"
                   par_lindigi4 = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "lindigi4"
                   par_lindigi5 = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "lindigi5"
                   par_cdbarras = xText:NODE-VALUE        WHEN xField:NAME = "cdbarras"
                   aux_nmconban = xText:NODE-VALUE        WHEN xField:NAME = "nmconban"
                   par_dtmvtopg = DATE(xText:NODE-VALUE)  WHEN xField:NAME = "dtmvtopg"
                   aux_vlrdocum = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "vlrdocum"
                   aux_cdseqfat = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "cdseqfat"
                   aux_nrdigfat = INT(xText:NODE-VALUE)   WHEN xField:NAME = "nrdigfat"
                   aux_nrcnvcob = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "nrcnvcob"
                   aux_nrboleto = DEC(xText:NODE-VALUE)   WHEN xField:NAME = "nrboleto"
                   aux_nrctacob = INT(xText:NODE-VALUE)   WHEN xField:NAME = "nrctacob"
                   aux_insittit = INT(xText:NODE-VALUE)   WHEN xField:NAME = "insittit"
                   aux_intitcop = INT(xText:NODE-VALUE)   WHEN xField:NAME = "intitcop"
                   aux_nrdctabb = INT(xText:NODE-VALUE)   WHEN xField:NAME = "nrdctabb".
        
        END.        
    END.
    
    SET-SIZE(ponteiro_xml) = 0. 
  END.

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText.

  CREATE xml_operacao26.
        ASSIGN xml_operacao26.dscabini = "<DADOS_PAGAMENTO>"
               xml_operacao26.lindigi1 = "<lindigi1>" +
                                         STRING(par_lindigi1) +
                                         "</lindigi1>"
               xml_operacao26.lindigi2 = "<lindigi2>" +
                                         STRING(par_lindigi2) +   
                                         "</lindigi2>"
               xml_operacao26.lindigi3 = "<lindigi3>" +
                                         STRING(par_lindigi3) +
                                         "</lindigi3>"
               xml_operacao26.lindigi4 = "<lindigi4>" +
                                         STRING(par_lindigi4) +
                                         "</lindigi4>" 
               xml_operacao26.lindigi5 = "<lindigi5>" +
                                         STRING(par_lindigi5) +
                                         "</lindigi5>"
               xml_operacao26.cdbarras = "<cdbarras>" +
                                         par_cdbarras + 
                                         "</cdbarras>" 
               xml_operacao26.nmconban = "<nmconban>" +
                                         aux_nmconban +
                                         "</nmconban>"
               xml_operacao26.dtmvtopg = "<dtmvtopg>" + 
                                    STRING(par_dtmvtopg,"99/99/9999") +
                                         "</dtmvtopg>"
               xml_operacao26.vlrdocum = "<vlrdocum>" +
                            TRIM(STRING(aux_vlrdocum,"zzzzzzzz9.99")) +
                                         "</vlrdocum>"
               xml_operacao26.cdseqfat = "<cdseqfat>" +
                                         STRING(aux_cdseqfat) +
                                         "</cdseqfat>"
               xml_operacao26.nrdigfat = "<nrdigfat>" +
                                         STRING(aux_nrdigfat) +
                                         "</nrdigfat>"
               xml_operacao26.nrcnvcob = "<nrcnvcob>" +
                                         STRING(aux_nrcnvcob) + 
                                         "</nrcnvcob>"
               xml_operacao26.nrboleto = "<nrboleto>" + 
                                         STRING(aux_nrboleto) + 
                                         "</nrboleto>"
               xml_operacao26.nrctacob = "<nrctacob>" +
                                         STRING(aux_nrctacob) + 
                                         "</nrctacob>"
               xml_operacao26.insittit = "<insittit>" +
                                         STRING(aux_insittit) +
                                         "</insittit>"   
               xml_operacao26.intitcop = "<intitcop>" +
                                         STRING(aux_intitcop) +
                                         "</intitcop>"           
               xml_operacao26.nrdctabb = "<nrdctabb>" + 
                                         STRING(aux_nrdctabb) + 
                                         "</nrdctabb>"
               xml_operacao26.dttransa = "<dttransa>" + 
                                     STRING(aux_datdodia,"99/99/9999") +
                                         "</dttransa>"
               xml_operacao26.dscabfim = "</DADOS_PAGAMENTO>".

  RETURN "OK".

/*................................ PROCEDURES ................................*/

PROCEDURE proc_geracao_log:
    
    /* Gerar log(CRAPLGM) - Rotina Oracle */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_prog
        aux_handproc = PROC-HANDLE NO-ERROR
        (INPUT par_cdcooper    /* pr_cdcooper */
        ,INPUT "996"           /* pr_cdoperad */
        ,INPUT aux_dscritic    /* pr_dscritic */
        ,INPUT "INTERNET"      /* pr_dsorigem */
        ,INPUT aux_dstransa    /* pr_dstransa */
        ,INPUT aux_datdodia    /* pr_dttransa */
        ,INPUT 0 /* Operacao sem sucesso */ /* pr_flgtrans */
        ,INPUT TIME            /* pr_hrtransa */
        ,INPUT par_idseqttl    /* pr_idseqttl */
        ,INPUT "INTERNETBANK"  /* pr_nmdatela */
        ,INPUT par_nrdconta    /* pr_nrdconta */
        ,OUTPUT 0 ). /* pr_nrrecid  */



    IF  ERROR-STATUS:ERROR  THEN DO:
        DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
            ASSIGN aux_msgerora = aux_msgerora + 
                                  ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
        END.
            
        ASSIGN aux_dscritic = "InternetBank26.pc_gera_log_prog ' --> '"  +
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


