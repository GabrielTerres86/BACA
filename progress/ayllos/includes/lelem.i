/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/lelem.i                | EMPR0001.pc_leitura_lem           |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/



/* .............................................................................

   Programa: includes/lelem.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93.                    Ultima atualizacao: 15/05/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de calculo de emprestimo.

   Alteracoes: 31/05/95 - Tratar o historico 95 (Edson).

               12/06/96 - Calcular prestacoes pagas (Edson).

               25/06/96 - Verificar integridade do inliquid x vlsdeved (Edson).

               01/11/96 - Alterado para calcular ate a data do movimento no
                          caso de contratos com debito em conta (Edson).

               27/01/98 - Criado historico 277 - estorno de juros (Deborah).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).

               05/11/98 - Alterado a forma de tratar os emprestimos com 
                          pagamento vinculado a conta-corrente (Edson).

               12/11/98 - Tratar atendimento noturno (Deborah).

               15/12/1999 - Tratar historico 349 (Edson).

               03/03/2000 - Tirar mensagem de correcao do saldo devedor 
                            (Deborah).

               22/03/2000 - Tratar historico 353 (Deborah).

               15/05/2002 - Nao descontar 88 fora do mes (Margarete).
               
               05/07/2002 - Tratar historicos 392, 393 e 395 (Edson).
               
               18/12/2002 - Quando estorno esta calculando prestacao
                            do mes errada (Margarete).
                            
               02/05/2003 - Tratar o historico 94 da mesma forma que o 91
                            (Edson).

               10/11/2003 - Tratar historicos 441 e 443 de forma semelhante ao
                            historico 88 (Edson).

               01/03/2004 - Desprezar histor 395 calculo qtprecal (Margarete).
               
               06/05/2004 - Quando histor 88 estava descontando duas
                            vez do aux_vlprepag (Margarete).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               31/05/2007 - Tratamento para historico 507 (Julio) 

               22/12/2010 - Se conta transferida nao ler o craplem.
                            Lancamento zerando no 1 dia util (Magui).

               20/09/2011- Erro no calculo do qtprepag. Quando pagto em
                           folha estava sempre contando como a prestacao
                           paga integral (Magui).

               10/01/2012 - Melhoria de desempenho (Gabriel)

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).

               15/01/2014 - Ajuste para igualdade com o Oracle (Gabriel).

               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)

               15/05/2015 - Projeto 158 - Servico Folha de Pagto
                           (Andre Santos - SUPERO)
............................................................................. */

DEF BUFFER crabemp FOR crapemp.
DEF BUFFER crabhis FOR craphis.

DEF        VAR lem_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR lem_qtprecal AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR lem_qtprepag AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR lem_vlrpgmes LIKE crapepr.vlpreemp EXTENT 30          NO-UNDO.
DEF        VAR lem_qtdpgmes AS INTE                                  NO-UNDO.
DEF        VAR lem_exipgmes AS LOGICAL                               NO-UNDO.
DEF        VAR lem_varqtdpg AS INTE                                  NO-UNDO.
DEF        VAR lem_flctamig AS LOG                                   NO-UNDO.


FIND crabemp WHERE crabemp.cdcooper = glb_cdcooper      AND 
                   crabemp.cdempres = crapepr.cdempres  NO-LOCK NO-ERROR.
                     
IF   AVAILABLE crabemp   THEN
     IF   (NOT crabemp.flgpagto OR NOT crabemp.flgpgtib)   THEN
          tab_diapagto = 0.

IF  (tab_diapagto > 0) AND (NOT crapepr.flgpagto) THEN
     tab_diapagto = 0.

ASSIGN lem_dtmvtolt = glb_dtmvtolt

       lem_flctamig = NO
       
       lem_qtprecal = 0

       lem_vlrpgmes = 0
       
       lem_qtdpgmes = 0
       
       aux_dtmesant = lem_dtmvtolt - DAY(lem_dtmvtolt)

       aux_nrdiacal = IF MONTH(crapepr.dtmvtolt) = MONTH(lem_dtmvtolt) AND
                          YEAR(crapepr.dtmvtolt) =  YEAR(lem_dtmvtolt)
                         THEN DAY(crapepr.dtmvtolt)
                         ELSE 0

       aux_vlprepag = 0
       aux_vljurmes = 0

       aux_inhst093 = FALSE

       glb_cdcritic = 0.

