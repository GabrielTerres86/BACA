BEGIN
  UPDATE crapris a
     SET a.qtdiaatr = 321
   WHERE a.cdcooper = 1
     AND a.nrdconta = 9813047
     AND a.nrctremp = 2983767
     AND a.dtrefere = to_date('14/03/2022', 'DD/MM/RRRR');

  UPDATE crapris a
     SET a.qtdiaatr = 321
   WHERE a.cdcooper = 14
     AND a.nrdconta = 206741
     AND a.nrctremp = 19664
     AND a.dtrefere = to_date('03/02/2022', 'DD/MM/RRRR');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
