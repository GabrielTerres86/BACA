CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS148" (pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdagenci  IN crapage.cdagenci%TYPE  --> Codigo Agencia 
                     ,pr_idparale  IN crappar.idparale%TYPE  --> Indicador de processoparalelo
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                     ,pr_dscritic OUT varchar2) is
                                        
/* ..........................................................................

   Programa: pc_crps148 (antigo Fontes/crps148.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                      Ultima atualizacao: 14/12/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 5 (Finalizacao do processo).
               Calcula as aplicacoes RPP aniversariantes.
               Nao gera relatorio.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes)

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               04/06/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)

               28/06/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               27/05/2015 - Realizando a retirada dos tratamentos de restart, pois o programa
                            apresentou erros no processo batch. Os códigos foram comentados e 
                            podem ser removidos em futuras alterações do fonte. (Renato - Supero)
                            
               14/12/2017 - Projeto Ligeirinho - Incluindo paralelismo para melhorar a performance 
                            da rotina (Roberto Nunhes - AMCOM).
............................................................................. */

  -- Agências por cooperativa, com poupança programada
  cursor cr_craprpp_age (pr_cdcooper in craprpp.cdcooper%type,
                         pr_dtmvtopr in craprpp.dtfimper%type) is 
    select distinct cdagenci
      from craprpp
     where craprpp.cdcooper  = pr_cdcooper
       and craprpp.dtfimper <= pr_dtmvtopr  
       and craprpp.incalmes  = 0
       and craprpp.cdsitrpp <> 5;        

  cursor cr_erro(pr_cdcooper in crapcop.cdcooper%TYPE) is
    select c.dsvlrprm
      from crapprm c
     where c.nmsistem = 'CRED'
       and c.cdcooper = pr_cdcooper
       and c.cdacesso = 'PC_CRPS148-ERRO';
  rw_erro cr_erro%ROWTYPE;
  
  -- Poupança programada
  cursor cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                     pr_dtmvtopr in craprpp.dtfimper%type,
                     pr_cdagenci in crapage.cdagenci%type) is
    select nrdconta,
           nrctrrpp,
           rowid
      from craprpp
     where craprpp.cdcooper  = pr_cdcooper
       and craprpp.cdagenci  = decode(pr_cdagenci,0,craprpp.cdagenci,pr_cdagenci)
       and craprpp.dtfimper <= pr_dtmvtopr
       and craprpp.incalmes  = 0
       and craprpp.cdsitrpp <> 5
     order by nrdconta,
              nrctrrpp;
    
  -- Registro para armazenar as datas
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  -- Exception para tratamento de erros tratáveis sem abortar a execução
  vr_exc_mensagem  exception;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  vr_inproces      crapdat.inproces%type;
  --Informacoes tabelas genericas
  vr_prcaplic      craptab.dstextab%type;
  -- Saldo calculado da poupança
  vr_vlsdrdpp      craprpp.vlsdrdpp%type := 0;
  -- Variáveis para controle de reprocesso
  vr_dsrestar      crapres.dsrestar%type;
  vr_inrestar      number(1);
  -- Tratamento de erros
  vr_exc_erro      exception;
  -- ID para o paralelismo
  vr_idparale      integer;
  --Variaveis de Excecao
  vr_exc_saida     exception;
  -- Qtde parametrizada de Jobs
  vr_qtdjobs       number;
  -- Job name dos processos criados
  vr_jobname       varchar2(30);
  -- Bloco PLSQL para chamar a execução paralela do pc_crps750
  vr_dsplsql       varchar2(4000);
  --Variaveis para retorno de erro
  vr_cdcritic      integer:= 0;
  vr_dscritic      varchar2(4000);
  vr_idprglog      number;
  --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
  vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;  
  vr_idlog_ini_ger tbgen_prglog.idprglog%type;
  vr_idlog_ini_par tbgen_prglog.idprglog%type;
