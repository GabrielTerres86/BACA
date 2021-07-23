BEGIN

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 11
WHERE ( x.cdcooper = 8 AND x.nrdconta = 2976 AND x.NRCTRPRO = 8661 );

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 1
WHERE ( x.cdcooper = 8 AND x.nrdconta = 46035 AND x.NRCTRPRO = 8372);

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 1
WHERE ( x.cdcooper = 8 AND x.nrdconta = 20435 AND x.NRCTRPRO = 8384);

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 1
WHERE ( x.cdcooper = 8 AND x.nrdconta = 45411 AND x.NRCTRPRO = 8386);

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 12
WHERE ( x.cdcooper = 8 AND x.nrdconta = 2976 AND x.NRCTRPRO = 3363 );

UPDATE tbgrv_registro_imagem x
SET x.idseqbem = 1
WHERE ( x.cdcooper = 8 AND x.nrdconta = 47708 AND x.NRCTRPRO = 8562);

UPDATE crapbpr x SET flgregim = 0 WHERE  x.cdcooper = 8 AND x.nrdconta = 4715 AND x.NRCTRPRO = 8858 AND x.idseqbem = 19;

COMMIT;
END;
