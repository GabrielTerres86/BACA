BEGIN

INSERT INTO cecred.crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('IMP_TERMO_CANCEL_SEG_PRES', 'SEGU0003', 'pc_imp_termo_cancel_seg_pres', 'pr_cdcooper,pr_nrdconta,pr_nrctrseg',(SELECT nrseqrdr from cecred.CRAPRDR WHERE nmprogra = 'SEGU0003'));

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/