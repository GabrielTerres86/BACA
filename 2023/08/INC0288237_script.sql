BEGIN
    UPDATE CECRED.tbcrd_limite_atualiza
    SET insitdec = 7
    ,tpsituacao = 6
    WHERE cdcooper = 2
    AND nrdconta = 576506
    AND tpsituacao = 6;
    
    commit;
END;
