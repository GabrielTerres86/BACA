DECLARE
  vr_dsarqlg       CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- Nome do arquivo de log mensal
  vr_dsmasklog     CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
  vr_diretori      CONSTANT VARCHAR2(100) := '/usr/connectSFN/CTC';
  
  -- variáveis
  TYPE vr_tbarq    IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
  vr_tbordarq      vr_tbarq;
  vr_tbarquiv      TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
  vr_dsindex       VARCHAR2(100);
  
  vr_dspesqfl      VARCHAR2(30);
  vr_dsmsglog      VARCHAR2(1000);
  
BEGIN
  
  -- Busca os arquivos para leitura
  vr_dspesqfl := 'APCS%RET';

  -- Buscar todos os arquivos no diretório específico
  GENE0001.pc_lista_arquivos(pr_lista_arquivo => vr_tbarquiv
                            ,pr_path          => vr_diretori||'/recebe' -- Ler pasta RECEBE
                            ,pr_pesq          => vr_dspesqfl);
    
  -- Se não encontrar arquivos
  IF vr_tbarquiv.COUNT() = 0 THEN
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_proc_arquivo_APCS (script)'
                     || ' --> Não foram encontrados arquivos para processar.';
        
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
      
    -- Encerra a execução
    RETURN;
      
  END IF;    
  
  -- Percorrer todos os arquivos encontrados.. para ordena-los pelo nome
  FOR vr_index IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
    vr_tbordarq(vr_tbarquiv(vr_index)) := vr_tbarquiv(vr_index);
  END LOOP;
  
  -- Limpar a tabela dos arquivos 
  vr_tbarquiv.DELETE;
  
  vr_dsindex := vr_tbordarq.FIRST;
  -- Percorrer os arquivos ordenados
  LOOP
    dbms_output.put_line(vr_tbordarq(vr_dsindex)); 
    vr_tbarquiv.EXTEND;
    vr_tbarquiv(vr_tbarquiv.COUNT()) := vr_tbordarq(vr_dsindex);
  
    EXIT WHEN vr_dsindex = vr_tbordarq.LAST();
    vr_dsindex := vr_tbordarq.next(vr_dsindex);
  END LOOP;
  
  -- Percorrer todos os arquivos encontrados
  FOR vr_index IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_proc_arquivo_APCS (script)'
                     || ' --> Processando arquivo: '||vr_tbarquiv(vr_index);
        
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    -- Rotina de monitoramento 
    PCPS0002.pc_monitorar_ret_PCPS(pr_nmarquiv => SUBSTR(vr_tbarquiv(vr_index),0,31)
                                  ,pr_dsdsigla => SUBSTR(vr_tbarquiv(vr_index),0,7)
                                  ,pr_dsdirarq => vr_diretori
                                  ,pr_idarqret => TRUE
                                  ,pr_inprcmnl => TRUE);
    
  END LOOP; -- Arquivos
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- LOGS DE EXECUCAO
    BEGIN
      vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                     || 'PCPS0002.pc_proc_arquivo_APCS (script)'
                     || ' --> ERRO: '||SQLERRM;
        
      -- Incluir log de execução.
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                ,pr_ind_tipo_log => 1
                                ,pr_des_log      => vr_dsmsglog
                                ,pr_nmarqlog     => vr_dsarqlg);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
END;
    
    
    
    
    
    
    
    
    
    
    
    
