/* .............................................................................

   Programa: Fontes/lcredia.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                        Ultima atualizacao: 27/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               15/08/95 - Alterado para capitalizar o calculo da taxa mensal
                          (Edson).

               17/01/97 - Alterado para calcular os coeficientes de prestacao
                          somente com a taxa base informada (Edson).

               20/03/98 - Alterado para desabilitar a critica 377 (Edson).

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).
               
               20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

               03/03/2004 - Gerar Log(lcredi.log) qdo houver alteracao(Mirtes)

               24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).

               11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

               28/06/2004 - Removido - colocado em comentarios - o campo Valor
                            Maximo Linha - tel_vlmaxdiv (Evandro).
                            
               10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                            Juridica (Evandro).

               30/08/2004 - Tratamento para tipo de descto (Consig. Folha)
                            (Julio)

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               17/03/2006 - Excluido campo "Conta ADM", e acrescentado 
                            tel_flgcrcta (Diego).
                            
               24/05/2006 - Implementada verificacao de operador utilizando
                            a tela "CALPRE" (Diego).
                            
               28/08/2007 - Adicionado campo cdusolcr(Guilherme).
               
               10/12/2007 - Alterado para nao criticar tel_txminima e 
                            tel_txbaspre quando for Transpocred (Diego).
                            
               20/05/2008 - Utilizar a tabela crapccp para armazenar o
                            coeficiente da linhas de credito, no lugar do
                            extende atributo craplcr.incalpre(Sidnei - Precise)
                            
               23/06/2009 - Incluir campo Operacao (Gabriel).
                            
               22/07/2009 - Tratar tel_cdusolcr com tipo 2 - EPR/BOLETOS.
                            (Fernando).
                            
               16/12/2009 - Incluido mais 2 opcoes no campo "Operacao" e "F7" 
                            para listar estas opcoes (Elton).    
                            
               15/03/2010 - Incluido o campo que ira indicar o tempo que o 
                            emprestimo permanecera na atenda apos sua 
                            liquidacao (Gati -Daniel).  
               16/03/2010 - incluido o campo que ira conter a origem do
                            recurso (gati - Daniel)
                            
               15/06/2010 - incluido o campo que determina se a impressao da
                            declaracao (Sandro - gati)          
                            
               20/07/2010 - Re-desenhada a tela para utilizar dois frames.
                            Incluir campo de 'Listar na proposta' (Gabriel).   
                            
               25/03/2011 - Realizado correcao para permitir a alteracao das
                            linhas de credito que ja estejam com Cod.Uso = 2 
                            (Adriano).
                            
               16/06/2011 - Inclusao do campo craplcr.perjurmo (Adriano).
               
               28/11/2011 - Alteraçoes para habilitar a ediçao do campo
                            TIPO na Opçao A, e gerar uma linha no log para
                            tal alteraçao (Lucas).        
                            
               23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).    
               
               25/07/2012 - Gravaçao de LOG para todos os campos alterados (Lucas).
                            
               10/10/2012 - Incluir campo modalidade e submodalidade (Gabriel). 
               
               11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)  
               
               30/11/2012 - Incluido duas novas opcoes no campo "Origem Rec"
                            (David Kruger). 
                            
               14/02/2013 - Incluir campo "MICROCREDITO DIM" em tt-origem
                             (Lucas R.).
                             
               20/05/2013 - Incluir campo "MICROCREDITO PNMPO BRDE" em tt-origem
                            (Daniel).

               28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                            (Carlos)
                            
               03/07/2013 - Incluído Modalidade 14 na Cria_Modali (Douglas).
               
               13/12/2013 - Inclusao de VALIDATE crapccp (Carlos)
               
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).

               23/09/2014 - Alteraçao da mensagem com critica 77 substituindo pela 
                            b1wgen9999.p procedure acha-lock, que identifica qual 
                            é o usuario que esta prendendo a transaçao. (Vanessa)

               29/01/2015 - (Chamado 248647)Inclusao do novo campo de
                            consulta automatizada (Tiago Castro - RKAM).
                            
               19/02/2015 - Inclusao origem "Recurso Proprio", alteracao de 
                            14/05/2014 (Guilherme/SUPERO) 
                            
               24/02/2015 - Novo campo qtrecpro (Jonata-RKAM).             
                            
               27/02/2015 - Adicionar nova origem de recurso "MICROCREDITO PNMPO 
                            BNDES CECRED". (Jaison/Gielow - SD: 257430).
                            
               27/05/2015 - Incluir novo frame Projeto cessao de Credito (James)
.............................................................................*/

{ includes/var_online.i }
{ includes/var_lcredi.i }   /*  Contem as definicoes das variaveis e forms  */
  

/** Cria registros no browser do campo tel_dsoperac **/
RUN cria_w-dsoperac.
RUN cria_tt-origem.
RUN cria_modali.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.
/* Verifica se existe algum operador utilizando a tela CALPRE */
DO WHILE TRUE:
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                      craptab.nmsistem = "CRED"              AND
                      craptab.tptabela = "GENERI"            AND
                      craptab.cdempres = 00                  AND
                      craptab.cdacesso = "OPCALCPRE"         AND
                      craptab.tpregist = 0  NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab  THEN
        LEAVE.
     
   IF   craptab.dstextab <> ""   THEN
        DO:
            HIDE MESSAGE.
            MESSAGE "Tela CALPRE esta sendo usada pelo operador"
                    craptab.dstextab.
            MESSAGE "Aguarde ou pressione F4/END para sair...".

            READKEY PAUSE 2.
            IF   KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    HIDE MESSAGE.
                    RETURN.
                 END.

            NEXT.
        END.
   ELSE
        DO:
            HIDE MESSAGE.
            LEAVE.
        END.
END.


TRANS_A:

