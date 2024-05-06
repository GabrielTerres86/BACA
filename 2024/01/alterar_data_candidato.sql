BEGIN

UPDATE tbcalris_colaboradores x
   SET x.dhrecebimento = x.dhrecebimento - 1
     , x.dhalteracao = x.dhalteracao - 1
 WHERE x.idcalris_colaborador IN (58469, 58468);
COMMIT;

END;