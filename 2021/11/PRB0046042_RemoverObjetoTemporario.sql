-- Remoção de objeto temporário para publicação de objetos em prod em data não programada
BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.calculaRiscoMelhoraCentral';
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/