DO TRANSACTION ON ERROR UNDO TRANS_A, RETRY:

   DO aux_tentaler = 1 TO 10:

      FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                         craplcr.cdlcremp = tel_cdlcremp
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplcr   THEN
           IF   LOCKED craplcr   THEN
                DO:
                    glb_cdcritic = 374.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 363.
      ELSE
           glb_cdcritic = 0.

      LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   ASSIGN tel_dslcremp = craplcr.dslcremp

          tel_dssitlcr = IF craplcr.flgstlcr THEN "LIBERADA" ELSE "BLOQUEADA"

          tel_nrgrplcr = craplcr.nrgrplcr
          tel_txmensal = craplcr.txmensal
          tel_txdiaria = craplcr.txdiaria * 100
          tel_txjurfix = craplcr.txjurfix
          tel_txjurvar = craplcr.txjurvar
          tel_txpresta = craplcr.txpresta
          tel_qtdcasas = craplcr.qtdcasas
          tel_nrinipre = craplcr.nrinipre
          tel_nrfimpre = craplcr.nrfimpre
          tel_txbaspre = craplcr.txbaspre
          tel_qtcarenc = craplcr.qtcarenc
          tel_vlmaxass = craplcr.vlmaxass
          tel_vlmaxasj = craplcr.vlmaxasj
          tel_perjurmo = craplcr.perjurmo

          tel_flgtarif = craplcr.flgtarif
          tel_flgtaiof = craplcr.flgtaiof
          tel_vltrfesp = craplcr.vltrfesp
          tel_flgcrcta = craplcr.flgcrcta

          tel_txminima = craplcr.txminima
          tel_txmaxima = craplcr.txmaxima

          tel_tpctrato = craplcr.tpctrato
          tel_tpdescto = craplcr.tpdescto
          tel_nrdevias = craplcr.nrdevias
          tel_cdusolcr = craplcr.cdusolcr
          aux_cdusolcr = craplcr.cdusolcr
          
          tel_tplcremp = craplcr.tplcremp
          tel_dstipolc = ENTRY(craplcr.tplcremp,aux_dstipolc)

          tel_dssitlcr = IF craplcr.flgsaldo
                            THEN tel_dssitlcr + " COM SALDO"
                            ELSE tel_dssitlcr + " SEM SALDO"

          tel_origrecu = craplcr.dsorgrec
          tel_manterpo = craplcr.nrdialiq           
          tel_flgimpde = craplcr.flgimpde
          tel_dsoperac = craplcr.dsoperac           
          tel_flglispr = craplcr.flglispr
          tel_qtrecpro = craplcr.qtrecpro
          
          tel_flgrefin = craplcr.flgrefin
          tel_consaut  = (craplcr.inconaut = 0)
          tel_flgreneg = craplcr.flgreneg

          tel_flgdisap = craplcr.flgdisap
          tel_flgcobmu = craplcr.flgcobmu
          tel_flgsegpr = craplcr.flgsegpr
          tel_cdhistor = craplcr.cdhistor
                             
          ant_tplcremp = tel_tplcremp
          tel_cdfinemp = 0
          aux_contador = 0.

    FIND gnmodal WHERE gnmodal.cdmodali = craplcr.cdmodali NO-LOCK NO-ERROR.

    IF   AVAIL gnmodal    THEN 
         ASSIGN tel_cdmodali = gnmodal.cdmodali + "-" + gnmodal.dsmodali.
    ELSE
         ASSIGN tel_cdmodali = "".

    FIND gnsbmod WHERE gnsbmod.cdmodali = craplcr.cdmodali AND
                       gnsbmod.cdsubmod = craplcr.cdsubmod
                       NO-LOCK NO-ERROR.

    IF   AVAIL gnsbmod   THEN
         ASSIGN tel_cdsubmod = gnsbmod.cdsubmod + "-" + gnsbmod.dssubmod.
    ELSE
         ASSIGN tel_cdsubmod = "".

    BUFFER-COPY craplcr TO tt-log-craplcr.

   /*  Descricao do modelo do contrato  */

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                      craptab.nmsistem = "CRED"          AND
                      craptab.tptabela = "GENERI"        AND
                      craptab.cdempres = 0               AND
                      craptab.cdacesso = "CTRATOEMPR"    AND
                      craptab.tpregist = tel_tpctrato    NO-LOCK
                      USE-INDEX craptab1 NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        tel_dsctrato = "MODELO NAO CADASTRADO".
   ELSE
        tel_dsctrato = craptab.dstextab.

   IF   tel_tpdescto = 1   THEN
        tel_dsdescto = "C/C".
   ELSE
        tel_dsdescto = "CONSIG. FOLHA".
        
   CASE tel_cdusolcr:
        WHEN 0 THEN tel_dsusolcr = "NORMAL".
        WHEN 1 THEN tel_dsusolcr = "MICRO CREDITO".
        WHEN 2 THEN tel_dsusolcr = "EPR/BOLETOS".
   END.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      HIDE FRAME f_lcredi_2.
      HIDE FRAME f_lcredi_3.
      HIDE FRAME f_lcredi_4.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          UPDATE tel_dslcremp WITH FRAME f_lcredi.
          LEAVE.

      END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           LEAVE.

      tel_dslcremp = CAPS (tel_dslcremp).

      DISPLAY tel_dslcremp WITH FRAME f_lcredi.

      PAUSE 0.

      DISPLAY tel_tplcremp
              tel_tpdescto 
              tel_dsdescto  
              tel_dstipolc
              tel_tpctrato
              tel_dsctrato
              tel_dsusolcr 
              tel_dssitlcr WITH FRAME f_lcredi_2.

      ASSIGN tel_dsoperac:READ-ONLY IN FRAME f_lcredi_2 = YES
             tel_origrecu:READ-ONLY IN FRAME f_lcredi_2 = YES
             tel_cdmodali:READ-ONLY IN FRAME f_lcredi_2 = YES
             tel_cdsubmod:READ-ONLY IN FRAME f_lcredi_2 = YES.
             
      bloco_update:
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          UPDATE tel_dsoperac tel_tplcremp
                 tel_tpdescto tel_nrdevias 
                 tel_flgrefin tel_flgreneg
                 tel_cdusolcr tel_flgtarif tel_flgtaiof
                 tel_vltrfesp tel_flgcrcta tel_manterpo
                 tel_flgimpde tel_origrecu 
                 tel_flglispr tel_cdmodali tel_cdsubmod
                 WITH FRAME f_lcredi_2
             
          EDITING:   

             READKEY.

             IF   FRAME-FIELD = "tel_dsoperac" THEN
                  DO:   
                      IF   LASTKEY = KEYCODE("F7") THEN
                           DO:        
                               OPEN QUERY dsoperac-q 
                                    FOR EACH w-dsoperac NO-LOCK.

                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   UPDATE  dsoperac-b WITH FRAME f_dsoperac.
                                   LEAVE.
                               END.

                               HIDE FRAME f_dsoperac.    

                               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                    NEXT.

                           END.
                      ELSE
                           APPLY LASTKEY.
                     
                      /** Atribuicao para nao gravar valor do campo */
                      /** "Operacao" com cortes **/
                      ASSIGN aux_dsoperac = tel_dsoperac.  
                  END.
             ELSE
             IF   FRAME-FIELD = "tel_origrecu" THEN
                  DO:
                     IF   LASTKEY = KEYCODE("F7")   AND 
                          INPUT tel_cdusolcr = 1    THEN /*  Cod.Uso = 1 */
                          DO:
                              OPEN QUERY origem-q FOR EACH tt-origem NO-LOCK.

                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                 UPDATE  brorigem WITH FRAME f_origem.
                                 LEAVE.
                              END.
                              
                              HIDE FRAME f_origem.     

                              IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                   NEXT.

                          END.
                     ELSE
                     IF   LASTKEY = KEYCODE("F8")   THEN
                          DO:
                              ASSIGN tel_origrecu = "".
                              DISPLAY tel_origrecu WITH FRAME f_lcredi_2.
                          END.
                     ELSE
                          APPLY LASTKEY.

                  END.
             ELSE
             IF   FRAME-FIELD = "tel_cdmodali"   THEN
                  DO:
                      IF   LASTKEY = KEYCODE("F7")   THEN 
                           DO:
                               OPEN QUERY modali-q FOR EACH tt-modali NO-LOCK.
                          
                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                  UPDATE  modali-b WITH FRAME f_modali.
                                  LEAVE.
                               END.
                               
                               HIDE FRAME f_modali.     
                          
                               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                    NEXT.
                          
                           END.
                      ELSE
                           APPLY LASTKEY.
                  END.
             ELSE     
             IF   FRAME-FIELD = "tel_cdsubmod"   THEN
                  DO:
                      IF   LASTKEY = KEYCODE("F7")   THEN
                           DO:
                               RUN cria_submodali.
                            
                               OPEN QUERY submodali-q 
                                   FOR EACH tt-submodali NO-LOCK.

                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                  UPDATE  submodali-b WITH FRAME f_submodali.
                                  LEAVE.
                               END.
                               
                               HIDE FRAME f_submodali.     
                          
                               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                                    NEXT.
                           END.
                      ELSE 
                      IF   LASTKEY = 13  THEN 
                           DO:
                               APPLY "GO".
                           END.  
                      ELSE 
                           APPLY LASTKEY.
                  END.
             ELSE
                  APPLY LASTKEY.

             HIDE MESSAGE.                                    

          END. /** Fim Editing **/
                
          LEAVE.
          
      END. /**Fim do Do While**/  
      
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
               HIDE FRAME f_lcredi_2.
               NEXT.
           END.
                   
      IF   (craplcr.flgcrcta = TRUE  AND tel_flgcrcta = FALSE) OR
           (craplcr.flgcrcta = FALSE AND tel_flgcrcta = TRUE) THEN
            RUN fontes/pedesenha.p (INPUT glb_cdcooper, 
                                    INPUT 3, 
                                    OUTPUT aut_flgsenha,
                                    OUTPUT aut_cdoperad).
      
      IF   tel_tpdescto <> craplcr.tpdescto   THEN
           DO:
               HIDE MESSAGE NO-PAUSE.
               MESSAGE "Aguarde, pesquisando contratos de emprestimos...".

               FIND FIRST crapepr WHERE crapepr.cdcooper = glb_cdcooper   AND
                                        crapepr.cdlcremp = tel_cdlcremp   AND
                                        crapepr.inliquid = 0  
                                        USE-INDEX crapepr2 
                                        NO-LOCK NO-ERROR.

               IF   AVAILABLE crapepr   THEN
                    DO:
                        HIDE MESSAGE NO-PAUSE.
                        glb_cdcritic = 377.
                        NEXT-PROMPT tel_tpdescto WITH FRAME f_lcredi_2.
                        NEXT.
                    END.

               HIDE MESSAGE NO-PAUSE.
           
           END.

      IF   tel_tpdescto = 1   THEN
           tel_dsdescto = "C/C".
      ELSE
           tel_dsdescto = "CONSIG. FOLHA".

      CASE tel_cdusolcr:
           WHEN 0 THEN tel_dsusolcr = "NORMAL".
           WHEN 1 THEN tel_dsusolcr = "MICRO CREDITO".
           WHEN 2 THEN tel_dsusolcr = "EPR/BOLETOS".
      END.
    
      DISPLAY tel_dsdescto
              tel_dsusolcr WITH FRAME f_lcredi_2.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        UNDO TRANS_A, NEXT.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 381.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE. 

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            UNDO TRANS_A, NEXT.
        END.

   IF   aux_confirma = "S"   THEN
        DO:
            ASSIGN ant_nrinipre = tel_nrinipre
                   ant_nrfimpre = tel_nrfimpre.
               
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF   glb_cdcritic > 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.

               DISPLAY tel_txmensal 
                       tel_txdiaria WITH FRAME f_lcredi_3.

               UPDATE tel_txjurfix tel_txjurvar 
                      tel_txpresta tel_txminima tel_txmaxima 
                      tel_txbaspre 
                      tel_nrgrplcr tel_qtcarenc
                      tel_perjurmo
                      tel_vlmaxass tel_consaut
                      tel_vlmaxasj tel_nrinipre tel_nrfimpre tel_qtdcasas
                      tel_qtrecpro
                      WITH FRAME f_lcredi_3

               EDITING:

                  READKEY.

                  IF   FRAME-FIELD = "tel_txjurfix"   OR
                       FRAME-FIELD = "tel_txjurvar"   OR
                       FRAME-FIELD = "tel_txpresta"   OR
                       FRAME-FIELD = "tel_txbaspre"   OR
                       FRAME-FIELD = "tel_qtcarenc"   OR
                       FRAME-FIELD = "tel_vlmaxass"   OR
                       FRAME-FIELD = "tel_vlmaxasj"   OR
                       FRAME-FIELD = "tel_txminima"   OR
                       FRAME-FIELD = "tel_txmaxima"   OR
                       FRAME-FIELD = "tel_perjurmo"   THEN
                       IF   LASTKEY =  KEYCODE(".")   THEN
                            APPLY 44.
                       ELSE
                            APPLY LASTKEY.
                  ELSE
                       APPLY LASTKEY.

               END.  /*  Fim do EDITING  */
               
               IF   glb_cdcooper <> 9  THEN
                    DO:
                        IF   tel_txminima = 0  THEN
                             DO:
                                 glb_cdcritic = 185.
                                 NEXT-PROMPT tel_txminima WITH FRAME f_lcredi_3.
                                 NEXT.
                             END.
                    END.
               
               IF   tel_txmaxima > 0              AND
                    tel_txminima > tel_txmaxima   THEN
                    DO:
                        glb_cdcritic = 185.
                        NEXT-PROMPT tel_txmaxima WITH FRAME f_lcredi_3.
                        NEXT.
                    END.

               /*  Verifica se a taxa base pertence ao grupo informado  */

               FIND FIRST crablcr WHERE crablcr.cdcooper = glb_cdcooper   AND
                                        crablcr.nrgrplcr = tel_nrgrplcr
                                        NO-LOCK NO-ERROR.

               IF   AVAILABLE crablcr   THEN
                    DO: 
                        IF   glb_cdcooper <> 9  THEN
                             DO:
                                 IF   tel_txbaspre <> crablcr.txbaspre   THEN
                                      DO:
                                          glb_cdcritic = 382.
                                          NEXT-PROMPT tel_txbaspre 
                                                      WITH FRAME f_lcredi_3.
                                          NEXT.
                                      END.
                             END. 
                    END.

               IF   glb_cdcooper <> 9  THEN
                    DO:
                        IF   tel_txbaspre = 0   THEN
                             DO:
                                 glb_cdcritic = 185.
                                 NEXT-PROMPT tel_txbaspre WITH FRAME f_lcredi_3.
                                 NEXT.
                             END.
                    END.

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.tptabela = "USUARI"         AND
                                  craptab.cdempres = 11               AND
                                  craptab.cdacesso = "CALCPRESTA"     AND
                                  craptab.tpregist = tel_nrgrplcr
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE craptab   THEN
                    DO:
                        glb_cdcritic = 570.
                        NEXT-PROMPT tel_nrgrplcr WITH FRAME f_lcredi_3.
                        NEXT.
                    END.

               IF   tel_nrinipre > tel_nrfimpre   THEN
                    DO:
                        glb_cdcritic = 380.
                        NEXT-PROMPT tel_nrinipre WITH FRAME f_lcredi_3.
                        NEXT.
                    END.
               
               /* Permitir no maximo 99 parcelas para tipo de desconto 
                  consignado em Folha de pagamento. Isto ocorre por   
                  restricao de layout CNAB que permite no maximo 2 caracter 
                  Sidnei - Precise IT */
               IF tel_tpdescto = 2 THEN /* consig. folha */
                  DO:
                     IF tel_nrfimpre > 99 THEN     
                        DO:
                            HIDE MESSAGE NO-PAUSE.
                            NEXT-PROMPT tel_nrfimpre WITH FRAME f_lcredi_3.
                            BELL.
                            MESSAGE "Permitido informar no maximo 99"
                                   "parcelas p/ Linhas com Desconto em Folha.".
                            NEXT.
                        END.
                  END.
               
               
               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 UNDO TRANS_A, NEXT.

            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "GENERI"     AND
                               craptab.cdempres = 0            AND
                               craptab.cdacesso = "TAXASDOMES" AND
                               craptab.tpregist = 1            NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                                 INPUT "banco",
                                                                 INPUT "craptab",
                                                                 OUTPUT par_loginusr,
                                                                 OUTPUT par_nmusuari,
                                                                 OUTPUT par_dsdevice,
                                                                 OUTPUT par_dtconnec,
                                                                 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                                  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        UNDO TRANS_A, NEXT.
                 END.

            ASSIGN
              aux_txutiliz = IF SUBSTRING(craptab.dstextab,1,1) = "T"
                                THEN DECIMAL(SUBSTRING(craptab.dstextab,03,10))
                                ELSE DECIMAL(SUBSTRING(craptab.dstextab,14,10))


              tel_txmensal = ROUND(((aux_txutiliz * (tel_txjurvar / 100) +
                                   100) * (1 + (tel_txjurfix / 100)) - 100),6)
                            
              tel_txmensal = IF tel_txminima > tel_txmensal
                                THEN tel_txminima
                                ELSE IF tel_txmaxima > 0  AND
                                        tel_txmaxima < tel_txmensal
                                        THEN tel_txmaxima
                                        ELSE tel_txmensal
                              
              tel_txdiaria = ROUND(tel_txmensal / 3000,7).

              DISPLAY tel_txmensal (tel_txdiaria * 100) @ tel_txdiaria
                      WITH FRAME f_lcredi_3.
        END.
   ELSE
        tel_txdiaria = tel_txdiaria / 100.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      UNDO TRANS_A, NEXT.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".

      glb_cdcritic = 381.
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      glb_cdcritic = 0.
      LEAVE. 

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
      DO:
          glb_cdcritic = 79.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
          UNDO TRANS_A, NEXT.
      END.
		
   IF aux_confirma = "S"   THEN
      DO:		
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             IF glb_cdcritic > 0   THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.
          
             IF tel_flgcrcta THEN
                DO:
                    ASSIGN tel_cdhistor = 0.

                    DISP tel_cdhistor
                         WITH FRAME f_lcredi_4.
                END.

             UPDATE tel_flgdisap
                    tel_flgcobmu
             	  	tel_flgsegpr
             		tel_cdhistor WHEN tel_flgcrcta = FALSE
                    WITH FRAME f_lcredi_4

             EDITING:
    
               READKEY.
    
               IF LASTKEY = KEYCODE("F7") THEN
                  DO:
                      IF FRAME-FIELD = "tel_cdhistor"   THEN
                         DO:
                             RUN fontes/zoom_historicos.p
                                                 (INPUT glb_cdcooper,
                                                  INPUT FALSE,
                                                  INPUT 0,
                                                  OUTPUT tel_cdhistor).
    
                             DISPLAY tel_cdhistor
                                     WITH FRAME f_lcredi_4.
                         END. 
                      ELSE 
                         APPLY LASTKEY.
                  END.
               ELSE 
                  APPLY LASTKEY.
    
             END. /* Fim do EDITING */
    
             /* Verificacao se credita em Conta */
             IF NOT tel_flgcrcta THEN
                DO:
                    FOR FIRST craphis FIELDS(cdcooper)
                                      WHERE craphis.cdcooper = glb_cdcooper AND
                                            craphis.cdhistor = tel_cdhistor
                                            NO-LOCK: END.
    
                    IF NOT AVAIL craphis THEN
                       DO:
                           glb_cdcritic = 93.
                           NEXT-PROMPT tel_cdhistor WITH FRAME f_lcredi_4.
                           NEXT.
                       END.
    
                END. /* END IF tel_tpdescto = 1 THEN */

             LEAVE.
            
          END.  /*  Fim do DO WHILE TRUE  */

      END. /* IF aux_confirma = "S"   THEN */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
      UNDO TRANS_A, NEXT.

   /* Confirmacao dos dados */
   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).


   IF   aux_confirma <> "S"   THEN
        UNDO TRANS_A, NEXT.

   /*  Alterando/Criando/excluindo tabela de coeficientes de prestacao  */    
   DO  aux_qtpresta = tel_nrinipre TO tel_nrfimpre:
       FIND FIRST crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                crapccp.cdlcremp = craplcr.cdlcremp AND
                                crapccp.nrparcel = aux_qtpresta 
                                NO-LOCK NO-ERROR.
       IF AVAIL crapccp THEN
          RUN gera_log_antes.
   END.
   
   /** craplcr.incalpre = 0. **/
   /** Limpar coeficientes   **/
   FOR EACH crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                          crapccp.cdlcremp = craplcr.cdlcremp
                          EXCLUSIVE-LOCK:
       DELETE crapccp.             
   END.

   DO aux_qtpresta = tel_nrinipre TO tel_nrfimpre:

      IF   tel_txbaspre = 0   THEN
           aux_incalpre = 1 / aux_qtpresta.
      ELSE       
           ASSIGN aux_txbaspre = tel_txbaspre / 100
                  
                  aux_incalcul = EXP(1 + aux_txbaspre,aux_qtpresta)
                  aux_incalpre = EXP((aux_incalcul - 1) /
                                          (aux_txbaspre * aux_incalcul),-1).
      
      ASSIGN aux_incalpre = ROUND(aux_incalpre,tel_qtdcasas).
      
              
      /** popular tabela de coeficientes **/
      CREATE crapccp.
      ASSIGN crapccp.cdcooper = craplcr.cdcooper
             crapccp.cdlcremp = craplcr.cdlcremp
             crapccp.nrparcel = aux_qtpresta
             crapccp.incalpre = aux_incalpre.
      VALIDATE crapccp.
             
   END.  /*  Fim do DO .. TO  */
   
   DO  aux_qtpresta = tel_nrinipre TO tel_nrfimpre:
       FIND FIRST crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                crapccp.cdlcremp = craplcr.cdlcremp AND
                                crapccp.nrparcel = aux_qtpresta 
                                NO-LOCK NO-ERROR.
       IF AVAIL crapccp THEN 
           RUN gera_log_apos.
   END.
   
   ASSIGN craplcr.dslcremp = tel_dslcremp
          craplcr.nrgrplcr = tel_nrgrplcr
          craplcr.txmensal = tel_txmensal
          craplcr.txdiaria = tel_txdiaria
          craplcr.txjurfix = tel_txjurfix
          craplcr.txjurvar = tel_txjurvar
          craplcr.txpresta = tel_txpresta
          craplcr.qtdcasas = tel_qtdcasas
          craplcr.nrinipre = tel_nrinipre
          craplcr.nrfimpre = tel_nrfimpre
          craplcr.txbaspre = tel_txbaspre
          craplcr.qtcarenc = tel_qtcarenc
          craplcr.vlmaxass = tel_vlmaxass          
          craplcr.vlmaxasj = tel_vlmaxasj
          craplcr.txminima = tel_txminima
          craplcr.txmaxima = tel_txmaxima
          craplcr.perjurmo = tel_perjurmo
          craplcr.tpdescto = tel_tpdescto
          craplcr.nrdevias = tel_nrdevias
          craplcr.cdusolcr = tel_cdusolcr
          craplcr.flgtarif = tel_flgtarif
          craplcr.flgtaiof = tel_flgtaiof
          craplcr.vltrfesp = tel_vltrfesp
          craplcr.flgcrcta = tel_flgcrcta
          craplcr.dsoperac = aux_dsoperac
          craplcr.dsorgrec = tel_origrecu
          craplcr.nrdialiq = tel_manterpo
          craplcr.flgimpde = tel_flgimpde
          craplcr.flglispr = tel_flglispr
          craplcr.tplcremp = tel_tplcremp
          craplcr.cdmodali = SUBSTR(tel_cdmodali,1,2)
          craplcr.cdsubmod = SUBSTR(tel_cdsubmod,1,2)
          craplcr.flgrefin = tel_flgrefin
          craplcr.flgreneg = tel_flgreneg
          craplcr.qtrecpro = tel_qtrecpro
          craplcr.inconaut = IF   tel_consaut   THEN 
                                  0
                             ELSE
                                  1
          tel_cdlcremp = 0
          craplcr.flgdisap = tel_flgdisap
          craplcr.flgcobmu = tel_flgcobmu
          craplcr.flgsegpr = tel_flgsegpr
          craplcr.cdhistor = tel_cdhistor.

   CLEAR FRAME f_lcredi_2 NO-PAUSE.
   CLEAR FRAME f_lcredi_3 NO-PAUSE.
   CLEAR FRAME f_lcredi_4 NO-PAUSE.

