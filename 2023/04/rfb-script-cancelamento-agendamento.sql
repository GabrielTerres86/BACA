BEGIN
  UPDATE cecred.craplau l
     SET l.insitlau = 3, 
         l.dtdebito = l.dtmvtopg,
         l.cdcritic = 717,
         l.dscritic = '(INC0264208) - Solicitado cancelamento dos agendamentos.'
 WHERE l.cdcooper = 7
   AND l.nrdconta = 2887
   AND l.insitlau = 1       
   AND l.VLLANAUT IN (155.91, 1341.18)
   AND l.cdhistor = 508;
   COMMIT;       
END;