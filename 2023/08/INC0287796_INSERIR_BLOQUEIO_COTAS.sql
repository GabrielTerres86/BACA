BEGIN

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
               VALUES(16                      
                     ,901377               
                     ,83382470900          
                     ,4 
                     ,3 
                     ,0  
                     ,trunc(SYSDATE)     
                     ,317.81 
                     ,1      
                     ,NULL   
                     ,'Vara da Fazenda Pub. Acid. do Trab e Reg. Pub Rio do Sul'                       
                     ,'Bloqueio de capital ate R$ 317,81'                       
                     ,'24/08/2023'                       
                     ,'310046643761' 
                     ,'5013470-07.2020.8.24.0054'                      
                     ,''                       
                     ,0                       
                     ,(To_Number(To_Char(systimestamp,'SSSSS'))));
                             
  COMMIT;
  
END;



