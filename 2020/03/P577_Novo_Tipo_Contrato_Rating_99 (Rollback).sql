/*********************************************************************************************
SCRIPT DE ROLLBACK
Função: P577 - Excluir novo dominio TPCTRATO = 99 - Empréstimos/Financiamentos em Regenociação
Criação: 12/03/2020 - Marcelo Elias Gonçalves/AMcom.
*********************************************************************************************/     
DECLARE
  --Variáveis  
  vr_erro      EXCEPTION;
  vr_dscritic  VARCHAR2(1000);
  --
BEGIN   
  BEGIN
    DELETE tbgen_dominio_campo
    WHERE  nmdominio = 'TPCTRATO'
    AND    cddominio = 99 ;  
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao Excluir Registro. Erro: '||SubStr(SQLERRM,1,255);
      RAISE vr_erro;        
  END;  
  
  --Mensagens de Saída
  dbms_output.put_line('Script Executado com Sucesso');
  
  --Salva
  COMMIT;
  --
EXCEPTION
  WHEN vr_erro THEN
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
    Raise_Application_Error(-20000,vr_dscritic); 
  WHEN OTHERS THEN 
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    Raise_application_Error(-20001,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));  
END;
/
