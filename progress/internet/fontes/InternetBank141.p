/*.................................................................................................
   Programa: sistema/internet/fontes/InternetBank141.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Junho/2015                        Ultima atualizacao: 27/01/2016
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)

   Objetivo  :

   Alteracoes: 04/11/2015 - Tratamento para leitura do xml da pc_lista_empregados_ib 
                            e na pc_envia_pagto_apr_ib (Vanessa).
                            
               10/12/2015 - Adicionado chamada da procedure pc_valid_repre_legal_trans para as 
                            operacoes 2 e 4. (Reinert)
                            
               27/01/2016 - Ajustes nas chamadas a rotinas com novo parâmetro contendo o CPF
                            do operador conectado e também troca de tags da quantidade de pagamento
                            no pagamento por arquivo (Marcos-Supero)
................................................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                    NO-UNDO.
DEF INPUT  PARAM par_lisrowid AS CHAR                                  NO-UNDO.
DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                    NO-UNDO.
DEF INPUT  PARAM par_idseqttl AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_nrcpfapr AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_flsolest AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dsarquiv AS CHAR                                  NO-UNDO. 
DEF INPUT  PARAM par_dsdireto AS CHAR                                  NO-UNDO. 
DEF INPUT  PARAM par_tpoperac AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_idopdebi AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_dtcredit AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_dtdebito AS DATE                                  NO-UNDO.
DEF INPUT  PARAM par_flgravar AS INTE                                  NO-UNDO.
DEF INPUT  PARAM par_vltarapr AS DECI                                  NO-UNDO.
DEF INPUT  PARAM par_xmldados AS LONGCHAR                              NO-UNDO.
DEF INPUT  PARAM par_dssessao AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.
DEF VAR xRoot3        AS HANDLE   NO-UNDO.   
DEF VAR xField        AS HANDLE   NO-UNDO.
DEF VAR xField2       AS HANDLE   NO-UNDO.  
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR xText2        AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO.
DEF VAR aux_cont_crit AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.

DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsalerta AS CHAR                                           NO-UNDO.
DEF VAR aux_des_reto AS CHAR                                           NO-UNDO.

DEF VAR aux_qtregerr AS CHAR                                           NO-UNDO.
DEF VAR aux_qtdregok AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregale AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregtot AS CHAR                                           NO-UNDO.
DEF VAR aux_vltotpag AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
 
DEF VAR aux_dtcredit AS CHAR                                           NO-UNDO.
DEF VAR aux_dtdebito AS CHAR                                           NO-UNDO.
DEF VAR aux_idopdebi AS CHAR                                           NO-UNDO.
DEF VAR aux_qtregpag AS CHAR                                           NO-UNDO.
DEF VAR aux_vllctpag AS CHAR                                           NO-UNDO.
DEF VAR aux_flgrvsal AS CHAR                                           NO-UNDO.
DEF VAR aux_vltarapr AS CHAR                                           NO-UNDO.
DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.
             
EMPTY TEMP-TABLE xml_operacao146.

IF  par_tpoperac = 1 THEN DO: /* Cancelamento */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_cancela_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_lisrowid,
                          INPUT par_nrdconta,
                          INPUT par_nrcpfapr,
                          OUTPUT 0,
                          OUTPUT "").
    CLOSE STORED-PROC pc_cancela_pagto_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_cancela_pagto_ib.pr_cdcritic
                          WHEN pc_cancela_pagto_ib.pr_cdcritic <> ?
           aux_dscritic = pc_cancela_pagto_ib.pr_dscritic.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

