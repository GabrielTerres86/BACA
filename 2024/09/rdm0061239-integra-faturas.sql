BEGIN
  UPDATE cecred.craplft
     SET flintegra  = NULL,
         cdsituacao = NULL,
         dsintegra  = NULL,
         insitfat   = 1,
         dtmvtolt   = to_date('13/09/2024', 'DD/MM/YYYY'),
         dtvencto   = to_date('13/09/2024', 'DD/MM/YYYY')
   WHERE progress_recid IN (77853192,77853167,77853090,77852792,77852164,
                            77851333,77850567,77848571,77848449,77847002,
                            77846858,77845659,77844819,77839141);
  COMMIT;
END;