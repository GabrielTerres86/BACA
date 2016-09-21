/* .............................................................................

   Programa: Fontes/lancapi.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/92.                           Ultima atualizacao: 09/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LANCAP.

   Alteracoes: 30/08/94 - Alterado para nao permitir lancamentos para associados
                          que tenham dtelimin (Deborah).

               15/03/95 - Eliminada a rotina de leitura dos lancamentos
                          (Deborah).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               09/11/98 - Tratar situacao em prejuizo (Deborah). 

               18/02/99 - Nao permitir saques de capital de ativos que 
                          resultem em capital inferior a R$10,00 (Deborah).
                          
               28/05/1999 - Dividir o lancamento em capital inicial e
                            nao permitir lancar apos encerramento da ADMISS
                            (Deborah).
                            
               26/06/2000 - Retirar critica 643 (Odair)    
               
               24/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               27/12/2001 - Alterado para tratar a rotina ver_capital (Edson).

               13/09/2002 - Alterado para tratar o boletim de caixa (Edson).
               
               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               04/07/2005 - Alimentado campo cdcooper da tabela craplct (Diego).
               
               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadm (Diego).

               03/02/2006 - Unificacao dos Bancos - SQLWorks

               13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada 
                            do programa fontes/testa_boletim.p - SQLWorks - 
                            Fernando.

               24/09/2007 - Conversao de rotina ver_capital para BO 
                            (Sidnei/Precise)
                 
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e CAN-FIND" da tabela
                            CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                          
               18/10/2012 - Tratamento para historico 1093 (Tiago).
               
               02/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
               
               05/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/12/2013 - Inclusao de VALIDATE craplct (Carlos)
.............................................................................*/

{ includes/var_online.i } 

{ sistema/generico/includes/var_internet.i }
DEF VAR h-b1wgen0001 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0140 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0155 AS HANDLE                                       NO-UNDO.

DEF SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF SHARED VAR tel_nrdocmto AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF SHARED VAR tel_vllanmto AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR tel_reganter AS CHAR    FORMAT "x(60)" EXTENT 6       NO-UNDO.

DEF SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF SHARED VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF SHARED VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_flgdodia AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF SHARED VAR aux_contador AS INT                                   NO-UNDO.
DEF SHARED VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF SHARED VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF SHARED VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF SHARED VAR aux_vllanmto AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF SHARED VAR aux_inhistor AS INT                                   NO-UNDO.

DEF SHARED VAR aux_qtcotmfx AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vldcotas AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmecot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmicot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vlcmmcot AS DECIMAL                               NO-UNDO.
DEF SHARED VAR aux_vllanmfx AS DECIMAL                               NO-UNDO.

DEF SHARED VAR aux_dtrefcot AS DATE                                  NO-UNDO.

DEF        VAR aux_flgadmis AS LOGICAL                               NO-UNDO.
DEF        VAR aux_sldesblo AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlblqjud AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlresblq AS DECIMAL                               NO-UNDO.

