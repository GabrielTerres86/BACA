BEGIN
  
UPDATE cecred.tbseg_historico_relatorio
   SET TPPESSOA = 2,
       CDACESSO = 'PROP_PRST_CONTRB_PJ_1',
       DSTEXPRM = 'Relat�rio�Prestamista�Contribut�rio PJ'
 WHERE IDHISTORICO_RELATORIO = 9;

COMMIT;
END;
