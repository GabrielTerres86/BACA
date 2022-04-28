BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     '0',
     'RECUSA_SEG_CONTR_SEMANAL',
     'Nome do arquivo de recusa semanal para seguro prestamista contributario',
     'CONTRIBUTARIO_AILOS_ddmmaaaa_Relatorio_STATUS.txt');
  COMMIT;
END;
/
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     '0',
     'RECUSA_SEG_CONTR_MENSAL',
     'Nome do arquivo de recusa semanal para seguro prestamista contributario',
     '495_aaaammdd_RecusasPrestamistaMensal_Contributario.txt');
  COMMIT;
END;
/
