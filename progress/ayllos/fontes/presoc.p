
/* ...........................................................................

   Programa: fontes/presoc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI (Eder J. Venancio)
   Data    : Abril/2011                      Ultima atualizacao: 06/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Tela com funcoes referentes a Previdencia disponiveis para as
               Cooperativas (baseada na tela PRINSS, funcoes "H", "L" e "R".

   Alteracoes: 30/09/2011 - Na opcao "H" Somente alterar horario se o 
                            glb_dsdepart for TI ou SUPORTE
                            (GATI - Vitor)
                            
               29/02/2011 - Retirado a opcao "R" e passado para a tela prprev
                            (Adriano).             
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).                            
                            
               10/01/2014 - Alterado critica de "15 - Agencia nao cadastrada"
                            para "962 - PA nao cadastrado". (Reinert) 
                            
               25/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
               
               06/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0091tt.i }

DEF VAR tel_cdagenci LIKE crapage.cdagenci                          NO-UNDO.
DEF VAR tel_datadlog LIKE crapdat.dtmvtolt                          NO-UNDO.
DEF VAR tel_cddopcao AS LOGICAL FORMAT "T/I"                        NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INT                                         NO-UNDO.
DEF VAR aux_nmarqdat AS CHAR                                        NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR     FORMAT "!"                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR h_b1wgen0091 AS HANDLE                                      NO-UNDO.
/* Variaveis de impressao */
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR par_flgrodar AS LOGI    INITIAL TRUE                        NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR par_flgfirst AS LOGI    INITIAL TRUE                        NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    INIT "Imprimir" FORMAT "x(8)"       NO-UNDO.
DEF VAR tel_dscancel AS CHAR    INIT "Cancelar" FORMAT "x(8)"       NO-UNDO.
DEF VAR par_flgcance AS LOGI                                        NO-UNDO.


DEF QUERY q_bancoob FOR tt-arquivos.

DEF BROWSE b_bancoob QUERY q_bancoob
    DISP   tt-arquivos.nmarquiv LABEL "Arquivo" FORMAT "x(30)"
           WITH CENTERED NO-BOX 13 DOWN.

FORM SKIP(1)
     glb_cddopcao AT  5 LABEL  "Opcao"
     HELP "Informe a opcao (H-Horarios; L-Log; R-Visual./Impressao)."
          VALIDATE(CAN-DO("H,L,R",glb_cddopcao),"014 - Opcao errada.")
     
     tel_cdagenci AT 31 LABEL "PA"
          VALIDATE(tel_cdagenci = 0 OR
                   CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                          crapage.cdagenci = tel_cdagenci),
                   "962 - PA nao cadastrado.")
                        
     tel_datadlog AT 55 LABEL "Data"
          HELP "Informe a data do LOG."
     WITH ROW 4 OVERLAY SIZE 80 BY 18 SIDE-LABELS NO-LABELS TITLE glb_tldatela 
          FRAME f_presoc.
     
FORM b_bancoob AT 1
         HELP "Use as <SETAS> p/ navegar e <ENTER> p/ selecionar o arquivo"
     WITH NO-BOX ROW 6 COLUMN 17 OVERLAY FRAME f_bancoob.

ON RETURN OF b_bancoob IN FRAME f_bancoob DO:

    HIDE FRAME f_bancoob.

    APPLY "GO".

END.

ASSIGN glb_cdcritic = 0
       glb_cddopcao = "R" /* Visualiz. / Impressao */
       tel_datadlog = glb_dtmvtolt.
        
