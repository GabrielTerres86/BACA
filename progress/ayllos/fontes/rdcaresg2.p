/* .............................................................................

   Programa: Fontes/rdcaresg2.p                          
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Julho/2001.                     Ultima atualizacao: 15/05/2015
                                                                        
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento do resgate das aplicacoes RDCA.

   Alteracoes: 02/04/2002 - Resgate on-line do RDCA30.
               
               21/08/2003 - Na CECRED, os resgates de RDCA30, so podem ser
                            feitos no vencimento mensal da aplicacao
                            (Fernando).

               23/10/2003 - Eliminado o tratamento acima (Deborah).

               06/01/2004 - Se saldo negativo nao deixar resgatar (Margarete).
 
               06/09/2004 - Incluido Flag Conta Investimento(Mirtes).

               03/11/2004 - Nao deixar resgatar aplicacoes feitas no dia.
                            Para isso usar a tela LANRDA (Margarete).
                            
               09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela (Evandro).
                            
               10/12/2004 - Ajustes para tratar das novas aliquotas de 
                            IRRF e Ajuste das posicoes s_chlist (Margarete).
                            
               07/01/2005 - Nao permitir resgate sem saldo (Margarete). 
               
               05/07/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplrg (Diego).
                            
               29/11/2005 - Permitir resgatar saldo 0.01 (Magui).
               
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               05/09/2006 - Alterado para habilitar a opcao 
                            "Resgate Saldo para a CI" em aplicacoes antigas, se
                            data do resgate for maior que 01/10/2006 (Diego).
                             
               22/05/2007 - Atender aos novos tipos de aplicacao (David).  
               
               30/10/2007 - Corrigir critica de saldo restante (Magui).

               17/01/2008 - Melhorar critica resgate valor minimo (Magui).

               03/06/2009 - Nao permitir que seja efetuado mais de 2 resgates 
                            de uma aplicacao no mesmo dia (Fernando).
                            
               28/04/2010 - Utilizar a includes/var_rdcapp2.i (Gabriel).
               
               11/10/2010 - Ajuste para utilizar BO da rotina (David).
               
               29/11/2010 - Utilizar a BO b1wgen0081.p (Adriano).
               
               08/12/2010 - Incluido controle no resgate total e parcial.
                            (Henrique).
               
               25/04/2014 - Ajuste para bloquear o campo tel_flgctain e deixa-lo
                            com o valor padrao "Nao".
                            Projeto Captacao (Adriano).

               12/08/2014 - Ajuste para bloquear o campo tel_dtresgat e deixa-lo
                            com o valor padrao a data do sistema. 
                            (Douglas - Projeto Captação Internet 2014/2)
                            
               16/09/2014 - Ajuste para não editar os campos tel_dtresgat e 
                            tel_flgctain que estão bloqueados. 
                            (Douglas - Projeto Captação Internet 2014/2)
                            
               06/02/2015 - Inclusao de procedures para a solicitacao de resgate
                            de novas aplicacoes e ajustes de tela (Jean Michel).    
                           
               15/05/2015 - Incluido validacao de limite de alcada de captacao
                            e permitir operador com limite suficiente autorizar
                            a operacao (Tiago/Gielow).
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nraplica AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_vlrresga AS DECI                                  NO-UNDO.
DEF  INPUT PARAM par_cdprodut LIKE crapcpc.cdprodut                    NO-UNDO.
DEF  INPUT PARAM par_idtipapl AS CHAR                                  NO-UNDO.

DEF VAR tel_dsresgat AS CHAR INIT "Resgates"                           NO-UNDO.
DEF VAR tel_dscancel AS CHAR INIT "Cancelamento"                       NO-UNDO.
DEF VAR tel_dsproxim AS CHAR INIT "Proximos"                           NO-UNDO.
DEF VAR tel_tpresgat AS CHAR                                           NO-UNDO.
DEF VAR aux_tpresgat AS INTE                                           NO-UNDO.

DEF VAR tel_dtresgat AS DATE                                           NO-UNDO.

DEF VAR tel_vlresgat AS DECI                                           NO-UNDO.

DEF VAR tel_flgctain AS LOGI                                           NO-UNDO.

DEF VAR aut_cdopera2 AS CHAR                                           NO-UNDO.
DEF VAR aut_cddsenha AS CHAR                                           NO-UNDO.
DEF VAR aut_flgsenha AS LOGICAL                                        NO-UNDO.

DEF VAR aux_vlrresga AS DEC                                            NO-UNDO.
DEF VAR aux_pedesenh AS LOGICAL INITIAL FALSE                          NO-UNDO.

DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_nrdocmto AS DECI                                           NO-UNDO.

DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     tel_dsresgat AT 05 FORMAT "x(08)"
         HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dscancel AT 24 FORMAT "x(12)"
         HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_dsproxim AT 47 FORMAT "x(08)"
         HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."        
     SKIP(1)
     WITH ROW 14 COLUMN 44 OVERLAY CENTERED WIDTH 60 NO-LABELS 
          TITLE COLOR NORMAL " Resgates " FRAME f_opcao.

FORM SKIP(1)
     tel_tpresgat AT 05 LABEL "Tipo de resgate (T/P)" FORMAT "!(1)"
                  HELP "Entre com o tipo de resgate (Total/Parcial)."
                  VALIDATE(CAN-DO("T,P",tel_tpresgat), "014 - Opcao errada.")
     SKIP(1)
     tel_vlresgat AT 10 LABEL "Valor do resgate" FORMAT "zzz,zzz,zz9.99" 
                  HELP "Entre com o valor do resgate."
     SKIP(1)
     tel_dtresgat AT 11 LABEL "Data do resgate" FORMAT "99/99/9999"  
                  HELP "Entre com a data do resgate."
     SKIP(1)
     tel_flgctain AT 11 LABEL "Resgatar Saldo para a CI?" FORMAT "Sim/Nao" 
                  HELP "Entre Sim/Nao - Conta Investimento"
     SKIP(1)
     WITH ROW 10 COLUMN 44 CENTERED WIDTH 60  OVERLAY SIDE-LABELS
          TITLE COLOR NORMAL " Resgate das Aplicacoes " FRAME f_resgate.

IF par_idtipapl = "A" THEN
    DO:
        IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

        RUN valida-acesso-opcao-resgate IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT glb_cdoperad,
                                                         INPUT glb_nmdatela,
                                                         INPUT 1,
                                                         INPUT par_nrdconta,
                                                         INPUT 1,
                                                         INPUT par_nraplica,
                                                         INPUT glb_dtmvtolt,
                                                         INPUT glb_cdprogra,
                                                         INPUT FALSE,
                                                         INPUT TRUE,
                                                        OUTPUT TABLE tt-erro).
        
        IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081.
        
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF  AVAILABLE tt-erro  THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                    END.
        
                RETURN.
            END.
        
    END.

DO WHILE TRUE:
    
    HIDE FRAME f_opcao.
    HIDE FRAME f_resgate.
    
    DISPLAY tel_dsresgat tel_dscancel tel_dsproxim WITH FRAME f_opcao.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CHOOSE FIELD tel_dsresgat tel_dscancel tel_dsproxim
                     WITH FRAME f_opcao.
        
        HIDE FRAME f_opcao.
        HIDE FRAME f_resgate.
        LEAVE.
        

    END. /** Fim do DO WHILE TRUE **/
    
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO: 
            HIDE MESSAGE NO-PAUSE.
            HIDE FRAME f_opcao.
            LEAVE.
        END.

    HIDE MESSAGE NO-PAUSE.

    IF FRAME-VALUE = tel_dsresgat  THEN
        RUN resgate.
    ELSE
        RUN fontes/rdcaresg3.p (INPUT IF FRAME-VALUE = tel_dscancel  THEN
                                          TRUE
                                      ELSE
                                          FALSE,
                                INPUT par_nrdconta,
                                INPUT par_nraplica,
                                INPUT par_idtipapl).
    
    PAUSE 0.
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/

