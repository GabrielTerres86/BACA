/* .............................................................................

   Programa: Fontes/slddpv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/95.                       Ultima atualizacao: 21/05/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para montar o saldo em depositos a vista e mostrar o
               extrato dos mesmos na tela ATENDA.

   Alteracao : 27/04/95 - Alterado para pedir a data de referencia para mostrar
                          o extrato (Odair).

               01/04/96 - Alterado para limitar a leitura de lancamentos para
                          extrato em 100 registros (Edson).

               16/01/97 - Alterado para tratar CPMF (Edson).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               03/09/97 - Alterado para alimenta campo aux_vldfolha para calculo
                          da rotina sldfol (Odair)

               16/10/07 - Alterado para mostrar a data de liberacao dos
                          depositos bloqueados (Edson).

               16/02/98 - Alterar a data final do CPMF (Odair)

               15/04/98 - Tratamento para milenio e troca para V8 (Magui).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               26/01/99 - Mostar a base de calculo do IOF sobre c/c (Deborah).
               
               19/02/99 - Alterado para nao calcular a CPMF sobre os valores
                          do item FOLHA (Deborah).

               02/03/99 - Tratar o saldo para a opcao LAUTOM (Deborah).

               15/04/1999 - Tratar debito do IOF sobre resgates antecipados
                            (Deborah).

               07/06/1999 - Tratar CPMF (Deborah).  

               02/08/1999 - Ler lista de historicos de uma tabela (Edson).

               17/03/2000 - Tratar campos para tela atenda estouros e 
                            liquidacoes (odair)
               
               20/08/2001 - Tratar onze posicoes no numero do documento (Edson).
            
               26/09/2002 - Tratar os historicos 351, 024 e 027 para mostrar
                            o cdpesqbb. (Ze Eduardo).

               26/03/2003 - Incluir tratamento da Concredi (Magui).

               07/04/2003 - Incluir tratamento do histor 399 (Magui).

               21/05/2003 - Alterado para tratar os historicos 104, 302 e 303
                            (Edson).
                            
               27/06/2003 - Incluir 156 na descricao do historico (Ze).        
               
               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera 
                            armazenado na variavel aux_lsconta3 (Julio).

               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               18/01/2005 - Nao mostrar mais a palavra "ESTOR" para os depositos
                            estornados (Edson).

               09/03/2005 - Verificar se necessidade de ler lancamentos
                            (glb_inproces = 3)(Mirtes).

               25/04/2005 - Aumentar a leitura do campo nrdocmto para 20 pos.
                            (Julio)

               22/06/2005 - Possibilitar pesquisa com mais de 2 meses(Mirtes).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Magui).

               09/12/2005 - Cheque salario nao existe mais (Magui).             

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               06/02/2006 - Inclusao de NO-UNDO nas temp-tables (substituicao
                            de FOR EACH/DELETE por EMPTY-TEMP-TABLE)- SQLWorks
                            - Eder 

               02/02/2007 - Exclusao do campo tel_vlbasiof (Diego).

               03/07/2007 - Prever historicos transferencia Internet(Mirtes)

               03/03/2008 - Incluir o historico 338 na lista de historico 
                            com cheque devolvido para exibir alinea (Ze).

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               09/09/2009 - Incluir historicos de transferencia de credito de
                            salario (David).

               23/11/2009 - Alteracao Codigo Historico (Kbase).

               08/01/2010 - Acrescentar historico 573 no mesmo IF com o 338
                            (Guilherme/Precise)
                            
               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                            
               21/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

{ includes/ctremp.i }

{ includes/var_cpmf.i } 

DEF INPUT  PARAM par_flgextra AS LOGICAL                             NO-UNDO.

DEF VAR aux_vlalipmf AS DECIMAL                                      NO-UNDO.
DEF VAR aux_vlestorn AS DECIMAL                                      NO-UNDO.
DEF VAR aux_vlestabo AS DECIMAL                                      NO-UNDO.

DEF VAR aux_indoipmf AS INT                                          NO-UNDO.

DEF VAR aux_dslibera AS CHAR                                         NO-UNDO.

DEF VAR tab_dtiniiof AS DATE                                         NO-UNDO.
DEF VAR tab_dtfimiof AS DATE                                         NO-UNDO.
DEF VAR tab_txiofapl AS DECIMAL FORMAT "zzzzzzzz9,999999"            NO-UNDO.

DEF VAR aux_lsconta3 AS CHAR                                         NO-UNDO.

IF   glb_dtmvtolt > 01/22/1997 AND glb_dtmvtolt < 01/24/1999 THEN
     aux_vlalipmf = glb_vlalipmf.
ELSE
     aux_vlalipmf = 0.

{ includes/cpmf.i }      

/*  Leitura da tabela de parametros para indentificar o Nro. da conta  */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).
                   
