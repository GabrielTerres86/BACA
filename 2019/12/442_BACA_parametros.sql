DECLARE
  
  -- Buscar registro da RDR
  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = pr_nmprogra;
  
  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  vr_nmprogra craprdr.nmprogra%TYPE;
BEGIN
    --Dados para o BACA
    vr_nmprogra := 'GRVM0001';
    OPEN  cr_craprdr (pr_nmprogra => vr_nmprogra);
    FETCH cr_craprdr INTO vr_nrseqrdr;
    CLOSE cr_craprdr;
    
    insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values('PREP_REGIS_CONTRATO','GRVM0001','pc_prep_registro_contrato_web','pr_nrdconta, pr_nrctrpro',vr_nrseqrdr);
    
    vr_nmprogra := 'GRVM0002';
    OPEN  cr_craprdr (pr_nmprogra => vr_nmprogra);
    FETCH cr_craprdr INTO vr_nrseqrdr;
    CLOSE cr_craprdr;
    
    insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values('GRAVA_RET_REGIS_CONTRATO','GRVM0002','pc_grava_ret_regis_contrat_web','pr_nrdconta, pr_nrctrpro,pd_idseqbem,pr_idgrvm ,pr_idregis',vr_nrseqrdr);

    insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
    values('GRAVA_RET_IMG_CONTRATO','GRVM0002','pc_grava_ret_img_contrat_web','pr_nrdconta,pr_nrctrpro,pd_idseqbem,pr_idgrvm ,pr_idregis',vr_nrseqrdr);
    
    insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values ('VALIDA_CRITICAS_REGISTRO', 'GRVM0002', 'pc_valida_criticas_reg_web', 'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_tpctrpro,pr_idseqbem,pr_cddopcao,pr_tpinclus', vr_nrseqrdr);


    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       0,
       'GRAVAM_UF_ENVIO_BENS_SEP',
       'Parametro de controle para verificar se o estado deve enviar o xml de bens de uma vez so ou enviar um xml para cada bem',
       'PR');
       
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       0,
       'URI_CONTRATO_GRAVAME',
       'URI para Registro Contrato do GRAVAME',
       '/osb-soa/GarantiaVeiculoRestService/v1/RegistrarContratoGravames');
       
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       0,
       'URI_IMG_CONTRATO_GRAVAME',
       'URI para Imagem Contrato do GRAVAME',
       '/osb-soa/GarantiaVeiculoRestService/v1/EnviarImagemContratoGravames');
       
    commit;
END;