DECLARE
  vr_seq_hist cecred.tbseg_historico_relatorio.idhistorico_relatorio%TYPE;
BEGIN
  INSERT INTO CECRED.CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES ('IMPRIME_TERMO_CANCELA_SEGURO_PRST_PJ', 'SEGU0004', 'pc_imp_termo_cancel_seg_pres', 'pr_cdcooper,pr_nrdconta,pr_nrctrseg', (SELECT NRSEQRDR FROM CECRED.CRAPRDR WHERE NMPROGRA = 'SEGU0004'));
  
  SELECT nvl(MAX(t.idhistorico_relatorio),0)+1
    INTO vr_seq_hist
    FROM cecred.tbseg_historico_relatorio t;
  
  INSERT INTO CECRED.TBSEG_HISTORICO_RELATORIO (IDHISTORICO_RELATORIO, CDACESSO, DSTEXPRM, DSVLRPRM, DTINICIO, FLTPCUSTEIO, TPPESSOA)
  VALUES (vr_seq_hist, 'TERMO_CANCELAMENTO_PJ', 'Relatório Prestamista referente ao termo de cancelamento do seguro prestamista', 'termo_cancelamento_pj.jasper', to_date('01/08/2024','dd/mm/yyyy'), 0, 2);
  
  COMMIT;
END;