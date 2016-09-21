/* .............................................................................

   Programa: Fontes/saldo_rdca_resgate.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Dezembro/2004.                  Ultima atualizacao: 17/01/2007

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do saldo das aplicacoes RDCA para resgate
               enxergando as novas aliquotas de imposto de renda.

   Observacoes: Para se saber o quanto de rendimento esta sendo resgatado se
                faz o seguinte calculo: valor do resgate / saldo da aplicacao
                ate a data com rendimentos, outros resgates, imposto de renda,
                etc., multiplicado por 100, isso da como resultado um 
                percentual. Pegasse o rendimento total ate a data multiplicado
                por esse percentual dividido por 100. Dando como resultado o
                valor em R$ do que rendeu o que esta sendo resgatado.
                
   Alteracoes: 04/02/2005 - Prever IR.Abono Aplicacao(historico  868) se
                            resgate efetuado antes do aniversario(Mirtes)

               06/05/2005 - Utilizar o indice craplap5 na leitura dos 
                            lancamentos (Edson).
               27/05/2005 - Se saldo para resgate for negativo, zerar(Mirtes)
               
               22/08/2005 - Quando aniver fim-de-semana e resgate total para
                            segunda estava deixando resgatar tudo.

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               17/01/2007 - Se a cooperativa opta por nao cobrar o abono da
                            cpmf e ha um resgate total no primeiro mes, o saque
                            nao enxerga o desconto do imposto de renda (Magui).
............................................................................. */

{includes/var_online.i } 
{includes/var_faixas_ir.i }

DEF BUFFER crabrda FOR craprda.
DEF BUFFER crablap FOR craplap.

ASSIGN aux_pcajsren = 0       aux_vlrenreg = 0
       aux_vldajtir = 0       aux_nrmeses  = 0
       aux_nrdias   = 0       aux_perirapl = 0
       aux_dtiniapl = ?       aux_cdhisren = 0
       aux_vlslajir = 0       aux_vlrenacu = 0
       aux_cdhisajt = 0       aux_sldrgttt = 0.

FIND crabrda WHERE crabrda.cdcooper = glb_cdcooper   AND
                   crabrda.nrdconta = aux_nrctaapl   AND
                   crabrda.nraplica = aux_nraplres   NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE crabrda   THEN                   
     DO: 
         glb_cdcritic = 426.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " " +
                           STRING(aux_nrctaapl,"zzzz,zzz,9") + " " +
                           STRING(aux_nraplres,"zzz,zz9") +
                           " >> log/proc_batch.log").
         RETURN.
     END.

IF   crabrda.dtmvtolt <= 12/22/2004   THEN
     ASSIGN aux_dtiniapl = 07/01/2004.
ELSE
     ASSIGN aux_dtiniapl = crabrda.dtmvtolt.

RUN fontes/calcmes.p (INPUT aux_dtiniapl,
                      INPUT aux_dtregapl,
                      OUTPUT aux_nrmeses,
                      OUTPUT aux_nrdias).
                      
IF   aux_nrmeses = ?   OR
     aux_nrdias  = ?   THEN                   
     DO: 
         glb_cdcritic = 840.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " " +
                           STRING(crabrda.nrdconta,"zzzz,zzz,9") + " " +
                           STRING(crabrda.nraplica,"zzz,zz9") + " " +
                           STRING(aux_dtiniapl,"99/99/9999") + " " +
                           STRING(aux_dtregapl,"99/99/9999") +
                           " >> log/proc_batch.log").
         RETURN.
     END.

IF   crabrda.tpaplica = 3   THEN /* RDCA30 */
     ASSIGN aux_cdhisren = 116
            aux_cdhisajt = 875.
ELSE
     IF   crabrda.tpaplica = 5   THEN  /* RDCA60 */
          ASSIGN aux_cdhisren = 179
                 aux_cdhisajt = 876.
IF   aux_cdhisren = 0   THEN  
     DO:
         glb_cdcritic = 526.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " " +
                           STRING(crabrda.nrdconta,"zzzz,zzz,9") + " " +
                           STRING(crabrda.nraplica,"zzz,zz9") + " " +
                           STRING(crabrda.tpaplica,"9") +
                           " >> log/proc_batch.log").
         RETURN.
     END.   
         
IF   aux_nrmeses <= 6   THEN
     DO:
         IF   aux_nrdias = 0    OR
              aux_nrmeses < 6   THEN
              ASSIGN aux_perirapl = aux_perirtab[1].
     END.              
