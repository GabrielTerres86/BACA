/* .............................................................................

   Programa: fontes/contas_financeiro_faturamento.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                   Ultima Atualizacao: 09/10/2012
   
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados financeiros - FATURAMENTO.

   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               14/07/2009 - Alteracao CDOPERAD (Diego).

               29/07/2009 - Ajuste para permitir cadastrar menos de 12 fatura-
                            mentos, permitir faturamentos com valores negativos
                            e zerados.
                            Inserido Browse para a visualizacao do EXTENT
                            (Fernando).
                            
               17/05/2010 - Adaptado para uso de BO (Jose Luis, DB1)
               
               09/10/2012 - Ajustado layout do FRAME "f_regua". (Daniel)

..............................................................................*/

{ sistema/generico/includes/b1wgen0069tt.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF         VAR tel_mesftbru AS INT  FORMAT "z9"                    NO-UNDO.
DEF         VAR tel_anoftbru AS INT  FORMAT "zzz9"                  NO-UNDO.
DEF         VAR tel_vlrftbru AS DECI FORMAT "-zzz,zzz,zz9.99"       NO-UNDO.
DEF         VAR tel_cdopejfn AS CHAR FORMAT "x(10)"                 NO-UNDO.
DEF         VAR tel_nmoperad AS CHAR FORMAT "x(13)"                 NO-UNDO.
DEF         VAR tel_dtaltjfn AS DATE FORMAT "99/99/9999"            NO-UNDO.

DEF         VAR aux_nrposext AS INT                                 NO-UNDO.
DEF         VAR aux_nrdlinha AS INT                                 NO-UNDO.
DEF         VAR aux_nrdrowid AS ROWID                               NO-UNDO.
DEF         VAR h-b1wgen0069 AS HANDLE                              NO-UNDO.
DEF         VAR reg_contador AS INT                   INIT 3        NO-UNDO.
DEF         VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                                    "Excluir",
                                                    "Incluir"]      NO-UNDO.
DEF         VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]    NO-UNDO.

DEF QUERY q_faturament FOR tt-faturam.
    
DEF BROWSE b_fatura QUERY q_faturament
    DISPLAY tt-faturam.mesftbru COLUMN-LABEL "Mes"         FORMAT "z9"
            tt-faturam.anoftbru COLUMN-LABEL "Ano"         FORMAT "zzz9"
            tt-faturam.vlrftbru COLUMN-LABEL "Faturamento" FORMAT 
                                                           "-zzz,zzz,zz9.99"
            WITH 4 DOWN SCROLLBAR-VERTICAL NO-BOX.

FORM SKIP(7)
     tel_dtaltjfn   LABEL " Alterado"               
     "-"
     tel_cdopejfn   LABEL " Operador" FORMAT "xxxxxxxxxx" AT 24
     tel_nmoperad   NO-LABEL                              AT 46
     
     SKIP(1)
     reg_dsdopcao[1]  AT 12  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 25  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 38  NO-LABEL FORMAT "x(7)"
     WITH ROW 10 WIDTH 61 CENTERED OVERLAY SIDE-LABELS TITLE 
     " FATURAMENTO " FRAME f_regua.

FORM 
     b_fatura 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 11 COLUMN 30 CENTERED OVERLAY NO-BOX FRAME f_browse.

FORM
    SKIP(1)
    tel_mesftbru  LABEL "Mes"   AT 12
        HELP "Informe o mes do faturamento."
        VALIDATE(tel_mesftbru > 0 AND tel_mesftbru < 13, "013 - Data errada.")
    SKIP
    tel_anoftbru  LABEL "Ano"   AT 12
        HELP "Informe o ano do faturamento."
        VALIDATE(tel_anoftbru >= 1000 AND tel_anoftbru <= YEAR(glb_dtmvtolt), 
                 "013 - Data errada.")
    SKIP
    tel_vlrftbru  LABEL "Faturamento"  AT 12
        HELP "Informe o faturamento."
    WITH ROW 12 WIDTH 50 CENTERED SIDE-LABELS OVERLAY NO-BOX 
         FRAME f_faturamentos.
          
ON ANY-KEY OF b_fatura IN FRAME f_browse DO:

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 3   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 3.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
        DO:
           IF   AVAILABLE tt-faturam   THEN
                DO:
                    ASSIGN aux_nrdrowid = tt-faturam.nrdrowid
                           aux_nrposext = tt-faturam.nrposext
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_faturament").
                         
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_fatura:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_nrposext = 0
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.

