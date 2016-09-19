/* .............................................................................

   Programa: fontes/contas_financeiro_bancos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Junho/2006                         Ultima Atualizacao: 08/04/2014

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados financeiros - BANCOS.

   Alteracoes:  14/07/2009 - Alteracao CDOPERAD (Diego).
   
                05/05/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
                
                08/04/2014 - Ajuste para esconder o frame f_zoom_bancos
                             corretamente (Adriano).
                             
..............................................................................*/

{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgen0067tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF         VAR tel_cddbanco AS INTEGER  FORMAT "zz9"               NO-UNDO.
DEF         VAR tel_dsdbanco AS CHAR     FORMAT "x(15)"             NO-UNDO.
DEF         VAR tel_dstipope AS CHAR     FORMAT "x(18)"             NO-UNDO.
DEF         VAR tel_vlropera AS DECIMAL  FORMAT "zzz,zzz,zz9.99"    NO-UNDO.
DEF         VAR tel_garantia AS CHAR     FORMAT "x(18)"             NO-UNDO.
DEF         VAR tel_dsvencto AS CHAR     FORMAT "x(12)"             NO-UNDO.
DEF         VAR tel_cdopejfn AS CHAR     FORMAT "x(10)"             NO-UNDO.
DEF         VAR tel_nmoperad AS CHAR     FORMAT "x(30)"             NO-UNDO.
DEF         VAR tel_dtaltjfn AS DATE     FORMAT "99/99/9999"        NO-UNDO.
DEF         VAR aux_cdopejfn AS CHAR     FORMAT "x(10)"             NO-UNDO.
DEF         VAR aux_nmoperad AS CHAR     FORMAT "x(14)"             NO-UNDO.
DEF         VAR aux_dtaltjfn AS DATE     FORMAT "99/99/9999"        NO-UNDO.

/* Variaveis para a regua de opcoes */
DEF         VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                                    "Excluir",
                                                    "Incluir"]      NO-UNDO.
DEF         VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]    NO-UNDO.
DEF         VAR reg_contador AS INT           INIT 1                NO-UNDO.

DEF         VAR aux_nrdrowid AS ROWID                               NO-UNDO.
DEF         VAR aux_nrdlinha AS INT                                 NO-UNDO.
DEF         VAR aux_seqbanco AS INT                                 NO-UNDO.
DEF         VAR h-b1wgen0067 AS HANDLE                              NO-UNDO.
DEF         VAR h-b1wgen0060 AS HANDLE                              NO-UNDO.
DEF         VAR h-b1wgen0059 AS HANDLE                              NO-UNDO.
DEF         VAR aux_dscritic AS CHAR                                NO-UNDO.

DEF QUERY q_bancos FOR tt-banco.

DEF BROWSE b_bancos QUERY q_bancos
    DISPLAY tt-banco.cddbanco FORMAT "zz9"   COLUMN-LABEL "Banco"
            tt-banco.dstipope FORMAT "x(18)" COLUMN-LABEL "Operacao"
            tt-banco.vlropera FORMAT "zzz,zzz,zz9.99" COLUMN-LABEL "Valor(R$)"
            tt-banco.garantia FORMAT "x(18)" COLUMN-LABEL "Garantia"
            tt-banco.dsvencto FORMAT "x(12)" COLUMN-LABEL "Vencimento"
            WITH 5 DOWN NO-BOX.
            
DEF QUERY  zoom_qbancos FOR tt-crapban.
DEF BROWSE zoom_bbancos QUERY zoom_qbancos
      DISP SPACE(5)
           tt-crapban.nmresbcc             COLUMN-LABEL "Nome Abreviado"
           SPACE(3)
           tt-crapban.cdbccxlt             COLUMN-LABEL "Codigo"
           SPACE(5)
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_zoom_bancos
          zoom_bbancos HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

