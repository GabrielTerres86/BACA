/* ............................................................................

   Programa: Fontes/contas_emails.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                   Ultima Atualizacao: 05/05/2014

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes aos e-mails do Associado

   Alteracoes: 19/03/2007 - Alterado formato dos campos crapcem.dsdemail e 
                            crapcem.nmpescto do browser (Elton).

               31/07/2007 - Aumentado o tamanho do e-mail para 40 caracteres
                            (Evandro).
                            
               13/05/2010 - Utilizar BO b1wgen0071.p na rotina (David).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
               
               05/05/2014 - Aumentado o tamanho do e-mail para 60 caracteres
                            (Douglas Quisinski).
                            
.............................................................................*/

{ sistema/generico/includes/b1wgen0071tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]               NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.
DEF VAR reg_contador AS INTE          INIT 1                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

DEF VAR tel_nmpescto LIKE crapcem.nmpescto                             NO-UNDO.
DEF VAR tel_secpscto LIKE crapcem.secpscto                             NO-UNDO.

DEF VAR h-b1wgen0071 AS HANDLE                                         NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                      NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF QUERY q_emails FOR tt-email-cooperado.

DEF BROWSE b_emails QUERY q_emails
    DISP tt-email-cooperado.dsdemail LABEL "Endereco Eletronico" FORMAT "x(40)"
         tt-email-cooperado.secpscto LABEL "Setor"               FORMAT "x(08)"
         tt-email-cooperado.nmpescto LABEL "Pessoa Contato"      FORMAT "x(24)"
         WITH 5 DOWN NO-BOX.

FORM SKIP(1) 
     tel_dsdemail AT 10 LABEL "E_mail"          FORMAT "x(60)"
                        HELP "Informe o endereco do e-mail"
     SKIP
     tel_secpscto AT 11 LABEL "Setor"           FORMAT "x(08)"
                        HELP "Informe o setor"    
     SKIP
     tel_nmpescto AT  2 LABEL "Pessoa Contato"  FORMAT "x(26)"
                        HELP "Informe o nome da pessoa de contato"
     SKIP(2)                                
     WITH ROW 12 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX FRAME f_emails.
     
FORM SKIP(8)
     reg_dsdopcao[1] AT 15 FORMAT "x(7)"
     reg_dsdopcao[2] AT 35 FORMAT "x(7)"
     reg_dsdopcao[3] AT 55 FORMAT "x(7)"
     WITH ROW 11 WIDTH 80 OVERLAY NO-LABEL TITLE " E-MAILS " FRAME f_regua.
          
FORM b_emails HELP "Pressione ENTER para selecionar ou F4/END para sair."
     WITH ROW 12 COLUMN 2 WIDTH 78 OVERLAY NO-BOX FRAME f_browse.
          
