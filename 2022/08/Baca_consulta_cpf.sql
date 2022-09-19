BEGIN
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('PLATAFORMA_API_CON_CPFCNPJ','TELA_ATENDA_API','pc_consulta_cpfcnpj_pix','pr_nrdconta,pr_cdcooper', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_API'));
 COMMIT;
                  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
