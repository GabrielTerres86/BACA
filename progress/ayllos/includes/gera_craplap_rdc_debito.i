/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+-----------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL               |
  +-------------------------------------+-----------------------------------+
  | includes/gera_craplap_rdc_debito.i  | APLI0001.pc_gera_craplap_rdc      |
  +-------------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/* .............................................................................

   Programa: Includes/gera_craplap_rdc_debito.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/David
   Data    : Maio/2007.                        Ultima atualizacao: 12/12/2013    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gera lancamentos no craplap referentes a RDCPRE e a RDCPOS. 

   Alteracoes: 12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO) 

............................................................................. */

CREATE craplap.
ASSIGN craplap.cdcooper = glb_cdcooper
       craplap.dtmvtolt = craplot.dtmvtolt
       craplap.cdagenci = craplot.cdagenci
       craplap.cdbccxlt = craplot.cdbccxlt
       craplap.nrdolote = craplot.nrdolote
       craplap.nrdconta = craprda.nrdconta
       craplap.nraplica = craprda.nraplica
       craplap.nrdocmto = aux_nrdocmto + 555000  
       craplap.txaplica = aux_txapllap
       craplap.txaplmes = aux_txapllap
       craplap.cdhistor = aux_cdhistor
       craplap.nrseqdig = craplot.nrseqdig + 1 
       craplap.vllanmto = aux_vllanmto
       craplap.dtrefere = aux_dtrefere
       craplap.vlrendmm = aux_vlrendmm
              
       craplot.vlinfodb = craplot.vlinfodb + craplap.vllanmto
       craplot.vlcompdb = craplot.vlcompdb + craplap.vllanmto
       craplot.qtinfoln = craplot.qtinfoln + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.nrseqdig = craplot.nrseqdig + 1.
VALIDATE craplap.
/* .......................................................................... */