END.  /*  Fim da transacao  */

/* Gravaçao do LOG */
FIND FIRST tt-log-craplcr NO-LOCK NO-ERROR NO-WAIT.

IF tel_dslcremp <> tt-log-craplcr.dslcremp THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "      +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"        +
                                 " Operador: " + glb_cdoperad               +
                                 " Alterou a Descricao da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")             +
                                 " de " + STRING(tt-log-craplcr.dslcremp)   +           
                                 " para "+ STRING(tel_dslcremp)+ "."        +   
                                 " >> log/lcredi.log").

IF tel_dsoperac <> tt-log-craplcr.dsoperac THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"       +
                                 " Operador: " + glb_cdoperad              +
                                 " Alterou a Operacao da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")            +
                                 " - " + craplcr.dslcremp                  +
                                 " de " + STRING(tt-log-craplcr.dsoperac)  +           
                                 " para "+ STRING(tel_dsoperac)+ "."       +   
                                 " >> log/lcredi.log").

IF tel_tplcremp <> tt-log-craplcr.tplcremp THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"       +
                                 " Operador: " + glb_cdoperad              +
                                 " Alterou o Tipo da Linha de Credito"     +
                                 STRING(craplcr.cdlcremp,"zzz9")            +
                                 " - " + craplcr.dslcremp                  +
                                 " de " + STRING(tt-log-craplcr.tplcremp)  +           
                                 " para "+ STRING(tel_tplcremp)+ "."       +   
                                 " >> log/lcredi.log").

