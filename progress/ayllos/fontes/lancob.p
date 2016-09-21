/* .............................................................................

   Programa: Fontes/lancob.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97.                       Ultima atualizacao: 05/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCOB.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze).
               
               30/03/2005 - Tratamento para a importacao do cadastramento
                            dos bloquetos (Ze).

               04/07/2005 - Alimentado campo cdcooper da tabela craplcb (Diego).

               28/09/2005 - Alteracao para Conta/DV (Ze).
               
               26/10/2005 - Aumentar o Campo do Documento (Ze).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 

               27/03/2006 - Alterado a pesquisa do craptab para o crapcco
                            (Julio/Ze) 
                            
               29/01/2007 - Considerar o campo craplcb.nrdconta na busca pelo
                            lancamento (Evandro).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e CAN-FIND" da tabela
                            CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               12/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).
                            
               17/03/2009 - Alterado para incluir o crapcob.cdbanpag (Ze).

               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               07/01/2010 - Alterado format do nrdconta para 8 digitos
                            (Adriano).
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               12/05/2011 - Incluso situação 3 (baixado - cob.reg.) na opcao "I"
                            (Guilherme).
                            
               20/06/2013 - Removido campo tel_vltarifa da tela e sua utilizacao
                            no programa. (Daniel)   
                            
               09/12/2013 - Inclusao de VALIDATE craplcb (Carlos)
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).
               
............................................................................. */

{ includes/var_online.i }

DEF       VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF       VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlinfocr AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"    NO-UNDO.
DEF       VAR tel_qtcompdb AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_vlcompdb AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"    NO-UNDO.
DEF       VAR tel_qtinfodb AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF       VAR tel_vlinfodb AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"    NO-UNDO.
DEF       VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF       VAR tel_vlcompcr AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"    NO-UNDO.
DEF       VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF       VAR tel_vldifecr AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"   NO-UNDO.
DEF       VAR tel_vldifedb AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"   NO-UNDO.
DEF       VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF       VAR tel_nrseqdig AS INT     FORMAT "zzz9"                NO-UNDO.
DEF       VAR tel_reganter AS CHAR    FORMAT "x(75)" EXTENT 6      NO-UNDO.
DEF       VAR tel_nrdctabb AS INT     FORMAT "zzz,zz9,9"           NO-UNDO.
DEF       VAR tel_nrdconta AS INT     FORMAT "zzzz,zz9,9"          NO-UNDO.
DEF       VAR tel_nrcnvcob AS INT     FORMAT "zzzzzzz9"            NO-UNDO.
DEF       VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zz9.99"          NO-UNDO.
DEF       VAR tel_nrdocmto AS INT     FORMAT "zzzzzzzz9"           NO-UNDO.

DEF       VAR aux_cdacesso AS CHAR                                 NO-UNDO.

DEF       VAR ant_flgretor AS LOGICAL                              NO-UNDO.
DEF       VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF       VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF       VAR aux_regexist AS LOGICAL                              NO-UNDO.
DEF       VAR aux_contador AS INT                                  NO-UNDO.
DEF       VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF       VAR tel_cdbancob AS INT     FORMAT "zz9"                 NO-UNDO.

