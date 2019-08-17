DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'CADDES';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
	INSERT INTO craprdr(nmprogra,dtsolici)
		   VALUES('CADDES', SYSDATE)
		   RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('CADASTRA_DESENVOLVEDOR', 'TELA_CADDES', 'pc_cadastra_desenvolvedor', 'pr_nrdocumento,pr_dsnome,pr_nrcep_endereco,pr_dsendereco,pr_nrendereco,pr_dsbairro,pr_dscidade,pr_dsunidade_federacao,pr_dsemail,pr_nrddd_celular,pr_nrtelefone_celular,pr_dscontato_celular,pr_nrddd_comercial,pr_nrtelefone_comercial,pr_dscontato_comercial,pr_inpessoa,pr_dscomplemento', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('CONSULTA_DESENVOLVEDOR', 'TELA_CADDES', 'pc_consulta_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ALTERA_DESENVOLVEDOR', 'TELA_CADDES', 'pc_altera_desenvolvedor', 'pr_cddesenvolvedor,pr_nrdocumento,pr_dsnome,pr_nrcep_endereco,pr_dsendereco,pr_nrendereco,pr_dsbairro,pr_dscidade,pr_dsunidade_federacao,pr_dsemail,pr_nrddd_celular,pr_nrtelefone_celular,pr_dscontato_celular,pr_nrddd_comercial,pr_nrtelefone_comercial,pr_dscontato_comercial,pr_inpessoa,pr_dscomplemento,pr_dsusuario_portal', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('EXCLUI_DESENVOLVEDOR', 'TELA_CADDES', 'pc_exclui_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('PESQUISA_DESENVOLVEDOR', 'TELA_CADDES', 'pc_pesquisa_desenvolvedor', 'pr_nrdocumento,pr_dsempresa,pr_nriniseq,pr_nrregist', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ALTERA_FRASE_DESENVOLVEDOR', 'TELA_CADDES', 'pc_altera_frase_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ENVIA_FRASE_DESENVOLVEDOR', 'TELA_CADDES', 'pc_envia_frase_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ENVIA_UUID_DESENVOLVEDOR', 'TELA_CADDES', 'pc_envia_uuid_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('GERA_UUID_DESENVOLVEDOR', 'TELA_CADDES', 'pc_gera_uuid_desenvolvedor', 'pr_cddesenvolvedor', vr_nrseqrdr);
  
  UPDATE crapaca c
    SET c.lstparam = c.lstparam || ',pr_flgapihm'
  WHERE c.nmdeacao = 'HABILITA_CONVENIO'
    AND c.nmpackag = 'TELA_ATENDA_COBRAN';
  
  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a CADDES criado com sucesso!');
  
END;