IF tel_tpdescto <> tt-log-craplcr.tpdescto THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"       +
                                 " Operador: " + glb_cdoperad              +
                                 " Alterou o Desconto da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")            +
                                 " - " + craplcr.dslcremp                  +
                                 " de " + STRING(tt-log-craplcr.tpdescto)  +           
                                 " para "+ STRING(tel_tpdescto)+ "."       +   
                                 " >> log/lcredi.log").

IF tel_nrdevias <> tt-log-craplcr.nrdevias THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "        +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"          +
                                 " Operador: " + glb_cdoperad                 +
                                 " Alterou o Nr. de Vias da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")               +
                                 " - " + craplcr.dslcremp                     +
                                 " de " + STRING(tt-log-craplcr.nrdevias)     +         
                                 " para "+ STRING(tel_nrdevias)+ "."          +   
                                 " >> log/lcredi.log").

IF tel_cdusolcr <> tt-log-craplcr.cdusolcr THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "        +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"          +
                                 " Operador: " + glb_cdoperad                 +
                                 " Alterou o Cod. de Uso da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")               +
                                 " - " + craplcr.dslcremp                     +
                                 " de " + STRING(tt-log-craplcr.cdusolcr)     +         
                                 " para "+ STRING(tel_cdusolcr)+ "."          +   
                                 " >> log/lcredi.log").

