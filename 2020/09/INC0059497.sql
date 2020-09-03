BEGIN
  BEGIN
     -- Atualiza a proposta
     UPDATE crawcrd w 
        SET w.nrcctitg = 7563239610410,
            w.nrcrcard = 5474080171904822,
            w.insitcrd = 3, 
            w.dtentreg = NULL, 
            w.inanuida = 0, 
            w.qtanuida = 0,
            w.dtlibera = trunc(SYSDATE),
            w.dtrejeit = NULL          
      WHERE w.cdcooper = 1
        AND w.nrdconta = 9911472
        AND w.nrcpftit = 80538908904;      
     
     BEGIN
           -- Insere o cartao
        INSERT INTO crapcrd (
      cdcooper,
      nrdconta,
      nrcrcard,
      nrcpftit,
      nmtitcrd,
      dddebito,
      cdlimcrd,
      dtvalida,
      nrctrcrd,
      cdmotivo,
      nrprotoc,
      cdadmcrd,
      tpcartao,
      dtcancel,
      flgdebit
    ) SELECT w.cdcooper
          ,w.nrdconta
          ,w.nrcrcard
          ,w.nrcpftit
          ,w.nmtitcrd
          ,w.dddebito
          ,w.cdlimcrd
          ,w.dtvalida
          ,w.nrctrcrd
          ,w.cdmotivo
          ,w.nrprotoc
          ,w.cdadmcrd
          ,w.tpcartao
          ,w.dtcancel
          ,w.flgdebit
       FROM crawcrd w
      WHERE w.cdcooper = 1
        AND w.nrdconta = 9911472
        AND w.nrcpftit = 80538908904;
       
       BEGIN
          -- insere conta cartoa
          INSERT INTO tbcrd_conta_cartao
                      (cdcooper,
                       nrdconta,
                       nrconta_cartao)
               VALUES (1,        
                       9911472, 
                       7563239610410);          
       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
           Raise_Application_Error (-20343, 'Erro ao criar registro na tbcrd_conta_cartao.' || SQLERRM);                  
       END;         
     EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK;
         Raise_Application_Error (-20343, 'Erro ao criar registro na crapcrd.' || SQLERRM);         
     END;  
     
     COMMIT;      
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       Raise_Application_Error (-20343, 'Erro ao atualizar registro crawcrd.' || SQLERRM);
   END;
   
END;
