BEGIN

UPDATE cecred.tbcalris_colaboradores a
   SET a.dhalteracao = sysdate -1
    , a.dhrecebimento = sysdate - 1
 WHERE trunc(a.dhrecebimento) = to_date('12/06/2024', 'dd/mm/yyyy');

COMMIT;

END;