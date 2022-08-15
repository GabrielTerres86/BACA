BEGIN
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('PLATAFORMA_API_CON_EXTRAT_UNIF_PIX','TELA_ATENDA_API','pc_consulta_extrato_unificado_pix','pr_nrdconta,pr_cdcooper', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_API'));


insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('PLATAFORMA_API_GRAVA_EXTRAT_UNIF_PIX','TELA_ATENDA_API','pc_altera_flag_unificacao_pix','pr_nrdconta,pr_cdcooper,pr_unifica', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_ATENDA_API'));
 
 COMMIT;
                  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
