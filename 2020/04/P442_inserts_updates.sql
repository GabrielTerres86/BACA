DECLARE
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Buscar registro da RDR
  CURSOR cr_craprdr(pr_nmprogra IN craprdr.nmprogra%TYPE) IS
    SELECT t.nrseqrdr
      FROM craprdr t
     WHERE t.NMPROGRA = pr_nmprogra;

  -- Variaveis
  vr_nrseqrdr craprdr.nrseqrdr%TYPE;
  vr_nmprogra craprdr.nmprogra%TYPE;
  vr_nrsolici INTEGER := 10001;

BEGIN
  --RDR
  INSERT INTO craprdr
    (NMPROGRA,
     DTSOLICI)
  VALUES
    ('GRVM0002',
     SYSDATE);

  -- PRM
  FOR rw_crapcop IN cr_crapcop LOOP
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'GRAVAM_DIA_AVISO_SEM_IMG',
       'Parametro de dias para aviso de contrato sem imagem',
       '0');
  
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'GRAVAM_ENV_AUTO_CTR',
       'Parametro de envio automatico de registro de contrato',
       'N');
  
    INSERT INTO crapprm
      (nmsistem,
       cdcooper,
       cdacesso,
       dstexprm,
       dsvlrprm)
    VALUES
      ('CRED',
       rw_crapcop.cdcooper,
       'GRAVAM_SIGLAS_UF_ENV_CTR',
       'Parametro de unidades federativas a enviar o contrato',
       '');
  
    -- PRG
    INSERT INTO CRAPPRG
      (NMSISTEM,
       CDPROGRA,
       DSPROGRA##1,
       DSPROGRA##2,
       DSPROGRA##3,
       DSPROGRA##4,
       NRSOLICI,
       NRORDPRG,
       INCTRPRG,
       CDRELATO##1,
       CDRELATO##2,
       CDRELATO##3,
       CDRELATO##4,
       CDRELATO##5,
       INLIBPRG,
       CDCOOPER,
       QTMINMED)
    VALUES
      ('CRED',
       'GRVM0002',
       'Definições de contratos/imagens',
       ' ',
       ' ',
       ' ',
       500,
       vr_nrsolici,
       1,
       0,
       0,
       0,
       0,
       0,
       1,
       rw_crapcop.cdcooper,
       NULL);
    vr_nrsolici := vr_nrsolici + 1;
    
    -- Codigos para gestao documental
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       98,
       'CDC - FISICO - DIVERSOS;0,00;194;0,00',
       rw_crapcop.cdcooper);
      
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       105,
       'CDC – FISICO – NOVOS;0,00;195;0,00',
       rw_crapcop.cdcooper);
       
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       107,
       'CDC – FISICO – USADOS;0,00;202;0,00',
       rw_crapcop.cdcooper);
    
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       109,
       'CDC – DIGITAL – NOVOS;0,00;193;0,00',
       rw_crapcop.cdcooper);
      
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       110,
       'CDC – DIGITAL – USADOS;0,00;197;0,00',
       rw_crapcop.cdcooper);
       
    INSERT INTO craptab
      (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO,
       TPREGIST,
       DSTEXTAB,
       CDCOOPER)
    VALUES
      ('CRED', 'GENERI', 0, 'DIGITALIZA',
       112,
       'CDC - DIGITAL - DIVERSOS;0,00;192;0,00',
       rw_crapcop.cdcooper);
    
  END LOOP;
  
  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso,
     dstexprm,
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'GRAVAM_DIA_AVISO_SEM_IMG',
     'Parametro de dias para aviso de contrato sem imagem',
     '0');

  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso,
     dstexprm,
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'GRAVAM_ENV_AUTO_CTR',
     'Parametro de envio automatico de registro de contrato',
     'N');

  INSERT INTO crapprm
    (nmsistem,
     cdcooper,
     cdacesso,
     dstexprm,
     dsvlrprm)
  VALUES
    ('CRED',
     0,
     'GRAVAM_SIGLAS_UF_ENV_CTR',
     'Parametro de unidades federativas a enviar o contrato',
     '');

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

  -- CRAPACA
   update crapaca aca 
      set aca.lstparam = 'pr_qterrlot,pr_nrdiaenv,pr_hrenvi01,pr_hrenvi02,pr_hrenvi03,pr_aprvcord,pr_perccber,pr_tipcomun,pr_nrdnaoef,pr_emlnaoef,pr_nrdsemim,pr_flgenaut,pr_siglaufs'
    where aca.nmdeacao = 'GRAVAM_GRAVA_PRM'
      and aca.nmpackag = 'TELA_GRAVAM';

  --Dados para o BACA
  vr_nmprogra := 'GRVM0001';
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr
    INTO vr_nrseqrdr;
  CLOSE cr_craprdr;

  INSERT INTO crapaca
    (nmdeacao,
     nmpackag,
     nmproced,
     lstparam,
     nrseqrdr)
  VALUES
    ('PREP_REGIS_CONTRATO',
     'GRVM0002',
     'pc_prep_registro_contrato_web',
     'pr_nrdconta,pr_nrctrpro,pr_uflicenc',
     vr_nrseqrdr);

  vr_nmprogra := 'GRVM0002';
  OPEN cr_craprdr(pr_nmprogra => vr_nmprogra);
  FETCH cr_craprdr
    INTO vr_nrseqrdr;
  CLOSE cr_craprdr;

  INSERT INTO crapaca
    (nmdeacao,
     nmpackag,
     nmproced,
     lstparam,
     nrseqrdr)
  VALUES
    ('GRAVA_RET_REGIS_CONTRATO',
     'GRVM0002',
     'pc_grava_ret_regis_contrat_web',
     'pr_nrdconta, pr_nrctrpro,pd_idseqbem,pr_idgrvm ,pr_idregis',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('VALIDA_CRITICAS_REGISTRO',
     'GRVM0002',
     'pc_valida_criticas_reg_web',
     'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_tpctrpro,pr_idseqbem,pr_cddopcao,pr_tpinclus',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('VALIDA_INCLUSAO_CONTRATO',
     'GRVM0002',
     'pc_valida_inclusao_contrato',
     'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_tpctrpro,pr_idseqbem,pr_cddopcao,pr_tpinclus',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('VALIDAR_BENS_ESTADOS',
     'GRVM0002',
     'pc_valida_bens_estados_web',
     'pr_cdcooper,pr_nrdconta,pr_nrctremp',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao,
     nmpackag,
     nmproced,
     lstparam,
     nrseqrdr)
  VALUES
    ('GRAVA_ESTADO_REGISTRO',
     vr_nmprogra,
     'pc_grava_estados_web',
     'pr_cdcooper,pr_nrdconta,pr_nrctrpro,pr_idseqbem,pr_cdsituac,pr_dssituac,pr_tipinclu,pr_tpregctr,pr_idgravam,pr_idregist,pr_uflicenc',
     vr_nrseqrdr);

  INSERT INTO crapaca
    (nmdeacao,
     nmpackag,
     nmproced,
     lstparam,
     nrseqrdr)
  VALUES
    ('GERA_PENDENCIAS_REGISTRO',
     vr_nmprogra,
     'pc_gera_pendencias_web',
     'pr_cdcooper,pr_nrdconta,pr_nrctrpro',
     vr_nrseqrdr);

  COMMIT;
END;

