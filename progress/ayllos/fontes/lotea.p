/* .............................................................................

   Programa: Fontes/lotea.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                       Ultima atualizacao: 27/06/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LOTE.

   Alteracoes: 08/06/94 - No tipo de lote 6 permitir que a data do debito seja
                          no maximo 60 dias a partir da data atual.

               21/06/94 - No tipo de lote 6, nao permitir que a data do debito
                          seja alterada apos a entrada dos lancamentos.

               30/11/94 - Alterado para permitir a alteracao de lotes tipo 10
                          e 11  (Odair).

               29/05/95 - Alterado para mostrar a data do debito somente para
                          tipo de lote 6 (Deborah).

               14/06/95 - Alterado para permitir alteracao do lote 12 (Odair).

               18/07/95 - Alterado para nao permitir lotes tipo 12 para data
                          superior a 30 dias (Deborah).

               15/12/95 - Alterado para tratar tipo de lote 13 (Odair).

               19/03/96 - Alterado para tratar tipo de lote 14 (Odair).

               16/08/96 - Alterado para tratar o lote tipo 13 a credito
                          (Deborah).

               29/08/96 - Alterado para tratar a data de pagamento tipo de lote
                          13 (Odair).

               21/10/96 - Alterado para nao permitir a alteracao da data de
                          vencimento das faturas no lote 13. (Deborah)

               09/12/96 - Tratar tipo de lote 15 (Odair).

               14/03/97 - Tratar tipo de lote 16 (Odair).

               10/04/97 - Tratar tipo de lote 17 (Odair).

               24/11/97 - Tratar tipo de lote 18 (Odair).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               06/07/98 - Tratar tplotmov 13 Lanfat - Alteracao para historico
                          288 na parte comentada para Celular (Odair)

               25/08/98 - Tratar historico 30 para lanfat (Odair)

               18/09/98 - Limitar lotes 17 ate numero 6849 (Deborah).
               
               05/10/98 - Tratar historico 29 para lanfat (Odair)

               19/09/98 - Tratar alteracao de historicos para tipo 13 (Odair)
               
               13/04/99 - Desabilitado tplotmov 7 limite de credito (Odair)
               
               21/09/99 - Tratar historico 348 (Odair)

               07/04/2000 - Tratar tipo de lote 19 - cheques em custodia
                            (Edson).

               26/06/2000 - Tratar tipo de lote 20 - titulos compensaveis
                            (Edson).

               05/01/2001 - Tratar tipo de lote 21 (Deborah).

               28/02/2001 - Permitir alterar o tipo de lote 15, deixando os
                            totais a debito e credito zerados (Deborah).

               05/04/2001 - Acrescentar o historico 374 (Embratel) na LANFAT.
                            (Ze Eduardo).

               18/06/2001 - Aumentar o prazo da custodia para 2 anos (Deborah).
               
               05/09/2001 - Incluir protocolo de custodia para tipo do
                            lote = 19 (Junior).

               13/09/2002 - Incluir tipo de lote para DOC e TED (Margarete).

               26/05/2003 - Nao permitir alterar alguns lotes (Edson).

               18/12/2003 - Alterado para NAO permitir data de liberacao para
                            o dia 31/12 de qualquer ano na custodia e nos
                            lancamentos automaticos (Edson).

               09/01/2004 - Nao aceitar mais Embratel histor 374 (Margarete).
               
               12/01/2004 - Incluir a TIM como fatura (Ze Eduardo).

               10/02/2004 - Efetuado controle por PAC(tabelas horario 
                            compel/titulo) (Mirtes)

               01/03/2004 - Alterado para NAO permitir a alteracao do lote de
                            desconto de cheques quando o bordero estiver li-
                            berado (Edson).

               17/09/2004 - Permitir alterar lotes Conta Investimento
                           (tplotmov 29 - LANLCI) (Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               18/05/2007 - Incluido critica para tipo de lote "9, 10 e 11"
                            aceitar somente Banco/Caixa 400 (Elton).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS.   
                          - Kbase IT Solutions - Eduardo Silva.
                          
               26/08/2008 - Removidas restricoes de alteracao para os lotes
                            de custodia de cheques conforme a opcao "I" da tela
                            (Evandro).

               26/09/2008 - Adaptar para tplotmov 35 Descto Titulos(Guilherme).
               
               20/05/2009 - Alteracao CDOPERAD (Kbase).
               
               26/03/2010 - Incluir <F7> no campo do historico.
                            Retirar comentarios desnecessarios  (Gabriel).
                            
               24/06/2010 - Nao permitir alterar tipo de lote 14 (poupanca) 
                            (Gabriel).             
                            
               16/11/2010 - Alteracao para atender ao Projeto de Truncagem (Ze).
               
               17/08/2011 - Criado condicao para nao permitir a alteracao 
                            do lote 7999 (Adriano).
                            
              29/11/2011 - Alterações para não permitir data de liberação/pagamento 
                           para último dia útil do Ano, nos Tipos 12 e 19 (Lucas).
              
              31/05/2012 - Retirado critica "62" quando tplotmov = 32. Incluido 
                           tplotmov 32 no IF NOT CAN-DO. (Lucas R.)  
                         - Permissao para somente departamento "TI" e "SUPORTE" 
                           poderem alterar tipo de lote 32 (Elton).
                           
              20/08/2012 - Tratamento para Migracao Viacredi para AltoVale
                           - Bloqueio de Data na ult. semana do ano (Ze).
                           
              08/05/2015 - Correcao da validacao de alteracao do cadastro do LOTE
                           habilitando a selecao da SELECTION-LIST (fontes/tplotmov.p)
                           SD 276368 - (Carlos Rafael Tanholi)             
                           
              08/09/2015 - Incluir no NOT CAN-DO do tplotmov os tipos 14,15,32
                           (Lucas Ranghetti #330111) 
                           
              24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).

			  27/06/2016 - Ajustes para nao alterar lote para o tipo 26 (Tiago/Elton SD438123).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lote.i }

DEF VAR h-b1wgen0015 AS HANDLE                                      NO-UNDO.

DEF    VAR     aux_dtdialim      AS DATE                            NO-UNDO.
DEF    VAR     cal_dtmvtopg      AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF VAR vRetorno AS CHAR NO-UNDO.
DEF VAR aux_lslotmov AS CHAR VIEW-AS SELECTION-LIST INNER-CHARS 40 INNER-LINES 12.

/* Utilizada para calcular data de pagto de faturas do tplotmov 13 Odair */

