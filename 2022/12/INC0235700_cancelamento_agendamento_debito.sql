BEGIN
  UPDATE cecred.craplau l
     SET l.insitlau = 3, 
         l.dtdebito = l.dtmvtopg, --to_date(l.dtmvtolt, 'dd/mm/yyyy'),
         l.cdcritic = 717,
         l.dscritic = '717 - Nao ha saldo suficiente para a operacao (INC0235700).'
     WHERE l.cdcooper = 1
       AND l.dtmvtopg = to_date('14/10/2022', 'dd/mm/yyyy')
       AND l.insitlau = 1
       AND l.cdhistor <> 3292
       AND l.dsorigem = 'DEBAUT';
   COMMIT;       
END;      

