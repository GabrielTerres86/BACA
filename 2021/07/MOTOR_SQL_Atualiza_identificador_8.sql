BEGIN

UPDATE tbgrv_registro_imagem x
SET x.nrctrpro = 220060
WHERE ( x.cdcooper = 6 AND x.nrdconta = 114871 AND x.NRCTRPRO = 240703 AND x.idseqbem = 3);

COMMIT;
END;
