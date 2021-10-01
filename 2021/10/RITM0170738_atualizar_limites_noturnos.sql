BEGIN
    update crapsnh set vllimite_noturno_pix_cooperado = LEAST(vllimite_pix_cooperado, 1000) where tpdsenha = 1;
    COMMIT;
END;