IF tel_flgtarif <> tt-log-craplcr.flgtarif THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "               +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                                 " Operador: " + glb_cdoperad                        +
                                 " Alterou a cobranca da Tarifa da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                      +
                                 " - " + craplcr.dslcremp                            +
                                 " de " + STRING(tt-log-craplcr.flgtarif,"Sim/Nao")  +         
                                 " para "+ STRING(tel_flgtarif,"Sim/Nao")+ "."       +   
                                 " >> log/lcredi.log").

IF tel_flgtaiof <> tt-log-craplcr.flgtaiof THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "              +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                +
                                 " Operador: " + glb_cdoperad                       +
                                 " Alterou a cobranca do IOF da Linha de Credito"   +
                                 STRING(craplcr.cdlcremp,"zzz9")                     +
                                 " - " + craplcr.dslcremp                           +
                                 " de " + STRING(tt-log-craplcr.flgtaiof,"Sim/Nao") +         
                                 " para "+ STRING(tel_flgtaiof,"Sim/Nao")+ "."      +   
                                 " >> log/lcredi.log").

                                     /* testar daqui */

IF tel_vltrfesp <> tt-log-craplcr.vltrfesp THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +  
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou Vl. da Tarf. Especial da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                       + 
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.vltrfesp)             +         
                                 " para "+ STRING(tel_vltrfesp)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_flgcrcta <> tt-log-craplcr.flgcrcta THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "              +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                +
                                 " Operador: " + glb_cdoperad                       +
                                 " Alterou parametro de Creditar em "               +
                                 "C/C da Linha de Credito"                          +
                                 STRING(craplcr.cdlcremp,"zzz9")                     +
                                 " - " + craplcr.dslcremp                           +
                                 " de " + STRING(tt-log-craplcr.flgcrcta,"Sim/Nao") +         
                                 " para "+ STRING(tel_flgcrcta,"Sim/Nao")+ "."      +   
                                 " >> log/lcredi.log").