END.
ELSE IF  par_tpoperac = 2 THEN DO: /* Valida selecao de registros para aprovacao */   

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_valid_repre_legal_trans aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT (IF par_nrcpfapr > 0 THEN 0 ELSE 1),
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_valid_repre_legal_trans aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.    

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_valida_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_dtmvtolt,
                          INPUT par_lisrowid,
                          INPUT 1,
                          INPUT par_nrcpfapr,
                          OUTPUT "",
                          OUTPUT "",
                          OUTPUT "").
    CLOSE STORED-PROC pc_valida_pagto_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_des_reto = ""
           aux_dscritic = ""
           aux_des_reto = pc_valida_pagto_ib.pr_des_reto
                          WHEN pc_valida_pagto_ib.pr_des_reto <> ?
           aux_dscritic = pc_valida_pagto_ib.pr_dscritic
                          WHEN pc_valida_pagto_ib.pr_dscritic <> ?
           xml_req      = pc_valida_pagto_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_des_reto <> "OK" AND aux_dscritic <> "" AND LENGTH(xml_req)>0 THEN DO:
        
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = xml_req.

        RETURN "NOK".
    END.
    ELSE IF  aux_des_reto <> "OK" AND aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    ELSE IF aux_des_reto = "OK" AND aux_dscritic <> "" THEN DO:

        ASSIGN xml_dsmsgerr = "<dsmsg>" + aux_dscritic + "</dsmsg>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 3 THEN DO: /* busca opcoes de debito */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_busca_opcao_deb_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT "").
    CLOSE STORED-PROC pc_busca_opcao_deb_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_opcao_deb_ib.pr_cdcritic
                          WHEN pc_busca_opcao_deb_ib.pr_cdcritic <> ?
           aux_dscritic = pc_busca_opcao_deb_ib.pr_dscritic
                          WHEN pc_busca_opcao_deb_ib.pr_dscritic <> ?
           xml_req      = pc_busca_opcao_deb_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                        
    IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 4 THEN DO: /* Aprovar registros selecionados */
