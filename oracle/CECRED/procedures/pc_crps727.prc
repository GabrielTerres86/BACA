CREATE OR REPLACE PROCEDURE CECRED.pc_crps727(pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /*..............................................................................

    Programa: pc_crps727                      
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odirlei Busana - AMcom
    Data    : Janeiro/2018                  Ultima Atualizacao : 24/01/2018

    Dados referente ao programa:

    Frequencia : Mensal (JOB).
    Objetivo   : Monitorar arrecadacao Bancoob

    Alteracoes : 
  ..............................................................................*/

  --------------------- ESTRUTURAS PARA OS RELATÓRIOS ---------------------

  ------------------------------- VARIAVEIS -------------------------------

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  
  -- Auxiliares para o processamento 
  vr_vltotfat     NUMBER;
  vr_vlgarbcb     crapcop.vlgarbcb%TYPE;
  vr_pergabcb     NUMBER;
  
  vr_dsmsggar     VARCHAR2(4000);
  vr_dsdestin     VARCHAR2(400);
  vr_dsdcorpo     VARCHAR2(4000);
  vr_dsassunt     VARCHAR2(400);
  
  
  -- Código do programa
  vr_cdprogra           CONSTANT crapprg.cdprogra%TYPE := 'CRPS727';
  vr_nomdojob           CONSTANT VARCHAR2(30)          := 'JBCONV_MONIT_ARREC_BANCOOB';
  vr_flgerlog           BOOLEAN;
  
  ---------------------------------- CURSORES  ----------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
          ,cop.nmrescop
          ,cop.vlgarbcb
      FROM crapcop cop
     WHERE cop.flgativo = 1  -- Somente ativas
       ORDER BY cdcooper;

  -- Buscar faturas
  CURSOR cr_craplft(pr_cdcooper crapcop.cdcooper%type
                   ,pr_dtmvtolt craplft.dtvencto%type) IS
    SELECT COUNT(lft.vllanmto) qtlanmto,
           SUM(lft.vllanmto) vllanmto
      FROM craplft lft,
           crapcon con
     WHERE lft.cdcooper = con.cdcooper       
       AND lft.cdempcon = con.cdempcon
       AND lft.cdsegmto = con.cdsegmto
       AND lft.cdhistor = con.cdhistor
       AND lft.cdcooper = pr_cdcooper
       AND lft.insitfat = 1
       AND lft.dtvencto = pr_dtmvtolt
       AND con.tparrecd = 2;
  
  ------------------------------- REGISTROS -------------------------------
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------   
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2,
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        
    END pc_controla_log_batch;
    
   
  BEGIN
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'I');
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN

      CLOSE btch0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;

    FOR rw_crapcop IN cr_crapcop LOOP    
      
      --> armazenar valor de garantia para calculo do percentual
      IF rw_crapcop.cdcooper = 3 THEN            
        vr_vlgarbcb := rw_crapcop.vlgarbcb;      
      END IF;
      
      -- Buscar faturas
      FOR rw_craplft IN cr_craplft( pr_cdcooper => rw_crapcop.cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.Dtmvtocd) LOOP
        
        -- Acumular valores de fatura pagas em todas as coops
        vr_vltotfat := nvl(vr_vltotfat,0) + nvl(rw_craplft.vllanmto,0);
        
      END LOOP;                                    
        
    END LOOP; --> Fim loop CRAPCOP
    
    IF vr_vlgarbcb > 0 THEN
    
      --> Calcular percentual da garantia atingido
      vr_pergabcb := (vr_vltotfat * 100) / vr_vlgarbcb;
      
      --> Validar percentual de atingimento da garantia
      vr_dsmsggar := NULL;
      IF vr_pergabcb >= 100 THEN
        vr_dsmsggar := 'Garantia para arrecadação de convênios BANCOOB está comprometida em <b>100%</b>,</br>'||
                       'Deve-se realizar um aporte financeiro imediatamente.';
      ELSIF vr_pergabcb >= 90 THEN
        vr_dsmsggar := 'Garantia para arrecadação de convênios BANCOOB está comprometida em <b>90%</b>,</br> '||
                       'quando alcançar 100% a liquidação no BANCOOB será interrompida. Deve-se realizar um '||
                       'aporte financeiro maior.';
      ELSIF vr_pergabcb >= 80 THEN
        vr_dsmsggar := 'Garantia para arrecadação de convênios BANCOOB está comprometida em <b>80%</b>.';
      END IF;
      
      --> caso atingiu algum percentual definido, deve gerar alerta
      IF vr_dsmsggar IS NOT NULL THEN
        --> Buscar email do destinatario.
        vr_dsdestin := gene0001.fn_param_sistema( pr_nmsistem => 'CRED', 
                                                  pr_cdcooper => 3, 
                                                  pr_cdacesso => 'EMAIL_ALERT_BANCOOB');
        
        vr_dsdcorpo := '</br> Atenção: '||vr_dsmsggar||'</br>';
        vr_dsassunt := 'Garantia para arrecadação de convênios BANCOOB comprometida';
        
        gene0003.pc_solicita_email( pr_cdcooper    => 3,
                                    pr_cdprogra    => vr_cdprogra, 
                                    pr_des_destino => vr_dsdestin, 
                                    pr_des_assunto => vr_dsassunt, 
                                    pr_des_corpo   => vr_dsdcorpo,
                                    pr_des_anexo   => NULL,
                                    pr_flg_enviar  => 'S', 
                                    pr_des_erro    => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;      
        END IF;
      END IF; 
      
    END IF; --> Fim IF vr_vlgarbcb > 0 
    --> Fim Validacao de Valor de Garantia
       
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------                                                     
  
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'F');
    

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    vr_dscritic := SQLERRM;                           
    --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);
    pr_dscritic := vr_dscritic;                      
    -- Efetuar rollback
    ROLLBACK;
    raise_application_error(-20500,vr_dscritic);
End pc_crps727;
/