IF  (tel_nrdolote = 4500    OR                /*  Lote de custodia / titulos  */
     tel_nrdolote = 8477    OR                /*  Lote de desconto de chqs    */
     tel_nrdolote = 10001   OR
     tel_nrdolote = 10002   OR
     tel_nrdolote = 10003)  AND  glb_dsdepart <> "TI"  THEN
     DO:
         ASSIGN glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.

/*** Magui em 13/09/2002 nao permitir alterar lotes gerados pelo caixa ***/

IF   tel_nrdolote >= 11000   AND
     tel_nrdolote <= 21999   THEN
     DO:
         ASSIGN glb_cdcritic = 650.
         CLEAR FRAME f_lote NO-PAUSE.
         NEXT.
     END.
     
/*** Nao permitir alterar o lote utilizado para tarifacao de DOC/TED ***/
IF tel_nrdolote = 7999 THEN
   DO:
      ASSIGN glb_cdcritic = 650.
      CLEAR FRAME f_lote NO-PAUSE.
      NEXT.
    
   END.

TRANS_A:               

DO TRANSACTION ON ERROR UNDO TRANS_A, NEXT:

   DO aux_contador = 1 TO 10:

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE  craplot   THEN
           IF   LOCKED craplot   THEN
                DO:
                    glb_cdcritic = 84.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    glb_cdcritic = 60.
                    CLEAR FRAME f_lote.
                END.
      ELSE
      IF   craplot.tplotmov = 14   THEN /* Tipo poupanca */
           DO:
               glb_cdcritic = 650.
               CLEAR FRAME f_lote NO-PAUSE.   
           END.
      ELSE
           ASSIGN glb_cdcritic = 0
                  aux_tplotmov = craplot.tplotmov
                  aux_dtmvtopg = craplot.dtmvtopg.
      LEAVE.

   END.  /*  Fim do DO .. TO  */
   
   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            NEXT.
        END.

   ASSIGN tel_qtinfoln = craplot.qtinfoln
          tel_vlinfodb = craplot.vlinfodb
          tel_vlinfocr = craplot.vlinfocr
          tel_qtcompln = craplot.qtcompln
          tel_vlcompdb = craplot.vlcompdb
          tel_vlcompcr = craplot.vlcompcr
          tel_tplotmov = craplot.tplotmov
          tel_dtmvtopg = craplot.dtmvtopg
          tel_cdhistor = craplot.cdhistor
          tel_cdbccxpg = craplot.cdbccxpg

          tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
          tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
          tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr

          aux_qtinfocc = craplot.qtinfocc  
          aux_vlinfocc = craplot.vlinfocc  
          aux_qtinfoci = craplot.qtinfoci
          aux_vlinfoci = craplot.vlinfoci
          aux_qtinfocs = craplot.qtinfocs
          aux_vlinfocs = craplot.vlinfocs.

   DISPLAY tel_dtmvtolt 
           tel_qtinfoln tel_vlinfodb tel_vlinfocr
           tel_qtcompln tel_qtdifeln tel_vlcompdb
           tel_vldifedb tel_vlcompcr tel_vldifecr tel_tplotmov
           WITH FRAME f_lote.
   

   /*** Magui em 13/09/2002 nao mexer em lotes gerados pelo caixa ***/
   IF   tel_nrdolote >= 11000   AND
        tel_nrdolote <= 21999   THEN
        DO:
            ASSIGN glb_cdcritic = 261.
            CLEAR FRAME f_lote NO-PAUSE.
            NEXT.
        END.
   
   IF   tel_tplotmov = 20 THEN                 /*  Titulos compensaveis  */
        IF   tel_cdbccxlt = 11   THEN
             DO:
                 /*  Tabela com o horario limite para digitacao  */
 
                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                    craptab.nmsistem = "CRED"        AND
                                    craptab.tptabela = "GENERI"      AND
                                    craptab.cdempres = 0             AND
                                    craptab.cdacesso = "HRTRTITULO"  AND
                                    craptab.tpregist = tel_cdagenci
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAILABLE craptab   THEN
                      DO:
                          glb_cdcritic = 676.
                          NEXT.
                      END.

                 IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))   THEN
                      DO:
                          glb_cdcritic = 676.
                          NEXT.
                      END.

                 IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN
                      DO:
                          glb_cdcritic = 677.
                          NEXT.
                      END.
             END.

   IF   tel_tplotmov = 26   THEN /*  Desconto de cheques  */
        DO:
            FIND crapbdc WHERE crapbdc.cdcooper = glb_cdcooper       AND
                               crapbdc.nrborder = craplot.cdhistor 
                               NO-LOCK NO-ERROR.
      
            IF   NOT AVAILABLE crapbdc   THEN
            DO:
                MESSAGE "Boletim nao encontrado.".
                 RETURN.
            END.
 
            IF   crapbdc.insitbdc > 2   THEN 
                 DO:
                     MESSAGE "Boletim ja LIBERADO.".
                     glb_cdcritic = 79.
                     NEXT.
                 END.
        END.
        
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      UPDATE tel_qtinfoln tel_vlinfodb tel_vlinfocr tel_tplotmov
             WITH FRAME f_lote

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

         IF   FRAME-FIELD = "tel_vlinfodb"   OR
              FRAME-FIELD = "tel_vlinfocr"   THEN
              IF   LASTKEY =  KEYCODE(".")   THEN
                   APPLY 44.
              ELSE
                   APPLY LASTKEY.
         ELSE
         IF   FRAME-FIELD = "tel_tplotmov"   THEN
              IF   LASTKEY = KEYCODE("F7")   THEN
                   DO:
                       RUN fontes/tplotmov.p (OUTPUT tel_tplotmov).
                       DISPLAY tel_tplotmov WITH FRAME f_lote.
                   END.
              ELSE
                   APPLY LASTKEY.        
         ELSE
              APPLY LASTKEY.

      END.  /*  Fim do EDITING  */

      IF   NOT CAN-DO("1,2,3,4,5,6,8,9,10,11,12,13," +        
                      "14,15,16,17,18,19,20,21,23,24,25,26,27,29,32,35",
           STRING(tel_tplotmov)) THEN 
       DO:             
           glb_cdcritic = 62.
           NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
           NEXT.
       END.
      
           /*** Conta salario ***/
      IF  (glb_dsdepart <> "TI"       AND 
           glb_dsdepart <> "SUPORTE"  AND 
           glb_dsdepart <> "CANAIS")  AND
           tel_tplotmov = 32         THEN
           DO:
               glb_cdcritic = 36.
               NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
               NEXT.
           END.
      
      IF   tel_qtinfoln = 0  AND
           CAN-DO("13,15,16,17,18",STRING(tel_tplotmov,"99")) THEN
           DO:
               glb_cdcritic = 26.
               NEXT-PROMPT tel_qtinfoln WITH FRAME f_lote.
               NEXT.
           END.

      IF   tel_vlinfodb =  0   AND
           tel_vlinfocr =  0   AND
           NOT CAN-DO("8,11,15",STRING(tel_tplotmov))   THEN
           DO:
               glb_cdcritic = 61.
               NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
               NEXT.
           END.

      IF   tel_tplotmov <> aux_tplotmov   THEN
           DO:
               IF   tel_qtcompln >  0   OR
                    aux_tplotmov = 26   OR
                    aux_tplotmov = 27   OR
                    aux_tplotmov = 35   OR
                    tel_tplotmov = 13   THEN
                    DO:
                        glb_cdcritic = 62.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic "Deve ser" aux_tplotmov.
                        NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                        glb_cdcritic = 0.
                        NEXT.
                    END.
           END.
           
      IF   tel_cdbccxlt <> 11 AND tel_tplotmov = 21 THEN /* Iptu so' no dia */
           DO:
               glb_cdcritic = 62.
               NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
               NEXT.
           END.
      
      IF  ((tel_cdbccxlt = 600)  AND 
           (NOT CAN-DO("6,19",STRING(tel_tplotmov))))       OR
          ((tel_cdbccxlt <> 600) AND 
           (CAN-DO("6,19",STRING(tel_tplotmov))))           AND
           glb_dsdepart <> "TI"                             THEN
           DO:
               glb_cdcritic = 584.
               NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
               NEXT.
           END.

      IF   tel_nrdolote > 5999 AND tel_nrdolote < 7000   AND 
           glb_dsdepart <> "TI"                          THEN
           IF   NOT CAN-DO("1,6,12,17",STRING(tel_tplotmov))   THEN
                DO:
                    glb_cdcritic = 261.
                    NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                    NEXT.
                END.

      IF   tel_tplotmov = 18 AND (tel_vlinfocr = 0 OR tel_vlinfodb = 0) THEN
           DO:
              glb_cdcritic = 61.
              IF   tel_vlinfocr = 0 THEN
                   NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
              ELSE
                   NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
              NEXT.
           END.

      /*  Cheques em custodia  */
      
      IF   tel_tplotmov = 19   THEN
           DO: /*
               IF   tel_nrdolote > 4500   AND   tel_nrdolote < 4600   THEN
                    DO:   */
                        IF   tel_vlinfocr > 0   AND   tel_vlinfodb > 0   THEN
                             DO:
                                 IF   tel_vlinfocr <> tel_vlinfodb   THEN
                                      DO:
                                          glb_cdcritic = 665.
                                          NEXT-PROMPT tel_vlinfodb 
                                                      WITH FRAME f_lote.
                                          NEXT.
                                      END.
                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 269.
                                 NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                                 NEXT.
                             END.            
           END.

      /*  Titulos compensaveis  */      
      IF   tel_tplotmov = 20 OR tel_tplotmov = 21 THEN
           DO:
               IF   tel_nrdolote > 4600   AND   tel_nrdolote < 4700   THEN
                    DO:
                        IF   tel_vlinfocr = 0   THEN
                             DO:
                                 glb_cdcritic = 269.
                                 NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                                 NEXT.
                             END.
                        
                        tel_vlinfodb = 0.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 58.
                        NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                        NEXT.
                    END.
           END.

      IF  (tel_nrdolote > 4600   AND   
           tel_nrdolote < 4700)  AND
           (tel_tplotmov <> 20 AND tel_tplotmov <> 21) THEN
           DO:
               glb_cdcritic = 62.
               NEXT-PROMPT tel_nrdolote WITH FRAME f_lote.
               NEXT.
           END.

      /*  Comp. eletronica  */
   
      IF   tel_tplotmov = 23   or
           tel_tplotmov = 24   OR
           tel_tplotmov = 25   THEN
           DO:
               /*  Tabela com o horario limite para digitacao  */

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                  craptab.nmsistem = "CRED"         AND
                                  craptab.tptabela = "GENERI"       AND
                                  craptab.cdempres = 0              AND
                                  craptab.cdacesso = "HRTRCOMPEL"   AND
                                  craptab.tpregist = tel_cdagenci
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE craptab   THEN
                    DO:
                        glb_cdcritic = 676.
                        NEXT.
                    END.

               IF   TIME >= INT(SUBSTRING(craptab.dstextab,3,5))   THEN
                    DO:
                        glb_cdcritic = 676.
                        NEXT.
                    END.

               IF   INT(SUBSTRING(craptab.dstextab,1,1)) > 0   THEN
                    DO:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                           craptab.nmsistem = "CRED"         AND
                                           craptab.tptabela = "GENERI"       AND
                                           craptab.cdempres = 0              AND
                                           craptab.cdacesso = "EXETRUNCAGEM" AND
                                           craptab.tpregist = tel_cdagenci   
                                           NO-LOCK NO-ERROR.
                   
                        IF   NOT AVAILABLE craptab THEN
                             DO:
                                 glb_cdcritic = 677.
                                 NEXT.
                             END.
                        ELSE
                             IF   craptab.dstextab = "NAO" THEN
                                  DO:
                                      glb_cdcritic = 677.
                                      NEXT.
                                  END.
                    END.
                        
               IF   (tel_tplotmov = 23                      AND
                   ((tel_vlinfocr = 0 AND tel_vlinfodb = 0) OR
                    (tel_vlinfocr <> tel_vlinfodb)))        THEN
                     DO:
                         glb_cdcritic = 61.
                         NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                         NEXT.
                     END.
           END.
     
      IF   CAN-DO("4,6,11,12,17",STRING(tel_tplotmov)) THEN
           DO:
               IF   tel_vlinfocr > 0   THEN
                    DO:
                        glb_cdcritic = 61.
                        NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                        NEXT.
                    END.

               IF   tel_tplotmov = 6   THEN
                    DO:
                        IF   tel_nrdolote < 6000   OR
                             tel_nrdolote > 6499   THEN
                             DO:
                                 glb_cdcritic = 261.
                                 NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                                 NEXT.
                             END.

                    END.

               IF   tel_tplotmov = 12   THEN
                    DO:
                        IF   tel_nrdolote < 6500   OR
                             tel_nrdolote > 6799   THEN
                             DO:
                                 glb_cdcritic = 62.
                                 NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                                 NEXT.
                             END.
                    END.

               IF   tel_tplotmov = 17   THEN
                    DO:
                        IF   tel_nrdolote < 6800   OR
                             tel_nrdolote > 6849   THEN
                             DO:
                                 glb_cdcritic = 58.
                                 NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
                                 NEXT.
                             END.
                    END.
           END.
      ELSE
           IF   CAN-DO("3,7,9,10,13,14,16",STRING(tel_tplotmov)) THEN
                IF   tel_vlinfocr = 0   THEN
                     DO:
                         glb_cdcritic = 61.
                         NEXT-PROMPT tel_vlinfocr WITH FRAME f_lote.
                         NEXT.
                     END.
                ELSE
                     DO:
                         IF   tel_vlinfodb > 0   THEN
                              DO:
                                  glb_cdcritic = 61.
                                  NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                                  NEXT.
                              END.
                     END.
           ELSE
                IF   tel_tplotmov = 8   AND
                     tel_vlinfodb > 0   THEN
                     DO:
                         glb_cdcritic = 61.
                         NEXT-PROMPT tel_vlinfodb WITH FRAME f_lote.
                         NEXT.
                     END.
      
      IF ((tel_cdbccxlt = 400)                          AND 
          (NOT CAN-DO("9,10,11",STRING(tel_tplotmov)))) OR
         ((tel_cdbccxlt <> 400)                         AND 
          (CAN-DO("9,10,11",STRING(tel_tplotmov)))) THEN
         DO:       
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
        END.
      
      
      tel_dtmvtopg = craplot.dtmvtopg.

      IF   tel_tplotmov = 6 THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_dtmvtopg WITH FRAME f_data.

                  IF   tel_dtmvtopg = ?                   OR
                       tel_dtmvtopg > (glb_dtmvtolt + 60) OR
                       tel_dtmvtopg <= glb_dtmvtolt       OR
                       CAN-DO("1,7",STRING(WEEKDAY(tel_dtmvtopg))) THEN
                       glb_cdcritic = 013.
                  ELSE
                       DO:

                           FIND crapfer WHERE 
                                crapfer.cdcooper = glb_cdcooper AND
                                crapfer.dtferiad = tel_dtmvtopg
                                NO-LOCK NO-ERROR.

                           IF   AVAILABLE crapfer   THEN
                                glb_cdcritic = 13.
                       END.

                  IF   tel_dtmvtopg <> aux_dtmvtopg   THEN
                       IF   tel_qtcompln > 0   THEN
                            glb_cdcritic = 13.

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_data.
                           glb_cdcritic = 0.
                       END.
                  ELSE
                       LEAVE.

               END. /* Fim do DO WHILE TRUE */

               HIDE FRAME f_data NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN  /*  F4 OU FIM   */
                    RETURN.
           END.

      IF   tel_tplotmov = 12 THEN
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  UPDATE tel_dtmvtopg 
                         tel_cdhistor
                         tel_cdbccxpg
                         WITH FRAME f_debito

                  EDITING:
                    
                    READKEY.

                    IF   LASTKEY = KEYCODE ("F7")   THEN
                         DO:
                             IF   FRAME-FIELD = "tel_cdhistor"   THEN
                                  DO:   
                                      RUN fontes/zoom_historicos.p 
                                                    (INPUT glb_cdcooper,
                                                     INPUT TRUE,
                                                     INPUT 0,
                                                     OUTPUT tel_cdhistor).

                                      DISPLAY tel_cdhistor WITH FRAME f_debito.
                                  END.
                              ELSE
                                  APPLY LASTKEY.
                         
                         END.
                    ELSE 
                         APPLY LASTKEY.

                  END.  /* Fim do EDITING */

                  IF   tel_dtmvtopg > (glb_dtmvtolt + 30) THEN
                       DO:
                           glb_cdcritic = 013.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                           NEXT.
                       END.

                  IF   tel_dtmvtopg < glb_dtmvtolt THEN
                       DO:
                           glb_cdcritic = 013.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_debito.
                           NEXT.
                       END.

                  /*  Nao permite pagamento para o último dia útil do ano.  */

                  RUN sistema/generico/procedures/b1wgen0015.p 
                  PERSISTENT SET h-b1wgen0015.
                                                        
                  ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtmvtopg)).
                  RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                        INPUT FALSE, 
                                                        INPUT TRUE,
                                                    INPUT-OUTPUT aux_dtdialim).
                  DELETE PROCEDURE h-b1wgen0015.
            
                  IF   aux_dtdialim = tel_dtmvtopg THEN 
                       DO:
                           glb_cdcritic = 13.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic. 
                           NEXT.
                       END.

                  FIND craphis  WHERE
                       craphis.cdcooper = glb_cdcooper AND
                       craphis.cdhistor = tel_cdhistor
                                      NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE craphis THEN
                       DO:
                           glb_cdcritic = 93.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_debito.
                           NEXT.
                       END.
                  ELSE
                       IF   craphis.tplotmov <>   1   OR
                            craphis.inhistor <>  11   OR
                            craphis.indebcre <> "D"   OR
                            craphis.indebcta <>   1   THEN
                            DO:
                                glb_cdcritic = 94.
                                NEXT-PROMPT tel_cdhistor WITH FRAME f_debito.
                                NEXT.
                            END.
                  LEAVE.

               END. /* Fim do DO WHILE TRUE */

               HIDE FRAME f_debito NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM  */
                    RETURN.
           END.

      IF   tel_tplotmov = 19 THEN                 /*  Cheques em custodia  */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  IF   craplot.qtcompln > 0   THEN
                       LEAVE.

                  UPDATE tel_dtmvtopg WITH FRAME f_data_custodia.

                  IF   tel_dtmvtopg <= glb_dtmvtolt                OR
                       tel_dtmvtopg = ?                            OR /*
                       CAN-DO("1,7",STRING(WEEKDAY(tel_dtmvtopg))) OR
                       CAN-FIND(crapfer WHERE
                                crapfer.cdcooper = glb_cdcooper    AND
                                crapfer.dtferiad = tel_dtmvtopg)   OR*/
                    
                       tel_dtmvtopg > (glb_dtmvtolt + 1095)         THEN
                       DO:
                           glb_cdcritic = 013.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_data_custodia.
                           NEXT.
                       END.

                  /*   Tratamento para Migracao Viacredi para AltoVale */
                  IF   glb_cdcooper = 1           AND
                       tel_dtmvtopg >= 12/25/2012 AND
                       tel_dtmvtopg <= 12/31/2012 AND
                      (tel_cdagenci = 07          OR
                       tel_cdagenci = 33          OR
                       tel_cdagenci = 38          OR
                       tel_cdagenci = 60          OR
                       tel_cdagenci = 62          OR
                       tel_cdagenci = 66)         THEN
                       DO:
                           glb_cdcritic = 013.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_data_custodia.
                           NEXT.
                       END.
                    
                    /*  Nao permite liberação para último dia útil do Ano.  */

                     RUN sistema/generico/procedures/b1wgen0015.p 
                     PERSISTENT SET h-b1wgen0015.
                  
                     ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtmvtopg)).
                     RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                           INPUT FALSE,
                                                           INPUT TRUE,
                                                     INPUT-OUTPUT aux_dtdialim).
                     DELETE PROCEDURE h-b1wgen0015.
                  
                     IF   aux_dtdialim = tel_dtmvtopg THEN 
                          DO:
                              glb_cdcritic = 13.
                              RUN fontes/critic.p.
                              BELL.
                              MESSAGE glb_dscritic. 
                              NEXT.
                          END.
                                      
                  LEAVE.

               END. /* Fim do DO WHILE TRUE */

               HIDE FRAME f_debito NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM  */
                    RETURN.
           
               FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                  NO-LOCK NO-ERROR.
        
               IF   NOT AVAILABLE crapcop   THEN
                    DO:
                        glb_cdcritic = 651.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        RETURN.
                    END.

               aux_dschqcop = "Cheques " + STRING(crapcop.nmrescop,"x(11)") +
                               ":".

               HIDE MESSAGE NO-PAUSE.
     
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  DISPLAY aux_dschqcop WITH FRAME f_info.
              
                  UPDATE  aux_qtinfocc
                          aux_vlinfocc
                          aux_qtinfoci
                          aux_vlinfoci
                          aux_qtinfocs
                          aux_vlinfocs WITH FRAME f_info

                  EDITING:

                     READKEY.
                 
                     IF   FRAME-FIELD = "aux_vlinfocc"   OR
                          FRAME-FIELD = "aux_vlinfocs"   OR
                          FRAME-FIELD = "aux_vlinfoci"   THEN
                          IF   LASTKEY =  KEYCODE(".")   THEN
                               APPLY 44.
                          ELSE
                               APPLY LASTKEY.
                     ELSE
                          APPLY LASTKEY.

                  END.   /* Fim do EDITING  */

                  ASSIGN tot_qtcheque = aux_qtinfocc + aux_qtinfoci + 
                                        aux_qtinfocs
                         tot_vlcheque = aux_vlinfocc + aux_vlinfoci + 
                                        aux_vlinfocs.
                     
                  DISPLAY tot_qtcheque tot_vlcheque WITH FRAME f_info.
              
                  IF   tot_qtcheque <> tel_qtinfoln THEN
                       glb_cdcritic = 26.
                       
                  IF   tot_vlcheque <> tel_vlinfocr THEN
                       glb_cdcritic = 269.
                     
                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                           NEXT.
                       END.

                  LEAVE.

               END. /* Fim do DO WHILE TRUE */

               HIDE FRAME f_info NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   /* F4 OU FIM */
                    RETURN.

           END.

      IF   tel_tplotmov = 20 THEN /* Titulos compensaveis */
           DO:
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   glb_cdcritic > 0 THEN
                       DO:
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                       END.

                  IF   craplot.qtcompln > 0   THEN
                       LEAVE.

                  UPDATE tel_dtmvtopg WITH FRAME f_data_custodia.

                  IF   tel_dtmvtopg <> ?   THEN
                       IF   tel_dtmvtopg <= glb_dtmvtolt   OR
                            CAN-DO("1,7",STRING(WEEKDAY(tel_dtmvtopg))) OR
                            CAN-FIND(crapfer WHERE
                                     crapfer.cdcooper = glb_cdcooper    AND
                                     crapfer.dtferiad = tel_dtmvtopg)   THEN
                            DO:
                                glb_cdcritic = 013.
                                NEXT-PROMPT tel_dtmvtopg 
                                            WITH FRAME f_data_custodia.
                                NEXT.
                            END.

                  IF  (craplot.cdbccxlt = 100 AND tel_dtmvtolt = ?)    OR
                      (craplot.cdbccxlt = 11  AND tel_dtmvtolt <> ?)   THEN
                       DO:
                           glb_cdcritic = 013.
                           NEXT-PROMPT tel_dtmvtopg WITH FRAME f_data_custodia.
                           NEXT.
                       END.

                  LEAVE.

               END. /* Fim do DO WHILE TRUE */

               HIDE FRAME f_debito NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN  /* F4 OU FIM  */
                    RETURN.
           END.

      IF   tel_tplotmov = 21 AND tel_dtmvtopg <> ? THEN
           DO:
              glb_cdcritic = 013.
              NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
              NEXT.
           END.

      IF  tel_tplotmov = 26 THEN
          DO:
            glb_cdcritic = 62.
            NEXT-PROMPT tel_tplotmov WITH FRAME f_lote.
            NEXT.
          END.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        NEXT.

   ASSIGN craplot.qtinfoln = tel_qtinfoln
          craplot.vlinfodb = tel_vlinfodb
          craplot.vlinfocr = tel_vlinfocr
          craplot.tplotmov = tel_tplotmov
          craplot.dtmvtopg = tel_dtmvtopg
          craplot.cdhistor = tel_cdhistor
          craplot.cdbccxpg = tel_cdbccxpg
          craplot.qtinfocc = aux_qtinfocc
          craplot.vlinfocc = aux_vlinfocc
          craplot.qtinfoci = aux_qtinfoci
          craplot.vlinfoci = aux_vlinfoci
          craplot.qtinfocs = aux_qtinfocs
          craplot.vlinfocs = aux_vlinfocs.

   ASSIGN tel_qtinfoln     = 0
          tel_vlinfodb     = 0
          tel_vlinfocr     = 0
          tel_tplotmov     = 0
          tel_dtmvtopg     = ?
          tel_cdbccxpg     = 0
          tel_cdhistor     = 0.

END.   /* Fim da transacao  --  TRANS_A  */

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
     END.

RELEASE craplot.

CLEAR FRAME f_lote NO-PAUSE.

ASSIGN tel_cdagenci = 0
       tel_cdbccxlt = 0
       tel_nrdolote = 0.

/* .......................................................................... */
