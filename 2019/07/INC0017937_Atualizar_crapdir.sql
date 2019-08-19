/* 
Solicitação: INC0017937
Objetivo   : Atualizar a coluna CRAPDIR.VLPREPAG da conta 2310350 (Viacredi) para os anos entre 2014 e 2015, para mostrar os valores pagos em empréstimo e financiamento no informe de rendimento de imposto de renda desse período.
Autor      : Edmar
*/

UPDATE CRAPDIR dir
SET dir.vlprepag = (select sum(decode(lcm.cdhistor,
                                      108, lcm.vllanmto,
                                      275, lcm.vllanmto,
                                     1539, lcm.vllanmto,
                                      393, lcm.vllanmto,
                                     1706, lcm.vllanmto * -1,
                                       99, lcm.vllanmto * -1,
                                       0))
                    from craplcm lcm
                    where lcm.cdcooper = dir.cdcooper
                      and lcm.nrdconta = dir.nrdconta
                      and lcm.cdhistor in (108, 275, 1539, 393, 1706, 99)
                      and lcm.dtmvtolt between trunc(dir.dtmvtolt, 'rrrr') and dir.dtmvtolt)
WHERE dir.cdcooper = 1
  and dir.nrdconta = 2310350
  and dir.dtmvtolt between '31/12/2014' and '31/12/2015';

COMMIT;
