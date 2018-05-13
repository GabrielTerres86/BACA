CREATE OR REPLACE PROCEDURE CECRED.pc_crps641 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> C�digo da cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                       ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                       ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> C�digo da cr�tica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descri��o da cr�tica
  BEGIN
    /* ..........................................................................

     Programa: Fontes/crps641.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CECRED
     Autor   : Adriano
     Data    : Marco/2013                     Ultima atualizacao: 22/10/2013

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Atualiza o risco da crapgrp com risco do ultimo dia do mes
                 na crapris.

     Alteracoes: 18/04/2013 - Colocado no-undo na declaracao das temp-tables
                              tt-erro, tt-grupo-economico (Adriano).

                 22/10/2013 - Convers�o Progress >> Oracle PLSQL (Edison-AMcom).

                 04/03/2014 - Valida��o e ajustes para execu��o (Petter-Supero).

  ............................................................................. */

    DECLARE
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Vari�veis para execu��o
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS641'; --> Nome do programa
      vr_exc_saida    EXCEPTION;                                   --> Controle de sa�da para erros tratados
      vr_exc_fimprg   EXCEPTION;                                   --> Controle para fim de execu��o
      vr_cdcritic     crapcri.cdcritic%TYPE;                       --> C�digo da cr�tica
      vr_dscritic     VARCHAR2(4000);                              --> Descri��o da cr�tica
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;                 --> Cursor para datas parametrizadas
      vr_dstextab     craptab.dstextab%TYPE;                       --> Descri��o da taxa de tabela
      vr_persocio     NUMBER;                                      --> Percentual de s�cio
      vr_tab_grupo    geco0001.typ_tab_crapgrp;                    --> PL Table para armazenar grupos econ�micos
      vr_cdoperad     VARCHAR2(40);                                --> C�digo do cooperado

    BEGIN
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => null);

      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      -- Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        -- Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

	    -- Verifica��o do calend�rio
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;

        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Se o m�s do movimento atual (dtmvtolt) � diferente do m�s ref. ao pr�ximo movimento(dtmvtopr)
      -- sai do programa e volta para a cadeia.
			IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') THEN
        RAISE vr_exc_fimprg;
      END IF;

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Busca o percentual societ�rio da cooperativa
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'PROVISAOCL'
                                               ,pr_tpregist => 999);

      -- Se n�o encontrar o percentual gera exce��o e sai do programa
      IF vr_dstextab IS NULL THEN
        vr_dscritic := 'Valor do Percentual Societ�rio Exigido n�o foi encontrado para a '||rw_crapcop.nmrescop;
        RAISE vr_exc_saida;
      ELSE
        -- Alimenta a vari�vel com o percentual societ�rio
        vr_persocio := substr(vr_dstextab, 91,6);
      END IF;

      -- Controlando a forma��o dos grupos economicos
      geco0001.pc_forma_grupo_economico(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_cdprogra => lower(vr_cdprogra)
                                       ,pr_idorigem => 1
                                       ,pr_persocio => vr_persocio
                                       ,pr_tab_crapdat => rw_crapdat
                                       ,pr_tab_grupo => vr_tab_grupo
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);

      -- Verifica se ocorreram eerros
      IF vr_dscritic <> 'OK' THEN
        vr_dscritic := 'Nao foi possivel atualizar o risco da CRAPGRP com risco do ultimo dia do mes na CRAPRIS. '|| vr_dscritic;
        -- Gravar mensagem de erro em LOG
        RAISE vr_exc_saida;
      END IF;

      -- Alimentando a mensagem de sucesso que ser� impressa no log
      vr_dscritic := 'Atualizacao do risco da CRAPGRP com risco do ultimo dia do mes na CRAPRIS realizado com sucesso.';

      -- Envio centralizado de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );

      -- Limpando a vari�vel de cr�tica
      vr_dscritic := '';

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar Commit de informa��es pendentes de grava��o
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
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

        -- Efetuar commit pois gravaremos o que foi processo at� ent�o
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos c�digo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps641;
/

