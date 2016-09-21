/* .............................................................................

   Programa: Fontes/lancap.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Julho/92                            Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCAP.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               09/03/01 - Incluir tratamento do boletim caixa (Margarete).

               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "codigo da agencia." para "codigo do PAC.";
                            VALIDATE de "015 - Agencia nao cadastrada." para
                            "015 - PAC nao cadastrado." (Evandro).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               23/11/2009 - Alteracao Codigo Historico (Kbase).         
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               23/02/2012 - Inclusao da opcao "K" (Adriano).      
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).       
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)               
                                
............................................................................. */

{ includes/var_online.i }

DEF NEW SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF NEW SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF NEW SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF NEW SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF NEW SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF NEW SHARED VAR tel_nrdocmto AS INT     FORMAT "zz,zzz,zz9"          NO-UNDO.
DEF NEW SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR tel_reganter AS CHAR    FORMAT "x(60)" EXTENT 6      NO-UNDO.

DEF NEW SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF NEW SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF NEW SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF NEW SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF NEW SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF NEW SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF NEW SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF NEW SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF NEW SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.

DEF NEW SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF NEW SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF NEW SHARED VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */  NO-UNDO.
DEF NEW SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF NEW SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF NEW SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF NEW SHARED VAR aux_cdhistor AS INT                                  NO-UNDO.
DEF NEW SHARED VAR aux_nrdocmto AS INT                                  NO-UNDO.
DEF NEW SHARED VAR aux_vllanmto AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_indebcre AS CHAR                                 NO-UNDO.
DEF NEW SHARED VAR aux_inhistor AS INT                                  NO-UNDO.

DEF NEW SHARED VAR aux_qtcotmfx AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_vldcotas AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_vlcmecot AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_vlcmicot AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_vlcmmcot AS DECIMAL                              NO-UNDO.
DEF NEW SHARED VAR aux_vllanmfx AS DECIMAL                              NO-UNDO.

DEF NEW SHARED VAR aux_dtrefcot AS DATE                                 NO-UNDO.

DEF NEW SHARED FRAME f_lancap.
DEF NEW SHARED FRAME f_regant.
DEF NEW SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Capital "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, I ou K)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I" OR
                                  glb_cddopcao = "K",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 32 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND(crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper AND 
                                           crapage.cdagenci = tel_cdagenci),
                                           "962 - PA nao cadastrado.")

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
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     "Hist   Conta/dv   Documento              Valor       Seq." AT 12
     SKIP(1)
     tel_cdhistor AT 12 NO-LABEL AUTO-RETURN
                        HELP "Entre com o codigo do historico."
                        VALIDATE (tel_cdhistor > 0 AND
                                  CAN-FIND(craphis WHERE 
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor),
                                           "093 - Historico errado.")

     tel_nrdconta AT 17 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta do associado."

     tel_nrdocmto AT 29 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero do documento."

     tel_vllanmto AT 42 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do lancamento."
                        VALIDATE (tel_vllanmto > 0,
                                  "091 - Valor do lancamento errado.")

     tel_nrseqdig AT 63 NO-LABEL

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lancap.

FORM tel_reganter[1] AT 12 NO-LABEL  tel_reganter[2] AT 12 NO-LABEL
     tel_reganter[3] AT 12 NO-LABEL  tel_reganter[4] AT 12 NO-LABEL
     tel_reganter[5] AT 12 NO-LABEL  tel_reganter[6] AT 12 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplct.cdhistor AT 12  craplct.nrdconta AT 17
     craplct.nrdocmto AT 29  craplct.vllanmto AT 42
     craplct.nrseqdig AT 63
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_cdhistor = 0
       tel_nrdconta = 0
       tel_nrdocmto = 0
       tel_vllanmto = 0
       tel_nrseqdig = 1
       tel_dtmvtolt = glb_dtmvtolt

       aux_flgretor = FALSE
       aux_dtrefcot = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).

