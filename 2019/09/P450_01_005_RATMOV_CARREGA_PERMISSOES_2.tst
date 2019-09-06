PL/SQL Developer Test script 3.0
109
/************************************************************************************
Fun��o....: Cadastrar Permiss�es de Acesso (crapace) para a Tela RATMOV, baseado nas
            Permiss�es de Acesso da Tela ATURAT.
           
            Observa��o: O Cadastro da Tela RATMOV (craptel) n�o � necess�rio, pois
                        segundo Guilherme existe outro script para este cadastro.
           
Cria��o...: 02/09/2019 (Marcelo Elias Gon�alves/AMcom).
************************************************************************************/
 
DECLARE
  --Cursor para Buscar Permiss�es de Acesso da tela ATURAT
  CURSOR cr_acessos_aturat IS 
    SELECT 'RATMOV'      nmdatela --Fixo
          ,ace.cddopcao  cddopcao
          ,ace.cdoperad  cdoperad
          ,' '           nmrotina --Fixo
          ,ace.cdcooper  cdcooper
          ,8             nrmodulo --Fixo
          ,0             idevento --Fixo
          ,2             idambace --Fixo
    FROM   craptel tel
          ,crapace ace
          ,crapope ope
          ,crapcop cop
    WHERE  tel.cdcooper = ace.cdcooper
    AND    tel.nmdatela = ace.nmdatela  
    AND    tel.nmrotina = ace.nmrotina
    AND    ace.cdcooper = ope.cdcooper
    AND    ace.cdoperad = ope.cdoperad
    AND    tel.cdcooper = cop.cdcooper
    AND    cop.flgativo = 1          --Somente Cooperativa Ativa
    AND    cop.cdcooper <> 3         --N�o para Central Ailos   
    AND    ope.cdsitope = 1          --Somente Operador Ativo
    AND    tel.nmdatela = 'ATURAT'   --Permiss�es de Acess da Tela ATURAT
    AND    tel.nmrotina = ' '        --Sem Rotina (Sistema grava espa�o)
    AND    ace.cddopcao IN ('C','A') --Somente Consulta e Altera��o
    AND    ace.idambace = 2;         --Somente Ambiente 2
            
  --Vari�veis
  vr_exc_erro    EXCEPTION;
  vr_dscritic    VARCHAR2(1000);
  vr_qtlida      NUMBER := 0;
  vr_qtinserida  NUMBER := 0;
  vr_qtjaexiste  NUMBER := 0;
           
BEGIN  
  
  --Para cada Permiss�o de Acesso da tela ATURAT
  FOR rw_acessos_aturat IN cr_acessos_aturat LOOP
    --Incrementa a Qtde Lida
    vr_qtlida := Nvl(vr_qtlida,0) + 1;

    --Criar Permiss�o de Acesso para tela RATMOV
    BEGIN
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
         (rw_acessos_aturat.nmdatela
         ,rw_acessos_aturat.cddopcao
         ,rw_acessos_aturat.cdoperad
         ,rw_acessos_aturat.nmrotina
         ,rw_acessos_aturat.cdcooper
         ,rw_acessos_aturat.nrmodulo
         ,rw_acessos_aturat.idevento
         ,rw_acessos_aturat.idambace); 
    EXCEPTION
      WHEN Dup_Val_On_Index THEN
        --Incrementa a Qtde J� Existente
        vr_qtjaexiste := Nvl(vr_qtjaexiste,0) + 1;             
      WHEN OTHERS THEN       
       vr_dscritic := 'Erro ao Inserir Permiss�o de Acesso. Cooperativa: '||rw_acessos_aturat.cdcooper||' | Tela: '||rw_acessos_aturat.nmdatela||' | Op��o: '||rw_acessos_aturat.cddopcao||' | Operador: '||rw_acessos_aturat.cdoperad||' | Ambiente: '||rw_acessos_aturat.idambace||'. Erro: '||SubStr(SQLERRM,1,255);
       RAISE vr_exc_erro;  
    END; 
    
    IF SQL%ROWCOUNT > 0 THEN
      --Incrementa a Qtde Inserida
      vr_qtinserida := Nvl(vr_qtinserida,0) + SQL%ROWCOUNT;      
    END IF; 
                 
  END LOOP;
  
  --Salva
  COMMIT;
  
  --Mensagens Sa�da
  dbms_output.put_line('  Resultado:');
  dbms_output.put_line(Lpad(vr_qtlida    ,10,' ')||' Permiss�es de Acesso Lidas na ATURAT.');
  dbms_output.put_line(Lpad(vr_qtjaexiste,10,' ')||' Permiss�es de Acesso J� Existentes na RATMOV.');
  dbms_output.put_line(Lpad(vr_qtinserida,10,' ')||' Permiss�es de Acesso Criadas na RATMOV.');  
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20000,vr_dscritic);
  WHEN OTHERS THEN    
    ROLLBACK;
    vr_dscritic:= 'Erro Geral no Script de Permiss�es de Acesso da Tela RATMOV (com base na tela ATURAT). Erro: '||SubStr(SQLERRM,1,255);
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20001,vr_dscritic);
END;
0
0