/*  Testa se esta rodando no batch e e' mensal  */

IF   glb_inproces > 2   THEN
     IF   CAN-DO("CRPS080,CRPS085,CRPS120",glb_cdprogra)   THEN
          IF   MONTH(lem_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
               ASSIGN lem_dtmvtolt = aux_dtultdia
                      aux_dtmesant = aux_dtultdia
                      aux_nrdiacal = 0.

IF  crapepr.inliquid = 1   AND
    crapepr.vlsdeved = 0   THEN
    DO:
        FIND craptco WHERE craptco.cdcopant = crapepr.cdcooper AND
                           craptco.nrctaant = crapepr.nrdconta AND
                           craptco.tpctatrf = 1                AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
        IF   AVAILABLE craptco   THEN
             DO:
                 FIND LAST craplem
                     WHERE craplem.cdcooper = crapepr.cdcooper   AND
                           craplem.nrdconta = crapepr.nrdconta   AND
                           craplem.nrctremp = crapepr.nrctremp   AND
                           craplem.cdhistor = 921 /* zerado pela migracao */
                           NO-LOCK NO-ERROR.
                 IF   AVAILABLE craplem  THEN
                      ASSIGN lem_flctamig = YES.
             END.
    END.

DO WHILE TRUE:
   FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper   AND
                          craplem.dtmvtolt > aux_dtmesant   AND
                          craplem.nrdconta = aux_nrdconta   AND
                          craplem.nrctremp = aux_nrctremp   NO-LOCK
                          BY craplem.dtmvtolt
                             BY craplem.cdhistor:

       /*** Conta migrada teve o seu zeramento no primeiro dia util do
            mes seguinte ***/
       IF  lem_flctamig THEN
           NEXT.
           
       FIND crabhis OF craplem NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crabhis   THEN
            DO:
                glb_cdcritic = 80.
                LEAVE.
            END.

       /*  Calcula percentual pago na prestacao e/ou acerto  */

       IF   CAN-DO("88,91,92,93,94,95,120,277,349,353,392,393,507",
                   STRING(craplem.cdhistor))   THEN
            DO:
                lem_qtprepag = 0.

                IF   craplem.vlpreemp > 0   THEN
                     lem_qtprepag = ROUND(craplem.vllanmto /
                                                  craplem.vlpreemp,4).

                IF   CAN-DO("88,120,507",STRING(craplem.cdhistor))  THEN
                     lem_qtprecal = lem_qtprecal - lem_qtprepag.
                ELSE
                     lem_qtprecal = lem_qtprecal + lem_qtprepag.
            END.

       aux_ddlanmto = DAY(craplem.dtmvtolt).

       IF   CAN-DO("91,92,94,277,349,353,392,393",
                               STRING(craplem.cdhistor))   THEN
            DO:
                aux_dtultpag = craplem.dtmvtolt.

                IF   aux_vlsdeved > 0   THEN
                     IF   aux_nrdiacal > aux_ddlanmto   THEN
                          aux_vljurmes = aux_vljurmes + (craplem.vllanmto *
                                             aux_txdjuros * (aux_ddlanmto -
                                                 aux_nrdiacal)).
                     ELSE
                          aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                             aux_txdjuros * (aux_ddlanmto -
                                                 aux_nrdiacal)).

                aux_nrdiacal = IF aux_nrdiacal > aux_ddlanmto
                                  THEN aux_nrdiacal
                                  ELSE aux_ddlanmto.
                       
                ASSIGN aux_vlsdeved = aux_vlsdeved - craplem.vllanmto
                       aux_vlprepag = aux_vlprepag + craplem.vllanmto
                       lem_qtdpgmes = lem_qtdpgmes + 1
                       lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
            END.
       ELSE
       IF   craplem.cdhistor = 93   OR
            craplem.cdhistor = 95   THEN
            DO:
                aux_dtultpag = craplem.dtmvtolt.

                IF   aux_ddlanmto > tab_diapagto   THEN
                     IF   aux_vlsdeved > 0   THEN
                          ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                                aux_txdjuros * (aux_ddlanmto -
                                                aux_nrdiacal))
                                 aux_nrdiacal = aux_ddlanmto.
                     ELSE
                          aux_nrdiacal = aux_ddlanmto.
                ELSE
                     IF   aux_vlsdeved > 0   THEN
                          ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                                aux_txdjuros *
                                                (tab_diapagto - aux_nrdiacal))
                                 aux_nrdiacal = tab_diapagto

                                 aux_inhst093 = TRUE.
                     ELSE
                          aux_nrdiacal = tab_diapagto.

                ASSIGN /***aux_qtprepag = aux_qtprepag + 1 ***/
                       aux_vlsdeved = aux_vlsdeved - craplem.vllanmto
                       aux_vlprepag = aux_vlprepag + craplem.vllanmto
                       lem_qtdpgmes = lem_qtdpgmes + 1
                       lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
            END.
       ELSE                               /* Mirtes Verificar aqui */
       IF   CAN-DO("88,395,441,443,507",STRING(craplem.cdhistor))   THEN
            DO:
                IF   aux_vlsdeved > 0   THEN
                     IF   aux_ddlanmto < tab_diapagto   THEN
                          IF   aux_nrdiacal = tab_diapagto   THEN
                               aux_vljurmes = aux_vljurmes +
                                             (craplem.vllanmto * aux_txdjuros *
                                                 (tab_diapagto - aux_ddlanmto)).
                          ELSE
                               ASSIGN aux_vljurmes = aux_vljurmes +
                                                     (aux_vlsdeved *
                                                      aux_txdjuros *
                                                          (aux_ddlanmto -
                                                           aux_nrdiacal))
                                      aux_nrdiacal = aux_ddlanmto.
                     ELSE
                     IF   aux_ddlanmto > tab_diapagto   THEN
                          ASSIGN aux_vljurmes = aux_vljurmes +
                                                (aux_vlsdeved * aux_txdjuros *
                                                (aux_ddlanmto - aux_nrdiacal))
                                 aux_nrdiacal = aux_ddlanmto.
                     ELSE .
                ELSE
                     aux_nrdiacal = IF aux_nrdiacal > aux_ddlanmto
                                       THEN aux_nrdiacal
                                       ELSE aux_ddlanmto.
                
                IF   craplem.cdhistor = 88   OR
                     craplem.cdhistor = 507  THEN /* estorno de pagamento */
                     DO:

                         ASSIGN aux_vlprepag = aux_vlprepag - craplem.vllanmto.
       
                         
                         IF   aux_vlprepag < 0   THEN
                              aux_vlprepag = 0.
                     END.
                     
                ASSIGN aux_vlsdeved = aux_vlsdeved + craplem.vllanmto
                       lem_exipgmes = NO.

                DO lem_varqtdpg = 1 TO lem_qtdpgmes:
                   IF   lem_vlrpgmes[lem_varqtdpg] = craplem.vllanmto    THEN
                        DO:
                            ASSIGN lem_exipgmes = YES.
                            LEAVE.
                        END.    
                END. 
                
                IF   lem_exipgmes   THEN
                     DO:
                         IF   craplem.cdhistor <> 88    AND
                              craplem.cdhistor <> 507   THEN
                         aux_vlprepag = IF aux_vlprepag >= craplem.vllanmto
                                           THEN aux_vlprepag - craplem.vllanmto
                                           ELSE 0.                         
                     END.
                     
            END.

   END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos de emprestimos  */
   IF   glb_cdcritic > 0   THEN
        LEAVE.

   IF   glb_inproces > 2   THEN
        IF   CAN-DO("CRPS080,CRPS085,CRPS120",glb_cdprogra)   THEN
             IF   MONTH(lem_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
                  aux_nrdiacal = 0.
             ELSE
                  aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
        ELSE
             IF   MONTH(lem_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
                  aux_nrdiacal = DAY(aux_dtultdia) - aux_nrdiacal.
             ELSE
                  aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
   ELSE
        aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.

   ASSIGN aux_vljurmes = IF aux_vlsdeved > 0
                            THEN aux_vljurmes + (aux_vlsdeved * aux_txdjuros *
                                                 aux_nrdiacal)
                            ELSE aux_vljurmes
          aux_qtprepag = TRUNCATE(lem_qtprecal,0).                  

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

aux_nrdiacal = 0.

IF   aux_dtcalcul <> ?   AND
     aux_vlsdeved  > 0   THEN
     DO:
         ASSIGN aux_nrdiacal = aux_dtcalcul - lem_dtmvtolt

                aux_nrdiames = IF aux_dtcalcul > aux_dtultdia
                                  THEN DAY(aux_dtultdia) - DAY(lem_dtmvtolt)
                                  ELSE aux_nrdiacal

                aux_nrdiamss = IF aux_dtcalcul > aux_dtultdia
                                  THEN aux_nrdiacal - aux_nrdiames
                                  ELSE 0.

         IF   aux_nrdiamss = 0   THEN
              aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                             aux_txdjuros * aux_nrdiames).
         ELSE
              ASSIGN aux_vljurmes = aux_vljurmes + (aux_vlsdeved *
                                        aux_txdjuros * aux_nrdiames)

                     aux_vljurmes = ROUND(aux_vljurmes,2)
                     aux_vlsdeved = aux_vlsdeved + aux_vljurmes
                     aux_vljuracu = aux_vljuracu + aux_vljurmes
                     aux_vljurmes = aux_vlsdeved * aux_txdjuros * aux_nrdiamss.

         aux_nrdiacal = IF DAY(aux_dtcalcul) < tab_diapagto
                           THEN tab_diapagto - DAY(aux_dtcalcul)
                           ELSE 0.
     END.
ELSE
     IF   DAY(lem_dtmvtolt) < tab_diapagto   AND
          glb_inproces < 3                   AND
          aux_vlsdeved > 0                   AND
          NOT aux_inhst093                   THEN
          aux_nrdiacal = tab_diapagto - DAY(lem_dtmvtolt).
     ELSE
          aux_nrdiacal = 0.

/*  Calcula juros sobre a prest. quando a consulta e' menor que o data pagto  */

IF   aux_nrdiacal > 0   AND   crapepr.dtdpagto <= aux_dtultdia   THEN
     IF   aux_vlsdeved > crapepr.vlpreemp   THEN
          aux_vljurmes = aux_vljurmes + (crapepr.vlpreemp * aux_txdjuros *
                                         aux_nrdiacal).
     ELSE
          aux_vljurmes = aux_vljurmes + (aux_vlsdeved * aux_txdjuros *
                                         aux_nrdiacal).

ASSIGN aux_vljurmes = ROUND(aux_vljurmes,2)
       aux_vljuracu = aux_vljuracu + aux_vljurmes
       aux_vlsdeved = aux_vlsdeved + aux_vljurmes.

IF   aux_vlsdeved > 0   AND   crapepr.inliquid > 0   THEN
     DO:
         IF   glb_inproces > 2   AND   glb_cdprogra = "crps078"   THEN
              DO:
                  IF   aux_vljurmes >= aux_vlsdeved   THEN
                       DO:                      
                           ASSIGN aux_vljurmes = aux_vljurmes - aux_vlsdeved
                                  aux_vljuracu = aux_vljuracu - aux_vlsdeved
                                  aux_vlsdeved = 0.
                       END.
                  ELSE
                       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                 " - " + glb_cdprogra + "' --> '" +
                                 "ATENCAO: NAO FOI POSSIVEL ZERAR O SALDO -" +
                                 " CONTA = " +
                                 STRING(crapepr.nrdconta,"zzzz,zzz,9") +
                                 " CONTRATO = " +
                                 STRING(crapepr.nrctremp,"zz,zzz,zz9") +
                                 " SALDO = " +
                                 STRING(aux_vlsdeved,"zzz,zz9.99") +
                                 " >> log/proc_batch.log").
              END.
         ELSE
              ASSIGN aux_vljurmes = aux_vljurmes - aux_vlsdeved
                     aux_vljuracu = aux_vljuracu - aux_vlsdeved
                     aux_vlsdeved = 0.
     END.


/* .......................................................................... */
