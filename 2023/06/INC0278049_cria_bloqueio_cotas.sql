begin 

  -- Inserir o registro do bloqueio
  INSERT INTO cecred.crapblj(cdcooper
                            ,nrdconta
                            ,nrcpfcgc
                            ,cdmodali
                            ,cdtipmov
                            ,flblcrft
                            ,dtblqini
                            ,dtblqfim
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
                     VALUES(1                      -- cdcooper
                           ,10951300               -- nrdconta
                           ,14462075000107         -- nrcpfcgc
                           ,4
                           ,3                      -- cdtipmov
                           ,0                      -- flblcrft
                           ,TRUNC(SYSDATE)         -- dtblqini
                           ,null                   -- dtblqfim
                           ,1893.48                -- vlbloque
                           ,1                      -- cdopdblq /* Operador Bloqueio    */
                           ,NULL                              -- cdopddes /* Operador Desbloqueio */
                           ,'Primeira Vara Civel da Comarca de Blumenau'  -- dsjuizem
                           ,'BLOQUEIO DE CAPITAL ATE R$ 1.893,48'         -- dsresord
                           ,TRUNC(SYSDATE)                                -- dtenvres
                           ,'310044068089'                                -- nroficio
                           ,'50000427542014824000'                   -- nrproces
                           ,''                      -- dsinfadc
                           ,0                       -- vlresblq
                           ,To_Number(To_Char(systimestamp,'SSSSS')));
                             
   commit;
                               
end;                             
