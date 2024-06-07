BEGIN
  INSERT INTO tbcobran_erros_serasa
    (cderro_serasa
    ,dserro_serasa
    ,cdocorre
    ,cdmotivo)
  VALUES
    (900
    ,'CALAMIDADE PUBLICA'
    ,92
    ,'16');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRB0049095 - US889190');
    RAISE;
END;
