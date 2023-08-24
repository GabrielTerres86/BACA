BEGIN

  -- Inserir o registro do bloqueio
  INSERT INTO cecred.crapblj(cdcooper
                     ,nrdconta
                     ,nrcpfcgc
                     ,cdmodali
                     ,cdtipmov
                     ,flblcrft
                     ,dtblqini
                     ,vlbloque
                     ,cdopdblq
                     ,cdopddes
                     ,dsjuizem
                     ,dsresord
                     ,dtenvres
                     ,nroficio
                     ,nrproces
                     ,dsinfadc
                     ,vlresblq
                     ,hrblqini)
               VALUES(16                       -- cdcooper
                     ,901377               -- nrdconta
                     ,83382470900               -- nrcpfcgc
                     ,4 -- cdmodali
                     ,3 --BLOQUEIO DE CAPITAL
                     ,0                       -- flblcrft
                     ,trunc(SYSDATE)      -- dtblqini                     
                     ,317.81 -- vlbloque
                     ,1                       -- cdopdblq /* Operador Bloqueio    */
                     ,NULL                              -- cdopddes /* Operador Desbloqueio */
                     ,'Vara da Fazenda Pub. Acid. do Trab e Reg. Pub Rio do Sul'                       -- dsjuizem
                     ,'Bloqueio de capital ate R$ 317,81'                       -- dsresord
                     ,'24/08/2023'                       -- dtenvres
                     ,'310046643761' -- nroficio
                     ,'5013470-07.2020.8.24.0054'                       -- nrproces
                     ,''                       -- dsinfadc
                     ,0                       -- vlresblq
                     ,(To_Number(To_Char(systimestamp,'SSSSS'))));
                             
  COMMIT;
  
END;



