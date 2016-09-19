/*** Atualiza juros do emprestimo na data de aniversario
     Ao abrir as agencias o juros ja deve estar creditado
***/
DEF var glb_cdcooper LIKE crapcop.cdcooper.

def var aux_diasmes  as inte.
def var aux_cdagenci as inte initial 1.
def var aux_cdbccxlt as inte initial 100.
DEF VAR aux_mes      AS INTE.
DEF VAR aux_ano      AS INTE.
def var aux_dtiniepr as date format "99/99/9999".
def var aux_dtdpagto as date format "99/99/9999".
def var aux_vlemprst like crapepr.vlemprst.
def var aux_txmensal like craplcr.txmensal.
def var aux_txdiaria like craplcr.txdiaria.
def var aux_qtpreemp like crapepr.qtpreemp.
def var aux_diapagto as inte format "99".
def var aux_qtdiacar as inte format "9999". /* dias carencia */
def var aux_qtdiacor as inte format "9999". /* dias decorridos */
def var aux_qtdiajur as inte format "9999". /* dias calculo taxa */
def var aux_parcelas as inte.
def var aux_vljurmes as dec decimals 9 format "zz9.9999999".
def var aux_prxdtlct as date format "99/99/9999". /* contrato informa */
def var aux_num      as inte.
def var aux_vlsdeved like crapepr.vlsdeved.

glb_cdcooper = inte(os-getenv("CDCOOPER")).
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
FIND crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

FIND crapepr WHERE crapepr.cdcooper = crapcop.cdcooper   AND
                   crapepr.nrdconta = 9660               AND
                   crapepr.nrctremp = 966                  EXCLUSIVE-LOCK.
IF   NOT AVAILABLE crapepr   THEN
     DO:
        MESSAGE "Emprestimo nao cadastrado".
        RETURN.
     END.                 
            
/*** Procurar data de vencimento que caia dentro do crapdat.dtmvtopr ***/
ASSIGN aux_dtdpagto = ?.
FOR EACH crappep WHERE crappep.cdcooper = crapcop.cdcooper and
                       crappep.nrdconta = crapepr.nrdconta and
                       crappep.nrctremp = crapepr.nrctremp no-lock:
    IF   crappep.dtvencto > crapdat.dtmvtolt    AND
         crappep.dtvencto <= crapdat.dtmvtopr   THEN
         DO:
             ASSIGN aux_dtdpagto = crappep.dtvencto.
             LEAVE.
         END.
end.

IF  aux_dtdpagto = ?   THEN
    RETURN.
    
FIND craplcr WHERE craplcr.cdcooper = crapcop.cdcooper   AND
                   craplcr.cdlcremp = crapepr.cdlcremp NO-LOCK NO-ERROR.
IF   NOT AVAILABLE craplcr   THEN
     DO:
         MESSAGE "Linha nao cadastrada".
         RETURN.
     END.               
/*** Juros do saldo devedor do ultimo calculo ate a data do pagamento ***/
FIND LAST craplem WHERE craplem.cdcooper = crapcop.cdcooper   AND
                        craplem.nrdconta = crapepr.nrdconta   AND
                        craplem.nrctremp = crapepr.nrctremp   AND
                        craplem.cdhistor = 98             NO-LOCK NO-ERROR.
ASSIGN aux_vlsdeved = crapepr.vlsdeved
       aux_qtdiacor = aux_dtdpagto - craplem.dtmvtolt
       aux_qtdiajur = 30.

if  aux_qtdiacor = 31 then /* sera usado meses com 30 dias */
    assign aux_qtdiacor = 30.
Assign aux_txdiaria = 
        trunc((exp(((craplcr.txmensal / 100) + 1),(1 / aux_qtdiajur)) - 1),9) 
                
      aux_vljurmes = 
     round(aux_vlsdeved * (EXP((1 + trunc((exp(((craplcr.txmensal / 100) + 1), 
               (1 / aux_qtdiajur)) - 1),9)) , (aux_qtdiacor)) - 1),2). 

message aux_vlsdeved aux_qtdiajur aux_qtdiacor aux_vljurmes.
pause.
DO WHILE TRUE:
   FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper   AND 
                      craplot.dtmvtolt = crapdat.dtmvtopr   AND
                      craplot.cdagenci = aux_cdagenci       AND
                      craplot.cdbccxlt = aux_cdbccxlt       AND
                      craplot.nrdolote = 8360
                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craplot   THEN
        IF   LOCKED craplot   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
             ELSE
                  DO:
                      CREATE craplot.
                      ASSIGN craplot.dtmvtolt = crapdat.dtmvtopr
                             craplot.cdagenci = aux_cdagenci
                             craplot.cdbccxlt = aux_cdbccxlt
                             craplot.nrdolote = 8360
                             craplot.tplotmov = 5
                             craplot.cdcooper = crapcop.cdcooper.

                      VALIDATE craplot.
                  END.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

CREATE craplem.
ASSIGN craplem.dtmvtolt = crapdat.dtmvtopr
       craplem.cdagenci = 1
       craplem.cdbccxlt = 100
       craplem.nrdolote = 1
       craplem.nrdconta = crapepr.nrdconta
       craplem.nrdocmto = craplot.nrseqdig + 1
       craplem.cdhistor = 98
       craplem.nrseqdig = craplot.nrseqdig + 1
       craplem.nrctremp = crapepr.nrctremp
       craplem.vllanmto = aux_vljurmes
       craplem.dtpagemp = aux_dtdpagto
       craplem.txjurepr = aux_txdiaria
       craplem.vlpreemp = crappep.vlparepr
       craplem.nrsequni = 0
       craplem.cdcooper = crapcop.cdcooper
       crapepr.vlsdeved = crapepr.vlsdeved + aux_vljurmes
       craplot.nrseqdig = craplot.nrseqdig + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.qtinfoln = craplot.qtinfoln + 1.

VALIDATE craplem.
