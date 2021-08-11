DECLARE
  v_nrseqrdr  craprdr.nrseqrdr%type;  
BEGIN
  INSERT INTO craprdr(nrseqrdr,nmprogra,dtsolici) VALUES ((SELECT MAX(nrseqrdr) + 1 FROM craprdr),'INSS0001', SYSDATE) 
  RETURNING nrseqrdr INTO v_nrseqrdr;

  INSERT INTO crapaca (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES ((SELECT MAX(nrseqaca)+1 FROM crapaca), 'CONSULTAR_NOTIF_INSS', 'INSS0001', 'pc_consulta_notif_inss', 'pr_cdcooper, pr_nrdconta', v_nrseqrdr);

  COMMIT;
END;