DEF       VAR aux_nrlotant AS INT                                  NO-UNDO.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E ou I)"
                        VALIDATE (CAN-DO("C,E,I", glb_cddopcao)
                                  ,"014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL " PA "
                        HELP "Entre com o codigo do PA"
                        VALIDATE (CAN-FIND(crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper  AND                                            crapage.cdagenci = tel_cdagenci),
                                           "015 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa"
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE (CAN-FIND(crapbcl WHERE 
                                           crapbcl.cdbccxlt = tel_cdbccxlt),
                                           "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote"
                        HELP "Entre com o numero do lote."
                        VALIDATE (tel_nrdolote > 0,
                                  "058 - Numero do lote errado.")

     SKIP(1)
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfocr AT 24 LABEL "Credito"
     tel_vlinfodb AT 51 LABEL "Debito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompcr AT 24 LABEL "Credito"
     tel_vlcompdb AT 51 LABEL "Debito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifecr AT 24 LABEL "Credito"
     tel_vldifedb AT 51 LABEL "Debito"
     SKIP(1)
"      Hist Bco Conta Base Convenio   Conta/DV Documento  Vlr titulo  Seq."
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_cdhistor AT 07 NO-LABEL
                        HELP "Entre com o codigo do historico."
                        VALIDATE (tel_cdhistor > 0 AND
                                  CAN-FIND(craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor),
                                           "093 - Historico errado.")

     tel_cdbancob AT 12 NO-LABEL
                        HELP "Entre com o codigo do Banco."
                        VALIDATE (CAN-FIND(crapban WHERE 
                                           crapban.cdbccxlt = tel_cdbancob),
                                           "057 - Banco nao cadastrado.")

     tel_nrdctabb AT 17 NO-LABEL
                        HELP "Entre com o numero da conta base."

     tel_nrcnvcob AT 27 NO-LABEL
                        HELP "Entre com o numero do convenio."

     tel_nrdconta AT 36 NO-LABEL
                        HELP "Entre com o conta/dv a ser creditado o valor."
                        
     tel_nrdocmto AT 47 NO-LABEL
                        HELP "Entre com o numero do documento."

     tel_vllanmto AT 58 NO-LABEL
                        HELP "Entre com o valor do titulo"
                        VALIDATE(tel_vllanmto > 0, "269 - Valor errado")

     tel_nrseqdig AT 69 NO-LABEL
     WITH ROW 14 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lancob.

FORM tel_reganter[1] AT 3 NO-LABEL  tel_reganter[2] AT 3 NO-LABEL
     tel_reganter[3] AT 3 NO-LABEL  tel_reganter[4] AT 3 NO-LABEL
     tel_reganter[5] AT 3 NO-LABEL  tel_reganter[6] AT 3 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM craplcb.cdhistor AT  2  FORMAT "zzz9"
     craplcb.cdbancob AT  8  FORMAT "zz9"
     craplcb.nrdctabb AT 12  FORMAT "zzz,zz9,9"
     craplcb.nrcnvcob AT 22  FORMAT "zzzzzzz9"
     craplcb.nrdconta AT 31  FORMAT "zzzzzzzz9"
     craplcb.nrdocmto AT 41  FORMAT "zzzzzzzz9"
     craplcb.vllanmto AT 52  FORMAT "zzz,zz9.99"
     craplcb.vltarifa AT 68  FORMAT "zz9.99"
     craplcb.nrseqdig AT 75  FORMAT "zzz9"
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = glb_cdagenci
       tel_cdbccxlt = glb_cdbccxlt
       tel_nrdolote = glb_nrdolote
       aux_flgretor = FALSE
       glb_cdcritic = 0.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
        WITH FRAME f_opcao.

CLEAR FRAME f_lancob ALL NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote
             WITH FRAME f_opcao.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANCOB"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_lancob.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   aux_flgretor = TRUE.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                      craplot.dtmvtolt = tel_dtmvtolt   AND
                      craplot.cdagenci = tel_cdagenci   AND
                      craplot.cdbccxlt = tel_cdbccxlt   AND
                      craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craplot   THEN
        DO:
            glb_cdcritic = 60.
            RUN fontes/critic.p.
            CLEAR FRAME f_lancob.
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            CLEAR FRAME f_opcao.
            DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                    tel_cdbccxlt tel_nrdolote
                    WITH FRAME f_opcao.
            BELL.
            MESSAGE  glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   IF   craplot.tplotmov <> 18   THEN
        DO:
            glb_cdcritic = 590.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   ASSIGN tel_cdhistor = craplot.cdhistor
          tel_nrseqdig = craplot.nrseqdig + 1

          tel_vlinfodb = craplot.vlinfodb
          tel_vlcompdb = craplot.vlcompdb
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_qtinfoln = craplot.qtinfoln
          tel_qtcompln = craplot.qtcompln
          tel_vlinfocr = craplot.vlinfocr
          tel_vlcompcr = craplot.vlcompcr
          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   DISPLAY tel_qtinfoln   tel_qtcompln   tel_vlinfodb
           tel_vlcompdb   tel_vlinfocr   tel_vlcompcr
           tel_qtdifeln   tel_vldifecr   tel_vldifedb
           WITH FRAME f_opcao.

   IF   tel_nrdolote <> aux_nrlotant THEN
        DO:
            HIDE FRAME f_regant.
            CLEAR FRAME f_lanctos ALL NO-PAUSE.
            CLEAR FRAME f_lancob.
            aux_nrlotant = tel_nrdolote.
        END.


   IF   glb_cddopcao = "C" THEN
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
           UPDATE tel_cdbancob tel_nrdctabb tel_nrcnvcob 
                  tel_nrdconta tel_nrdocmto WITH FRAME f_lancob.
           
           IF   tel_nrdocmto = 0   THEN
                DO:
                    ASSIGN aux_regexist = FALSE
                           ant_flgretor = FALSE
                           aux_contador = 0.
        
                    CLEAR FRAME f_lancob .

                    HIDE FRAME f_regant.
           
                    CLEAR FRAME f_lanctos ALL NO-PAUSE.
           
                    FOR EACH craplcb WHERE craplcb.cdcooper = glb_cdcooper   AND
                                           craplcb.dtmvtolt = tel_dtmvtolt   AND
                                           craplcb.cdagenci = tel_cdagenci   AND
                                           craplcb.cdbccxlt = tel_cdbccxlt   AND
                                           craplcb.nrdolote = tel_nrdolote
                                           NO-LOCK USE-INDEX craplcb3:
           
                        ASSIGN aux_regexist = TRUE
                               aux_contador = aux_contador + 1
                   
                               tel_reganter[6] = tel_reganter[5]
                               tel_reganter[5] = tel_reganter[4]
                               tel_reganter[4] = tel_reganter[3]
                               tel_reganter[3] = tel_reganter[2]
                               tel_reganter[2] = tel_reganter[1]
                               tel_reganter[1] = STRING(craplcb.cdhistor,"zzz9")
                               + " " +
                               STRING(craplcb.cdbancob,"zz9") + " " +
                               STRING(craplcb.nrdctabb,"zzz,zz9,9") + " " +
                               STRING(craplcb.nrcnvcob,"zzzzzzz9") + " " +
                               STRING(craplcb.nrdconta,"zzzzzzzz9") + " " +
                               STRING(craplcb.nrdocmto,"zzzzzzzz9") + "  " +
                               STRING(craplcb.vllanmto,"zzz,zz9.99")
                               + "     " +
                               STRING(craplcb.vltarifa,"zz9.99") + " " +
                               STRING(craplcb.nrseqdig,"zzz9").
            
                        IF   aux_contador = 1   THEN
                             IF   ant_flgretor   THEN
                                  DO:
                                     PAUSE MESSAGE
                           "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                     CLEAR FRAME f_lanctos ALL NO-PAUSE.
                                  END.
                             ELSE
                                  ant_flgretor = TRUE.
                        
                        PAUSE (0).
                           
                        DISPLAY craplcb.cdhistor craplcb.cdbancob
                                craplcb.nrdctabb craplcb.nrcnvcob
                                craplcb.nrdconta craplcb.nrdocmto
                                craplcb.vllanmto craplcb.vltarifa
                                craplcb.nrseqdig WITH FRAME f_lanctos.

                        IF   aux_contador = 6   THEN
                             aux_contador = 0.
                        ELSE
                             DOWN WITH FRAME f_lanctos.
                    END.    /* FOR EACH */
                        
                    IF   NOT aux_regexist   THEN
                         glb_cdcritic = 11.
                    
                    IF   glb_cdcritic > 0 THEN
                         DO:
                            RUN fontes/critic.p.
                            BELL.
                            CLEAR FRAME f_lancob NO-PAUSE.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                         END.

                    HIDE FRAME f_lanctos.

                    NEXT.

                END.

           FIND craplcb WHERE craplcb.cdcooper = glb_cdcooper   AND 
                              craplcb.dtmvtolt = tel_dtmvtolt   AND
                              craplcb.cdagenci = tel_cdagenci   AND
                              craplcb.cdbccxlt = tel_cdbccxlt   AND
                              craplcb.nrdolote = tel_nrdolote   AND
                              craplcb.cdbancob = tel_cdbancob   AND
                              craplcb.nrdctabb = tel_nrdctabb   AND
                              craplcb.nrcnvcob = tel_nrcnvcob   AND
                              craplcb.nrdconta = tel_nrdconta   AND
                              craplcb.nrdocmto = tel_nrdocmto   
                              NO-LOCK NO-ERROR.
          
           IF   NOT AVAILABLE craplcb   THEN
                glb_cdcritic = 592.
           ELSE
                ASSIGN tel_cdhistor = craplcb.cdhistor
                       tel_vllanmto = craplcb.vllanmto
                       tel_nrseqdig = craplcb.nrseqdig.
          
           IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    BELL.
                    CLEAR FRAME f_lancob.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.
          
           DISPLAY tel_cdhistor   tel_vllanmto
                   tel_nrseqdig   WITH FRAME f_lancob.
        
              
        END.   /* FIM do DO WHILE TRUE da consulta */
        
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            IF   glb_cdcritic > 0 THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     CLEAR FRAME f_lancob.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.

            UPDATE tel_cdbancob tel_nrdctabb tel_nrcnvcob 
                   tel_nrdconta tel_nrdocmto WITH FRAME f_lancob.

            glb_nrcalcul = tel_nrdctabb.
            RUN fontes/digfun.p.

            IF   NOT glb_stsnrcal   THEN
                 DO:
                     glb_cdcritic = 8.
                     NEXT-PROMPT tel_nrdctabb WITH FRAME f_lancob.
                     NEXT.
                 END.

            glb_nrcalcul = tel_nrdconta.
            RUN fontes/digfun.p.

            IF   NOT glb_stsnrcal   THEN
                 DO:
                     glb_cdcritic = 8.
                     NEXT-PROMPT tel_nrdconta WITH FRAME f_lancob.
                     NEXT.
                 END.

            ASSIGN aux_regexist = FALSE.

            FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper AND
                               crapcco.cddbanco  = tel_cdbancob AND
                               crapcco.nrconven  = tel_nrcnvcob AND
                               crapcco.nrdctabb  = tel_nrdctabb             
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcco THEN
                 DO:
                     glb_cdcritic = 591.
                     NEXT-PROMPT tel_cdbancob WITH FRAME f_numcob.
                 END.
            ELSE
                 aux_regexist = TRUE.

            IF   NOT aux_regexist THEN
                 DO:
                     glb_cdcritic = 586.
                     NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                     NEXT.
                 END.

            IF   tel_nrdocmto = 0 THEN
                 DO:
                     glb_cdcritic = 22.
                     NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancob.
                     NEXT.
                 END.

            IF   NOT CAN-FIND(craplcb WHERE 
                              craplcb.cdcooper = glb_cdcooper     AND
                              craplcb.dtmvtolt = tel_dtmvtolt     AND
                              craplcb.cdagenci = tel_cdagenci     AND
                              craplcb.cdbccxlt = tel_cdbccxlt     AND
                              craplcb.nrdolote = tel_nrdolote     AND
                              craplcb.nrdctabb = tel_nrdctabb     AND
                              craplcb.cdbancob = tel_cdbancob     AND
                              craplcb.nrcnvcob = tel_nrcnvcob     AND
                              craplcb.nrdconta = tel_nrdconta     AND
                              craplcb.nrdocmto = tel_nrdocmto)    THEN
                 DO:
                     glb_cdcritic = 90.
                     NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                     NEXT.
                 END.

            FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper AND 
                               crapcob.cdbandoc = tel_cdbancob AND
                               crapcob.nrdctabb = tel_nrdctabb AND
                               crapcob.nrcnvcob = tel_nrcnvcob AND
                               crapcob.nrdconta = tel_nrdconta AND
                               crapcob.nrdocmto = tel_nrdocmto
                               USE-INDEX crapcob1 NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcob THEN
                 DO:
                     glb_cdcritic = 592.
                     NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancob.
                     NEXT.
                 END.

            IF   crapcob.dtretcob = ? THEN
                 DO:
                     glb_cdcritic = 589.
                     NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                     NEXT.
                 END.

            IF   crapcob.incobran <> 5 THEN
                 DO:
                     glb_cdcritic = 595.
                     NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
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

                  IF   NOT AVAILABLE craplot   THEN
                       IF   LOCKED craplot   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 60.
                  ELSE
                       IF   craplot.tplotmov <> 18   THEN
                            glb_cdcritic = 590.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               DO WHILE TRUE:

                  FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper AND 
                                     crapcob.cdbandoc = tel_cdbancob AND
                                     crapcob.nrdctabb = tel_nrdctabb AND
                                     crapcob.nrcnvcob = tel_nrcnvcob AND
                                     crapcob.nrdconta = tel_nrdconta AND
                                     crapcob.nrdocmto = tel_nrdocmto
                                     USE-INDEX crapcob1
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE crapcob   THEN
                       IF   LOCKED crapcob   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 592.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   glb_cdcritic > 0   THEN
                    NEXT.

               DO WHILE TRUE:

                  FIND craplcb WHERE craplcb.cdcooper = glb_cdcooper AND 
                                     craplcb.dtmvtolt = tel_dtmvtolt AND
                                     craplcb.cdagenci = tel_cdagenci AND
                                     craplcb.cdbccxlt = tel_cdbccxlt AND
                                     craplcb.nrdolote = tel_nrdolote AND
                                     craplcb.nrdctabb = tel_nrdctabb AND
                                     craplcb.cdbancob = tel_cdbancob AND
                                     craplcb.nrcnvcob = tel_nrcnvcob AND
                                     craplcb.nrdconta = tel_nrdconta AND
                                     craplcb.nrdocmto = tel_nrdocmto
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF   NOT AVAILABLE craplcb THEN
                       IF   LOCKED craplcb   THEN
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                       ELSE
                            glb_cdcritic = 90.

                  LEAVE.

               END.  /* Fim do DO WHILE TRUE */

               IF   glb_cdcritic > 0 THEN
                    NEXT.

               ASSIGN tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_vlinfocr = craplot.vlinfocr
                      tel_vlcompcr = craplot.vlcompcr
                      tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                      tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
                      tel_vlcompdb = craplot.vlcompdb
                      tel_vlinfodb = craplot.vlinfodb

                      tel_cdhistor = craplcb.cdhistor
                      tel_cdbancob = craplcb.cdbancob
                      tel_nrcnvcob = craplcb.nrcnvcob
                      tel_vllanmto = craplcb.vllanmto
                      tel_nrdconta = craplcb.nrdconta
                      tel_nrdocmto = craplcb.nrdocmto
                      tel_nrseqdig = craplcb.nrseqdig.

               DISPLAY tel_qtinfoln tel_vlinfocr tel_qtcompln tel_vlcompcr
                       tel_vlinfodb tel_vlcompdb tel_vldifedb
                       tel_qtdifeln tel_vldifecr
                       WITH FRAME f_opcao.

               DISPLAY tel_cdhistor tel_cdbancob tel_nrdctabb tel_nrcnvcob
                       tel_nrdconta tel_nrdocmto tel_vllanmto
                       tel_nrseqdig WITH FRAME f_lancob.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  aux_confirma = "N".

                  glb_cdcritic = 78.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  glb_cdcritic = 0.
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                        glb_cdcritic = 79.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        NEXT.
                    END.

               DELETE craplcb.

               ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllanmto
                      craplot.qtcompln = craplot.qtcompln - 1
                      craplot.vlcompdb = craplot.vlcompdb

                      crapcob.incobran = 0
                      crapcob.dtdpagto = ?
                      crapcob.vldpagto = 0
                      crapcob.indpagto = 0
                      crapcob.cdbanpag = 0
                      crapcob.cdagepag = 0
                      
                      tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_vlinfocr = craplot.vlinfocr
                      tel_vlcompcr = craplot.vlcompcr
                      tel_vlinfodb = craplot.vlinfodb
                      tel_vlcompdb = craplot.vlcompdb
                      tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                      tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb.

            END.   /*  Fim da transacao.  */

            RELEASE craplot.
            RELEASE crapcob.

            IF   tel_qtdifeln = 0  AND  tel_vldifecr = 0  AND
                 tel_vldifedb = 0  THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_lancob.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     glb_nmdatela = "LOTE".
                     RETURN.
                 END.

            ASSIGN  tel_vllanmto = 0
                    tel_nrseqdig = 0.

            DISPLAY tel_qtinfoln tel_vlinfocr tel_vlinfodb
                    tel_qtcompln tel_vlcompcr tel_vlcompdb
                    tel_qtdifeln tel_vldifecr tel_vldifedb
                    WITH FRAME f_opcao.

            CLEAR FRAME f_lancob.
        END.  /*  Fim do DO WHILE TRUE  */
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
             DO WHILE TRUE:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   IF   glb_cdcritic > 0   THEN
                        DO:
                            RUN fontes/critic.p.
                            CLEAR FRAME f_lancob.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                        END.
                   ELSE
                        ASSIGN tel_vllanmto = 0
                               tel_nrdocmto = 0
                               tel_cdhistor = 0
                               tel_cdbancob = 0
                               tel_nrdctabb = 0
                               tel_nrcnvcob = 0
                               tel_nrdconta = 0
                               tel_nrseqdig = 0.
                               

                   DISPLAY tel_nrseqdig WITH FRAME f_lancob.

                   UPDATE tel_cdhistor tel_cdbancob tel_nrdctabb
                          tel_nrcnvcob tel_nrdconta tel_nrdocmto
                          tel_vllanmto
                          WITH FRAME f_lancob

                   EDITING:

                       READKEY.
                       IF   FRAME-FIELD = "tel_vllanmto"   THEN
                            IF   LASTKEY =  KEYCODE(".")   THEN
                                 APPLY 44.
                            ELSE
                                 APPLY LASTKEY.
                       ELSE
                            APPLY LASTKEY.

                   END.  /*  Fim do EDITING  */

                   FIND craphis WHERE
                        craphis.cdcooper = glb_cdcooper AND
                        craphis.cdhistor = tel_cdhistor 
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE craphis THEN
                        DO:
                            glb_cdcritic = 93.
                            NEXT-PROMPT tel_cdhistor WITH FRAME f_lancob.
                            NEXT.
                        END.

                   IF   craphis.tplotmov <> 18 THEN
                        DO:
                            glb_cdcritic = 94.
                            NEXT-PROMPT tel_cdhistor WITH FRAME f_lancob.
                            NEXT.
                        END.

                   glb_nrcalcul = tel_nrdctabb.
                   RUN fontes/digfun.p.

                   IF   NOT glb_stsnrcal   THEN
                        DO:
                            glb_cdcritic = 8.
                            NEXT-PROMPT tel_nrdctabb WITH FRAME f_lancob.
                            NEXT.
                        END.

                   ASSIGN aux_regexist = FALSE.

                   FIND crapcco WHERE crapcco.cdcooper  = glb_cdcooper AND
                                      crapcco.cddbanco  = tel_cdbancob AND
                                      crapcco.nrconven  = tel_nrcnvcob AND
                                      crapcco.nrdctabb  = tel_nrdctabb
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE crapcco   THEN
                        DO:
                            glb_cdcritic = 591.
                            NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                        END.
                   ELSE
                        aux_regexist = TRUE.
                   
                   IF   NOT aux_regexist THEN
                        DO:
                            glb_cdcritic = 586.
                            NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                            NEXT.
                        END.

                   IF   tel_nrdocmto = 0 THEN
                        DO:
                            glb_cdcritic = 22.
                            NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancob.
                            NEXT.
                        END.

                   FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper AND
                                      crapcob.cdbandoc = tel_cdbancob AND
                                      crapcob.nrdctabb = tel_nrdctabb AND
                                      crapcob.nrcnvcob = tel_nrcnvcob AND
                                      crapcob.nrdconta = tel_nrdconta AND
                                      crapcob.nrdocmto = tel_nrdocmto
                                      USE-INDEX crapcob1 NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE crapcob THEN
                        DO:
                            glb_cdcritic = 592.
                            NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancob.
                            NEXT.
                        END.

                   IF   crapcob.dtretcob = ? THEN
                        DO:
                            glb_cdcritic = 589.
                            NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                            NEXT.
                        END.

                   IF   crapcob.incobran <> 0 AND  /* aberto              */
                        crapcob.incobran <> 3 THEN /* baixado (cob. reg.) */
                        DO:
                            glb_cdcritic = 594.
                            NEXT-PROMPT tel_cdbancob WITH FRAME f_lancob.
                            NEXT.
                        END.

                   IF   CAN-FIND(craplcb WHERE 
                                 craplcb.cdcooper = glb_cdcooper AND
                                 craplcb.dtmvtolt = tel_dtmvtolt AND
                                 craplcb.cdagenci = tel_cdagenci AND
                                 craplcb.cdbccxlt = tel_cdbccxlt AND
                                 craplcb.nrdolote = tel_nrdolote AND
                                 craplcb.nrdctabb = tel_nrdctabb AND
                                 craplcb.cdbancob = tel_cdbancob AND
                                 craplcb.nrdconta = tel_nrdconta AND
                                 craplcb.nrcnvcob = tel_nrcnvcob AND
                                 craplcb.nrdocmto = tel_nrdocmto)   THEN
                        DO:
                            glb_cdcritic = 92.
                            NEXT-PROMPT tel_nrdctabb WITH FRAME f_lancob.
                            NEXT.
                        END.

                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN   /* F4 OU FIM   */
                     DO:
                        HIDE FRAME f_opcao.
                        HIDE FRAME f_lancob.
                        HIDE FRAME f_regant.
                        LEAVE.   /* Volta pedir a opcao para o operador */
                     
                     END.

                DO TRANSACTION:

                   DO WHILE TRUE:

                      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                                         craplot.dtmvtolt = tel_dtmvtolt   AND
                                         craplot.cdagenci = tel_cdagenci   AND
                                         craplot.cdbccxlt = tel_cdbccxlt   AND
                                         craplot.nrdolote = tel_nrdolote
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE craplot   THEN
                           IF   LOCKED craplot   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                glb_cdcritic = 90.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   DO WHILE TRUE:

                      FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper AND 
                                         crapcob.cdbandoc = tel_cdbancob AND
                                         crapcob.nrdctabb = tel_nrdctabb AND
                                         crapcob.nrcnvcob = tel_nrcnvcob AND
                                         crapcob.nrdconta = tel_nrdconta AND
                                         crapcob.nrdocmto = tel_nrdocmto
                                         USE-INDEX crapcob1
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF   NOT AVAILABLE crapcob   THEN
                           IF   LOCKED crapcob   THEN
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                           ELSE
                                glb_cdcritic = 592.

                      LEAVE.

                   END.  /*  Fim do DO WHILE TRUE  */

                   IF   glb_cdcritic > 0   THEN
                        NEXT.

                   CREATE craplcb.
                   ASSIGN craplcb.cdagenci = craplot.cdagenci
                          craplcb.cdbccxlt = craplot.cdbccxlt
                          craplcb.cdhistor = tel_cdhistor
                          craplcb.dtmvtolt = craplot.dtmvtolt
                          craplcb.nrdconta = tel_nrdconta
                          craplcb.nrdctabb = tel_nrdctabb
                          craplcb.nrdocmto = tel_nrdocmto
                          craplcb.vllanmto = tel_vllanmto
                          craplcb.nrdolote = craplot.nrdolote
                          craplcb.cdbancob = tel_cdbancob
                          craplcb.nrcnvcob = tel_nrcnvcob
                          craplcb.nrseqdig = craplot.nrseqdig + 1
                          craplcb.cdcooper = glb_cdcooper

                          crapcob.incobran = 5
                          crapcob.vldpagto = tel_vllanmto
                          crapcob.dtdpagto = craplot.dtmvtolt
                          crapcob.indpagto = 2
                          crapcob.cdbanpag = 11
                          crapcob.cdagepag = 0

                          craplot.nrseqdig = craplot.nrseqdig + 1
                          craplot.qtcompln = craplot.qtcompln + 1.

                   VALIDATE craplcb.

                   ASSIGN tel_qtinfoln = craplot.qtinfoln
                          tel_qtcompln = craplot.qtcompln
                          tel_nrseqdig = craplcb.nrseqdig

                          craplot.vlcompdb = craplot.vlcompdb
                          craplot.vlcompcr = craplot.vlcompcr + tel_vllanmto

                          tel_vlinfodb    = craplot.vlinfodb
                          tel_vlcompdb    = craplot.vlcompdb
                          tel_vldifedb    = craplot.vlcompdb - craplot.vlinfodb
                          tel_vlinfocr    = craplot.vlinfocr
                          tel_vlcompcr    = craplot.vlcompcr
                          tel_qtdifeln    = craplot.qtcompln - craplot.qtinfoln
                          tel_vldifecr    = craplot.vlcompcr - craplot.vlinfocr.

                END.   /* Fim da transacao */

                IF   tel_qtdifeln = 0   AND   tel_vldifecr = 0  AND
                     tel_vldifedb = 0   THEN
                     DO:
                         HIDE FRAME f_opcao.
                         HIDE FRAME f_lancob.
                         HIDE FRAME f_regant.
                         HIDE FRAME f_lanctos.
                         HIDE FRAME f_moldura.
                         glb_nmdatela = "LOTE".
                         RETURN.
                     END.

                ASSIGN tel_reganter[6] = tel_reganter[5]
                       tel_reganter[5] = tel_reganter[4]
                       tel_reganter[4] = tel_reganter[3]
                       tel_reganter[3] = tel_reganter[2]
                       tel_reganter[2] = tel_reganter[1]
                       tel_reganter[1] = STRING(tel_cdhistor,"zzz9") + " " +
                                STRING(tel_cdbancob,"zz9") + "  " +
                                STRING(tel_nrdctabb,"zzz,zz9,9") + " " +
                                STRING(tel_nrcnvcob,"zzzzzzz9") + " " +
                                STRING(tel_nrdconta,"zzzz,zz9,9") + " " +
                                STRING(tel_nrdocmto,"zzzzzzzz9") + "  " +
                                STRING(tel_vllanmto,"zzz,zz9.99") + "     " +
                                STRING(tel_nrseqdig,"zzz9")
                       
                       tel_vllanmto = 0

                       tel_nrseqdig = craplot.nrseqdig + 1.

                DISPLAY tel_qtinfoln  tel_vlinfocr tel_qtcompln
                        tel_vlinfodb  tel_vlcompdb tel_vldifedb
                        tel_vlcompcr  tel_qtdifeln tel_vldifecr
                        WITH FRAME f_opcao.

                DISPLAY tel_cdhistor  tel_nrdctabb tel_vllanmto
                        tel_nrseqdig
                        WITH FRAME f_lancob.

                HIDE FRAME f_lanctos.

                DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
                        tel_reganter[4] tel_reganter[5] tel_reganter[6]
                        WITH FRAME f_regant.

             END.  /*  Fim do DO WHILE TRUE  */

        END.
  
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */
 
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        NEXT.
        
    
/* .......................................................................... */

