BEGIN
  BEGIN
    UPDATE crappro
       SET nrdocmto = 422693
         , vldocmto = 1000
     WHERE cdcooper = 7
       AND nrdconta = 254045
       AND dtmvtolt = '17/05/2019';
    UPDATE crappro
       SET nrdocmto = 51427
         , vldocmto = 600
     WHERE cdcooper = 16
       AND nrdconta = 500690
       AND dtmvtolt = '14/05/2019';
    UPDATE crappro
       SET flgativo = 0
     WHERE cdcooper = 13
       AND nrdconta = 281387
       AND dtmvtolt = '13/05/2019';
    UPDATE crappro
       SET flgativo = 0
     WHERE cdcooper = 7
       AND nrdconta = 127078
       AND dtmvtolt = '20/05/2019';
  END;
  --
  BEGIN
    FOR r1 in (SELECT DISTINCT
                      b.dtmvtolt
                     ,b.cdcooper
                     ,b.nrdconta
                     ,b.ROWID rowid_crapdoc
                 FROM crapdoc b
                WHERE cdcooper > 0
                  AND dtmvtolt > '01-02-2019'
                  AND tpbxapen = 0
                  AND tpdocmto = 19
                  AND flgdigit = 0
                  AND EXISTS (SELECT 1
                                FROM crappro a
                               WHERE b.cdcooper = a.cdcooper
                                 AND b.nrdconta = a.nrdconta
                                 AND b.dtmvtolt = a.dtmvtolt
                                 AND a.cdtippro = 29
                                 AND a.flgativo = 1
                                 AND EXISTS (SELECT *
                                               FROM craplim c
                                              WHERE c.cdcooper = a.cdcooper
                                                AND c.nrdconta = a.nrdconta
                                                AND c.nrctrlim = a.nrdocmto
                                                AND c.flgdigit = 0
                                                AND c.insitlim <> 3)))
    LOOP
      BEGIN
        UPDATE crapdoc aa
           SET dtbxapen = SYSDATE
              ,cdopebxa = '1'
              ,tpbxapen = 3
         WHERE ROWID = r1.rowid_crapdoc;
      EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20500,'Erro Update CRAPDOC = '||SQLERRM);
      END;
    END LOOP;
  END;
  --
  
  COMMIT;
END;
