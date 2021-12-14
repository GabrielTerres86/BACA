BEGIN

/* Conta: 13019368 */

   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13019368,
    7563239788010,
    0,
    17
    );

    UPDATE CRAWCRD
       SET NRCRCARD = 6393500211067740
          ,INSITCRD = 4
          ,NRCCTITG = 7563239788010
          ,CDLIMCRD = 0
    ,dtrejeit = null
    ,dtlibera = trunc(SYSDATE)
    ,dtentreg = TO_DATE('25/11/2021', 'dd/mm/yyyy')
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13019368
       AND NRCTRCRD = 2296271;

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
           ,13019368
           ,6393500211067740
           ,5732128999
           ,'GILSON GODOY TIBLIER'
           ,0
           ,0
           ,NULL
           ,2296271
           ,0
           ,0
           ,17
           ,2
           ,NULL
           ,1
           ,0);

  COMMIT;

END;
