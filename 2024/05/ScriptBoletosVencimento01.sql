BEGIN

  UPDATE cecred.crapcob c
     SET c.dtvencto = to_date('15062024','ddmmyyyy')
        ,c.dtvctori = to_date('15062024','ddmmyyyy')
        ,c.dtlipgto = to_date('15072024','ddmmyyyy')
   WHERE (idtitleg, nrdconta, nrdocmto) in ((131879220, 84946393, 1889));

   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.EXCECAOINTERNA(pr_cdcooper => 3, pr_compleme => 'Script vencm');
END;
