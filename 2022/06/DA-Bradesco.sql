BEGIN
  UPDATE cecred.craplau l
     SET l.dtdebito = to_date(l.dtmvtolt, 'dd-mm-yyyy'),
         l.cdcritic = 1073,
         l.dscritic = '1073 - Nao foi possivel debitar o agendamento.'
     WHERE l.cdcooper IN (SELECT c.cdcooper FROM cecred.crapcop c)
       AND l.dtmvtopg between to_date('01/11/2021', 'dd/mm/yyyy') and to_date('12/06/2022', 'dd/mm/yyyy')
       AND l.insitlau = 3
       AND l.cdhistor <> 3292
       AND l.dsorigem = 'DEBAUT';

  COMMIT;
END;