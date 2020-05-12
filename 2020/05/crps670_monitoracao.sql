BEGIN
  INSERT INTO crapprm
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
  VALUES
    ('CRED'
    ,0
    ,'CRPS670_MONITORACAO'
    ,'Controle com última data de execução do PC_CRPS670'
    ,trunc(to_char(SYSDATE - 1
                  ,'DD/MM/YYYY')));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    pc_internal_exception(pr_compleme => 'PC_CRPS670');
END;
