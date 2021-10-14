BEGIN

/* Conta: 13449737 */

   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13449737,
    7563239818936,
    2500.00,
    18
    );

    UPDATE CRAWCRD
       SET NRCRCARD = 5161620002890878
          ,INSITCRD = 3
          ,NRCCTITG = 7563239818936
          ,CDLIMCRD = 0
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13449737
       AND NRCTRCRD = 2384849;

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
           ,13449737
           ,5161620002890878
           ,31866835807
           ,'ADEMIR ANTONIO LINO'
           ,11
           ,0
           ,NULL
           ,2384849
           ,0
           ,0
           ,18
           ,2
           ,NULL
           ,1
           ,0);

/* Conta: 13453882 */

   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (1,
    13453882,
    7563239818675,
    3000.00,
    12
    );

    UPDATE CRAWCRD
       SET NRCRCARD = 5127070387372386
          ,INSITCRD = 3
          ,NRCCTITG = 7563239818675
          ,CDLIMCRD = 23
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13453882
       AND NRCTRCRD = 2391620;

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
           ,13453882
           ,5127070387372386
           ,26128715869
           ,'SAMARA DE FREITAS'
           ,11
           ,23
           ,NULL
           ,2391620
           ,0
           ,0
           ,12
           ,2
           ,NULL
           ,1
           ,0);

/* Conta: 13216295 */

    UPDATE CRAWCRD
       SET NRCRCARD = 5474080230827089
          ,INSITCRD = 3
          ,NRCCTITG = 7563239818919
          ,CDLIMCRD = 10
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 1
       AND NRDCONTA = 13216295
       AND NRCTRCRD = 2386604;

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
           ,13216295
           ,5474080230827089
           ,6892237908
           ,'FERNANDO MAY'
           ,19
           ,10
           ,NULL
           ,2386604
           ,0
           ,0
           ,15
           ,2
           ,NULL
           ,1
           ,0);

  COMMIT;

END;