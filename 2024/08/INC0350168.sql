DECLARE
  CURSOR cr_crapcyb IS
    SELECT a.cdcooper
          ,a.nrdconta
          ,a.cdorigem
          ,a.nrctremp
          ,c.dtmvtolt
      FROM cecred.crapcyb a
          ,cecred.crapass b
          ,cecred.crapdat c
     WHERE a.cdcooper = b.cdcooper
       AND a.nrdconta = b.nrdconta
       AND a.cdcooper = c.cdcooper
       AND a.cdcooper = 1
       AND b.progress_recid = 735832
       AND a.nrctremp = 801020501
     ORDER BY a.cdorigem
             ,a.nrctremp;
  rw_crapcyb cr_crapcyb%ROWTYPE;
BEGIN
  OPEN cr_crapcyb;
  FETCH cr_crapcyb
    INTO rw_crapcyb;
  CLOSE cr_crapcyb;

  IF nvl(rw_crapcyb.cdcooper, 0) > 0 THEN
    INSERT INTO cecred.crapcyc
      (cdcooper
      ,cdorigem
      ,nrdconta
      ,nrctremp
      ,flgjudic
      ,flextjud
      ,flgehvip
      ,cdoperad
      ,dtinclus
      ,cdopeinc
      ,dtaltera)
    VALUES
      (rw_crapcyb.cdcooper
      ,rw_crapcyb.cdorigem
      ,rw_crapcyb.nrdconta
      ,rw_crapcyb.nrctremp
      ,0
      ,0
      ,1
      ,'cyber'
      ,rw_crapcyb.dtmvtolt
      ,'cyber'
      ,rw_crapcyb.dtmvtolt);
    COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
