/* .............................................................................

   Programa: Fontes/landpv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/91.                       Ultima atualizacao: 11/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANDPV.

   Alteracoes: 13/06/94 - Alterado para ler a tabela com as contas convenio do
                          Banco do Brasil (Edson).

               21/09/94 - Alterado para permitir a consulta de lancamentos de
                          lotes de data anterior ao movimento (Deborah).

               29/09/94 - Alterado layout de tela e inclusao no campo Alinea
                          (Deborah/Edson).

               01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             12/03/2001 - Incluir tratamento do boletim caixa (Margarete).
               
             14/05/2001 - Incluir opcao D e M (Margarete).

             05/03/2003 - Nao deixar mexer nos lotes de debitos se os mesmos
                          ja foram autenticados.

             14/03/2003 - Incluir tratamento da Concredi (Margarete).

             10/02/2004 - Incluido tres parametros chamada compel_r(Mirtes)
             
             27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

             27/02/2007 - Ajuste para o Bancoob (Magui)
             
             24/04/2007 - Gravar banco compensacao na tabela crawage (David).

             26/02/2009 - Substituir a leitura da tabela craptab pelo 
                          ver_ctace.p para informacoes de conta convenio
                          (Sidnei - Precise IT)
             
             26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                          para o banco/agencia COMPE de CHEQUE (cdagechq e
                          cdbanchq) - (Sidnei - Precise).
                          
             23/03/2011 - Incluido condicao na opcao "I" para nao permitir 
                          inclusoes no lote 10115 (Adriano).
                                     
             17/08/2011 - Criado condicao para nao permitir a exclusao do lote
                          7999 (Adriano).
                          
             30/11/2011 - Tratamento inclusao/exclusao de lancamentos ref. 
                          Deposito/Transferencia Intercoperativa  (Diego).             

             13/03/2012 - Implementado critica para novos numeros de lotes 
                          (Tiago).
                          
             19/04/2012 - Substituido codigo fonte do programa landpv.p pelo 
                          fonte do landpvp.p (Elton).
                          
             13/11/2014 - Removido display do campo tel_nrseqdig no frame 
                          f_landpv.
                          Motivo: Foi necessario voltar o tamanho do campo
                          de valor (tel_vllanmto) para o seu tamanho original.
                          (Chamado 175752) - (Fabricio)
                          
             11/12/2015 - Correcao provisoria para limpar a glb_dscritic
                          (Douglas - Chamado 371886)

............................................................................. */

DEFINE TEMP-TABLE crawage                                            NO-UNDO
       FIELD  cdagenci  LIKE crapage.cdagenci
       FIELD  nmresage  LIKE crapage.nmresage
       FIELD  nmcidade  LIKE crapage.nmcidade 
       FIELD  cdagecbn  LIKE crapage.cdagecbn
       FIELD  cdbanchq  LIKE crapage.cdbanchq.

{ includes/var_online.i }
{ includes/var_landpv.i "NEW" }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0134 AS HANDLE                                       NO-UNDO.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "USUARI"       AND
                   craptab.cdempres = 11             AND
                   craptab.cdacesso = "MAIORESCHQ"   AND
                   craptab.tpregist = 1              NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     ASSIGN glb_vldebcon =  1
            glb_vllimneg = -1.
ELSE
     ASSIGN glb_vldebcon = DECIMAL(SUBSTRING(craptab.dstextab,01,15))
            glb_vllimneg = DECIMAL(SUBSTRING(craptab.dstextab,17,16)).

/*  Le tabela com as contas convenio do Banco do Brasil - Geral  */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 0,
                       OUTPUT aux_lscontas).

IF   aux_lscontas = ""   THEN
     DO:
         glb_cdcritic = 393.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_nmdatela = " ".
         RETURN.
     END.

/*  Le tabela com as contas convenio do Banco do Brasil - talao normal */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 1,
                       OUTPUT aux_lsconta1).

/*  Le tabela com as contas convenio do Banco do Brasil - talao transf.*/

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).

/*  Le tabela com as contas convenio do Banco do Brasil - chq.salario */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "VLCTRMVESP"   AND
                   craptab.tpregist = 0              NO-LOCK NO-ERROR.
IF   AVAILABLE craptab   THEN             
     ASSIGN aux_vlctrmve = DEC(craptab.dstextab).                           

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "I"
       tel_cdhistor = 0
       tel_nrdctabb = 0
       tel_nrdocmto = 0
       tel_vllanmto = 0
       tel_dtliblan = ?
       tel_dtmvtolt = glb_dtmvtolt
       aux_flgretor = FALSE.

IF   glb_nmtelant = "LOTE"   THEN
     ASSIGN tel_cdagenci = glb_cdagenci
            tel_cdbccxlt = glb_cdbccxlt
            tel_nrdolote = glb_nrdolote.

