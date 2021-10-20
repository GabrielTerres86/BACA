BEGIN

/* Conta: 13454013 */

   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13454013,
    7563239818946,
    0,
    12
    );

    UPDATE CRAWCRD
       SET NRCRCARD = 5127070387423874
          ,INSITCRD = 3
          ,NRCCTITG = 7563239818946
          ,CDLIMCRD = 0
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13454013
       AND NRCTRCRD = 2384766;

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
           ,13454013
           ,5127070387423874
           ,38006855900
           ,'JOSE LUIZ PETERMANN'
           ,19
           ,0
           ,NULL
           ,2384766
           ,0
           ,0
           ,12
           ,2
           ,NULL
           ,1
           ,0);

  COMMIT;

END;