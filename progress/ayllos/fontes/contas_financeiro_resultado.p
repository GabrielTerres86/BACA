/* .............................................................................

   Programa: fontes/contas_financeiro_resultado.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                         Ultima Atualizacao: 30/04/2010

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados financeiros - RESULTADO.

   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               30/04/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
..............................................................................*/

{ sistema/generico/includes/b1wgen0068tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF         VAR tel_vlrctbru LIKE crapjfn.vlrctbru                  NO-UNDO.
DEF         VAR tel_vlctdpad LIKE crapjfn.vlctdpad                  NO-UNDO.
DEF         VAR tel_vldspfin LIKE crapjfn.vldspfin                  NO-UNDO.
DEF         VAR tel_ddprzrec LIKE crapjfn.ddprzrec                  NO-UNDO.
DEF         VAR tel_ddprzpag LIKE crapjfn.ddprzpag                  NO-UNDO.
DEF         VAR tel_dtaltjfn AS DATE FORMAT "99/99/9999"            NO-UNDO.
DEF         VAR tel_cdopejfn AS CHAR FORMAT "x(10)"                 NO-UNDO.
DEF         VAR tel_nmoperad AS CHAR FORMAT "x(14)"                 NO-UNDO.

DEF         VAR reg_dsdopcao AS CHAR FORMAT "x(07)" INIT "Alterar"  NO-UNDO.

DEF         VAR aux_flgsuces AS LOGICAL                             NO-UNDO.
DEF         VAR h-b1wgen0068 AS HANDLE                              NO-UNDO.


FORM SKIP 
"--------- Contas de Resultado dos Ultimos 12 Meses (Valores em R$) -----------"
     SKIP
     tel_vlrctbru  AT 18   LABEL "Receita Bruta de Vendas"
                   HELP "Informe o valor da receita bruta de vendas"
     SKIP
     tel_vlctdpad  AT 01   LABEL "Custos e Despesas Administrativas/Vendas"
           HELP "Informe somatorio dos custos e despesas administrativas/vendas"
     SKIP
     tel_vldspfin  AT 21   LABEL "Despesas Financeiras"
                   HELP "Informe o valor de despesas financeiras"
     SKIP
"------------------------ Prazos Medios (Em Dias) -----------------------------"
     SKIP
     tel_ddprzrec  AT 29   LABEL "Recebimentos"
                   HELP "Informe em dias o prazo para recebimentos"
     SKIP
     tel_ddprzpag  AT 31   LABEL "Pagamentos"
                   HELP "Informe em dias o prazo de pagamentos"
     SKIP(1)
     "Dados Resultado =>"
     tel_dtaltjfn          LABEL " Alterado"
     tel_cdopejfn          LABEL " Operador"
     tel_nmoperad
     SKIP(1)
     reg_dsdopcao  AT 35   NO-LABEL
                   HELP "Pressione ENTER para selecionar / F4 ou END para sair"
     WITH ROW 09 OVERLAY SIDE-LABELS NO-LABELS
          TITLE " RESULTADO " CENTERED FRAME f_financeiro_resultado.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    IF  NOT VALID-HANDLE(h-b1wgen0068) THEN
        RUN sistema/generico/procedures/b1wgen0068.p 
            PERSISTENT SET h-b1wgen0068.

    RUN Busca_Dados IN h-b1wgen0068
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
         OUTPUT TABLE tt-resultado,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  LEAVE.
               END.
        END.

    FIND FIRST tt-resultado NO-ERROR.

    IF  NOT AVAILABLE tt-resultado THEN
        DO:
           MESSAGE "Nao foi possivel obter os dados das REGISTRO do associado".
           LEAVE.
        END.

   ASSIGN aux_flgsuces = NO.
   
   ASSIGN
       tel_vlrctbru = tt-resultado.vlrctbru
       tel_vlctdpad = tt-resultado.vlctdpad  
       tel_vldspfin = tt-resultado.vldspfin
       tel_ddprzrec = tt-resultado.ddprzrec 
       tel_ddprzpag = tt-resultado.ddprzpag  
       tel_cdopejfn = tt-resultado.cdoperad
       tel_nmoperad = tt-resultado.nmoperad 
       tel_dtaltjfn = tt-resultado.dtaltjfn.
   
   DISPLAY  tel_vlrctbru   tel_vlctdpad    tel_vldspfin
            tel_ddprzrec   tel_ddprzpag    tel_cdopejfn
            tel_nmoperad   tel_dtaltjfn    reg_dsdopcao
            WITH FRAME f_financeiro_resultado.
             
   CHOOSE FIELD reg_dsdopcao WITH FRAME f_financeiro_resultado.

   IF  FRAME-FIELD = "reg_dsdopcao"   THEN
       DO TRANSACTION ON ENDKEY UNDO, LEAVE:
          ASSIGN glb_nmrotina = "FINANCEIRO-RESULTADO"
                 glb_cddopcao = "A".
          
          { includes/acesso.i }

          UPDATE  tel_vlrctbru   tel_vlctdpad    tel_vldspfin
                  tel_ddprzrec   tel_ddprzpag 
                  WITH FRAME f_financeiro_resultado
          EDITING:

              READKEY.
              HIDE MESSAGE NO-PAUSE.

              IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                   UNDO, LEAVE.
              ELSE
                   APPLY LASTKEY.

          END.  /*  Fim do EDITING  */

          DISPLAY  tel_vlrctbru   tel_vlctdpad    tel_vldspfin
                   tel_ddprzrec   tel_ddprzpag    tel_cdopejfn
                   tel_nmoperad   tel_dtaltjfn
                   WITH FRAME f_financeiro_resultado.

          RUN Valida_Dados IN h-b1wgen0068
              ( INPUT glb_cdcooper, 
                INPUT 0,            
                INPUT 0,            
                INPUT glb_cdoperad, 
                INPUT glb_nmdatela, 
                INPUT 1,            
                INPUT tel_nrdconta, 
                INPUT tel_idseqttl, 
                INPUT YES,
                INPUT glb_dtmvtolt,
                INPUT glb_cddopcao,
                INPUT tel_vlrctbru,
                INPUT tel_vlctdpad,
                INPUT tel_vldspfin,
                INPUT tel_ddprzrec,
                INPUT tel_ddprzpag,
               OUTPUT TABLE tt-erro) .

          IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
              DO:
                 FIND FIRST tt-erro NO-ERROR.

                 IF  AVAILABLE tt-erro THEN
                     DO:
                        MESSAGE tt-erro.dscritic.
                        NEXT.
                     END.
              END.

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
                   UNDO, LEAVE.
               END.
          ELSE 
               DO:
                  IF  VALID-HANDLE(h-b1wgen0068) THEN
                      DELETE OBJECT h-b1wgen0068.

                  RUN sistema/generico/procedures/b1wgen0068.p 
                      PERSISTENT SET h-b1wgen0068.

                  RUN Grava_Dados IN h-b1wgen0068
                      ( INPUT glb_cdcooper, 
                        INPUT 0,            
                        INPUT 0,            
                        INPUT glb_cdoperad, 
                        INPUT glb_nmdatela, 
                        INPUT 1,            
                        INPUT tel_nrdconta, 
                        INPUT tel_idseqttl, 
                        INPUT TRUE,
                        INPUT glb_cddopcao,
                        INPUT glb_dtmvtolt,
                        INPUT tel_vlrctbru,
                        INPUT tel_vlctdpad,
                        INPUT tel_vldspfin,
                        INPUT tel_ddprzrec,
                        INPUT tel_ddprzpag,
                       OUTPUT aux_tpatlcad,
                       OUTPUT aux_msgatcad,
                       OUTPUT aux_chavealt,
                       OUTPUT TABLE tt-erro) .

                  IF  RETURN-VALUE <> "OK" OR 
                      TEMP-TABLE tt-erro:HAS-RECORDS THEN
                      DO:
                         FIND FIRST tt-erro NO-ERROR.

                         IF  AVAILABLE tt-erro THEN
                             DO:
                                MESSAGE tt-erro.dscritic.
                                NEXT.
                             END.
                      END.

                  /* verificar se é necessario registrar o crapalt */
                  RUN proc_altcad (INPUT "b1wgen0068.p").

                  IF  VALID-HANDLE(h-b1wgen0068) THEN
                      DELETE OBJECT h-b1wgen0068.

                  IF  RETURN-VALUE <> "OK" THEN
                      NEXT.
               END.
          
          LEAVE.
               
       END. /* Fim TRANSACTION */
       
   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
       aux_confirma <> "S"                  THEN
       NEXT.
   ELSE
       DO:
           aux_flgsuces = YES.
           LEAVE.
       END.
        
END.

HIDE MESSAGE NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0068) THEN
    DELETE OBJECT h-b1wgen0068.

IF   aux_flgsuces   THEN
     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         MESSAGE "Alteracao efetuada com sucesso!".
         PAUSE 2 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         LEAVE.
     END.

HIDE FRAME f_financeiro_resultado NO-PAUSE.

/* ..........................................................................*/
