-- Remo��o de objeto tempor�rio para publica��o de objetos em prod em data n�o programada
BEGIN
  EXECUTE IMMEDIATE 'DROP PROCEDURE GESTAODERISCO.calculaRiscoMelhoraCentral';
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/
