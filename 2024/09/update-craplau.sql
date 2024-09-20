BEGIN
  UPDATE cecred.craplft
     SET flintegra  = NULL,
         cdsituacao = NULL,
         dsintegra  = NULL,
         insitfat   = 1,
         dtmvtolt   = to_date('20/09/2024', 'DD/MM/YYYY'),
         dtvencto   = to_date('20/09/2024', 'DD/MM/YYYY'),
         nrseqdig   = nrseqdig + 9000000
   WHERE progress_recid IN (77943474);
  COMMIT;

  UPDATE cecred.craplau
     SET dtdebito = to_date('25/09/2020', 'dd/mm/yyyy')
   WHERE nrdconta = 8076901
     AND cdcooper = 1
     AND progress_recid = 42398793;
  COMMIT;
END;