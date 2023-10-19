BEGIN
  INSERT INTO craprdr
    (NMPROGRA
    ,DTSOLICI)
  VALUES
    ('TARI0001'
    ,SYSDATE);
	
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CANCELA_DESCONTO_PIX'
    ,'TARI0001'
    ,'pc_cancela_desconto_pix_web'
    ,'pr_iddesconto_pix,pr_cdoperador'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TARI0001'
        AND ROWNUM = 1));
	
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('INCLUI_DESCONTO_PIX'
    ,'TARI0001'
    ,'pc_inclui_desconto_pix_web'
    ,'pr_cdtarcom,pr_dtinicom,pr_dtfimcom,pr_pedescom,pr_cdtarcob,pr_dtinicob,pr_dtfimcob,pr_pedescob,pr_dsjustif,pr_cdaprova,pr_cdoperad'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TARI0001'
        AND ROWNUM = 1));
	
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VALIDA_DESCONTO_PIX'
    ,'TARI0001'
    ,'pc_carrega_par_tar_vigente_web'
    ,'pr_cdbattar'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TARI0001'
        AND ROWNUM = 1));
		
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('CONSULTA_DESCONTO_PIX'
    ,'TARI0001'
    ,'pc_consulta_desconto_pix_web'
    ,'pr_cdcooper,pr_nrdconta'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TARI0001'
        AND ROWNUM = 1));
		
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VERIFICA_PESSOA_JURIDICA'
    ,'TELA_ATENDA_API'
    ,'pc_verifica_pessoa_juridica'
    ,'pr_nrcpfcgc'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TELA_ATENDA_API'
        AND ROWNUM = 1));

  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('VERIFICA_DESCONTO_PIX_ATIVO'
    ,'TARI0001'
    ,'pc_verifica_desconto_pix_ativo_web'
    ,'pr_cdtarcom,pr_dtinicom,pr_cdtarcob,pr_dtinicob,pr_nrdconta'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'TARI0001'
        AND ROWNUM = 1));
COMMIT;
END;