PROCEDURE resgate:
    
    IF par_idtipapl = "A" THEN
        DO:
            IF NOT VALID-HANDLE(h-b1wgen0081) THEN
                RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

            RUN valida-acesso-opcao-resgate IN h-b1wgen0081 (INPUT glb_cdcooper,
                                                             INPUT 0,
                                                             INPUT 0,
                                                             INPUT glb_cdoperad,
                                                             INPUT glb_nmdatela,
                                                             INPUT 1,
                                                             INPUT par_nrdconta,
                                                             INPUT 1,
                                                             INPUT par_nraplica,
                                                             INPUT glb_dtmvtolt,
                                                             INPUT glb_cdprogra,
                                                             INPUT TRUE, 
                                                             INPUT TRUE,
                                                            OUTPUT TABLE tt-erro).
            
            IF VALID-HANDLE(h-b1wgen0081) THEN
                DELETE PROCEDURE h-b1wgen0081.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE tt-erro  THEN
                        DO:
                            BELL.
                            MESSAGE tt-erro.dscritic.
                            PAUSE 3 NO-MESSAGE.
                        END.
                    NEXT.
                END.
        END.
    
    ASSIGN tel_tpresgat = ""
           tel_dtresgat = glb_dtmvtolt
           tel_vlresgat = 0
           aut_cdopera2 = ""
           aut_cddsenha = ""
           tel_flgctain:READ-ONLY IN FRAME f_resgate = YES.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        DISPLAY tel_dtresgat tel_flgctain WITH FRAME f_resgate.
        DISABLE tel_dtresgat tel_flgctain WITH FRAME f_resgate.
        
        UPDATE tel_tpresgat
               tel_dtresgat WHEN par_idtipapl <> "A"
               tel_vlresgat WHEN tel_tpresgat <> "T" 
               WITH FRAME f_resgate

        EDITING:

            READKEY.
            
            IF  FRAME-FIELD = "tel_tpresgat"  THEN
                DO:
                    IF INPUT tel_tpresgat = "T"  THEN
                        DO:
                            ASSIGN tel_vlresgat = 0.                
                            DISPLAY tel_vlresgat WITH FRAME f_resgate.
                            DISABLE tel_vlresgat WITH FRAME f_resgate.

                            IF par_idtipapl = "N" THEN
                                ENABLE tel_dtresgat WITH FRAME f_resgate.
                        END.
                    ELSE
                        DO:
                            IF par_idtipapl = "N" THEN
                                ENABLE tel_vlresgat tel_dtresgat WITH FRAME f_resgate.
                            ELSE
                                ENABLE tel_vlresgat WITH FRAME f_resgate.
                        END.
                    
                    APPLY LASTKEY.
                END.
            ELSE
            IF  FRAME-FIELD = "tel_vlresgat"  THEN
                DO:
                    IF LASTKEY =  KEYCODE(".")  THEN
                        APPLY 44.
                    ELSE
                        APPLY LASTKEY.

                END.
            ELSE
                APPLY LASTKEY.

            IF GO-PENDING  THEN
                DO WITH FRAME f_resgate:
                    ASSIGN tel_tpresgat tel_vlresgat tel_dtresgat tel_flgctain.
                END.

        END. /** Fim do EDITING **/
        
        /* Validações de Resgates */
        IF par_idtipapl = "A" THEN
            DO:
                RUN gravar-resgate (INPUT TRUE).  /** VALIDACAO **/ 

                IF RETURN-VALUE = "NOK"  AND
                   aux_pedesenh = TRUE THEN
                   DO:
                        ASSIGN aut_cdopera2 = ""
                               aux_pedesenh = FALSE.

                        /* necessita da senha do operador */
                        RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                                 INPUT 1,
                                                 OUTPUT aut_flgsenha,
                                                 OUTPUT aut_cdopera2).
    
                        IF  NOT aut_flgsenha   THEN
                            DO:
                                aut_cdopera2 = "".
                                NEXT.
                            END.
                            

                        RUN gravar-resgate (INPUT TRUE).  /** VALIDACAO **/ 

                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                              NEXT.
                            END.

                   END.

            END.
        ELSE
            DO:
                IF tel_tpresgat = "P" THEN
                  ASSIGN aux_tpresgat = 1.
                ELSE
                  ASSIGN aux_tpresgat = 2.
                
                IF aut_cdopera2 = "" THEN
                   ASSIGN aut_cdopera2 = glb_cdoperad.

                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                
                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE pc_val_solicit_resg
                    aux_handproc = PROC-HANDLE NO-ERROR(INPUT DEC(glb_cdcooper),  /* Código da Cooperativa */
                                                        INPUT aut_cdopera2,       /* Código do Operador */
                                                        INPUT glb_nmdatela,       /* Nome da Tela */
                                                        INPUT DEC(1),             /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA) */
                                                        INPUT DEC(par_nrdconta),  /* Número da Conta */
                                                        INPUT DEC(1),             /* Titular da Conta */
                                                        INPUT DEC(par_nraplica),  /* Número da Aplicação */
                                                        INPUT par_cdprodut,       /* Código do Produto */
                                                        INPUT DATE(tel_dtresgat), /* Data do Resgate (Data informada em tela) */
                                                        INPUT DEC(tel_vlresgat),  /* Valor do Resgate (Valor informado em tela) */
                                                        INPUT DEC(aux_tpresgat),  /* Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total) */
                                                        INPUT DEC(tel_flgctain),  /* Resgate na Conta Investimento (Identificador informado em tela, 0 – Não) */
                                                        INPUT DEC(1),             /* Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim) */
                                                        INPUT DEC(1),             /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                                        INPUT '',
                                                        INPUT '',
                                                        INPUT 0, 
                                                       OUTPUT 0,                  /* Código da crítica */
                                                       OUTPUT "").                /* Descricao da Critica */
                
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_val_solicit_resg
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
             
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
        
                /* Busca possíveis erros */ 
                ASSIGN glb_cdcritic = pc_val_solicit_resg.pr_cdcritic
                       glb_dscritic = pc_val_solicit_resg.pr_dscritic.
        
                IF glb_dscritic <> ? AND
                   glb_dscritic <> ""  THEN
                  DO:
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE 3 NO-MESSAGE.
                      
                    IF glb_dscritic MATCHES "*alcada menor que o da operacao*" THEN
                    DO: 
                        ASSIGN aut_cdopera2 = "".
                        /* necessita da senha do operador */
                        RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                                 INPUT 1,
                                                 OUTPUT aut_flgsenha,
                                                 OUTPUT aut_cdopera2).
    
                        IF  NOT aut_flgsenha   THEN
                            NEXT.
    
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
    
                        /* Efetuar a chamada a rotina Oracle */ 
                        RUN STORED-PROCEDURE pc_val_solicit_resg
                            aux_handproc = PROC-HANDLE NO-ERROR(INPUT DEC(glb_cdcooper),  /* Código da Cooperativa */
                                                                INPUT aut_cdopera2,       /* Código do Operador */
                                                                INPUT glb_nmdatela,       /* Nome da Tela */
                                                                INPUT DEC(1),             /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA) */
                                                                INPUT DEC(par_nrdconta),  /* Número da Conta */
                                                                INPUT DEC(1),             /* Titular da Conta */
                                                                INPUT DEC(par_nraplica),  /* Número da Aplicação */
                                                                INPUT par_cdprodut,       /* Código do Produto */
                                                                INPUT DATE(tel_dtresgat), /* Data do Resgate (Data informada em tela) */
                                                                INPUT DEC(tel_vlresgat),  /* Valor do Resgate (Valor informado em tela) */
                                                                INPUT DEC(aux_tpresgat),  /* Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total) */
                                                                INPUT DEC(tel_flgctain),  /* Resgate na Conta Investimento (Identificador informado em tela, 0 – Não) */
                                                                INPUT DEC(1),             /* Identificador de validação do bloqueio judicial (0 – Não / 1 – Sim) */
                                                                INPUT DEC(1),             /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                                                INPUT '',
                                                                INPUT '',
                                                                INPUT 0, 
                                                               OUTPUT 0,                  /* Código da crítica */
                                                               OUTPUT "").                /* Descricao da Critica */
    
                        /* Fechar o procedimento para buscarmos o resultado */ 
                        CLOSE STORED-PROC pc_val_solicit_resg
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
                        /* Busca possíveis erros */ 
                        ASSIGN glb_cdcritic = pc_val_solicit_resg.pr_cdcritic
                               glb_dscritic = pc_val_solicit_resg.pr_dscritic.
    
                        IF glb_dscritic <> ? AND
                           glb_dscritic <> "" THEN
                           DO:
                             NEXT.
                           END.
                    END.
                    ELSE
                        NEXT.
                  END.
            END.
        
        ASSIGN glb_cdcritic = 78.
        RUN fontes/critic.p.
        ASSIGN glb_cdcritic = 0.

        FOR EACH tt-msg-confirma NO-LOCK:

            IF  tt-msg-confirma.inconfir = 1  THEN
                ASSIGN glb_dscritic = tt-msg-confirma.dsmensag.
            ELSE
                DO:
                    DISPLAY SKIP(1)
                            SUBSTR(tt-msg-confirma.dsmensag,1,
                                   INDEX(tt-msg-confirma.dsmensag,".") + 1) 
                                   FORMAT "x(68)"
                            SKIP
                            SUBSTR(tt-msg-confirma.dsmensag,
                                   INDEX(tt-msg-confirma.dsmensag,".") + 1)
                                   FORMAT "x(68)"
                            SKIP(1)
                            WITH OVERLAY CENTERED ROW 12 WIDTH 70 
                                 COLOR MESSAGE FRAME f_mensagem.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        LEAVE.
                    END. /** Fim do DO WHILE TRUE **/
                    
                    HIDE FRAME f_mensagem NO-PAUSE.
                END.
            END.

        ASSIGN aux_confirma = "N".

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            BELL.
            MESSAGE glb_dscritic UPDATE aux_confirma.
            LEAVE.
              
        END. /** Fim do DO WHILE TRUE **/

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
            aux_confirma <> "S"                 THEN
            DO:
                ASSIGN glb_cdcritic = 79.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.

                BELL.
                MESSAGE glb_dscritic.

                HIDE FRAME f_resgate.
                RETURN "NOK".
            END.

        IF par_idtipapl = "A" THEN
            DO:
                RUN gravar-resgate (INPUT FALSE).  /** CADASTRO **/

                IF RETURN-VALUE = "NOK" THEN
                   NEXT.    
            END.
        ELSE
            DO: 
                
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
               
                /* Efetuar a chamada a rotina Oracle */ 
                RUN STORED-PROCEDURE pc_solicita_resgate
                  aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,                        /* Código da Cooperativa */
                                                      INPUT aut_cdopera2,                        /* Código do Operador */
                                                      INPUT glb_nmdatela,                        /* Nome da Tela */
                                                      INPUT 1,                                   /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA) */
                                                      INPUT par_nrdconta,                        /* Número da Conta */
                                                      INPUT 1,                                   /* Titular da Conta */
                                                      INPUT par_nraplica,                        /* Número da Aplicação */
                                                      INPUT par_cdprodut,                        /* Código do Produto */
                                                      INPUT DATE(tel_dtresgat),                  /* Data do Resgate (Data informada em tela) */
                                                      INPUT DEC(tel_vlresgat),                   /* Valor do Resgate (Valor informado em tela) */
                                                      INPUT IF tel_tpresgat = "P" THEN 1 ELSE 2, /* Tipo do Resgate (Tipo informado em tela, 1 – Parcial / 2 – Total) */
                                                      INPUT INT(tel_flgctain),                   /* Resgate na Conta Investimento (Identificador informado em tela, 0 – Não) */
                                                      INPUT 1, 
                                                      INPUT "",
                                                      INPUT "",
                                                      INPUT 0,                                  /* Identificador de Log (Fixo no código, 0 – Não / 1 - Sim) */
                                                     OUTPUT 0,                                   /* Código da crítica */
                                                     OUTPUT "").                                /* Descricao da Critica */
                                                                                               
                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_solicita_resgate
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
             
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                /* Busca possíveis erros */ 
                ASSIGN glb_cdcritic = pc_solicita_resgate.pr_cdcritic.
                ASSIGN glb_dscritic = pc_solicita_resgate.pr_dscritic.

                IF glb_cdcritic <> 0 AND 
                   glb_dscritic <> ? THEN
                  DO:
                    BELL.
                    MESSAGE glb_dscritic.
                    RETURN "NOK".
                  END.
                
            END.
         
        LEAVE.  

    END. /** Fim do DO WHILE TRUE **/

    APPLY LASTKEY.

    HIDE FRAME f_resgate.

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
      RETURN "OK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gravar-resgate:

    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.

    IF  aut_cdopera2 = "" THEN
        ASSIGN aut_cdopera2 = glb_cdoperad.

    IF NOT VALID-HANDLE(h-b1wgen0081) THEN
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
    
    RUN cadastrar-resgate-aplicacao IN h-b1wgen0081(INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT aut_cdopera2,
                                                    INPUT glb_nmdatela,
                                                    INPUT 1,
                                                    INPUT par_nrdconta,
                                                    INPUT 1,
                                                    INPUT par_nraplica,
                                                    INPUT tel_tpresgat,
                                                    INPUT tel_vlresgat,
                                                    INPUT tel_dtresgat,
                                                    INPUT tel_flgctain,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtopr,
                                                    INPUT glb_cdprogra,
                                                    INPUT par_flgvalid,
                                                    INPUT TRUE,
                                                    INPUT "",
                                                    INPUT "",
                                                   OUTPUT aux_nrdocmto,
                                                   OUTPUT TABLE tt-msg-confirma,
                                                   OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0081) THEN
        DELETE PROCEDURE h-b1wgen0081.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                DO:
                    ASSIGN aut_cdopera2 = glb_cdoperad.
                    IF tt-erro.dscritic MATCHES "*alcada menor que o da operacao*"  THEN
                       aux_pedesenh = TRUE.
                    ELSE
                       aux_pedesenh = FALSE.

                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/*............................................................................*/
