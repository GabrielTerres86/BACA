BEGIN

/* Conta: 13453807 */

   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13453807,
    7563239818945,
    0,
    16
    );

    UPDATE CRAWCRD
       SET NRCRCARD = 6393500219514362
          ,INSITCRD = 3
          ,NRCCTITG = 7563239818945
          ,CDLIMCRD = 0
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13453807
       AND NRCTRCRD = 2384718;

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
           ,13453807
           ,6393500219514362
           ,14303380911
           ,'JOAO V F HASCKEL'
           ,0
           ,0
           ,NULL
           ,2384718
           ,0
           ,0
           ,16
           ,2
           ,NULL
           ,1
           ,0);

  COMMIT;

END;