/*
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_valid_repre_legal_trans aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_idseqttl,
                          INPUT (IF par_nrcpfapr > 0 THEN 0 ELSE 1),
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_valid_repre_legal_trans aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
           aux_dscritic = pc_valid_repre_legal_trans.pr_dscritic
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?.    

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_verifica_rep_assinatura aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,   /*Codigo Cooperativa                       */
                          INPUT par_nrdconta,   /*Conta do Associado                       */
                          INPUT par_idseqttl,   /*Titularidade do Associado                */
                          INPUT 3,              /*Codigo Origem                            */
                          OUTPUT 0,             /*Codigo 1 exige Ass. Conj.                */
                          OUTPUT 0,             /*CPF do Rep. Legal                        */
                          OUTPUT "",            /*Nome do Rep. Legal                       */
                          OUTPUT 0,             /*Cartao Magnetico conjunta, 0 nao, 1 sim  */
                          OUTPUT 0,             /*Codigo do erro                           */
                          OUTPUT "").           /*Descricao do erro                        */

    CLOSE STORED-PROC pc_verifica_rep_assinatura aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_idastcjt = 0
           aux_nrcpfcgc = 0
           aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic
                          WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_rep_assinatura.pr_dscritic
                          WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?
           aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt
                          WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
           aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc
                          WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
           aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                          WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.   */
    
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_verifica_idastcjt_pfp aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,   /*Codigo Cooperativa                       */
                          INPUT par_nrdconta,   /*Conta do Associado                       */
                          INPUT par_idseqttl,   /*Titularidade do Associado                */
                          INPUT par_nrcpfapr,   /*pr_nrcpfope                              */
                          INPUT "INTERNET",     /*Codigo Origem                            */
                          INPUT par_lisrowid,   /* Lista de ROWIDS                         */                          
                          INPUT par_flsolest,
                          OUTPUT "",
                          OUTPUT 0,             /*Codigo do erro                           */
                          OUTPUT "").           /*Descricao do erro                        */

    CLOSE STORED-PROC pc_verifica_idastcjt_pfp aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsalerta = ""
           aux_nrcpfcgc = 0
           aux_cdcritic = pc_verifica_idastcjt_pfp.pr_cdcritic
                          WHEN pc_verifica_idastcjt_pfp.pr_cdcritic <> ?
           aux_dscritic = pc_verifica_idastcjt_pfp.pr_dscritic
                          WHEN pc_verifica_idastcjt_pfp.pr_dscritic <> ?
           aux_dsalerta = pc_verifica_idastcjt_pfp.pr_dsalerta
                          WHEN pc_verifica_idastcjt_pfp.pr_dsalerta <> ?.
  
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.   

    /*IF  aux_idastcjt = 1 THEN
        DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_cria_trans_pend_folha aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT 90,             /* Codigo do PA                                                     */
                                  INPUT 900,            /* Numero do Caixa                                                  */
                                  INPUT "996",          /* Codigo do Operados                                               */
                                  INPUT "INTERNETBANK", /* Nome da Tela                                                     */
                                  INPUT 3,              /* Origem da solicitacao                                            */
                                  INPUT par_idseqttl,   /* Sequencial de Titular                                            */
                                  INPUT 0,              /* Numero do cpf do operador juridico                               */
                                  INPUT aux_nrcpfcgc,   /* Numero do cpf do representante legal                             */
                                  INPUT 0,              /* Cooperativa do Terminal                                          */
                                  INPUT 0,              /* Agencia do Terminal                                              */
                                  INPUT 0,              /* Numero do Terminal Financeiro                                    */
                                  INPUT par_dtmvtolt,   /* Data do movimento                                                */
                                  INPUT par_cdcooper,   /* Codigo da cooperativa                                            */
                                  INPUT par_nrdconta,   /* Numero da Conta                                                  */
                                  INPUT par_flsolest,   /* Indicador de solicitacao de estouro de conta (0 – Nao / 1 – Sim) */
                                  INPUT par_lisrowid,   /* Lista de ROWIDS                                                  */
                                  INPUT aux_idastcjt,   /* Indicador de Assinatura Conjunta                                 */
                                  OUTPUT 0,             /* Codigo de Critica                                                */
                                  OUTPUT "").           /* Descricao de Critica                                             */
        
            CLOSE STORED-PROC pc_cria_trans_pend_folha aux_statproc = PROC-STATUS
                  WHERE PROC-HANDLE = aux_handproc.
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_cria_trans_pend_folha.pr_cdcritic
                                  WHEN pc_cria_trans_pend_folha.pr_cdcritic <> ?
                   aux_dscritic = pc_cria_trans_pend_folha.pr_dscritic
                                  WHEN pc_cria_trans_pend_folha.pr_dscritic <> ?.
        
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
            IF  aux_cdcritic > 0    OR
                aux_dscritic <> ""  THEN
                DO:
                    ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                    RETURN "NOK".
                END.
            ELSE
            DO:
                RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
                    SET h-b1wgen0014.
                    
                IF  VALID-HANDLE(h-b1wgen0014)  THEN
                    DO:
                        ASSIGN aux_dstransa = "Cadastrar folha de pagamento".

                        RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                                      INPUT "996",
                                                      INPUT aux_dscritic,
                                                      INPUT "INTERNET",
                                                      INPUT aux_dstransa,
                                                      INPUT aux_datdodia,
                                                      INPUT TRUE,
                                                      INPUT TIME,
                                                      INPUT par_idseqttl,
                                                      INPUT "INTERNETBANK",
                                                      INPUT par_nrdconta,
                                                      OUTPUT aux_nrdrowid).
            
                        RUN gera_log_item IN h-b1wgen0014 
                           (INPUT aux_nrdrowid,
                            INPUT "CPF Representante/Procurador" ,
                            INPUT "",
                            INPUT aux_nrcpfcgc).
                        
                        RUN gera_log_item IN h-b1wgen0014 
                           (INPUT aux_nrdrowid,
                            INPUT "Nome Representante/Procurador" ,
                            INPUT "",
                            INPUT aux_nmprimtl).
                            
                        DELETE PROCEDURE h-b1wgen0014.
                    END.

                ASSIGN aux_dsalerta = "Pagamento registrado com sucesso. " + 
                                      "Aguardando aprovacao da operacao pelos " +
                                      "demais responsaveis.".      
            END.
        END.
    ELSE
        DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_aprovar_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_dtmvtolt,
                                  INPUT par_nrcpfapr,
                                  INPUT par_flsolest,
                                  INPUT par_lisrowid,
                                  OUTPUT "",
                                  OUTPUT "",
                                  OUTPUT "").
            CLOSE STORED-PROC pc_aprovar_pagto_ib aux_statproc = PROC-STATUS
                  WHERE PROC-HANDLE = aux_handproc.
        
            ASSIGN aux_des_reto = ""
                   aux_dsalerta = ""
                   aux_dscritic = ""
                   aux_des_reto = pc_aprovar_pagto_ib.pr_des_reto
                                  WHEN pc_aprovar_pagto_ib.pr_des_reto <> ?
                   aux_dsalerta = pc_aprovar_pagto_ib.pr_dsalerta
                                  WHEN pc_aprovar_pagto_ib.pr_dsalerta <> ?
                   aux_dscritic = pc_aprovar_pagto_ib.pr_dscritic
                                  WHEN pc_aprovar_pagto_ib.pr_dscritic <> ?.
        
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
            IF  aux_des_reto <> "OK" AND aux_dscritic <> "" THEN DO:
                ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
                RETURN "NOK".
            END.
        END.*/

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsmsg>" + aux_dsalerta + "</dsmsg>".

