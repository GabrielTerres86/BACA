DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;

  rw_crapdat  btch0001.rw_crapdat%TYPE;

BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
  
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat
      INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
  
    UPDATE gestaoderisco.tbcc_historico_juros_adp h
       SET h.vllimite =
           (SELECT s.vllimcre
              FROM crapsda s
             WHERE s.cdcooper = h.cdcooper
               AND s.nrdconta = h.nrdconta
               AND s.dtmvtolt = h.dtmvtolt
               AND s.vlsddisp < 0
               AND s.vllimcre > 0)
     WHERE h.cdcooper = rw_crapcop.cdcooper
       AND h.dtmvtolt = rw_crapdat.dtmvtoan
       AND EXISTS (SELECT 1
              FROM crapsda s
             WHERE s.cdcooper = h.cdcooper
               AND s.nrdconta = h.nrdconta
               AND s.dtmvtolt = h.dtmvtolt
               AND s.vlsddisp < 0
               AND s.vllimcre > 0);
  
  END LOOP;
  COMMIT;

END;
