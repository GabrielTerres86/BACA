BEGIN
UPDATE CECRED.TBGEN_ANALISE_FRAUDE A SET A.CDPARECER_ANALISE = 2, A.FLGANALISE_MANUAL = 1 WHERE A.IDANALISE_FRAUDE = 357047354;
COMMIT;
END;