END.
ELSE IF  par_tpoperac = 5 THEN DO: /* Validar arquivo de pagamentos */
  
  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag criticas em diante */ 
  CREATE X-NODEREF  xRoot3.  /* Vai conter a tag critica em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xField2.
  CREATE X-NODEREF  xText.
  CREATE X-NODEREF  xText2.  /* Vai conter o texto que existe dentro da tag xField */ 

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_valida_arq_folha_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT 3,
                          INPUT par_nrdconta,
                          INPUT par_dsarquiv,
                          INPUT par_dsdireto,
                          INPUT par_dssessao,
                          INPUT STRING(par_dtcredit),
                          OUTPUT "",
                          OUTPUT "").
    CLOSE STORED-PROC pc_valida_arq_folha_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_des_reto = ""
           aux_dsalerta = ""
           aux_dscritic = ""
           aux_dscritic = pc_valida_arq_folha_ib.pr_dscritic
                          WHEN pc_valida_arq_folha_ib.pr_dscritic <> ?
           xml_req      = pc_valida_arq_folha_ib.pr_retxml.
                                        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
   
    IF ponteiro_xml <> ? THEN
    DO: 
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
       
        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
          /* xRoot:GET-CHILD(xRoot2,aux_cont_raiz).*/
              
           IF xRoot:SUBTYPE <> "ELEMENT" THEN 
              NEXT.         
               
           xRoot:GET-CHILD(xText,1).
           
           IF xRoot:NAME = "criticas" THEN
            DO: 
              ASSIGN aux_qtregerr = STRING(xRoot:GET-ATTRIBUTE("qtregerr"))
                     aux_qtdregok = STRING(xRoot:GET-ATTRIBUTE("qtdregok"))
                     aux_qtregale = STRING(xRoot:GET-ATTRIBUTE("qtregale")) 
                     aux_qtregtot = STRING(xRoot:GET-ATTRIBUTE("qtregtot")) 
                     aux_vltotpag = STRING(xRoot:GET-ATTRIBUTE("vltotpag")) 
                     aux_nmarquiv = STRING(xRoot:GET-ATTRIBUTE("nmarquiv")). /*MESSAGE "aux_vltotpag: " + aux_vltotpag.*/
            END.
            xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
            
            IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
             NEXT.         
            
            xRoot2:GET-CHILD(xText,1).
            
            IF xRoot2:NUM-CHILDREN > 0 THEN
               CREATE xml_operacao146.
                        
            DO aux_cont_crit = 1 TO xRoot2:NUM-CHILDREN:
               xRoot2:GET-CHILD(xField,aux_cont_crit).                   
            
                
               IF xField:SUBTYPE <> "ELEMENT" THEN 
                  NEXT. 
                
               xField:GET-CHILD(xText,1). 
               ASSIGN xml_operacao146.nrseqvld = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrseqvld"
                      xml_operacao146.dsdconta = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsdconta"
                      xml_operacao146.dscpfcgc = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dscpfcgc"
                      xml_operacao146.dscritic = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dscritic"
                      xml_operacao146.dsorigem = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsorigem"
                      xml_operacao146.vlrpagto = STRING(xText:NODE-VALUE) WHEN xField:NAME = "vlrpagto". 
            END. 
        END.
        SET-SIZE(ponteiro_xml) = 0. 
    END.
  
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<criticas qtregerr = '" + aux_qtregerr + "' qtdregok = '" + aux_qtdregok + "' qtregale = '" + aux_qtregale + "' qtregtot = '" + aux_qtregtot + "' vltotpag = '" + aux_vltotpag + "' nmarquiv = '" + aux_nmarquiv + "' >".
   
    FOR EACH xml_operacao146 WHERE NO-LOCK:   
              
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<critica>
                                     <nrseqvld>" + xml_operacao146.nrseqvld + "</nrseqvld>
                                     <dsdconta>" + xml_operacao146.dsdconta + "</dsdconta>
                                     <dscpfcgc>" + xml_operacao146.dscpfcgc + "</dscpfcgc>
                                     <dscritic>" + xml_operacao146.dscritic + "</dscritic>
                                     <dsorigem>" + xml_operacao146.dsorigem + "</dsorigem>
                                     <vlrpagto>" + xml_operacao146.vlrpagto + "</vlrpagto>
                                     </critica>".                                     
       
    END.
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "</criticas>".

