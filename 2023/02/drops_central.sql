DECLARE
  PROCEDURE apagar(comando IN VARCHAR2) IS
  BEGIN
   EXECUTE IMMEDIATE comando;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
  END;

BEGIN
  apagar('DROP PROCEDURE GESTAODERISCO.obterVencParcelas');
  commit;
EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
END;