FORM SKIP(1) 
     tel_cddbanco      AT 29  LABEL "Banco"      FORMAT "zz9"
                             HELP "Informe o numero do banco ou F7 para listar"
                             VALIDATE(tel_cddbanco <> 0,
                                      "375 - O campo deve ser preenchido.")
     tel_dsdbanco      AT 40  NO-LABEL
     SKIP
     tel_dstipope      AT 26  LABEL "Operacao"   FORMAT "x(18)"
             HELP "Informe o tipo de operacao realizada com a inst. financeira."
                              VALIDATE(tel_dstipope <> "",
                                       "375 - O campo deve ser preenchido.")
     SKIP
     tel_vlropera      AT 25  LABEL "Valor(R$)"  FORMAT "zzz,zzz,zz9.99"
                              HELP "Informe o valor da operacao financeira"
                              VALIDATE(tel_vlropera <> 0,
                                       "375 - O campo deve ser preenchido.")
     SKIP
     tel_garantia      AT 26  LABEL "Garantia"   FORMAT "x(18)"
                              HELP "Informe o tipo de garantia"
                              VALIDATE(tel_garantia <> "",
                                       "375 - O campo deve ser preenchido.")
     SKIP
     tel_dsvencto      AT 24  LABEL "Vencimento" FORMAT "x(10)"
         HELP "Informe o vencimento da operacao ou VARIOS para diversas datas"
     tel_cdopejfn      AT 26  LABEL "Operador"
     tel_nmoperad 
     tel_dtaltjfn      AT 30  LABEL "Data"
     SKIP(1)                                
     WITH ROW 10 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS NO-BOX NO-LABEL
              FRAME f_financeio_banco.

     
FORM SKIP(9)
     "     Dados Banco =>"
     aux_dtaltjfn  LABEL " Alterado"
     aux_cdopejfn  LABEL " Operador"
     aux_nmoperad
     SKIP(1)
     reg_dsdopcao[1]  AT 15  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 35  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 55  NO-LABEL FORMAT "x(7)"
     WITH ROW 8 WIDTH 80 OVERLAY SIDE-LABELS NO-LABELS 
          TITLE " BANCO " FRAME f_regua.

FORM b_bancos HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 10 COLUMN 5 OVERLAY NO-BOX FRAME f_browse.

ON 'ENTRY' OF b_bancos DO:

    IF   aux_nrdlinha > 0   THEN
         REPOSITION q_bancos TO ROW(aux_nrdlinha).        
    
END.

ON RETURN OF zoom_bbancos DO:

    FIND CURRENT tt-crapban NO-ERROR.

    IF  AVAILABLE tt-crapban THEN
        ASSIGN 
            tel_cddbanco = tt-crapban.cdbccxlt
            tel_dsdbanco = tt-crapban.nmresbcc.
    ELSE 
        ASSIGN 
            tel_cddbanco = 0
            tel_dsdbanco = "".

    DISPLAY tel_cddbanco tel_dsdbanco WITH FRAME f_financeio_banco.

    HIDE FRAME f_zoom_bancos.
    APPLY "GO".

    RETURN.
END.

ON ANY-KEY OF b_bancos IN FRAME f_browse DO:

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
           IF   AVAILABLE tt-banco   THEN
                DO:
                    ASSIGN aux_nrdrowid = tt-banco.nrdrowid
                           aux_seqbanco = tt-banco.nrdlinha
                           aux_nrdlinha = CURRENT-RESULT-ROW("q_bancos").
                         
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b_bancos:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_seqbanco = 0
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
END.

/* Atualiza a descricao do banco */
ON LEAVE OF tel_cddbanco IN FRAME f_financeio_banco DO:
    HIDE MESSAGE NO-PAUSE.

   ASSIGN INPUT tel_cddbanco.

   /* Digitou banco errado */
   IF  NOT DYNAMIC-FUNCTION("BuscaBanco" IN h-b1wgen0060,
                             INPUT tel_cddbanco,
                            OUTPUT tel_dsdbanco,
                            OUTPUT aux_dscritic ) AND tel_cddbanco <> 0 THEN
       DO:
           BELL.
           MESSAGE aux_dscritic.
           NEXT-PROMPT tel_cddbanco WITH FRAME f_financeio_banco.
           RETURN NO-APPLY.
       END.

   DISPLAY tel_dsdbanco WITH FRAME f_financeio_banco.              
