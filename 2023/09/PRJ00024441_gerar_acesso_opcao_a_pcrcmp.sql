DECLARE

  TYPE Colaboradores IS TABLE OF VARCHAR2(100);
  operador Colaboradores := Colaboradores('F0033180',
                                          'F0034495',
                                          'F0033352',
                                          'F0033031',
                                          'F0030248',
                                          'F0031129',
                                          'f0031979',
                                          'f0030892',
                                          'f0034418');

  vr_operador VARCHAR2(20);

BEGIN

  UPDATE craptel a
     SET a.cdopptel = a.cdopptel || ',A'
        ,a.lsopptel = a.lsopptel || ',MONITOR ARQUIVO'
   WHERE a.nmdatela = 'PCRCMP';

  FOR i IN operador.FIRST .. operador.LAST LOOP
    vr_operador := operador(i);
  
    INSERT INTO crapace
      (nmdatela
      ,cddopcao
      ,cdoperad
      ,nmrotina
      ,cdcooper
      ,nrmodulo
      ,idevento
      ,idambace)
    VALUES
      ('PCRCMP'
      ,'A'
      ,vr_operador
      ,' '
      ,3
      ,1
      ,0
      ,2);
  
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'PRJ0024441');
    RAISE;
  
END;
