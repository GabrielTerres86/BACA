BEGIN

UPDATE cecred.tbcalris_fornecedores a
   SET a.dhalteracao = sysdate -1
    , a.dhrecebimento = sysdate - 1
 WHERE trunc(a.dhrecebimento) = to_date('16/06/2024', 'dd/mm/yyyy');

COMMIT;

END;