/* .............................................................................

   Programa: Fontes/lcredie.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                           Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de exclusao da tela LCREDI.

   Alteracoes: 14/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o sinali-
                          zador de linha com saldo devedor.

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
             20/12/2002 - Incluir campo Valor Tarifa Especial (Junior).

             24/03/2004 - Incluido na tela campo Dias Carencia(Mirtes).
 
             11/06/2004 - Incluido na tela campos - Valor Maximo Linha e
                                         Valor Maximo Associado (Evandro).

             28/06/2004 - Removido - colocado em comentarios - o campo Valor
                          Maximo Linha - tel_vlmaxdiv (Evandro).

             10/08/2004 - Incluido campo tel_vlmaxasj - Valor Maximo Pessoa
                          Juridica (Evandro).

             30/08/2004 - Tratamento para tipo de desconto de emprestimo
                          (Julio).

             27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

             17/03/2006 - Excluido campo "Conta ADM", e acrescentado 
                          tel_flgcrcat (Diego).
                          
             28/08/2007 - Adicionado campo cdusolcr(Guilherme).

             20/05/2008 - Utilizar a tabela crapccp para armazenar o
                          coeficiente da linhas de credito, no lugar do
                          extende atributo craplcr.incalpre(Sidnei - Precise)

             24/06/2009 - Incluido campo Operacao (Gabriel).   

             22/07/2009 - Tratar tel_cdusolcr com tipo 2 - EPR/BOLETOS.
                          (Fernando).
                          
             16/12/2009 - Alterado campo tel_dsoperac (Elton).
             
             15/03/2010 - Incluido o campo que ira indicar o tempo que o 
                            emprestimo permanecera na atenda apos sua 
                            liquidacao (Gati -Daniel). 
                            
             16/03/2010 - incluido o campo que ira conter a origem do
                            recurso (gati - Daniel)    
                            
             29/06/2010 - Incluir campo de 'listar na proposta' (Gabriel).   
             
             23/05/2012 - Adicionado campo de Tarifa IOF (Lucas).   
             
             11/06/2012 - Tratamento para remoção do campo EXTENT crapfin.cdlcrhab (Lucas).
             
             25/07/2012 - Gravação de LOG (Lucas).
             
             04/10/2012 - Incluir novos campos modalidade e Submodalidade
                          (Gabriel). 
                          
             11/10/2012 - Incluir Campo flgreneg na tela (Lucas R.)
             
             28/05/2013 - Softdesk 66547 Incluir Campo flgrefin na tela 
                          (Carlos)
                          
             25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                          posicoes (Tiago/Gielow SD137074).             
............................................................................. */

{ includes/var_online.i }

{ includes/var_lcredi.i }   /*  Contem as definicoes das variaveis e forms  */

TRANS_E:

