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
    12716995,
    7563239738820,
    NULL,
    12
    );
  END;
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 5127070349668681
          ,INSITCRD = 4
          ,NRCCTITG = 7563239738820
          ,CDLIMCRD = 0
     WHERE CDCOOPER = 1
       AND NRDCONTA = 12716995
       AND NRCTRCRD = 2158692;
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
           ,12716995
           ,5127070349668681
           ,12399090985
           ,'DANIELLE DE MORAES'
           ,19
           ,0
           ,NULL
           ,2158692
           ,0
           ,0
           ,12
           ,2
           ,NULL
           ,1
           ,0);
  END;  
  COMMIT;
  
END;
