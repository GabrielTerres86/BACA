BEGIN

UPDATE cecred.tbcalris_colaboradores a
   SET a.dhalteracao = sysdate -1
    , a.dhrecebimento = sysdate - 1
 WHERE trunc(a.dhrecebimento) = to_date('13/06/2024', 'dd/mm/yyyy');

COMMIT;

END;