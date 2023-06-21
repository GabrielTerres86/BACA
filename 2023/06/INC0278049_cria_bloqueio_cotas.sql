begin 

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
                     VALUES(1                      
                           ,10951300               
                           ,14462075000107         
                           ,4
                           ,3                      
                           ,0                      
                           ,TRUNC(SYSDATE)         
                           ,null                   
                           ,1893.48                
                           ,1                      
                           ,NULL                   
                           ,'Primeira Vara Civel da Comarca de Blumenau'
                           ,'BLOQUEIO DE CAPITAL ATE R$ 1.893,48'       
                           ,TRUNC(SYSDATE)                              
                           ,'310044068089'                              
                           ,'50000427542014824000'                   
                           ,''                      
                           ,0                       
                           ,To_Number(To_Char(systimestamp,'SSSSS')));
                             
   commit;
                               
end;                             
