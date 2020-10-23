INSERT INTO CRAPACA VALUES(3966,'CONSULTAMOVCMP_P11', 'TELA_MOVCMP', 'pc_protocolos_dev_doc', 'pr_vcooper,pr_dtinicial,pr_dtfinal', 1844);
INSERT INTO CRAPACA VALUES(3967,'CONSULTAMOVCMP_P12', 'TELA_MOVCMP', 'pc_lotes_doc_detalhes', 'pr_vcooper,pr_dtmvtolt,pr_nrversao', 1844);
UPDATE CRAPACA
SET LSTPARAM = 'pr_cdocorrencia,pr_tparquiv'
WHERE NMDEACAO = 'CONSULTAMOVCMP_P9'
  AND NRSEQRDR = 1844;

COMMIT;

