BEGIN

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('CONSULTA_DEVOLUCAO', 'TELA_MANPRT', 'pc_consulta_devolucao', 'pr_dtinicial,pr_dtfinal,pr_vlinicial,pr_vlfinal,pr_nrregist,pr_nriniseq', 1284);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('CONSULTA_RETORNO', 'TELA_MANPRT', 'pc_consulta_retorno', 'pr_cdcooperativa,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_nprotcra,pr_flstatus,pr_idcidade,pr_cdestado,pr_nrregist,pr_nriniseq', 1284);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('EXPORTA_CONSULTA_RETORNO', 'TELA_MANPRT', 'pc_exporta_consulta_retornos', 'pr_cdcooperativa,pr_nrdconta,pr_dtinicial,pr_dtfinal,pr_nprotcra,pr_flstatus,pr_idcidade,pr_cdestado,pr_nrregist,pr_nriniseq', 1284);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('EXPORTA_CONSULTA_DEVOLUCAO', 'TELA_MANPRT', 'pc_exporta_consulta_devolucao', 'pr_dtinicial,pr_dtfinal,pr_vlinicial,pr_vlfinal,pr_nrregist,pr_nriniseq', 1284);


-- Test statements here
  FOR rec IN (SELECT cdcooper, cdhistor FROM craphis a
              WHERE cdhistor IN (3001, 3002, 3003, 3004, 3006, 3008)
              AND NOT EXISTS (SELECT 1 FROM crapthi b
                              WHERE a.cdcooper = b.cdcooper
                                AND a.cdhistor = b.cdhistor ) ) LOOP

    insert into crapthi (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    values (rec.cdhistor, 'AIMARO', 0.00, rec.cdcooper);
    
    insert into crapthi (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    values (rec.cdhistor, 'CAIXA', 0.00, rec.cdcooper);
    
    insert into crapthi (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    values (rec.cdhistor, 'INTERNET', 0.00, rec.cdcooper);

    insert into crapthi (CDHISTOR, DSORIGEM, VLTARIFA, CDCOOPER)
    values (rec.cdhistor, 'CASH', 0.00, rec.cdcooper);

  END LOOP;
  
COMMIT;

END;   