DO TRANSACTION ON ERROR UNDO TRANS_E, RETRY:

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
          tel_origrecu = craplcr.dsorgrec
          tel_manterpo = craplcr.nrdialiq
          
          tel_tplcremp = craplcr.tplcremp
          tel_dstipolc = ENTRY(craplcr.tplcremp,aux_dstipolc)

          tel_dssitlcr = IF craplcr.flgsaldo
                            THEN tel_dssitlcr + " COM SALDO"
                            ELSE tel_dssitlcr + " SEM SALDO"
          
          tel_dsoperac = craplcr.dsoperac
          tel_flglispr = craplcr.flglispr
          tel_flgimpde = craplcr.flgimpde
          
          tel_flgrefin = craplcr.flgrefin
          tel_flgreneg = craplcr.flgreneg

          tel_cdfinemp = 0

          aux_contador = 0
          aux_lsfinhab = "".

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

   FOR EACH craplch WHERE craplch.cdcooper = glb_cdcooper      AND
                          craplch.cdlcrhab = craplcr.cdlcremp  NO-LOCK:

       ASSIGN aux_contador = aux_contador + 1
              tel_cdfinemp[aux_contador] = craplch.cdfinemp
              aux_lsfinhab = aux_lsfinhab + STRING(craplch.cdfinemp) + ",".

   END.  /*  Fim do FOR EACH  */

   DISPLAY tel_dslcremp WITH FRAME f_lcredi.

   PAUSE 0.

   DISPLAY tel_dsoperac
           tel_tplcremp tel_dstipolc tel_flgtarif tel_flgtaiof tel_vltrfesp
           tel_flgcrcta tel_tpctrato tel_dsctrato tel_nrdevias 
           tel_flgrefin tel_flgreneg
           tel_cdusolcr tel_dssitlcr tel_tpdescto tel_dsdescto tel_dsusolcr 
           tel_flgimpde tel_origrecu tel_manterpo tel_flglispr  
           tel_cdmodali tel_cdsubmod
           WITH FRAME f_lcredi_2.

   aux_contador = 1.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
      aux_confirma = "N".

      glb_cdcritic = 378.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.

      IF   NOT CAN-DO("S,N",aux_confirma)   THEN
           NEXT.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
       NEXT.

   IF  aux_confirma = "S"   THEN
       DO:
             RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 UNDO TRANS_E, NEXT.
                 
            /*  Bloqueia a linha de credito para nao ser mais utilizada  */
            craplcr.flgstlcr = FALSE.

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Aguarde, pesquisando contratos de emprestimos...".

            FIND FIRST crapepr WHERE crapepr.cdcooper = glb_cdcooper    AND
                                     crapepr.cdlcremp = tel_cdlcremp    NO-LOCK
                                     USE-INDEX crapepr2 NO-ERROR.

            IF   AVAILABLE crapepr   THEN
                 DO:
                     HIDE MESSAGE NO-PAUSE.

                     ASSIGN glb_cdcritic = 377
                            aux_flgclear = FALSE.
                     UNDO TRANS_E, NEXT.
                 END.

            HIDE MESSAGE NO-PAUSE.

            /*  Zera os coeficientes de prestacao  */

            /** craplcr.incalpre = 0.  **/
            FOR EACH crapccp WHERE crapccp.cdcooper = craplcr.cdcooper AND
                                   crapccp.cdlcremp = craplcr.cdlcremp
                                   EXCLUSIVE-LOCK:
                DELETE crapccp.             
            END.

            FOR EACH craplch WHERE craplch.cdcooper = glb_cdcooper     AND
                                   craplch.cdlcrhab = craplcr.cdlcremp
                                   EXCLUSIVE-LOCK.

                DELETE craplch.

            END.

            DELETE craplcr.

            CLEAR FRAME f_lcredi   NO-PAUSE.
            CLEAR FRAME f_lcredi_2 NO-PAUSE.
            HIDE  FRAME f_finali NO-PAUSE.

            FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                               craplcr.cdlcremp = tel_cdlcremp
                               NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplcr   THEN
                    DO:
                        /* Grava LOG da Linha de Crédito Deletada */
                        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                                                      STRING(TIME,"HH:MM:SS") + "' --> '"       +
                                                      " Operador: " + glb_cdoperad              +
                                                      " Deletou a Linha de Credito "            +
                                                      STRING(tel_cdlcremp,"zzz9")                +
                                                      " - " + tel_dslcremp + "."                +   
                                                      " >> log/lcredi.log").
                    END.

            ASSIGN tel_cdlcremp = 0.
            NEXT.
        END.

   tel_cdfinemp = 0.

   HIDE MESSAGE NO-PAUSE.

   MESSAGE "Finalidades disponiveis:" SUBSTRING(aux_lsfinhab,001,70).
   MESSAGE SUBSTRING(aux_lsfinhab,071,70).

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
      UPDATE tel_cdfinemp HELP "Infome o codigo da finalidade do emprestimo."
             WITH FRAME f_finali.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_finali NO-PAUSE.
            UNDO TRANS_E, NEXT.
        END.

   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S"   THEN
        DO:
            HIDE FRAME f_finali NO-PAUSE.
            UNDO TRANS_E, NEXT.
        END.

   ATUALIZA_E_2:
   DO aux_contador = 1 TO 81:
                
      IF  tel_cdfinemp[aux_contador] > 0   THEN
          DO:
               FIND craplch WHERE craplch.cdcooper = glb_cdcooper                AND
                                  craplch.cdlcrhab = craplcr.cdlcremp            AND
                                  craplch.cdfinemp = tel_cdfinemp[aux_contador]
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF  NOT AVAILABLE craplch   THEN
                   IF  LOCKED craplch   THEN
                       DO:
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                   ELSE
                       NEXT ATUALIZA_E_2.
                       
               DELETE craplch.
               ASSIGN aux_cdfinlog = aux_cdfinlog + STRING(tel_cdfinemp[aux_contador]) + ", ".
          END.

   END.  /* Fim do DO .. TO  */

   /* Grava LOG das Finalidades Deletadas */
   IF aux_cdfinlog <> "" THEN
   UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " "     +
                                 STRING(TIME,"HH:MM:SS") + "' --> '"       +
                                 " Operador: " + glb_cdoperad              +
                                 " Deletou as finalidades " + aux_cdfinlog +
                                 " da Linha de Credito"                    +
                                 STRING(craplcr.cdlcremp,"zzz9")            +
                                 " - " + craplcr.dslcremp + "."            +   
                                 " >> log/lcredi.log").

   CLEAR FRAME f_lcredi   NO-PAUSE.
   CLEAR FRAME f_lcredi_2 NO-PAUSE.
   HIDE  FRAME f_finali   NO-PAUSE.

END.  /*  Fim da transacao  */

/* .......................................................................... */
