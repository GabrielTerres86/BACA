BEGIN

UPDATE	CECRED.TBGRV_REGISTRO_CONTRATO
SET	CDSITUACAO_CONTRATO = 2,
	DSRETORNO_CONTRATO = 'SC20240001044713',
	DSC_IDENTIFICADOR = 'SC20240001044713'
WHERE	IDREGISTRO_CONTRATO = 637763;

COMMIT;

EXCEPTION WHEN OTHERS THEN
	ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO ' || SQLERRM);
END;