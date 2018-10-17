/*..............................................................................

   Programa: sistema/internet/fontes/InternetBank116.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas Quisinski
   Data    : Setembro/2014.                 Ultima atualizacao: 14/08/2018
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Realiza validação e inclusão do resgate de aplicação.
   
   Alteracoes: 22/09/2014 - Remover o parametro par_dtresgat e utilizar o valor
                            de par_dtmvtolt. (Douglas - Projeto Captação 
                            Internet 2014/2)
                            
               13/04/2015 - Ajuste projeto novos produtos captacao (David).
               
               11/12/2015 - Adicionado validacao do representante legal da conta.
                            (Jorge/David) - Proj. 131 Assinatura Multipla.

               20/04/2018 - Adicionado validacao da adesao do produto 41 resgate 
                            de aplicacao. PRJ366 (Lombardi).

               28/06/2018 - Inserido tratamento para Resgate via URA

               14/08/2018 - Inclusao da TAG <cdmsgerr> nos retornos de erro do XML,
                            Prj.427 - URA (Jean Michel)

..............................................................................*/

{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }

{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0081tt.i }

DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                     NO-UNDO.
DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                     NO-UNDO.
DEF INPUT PARAM par_nrdcaixa AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_cdoperad LIKE crapope.cdoperad                     NO-UNDO.
DEF INPUT PARAM par_nmdatela AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_idorigem AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_inproces AS INTE                                   NO-UNDO.

DEF INPUT PARAM par_nrdconta LIKE crapttl.nrdconta                     NO-UNDO.
DEF INPUT PARAM par_idseqttl LIKE crapttl.idseqttl                     NO-UNDO.
DEF INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt                     NO-UNDO.
DEF INPUT PARAM par_dtmvtopr LIKE crapdat.dtmvtopr                     NO-UNDO.
DEF INPUT PARAM par_flmensag AS LOGI                                   NO-UNDO.
DEF INPUT PARAM par_flgerlog AS LOGI                                   NO-UNDO.
DEF INPUT PARAM par_flgctain AS LOGI                                   NO-UNDO.
DEF INPUT PARAM par_cdprogra AS CHAR                                   NO-UNDO.

/* Esse parametro recebe todas as informacoes de todas as aplicacaoes que serao
   resgatadas. As aplicacoes devem ser separadas por "|" e as informacoes especificas
   de cada aplicacao devem ser separadas por ";"
   EX: nraplica;tpresgat;vlresgat|nraplica;tpresgat;vlresgat*/
DEF INPUT PARAM par_aplicacao AS CHAR                                  NO-UNDO.
DEF INPUT PARAM par_vltotrgt AS DECI                                   NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR h-b1wgen0014 AS HANDLE                                         NO-UNDO.

DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/* Informacoes para separar os dados das aplicacoes */
DEF VAR aux_info_apl AS CHAR                                           NO-UNDO.
DEF VAR aux_qtaplica AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR aux_nrdocmto AS CHAR                                           NO-UNDO.

DEF VAR aux_idastcjt AS INTE                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_flcartma AS INTE                                           NO-UNDO.

DEF VAR aux_vlresgat AS DECI                                           NO-UNDO.

