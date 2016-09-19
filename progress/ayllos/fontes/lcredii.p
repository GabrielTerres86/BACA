/* .............................................................................

   Programa: Fontes/lcredii.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 27/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               15/08/95 - Alterado para capitalizar o calculo da taxa mensal
                          (Edson).

               17/01/97 - Alterado para calcular os coeficientes de prestacao
                          somente com a taxa base informada (Edson).

               05/10/1999 - Aumentado o numero de casas decimais na taxa
                            (Edson).
                            
               20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

               24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).

               11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

               28/06/2004 - Removido - colocado em comentarios - o campo Valor
                            Maximo Linha - tel_vlmaxdiv (Evandro).
                            
               10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                            Juridica (Evandro).
               
               23/09/2004 - Inclusao do campo tipo de desconto para emprestimo
                            em consignacao (Julio)

               04/07/2005 - Alimentado campo cdcooper da tabela craplcr (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               17/03/2006 - Excluido campo "Conta ADM", e acrescentado
                            tel_flgcrcta (Diego).
                            
               28/08/2007 - Adicionado campo cdusolcr(Guilherme).
               
               10/12/2007 - Alterado para nao criticar tel_txminima e
                            tel_txbaspre quando for Transpocred (Diego).
                            
               20/05/2008 - Utilizar a tabela crapccp para armazenar o
                            coeficiente da linhas de credito, no lugar do
                            extende atributo craplcr.incalpre(Sidnei - Precise)

               24/06/2009 - Incluida campo Operacao (Gabriel).

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

              20/07/2010 - Incluir camnpo 'Listar na proposta' (Gabriel).                    

              24/03/2011 - Corrigido problema de sobreposicao na inclusao 
                           de uma linha ja existente (Adriano).

              16/06/2011 - Inclusao do campo craplcr.perjurmo (Adriano).

              23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).

              11/06/2012 - Tratamento para remoçao do campo EXTENT crapfin.cdlcrhab (Lucas).

              10/10/2012 - Incluir campo modalidade e submodalidade (Gabriel).

              11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)

              30/11/2012 - Incluido duas novas opcoes no campo "Origem Rec"
                           (David Kruger). 

              14/02/2013 - Incluir opcao "MICROCREDITO DIM" em tt-origem 
                           (Lucas R.)

              20/05/2013 - Incluir campo "MICROCREDITO PNMPO BRDE" em tt-origem
                           (Daniel).

              28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                           (Carlos)

              03/07/2013 - Incluído Modalidade 14 na Cria_Modali (Douglas)

              13/12/2013 - Inclusao de VALIDATE craplcr, crapccp e craplch 
                           (Carlos)

              14/05/2014 - Inclusao origem "Recurso Proprio" (Guilherme/SUPERO)
              
              05/11/2014 - Alteraçao da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

              30/01/2015 - (Chamado 248647) Inclusao do campo novo INCONAUT
                            (Tiago Castro - RKAM).
                            
              24/02/2015 - Novo campo qtrecpro (Jonata-RKAM).              
                            
              27/02/2015 - Adicionar nova origem de recurso "MICROCREDITO PNMPO 
                           BNDES CECRED". (Jaison/Gielow - SD: 257430).
                           
              27/05/2015 - Incluir novo frame Projeto cessao de Credito. (James)
                           
............................................................................. */

{ includes/var_online.i }
{ includes/var_lcredi.i }   /*  Contem as definicoes das variaveis e forms  */

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


ASSIGN tel_flglispr = YES.

/** Cria registros no browser do campo tel_dsoperac **/
RUN cria_w-dsoperac. 
RUN cria_origem.
RUN cria_modali.

