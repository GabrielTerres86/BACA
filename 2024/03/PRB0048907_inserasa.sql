BEGIN
  UPDATE tbcobran_param_negativacao
  SET hrenvio_arquivo = to_number(to_char(to_date('0800', 'hh24mi'), 'sssss'));
  UPDATE crapcob cob
  SET cob.inserasa = 1
   WHERE 1 = 1
     AND (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN
((8,82475920,107004,125)
,(8,82475920,107004,126)
,(8,82475920,107004,127)
,(8,82475920,107004,128)
,(8,82475920,107004,129)
,(9,84606444,108004,1)
,(9,84606444,108004,2)
,(9,84606444,108004,3)
,(9,84606444,108004,4)
,(9,84606444,108004,5));
  UPDATE crapcob cob
  SET cob.inserasa = 2
   WHERE 1 = 1
     AND (cob.cdcooper, cob.nrdconta, cob.nrcnvcob, cob.nrdocmto) IN
((8,82475920,107004,130)
,(8,82475920,107004,131)
,(8,82475920,107004,132)
,(8,82475920,107004,133)
,(8,82475920,107004,134)
,(8,82475920,107004,135)
,(9,84606444,108004,6)
,(9,84606444,108004,7)
,(9,84606444,108004,8)
,(9,84606444,108004,9)
,(9,84606444,108004,10));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441 PRB0048907');
    ROLLBACK;
    RAISE;
END;