IF tel_manterpo <> tt-log-craplcr.nrdialiq THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "              +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                +
                                 " Operador: " + glb_cdoperad                       +
                                 " Alterou o val. que o Contrato sera Mantido "     +
                                 " apos Liquidado da Linha de Credito"              +
                                 STRING(craplcr.cdlcremp,"zzz9")                     +
                                 " - " + craplcr.dslcremp                           +
                                 " de " + STRING(tt-log-craplcr.nrdialiq) +         
                                 " para "+ STRING(tel_manterpo)+ "."      +   
                                 " >> log/lcredi.log").


IF tel_flgimpde <> tt-log-craplcr.flgimpde THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "              +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                +
                                 " Operador: " + glb_cdoperad                       +
                                 " Alterou a Impressao de Declaracao"               +
                                 " da Linha de Credito"                             +
                                 STRING(craplcr.cdlcremp,"zzz9")                     +
                                 " - " + craplcr.dslcremp                           +
                                 " de " + STRING(tt-log-craplcr.flgimpde,"Sim/Nao") +         
                                 " para "+ STRING(tel_flgimpde,"Sim/Nao")+ "."      +   
                                 " >> log/lcredi.log").

IF tel_origrecu <> tt-log-craplcr.dsorgrec THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "              +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                +
                                 " Operador: " + glb_cdoperad                       +
                                 " Alterou a Origem de Recurso da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                     +
                                 " - " + craplcr.dslcremp                           +
                                 " de " + STRING(tt-log-craplcr.dsorgrec)           +         
                                 " para "+ STRING(tel_origrecu)+ "."                +   
                                 " >> log/lcredi.log").