begin
  vr_cdprogra := 'CRPS148';
  
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS148',
                             pr_action => vr_cdprogra);
                             
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
                                               
  -- Se retornou algum erro
  if pr_cdcritic <> 0 then
    -- Buscar descrição do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_erro;
  end if;  
                  
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor pois haverá raise
      close btch0001.cr_crapdat;
      pr_cdcritic:= 1;
      -- Montar mensagem de critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      raise vr_exc_erro;
    else
      -- Atribuir a proxima data do movimento
      vr_dtmvtopr := rw_crapdat.dtmvtopr;
      -- Atribuir o indicador de processo
      vr_inproces := rw_crapdat.inproces;
    end if;
  close btch0001.cr_crapdat;  

  --Retirar quando terminar 
  --forcando sempre pegar data de mov. específica 
  vr_inproces := 3;
  --vr_dtmvtopr := to_date('01/07/2017','dd/mm/yyyy');

  -- Buscar o percentual de IR da aplicação
  vr_prcaplic := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'CONFIG',
                                            pr_cdempres => 0,
                                            pr_cdacesso => 'PERCIRAPLI',
                                            pr_tpregist => 0);

  -- Buscar informações de reprocesso
  /*btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              pr_cdcritic,
                              pr_dscritic);
  if pr_dscritic is not null then
    raise vr_exc_erro;
  end if;*/

  -- Buscar quantidade parametrizada de Jobs
  vr_qtdjobs := gene0001.fn_retorna_qt_paralelo( pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                               , vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                               ); 
  
  /* Paralelismo visando performance Rodar Somente no processo Noturno */
  if vr_inproces         > 2 and
     vr_qtdjobs          > 0 and 
     pr_cdagenci         = 0 then  
  
    -- Gerar o ID para o paralelismo
    vr_idparale := gene0001.fn_gera_ID_paralelo;
    
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    vr_idlog_ini_ger := null;
    pc_log_programa(pr_dstiplog   => 'I',    
                    pr_cdprograma => vr_cdprogra,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_ger);
     
    -- Se houver algum erro, o id vira zerado
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
       RAISE vr_exc_saida;
    END IF;
                                          
    -- Retorna as agências, com poupança programada
    for rw_craprpp_age in cr_craprpp_age (pr_cdcooper,
                                          vr_dtmvtopr) loop
                                          
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'crps148_' || rw_craprpp_age.cdagenci || '$';  
    
      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(rw_craprpp_age.cdagenci
                                                    ,3
                                                    ,'0') --> Utiliza a agência como id programa
                                ,pr_des_erro => pr_dscritic);
                                
      -- Testar saida com erro
      if pr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;     
      
      -- Grava controle de batch por agência
      gene0001.pc_grava_batch_controle( pr_cdcooper              --pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                       ,vr_cdprogra              --pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                       ,vr_dtmvtopr              --pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                       ,1                        --pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                       ,rw_craprpp_age.cdagenci  --pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                       ,null                     --pr_cdrestart   IN tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                       ,1                        --pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                       ,vr_idcontrole            --pr_idcontrole OUT tbgen_batch_controle.idcontrole%TYPE  -- ID de Controle
                                       ,pr_cdcritic              --pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                       ,pr_dscritic              --pr_dscritic   OUT crapcri.dscritic%TYPE
                                       );      
      
      -- Montar o bloco PLSQL que será executado
      -- Ou seja, executaremos a geração dos dados
      -- para a agência atual atraves de Job no banco
      vr_dsplsql := 'DECLARE' || chr(13) || --
                    '  wpr_stprogra NUMBER;' || chr(13) || --
                    '  wpr_infimsol NUMBER;' || chr(13) || --
                    '  wpr_cdcritic NUMBER;' || chr(13) || --
                    '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                    'BEGIN' || chr(13) || --
                    '  pc_crps148( '|| pr_cdcooper || ',' ||
                                       rw_craprpp_age.cdagenci || ',' ||
                                       vr_idparale || ',' ||
                                       'null' || ',' ||
                                   ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                    chr(13) || --
                    'END;'; --  
       
       -- Faz a chamada ao programa paralelo atraves de JOB
       gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                             ,pr_cdprogra => vr_cdprogra  --> Código do programa
                             ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                             ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                             ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                             ,pr_jobname  => vr_jobname   --> Nome randomico criado
                             ,pr_des_erro => pr_dscritic);    
                             
       -- Testar saida com erro
       if pr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
       end if;
      /*
       dbms_output.put_line('JOB CRIADO :'||vr_jobname||' - '||vr_idparale);
       
       dbms_output.put_line('Comando : '||vr_dsplsql);
       
       dbms_output.put_line('Inicio pc_aguarda_paralelo JOB - '||to_char(sysdate,'hh24:mi:ss'));
       */
       -- Chama rotina que irá pausar este processo controlador
       -- caso tenhamos excedido a quantidade de JOBS em execuçao
       gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                   ,pr_des_erro => pr_dscritic);
       /*
       dbms_output.put_line('Fim pc_aguarda_paralelo JOB - '||to_char(sysdate,'hh24:mi:ss'));
       dbms_output.put_line('');
       */
       -- Testar saida com erro
       if  pr_dscritic is not null then 
         -- Levantar exceçao
         raise vr_exc_saida;
       end if;
       
       
    end loop;
    --dbms_output.put_line('Inicio pc_aguarda_paralelo GERAL - '||to_char(sysdate,'hh24:mi:ss')); 
    -- Chama rotina de aguardo agora passando 0, para esperarmos
    -- até que todos os Jobs tenha finalizado seu processamento
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => pr_dscritic);
                                
    --dbms_output.put_line('Fim pc_aguarda_paralelo GERAL - '||to_char(sysdate,'hh24:mi:ss'));                          
    -- Testar saida com erro
    open cr_erro(pr_cdcooper);
    fetch cr_erro into rw_erro;
    if cr_erro%found then
      close cr_erro;
      vr_cdcritic := 0;
      vr_dscritic := rw_erro.dsvlrprm;
      raise vr_exc_saida;
    else
      close cr_erro;
    end if;

    if pr_dscritic is not null then 
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    --Salvar informacoes no banco de dados
    commit;

    return;
  else    
    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    vr_idlog_ini_par := null;
    pc_log_programa(pr_dstiplog   => 'I',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par);
    
    -- Processo antigo sem paralelismo
    -- Buscar informações da poupança programada
    for rw_craprpp in cr_craprpp (pr_cdcooper,
                                  vr_dtmvtopr,
                                  pr_cdagenci) loop
      /*if vr_inrestar > 0 and
         rw_craprpp.nrdconta = vr_nrctares and
         rw_craprpp.nrctrrpp <= to_number(vr_dsrestar) then
        continue;
      end if;*/
      
      
      
      -- Grava LOG de ocorrência inicial da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => 1,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Início - apli0001.pc_calc_poupanca. AGENCIA: '||pr_cdagenci||
                                                                                ' - CONTA: '||rw_craprpp.nrdconta||
                                                                                ' - INPROCES: '||vr_inproces,
                      PR_IDPRGLOG           => vr_idlog_ini_par);       
      
      --Executa cálculo de poupança (antigo poupanca.i)
      apli0001.pc_calc_poupanca (pr_cdcooper => pr_cdcooper,          --> Cooperativa
                                 pr_dstextab => vr_prcaplic,          --> Percentual de IR da aplicação
                                 pr_cdprogra => vr_cdprogra,          --> Programa chamador
                                 pr_inproces => vr_inproces,          --> Indicador do processo
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,  --> Data do processo
                                 pr_dtmvtopr => vr_dtmvtopr,          --> Próximo dia útil
                                 pr_rpp_rowid => rw_craprpp.rowid,    --> Identificador do registro da tabela CRAPRPP em processamento
                                 pr_vlsdrdpp => vr_vlsdrdpp,          --> Saldo da poupança programada
                                 pr_cdcritic => pr_cdcritic,          --> Código da critica de erro
                                 pr_des_erro => pr_dscritic);         --> Descrição do erro encontrado
      if pr_dscritic is not null or pr_cdcritic is not null then
        raise vr_exc_erro;
      end if;
      
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => 1,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim - apli0001.pc_calc_poupanca. AGENCIA: '||pr_cdagenci||
                                                                                ' - CONTA: '||rw_craprpp.nrdconta||
                                                                                ' - INPROCES: '||vr_inproces,
                      PR_IDPRGLOG           => vr_idlog_ini_par); 
      
      
      -- Atualiza controle de reprocesso
      /*begin
        update crapres
           set crapres.nrdconta = rw_craprpp.nrdconta
         where crapres.cdcooper = pr_cdcooper
           and crapres.cdprogra = vr_cdprogra;
        if sql%rowcount = 0 then
          pr_cdcritic := 151;
          pr_dscritic := gene0001.fn_busca_critica(151);
          --
          raise vr_exc_erro;
        end if;
      exception
        when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
          raise vr_exc_erro;
      end;
      --
      commit;*/
    end loop;
    
    --Grava data fim para o JOB na tabela de LOG 
    pc_log_programa(pr_dstiplog   => 'F',    
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                    pr_cdcooper   => pr_cdcooper, 
                    pr_tpexecucao => 2,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par);                     
  end if;    
  
  -- Eliminar controle de reprocesso
  /*btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              pr_dscritic);
  if pr_dscritic is not null then
    pr_cdcritic := 0;
    raise vr_exc_erro;
  end if;*/
  
  if pr_cdagenci = 0 then
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);
    
    if vr_inproces > 2 then 
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);                 
    end if;

    --Salvar informacoes no banco de dados
    commit;
  else
    
    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => LPAD(pr_cdagenci
                                                    ,3
                                                    ,'0')
                                ,pr_des_erro => vr_dscritic);  
  
    -- Atualiza finalização do batch na tabela de controle 
    gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                       ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                       ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                       );  
    --Salvar informacoes no banco de dados
    commit;
  end if;
