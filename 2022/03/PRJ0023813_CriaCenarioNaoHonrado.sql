BEGIN
  UPDATE crapris a
     SET a.qtdiaatr = 321
   WHERE a.cdcooper = 14
     AND a.nrdconta = 202320
     AND a.nrctremp = 19124
     AND a.dtrefere = to_date('09/03/2022', 'DD/MM/RRRR');

  UPDATE crapris a
     SET a.qtdiaatr = 321
   WHERE a.cdcooper = 7
     AND a.nrdconta = 193992
     AND a.nrctremp = 43195
     AND a.dtrefere = to_date('09/03/2022', 'DD/MM/RRRR');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