DEF SHARED FRAME f_lancap.
DEF SHARED FRAME f_regant.
DEF SHARED FRAME f_lanctos.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE COLOR MESSAGE " Lancamentos de Capital "
                      FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E ou I)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I",
                                  "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 32 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE (CAN-FIND (crapage WHERE 
                                            crapage.cdcooper = glb_cdcooper  AND
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

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET tel_cdhistor tel_nrdconta tel_nrdocmto tel_vllanmto
          WITH FRAME f_lancap

      EDITING:

               READKEY.
               IF   FRAME-FIELD = "tel_vllanmto"   THEN
                    IF   LASTKEY =  KEYCODE(".")   THEN
                         APPLY 44.
                    ELSE
                         APPLY LASTKEY.
               ELSE
                    APPLY LASTKEY.

      END.

      ASSIGN aux_cdhistor = tel_cdhistor
             aux_nrdconta = tel_nrdconta
             aux_nrdocmto = tel_nrdocmto
             aux_vllanmto = tel_vllanmto
             glb_cdcritic = 0
             glb_dscritic = ""
             glb_dscricpl = "".
       
      FIND craphis WHERE 
           craphis.cdcooper = glb_cdcooper AND
           craphis.cdhistor = tel_cdhistor NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craphis   THEN
           DO:
               glb_cdcritic = 93.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lancap.
           END.
      ELSE
      IF   craphis.tplotmov <> 2   THEN
           DO:  
               glb_cdcritic = 94.
               NEXT-PROMPT tel_cdhistor WITH FRAME f_lancap.
           END.
      ELSE
      DO:
          ASSIGN glb_nrcalcul = tel_nrdconta
                 aux_indebcre = craphis.indebcre
                 aux_inhistor = craphis.inhistor.

          RUN fontes/digfun.p.
          IF   NOT glb_stsnrcal   THEN
               DO:
                   glb_cdcritic = 8.
                   NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
               END.
          ELSE
          IF   tel_nrdocmto = 0   THEN
               DO:
                   glb_cdcritic = 22.
                   NEXT-PROMPT tel_nrdocmto WITH FRAME f_lancap.
               END.
          ELSE
          DO:
              FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                 crapass.nrdconta = tel_nrdconta
                                 NO-LOCK NO-ERROR.

              IF   NOT AVAILABLE crapass   THEN
                   DO:
                       glb_cdcritic = 9.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
                   END.
              ELSE
              IF   crapass.dtelimin <> ? THEN
                   DO:
                       glb_cdcritic = 410.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
                   END.
              ELSE
              IF   LOOKUP(STRING(crapass.cdsitdtl),"5,6,7,8") <> 0   THEN
                   DO:
                       glb_cdcritic = 695.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
                   END.
              ELSE
              IF   LOOKUP(STRING(crapass.cdsitdtl),"2,4,6,8") <> 0   THEN
                   DO:
                       glb_cdcritic = 95.
                       NEXT-PROMPT tel_nrdconta WITH FRAME f_lancap.
                   END.
              ELSE   
              IF   CAN-FIND(craplct WHERE craplct.cdcooper = glb_cdcooper   AND
                                          craplct.dtmvtolt = tel_dtmvtolt   AND
                                          craplct.cdagenci = tel_cdagenci   AND
                                          craplct.cdbccxlt = tel_cdbccxlt   AND
                                          craplct.nrdolote = tel_nrdolote   AND
                                          craplct.nrdconta = tel_nrdconta   AND
                                          craplct.nrdocmto = tel_nrdocmto
                                          USE-INDEX craplct1)   THEN
                   glb_cdcritic = 92.
              ELSE
              IF   (craphis.inhistor = 17) AND
                   (CAN-FIND (FIRST
                             craplct WHERE craplct.cdcooper = glb_cdcooper  AND
                                           craplct.nrdconta = tel_nrdconta  AND
                                           craplct.dtmvtolt = tel_dtmvtolt  AND
                                           craplct.cdhistor = 81
                                           USE-INDEX craplct2))  THEN
                   glb_cdcritic = 218.
          END.
      END.

      FIND FIRST crapmat WHERE crapmat.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE crapmat THEN
           glb_cdcritic = 642.

      IF   glb_cdcritic > 0 THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lancap.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_cdhistor tel_nrdconta
                       tel_nrdocmto tel_vllanmto
                       WITH FRAME f_lancap.
               MESSAGE glb_dscritic.
               NEXT.
           END.

      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        RETURN.  /* Volta pedir a opcao para o operador */

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
         
         LEAVE.
      END.
            
      IF   glb_cdcritic = 0   THEN
           IF   craplot.tplotmov <> 2   THEN
                glb_cdcritic = 213.

      IF   glb_cdcritic = 0   THEN
           DO:
               IF   craplot.nrdcaixa > 0   THEN
                    RUN fontes/testa_boletim.p (INPUT  glb_cdcooper,
                                                INPUT  craplot.dtmvtolt,
                                                INPUT  craplot.cdagenci,
                                                INPUT  craplot.cdbccxlt,
                                                INPUT  craplot.nrdolote,
                                                INPUT  craplot.nrdcaixa,
                                                INPUT  craplot.cdopecxa,
                                                OUTPUT glb_cdcritic).
           END.
      
      aux_flgadmis = FALSE.
      
      FIND crapadm WHERE crapadm.cdcooper = glb_cdcooper  AND
                         crapadm.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.
      
      IF   AVAILABLE crapadm THEN
           aux_flgadmis = TRUE.
      IF   glb_cdcritic = 0   THEN
           DO WHILE TRUE:

              FIND crapcot WHERE crapcot.cdcooper = glb_cdcooper AND
                                 crapcot.nrdconta = tel_nrdconta
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE crapcot   THEN
                   IF   LOCKED crapcot   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 169.
                            LEAVE.
                        END.

              ASSIGN aux_qtcotmfx = crapcot.qtcotmfx
                     aux_vldcotas = crapcot.vldcotas
                     aux_vlcmicot = crapcot.vlcmicot.

              /*** Busca Saldo Bloqueado Judicial ***/
              RUN sistema/generico/procedures/b1wgen0155.p 
                        PERSISTENT SET h-b1wgen0155.

              RUN retorna-valor-blqjud IN h-b1wgen0155
                                   (INPUT glb_cdcooper,
                                    INPUT tel_nrdconta,
                                    INPUT 0, /* fixo - nrcpfcgc */
                                    INPUT 3, /* Bloq. Capital   */
                                    INPUT 4, /* 4 - CAPITAL     */
                                    INPUT glb_dtmvtolt,
                                    OUTPUT aux_vlblqjud,
                                    OUTPUT aux_vlresblq).

              DELETE PROCEDURE h-b1wgen0155.

              
              /* Rotina eliminada em virtude da correcao trimestral

              { includes/lelct.i }   /*  Rotina de calculo do capital */

              IF   glb_cdcritic > 0   THEN
                   LEAVE.
              */

              IF   aux_inhistor = 6   THEN
                   crapcot.vldcotas = crapcot.vldcotas + tel_vllanmto.
              ELSE
              IF  aux_inhistor = 16   THEN
              DO:
                  IF   tel_vllanmto > (aux_vldcotas - aux_vlblqjud)  THEN
                       glb_cdcritic = 203.
                  ELSE
                  DO:
                      IF tel_cdhistor <> 402   THEN
                      DO:
                          
                          RUN sistema/generico/procedures/b1wgen0001.p
                          PERSISTENT SET h-b1wgen0001.
      
                          IF   VALID-HANDLE(h-b1wgen0001)   THEN
                          DO:
                               RUN ver_capital IN h-b1wgen0001
                                                         (INPUT  glb_cdcooper,
                                                          INPUT  tel_nrdconta,
                                                          INPUT  0, /*agencia*/
                                                          INPUT  0, /* caixa */
                                                          tel_vllanmto,
                                                          INPUT  glb_dtmvtolt,
                                                          INPUT  "lancapi",
                                                          INPUT  1, /* AYLLOS */
                                                          OUTPUT TABLE tt-erro).
                               /* Verifica se houve erro */
                               FIND FIRST tt-erro NO-LOCK NO-ERROR.

                               IF   AVAILABLE tt-erro   THEN
                               DO:
                                    ASSIGN glb_cdcritic = tt-erro.cdcritic
                                           glb_dscricpl = tt-erro.dscritic.
                               END.
                               DELETE PROCEDURE h-b1wgen0001.
                               
                               IF  tel_cdhistor = 1093 THEN
                                   DO: 

                                       RUN 
                                        sistema/generico/procedures/b1wgen0140.p
                                        PERSISTENT SET h-b1wgen0140.
        
                                       RUN saldo_procap_desbloqueado 
                                          IN h-b1wgen0140(INPUT  glb_cdcooper,
                                                          INPUT  tel_nrdconta,
                                                          OUTPUT aux_sldesblo).
        
                                       DELETE PROCEDURE h-b1wgen0140.
        
                                       IF  tel_vllanmto > aux_sldesblo THEN
                                           ASSIGN glb_cdcritic = 952
                                                  glb_dscricpl = "".
                                               /* glb_dscricpl = "Saldo R$" +
                                            STRING(aux_sldesblo,"z,zzz,zz9.99").
                                               */
                                   END.
                               
                               /*************************/
                               IF   glb_cdcritic = 0  THEN
                                    crapcot.vldcotas = crapcot.vldcotas - 
                                                       tel_vllanmto.
                      
                          END.
                          /************************************/
                      END.     
                  END.
              END.
              ELSE
              IF   aux_inhistor = 17   THEN
                   DO:
                       IF   tel_vllanmto > aux_vlcmecot   THEN
                            assign glb_cdcritic = 204
                                   glb_dscricpl = string(aux_vlcmecot).
                   END.
              ELSE
              IF   aux_inhistor = 18   THEN
                   DO:
                       IF   tel_vllanmto > aux_vlcmicot   THEN
                            glb_cdcritic = 205.
                   END.
              ELSE
              IF   NOT CAN-DO("6,7,8",STRING(aux_inhistor))   THEN
                   glb_cdcritic = 214.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

      IF   glb_cdcritic > 0 THEN  
           DO:
               RUN fontes/critic.p.
               BELL.
               CLEAR FRAME f_lancap.
               DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                       tel_cdbccxlt tel_nrdolote tel_cdhistor
                       tel_nrdconta tel_nrdocmto tel_vllanmto
                       WITH FRAME f_lancap.
               MESSAGE glb_dscritic glb_dscricpl.
               NEXT.
           END.

      CREATE craplct.
      ASSIGN tel_nrseqdig     = craplot.nrseqdig + 1
             craplct.dtmvtolt = tel_dtmvtolt
             craplct.cdagenci = tel_cdagenci
             craplct.cdbccxlt = tel_cdbccxlt 
             craplct.nrdolote = tel_nrdolote
             craplct.nrdconta = tel_nrdconta
             craplct.nrdocmto = tel_nrdocmto
             craplct.vllanmto = IF   aux_flgadmis = TRUE AND 
                                     aux_vldcotas = 0    AND 
                                     (tel_vllanmto > crapmat.vlcapini) 
                                     THEN (tel_vllanmto - crapmat.vlcapini) 
                                     ELSE tel_vllanmto
             craplct.cdhistor = tel_cdhistor
             craplct.nrseqdig = tel_nrseqdig
             craplct.cdcooper = glb_cdcooper

             craplot.nrseqdig = tel_nrseqdig
             craplot.qtcompln = craplot.qtcompln + 1.
      VALIDATE craplct.

      IF   aux_indebcre = "D"   THEN
           craplot.vlcompdb = craplot.vlcompdb + craplct.vllanmto.
      ELSE
           IF   aux_indebcre = "C"   THEN
                craplot.vlcompcr = craplot.vlcompcr + craplct.vllanmto.

      IF   aux_flgadmis = TRUE AND 
           aux_vldcotas = 0    AND 
           (tel_vllanmto > crapmat.vlcapini)  THEN
           DO:
               CREATE craplct.
               ASSIGN tel_nrseqdig     = craplot.nrseqdig + 1
                      craplct.dtmvtolt = tel_dtmvtolt
                      craplct.cdagenci = tel_cdagenci
                      craplct.cdbccxlt = tel_cdbccxlt 
                      craplct.nrdolote = tel_nrdolote
                      craplct.nrdconta = tel_nrdconta
                      craplct.nrdocmto = (tel_nrdocmto + craplct.nrdolote)
                      craplct.vllanmto = crapmat.vlcapini             
                      craplct.cdhistor = 60
                      craplct.nrseqdig = tel_nrseqdig
                      craplct.cdcooper = glb_cdcooper

                      craplot.nrseqdig = tel_nrseqdig
                      craplot.qtcompln = craplot.qtcompln + 1.

               VALIDATE craplct.

               IF   aux_indebcre = "D"   THEN
                    craplot.vlcompdb = craplot.vlcompdb + craplct.vllanmto.
               ELSE
                    IF   aux_indebcre = "C"   THEN
                         craplot.vlcompcr = craplot.vlcompcr + craplct.vllanmto.
           END.

      ASSIGN tel_qtinfoln = craplot.qtinfoln   tel_qtcompln = craplot.qtcompln
             tel_vlinfodb = craplot.vlinfodb   tel_vlcompdb = craplot.vlcompdb
             tel_vlinfocr = craplot.vlinfocr   tel_vlcompcr = craplot.vlcompcr
             tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

   END.   /* Fim da transacao */

   RELEASE craplot.
   RELEASE craplct.
   RELEASE crapcot.

   IF   tel_qtdifeln = 0  AND  tel_vldifedb = 0  AND  tel_vldifecr = 0   THEN
        DO:
            glb_nmdatela = "LOTE".
            RETURN.                        /* Volta ao lancap.p */
        END.

   ASSIGN tel_reganter[6] = tel_reganter[5]  tel_reganter[5] = tel_reganter[4]
          tel_reganter[4] = tel_reganter[3]  tel_reganter[3] = tel_reganter[2]
          tel_reganter[2] = tel_reganter[1]

          tel_reganter[1] = STRING(tel_cdhistor,"zzz9")               + "  "  +
                            STRING(tel_nrdconta,"zzzz,zzz,9")         + "  "  +
                            STRING(tel_nrdocmto,"zz,zzz,zz9")         + "   " +
                            STRING(tel_vllanmto,"zzz,zzz,zzz,zz9.99") + "   " +
                            STRING(tel_nrseqdig,"zz,zz9").

   ASSIGN tel_cdhistor = 0  tel_nrdconta = 0  tel_nrdocmto = 0
          tel_vllanmto = 0  tel_nrseqdig = tel_nrseqdig + 1.

   DISPLAY tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_vlcompdb tel_vlcompcr
           tel_qtdifeln tel_vldifedb tel_vldifecr
           tel_cdhistor tel_nrdconta tel_nrdocmto
           tel_vllanmto tel_nrseqdig
           WITH FRAME f_lancap.

   HIDE FRAME f_lanctos.

   DISPLAY tel_reganter[1] tel_reganter[2] tel_reganter[3]
           tel_reganter[4] tel_reganter[5] tel_reganter[6]
           WITH FRAME f_regant.

END.

/* .......................................................................... */

