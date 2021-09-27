BEGIN
/* Corrigir cartão que está registrado no Bancoob, mas veio erro na API */

   BEGIN
   INSERT INTO tbcrd_conta_cartao
    (cdcooper
    ,nrdconta
    ,nrconta_cartao
    ,vllimite_global
    ,cdadmcrd
    )
    VALUES
    (16,
    484440,
    7564420077298,
    NULL,
    16
    );
  END;
  BEGIN
    UPDATE CRAWCRD
       SET NRCRCARD = 6393500103930096
          ,INSITCRD = 3
          ,NRCCTITG = 7564420077298
          ,CDLIMCRD = 0
	  ,dtrejeit = null
	  ,dtlibera = trunc(SYSDATE)
	  ,dtentreg = null
     WHERE CDCOOPER = 16
       AND NRDCONTA = 484440
       AND NRCTRCRD = 153397;
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
           ,484440
           ,6393500103930096
           ,2529412928
           ,'DANIEL R MATHIAS'
           ,0
           ,0
           ,NULL
           ,153397
           ,0
           ,0
           ,16
           ,2
           ,NULL
           ,1
           ,0);
  END;  
  COMMIT;
END;