CREATE OR REPLACE PROCEDURE CECRED.pc_crps041(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS041 (Antigo Fontes/crps041.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Outubro/92.                         Ultima atualizacao: 16/03/2015

   Dados referentes ao programa:

   Frequencia: Anual (Batch - Background).
   Objetivo  : Atende a solicitacao 025.
               Fazer limpeza anual dos planos de capital cancelados no ano an-
               terior.
               Rodara na primeira sexta-feira apos o processo mensal de MARCO.

   Alteracoes: 15/08/94 - Alterado para limpar os planos cancelados com data
                          de cancelamento menor que o ano corrente (Edson).

               14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
  
               16/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
  ............................................................................. */
  
  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
  CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    -- Verifica se deve executar
    SELECT tab.dstextab
          ,ROWID
      FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper
       AND UPPER(tab.nmsistem) = 'CRED'
       AND UPPER(tab.tptabela) = 'GENERI'
       AND tab.cdempres        = 00
       AND UPPER(tab.cdacesso) = 'EXELIMPCOT'
       AND tab.tpregist        = 002;
  rw_craptab cr_craptab%ROWTYPE; 
  
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS041';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  -- Quantidade Registros Deletados
  vr_qtpladel NUMBER := 0;
   
BEGIN

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);
                              
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;                          
    
  -- Leitura do calendário da cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se não encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic:= 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;
        
  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  --  Verifica se deve executar
  OPEN cr_craptab (pr_cdcooper);
  FETCH cr_craptab INTO rw_craptab;
    
  IF cr_craptab%NOTFOUND THEN
      
    CLOSE cr_craptab;
      
    vr_cdcritic := 178; -- 178 - Falta tabela de execucao de limpeza - registro 002.
    RAISE vr_exc_saida;
  END IF;
    
  CLOSE cr_craptab;
       
  IF rw_craptab.dstextab = '1' THEN
    
    vr_cdcritic := 177; -- 177 - Limpeza ja rodou este mes.
    RAISE vr_exc_fimprg;
    
  END IF;

  BEGIN
    -- Le os planos a serem excluidos
    DELETE FROM crappla pla
          WHERE pla.cdcooper = pr_cdcooper
            AND pla.cdsitpla = 2
            AND pla.tpdplano = 1 
            AND to_char(pla.dtcancel,'YYYY') < to_char(rw_crapdat.dtmvtolt,'YYYY');
    -- Recebe quantidade de registros deletados
    vr_qtpladel := SQL%ROWCOUNT;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao deletar registro da crappla. Detalhes: '||SQLERRM;
      RAISE vr_exc_saida;
  END;
  
  
  BEGIN
    UPDATE craptab
       SET craptab.dstextab = '1'
     WHERE craptab.rowid = rw_craptab.rowid;
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao atualizar a tabela craptab: '|| SQLERRM;
      RAISE vr_exc_saida;
  END;
  
  vr_dscritic := 'Deletados no PLA = ' ||
                  gene0002.fn_mask(vr_qtpladel,'z.zzz.zz9'); 
  
  -- Imprime no log do processo os totais das exclusoes
  BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                            ,pr_ind_tipo_log => 2 -- Erro tratato
                            ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                             || vr_cdprogra || ' --> '
                                             || vr_dscritic );
     
  -- Processo OK, devemos chamar a fimprg
  BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN

    -- Se retornou apenas o codigo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Busca Descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;

    -- Se foi gerado critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN

      -- Envio Centralizado de Log de Erro
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- ERRO TRATATO
                                 pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') ||
                                                    ' -' || vr_cdprogra || ' --> ' ||
                                                    vr_dscritic);

    END IF;

    -- Chamos o pc_valida_fimprg para encerrar o processo sem parar a cadeia
    BTCH0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- Salva informações no banco de dados
    COMMIT;
      
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END pc_crps041;
/

