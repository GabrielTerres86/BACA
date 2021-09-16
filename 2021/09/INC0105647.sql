BEGIN
   BEGIN
   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13170538,
    7563239787757,
    NULL,
    13
    );
  END;
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 5158940078588429
          ,INSITCRD = 3
          ,NRCCTITG = 7563239787757
          ,CDLIMCRD = 70
          ,DTREJEIT = NULL
          ,DTLIBERA = TRUNC(SYSDATE)
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13170538
       AND NRCTRCRD = 2295789;
  END;
  BEGIN
    INSERT INTO crapcrd
           (cdcooper
           ,nrdconta
           ,nrcrcard
           ,nrcpftit
           ,nmtitcrd
           ,dddebito
           ,cdlimcrd
           ,dtvalida
           ,nrctrcrd
           ,cdmotivo
           ,nrprotoc
           ,cdadmcrd
           ,tpcartao
           ,dtcancel
           ,flgdebit
           ,flgprovi)
        VALUES
           (1
           ,13170538
           ,5158940078588429
           ,25900947874
           ,'CELSO R GUBITOSO'
           ,11
           ,70
           ,NULL
           ,2295789
           ,0
           ,0
           ,13
           ,2
           ,NULL
           ,1
           ,0);
  END;  
  COMMIT;
  
END;