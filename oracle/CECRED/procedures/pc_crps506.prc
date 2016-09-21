CREATE OR REPLACE PROCEDURE CECRED.pc_crps506(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Coop conectada
                                             ,pr_flgresta IN PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  /* ............................................................................
   Programa: PC_CRPS506 (Antigo Fontes/crps506.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme    
   Data    : Abril/2008                      Ultima atualizacao: 24/03/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 005 (Finalizacao do processo).
               Este programa roda baseado na data do proximo movimento dtmvtopr.
               Verificar as poupancas programadas com vencimento na proxima 
               data de movimento, e criar o registro na craplrg para a poupanca
               ser resgatada para a conta investimento (crps156).

   Alteracoes: 12/08/2013 - Tratamento para o Bloqueio Judicial (Ze).
  
               24/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel)
  
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
  
  -- Cursor Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                    pr_cdagenci IN craplot.cdagenci%TYPE,
                    pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                    pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT lot.cdcooper
          ,lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,lot.tplotmov
          ,lot.nrseqdig
          ,lot.rowid
          ,lot.qtcompln
          ,lot.qtinfoln
          ,lot.vlcompdb
          ,lot.vlinfodb
     FROM craplot lot
    WHERE lot.cdcooper = pr_cdcooper
      AND lot.dtmvtolt = pr_dtmvtolt
      AND lot.cdagenci = pr_cdagenci
      AND lot.cdbccxlt = pr_cdbccxlt
      AND lot.nrdolote = pr_nrdolote; 
  rw_craplot cr_craplot%ROWTYPE;
  
  -- Buscar poupanca programada.
  CURSOR cr_craprpp(pr_cdcooper IN craprpp.cdcooper%TYPE,
                    pr_dtmvtopr IN craprpp.dtvctopp%TYPE) IS
    SELECT rpp.nrdconta
          ,rpp.nrctrrpp
     FROM craprpp rpp
    WHERE rpp.cdcooper  = pr_cdcooper 
      AND rpp.dtvctopp <= pr_dtmvtopr           
      AND rpp.cdsitrpp <> 5;   
      
  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS506';

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  
  vr_vlblqjud NUMBER := 0;
  vr_vlresblq NUMBER := 0;
  
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

   -- Leitura Lançamentos
  FOR rw_craprpp IN cr_craprpp(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP 

    -- Inicializa as Variaveis                           
    vr_vlblqjud := 0;
    vr_vlresblq := 0;  
    
    -- Busca Saldo Bloqueado Judicial 
    GENE0005.pc_retorna_valor_blqjud (pr_cdcooper => pr_cdcooper         --> Cooperativa
                                     ,pr_nrdconta => rw_craprpp.nrdconta --> Conta
                                     ,pr_nrcpfcgc => 0                   --> CPF/CGC
                                     ,pr_cdtipmov => 1 -- Bloqueio       --> Tipo do movimento
                                     ,pr_cdmodali => 3 -- Poupanca       --> Modalidade
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                     ,pr_vlbloque => vr_vlblqjud         --> Valor bloqueado
                                     ,pr_vlresblq => vr_vlresblq         --> Valor que falta bloquear
                                     ,pr_dscritic => vr_dscritic);       --> Erros encontrados no processo

    -- Progress não taratava erro na busca de valor bloqueio                                 
    
    IF vr_vlblqjud > 0 THEN
      CONTINUE;                                   
    END IF;
    
    
    -- Verifica Existencia de Lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => rw_crapdat.dtmvtopr
                   ,pr_cdagenci => 99
                   ,pr_cdbccxlt => 400
                   ,pr_nrdolote => 506);
    FETCH cr_craplot INTO rw_craplot;
      
    IF cr_craplot%NOTFOUND THEN
          
      -- Fechar Cursor
      CLOSE cr_craplot; 
      
      BEGIN
        --Inserir a capa do lote retornando informacoes para uso posterior
        INSERT INTO craplot(dtmvtolt
                           ,dtmvtopg
                           ,cdbccxpg
                           ,cdhistor
                           ,tpdmoeda
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,tplotmov
                           ,cdcooper
                           ,nrseqdig)
                   VALUES  (rw_crapdat.dtmvtopr
                           ,rw_crapdat.dtmvtopr
                           ,0
                           ,0
                           ,1
                           ,99
                           ,400
                           ,506
                           ,11
                           ,pr_cdcooper
                           ,0)
                   RETURNING cdcooper
                            ,dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,tplotmov
                            ,nrseqdig
                            ,ROWID
                   INTO  rw_craplot.cdcooper
                        ,rw_craplot.dtmvtolt
                        ,rw_craplot.cdagenci
                        ,rw_craplot.cdbccxlt
                        ,rw_craplot.nrdolote
                        ,rw_craplot.tplotmov
                        ,rw_craplot.nrseqdig
                        ,rw_craplot.rowid;

      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tabela craplot. '|| SQLERRM;
          --Sair do programa
          RAISE vr_exc_saida;
      END;  
      
    ELSE
      -- Apenas Fechar Cursor
      CLOSE cr_craplot; 
    END IF;
    
    -- Cria Registro na CRAPLRG
    BEGIN
      INSERT INTO craplrg(cdagenci
                         ,cdbccxlt
                         ,nrdocmto
                         ,nrdolote
                         ,nrseqdig
                         ,dtmvtolt
                         ,dtresgat
                         ,inresgat
                         ,nraplica
                         ,nrdconta
                         ,tpaplica
                         ,tpresgat
                         ,vllanmto
                         ,cdoperad
                         ,hrtransa
                         ,flgcreci
                         ,cdcooper)
                 VALUES  (rw_craplot.cdagenci
                         ,rw_craplot.cdbccxlt
                         ,rw_craplot.nrseqdig
                         ,rw_craplot.nrdolote
                         ,rw_craplot.nrseqdig
                         ,rw_crapdat.dtmvtopr
                         ,rw_crapdat.dtmvtopr
                         ,0
                         ,rw_craprpp.nrctrrpp
                         ,rw_craprpp.nrdconta
                         ,4
                         ,2
                         ,0
                         ,'1'
                         ,GENE0002.fn_busca_time -- TIME
                         ,1 -- TRUE
                         ,pr_cdcooper);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tabela craplgr. ' || SQLERRM;
        --Sair do programa
        RAISE vr_exc_saida;
    END;
        
    --Atualizar capa do Lote
    BEGIN
      UPDATE craplot SET craplot.qtinfoln = NVL(rw_craplot.qtinfoln,0) + 1
                        ,craplot.qtcompln = NVL(rw_craplot.qtcompln,0) + 1
                        ,craplot.nrseqdig = NVL(rw_craplot.nrseqdig,0) + 1
      WHERE craplot.ROWID = rw_craplot.ROWID;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
        --Sair do programa
        RAISE vr_exc_saida;
    END;
                               

  END LOOP;                                           
      
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
END pc_crps506;
/

