CREATE OR REPLACE PROCEDURE CECRED.pc_crps704 (pr_cdcooper IN crapcop.cdcooper%TYPE ) IS   --> Cooperativa solicitada                                              
  /* .............................................................................

     Programa: pc_crps704 (Fontes/crps704.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odirlei Busana - AMcom
     Data    : Mar�o/2016                     Ultima atualizacao: 08/11/2016

     Dados referentes ao programa:

     Frequencia: Executado via Job - Primeira segunda do m�s
     Objetivo  : Enviar cancelamento das propostas que ser�o excluidas pelo proceso de limpeza

     Alteracoes: 
     
     08/11/2016 - #551196 padronizar os nomes do job por produto e monitorar a sua 
                  execu��o em log (Carlos)

  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- C�digo do programa
  vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS704';
  vr_cdcooper   NUMBER  := 3;

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = nvl(NULLIF(pr_cdcooper,0),cop.cdcooper) --> buscar todas as coops se for coop 0
       AND cop.flgativo = 1
     ORDER BY cop.cdcooper;

  -- Cursor gen�rico de calend�rio
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- buscar nome do programa
  CURSOR cr_crapprg IS
    SELECT lower(crapprg.dsprogra##1) dsprogra##1
      FROM crapprg 
     WHERE cdcooper = vr_cdcooper
       AND cdprogra = vr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;
  
  -- Cadastro auxiliar dos emprestimos com movimento a mais de 4 meses
  -- que n�o estejam cadastrados na crapepr
  CURSOR cr_crawepr ( pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN DATE) IS
    SELECT crawepr.cdcooper 
          ,crawepr.nrdconta
          ,crawepr.nrctremp
          ,crawepr.cdagenci
      FROM crawepr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.dtenvest IS NOT NULL
       AND crawepr.dtmvtolt < pr_dtmvtolt --data do movimento
       AND NOT EXISTS ( SELECT 1
                          FROM crapepr
                         WHERE crapepr.cdcooper = crawepr.cdcooper
                           AND crapepr.nrdconta = crawepr.nrdconta
                           AND crapepr.nrctremp = crawepr.nrctremp)
     ORDER BY crawepr.cdcooper,
              crawepr.nrdconta,
              crawepr.nrctremp;

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  vr_qtmeslim     INTEGER := 0;
  vr_dtlimepr     DATE;
  vr_qtderros     NUMBER  := 0;
  vr_qtsucess     NUMBER  := 0;
  
  -- Nome do arquivo de limpeza
  vr_nmarqlmp VARCHAR2(500) := 'arquivos/.limpezaok';
  -- Nome do diretorio da cooperativa
  vr_nmdireto VARCHAR2(500);
  
  --------------------------- SUBROTINAS INTERNAS --------------------------

  vr_nomdojob    VARCHAR2(40) := 'JBEPR_CANCELA_PROPOSTA';
  vr_flgerlog    BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    --> Controlar gera��o de log de execu��o dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
  END pc_controla_log_batch;
BEGIN

  --------------- VALIDACOES INICIAIS -----------------
  
  -- Incluir nome do m�dulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  
  -- Buscar nome do programa
  OPEN cr_crapprg;
  FETCH cr_crapprg INTO rw_crapprg;
  CLOSE cr_crapprg;
  
  -- Verificar se � para rodar para todas as cooperativas
  IF pr_cdcooper = 0 THEN
    vr_cdcooper := 3;
  ELSE
    vr_cdcooper := pr_cdcooper;
  END IF;

  -- Leitura do calend�rio da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se n�o encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  --> verificar se � uma segunda-feira
  IF to_char(rw_crapdat.dtmvtolt,'D') <> 2 THEN  
    vr_dscritic := 'Processo n�o pode ser executado neste dia.';
    RAISE vr_exc_saida;  
  END IF;  

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  --> Buscar parametro que define quantidade de meses para limpeza
  vr_qtmeslim := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                           pr_cdcooper => vr_cdcooper, 
                                           pr_cdacesso => 'QTD_MES_LIMPEZA_WEPR');
  
  IF nvl(vr_qtmeslim,0) = 0 THEN
    vr_dscritic := 'Quantidade de meses para limpeza nao encontrado.';
    RAISE vr_exc_saida;
  ELSE
    -- primeiro dia de 4 meses atras (120 dias)
    vr_dtlimepr := TRUNC(add_months(rw_crapdat.dtmvtolt,vr_qtmeslim*-1),'MONTH');                                      
  END IF;

  -- Log de in�cio da execu��o
  pc_controla_log_batch('I');

  FOR rw_crapcop IN cr_crapcop LOOP 
  
    -- Buscar diretorio da cooperativa
    vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nmsubdir => '');
                                        
    /* Verificar se arquivo .limpezaok esta criado, significa que processo ja rodou no m�s, 
       crps000 faz exclusao do arquivo no final do m�s  */
    IF gene0001.fn_exis_arquivo(pr_caminho => vr_nmdireto||'/'||vr_nmarqlmp) THEN
    
      vr_dscritic := to_char(rw_crapcop.cdcooper,'fm00')||' - Processo de limpeza ja rodou este mes para esta cooperativa.';  
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra ||' --> '|| vr_dscritic,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
                                   
      vr_dscritic := NULL;                                    
      continue; --> Buscar proxima cooperativa
    END IF;
    
    -->  Leitura do crawepr a ser enviado o cancelamento
    FOR rw_crawepr IN cr_crawepr( pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_dtmvtolt => vr_dtlimepr) LOOP
    
      --> Enviar o cancelamento da proposta para a esteira
      ESTE0001.pc_cancelar_proposta_est ( pr_cdcooper  => rw_crawepr.cdcooper,  --> Codigo da cooperativa
                                          pr_cdagenci  => rw_crawepr.cdagenci,  --> Codigo da agencia                                          
                                          pr_cdoperad  => 1,                    --> codigo do operador
                                          pr_cdorigem  => 9,-- Esteira          --> Origem da operacao
                                          pr_nrdconta  => rw_crawepr.nrdconta,  --> Numero da conta do cooperado
                                          pr_nrctremp  => rw_crawepr.nrctremp,  --> Numero da proposta de emprestimo atual/antigo                                      
                                          pr_dtmvtolt  => rw_crapdat.dtmvtolt,  --> Data do movimento                                      
                                          ---- OUT ----                           
                                          pr_cdcritic  => vr_cdcritic,          --> Codigo da critica
                                          pr_dscritic  => vr_dscritic);         --> Descricao da critica
      
      -- Verificar se retornou critica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        
        IF nvl(vr_cdcritic,0) > 0 AND
           TRIM(vr_dscritic) IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
        END IF; 
      
        vr_dscritic := 'ERRO coop ' || rw_crawepr.cdcooper ||
                       ' nrdconta ' || rw_crawepr.nrdconta ||
                       ' nrctremp ' || rw_crawepr.nrctremp ||
                       ': '|| vr_dscritic;                           
        -- Gerar log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                   pr_ind_tipo_log => 2, 
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' - '||vr_cdprogra ||' --> '|| vr_dscritic,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
      
       
        vr_qtderros := vr_qtderros + 1; 
        continue; --> buscar proximo
      END IF;   
      
      vr_qtsucess := vr_qtsucess + 1;
      
    END LOOP; --> Fim Loop crawepr
  END LOOP;
  
  -- Gerar log
  IF (vr_qtderros + vr_qtsucess) > 0 THEN
    vr_dscritic := 'Foram enviados '|| (vr_qtderros + vr_qtsucess)||
                   ' cancelamentos para Esteira, '||
                   vr_qtsucess ||' com sucesso e '||
                   vr_qtderros ||' com erro.';
  ELSE
    vr_dscritic := 'Nenhum cancelamento de proposta enviado.';
  END IF;              

  btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                             pr_ind_tipo_log => 1, 
                             pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                ' - '||vr_nomdojob ||' --> '|| vr_dscritic);                                 

  vr_dscritic := NULL;
  ----------------- ENCERRAMENTO DO PROGRAMA -------------------
 
  -- Log de fim da execu��o
  pc_controla_log_batch('F');
  
  -- Salvar informa��es atualizadas
  COMMIT;

EXCEPTION  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic );       
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro n�o tratado
    vr_dscritic := sqlerrm;
    
    -- Envio centralizado de log de erro
    vr_flgerlog := TRUE;
    pc_controla_log_batch('E', vr_dscritic);
                                               
    -- Efetuar rollback
    ROLLBACK;

END pc_crps704;
/