IF glb_nmtelant = "LOTE" THEN
   ASSIGN tel_cdagenci = glb_cdagenci
          tel_cdbccxlt = glb_cdbccxlt
          tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao 
        tel_dtmvtolt 
        tel_cdagenci 
        tel_cdbccxlt
        tel_nrdolote 
        tel_cdhistor 
        tel_nrdconta 
        tel_nrdocmto
        tel_vllanmto 
        tel_nrseqdig
        WITH FRAME f_lancap.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:


   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF NOT aux_flgretor AND  
         glb_cdcritic = 0 THEN
         IF tel_cdagenci <> 0 AND
            tel_cdbccxlt <> 0 AND
            tel_nrdolote <> 0 THEN
            LEAVE.
      
      ASSIGN glb_cdcritic = 0.
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE glb_cddopcao
                WITH FRAME f_lancap.

         LEAVE.

      END.


      IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
         LEAVE.

      SET tel_dtmvtolt WHEN glb_cddopcao = "K"
          tel_cdagenci 
          tel_cdbccxlt 
          tel_nrdolote
          WITH FRAME f_lancap.


      IF glb_cddopcao <> "C" AND  
         tel_cdbccxlt = 11   AND     
         tel_cdagenci <> 11  THEN  /* boletim de caixa -   EDSON PA1 */ 
         DO:
             FIND craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                craplot.dtmvtolt = glb_dtmvtolt AND
                                craplot.cdagenci = tel_cdagenci AND
                                craplot.cdbccxlt = tel_cdbccxlt AND
                                craplot.nrdolote = tel_nrdolote
                                NO-LOCK NO-ERROR.

             IF NOT AVAILABLE craplot THEN
                DO: 
                    ASSIGN glb_cdcritic = 60.
                    RUN fontes/critic.p.
                    BELL.
                    DISPLAY glb_cddopcao 
                            tel_dtmvtolt 
                            tel_cdagenci
                            tel_cdbccxlt 
                            tel_nrdolote 
                            WITH FRAME f_lancap.

                    MESSAGE glb_dscritic.
                    NEXT.

                END.

             IF craplot.nrdcaixa > 0 THEN
                DO:
                    FIND LAST crapbcx WHERE 
                              crapbcx.cdcooper = glb_cdcooper     AND
                              crapbcx.dtmvtolt = glb_dtmvtolt     AND
                              crapbcx.cdagenci = craplot.cdagenci AND
                              crapbcx.nrdcaixa = craplot.nrdcaixa AND
                              crapbcx.cdopecxa = craplot.cdopecxa
                              USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
                    
                    IF NOT AVAILABLE crapbcx    THEN
                       DO:
                           ASSIGN glb_cdcritic = 701.
                           RUN fontes/critic.p.
                           BELL.
                           DISPLAY glb_cddopcao 
                                   tel_dtmvtolt 
                                   tel_cdagenci
                                   tel_cdbccxlt 
                                   tel_nrdolote 
                                   WITH FRAME f_lancap.

                           MESSAGE glb_dscritic.
                           NEXT.

                       END. 
                    ELSE
                    IF crapbcx.cdsitbcx = 2   THEN
                       DO:
                           ASSIGN glb_cdcritic = 698.
                           RUN fontes/critic.p.
                           BELL.
                           DISPLAY glb_cddopcao 
                                   tel_dtmvtolt 
                                   tel_cdagenci
                                   tel_cdbccxlt 
                                   tel_nrdolote 
                                   WITH FRAME f_lancap.

                           MESSAGE glb_dscritic.
                           NEXT.

                       END.   

                END.

         END.

      LEAVE.

   END.


   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.
          IF CAPS(glb_nmdatela) <> "LANCAP" THEN
             DO:
                 HIDE FRAME f_lancap.
                 HIDE FRAME f_regant.
                 HIDE FRAME f_lanctos.
                 HIDE FRAME f_moldura.
                 RETURN.

             END.
          ELSE
               NEXT.

      END.


   ASSIGN aux_dtmvtolt = tel_dtmvtolt
          aux_cdagenci = tel_cdagenci
          aux_cdbccxlt = tel_cdbccxlt
          aux_nrdolote = tel_nrdolote
          aux_flgretor = TRUE.


   IF aux_cddopcao <> glb_cddopcao THEN
      DO:
          { includes/acesso.i }
          aux_cddopcao = glb_cddopcao.
      END.


   IF INPUT glb_cddopcao = "A" THEN
      DO: 
          RUN fontes/lancapa.p.

      END.
   ELSE
      IF INPUT glb_cddopcao = "C" THEN
         DO:
             RUN fontes/lancapc.p.
             

         END.
      ELSE
         IF INPUT glb_cddopcao = "E" THEN
            DO:
               RUN fontes/lancape.p.

            END.
         ELSE
            IF INPUT glb_cddopcao = "I" THEN
               DO:
                   RUN fontes/lancapi.p.

               END.
            ELSE 
               IF INPUT glb_cddopcao = "K" THEN
                  DO: 
                      RUN fontes/lancapk.p.

                  END.

   IF glb_nmdatela = "LOTE" THEN
      DO:
          HIDE FRAME f_lancap.
          HIDE FRAME f_regant.
          HIDE FRAME f_lanctos.
          HIDE FRAME f_moldura.
          RETURN.                        /* Retorna a tela LOTE */

      END.

END.

/* .......................................................................... */