/* Verificar se o tipo de conta permite a contrataçao do produto. */
{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valida_adesao_produto
    aux_handproc = PROC-HANDLE NO-ERROR
                            (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT 41,   /* Codigo Produto */
                             OUTPUT 0,   /* pr_cdcritic */
                             OUTPUT ""). /* pr_dscritic */

CLOSE STORED-PROC pc_valida_adesao_produto
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valida_adesao_produto.pr_cdcritic                          
                          WHEN pc_valida_adesao_produto.pr_cdcritic <> ?
       aux_dscritic = pc_valida_adesao_produto.pr_dscritic
                          WHEN pc_valida_adesao_produto.pr_dscritic <> ?.

IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        IF aux_dscritic = "" THEN
           DO:
              FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                 NO-LOCK NO-ERROR.
              
              IF AVAIL crapcri THEN
                 ASSIGN aux_dscritic = crapcri.dscritic.
              ELSE
                 ASSIGN aux_dscritic =  "Nao foi possivel validar a adesao do produto.".
           
           END.
        
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".
        
        RETURN "NOK".
    END.

/* Quantidade de aplicacoes */
ASSIGN aux_qtaplica = NUM-ENTRIES(par_aplicacao,"|")
       aux_vlresgat = 0.

/* Percorrer todas as aplicacoes para verificar o numero da aplicacao */
DO aux_contador = 1 TO aux_qtaplica:
    ASSIGN aux_info_apl = ENTRY(aux_contador,par_aplicacao,"|").

    CREATE tt-dados-resgate.
    ASSIGN tt-dados-resgate.idtipapl = "A"
           tt-dados-resgate.nraplica = INTE(ENTRY(1,aux_info_apl,";"))
           tt-dados-resgate.tpresgat = TRIM(ENTRY(2,aux_info_apl,";"))
           tt-dados-resgate.vlresgat = IF tt-dados-resgate.tpresgat = "1" THEN /* Resgate Parcial */
                                          DECI(ENTRY(3,aux_info_apl,";")) 
                                       ELSE /* Resgate Total sempre deve trabalhar com valor zerado devido a regra na procedure de resgate */
                                          0
           aux_vlresgat = aux_vlresgat + DECI(ENTRY(3,aux_info_apl,";")).

END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_valida_valor_de_adesao
aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Cooperativa */
                                     INPUT par_nrdconta, /* Numero da conta */
                                     INPUT 41,           /* Codigo Produto */
                                     INPUT STRING(aux_vlresgat), /* Valor contratado */
                                     INPUT par_idorigem, /* Id Origem */
                                     INPUT 0,            /* Codigo da chave */
                                    OUTPUT 0,            /* Solicita senha coordenador */
                                    OUTPUT 0,            /* Codigo da crítica */
                                    OUTPUT "").          /* Descriçao da crítica */

CLOSE STORED-PROC pc_valida_valor_de_adesao
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valida_valor_de_adesao.pr_cdcritic 
                      WHEN pc_valida_valor_de_adesao.pr_cdcritic <> ?
       aux_dscritic = pc_valida_valor_de_adesao.pr_dscritic
                      WHEN pc_valida_valor_de_adesao.pr_dscritic <> ?.

IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
     DO:
         IF aux_dscritic = "" THEN
             DO:
                FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                                   NO-LOCK NO-ERROR.
                
                IF AVAIL crapcri THEN
                   ASSIGN aux_dscritic = crapcri.dscritic.
                ELSE
                   ASSIGN aux_dscritic =  "Nao foi possivel validar o valor de adesao.".
             END.
          
          ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".

          RETURN "NOK".
END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_valid_repre_legal_trans
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  1,  /* pr_flvldrep */
                    OUTPUT 0,
                    OUTPUT "").

CLOSE STORED-PROC pc_valid_repre_legal_trans 
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_cdcritic = 0
       aux_dscritic = ""
       aux_cdcritic = pc_valid_repre_legal_trans.pr_cdcritic 
                          WHEN pc_valid_repre_legal_trans.pr_cdcritic <> ?
       aux_dscritic = TRIM(pc_valid_repre_legal_trans.pr_dscritic)
                          WHEN pc_valid_repre_legal_trans.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> ""  THEN
DO:
     IF TRIM(aux_dscritic) = "" THEN
   DO:
            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
        
            IF AVAILABLE crapcri THEN
               ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
        ELSE
               ASSIGN aux_dscritic =  "Nao foi possivel validar o Representante Legal.".

   END.

     ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                           "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>". 
   RETURN "NOK".

END.

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

RUN STORED-PROCEDURE pc_verifica_rep_assinatura
    aux_handproc = PROC-HANDLE NO-ERROR
                   (INPUT  par_cdcooper,
                    INPUT  par_nrdconta,
                    INPUT  par_idseqttl,
                    INPUT  par_idorigem,
                    OUTPUT 0,   /* idastcjt */
                    OUTPUT 0,   /* nrcpfcgc */
                    OUTPUT "",  /* nmprimtl */
                    OUTPUT 0,   /* flcartma */
                    OUTPUT 0,   /* cdcritic */
                    OUTPUT ""). /* dscritic */
    