END.
ELSE IF  par_tpoperac = 6 THEN DO: /* Verifica a data de credito informada */

    /* Buscamos data de credito valida quando entramos na tela a primeira vez  */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_valid_dat_cred_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          OUTPUT 0,
                          OUTPUT "",
                          OUTPUT "").
    CLOSE STORED-PROC pc_valid_dat_cred_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_valid_dat_cred_ib.pr_cdcritic
                          WHEN pc_valid_dat_cred_ib.pr_cdcritic <> ?
           aux_dscritic = pc_valid_dat_cred_ib.pr_dscritic
                          WHEN pc_valid_dat_cred_ib.pr_dscritic <> ?
           xml_req      = pc_valid_dat_cred_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 7 THEN DO: /* Lista de empregados p/ tela de pagto convencional */

    /* Buscamos data de credito valida quando entramos na tela a primeira vez  */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_lista_empregados_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    CLOSE STORED-PROC pc_lista_empregados_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_lista_empregados_ib.pr_cdcritic
                          WHEN pc_lista_empregados_ib.pr_cdcritic <> ?
           aux_dscritic = pc_lista_empregados_ib.pr_dscritic
                          WHEN pc_lista_empregados_ib.pr_dscritic <> ?
           xml_req      = pc_lista_empregados_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    /* Efetuar a leitura do XML*/ 
   SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
   PUT-STRING(ponteiro_xml,1) = xml_req. 
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
  
  IF ponteiro_xml <> ? THEN
      DO:
         xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
         xDoc:GET-DOCUMENT-ELEMENT(xRoot).
         
          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
         
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
      
            IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
               NEXT. 
            
            IF xRoot2:NUM-CHILDREN > 0 THEN
              CREATE xml_operacao143.
             
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                xRoot2:GET-CHILD(xField,aux_cont).
                     
                 IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                 
                 xField:GET-CHILD(xText,1).                
                /*MESSAGE "xField:NAME: " + STRING(xField:NAME) + " xText:NODE-VALUE: " + STRING(STRING(xText:NODE-VALUE)).*/
                 ASSIGN  xml_operacao143.nrdconta = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                         xml_operacao143.nrcpfemp = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfemp"
                         xml_operacao143.nmprimtl = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nmprimtl"
                         xml_operacao143.dsdcargo = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsdcargo"
                         xml_operacao143.dtadmiss = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dtadmiss"
                         xml_operacao143.dstelefo = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dstelefo"
                         xml_operacao143.dsdemail = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsdemail"
                         xml_operacao143.nrregger = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrregger"
                         xml_operacao143.nrodopis = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrodopis"
                         xml_operacao143.nrdactps = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdactps"
                         xml_operacao143.cdempres = STRING(xText:NODE-VALUE) WHEN xField:NAME = "cdempres"
                         xml_operacao143.idtpcont = STRING(xText:NODE-VALUE) WHEN xField:NAME = "idtpcont"
                         xml_operacao143.vlultsal = STRING(xText:NODE-VALUE) WHEN xField:NAME = "vlultsal".
             END.
          END.
          
          SET-SIZE(ponteiro_xml) = 0. 
      END.
   /*Elimina os objetos criados*/
   DELETE OBJECT xDoc. 
   DELETE OBJECT xRoot. 
   DELETE OBJECT xRoot2. 
   DELETE OBJECT xField. 
   DELETE OBJECT xText.
   
   CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<raiz>".
   
   FOR EACH xml_operacao143 WHERE NO-LOCK:   
      
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<funcionarios><nrdconta>" + xml_operacao143.nrdconta + "</nrdconta>" +
                                     "<nrcpfemp>" + xml_operacao143.nrcpfemp + "</nrcpfemp>" +
                                     "<nmprimtl>" + xml_operacao143.nmprimtl + "</nmprimtl>" +
                                     "<dsdcargo>" + xml_operacao143.dsdcargo + "</dsdcargo>" +
                                     "<dtadmiss>" + xml_operacao143.dtadmiss + "</dtadmiss>" +
                                     "<dstelefo>" + xml_operacao143.dstelefo + "</dstelefo>" +
                                     "<dsdemail>" + xml_operacao143.dsdemail + "</dsdemail>" +
                                     "<nrregger>" + xml_operacao143.nrregger + "</nrregger>" +
                                     "<nrdactps>" + xml_operacao143.nrdactps + "</nrdactps>" +
                                     "<nrodopis>" + xml_operacao143.nrodopis + "</nrodopis>" +
                                     "<cdempres>" + xml_operacao143.cdempres + "</cdempres>" +
                                     "<idtpcont>" + xml_operacao143.idtpcont + "</idtpcont>" +
                                     "<vlultsal>" + xml_operacao143.vlultsal + "</vlultsal></funcionarios>".                                     
       
    

    END.
    
    CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "</raiz>".

