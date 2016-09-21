CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS579" (pr_cdcooper IN crapcop.cdcooper%type   --> Codigo da cooperativa
                        ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                        ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic OUT crapcri.cdcritic%type  --> Codigo de critica
                        ,pr_dscritic OUT VARCHAR2)              --> Descricao de critica
AS
  BEGIN
    /* .........................................................................

    Programa: PC_CRPS579 (Antigo Fontes/crps579.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Vitor
    Data    : Agosto/2010                       Ultima atualizacao: 29/10/2015

    Dados referentes ao programa:

    Frequencia: Diario (Batch - Background).
    Objetivo  : Fazer limpeza limpeza dos registros de controle
               da Compensação ABBC no Banco Generico.

    Alteracoes: 19/09/2013 - Conversao Progress -> PL/SQL (Douglas Pagel).
    
                10/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                             das criticas e chamadas a fimprg.p (Douglas Pagel)
                             
                29/10/2015 - Retirar exclusão da tabela gncpdoc (Lucas Ranghetti #323825)
    ......................................................................... */
    DECLARE
      -- Identificacao do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS579';
      
      -- Controle de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      

      -- CURSORES --
      -- Cursor para validação da cooperativa
      cursor cr_crapcop is
        SELECT nmrescop, cdcooper
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;

      -- Cursor para listagem das cooperativas
      cursor cr_crapcop_loop is
        SELECT nmrescop, cdcooper
          FROM crapcop;
      rw_crapcop_loop cr_crapcop_loop%rowtype;

      -- Rowtype para validacao da data
      rw_crapdat btch0001.cr_crapdat%rowtype;
      -- FIM CURSORES --

      -- VARIAVEIS --
      vr_exc_saida exception;      -- Excecao padrao
      vr_exc_fimprg exception;     -- Exceção com fimprg sem interromper a cadeia.
      vr_dstextab craptab.dstextab%type; -- Retorno para funcao tabe0001.fn_busca_dstextab
      vr_dtlimite date;            -- Data limite para limpeza
      vr_nmtable varchar2(50);     -- Nome da tabela que está sendo executada para exception
      vr_qtdptit pls_integer := 0; -- Contador para Compensacao Titulos da Central
      vr_qtdpchq pls_integer := 0; -- Contador para Compensacao Cheques da Central
      vr_qtdpdev pls_integer := 0; -- Contador para Compensacao Cheques Devolvidos da Central
      vr_qtdarcp pls_integer := 0; -- Contador para Gerencial Tarifas da Central
      vr_qtdcomp pls_integer := 0; -- Contador para Fechamento Compensacao (FAC e ROC)
      vr_qtdcdda pls_integer := 0; -- Contador para Ressarcimento de Custo DDA
      -- FIM VARIAVEIS --

      -- PROCEDIMENTOS --
      -- Procedimento para escrita do resultado de registros deletados de cada tabela.
      procedure pc_gera_log_result (pr_nmtable in varchar2
                                   ,pr_qtdregi in pls_integer) is
      begin
        vr_cdcritic := 661;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper                   --> Cooperativa
                                  ,pr_ind_tipo_log => 2 --Tratado               --> Nivel criticidade do log
                                  ,pr_des_log => to_char(sysdate, 'hh24:mi:ss')
                                                || ' - '
                                                || vr_cdprogra
                                                || ' --> '
                                                || vr_dscritic || ' '
                                                || pr_nmtable || ' = '
                                                || GENE0002.fn_mask(pr_qtdregi, 'zzz,zz9'));
      end;
      -- FIM PROCEDIMENTOS --
    BEGIN
      -- Informa acesso
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Valida Iniprg
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Sair do processo e abortar a cadeia
        RAISE vr_exc_saida;
      END IF;

      -- Inicio da Regra de Negocio
      -- Programa chamado somente pela CECRED toda primeira segunda-feira do mês.

      --Busca na crapdat
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'EXELIMPEZA'
                                               ,pr_tpregist => 001);
      -- Se não encontrar registro
      if vr_dstextab is null then
         -- codigo da critica
         vr_cdcritic:= 387;
         -- Gera log e sai do programa
         RAISE vr_exc_saida;
      end if;

      -- Se já foi executado
      if vr_dstextab = '1' then
        -- codigo da critica
        vr_cdcritic := 177;
        -- Gera log e sai do programa
        raise vr_exc_saida;
      end if;

      -- Monta data limite para limpeza
      -- Ex: rw_crpadat.dtmvtolt = 28/06/2013
      vr_dtlimite := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd'); -- fim mes anterior
      -- vr_dtlimite = 31/05/2013
      vr_dtlimite := vr_dtlimite - to_char(vr_dtlimite, 'dd'); -- 30 Dias
      -- vr_dtlimte = 30/04/2013
      vr_dtlimite := vr_dtlimite - to_char(vr_dtlimite, 'dd'); -- 60 Dias
      -- vr_dtlimite = 31/03/2013
      vr_dtlimite := vr_dtlimite + 1; -- Primeiro dia de 2 meses atras
      -- vr_dtlimite = 01/04/2013

      -- Para cada cooperativa da crapcop
      open cr_crapcop_loop;
      loop
        fetch cr_crapcop_loop
          into rw_crapcop_loop;

        -- Se não econtrar mais cooperativas
        exit when cr_crapcop_loop%notfound;
        --Bloco para limpeza das tabelas
        begin
          -- Limpar Compensacao Titulos da Central
          vr_nmtable := 'GNCPTIT';
          DELETE
            FROM gncptit
           WHERE gncptit.cdcooper = rw_crapcop_loop.cdcooper
             AND gncptit.dtmvtolt <= vr_dtlimite;
          vr_qtdptit := vr_qtdptit + SQL%ROWCOUNT;

          -- Limpar Compensacao de Cheques da Central
          vr_nmtable := 'GNCPCHQ';
          DELETE
            FROM gncpchq
           WHERE gncpchq.cdcooper = rw_crapcop_loop.cdcooper
             AND gncpchq.dtmvtolt <= vr_dtlimite;
          vr_qtdpchq := vr_qtdpchq + SQL%ROWCOUNT;

          -- Limpar Compensacao de Cheques Devolvidos da Central
          vr_nmtable := 'GNCPDEV';
          DELETE
            FROM gncpdev
           WHERE gncpdev.cdcooper = rw_crapcop_loop.cdcooper
             AND gncpdev.dtmvtolt <= vr_dtlimite;
          vr_qtdpdev := vr_qtdpdev + SQL%ROWCOUNT;

          -- Limpar Gerencial Tarifas de Compensacao da Central
          vr_nmtable := 'GNTARCP';
          DELETE
            FROM gntarcp
           WHERE gntarcp.cdcooper = rw_crapcop_loop.cdcooper
             AND gntarcp.dtmvtolt <= vr_dtlimite;
          vr_qtdarcp := vr_qtdarcp + SQL%ROWCOUNT;

          -- Limpar Dados de Fechamento da Compensacao (FAC e ROC)
          vr_nmtable := 'GNFCOMP';
          DELETE
            FROM gnfcomp
           WHERE gnfcomp.cdcooper = rw_crapcop_loop.cdcooper
             AND gnfcomp.dtmvtolt <= vr_dtlimite;
          vr_qtdcomp := vr_qtdcomp + SQL%ROWCOUNT;

          -- Limpar Dados de Ressarcimento de Custo DDA
          vr_nmtable := 'GNRCDDA';
          DELETE
            FROM gnrcdda
           WHERE gnrcdda.cdcooper = rw_crapcop_loop.cdcooper
             AND gnrcdda.dtmvtolt <= vr_dtlimite;
          vr_qtdcdda := vr_qtdcdda + SQL%ROWCOUNT;
          -- bloco de exception para comando de DELETE
        exception -- Exception da transacao
          when others then
            vr_dscritic := 'Erro ao limpar a tabela ' || vr_nmtable || ' da Cooperativa ' || rw_crapcop_loop.nmrescop || '. Erro: ' || sqlerrm;

            -- Apenas informa no log que houve erro. 
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> ATENCAO !! '
                                                       || vr_dscritic);
        end; -- Fim do bloco de transacao
        
      end loop; -- Fim loop das cooperativas

      -- Gera informações totais no log
      -- Gera log da limpeza na GNCPTIT
      pc_gera_log_result (pr_nmtable => 'GNCPTIT'
                         ,pr_qtdregi => vr_qtdptit);
      -- Gera log da limpeza na GNCPCHQ
      pc_gera_log_result (pr_nmtable => 'GNCPCHQ'
                         ,pr_qtdregi => vr_qtdpchq);
      -- Gera log da limpeza na GNCPDEV
      pc_gera_log_result (pr_nmtable => 'GNCPDEV'
                         ,pr_qtdregi => vr_qtdpdev);
      -- Gera log da limpeza na GNTARCP
      pc_gera_log_result (pr_nmtable => 'GNTARCP'
                         ,pr_qtdregi => vr_qtdarcp);
      -- Gera log da limpeza na GNFCOMP
      pc_gera_log_result (pr_nmtable => 'GNFCOMP'
                         ,pr_qtdregi => vr_qtdcomp);
      -- Gera log da limpeza na GNRCDDA
      pc_gera_log_result (pr_nmtable => 'GNRCDDA'
                         ,pr_qtdregi => vr_qtdcdda);

      -- Fim da Regra de Negocio
      
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Comita alteracoes
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        END IF;                                                   
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
        
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END PC_CRPS579;
/

