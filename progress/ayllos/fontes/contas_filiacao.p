/* ............................................................................

   Programa: fontes/contas_filiacao.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                         Ultima Atualizacao: 22/09/2010
  
   Dados referentes ao programa:
     
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados - FILIACAO.
           
   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               13/01/2010 - Adaptacao para uso de BO (Jose Luis-DB1), task 119
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel, DB1).
.............................................................................*/

{ sistema/generico/includes/b1wgen0054tt.i}
{ sistema/generico/includes/var_internet.i}
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR tel_nmpaittl LIKE crapttl.nmpaittl                             NO-UNDO.
DEF VAR tel_nmmaettl LIKE crapttl.nmmaettl                             NO-UNDO.
DEF VAR reg_dsdopcao AS CHAR INIT "Alterar" FORMAT "x(07)"             NO-UNDO.
DEF VAR aux_nmdcampo AS CHARACTER                                      NO-UNDO.
DEF VAR aux_flgsuces AS LOGICAL                                        NO-UNDO.
DEF VAR h-b1wgen0054 AS HANDLE                                         NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                      NO-UNDO.
DEF VAR aux_msgalert AS CHARACTER                                      NO-UNDO.

FORM SKIP(1)
     tel_nmmaettl  AT 01  FORMAT "x(40)"
                          LABEL "Nome da mae"
                          HELP "Informe o nome da mae do titular"
                          VALIDATE(tel_nmmaettl <> "",
                                   "375 - O campo deve ser preenchido.")
     SKIP(1)                   
     tel_nmpaittl  AT 01  FORMAT "x(40)"
                          LABEL "Nome do pai"
                          HELP "Informe o nome do pai do titular"
     SKIP(1)
     reg_dsdopcao  AT 24  NO-LABEL
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 14 OVERLAY SIDE-LABELS TITLE " FILIACAO " CENTERED
                      FRAME f_filiacao.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  NOT VALID-HANDLE(h-b1wgen0054)  THEN
        RUN sistema/generico/procedures/b1wgen0054.p 
            PERSISTENT SET h-b1wgen0054.
    
    RUN Busca_Dados IN h-b1wgen0054 (INPUT glb_cdcooper, 
                                     INPUT 0,            
                                     INPUT 0,            
                                     INPUT glb_cdoperad, 
                                     INPUT glb_nmdatela, 
                                     INPUT 1,            
                                     INPUT tel_nrdconta, 
                                     INPUT tel_idseqttl, 
                                     INPUT YES, 
                                    OUTPUT aux_msgconta,
                                    OUTPUT TABLE tt-filiacao,
                                    OUTPUT TABLE tt-erro) NO-ERROR.

    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
 
            IF  AVAILABLE tt-erro  THEN
                MESSAGE tt-erro.dscritic.
                   
            LEAVE.
        END.
 
    FIND FIRST tt-filiacao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE tt-filiacao  THEN
        DO:
            MESSAGE "Nao foi possivel obter os dados da filiacao".
            LEAVE.
        END.

    ASSIGN tel_nmpaittl = tt-filiacao.nmpaittl
           tel_nmmaettl = tt-filiacao.nmmaettl.
 
    DISPLAY tel_nmpaittl tel_nmmaettl reg_dsdopcao WITH FRAME f_filiacao.
 
    CHOOSE FIELD reg_dsdopcao WITH FRAME f_filiacao.

    IF   FRAME-FIELD = "reg_dsdopcao"   THEN
         DO ON ENDKEY UNDO, NEXT:

            IF  aux_msgconta <> "" THEN
                DO:
                   MESSAGE aux_msgconta. 
                   NEXT.
                END.

            ASSIGN glb_nmrotina = "FILIACAO"
                   glb_cddopcao = "A".

            { includes/acesso.i } 

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_nmmaettl  tel_nmpaittl  WITH FRAME f_filiacao
               EDITING:

                   READKEY.
                   
                   APPLY LASTKEY.

                   IF  GO-PENDING THEN
                       DO:
                           RUN Valida_Dados IN h-b1wgen0054 
                                           (INPUT glb_cdcooper, 
                                            INPUT 0,            
                                            INPUT 0,            
                                            INPUT glb_cdoperad, 
                                            INPUT glb_nmdatela, 
                                            INPUT 1,            
                                            INPUT tel_nrdconta, 
                                            INPUT tel_idseqttl, 
                                            INPUT YES, 
                                            INPUT INPUT tel_nmmaettl,
                                            INPUT INPUT tel_nmpaittl,
                                           OUTPUT aux_nmdcampo,
                                           OUTPUT TABLE tt-erro).

                           IF  RETURN-VALUE <> "OK" THEN
                               DO:
                                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                                   IF  AVAILABLE tt-erro THEN
                                       MESSAGE tt-erro.dscritic.

                                   {sistema/generico/includes/foco_campo.i 
                                      &VAR-GERAL=SIM
                                      &NOME-FRAME="f_filiacao" 
                                      &NOME-CAMPO=aux_nmdcampo }
                               END.
                       END.

               END.  /*  Fim do EDITING  */

               LEAVE.

            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                 NEXT.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               glb_cdcritic = 0.
               MESSAGE COLOR NORMAL glb_dscritic
               UPDATE aux_confirma.
               LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S"                  THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 2 NO-MESSAGE.
                     HIDE MESSAGE NO-PAUSE.
                     UNDO, NEXT.
                 END.

            IF  VALID-HANDLE(h-b1wgen0054) THEN
                DELETE OBJECT h-b1wgen0054.

            RUN sistema/generico/procedures/b1wgen0054.p 
                PERSISTENT SET h-b1wgen0054.
            
            RUN Grava_Dados IN h-b1wgen0054 (INPUT glb_cdcooper, 
                                             INPUT 0,            
                                             INPUT 0,            
                                             INPUT glb_cdoperad, 
                                             INPUT glb_nmdatela, 
                                             INPUT 1,            
                                             INPUT tel_nrdconta, 
                                             INPUT tel_idseqttl, 
                                             INPUT YES, 
                                             INPUT tel_nmmaettl,
                                             INPUT tel_nmpaittl,
                                             INPUT glb_cddopcao,
                                             INPUT glb_dtmvtolt,
                                            OUTPUT aux_msgalert,
                                            OUTPUT aux_tpatlcad,
                                            OUTPUT aux_msgatcad,
                                            OUTPUT aux_chavealt,
                                            OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        MESSAGE tt-erro.dscritic.

                    NEXT.
                 END.

            /* verificar se é necessario registrar o crapalt */
            RUN proc_altcad (INPUT "b1wgen0054.p").

            IF  VALID-HANDLE(h-b1wgen0054) THEN
                DELETE OBJECT h-b1wgen0054.

            IF  aux_msgalert <> "" THEN
                MESSAGE aux_msgalert.

         END. /* Fim TRANSACTION */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S"                  THEN
         NEXT.
    ELSE
         DO:
             aux_flgsuces = YES.
             LEAVE.
         END.
        
END. /* Fim do DO WHILE TRUE */

IF  VALID-HANDLE(h-b1wgen0054) THEN
    DELETE OBJECT h-b1wgen0054.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         LEAVE.
     END.

HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_filiacao NO-PAUSE.
RETURN.
/* ......................................................................... */
