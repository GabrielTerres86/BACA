/* .............................................................................

   Programa: Fontes/lancrd.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97                           Ultima atualizacao: 14/02/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCRD.

   Alteracoes: 20/08/98 - Alterado para tratar mais de um tipo de cartao                                   (Deborah).
                          
               10/09/98 - Tratar tipo de conta 7 (Deborah).           

               09/11/98 - Tratar situacao em prejuizo (Deborah).

             24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                          titular (Eduardo).

             13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             31/07/2002 - Incluir nova situacao da conta (Margarete).

             07/05/2004 - Comentado o bloqueio para administradora desativada
                         (Julio)

             30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando   
             
             26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                          para crapbcl (Adriano). 
                          
             12/07/2011 - Alterado a palavra Credicard para Cecred Visa, no 
                          help do campo tel_nrctrcrd. (Fabricio)
                          
             30/04/2013 - Ajustes para inclusao da chamada alerta_fraude
                          (Adriano).
                          
             05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).             

			 14/02/2017 - Ajustando o format do campo nrctrcrd nos relatórios que o utilizam.
			    		  SD 594718 (Kelvin).			 
             
             08/03/2018 - Substituida validacao "cdtipcta = 5, 6, 7, 17, 18" por "cdmodali = 2,3"
                          PRJ366 (Lombardi).
             
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i } 
{ includes/var_online.i }

DEF       VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF       VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF       VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF       VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF       VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF       VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_reganter AS CHAR    FORMAT "x(60)" EXTENT 6      NO-UNDO.

DEF       VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF       VAR tel_nrctrcrd AS INT     FORMAT "zzz,zzz,zz9"         NO-UNDO.
DEF       VAR tel_vllimpro AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF       VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF       VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF       VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF       VAR aux_regexist AS LOGICAL                              NO-UNDO.
DEF       VAR aux_contador AS INT                                  NO-UNDO.
DEF       VAR aux_cddopcao AS CHAR                                 NO-UNDO.

DEF       VAR aux_nrlotant AS INT                                  NO-UNDO.
DEF       VAR aux_dsoperac AS CHAR                                 NO-UNDO.
DEF       VAR h-b1wgen0110 AS HANDLE                               NO-UNDO.

DEF       VAR aux_cdmodali AS INT                                  NO-UNDO.
DEF       VAR aux_des_erro AS CHAR                                 NO-UNDO.
DEF       VAR aux_dscritic AS CHAR                                 NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E ou I)"
                        VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "E" OR
                                  glb_cddopcao = "I", "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 35 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do Posto de Atendimento."
                        VALIDATE (CAN-FIND(crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper AND 
                                           crapage.cdagenci = tel_cdagenci),
                                           "015 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE (CAN-FIND(crapbcl WHERE 
                                           crapbcl.cdbccxlt = tel_cdbccxlt),
                                           "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do lote errado.")

     SKIP(1)
     tel_qtinfoln AT 12 LABEL "Informado:   Qtd"
     tel_vlinfocr AT 41 LABEL "Credito"
     SKIP
     tel_qtcompln AT 12 LABEL "Computado:   Qtd"
     tel_vlcompcr AT 41 LABEL "Credito"
     SKIP
     tel_qtdifeln AT 12 LABEL "Diferenca:   Qtd"
     tel_vldifecr AT 41 LABEL "Credito"
     SKIP(1)
     "Conta/dv    Proposta   Valor do Limite      Seq." AT 15
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nrdconta AT 13 NO-LABEL
                  HELP "Entre com o numero da conta/dv do associado."

     tel_nrctrcrd AT 28 NO-LABEL
                  HELP "Entre com o numero da proposta/contrato Cecred Visa."

     tel_vllimpro AT 43 NO-LABEL
                  HELP "Entre com o valor do premio mensal"
                  VALIDATE(tel_vllimpro > 0, "91 - Valor do lancamento errado.")

     tel_nrseqdig AT 61 NO-LABEL
     WITH ROW 14 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lancrd.

FORM tel_reganter[1] AT 2 NO-LABEL  tel_reganter[2] AT 2 NO-LABEL
     tel_reganter[3] AT 2 NO-LABEL  tel_reganter[4] AT 2 NO-LABEL
     tel_reganter[5] AT 2 NO-LABEL  tel_reganter[6] AT 2 NO-LABEL
     WITH ROW 15 COLUMN 13 OVERLAY NO-BOX NO-LABELS FRAME f_regant.

FORM crawcrd.nrdconta AT 13
     crawcrd.nrctrcrd AT 28  FORMAT "zzz,zz9"
     craptlc.vllimcrd AT 39  FORMAT "zzz,zzz,zz9.99"
     crawcrd.nrseqdig AT 56
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cddopcao = "I"
       tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = glb_cdagenci
       tel_cdbccxlt = glb_cdbccxlt
       tel_nrdolote = glb_nrdolote
       aux_flgretor = FALSE
       glb_cdcritic = 0.

DISPLAY glb_cddopcao 
        tel_dtmvtolt 
        tel_cdagenci 
        tel_cdbccxlt 
        tel_nrdolote
        WITH FRAME f_opcao.

CLEAR FRAME f_lancrd ALL NO-PAUSE.

NEXT-PROMPT tel_cdagenci WITH FRAME f_opcao.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF NOT aux_flgretor   THEN
         IF   tel_cdagenci <> 0   AND
              tel_cdbccxlt <> 0   AND
              tel_nrdolote <> 0   THEN
              LEAVE.

      UPDATE glb_cddopcao 
             tel_cdagenci 
             tel_cdbccxlt 
             tel_nrdolote
             WITH FRAME f_opcao.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.

          IF CAPS(glb_nmdatela) <> "LANCRD"   THEN
             DO:
                 HIDE FRAME f_opcao.
                 HIDE FRAME f_lancrd.
                 HIDE FRAME f_regant.
                 HIDE FRAME f_lanctos.
                 HIDE FRAME f_moldura.
                 RETURN.

             END.
          ELSE
             NEXT.

      END.

   ASSIGN aux_flgretor = TRUE.

   IF aux_cddopcao <> glb_cddopcao   THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.
      END.

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   
                      NO-LOCK NO-ERROR.

   IF NOT AVAILABLE craplot   THEN
      DO:
          ASSIGN glb_cdcritic = 60.
          RUN fontes/critic.p.
          CLEAR FRAME f_lancrd.
          HIDE FRAME f_regant.
          CLEAR FRAME f_lanctos ALL NO-PAUSE.
          CLEAR FRAME f_opcao.

          DISPLAY glb_cddopcao 
                  tel_dtmvtolt 
                  tel_cdagenci
                  tel_cdbccxlt 
                  tel_nrdolote
                  WITH FRAME f_opcao.

          BELL.
          MESSAGE  glb_dscritic.
          ASSIGN glb_cdcritic = 0.
          NEXT.

      END.

   IF craplot.tplotmov <> 16   THEN
      DO:
          ASSIGN glb_cdcritic = 540.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          ASSIGN glb_cdcritic = 0.
          NEXT.

      END.

   ASSIGN tel_nrseqdig = craplot.nrseqdig + 1
          tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfocr = craplot.vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   DISPLAY tel_qtinfoln   
           tel_qtcompln
           tel_vlinfocr   
           tel_vlcompcr
           tel_qtdifeln   
           tel_vldifecr
           WITH FRAME f_opcao.

   IF tel_nrdolote <> aux_nrlotant THEN
      DO:
          HIDE FRAME f_regant.
          CLEAR FRAME f_lanctos ALL NO-PAUSE.
          CLEAR FRAME f_lancrd.
          ASSIGN aux_nrlotant = tel_nrdolote.

      END.

   IF glb_cddopcao = "C" THEN

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lancrd.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.

            END.

         UPDATE tel_nrdconta 
                tel_nrctrcrd 
                WITH FRAME f_lancrd.

         IF tel_nrdconta = 0 AND tel_nrctrcrd = 0   THEN
            DO:
                ASSIGN aux_flgerros = FALSE
                       aux_regexist = FALSE
                       aux_flgretor = FALSE
                       aux_contador = 0.

                CLEAR FRAME f_lancrd .

                HIDE FRAME f_regant.

                CLEAR FRAME f_lanctos ALL NO-PAUSE.

                FOR EACH crawcrd WHERE crawcrd.cdcooper = glb_cdcooper   AND
                                       crawcrd.dtmvtolt = tel_dtmvtolt   AND
                                       crawcrd.cdagenci = tel_cdagenci   AND
                                       crawcrd.cdbccxlt = tel_cdbccxlt   AND
                                       crawcrd.nrdolote = tel_nrdolote
                                       USE-INDEX crawcrd3 NO-LOCK:


                    FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND
                                       craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                                       craptlc.tpcartao = crawcrd.tpcartao AND
                                       craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                                       craptlc.dddebito = 0 
                                       NO-LOCK NO-ERROR.

                    IF NOT AVAILABLE craptlc   THEN
                       DO:
                           ASSIGN glb_cdcritic = 532.
                           LEAVE.

                       END.

                    ASSIGN aux_regexist = TRUE
                           aux_contador = aux_contador + 1

                           tel_reganter[6] = tel_reganter[5]
                           tel_reganter[5] = tel_reganter[4]
                           tel_reganter[4] = tel_reganter[3]
                           tel_reganter[3] = tel_reganter[2]
                           tel_reganter[2] = tel_reganter[1]
                           tel_reganter[1] =
                           STRING(crawcrd.nrdconta,"zzzz,zzz,9") + "     " +
                           STRING(crawcrd.nrctrcrd,"zzz,zz9") + "    " +
                           STRING(craptlc.vllimcrd,"zzz,zzz,zz9.99") + 
                           "    " +
                           STRING(crawcrd.nrseqdig,"zz,zz9").

                    IF aux_contador = 1   THEN
                       IF aux_flgretor   THEN
                          DO:
                             PAUSE MESSAGE
                      "Tecle <Entra> para continuar ou <Fim> para encerrar".
                             CLEAR FRAME f_lanctos ALL NO-PAUSE.
                          END.
                       ELSE
                          ASSIGN aux_flgretor = TRUE.

                    PAUSE (0).

                    DISPLAY crawcrd.nrdconta 
                            crawcrd.nrctrcrd
                            craptlc.vllimcrd 
                            crawcrd.nrseqdig
                            WITH FRAME f_lanctos.

                    IF aux_contador = 6   THEN
                       ASSIGN aux_contador = 0.
                    ELSE
                       DOWN WITH FRAME f_lanctos.

                END. /* Fim do FOR EACH */

                IF NOT aux_regexist   THEN
                   ASSIGN glb_cdcritic = 11
                          aux_flgretor = TRUE.

                NEXT.

            END.

         ASSIGN glb_nrcalcul = tel_nrdconta.

         RUN fontes/digfun.p.

         IF NOT glb_stsnrcal   THEN
            DO:
                ASSIGN glb_cdcritic = 8.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                NEXT.

            END.

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                            crapass.nrdconta = tel_nrdconta 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                NEXT.

            END.

         FIND FIRST crawcrd WHERE crawcrd.cdcooper = glb_cdcooper   AND 
                                  crawcrd.dtmvtolt = tel_dtmvtolt   AND
                                  crawcrd.cdagenci = tel_cdagenci   AND
                                  crawcrd.cdbccxlt = tel_cdbccxlt   AND
                                  crawcrd.nrdolote = tel_nrdolote   AND
                                  crawcrd.nrdconta = tel_nrdconta   AND
                                  crawcrd.nrctrcrd = tel_nrctrcrd
                                  NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crawcrd   THEN
            DO:
                ASSIGN glb_cdcritic = 90.
                NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                NEXT.

            END.
         ELSE
            ASSIGN tel_nrseqdig = crawcrd.nrseqdig.

         FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND 
                            craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                            craptlc.tpcartao = crawcrd.tpcartao AND
                            craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                            craptlc.dddebito = 0 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE craptlc   THEN
            DO:
                ASSIGN glb_cdcritic = 532.
                NEXT.

            END.

         ASSIGN tel_vllimpro = craptlc.vllimcrd.          

         DISPLAY tel_vllimpro   
                 tel_nrseqdig   
                 WITH FRAME f_lancrd.

      END.   /* FIM do DO WHILE TRUE da consulta */

   ELSE
   IF glb_cddopcao = "E"   THEN
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lancrd.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.

            END.

         UPDATE tel_nrdconta 
                tel_nrctrcrd 
                WITH FRAME f_lancrd.

         ASSIGN glb_nrcalcul = tel_nrdconta.

         RUN fontes/digfun.p.

         IF NOT glb_stsnrcal   THEN
            DO:
                ASSIGN glb_cdcritic = 8.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                NEXT.

            END.

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                            crapass.nrdconta = tel_nrdconta 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                NEXT.

            END.

         IF NOT VALID-HANDLE(h-b1wgen0110) THEN
            RUN sistema/generico/procedures/b1wgen0110.p
                PERSISTENT SET h-b1wgen0110.

         /*Monta a mensagem da operacao para envio no e-mail*/
         ASSIGN aux_dsoperac = "Tentativa de alterar/incluir "       + 
                               "limite de credito na conta "         +
                               STRING(crapass.nrdconta,"zzzz,zzz,9") + 
                               " - CPF/CNPJ " +
                              (IF crapass.inpessoa = 1 THEN
                                  STRING((STRING(crapass.nrcpfcgc,
                                  "99999999999")),"xxx.xxx.xxx-xx")
                               ELSE
                                  STRING((STRING(crapass.nrcpfcgc,
                                  "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

         /*Verifica se o associado esta no cadastro restritivo. Se estiver,
           sera enviado um e-mail informando a situacao*/
         RUN alerta_fraude IN h-b1wgen0110(INPUT glb_cdcooper,
                                           INPUT glb_cdagenci,
                                           INPUT 0, /*nrdcaixa*/
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT glb_dtmvtolt,
                                           INPUT 1, /*ayllos*/
                                           INPUT crapass.nrcpfcgc, 
                                           INPUT crapass.nrdconta,
                                           INPUT 1,
                                           INPUT TRUE, /*bloqueia operacao*/
                                           INPUT 8, /*cdoperac*/
                                           INPUT aux_dsoperac,
                                           OUTPUT TABLE tt-erro).
         
         IF VALID-HANDLE(h-b1wgen0110) THEN
            DELETE PROCEDURE(h-b1wgen0110).
         
         IF RETURN-VALUE <> "OK" THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro THEN
                  ASSIGN glb_cdcritic = tt-erro.cdcritic.
               ELSE
                  MESSAGE "Nao foi possivel verificar o " + 
                          "cadastro restritivo.".

               NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
               NEXT.

            END.

         IF tel_nrctrcrd = 0 THEN
            DO:
                ASSIGN glb_cdcritic = 380.
                NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                NEXT.

            END.

         DO TRANSACTION:

            DO WHILE TRUE:

               FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                                  craplot.dtmvtolt = tel_dtmvtolt   AND
                                  craplot.cdagenci = tel_cdagenci   AND
                                  craplot.cdbccxlt = tel_cdbccxlt   AND
                                  craplot.nrdolote = tel_nrdolote
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF NOT AVAILABLE craplot   THEN
                  IF LOCKED craplot   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                  ELSE
                     ASSIGN glb_cdcritic = 60.
               ELSE
                  IF craplot.tplotmov <> 16   THEN
                     ASSIGN glb_cdcritic = 100.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF glb_cdcritic > 0 THEN
               NEXT.

            DO WHILE TRUE:

               FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper AND 
                                  crawcrd.dtmvtolt = tel_dtmvtolt AND
                                  crawcrd.cdagenci = tel_cdagenci AND
                                  crawcrd.cdbccxlt = tel_cdbccxlt AND
                                  crawcrd.nrdolote = tel_nrdolote AND
                                  crawcrd.nrdconta = tel_nrdconta AND
                                  crawcrd.nrctrcrd = tel_nrctrcrd
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF NOT AVAILABLE crawcrd THEN
                  IF LOCKED crawcrd   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                  ELSE
                     ASSIGN glb_cdcritic = 90.

               LEAVE.

            END.  /* Fim do DO WHILE TRUE */

            IF glb_cdcritic > 0 THEN
               NEXT.

            IF crawcrd.insitcrd <> 1 THEN
               ASSIGN glb_cdcritic = 537.

            FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND 
                               craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                               craptlc.tpcartao = crawcrd.tpcartao AND
                               craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                               craptlc.dddebito = 0 
                               NO-LOCK NO-ERROR.

            IF NOT AVAILABLE craptlc   THEN
               ASSIGN glb_cdcritic = 532.
            ELSE
               ASSIGN tel_vllimpro = craptlc.vllimcrd.           

            IF glb_cdcritic > 0 THEN
               NEXT.

            ASSIGN tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfocr = craplot.vlinfocr
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                   tel_nrseqdig = crawcrd.nrseqdig.

            DISPLAY tel_qtinfoln 
                    tel_vlinfocr 
                    tel_qtcompln 
                    tel_vlcompcr
                    tel_qtdifeln 
                    tel_vldifecr
                    WITH FRAME f_opcao.

            DISPLAY tel_vllimpro   
                    tel_nrseqdig   
                    WITH FRAME f_lancrd.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               ASSIGN aux_confirma = "N".

               ASSIGN glb_cdcritic = 78.
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               ASSIGN glb_cdcritic = 0.
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
               aux_confirma <> "S" THEN
               DO:
                   ASSIGN glb_cdcritic = 79.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   ASSIGN glb_cdcritic = 0.
                   NEXT.

               END.

            ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllimpro
                   craplot.qtcompln = craplot.qtcompln - 1
                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfocr = craplot.vlinfocr
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

                   crawcrd.dtmvtolt = ?
                   crawcrd.cdagenci = 0
                   crawcrd.cdbccxlt = 0
                   crawcrd.nrdolote = 0
                   crawcrd.nrseqdig = 0
                   crawcrd.insitcrd = 0.

         END.   /*  Fim da transacao.  */

         IF glb_cdcritic > 0 THEN
            NEXT.

         RELEASE craplot.
         RELEASE crawcrd.

         IF tel_qtdifeln = 0  AND  tel_vldifecr = 0  THEN
            DO:
                HIDE FRAME f_opcao.
                HIDE FRAME f_lancrd.
                HIDE FRAME f_regant.
                HIDE FRAME f_lanctos.
                HIDE FRAME f_moldura.
                ASSIGN glb_nmdatela = "LOTE".
                RETURN.

            END.

         ASSIGN  tel_nrdconta = 0 tel_nrctrcrd = 0
                 tel_vllimpro = 0 tel_nrseqdig = 0.

         DISPLAY tel_qtinfoln 
                 tel_vlinfocr
                 tel_qtcompln 
                 tel_vlcompcr
                 tel_qtdifeln 
                 tel_vldifecr
                 WITH FRAME f_opcao.

         CLEAR FRAME f_lancrd.

      END.  /*  Fim do DO WHILE TRUE  */
   ELSE
   IF glb_cddopcao = "I"   THEN
      DO:
         DO WHILE TRUE:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF glb_cdcritic > 0   THEN
                  DO:
                      RUN fontes/critic.p.
                      CLEAR FRAME f_lancrd.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0.

                  END.
               ELSE
                  ASSIGN tel_nrdconta = 0
                         tel_nrctrcrd = 0
                         tel_vllimpro = 0.

               DISPLAY tel_nrseqdig 
                       WITH FRAME f_lancrd.

               UPDATE tel_nrdconta 
                      tel_nrctrcrd 
                      tel_vllimpro
                      WITH FRAME f_lancrd

               EDITING:

                   READKEY.
                   IF FRAME-FIELD = "tel_vllimpro"   THEN
                      IF LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                      ELSE
                         APPLY LASTKEY.
                   ELSE
                      APPLY LASTKEY.

               END.  /*  Fim do EDITING  */

               ASSIGN glb_nrcalcul = tel_nrdconta.

               RUN fontes/digfun.p.

               IF NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN glb_cdcritic = 8.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE crapass   THEN
                  DO:
                      ASSIGN glb_cdcritic = 9.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF NOT VALID-HANDLE(h-b1wgen0110) THEN
                  RUN sistema/generico/procedures/b1wgen0110.p
                      PERSISTENT SET h-b1wgen0110.

               /*Monta a mensagem da operacao para envio no e-mail*/
               ASSIGN aux_dsoperac = "Tentativa de alterar/incluir "       + 
                                     "limite de credito na conta "         +
                                     STRING(crapass.nrdconta,"zzzz,zzz,9") + 
                                     " - CPF/CNPJ " +
                                    (IF crapass.inpessoa = 1 THEN
                                        STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                                     ELSE
                                        STRING((STRING(crapass.nrcpfcgc,
                                                "99999999999999")),
                                                "xx.xxx.xxx/xxxx-xx")).
                     
               /*Verifica se o associado esta no cadastro restritivo. Se estiver,
                 sera enviado um e-mail informando a situacao*/
               RUN alerta_fraude IN h-b1wgen0110(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT 0, /*nrdcaixa*/
                                                 INPUT glb_cdoperad,
                                                 INPUT glb_nmdatela,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 1, /*ayllos*/
                                                 INPUT crapass.nrcpfcgc, 
                                                 INPUT crapass.nrdconta,
                                                 INPUT 1,
                                                 INPUT TRUE, /*bloqueia operacao*/
                                                 INPUT 8, /*cdoperac*/
                                                 INPUT aux_dsoperac,
                                                 OUTPUT TABLE tt-erro).
               
               IF VALID-HANDLE(h-b1wgen0110) THEN
                  DELETE PROCEDURE(h-b1wgen0110).
               
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF AVAIL tt-erro THEN
                        ASSIGN glb_cdcritic = tt-erro.cdcritic.
                     ELSE
                        MESSAGE "Nao foi possivel verificar o " + 
                                "cadastro restritivo.".

                     NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                     NEXT.

                  END.

               IF crapass.dtelimin <> ? THEN
                  DO:
                      ASSIGN glb_cdcritic = 410.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               
               { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

               RUN STORED-PROCEDURE pc_busca_modalidade_tipo
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.inpessoa, /* Tipo de pessoa */
                                                    INPUT crapass.cdtipcta, /* Tipo de conta */
                                                   OUTPUT 0,                /* Modalidade */
                                                   OUTPUT "",               /* Flag Erro */
                                                   OUTPUT "").              /* Descrição da crítica */

               CLOSE STORED-PROC pc_busca_modalidade_tipo
                     aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

               ASSIGN aux_cdmodali = 0
                      aux_des_erro = ""
                      aux_dscritic = ""
                      aux_cdmodali = pc_busca_modalidade_tipo.pr_cdmodalidade_tipo 
                                     WHEN pc_busca_modalidade_tipo.pr_cdmodalidade_tipo <> ?
                      aux_des_erro = pc_busca_modalidade_tipo.pr_des_erro 
                                     WHEN pc_busca_modalidade_tipo.pr_des_erro <> ?
                      aux_dscritic = pc_busca_modalidade_tipo.pr_dscritic
                                     WHEN pc_busca_modalidade_tipo.pr_dscritic <> ?.

               IF aux_des_erro = "NOK"  THEN
                   DO:
                      ASSIGN glb_dscritic = aux_dscritic.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.
                   END.
               
               IF CAN-DO("2,3",STRING(aux_cdmodali)) THEN
                  DO:
                      ASSIGN glb_cdcritic = 332.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                  DO:
                      ASSIGN glb_cdcritic = 695.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.
               
               IF CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                  DO:
                      ASSIGN glb_cdcritic = 95.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF crapass.cdsitdct <> 1   AND 
                  crapass.cdsitdct <> 6   THEN
                  DO:
                      ASSIGN glb_cdcritic = 64.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF tel_nrctrcrd = 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 22.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF tel_vllimpro = 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 269.
                      NEXT-PROMPT tel_vllimpro WITH FRAME f_lancrd.
                      NEXT.

                  END.

               FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper   AND 
                                  crawcrd.nrdconta = tel_nrdconta   AND
                                  crawcrd.nrctrcrd = tel_nrctrcrd
                                  USE-INDEX crawcrd1 NO-LOCK NO-ERROR.

               IF NOT AVAILABLE crawcrd THEN
                  DO:
                      ASSIGN glb_cdcritic = 535.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF crawcrd.insitcrd <> 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 536.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               FIND crapadc WHERE crapadc.cdcooper = glb_cdcooper AND 
                                  crapadc.cdadmcrd = crawcrd.cdadmcrd
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE crapadc   THEN
                  DO:
                      ASSIGN glb_cdcritic = 605.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.
                /****** Julio
               IF   crapadc.insitadc <> 0 THEN
                    DO:
                        glb_cdcritic = 607.
                        NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                        NEXT.
                    END.   Julio *******/

               FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND
                                  craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                                  craptlc.tpcartao = crawcrd.tpcartao AND
                                  craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                                  craptlc.dddebito = 0 
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE craptlc   THEN
                  DO:
                      ASSIGN glb_cdcritic = 532.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF craptlc.insittab <> 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 604.
                      NEXT-PROMPT tel_vllimpro WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF craptlc.vllimcrd <> tel_vllimpro THEN
                  DO:
                      ASSIGN glb_cdcritic = 269.
                      NEXT-PROMPT tel_vllimpro WITH FRAME f_lancrd.
                      NEXT.

                  END.

               FIND craptlc WHERE craptlc.cdcooper = glb_cdcooper     AND 
                                  craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                                  craptlc.tpcartao = 0                AND
                                  craptlc.cdlimcrd = 0                AND
                                  craptlc.dddebito = crawcrd.dddebito    
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE craptlc   THEN
                  DO:
                      ASSIGN glb_cdcritic = 520.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF craptlc.insittab <> 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 520.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN   /* F4 OU FIM   */
               LEAVE.   /* Volta pedir a opcao para o operador */

            DO TRANSACTION:

               DO WHILE TRUE:

                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                     craplot.dtmvtolt = tel_dtmvtolt   AND
                                     craplot.cdagenci = tel_cdagenci   AND
                                     craplot.cdbccxlt = tel_cdbccxlt   AND
                                     craplot.nrdolote = tel_nrdolote
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE craplot   THEN
                     IF LOCKED craplot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        ASSIGN glb_cdcritic = 90.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF glb_cdcritic > 0   THEN
                  NEXT.

               ASSIGN tel_nrseqdig = craplot.nrseqdig + 1.

               IF CAN-FIND(crawcrd WHERE
                           crawcrd.cdcooper = glb_cdcooper   AND 
                           crawcrd.dtmvtolt = tel_dtmvtolt   AND
                           crawcrd.cdagenci = tel_cdagenci   AND
                           crawcrd.cdbccxlt = tel_cdbccxlt   AND
                           crawcrd.nrdolote = tel_nrdolote   AND
                           crawcrd.nrdconta = tel_nrdconta   AND
                           crawcrd.nrctrcrd = tel_nrctrcrd
                           USE-INDEX crawcrd2) THEN
                  DO:
                      ASSIGN glb_cdcritic = 92.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF CAN-FIND(crawcrd WHERE
                           crawcrd.cdcooper = glb_cdcooper   AND 
                           crawcrd.dtmvtolt = tel_dtmvtolt   AND
                           crawcrd.cdagenci = tel_cdagenci   AND
                           crawcrd.cdbccxlt = tel_cdbccxlt   AND
                           crawcrd.nrdolote = tel_nrdolote   AND
                           crawcrd.nrseqdig = tel_nrseqdig
                           USE-INDEX crawcrd3) THEN
                  DO:
                      ASSIGN glb_cdcritic = 92.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               DO WHILE TRUE:

                  FIND crawcrd WHERE crawcrd.cdcooper = glb_cdcooper   AND
                                     crawcrd.nrdconta = tel_nrdconta   AND
                                     crawcrd.nrctrcrd = tel_nrctrcrd
                                     USE-INDEX crawcrd1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE crawcrd THEN
                     IF LOCKED crawcrd   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        ASSIGN glb_cdcritic = 535.

                  LEAVE.

               END.

               IF crawcrd.insitcrd <> 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 536.
                      NEXT-PROMPT tel_nrctrcrd WITH FRAME f_lancrd.
                      NEXT.

                  END.

               IF glb_cdcritic > 0   THEN
                  NEXT.

               ASSIGN crawcrd.dtmvtolt = craplot.dtmvtolt
                      crawcrd.cdagenci = craplot.cdagenci
                      crawcrd.cdbccxlt = craplot.cdbccxlt
                      crawcrd.nrdolote = craplot.nrdolote
                      crawcrd.insitcrd = 1
                      crawcrd.nrseqdig = craplot.nrseqdig + 1

                      craplot.nrseqdig = craplot.nrseqdig + 1
                      craplot.qtcompln = craplot.qtcompln + 1

                      tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_nrseqdig = crawcrd.nrseqdig

                      craplot.vlcompcr = craplot.vlcompcr + tel_vllimpro

                      tel_vlinfocr    = craplot.vlinfocr
                      tel_vlcompcr    = craplot.vlcompcr
                      tel_qtdifeln    = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifecr    = craplot.vlcompcr - craplot.vlinfocr.

            END.   /* Fim da transacao */

            IF glb_cdcritic > 0 THEN
               NEXT.

            IF tel_qtdifeln = 0   AND   
               tel_vldifecr = 0   THEN
               DO:
                   HIDE FRAME f_opcao.
                   HIDE FRAME f_lancrd.
                   HIDE FRAME f_regant.
                   HIDE FRAME f_lanctos.
                   HIDE FRAME f_moldura.
                   ASSIGN glb_nmdatela = "LOTE".
                   RETURN.

               END.

            ASSIGN tel_reganter[6] = tel_reganter[5]
                   tel_reganter[5] = tel_reganter[4]
                   tel_reganter[4] = tel_reganter[3]
                   tel_reganter[3] = tel_reganter[2]
                   tel_reganter[2] = tel_reganter[1]
                   tel_reganter[1] =
                           STRING(crawcrd.nrdconta,"zzzz,zzz,9") + "     " +
                           STRING(crawcrd.nrctrcrd,"zzz,zz9") + "    " +
                           STRING(tel_vllimpro,"zzz,zzz,zz9.99") + "    " +
                           STRING(crawcrd.nrseqdig,"zz,zz9")

                   tel_nrseqdig = craplot.nrseqdig + 1.

            DISPLAY tel_qtinfoln  
                    tel_vlinfocr 
                    tel_qtcompln
                    tel_vlcompcr  
                    tel_qtdifeln 
                    tel_vldifecr
                    WITH FRAME f_opcao.

            DISPLAY tel_nrseqdig 
                    WITH FRAME f_lancrd.

            HIDE FRAME f_lanctos.

            DISPLAY tel_reganter[1] 
                    tel_reganter[2] 
                    tel_reganter[3]
                    tel_reganter[4] 
                    tel_reganter[5] 
                    tel_reganter[6]
                    WITH FRAME f_regant.

            RELEASE craplot.
            RELEASE crawcrd.

         END.  /*  Fim do DO WHILE TRUE  */

      END.

   END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

