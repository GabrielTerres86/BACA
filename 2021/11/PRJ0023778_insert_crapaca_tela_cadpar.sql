DECLARE
  vr_rdr NUMBER;
BEGIN
  
  insert into CRAPRDR (NMPROGRA, DTSOLICI)
  values ('TELA_CADPAR',SYSDATE) RETURNING NRSEQRDR INTO vr_rdr;
     
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('IF_HAS_VINCULO_TARIFA', 'TELA_CADPAR', 'pc_if_has_vinculo_tarifa', 'pr_codigoparametro', vr_rdr);
  
  COMMIT;
  
END;
