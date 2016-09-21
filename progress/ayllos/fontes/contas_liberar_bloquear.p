/* .............................................................................
 
   Programa: fontes/contas_liberar_bloquear.p
   Sitema  : Cooperados - Cooperativa de Credito
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Dezembro/2014                       Ultima Atualizacao: 05/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (On-Line).
   Objetivo  : Efetuar manutencao para liberar ou bloquear.

   Alteracoes: 05/01/2016 - Adicionado campo libera credito pre-aprovado, 
                            flgcrdpa (Anderson).
............................................................................. */
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/b1wgen0188tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR reg_dsdopcao AS CHAR FORMAT "x(07)" INIT "Alterar"             NO-UNDO.
DEF VAR tel_flgrenli    LIKE crapass.flgrenli   FORMAT "Sim/Nao"       NO-UNDO.
DEF VAR tel_flgcrdpa    LIKE crapass.flgcrdpa   FORMAT "Sim/Nao"       NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_libcrdpa AS LOGICAL                                        NO-UNDO.

DEF VAR h-b1wgen0193 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0188 AS HANDLE                                         NO-UNDO.

FORM SKIP(1)
     tel_flgrenli AT 2 LABEL "Renova Limite Credito Automatico"
                       HELP "(S)Sim para Renovar ou (N)Nao para nao Renovar"
     tel_flgcrdpa AT 7 LABEL "Libera Credito Pre-Aprovado"
                       HELP "(S)Sim para Liberar ou (N)Nao para Bloquear"
     SKIP(3)                              
     reg_dsdopcao AT 37 NO-LABEL
         HELP "Pressione ENTER para selecionar ou F4/END para sair"
     WITH ROW 9 WIDTH 80 OVERLAY SIDE-LABELS  TITLE " DESABILITAR OPERACOES " 
             CENTERED FRAME f_liberar_bloquear.

ON LEAVE OF tel_flgcrdpa IN FRAME f_liberar_bloquear DO:

    /* Liberacao Credito Pre Aprovado */
    ASSIGN INPUT tel_flgcrdpa.

    IF tel_flgcrdpa = YES THEN
    DO:
        /* Verifica se o Cooperado possui Credito Pre Aprovado */
        IF  NOT VALID-HANDLE(h-b1wgen0188) THEN
            RUN sistema/generico/procedures/b1wgen0188.p 
                PERSISTENT SET h-b1wgen0188.
    
        RUN busca_dados IN h-b1wgen0188 (INPUT glb_cdcooper,
                                         INPUT 0, /* cdagenci */
                                         INPUT 0, /* nrdcaixa */
                                         INPUT glb_cdoperad,
                                         INPUT glb_nmdatela,
                                         INPUT 1, /* idorigem */
                                         INPUT tel_nrdconta,
                                         INPUT tel_idseqttl,
                                         INPUT 0, /* nrcpfope */
                                         OUTPUT TABLE tt-dados-cpa,
                                         OUTPUT TABLE tt-erro).

        FIND tt-dados-cpa NO-LOCK NO-ERROR.

        IF NOT AVAIL tt-dados-cpa OR tt-dados-cpa.vldiscrd <= 0 THEN
           DO:
               MESSAGE "Alteracao nao permitida. " + 
                       "Cooperado nao possui Credito Pre-Aprovado.".
               RETURN NO-APPLY.
           END.
        
        IF  VALID-HANDLE(h-b1wgen0188) THEN
            DELETE PROCEDURE h-b1wgen0188.
    END.
END.
        
PRINCIPAL:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF NOT VALID-HANDLE(h-b1wgen0193) THEN
      RUN sistema/generico/procedures/b1wgen0193.p 
          PERSISTENT SET h-b1wgen0193.

   RUN busca_dados IN h-b1wgen0193 (INPUT glb_cdcooper, 
                                    INPUT 0,            
                                    INPUT 0,            
                                    INPUT glb_cdoperad, 
                                    INPUT glb_nmdatela, 
                                    INPUT 1,            
                                    INPUT tel_nrdconta, 
                                    INPUT glb_dtmvtolt,
                                    INPUT tel_idseqttl,            
                                   OUTPUT tel_flgrenli,
                                   OUTPUT tel_flgcrdpa,
                                   OUTPUT aux_libcrdpa,
                                   OUTPUT TABLE tt-erro).

   IF RETURN-VALUE = "NOK"  THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF AVAILABLE tt-erro  THEN
             DO:
                 BELL.
                 MESSAGE tt-erro.dscritic.
             END.
   
          LEAVE PRINCIPAL.
      END.
      
   DISPLAY tel_flgrenli
           tel_flgcrdpa
           reg_dsdopcao
           WITH FRAME f_liberar_bloquear NO-ERROR.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       CHOOSE FIELD reg_dsdopcao WITH FRAME f_liberar_bloquear.
       LEAVE.

   END.
   
   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       LEAVE PRINCIPAL.
           
   ASSIGN glb_nmrotina = "DESABILITAR OPERACOES"
          glb_cddopcao = "A".
                                      
   { includes/acesso.i }

   HIDE MESSAGE NO-PAUSE.
                                      
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
      UPDATE tel_flgrenli
             tel_flgcrdpa WHEN aux_libcrdpa = YES
             WITH FRAME f_liberar_bloquear.
      LEAVE.
   
   END.  /** DO WHILE TRUE **/  

   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       NEXT PRINCIPAL.

   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).
   
   IF  aux_confirma <> "S"  THEN
       NEXT PRINCIPAL.        
   
   RUN grava_dados IN h-b1wgen0193(INPUT glb_cdcooper,
                                   INPUT 0,           
                                   INPUT 0,           
                                   INPUT glb_cdoperad,
                                   INPUT glb_nmdatela,
                                   INPUT 1,           
                                   INPUT tel_nrdconta,
                                   INPUT glb_dtmvtolt,
                                   INPUT tel_idseqttl,
                                   INPUT tel_flgrenli,
                                   INPUT tel_flgcrdpa,
                                   INPUT TRUE, /* par_flgerlog */
                                   OUTPUT TABLE tt-erro).
                                                     
   IF RETURN-VALUE = "NOK"  THEN 
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF AVAILABLE tt-erro  THEN 
             DO:
                 BELL.
                 MESSAGE tt-erro.dscritic.
             END.

          NEXT PRINCIPAL.
      END.
   
   IF VALID-HANDLE(h-b1wgen0193) THEN
      DELETE PROCEDURE h-b1wgen0193.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT PRINCIPAL.
   
   BELL.
   MESSAGE "Alteracao efetuada com sucesso!".
   PAUSE 2 NO-MESSAGE.
   HIDE MESSAGE NO-PAUSE.
   NEXT PRINCIPAL.
    
END. /** Fim DO WHILE TRUE **/

                      
HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_liberar_bloquear NO-PAUSE.

IF VALID-HANDLE(h-b1wgen0193) THEN
   DELETE PROCEDURE h-b1wgen0193.
IF VALID-HANDLE(h-b1wgen0188) THEN
   DELETE PROCEDURE h-b1wgen0188.

 
    

/*............................................................................*/