exception
  when vr_exc_erro then
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    
    if pr_cdagenci <> 0 then 
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => 1,                              -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);   
    
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci
                                                      ,3
                                                      ,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if; 
    -- Desfazer as alterações
    rollback;
  WHEN vr_exc_saida THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descricao
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci
                                                        ,3
                                                        ,'0')
                                    ,pr_des_erro => vr_dscritic);
        
        -- Grava LOG de erro com as críticas retornadas                           
        pc_log_programa(PR_DSTIPLOG      => 'E', 
                        PR_CDPROGRAMA    => vr_cdprogra,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => 1,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        PR_IDPRGLOG      => vr_idprglog);  
                                    
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;

      IF pr_cdagenci <> 0 THEN
        begin
          insert into crapprm(nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dstexprm
                             ,dsvlrprm)
                             values
                             ('CRED'
                             ,pr_cdcooper
                             ,'PC_CRPS148-ERRO'
                             ,'Erro na execução da rotina pc_crps148'
                             ,'Agência: '||pr_cdagenci||' - Erro: '||pr_dscritic);
        exception
          when dup_val_on_index then
            null;
        end;
      END IF;
  when others then    
    if pr_cdagenci <> 0 then 
      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci
                                                      ,3
                                                      ,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if; 
    
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Desfazer as alterações
    rollback;
END;
/
