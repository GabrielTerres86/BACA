/* .............................................................................

   Programa: Fontes/lancdc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                       Ultima atualizacao: 12/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCDC.

   Alteracoes: 04/08/2003 - Inclusao do registro na crapmcr (Julio).
               
               20/07/2004 - Efetuar Critica valor Utilizado(Mirtes)
               
               14/10/2004 - Obter Risco do Rating(Associado)/Verificar 
                            Atualizacao do Rating(Evandro).
               
               02/12/2004 - Nao permitir limite de desconto para associados
                            demitidos (Edson).

               18/05/2005 - Alterada tabela craptab por crapcop (Diego).

               04/07/2005 - Alimentado campo cdcooper das tabelas crapmcr,
                            crapcdc (Diego).
                              
               26/07/2005 - Retirar atualizacao Rating para valores menores
                            que 50.000(Mirtes).

               08/08/2005 - Verificar valores utilizados(substituicao de
                            contratos)(Mirtes)
 
               25/08/2005 - Valores utilizados(acerto mensagens)(Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               06/01/2006 - Quando excluir o desconto, excluir o registro
                            de microfilmagem (Magui).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
               24/10/2006 - Mostra mensagem quando valor for maior do que o
                            valor parametrizado na TAB033 (Elton).

               26/04/2007 - Revisao do RATING se valor da operacao for maior
                            que 5% do PR da cooperativa (David).
               
               13/07/2007 - Alterado para atualizar o valor computado na
                            ocorrencia de uma exclusao de lancamento (Elton). 
                            
               15/10/2009 - Alterada chave de acesso a tabela crapras
                            (Gabriel).         
                            
               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               20/03/2012 - Alimentado o campo 'tpctrlim' da CRAPCDC com valor
                            fixo de 2 (Descto chqs). (Lucas)
                            
               29/11/2012 - Ajustes referentes ao Projeto GE (Lucas R.).
               
               30/04/2013 - Ajuste no layout do frame f_grupo_economico 
                            (Adriano).
               
               09/12/2013 - Inclusao de VALIDATE crapmcr e crapcdc (Carlos)
               
               25/06/2014 - Exclusao da temp table tt-grupo-economico 
                            para uso da temp-table tt-grupo na b1wgen0138tt.
                            (Chamado 130880) - (Tiago Castro - RKAM)
               
               12/09/2014 - Alteração da Nomeclatura para PA (Vanessa).

 ............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0138tt.i }

DEF VAR tel_dtmvtolt       AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF VAR tel_cdagenci       AS INT     FORMAT "zz9"                  NO-UNDO.
DEF VAR tel_cdbccxlt       AS INT     FORMAT "zz9"                  NO-UNDO.
DEF VAR tel_nrdolote       AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR tel_qtinfoln       AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF VAR tel_vlinfocr       AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_qtcompln       AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF VAR tel_vlcompcr       AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF VAR tel_qtdifeln       AS INT     FORMAT "zz,zz9-"              NO-UNDO.
DEF VAR tel_vldifecr       AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF VAR tel_nrseqdig       AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF VAR tel_reganter       AS CHAR    FORMAT "x(76)" EXTENT 6       NO-UNDO.
                       
DEF VAR tel_nrdconta       AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF VAR tel_nrctrlim       AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF VAR tel_vllimite       AS DECIMAL FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
                       
DEF VAR aux_confirma       AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF VAR aux_flgerros       AS LOGICAL                               NO-UNDO.
DEF VAR aux_flgretor       AS LOGICAL                               NO-UNDO.
DEF VAR aux_regexist       AS LOGICAL                               NO-UNDO.
                       
DEF VAR aux_contador       AS INT                                   NO-UNDO.
DEF VAR aux_nrlotant       AS INT                                   NO-UNDO.
                       
DEF VAR aux_cddopcao       AS CHAR                                  NO-UNDO.
DEF VAR aux_valor          AS DEC                                   NO-UNDO.

DEF VAR aux_aprovavl       AS LOG  FORMAT "Sim/Nao"                 NO-UNDO.
DEF VAR aux_vlr_maxleg     AS DEC                                   NO-UNDO.
DEF VAR aux_vlr_maxutl     AS DEC                                   NO-UNDO.
DEF VAR aux_vlr_minscr     AS DEC                                   NO-UNDO.
DEF VAR aux_vlr_excedido   AS LOG                                   NO-UNDO.
                           
DEF VAR aux_par_nrdconta   AS INT                                   NO-UNDO.
DEF VAR aux_par_dsctrliq   AS CHAR                                  NO-UNDO.
DEF VAR aux_par_vlutiliz   AS DEC                                   NO-UNDO.
                           
DEF VAR h-b1wgen0043       AS HANDLE                                NO-UNDO.
DEF VAR h-b1wgen0138        AS HANDLE                               NO-UNDO.
                                                                
DEF VAR aux_nrdgrupo        AS INT                                  NO-UNDO.
DEF VAR aux_dsdrisgp        AS CHAR                                 NO-UNDO.
DEF VAR aux_gergrupo        AS CHAR                                 NO-UNDO.
DEF VAR aux_riscogrp        AS CHAR FORMAT "X(2)"                   NO-UNDO.
DEF VAR aux_vlutiliz        AS DEC                                  NO-UNDO.
DEF VAR aux_pertengp        AS LOG                                  NO-UNDO.
DEF VAR aux_qtctarel        AS INT  FORMAT "zz9"                    NO-UNDO.

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
     tel_qtinfoln AT 12 LABEL "Informado:Qtd"
     tel_vlinfocr AT 38 LABEL "Credito"
     SKIP
     tel_qtcompln AT 12 LABEL "Computado:Qtd"
     tel_vlcompcr AT 38 LABEL "Credito"
     SKIP
     tel_qtdifeln AT 12 LABEL "Diferenca:Qtd"
     tel_vldifecr AT 38 LABEL "Credito"
     SKIP(1)
     "Conta/dv     Contrato                            Valor" AT  4
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_nrdconta AT  2 NO-LABEL
                        HELP "Entre com o numero da conta/dv do associado."

     tel_nrctrlim AT 15 NO-LABEL
                        HELP "Entre com o numero contrato de limite."

     tel_vllimite AT 44 NO-LABEL
                        HELP "Entre com o valor do limite de desconto."

     WITH ROW 14 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lancdc.

FORM tel_reganter[1] AT 2 NO-LABEL  tel_reganter[2] AT 2 NO-LABEL
     tel_reganter[3] AT 2 NO-LABEL  tel_reganter[4] AT 2 NO-LABEL
     tel_reganter[5] AT 2 NO-LABEL  tel_reganter[6] AT 2 NO-LABEL
     WITH ROW 15 COLUMN 2 OVERLAY NO-BOX NO-LABELS FRAME f_regant.

FORM crapcdc.nrdconta AT  2
     crapcdc.nrctrlim AT 15 FORMAT "zz,zzz,zz9"
     crapcdc.vllimite AT 44
     WITH ROW 15 COLUMN 2 OVERLAY NO-LABEL NO-BOX 6 DOWN FRAME f_lanctos.

DEF QUERY q-grupo-economico FOR tt-grupo.
    
DEF BROWSE b-grupo-economico QUERY q-grupo-economico
    DISPLAY tt-grupo.nrctasoc
    WITH 3 DOWN NO-LABELS NO-BOX WIDTH 15 OVERLAY.

FORM SKIP(1)
     "Conta"                                      AT 7 
     tel_nrdconta                                 
     "Pertence a Grupo Economico."               
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP                                         
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)                                      
     "Grupo Possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"
     SKIP
     "-------------------------------------"      AT 7
     SKIP
     b-grupo-economico                            AT 18
        HELP "Pressione ENTER / F4 ou END p/ sair."
     WITH ROW 7 CENTERED NO-LABELS OVERLAY WIDTH 57 FRAME f_grupo_economico.

VIEW FRAME f_moldura.

PAUSE(0).

ON RETURN OF b-grupo-economico
   DO:
       APPLY "GO".
   END.    

ASSIGN glb_cddopcao = "I"
       tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = glb_cdagenci
       tel_cdbccxlt = glb_cdbccxlt
       tel_nrdolote = glb_nrdolote
       aux_flgretor = FALSE
       glb_cdcritic = 0.

DISPLAY glb_cddopcao tel_dtmvtolt tel_cdagenci tel_cdbccxlt tel_nrdolote
        WITH FRAME f_opcao.

CLEAR FRAME f_lancdc ALL NO-PAUSE.

NEXT-PROMPT tel_cdagenci WITH FRAME f_opcao.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   NOT aux_flgretor  
      AND  glb_cdcritic = 0   THEN
           IF   tel_cdagenci <> 0   AND
                tel_cdbccxlt <> 0   AND
                tel_nrdolote <> 0   THEN
                LEAVE.

      ASSIGN glb_cdcritic = 0.

      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_nrdolote
             WITH FRAME f_opcao.
             
      IF   tel_cdbccxlt = 11   THEN
           DO:
               MESSAGE "NAO PODE SER DO CAIXA".
               NEXT.
           END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.
          IF   CAPS(glb_nmdatela) <> "lancdc"   THEN
               DO:
                   HIDE FRAME f_opcao.
                   HIDE FRAME f_lancdc.
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
          CLEAR FRAME f_lancdc.
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

   IF craplot.tplotmov <> 27   THEN
      DO:
          ASSIGN glb_cdcritic = 62.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic .
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
          CLEAR FRAME f_lancdc.
          ASSIGN aux_nrlotant = tel_nrdolote.

      END.

   IF glb_cddopcao = "C" THEN
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lancdc.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.

            END.

         UPDATE tel_nrdconta 
                tel_nrctrlim 
                WITH FRAME f_lancdc.

         IF tel_nrdconta = 0 AND tel_nrctrlim = 0   THEN
            DO:
                ASSIGN aux_flgerros = FALSE
                       aux_regexist = FALSE
                       aux_flgretor = FALSE
                       aux_contador = 0.

                CLEAR FRAME f_lancdc .

                HIDE FRAME f_regant.

                CLEAR FRAME f_lanctos ALL NO-PAUSE.

                FOR EACH crapcdc WHERE crapcdc.cdcooper = glb_cdcooper   AND
                                       crapcdc.dtmvtolt = tel_dtmvtolt   AND
                                       crapcdc.cdagenci = tel_cdagenci   AND
                                       crapcdc.cdbccxlt = tel_cdbccxlt   AND
                                       crapcdc.nrdolote = tel_nrdolote
                                       USE-INDEX crapcdc2 NO-LOCK:

                    ASSIGN aux_regexist = TRUE
                           aux_contador = aux_contador + 1

                           tel_reganter[6] = tel_reganter[5]
                           tel_reganter[5] = tel_reganter[4]
                           tel_reganter[4] = tel_reganter[3]
                           tel_reganter[3] = tel_reganter[2]
                           tel_reganter[2] = tel_reganter[1]
                           tel_reganter[1] =
                              STRING(crapcdc.nrdconta,"zzzz,zzz,9") + "  " +
                              STRING(crapcdc.nrctrlim,"zzz,zzz,zz9") +
                              "   " +
                              STRING(crapcdc.vllimite,"zzz,zz9.99").

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

                    DISPLAY crapcdc.nrdconta 
                            crapcdc.nrctrlim
                            crapcdc.vllimite
                            WITH FRAME f_lanctos.

                    IF aux_contador = 6   THEN
                       aux_contador = 0.
                    ELSE
                       DOWN WITH FRAME f_lanctos.

                END. /* Fim do FOR EACH */

                IF NOT aux_regexist   THEN
                   glb_cdcritic = 11.

                NEXT.

            END.

         ASSIGN glb_nrcalcul = tel_nrdconta.

         RUN fontes/digfun.p.

         IF NOT glb_stsnrcal   THEN
            DO:
                ASSIGN glb_cdcritic = 8.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                NEXT.

            END.

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                            crapass.nrdconta = tel_nrdconta 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                NEXT.

            END.

         IF crapass.dtdemiss <> ?   THEN
            DO:
                ASSIGN glb_cdcritic = 75.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                NEXT.

            END.
         
         FIND crapcdc WHERE crapcdc.cdcooper = glb_cdcooper   AND 
                            crapcdc.dtmvtolt = tel_dtmvtolt   AND
                            crapcdc.cdagenci = tel_cdagenci   AND
                            crapcdc.cdbccxlt = tel_cdbccxlt   AND
                            crapcdc.nrdolote = tel_nrdolote   AND
                            crapcdc.nrdconta = tel_nrdconta   AND
                            crapcdc.nrctrlim = tel_nrctrlim
                            USE-INDEX crapcdc1 NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapcdc   THEN
            DO:
                ASSIGN glb_cdcritic = 90.
                NEXT-PROMPT tel_nrctrlim WITH FRAME f_lancdc.
                NEXT.

            END.

         ASSIGN tel_vllimite = crapcdc.vllimite
                tel_nrseqdig = crapcdc.nrseqdig.
                 
         DISPLAY tel_vllimite 
                 tel_nrseqdig 
                 WITH FRAME f_lancdc.

      END.   /* FIM do DO WHILE TRUE da consulta */
   ELSE
   IF glb_cddopcao = "E"   THEN
      EXCLUSAO:
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         IF glb_cdcritic > 0 THEN
            DO:
                RUN fontes/critic.p.
                BELL.
                CLEAR FRAME f_lancdc.
                MESSAGE glb_dscritic.
                ASSIGN glb_cdcritic = 0.

            END.

         UPDATE tel_nrdconta 
                tel_nrctrlim 
                WITH FRAME f_lancdc.

         ASSIGN glb_nrcalcul = tel_nrdconta.

         RUN fontes/digfun.p.

         IF NOT glb_stsnrcal   THEN
            DO:
                ASSIGN glb_cdcritic = 8.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                NEXT.

            END.

         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND 
                            crapass.nrdconta = tel_nrdconta 
                            NO-LOCK NO-ERROR.

         IF NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN glb_cdcritic = 9.
                NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                NEXT.

            END.

         IF tel_nrctrlim = 0 THEN
            DO:
                ASSIGN glb_cdcritic = 380.
                NEXT-PROMPT tel_nrctrlim WITH FRAME f_lancdc.
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
                  IF craplot.tplotmov <> 27   THEN
                     ASSIGN glb_cdcritic = 100.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF glb_cdcritic > 0 THEN
               NEXT.

            DO WHILE TRUE:

               FIND crapcdc WHERE crapcdc.cdcooper = glb_cdcooper   AND 
                                  crapcdc.dtmvtolt = tel_dtmvtolt   AND
                                  crapcdc.cdagenci = tel_cdagenci   AND
                                  crapcdc.cdbccxlt = tel_cdbccxlt   AND
                                  crapcdc.nrdolote = tel_nrdolote   AND
                                  crapcdc.nrdconta = tel_nrdconta   AND
                                  crapcdc.nrctrlim = tel_nrctrlim
                                  USE-INDEX crapcdc1
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF NOT AVAILABLE crapcdc THEN
                  IF LOCKED crapcdc   THEN
                     DO:
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
                  ELSE
                     DO:
                         ASSIGN glb_cdcritic = 90.
                         LEAVE.
                     END.

               FIND FIRST crapbdc WHERE crapbdc.cdcooper = glb_cdcooper     AND
                                        crapbdc.nrdconta = crapcdc.nrdconta AND
                                        crapbdc.nrctrlim = crapcdc.nrctrlim
                                        NO-LOCK NO-ERROR.
                          
               IF AVAILABLE crapbdc   THEN
                  DO:
                      MESSAGE "Ja existem borderos lancados para este"
                              "contrato.".
                      ASSIGN glb_cdcritic = 999.
                      LEAVE.

                  END.
               
               DO WHILE TRUE:

                  FIND craplim WHERE craplim.cdcooper = glb_cdcooper   AND 
                                     craplim.nrdconta = tel_nrdconta   AND
                                     craplim.nrctrlim = tel_nrctrlim   AND
                                     craplim.tpctrlim = 2
                                     EXCLUSIVE-LOCK NO-ERROR.

                  IF NOT AVAILABLE craplim   THEN
                     IF LOCKED craplim   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            ASSIGN glb_cdcritic = 484.
                            LEAVE.

                        END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               LEAVE.

            END.  /* Fim do DO WHILE TRUE */

            IF glb_cdcritic > 0 THEN
               NEXT.

            ASSIGN tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfocr = craplot.vlinfocr
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                   tel_nrseqdig = crapcdc.nrseqdig.

            DISPLAY tel_qtinfoln 
                    tel_vlinfocr 
                    tel_qtcompln 
                    tel_vlcompcr
                    tel_qtdifeln 
                    tel_vldifecr
                    WITH FRAME f_opcao.

            DISPLAY tel_nrseqdig 
                    WITH FRAME f_lancdc.

            /* Confirmar operacao */
            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF aux_confirma <> "S"   THEN
               NEXT.

                
            ASSIGN tel_vllimite  = crapcdc.vllimite. 
            
            DELETE crapcdc.    

            /*** Eliminar registro de microfilmagem ***/
            FIND crapmcr WHERE crapmcr.cdcooper = glb_cdcooper     AND 
                               crapmcr.nrdconta = craplim.nrdconta AND
                               crapmcr.nrcontra = craplim.nrctrlim AND
                               crapmcr.tpctrmif = 2                AND
                               crapmcr.tpctrlim = craplim.tpctrlim 
                               EXCLUSIVE-LOCK NO-ERROR.
                               
            IF AVAILABLE crapmcr   THEN
               DELETE crapmcr.

            ASSIGN craplot.vlcompcr = craplot.vlcompcr - tel_vllimite  
                   craplot.qtcompln = craplot.qtcompln - 1
                   tel_qtinfoln = craplot.qtinfoln
                   tel_qtcompln = craplot.qtcompln
                   tel_vlinfocr = craplot.vlinfocr
                   tel_vlcompcr = craplot.vlcompcr
                   tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
                   tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
                   
                   craplim.insitlim = 1
                   craplim.dtinivig = ?
                   craplim.dtfimvig = ?.
            
            IF NOT VALID-HANDLE(h-b1wgen0043) THEN
               RUN sistema/generico/procedures/b1wgen0043.p       
                   PERSISTENT SET h-b1wgen0043.
            
            /* Voltar atras Rating */
            RUN volta-atras-rating IN h-b1wgen0043 (INPUT glb_cdcooper,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT glb_dtmvtopr,
                                                    INPUT tel_nrdconta,
                                                    INPUT 2, /* Descto. Cheque*/
                                                    INPUT tel_nrctrlim,
                                                    INPUT 1,
                                                    INPUT 1,
                                                    INPUT glb_nmdatela,
                                                    INPUT glb_inproces,
                                                    INPUT FALSE,
                                                    OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen0043) THEN
               DELETE OBJECT h-b1wgen0043.

            IF RETURN-VALUE <> "OK"   THEN
               DO:
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.

                   IF AVAILABLE tt-erro   THEN
                      DO:
                          MESSAGE tt-erro.dscritic.
                          PAUSE 3 NO-MESSAGE.
                          UNDO , NEXT EXCLUSAO.

                      END.

               END.
                   
         END.   /*  Fim da transacao.  */

         RELEASE craplot.

         IF tel_qtdifeln = 0  AND  tel_vldifecr = 0  THEN
            DO:
                HIDE FRAME f_opcao.
                HIDE FRAME f_lancdc.
                HIDE FRAME f_regant.
                HIDE FRAME f_lanctos.
                HIDE FRAME f_moldura.
                ASSIGN glb_nmdatela = "LOTE".
                RETURN.

            END.

         ASSIGN  tel_nrdconta = 0 tel_nrctrlim = 0
                 tel_vllimite = 0

                 tel_nrseqdig = 0.

         DISPLAY tel_qtinfoln 
                 tel_vlinfocr
                 tel_qtcompln 
                 tel_vlcompcr
                 tel_qtdifeln 
                 tel_vldifecr
                 WITH FRAME f_opcao.

         CLEAR FRAME f_lancdc.

      END.  /*  Fim do DO WHILE TRUE  */
   ELSE                      
   IF glb_cddopcao = "I"   THEN
      DO:
         ASSIGN tel_vllimite = 0.

         INCLUSAO:
         DO WHILE TRUE:

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF glb_cdcritic > 0   THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                  END.
                    
               UPDATE tel_nrdconta 
                      tel_nrctrlim 
                      WITH FRAME f_lancdc.

               ASSIGN glb_nrcalcul = tel_nrdconta.

               RUN fontes/digfun.p.

               IF NOT glb_stsnrcal   THEN
                  DO:
                      ASSIGN glb_cdcritic = 8.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                      NEXT.

                  END.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                                  crapass.nrdconta = tel_nrdconta
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE crapass   THEN
                  DO:
                      ASSIGN glb_cdcritic = 9.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                      NEXT.

                  END.

               IF crapass.dtelimin <> ? THEN
                  DO:
                      ASSIGN glb_cdcritic = 410.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                      NEXT.

                  END.

               IF CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl))   THEN
                  DO:
                      ASSIGN glb_cdcritic = 695.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                      NEXT.

                  END.
               
               IF CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN
                  DO:
                      ASSIGN glb_cdcritic = 95.
                      NEXT-PROMPT tel_nrdconta WITH FRAME f_lancdc.
                      NEXT.

                  END.

               IF tel_nrctrlim = 0 THEN
                  DO:
                      ASSIGN glb_cdcritic = 22.
                      NEXT-PROMPT tel_nrctrlim WITH FRAME f_lancdc.
                      NEXT.

                  END.

               IF CAN-FIND(crapcdc WHERE
                           crapcdc.cdcooper = glb_cdcooper AND 
                           crapcdc.dtmvtolt = tel_dtmvtolt AND
                           crapcdc.cdagenci = tel_cdagenci AND
                           crapcdc.cdbccxlt = tel_cdbccxlt AND
                           crapcdc.nrdolote = tel_nrdolote AND
                           crapcdc.nrdconta = tel_nrdconta AND
                           crapcdc.nrctrlim = tel_nrctrlim
                           USE-INDEX crapcdc1) THEN
                  DO:
                      ASSIGN glb_cdcritic = 92.
                      NEXT-PROMPT tel_nrctrlim WITH FRAME f_lancdc.
                      NEXT.

                  END.
               
               FIND FIRST craplim WHERE craplim.cdcooper = glb_cdcooper  AND
                                        craplim.nrdconta = tel_nrdconta  AND
                                        craplim.tpctrlim = 2             AND
                                        craplim.insitlim = 2
                                        NO-LOCK NO-ERROR.

               IF AVAILABLE craplim   THEN
                  DO:
                      MESSAGE "O contrato" craplim.nrctrlim "deve ser"
                              "cancelado primeiro.".
                      NEXT.

                  END.

               RELEASE craplim.

               FIND craplim WHERE craplim.cdcooper = glb_cdcooper   AND 
                                  craplim.nrdconta = tel_nrdconta   AND
                                  craplim.nrctrlim = tel_nrctrlim   AND
                                  craplim.tpctrlim = 2 
                                  NO-LOCK NO-ERROR.

               IF NOT AVAILABLE craplim   THEN                   
                  DO:
                       ASSIGN glb_cdcritic = 484.
                       NEXT-PROMPT tel_nrctrlim WITH FRAME f_lancdc.
                       NEXT.

                  END.

               IF craplim.insitlim <> 1   THEN
                  DO:
                      MESSAGE "Deve estar em estudo".
                      NEXT.

                  END.
               
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  IF glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         ASSIGN glb_cdcritic = 0.

                     END.
                  
                  UPDATE tel_vllimite 
                         WITH FRAME f_lancdc

                  EDITING:

                      READKEY.
                   
                      IF FRAME-FIELD = "tel_vllimite"   THEN
                         IF LASTKEY =  KEYCODE(".")   THEN
                            APPLY 44.
                         ELSE
                            APPLY LASTKEY.
                      ELSE
                         APPLY LASTKEY.

                  END.  /*  Fim do EDITING  */

                  IF craplim.vllimite <> tel_vllimite   THEN
                     DO:
                         ASSIGN glb_cdcritic = 91.
                         NEXT-PROMPT tel_vllimite WITH FRAME f_lancdc.
                         NEXT.

                     END.
                
                  /*-----*/
                  ASSIGN aux_vlr_excedido = NO
                         aux_vlr_maxleg = 0
                         aux_vlr_maxutl = 0
                         aux_vlr_minscr = 0.
                  
                  FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                     NO-LOCK NO-ERROR. 

                  IF AVAIL crapcop THEN
                     ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
                            aux_vlr_maxutl = crapcop.vlmaxutl
                            aux_vlr_minscr = crapcop.vlcnsscr.
                        

                  ASSIGN aux_par_nrdconta = tel_nrdconta
                         aux_par_dsctrliq = " "
                         aux_par_vlutiliz = 0
                         aux_qtctarel     = 0.
   
                  IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                     RUN sistema/generico/procedures/b1wgen0138.p
                         PERSISTENT SET h-b1wgen0138.
                
                  ASSIGN aux_pertengp = DYNAMIC-FUNCTION("busca_grupo" 
                                                       IN h-b1wgen0138,
                                                       INPUT glb_cdcooper,
                                                       INPUT tel_nrdconta,
                                                       OUTPUT aux_nrdgrupo,
                                                       OUTPUT aux_gergrupo,
                                                       OUTPUT aux_dsdrisgp).
                  
                  IF VALID-HANDLE(h-b1wgen0138) THEN
                     DELETE OBJECT h-b1wgen0138.

                  IF aux_gergrupo <> "" THEN
                     DO: 
                         ASSIGN aux_aprovavl = NO.

                         MESSAGE COLOR NORMAL aux_gergrupo + " Confirma?"
                                              UPDATE aux_aprovavl.
                                      
                         IF aux_aprovavl = NO THEN
                            DO:
                               ASSIGN glb_cdcritic = 79.
                               NEXT-PROMPT tel_vllimite WITH FRAME f_lancdc.
                               NEXT.

                            END.

                     END.

                  IF aux_pertengp THEN
                     DO: 
                         IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                            RUN sistema/generico/procedures/b1wgen0138.p
                                PERSISTENT SET h-b1wgen0138.

                        /* Procedure responsavel por calcular o 
                         endividamento do grupo */
                        RUN calc_endivid_grupo IN h-b1wgen0138
                                              (INPUT glb_cdcooper,
                                               INPUT glb_cdagenci, 
                                               INPUT 0, 
                                               INPUT glb_cdoperad, 
                                               INPUT glb_dtmvtolt, 
                                               INPUT glb_nmdatela, 
                                               INPUT 1, 
                                               INPUT aux_nrdgrupo, 
                                               INPUT TRUE, /*Cons. p/ cta*/
                                              OUTPUT aux_riscogrp, 
                                              OUTPUT aux_par_vlutiliz,
                                              OUTPUT TABLE tt-grupo, 
                                              OUTPUT TABLE tt-erro).
                    
                        IF VALID-HANDLE(h-b1wgen0138) THEN
                           DELETE OBJECT h-b1wgen0138.
                        
                        IF RETURN-VALUE <> "OK" THEN
                           RETURN "NOK".  

                        IF aux_vlr_maxutl > 0 THEN
                           DO:
                              IF tel_vllimite > aux_par_vlutiliz THEN
                                 ASSIGN aux_valor = tel_vllimite.       
                              ELSE
                                 ASSIGN aux_valor = aux_par_vlutiliz.
                              
                              IF aux_valor > aux_vlr_maxutl THEN    
                                 DO:
                                    ASSIGN aux_aprovavl = NO.

                                    MESSAGE COLOR NORMAL
                                    "Vlrs(Utl) Excedidos (Utiliz. "    +
                                    TRIM(STRING(aux_par_vlutiliz,
                                    "zzz,zzz,zz9.99")) + " Excedido "  +
                                    TRIM(STRING((aux_valor - aux_vlr_maxutl),
                                    "zzz,zzz,zz9.99")) + ").Confirma? " 
                                    UPDATE aux_aprovavl.
                                    
                                    IF NOT aux_aprovavl THEN 
                                       ASSIGN aux_vlr_excedido = YES.

                                 END.
      
                              IF aux_vlr_excedido = NO AND
                                 aux_valor > aux_vlr_maxleg THEN
                                 DO:
                                    ASSIGN aux_vlr_excedido = YES.  

                                    MESSAGE COLOR NORMAL
                                    "Vlr(Legal) Excedido (Utiliz. " +
                                    TRIM(STRING(aux_par_vlutiliz,
                                    "zzz,zzz,zz9.99")) + " Excedido " + 
                                    TRIM(STRING((aux_valor - aux_vlr_maxleg),
                                    "zzz,zzz,zz9.99")) + ").". 

                                    PAUSE 2 NO-MESSAGE.

                                    IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                                       DO:  
                                          FOR EACH tt-grupo NO-LOCK:

                                              ASSIGN aux_qtctarel = aux_qtctarel + 1.

                                          END.

                                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                          
                                             OPEN QUERY q-grupo-economico
                                                  FOR EACH tt-grupo 
                                                           NO-LOCK.
                                             
                                             DISP tel_nrdconta
                                                  aux_qtctarel
                                                  WITH FRAME f_grupo_economico.

                                             UPDATE b-grupo-economico
                                                    WITH FRAME f_grupo_economico.
                                       
                                             LEAVE.
                                       
                                          END.
                                       
                                          CLOSE QUERY q-grupo-economico.
                                          HIDE FRAME f_grupo_economico.
                                           
                                       END.
                                  
                                   END.
              
                             IF aux_vlr_excedido = YES THEN
                                DO:
                                   ASSIGN glb_cdcritic = 79.
                                   NEXT-PROMPT tel_vllimite WITH FRAME f_lancdc.
                                   NEXT.

                                END.
                           END.
                              
                        IF aux_valor > aux_vlr_minscr  THEN
                           DO:
                              MESSAGE "Efetue consulta no SCR.".
                              PAUSE 2 NO-MESSAGE.
                              HIDE MESSAGE NO-PAUSE.

                           END.
                     END.
                  ELSE
                     DO:
                        RUN fontes/saldo_utiliza.p (INPUT  aux_par_nrdconta,
                                                    INPUT  aux_par_dsctrliq,
                                                    OUTPUT aux_par_vlutiliz).
      
                        IF aux_vlr_maxutl > 0 THEN
                           DO:
                              IF tel_vllimite > aux_par_vlutiliz THEN
                                 ASSIGN aux_valor = tel_vllimite.       
                              ELSE
                                 ASSIGN aux_valor = aux_par_vlutiliz.
                              
                              IF aux_valor > aux_vlr_maxutl THEN    
                                 DO:
                                    ASSIGN aux_aprovavl = NO.
                                    MESSAGE COLOR NORMAL
                                    "Vlrs(Utl) Excedidos"    +
                                    "(Utiliz. "              +
                                    TRIM(STRING(aux_par_vlutiliz,
                                    "zzz,zzz,zz9.99")) +  
                                    " Excedido "
                                    TRIM(STRING((aux_valor - 
                                    aux_vlr_maxutl),"zzz,zzz,zz9.99")) +
                                    ").Confirma? " 
                                    UPDATE aux_aprovavl.
                                    
                                    IF NOT aux_aprovavl THEN 
                                       ASSIGN aux_vlr_excedido = YES.

                                 END.
      
                              IF aux_vlr_excedido = NO      AND
                                 aux_valor > aux_vlr_maxleg THEN
                                 DO:
                                    ASSIGN aux_vlr_excedido = YES.  

                                    MESSAGE COLOR NORMAL
                                    "Vlr(Legal) Excedido" +
                                    "(Utiliz. "              +
                                    TRIM(STRING(aux_par_vlutiliz,
                                    "zzz,zzz,zz9.99")) + 
                                    " Excedido "
                                    TRIM(STRING((aux_valor -      
                                    aux_vlr_maxleg),"zzz,zzz,zz9.99")) +
                                    ").". 

                                    PAUSE 3 NO-MESSAGE.
                                    HIDE MESSAGE NO-PAUSE.

                                 END.
              
                             IF aux_vlr_excedido = YES THEN
                                DO:
                                  ASSIGN glb_cdcritic = 79.
                                  NEXT-PROMPT tel_vllimite WITH FRAME f_lancdc.
                                  NEXT.

                                END.
                           END.
                              
                        IF  aux_valor > aux_vlr_minscr  THEN
                            MESSAGE "Efetue consulta no SCR.".

                     END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  NEXT.

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

               DO WHILE TRUE:

                  FIND craplim WHERE craplim.cdcooper = glb_cdcooper   AND
                                     craplim.nrdconta = tel_nrdconta   AND
                                     craplim.nrctrlim = tel_nrctrlim   AND
                                     craplim.tpctrlim = 2
                                     EXCLUSIVE-LOCK NO-ERROR.

                  IF NOT AVAILABLE craplim   THEN
                     IF LOCKED craplim   THEN
                        DO:
                            PAUSE 2 NO-MESSAGE.
                            NEXT.
                        END.
                     ELSE
                        DO:
                            ASSIGN glb_cdcritic = 484.
                            LEAVE.
                        END.

                  ASSIGN craplim.insitlim = 2
                         craplim.qtrenova = 0
                         craplim.dtinivig = glb_dtmvtolt
                         craplim.dtfimvig = glb_dtmvtolt + craplim.qtdiavig.

                  FIND crapmcr WHERE crapmcr.cdcooper = glb_cdcooper     AND
                                     crapmcr.nrdconta = craplim.nrdconta AND
                                     crapmcr.nrcontra = craplim.nrctrlim AND
                                     crapmcr.tpctrmif = 2                AND
                                     crapmcr.tpctrlim = craplim.tpctrlim 
                                     NO-LOCK NO-ERROR.

                  IF NOT AVAILABLE crapmcr  THEN
                     DO:
                        CREATE crapmcr.

                        ASSIGN crapmcr.dtmvtolt = glb_dtmvtolt
                               crapmcr.cdagenci = crapass.cdagenci
                               crapmcr.nrdolote = craplot.nrdolote
                               crapmcr.cdbccxlt = craplot.cdbccxlt
                               crapmcr.nrdconta = craplim.nrdconta
                               crapmcr.nrcontra = craplim.nrctrlim
                               crapmcr.tpctrmif = 2
                               crapmcr.vlcontra = craplim.vllimite
                               crapmcr.nrctaav1 = craplim.nrctaav1
                               crapmcr.nrctaav2 = craplim.nrctaav2
                               crapmcr.tpctrlim = craplim.tpctrlim
                               crapmcr.qtrenova = craplim.qtrenova
                               crapmcr.cddlinha = craplim.cddlinha
                               crapmcr.cdcooper = glb_cdcooper.

                        VALIDATE crapmcr.

                     END.
                  ELSE
                     DO:
                        ASSIGN glb_cdcritic = 92.
                        LEAVE.
                     END.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               IF glb_cdcritic > 0   THEN
                  NEXT.
               
               CREATE crapcdc.

               ASSIGN crapcdc.dtmvtolt = craplot.dtmvtolt
                      crapcdc.cdagenci = craplot.cdagenci
                      crapcdc.cdbccxlt = craplot.cdbccxlt
                      crapcdc.nrdolote = craplot.nrdolote
                      crapcdc.nrdconta = tel_nrdconta
                      crapcdc.nrctrlim = tel_nrctrlim
                      crapcdc.vllimite = tel_vllimite
                      crapcdc.nrseqdig = craplot.nrseqdig + 1
                      crapcdc.cdcooper = glb_cdcooper
                      crapcdc.tpctrlim = 2
                      craplot.nrseqdig = craplot.nrseqdig + 1
                      craplot.qtcompln = craplot.qtcompln + 1.

               VALIDATE crapcdc.

               ASSIGN tel_qtinfoln = craplot.qtinfoln
                      tel_qtcompln = craplot.qtcompln
                      tel_nrseqdig = crapcdc.nrseqdig

                      craplot.vlcompcr = craplot.vlcompcr + tel_vllimite

                      tel_vlinfocr    = craplot.vlinfocr
                      tel_vlcompcr    = craplot.vlcompcr
                      tel_qtdifeln    = craplot.qtcompln - craplot.qtinfoln
                      tel_vldifecr    = craplot.vlcompcr - craplot.vlinfocr.

               RUN fontes/gera_rating.p (INPUT glb_cdcooper,
                                         INPUT tel_nrdconta,
                                         INPUT 2, /*Desc. Cheque*/ 
                                         INPUT tel_nrctrlim,
                                         INPUT TRUE). /* Gravar*/     

               IF RETURN-VALUE <> "OK" THEN
                  DO:
                      UNDO , NEXT INCLUSAO.
                  END.

            END.   /* Fim da transacao */

            IF tel_qtdifeln = 0   AND   tel_vldifecr = 0   THEN
               DO:
                   HIDE FRAME f_opcao   NO-PAUSE.
                   HIDE FRAME f_lancdc  NO-PAUSE.
                   HIDE FRAME f_regant  NO-PAUSE.
                   HIDE FRAME f_lanctos NO-PAUSE.
                   HIDE FRAME f_moldura NO-PAUSE.
                   ASSIGN glb_nmdatela = "LOTE".
                   RETURN.

               END.

            ASSIGN tel_reganter[6] = tel_reganter[5]
                   tel_reganter[5] = tel_reganter[4]
                   tel_reganter[4] = tel_reganter[3]
                   tel_reganter[3] = tel_reganter[2]
                   tel_reganter[2] = tel_reganter[1]
                   tel_reganter[1] = STRING(tel_nrdconta,"zzzz,zzz,9") + "  "   +
                                     STRING(tel_nrctrlim,"zzz,zzz,zz9") + "   " +
                                     STRING(tel_vllimite,"zzz,zz9.99"). 

            DISPLAY tel_qtinfoln  
                    tel_vlinfocr 
                    tel_qtcompln
                    tel_vlcompcr  
                    tel_qtdifeln 
                    tel_vldifecr
                    WITH FRAME f_opcao.

            HIDE FRAME f_lanctos.

            DISPLAY tel_reganter[1] 
                    tel_reganter[2] 
                    tel_reganter[3]
                    tel_reganter[4] 
                    tel_reganter[5] 
                    tel_reganter[6]
                    WITH FRAME f_regant.

            ASSIGN tel_nrdconta = 0
                   tel_nrctrlim = 0
                   tel_vllimite = 0
                   tel_nrseqdig = craplot.nrseqdig + 1.

            DISPLAY tel_nrseqdig 
                    tel_vllimite 
                    WITH FRAME f_lancdc.

         END.  /*  Fim do DO WHILE TRUE  */

      END.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */



