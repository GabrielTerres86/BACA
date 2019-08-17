  -- Novos parâmetros para MANTEM_CONFIG_APL_PROG
  Update crapaca set LSTPARAM='pr_cdcooper_a,pr_cdprodut,pr_flgteimo,pr_fldbparc,pr_vlminimo,pr_flgautoatendimento,pr_flgresgate_prog' where NMDEACAO='MANTEM_CONFIG_APL_PROG';

  -- Novos parâmetros para MNOMPRO
  Update crapaca set LSTPARAM='pr_cddopcao,pr_cdprodut,pr_cdnomenc,pr_dsnomenc,pr_idsitnom,pr_qtmincar,pr_qtmaxcar,pr_vlminapl,pr_vlmaxapl,pr_dscaract' where NMDEACAO='MNOMPRO';

  -- Contratação de plano de apl. programada
  Insert into crapaca (NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM,NRSEQRDR) Values ('LISTA_PRODUTOS_APL_PROG_CONTRATACAO','APLI0008','pc_lista_prods_apl_prog_web','pr_idtippro',v_NRSEQRDR);


  commit;