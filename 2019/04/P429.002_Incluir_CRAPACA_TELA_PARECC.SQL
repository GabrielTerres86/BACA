DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'TELA_PARECC';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('TELA_PARECC', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_DOMINIO_PARECC', 'TELA_PARECC', 'pc_busca_dominio_parecc', 'pr_nmdominio', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_COOP_PARECC', 'TELA_PARECC', 'pc_busca_coop_parecc', '', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_PA_PARECC', 'TELA_PARECC', 'pc_busca_pa_coop', 'pr_cdcooperativa,pr_idfuncionalidade,pr_idtipoenvio', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ALTERA_PARAMS_PARECC', 'TELA_PARECC', 'pc_altera_params_parecc', 'pr_cdcooperativa,pr_idfuncionalidade,pr_flghabilitar,pr_idtipoenvio,pr_cdcooppodenviar', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_FLGHABILITAR', 'TELA_PARECC', 'pc_busca_flghabilitar', 'pr_cdcooperativa,pr_idfuncionalidade', vr_nrseqrdr);
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a PARECC criado com sucesso!');
  
END;
