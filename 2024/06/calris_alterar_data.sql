BEGIN

UPDATE cecred.tbcalris_colaboradores a
   SET a.dhrecebimento = sysdate -1
 WHERE trunc(a.dhrecebimento) = '10/06/2024';

COMMIT;

END;