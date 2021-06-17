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
    12129674,
    7563239679923,
    NULL,
    15
    );
  END;
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 5474080190862100
          ,INSITCRD = 4
          ,NRCCTITG = 7563239679923
          ,CDLIMCRD = 0
     WHERE CDCOOPER = 1
       AND NRDCONTA = 12129674
       AND NRCTRCRD = 1985521;
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
           ,12129674
           ,5474080190862100
           ,03273453907
           ,'DAIANA ANTUNES CORREA'
           ,11
           ,0
           ,NULL
           ,1985521
           ,0
           ,0
           ,15
           ,2
           ,NULL
           ,1
           ,0);
  END;
  
  BEGIN
  DELETE FROM CRAWCRD
  WHERE CDCOOPER = 1
    AND NRDCONTA = 12129674
    AND NRCTRCRD = 2113863;
  END;
  
  COMMIT; 
  
END;