DO WHILE TRUE:

   RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

   RUN verifica_operador_presoc IN h_b1wgen0091 (INPUT  glb_cdcooper,
                                                 INPUT  glb_cdoperad,
                                                 INPUT  glb_nmoperad,
                                                 INPUT  YES,
                                                 OUTPUT TABLE tt-mensagens).

   DELETE PROCEDURE h_b1wgen0091.

   IF   RETURN-VALUE = "NOK"  THEN
        DO:
            HIDE MESSAGE NO-PAUSE.

            FOR EACH tt-mensagens BY tt-mensagens.nrseqmsg:
                MESSAGE tt-mensagens.dsmensag.
            END.

            READKEY PAUSE 2.
            HIDE MESSAGE NO-PAUSE.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                     /* Volta para o menu */
                     glb_nmdatela = "".
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   
   DISABLE tel_datadlog tel_cdagenci WITH FRAME f_presoc.
   
   HIDE    tel_datadlog tel_cdagenci IN FRAME f_presoc.
   
   tel_cdagenci = 0.

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE glb_cddopcao WITH FRAME f_presoc.
      LEAVE.
   END.

   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "presoc"   THEN
                 DO:
                     HIDE FRAME f_presoc.
                     RUN sistema/generico/procedures/b1wgen0091.p 
                                          PERSISTENT SET h_b1wgen0091.

                     RUN verifica_operador_presoc IN h_b1wgen0091 
                                                 (INPUT  glb_cdcooper,
                                                  INPUT  glb_cdoperad,
                                                  INPUT  glb_nmoperad,
                                                  INPUT  NO,
                                                  OUTPUT TABLE tt-mensagens).
                    
                     DELETE PROCEDURE h_b1wgen0091.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END. 

   IF  glb_cddopcao = "H"  AND 
       NOT CAN-DO(20,glb_cddepart)/*TI*/  THEN 
       DO:
           BELL.
           MESSAGE "Operador sem autorizacao para alterar horario".
           
           PAUSE 2 NO-MESSAGE.
           RETURN.
       END.

   /* HELP dinamico para o PA */
   IF   glb_cddopcao = "H"   THEN
        tel_cdagenci:HELP = "Informe o numero do PA para alterar o horario.".
   ELSE
        tel_cdagenci:HELP = "Informe o numero do PA ou pressione <ENTER> " +
                            "p/ todos.".
   
   IF   glb_cddopcao = "L"   THEN
        DO:
            DISPLAY tel_datadlog WITH FRAME f_presoc.
            ENABLE tel_datadlog WITH FRAME f_presoc.
        END.
   
   IF   NOT glb_cddopcao = "R"   THEN
        UPDATE tel_cdagenci WITH FRAME f_presoc.
             
   ASSIGN tel_datadlog.
   
   IF   glb_cddopcao = "L"   THEN
        DO:
            RUN opcao_l.
            NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "H"   THEN
        DO:
            IF   tel_cdagenci = 0   THEN
                 MESSAGE "O PA deve ser escolhido.".
            ELSE
                 RUN opcao_h.
                 
            NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "R"    THEN
        DO:
            EMPTY TEMP-TABLE tt-arquivos.
            
            tel_cddopcao = TRUE.

            RUN sistema/generico/procedures/b1wgen0091.p 
                                          PERSISTENT SET h_b1wgen0091.

            RUN verifica_arquivos_relatorio_processamento IN h_b1wgen0091 (
                OUTPUT TABLE tt-arquivos).

            DELETE PROCEDURE h_b1wgen0091.

            OPEN QUERY q_bancoob FOR EACH tt-arquivos NO-LOCK.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_bancoob WITH FRAME f_bancoob.
               LEAVE.
            END.
            
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 NOT AVAILABLE tt-arquivos            THEN
                 NEXT.
            
            aux_nmarqimp = "rl/" + tt-arquivos.nmarquiv.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
            
                IF   tel_cddopcao   THEN
                     RUN fontes/visrel.p(INPUT aux_nmarqimp).
                ELSE
                     DO:

                        FIND FIRST crapass WHERE 
                             crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
                        
                        glb_nmformul = "132col".
                        { includes/impressao.i }
                     END.
                              
                LEAVE.

            END. /* Fim do DO WHILE TRUE */
        
        END.  /* Fim da Opcao "R" */
                   
END.  /* fim DO WHILE TRUE */

