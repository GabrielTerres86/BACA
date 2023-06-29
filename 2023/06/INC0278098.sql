BEGIN
    UPDATE CECRED.tbcrd_limite_atualiza
    SET insitdec = 7
    ,tpsituacao = 6
    WHERE cdcooper = 1
    AND nrdconta = 12439703
    AND NRPROPOSTA_EST IN (2830976 ,2624945 ) 
    AND TPSITUACAO = 6 ;
    
    commit;
END;
