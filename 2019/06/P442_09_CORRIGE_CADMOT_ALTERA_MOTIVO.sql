-- Corrigir busca de motivos na tela CADMOT
DECLARE
  CURSOR cr_insert_tela IS
    SELECT ca.nmpackag
          ,ca.nmproced
          ,ca.lstparam
    FROM craprdr cr, crapaca ca
    WHERE ca.nrseqrdr = cr.nrseqrdr
      AND cr.nmprogra = 'CADMOT'
      AND ca.nmdeacao = 'LISTA_COMBO_PRODUTOS';
  rw_insert_tela cr_insert_tela%ROWTYPE;
  
  CURSOR cr_get_seq IS
    SELECT cr.nrseqrdr
    FROM craprdr cr
    WHERE cr.nmprogra = 'CADMOT';
  rw_get_seq cr_get_seq%ROWTYPE;
  
BEGIN
  OPEN cr_insert_tela;
  FETCH cr_insert_tela INTO rw_insert_tela;
  
  IF cr_insert_tela%NOTFOUND THEN
    OPEN cr_get_seq;
    FETCH cr_get_seq INTO rw_get_seq;
    CLOSE cr_get_seq;
  
    INSERT INTO crapaca(nrseqrdr, nmdeacao, nmpackag, nmproced, lstparam)
       VALUES(rw_get_seq.nrseqrdr, 'LISTA_COMBO_PRODUTOS', 'TELA_CADMOT', 'pc_lista_produtos', NULL);
  END IF;
  
  CLOSE cr_insert_tela;
  
  COMMIT;
END;