ON ANY-KEY OF b_emails IN FRAME f_browse DO:

    HIDE MESSAGE NO-PAUSE.

    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
        DO:
            ASSIGN reg_contador = reg_contador + 1.
 
            IF  reg_contador > 3  THEN
                ASSIGN reg_contador = 1.
                 
            ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
        END.
    ELSE        
    IF  KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
        DO:
            ASSIGN reg_contador = reg_contador - 1.
 
            IF  reg_contador < 1  THEN
                ASSIGN reg_contador = 3.
                 
            ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
        END.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "HELP"  THEN
        APPLY LASTKEY.
    ELSE
    IF  KEY-FUNCTION(LASTKEY) = "RETURN"  THEN
        DO:
            IF  glb_cddopcao = "A"  OR
                glb_cddopcao = "E"  THEN
                DO:
                    IF  NOT AVAILABLE tt-email-cooperado  THEN
                        RETURN.

                    ASSIGN aux_nrdrowid = tt-email-cooperado.nrdrowid
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_emails").
                    
                    b_emails:DESELECT-ROWS().
                END.
            ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrdlinha = 0.
                        
            APPLY "GO".
        END.
    ELSE
        RETURN.
            
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.

ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0071)  THEN
        RUN sistema/generico/procedures/b1wgen0071.p 
            PERSISTENT SET h-b1wgen0071.

    ASSIGN glb_nmrotina = "E_MAILS"
           glb_cddopcao = reg_cddopcao[reg_contador].
   
    DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
    CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
 
    RUN obtem-email-cooperado IN h-b1wgen0071 (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1,
                                               INPUT tel_nrdconta,
                                               INPUT tel_idseqttl,
                                               INPUT aux_flgerlog,
                                              OUTPUT aux_msgconta,
                                              OUTPUT TABLE tt-email-cooperado).

    /** Gerar log somente na primeira leitura **/
    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.
    ELSE
        CLOSE QUERY q_emails.

    OPEN QUERY q_emails FOR EACH tt-email-cooperado NO-LOCK.

    IF  aux_nrdlinha > 0  THEN
        DO:
            IF  aux_nrdlinha > NUM-RESULTS("q_emails")  THEN
                ASSIGN aux_nrdlinha = NUM-RESULTS("q_emails").

            REPOSITION q_emails TO ROW(aux_nrdlinha).
        END.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       UPDATE b_emails WITH FRAME f_browse.
       LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
    
    /*Alteração: Mostra critica se usuario titular em outra conta 
     (Gabriel/DB1)*/
    IF  aux_msgconta <> "" THEN
        DO:
           MESSAGE aux_msgconta. 
           NEXT.
        END.
        
    { includes/acesso.i }

    ASSIGN tel_dsdemail = ""
           tel_secpscto = ""
           tel_nmpescto = "".

    RUN obtem-dados-gerenciar-email IN h-b1wgen0071 
                                   (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT glb_nmdatela,
                                    INPUT 1,
                                    INPUT tel_nrdconta,
                                    INPUT tel_idseqttl,
                                    INPUT glb_cddopcao,
                                    INPUT aux_nrdrowid,
                                    INPUT TRUE,
                                   OUTPUT aux_inpessoa,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-email-cooperado).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    FIND FIRST tt-email-cooperado NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-email-cooperado  THEN
        ASSIGN tel_dsdemail = tt-email-cooperado.dsdemail
               tel_secpscto = tt-email-cooperado.secpscto
               tel_nmpescto = tt-email-cooperado.nmpescto.

    DISPLAY tel_dsdemail
            tel_secpscto WHEN aux_inpessoa > 1
            tel_nmpescto WHEN aux_inpessoa > 1
            WITH FRAME f_emails.

    HIDE MESSAGE NO-PAUSE.
    
    IF  glb_cddopcao = "A"  OR
        glb_cddopcao = "I"  THEN
        DO:
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                UPDATE tel_dsdemail
                       tel_secpscto WHEN aux_inpessoa > 1
                       tel_nmpescto WHEN aux_inpessoa > 1
                       WITH FRAME f_emails.

                RUN validar-dados-informados.

                IF  RETURN-VALUE = "NOK"  THEN
                    NEXT.
        
                LEAVE.
        
            END. /** Fim do DO WHILE TRUE **/
        
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    HIDE FRAME f_emails NO-PAUSE.
                    NEXT.
                END.
        END.
    ELSE
    IF  glb_cddopcao = "E"  THEN
        DO:
            RUN validar-dados-informados.

            IF  RETURN-VALUE = "NOK"  THEN
                NEXT.
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        ASSIGN aux_confirma = "N"
               glb_cdcritic = 78.
        RUN fontes/critic.p.     
        ASSIGN glb_cdcritic = 0.
        
        BELL.                   
        MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

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
             
            HIDE FRAME f_emails NO-PAUSE.

            NEXT.
        END.

    IF  VALID-HANDLE(h-b1wgen0071) THEN
        DELETE OBJECT h-b1wgen0071.

    RUN sistema/generico/procedures/b1wgen0071.p PERSISTENT SET h-b1wgen0071.

    RUN gerenciar-email IN h-b1wgen0071 (INPUT glb_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1,
                                         INPUT tel_nrdconta,
                                         INPUT tel_idseqttl,
                                         INPUT glb_cddopcao,
                                         INPUT glb_dtmvtolt,
                                         INPUT aux_nrdrowid,
                                         INPUT tel_dsdemail,
                                         INPUT tel_secpscto,
                                         INPUT tel_nmpescto,
                                         INPUT "A",
                                         INPUT TRUE,
                                        OUTPUT aux_tpatlcad,
                                        OUTPUT aux_msgatcad,
                                        OUTPUT aux_chavealt,
                                        OUTPUT aux_msgrvcad,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            HIDE FRAME f_emails NO-PAUSE.
            NEXT.
        END.

    RUN proc_altcad (INPUT "b1wgen0071.p").

    IF  VALID-HANDLE(h-b1wgen0071) THEN
        DELETE OBJECT h-b1wgen0071.
    
    IF aux_msgrvcad <> "" THEN
       MESSAGE aux_msgrvcad.
    
    HIDE FRAME f_emails NO-PAUSE.

END. /** Fim do DO WHILE TRUE **/

IF  VALID-HANDLE(h-b1wgen0071) THEN
    DELETE PROCEDURE h-b1wgen0071.

/*...........................................................................*/

PROCEDURE validar-dados-informados:

    RUN validar-email IN h-b1wgen0071 (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_nmdatela,
                                       INPUT 1,
                                       INPUT tel_nrdconta,
                                       INPUT tel_idseqttl,
                                       INPUT glb_cddopcao,
                                       INPUT aux_nrdrowid,
                                       INPUT tel_dsdemail,
                                       INPUT tel_secpscto,
                                       INPUT tel_nmpescto,
                                       INPUT TRUE,
                                       INPUT 0, /* Conta replicadora */
                                      OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            HIDE FRAME f_emails NO-PAUSE.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE mostra-critica:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.
                                       
/*...........................................................................*/
