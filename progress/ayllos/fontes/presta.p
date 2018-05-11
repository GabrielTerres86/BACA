/* .............................................................................

   Programa: Fontes/presta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/94.                      Ultima atualizacao: 30/01/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PRESTA - Alteracao do valor da prestacao.

   Alteracoes: 20/11/96 - Alterar a mascara do campo nrctremp (Odair).

               03/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               18/12/2003 - Alterado para gerar log (Edson).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               09/02/2006 - Inclusao de LOCK em comandos de pesquisa - SQLWorks
                            - Andre
                            
               09/04/2008 - Alteração do campo "crapepr.qtpreemp"  no formato 
                            de "<9" para o formato de "zz9" - 
                            Kbase it Solutions - Eduardo          

               04/12/2008 - Habilitada tela para linhas 250 e 251(Mirtes)
               
               14/09/2011 - Inclusao do Requisito "PRESTA - Restricao … 
                            alteracao de parcelas" (Vitor - GATI)
                         
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)             

               30/01/2017 - Nao permitir alterar valor da prestacao para o produto Pos-Fixado.
                            (Jaison/James - PRJ298)

............................................................................. */

{ includes/ctremp.i "NEW" }

{ includes/var_online.i }

DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrctremp AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(35)"                NO-UNDO.
DEF        VAR tel_cdpesqui AS CHAR    FORMAT "x(26)"                NO-UNDO.
DEF        VAR tel_vlpreemp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.

DEF        VAR epr_nrctremp AS INT     EXTENT 99                     NO-UNDO.

DEF        VAR aux_nrctatos AS INT                                   NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.

DEF        VAR aux_stimeout AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.


FORM SKIP(1)
     glb_cddopcao AT 3 LABEL "   Opcao" AUTO-RETURN
                             HELP "Informe a opcao desejada (A,C)"
                       VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C",
                       "014 - Opcao errada")

     SKIP(2)
     tel_nrdconta     AT 3  LABEL "Conta/dv" AUTO-RETURN
                      HELP "Informe o numero da conta do associado"

     tel_nmprimtl     AT 27 LABEL "Titular"

     SKIP(2)
     tel_nrctremp     AT 20  LABEL "Contrato" AUTO-RETURN
                      HELP "Informe o numero do contrato ou F7 para listar"

     SKIP(2)
     tel_vlpreemp AT 10 LABEL "Valor da Prestacao"
                      HELP "Informe o valor da prestacao"
                      VALIDATE (tel_vlpreemp > 0,
                                "208 - Valor da prestacao errado")

     SKIP(2)
     tel_cdpesqui     AT 20 LABEL "Pesquisa"

     SKIP(2)
     WITH ROW 4 WIDTH 80 OVERLAY SIDE-LABELS TITLE glb_tldatela FRAME f_conta.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

PAUSE 0.

