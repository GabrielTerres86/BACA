DECLARE
  /*Este Script verifica se a tela desejada existe na craprdr, caso nao exista faz o insert
  Após isso faz o insert na crapaca*/

  vr_nrseqrdr  cecred.craprdr.nrseqrdr%TYPE;
  vr_nrseqaca  cecred.crapaca.nrseqaca%TYPE;
  vr_nome_tela cecred.craprdr.nmprogra%TYPE := 'TELA_ATENDA_COBRAN';
  vr_nmdeacao  cecred.crapaca.nmdeacao%TYPE := 'CONSULTA_CONVENIO_INSERT';
  vr_nmpackag  cecred.crapaca.nmpackag%TYPE := 'TELA_ATENDA_COBRAN';
  vr_nmproced  cecred.crapaca.nmproced%TYPE := 'pc_consulta_convenio';
  vr_lstparam  cecred.crapaca.lstparam%TYPE := 'pr_cdcooper,pr_nrdconta,pr_nrconven';

BEGIN

  BEGIN
    SELECT rdr.nrseqrdr INTO vr_nrseqrdr FROM cecred.craprdr rdr WHERE upper(rdr.nmprogra) = vr_nome_tela;
  EXCEPTION
    WHEN no_data_found THEN
      SELECT MAX(nrseqrdr) + 1 INTO vr_nrseqrdr FROM craprdr;
    
      INSERT INTO cecred.craprdr (nrseqrdr, nmprogra, dtsolici) VALUES (vr_nrseqrdr, vr_nome_tela, SYSDATE);
    
      COMMIT;
  END;

  SELECT MAX(nrseqaca) + 1 INTO vr_nrseqaca FROM cecred.crapaca;

  INSERT INTO cecred.crapaca
    (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES
    (vr_nrseqaca, vr_nmdeacao, vr_nmpackag, vr_nmproced, vr_lstparam, vr_nrseqrdr);
  COMMIT;
END;
