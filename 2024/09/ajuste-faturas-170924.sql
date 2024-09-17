BEGIN
  UPDATE cecred.craplft
     SET flintegra  = NULL,
         cdsituacao = NULL,
         dsintegra  = NULL,
         insitfat   = 1,
         dtmvtolt   = to_date('17/09/2024', 'DD/MM/YYYY'),
         dtvencto   = to_date('17/09/2024', 'DD/MM/YYYY'),
         nrseqdig   = nrseqdig + 9000000
   WHERE progress_recid IN (77874775,77901012,77901028,77900577,77900234,77899708,77899552,77899762,77899400,77900729,77900357,77899716
,77899438,77900915,77900914,77899138,77899957,77900927,77899461,77900358,77900334);

  COMMIT;
END;