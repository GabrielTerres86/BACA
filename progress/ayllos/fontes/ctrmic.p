/* .............................................................................

   Programa: fontes/ctrmic.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Abril/2003.                     Ultima atualizacao: 30/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CTRMIC -- Consultar contratos de emprestimos
               e de limites de credito microfilmados.

   Alteracoes: 22/07/2003 - Inclusao do campo valor do contrato na tela,
                            indentificacao do contrato MIC/ARQ, substituicao
                            do campo dtmvtolt por dtdbaixa, com label 
                            liquidacao (Julio). 

               06/08/2003 - Inclusao da informacao tipo de limite (Julio).

               27/01/2004 - Nao mostrava todos os contratos (Margarete).

               07/10/2004 - Alterado o HELP do campo "tel_tpctrmif" para
                            informar os tipos de contrato e "corrigida" a
                            limpeza da exibicao dos lancamentos (Evandro).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               01/09/2009 - Acerto na listagem DOWN WITH FRAME (Guilherme).
               
               06/05/2010 - Inclusao do campo "Linha de Credito" na tela.
                            (Sandro-GATI)
                            
               11/10/2012 - Nova chamada da procedure valida_operador_migrado
                            da b1wgen9998 para controle de contas e operadores
                            migrados (David Kruger).
                     
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               30/03/2015 - Alterado para quando nao houver data de baixa na
                            crapmcr procurar na crapepr e mostrar dtultpago
                            caso inliquid seja igual a 1(liquidado)
                            (Tiago/Gielow SD211186).             
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_tpctrmif AS INTE    FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_cdpesqui AS CHAR    FORMAT "x(25)"                NO-UNDO.  
DEF        VAR tel_dslcremp AS CHAR    FORMAT "x(29)"                NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
                            
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR tel_dstpcont AS CHAR                                  NO-UNDO.
DEF        VAR aux_opmigrad AS LOG                                   NO-UNDO.

DEF        VAR aux_flnovepr AS LOG                                   NO-UNDO.

DEF        VAR h-b1wgen9998 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  5 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C ou D)"
                        VALIDATE (CAN-DO("C,D",glb_cddopcao),
                                  "014 - Opcao errada.")

     tel_nrdconta AT 15 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta."

     SPACE(2)
     tel_dtmvtolt       LABEL "Data" AUTO-RETURN
     
     SPACE(2)
     tel_tpctrmif       LABEL "Tipo Contrato" AUTO-RETURN
     HELP "Informe o tipo de contrato (1=Emprestimo 2=Limite/Desconto)."
                        VALIDATE(CAN-DO("1,2",tel_tpctrmif),
                                 "014 - Opcao errada.")
                                 
     SKIP(1)
     "Conta/dv Titular                              Tipo    Contrato" AT 3
     "  Liquidacao"                   
     SKIP
     "         CNPJ                    Valor(R$)                    " AT 3
     "    Pesquisa"
     SKIP
     "                                                          "     AT 3
     "Linha de Credito"
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_contratos.

FORM SKIP(1)
     crapmcr.nrdconta AT 1
     crapass.nmprimtl AT 12 FORMAT "x(34)"
     tel_dstpcont FORMAT "x(6)" AT 48
     crapmcr.nrcontra AT 56
     SPACE(3)
     crapmcr.dtdbaixa FORMAT "99/99/9999" AT 68
     SKIP
     tel_nrcpfcgc AT 8 
     crapmcr.vlcontra 
     tel_cdpesqui FORMAT "x(29)" AT 49
     SKIP
     tel_dslcremp FORMAT "x(29)" AT 49
     WITH ROW 11 COLUMN 2 OVERLAY 2 DOWN NO-LABEL NO-BOX FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_contratos.

      ASSIGN tel_nrdconta = 0
             tel_tpctrmif = 0
             tel_dtmvtolt = ?.
      DISPLAY tel_nrdconta tel_tpctrmif tel_dtmvtolt
              WITH FRAME f_contratos.
              
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "ctrmic"   THEN
                 DO:
                     HIDE FRAME f_contratos.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DISPLAY tel_nrdconta tel_tpctrmif WITH FRAME f_contratos.

   CLEAR FRAME f_lanctos ALL NO-PAUSE.

   IF   glb_cddopcao = "C"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    glb_cdcritic = 0.
                END.

           UPDATE tel_nrdconta tel_tpctrmif WITH FRAME f_contratos
           
           EDITING:

              aux_stimeout = 0.

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF   LASTKEY = -1   THEN
                      DO:
                          aux_stimeout = aux_stimeout + 1.

                          IF   aux_stimeout > glb_stimeout   THEN
                               QUIT.

                          NEXT.
                      END.

                 APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */

           ASSIGN aux_regexist = FALSE
                  aux_flgretor = FALSE
                  aux_contador = 0.

           CLEAR FRAME f_lanctos ALL NO-PAUSE.
          
           RUN sistema/generico/procedures/b1wgen9998.p
               PERSISTENT SET h-b1wgen9998.

           /* Validacao de operado e conta migrada */
           RUN valida_operador_migrado IN h-b1wgen9998 (INPUT glb_cdoperad,
                                                        INPUT tel_nrdconta,
                                                        INPUT glb_cdcooper,
                                                        INPUT glb_cdagenci,
                                                        OUTPUT aux_opmigrad,
                                                        OUTPUT TABLE tt-erro).
   
           DELETE PROCEDURE h-b1wgen9998.

           IF RETURN-VALUE <> "OK" THEN
              DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
          
                  IF AVAIL tt-erro THEN
                     DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE.
                        NEXT.
                     END.
        
              END.
           
           FOR EACH crapmcr WHERE crapmcr.cdcooper = glb_cdcooper   AND
                                  crapmcr.nrdconta = tel_nrdconta   AND
                                  crapmcr.tpctrmif = tel_tpctrmif   NO-LOCK
                                  BY crapmcr.dtmvtolt DESCENDING:
            
               ASSIGN aux_regexist = TRUE
                      aux_contador = aux_contador + 1.

               IF   aux_contador = 3   THEN
                    DO:
                        PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    END.
            
               ASSIGN tel_nrcpfcgc = ""
                      tel_cdpesqui = "".
               
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                  crapass.nrdconta = crapmcr.nrdconta 
                                  NO-LOCK NO-ERROR.
               IF   AVAILABLE crapass   THEN
                    DO:
                        IF   LENGTH(STRING(crapass.nrcpfcgc)) < 12 THEN
                             ASSIGN tel_nrcpfcgc = 
                                        STRING(crapass.nrcpfcgc,"99999999999")
                                    tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                   "    xxx.xxx.xxx-xx").
                        ELSE
                             ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                   "99999999999999")
                                    tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                   "xx.xxx.xxx/xxxx-xx").
                    END.

               ASSIGN tel_cdpesqui = STRING(crapmcr.dtmvtolt,"99/99/9999")
                                     + "-" +
                                     STRING(crapmcr.cdagenci,"999")  
                                     + "-" +
                                     STRING(crapmcr.cdbccxlt,"999")  
                                     + "-" +
                                     STRING(crapmcr.nrdolote,"999999").        
                                            
               IF   crapmcr.tpctrlim = 1   THEN
                    tel_dstpcont = "CHEQUE".
               ELSE
               IF   crapmcr.tpctrlim = 2   THEN
                    tel_dstpcont = "DESCTO".
               ELSE
                    tel_dstpcont = "".
                    
               IF   crapmcr.flgmifil   THEN
                    tel_cdpesqui = tel_cdpesqui + "-MIC".
               ELSE
                    tel_cdpesqui = tel_cdpesqui + "-ARQ".

               FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                                  craplcr.cdlcremp = crapmcr.cdlcremp
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE craplcr   THEN
                    DO:
                        ASSIGN tel_dslcremp = STRING(crapmcr.cdlcremp,"zzz9") + " " + craplcr.dslcremp.     
                    END.
               ELSE DO:
                        IF   crapmcr.cdlcremp = 0 THEN
                             ASSIGN tel_dslcremp = "".
                        ELSE
                             ASSIGN tel_dslcremp = STRING(crapmcr.cdlcremp,"zzz9").
                    END.

               ASSIGN aux_flnovepr = FALSE.

               IF  crapmcr.dtdbaixa = ? THEN
                   DO:

                    FIND crapepr WHERE crapepr.cdcooper = crapmcr.cdcooper
                                   AND crapepr.nrdconta = crapmcr.nrdconta
                                   AND crapepr.nrctremp = crapmcr.nrcontra
                                   AND crapepr.inliquid = 1
                                   NO-LOCK NO-ERROR.

                    IF  AVAIL(crapepr) THEN
                        DO:
                            ASSIGN aux_flnovepr = TRUE.
                        END.
                   END.

               IF  aux_flnovepr = TRUE THEN
                   DO:
                       DISPLAY crapmcr.nrdconta 
                               crapass.nmprimtl WHEN AVAILABLE crapass 
                               tel_dstpcont crapmcr.nrcontra crapepr.dtultpag @ crapmcr.dtdbaixa 
                               tel_nrcpfcgc tel_cdpesqui crapmcr.vlcontra
                               tel_dslcremp
                               WITH FRAME f_lanctos.
                   END.
               ELSE
                   DO:
                       DISPLAY crapmcr.nrdconta 
                               crapass.nmprimtl WHEN AVAILABLE crapass 
                               tel_dstpcont crapmcr.nrcontra crapmcr.dtdbaixa
                               tel_nrcpfcgc tel_cdpesqui crapmcr.vlcontra
                               tel_dslcremp
                               WITH FRAME f_lanctos.
                   END. 
                             
               DOWN WITH FRAME f_lanctos.
               
               IF   aux_contador = 3   THEN
                    aux_contador = 0.

           END.  /*  Fim do FOR EACH  */
           
           IF   NOT aux_regexist   THEN
                glb_cdcritic = 11.

        END.  /*  Fim do DO WHILE TRUE  */
   ELSE
   IF   glb_cddopcao = "D"   THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           IF   glb_cdcritic > 0   THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
                    glb_cdcritic = 0.
                END.

           UPDATE tel_dtmvtolt tel_tpctrmif WITH FRAME f_contratos

           EDITING:

              aux_stimeout = 0.

              DO WHILE TRUE:

                 READKEY PAUSE 1.

                 IF   LASTKEY = -1   THEN
                      DO:
                          aux_stimeout = aux_stimeout + 1.

                          IF   aux_stimeout > glb_stimeout   THEN
                               QUIT.

                          NEXT.
                      END.

                 APPLY LASTKEY.

                 LEAVE.

              END.  /*  Fim do DO WHILE TRUE  */

           END.  /*  Fim do EDITING  */

           ASSIGN aux_regexist = FALSE
                  aux_flgretor = FALSE
                  aux_contador = 0.

           CLEAR FRAME f_lanctos ALL NO-PAUSE.
           
           FOR EACH crapmcr WHERE crapmcr.cdcooper  = glb_cdcooper   AND
                                  crapmcr.dtmvtolt >= tel_dtmvtolt   AND       
                                  crapmcr.tpctrmif  = tel_tpctrmif   NO-LOCK   
                                  BY crapmcr.dtmvtolt DESCENDING:

               ASSIGN aux_regexist = TRUE
                      aux_contador = aux_contador + 1.

               IF   aux_contador = 3   THEN
                    IF   aux_flgretor   THEN
                         DO:
                              PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                              CLEAR FRAME f_lanctos ALL NO-PAUSE.
                         END.
                    ELSE
                         aux_flgretor = TRUE.

               ASSIGN tel_nrcpfcgc = "".
               
               FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                                  crapass.nrdconta = crapmcr.nrdconta 
                                  NO-LOCK NO-ERROR.
               IF   AVAILABLE crapass   THEN
                    DO:
                        IF   LENGTH(STRING(crapass.nrcpfcgc)) < 12 THEN
                             ASSIGN tel_nrcpfcgc = 
                                        STRING(crapass.nrcpfcgc,"99999999999")
                                    tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                   "    xxx.xxx.xxx-xx").
                        ELSE
                             ASSIGN tel_nrcpfcgc = STRING(crapass.nrcpfcgc,
                                                   "99999999999999")
                                    tel_nrcpfcgc = STRING(tel_nrcpfcgc,
                                                   "xx.xxx.xxx/xxxx-xx").
                    END.

               ASSIGN tel_cdpesqui = STRING(crapmcr.dtmvtolt,"99/99/9999")
                                     + "-" +
                                     STRING(crapmcr.cdagenci,"999")  
                                     + "-" +
                                     STRING(crapmcr.cdbccxlt,"999")  
                                     + "-" +
                                     STRING(crapmcr.nrdolote,"999999"). 
 
               IF   crapmcr.tpctrlim = 1   THEN
                    tel_dstpcont = "CHEQUE".
               ELSE
               IF   crapmcr.tpctrlim = 2   THEN
                    tel_dstpcont = "DESCTO".
                    
               IF   crapmcr.flgmifil    THEN
                    tel_cdpesqui = tel_cdpesqui + "-MIC".
               ELSE
                    tel_cdpesqui = tel_cdpesqui + "-ARQ".

               FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                                  craplcr.cdlcremp = crapmcr.cdlcremp
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE craplcr   THEN
                    DO:
                        ASSIGN tel_dslcremp = STRING(crapmcr.cdlcremp,"zzz9") + " " + craplcr.dslcremp.   
                    END.
               ELSE DO:
                        IF   crapmcr.cdlcremp = 0 THEN
                             ASSIGN tel_dslcremp = "".
                        ELSE
                             ASSIGN tel_dslcremp = STRING(crapmcr.cdlcremp,"zzz9").
                    END.

               ASSIGN aux_flnovepr = FALSE.
    
               IF  crapmcr.dtdbaixa = ? THEN
                   DO:
    
                    FIND crapepr WHERE crapepr.cdcooper = crapmcr.cdcooper
                                   AND crapepr.nrdconta = crapmcr.nrdconta
                                   AND crapepr.nrctremp = crapmcr.nrcontra
                                   AND crapepr.inliquid = 1
                                   NO-LOCK NO-ERROR.
    
                    IF  AVAIL(crapepr) THEN
                        DO:
                            ASSIGN aux_flnovepr = TRUE.
                        END.
                   END.
    
               IF  aux_flnovepr = TRUE THEN
                   DO:
                       DISPLAY crapmcr.nrdconta 
                               crapass.nmprimtl WHEN AVAILABLE crapass 
                               tel_dstpcont crapmcr.nrcontra crapepr.dtultpag @ crapmcr.dtdbaixa 
                               tel_nrcpfcgc tel_cdpesqui crapmcr.vlcontra
                               tel_dslcremp
                               WITH FRAME f_lanctos.
                   END.
               ELSE
                   DO:
                       DISPLAY crapmcr.nrdconta 
                               crapass.nmprimtl WHEN AVAILABLE crapass 
                               tel_dstpcont crapmcr.nrcontra crapmcr.dtdbaixa
                               tel_nrcpfcgc tel_cdpesqui crapmcr.vlcontra
                               tel_dslcremp
                               WITH FRAME f_lanctos.
                   END. 

               DOWN WITH FRAME f_lanctos.

               IF   aux_contador = 3   THEN
                    aux_contador = 0.

           END.  /*  Fim do FOR EACH  */
           
           IF   NOT aux_regexist   THEN
                glb_cdcritic = 11.

        END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
