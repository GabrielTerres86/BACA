PL/SQL Developer Test script 3.0
186
declare 
  pr_dtmvtolt  date := to_date('31/08/2020','dd/mm/rrrr');
  pr_dtmvtolt2 date := to_date('31/12/2020','dd/mm/rrrr');
  vr_dsjobnam  VARCHAR2(100):= 'JBCRD_IMPORTA_UTLZ_CARTAO - VIA BACA';

  TYPE typ_reg_utlz_crd IS
    RECORD(dtmvtolt         tbcrd_intermed_utlz_cartao.dtmvtolt%TYPE
           ,nrconta_cartao   tbcrd_intermed_utlz_cartao.nrconta_cartao%TYPE
           ,qttransa_debito  tbcrd_intermed_utlz_cartao.qttransa_debito%TYPE
           ,qttransa_credito tbcrd_intermed_utlz_cartao.qttransa_credito%TYPE
           ,vltransa_debito  tbcrd_intermed_utlz_cartao.vltransa_debito%TYPE
           ,vltransa_credito tbcrd_intermed_utlz_cartao.vltransa_credito%TYPE); 
  TYPE typ_tab_utlz_crd IS
    TABLE OF typ_reg_utlz_crd;
    
   -- Definicao do tipo de tabela para as conta cartao
  TYPE typ_reg_conta_crd IS
    RECORD(cdcooper        crapass.cdcooper%TYPE
           ,nrdconta        crapass.nrdconta%TYPE); 
  TYPE typ_tab_conta_crd IS
    TABLE OF typ_reg_conta_crd INDEX BY VARCHAR2(15);

  vr_tab_utlz_crd  typ_tab_utlz_crd;
  vr_tab_conta_crd typ_tab_conta_crd;     
   
  -- Variaveis de erro
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(500);
  vr_exc_erro  EXCEPTION; -- Erro de programa
     
  CURSOR cr_intermedcrd IS
    SELECT inmedcrd.dtmvtolt
           ,inmedcrd.nrconta_cartao
           ,inmedcrd.qttransa_debito
           ,inmedcrd.qttransa_credito
           ,inmedcrd.vltransa_debito
           ,inmedcrd.vltransa_credito
    FROM tbcrd_intermed_utlz_cartao inmedcrd
    WHERE inmedcrd.dtmvtolt = pr_dtmvtolt or
          inmedcrd.dtmvtolt = pr_dtmvtolt2; 

  -- Busca conta e cooper do cooperado
  CURSOR cr_contacrd IS
    SELECT tbcc.cdcooper
           ,tbcc.nrdconta
           ,tbcc.nrconta_cartao
    FROM tbcrd_conta_cartao tbcc;
  rw_contacrd cr_contacrd%ROWTYPE;
   
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                  ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                  ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                  ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                  ,pr_cdcooper IN VARCHAR2
                                  ,pr_flgsuces IN NUMBER   DEFAULT 1    -- Indicador de sucesso da execução  
                                  ,pr_flabrchd IN INTEGER  DEFAULT 0    -- Abre chamado 1 Sim/ 0 Não
                                  ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                  ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                  ,pr_flreinci IN INTEGER  DEFAULT 0    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
  ) IS
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                           ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                           ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                           ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                           ,pr_dsmensagem    => pr_dscritic
                           ,pr_cdmensagem    => pr_cdcritic
                           ,pr_cdcooper      => NVL(pr_cdcooper,0)
                           ,pr_flgsucesso    => pr_flgsuces
                           ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                           ,pr_texto_chamado => pr_textochd
                           ,pr_destinatario_email => pr_desemail
                           ,pr_flreincidente => pr_flreinci
                           ,pr_cdprograma    => vr_dsjobnam
                           ,pr_idprglog      => vr_idprglog);   
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => 3);                                                             
  END pc_controla_log_batch;

begin  
  -- Armazena os valores em memoria
  OPEN  cr_intermedcrd;
  FETCH cr_intermedcrd BULK COLLECT INTO vr_tab_utlz_crd;     
  CLOSE cr_intermedcrd;

  -- Armazena os dados conta cartao
  FOR rw_contacrd IN cr_contacrd LOOP
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).cdcooper := rw_contacrd.cdcooper;
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).nrdconta := rw_contacrd.nrdconta;                  
  END LOOP;
   
  IF vr_tab_utlz_crd.COUNT = 0 THEN
    vr_dscritic := 'Sem dados para importacao!';
    raise vr_exc_erro;
  ELSE
    FOR idx IN vr_tab_utlz_crd.FIRST .. vr_tab_utlz_crd.LAST LOOP             
      IF vr_tab_conta_crd.EXISTS(vr_tab_utlz_crd(idx).nrconta_cartao) = FALSE THEN                     
         -- Quando não encontrar o cooperado, gera log e continua para o próximo
                vr_cdcritic := 9;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;                        
                -- Log de erro de execucao
                pc_controla_log_batch(pr_dstiplog => 'O'
                                     ,pr_tpocorre => 1
                                     ,pr_cdcricid => 0
                                     ,pr_cdcritic => NVL(vr_cdcritic,0)
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_cdcooper => 3);                                 
                CONTINUE;
             END IF;
             
             BEGIN
               INSERT INTO tbcrd_utilizacao_cartao (
                           dtmvtolt
                           ,nrconta_cartao
                           ,cdcooper
                           ,nrdconta
                           ,qttransa_debito
                           ,qttransa_credito
                           ,vltransa_debito
                           ,vltransa_credito
               ) VALUES (
                           vr_tab_utlz_crd(idx).dtmvtolt
                           ,vr_tab_utlz_crd(idx).nrconta_cartao
                           ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).cdcooper
                           ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).nrdconta
                           ,vr_tab_utlz_crd(idx).qttransa_debito
                           ,vr_tab_utlz_crd(idx).qttransa_credito
                           ,vr_tab_utlz_crd(idx).vltransa_debito
                           ,vr_tab_utlz_crd(idx).vltransa_credito
               );
             EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                    vr_cdcritic := 285;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;
                    
                    -- Log de erro de execucao
                    pc_controla_log_batch(pr_dstiplog => 'O'
                                         ,pr_tpocorre => 4
                                         ,pr_cdcricid => 0
                                         ,pr_cdcritic => NVL(vr_cdcritic,0)
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_cdcooper => 3);                
                    
               WHEN OTHERS THEN
                    vr_cdcritic := 9999;
                    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || SQLERRM;
                    
                    -- Log de erro de execucao
                    pc_controla_log_batch(pr_dstiplog => 'O'
                                         ,pr_tpocorre => 4
                                         ,pr_cdcricid => 0
                                         ,pr_cdcritic => NVL(vr_cdcritic,0)
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_cdcooper => 3);                                               
                 
             END;              
         END LOOP;
   END IF;
   
     COMMIT;
     
     :vr_dscritic := 'SUCESSO';
     -- Log de fim de execucao
     pc_controla_log_batch(pr_dstiplog => 'F'
                           ,pr_flgsuces => 1
                           ,pr_cdcooper => 3);     
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
       
      :vr_dscritic := 'ERRO ' ||nvl(vr_dscritic,' ');      
              -- Log de erro de execucao
        pc_controla_log_batch(pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_cdcooper => 3
                             ,pr_flgsuces => 0);  
end;
0
0
