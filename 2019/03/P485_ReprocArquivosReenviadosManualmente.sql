DECLARE
  vr_dsarqlg         CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log'; -- Nome do arquivo de log mensal
  vr_dsmasklog       CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
  vr_qtminuto        CONSTANT NUMBER       := (5/24/60); -- Equivalente à 5 minutos
  vr_qtxvsegundos    CONSTANT NUMBER       := (15/24/60/60); -- Equivalente à 15 segundos
  vr_nrispb_emissor  CONSTANT VARCHAR2(8)  := 05463212;  -- ISPB Ailos 
  vr_nrispb_destina  CONSTANT VARCHAR2(8)  := '02992335'; -- ISPB CIP
  vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS'; -- Formato campo dataHora
  vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';    -- Formato campo data
  vr_dsdominioerro   CONSTANT VARCHAR2(20) := 'ERRO_PCPS_CIP'; -- Dominio padrão para erros PCPS
  vr_dsmotivoreprv   CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';
  vr_dsmotivocancel  CONSTANT VARCHAR2(30) := 'MOTVCANCELTPORTDDCTSALR';
  vr_dsmotivoaceite  CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_dsmotivoconttc  CONSTANT VARCHAR2(30) := 'MOTVCONTTC'; 
  vr_dsmotivoencerr  CONSTANT VARCHAR2(30) := 'MOTVENCRMNTCONTTC'; 
  vr_dsmotivoresrep  CONSTANT VARCHAR2(30) := 'MOTVRESPCONTTCREPVD'; 
  vr_dsmotivoresapv  CONSTANT VARCHAR2(30) := 'MOTVRESPCONTTCAPROVD';
  
  vr_nmarquiv    VARCHAR2(50);
  vr_dsmsglog    VARCHAR2(2000);
  
  FUNCTION fn_remove_xmlns(pr_dsxmlarq IN CLOB) RETURN CLOB IS

    -- Variáveis
    vr_dsremove  VARCHAR2(1000);
    vr_nrposant  NUMBER;
    vr_nrposdep  NUMBER;
  
  BEGIN
    
    -- Guarda a posição de início do xmlns
    vr_nrposant := INSTR(pr_dsxmlarq,'xmlns=');
    
    -- Guarda a posição do primeiro ">" após o xmlns
    vr_nrposdep := INSTR(pr_dsxmlarq,'>',vr_nrposant);
    
    -- Separar o tag xmlns
    vr_dsremove := SUBSTR(pr_dsxmlarq, vr_nrposant, (vr_nrposdep - vr_nrposant));

    -- Remover e retornar
    RETURN REPLACE(pr_dsxmlarq,vr_dsremove,NULL);

  END fn_remove_xmlns;
  
  PROCEDURE pc_proc_ERR_APCS101(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    
    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_envia   T
       SET t.dsdominio_motivo = vr_dsdominioerro
         , t.cdmotivo         = vr_cderrret
         , t.idsituacao       = 1 -- Retornar para A Solicitar, pois o erro foi no arquivo 
         , t.nmarquivo_retorno= vr_nmarquiv -- Para identificar a última ocorrencia de problema
     WHERE t.idsituacao       = 2 -- Atualizar apenas as que ainda estão como solicitadas
       AND t.nmarquivo_envia  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS101. ' ||SQLERRM;
  END pc_proc_ERR_APCS101;
  
  PROCEDURE pc_proc_ERR_APCS103(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
    
    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_recebe   T
       SET t.dtretorno           = NULL
         , t.nmarquivo_resposta  = vr_nmarquiv
         -- Não deve mexer no motivo, pois será reenviado
         --, t.dsdominio_motivo    = vr_dsdominioerro
         --, t.cdmotivo            = vr_cderrret
     WHERE t.nmarquivo_resposta  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS103. ' ||SQLERRM;
  END pc_proc_ERR_APCS103;
  
  PROCEDURE pc_proc_ERR_APCS105(pr_dsxmlarq  IN CLOB          --> Conteúdo do arquivo
                               ,pr_dscritic OUT VARCHAR2) IS  --> Descricao erro
   
    -- CURSORES
    -- Retorna o código do erro
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    
    -- Variáveis
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
    
  BEGIN
    
    -- Remover o xmlns do arquivo
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
  
    -- Percorrer todas as aprovações retornadas
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
                         
    -- Se não encontrar dados
    IF cr_ret_erro%NOTFOUND THEN
      -- Crítica
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      
      -- Fechar o cursor
      CLOSE cr_ret_erro;
    
      -- Encerrar a rotina
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_ret_erro;
    
    -- Remover o "_ERR" da informação do nome do arquivo
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    -- ATUALIZAR TODOS OS REGISTROS QUE FORAM ENVIADOS NO ARQUIVO 
    UPDATE tbcc_portabilidade_envia   T
       SET t.idsituacao       = 5 -- A Cancelar
         , t.nmarquivo_envia  = NULL
         , t.dtretorno        = SYSDATE
     WHERE t.nmarquivo_envia  = vr_nmarqenv;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS105. ' ||SQLERRM;
  END pc_proc_ERR_APCS105;
  
  
  PROCEDURE pc_monitorar_ret_PCPS(pr_nmarquiv  IN VARCHAR2
                                 ,pr_dsdsigla  IN crapscb.dsdsigla%TYPE
                                 ,pr_dsdirarq  IN crapscb.dsdirarq%TYPE) IS
    
    -- Tabela para receber arquivos lidos no unix
    -- Variáveis
    vr_tbarquiv    TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_dthrexec    TIMESTAMP;
    vr_jobnames    VARCHAR2(100);
    vr_dsdplsql    VARCHAR2(10000);
    vr_idarqPRO    BOOLEAN;
    vr_idarqERR    BOOLEAN;
    vr_idarqRET    BOOLEAN;
    vr_nmarqPRO    VARCHAR2(50);
    vr_nmarqERR    VARCHAR2(50);
    vr_nmarqRET    VARCHAR2(50);

    vr_dsarqLOB    CLOB; -- Dados descriptografados do arquivo
    
    -- Variável de críticas
    vr_dsmsglog    VARCHAR2(1000);
    vr_dscritic    VARCHAR2(10000);
    vr_typsaida    VARCHAR2(10);

    -- Tratamento de erros
    vr_exc_erro    EXCEPTION;
    
  BEGIN
    
    -- Buscar os arquivos
    BEGIN    
      GENE0001.pc_lista_arquivos(pr_lista_arquivo => vr_tbarquiv
                                ,pr_path          => pr_dsdirarq||'/recebe' -- Ler pasta RECEBE
                                ,pr_pesq          => pr_nmarquiv||'%');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao buscar arquivos('||pr_dsdirarq||'/recebe): '||SQLERRM;
        RAISE vr_exc_erro;
    END;    
      
    -- Inicializar as variáveis de controle.. a execução é feita com base em variáveis de controle
    -- pois pode ocorrer de a mesma execução encontrar o PRO e o RET
    vr_idarqPRO := FALSE;
    vr_idarqERR := FALSE;
    vr_idarqRET := FALSE;
    vr_nmarqPRO := NULL;
    vr_nmarqERR := NULL;
    vr_nmarqRET := NULL;
      
    -- Percorrer os arquivos retornados
    FOR ind IN vr_tbarquiv.FIRST..vr_tbarquiv.LAST LOOP
        
      -- Verifica se foi encontrado retorno de um arquivo de Erro "_ERR"
      IF    UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_ERR') THEN
        -- Indica que foi encontrado o arquivo ERR
        vr_idarqERR := TRUE;
        vr_nmarqERR := vr_tbarquiv(ind);

      -- Verifica se foi encontrado retorno de arquivo de Protocolo "_PRO"
      ELSIF UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_PRO') THEN
        -- Indica que foi encontrado o arquivo PRO
        vr_idarqPRO := TRUE;
        vr_nmarqPRO := vr_tbarquiv(ind);
          
      -- Verifica se foi encontrado o arquivo de retorno "_RET"
      ELSIF UPPER(vr_tbarquiv(ind)) = UPPER(pr_nmarquiv||'_RET') THEN
        -- Indica que foi encontrado o arquivo RET
        vr_idarqRET := TRUE;
        vr_nmarqRET := vr_tbarquiv(ind);
        
      ELSE
          
        -- Gerar crítica informando que foi encontrado um arquivo que não estava sendo esperando
        vr_dscritic := 'Erro ao buscar arquivos('||pr_dsdirarq||'/recebe): '||SQLERRM;
        RAISE vr_exc_erro;          
        
      END IF;
        
        
    END LOOP;
     
    -- Se encontrar o arquivo de ERRO
    IF vr_idarqERR THEN
        
      -- LOGS DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Iniciando processamento do arquivo: '||vr_nmarqERR;
          
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      -- Executar a descriptografia do arquivo
      PCPS0003.PC_LEITURA_ARQ_PCPS(pr_nmarqori => pr_dsdirarq||'/recebe/'||vr_nmarqERR
                                  ,pr_nmarqout => pr_dsdirarq||'/recebidos/'||vr_nmarqERR||'.xml'
                                  ,pr_dscritic => vr_dscritic);
      -- Em caso de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Carregar o conteúdo extraído do arquivo criptografado
      vr_dsarqLOB := PCPS0001.fn_arq_utf_para_clob(pr_caminho => pr_dsdirarq||'/recebidos'
                                              ,pr_arquivo => vr_nmarqERR||'.xml');  -- XML extraído
        
      -- Chama a rotina para processamento do arquivo de erro
      CASE pr_dsdsigla
        WHEN 'APCS101' THEN
          -- Processar retorno do arquivo
          pc_proc_ERR_APCS101(pr_dsxmlarq => vr_dsarqLOB
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS103' THEN
          -- Processar retorno do arquivo
          pc_proc_ERR_APCS103(pr_dsxmlarq => vr_dsarqLOB
                             ,pr_dscritic => vr_dscritic);
        WHEN 'APCS105' THEN
          -- Processar retorno do arquivo
          pc_proc_ERR_APCS105(pr_dsxmlarq => vr_dsarqLOB
                             ,pr_dscritic => vr_dscritic);
        ELSE
          vr_dscritic := 'Rotina não especificada para processar arquivos: '||pr_dsdsigla;
          RAISE vr_exc_erro;
      END CASE;
                         
      -- Se houver retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Devemos movê-lo para a pasta envia
      GENE0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirarq||'/recebe/'||vr_nmarqERR||' '||pr_dsdirarq||'/recebidos/'||vr_nmarqERR
                                 ,pr_typ_saida   => vr_typsaida
                                 ,pr_des_saida   => vr_dscritic);
      
      -- Testa se a saída da execução acusou erro
      IF vr_typsaida = 'ERR' THEN
        -- LOG DE EXECUCAO
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_monitorar_ret_PCPS'
                         || ' --> Erro ao copiar arquivo para pasta RECEBIDOS: '||vr_nmarqERR;
            
          -- Incluir log de execução.
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
          
        -- Não irá estourar critica por ser um arquivo de retorno e pode ser copiado manualmente
        vr_dscritic := NULL;
      END IF;
        
      -- LOGS DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Concluido processamento do arquivo: '||vr_nmarqERR;
          
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
     
    END IF; -- Fim processamento arquivo ERR
      
      
    -- Efetivar processamento realizado
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Erro ao monitorar: '||vr_nmarqERR||'. '||vr_dscritic;
            
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      raise_application_error(-20001, vr_dscritic);
    WHEN OTHERS THEN
      ROLLBACK;
      
      -- Guardar erro
      vr_dscritic := SQLERRM;
      
      -- LOG DE EXECUCAO
      BEGIN
        vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_monitorar_ret_PCPS'
                       || ' --> Erro ao monitorar: '||vr_nmarqERR||'. '||vr_dscritic;
            
        -- Incluir log de execução.
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3 -- LOG da Central
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dsmsglog
                                  ,pr_nmarqlog     => vr_dsarqlg);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      raise_application_error(-20002, 'Erro na rotina PC_MONITORAR_RET_PCPS: '||SQLERRM);
	END pc_monitorar_ret_PCPS;
  
BEGIN
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS101_05463212_20190226_00417';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS101'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS101_05463212_20190226_00419';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS101'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS101_05463212_20190226_00420';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS101'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS105_05463212_20190226_00027';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS105'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS105_05463212_20190226_00028';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS105'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS101_05463212_20190226_00418';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS101'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  BEGIN
    vr_nmarquiv := 'APCS103_05463212_20190226_00101';
    pc_monitorar_ret_pcps(pr_nmarquiv => vr_nmarquiv
                         ,pr_dsdsigla => 'APCS103'
                         ,pr_dsdirarq => '/usr/connectSFN/CTC');
  EXCEPTION
    WHEN OTHERS THEN
      -- Registrar mensagem no log e pular para o próximo registro
      BEGIN
        vr_dsmsglog := to_char(SYSDATE,vr_dsmasklog)||' - '
                       || 'ARQUIVOS REENVIADOS PARA CIP'
                       || ' --> '||SQLERRM;
          
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
  ----------------------------------------------------------------------------
  
  COMMIT;
  
END;
