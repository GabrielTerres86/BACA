--Dados para o BACA
insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
values('PREP_REGIS_CONTRATO','GRVM0001','pc_prepara_registro_contrato','pr_nrdconta, pr_nrctrpro',463);

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
   'URI para Contrato do GRAVAME',
   '/osb-soa/GarantiaVeiculoRestService/v1/RegistrarContratoGravames');
   
commit;