IF tel_flglispr <> tt-log-craplcr.flglispr THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                 +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                                 " Operador: " + glb_cdoperad                          +
                                 " Alterou a Listagem na Proposta da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                        +
                                 " - " + craplcr.dslcremp                              +
                                 " de " + STRING(tt-log-craplcr.flglispr,"Sim/Nao")    +         
                                 " para "+ STRING(tel_flglispr,"Sim/Nao")+ "."         +   
                                 " >> log/lcredi.log").

IF tel_txjurfix <> tt-log-craplcr.txjurfix THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Val. de Juros Fixos da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.txjurfix)             +         
                                 " para "+ STRING(tel_txjurfix)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_txjurvar <> tt-log-craplcr.txjurvar THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                    +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                      +
                                 " Operador: " + glb_cdoperad                             +
                                 " Alterou o Val. de Juros Variaveis da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                           +
                                 " - " + craplcr.dslcremp                                 +
                                 " de " + STRING(tt-log-craplcr.txjurvar)                 +         
                                 " para "+ STRING(tel_txjurvar)+ "."                      +   
                                 " >> log/lcredi.log").

IF tel_txpresta <> tt-log-craplcr.txpresta THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                 +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                   +
                                 " Operador: " + glb_cdoperad                          +
                                 " Alterou a Taxa sobre Prestacao da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                        +
                                 " - " + craplcr.dslcremp                              +
                                 " de " + STRING(tt-log-craplcr.txpresta)              +         
                                 " para "+ STRING(tel_txpresta)+ "."                   +   
                                 " >> log/lcredi.log").

IF tel_txminima <> tt-log-craplcr.txminima THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a Taxa Minima da Linha de Credito"         +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.txminima)             +         
                                 " para "+ STRING(tel_txminima)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_txmaxima <> tt-log-craplcr.txmaxima THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a Taxa Maxima da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.txmaxima)             +         
                                 " para "+ STRING(tel_txmaxima)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_txbaspre <> tt-log-craplcr.txbaspre THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a Taxa Base da Linha de Credito"           +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.txbaspre)             +         
                                 " para "+ STRING(tel_txbaspre)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_nrgrplcr <> tt-log-craplcr.nrgrplcr THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Grupo da Linha de Credito"               +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.nrgrplcr)             +         
                                 " para "+ STRING(tel_nrgrplcr)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_nrgrplcr <> tt-log-craplcr.nrgrplcr THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Grupo da Linha de Credito"               +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.nrgrplcr)             +         
                                 " para "+ STRING(tel_nrgrplcr)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_qtcarenc <> tt-log-craplcr.qtcarenc THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou os Dias de Carencia da Linha de Credito"   +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.qtcarenc)             +         
                                 " para "+ STRING(tel_qtcarenc)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_perjurmo <> tt-log-craplcr.perjurmo THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Juros de Mora da Linha de Credito"       +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.perjurmo)             +         
                                 " para "+ STRING(tel_perjurmo)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_vlmaxass <> tt-log-craplcr.vlmaxass THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Vl.Maximo Associado da Linha de Credito" +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.vlmaxass)             +         
                                 " para "+ STRING(tel_vlmaxass)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_vlmaxasj <> tt-log-craplcr.vlmaxasj THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Vl.Maximo para PJ da Linha de Credito"   +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.vlmaxasj)             +         
                                 " para "+ STRING(tel_vlmaxasj)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_nrinipre <> tt-log-craplcr.nrinipre OR
   tel_nrfimpre <> tt-log-craplcr.nrfimpre THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a Prestacao da Linha de Credito"           +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.nrinipre)             +         
                                 " a " +  STRING(tt-log-craplcr.nrfimpre)             +
                                 " para "+ STRING(tel_nrinipre)                       +
                                 " a " +  STRING(tel_nrfimpre)+ "."                   +                
                                 " >> log/lcredi.log").

