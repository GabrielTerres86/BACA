CREATE OR REPLACE PROCEDURE CECRED.
         PC_CRPS289 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps289 (Fontes/crps289.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Maio/2000                         Ultima atualizacao: 22/11/2013

       Dados referentes ao programa:

       Frequencia: Por solicitacao
       Objetivo  : Listar etiquetas para com dados dos associados para selar cartas
                   pela solicitacao 77.

       Alteracoes: 22/12/2000 - Imprimir etiquetas nas impressoras a laser
                                (Eduardo).

                   31/07/2002 - Incluir nova situacao da conta (Margarete).

                   05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)

                   06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                   19/06/2006 - Modificados campos referente endereco para a
                                estrutura crapenc (Diego).

                   27/07/2006 - Efetuado acerto no format do campo rel_linhaimp[2]
                                (Diego).

                   21/11/2006 - Modificado layout das etiquetas (Diego).

                   31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                   25/04/2011 - Aumentar formatos da cidade e bairro (Gabriel).

                   09/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                                ser acionada em caso de saída para continuação da cadeia,
                                e não em caso de problemas na execução (Marcos-Supero)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS289';

      -- Tratamento de erros e desvios de fluxo
      vr_exc_saida exception;
      vr_exc_fimprg exception;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca das empresas em titulares de conta
      CURSOR cr_crapttl IS
        SELECT nrdconta
              ,cdempres
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1; --> Somente titulares

      -- Busca das empresas no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT nrdconta
              ,cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper;

      -- Busca do nome resumido da empresa
      CURSOR cr_crapemp IS
        SELECT cdempres
              ,nmresemp
          FROM crapemp
         WHERE cdcooper = pr_cdcooper;

      -- Busca das seções para o extrato
      CURSOR cr_crapdes IS
        SELECT LPAD(cdagenci,3,'0')||LPAD(cdsecext,3,'0') dschave --> Chave para a pltable
              ,nmsecext
          FROM crapdes
         WHERE cdcooper = pr_cdcooper;

      -- Busca dos endereços dos cooperados
      CURSOR cr_crapenc IS
        SELECT nrdconta
              ,nrcepend
              ,DECODE(nrendere,0,NULL,nrendere) nrendere
              ,dsendere
              ,nmbairro
              ,nmcidade
              ,cdufende
              ,complend
          FROM crapenc
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1  --> Somente do titular
           AND cdseqinc = 1;

      -- Cursor para busca das solicitações de impressão de etiqueta
      CURSOR cr_crapsol IS
        SELECT rowid
              ,cdempres                                               --> pac
              ,NVL(gene0002.fn_char_para_number(dsparame),0) dsparame --> seção extrado
              ,nrdevias                                               --> tipo emissão (1 - Correios, 2 - Outra)
          FROM crapsol
         WHERE cdcooper = pr_cdcooper
           AND nrsolici = 77;

      -- Busca das contas ativas relacionadas ao PAC solicitado
      CURSOR cr_crapass_sol(pr_cdagenci crapass.cdagenci%TYPE
                           ,pr_cdsecext crapass.cdsecext%TYPE) IS
        SELECT ass.nrdconta
              ,ass.cdagenci
              ,DECODE(ass.tpextcta,1,'M',2,'Q',' ') tpextcta
              ,ass.nmprimtl
              ,DECODE(ass.cdsecext,0,999,cdsecext) cdsecext
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.cdagenci = pr_cdagenci
           AND ass.cdsecext = DECODE(pr_cdsecext,0,ass.cdsecext,pr_cdsecext) --> Se não foi passado então compara com o próprio campo
           AND ass.dtdemiss IS NULL
           AND ass.cdsitdct IN(1,6)
         ORDER BY ass.cdagenci
                 ,NVL(ass.cdsecext,0)
                 ,ass.nrdconta;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Obs. A chave é o número da conta
      TYPE typ_tab_empresa IS
        TABLE OF crapjur.cdempres%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_empresa typ_tab_empresa;

      -- Tipo para armazenar o nome resumido da empresa
      TYPE typ_tab_nmresemp IS
        TABLE OF crapemp.nmresemp%TYPE
          INDEX BY PLS_INTEGER;
      vr_tab_nmresemp typ_tab_nmresemp;

      -- Tipo para armazenar a descrição da seção
      TYPE typ_tab_dssecext IS
        TABLE OF crapdes.nmsecext%TYPE
          INDEX BY VARCHAR2(6); --> Chave composta por Pac(3) + Seção(3)
      vr_tab_dssecext typ_tab_dssecext;

      -- Definição de tipo para armazenar informações do endereço dos cooperados (crapenc)
      TYPE typ_reg_crapenc IS
        RECORD(nrcepend crapenc.nrcepend%TYPE
              ,nrendere crapenc.nrendere%TYPE
              ,dsendere crapenc.dsendere%TYPE
              ,nmbairro crapenc.nmbairro%TYPE
              ,nmcidade crapenc.nmcidade%TYPE
              ,cdufende crapenc.cdufende%TYPE
              ,complend crapenc.complend%TYPE);
      TYPE typ_tab_crapenc IS
        TABLE OF typ_reg_crapenc
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapenc typ_tab_crapenc;

      ------------------------------- VARIAVEIS -------------------------------

      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;                  -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo
      vr_flgachou    BOOLEAN := FALSE;      -- Indicador de encontro de algum registro para o relatório
      vr_nrseqetq    PLS_INTEGER;           -- Contador de etiquestas

      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN

      -- Incluir nome do módulo logado
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
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
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

      -- Carregar PLTABLE de titulares de conta
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_empresa(rw_crapttl.nrdconta) := rw_crapttl.cdempres;
      END LOOP;
      -- Carregar PLTABLE de empresas
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_empresa(rw_crapjur.nrdconta) := rw_crapjur.cdempres;
      END LOOP;

      -- Carregar PLTABLE com nome resumido da empresa
      FOR rw_crapemp IN cr_crapemp LOOP
        vr_tab_nmresemp(rw_crapemp.cdempres) := rw_crapemp.nmresemp;
      END LOOP;

      -- Carregar PLTABLE de seções para o extrato
      FOR rw_crapdes IN cr_crapdes LOOP
        vr_tab_dssecext(rw_crapdes.dschave) := rw_crapdes.nmsecext;
      END LOOP;

      -- Incluir o nó raiz ao XML
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Busca todas as solicitações de impressão de etiqueta
      FOR rw_crapsol IN cr_crapsol LOOP

        -- Criaremos a tag da solicitação
        pc_escreve_clob(vr_clobxml,'<solicit rowid="'||rw_crapsol.rowid||'" tpemissao="'||rw_crapsol.nrdevias||'" >');

        -- Se for uma solicitação de envio aos correios
        -- e a PLTABLE de endereços ainda não foi carregada
        IF rw_crapsol.nrdevias = 1 AND vr_tab_crapenc.COUNT = 0 THEN

          -- Buscar os endereços dos associados
          FOR rw_crapenc IN cr_crapenc LOOP
            -- Adicionar o endereço a PL TABLE chaveado pela conta
            vr_tab_crapenc(rw_crapenc.nrdconta).nrcepend := rw_crapenc.nrcepend;
            vr_tab_crapenc(rw_crapenc.nrdconta).nrendere := rw_crapenc.nrendere;
            vr_tab_crapenc(rw_crapenc.nrdconta).dsendere := rw_crapenc.dsendere;
            vr_tab_crapenc(rw_crapenc.nrdconta).nmbairro := rw_crapenc.nmbairro;
            vr_tab_crapenc(rw_crapenc.nrdconta).nmcidade := rw_crapenc.nmcidade;
            vr_tab_crapenc(rw_crapenc.nrdconta).cdufende := rw_crapenc.cdufende;
            vr_tab_crapenc(rw_crapenc.nrdconta).complend := gene0007.fn_caract_acento(rw_crapenc.complend);
          END LOOP;
        END IF;

        -- Iniciar contador
        vr_nrseqetq := 1;

        -- Busca dos associados ativos
        FOR rw_crapass IN cr_crapass_sol(pr_cdagenci => rw_crapsol.cdempres
                                        ,pr_cdsecext => rw_crapsol.dsparame) LOOP

          -- Ativar a flag de encontro de informações
          vr_flgachou := true;

          -- Verificar se não existe empresa vinculada a conta
          IF NOT vr_tab_empresa.EXISTS(rw_crapass.nrdconta) OR NOT vr_tab_nmresemp.EXISTS(vr_tab_empresa(rw_crapass.nrdconta)) THEN
            -- Gerar critica 40
            vr_cdcritic := 40;
            RAISE vr_exc_saida;
          END IF;

          -- Verificar se existe seção vinculada ao extrato
          IF NOT vr_tab_dssecext.EXISTS(LPAD(rw_crapass.cdagenci,3,'0')||LPAD(rw_crapass.cdsecext,3,'0')) THEN
            -- Gerar critica 19
            vr_cdcritic := 19;
            RAISE vr_exc_saida;
          END IF;

          -- Para emissão de Correspondencia de Correios
          IF rw_crapsol.nrdevias = 1 THEN
            -- Gerar o registro com informações de endereço também
            pc_escreve_clob(vr_clobxml,'<etiqueta>'
                                     ||'  <nmprimtl>'||SUBSTR(rw_crapass.nmprimtl,1,40)||'</nmprimtl>'
                                     ||'  <nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'zzzzzz99')||'</nrdconta>'
                                     ||'  <tpextcta>'||rw_crapass.tpextcta||'</tpextcta>'
                                     ||'  <dsendere>'||SUBSTR(vr_tab_crapenc(rw_crapass.nrdconta).dsendere,1,32)||'</dsendere>'
                                     ||'  <nrendere>'||gene0002.fn_mask(vr_tab_crapenc(rw_crapass.nrdconta).nrendere,'zzz.zzz')||'</nrendere>'
                                     ||'  <complend>'||SUBSTR(vr_tab_crapenc(rw_crapass.nrdconta).complend,1,40)||'</complend>'
                                     ||'  <nmbairro>'||SUBSTR(vr_tab_crapenc(rw_crapass.nrdconta).nmbairro,1,40)||'</nmbairro>'
                                     ||'  <nrcepend>'||gene0002.fn_mask(vr_tab_crapenc(rw_crapass.nrdconta).nrcepend,'zzzzz.zz9')||'</nrcepend>'
                                     ||'  <nmcidade>'||SUBSTR(vr_tab_crapenc(rw_crapass.nrdconta).nmcidade||' - '||vr_tab_crapenc(rw_crapass.nrdconta).cdufende,1,31)||'</nmcidade>'
                                     ||'</etiqueta>');
          ELSE
            -- Gerar o registro apenas com informações da conta
            pc_escreve_clob(vr_clobxml,'<etiqueta>'
                                     ||'  <nmprimtl>'||SUBSTR(gene0007.fn_caract_acento(rw_crapass.nmprimtl),1,40)||'</nmprimtl>'
                                     ||'  <cdagenci>'||gene0002.fn_mask(rw_crapass.cdagenci,'999')||'</cdagenci>'
                                     ||'  <nrdconta>'||gene0002.fn_mask(rw_crapass.nrdconta,'9999.999.9')||'</nrdconta>'
                                     ||'  <nmresemp>'||SUBSTR(vr_tab_nmresemp(vr_tab_empresa(rw_crapass.nrdconta)),1,15)||'</nmresemp>'
                                     ||'  <cdsecext>'||gene0002.fn_mask(rw_crapass.cdsecext,'999')||'</cdsecext>'
                                     ||'  <nmsecext>'||RPAD(SUBSTR(vr_tab_dssecext(LPAD(rw_crapass.cdagenci,3,'0')||LPAD(rw_crapass.cdsecext,3,'0')),1,25),25,' ')||'</nmsecext>'
                                     ||'  <nrseqetq>'||gene0002.fn_mask(vr_nrseqetq,'z.zz9')||'</nrseqetq>'
                                     ||'</etiqueta>');
          END IF;

          -- Incrementar contador
          vr_nrseqetq := vr_nrseqetq + 1;

        END LOOP; -- Fim leitura dos associados

        -- Fechamos a tag da solicitação
        pc_escreve_clob(vr_clobxml,'</solicit>');

        -- Por fim, ativa a flag de solicitação impressa
        BEGIN
          UPDATE crapsol
             SET insitsol = 2
           WHERE rowid = rw_crapsol.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar erro e sair
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar a solicitação para impressa. Detalhes: '||sqlerrm;
            RAISE vr_exc_saida;
        END;

      END LOOP;

      -- Encerrar a tag raiz
      pc_escreve_clob(vr_clobxml,'</raiz>');

      -- Se encontrou alguma informação
      IF vr_flgachou THEN

        -- Busca do diretório base da cooperativa para a geração de relatórios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper);

        -- Submeter o relatório 237
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                       --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml                        --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/solicit/etiqueta'          --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl237.jasper'                  --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                              --> Parametros para montagem do arquivo
                                   ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl237.lst'  --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                               --> 132 colunas
                                   ,pr_flg_gerar => 'N'                               --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                               --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => 'etqcorreio'                      --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                 --> Número de cópias
                                   ,pr_sqcabrel  => 1                                 --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic);                     --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          vr_cdcritic := 0;
          RAISE vr_exc_saida;
        END IF;

        -- Gerar no Log o aviso para impressão das etiquetas
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Aviso
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || gene0001.fn_busca_critica(660) );


      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar commit final
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
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

  END pc_crps289;
/