END.
ELSE IF  par_tpoperac = 8 THEN DO: /* Busca origens de pagamentos convencional */

    /* Buscamos data de credito valida quando entramos na tela a primeira vez  */
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_lista_origem_pagto_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").
    CLOSE STORED-PROC pc_lista_origem_pagto_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_lista_origem_pagto_ib.pr_cdcritic
                          WHEN pc_lista_origem_pagto_ib.pr_cdcritic <> ?
           aux_dscritic = pc_lista_origem_pagto_ib.pr_dscritic
                          WHEN pc_lista_origem_pagto_ib.pr_dscritic <> ?
           xml_req      = pc_lista_origem_pagto_ib.pr_data_xml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
   

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 9 THEN DO: /* Gravar arquivo folha */
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gravar_arq_folha_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_nrcpfapr,
                          INPUT par_lisrowid,
                          INPUT par_idopdebi,
                          INPUT par_dtcredit,
                          INPUT par_dtdebito,
                          INPUT par_vltarapr,
                          INPUT par_xmldados,
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_gravar_arq_folha_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_gravar_arq_folha_ib.pr_dscritic
                          WHEN pc_gravar_arq_folha_ib.pr_dscritic <> ?
           xml_req      = pc_gravar_arq_folha_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 10 THEN DO: /* Busca dados de pagamentos para tela de alteraçăo via arquivo */
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_consulta_arq_folha_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_lisrowid,
                          OUTPUT "",
                          OUTPUT "").

    CLOSE STORED-PROC pc_consulta_arq_folha_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dscritic = pc_consulta_arq_folha_ib.pr_dscritic
                          WHEN pc_consulta_arq_folha_ib.pr_dscritic <> ?
           xml_req      = pc_consulta_arq_folha_ib.pr_retxml.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 11 THEN DO: /* Envio de pagamentos para aprovacao */
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_envia_pagto_apr_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          INPUT par_nrcpfapr,
                          INPUT par_lisrowid,
                          INPUT par_idopdebi,
                          INPUT par_dtcredit,
                          INPUT par_dtdebito,
                          INPUT par_vltarapr,
                          INPUT par_flgravar,
                          INPUT par_dsdireto,
                          INPUT par_dsarquiv,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_envia_pagto_apr_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_envia_pagto_apr_ib.pr_cdcritic
                          WHEN pc_envia_pagto_apr_ib.pr_cdcritic <> ?
           aux_dscritic = pc_envia_pagto_apr_ib.pr_dscritic
                          WHEN pc_envia_pagto_apr_ib.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN DO:
       
       IF  aux_cdcritic = 999 THEN DO: /* Mensagem de Alerta */
           ASSIGN xml_dsmsgerr = "<dsmsgalerta>" + aux_dscritic + "</dsmsgalerta>".
           RETURN "NOK".
       END.

       ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
       RETURN "NOK".

    END.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.
