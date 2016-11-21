CREATE OR REPLACE PROCEDURE CECRED.
       PC_CRPS109(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                 ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                 ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                 ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                 ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN

    /*
    Programa: PC_CRPS109 (Antigo Fontes/crps109.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Odair
    Data    : Janeiro/95.                     Ultima atualizacao: 26/05/2014

    Dados referentes ao programa:

    Frequencia: Diario (Batch - Background).
    Objetivo  : Atende a solicitacao 1, ordem 91.
                Emite listagem das aplicacoes RDCA por agencia.

    Observacao: Para que haja o pedido de impressao do relatorio para a agencia
                devera existir a seguinte tabela CRED-GENERI-0-IMPREL089-agencia
                onde o texto da tabela informa os dias que deve ser impresso o
                relatorio.

    Alteracoes: 15/02/95 - Alterado para acumular o saldo e a quantidade das
                           aplicacoes na tabela CRED-GENERI-00-DESPESAMES-001
                           e atender a solicitacao 2 (Edson).

                29/05/95 - Alterado para  nao atualizar a solicitacao como pro-
                           cessada (Odair).

                17/07/95 - Incluido os totais para as aplicacoes com saldo nega-
                           tivo no total geral (Edson).

                04/12/95 - Alterado para imprimir 1 copia nos dias normais e
                           2 copias no mensal (Odair).

                19/03/96 - Alterado para imprimir por agencia selecionada
                           (Edson).

                09/07/96 - Alterado para imprimir tambem agencia 3 (Deborah).

                17/09/96 - Alterado para criar tabela para impressao dos
                           relatorios por agencia (Odair).

                22/11/96 - Tratar RDCAII (Odair).

                22/08/97 - Tirar linha entre as aplicacoes (Odair)

                18/02/98 - Apresentar totais por faixa RDCA60 (Odair)

                24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                29/12/1999 - Alterado para nao imprimir se nao houver aplica-
                             coes (Deborah).

                26/01/2000 - Gerar pedido de impressao (Deborah).

                03/10/2003 - Eliminada tabela de DESPESA (Deborah).

                17/10/2003 - Tratamento para calculo do VAR (Margarete).

                22/06/2004 - Incluidos os campos: RESGATES DO MES e TOTAL DE
                             RESGATES (Evandro).

                22/09/2004 - Incluidos historicos 492/494(CI)(Mirtes)

                03/02/2005 - Incluido log para listar aplicacoes com saldo
                             negativo(Mirtes)

                29/06/2005 - Alimentado campo cdcooper das tabelas crapvar e
                             craptab (Diego).

                06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                             "fontes/iniprg.p" por causa da "glb_cdcooper"
                             (Evandro).

                15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                31/03/2006 - Corrigir rotina de impressao do relatorio 89
                             (Junior).

                30/11/2006 - Melhoria de performance (Evandro).

                09/10/2007 - Mudar solicitacao de 86 para 1. Ordem de 9 para 91
                             Retira o new e o flgbatch (Magui).

                03/12/2007 - Substituir chamada da include aplicacao.i pela
                             BO b1wgen0004.i. (Sidnei - Precise).

                26/11/2010 - Retirar da sol 1 ordem 91 e colocar na sol 82
                             ordem 80.E na CECRED sol 82 ordem 83 (Magui).

                09/01/2013 - Conversão Progress >> Oracle PLSQL (Marcos-Supero)

                01/10/2013 - Correção de to_char(sysdate,'HH24:MM:SS') para
                             to_char(sysdate,'HH24:MI:SS') (Marcos-Supero)

                04/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                             das criticas e chamadas a fimprg.p (Marcos-Supero)

                10/12/2013 - Incluir alterações realizadas no Progress ( Renato - Supero )
                           - Alterado totalizador de PAs de 99 para 999. (Reinert)
                           
                07/02/2014 - Alterado a lógica de gravação na vr_vet_vlfaixas, pois 
                             quando não há nenhuma craptrd, estava sendo gerada a faxa 
                             extrema a aparecida no relatório "ACIMA ...", desneces-
                             sariamente (Marcos-Supero)
                           
                26/05/2014 - Nao utilizar mais a tabela CRAPVAR (desativacao da VAR). (Andrino-RKAM)

    ............................................................................. */

    /*  **************  Decisoes sobre o VAR  **********************************
        Rdca30 = carencia depois diario (usar taxa provisoria senao houver oficial)
                 quando dtdpagto = glb_dtmvtopr nao ha juros ja esta imbutido no saldo
        Rdca60 = carencia depois mensal (usar taxa provisoria senao houver oficial)
    **************************************************************************** */
    DECLARE
      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE;

      -- Tratamento de erros
      vr_exc_saida   exception;
      vr_exc_fimprg exception;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      /* Busca dos dados da cooperativa */
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrtelura
              ,cop.dsdircop
              ,cop.cdbcoctl
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      /* Cursor genérico de calendário */
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      /* Cursor genérico de parametrização */
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
              ,tab.ROWID
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND tab.nmsistem = pr_nmsistem
           AND tab.tptabela = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND tab.cdacesso = pr_cdacesso
           AND tab.tpregist = pr_tpregist;
      rw_craptab cr_craptab%ROWTYPE;

      -- Vetor para armazenamento das faixas a processar
      TYPE typ_tab_vlfaixas IS
        TABLE OF craptrd.vlfaixas%TYPE
        INDEX BY BINARY_INTEGER;
      vr_vet_vlfaixas typ_tab_vlfaixas;

      -- Busca de todas as faixas de taxas do RDCA
      CURSOR cr_craptrd IS
        SELECT trd.vlfaixas
          FROM craptrd trd
         WHERE trd.cdcooper = pr_cdcooper         --> Cooperativa logada
           AND trd.dtfimper = rw_crapdat.dtmvtolt --> Data atual
           AND trd.tptaxrda = 3                   --> Tipo de taxa 3 - RDCAII
           AND trd.incarenc = 0                   --> Sem carência
           AND trd.vlfaixas > 0                   --> Com faixa maior que zero
         GROUP BY trd.vlfaixas
         ORDER BY trd.vlfaixas;

      -- Busca das aplicações cadastradas de RDCA
      CURSOR cr_craprda IS
        SELECT rda.nrdconta
              ,rda.tpaplica
              ,rda.nraplica
              ,rda.dtmvtolt
              ,rda.vlaplica
              ,rda.vlsdrdca
              ,rda.inaniver
              ,rda.dtiniper
              ,rda.dtfimper
          FROM craprda rda
         WHERE rda.cdcooper = pr_cdcooper --> Coop logada
           AND rda.tpaplica IN(3,5)       --> Tipo de aplicação RDCA ou RDCAII
           AND rda.insaqtot = 0;          --> Não sacado totalmente

      -- Busca do associado
      CURSOR cr_crapass(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.cdsitdct
              ,ass.cdtipcta
              ,ass.cdagenci
              ,DECODE(ass.nrramemp,0,NULL,ass.nrramemp) nrramemp
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      -- Erros na gene0001.pc_gera_erro
      vr_des_reto     VARCHAR2(3);  --> Saída do método de cálculo de rendimentos
      vr_tab_erro     gene0001.typ_tab_erro; --> Tabela com erros da gene0001.pc_gera_erro

      -- Variáveis auxiliares para os rendimentos
      vr_apl_vlsldapl NUMBER(18,8); --> Saldo da aplicação
      vr_vlsldapl     NUMBER(18,8); --> Saldo da aplicação RDCA
      vr_apl_vlsaques NUMBER(18,8); --> Acumulador de saques
      vr_apl_txaplica NUMBER(18,8); --> Taxa da aplicação
      vr_vlsdrdca     NUMBER(18,8); --> Saldo da aplicação
      vr_vldperda     NUMBER(18,8); --> Valor calculado da perda
      vr_neg_qtaplica NUMBER;       --> Quantidade de aplicações negativas
      vr_neg_vlsldapl NUMBER(18,8); --> Valor das aplicações negativas
      -- Descrição para aplicações negativas
      vr_des_log_aplica VARCHAR2(4000);

      -- Busca dos lançamentos da aplicação com base numa data passada e numa lista de históricos
      CURSOR cr_craplap(pr_nraplica  IN craplap.nraplica%TYPE
                       ,pr_nrdconta  IN craplap.nrdconta%TYPE
                       ,pr_dtinicia  IN craplap.dtmvtolt%TYPE
                       ,pr_dttermin  IN craplap.dtmvtolt%TYPE
                       ,pr_lsthistor IN VARCHAR2) IS
        SELECT SUM(lap.vllanmto) vllanmto
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_nraplica
           AND lap.dtmvtolt >= pr_dtinicia
           AND lap.dtmvtolt <= pr_dttermin
           AND ','||pr_lsthistor||',' LIKE ('%,'||lap.cdhistor||',%'); --> Retornar históricos passados na listagem
      rw_craplap cr_craplap%ROWTYPE;

      -- Definição de Tipo para gravaçao dos dados
      -- das aplicações que gerarão o relatório final
      TYPE typ_reg_aplica IS
        RECORD (cdagenci crapass.cdagenci%TYPE
               ,nrdconta craprda.nrdconta%TYPE
               ,nraplica craprda.nraplica%TYPE
               ,tpaplica craprda.tpaplica%TYPE
               ,nrramemp crapass.nrramemp%TYPE
               ,dtmvtolt craprda.dtmvtolt%TYPE
               ,vlaplica craprda.vlaplica%TYPE
               ,inaniver craprda.inaniver%TYPE
               ,nmprimtl crapass.nmprimtl%TYPE
               ,apl_vlsaques NUMBER(14,2)
               ,apl_vlsldapl NUMBER(14,2)
               ,apl_txaplica NUMBER(7,6)
               ,apl_dsdacstp VARCHAR2(3));
      -- Definição da tabela que implementa
      -- registros com o tipo acima declarado
      TYPE typ_tab_aplica IS
        TABLE OF typ_reg_aplica
        INDEX BY VARCHAR2(17); --> Ag(3) + Cta(8) + Aplica(6)
      -- Por fim, um vetor para instanciar a tabela e suas informações
      vr_vet_aplica typ_tab_aplica;
      -- Variável para chaveamento (hash) da tabela de aplicações
      vr_des_chave VARCHAR2(17);

      -- Variáveis auxiliares para calculo do VAR
      vr_dtdpagto DATE;
      vr_dtiniper DATE;
      vr_vllanmto NUMBER(25,2);
      vr_tptaxvar craptrd.tptaxrda%TYPE;
      vr_txaplica NUMBER(18,8);
      vr_vlrendim NUMBER(18,8);

      -- Variaveis de retorno da APLI0001
      vr_sldpresg_tmp craplap.vllanmto%TYPE; --> Valor saldo de resgate
      vr_dup_vlsdrdca craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA

      -- Busca de taxas baseada num valor passado
      CURSOR cr_craptrd_faixa(pr_dtiniper IN craptrd.dtiniper%TYPE
                             ,pr_tptaxrda IN craptrd.tptaxrda%TYPE
                             ,pr_vlfaixas IN craptrd.vlfaixas%TYPE) IS
        SELECT trd.txofidia
              ,trd.txprodia
              ,COUNT (*) OVER ()
          FROM craptrd trd
         WHERE trd.cdcooper = pr_cdcooper   --> Cooperativa logada
           AND trd.dtiniper = pr_dtiniper   --> Data atual
           AND trd.tptaxrda = pr_tptaxrda   --> Tipo de taxa
           AND trd.incarenc = 0             --> Sem carência
           AND trd.vlfaixas <= pr_vlfaixas; --> Com faixa menor ou igual ao valor passado
      -- Busca de taxas baseada num valor passado sem a data
      CURSOR cr_craptrd_faixa_2(pr_tptaxrda IN craptrd.tptaxrda%TYPE
                               ,pr_vlfaixas IN craptrd.vlfaixas%TYPE) IS
        SELECT trd.txofidia
              ,trd.txprodia
          FROM craptrd trd
         WHERE trd.cdcooper = pr_cdcooper                   --> Cooperativa logada
           AND trd.tptaxrda = pr_tptaxrda                   --> Tipo de taxa
           AND trd.incarenc = 0                             --> Sem carência
           AND trd.vlfaixas <= pr_vlfaixas                  --> Com faixa menor ou igual ao valor passado
         ORDER BY trd.progress_recid DESC; --> Buscar o ultimo quando encontrar mais de um
      -- Variaveis de taxa que podem ser usadas nos dois cursores acima
      vr_txofidia craptrd.txofidia%TYPE;
      vr_txprodia craptrd.txprodia%TYPE;
      vr_qtdregis NUMBER;
      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT age.nmresage
          FROM crapage age
         WHERE age.cdcooper = pr_cdcooper
           AND age.cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;
      -- Variável para armazenar as informações em XML
      vr_des_xml CLOB;
      vr_apl_dsaplica VARCHAR2(11);
      vr_rel_dsaplica VARCHAR2(6);
      vr_apl_dsobserv VARCHAR2(20);
      vr_des_vlsldapl VARCHAR2(15);
      vr_des_txaplica VARCHAR2(10);
      -- Variável para o caminho e nome do arquivo base
      vr_nom_direto  VARCHAR2(200);
      vr_nom_arquivo VARCHAR2(200);
      -- Definição de Tipo para somatório dos totais
      TYPE typ_reg_total IS
        RECORD (apl_dstotal  VARCHAR2(30)
               ,apl_dsaplica VARCHAR2(6)
               ,apl_dsfaixa  VARCHAR2(20)
               ,apl_qtdaplic NUMBER
               ,apl_vlsaques NUMBER(14,2)
               ,apl_vlsldapl NUMBER(14,2));
      -- Definição da tabela que implementa
      -- registros com o tipo acima declarado
      TYPE typ_tab_total IS
        TABLE OF typ_reg_total
        INDEX BY VARCHAR2(8); --> TipoAplica(6) + Faixa(2)
      -- Por fim, um vetor para instanciar a tabela e suas informações
      vr_vet_total typ_tab_total;
      -- Variável para chaveamento (hash) da tabela de totais
      vr_des_chave_tot VARCHAR2(8);
      -- Por fim, um vetor para totalizador geral
      vr_vet_total_geral typ_tab_total;
      -- Variáveis para guardar a configuração de impressão(Imprim.p)
      vr_flimprim VARCHAR2(1);  --> Chamar a impressão (Imprim.p)
      vr_nmformul VARCHAR2(10); --> Nome do formulário para impressão
      vr_nrcopias NUMBER(2);    --> Número de cópias
      -- Sufixo para relatórios gerais das agencias
      vr_dssuftot  CONSTANT crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL');
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
    BEGIN
      -- Código do programa
      vr_cdprogra := 'CRPS109';
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS109'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
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

      -- Validações iniciais do programa
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

      -- Busca de todas as faixas de taxas do RDCA
      vr_vet_vlfaixas.DELETE;
      FOR rw_craptrd IN cr_craptrd LOOP
        -- Incluir a faixa no vetor das faixas processáveis
        vr_vet_vlfaixas(vr_vet_vlfaixas.COUNT()+1) := rw_craptrd.vlfaixas;
      END LOOP;
      -- Se encontramos pelo menos uma faixa
      IF vr_vet_vlfaixas.COUNT > 0 THEN
        -- Adicionar o limite extremo nas faixas
        vr_vet_vlfaixas(vr_vet_vlfaixas.COUNT()+1) := 999999999;
      END IF;  

      -- Chamar rotina que atualiza o vetor vr_faixa_ir_rdca pois
      -- precisaremos dele atualizado mais abaixo
      apli0001.pc_busca_faixa_ir_rdca(pr_cdcooper => pr_cdcooper);
      -- Incialização dos controladores de aplicações negativas
      vr_neg_qtaplica := 0;
      vr_neg_vlsldapl := 0;
      -- Reinicar temp-table
      vr_vet_aplica.DELETE;

      -- Busca das aplicações cadastradas de RDCA
      FOR rw_craprda IN cr_craprda LOOP
        -- Reiniciar contador de saques
        vr_apl_vlsaques := 0;
        vr_apl_vlsldapl := 0;
        vr_vlsdrdca     := 0;
        -- Calcular o Saldo da aplicacao ate a data do movimento
        -- de acordo com o tipo de aplicação do registro
        IF rw_craprda.tpaplica = 3 THEN --> RDCA
          -- Consultar o saldo da aplicação
          apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                               ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Próximo dia util
                                               ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                               ,pr_cdagenci => 1                   --> Código da agência
                                               ,pr_nrdcaixa => 999                 --> Número do caixa
                                               ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                               ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                               ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação
                                               ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicação RDCA
                                               ,pr_sldpresg => vr_sldpresg_tmp     --> Valor saldo de resgate
                                               ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                               ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                               ,pr_txaplica => vr_apl_txaplica     --> TAxa utilizada
                                               ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
          -- Se retornar erro
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            ELSE
              vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informação na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            END IF;
            -- Levantar exceção
            RAISE vr_exc_saida;
          END IF;
          -- Guardar o saldo da aplicação calculado
          vr_apl_vlsldapl := vr_vlsdrdca;
          -- Se o saldo da aplicação for negativo
          IF vr_apl_vlsldapl < 0 THEN
            -- Acumular a quantidade de aplicações negativas
            vr_neg_qtaplica := vr_neg_qtaplica+1;
            -- Acumular esta aplicação no saldo de aplicações negativas
            vr_neg_vlsldapl := vr_neg_vlsldapl + vr_apl_vlsldapl;
            -- Montar mensagem para avisar sobre a aplicação negativa
            vr_des_log_aplica := to_char(sysdate,'HH24:MI:SS')
                              || ' - Aplic.Saldo Negativo --> '
                              || ' Conta: '||gene0002.fn_mask_conta(rw_craprda.nrdconta)
                              || ' Aplicacao: '||gene0002.fn_mask(rw_craprda.nraplica,'zzz.zz9')
                              || ' Valor: '|| to_char(vr_vlsdrdca,'999g999g999g990d00');
            -- Escrever no log específico do crps109
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 --> Normal
                                      ,pr_des_log      => vr_des_log_aplica
                                      ,pr_nmarqlog     => vr_cdprogra);
          END IF;
          -- Buscar todos os lançamenos de resgate desta aplicação
          FOR rw_craplap IN cr_craplap(pr_nraplica  => rw_craprda.nraplica
                                      ,pr_nrdconta  => rw_craprda.nrdconta
                                      ,pr_dtinicia  => rw_crapdat.dtinimes --> Primeiro dia mês corrente
                                      ,pr_dttermin  => rw_crapdat.dtmvtolt --> Data atual
                                      ,pr_lsthistor => '118,492') LOOP --> Resgates
            -- Acumular para cada resgate
            vr_apl_vlsaques := vr_apl_vlsaques + NVL(rw_craplap.vllanmto,0);
          END LOOP;
        ELSIF rw_craprda.tpaplica = 5 THEN --> RDCAII
          -- Rotina de calculo do aniversario do RDCA2
          apli0001.pc_calc_aniver_rdca2c(pr_cdcooper => pr_cdcooper  --> Cooperativa
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                        ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                        ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                        ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação pós cálculo
                                        ,pr_des_erro => vr_dscritic);       --> Saida com com erros;
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_saida;
          END IF;
          -- Guardar o saldo da aplicação calculado
          vr_apl_vlsldapl := vr_vlsdrdca;
          -- Utilizar como taxa zero
          vr_apl_txaplica := 0;
          -- Buscar todos os lançamenos de resgate desta aplicação
          FOR rw_craplap IN cr_craplap(pr_nraplica  => rw_craprda.nraplica
                                      ,pr_nrdconta  => rw_craprda.nrdconta
                                      ,pr_dtinicia  => rw_crapdat.dtinimes --> Primeiro dia mês corrente
                                      ,pr_dttermin  => rw_crapdat.dtmvtolt --> Data atual
                                      ,pr_lsthistor => '178,494') LOOP --> Resgates
            -- Acumular para cada resgate
            vr_apl_vlsaques := vr_apl_vlsaques + NVL(rw_craplap.vllanmto,0);
          END LOOP;
        END IF; -- Fim cfme tipo de aplicação
        -- Somente adicioná-la se o saldo da aplicação for superior a zero
        IF vr_apl_vlsldapl > 0 THEN
          -- Buscar informações do associado
          OPEN cr_crapass(rw_craprda.nrdconta);
          FETCH cr_crapass
           INTO rw_crapass;
          -- Se não encontrar
          IF cr_crapass%NOTFOUND THEN
            -- Gerar crítica 251 e abortar a cadeia
            CLOSE cr_crapass;
            vr_cdcritic := 251;
            RAISE vr_exc_saida;
          ELSE
            -- Apenas fechar o cursor para continuar
            CLOSE cr_crapass;
          END IF;
          -- Criar chave da aplicação para gravação na tabela de aplicações
          -- Agencia (999) + Conta (99999999) + Aplicação (999999)
          vr_des_chave := to_char(rw_crapass.cdagenci,'fm000')
                       || to_char(rw_craprda.nrdconta,'fm00000000')
                       || to_char(rw_craprda.nraplica,'fm000000');
          -- Criar registro na tabela de aplicações
          vr_vet_aplica(vr_des_chave).cdagenci := rw_crapass.cdagenci;
          vr_vet_aplica(vr_des_chave).nrdconta := rw_craprda.nrdconta;
          vr_vet_aplica(vr_des_chave).nraplica := rw_craprda.nraplica;
          vr_vet_aplica(vr_des_chave).tpaplica := rw_craprda.tpaplica;
          vr_vet_aplica(vr_des_chave).nrramemp := rw_crapass.nrramemp;
          vr_vet_aplica(vr_des_chave).dtmvtolt := rw_craprda.dtmvtolt;
          vr_vet_aplica(vr_des_chave).vlaplica := rw_craprda.vlaplica;
          vr_vet_aplica(vr_des_chave).inaniver := rw_craprda.inaniver;
          vr_vet_aplica(vr_des_chave).nmprimtl := rw_crapass.nmprimtl;
          vr_vet_aplica(vr_des_chave).apl_vlsaques := vr_apl_vlsaques;
          vr_vet_aplica(vr_des_chave).apl_vlsldapl := vr_apl_vlsldapl;
          vr_vet_aplica(vr_des_chave).apl_txaplica := vr_apl_txaplica;
          vr_vet_aplica(vr_des_chave).apl_dsdacstp := to_char(rw_crapass.cdsitdct,'fm0') || to_char(rw_crapass.cdtipcta,'fm00');
          -- Criando base para calculo do VAR --
          -- Inicializando as variaveis
          vr_dtdpagto := null;
          vr_dtiniper := null;
          vr_vllanmto := 0;
          vr_tptaxvar := 0;
          -- Para aplicação RDCA
          IF rw_craprda.tpaplica = 3 THEN
            -- Tipo da taxa fixo 1
            vr_tptaxvar := 1;
            -- Lançamento recebe o saldo da aplicação
            vr_vllanmto := vr_apl_vlsldapl;
            -- Se ainda não completou aniversário
            IF rw_craprda.inaniver = 0 THEN
              -- Data são baseadas no período da aplicação
              vr_dtdpagto := rw_craprda.dtfimper;
              vr_dtiniper := rw_craprda.dtiniper;
              vr_vllanmto := vr_apl_vlsldapl;
            ELSE
              -- Data serão baseadas no próximo movimento util
              vr_dtiniper := rw_crapdat.dtmvtopr;
              vr_dtdpagto := rw_crapdat.dtmvtopr;
            END IF;
          ELSE
            -- Tipo de taxa fixo 3
            vr_tptaxvar := 3;
            -- Se ainda não completou aniversário
            IF rw_craprda.inaniver = 0 THEN
              -- Se a data de movimentação da aplicação for
              -- diferente do dia de início da mesma
              IF rw_craprda.dtmvtolt <> rw_craprda.dtiniper THEN
                -- Data são baseadas no período da aplicação
                vr_dtdpagto := rw_craprda.dtfimper;
                vr_dtiniper := rw_craprda.dtiniper;
                -- Lançamento igual ao saldo da aplicação
                vr_vllanmto := vr_apl_vlsldapl;
              ELSE
                -- Adicionar 2 meses na data de início da aplicação
                -- para utilizar como data de lançamento
                vr_dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_craprda.dtiniper --> Data do movimento
                                                    ,pr_qtmesano => 2                   --> Quantidade a acumular
                                                    ,pr_tpmesano => 'M'                 --> Tipo Mes ou Ano
                                                    ,pr_des_erro => vr_dscritic);
                -- Início do período baseia-se na data de movimentação da aplicação
                vr_dtiniper := rw_craprda.dtmvtolt;
                -- Se o saldo da aplicação for diferente de zero
                IF rw_craprda.vlsdrdca <> 0 THEN
                  -- Utilizaremos o mesmo para lançar
                  vr_vllanmto := rw_craprda.vlsdrdca;
                ELSE
                  -- Utilizaremos o valor da aplicação
                  vr_vllanmto := rw_craprda.vlaplica;
                END IF;
              END IF;
            ELSE
              -- Data são baseadas no período da aplicação
              vr_dtdpagto := rw_craprda.dtfimper;
              vr_dtiniper := rw_craprda.dtiniper;
              -- Lançamento igual ao saldo da aplicação
              vr_vllanmto := vr_apl_vlsldapl;
            END IF;
          END IF;
          -- Se por algum motivo, a data de início não estiver com valor
          IF vr_dtiniper IS NULL THEN
            -- Gerar crítica 347 no log
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '
                                                       || gene0001.fn_busca_critica(347)|| ' DATA '||to_char(vr_dtiniper,'dd/mm/yyyy')
                                                       || ' CONTA '||to_char(rw_craprda.nrdconta)||' APLIC '||to_char(rw_craprda.nraplica));
            -- Ignorar o restante do processo
            CONTINUE;
          END IF;
          -- Garantir que a data de pagamento seja maior ou igual
          -- ao próximo dia util de movimento
          IF vr_dtdpagto < rw_crapdat.dtmvtopr THEN
            vr_dtdpagto := rw_crapdat.dtmvtopr;
          END IF;
          -- Busca de taxas baseada no valor encontrado e nas datas montadas anteriormente
          vr_txofidia := NULL;
          vr_txprodia := NULL;
          vr_qtdregis := 0;
          OPEN cr_craptrd_faixa(pr_dtiniper => vr_dtiniper
                               ,pr_tptaxrda => vr_tptaxvar
                               ,pr_vlfaixas => vr_vllanmto);
          FETCH cr_craptrd_faixa
           INTO vr_txofidia
               ,vr_txprodia
               ,vr_qtdregis;
          -- Se não encontrar ou existir mais de 1 registro
          IF cr_craptrd_faixa%NOTFOUND OR vr_qtdregis > 1 THEN
            -- Fechar o cursor
            CLOSE cr_craptrd_faixa;
            -- Buscar novamente só que sem a data de início do período
            OPEN cr_craptrd_faixa_2(pr_tptaxrda => vr_tptaxvar
                                   ,pr_vlfaixas => vr_vllanmto);
            FETCH cr_craptrd_faixa_2
             INTO vr_txofidia
                 ,vr_txprodia;
            -- Se mesmo assim não encontrar
            IF cr_craptrd_faixa_2%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_craptrd_faixa;
              -- Gerar crítica 347 no log
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '
                                                         || gene0001.fn_busca_critica(347)|| ' DATA '||to_char(vr_dtiniper,'dd/mm/yyyy')
                                                         || ' CONTA '||to_char(rw_craprda.nrdconta)||' APLIC '||to_char(rw_craprda.nraplica));
              -- Ignorar o restante do processo
              CONTINUE;
            ELSE
              -- Apenas fechar o cursor
              CLOSE cr_craptrd_faixa_2;
            END IF;
          ELSE
            -- Encontrou, então apenas fechar o cursor
            CLOSE cr_craptrd_faixa;
          END IF;
          -- Utilizar a taxa taxa do dia, e se não tiver do próximo
          IF vr_txofidia > 0 THEN
            vr_txaplica := (vr_txofidia / 100);
          -- Se tiver taxa no próximo dia
          ELSIF vr_txprodia > 0 THEN
            vr_txaplica := (vr_txprodia / 100);
          ELSE
            -- Se mesmo assim não encontrar, então enviamos a
            -- crítica 427 ao Log do processo Oracle
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '|| vr_cdprogra || ' --> '
                                                       || gene0001.fn_busca_critica(427)|| ' DATA '||to_char(vr_dtiniper,'dd/mm/yyyy')
                                                       || ' CONTA '||to_char(rw_craprda.nrdconta)||' APLIC '||to_char(rw_craprda.nraplica));
            -- Ignorar o restante do processo
            CONTINUE;
          END IF;
          -- Novamente carregar a variavel de saldo da aplicaçao, com
          -- base na vr_vllanmto que carregamos acima
          vr_apl_vlsldapl := vr_vllanmto;
          -- Buscar todos os dias uteis entre as datas encontradas acima
          LOOP
            -- Validar se a data inicial é util e se não for trazer a primeira após
            vr_dtiniper := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                      ,pr_dtmvtolt => vr_dtiniper);
            -- Continuar enquanto a data inicial for inferior a data para pagto
            EXIT WHEN vr_dtiniper >= vr_dtdpagto;
            -- Acumular os rendimentos com base no saldo * taxa encontrada
            vr_vlrendim := TRUNC((vr_apl_vlsldapl * vr_txaplica),8);
            -- Acumular no saldo o rendimento calculado
            vr_apl_vlsldapl := vr_apl_vlsldapl + vr_vlrendim;
            -- Incrementar mais um dia na data auxiliar para processar o próximo dia
            vr_dtiniper := vr_dtiniper + 1;
          END LOOP; --> Fim da do calculos nos dias uteis
        END IF;
      END LOOP; -- Fim das aplicações de RDCA
      -- Iremos criar o vetor de registros totais geral
      -- Recriar a tabela que sumariza as aplicações por tipo e faixa
      vr_vet_total_geral.DELETE;
      -- Criar o registro para a aplicação RDCA com faixa 0, pois não terá faixas
      vr_vet_total_geral('RDCA  00').apl_dstotal  := 'TOTAL LISTADOS    ==>';
      vr_vet_total_geral('RDCA  00').apl_dsaplica := 'RDCA';
      vr_vet_total_geral('RDCA  00').apl_dsfaixa  := NULL;
      vr_vet_total_geral('RDCA  00').apl_qtdaplic := 0;
      vr_vet_total_geral('RDCA  00').apl_vlsaques := 0;
      vr_vet_total_geral('RDCA  00').apl_vlsldapl := 0;
      -- Para o RDCA60, criaremos o registro RDCA60 com faixa 00 para o registro base
      vr_vet_total_geral('RDCA6000').apl_dstotal  := NULL;
      vr_vet_total_geral('RDCA6000').apl_dsaplica := 'RDCA60';
      vr_vet_total_geral('RDCA6000').apl_dsfaixa  := NULL;
      vr_vet_total_geral('RDCA6000').apl_qtdaplic := 0;
      vr_vet_total_geral('RDCA6000').apl_vlsaques := 0;
      vr_vet_total_geral('RDCA6000').apl_vlsldapl := 0;
      -- E também criaremos pra cada faixa da tabela de valores
      FOR vr_ind IN 1..vr_vet_vlfaixas.COUNT LOOP
        vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_dstotal  := NULL;
        vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsaplica := NULL;
        -- No ultimo a descrição é apenas "ACIMA"
        IF vr_ind = vr_vet_vlfaixas.COUNT THEN
          vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsfaixa  := ' ACIMA:';
        ELSE
          vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsfaixa  := ' ATE '||to_char(vr_vet_vlfaixas(vr_ind),'999g999g990d00');
        END IF;
        vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_qtdaplic := 0;
        vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsaques := NULL;
        vr_vet_total_geral('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsldapl := 0;
      END LOOP;
      -- Criamos um registro em branco, pois precisaremos de um espaço para listar o total negativo
      vr_vet_total_geral('ZZZZZZ01').apl_dstotal  := NULL;
      vr_vet_total_geral('ZZZZZZ01').apl_dsaplica := NULL;
      vr_vet_total_geral('ZZZZZZ01').apl_dsfaixa  := NULL;
      vr_vet_total_geral('ZZZZZZ01').apl_qtdaplic := NULL;
      vr_vet_total_geral('ZZZZZZ01').apl_vlsaques := NULL;
      vr_vet_total_geral('ZZZZZZ01').apl_vlsldapl := NULL;
      -- Por fim, criamos um registro para o total negativo já passando seus
      -- valores pois temos os mesmos acumulados na rotina anterior
      vr_vet_total_geral('ZZZZZZ02').apl_dstotal  := 'TOTAL NEGATIVOS   ==>';
      vr_vet_total_geral('ZZZZZZ02').apl_dsaplica := NULL;
      vr_vet_total_geral('ZZZZZZ02').apl_dsfaixa  := NULL;
      vr_vet_total_geral('ZZZZZZ02').apl_qtdaplic := vr_neg_qtaplica;
      vr_vet_total_geral('ZZZZZZ02').apl_vlsaques := NULL;
      vr_vet_total_geral('ZZZZZZ02').apl_vlsldapl := vr_neg_vlsldapl;
      -- Busca do diretório base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
      -- Nome base do arquivo é crrl089_
      vr_nom_arquivo := 'crrl089';
      -- Processar todos os registros das aplicações montadas acima
      vr_des_chave := vr_vet_aplica.FIRST;
      LOOP
        -- Sair quando a chave atual for null (chegou no final)
        EXIT WHEN vr_des_chave IS NULL;
        -- Se estivermos processando o primeiro registro do vetor ou mudou a agência
        IF vr_des_chave = vr_vet_aplica.FIRST OR vr_vet_aplica(vr_des_chave).cdagenci <> vr_vet_aplica(vr_vet_aplica.PRIOR(vr_des_chave)).cdagenci THEN
          -- Inicializar o CLOB
          dbms_lob.createtemporary(vr_des_xml, TRUE);
          dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
          -- Inicilizar as informações do XML
          pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><agencias>');
          -- Buscar nome da agência
          vr_nmresage := NULL;
          OPEN cr_crapage(pr_cdagenci => vr_vet_aplica(vr_des_chave).cdagenci);
          FETCH cr_crapage
           INTO vr_nmresage;
          CLOSE cr_crapage;
          -- Adicionar o nó da agência e já iniciar o de aplicações
          pc_escreve_xml('<agencia cdagenci="'||vr_vet_aplica(vr_des_chave).cdagenci||'">
                            <nmresage>'||vr_nmresage||'</nmresage>
                            <aplicacoes>');
          -- Recriar a tabela que sumariza as aplicações por tipo e faixa
          vr_vet_total.DELETE;
          -- Criar o registro para a aplicação RDCA com faixa 0, pois não terá faixas
          vr_vet_total('RDCA  00').apl_dstotal  := 'TOTAL DA AGENCIA  ==>';
          vr_vet_total('RDCA  00').apl_dsaplica := 'RDCA';
          vr_vet_total('RDCA  00').apl_dsfaixa  := NULL;
          vr_vet_total('RDCA  00').apl_qtdaplic := 0;
          vr_vet_total('RDCA  00').apl_vlsaques := 0;
          vr_vet_total('RDCA  00').apl_vlsldapl := 0;
          -- Para o RDCA60, criaremos o registro RDCA60 com faixa 00 para o registro base
          vr_vet_total('RDCA6000').apl_dstotal  := NULL;
          vr_vet_total('RDCA6000').apl_dsaplica := 'RDCA60';
          vr_vet_total('RDCA6000').apl_dsfaixa  := NULL;
          vr_vet_total('RDCA6000').apl_qtdaplic := 0;
          vr_vet_total('RDCA6000').apl_vlsaques := 0;
          vr_vet_total('RDCA6000').apl_vlsldapl := 0;
          -- E também criaremos pra cada faixa da tabela de valores
          FOR vr_ind IN 1..vr_vet_vlfaixas.COUNT LOOP
            vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_dstotal  := NULL;
            vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsaplica := NULL;
            -- No ultimo a descrição é apenas "ACIMA"
            IF vr_ind = vr_vet_vlfaixas.COUNT THEN
              vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsfaixa  := ' ACIMA:';
            ELSE
              vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_dsfaixa  := ' ATE '||to_char(vr_vet_vlfaixas(vr_ind),'999g999g990d00');
            END IF;
            vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_qtdaplic := 0;
            vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsaques := NULL;
            vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsldapl := 0;
          END LOOP;
        END IF;
        -- Processar informações para cada tipo de aplicação
        IF vr_vet_aplica(vr_des_chave).tpaplica = 3 THEN
          vr_rel_dsaplica := 'RDCA';
          -- Acumular a aplicação atual no vetor de totalizadores do registro base
          vr_vet_total('RDCA  00').apl_qtdaplic := vr_vet_total('RDCA  00').apl_qtdaplic + 1;
          vr_vet_total('RDCA  00').apl_vlsaques := vr_vet_total('RDCA  00').apl_vlsaques + vr_vet_aplica(vr_des_chave).apl_vlsaques;
          vr_vet_total('RDCA  00').apl_vlsldapl := vr_vet_total('RDCA  00').apl_vlsldapl + vr_vet_aplica(vr_des_chave).apl_vlsldapl;
        ELSE
          vr_rel_dsaplica := 'RDCA60';
          -- Acumular a aplicação atual no vetor de totalizadores do registro base
          vr_vet_total('RDCA6000').apl_qtdaplic := vr_vet_total('RDCA6000').apl_qtdaplic + 1;
          vr_vet_total('RDCA6000').apl_vlsaques := vr_vet_total('RDCA6000').apl_vlsaques + vr_vet_aplica(vr_des_chave).apl_vlsaques;
          vr_vet_total('RDCA6000').apl_vlsldapl := vr_vet_total('RDCA6000').apl_vlsldapl + vr_vet_aplica(vr_des_chave).apl_vlsldapl;
          -- Buscar em qual faixa esta aplicação se enquadra
          FOR vr_ind IN 1..vr_vet_vlfaixas.COUNT LOOP
            -- Se o valor desta aplicação é inferior ou igual ao valor da faixa
            IF vr_vet_aplica(vr_des_chave).apl_vlsldapl < vr_vet_vlfaixas(vr_ind) THEN
              -- Acumular os dados na posição atual
              vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_qtdaplic := vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_qtdaplic + 1;
              vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsldapl := vr_vet_total('RDCA60'||LPAD(vr_ind,2,'0')).apl_vlsldapl + vr_vet_aplica(vr_des_chave).apl_vlsldapl;
              -- Sair do LOOP
              EXIT;
            END IF;
          END LOOP;
        END IF;
        -- Descrição da aplicação
        vr_apl_dsaplica := gene0002.fn_mask(vr_vet_aplica(vr_des_chave).nraplica,'zzz.zz9')||'/001';
        -- Montar descrição da observação cfme o aniversário
        IF vr_vet_aplica(vr_des_chave).inaniver = 0 THEN
          vr_apl_dsobserv := 'NAO DISPONIVEL';
        ELSE
          vr_apl_dsobserv := ' ';
        END IF;
        -- Se o saldo da aplicação for superior a zero
        IF vr_vet_aplica(vr_des_chave).apl_vlsldapl > 0 THEN
          -- Enviá-lo e formatar com a mascara
          vr_des_vlsldapl := to_char(vr_vet_aplica(vr_des_chave).apl_vlsldapl,'fm999g999g990d00');
        ELSE
          -- Não enviar nada
          vr_des_vlsldapl := NULL;
        END IF;
        -- Se a taxa da aplicação for superior a zero
        IF vr_vet_aplica(vr_des_chave).apl_txaplica > 0 THEN
          -- Enviá-la e formatar a informação
          vr_des_txaplica := to_char(vr_vet_aplica(vr_des_chave).apl_txaplica,'fm90d000000');
        ELSE
          -- Não enviar nada
          vr_des_txaplica := NULL;
        END IF;
        pc_escreve_xml('<aplicacao id="'||vr_des_chave||'">
                         <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_vet_aplica(vr_des_chave).nrdconta))||'</nrdconta>
                         <apl_dsdacstp>'||vr_vet_aplica(vr_des_chave).apl_dsdacstp||'</apl_dsdacstp>
                         <apl_nmprimtl>'||SUBSTR(vr_vet_aplica(vr_des_chave).nmprimtl,1,25)||'</apl_nmprimtl>
                         <apl_nrramemp>'||vr_vet_aplica(vr_des_chave).nrramemp||'</apl_nrramemp>
                         <apl_dsaplica>'||LTRIM(vr_apl_dsaplica)||'</apl_dsaplica>
                         <rel_dsaplica>'||vr_rel_dsaplica||'</rel_dsaplica>
                         <apl_dtaplica>'||to_char(vr_vet_aplica(vr_des_chave).dtmvtolt,'dd/mm/yyyy')||'</apl_dtaplica>
                         <apl_vlaplica>'||to_char(vr_vet_aplica(vr_des_chave).vlaplica,'fm999g999g990d00')||'</apl_vlaplica>
                         <apl_vlsldapl>'||vr_des_vlsldapl||'</apl_vlsldapl>
                         <apl_txaplica>'||vr_des_txaplica||'</apl_txaplica>
                         <apl_dsobserv>'||vr_apl_dsobserv||'</apl_dsobserv>
                         <apl_vlsaques>'||to_char(vr_vet_aplica(vr_des_chave).apl_vlsaques,'fm999g999g990d00')||'</apl_vlsaques>
                       </aplicacao>');
        -- Se este for o ultimo registro do vetor, ou da agência
        IF vr_des_chave = vr_vet_aplica.LAST OR vr_vet_aplica(vr_des_chave).cdagenci <> vr_vet_aplica(vr_vet_aplica.NEXT(vr_des_chave)).cdagenci THEN
          -- Finalizar o agrupador de aplicações e Adicionar o nó com de totais
          pc_escreve_xml('</aplicacoes><totais>');
          -- Adicionaremos os registros de totais no XML, percorrendo o vetor de totais
          vr_des_chave_tot := vr_vet_total.FIRST;
          LOOP
            -- Sair quando não existirem mais registros no vetor
            EXIT WHEN vr_des_chave_tot IS NULL;
            -- Adicionar o nó com de totais
            pc_escreve_xml('<total id="'||vr_des_chave_tot||'">
                             <apl_dstotal>'||vr_vet_total(vr_des_chave_tot).apl_dstotal||'</apl_dstotal>
                             <apl_dsaplica>'||vr_vet_total(vr_des_chave_tot).apl_dsaplica||'</apl_dsaplica>
                             <apl_dsfaixa>'||vr_vet_total(vr_des_chave_tot).apl_dsfaixa||'</apl_dsfaixa>
                             <apl_qtdaplic>'||to_char(vr_vet_total(vr_des_chave_tot).apl_qtdaplic,'fm999g999g990')||'</apl_qtdaplic>
                             <apl_vlsaques>'||to_char(vr_vet_total(vr_des_chave_tot).apl_vlsaques,'fm999g999g990d00')||'</apl_vlsaques>
                             <apl_vlsldapl>'||to_char(vr_vet_total(vr_des_chave_tot).apl_vlsldapl,'fm999g999g990d00')||'</apl_vlsldapl>
                           </total>');
            -- Acumular o valor no vetor total, usando a mesma chave, pois gravamos-as igualmente
            vr_vet_total_geral(vr_des_chave_tot).apl_qtdaplic := vr_vet_total_geral(vr_des_chave_tot).apl_qtdaplic + vr_vet_total(vr_des_chave_tot).apl_qtdaplic;
            vr_vet_total_geral(vr_des_chave_tot).apl_vlsaques := vr_vet_total_geral(vr_des_chave_tot).apl_vlsaques + vr_vet_total(vr_des_chave_tot).apl_vlsaques;
            vr_vet_total_geral(vr_des_chave_tot).apl_vlsldapl := vr_vet_total_geral(vr_des_chave_tot).apl_vlsldapl + vr_vet_total(vr_des_chave_tot).apl_vlsldapl;
            -- Busca o próximo total
            vr_des_chave_tot := vr_vet_total.NEXT(vr_des_chave_tot);
          END LOOP;
          -- Fechar a tag de totais e agências depois
          pc_escreve_xml('</totais></agencia></agencias>');
          -- No processo mensal imprimir todas as agencias
          IF TRUNC(rw_crapdat.dtmvtolt,'mm') <> TRUNC(rw_crapdat.dtmvtopr,'mm') THEN
            -- Pode imprimir, então configura as variáveis
            vr_flimprim := 'S';
            vr_nmformul := '234dh';
            vr_nrcopias := 1;
          ELSE
            -- Buscar qual o dia configurado para impressão
            -- do 89 desta agência na cooperativa conectada
            rw_craptab := NULL;
            OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                           ,pr_nmsistem => 'CRED'
                           ,pr_tptabela => 'GENERI'
                           ,pr_cdempres => 0
                           ,pr_cdacesso => 'IMPREL089'
                           ,pr_tpregist => vr_vet_aplica(vr_des_chave).cdagenci);
            FETCH cr_craptab
             INTO rw_craptab;
            CLOSE cr_craptab;
            -- Se está configurado a impressão no dia atual
            IF INSTR(NVL(rw_craptab.dstextab,'0'),to_char(rw_crapdat.dtmvtolt,'d')) > 0 THEN
              -- Pode imprimir, então configura as variáveis
              vr_flimprim := 'S';
              vr_nmformul := '234dh';
              vr_nrcopias := 1;
            ELSE
              -- Não imprimir, apenas gerar o lst no rl
              vr_flimprim := 'N';
              vr_nmformul := NULL;
              vr_nrcopias := NULL;
            END IF;
          END IF;
          -- Efetuar solicitação de geração de relatório --
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/agencias/agencia[@cdagenci='||vr_vet_aplica(vr_des_chave).cdagenci||']' --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl089.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => 'PR_CDAGENCI##'||vr_vet_aplica(vr_des_chave).cdagenci --> Enviar como parâmetro apenas a agência
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'_'||to_char(vr_vet_aplica(vr_des_chave).cdagenci,'fm000')||'.lst' --> Arquivo final com código da agência
                                     ,pr_qtcoluna  => 234                 --> 234 colunas
                                     ,pr_flg_impri => vr_flimprim         --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => vr_nmformul         --> Nome do formulário para impressão
                                     ,pr_nrcopias  => vr_nrcopias         --> Número de cópias
                                     ,pr_des_erro  => vr_dscritic);       --> Saída com erro
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_des_xml);
          dbms_lob.freetemporary(vr_des_xml);
        END IF;
        -- Buscar o próximo registro da tabela
        vr_des_chave := vr_vet_aplica.NEXT(vr_des_chave);
      END LOOP;
      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Incializar o arquivo XML novamente para a agência 99
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><agencias>');
      -- Ao terminar de ler todas as agência, gerar o registro da agência 99 (Totalizadora)
      pc_escreve_xml('<agencia cdagenci="99">
                        <nmresage>AGENCIA TOTALIZADORA</nmresage>
                        <aplicacoes/>
                        <totais>');
      -- Adicionaremos os registros de totais no XML, percorrendo o vetor de totais
      vr_des_chave_tot := vr_vet_total_geral.FIRST;
      LOOP
        -- Sair quando não existirem mais registros no vetor
        EXIT WHEN vr_des_chave_tot IS NULL;
        -- Adicionar o nó com os dados de total
        pc_escreve_xml('<total id="'||vr_des_chave_tot||'">
                          <apl_dstotal>'||vr_vet_total_geral(vr_des_chave_tot).apl_dstotal||'</apl_dstotal>
                          <apl_dsaplica>'||vr_vet_total_geral(vr_des_chave_tot).apl_dsaplica||'</apl_dsaplica>
                          <apl_dsfaixa>'||vr_vet_total_geral(vr_des_chave_tot).apl_dsfaixa||'</apl_dsfaixa>
                          <apl_qtdaplic>'||to_char(vr_vet_total_geral(vr_des_chave_tot).apl_qtdaplic,'fm999g999g990')||'</apl_qtdaplic>
                          <apl_vlsaques>'||to_char(vr_vet_total_geral(vr_des_chave_tot).apl_vlsaques,'fm999g999g990d00')||'</apl_vlsaques>
                          <apl_vlsldapl>'||to_char(vr_vet_total_geral(vr_des_chave_tot).apl_vlsldapl,'fm999g999g990d00')||'</apl_vlsldapl>
                        </total>');
        -- Busca o próximo total
        vr_des_chave_tot := vr_vet_total_geral.NEXT(vr_des_chave_tot);
      END LOOP;
      -- Finalizar o XML
      pc_escreve_xml('</totais></agencia></agencias>');
      -- Ao terminar de ler os registros, iremos gravar o XML para arquivo totalizador--
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/agencias/agencia[@cdagenci=99]' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl089.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => 'PR_CDAGENCI##99'   --> Enviar como parâmetro apenas a agência
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'_'||vr_dssuftot||'.lst' --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 234                 --> 234 colunas
                                 ,pr_flg_impri => 'S'                --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                  --> Número de cópias
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      -- Limpar as temp-tables
      vr_vet_vlfaixas.DELETE;
      vr_vet_aplica.DELETE;
      vr_vet_total_geral.DELETE;
      vr_vet_total.DELETE;
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
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
  END pc_crps109;
/

