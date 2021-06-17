BEGIN
  
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 5158940073116945
          ,INSITCRD = 3
          ,NRCCTITG = 7564420077122
          ,CDLIMCRD = 20
     WHERE CDCOOPER = 16
       AND NRDCONTA = 166197
       AND NRCTRCRD = 153252;
  END;
  
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 5474080209402898
          ,INSITCRD = 3
          ,NRCCTITG = 7563239738666
          ,CDLIMCRD = 10
     WHERE CDCOOPER = 1
       AND NRDCONTA = 12692190
       AND NRCTRCRD = 2158337;
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
           (16
           ,166197
           ,5158940073116945
           ,05187718908
           ,'CLEOMIR D SANTOS'
           ,16
           ,20
           ,NULL
           ,153252
           ,0
           ,0
           ,13
           ,2
           ,NULL
           ,1
           ,0);
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
           ,12692190
           ,5474080209402898
           ,01683639928
           ,'SANDRA DA V FRANCELINO '
           ,11
           ,10
           ,NULL
           ,2158337
           ,0
           ,0
           ,15
           ,2
           ,NULL
           ,1
           ,0);
  END;
  
  COMMIT;
  
END;