TRANS_I:
DO TRANSACTION ON ERROR UNDO TRANS_I, RETRY:
    
   DO aux_tentaler = 1 TO 10:
       
       FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                          craplcr.cdlcremp = tel_cdlcremp
                          NO-LOCK NO-ERROR NO-WAIT.

       IF  NOT AVAILABLE craplcr   THEN
           DO:
               CREATE craplcr.
               ASSIGN craplcr.cdlcremp = tel_cdlcremp
                      craplcr.tplcremp = 1
                      craplcr.tpctrato = 1
                      craplcr.nrdevias = 1
                      craplcr.flgstlcr = TRUE
                      craplcr.cdcooper = glb_cdcooper.
               VALIDATE craplcr.
           END.
       ELSE
           DO:
               glb_cdcritic = 937.
               RETURN.
           END.

       glb_cdcritic = 0.
       LEAVE.

   END.  /*  Fim do DO .. TO  */

   IF  glb_cdcritic > 0   THEN
       NEXT.

   aux_contador = 0.

   DISPLAY glb_cddopcao tel_cdlcremp WITH FRAME f_lcredi.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
   
      ASSIGN tel_flgcrcta = TRUE /* Altera flag(NO) somente GERENTE */
             tel_flgimpde = FALSE. 
           
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
         UPDATE tel_dslcremp WITH FRAME f_lcredi.
         LEAVE.
       
      END.
   
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
           LEAVE.
     
      tel_dslcremp = CAPS (tel_dslcremp).
     
      DISPLAY tel_dslcremp WITH FRAME f_lcredi.
     
      PAUSE 0.
         
      DISPLAY tel_flgcrcta
              tel_flgimpde 
              tel_dssitlcr WITH FRAME f_lcredi_2.
      
      ASSIGN tel_dsoperac:READ-ONLY = TRUE
             tel_origrecu:READ-ONLY = TRUE
             tel_cdmodali:READ-ONLY = TRUE
             tel_cdsubmod:READ-ONLY = TRUE.
   
      bloco_update:
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
         UPDATE tel_dsoperac
                tel_tplcremp tel_tpdescto
                tel_tpctrato tel_nrdevias 
                tel_flgrefin tel_flgreneg
                tel_cdusolcr tel_flgtarif tel_flgtaiof 
                tel_vltrfesp tel_flgcrcta tel_manterpo 
                tel_flgimpde
                tel_origrecu 
                tel_flglispr
                tel_cdmodali
                tel_cdsubmod
                WITH FRAME f_lcredi_2
                  
         EDITING:   
                       
           READKEY.
           
           IF   FRAME-FIELD = "tel_dsoperac" THEN
                DO:   
                    IF   LASTKEY = KEYCODE("F7")   THEN
                         DO:        
                             OPEN QUERY dsoperac-q FOR EACH w-dsoperac NO-LOCK.
 
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

                    /** Atribuicao para nao gravar valor do campo "Operacao" com cortes **/
                    ASSIGN aux_dsoperac = tel_dsoperac. 
 
                END.
           ELSE
           IF   FRAME-FIELD = "tel_origrecu" THEN
                DO:
                    IF   LASTKEY = KEYCODE("F7")  AND 
                         INPUT tel_cdusolcr = 1   THEN
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
                    IF   LASTKEY = KEYCODE ("F8") THEN
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
                             OPEN QUERY modali-q 
                                 FOR EACH tt-modali NO-LOCK.
                        
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
           IF   FRAME-FIELD = "tel_cdsubmod"    THEN
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
                                                                           
                  END.   /** Fim Editing **/
           
           LEAVE.
           
         END. /* Fim do DO WHILE TRUE */
           
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              DO:
                  HIDE FRAME f_lcredi_2.
                  NEXT.
              END.
            
         IF   tel_flgcrcta = FALSE  THEN
              RUN fontes/pedesenha.p (INPUT glb_cdcooper, 
                                      INPUT 3, 
                                      OUTPUT aut_flgsenha,
                                      OUTPUT aut_cdoperad).
                                                                        
         ASSIGN tel_dstipolc = ENTRY(tel_tplcremp,aux_dstipolc).
         
         /*  Descricao do modelo do contrato  */
         
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 0              AND
                          craptab.cdacesso = "CTRATOEMPR"   AND
                          craptab.tpregist = tel_tpctrato   NO-LOCK
                          USE-INDEX craptab1 NO-ERROR.
         
         IF   NOT AVAILABLE craptab   THEN
              DO:
                  glb_cdcritic = 529.
                  NEXT-PROMPT tel_tpctrato WITH FRAME f_lcredi_2.
                  NEXT.
              END.
         ELSE
              tel_dsctrato = craptab.dstextab.
     
         IF   tel_tpdescto = 1  THEN
              tel_dsdescto = "C/C".
         ELSE
              tel_dsdescto = "CONSIG. FOLHA".
        
         CASE tel_cdusolcr:
             WHEN 0 THEN tel_dsusolcr = "NORMAL".
             WHEN 1 THEN tel_dsusolcr = "MICRO CREDITO".
             WHEN 2 THEN tel_dsusolcr = "EPR/BOLETOS".
         END.
        
         DISPLAY tel_dsoperac
                 tel_dstipolc tel_dsctrato 
                 tel_dsdescto tel_dsusolcr
                 WITH FRAME f_lcredi_2.
           
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
            IF   glb_cdcritic > 0   THEN
                 DO:
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                 END.
           
            UPDATE tel_txjurfix tel_txjurvar tel_txpresta tel_txminima
                   tel_txmaxima tel_txbaspre
                   tel_nrgrplcr 
                   tel_qtcarenc
                   tel_perjurmo
                   tel_vlmaxass
                   tel_vlmaxasj
                   tel_nrinipre
                   tel_nrfimpre 
                   tel_qtdcasas
                   tel_consaut
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
                              NEXT-PROMPT tel_txminima  
                                          WITH FRAME f_lcredi_3.
                              NEXT.
                          END.
                 END.                  
              
            /*  Verifica se a taxa base pertence ao grupo informado  */
            FIND FIRST crablcr WHERE crablcr.cdcooper = glb_cdcooper   AND
                                     crablcr.nrgrplcr = tel_nrgrplcr
                                     NO-LOCK NO-ERROR.
           
            IF   AVAILABLE crablcr   THEN
                 DO:  
                     IF   glb_cdcooper <> 9  THEN
                          DO:
                              IF   tel_txbaspre <> crablcr.txbaspre  THEN
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
                              NEXT-PROMPT tel_txbaspre 
                                          WITH FRAME f_lcredi_3.
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
                 
            IF   tel_tpdescto = 2 THEN /* consig. folha */
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

         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            DO:
          	    HIDE FRAME f_lcredi_3.
                NEXT.
            END.
         
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

               END. /* END IF tel_flgcrcta THEN */

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
           
        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
             DO:
                 HIDE FRAME f_lcredi_2.
                 HIDE FRAME f_lcredi_3.
                 HIDE FRAME f_lcredi_4.
                 NEXT.
             END.
   
        LEAVE.
           
      END.  /*  Fim do DO WHILE TRUE  */
           
      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
           DO:
                HIDE FRAME f_lcredi_2.
                HIDE FRAME f_lcredi_3.
                HIDE FRAME f_lcredi_4.
                UNDO TRANS_I, NEXT.
           END.
          
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                         craptab.nmsistem = "CRED"         AND
                         craptab.tptabela = "GENERI"       AND
                         craptab.cdempres = 0              AND
                         craptab.cdacesso = "TAXASDOMES"   AND
                         craptab.tpregist = 1              NO-LOCK
                         USE-INDEX craptab1 NO-ERROR.
           
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
               
                UNDO TRANS_I, NEXT.
           END.
      
      ASSIGN aux_txutiliz = IF SUBSTRING(craptab.dstextab,1,1) = "T"
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
           
             tel_txdiaria = ROUND(tel_txmensal / 3000,7)
           
             craplcr.dslcremp = tel_dslcremp
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
             craplcr.tplcremp = tel_tplcremp
             craplcr.tpctrato = tel_tpctrato
             craplcr.tpdescto = tel_tpdescto
             craplcr.nrdevias = tel_nrdevias
             craplcr.cdusolcr = tel_cdusolcr
             craplcr.flgtarif = tel_flgtarif
             craplcr.flgtaiof = tel_flgtaiof
             craplcr.vltrfesp = tel_vltrfesp
             craplcr.flgcrcta = tel_flgcrcta
             craplcr.dsorgrec = tel_origrecu
             craplcr.nrdialiq = tel_manterpo
             craplcr.flgimpde = tel_flgimpde
             craplcr.flglispr = tel_flglispr
             craplcr.cdmodali = SUBSTR(tel_cdmodali,1,2)
             craplcr.cdsubmod = SUBSTR(tel_cdsubmod,1,2)
             craplcr.flgrefin = tel_flgrefin
             craplcr.flgreneg = tel_flgreneg
             craplcr.qtrecpro = tel_qtrecpro 
             craplcr.inconaut = IF   tel_consaut   THEN
                                     0
                                ELSE
                                     1           
             craplcr.flgsaldo = FALSE
             craplcr.flgstlcr = TRUE
             craplcr.dsoperac = aux_dsoperac
             craplcr.flgdisap = tel_flgdisap
             craplcr.flgcobmu = tel_flgcobmu
             craplcr.flgsegpr = tel_flgsegpr
             craplcr.cdhistor = tel_cdhistor
             
             tel_txdiaria = tel_txdiaria * 100.
        
      DISPLAY tel_flgdisap
              tel_flgcobmu
              tel_flgsegpr
              tel_cdhistor
              WITH FRAME f_lcredi_4.

      DISPLAY tel_txjurfix tel_txjurvar tel_txpresta tel_txminima tel_txmaxima
              tel_txmensal tel_txdiaria tel_qtdcasas tel_nrinipre tel_nrfimpre
              tel_txbaspre 
              tel_qtcarenc
              tel_perjurmo
              tel_vlmaxass
              tel_vlmaxasj
              tel_nrgrplcr
              tel_consaut
              WITH FRAME f_lcredi_3.

      PAUSE 0.

      DISPLAY tel_dsoperac
              tel_tplcremp tel_dstipolc
              tel_tpctrato tel_dsctrato tel_nrdevias
              tel_flgrefin tel_flgreneg 
              tel_cdusolcr tel_flgtarif tel_flgtaiof
              tel_vltrfesp tel_flgcrcta tel_dssitlcr 
              tel_tpdescto tel_dsdescto tel_dsusolcr
              WITH FRAME f_lcredi_2.

      PAUSE 0.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
         UPDATE tel_cdfinemp
                HELP "Infome o codigo da finalidade do emprestimo."
                
                WITH FRAME f_finali.
      
         DO aux_contador = 1 TO 81:
      
            IF   tel_cdfinemp[aux_contador] = 0   THEN
                 NEXT.
           
               IF   CAN-FIND(crapfin WHERE
                         crapfin.cdcooper = glb_cdcooper   AND 
                         crapfin.cdfinemp = tel_cdfinemp[aux_contador])   THEN                                           
                                       NEXT.
            ELSE
                 DO:
                     glb_cdcritic = 362.
                     NEXT-PROMPT tel_cdfinemp[aux_contador] WITH FRAME f_finali.
                     LEAVE.
                 END.
      
         END.  /*  Fim do DO .. TO  */
      
         IF   glb_cdcritic > 0   THEN
              DO:
                  BELL.
                  RUN fontes/critic.p.
                  MESSAGE glb_dscritic.
                  glb_cdcritic = 0.
                  NEXT.
              END.
      
         LEAVE.
      
   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_finali NO-PAUSE.
            UNDO TRANS_I, NEXT.
        END.

   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        DO:
            HIDE FRAME f_finali NO-PAUSE.
            UNDO TRANS_I, NEXT.
        END.

   FOR EACH crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                          crapccp.cdlcremp = craplcr.cdlcremp
                          EXCLUSIVE-LOCK:
       DELETE crapccp.             
   END.
 
   /*  Criando tabela de coeficientes de prestacao  */
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

   ATUALIZA_I:
   DO aux_contador = 1 TO 81:

       IF   tel_cdfinemp[aux_contador] = 0   THEN
             NEXT.

       DO WHILE TRUE:

           FIND crapfin WHERE crapfin.cdcooper = glb_cdcooper  AND
                              crapfin.cdfinemp = tel_cdfinemp[aux_contador]
                              NO-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crapfin   THEN
                NEXT ATUALIZA_I.

           LEAVE.
     
       END.  /* Fim do DO WHILE TRUE  */  
     
       FIND craplch WHERE craplch.cdcooper = glb_cdcooper               AND
                          craplch.cdlcrhab = craplcr.cdlcremp           AND
                          craplch.cdfinemp = tel_cdfinemp[aux_contador]
                          NO-LOCK NO-ERROR NO-WAIT.

       IF  NOT AVAIL craplch THEN
           DO:
                FIND LAST crablch WHERE crablch.cdcooper = glb_cdcooper      AND
                                        crablch.cdfinemp = crapfin.cdfinemp
                                        NO-LOCK NO-ERROR NO-WAIT.

                IF AVAIL crablch THEN
                    ASSIGN aux_nrseqlch = crablch.nrseqlch.
                ELSE
                    ASSIGN aux_nrseqlch = 0.

                    CREATE craplch.
                    ASSIGN craplch.cdcooper = crapfin.cdcooper
                           craplch.cdfinemp = tel_cdfinemp[aux_contador]
                           craplch.cdlcrhab = craplcr.cdlcremp
                           craplch.nrseqlch = aux_nrseqlch + 1.
                VALIDATE craplch.
          END.
   END.  /*  Fim do DO .. TO  */

   tel_cdlcremp = 0.

   HIDE  FRAME f_finali NO-PAUSE.

END.  /*  Fim da transacao  */

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

PROCEDURE cria_Origem:

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
        ASSIGN tt-modali.cdmodali = gnmodal.cdmodali +  "-" + 
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
/* .......................................................................... */