ASSIGN glb_cddopcao = "I".

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0069) THEN
       RUN sistema/generico/procedures/b1wgen0069.p
           PERSISTENT SET h-b1wgen0069.

   ASSIGN aux_nrdrowid = ?
          aux_nrposext = 0.

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

   DISPLAY reg_dsdopcao tel_dtaltjfn tel_cdopejfn tel_nmoperad 
           WITH FRAME f_regua. 
   
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
      
   OPEN QUERY q_faturament FOR EACH tt-faturam WHERE 
                                    tt-faturam.anoftbru <> 0 AND
                                    tt-faturam.mesftbru <> 0
                                    NO-LOCK BY tt-faturam.anoftbru DESC
                                            BY tt-faturam.mesftbru DESC.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_fatura WITH FRAME f_browse.
      LEAVE.
   END.

   IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.

   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_faturament TO ROW(aux_nrdlinha).
   
   { includes/acesso.i }
   
   IF   glb_cddopcao = "I"   THEN
        DO:
           ASSIGN tel_mesftbru = 0
                  tel_anoftbru = 0
                  tel_vlrftbru = 0
                  aux_nrposext = 0.
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
              HIDE FRAME f_browse.
              UPDATE tel_mesftbru tel_anoftbru tel_vlrftbru 
                     WITH FRAME f_faturamentos.

              RUN Valida_Dados.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.

              RUN confirma.
              
              IF   aux_confirma <> "S"  THEN
                   LEAVE.
              ELSE 
                   DO:
                      RUN Grava_Dados.
    
                      IF  RETURN-VALUE <> "OK" THEN
                          NEXT.
                   END.

              MESSAGE "Inclusao efetuada com sucesso.".
              PAUSE 2 NO-MESSAGE.

              LEAVE.
           END. /* Fim do DO WHILE TRUE - TRANSACTION */
        
           NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "A"   THEN
        DO:
           IF   aux_nrdrowid <> ?   THEN
                DO:
                   ASSIGN tel_mesftbru = tt-faturam.mesftbru
                          tel_anoftbru = tt-faturam.anoftbru
                          tel_vlrftbru = tt-faturam.vlrftbru.
                    
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                      HIDE FRAME f_browse.
                      
                      UPDATE tel_mesftbru tel_anoftbru tel_vlrftbru
                             WITH FRAME f_faturamentos.
                   
                      RUN Valida_Dados.

                      IF  RETURN-VALUE <> "OK" THEN
                          NEXT.

                      RUN confirma.
                    
                      IF   aux_confirma <> "S"   THEN
                           LEAVE.
                      ELSE 
                           DO:
                              RUN Grava_Dados.
    
                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.
                           END.
                      
                      MESSAGE "Alteracao efetuada com sucesso.".
                      PAUSE 2 NO-MESSAGE.

                      LEAVE.
                   END. /* Fim do DO WHILE TRUE - TRANSACTION */
                END.
               
           NEXT.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
           IF   aux_nrdrowid <> ?   THEN
                DO:
                   RUN confirma.
                   
                   IF   aux_confirma <> "S"   THEN
                        NEXT.
                   ELSE 
                        DO:
                           RUN Grava_Dados.

                           IF  RETURN-VALUE <> "OK" THEN
                               NEXT.
                        END.
                
                   MESSAGE "Exclusao efetuada com sucesso.".
                   PAUSE 2 NO-MESSAGE.
                
                END.

           NEXT.
        END.
END. /* Fim do DO WHILE TRUE */

IF  VALID-HANDLE(h-b1wgen0069) THEN
    DELETE OBJECT h-b1wgen0069.

HIDE MESSAGE NO-PAUSE.

/*.................................PROCEDURES................................*/

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0069
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT aux_nrposext,
         OUTPUT TABLE tt-faturam,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    FIND FIRST tt-faturam NO-ERROR.

    IF  AVAILABLE tt-faturam THEN
        ASSIGN
           tel_dtaltjfn = tt-faturam.dtaltjfn
           tel_cdopejfn = tt-faturam.cdoperad
           tel_nmoperad = tt-faturam.nmoperad.

    RETURN "OK".
END.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0069
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
          INPUT tel_vlrftbru,
          INPUT tel_mesftbru,
          INPUT tel_anoftbru,
          INPUT aux_nrposext,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".
END.

PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0069) THEN
        DELETE OBJECT h-b1wgen0069.

    RUN sistema/generico/procedures/b1wgen0069.p PERSISTENT SET h-b1wgen0069.

    RUN Grava_Dados IN h-b1wgen0069
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT tel_vlrftbru,
          INPUT tel_mesftbru,
          INPUT tel_anoftbru,
          INPUT aux_nrposext,
          INPUT aux_nrdrowid,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0069.p").

    IF  VALID-HANDLE(h-b1wgen0069) THEN
        DELETE OBJECT h-b1wgen0069.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    RETURN "OK".
END.

PROCEDURE confirma.

   /* Confirma */
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         ASSIGN aux_confirma = "N"
         glb_cdcritic = 78.
         RUN fontes/critic.p.
         glb_cdcritic = 0.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */
      
     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
          DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             MESSAGE glb_dscritic.
             PAUSE 2 NO-MESSAGE.
          END. /* Mensagem de confirmacao */
                                
END PROCEDURE.
/* ......................................................................... */
