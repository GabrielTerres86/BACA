DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = 'ATENDA_CRD';
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  
BEGIN
  
  -- Buscar RDR
  OPEN  cr_craprdr;
  FETCH cr_craprdr INTO vr_nrseqrdr;
  
  -- Se nao encontrar
  IF cr_craprdr%NOTFOUND THEN
  
  INSERT INTO craprdr(nmprogra,dtsolici)
       VALUES('ATENDA_CRD', SYSDATE)
       RETURNING craprdr.nrseqrdr INTO vr_nrseqrdr;
  
  END IF;
  
  -- Fechar o cursor
  CLOSE cr_craprdr;
  
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('VALIDA_REENVIO_ALT_LIMITE', 'TELA_ATENDA_CARTAOCREDITO', 'pc_valida_reenvio_alt_limite', 'pr_cdcooper,pr_nrdconta,pr_nrcctitg', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ATUALIZA_ENDERECO_CRD', 'TELA_ATENDA_CARTAOCREDITO', 'pc_atualiza_endereco_crd', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd,pr_idtipoenvio,pr_cdagenci', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_PARAMETRO_APROVADOR', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_parametro_aprovador', 'pr_cdcooper', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_ENDERECOS_CRD', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_enderecos_crd', 'pr_cdcooper,pr_nrdconta', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('BUSCA_DADOS_CRD', 'TELA_ATENDA_CARTAOCREDITO', 'pc_busca_dados_crd', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd,pr_cdadmcrd', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('RETORNA_DADOS_ENTREGA_CARTAO', 'CADA0004', 'pc_retorna_dados_entrg_crt_web', 'pr_cdcooper,pr_nrdconta,pr_nrctrcrd', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('ENVIO_CARTAO_COOP_PA', 'TELA_ATENDA_CARTAOCREDITO', 'pc_verifica_cooperativa_pa_web', 'pr_nrdconta', vr_nrseqrdr);
  INSERT INTO crapaca (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) VALUES ('RETORNA_TIPO_ENVIO', 'CCRD0008', 'pc_retorna_tipo_envio', 'pr_nrdconta,pr_nrctrcrd', vr_nrseqrdr);

  COMMIT;
  
  -- Apresenta uma mensagem de ok
  dbms_output.put_line('Referencia a ATENDA_CRD criado com sucesso!');
  
END;
