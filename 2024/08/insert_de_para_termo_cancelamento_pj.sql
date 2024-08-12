begin
  INSERT INTO CECRED.CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('IMPRIME_TERMO_CANCELA_SEGURO_PRST_PJ', 'SEGU0004', 'pc_imp_termo_cancel_seg_pres', 'pr_cdcooper,pr_nrdconta,pr_nrctrseg', 2564);
  
  INSERT INTO CECRED.TBSEG_HISTORICO_RELATORIO (CDACESSO, DSTEXPRM, DSVLRPRM, DTINICIO, FLTPCUSTEIO, TPPESSOA)
  VALUES ('TERMO_CANCELAMENTO_PJ', 'Relatório Prestamista referente ao termo de cancelamento do seguro prestamista', 'termo_cancelamento_pj.jasper', to_date('01/08/2024','dd/mm/yyyy'), 0, 2);
  
  COMMIT;
end;