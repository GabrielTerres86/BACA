BEGIN
    UPDATE CECRED.tbcrd_limite_atualiza
    SET insitdec = 7
    ,tpsituacao = 6
    WHERE cdcooper = 1
    AND nrdconta = 10505792
    AND NRPROPOSTA_EST IN (3193392 ,1598061 );
   
    commit;
END;
