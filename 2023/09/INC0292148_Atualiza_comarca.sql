DECLARE
BEGIN
  UPDATE cecred.CRAPMUN MUN
     SET MUN.CDCOMARC = 2708006
   WHERE MUN.CDUFIBGE = 27
     AND MUN.CDCIDADE = 2819;

  UPDATE cecred.crapsqu squ
     SET squ.nrseqatu = 5
   WHERE UPPER(squ.nmtabela) = UPPER('CRAPMUN')
     AND UPPER(squ.nmdcampo) = UPPER('SQARQREM')
     AND UPPER(squ.dsdchave) = UPPER('085;2708006');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sistema.excecaointerna(pr_cdcooper => 3, pr_compleme => 'INC0292148');
    RAISE;
END;