END.

ON VALUE-CHANGED OF tel_dsvencto IN FRAME f_financeio_banco DO:

   HIDE MESSAGE.
   
   IF   INPUT tel_dsvencto = "v"  OR 
        INPUT tel_dsvencto = "V"  THEN
        DO:
            ASSIGN tel_dsvencto = "VARIOS".
            DISPLAY tel_dsvencto WITH FRAME f_financeio_banco.
            APPLY "GO".
        END.
   ELSE
   IF   CAN-DO("1,2,3,4,5,6,7,8,9,0",KEY-FUNCTION(LASTKEY)) THEN
        DO:
            IF  LENGTH(INPUT tel_dsvencto) = 2 OR 
                LENGTH(INPUT tel_dsvencto) = 5 THEN
                APPLY KEYCODE("/").  
            
        END.
   ELSE
        DO:
            MESSAGE "Atencao: Digite caracteres numericos ou V para varios".
            APPLY "BACKSPACE".
        END.
END. 

DO WHILE TRUE:

   IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
       RUN sistema/generico/procedures/b1wgen0059.p 
           PERSISTENT SET h-b1wgen0059.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   IF  NOT VALID-HANDLE(h-b1wgen0067) THEN
       RUN sistema/generico/procedures/b1wgen0067.p 
           PERSISTENT SET h-b1wgen0067.

   ASSIGN glb_cddopcao = "C".

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

    /* Carrega a lista de bancos */
   OPEN QUERY q_bancos FOR EACH tt-banco NO-LOCK BY tt-banco.nrdlinha.

   ASSIGN glb_nmrotina = "FINANCEIRO-BANCO"
          glb_cddopcao = reg_cddopcao[reg_contador].
   
   DISPLAY aux_cdopejfn aux_nmoperad aux_dtaltjfn reg_dsdopcao 
           WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_bancos WITH FRAME f_browse.
      LEAVE.
   END.

   IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
       LEAVE.

   /* Deixa o browse visivel e marca a linha que tinha sido selecionada */
   VIEW FRAME f_browse.
   IF   aux_nrdlinha > 0   THEN
        REPOSITION q_bancos TO ROW(aux_nrdlinha).        

   { includes/acesso.i }

   IF   glb_cddopcao = "I"   THEN
        DO:             
            IF  QUERY q_bancos:NUM-RESULTS = 5 THEN
                 DO:
                     MESSAGE "Cadastro completo. Maximo 5 cadastros".
                     PAUSE 3 NO-MESSAGE.
                     NEXT.
                 END.
            
            HIDE MESSAGE NO-PAUSE.
            
            ASSIGN tel_cddbanco = 0  
                   tel_dsdbanco = ""
                   tel_dstipope = ""  
                   tel_vlropera = 0
                   tel_garantia = "" 
                   tel_dsvencto = ""
                   tel_cdopejfn = ""
                   tel_nmoperad = ""
                   tel_dtaltjfn = ?
                   aux_contador = 1
                   glb_cdcritic = 0
                   aux_nrdrowid = ?
                   aux_nrdlinha = 0
                   aux_seqbanco = 0.
                   
            DISPLAY tel_dsdbanco tel_cdopejfn tel_nmoperad tel_dtaltjfn 
                    WITH FRAME f_financeio_banco.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_cddbanco  tel_dstipope   tel_vlropera
                      tel_garantia  tel_dsvencto   WITH FRAME f_financeio_banco
 
               EDITING:
           
                 READKEY.
                 HIDE MESSAGE NO-PAUSE.
                 
                 IF   LASTKEY = KEY-CODE("F7")       AND
                      FRAME-FIELD = "tel_cddbanco"   THEN
                      DO:
                          RUN Busca_Banco.

                          OPEN QUERY zoom_qbancos FOR EACH tt-crapban NO-LOCK.
                             
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE zoom_bbancos WITH FRAME f_zoom_bancos.
                             LEAVE.
                          END.
                        
                          IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                               DO:
                                  HIDE FRAME f_zoom_bancos.
                                  NEXT.  

                               END.
                      END.
                 ELSE
                      APPLY LASTKEY.
                   
               END.  /*  Fim do EDITING  */       

               RUN Valida_Dados.

               IF  RETURN-VALUE <> "OK" THEN
                   NEXT.

               RUN Busca_Operador.

               IF  RETURN-VALUE <> "OK" THEN
                   NEXT.

               ASSIGN tel_dtaltjfn = glb_dtmvtolt.
                     
               DISPLAY tel_cdopejfn tel_nmoperad tel_dtaltjfn 
                       WITH FRAME f_financeio_banco.

               RUN Confirma.

               IF   aux_confirma = "S" THEN
                    DO:
                        RUN Grava_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.
                                
                        LEAVE.
                    END. 
            END.
        END.
   ELSE        
   IF   glb_cddopcao = "A"   THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
            ASSIGN glb_cdcritic = 0.

            /* Se foi selecionado algum registro */
            IF   aux_nrdrowid <> ?   THEN
                 DO:
                     FIND FIRST tt-banco WHERE 
                                         tt-banco.nrdrowid = aux_nrdrowid AND
                                         tt-banco.nrdlinha = aux_seqbanco
                                         NO-LOCK NO-ERROR.

                     IF  NOT AVAILABLE tt-banco THEN
                         NEXT.

                     ASSIGN tel_cddbanco = tt-banco.cddbanco
                            tel_dsdbanco = tt-banco.dsdbanco
                            tel_dstipope = tt-banco.dstipope
                            tel_vlropera = tt-banco.vlropera
                            tel_garantia = tt-banco.garantia
                            tel_dsvencto = tt-banco.dsvencto
                            tel_cdopejfn = tt-banco.cdoperad
                            tel_nmoperad = tt-banco.nmoperad
                            tel_dtaltjfn = tt-banco.dtaltjfn.
                            
                     DISPLAY tel_dsdbanco tel_cdopejfn 
                             tel_nmoperad tel_dtaltjfn
                             WITH FRAME f_financeio_banco.
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                         UPDATE  tel_cddbanco  tel_dstipope 
                                 tel_vlropera  tel_garantia 
                                 tel_dsvencto  WITH FRAME f_financeio_banco
                         EDITING:
               
                               READKEY.
                               HIDE MESSAGE NO-PAUSE.
                   
                               IF   LASTKEY = KEY-CODE("F7")       AND
                                    FRAME-FIELD = "tel_cddbanco"   THEN
                                    DO:
                                        RUN Busca_Banco.
                                        OPEN QUERY zoom_qbancos 
                                                   FOR EACH tt-crapban NO-LOCK.
                              
                                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                           UPDATE zoom_bbancos 
                                                  WITH FRAME f_zoom_bancos.
                                           LEAVE.
                                        END.
                              
                                        IF   KEY-FUNCTION(LASTKEY) = 
                                             "END-ERROR"   THEN
                                             DO:
                                                HIDE FRAME f_zoom_bancos.
                                                NEXT.
                                             END.

                                    END.
                                ELSE
                               
                                    APPLY LASTKEY.
    
                         END.  /*  Fim do EDITING  */
                         
                         RUN Valida_Dados.

                         IF   RETURN-VALUE <> "OK"  THEN
                              NEXT.

                         LEAVE.

                     END. /* Fim do DO WHILE TRUE */
                     
                     IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                          NEXT.

                     IF   tel_cddbanco <> tt-banco.cddbanco  OR
                          tel_dstipope <> tt-banco.dstipope  OR
                          tel_vlropera <> tt-banco.vlropera  OR
                          tel_garantia <> tt-banco.garantia  OR
                          tel_dsvencto <> tt-banco.dsvencto  THEN
                          DO:
                              RUN Busca_Operador.

                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.

                              ASSIGN tel_dtaltjfn = glb_dtmvtolt.
                                     
                              DISPLAY tel_cdopejfn tel_nmoperad tel_dtaltjfn
                                      WITH FRAME f_financeio_banco.
                          END.
                                   
                     RUN Confirma.

                     IF   aux_confirma = "S" THEN
                          DO:
                              RUN Grava_Dados.
        
                              IF  RETURN-VALUE <> "OK" THEN
                                  NEXT.
                          END. 
                 END.
        END.
   ELSE        
   IF   glb_cddopcao = "E"   THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
            ASSIGN glb_cdcritic = 0.

            /* Se foi selecionado algum registro */
            IF   aux_nrdrowid <> ?   THEN
                 DO:
                    FIND FIRST tt-banco WHERE 
                                        tt-banco.nrdrowid = aux_nrdrowid AND
                                        tt-banco.nrdlinha = aux_seqbanco
                                        NO-LOCK NO-ERROR.
    
                    IF  NOT AVAILABLE tt-banco THEN
                        NEXT.
    
                    ASSIGN tel_cddbanco = tt-banco.cddbanco
                           tel_dsdbanco = tt-banco.dsdbanco
                           tel_dstipope = tt-banco.dstipope
                           tel_vlropera = tt-banco.vlropera
                           tel_garantia = tt-banco.garantia
                           tel_dsvencto = tt-banco.dsvencto
                           tel_cdopejfn = tt-banco.cdoperad
                           tel_nmoperad = tt-banco.nmoperad
                           tel_dtaltjfn = tt-banco.dtaltjfn.
                 
                    RUN Confirma.

                    IF   aux_confirma = "S" THEN
                         DO:
                             RUN Grava_Dados.

                             IF  RETURN-VALUE <> "OK" THEN
                                 NEXT.
                         END. 
                 END.
        END.
