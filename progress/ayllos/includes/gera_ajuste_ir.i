/* .............................................................................

   Programa: Includes/gera_ajuste_ir.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Dezembro/2004.                  Ultima atualizacao: 09/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gera lancamentos de ajuste de IRRF se necessario. 

   Alteracoes: 06/07/2005 - Alimentado campo cdcooper da tabela craplap (Diego).
               
               09/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  
............................................................................. */

ASSIGN craplap.vlslajir = TRUNCATE(aux_vlslajir,2)
       craplap.vlrenacu = ROUND(aux_vlrenacu,2)
       craplap.pcajsren = TRUNCATE(aux_pcajsren,2) 
       craplap.vlrenreg = ROUND(aux_vlrenreg,2) 
       craplap.vldajtir = IF aux_sldrgttt <= -0.03 AND
                             aux_sldrgttt >= 0.03 THEN
                             TRUNCATE(aux_vldajtir + aux_sldrgttt,2)
                          ELSE
                             TRUNCATE(aux_vldajtir,2)
       craplap.aliaplaj = aux_perirapl
       craplap.qtdmesaj = aux_nrmeses
       craplap.qtddiaaj = aux_nrdias
       craplap.rendatdt = ROUND(aux_vlrenper,2).
       
IF   craplap.vldajtir > 0   THEN
     DO:
         CREATE craplap.
         ASSIGN craplap.dtmvtolt = craplot.dtmvtolt
                craplap.cdagenci = craplot.cdagenci
                craplap.cdbccxlt = craplot.cdbccxlt
                craplap.nrdolote = craplot.nrdolote
                craplap.nrdconta = craprda.nrdconta
                craplap.nraplica = craprda.nraplica
                craplap.nrdocmto = aux_doctoajt + 888000 
                craplap.txaplica = aux_perirapl
                craplap.txaplmes = aux_perirapl
                craplap.cdhistor = aux_cdhisajt
                craplap.nrseqdig = craplot.nrseqdig + 1 
                craplap.vllanmto = IF aux_sldrgttt <= -0.03 AND
                                      aux_sldrgttt >= 0.03 THEN
                                      TRUNCATE(aux_vldajtir + aux_sldrgttt,2)
                                   ELSE
                                      TRUNCATE(aux_vldajtir,2)
                craplap.dtrefere = aux_dtrefajt
                craplap.vlslajir = TRUNCATE(aux_vlslajir,2)
                craplap.vlrenacu = ROUND(aux_vlrenacu,2)
                craplap.pcajsren = TRUNCATE(aux_pcajsren,2) 
                craplap.vlrenreg = ROUND(aux_vlrenreg,2) 
                craplap.vldajtir = IF aux_sldrgttt <= -0.03 AND
                                      aux_sldrgttt >= 0.03 THEN
                                      TRUNCATE(aux_vldajtir + aux_sldrgttt,2)
                                   ELSE
                                      TRUNCATE(aux_vldajtir,2)
                craplap.aliaplaj = aux_perirapl
                craplap.qtdmesaj = aux_nrmeses
                craplap.qtddiaaj = aux_nrdias
                craplap.rendatdt = ROUND(aux_vlrenper,2)
                craplap.vlregpaj = TRUNCATE(aux_vlregpaj,2)
                craplap.cdcooper = glb_cdcooper
              
                craplot.vlinfocr = craplot.vlinfocr + craplap.vllanmto
                craplot.vlcompcr = craplot.vlcompcr + craplap.vllanmto
                craplot.qtinfoln = craplot.qtinfoln + 1
                craplot.qtcompln = craplot.qtcompln + 1
                craplot.nrseqdig = craplot.nrseqdig + 1.
         VALIDATE craplap.
     END.

/* .......................................................................... */