/*   FIM DA LEITURA DA TABELA DE PARAMETROS   */

/*  Historico de cheques  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "HSTCHEQUES"   AND
                   craptab.tpregist = 0 NO-LOCK NO-ERROR.

IF   AVAILABLE craptab   THEN
     aux_lshistor = craptab.dstextab.
ELSE
     aux_lshistor = "999".
    
/*  Tabela com a taxa do IOF */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "USUARI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "CTRIOFRDCA"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 626.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         NEXT.
     END.

ASSIGN tab_dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       tab_dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       tab_txiofapl = IF   glb_dtmvtolt >= tab_dtiniiof AND
                           glb_dtmvtolt <= tab_dtfimiof 
                           THEN DECIMAL(SUBSTR(craptab.dstextab,23,16))
                           ELSE 0.
 
IF   NOT par_flgextra  THEN
     DO:
         FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper  AND
                            crapsld.nrdconta = tel_nrdconta  NO-LOCK NO-ERROR.

         IF   NOT AVAIL crapsld   THEN
              DO:
                  glb_cdcritic = 10.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  RETURN.
              END.

         ASSIGN tel_vlsddisp = crapsld.vlsddisp
                tel_vlsdbloq = crapsld.vlsdbloq
                tel_vlsdblpr = crapsld.vlsdblpr
                tel_vlsdblfp = crapsld.vlsdblfp
                tel_vlsdchsl = crapsld.vlsdchsl
                tel_vlsmnesp = crapsld.vlsmnesp
                tel_vlsmnmes = crapsld.vlsmnmes
                tel_vlsmnblq = crapsld.vlsmnblq
                tel_qtddsdev = crapsld.qtddsdev
                tel_qtddtdev = crapsld.qtddtdev

                aux_vlipmfap = 0
                aux_flgerros = FALSE
                aux_vlestabo = 0.


         /*--------------*/
         IF  glb_inproces >=3 THEN
             DO:
                IF  crapsld.dtrefere <>   glb_dtmvtoan THEN 
                    DO: /* Nao rodou crps001 */
         
                        /*  Leitura dos lancamentos dia Anterior */

                       FOR EACH craplcm WHERE 
                                craplcm.cdcooper = glb_cdcooper       AND
                                craplcm.nrdconta = crapsld.nrdconta   AND
                                craplcm.dtmvtolt = glb_dtmvtoan       AND
                                craplcm.cdhistor <> 289 NO-LOCK
                                USE-INDEX craplcm2:   

                           FIND craphis WHERE 
                                        craphis.cdhistor = craplcm.cdhistor AND
                                        craphis.cdcooper = craplcm.cdcooper
                                        NO-LOCK NO-ERROR.

                           IF   NOT AVAIL craphis   THEN
                                DO:
                                   glb_cdcritic = 80.
                                   aux_flgerros = TRUE.
                                   LEAVE.
                                END.

                           ASSIGN aux_txdoipmf = tab_txcpmfcc             
                                  aux_indoipmf = IF tab_indabono = 0 AND
                                                 CAN-DO("114,117,127,160",
                                                 STRING(craplcm.cdhistor))
                                                 THEN 1
                                                 ELSE craphis.indoipmf.

                           IF   craphis.inhistor = 1   THEN
                                tel_vlsddisp = tel_vlsddisp + craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 2   THEN
                                tel_vlsdchsl = tel_vlsdchsl + craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 3   THEN
                                tel_vlsdbloq = tel_vlsdbloq + craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 4   THEN
                                tel_vlsdblpr = tel_vlsdblpr + craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 5   THEN
                                tel_vlsdblfp = tel_vlsdblfp + craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 11   THEN
                                tel_vlsddisp = tel_vlsddisp - craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 12   THEN
                                tel_vlsdchsl = tel_vlsdchsl - craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 13   THEN
                                tel_vlsdbloq = tel_vlsdbloq - craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 14   THEN
                                tel_vlsdblpr = tel_vlsdblpr - craplcm.vllanmto.
                           ELSE
                           IF   craphis.inhistor = 15   THEN
                                tel_vlsdblfp = tel_vlsdblfp - craplcm.vllanmto.
                           ELSE
                                DO:
                                   glb_cdcritic = 83.
                                   aux_flgerros = TRUE.
                                   LEAVE.
                                END.

                           /*  Calcula CPMF para os lancamentos  */

                           IF   aux_indoipmf > 1   THEN
                                IF  craphis.indebcre = "D"   THEN
                                    aux_vlipmfap = aux_vlipmfap +
                                    (TRUNC(craplcm.vllanmto * tab_txcpmfcc,2)).
                                ELSE
                                IF   craphis.indebcre = "C"   THEN
                                     aux_vlipmfap = aux_vlipmfap -
                                     (TRUNC(craplcm.vllanmto * tab_txcpmfcc,2)).
                                ELSE .
                           ELSE
                           IF   craphis.inhistor = 12 THEN
                                DO:
                                   /*** Magui desativado em 09/12/2005
                                   FIND crapchs WHERE
                                        crapchs.cdcooper = glb_cdcooper     AND
                                        crapchs.nrdconta = craplcm.nrdconta AND
                                        crapchs.nrdocmto = craplcm.nrdocmto
                                        USE-INDEX crapchs2 NO-LOCK NO-ERROR.

                                   IF   NOT AVAIL crapchs   THEN
                                        IF CAN-DO(aux_lsconta3,
                                           STRING(craplcm.nrdctabb))THEN
                                           DO:
                                              glb_cdcritic = 286.
                                              aux_flgerros = TRUE.
                                              LEAVE.
                                           END.
                                        ELSE
                                        IF  craplcm.cdhistor <> 43 THEN
                                            ASSIGN tel_vlsdchsl = 
                                                   tel_vlsdchsl -
                                                  (TRUNC(craplcm.vllanmto *
                                                   tab_txcpmfcc,2))
                                                   tel_vlsddisp = 
                                                   tel_vlsddisp +
                                                  (TRUNC(craplcm.vllanmto * 
                                                   tab_txcpmfcc,2))
                                                   aux_vlipmfap =
                                                   aux_vlipmfap +
                                                  (TRUNC(craplcm.vllanmto *
                                                   tab_txcpmfcc,2)).
                                        ELSE .
                                   ELSE
                                        ASSIGN tel_vlsdchsl =
                                               tel_vlsdchsl - crapchs.vldoipmf
                                               tel_vlsddisp = 
                                               tel_vlsddisp + crapchs.vldoipmf
                                               aux_vlipmfap =
                                               aux_vlipmfap + crapchs.vldoipmf.
                                   **************************************/
                                   /* Magui em substituicao ao cheque sal */                                       
                                IF  craplcm.cdhistor <> 43 THEN
                                       ASSIGN tel_vlsdchsl = tel_vlsdchsl -
                                                  (TRUNC(craplcm.vllanmto *
                                                   tab_txcpmfcc,2))
                                              tel_vlsddisp = tel_vlsddisp +
                                                  (TRUNC(craplcm.vllanmto * 
                                                   tab_txcpmfcc,2))
                                              aux_vlipmfap = aux_vlipmfap +
                                                  (TRUNC(craplcm.vllanmto *
                                                   tab_txcpmfcc,2)).
                                END.

                           IF   tab_indabono = 0   AND
                                tab_dtiniabo <= craplcm.dtrefere AND
                                CAN-DO("186,187,498,500",
                                STRING(craplcm.cdhistor))   THEN
                                ASSIGN aux_vlestorn =
                                       TRUNCATE(craplcm.vllanmto *
                                                tab_txcpmfcc,2)

                                       aux_vlipmfap = 
                                       aux_vlipmfap + aux_vlestorn +
                                       TRUNCATE(aux_vlestorn * tab_txcpmfcc,2)
                                       aux_vlestabo = 
                                       aux_vlestabo + craplcm.vllanmto.
                       END.  /*  Fim FOR EACH - Leitura lancamentos dia ant */
                   
                       IF   aux_flgerros   THEN
                            DO:
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE glb_dscritic.
                               RETURN.
                            END.
                    END.
             END.
         /*-------------*/

         /*  Leitura dos lancamentos do dia  */

         FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                                craplcm.nrdconta = crapsld.nrdconta   AND
                                craplcm.dtmvtolt = glb_dtmvtolt       AND
                                craplcm.cdhistor <> 289 
                                USE-INDEX craplcm2 NO-LOCK:

             FIND craphis WHERE craphis.cdhistor = craplcm.cdhistor AND
                                craphis.cdcooper = craplcm.cdcooper
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE craphis   THEN
                  DO:
                      glb_cdcritic = 80.
                      aux_flgerros = TRUE.
                      LEAVE.
                  END.

             ASSIGN aux_txdoipmf = tab_txcpmfcc             

                    aux_indoipmf = IF tab_indabono = 0 AND
                                      CAN-DO("114,117,127,160",
                                             STRING(craplcm.cdhistor))
                                      THEN 1
                                      ELSE craphis.indoipmf.

             IF   craphis.inhistor = 1   THEN
                  tel_vlsddisp = tel_vlsddisp + craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 2   THEN
                  tel_vlsdchsl = tel_vlsdchsl + craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 3   THEN
                  tel_vlsdbloq = tel_vlsdbloq + craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 4   THEN
                  tel_vlsdblpr = tel_vlsdblpr + craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 5   THEN
                  tel_vlsdblfp = tel_vlsdblfp + craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 11   THEN
                  tel_vlsddisp = tel_vlsddisp - craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 12   THEN
                  tel_vlsdchsl = tel_vlsdchsl - craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 13   THEN
                  tel_vlsdbloq = tel_vlsdbloq - craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 14   THEN
                  tel_vlsdblpr = tel_vlsdblpr - craplcm.vllanmto.
             ELSE
             IF   craphis.inhistor = 15   THEN
                  tel_vlsdblfp = tel_vlsdblfp - craplcm.vllanmto.
             ELSE
                  DO:
                      glb_cdcritic = 83.
                      aux_flgerros = TRUE.
                      LEAVE.
                  END.

             /*  Calcula CPMF para os lancamentos  */

             IF   aux_indoipmf > 1   THEN
                  IF   craphis.indebcre = "D"   THEN
                       aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                  ELSE
                       IF   craphis.indebcre = "C"   THEN
                            aux_vlipmfap = aux_vlipmfap -
                                  (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                       ELSE .
             ELSE
             IF   craphis.inhistor = 12 THEN
                  DO:
                      /*** Magui desativado em 09/12/2005
                      FIND crapchs WHERE crapchs.cdcooper = glb_cdcooper     AND
                                         crapchs.nrdconta = craplcm.nrdconta AND
                                         crapchs.nrdocmto = craplcm.nrdocmto
                                         USE-INDEX crapchs2 NO-LOCK NO-ERROR.

                      IF   NOT AVAILABLE crapchs   THEN
                           IF CAN-DO(aux_lsconta3, STRING(craplcm.nrdctabb))THEN
                                DO:
                                    glb_cdcritic = 286.
                                    aux_flgerros = TRUE.
                                    LEAVE.
                                END.
                           ELSE
                           IF   craplcm.cdhistor <> 43 THEN
                                ASSIGN tel_vlsdchsl = tel_vlsdchsl -
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                      tel_vlsddisp = tel_vlsddisp +
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                      aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                           ELSE .
                      ELSE
                           ASSIGN tel_vlsdchsl = tel_vlsdchsl - crapchs.vldoipmf
                                  tel_vlsddisp = tel_vlsddisp + crapchs.vldoipmf
                                 aux_vlipmfap = aux_vlipmfap + crapchs.vldoipmf.
                      *******************************************/
                      /*** Magui em substituicao ao cheque salario ***/
                      IF   craplcm.cdhistor <> 43 THEN
                           ASSIGN tel_vlsdchsl = tel_vlsdchsl -
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                  tel_vlsddisp = tel_vlsddisp +
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                  aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                  END.

             IF   tab_indabono = 0   AND
                  tab_dtiniabo <= craplcm.dtrefere AND
                  CAN-DO("186,187,498,500",STRING(craplcm.cdhistor))   THEN
                  ASSIGN aux_vlestorn = TRUNCATE(craplcm.vllanmto *
                                                 tab_txcpmfcc,2)

                         aux_vlipmfap = aux_vlipmfap + aux_vlestorn +
                                        TRUNCATE(aux_vlestorn * tab_txcpmfcc,2)
                         aux_vlestabo = aux_vlestabo + craplcm.vllanmto.

         END.  /*  Fim do FOR EACH -- Leitura dos lancamentos do dia  */

         IF   aux_flgerros   THEN
              DO:
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  RETURN.
              END.
              
          aux_vlestabo = TRUNCATE(aux_vlestabo * tab_txiofapl,2).
          
          ASSIGN tel_vlstotal = tel_vlsddisp + tel_vlsdbloq + tel_vlsdblpr +
                               tel_vlsdblfp + tel_vlsdchsl

                tel_vlacerto = tel_vlsddisp - crapsld.vlipmfap -
                               crapsld.vlipmfpg - aux_vlipmfap - aux_vlestabo

                tel_vlipmfpg = crapsld.vlipmfpg

                tel_vlsaqmax = IF tel_vlacerto <= 0
                                  THEN 0
                                  ELSE TRUNC(tel_vlacerto * tab_txrdcpmf,2)

                tel_vlacerto = tel_vlacerto + tel_vlsdbloq + tel_vlsdblpr +
                               tel_vlsdblfp
                               
                aux_vllautom = tel_vlacerto 
 
                tel_vlacerto = IF tel_vlacerto < 0
                                  THEN TRUNC(tel_vlacerto * 
                                        (1 + tab_txcpmfcc),2)
                                  ELSE tel_vlacerto

                aux_nrmesano = IF MONTH(glb_dtmvtolt) > 6
                                  THEN MONTH(glb_dtmvtolt) - 6
                                  ELSE MONTH(glb_dtmvtolt)

                tel_vlsmdtri = IF aux_nrmesano = 1   THEN   /*  Meses 1 ou 7  */
                                 (crapsld.vlsmstre[6] + crapsld.vlsmstre[5] +
                                          crapsld.vlsmstre[4]) / 3
                               ELSE
                               IF aux_nrmesano = 2   THEN   /*  Meses 2 ou 8  */
                                  (crapsld.vlsmstre[1] + crapsld.vlsmstre[6] +
                                           crapsld.vlsmstre[5]) / 3
                               ELSE
                               IF aux_nrmesano = 3   THEN   /*  Meses 3 ou 9  */
                                  (crapsld.vlsmstre[2] + crapsld.vlsmstre[1] +
                                           crapsld.vlsmstre[6]) / 3
                               ELSE
                               IF aux_nrmesano = 4   THEN   /*  Meses 4 ou 10 */
                                  (crapsld.vlsmstre[3] + crapsld.vlsmstre[2] +
                                           crapsld.vlsmstre[1]) / 3
                               ELSE
                               IF aux_nrmesano = 5   THEN   /*  Meses 5 ou 11 */
                                  (crapsld.vlsmstre[4] + crapsld.vlsmstre[3] +
                                           crapsld.vlsmstre[2]) / 3
                               ELSE
                               IF aux_nrmesano = 6   THEN   /*  Meses 6 ou 12 */
                                  (crapsld.vlsmstre[5] + crapsld.vlsmstre[4] +
                                           crapsld.vlsmstre[3]) / 3
                               ELSE 0

                tel_vlsmdsem = (crapsld.vlsmstre[1] + crapsld.vlsmstre[2] +
                                crapsld.vlsmstre[3] + crapsld.vlsmstre[4] +
                                crapsld.vlsmstre[5] + crapsld.vlsmstre[6]) / 6

                tel_vlsmdpos[1] = crapsld.vlsmstre[aux_nrmesano]

                tel_vlsmdpos[2] = crapsld.vlsmstre[IF (aux_nrmesano + 1) > 6
                                                     THEN (aux_nrmesano + 1) - 6
                                                     ELSE (aux_nrmesano + 1)]

                tel_vlsmdpos[3] = crapsld.vlsmstre[IF (aux_nrmesano + 2) > 6
                                                     THEN (aux_nrmesano + 2) - 6
                                                     ELSE (aux_nrmesano + 2)]

                tel_vlsmdpos[4] = crapsld.vlsmstre[IF (aux_nrmesano + 3) > 6
                                                     THEN (aux_nrmesano + 3) - 6
                                                     ELSE (aux_nrmesano + 3)]

                tel_vlsmdpos[5] = crapsld.vlsmstre[IF (aux_nrmesano + 4) > 6
                                                     THEN (aux_nrmesano + 4) - 6
                                                     ELSE (aux_nrmesano + 4)]

                tel_vlsmdpos[6] = crapsld.vlsmstre[IF (aux_nrmesano + 5) > 6
                                                     THEN (aux_nrmesano + 5) - 6
                                                     ELSE (aux_nrmesano + 5)]

                tel_vlsmdpos[7] = crapsld.vlsmpmes
                
                aux_nranoatu = STRING(YEAR(glb_dtmvtolt),"9999")
                aux_nranoant = STRING(YEAR(glb_dtmvtolt) - 1,"9999")

                aux_nrmesano = MONTH(glb_dtmvtolt)
                aux_inmesano = 0.
                
         DO aux_contador = aux_nrmesano TO aux_nrmesano + 6:

            ASSIGN aux_nrindice = 6 + aux_contador

                   aux_nrindice = IF aux_nrindice > 12
                                     THEN aux_nrindice - 12
                                     ELSE aux_nrindice

                   aux_inmesano = aux_inmesano + 1

                   tel_nmmesano[aux_inmesano] =
                                STRING(aux_nmmesano[aux_nrindice],"x(3)")

                   tel_nmmesano[aux_inmesano] = tel_nmmesano[aux_inmesano] +
                                           IF aux_nrindice > MONTH(glb_dtmvtolt)
                                              THEN "/" + aux_nranoant + ":"
                                              ELSE "/" + aux_nranoatu + ":".

         END.  /*  Fim do DO .. TO  */

         ASSIGN tel_nmmesano[7] =
                    STRING(aux_nmmesano[MONTH(glb_dtmvtolt)],"x(3)") + "/" +
                    aux_nranoatu + ":"

                tel_dslimcre = IF aux_tplimcre = 1
                                  THEN "(CP)"
                                  ELSE IF aux_tplimcre = 2
                                          THEN "(SM)"
                                          ELSE "".

         ASSIGN tel_vlbscpmf = 0
                tel_vlpgcpmf = 0
                
                tel_dsexcpmf[1] = YEAR(glb_dtmvtolt) - 1
                tel_dsexcpmf[2] = YEAR(glb_dtmvtolt).
                
         FOR EACH crapipm WHERE crapipm.cdcooper = glb_cdcooper       AND
                                crapipm.nrdconta = crapsld.nrdconta   AND
                                crapipm.dtdebito > DATE(12,31,
                                      YEAR(glb_dtmvtolt) - 2) NO-LOCK:
             
             IF   YEAR(crapipm.dtdebito) = YEAR(glb_dtmvtolt)   THEN
                  ASSIGN tel_vlbscpmf[2] = tel_vlbscpmf[2] + crapipm.vlbasipm
                         tel_vlpgcpmf[2] = tel_vlpgcpmf[2] + crapipm.vldoipmf.
             ELSE
                  ASSIGN tel_vlbscpmf[1] = tel_vlbscpmf[1] + crapipm.vlbasipm
                         tel_vlpgcpmf[1] = tel_vlpgcpmf[1] + crapipm.vldoipmf.
     
         END.  /*  Fim do FOR EACH -- crapipm  */
     END.
ELSE
     DO:
         EMPTY TEMP-TABLE crawext. 

         aux_dtpesqui = ?.

         DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE aux_dtpesqui WITH FRAME f_data.

              LEAVE.

         END. /* Fim do DO WHILE TRUE */

         HIDE FRAME f_data NO-PAUSE.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
              RETURN.

         IF   aux_dtpesqui = ? THEN
              aux_dtpesqui = (glb_dtmvtolt - DAY(glb_dtmvtolt)) + 1.
  
         IF   aux_dtpesqui <= 03/31/2005 THEN
              aux_dtpesqui = 04/01/2005.
 
         aux_contador = 0.

         FOR EACH craplcm WHERE craplcm.cdcooper =  glb_cdcooper   AND
                                craplcm.nrdconta =  tel_nrdconta   AND
                                craplcm.dtmvtolt >= aux_dtpesqui   AND
                                craplcm.cdhistor <> 289  
                                USE-INDEX craplcm2 NO-LOCK:

             CREATE crawext.
             ASSIGN crawext.dtmvtolt = craplcm.dtmvtolt
                    crawext.vllanmto = craplcm.vllanmto

                    crawext.nrdocmto = IF CAN-DO(aux_lshistor,
                                                     STRING(craplcm.cdhistor))
                                          THEN STRING(craplcm.nrdocmto,
                                                              "zzzzz,zz9,9")
                                          ELSE 
                                          IF LENGTH(STRING(craplcm.nrdocmto)) <
                                             10 
                                             THEN STRING(craplcm.nrdocmto,
                                                              "zzzzzzz,zz9")
                                             ELSE 
                                                SUBSTR(STRING(craplcm.nrdocmto,
                                       "99999999999999999999"),10,11)
                    aux_contador     = aux_contador + 1.

             IF   CAN-DO("375,376,377,537,538,539,771,772",
                  STRING(craplcm.cdhistor))   THEN
                  crawext.nrdocmto = STRING(INT(SUBSTR(craplcm.cdpesqbb,45,8)),
                                            "zzzzz,zzz,9").
             ELSE
             IF   CAN-DO("104,302,303",STRING(craplcm.cdhistor))   THEN
                  DO:
                      IF   INT(craplcm.cdpesqbb) > 0   THEN
                           crawext.nrdocmto = STRING(INT(craplcm.cdpesqbb),
                                                         "zzzzz,zzz,9").
                      ELSE
                           crawext.nrdocmto = STRING(craplcm.nrdocmto,
                                                     "zzz,zzz,zz9").   
                  END.
                  
             IF   aux_contador > 320   THEN
                  DO:
                      glb_cdcritic = 493.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      ASSIGN glb_cdcritic = 0
                             aux_contador = 0.
                      RETURN.
                  END.

             FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplcm.cdcooper AND 
                               craphis.cdhistor = craplcm.cdhistor NO-ERROR.

             IF   NOT AVAILABLE craphis   THEN
                  ASSIGN crawext.indebcre = "?"
                         crawext.dshistor = STRING(craplcm.cdhistor,"9999") +
                                            "-" + "Nao cadastrado!".
             ELSE
                  DO:
                      aux_dslibera = "".

                      IF   CAN-DO("3,4,5",STRING(craphis.inhistor))   THEN
                           DO:
                               FIND crapdpb WHERE
                                    crapdpb.cdcooper = glb_cdcooper     AND
                                    crapdpb.dtmvtolt = craplcm.dtmvtolt AND
                                    crapdpb.cdagenci = craplcm.cdagenci AND
                                    crapdpb.cdbccxlt = craplcm.cdbccxlt AND
                                    crapdpb.nrdolote = craplcm.nrdolote AND
                                    crapdpb.nrdconta = tel_nrdconta     AND
                                    crapdpb.nrdocmto = craplcm.nrdocmto
                                    NO-LOCK NO-ERROR.

                               IF   NOT AVAILABLE crapdpb   THEN
                                    aux_dslibera = "(**/**)".
                               ELSE  /*
                               IF   crapdpb.inlibera = 1 THEN     */
                                    aux_dslibera = "(" + SUBSTRING
                                       (STRING(crapdpb.dtliblan),1,5)
                                                 + ")".
                           /*    ELSE
                                    aux_dslibera = "(Estorno)".   */
                           END.

                      ASSIGN crawext.indebcre = craphis.indebcre
                             crawext.dshistor = STRING(craplcm.cdhistor,"9999") +
                                                "-" + craphis.dshistor +
                                                (IF (craplcm.cdhistor = 24  OR
                                                     craplcm.cdhistor = 27  OR
                                                     craplcm.cdhistor = 47  OR
                                                     craplcm.cdhistor = 78  OR
                                                     craplcm.cdhistor = 156 OR
                                                     craplcm.cdhistor = 191 OR
                                                     craplcm.cdhistor = 351 OR
                                                     craplcm.cdhistor = 338 OR
                                                     craplcm.cdhistor = 399 OR
                                                     craplcm.cdhistor = 573)
                                                     THEN craplcm.cdpesqbb
                                                     ELSE "") + " " +
                                                 aux_dslibera.
                  END.

         END.  /*  Fim do FOR EACH  */

         RUN fontes/atenda_e.p.
     END.

/* .......................................................................... */