ELSE IF  par_tpoperac = 12 THEN DO: /* Busca informacoes de pagamento para alterar */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_lista_pgto_pend_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          INPUT par_lisrowid,
                          OUTPUT "",
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_lista_pgto_pend_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_lista_pgto_pend_ib.pr_cdcritic
                          WHEN pc_lista_pgto_pend_ib.pr_cdcritic <> ?
           aux_dscritic = pc_lista_pgto_pend_ib.pr_dscritic
                          WHEN pc_lista_pgto_pend_ib.pr_dscritic <> ?
           xml_req      = pc_lista_pgto_pend_ib.pr_xmlpagto.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.
    
    /* Efetuar a leitura do XML*/ 
   SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
   PUT-STRING(ponteiro_xml,1) = xml_req. 
   
   /* Inicializando objetos para leitura do XML */ 
   CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
   CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
   CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
   CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
   CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
  
  IF ponteiro_xml <> ? THEN
      DO:
         xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
         xDoc:GET-DOCUMENT-ELEMENT(xRoot).
         
          DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN:
         
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
          
          IF xRoot:NAME = "dados" THEN
                DO: 
                  ASSIGN aux_dtcredit = STRING(xRoot:GET-ATTRIBUTE("dtcredit"))
                         aux_dtdebito = STRING(xRoot:GET-ATTRIBUTE("dtdebito"))
                         aux_idopdebi = STRING(xRoot:GET-ATTRIBUTE("idopdebi")) 
                         aux_qtregpag = STRING(xRoot:GET-ATTRIBUTE("qtregpag")) 
                         aux_vllctpag = STRING(xRoot:GET-ATTRIBUTE("vllctpag")) 
                         aux_flgrvsal = STRING(xRoot:GET-ATTRIBUTE("flgrvsal"))
                         aux_vltarapr = STRING(xRoot:GET-ATTRIBUTE("vltarapr")). 
                         
                END.
                
            IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
               NEXT. 
            
            IF xRoot2:NUM-CHILDREN > 0 THEN
              CREATE xml_operacao141.
             
             DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                xRoot2:GET-CHILD(xField,aux_cont).
                     
                 IF xField:SUBTYPE <> "ELEMENT" THEN 
                    NEXT. 
                 
                 xField:GET-CHILD(xText,1).                
                /*MESSAGE "xField:NAME: " + STRING(xField:NAME) + " xText:NODE-VALUE: " + STRING(STRING(xText:NODE-VALUE)).*/
                 ASSIGN  xml_operacao141.cdcooper = STRING(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper"
                         xml_operacao141.cdempres = STRING(xText:NODE-VALUE) WHEN xField:NAME = "cdempres"
                         xml_operacao141.nrdconta = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta"
                         xml_operacao141.nrcpfemp = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfemp"
                         xml_operacao141.cdorigem = STRING(xText:NODE-VALUE) WHEN xField:NAME = "cdorigem"
                         xml_operacao141.vllancto = STRING(xText:NODE-VALUE) WHEN xField:NAME = "vllancto"
                         xml_operacao141.dsrowlfp = STRING(xText:NODE-VALUE) WHEN xField:NAME = "dsrowlfp"
                         xml_operacao141.nmprimtl = STRING(xText:NODE-VALUE) WHEN xField:NAME = "nmprimtl"
                         xml_operacao141.idtpcont = STRING(xText:NODE-VALUE) WHEN xField:NAME = "idtpcont".
                        
             END.
          END.
          
          
          SET-SIZE(ponteiro_xml) = 0. 
      END.
   /*Elimina os objetos criados*/
   DELETE OBJECT xDoc. 
   DELETE OBJECT xRoot. 
   DELETE OBJECT xRoot2. 
   DELETE OBJECT xField. 
   DELETE OBJECT xText.
   
   CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<dados dtcredit =""" + aux_dtcredit + """ dtdebito =""" + aux_dtdebito + """ idopdebi =""" + aux_idopdebi + """ qtlctpag =""" + aux_qtregpag + """
                                             vllctpag =""" + aux_vllctpag + """ flgrvsal =""" + aux_flgrvsal + """ vltarapr =""" + aux_vltarapr + """ >".
                                            
   FOR EACH xml_operacao141 WHERE NO-LOCK:   
      MESSAGE "l".
      CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "<lanctos><cdcooper>" + xml_operacao141.cdcooper + "</cdcooper>" +
                                     "<cdempres>" + xml_operacao141.cdempres + "</cdempres>" +
                                     "<nrdconta>" + xml_operacao141.nrdconta + "</nrdconta>" +
                                     "<nrcpfemp>" + xml_operacao141.nrcpfemp + "</nrcpfemp>" +
                                     "<cdorigem>" + xml_operacao141.cdorigem + "</cdorigem>" +
                                     "<vllancto>" + xml_operacao141.vllancto + "</vllancto>" +
                                     "<dsrowlfp>" + xml_operacao141.dsrowlfp + "</dsrowlfp>" +
                                     "<nmprimtl>" + xml_operacao141.nmprimtl + "</nmprimtl>" +                                            
                                     "<idtpcont>" + xml_operacao141.idtpcont + "</idtpcont></lanctos>".                                       
       
    END.
    
    CREATE xml_operacao.
      ASSIGN xml_operacao.dslinxml = "</dados>".
  

END.
ELSE IF  par_tpoperac = 13 THEN DO: /* Excluir lancamento permanentemente */

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_exclui_lancto_pfp_ib aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_nrdconta,
                          INPUT par_lisrowid,
                          OUTPUT 0,
                          OUTPUT "").

    CLOSE STORED-PROC pc_exclui_lancto_pfp_ib aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_exclui_lancto_pfp_ib.pr_cdcritic
                          WHEN pc_exclui_lancto_pfp_ib.pr_cdcritic <> ?
           aux_dscritic = pc_exclui_lancto_pfp_ib.pr_dscritic
                          WHEN pc_exclui_lancto_pfp_ib.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        RETURN "NOK".
    END.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = xml_req.

END.


RETURN "OK".