IF tel_qtdcasas <> tt-log-craplcr.qtdcasas THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a qtd. de Decimais da Linha de Credito"    +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.qtdcasas)             +         
                                 " para "+ STRING(tel_qtdcasas)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_flgrefin <> tt-log-craplcr.flgrefin THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou o Refinanciamento"    +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.flgrefin)             +         
                                 " para "+ STRING(tel_flgrefin)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_flgreneg <> tt-log-craplcr.flgreneg THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "                +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"                  +
                                 " Operador: " + glb_cdoperad                         +
                                 " Alterou a Renegociacao"    +
                                 STRING(craplcr.cdlcremp,"zzz9")                       +
                                 " - " + craplcr.dslcremp                             +
                                 " de " + STRING(tt-log-craplcr.flgreneg)             +         
                                 " para "+ STRING(tel_flgreneg)+ "."                  +   
                                 " >> log/lcredi.log").

IF tel_flgdisap <> tt-log-craplcr.flgdisap THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "             +
                               STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                               " Operador: " + glb_cdoperad                        +
                               " Alterou Dispensar Aprovacao "                     +
                               STRING(craplcr.cdlcremp,"zzz9")                     +
                               " - " + craplcr.dslcremp                            +
                               " de " + STRING(tt-log-craplcr.flgdisap,"Sim/Nao")  +
                               " para "+ STRING(tel_flgdisap,"Sim/Nao")+ "."       +
                               " >> log/lcredi.log").

IF tel_flgcobmu <> tt-log-craplcr.flgcobmu THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "             +
                               STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                               " Operador: " + glb_cdoperad                        +
                               " Alterou Cobrar Multa "                            +
                               STRING(craplcr.cdlcremp,"zzz9")                     +
                               " - " + craplcr.dslcremp                            +
                               " de " + STRING(tt-log-craplcr.flgcobmu,"Sim/Nao")  +
                               " para "+ STRING(tel_flgcobmu,"Sim/Nao")+ "."       +
                               " >> log/lcredi.log").

IF tel_flgsegpr <> tt-log-craplcr.flgsegpr THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "             +
                               STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                               " Operador: " + glb_cdoperad                        +
                               " Alterou Seguro Prestamista "                       +
                               STRING(craplcr.cdlcremp,"zzz9")                     +
                               " - " + craplcr.dslcremp                            +
                               " de " + STRING(tt-log-craplcr.flgsegpr,"Sim/Nao")  +
                               " para "+ STRING(tel_flgsegpr,"Sim/Nao")+ "."       +
                               " >> log/lcredi.log").

IF tel_cdhistor <> tt-log-craplcr.cdhistor THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "   +
                               STRING(TIME,"HH:MM:SS") + "' --> '"       +
                               " Operador: " + glb_cdoperad              +
                               " Alterou Historico "                     +
                               STRING(craplcr.cdlcremp,"zzz9")           +
                               " - " + craplcr.dslcremp                  +
                               " de " + STRING(tt-log-craplcr.cdhistor)  +
                               " para "+ STRING(tel_cdhistor)+ "."       +
                               " >> log/lcredi.log").
    
PROCEDURE gera_log_antes.
 
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
               STRING(TIME,"HH:MM:SS") + "' --> '"  +
               " Operador: " + glb_cdoperad +
               " Coeficiente da Prestacao =  " +
                 STRING(aux_qtpresta) + " de " +             
               STRING(crapccp.incalpre,"9.999999") +   
               " Linha: " +
                 STRING(craplcr.cdlcremp,"zzz9") +
               " >> log/lcredi.log").
END.


PROCEDURE gera_log_apos.
 
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " " +
               STRING(TIME,"HH:MM:SS") + "' --> '"  +
               " Operador: " + glb_cdoperad +
               " Coeficiente da Prestacao =  " +
               STRING(aux_qtpresta) + " para " +   
               STRING(crapccp.incalpre,"9.999999") +  
               " Linha: " +
                 STRING(craplcr.cdlcremp,"zzz9") +
               " >> log/lcredi.log").
END.


PROCEDURE cria_w-dsoperac:

    CREATE w-dsoperac.  
    ASSIGN w-dsoperac.dsoperac = "EMPRESTIMO".
    CREATE w-dsoperac.
    ASSIGN w-dsoperac.dsoperac = "FINANCIAMENTO".
    CREATE w-dsoperac.
    ASSIGN w-dsoperac.dsoperac = "CAPITAL DE GIRO ATE 30 DIAS".
    CREATE w-dsoperac.
    ASSIGN w-dsoperac.dsoperac = "CAPITAL DE GIRO ACIMA 30 DIAS".
    
END.

PROCEDURE cria_tt-origem:


    CREATE tt-origem.
    ASSIGN tt-origem.origem = "RECURSO PROPRIO".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO ABN".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO ABN".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO BB".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO BNDES".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO BNDES CECRED".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO BRDE".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO CAIXA".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO PNMPO DIM".
    CREATE tt-origem.
    ASSIGN tt-origem.origem = "MICROCREDITO DIM".
    
END.

PROCEDURE cria_modali:

    FOR EACH gnmodal WHERE gnmodal.cdmodali = "02" OR 
                           gnmodal.cdmodali = "04" OR
                           gnmodal.cdmodali = "14" NO-LOCK:

        CREATE tt-modali.
        ASSIGN tt-modali.cdmodali = gnmodal.cdmodali + "-" + 
                                    gnmodal.dsmodali.

    END.

END PROCEDURE.

PROCEDURE cria_submodali:

    EMPTY TEMP-TABLE tt-submodali.

    FOR EACH gnsbmod WHERE gnsbmod.cdmodali = SUBSTR(tel_cdmodali,1,2) NO-LOCK:

        CREATE tt-submodali.
        ASSIGN tt-submodali.cdsubmod = gnsbmod.cdsubmod + "-" + 
                                       gnsbmod.dssubmod.

    END.

END PROCEDURE.


/* .................................................................... */