PROCEDURE opcao_l:

    FORM tt-log-process.dslinlog
         WITH 12 DOWN ROW 8 OVERLAY WIDTH 80 NO-LABELS CENTERED
              TITLE " Log em " + STRING(tel_datadlog,"99/99/9999") + " "
              FRAME f_opcao_l.

    RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h_b1wgen0091.

    RUN consulta_log_processamento IN h_b1wgen0091 (INPUT  glb_cdcooper,
                                                    INPUT  0,
                                                    INPUT  0,
                                                    INPUT  glb_cdcooper,
                                                    INPUT  tel_cdagenci,
                                                    INPUT  tel_datadlog,
                                                    OUTPUT TABLE tt-log-process,
                                                    OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h_b1wgen0091.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
    
            RETURN "NOK".
        END.

    FOR EACH tt-log-process BY tt-log-process.cdcooper 
                            BY tt-log-process.cdagenci
                            BY tt-log-process.dslinlog:
        DISPLAY tt-log-process.dslinlog WITH FRAME f_opcao_l.
        DOWN WITH FRAME f_opcao_l.                
    END.

    IF   NOT CAN-FIND(FIRST tt-log-process)   THEN
         MESSAGE "Nao ha registro de arquivos para a data informada.".
    
END PROCEDURE. /* Fim opcao_l */

PROCEDURE opcao_h:
    
    DEF VAR tel_hrfimpag    AS INT                                  NO-UNDO.
    DEF VAR tel_mmfimpag    AS INT                                  NO-UNDO.
    DEF VAR h-b1wgen0091    AS HANDLE                               NO-UNDO.
    
    FORM tel_hrfimpag FORMAT "99"
                      LABEL "Limite para pagamento de beneficios"
                      HELP "Entre com a hora limite (0 a 23)."
                      VALIDATE(tel_hrfimpag >= 0   AND
                               tel_hrfimpag <= 23,
                               "687 - Horario errado.")
         ":"                        AT 40
         tel_mmfimpag FORMAT "99"   AT 41
                      HELP "Entre com os minutos (0 a 59)."
                      VALIDATE(tel_mmfimpag >= 0   AND
                               tel_mmfimpag <= 59,
                               "687 - Horario errado.")
         "Horas"
         WITH ROW 13 CENTERED NO-BOX NO-LABELS SIDE-LABELS OVERLAY
              FRAME f_horario.
         
    
    DO  TRANSACTION ON ENDKEY UNDO, LEAVE:
        
        RUN sistema/generico/procedures/b1wgen0091.p 
            PERSISTENT SET h-b1wgen0091.

        RUN consulta_horario IN h-b1wgen0091 ( INPUT glb_cdcooper, 
                                               INPUT tel_cdagenci, 
                                               INPUT 0,
                                               OUTPUT tel_hrfimpag,
                                               OUTPUT tel_mmfimpag,
                                               OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0091.

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
    
            RETURN "NOK".
        END.

        UPDATE tel_hrfimpag
               tel_mmfimpag
               WITH FRAME f_horario.                    
        
        /* pede confirmacao */
        RUN fontes/confirma.p (INPUT "",
                               OUTPUT aux_confirma).
        IF   aux_confirma <> "S"   THEN       
            RETURN.

        RUN sistema/generico/procedures/b1wgen0091.p 
            PERSISTENT SET h-b1wgen0091.

        RUN altera_horario IN h-b1wgen0091 ( INPUT  glb_cdcooper,
                                             INPUT  tel_cdagenci,
                                             INPUT  0,
                                             INPUT  tel_hrfimpag,
                                             INPUT  tel_mmfimpag,
                                             INPUT  glb_dtmvtolt,
                                             INPUT  glb_cdoperad,
                                             OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0091.

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-erro THEN
                DO:
                    BELL.
                    MESSAGE tt-erro.dscritic.
                END.
    
            RETURN "NOK".
        END.

    END.

    RETURN "OK".

END PROCEDURE. /* Fim opcao_h */

/* .......................................................................... */