PAUSE(0).

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt
        tel_nrdolote tel_cdhistor tel_nrdctabb tel_cdbaninf
        tel_cdageinf tel_nrdocmto tel_vllanmto tel_dtliblan 
        WITH FRAME f_landpv.

CLEAR FRAME f_regant NO-PAUSE.
CLEAR FRAME f_lanctos_compel NO-PAUSE.
CLEAR FRAME f_consulta_compel NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      SET glb_cddopcao WITH FRAME f_landpv.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF   NOT CAN-DO("K,M",glb_cddopcao)   THEN
              DO:
                  tel_dtmvtolt = glb_dtmvtolt.
                  DISPLAY tel_dtmvtolt WITH FRAME f_landpv.
                  SET tel_cdagenci tel_cdbccxlt tel_nrdolote
                      WITH FRAME f_landpv.
              END.
         ELSE
              SET tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
                  WITH FRAME f_landpv.

         IF   NOT CAN-DO("C,K,M",glb_cddopcao)          AND
              CAN-DO("11,500",STRING(tel_cdbccxlt))   AND
              tel_cdagenci <> 11    THEN  /* boletim de caixa -   EDSON PAC1 */ 
              DO:
                  FIND craplot WHERE craplot.cdcooper = glb_cdcooper    AND
                                     craplot.dtmvtolt = glb_dtmvtolt    AND
                                     craplot.cdagenci = tel_cdagenci    AND
                                     craplot.cdbccxlt = tel_cdbccxlt    AND
                                     craplot.nrdolote = tel_nrdolote
                                     NO-LOCK NO-ERROR.
                                     
                  IF   NOT AVAILABLE craplot   THEN
                       DO: 
                           ASSIGN glb_cdcritic = 60. 
                           RUN fontes/critic.p.
                           BELL.
                           DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                   tel_cdbccxlt tel_nrdolote 
                                   WITH FRAME f_landpv.
                           MESSAGE glb_dscritic.
                           NEXT.
                       END.
                  
                  IF   craplot.cdopecxa <> ""   AND  
                       craplot.nrautdoc <> 0    THEN
                       DO:
                           ASSIGN glb_cdcritic = 750. 
                           RUN fontes/critic.p.
                           BELL.
                           DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci
                                   tel_cdbccxlt tel_nrdolote 
                                   WITH FRAME f_landpv.
                           MESSAGE glb_dscritic.
                           NEXT.
                       END.
                  
                  IF   craplot.nrdcaixa > 0   THEN
                       DO:
                           FIND LAST crapbcx WHERE 
                                     crapbcx.cdcooper = glb_cdcooper        AND
                                     crapbcx.dtmvtolt = glb_dtmvtolt        AND
                                     crapbcx.cdagenci = craplot.cdagenci    AND
                                     crapbcx.nrdcaixa = craplot.nrdcaixa    AND
                                     crapbcx.cdopecxa = craplot.cdopecxa    
                                     USE-INDEX crapbcx2 NO-LOCK NO-ERROR.
                  
                           IF   NOT AVAILABLE crapbcx    THEN
                                DO:
                                    ASSIGN glb_cdcritic = 701. 
                                    RUN fontes/critic.p.
                                    BELL.
                                    DISPLAY glb_cddopcao tel_dtmvtolt
                                            tel_cdagenci
                                            tel_cdbccxlt tel_nrdolote 
                                            WITH FRAME f_landpv.
                                    MESSAGE glb_dscritic.
                                    NEXT.
                                END. 
                           ELSE
                           IF   crapbcx.cdsitbcx = 2   THEN
                                DO:
                                    ASSIGN glb_cdcritic = 698.
                                    RUN fontes/critic.p.
                                    BELL.
                                    DISPLAY glb_cddopcao tel_dtmvtolt
                                            tel_cdagenci
                                            tel_cdbccxlt tel_nrdolote 
                                            WITH FRAME f_landpv.
                                    MESSAGE glb_dscritic.
                                    NEXT.
                                END. 
                       END.
              END.
  
         IF   INPUT glb_cddopcao = "M"   THEN
              DO:
                  IF  NOT CAN-FIND(FIRST crapchd WHERE 
                                   crapchd.cdcooper = glb_cdcooper   AND
                                   crapchd.dtmvtolt = tel_dtmvtolt   AND
                                   crapchd.cdagenci = tel_cdagenci   AND
                                   crapchd.cdbccxlt = tel_cdbccxlt   AND
                                   crapchd.nrdolote = tel_nrdolote)  THEN
                      DO:
                          ASSIGN glb_cdcritic = 338. 
                          RUN fontes/critic.p.
                          BELL.
                          DISPLAY glb_cddopcao tel_dtmvtolt
                                  tel_cdagenci
                                  tel_cdbccxlt tel_nrdolote 
                                  WITH FRAME f_landpv.
                          MESSAGE glb_dscritic.
                          NEXT.
                      END.
              END.
         
         IF   INPUT glb_cddopcao = "I"   OR
              INPUT glb_cddopcao = "E"   THEN
              DO:
                  /*** Magui 13/09/2002 nao mexer lotes gerados pelo caixa ***/
                  IF   tel_nrdolote >= 11000   AND
                       tel_nrdolote <= 29999   THEN  /*Debito Trf. Intercoop*/
                       DO:
                           ASSIGN glb_cdcritic = 261.
                           RUN fontes/critic.p.
                           DISPLAY glb_cddopcao tel_dtmvtolt
                                   tel_cdagenci
                                   tel_cdbccxlt tel_nrdolote 
                                   WITH FRAME f_landpv.
                           MESSAGE glb_dscritic.
                           NEXT.
                       END.

                  IF   tel_nrdolote = 10115 OR  /*TED/TEC*/ 
                       tel_nrdolote = 10118 OR  /*Credito Dep. Intercoop*/
                       tel_nrdolote = 10119 OR  /*Deb. Tarfia Trf. Intercoop*/
                       tel_nrdolote = 10120 THEN  /*Credito Trf. Intercoop.*/
                       DO:
                           ASSIGN glb_cdcritic = 261.
                           RUN fontes/critic.p.
                           DISPLAY glb_cddopcao tel_dtmvtolt
                                   tel_cdagenci
                                   tel_cdbccxlt tel_nrdolote 
                                   WITH FRAME f_landpv.
                           MESSAGE glb_dscritic.
                           NEXT.
                       END.
                  
                  RUN sistema/generico/procedures/b1wgen0134.p
                                   PERSISTENT SET h-b1wgen0134.

                  RUN valida_lote_emprst_tipo1 IN h-b1wgen0134
                        (INPUT glb_cdcooper,
                         INPUT glb_cdagenci,
                         INPUT 0,
                         INPUT 0,
                         INPUT tel_nrdolote,
                         OUTPUT TABLE tt-erro).

                  DELETE PROCEDURE h-b1wgen0134.
                
                  IF RETURN-VALUE = "OK"   THEN
                     DO:

                         ASSIGN glb_cdcritic = 261.
                         RUN fontes/critic.p.
                         DISPLAY glb_cddopcao tel_dtmvtolt
                                 tel_cdagenci
                                 tel_cdbccxlt tel_nrdolote 
                                 WITH FRAME f_landpv.
                         MESSAGE glb_dscritic.
                         NEXT.

                     END.

              END.
                  
         LEAVE.

      END. /* Fim do WHILE TRUE mais interno */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           NEXT.

      LEAVE.

   END. /* Fim do WHILE TRUE */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "LANDPV"   THEN
                 DO:
                     HIDE FRAME f_landpv.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_compel.
                     HIDE FRAME f_lanctos_compel.
                     HIDE FRAME f_consulta_compel.
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

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.
        
   /*
   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            RUN fontes/landpva.p.
        END.
   ELSE  */
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 RUN fontes/landpvc.p.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "E"   THEN
                  DO:
                      IF   tel_nrdolote = 4500  OR
                           tel_nrdolote = 7999  THEN 
                           DO:
                               glb_cdcritic = 650.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.
                           END.

                      RUN fontes/landpve.p.
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "I"   THEN
                       DO:
                           ASSIGN glb_cdcritic = 0
                                  glb_dscritic = "".
                           RUN fontes/landpvi.p.
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "K"  THEN
                            DO:
                                RUN fontes/landpvk.p.
                            END.
                       ELSE
                            IF   INPUT glb_cddopcao = "D"   THEN
                                 DO:
                                     RUN fontes/landpvr.p.
                                 END.
                            ELSE
                                 IF   INPUT glb_cddopcao = "M"   THEN
                                      DO:
                                         EMPTY TEMP-TABLE crawage.
                                         
                                         FOR EACH crapage WHERE 
                                                  crapage.cdcooper =
                                                  glb_cdcooper NO-LOCK:
                                             
                                             CREATE crawage.
                                             ASSIGN  crawage.cdbanchq =
                                                     crapage.cdbanchq
                                                     crawage.cdagenci =
                                                     crapage.cdagenci
                                                     crawage.nmresage =
                                                     crapage.nmresage.
                                          
                                          END. 
                                          
                                          RUN fontes/compel_r.p (tel_dtmvtolt,
                                                                 tel_cdagenci,
                                                                 tel_cdbccxlt,
                                                                 tel_nrdolote,
                                                                 FALSE,
                                                      INPUT TABLE crawage,
                                                      INPUT YES,
                                                      INPUT NO).  
                                      END.
                                      
   IF   glb_nmdatela = "LOTE"   THEN
        DO:
            HIDE FRAME f_landpv.
            HIDE FRAME f_regant.
            HIDE FRAME f_lanctos.
            HIDE FRAME f_compel.
            HIDE FRAME f_lanctos_compel.
            HIDE FRAME f_consulta_compel.
            HIDE FRAME f_moldura.
            RETURN.                        /* Retorna a tela LOTE */
        END.
END.

/* .......................................................................... */