CLOSE STORED-PROC pc_verifica_rep_assinatura 
aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_idastcjt = 0
       aux_nrcpfcgc = 0
       aux_nmprimtl = ""
       aux_flcartma = 0
       aux_cdcritic = 0
       aux_dscritic = ""
       aux_idastcjt = pc_verifica_rep_assinatura.pr_idastcjt 
                          WHEN pc_verifica_rep_assinatura.pr_idastcjt <> ?
       aux_nrcpfcgc = pc_verifica_rep_assinatura.pr_nrcpfcgc 
                          WHEN pc_verifica_rep_assinatura.pr_nrcpfcgc <> ?
       aux_nmprimtl = pc_verifica_rep_assinatura.pr_nmprimtl 
                          WHEN pc_verifica_rep_assinatura.pr_nmprimtl <> ?
       aux_flcartma = pc_verifica_rep_assinatura.pr_flcartma 
                          WHEN pc_verifica_rep_assinatura.pr_flcartma <> ?
       aux_cdcritic = pc_verifica_rep_assinatura.pr_cdcritic 
                          WHEN pc_verifica_rep_assinatura.pr_cdcritic <> ?
       aux_dscritic = TRIM(pc_verifica_rep_assinatura.pr_dscritic)
                      WHEN pc_verifica_rep_assinatura.pr_dscritic <> ?. 

IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
DO:
  IF aux_dscritic = "" THEN
     DO:
        FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
        
        IF AVAILABLE crapcri THEN
           ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
        ELSE
           ASSIGN aux_dscritic =  "Nao foi possivel validar o Representante Legal.".
     END.

  ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                        "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".

  RETURN "NOK".

END.

IF (par_flmensag OR (NOT par_flmensag AND aux_idastcjt = 0)) AND par_idorigem <> 6 THEN
DO:
    IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
        RUN sistema/generico/procedures/b1wgen0081.p 
            PERSISTENT SET h-b1wgen0081.
    
    RUN cadastrar-varios-resgates-aplicacao IN h-b1wgen0081(INPUT par_cdcooper,
                                                            INPUT par_cdagenci,
                                                            INPUT par_nrdcaixa,
                                                            INPUT par_cdoperad,
                                                            INPUT par_nmdatela,
                                                            INPUT par_idorigem,
                                                            INPUT par_nrdconta,
                                                            INPUT par_idseqttl,
                                                            INPUT par_dtmvtolt,
                                                            INPUT par_flgctain,
                                                            INPUT par_dtmvtolt,
                                                            INPUT par_dtmvtopr,
                                                            INPUT par_cdprogra,
                                                            INPUT par_flmensag,
                                                            INPUT par_flgerlog,
                                                            INPUT TABLE tt-dados-resgate,
                                                           OUTPUT aux_nrdocmto,
                                                           OUTPUT TABLE tt-msg-confirma,
                                                           OUTPUT TABLE tt-erro).
    
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
       
           IF AVAILABLE tt-erro  THEN
               ASSIGN aux_dscritic = TRIM(tt-erro.dscritic)
                      aux_cdcritic = tt-erro.cdcritic.
           ELSE
               ASSIGN aux_dscritic = "Nao foi possivel consultar aplicacoes.".
       
           ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                                 "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>". 
       
           IF  VALID-HANDLE(h-b1wgen0081) THEN
               DELETE PROCEDURE h-b1wgen0081.
       
           RETURN "NOK".
       END.
    
    IF  VALID-HANDLE(h-b1wgen0081) THEN
        DELETE PROCEDURE h-b1wgen0081.
    
    ASSIGN aux_dslinxml = "".
    
    /* Carregar todas as mensagens de confirmação */
    FOR EACH wt_msg_confirma NO-LOCK:
    
        ASSIGN aux_dslinxml = aux_dslinxml + 
                              "<MSGCONFIRMA>" + 
                                  "<inconfir>" + STRING(wt_msg_confirma.inconfir) + "</inconfir>" +
                                  "<dsmensag>" + STRING(wt_msg_confirma.dsmensag) + "</dsmensag>" +
                              "</MSGCONFIRMA>".
    END.
    
    IF NOT par_flmensag THEN 
       ASSIGN aux_dslinxml = aux_dslinxml + 
                             "<APLICACOES>" + 
                                  "<nrdocmto>" + aux_nrdocmto + "</nrdocmto>" +
                                  "<dsprotoc></dsprotoc>" + /* Implementaçao futura */
                             "</APLICACOES>" +
                             "<dsmsgsuc>Resgate realizado com sucesso.</dsmsgsuc>" +
                             "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
    
