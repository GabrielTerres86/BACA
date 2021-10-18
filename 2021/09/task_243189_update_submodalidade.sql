BEGIN
  UPDATE gnsbmod
     SET dssubmod = 'Outros emprestimos'
   WHERE cdmodali = '02'
     AND cdsubmod = '99';
  COMMIT;
END;
/