DECLARE
  
  vr_dscritic      VARCHAR2(2000);

BEGIN
 
  BEGIN
    UPDATE craptel tel
       SET tel.cdopptel = tel.cdopptel||',Z'
         , tel.lsopptel = tel.lsopptel||',ATL.CADAST'
     WHERE tel.nmdatela = 'CONTAS' 
       AND tel.nmrotina = 'IDENTIFICACAO';
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro ao alterar opções ATENDA-IDENTIFICACAO: '||SQLERRM);
  END;

  COMMIT;
  --ROLLBACK;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000,'ERRO SCRIPT ACESSOS: '||SQLERRM);
END;
