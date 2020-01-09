--Dados para o BACA
insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values('PREP_REGIS_CONTRATO','GRVM0001','pc_prep_registro_contrato_web','pr_nrdconta, pr_nrctrpro',463);

insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values('GRAVA_RET_REGIS_CONTRATO','GRVM0002','pc_grava_ret_regis_contrat_web','pr_nrdconta, pr_nrctrpro,pd_idseqbem,pr_idgrvm ,pr_idregis',1845);

insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values('GRAVA_RET_IMG_CONTRATO','GRVM0002','pc_grava_ret_img_contrat_web','pr_nrdconta,pr_nrctrpro,pd_idseqbem,pr_idgrvm ,pr_idregis',1845);

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