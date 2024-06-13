BEGIN

UPDATE cecred.tbcalris_colaboradores a
   SET a.dhrecebimento = sysdate -1
 WHERE trunc(a.dhrecebimento) = to_date('10/06/2024', 'dd/mm/yyyy');

COMMIT;

END;