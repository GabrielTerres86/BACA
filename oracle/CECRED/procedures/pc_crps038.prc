CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps038 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps038 (Fontes/crps038.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Outubro/92.                         Ultima atualizacao: 14/02/2014

       Dados referentes ao programa:

       Sempre que alterar este programa alterar o crps077.p

       Frequencia: Anual (Batch - Background).
       Objetivo  : Atende a solicitacao 024 (anual - limpeza anual)
                   Emite: arquivo geral de extratos de capital para microfilmagem
                          ate a conta 519999.

       Alteracao : 20/03/95 - Alterado para ajustar o layout para mostrar os
                              lancamentos em moedas fixas. (Odair).

                   03/04/97 - Alterado para mudar do /win10 para o /win12 (Deborah).

                   04/02/98 - Incluir funcao transmic (Odair)

                   09/03/98 - Alterado para passar novo parametro para o shell
                              transmic (Deborah).

                   23/12/1999 - Acerto para buscar dados no crapcop (Deborah).

                   10/01/2000 - Padronizar mensagens (Deborah).

                   23/03/2000 - Tratar arquivos de microfilmagem, transmitindo
                                para Hering somente arquivos com registros (Odair)

                   01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

                   02/08/2004 - Modificado caminho do win12 (Evandro).

                   20/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   14/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                                glb_cdcooper) no "for each" da tabela CRAPHIS.
                              - Kbase IT Solutions - Paulo Ricardo Maciel.

                   30/10/2008 - Alteracao CDEMPRES (Diego).

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   03/01/2012 - Incluir tipo de lote 10 para historicos (David).

                   14/02/2014 - Conversao Progress -> Oracle (Edison - AMcom)

    ............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS038';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- Controle da execução do programa
      vr_dstextab   craptab.dstextab%TYPE;
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

      -- Se a variavel de erro é <> 0
      IF nvl(vr_cdcritic,0) <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a cooperativa deve gerar o arquivo
      vr_dstextab := tabe0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'CONFIG'
                                                ,pr_cdempres => pr_cdcooper
                                                ,pr_cdacesso => 'MICROFILMA'
                                                ,pr_tpregist => 38);

      -- se nao encontrar o parametro, aborta a execucao
      IF trim(vr_dstextab) IS NULL THEN
        -- gera critica 652 - Falta tabela de configuracao da cooperativa
        vr_cdcritic := 652;
        -- busca descricao da critica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' - CRED-CONFIG-NN-MICROFILMA-038';
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se o programa deve rodar para esta Cooperativa
      IF to_number(substr(vr_dstextab,1,1)) <> 1 THEN
        -- finalizando o programa
        RAISE vr_exc_fimprg;
      END IF;

      -- chama a package para gerar o arquivo
      LIMP0001.pc_limpeza_microfilmagem ( pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                          ,pr_flgresta => pr_flgresta   --> Flag padrao para utilizacao de restart
                                          ,pr_cdprogra => vr_cdprogra   --> Nome Programa da Execucao crps019/crps076
                                          ,pr_flgtrans => substr(vr_dstextab,3,1) = '1' --> Indica se deve transmitir os arquivo
                                          ,pr_stprogra => pr_stprogra   --> Saida de termino da execucao
                                          ,pr_infimsol => pr_infimsol   --> Saida de termino da solicitacao
                                          ,pr_cdcritic => vr_cdcritic   --> Codigo da Critica
                                          ,pr_dscritic => vr_dscritic); --> Descricao da Critica

      -- se retornar alguma crítica aborta a execucao
      IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        -- finaliza a execucao
        RAISE vr_exc_saida;
      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
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
  END pc_crps038;
/