END.
/* Origem URA */
ELSE IF par_idorigem = 6 THEN
DO:
 
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_resgata_aplicacao
        aux_handproc = PROC-HANDLE NO-ERROR
                       (INPUT  par_cdcooper,
                        INPUT  par_nrdconta,
                        INPUT  par_vltotrgt,
                        INPUT  par_cdagenci,
                        INPUT  par_nrdcaixa,
                        INPUT  par_cdoperad,
                        INPUT  par_nmdatela,
                        INPUT  par_idorigem,
                        INPUT  par_idseqttl,
                        INPUT  "A",
                        INPUT  INT(par_flmensag),
                        INPUT  aux_idastcjt,
                        INPUT  aux_nrcpfcgc,
                        OUTPUT "",
                        OUTPUT 0,
                        OUTPUT "").

    CLOSE STORED-PROC pc_resgata_aplicacao 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""
           aux_nrdocmto = ""
           aux_dscritic = TRIM(pc_resgata_aplicacao.pr_dscritic)
                          WHEN pc_resgata_aplicacao.pr_dscritic <> ?
           aux_cdcritic = INT(pc_resgata_aplicacao.pr_cdcritic)
                          WHEN pc_resgata_aplicacao.pr_cdcritic <> ?               
           aux_nrdocmto = pc_resgata_aplicacao.pr_nrdocmto
                          WHEN pc_resgata_aplicacao.pr_nrdocmto <> ?.                           

    IF TRIM(aux_dscritic) <> "" THEN
    DO:
        ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                              "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>".
        RETURN "NOK".  
    END. 
    
    
    IF NOT par_flmensag THEN 
       ASSIGN aux_dslinxml = aux_dslinxml + 
                             "<APLICACOES>" + 
                                  "<nrdocmto>" + aux_nrdocmto + "</nrdocmto>" +
                                  "<dsprotoc></dsprotoc>" + /* Implementaçao futura */
                             "</APLICACOES>" +
                             "<dsmsgsuc>Resgate realizado com sucesso.</dsmsgsuc>" +
                             "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
                             

    /* Se for assinatura conjunta */
    IF aux_idastcjt = 1 THEN
    DO:
     RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
             SET h-b1wgen0014.
    
     IF  VALID-HANDLE(h-b1wgen0014)  THEN
     DO:
         aux_dstransa = "Cadastrar resgate da aplicacao".

         RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                       INPUT "996",
                                       INPUT aux_dscritic,
                                       INPUT "INTERNET",
                                       INPUT aux_dstransa,
                                       INPUT aux_datdodia,
                                       INPUT TRUE,
                                       INPUT TIME,
                                       INPUT par_idseqttl,
                                       INPUT "InternetBank",
                                       INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

         RUN gera_log_item IN h-b1wgen0014 
             (INPUT aux_nrdrowid,
              INPUT "CPF Representate/Procurador" ,
              INPUT "",
              INPUT aux_nrcpfcgc).

        RUN gera_log_item IN h-b1wgen0014 
             (INPUT aux_nrdrowid,
              INPUT "Nome Representate/Procurador" ,
              INPUT "",
              INPUT aux_nmprimtl).

         DELETE PROCEDURE h-b1wgen0014.
     END.

     ASSIGN aux_dscritic = "Resgate registrado com sucesso. "    + 
                           "Aguardando aprovacao da operacao pelos "  +
                           "demais responsaveis."   
            aux_dslinxml = "<dsmsgsuc>" + TRIM(aux_dscritic) + "</dsmsgsuc>" +
                           "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".                             
    END.
END.

