BEGIN
  
   INSERT
    INTO craprdr(nmprogra,dtsolici) values ('TELA_CADPAR', SYSDATE);

   INSERT
    INTO crapaca(nmdeacao, 
                 nmpackag, 
                 nmproced, 
                 lstparam, 
                 nrseqrdr) VALUES 
                 ('IF_HAS_VINCULO_TARIFA', 
                  'TELA_CADPAR', 
                  'pc_if_has_vinculo_tarifa', 
                  'pr_codigoParametro', 
                  (select craprdr.nrseqrdr from craprdr where craprdr.nmprogra = 'TELA_CADPAR'));

   commit;
EXCEPTION
  WHEN OTHERS THEN 
    NULL;
end;