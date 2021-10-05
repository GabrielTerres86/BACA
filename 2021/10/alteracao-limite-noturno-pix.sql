BEGIN
    UPDATE crapsnh SET vllimite_noturno_pix_cooperado = LEAST(vllimite_pix_cooperado, 1000) WHERE tpdsenha = 1 and vllimite_pix is not null;
    COMMIT;
END;