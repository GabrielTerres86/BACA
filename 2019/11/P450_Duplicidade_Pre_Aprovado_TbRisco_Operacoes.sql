/*************************************************************************
Função: Corrigir Bug 27617 - Rating - Limite Pré aprovado em duplicidade.
Criação: 28/10/2019 - Marcelo Elias Gonçalves/AMcom.
*************************************************************************/     
DECLARE
  --Cursor para verificar os CPF/CNPJ Base que estão com registro de pre-aprovado duplicados na tbrisco_operacoes
  CURSOR cr_tbrisco_pre IS    
    SELECT a.cdcooper         cdcooper        
          ,a.nrcpfcnpj_base   nrcpfcnpj_base
          ,a.tpctrato         tpctrato
          ,Count(1)           qtde            
    FROM   tbrisco_operacoes  a
    WHERE  a.tpctrato = 68 --Pre-Aprovado
    GROUP BY a.cdcooper         
            ,a.nrcpfcnpj_base
            ,a.tpctrato
    HAVING Count(1) > 1;   --Registro Duplicado
    
  --Variáveis  
  vr_erro              EXCEPTION;
  vr_dscritic          VARCHAR2(1000);
  vr_nrdconta          tbrisco_operacoes.nrdconta%TYPE;
  vr_qt_lido           NUMBER := 0;
  vr_qt_excluido       NUMBER := 0; 
  vr_qt_excluido_hist  NUMBER := 0; 
  --
BEGIN   
  --Para cada Registro duplicado
  FOR rw_tbrisco_pre IN cr_tbrisco_pre LOOP
    --
    --Inclrementa Qtde de Registros Excluidos
    vr_qt_lido  := Nvl(vr_qt_lido,0) + 1;
    --Inicializa Variável
    vr_nrdconta := NULL;
    --
    --Exclui o Registro Sem Nota Rating ou Com Rating mais Antigo
    BEGIN
      DELETE tbrisco_operacoes  a
      WHERE  a.cdcooper       = rw_tbrisco_pre.cdcooper      
      AND    a.nrcpfcnpj_base = rw_tbrisco_pre.nrcpfcnpj_base
      AND    a.nrctremp       = 0
      AND    a.tpctrato       = rw_tbrisco_pre.tpctrato
      AND   (a.inpontos_rating IS NULL OR (a.dtvencto_rating = (SELECT Min(b.dtvencto_rating) 
                                                                FROM   tbrisco_operacoes  b
                                                                WHERE  b.tpctrato       = a.tpctrato
                                                                AND    b.cdcooper       = a.cdcooper
                                                                AND    b.nrctremp       = a.nrctremp
                                                                AND    b.nrcpfcnpj_base = a.nrcpfcnpj_base) AND 0 = (SELECT Count(1) 
                                                                                                                     FROM   tbrisco_operacoes  c
                                                                                                                     WHERE  c.tpctrato = a.tpctrato
                                                                                                                     AND    c.cdcooper       = a.cdcooper
                                                                                                                     AND    c.nrctremp       = a.nrctremp
                                                                                                                     AND    c.nrcpfcnpj_base = a.nrcpfcnpj_base
                                                                                                                     AND    c.inpontos_rating IS NULL)))
      RETURN nrdconta INTO vr_nrdconta;
      
      --Inclrementa Qtde de Registros Excluidos
      vr_qt_excluido := Nvl(vr_qt_excluido,0) + SQL%ROWCOUNT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Excluir Registro Duplicado (Pre-Aprovado) para o CPF/CNPJ Base: '||rw_tbrisco_pre.nrcpfcnpj_base||' | Cooperativa: '||rw_tbrisco_pre.cdcooper||'. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;        
    END;  
    --
    --Exclui os Históricos do Registro excluído acima
    BEGIN
      DELETE tbrating_historicos
      WHERE  cdcooper = rw_tbrisco_pre.cdcooper      
      AND    nrdconta = vr_nrdconta
      AND    tpctrato = rw_tbrisco_pre.tpctrato
      AND    nrctremp = 0;     
      
      --Inclrementa Qtde de Registros de Históricos Excluidos
      vr_qt_excluido_hist := Nvl(vr_qt_excluido_hist,0) + SQL%ROWCOUNT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Excluir Registro Históricos (Pre-Aprovado) para o CPF/CNPJ Base: '||rw_tbrisco_pre.nrcpfcnpj_base||' | Conta: '||vr_nrdconta||' | Cooperativa: '||rw_tbrisco_pre.cdcooper||'. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;        
    END;  
    --
  END LOOP; 
  
  --Mensagens de Saída
  dbms_output.put_line('Script Executado com Sucesso:');
  dbms_output.put_line(Lpad((vr_qt_lido*2),6,' ')     ||' Registros Lidos     (tbrisco_operacoes)');
  dbms_output.put_line(Lpad(vr_qt_excluido,6,' ')     ||' Registros Excluídos (tbrisco_operacoes)');
  dbms_output.put_line(Lpad(vr_qt_excluido_hist,6,' ')||' Registros Excluídos (tbrating_historicos)');
  
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
