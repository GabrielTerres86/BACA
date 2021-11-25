BEGIN
UPDATE tbcompe_icf_movimento t
   SET t.dsrowid_depositante = NULL
 WHERE t.dtmvtolt = to_date('14/10/2021','dd/mm/yyyy')
   AND t.tparquiv = 2;
COMMIT;
END;   