END.         

IF  VALID-HANDLE(h-b1wgen0059) THEN
    DELETE OBJECT h-b1wgen0059.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

IF  VALID-HANDLE(h-b1wgen0067) THEN
    DELETE OBJECT h-b1wgen0067.

HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_browse NO-PAUSE.

PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0067
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT 0,
          INPUT glb_cddopcao,
         OUTPUT TABLE tt-banco,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    FIND FIRST tt-banco NO-ERROR.

    IF  AVAILABLE tt-banco THEN
        ASSIGN 
            aux_dtaltjfn = tt-banco.dtaltjfn
            aux_cdopejfn = tt-banco.cdoperad
            aux_nmoperad = tt-banco.nmoperad.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Dados:

    RUN Valida_Dados IN h-b1wgen0067
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
          INPUT tel_cddbanco,
          INPUT tel_dstipope,
          INPUT tel_vlropera,
          INPUT tel_garantia,
          INPUT tel_dsvencto,
         OUTPUT TABLE tt-erro ) .

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

END PROCEDURE.

PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0067) THEN
        DELETE OBJECT h-b1wgen0067.

    RUN sistema/generico/procedures/b1wgen0067.p PERSISTENT SET h-b1wgen0067.

    RUN Grava_Dados IN h-b1wgen0067
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
          INPUT aux_seqbanco,
          INPUT tel_cddbanco,
          INPUT tel_dstipope,
          INPUT tel_vlropera,
          INPUT tel_garantia,
          INPUT tel_dsvencto,
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
    RUN proc_altcad (INPUT "b1wgen0067.p").

    IF  VALID-HANDLE(h-b1wgen0067) THEN
        DELETE OBJECT h-b1wgen0067.

    IF  RETURN-VALUE <> "OK" THEN
        NEXT.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Banco:

    DEFINE VARIABLE aux_qtregist AS INTEGER     NO-UNDO.

    RUN busca-crapban IN h-b1wgen0059
        ( INPUT 0,
          INPUT "",
          INPUT 99999,
          INPUT 0,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-crapban ).

    RETURN "OK".

END PROCEDURE.

PROCEDURE Busca_Operador:

    DYNAMIC-FUNCTION("BuscaOperador" IN h-b1wgen0060,
                     INPUT glb_cdcooper,
                     INPUT glb_cdoperad,
                    OUTPUT tel_nmoperad,
                    OUTPUT aux_dscritic ).

    ASSIGN tel_cdopejfn = glb_cdoperad.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Confirma:

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
/*              RETURN "NOK". */
         END.

     RETURN "OK".

END PROCEDURE.


/*...........................................................................*/