ELSE IF NOT par_flmensag AND aux_idastcjt = 1 THEN
DO: 
    FOR EACH tt-dados-resgate NO-LOCK:
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
        RUN STORED-PROCEDURE pc_cria_trans_pend_aplica
           aux_handproc = PROC-HANDLE NO-ERROR
                          (INPUT  par_cdagenci,
                           INPUT  par_nrdcaixa,
                           INPUT  par_cdoperad,
                           INPUT  par_nmdatela,
                           INPUT  par_idorigem,
                           INPUT  par_idseqttl,
                           INPUT  0,   /* par_nrcpfope */
                           INPUT  aux_nrcpfcgc,
                           INPUT  0,   /* par_cdcoptfn */
                           INPUT  0,   /* par_cdagetfn */
                           INPUT  0,   /* par_nrterfin */
                           INPUT  par_dtmvtolt,
                           INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  2,    /* par_idoperac */
                           INPUT  tt-dados-resgate.idtipapl,
                           INPUT  tt-dados-resgate.nraplica,
                           INPUT  0,    /* par_cdprodut */
                           INPUT  INTEGER(tt-dados-resgate.tpresgat),
                           INPUT  tt-dados-resgate.vlresgat,
                           INPUT  0,    /* par_nrdocmto */
                           INPUT  0,    /* par_idtipage */
                           INPUT  0,    /* par_idperage */
                           INPUT  0,    /* par_qtmesage */
                           INPUT  0,    /* par_dtdiaage */
                           INPUT  ?,    /* par_dtiniage */
                           INPUT  aux_idastcjt,
                           OUTPUT 0,    /* par_cdcritic */
                           OUTPUT "").  /* par_dscritic */

        CLOSE STORED-PROC pc_cria_trans_pend_aplica 
             aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_cdcritic = 0
              aux_dscritic = ""
              aux_cdcritic = pc_cria_trans_pend_aplica.pr_cdcritic 
                                 WHEN pc_cria_trans_pend_aplica.pr_cdcritic <> ?
               aux_dscritic = TRIM(pc_cria_trans_pend_aplica.pr_dscritic)
                                 WHEN pc_cria_trans_pend_aplica.pr_dscritic <> ?. 
        
        IF aux_cdcritic <> 0 OR TRIM(aux_dscritic) <> "" THEN
        DO:
             IF TRIM(aux_dscritic) = "" THEN
                DO:
                   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic NO-LOCK NO-ERROR.
        
                   IF AVAILABLE crapcri THEN
                      ASSIGN aux_dscritic = TRIM(crapcri.dscritic).
                   ELSE
                      ASSIGN aux_dscritic =  "Nao foi possivel criar transacao pendente de aplicacao.".
        
                END.
        
             ASSIGN xml_dsmsgerr = "<dsmsgerr>" + TRIM(aux_dscritic) + "</dsmsgerr>" +
                                   "<cdmsgerr>" + STRING(aux_cdcritic) + "</cdmsgerr>". 
        
             RETURN "NOK".
        
        END. 

    END.

     RUN sistema/generico/procedures/b1wgen0014.p PERSISTENT 
             SET h-b1wgen0014.
    
     IF  VALID-HANDLE(h-b1wgen0014)  THEN
     DO:
         aux_dstransa = "Cadastrar resgate da aplicacao".

         RUN gera_log IN h-b1wgen0014 (INPUT par_cdcooper,
                                       INPUT "996",
                                       INPUT aux_dscritic,
                                       INPUT "INTERNET",
                                       INPUT aux_dstransa,
                                       INPUT aux_datdodia,
                                       INPUT TRUE,
                                       INPUT TIME,
                                       INPUT par_idseqttl,
                                       INPUT "InternetBank",
                                       INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

         RUN gera_log_item IN h-b1wgen0014 
             (INPUT aux_nrdrowid,
              INPUT "CPF Representate/Procurador" ,
              INPUT "",
              INPUT aux_nrcpfcgc).

        RUN gera_log_item IN h-b1wgen0014 
             (INPUT aux_nrdrowid,
              INPUT "Nome Representate/Procurador" ,
              INPUT "",
              INPUT aux_nmprimtl).

         DELETE PROCEDURE h-b1wgen0014.
     END.

     ASSIGN aux_dscritic = "Resgate registrado com sucesso. "    + 
                           "Aguardando aprovacao da operacao pelos "  +
                           "demais responsaveis."   
            aux_dslinxml = "<dsmsgsuc>" + aux_dscritic + "</dsmsgsuc>" +
                           "<idastcjt>" + STRING(aux_idastcjt) + "</idastcjt>".
END.

CREATE xml_operacao.
ASSIGN xml_operacao.dslinxml = aux_dslinxml.

RETURN "OK".

/*............................................................................*/