IF   aux_perirapl = 0   THEN
     DO:
         IF   aux_nrmeses >= 6   AND
              aux_nrmeses <= 12  THEN
              DO:
                  IF   aux_nrdias = 0     OR
                       aux_nrmeses < 12   THEN
                       ASSIGN aux_perirapl = aux_perirtab[2].
              END.
     END.
IF   aux_perirapl = 0   THEN
     DO:
         IF   aux_nrmeses >= 12   AND
              aux_nrmeses <= 24   THEN
              DO:
                  IF   aux_nrdias = 0     OR
                       aux_nrmeses < 24   THEN
                       ASSIGN aux_perirapl = aux_perirtab[3].
              END.  
     END.
IF   aux_perirapl = 0   THEN          
     ASSIGN aux_perirapl = aux_perirtab[4].

IF   aux_perirapl = 0   AND  
     glb_cdcooper <> 3 THEN
     DO:
         glb_cdcritic = 180.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" +
                           glb_dscritic + " " +
                           STRING(crabrda.nrdconta,"zzzz,zzz,9") + " " +
                           STRING(crabrda.nraplica,"zzz,zz9") + " " +
                           STRING(crabrda.tpaplica,"9") +
                           " >> log/proc_batch.log").
         RETURN.
      END.

FIND LAST crablap WHERE crablap.cdcooper = glb_cdcooper       AND
                        crablap.nrdconta = crabrda.nrdconta   AND
                        crablap.nraplica = crabrda.nraplica   AND
                        crablap.cdhistor = aux_cdhisren       NO-LOCK
                        USE-INDEX craplap5 NO-ERROR.

IF   NOT AVAILABLE crablap   THEN  
     DO:
         ASSIGN aux_sldpresg = aux_vlsldapl
                aux_vlslajir = crabrda.vlsdrdca
                aux_vlr_abono_ir = 0.

         IF  (crabrda.dtfimper > glb_dtmvtoan    AND
              crabrda.dtfimper <= glb_dtmvtolt)  OR 
             (glb_cdprogra = "crps105" AND
             (crabrda.dtfimper = glb_dtmvtopr) OR
             (crabrda.dtfimper < glb_dtmvtopr AND
              crabrda.dtfimper > glb_dtmvtolt))   THEN 
              DO:   
                 ASSIGN 
                 aux_vlr_abono_ir = TRUNCATE((crabrda.vlabcpmf * 
                                                 aux_perirtab[1] / 100),2)
                 aux_sldpresg = aux_sldpresg - aux_vlr_abono_ir -
                     TRUNCATE((aux_vlrenper * aux_perirtab[1] / 100),2).
                         
              END.                             
     END.       
ELSE     
     DO:
         ASSIGN aux_vlslajir = crablap.vlslajir
                aux_vlrenacu = crablap.vlrenacu.
         
         IF   aux_vlslajir > 0   THEN       
              DO:
                  ASSIGN aux_pcajsren = aux_vlsldapl / aux_vlslajir * 100.
                  IF   aux_pcajsren > 100   THEN        
                       ASSIGN aux_pcajsren = 100.
             
                  ASSIGN aux_vlr_abono_ir = 0.
                  IF  (crabrda.dtfimper > glb_dtmvtoan    AND
                       crabrda.dtfimper <= glb_dtmvtolt)   AND 
                      crabrda.vlabcpmf > 0 THEN
                      DO:   
                         aux_vlr_abono_ir =                                                                                 TRUNCATE((crabrda.vlabcpmf * 
                                                 aux_perirtab[1] / 100),2).
                           
                      END. 
                  ASSIGN aux_vlrenreg = aux_vlrenacu * aux_pcajsren / 100
                         aux_vldajtir = 
                            TRUNCATE((aux_vlrenreg * aux_perirapl / 100) -
                            (aux_vlrenreg * aux_perirtab[4] / 100),2)
                         aux_sldpresg = ROUND(aux_vlsldapl - 
                            aux_vlr_abono_ir - aux_vldajtir - 
                            TRUNCATE((aux_vlrenper * aux_perirapl / 100),2),2).
                  
                  IF  aux_sldpresg < 0 THEN  /* Saldo neg.aplicacao    */
                      ASSIGN aux_sldpresg = 0.
                         
                  ASSIGN  aux_sldrgttt = aux_vlsldapl - aux_sldpresg -
                                         aux_vldajtir.
              
              END.
     END.  

IF   crabrda.tpaplica = 3   THEN /* RDCA30 */
     ASSIGN aux_sldrgttt = 0.
/* .......................................................................... */

