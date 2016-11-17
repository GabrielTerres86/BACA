/*** Juros sobre os emprestimos em aberto no mensal. Somente para 
     contabilidade. Nao enexerga parcelas, somentes saldo devedor
     CUIDADO, esta sendo usada 9 casas decimais
     ***/

{includes/var_batch.i "new"}

def var aux_diasmes  as inte.
/*** 98 sempre na age 1, cxa 100 e lote 8360 ***/
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

/*** Para calculo do juros mensal usar meses com 30 dias ***/
assign aux_diasmes = 0.
if day(crapdat.dtmvtolt) = 31 then
   assign aux_diasmes = 1.
FOR EACH crapepr where crapepr.cdcooper = crapcop.cdcooper AND
                       crapepr.nrdconta = 9660             AND
                       crapepr.nrctremp = 966:
    ASSIGN aux_vlsdeved = 0
           aux_dtiniepr = ?.
    FOR EACH craplem WHERE craplem.cdcooper = crapcop.cdcooper AND
                           craplem.nrdconta = crapepr.nrdconta AND
                           craplem.nrctremp = crapepr.nrctremp
                           NO-LOCK:
        FIND craphis WHERE craphis.cdcooper = crapcop.cdcooper and
                           craphis.cdhistor = craplem.cdhistor
                                                      NO-LOCK NO-ERROR.
        IF   craphis.indebcre = "D"   THEN
             ASSIGN aux_vlsdeved = aux_vlsdeved + craplem.vllanmto.
        ELSE
             ASSIGN aux_vlsdeved = aux_vlsdeved - craplem.vllanmto.
        if  craplem.cdhistor = 98 then /* juros */
            assign aux_dtiniepr = craplem.dtpagemp.
    END.
    IF   aux_vlsdeved = 0   THEN
         NEXT.
    if  aux_dtiniepr = ?   then
        assign aux_dtiniepr = crapepr.dtmvtolt.
    FIND craplcr WHERE craplcr.cdcooper = crapcop.cdcooper AND 
                       craplcr.cdlcremp = crapepr.cdlcremp NO-LOCK NO-ERROR.
    ASSIGN aux_qtdiacor = (crapdat.dtmvtolt - aux_diasmes) - aux_dtiniepr
           aux_qtdiajur = 30.

    if  aux_qtdiacor = 31 then /* sera usado meses com 30 dias */
        assign aux_qtdiacor = 30.
    Assign aux_txdiaria = 
        trunc((exp(((craplcr.txmensal / 100) + 1),(1 / aux_qtdiajur)) - 1),9) 
                
           aux_vljurmes = 
     round(aux_vlsdeved * (EXP((1 + trunc((exp(((craplcr.txmensal / 100) + 1), 
               (1 / aux_qtdiajur)) - 1),9)) , (aux_qtdiacor)) - 1),2). 
     disp aux_vlsdeved aux_qtdiajur aux_qtdiacor aux_vljurmes.   
    IF   aux_vljurmes <> 0   THEN
         DO:
            DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = crapcop.cdcooper   AND 
                                   craplot.dtmvtolt = crapdat.dtmvtolt   AND
                                   craplot.cdagenci = aux_cdagenci   AND
                                   craplot.cdbccxlt = aux_cdbccxlt   AND
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
                              ASSIGN craplot.dtmvtolt = crapdat.dtmvtolt
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
             ASSIGN craplem.dtmvtolt = crapdat.dtmvtolt
                    craplem.cdagenci = 1
                    craplem.cdbccxlt = 100
                    craplem.nrdolote = 1
                    craplem.nrdconta = crapepr.nrdconta
                    craplem.nrdocmto = (craplot.nrseqdig + 1) * 2
                    craplem.cdhistor = 98
                    craplem.nrseqdig = (craplot.nrseqdig + 1) * 2
                    craplem.nrctremp = crapepr.nrctremp
                    craplem.vllanmto = aux_vljurmes
                    craplem.dtpagemp = crapdat.dtmvtolt - aux_diasmes 
                                       /* calculo ate o dia 30 */
                    craplem.txjurepr = aux_txdiaria
                    craplem.vlpreemp = crapepr.vlpreemp
                    craplem.nrsequni = 0
                    craplem.cdcooper = crapcop.cdcooper
                    crapepr.vlsdeved = aux_vlsdeved + aux_vljurmes
                    craplot.nrseqdig = (craplot.nrseqdig + 1) * 2
                    craplot.qtcompln = craplot.qtcompln + 1
                    craplot.qtinfoln = craplot.qtinfoln + 1.

             VALIDATE craplem.
         END.
end.
