BEGIN
  
UPDATE cecred.tbseg_historico_relatorio
   SET TPPESSOA = 2,
       CDACESSO = 'PROP_PRST_CONTRB_PJ_1',
       DSTEXPRM = 'Relatório Prestamista Contributário PJ'
 WHERE IDHISTORICO_RELATORIO = 9;

COMMIT;
END;
