


INSERT INTO craprel (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper, periodic, tprelato, inimprel, ingerpdf)
  (SELECT 750, 1, 1, 'EXTRATO DE DESCONTO DE TITULOS', 1, 'Atendimento', 'padrao', 0, crapcop.cdcooper, 'D', 1, 1, 1 FROM crapcop where flgativo = 1);

UPDATE craptel 
   SET cdopptel = cdopptel || ',X',
       lsopptel = ',EXTRATO'
 WHERE nmrotina = 'DSC TITS - BORDERO'
   AND nmdatela = 'ATENDA'
;