VIEW FRAME f_conta.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               IF   glb_cdcritic <> 356 THEN
                    tel_nrctremp = 0.

               ASSIGN tel_vlpreemp = 0
                      tel_cdpesqui = " ".
               DISPLAY tel_nmprimtl tel_nrctremp tel_vlpreemp
                       tel_cdpesqui WITH FRAME f_conta.
               glb_cdcritic = 0.
           END.

      RELEASE crapepr.

      NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.

      UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_conta

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

      glb_nrcalcul = tel_nrdconta.

      RUN fontes/digfun.p.

      IF   NOT glb_stsnrcal   THEN
           DO:
               ASSIGN glb_cdcritic = 8
                      tel_nmprimtl = " " .
               NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PRESTA"   THEN
                 DO:
                     HIDE FRAME f_conta.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                      crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN
        DO:
            ASSIGN glb_cdcritic = 9
                   tel_nmprimtl = " ".
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

   ASSIGN tel_nmprimtl = crapass.nmprimtl.

   DISPLAY tel_nmprimtl WITH FRAME f_conta.

   ASSIGN tel_nrctremp = 0
          aux_nrctatos = 0
          s_chextent   = 0
          s_chlist     = "".

   FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper AND 
                          crapepr.nrdconta = tel_nrdconta AND
                          crapepr.inliquid = 0 NO-LOCK:

       FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                          craplcr.cdlcremp = crapepr.cdlcremp NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craplcr   THEN
            NEXT.

       IF  craplcr.tplcremp = 2 OR
           craplcr.cdlcremp = 250 OR
           craplcr.cdlcremp = 403 OR
           craplcr.cdlcremp = 410 OR
           craplcr.cdlcremp = 251 THEN
           .
       ELSE     
           NEXT.

       ASSIGN aux_nrctatos = aux_nrctatos + 1
              aux_nrctremp = crapepr.nrctremp

              epr_nrctremp[aux_nrctatos] = crapepr.nrctremp

              s_chextent           = s_chextent + 1
              s_chlist[s_chextent] =
                         STRING(crapepr.nrctremp,"zz,zzz,zz9") + " " +
                         STRING(crapepr.dtmvtolt,"99/99/9999") + " " +
                         STRING(crapepr.vlemprst,"zzzz,zzz,zz9.99") + " " +
                         STRING(crapepr.qtpreemp,"zz9") + " x " +
                         STRING(crapepr.vlpreemp,"zzz,zzz,zz9.99") + " " +
                         "LC " + STRING(crapepr.cdlcremp,"9999") + " " +
                         "Fin " + STRING(crapepr.cdfinemp,"999").

   END.  /*  Fim do FOR EACH  --  Leitura dos contratos de emprestimos  */

   IF   aux_nrctatos = 0   THEN
        DO:
            glb_cdcritic = 370.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

   IF   aux_nrctatos = 1 THEN
        tel_nrctremp = aux_nrctremp.
   ELSE
        DO:
            UPDATE tel_nrctremp WITH FRAME f_conta

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

                  IF   LASTKEY = KEYCODE("F7")        AND
                       FRAME-FIELD = "tel_nrctremp"   THEN
                       DO:
                           IF   s_chextent > 0   THEN
                                DO:
                                    ASSIGN s_row      = 10
                                           s_column   = 15
                                           s_hide     = TRUE
                                           s_title    = " Contratos "
                                           s_dbfilenm = "crapepr"
                                           s_multiple = FALSE
                                           s_wide     = TRUE.

                                    RUN fontes/ctremp.p.

                                    IF   s_chcnt > 0   THEN
                                         DO:
                                             tel_nrctremp = epr_nrctremp
                                                            [s_choice[s_chcnt]].

                                             DISPLAY tel_nrctremp
                                                     WITH FRAME f_conta.
                                         END.
                                END.
                       END.

                  APPLY LASTKEY.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

            END.  /*  Fim do EDITING  */

        END. /* Fim do DO */

   FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                      crapepr.nrdconta = tel_nrdconta   AND
                      crapepr.nrctremp = tel_nrctremp   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapepr   THEN
        DO:
            glb_cdcritic = 356.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

   IF   crapepr.inliquid = 1 THEN
        DO:
            glb_cdcritic = 358.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

   FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND 
                      craplcr.cdlcremp = crapepr.cdlcremp NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE craplcr   THEN
        DO:
            ASSIGN glb_cdcritic = 363
                   tel_vlpreemp = 0
                   tel_cdpesqui = " ".
            DISPLAY tel_vlpreemp tel_cdpesqui WITH FRAME f_conta.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.

   IF   craplcr.tplcremp = 2   OR
        craplcr.cdlcremp = 250 OR
        craplcr.cdlcremp = 251 OR
        craplcr.cdlcremp = 410 OR
        craplcr.cdlcremp = 403 THEN
        .
   ELSE 
        DO:
            ASSIGN glb_cdcritic = 369
                   tel_vlpreemp = 0
                   tel_cdpesqui = " ".
            DISPLAY tel_vlpreemp tel_cdpesqui WITH FRAME f_conta.
            NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
            NEXT.
        END.   

   ASSIGN tel_cdpesqui = STRING(crapepr.dtmvtolt,"99/99/9999") + "-" +
                         STRING(crapepr.cdagenci,"999")      + "-" +
                         STRING(crapepr.cdbccxlt,"999")      + "-" +
                         STRING(crapepr.nrdolote,"999999")
          tel_vlpreemp = crapepr.vlpreemp.

   DISPLAY tel_cdpesqui tel_nrctremp WITH FRAME f_conta.

   IF   glb_cddopcao = "C"   THEN
        DO:
            DISPLAY tel_vlpreemp WITH FRAME f_conta.
            NEXT.
        END.
   
   IF crapepr.tpemprst = 1   OR
      crapepr.tpemprst = 2   THEN 
        DO:
            MESSAGE "Operacao invalida para esse tipo de contrato.".
            NEXT.
        END.

   DO TRANSACTION ON ERROR UNDO, LEAVE:

      DO aux_contador = 1 TO 10:

         FIND crapepr WHERE crapepr.cdcooper = glb_cdcooper AND 
                            crapepr.nrdconta = tel_nrdconta AND
                            crapepr.nrctremp = tel_nrctremp
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE crapepr   THEN
              IF   LOCKED crapepr   THEN
                   DO:
                       glb_cdcritic = 371.
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 356.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_conta.
                       LEAVE.
                   END.
         ELSE
              DO:
                  glb_cdcritic = 0.
                  LEAVE.
              END.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0   THEN
           NEXT.

      tel_vlpreemp = crapepr.vlpreemp.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE tel_vlpreemp WITH FRAME f_conta.

         LEAVE.

      END.

      IF   tel_vlpreemp <> crapepr.vlpreemp   THEN
           UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
                             STRING(TIME,"HH:MM:SS") + "' --> '"  +
                             " Operador: " + glb_cdoperad +
                             " Parcela alterada de " +
                             STRING(crapepr.vlpreemp,"zz,zzz,zzz,zz9.99") +
                             " para " + 
                             STRING(tel_vlpreemp,"zz,zzz,zzz,zz9.99") +
                             "  Conta: " +
                             STRING(crapepr.nrdconta,"zzzz,zzz,9") +
                             "  Contrato: " +
                             STRING(crapepr.nrctremp,"zz,zzz,zz9") +
                             " >> log/presta.log").

      crapepr.vlpreemp = tel_vlpreemp.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */
           NEXT.

   END.  /* Fim da transacao */

   RELEASE crapepr.

   NEXT.

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

