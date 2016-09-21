CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS147" (pr_cdcooper  IN NUMBER             --> Cooperativa
                                                ,pr_flgresta  IN PLS_INTEGER        --> Flag padrão para utilização de restart
                                                ,pr_stprogra  OUT PLS_INTEGER        --> Saída de termino da execução
                                                ,pr_infimsol  OUT PLS_INTEGER        --> Saída de termino da solicitação
                                                ,pr_cdcritic  OUT NUMBER            --> Código crítica
                                                ,pr_dscritic  OUT VARCHAR2) IS      --> Descrição crítica
BEGIN
/* ..........................................................................
   Programa: PC_CRPS147  (Antigo: Fontes/crps147.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                       Ultima atualizacao: 06/06/2016

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular a provisao mensal e emitir resumo da poupanca programda.
               Relatorio 123.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               07/01/2000 - Nao gerar pedido de relatorio (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               26/07/2001 - Gerar arquivo para conferencia (Junior).

               29/01/2004 - Mostrar o IR recolhido na fonte (Margarete).

               19/04/2004 - Atualizar novos campos craprpp (Margarete).

               24/05/2004 - Incluir total abono cpmf a recuperar (Margarete).

               22/09/2004 - Incluido historico 496(CI)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper da tabela craprej (Diego)

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).

               04/05/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)

               02/09/2010 - Incluir no relatorio o quadro de periodos.
                            Tarefa 34624 (Henrique).

               13/09/2010 - Adicionar novos prazos no quadro de periodos.
                            (Henrique)

               26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)

               21/11/2011 - Correção para considerar o prazo a partir da
                            data atual (glb_dtmvtolt) ao invés da data
                            de criação do plano de poupança programada
                           (Irlan/Lucas)

               05/05/2013 - Conversão Progress >> Oracle PL/SQL (Petter - Supero)

               09/08/2013 - Inclusão de teste na pr_flgresta antes de controlar
                            o restart (Marcos-Supero)

               09/08/2013 - Troca da busca do mes por extenso com to_char para
                            utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               09/12/2013 - Inclusão das alterações de novembro (Petter - Supero).
               
               23/03/2015 - Projeto de separação contábeis de PF e PJ.
                            (Andre Santos - SUPERO)

               06/06/2016 - Ajuste realizados:
                            -> Alterado a leitura da craptab para ser feito através de rotina
                               genérica;
                            -> Ajuste na estrutura do programa para ler os lançamentos de poupança
                               a partir da pltable dos registros de poupança programada, desta forma
                               conseguimos ler os lançamentos com o indice completo
                            (Adriano).
                            
............................................................................. */
  DECLARE
    vr_rel_dtdebito   DATE;                           --> Data de débito
    vr_rel_qtdebito   NUMBER := 0;                    --> Quantidade de débitos
    vr_rel_vldebito   NUMBER(20,2) := 0;              --> Valor do débito
    vr_res_qtrppati   NUMBER := 0;                    --> Quantidade de participação
    vr_res_qtrppati_a NUMBER := 0;                    --> Quantidade de participação auxiliar
    vr_res_qtrppati_n NUMBER := 0;                    --> Quantidade de participação por execução
    vr_res_qtrppnov   NUMBER := 0;                    --> Quantidade de participação
    vr_res_qtrppnov_a NUMBER := 0;                    --> Quantidade de participação auxiliar
    vr_res_qtrppnov_n NUMBER := 0;                    --> Quantidade de participação por execução
    vr_res_vlrppati   NUMBER(20,2) := 0;              --> Valor da participação
    vr_res_vlrppati_a NUMBER(20,2) := 0;              --> Valor da participação auxiliar
    vr_res_vlrppati_n NUMBER(20,2) := 0;              --> Valor da participação por execução
    vr_res_vlrppmes   NUMBER(20,2) := 0;              --> Valor mensal
    vr_res_vlrppmes_a NUMBER(20,2) := 0;              --> Valor mensal auxiliar
    vr_res_vlrppmes_n NUMBER(20,2) := 0;              --> Valor mensal por execução
    vr_res_vlresmes   NUMBER(20,2) := 0;              --> Valor resultado mensal
    vr_res_vlresmes_a NUMBER(20,2) := 0;              --> Valor resultado mensal auxiliar
    vr_res_vlresmes_n NUMBER(20,2) := 0;              --> Valor resultado mensal por execução
    vr_res_vlrppnov   NUMBER(20,2) := 0;              --> Valor de participação novo
    vr_res_vlrppnov_a NUMBER(20,2) := 0;              --> Valor de participação novo auxiliar
    vr_res_vlrppnov_n NUMBER(20,2) := 0;              --> Valor de participação novo por execução
    vr_res_vlrenmes   NUMBER(20,2) := 0;              --> Valor de resultado mês
    vr_res_vlrenmes_a NUMBER(20,2) := 0;              --> Valor de resultado mês auxiliar
    vr_res_vlrenmes_n NUMBER(20,2) := 0;              --> Valor de resultado mês por execução
    vr_res_vlprvmes   NUMBER(20,2) := 0;              --> Valor previsto mensal
    vr_res_vlprvmes_a NUMBER(20,2) := 0;              --> Valor previsto mensal auxiliar
    vr_res_vlprvmes_n NUMBER(20,2) := 0;              --> Valor previsto mensal por execução
    vr_res_vlprvlan   NUMBER(20,2) := 0;              --> Valor previsto lançamento
    vr_res_vlprvlan_a NUMBER(20,2) := 0;              --> Valor previsto lançamento auxiliar
    vr_res_vlprvlan_n NUMBER(20,2) := 0;              --> Valor previsto lançamento por execução
    vr_res_vlajuprv   NUMBER(20,2) := 0;              --> Valor previsto juros
    vr_res_vlajuprv_a NUMBER(20,2) := 0;              --> Valor previsto juros auxiliar
    vr_res_vlajuprv_n NUMBER(20,2) := 0;              --> Valor previsto juros por execução
    vr_res_vlrtirrf   NUMBER(20,2) := 0;              --> Valor IRRF
    vr_res_vlrtirrf_a NUMBER(20,2) := 0;              --> Valor IRRF auxiliar
    vr_res_vlrtirrf_n NUMBER(20,2) := 0;              --> Valor IRRF por execução
    vr_res_bsabcpmf   NUMBER(20,2) := 0;              --> Valor CPMF
    vr_res_bsabcpmf_a NUMBER(20,2) := 0;              --> Valor CPMF auxiliar
    vr_res_bsabcpmf_n NUMBER(20,2) := 0;              --> Valor CPMF por execução
    vr_res_vlrtirab   NUMBER(20,2) := 0;              --> Valor retido
    vr_res_vlrtirab_a NUMBER(20,2) := 0;              --> Valor retido auxiliar
    vr_res_vlrtirab_n NUMBER(20,2) := 0;              --> Valor retido por execução
    vr_tot_qtdebito   NUMBER(20,3) := 0;              --> Quantidade total de débito
    vr_tot_vldebito   NUMBER(20,2) := 0;              --> Valor total débito
    vr_dtinimes       DATE;                           --> Data inicial mes
    vr_dtfimmes       DATE;                           --> Data final mes
    vr_vlsdextr       craprpp.vlsdextr%TYPE := 0;     --> Valor de descrição
    vr_vlslfmes       craprpp.vlslfmes%TYPE := 0;     --> Valor fixo mes
    vr_valorapl       NUMBER(20,2) := 0;              --> Valor aplicado total
    vr_vlacumul       NUMBER(20,2) := 0;              --> Valor acumulado
    vr_qtdaplic       NUMBER := 0;                    --> Quantidade aplicada
    vr_tot_vlacumul   NUMBER(20,2) := 0;              --> Valor acumulado total
    vr_prazodia       NUMBER := 0;                    --> Dias de prazo
    vr_posicao        NUMBER := 0;                    --> Valor da posição
    vr_cddprazo       crapprb.cddprazo%TYPE;          --> Código do prazo
    vr_rel_dsmesref   VARCHAR2(4000);                 --> Mês de referencia
    vr_nmformul       VARCHAR2(40);                   --> Nome do formulário

    vr_cdprogra       CONSTANT crapprg.cdprogra%TYPE := 'CRPS147'; --> Código do programa executor
    --vr_desc_erro      VARCHAR2(4000);                 --> Mensagem de erro
    vr_exc_erro       EXCEPTION;                      --> Controle de exceção personalizada
    vr_exc_fimprg     exception;
    vr_dscritic       VARCHAR2(4000);

    vr_nom_dir        VARCHAR2(100);                  --> Nome da pasta
    vr_cdcritic       NUMBER;                         --> Código da crítica
    rw_crapdat        btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor genérico
    vr_rpp_vlsdrdpp   craprpp.vlsdrdpp%type := 0;     --> Valor de poupança acumulado
    vr_str_1          CLOB;                           --> Variável para armazenar XML de dados
    vr_str_2          CLOB;                           --> Variável para armazenar XML de dados
    vr_dtctr          DATE;                           --> Data de controle para quebra de iteração
    vr_count          NUMBER := 0;                    --> Contador para iteração do LOOP
    vr_nrcopias       NUMBER;                         --> Número de cópias
    vr_dextabi        craptab.dstextab%TYPE;          --> Armazenar execução para cálculo de poupança
    vr_exc_p1         EXCEPTION;                      --> Controle de exceção de LOOP interno
    vr_exc_p2         EXCEPTION;                      --> Controle de exceção de LOOP externo
    vr_idx_bndes      VARCHAR2(10);                   --> Índice para PL Table
    vr_valortexto     NUMBER := 0;                    --> Valor para preencher dinamicamente faixa de dias
    vr_texto          VARCHAR2(200);                  --> Texto da mensagem dinamica
    vr_nom_dirs       VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nom_direto     VARCHAR2(400);                  --> Nome da pasta para arquivo de dados
    vr_nom_micros     VARCHAR2(400);                  --> Nome da pasta micros
    vr_nmarqtxt       VARCHAR2(100);                  --> Nome do arquivo TXT
    vr_input_file     UTL_FILE.file_type;             --> Handle Utl File
    vr_setlinha       VARCHAR2(400);                  --> Linhas do arquivo
    vr_tot_rppagefis  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Fisicas
    vr_tot_rppagejur  NUMBER := 0;                    --> Valor Total de Poup Ativas de Pessoas Juridica
    vr_tot_vlrprvfis  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Fisicas
    vr_tot_vlrprvjur  NUMBER := 0;                    --> Valor Total de Provisao Mensal de Pessoas Juridica
    vr_dsprefix       CONSTANT VARCHAR2(15) := 'REVERSAO '; --> Constante de complemento inicial das mensagens de reversão
    vr_dscomand       VARCHAR2(400);                  --> Comando UNIX
    vr_typ_saida      VARCHAR2(400);                  --> Verificar erro na execução do Script UNIX
    vr_index          PLS_INTEGER;                    --> Controla index 
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.nrctactl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Buscar dados do cadastro de poupança programada
    CURSOR cr_craprpp(pr_cdcooper IN craptab.cdcooper%TYPE) IS --> Código da cooperativa
      SELECT cp.nrdconta
            ,ass.cdagenci
            ,DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpessoa
            ,cp.nrctrrpp
            ,cp.dtinirpp
            ,cp.dtiniper
            ,cp.flgctain
            ,cp.vlsdrdpp
            ,cp.dtcalcul
            ,cp.cdsitrpp
            ,cp.rowid
            ,cp.dtfimper
            ,cp.vlprerpp
            ,cp.dtdebito
            ,cp.vlsdextr
            ,cp.dtslfmes
            ,cp.vlslfmes
            ,cp.vlabcpmf
            ,cp.dtvctopp
      FROM craprpp cp
          ,crapass ass
      WHERE cp.cdcooper = ass.cdcooper
        AND cp.nrdconta = ass.nrdconta
        AND cp.cdcooper = pr_cdcooper
        AND cp.cdsitrpp <> 5
      ORDER BY cp.nrdconta, cp.nrctrrpp;

    -- Buscar cadastro de poupança programada
    CURSOR cr_craprppp(pr_cdcooper IN craptab.cdcooper%TYPE) IS     --> Código cooperativa
      SELECT cp.cdcooper 
            ,cp.nrdconta
            ,cp.nrctrrpp
            ,cp.flgctain
      FROM craprpp cp
      WHERE cp.cdcooper = pr_cdcooper;

    -- Buscar lançamentos do mês
    CURSOR cr_craplpp(pr_cdcooper IN craptab.cdcooper%TYPE        --> Código cooperativa
                     ,pr_nrdconta IN craplpp.nrdconta%TYPE        --> Número da conta
                     ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE        --> Número da poupança programada
                     ,pr_dtinimes IN craplpp.dtmvtolt%TYPE        --> Data inicial do mês
                     ,pr_dtfimmes IN craplpp.dtmvtolt%TYPE) IS    --> Data final do mês
      SELECT cp.nrdconta
            ,DECODE(ass.inpessoa, 3, 2, ass.inpessoa) inpessoa
            ,ass.cdagenci
            ,cp.nrctrrpp
            ,cp.cdhistor
            ,cp.vllanmto
            ,cp.nrdolote
      FROM craplpp cp
          ,crapass ass
      WHERE cp.cdcooper = ass.cdcooper
        AND cp.nrdconta = ass.nrdconta
        AND cp.nrdconta = pr_nrdconta
        AND cp.nrctrrpp = pr_nrctrrpp
        AND cp.cdcooper = pr_cdcooper
        AND cp.dtmvtolt > pr_dtinimes
        AND cp.dtmvtolt < pr_dtfimmes;

    -- Buscar dados de rejeitados
    CURSOR cr_craprej (pr_cdcooper IN craptab.cdcooper%TYPE         --> Código cooperativa
                      ,pr_cdprogra IN crapres.cdprogra%TYPE) IS     --> Código do programa
      SELECT cj.dtmvtolt
            ,cj.vllanmto
            ,COUNT(1) OVER() contagem
            ,cj.rowid
      FROM craprej cj
      WHERE cj.cdcooper = pr_cdcooper
        AND cj.cdpesqbb = pr_cdprogra
      ORDER BY cj.dtmvtolt;

    -- PL Table para armazenar dados do cadastro de poupança programada
    TYPE typ_reg_craprpp IS
      RECORD(cdcooper  craprpp.cdcooper%TYPE
            ,nrdconta  craprpp.nrdconta%TYPE
            ,nrctrrpp  craprpp.nrctrrpp%TYPE
            ,flgctain  craprpp.flgctain%TYPE);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_craprpp IS TABLE OF typ_reg_craprpp INDEX BY PLS_INTEGER;
    vr_tab_craprpp typ_tab_craprpp;

    -- PL Table para armazenar dados diversos de arrays
    TYPE typ_reg_dados IS
      RECORD(vr_valorapl NUMBER(20,2)
            ,vr_vlacumul NUMBER(20,2)
            ,vr_qtdaplic NUMBER);

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_dados IS TABLE OF typ_reg_dados INDEX BY PLS_INTEGER;
    vr_tab_dados typ_tab_dados;

    -- PL Table para armazenar valores de conta e aplicação BNDES
    TYPE typ_reg_cta_bndes IS
      RECORD(nrdconta  NUMBER
            ,vlaplica  NUMBER(20,8));

    -- Instancia e indexa o tipo da PL TABLE para liberar para uso
    TYPE typ_tab_cta_bndes IS TABLE OF typ_reg_cta_bndes INDEX BY VARCHAR2(10);
    vr_tab_cta_bndes typ_tab_cta_bndes;
    
    -- PL Table para armazenar valores totais por PF e PJ
    TYPE typ_reg_total IS
      RECORD(qtrppati NUMBER(20,2) DEFAULT 0
            ,vlrppati NUMBER(20,2) DEFAULT 0
            ,vlrppmes NUMBER(20,2) DEFAULT 0
            ,vlresmes NUMBER(20,2) DEFAULT 0
            ,qtrppnov NUMBER(20,2) DEFAULT 0
            ,vlrppnov NUMBER(20,2) DEFAULT 0
            ,vlrenmes NUMBER(20,2) DEFAULT 0
            ,vlprvmes NUMBER(20,2) DEFAULT 0
            ,vlprvlan NUMBER(20,2) DEFAULT 0
            ,vlajuprv NUMBER(20,2) DEFAULT 0
            ,vlrtirrf NUMBER(20,2) DEFAULT 0
            ,vlrtirab NUMBER(20,2) DEFAULT 0
            ,bsabcpmf NUMBER(20,2) DEFAULT 0);

    -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
    TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;
    vr_tab_total typ_tab_total;

    -- Instancia e indexa por agencia as poupacas ativas de pessoa fisica
    TYPE typ_tab_vlrppage_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_typ_tab_vlrppage_fis typ_tab_vlrppage_fis;
    
    -- Instancia e indexa por agencia as poupacas ativas de pessoa juridica
    TYPE typ_tab_vlrppage_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_typ_tab_vlrppage_jur typ_tab_vlrppage_jur;
    
    -- Instancia e indexa por agencia as provisoes mensais de pessoa fisica
    TYPE typ_tot_vlrprvmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrprvmes_fis typ_tot_vlrprvmes_fis;
    
    -- Instancia e indexa por agencia as provisoes mensais de pessoa juridica
    TYPE typ_tot_vlrprvmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    vr_tot_vlrprvmes_jur typ_tot_vlrprvmes_jur;    

    -- Procedure para consistir e gravar dados na CRAPPRB
    PROCEDURE pc_cria_crapprb (pr_prazodia  IN NUMBER                  --> Prazo de dias
                              ,pr_vlretorn  IN crapprb.vlretorn%TYPE   --> Valor de retorno
                              ,pr_nrctactl  IN crapcop.nrctactl%TYPE   --> Número da conta
                              ,pr_desc_erro OUT VARCHAR2) AS           --> Saída de erro
      BEGIN
        DECLARE
          vr_cddprazo   crapprb.cddprazo%TYPE;               --> Código do prazo de pagamento

        BEGIN
          -- Definir código de prazo de pagamento
          CASE pr_prazodia
            WHEN 1  THEN vr_cddprazo := 90;
            WHEN 2  THEN vr_cddprazo := 180;
            WHEN 3  THEN vr_cddprazo := 270;
            WHEN 4  THEN vr_cddprazo := 360;
            WHEN 5  THEN vr_cddprazo := 720;
            WHEN 6  THEN vr_cddprazo := 1080;
            WHEN 7  THEN vr_cddprazo := 1440;
            WHEN 8  THEN vr_cddprazo := 1800;
            WHEN 9  THEN vr_cddprazo := 2160;
            WHEN 10 THEN vr_cddprazo := 2520;
            WHEN 11 THEN vr_cddprazo := 2880;
            WHEN 12 THEN vr_cddprazo := 3240;
            WHEN 13 THEN vr_cddprazo := 3600;
            WHEN 14 THEN vr_cddprazo := 3960;
            WHEN 15 THEN vr_cddprazo := 4320;
            WHEN 16 THEN vr_cddprazo := 4680;
            WHEN 17 THEN vr_cddprazo := 5040;
            WHEN 18 THEN vr_cddprazo := 5400;
            WHEN 19 THEN vr_cddprazo := 5401;
          END CASE;

          -- Realizar INSERT na CRAPPRB
          INSERT INTO crapprb (cdcooper, dtmvtolt, nrdconta, cdorigem, cddprazo, vlretorn)
            VALUES(3, rw_crapdat.dtmvtolt, pr_nrctactl, 9, vr_cddprazo, pr_vlretorn);
      EXCEPTION
        WHEN OTHERS THEN
          pr_desc_erro := 'Erro em pc_cria_crapprb: ' || SQLERRM;
      END;
    END pc_cria_crapprb;

    -- Procedure para acumular valores de novas e antigas aplicações
    PROCEDURE pc_acumula_aplicacoes(pr_cdhistor  IN craplpp.cdhistor%TYPE   --> Código do histórico
                                   ,pr_tipoapli  IN VARCHAR2                --> Indicar se aplicação é nova (N) ou antiga (A)
                                   ,pr_vllanmto  IN craplpp.vllanmto%TYPE   --> Valor de movimento
                                   ,pr_nrdolote  IN craplpp.nrdolote%TYPE   --> Número do lote
                                   ,pr_desc_erro OUT VARCHAR2) AS           --> Descrição de erros no processo
    BEGIN
      BEGIN
        -- Faz o acumulo de acordo com o código do histórico
        -- Considera se irá gerar lançamentos em aplicações novas ou antigas
        CASE
          WHEN pr_cdhistor = 150 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrppmes_n := vr_res_vlrppmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrppmes_a := vr_res_vlrppmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor IN (158,496) THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlresmes_n := vr_res_vlresmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlresmes_a := vr_res_vlresmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = 151 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrenmes_n := vr_res_vlrenmes_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrenmes_a := vr_res_vlrenmes_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = 152 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlprvmes_n := vr_res_vlprvmes_n + pr_vllanmto;

              IF pr_nrdolote = 8383 THEN
                vr_res_vlprvlan_n := vr_res_vlprvlan_n + pr_vllanmto;
              END IF;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlprvmes_a := vr_res_vlprvmes_a + pr_vllanmto;

              IF pr_nrdolote = 8383 THEN
                vr_res_vlprvlan_a := vr_res_vlprvlan_a + pr_vllanmto;
              END IF;
            END IF;
          WHEN pr_cdhistor IN (157,154) THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlajuprv_n := vr_res_vlajuprv_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlajuprv_a := vr_res_vlajuprv_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor IN (155,156) THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlajuprv_n := vr_res_vlajuprv_n - pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlajuprv_a := vr_res_vlajuprv_a - pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = 863 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrtirrf_n := vr_res_vlrtirrf_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrtirrf_a := vr_res_vlrtirrf_a + pr_vllanmto;
            END IF;
          WHEN pr_cdhistor = 870 THEN
            IF pr_tipoapli = 'N' THEN
              vr_res_vlrtirab_n := vr_res_vlrtirab_n + pr_vllanmto;
            ELSIF pr_tipoapli = 'A' THEN
              vr_res_vlrtirab_a := vr_res_vlrtirab_a + pr_vllanmto;
            END IF;
        END CASE;
      EXCEPTION
        WHEN OTHERS THEN
          IF pr_tipoapli = 'N' THEN
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo N: ' || SQLERRM;
          ELSIF pr_tipoapli = 'A' THEN
            pr_desc_erro := 'Erro em pc_acumula_aplicacoes tipo A: ' || SQLERRM;
          END IF;
      END;
    END pc_acumula_aplicacoes;

    -- Procedure para escrever texto na variável CLOB do XML
    PROCEDURE pc_xml_tag(pr_des_dados IN VARCHAR2                --> String que será adicionada ao CLOB
                        ,pr_clob      IN OUT NOCOPY CLOB) IS     --> CLOB que irá receber a string
    BEGIN
      dbms_lob.writeappend(pr_clob, length(pr_des_dados), pr_des_dados);
    END pc_xml_tag;
    
    
  ---------------------------------------
  -- Inicio Bloco Principal pc_crps147
  ---------------------------------------
  BEGIN
    -- Atribuição de valores iniciais da procedure
    vr_nmformul := '';
    vr_nrcopias := 1;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                             , pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;

      vr_cdcritic := 651;

      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    vr_nom_dirs := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/salvar');

    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1--TRUE
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => vr_cdcritic);

    -- Caso retorno crítica busca a descrição
    IF vr_cdcritic <> 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    END IF;

    --Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Buscar informações para cálculo de poupança
    vr_dextabi:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'CONFIG'
                                           ,pr_cdempres => 0
                                           ,pr_cdacesso => 'PERCIRAPLI'
                                           ,pr_tpregist => 0);

    -- Limpa Tabela de Memoria de Totais Separdos por PF e PJ
    vr_tab_total.DELETE;
    FOR idx IN 1..2 LOOP
        vr_tab_total(idx).qtrppati := 0;
        vr_tab_total(idx).vlrppati := 0;
        vr_tab_total(idx).vlrppmes := 0;
        vr_tab_total(idx).vlresmes := 0;
        vr_tab_total(idx).qtrppnov := 0;
        vr_tab_total(idx).vlrppnov := 0;
        vr_tab_total(idx).vlrenmes := 0;
        vr_tab_total(idx).vlprvmes := 0;
        vr_tab_total(idx).vlprvlan := 0;
        vr_tab_total(idx).vlajuprv := 0;
        vr_tab_total(idx).vlrtirrf := 0;
        vr_tab_total(idx).vlrtirab := 0;
        vr_tab_total(idx).bsabcpmf  := 0;
    END LOOP;

    -- Inicializar PL Table de dados diversos
    FOR idx IN 1..19 LOOP
      vr_tab_dados(idx).vr_valorapl := 0;
      vr_tab_dados(idx).vr_vlacumul := 0;
      vr_tab_dados(idx).vr_qtdaplic := 0;
    END LOOP;

    vr_index:= vr_tab_craprpp.count + 1;
    
    -- Carregar dados na PL Table
    FOR vr_craprpp IN cr_craprppp(pr_cdcooper) LOOP
      vr_tab_craprpp(vr_index).cdcooper := vr_craprpp.cdcooper;
      vr_tab_craprpp(vr_index).nrdconta := vr_craprpp.nrdconta;
      vr_tab_craprpp(vr_index).nrctrrpp := vr_craprpp.nrctrrpp;
      vr_tab_craprpp(vr_index).flgctain := vr_craprpp.flgctain;
    END LOOP;

    -- Definir dias do mês
    vr_dtinimes := add_months(last_day(rw_crapdat.dtmvtolt), -1);
    vr_dtfimmes := to_date('01' || to_char(add_months(rw_crapdat.dtmvtolt, 1), 'MM/RRRR'), 'DD/MM/RRRR');

    -- Limpar crítica
    vr_cdcritic := 0;
    
    -- Inicializa Tabela Temporaria
    vr_typ_tab_vlrppage_fis.DELETE;
    vr_typ_tab_vlrppage_jur.DELETE;
    vr_tot_vlrprvmes_fis.DELETE;
    vr_tot_vlrprvmes_jur.DELETE;

    -- Formatar mês de referência
    vr_rel_dsmesref := gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt, 'MM')) ||'/'||to_char(rw_crapdat.dtmvtolt, 'RRRR');

    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_str_2, TRUE);
    dbms_lob.open(vr_str_2, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><base>', vr_str_2);

    -- Leitura das aplicações
    -- Definir ponto para salvar alterações
    SAVEPOINT TRANS_POUP;
    
    -- Se ocorrer erros acionar SAVEPOINT para desfazer as alterações e continuar o processo
    BEGIN
      FOR vr_craprpp IN cr_craprpp(pr_cdcooper) LOOP
        BEGIN
          -- Zerar valores de variáveis
          vr_cdcritic := 0;
          vr_vlsdextr := 0;
          vr_vlslfmes := 0;

          -- Validar data do cursor com a data global da movimentação
          IF vr_craprpp.dtinirpp <= rw_crapdat.dtmvtolt THEN
            -- Validar data inicial do período do cursor com a data global da movimentação
            IF vr_craprpp.dtiniper <= rw_crapdat.dtmvtolt THEN
              -- Cálculo da aplicação
              apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                       ,pr_dstextab  => vr_dextabi
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_inproces  => rw_crapdat.inproces
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                       ,pr_rpp_rowid => vr_craprpp.rowid
                                       ,pr_vlsdrdpp  => vr_rpp_vlsdrdpp
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_des_erro  => vr_dscritic);

              -- Verificar se ocorreram erros no cálculo de poupança
              IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
                vr_cdcritic := 0;
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' ||
                                                              vr_dscritic || '. ');
                RAISE vr_exc_erro;
              END IF;

              -- Dados para o resumo
              IF vr_rpp_vlsdrdpp > 0 THEN
                -- Atribuir valores para as variáveis agrupando por tipo de pessoa
                vr_res_qtrppati := vr_res_qtrppati + 1;
                vr_res_vlrppati := vr_res_vlrppati + vr_rpp_vlsdrdpp;
                -- Atribuir valores para Pl-Table separando por PF e PJ
                vr_tab_total(vr_craprpp.inpessoa).qtrppati := vr_tab_total(vr_craprpp.inpessoa).qtrppati + 1;
                vr_tab_total(vr_craprpp.inpessoa).vlrppati := vr_tab_total(vr_craprpp.inpessoa).vlrppati + vr_rpp_vlsdrdpp;
                vr_vlsdextr := vr_rpp_vlsdrdpp;
                vr_vlslfmes := vr_rpp_vlsdrdpp;

                -- Valida flag de execução
                IF vr_craprpp.flgctain = 1 THEN
                  vr_res_qtrppati_n := vr_res_qtrppati_n + 1;
                  vr_res_vlrppati_n := vr_res_vlrppati_n + vr_rpp_vlsdrdpp;
                ELSE
                  vr_res_qtrppati_a := vr_res_qtrppati_a + 1;
                  vr_res_vlrppati_a := vr_res_vlrppati_a + vr_rpp_vlsdrdpp;
                END IF;
                
                -- Guarda as informacoes de poup ativas por agencia. Dados para Contabilidade
                IF vr_craprpp.inpessoa = 1 THEN
                   -- Verifica se existe valor para agencia corrente de pessoa fisica
                   IF vr_typ_tab_vlrppage_fis.EXISTS(vr_craprpp.cdagenci) THEN
                      -- Soma os valores por agencia de pessoa fisica
                      vr_typ_tab_vlrppage_fis(vr_craprpp.cdagenci) := vr_typ_tab_vlrppage_fis(vr_craprpp.cdagenci) + vr_rpp_vlsdrdpp;
                   ELSE
                      -- Inicializa o array com o valor inicial de pessoa fisica
                      vr_typ_tab_vlrppage_fis(vr_craprpp.cdagenci) := vr_rpp_vlsdrdpp;
                   END IF;
                   -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa fisica
                   vr_tot_rppagefis := vr_tot_rppagefis + vr_rpp_vlsdrdpp;
                ELSE
                   -- Verifica se existe valor para agencia corrente de pessoa juridica
                   IF vr_typ_tab_vlrppage_jur.EXISTS(vr_craprpp.cdagenci) THEN
                      -- Soma os valores por agencia de pessoa juridica
                      vr_typ_tab_vlrppage_jur(vr_craprpp.cdagenci) := vr_typ_tab_vlrppage_jur(vr_craprpp.cdagenci) + vr_rpp_vlsdrdpp;
                   ELSE
                      -- Inicializa o array com o valor inicial de pessoa juridica
                      vr_typ_tab_vlrppage_jur(vr_craprpp.cdagenci) := vr_rpp_vlsdrdpp;
                   END IF;
                   
                   -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa juridica
                   vr_tot_rppagejur := vr_tot_rppagejur + vr_rpp_vlsdrdpp;
                END IF;

                -- Escrever dados no XML do arquivo de dados
                pc_xml_tag('<dados><nrdconta>' || to_char(vr_craprpp.nrdconta, 'FM999999G999G0') || '</nrdconta>', vr_str_2);
                pc_xml_tag('<nrctrrpp>' || to_char(vr_craprpp.nrctrrpp, 'FM999G999G999G990') || '</nrctrrpp>', vr_str_2);
                pc_xml_tag('<vr_rpp_vlsdrdpp>' || to_char(vr_rpp_vlsdrdpp, 'FM999G999G990D00') || '</vr_rpp_vlsdrdpp>', vr_str_2);
                pc_xml_tag('<dtcalcul>' || to_char(vr_craprpp.dtcalcul,'DD/MM/RRRR') || '</dtcalcul>', vr_str_2);
                pc_xml_tag('<dtiniper>' || to_char(vr_craprpp.dtiniper,'DD/MM/RRRR') || '</dtiniper>', vr_str_2);
                pc_xml_tag('<dtfimper>' || to_char(vr_craprpp.dtfimper,'DD/MM/RRRR') || '</dtfimper></dados>', vr_str_2);
              END IF;
            END IF;
          END IF;

          -- Validar valores de datas
          IF to_char(vr_craprpp.dtinirpp, 'MMRRRR') = to_char(rw_crapdat.dtmvtolt, 'MMRRRR') AND
              vr_craprpp.cdsitrpp IN (1,2) THEN
            -- Zerar variáveis
            -- Atribuir valores para as variáveis agrupando por tipo de pessoa
            vr_res_qtrppnov := vr_res_qtrppnov + 1;
            -- Atribuir valores para Pl-Table separando por PF e PJ
            vr_tab_total(vr_craprpp.inpessoa).qtrppnov := vr_tab_total(vr_craprpp.inpessoa).qtrppnov + 1;
            -- Atribuir valores para as variáveis agrupando por tipo de pessoa
            vr_res_vlrppnov := vr_res_vlrppnov + vr_craprpp.vlprerpp;
            -- Atribuir valores para Pl-Table separando por PF e PJ
            vr_tab_total(vr_craprpp.inpessoa).vlrppnov := vr_tab_total(vr_craprpp.inpessoa).vlrppnov + vr_craprpp.vlprerpp;
            vr_vlsdextr := vr_craprpp.vlprerpp;

            -- Valida flag de execução
            IF vr_craprpp.flgctain = 1 THEN
              vr_res_qtrppnov_n := vr_res_qtrppnov_n + 1;
              vr_res_vlrppnov_n := vr_res_vlrppnov_n + vr_craprpp.vlprerpp;
            ELSE
              vr_res_qtrppnov_a := vr_res_qtrppnov_a + 1;
              vr_res_vlrppnov_a := vr_res_vlrppnov_a + vr_craprpp.vlprerpp;
            END IF;
          END IF;

          -- Validar dados para realizar INSERT
          IF vr_craprpp.cdsitrpp = 1 OR vr_craprpp.cdsitrpp = 2 THEN
            BEGIN
              INSERT INTO craprej (dtmvtolt, vllanmto, cdpesqbb, cdcooper)
                VALUES(vr_craprpp.dtdebito, vr_craprpp.vlprerpp, vr_cdprogra, pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar CRAPRPP: ' || SQLERRM;
                RAISE vr_exc_p1;
            END;
          END IF;

          -- Realizar update no registro corrente do cursor
          BEGIN
            UPDATE craprpp cr
            SET cr.vlsdextr = vr_vlsdextr
               ,cr.dtslfmes = rw_crapdat.dtmvtolt
               ,cr.vlslfmes = vr_vlslfmes
            WHERE cr.rowid = vr_craprpp.rowid
             RETURNING cr.vlsdextr, cr.dtslfmes, cr.vlslfmes
              INTO vr_craprpp.vlsdextr, vr_craprpp.dtslfmes, vr_craprpp.vlslfmes;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAPRPP: ' || SQLERRM;
              RAISE vr_exc_p1;
          END;

          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_bsabcpmf := vr_res_bsabcpmf + vr_craprpp.vlabcpmf;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craprpp.inpessoa).bsabcpmf := vr_tab_total(vr_craprpp.inpessoa).bsabcpmf + vr_craprpp.vlabcpmf;
          

          -- Verificar flag para cálcular CPMF
          IF vr_craprpp.flgctain = 1 THEN
            vr_res_bsabcpmf_n := vr_res_bsabcpmf_n + vr_craprpp.vlabcpmf;
          ELSE
            vr_res_bsabcpmf_a := vr_res_bsabcpmf_a + vr_craprpp.vlabcpmf;
          END IF;

          -- Atribuir valor para a variável
          vr_prazodia := vr_craprpp.dtvctopp - rw_crapdat.dtmvtolt;

          -- Atualiza valores de acordo com o prazo estipulado
          CASE
            WHEN vr_prazodia <= 90 THEN
              vr_tab_dados(1).vr_qtdaplic := vr_tab_dados(1).vr_qtdaplic + 1;
              vr_tab_dados(1).vr_valorapl := vr_tab_dados(1).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 90 AND vr_prazodia <= 180 THEN
              vr_tab_dados(2).vr_qtdaplic := vr_tab_dados(2).vr_qtdaplic + 1;
              vr_tab_dados(2).vr_valorapl := vr_tab_dados(2).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 180 AND vr_prazodia <= 270 THEN
              vr_tab_dados(3).vr_qtdaplic := vr_tab_dados(3).vr_qtdaplic + 1;
              vr_tab_dados(3).vr_valorapl := vr_tab_dados(3).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 270 AND vr_prazodia <= 360 THEN
              vr_tab_dados(4).vr_qtdaplic := vr_tab_dados(4).vr_qtdaplic + 1;
              vr_tab_dados(4).vr_valorapl := vr_tab_dados(4).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 360 AND vr_prazodia <= 720 THEN
              vr_tab_dados(5).vr_qtdaplic := vr_tab_dados(5).vr_qtdaplic + 1;
              vr_tab_dados(5).vr_valorapl := vr_tab_dados(5).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 720 AND vr_prazodia <= 1080 THEN
              vr_tab_dados(6).vr_qtdaplic := vr_tab_dados(6).vr_qtdaplic + 1;
              vr_tab_dados(6).vr_valorapl := vr_tab_dados(6).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 1080 AND vr_prazodia <= 1440 THEN
              vr_tab_dados(7).vr_qtdaplic := vr_tab_dados(7).vr_qtdaplic + 1;
              vr_tab_dados(7).vr_valorapl := vr_tab_dados(7).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 1440 AND vr_prazodia <= 1800 THEN
              vr_tab_dados(8).vr_qtdaplic := vr_tab_dados(8).vr_qtdaplic + 1;
              vr_tab_dados(8).vr_valorapl := vr_tab_dados(8).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 1800 AND vr_prazodia <= 2160 THEN
              vr_tab_dados(9).vr_qtdaplic := vr_tab_dados(9).vr_qtdaplic + 1;
              vr_tab_dados(9).vr_valorapl := vr_tab_dados(9).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 2160 AND vr_prazodia <= 2520 THEN
              vr_tab_dados(10).vr_qtdaplic := vr_tab_dados(10).vr_qtdaplic + 1;
              vr_tab_dados(10).vr_valorapl := vr_tab_dados(10).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 2520 AND vr_prazodia <= 2880 THEN
              vr_tab_dados(11).vr_qtdaplic := vr_tab_dados(11).vr_qtdaplic + 1;
              vr_tab_dados(11).vr_valorapl := vr_tab_dados(11).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 2880 AND vr_prazodia <= 3240 THEN
              vr_tab_dados(12).vr_qtdaplic := vr_tab_dados(12).vr_qtdaplic + 1;
              vr_tab_dados(12).vr_valorapl := vr_tab_dados(12).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 3240 AND vr_prazodia <= 3600 THEN
              vr_tab_dados(13).vr_qtdaplic := vr_tab_dados(13).vr_qtdaplic + 1;
              vr_tab_dados(13).vr_valorapl := vr_tab_dados(13).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 3600 AND vr_prazodia <= 3960 THEN
              vr_tab_dados(14).vr_qtdaplic := vr_tab_dados(14).vr_qtdaplic + 1;
              vr_tab_dados(14).vr_valorapl := vr_tab_dados(14).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 3960 AND vr_prazodia <= 4320 THEN
              vr_tab_dados(15).vr_qtdaplic := vr_tab_dados(15).vr_qtdaplic + 1;
              vr_tab_dados(15).vr_valorapl := vr_tab_dados(15).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 4320 AND vr_prazodia <= 4680 THEN
              vr_tab_dados(16).vr_qtdaplic := vr_tab_dados(16).vr_qtdaplic + 1;
              vr_tab_dados(16).vr_valorapl := vr_tab_dados(16).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 4680 AND vr_prazodia <= 5040 THEN
              vr_tab_dados(17).vr_qtdaplic := vr_tab_dados(17).vr_qtdaplic + 1;
              vr_tab_dados(17).vr_valorapl := vr_tab_dados(17).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 5040 AND vr_prazodia <= 5400 THEN
              vr_tab_dados(18).vr_qtdaplic := vr_tab_dados(18).vr_qtdaplic + 1;
              vr_tab_dados(18).vr_valorapl := vr_tab_dados(18).vr_valorapl + vr_craprpp.vlslfmes;
            WHEN vr_prazodia > 5400 THEN
              vr_tab_dados(19).vr_qtdaplic := vr_tab_dados(19).vr_qtdaplic + 1;
              vr_tab_dados(19).vr_valorapl := vr_tab_dados(19).vr_valorapl + vr_craprpp.vlslfmes;
          END CASE;

          -- Valida se existe registro de conta BNDES para atualizar, senão insere
          IF vr_tab_cta_bndes.exists(lpad(vr_craprpp.nrdconta, 10, '0')) THEN
            vr_tab_cta_bndes(lpad(vr_craprpp.nrdconta, 10, '0')).vlaplica :=
                     vr_tab_cta_bndes(lpad(vr_craprpp.nrdconta, 10, '0')).vlaplica + vr_craprpp.vlslfmes;
          ELSE
            vr_tab_cta_bndes(lpad(vr_craprpp.nrdconta, 10, '0')).nrdconta := vr_craprpp.nrdconta;
            vr_tab_cta_bndes(lpad(vr_craprpp.nrdconta, 10, '0')).vlaplica := vr_craprpp.vlslfmes;
          END IF;

        EXCEPTION
          WHEN vr_exc_p1 THEN
            vr_cdcritic := 0;
            RAISE vr_exc_p2;
          when vr_exc_erro then
            raise vr_exc_erro;
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao validar dados: ' || SQLERRM;
            RAISE vr_exc_p2;
        END;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_p2 THEN
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro em CR_CRAPRPP: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- Inserir informações na CRAPPRB
    -- Iterar sob os registros gerados
    FOR vr_posicao IN 1..19 LOOP
      -- Validar o valor de aplicação
      IF vr_tab_dados(vr_posicao).vr_valorapl > 0 THEN
        pc_cria_crapprb (pr_prazodia  => vr_posicao
                        ,pr_vlretorn  => vr_tab_dados(vr_posicao).vr_valorapl
                        ,pr_nrctactl  => rw_crapcop.nrctactl
                        ,pr_desc_erro => vr_dscritic);
      END IF;
    END LOOP;

    -- Percorrer PL Table de contas do BNDES
    vr_idx_bndes := vr_tab_cta_bndes.first;

    LOOP
      EXIT WHEN vr_idx_bndes IS NULL;

      -- Verificar se o valor aplicado é maior que zero
      IF vr_tab_cta_bndes(vr_idx_bndes).vlaplica > 0 THEN
        -- Realizar INSERT na CRAPPRB
        BEGIN
          INSERT INTO crapprb (cdcooper
                              ,dtmvtolt
                              ,nrdconta
                              ,cdorigem
                              ,cddprazo
                              ,vlretorn)
            VALUES(pr_cdcooper
                  ,rw_crapdat.dtmvtolt
                  ,vr_tab_cta_bndes(vr_idx_bndes).nrdconta
                  ,9
                  ,0
                  ,vr_tab_cta_bndes(vr_idx_bndes).vlaplica);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar CRAPRPP: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;

      vr_idx_bndes := vr_tab_cta_bndes.next(vr_idx_bndes);
    END LOOP;

    -- Verifica se foram encontradas críticas no processo
    IF vr_cdcritic > 0 THEN
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
    END IF;

    vr_index := vr_tab_craprpp.first;
    
    WHILE vr_index IS NOT NULL LOOP
      
    -- Leitura dos lançamentos do mês
      FOR vr_craplpp IN cr_craplpp(pr_cdcooper => vr_tab_craprpp(vr_index).cdcooper
                                  ,pr_nrdconta => vr_tab_craprpp(vr_index).nrdconta
                                  ,pr_nrctrrpp => vr_tab_craprpp(vr_index).nrctrrpp
                                  ,pr_dtinimes => vr_dtinimes 
                                  ,pr_dtfimmes => vr_dtfimmes) LOOP

      -- Valida se será computado aplicações novas ou antigas
        IF vr_tab_craprpp(vr_index).flgctain = 1 THEN
        pc_acumula_aplicacoes(pr_cdhistor  => vr_craplpp.cdhistor
                             ,pr_tipoapli  => 'N'
                             ,pr_vllanmto  => vr_craplpp.vllanmto
                             ,pr_nrdolote  => vr_craplpp.nrdolote
                             ,pr_desc_erro => vr_dscritic);

        -- Se ocorrer erros no processo
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        pc_acumula_aplicacoes(pr_cdhistor  => vr_craplpp.cdhistor
                             ,pr_tipoapli  => 'A'
                             ,pr_vllanmto  => vr_craplpp.vllanmto
                             ,pr_nrdolote  => vr_craplpp.nrdolote
                             ,pr_desc_erro => vr_dscritic);

        -- Se ocorrer erros no processo
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Valida histórico para fazer sumarização
      CASE
        WHEN vr_craplpp.cdhistor = 150 THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlrppmes := vr_res_vlrppmes + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlrppmes := vr_tab_total(vr_craplpp.inpessoa).vlrppmes + vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor IN (158,496) THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlresmes := vr_res_vlresmes + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlresmes := vr_tab_total(vr_craplpp.inpessoa).vlresmes + vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor = 151 THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlrenmes := vr_res_vlrenmes + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlrenmes := vr_tab_total(vr_craplpp.inpessoa).vlrenmes + vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor = 152 THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlprvmes := vr_res_vlprvmes + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlprvmes := vr_tab_total(vr_craplpp.inpessoa).vlprvmes + vr_craplpp.vllanmto;
          
          IF vr_craplpp.inpessoa = 1 THEN
             
             -- Separando as opcoes de previsao mensal por agencia
             IF vr_tot_vlrprvmes_fis.EXISTS(vr_craplpp.cdagenci) THEN
                vr_tot_vlrprvmes_fis(vr_craplpp.cdagenci) := vr_tot_vlrprvmes_fis(vr_craplpp.cdagenci) + vr_craplpp.vllanmto;
             ELSE
                vr_tot_vlrprvmes_fis(vr_craplpp.cdagenci) := vr_craplpp.vllanmto;
             END IF;

             -- Gravando as informacoe para gerar o valor provisao mensal de pessoa fisica
             vr_tot_vlrprvfis := vr_tot_vlrprvfis + vr_craplpp.vllanmto;
          ELSE

             -- Separando as opcoes de previsao mensal por agencia
             IF vr_tot_vlrprvmes_jur.EXISTS(vr_craplpp.cdagenci) THEN
                vr_tot_vlrprvmes_jur(vr_craplpp.cdagenci) := vr_tot_vlrprvmes_jur(vr_craplpp.cdagenci) + vr_craplpp.vllanmto;
             ELSE
                vr_tot_vlrprvmes_jur(vr_craplpp.cdagenci) := vr_craplpp.vllanmto;
             END IF;

             -- Gravando as informacoe para gerar o valor provisao mensal de pessoa fisica
             vr_tot_vlrprvjur := vr_tot_vlrprvjur + vr_craplpp.vllanmto;
          END IF;

          IF vr_craplpp.nrdolote = 8383 THEN
            -- Atribuir valores para as variáveis agrupando por tipo de pessoa
            vr_res_vlprvlan := vr_res_vlprvlan + vr_craplpp.vllanmto;
            -- Atribuir valores para Pl-Table separando por PF e PJ
            vr_tab_total(vr_craplpp.inpessoa).vlprvlan := vr_tab_total(vr_craplpp.inpessoa).vlprvlan + vr_craplpp.vllanmto;
          END IF;
        WHEN vr_craplpp.cdhistor IN (157,154) THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlajuprv := vr_res_vlajuprv + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlajuprv := vr_tab_total(vr_craplpp.inpessoa).vlajuprv + vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor IN (156,155) THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlajuprv := vr_res_vlajuprv - vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlajuprv := vr_tab_total(vr_craplpp.inpessoa).vlajuprv - vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor = 863 THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlrtirrf := vr_res_vlrtirrf + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlrtirrf := vr_tab_total(vr_craplpp.inpessoa).vlrtirrf + vr_craplpp.vllanmto;
        WHEN vr_craplpp.cdhistor = 870 THEN
          -- Atribuir valores para as variáveis agrupando por tipo de pessoa
          vr_res_vlrtirab := vr_res_vlrtirab + vr_craplpp.vllanmto;
          -- Atribuir valores para Pl-Table separando por PF e PJ
          vr_tab_total(vr_craplpp.inpessoa).vlrtirab := vr_tab_total(vr_craplpp.inpessoa).vlrtirab + vr_craplpp.vllanmto;
      END CASE;
    END LOOP;

      vr_index :=  vr_tab_craprpp.next(vr_index);
           
    END LOOP;
    
    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_str_1, TRUE);
    dbms_lob.open(vr_str_1, dbms_lob.lob_readwrite);

    -- Inicilizar as informações do XML
    pc_xml_tag('<?xml version="1.0" encoding="utf-8"?><base>', vr_str_1);

    -- Escrever dados no XML
    pc_xml_tag('<aplicpoup>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>QUANTIDADE DE POUPANCAS ATIVAS:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_qtrppati_a, 0), 'FM999G999G990') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_qtrppati_n, 0), 'FM999G999G990') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_qtrppati, 0), 'FM999G999G990') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).qtrppati, 0), 'FM999G999G990') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).qtrppati, 0), 'FM999G999G990') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>SALDO TOTAL DAS POUPANCAS ATIVAS:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrppati_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrppati_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrppati, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppati, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppati, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR TOTAL APLICADO NO MES:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrppmes_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrppmes_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrppmes, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppmes, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppmes, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR TOTAL DOS RESGATES DO MES:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlresmes_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlresmes_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlresmes, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlresmes, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlresmes, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>QUANTIDADE DE POUPANCAS NOVAS:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_qtrppnov_a, 0), 'FM999G999G990') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_qtrppnov_n, 0), 'FM999G999G990') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_qtrppnov, 0), 'FM999G999G990') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).qtrppnov, 0), 'FM999G999G990') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).qtrppnov, 0), 'FM999G999G990') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR DAS NOVAS POUPANCAS:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrppnov_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrppnov_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrppnov, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrppnov, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrppnov, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>RENDIMENTO CREDITADO NO MES:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrenmes_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrenmes_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrenmes, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrenmes, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrenmes, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR TOTAL DA PROVISAO DO MES:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlprvmes_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlprvmes_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlprvmes, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlprvmes, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlprvmes, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>PROVISAO DE APLICACOES A VENCER:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlprvlan_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlprvlan_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlprvlan, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlprvlan, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlprvlan, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>AJUSTE DE PROVISAO:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlajuprv_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlajuprv_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlajuprv, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlajuprv, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlajuprv, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR DO IR RETIDO NA FONTE:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrtirrf_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrtirrf_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrtirrf, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrtirrf, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrtirrf, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);    
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>VALOR DO IR SOBRE ABONO:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_vlrtirab_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_vlrtirab_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_vlrtirab, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).vlrtirab, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).vlrtirab, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('<aplic>', vr_str_1);
    pc_xml_tag('<nomecampo>ABONOS ADIANTADOS A RECUPERAR:</nomecampo>', vr_str_1);
    pc_xml_tag('<antiga>' || to_char(nvl(vr_res_bsabcpmf_a, 0), 'FM999G999G990D00') || '</antiga>', vr_str_1);
    pc_xml_tag('<nova>' || to_char(nvl(vr_res_bsabcpmf_n, 0), 'FM999G999G990D00') || '</nova>', vr_str_1);
    pc_xml_tag('<saldo>' || to_char(nvl(vr_res_bsabcpmf, 0), 'FM999G999G990D00') || '</saldo>', vr_str_1);
    -- Separando o saldo total por PF e PJ
    pc_xml_tag('<vltotfis>' || to_char(nvl(vr_tab_total(1).bsabcpmf, 0), 'FM999G999G990D00') || '</vltotfis>', vr_str_1);
    pc_xml_tag('<vltotjur>' || to_char(nvl(vr_tab_total(2).bsabcpmf, 0), 'FM999G999G990D00') || '</vltotjur>', vr_str_1);
    pc_xml_tag('</aplic>', vr_str_1);
    pc_xml_tag('</aplicpoup>', vr_str_1);

    -- Acumular valores para totalização
    FOR idx IN 1..vr_tab_dados.count() LOOP
      -- Controlar fluxo dos registros (primeiro registro)
      IF idx = 1 THEN
        vr_tab_dados(idx).vr_vlacumul := vr_tab_dados(idx).vr_valorapl;
      ELSE
        vr_tab_dados(idx).vr_vlacumul := vr_tab_dados(idx - 1).vr_vlacumul + vr_tab_dados(idx).vr_valorapl;
      END IF;

      -- Para totalizar demais registros
      IF idx = 19 THEN
        vr_tot_vlacumul := vr_tab_dados(idx).vr_vlacumul;
      END IF;
    END LOOP;

    -- Escrever dados de sumarização no XML
    pc_xml_tag('<prazoMedio vr_rel_dsmesref= "'||vr_rel_dsmesref||'">', vr_str_1);

    FOR idx IN 1..vr_tab_dados.count() LOOP
      IF idx <= 4 THEN
        vr_valortexto := vr_valortexto + 90;
        vr_texto := 'ATE ' || vr_valortexto;
      ELSE
        IF idx = 19 THEN
          vr_texto := 'MAIS DE ' || vr_valortexto;
        ELSE
          vr_valortexto := vr_valortexto + 360;
          vr_texto := 'ATE ' || vr_valortexto;
        END IF;
      END IF;
      pc_xml_tag('<prazo>', vr_str_1);
      pc_xml_tag('<vr_texto>' || vr_texto || '</vr_texto>', vr_str_1);
      pc_xml_tag('<vr_valorapl>' || to_char(nvl(vr_tab_dados(idx).vr_valorapl, 0), 'FM999G999G990D00') ||
                 '</vr_valorapl>', vr_str_1);
      pc_xml_tag('<vr_vlacumul>' || to_char(nvl(vr_tab_dados(idx).vr_vlacumul, 0), 'FM999G999G990D00') ||
                 '</vr_vlacumul>', vr_str_1);
      pc_xml_tag('<vr_qtdaplic>' || to_char(nvl(vr_tab_dados(idx).vr_qtdaplic, 0), 'FM999G999G990') ||
                 '</vr_qtdaplic>', vr_str_1);
      pc_xml_tag('</prazo>', vr_str_1);
    END LOOP;

    pc_xml_tag('</prazoMedio>', vr_str_1);

    pc_xml_tag('<prazoMedioTotal><total>' || to_char(nvl(vr_tot_vlacumul, 0), 'FM999G999G990D00') ||
               '</total></prazoMedioTotal>', vr_str_1);

    pc_xml_tag('<debitos>', vr_str_1);

    -- Consultar dados de rejeitados
    FOR vr_craprej IN cr_craprej(pr_cdcooper, vr_cdprogra) LOOP
      -- Atribuir contador
      vr_count := vr_count + 1;

      -- Atribuir valores para as variáveis
      vr_rel_dtdebito := vr_craprej.dtmvtolt;
      vr_rel_qtdebito := vr_rel_qtdebito + 1;
      vr_rel_vldebito := vr_rel_vldebito + vr_craprej.vllanmto;
      vr_tot_qtdebito := vr_tot_qtdebito + 1;
      vr_tot_vldebito := vr_tot_vldebito + vr_craprej.vllanmto;

      -- Identifica se a data é diferente da anterior
      IF ( vr_craprej.dtmvtolt <> nvl(vr_dtctr, vr_craprej.dtmvtolt) ) THEN

        pc_xml_tag('<debito><vr_rel_dtdebito>' || to_char(vr_dtctr, 'DD/MM/RRRR') ||
                   '</vr_rel_dtdebito>', vr_str_1);
        pc_xml_tag('<vr_rel_qtdebito>' || to_char(nvl(vr_rel_qtdebito - 1, 0), 'FM999G999G990') ||
                   '</vr_rel_qtdebito>', vr_str_1);
        pc_xml_tag('<vr_rel_vldebito>' || to_char(nvl(vr_rel_vldebito - vr_craprej.vllanmto, 0), 'FM999G999G990D00') ||
                   '</vr_rel_vldebito></debito>', vr_str_1);

        -- reiniciar valores de variáveis
        vr_rel_dtdebito := vr_craprej.dtmvtolt;
        vr_rel_qtdebito := 1;
        vr_rel_vldebito := vr_craprej.vllanmto;
      END IF;

      -- SE FOR O ULTIMO imprimir valores correntes
      IF ( vr_count = vr_craprej.contagem ) THEN
        pc_xml_tag('<debito><vr_rel_dtdebito>' || to_char(vr_rel_dtdebito, 'DD/MM/RRRR') ||
                   '</vr_rel_dtdebito>', vr_str_1);
        pc_xml_tag('<vr_rel_qtdebito>' || to_char(nvl(vr_rel_qtdebito , 0), 'FM999G999G990') ||
                   '</vr_rel_qtdebito>', vr_str_1);
        pc_xml_tag('<vr_rel_vldebito>' || to_char(nvl(vr_rel_vldebito, 0), 'FM999G999G990D00') ||
                   '</vr_rel_vldebito></debito>', vr_str_1);
      END IF;
      -- Atribui o valor da data em execução
      vr_dtctr := vr_craprej.dtmvtolt;

      -- Deletar dados de rejeitados
      DELETE craprej ce WHERE ce.rowid = vr_craprej.rowid;
    END LOOP;

    --Senao existir registros apenas envia a tag para montar rel no ireport
    IF vr_count = 0 then
      pc_xml_tag('<debito></debito>', vr_str_1);
    END IF;
    
    -----------------------------------------------
    -- Inicio de geracao de arquivo AAMMDD_POUP.txt
    -----------------------------------------------    

    -- Arquivo gerado somente no processo mensal
    IF TRUNC(rw_crapdat.dtmvtopr,'MM') <> TRUNC(rw_crapdat.dtmvtolt,'MM') THEN
      
       -- Busca o caminho padrao do arquivo no unix + /integra
       vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'contab');

       -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
       vr_nmarqtxt:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_POUP.txt';

       -- Tenta abrir o arquivo de log em modo gravacao
       gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                               ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                               ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);  --> Erro
       IF vr_dscritic IS NOT NULL THEN
          -- Levantar Excecao
          RAISE vr_exc_erro;
       END IF;
       
       -- Se o valro total é maior que zero
       IF nvl(vr_tot_rppagefis,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(4257, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(4277, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_rppagefis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"SALDO TOTAL DE TITULOS ATIVOS POUPANCA PROGRAMADA - COOPERADOS PESSOA FISICA"';           --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
             
         -- Verifica se existe valores       
         IF vr_typ_tab_vlrppage_fis.COUNT > 0 THEN
               
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             
              -- Gravas as informacoes de valores por agencia
              FOR vr_idx_agencia IN vr_typ_tab_vlrppage_fis.FIRST()..vr_typ_tab_vlrppage_fis.LAST() LOOP
                  -- Verifica se existe a informacao
                  IF vr_typ_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
                    -- Se valor é maior que zero
                    IF vr_typ_tab_vlrppage_fis(vr_idx_agencia) > 0 THEN
                      -- Montar linha para gravar no arquivo
                      vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrppage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                      -- Escrever linha no arquivo
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                    ,pr_des_text => vr_setlinha); --> Texto para escrita
                    END IF;
                  END IF;
                  -- Limpa variavel
                  vr_setlinha := '';       
              END LOOP;
                
            END LOOP;
         END IF;

         -- Montando o cabecalho para fazer a reversao das
         -- conta para estornar os valores caso necessario
         vr_setlinha := '70'||                                                                                     --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                               --> Data DDMMAA
                        gene0002.fn_mask(4277, pr_dsforma => '9999')||','||                                        --> Conta Destino
                        gene0002.fn_mask(4257, pr_dsforma => '9999')||','||                                        --> Conta Origem
                        TRIM(TO_CHAR(vr_tot_rppagefis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                        --> Fixo
                        '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS POUPANCA PROGRAMADA - COOPERADOS PESSOA FISICA"';          --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
             
         -- Verifica se existe valores       
         IF vr_typ_tab_vlrppage_fis.COUNT > 0 THEN               
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_typ_tab_vlrppage_fis.FIRST()..vr_typ_tab_vlrppage_fis.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_typ_tab_vlrppage_fis.EXISTS(vr_idx_agencia) THEN
                 -- Se valor é maior que zero
                 IF vr_typ_tab_vlrppage_fis(vr_idx_agencia) > 0 THEN
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrppage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
               
           END LOOP; -- fim repete
         END IF;
       END IF; -- Se total maior que zero
       
       -- Se o valro total é maior que zero
       IF nvl(vr_tot_rppagejur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(4257, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(4278, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"SALDO TOTAL DE TITULOS ATIVOS POUPANCA PROGRAMADA - COOPERADOS PESSOA JURIDICA"';         --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
             
         -- Verifica se existe valores       
         IF vr_typ_tab_vlrppage_jur.COUNT > 0 THEN   
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_typ_tab_vlrppage_jur.FIRST()..vr_typ_tab_vlrppage_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_typ_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor é maior que zero
                 IF vr_typ_tab_vlrppage_jur(vr_idx_agencia) > 0 THEN
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrppage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   --Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
         
         -- Montando o cabecalho para fazer a reversao das
         -- conta para estornar os valores caso necessario
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(4278, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        gene0002.fn_mask(4257, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        TRIM(TO_CHAR(vr_tot_rppagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS POUPANCA PROGRAMADA - COOPERADOS PESSOA JURIDICA"';         --> Descricao
                        
         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         -- Verifica se existe valores       
         IF vr_typ_tab_vlrppage_jur.COUNT > 0 THEN               
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_typ_tab_vlrppage_jur.FIRST()..vr_typ_tab_vlrppage_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_typ_tab_vlrppage_jur.EXISTS(vr_idx_agencia) THEN
                 -- Se o valor é maior que zero
                 IF vr_typ_tab_vlrppage_jur(vr_idx_agencia) > 0 THEN
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_typ_tab_vlrppage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrit
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
       END IF; -- Se total maior que zero
       
       -- Se o valro total é maior que zero
       IF nvl(vr_tot_vlrprvfis,0) > 0 THEN
         
         /*** Montando as informacoes de PESSOA FISICA ***/
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8063, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8123, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrprvfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"PROVISAO DO MES - POUPANCA PROGRAMADA COOPERADOS PESSOA FISICA"';                         --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_fis.COUNT > 0 THEN
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrprvmes_fis.FIRST()..vr_tot_vlrprvmes_fis.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrprvmes_fis.EXISTS(vr_idx_agencia) THEN
                 -- Se o valor for maior que zero
                 IF vr_tot_vlrprvmes_fis(vr_idx_agencia) > 0 THEN
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
         
         -- Montando o cabecalho para fazer a reversao das
         -- conta para estornar os valores caso necessario
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8123, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8063, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrprvfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"'||vr_dsprefix||'PROVISAO DO MES - POUPANCA PROGRAMADA COOPERADOS PESSOA FISICA"';                         --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_fis.COUNT > 0 THEN
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrprvmes_fis.FIRST()..vr_tot_vlrprvmes_fis.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrprvmes_fis.EXISTS(vr_idx_agencia) THEN
                 -- Se o valor é maior que zero
                 IF vr_tot_vlrprvmes_fis(vr_idx_agencia) > 0 THEN
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   -- Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
       END IF; -- Se total maior que zero
       
       -- Se o valro total é maior que zero
       IF nvl(vr_tot_vlrprvjur,0) > 0 THEN
       
         /*** Montando as informacoes de PESSOA JURIDICA ***/       
         -- Montando o cabecalho das contas do dia atual
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8064, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        gene0002.fn_mask(8123, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        TRIM(TO_CHAR(vr_tot_vlrprvjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"PROVISAO DO MES - POUPANCA PROGRAMADA COOPERADOS PESSOA JURIDICA"';                       --> Descricao

         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
             
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_jur.COUNT > 0 THEN   
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrprvmes_jur.FIRST()..vr_tot_vlrprvmes_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrprvmes_jur.EXISTS(vr_idx_agencia) THEN       
                 -- Se o valor é maior que zero
                 IF vr_tot_vlrprvmes_jur(vr_idx_agencia) > 0 THEN       
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   --Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
         
         -- Montando o cabecalho para fazer a reversao das
         -- conta para estornar os valores caso necessario
         vr_setlinha := '70'||                                                                                      --> Informacao inicial
                        TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                        TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                                --> Data DDMMAA
                        gene0002.fn_mask(8123, pr_dsforma => '9999')||','||                                         --> Conta Destino
                        gene0002.fn_mask(8064, pr_dsforma => '9999')||','||                                         --> Conta Origem
                        TRIM(TO_CHAR(vr_tot_vlrprvjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                        gene0002.fn_mask(1434, pr_dsforma => '9999')||','||                                         --> Fixo
                        '"'||vr_dsprefix||'PROVISAO DO MES - POUPANCA PROGRAMADA COOPERADOS PESSOA JURIDICA"';                       --> Descricao
                        
         gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                       ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         -- Verifica se existe valores       
         IF vr_tot_vlrprvmes_jur.COUNT > 0 THEN   
           -- imprimir as informações para cada conta, ou seja, duplicado
           FOR repete IN 1..2 LOOP
             -- Gravas as informacoes de valores por agencia
             FOR vr_idx_agencia IN vr_tot_vlrprvmes_jur.FIRST()..vr_tot_vlrprvmes_jur.LAST() LOOP
               -- Verifica se existe a informacao
               IF vr_tot_vlrprvmes_jur.EXISTS(vr_idx_agencia) THEN  
                 -- Se o valor é maior que zero
                 IF vr_tot_vlrprvmes_jur(vr_idx_agencia) > 0 THEN  
                   -- Montar linha para gravar no arquivo
                   vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tot_vlrprvmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                   --Escrever linha no arquivo
                   gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                 ,pr_des_text => vr_setlinha); --> Texto para escrita
                 END IF;
               END IF;
               -- Limpa variavel
               vr_setlinha := '';       
             END LOOP;
           END LOOP; -- fim repete
         END IF;
       END IF; -- Se total maior que zero
              
       --Fechar Arquivo
       BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
       EXCEPTION
          WHEN OTHERS THEN
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
       END;

       -- Buscar o diretório micros
       vr_nom_micros := gene0001.fn_diretorio(pr_tpdireto => 'M'   
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/contab'); 
       
       -- Executa comando UNIX para converter arq para Dos
       vr_dscomand := 'ux2dos ' || vr_nom_direto ||'/'||vr_nmarqtxt||' > '
                                || vr_nom_micros ||'/'||vr_nmarqtxt || ' 2>/dev/null';

       -- Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_dscomand
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
       IF vr_typ_saida = 'ERR' THEN
         RAISE vr_exc_erro;
       END IF;

    END IF;

    -----------------------------------------------
    -- Fim de geracao de arquivo AAMMDD_POUP.txt       
    -----------------------------------------------

    -- Escrever totais no XML
    pc_xml_tag('</debitos>', vr_str_1);
    pc_xml_tag('<totalDebito><vr_tot_qtdebito>' || to_char(nvl(vr_tot_qtdebito, 0), 'FM999G999G990') ||
               '</vr_tot_qtdebito>', vr_str_1);
    pc_xml_tag('<vr_tot_vldebito>' || to_char(nvl(vr_tot_vldebito, 0), 'FM999G999G990D00') ||
               '</vr_tot_vldebito></totalDebito>', vr_str_1);

    -- Escrever total no XML
    pc_xml_tag('<total>' || to_char(vr_res_vlrppati, 'FM999G999G990D00') || '</total>', vr_str_2);

    -- Finalizar XML
    pc_xml_tag('</base>', vr_str_1);
    pc_xml_tag('</base>', vr_str_2);
    
    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_str_1
                               ,pr_dsxmlnode => '/base'
                               ,pr_dsjasper  => 'crrl123.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nom_dir || '/crrl123.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => vr_dscritic);

    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      RAISE vr_exc_erro;
    END IF;
    
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => vr_cdprogra
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_str_2
                               ,pr_dsxmlnode => '/base/dados'
                               ,pr_dsjasper  => 'crps147.jasper'
                               ,pr_dsparams  => NULL
                               ,pr_dsarqsaid => vr_nom_dirs || '/crps147.dat'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 80
                               ,pr_sqcabrel  => 1
                               ,pr_cdrelato  => NULL
                               ,pr_flg_impri => 'N'
                               ,pr_nmformul  => NULL
                               ,pr_nrcopias  => NULL
                               ,pr_dspathcop => NULL
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'S'
                               ,pr_des_erro  => vr_dscritic);

    -- Verifica se ocorreram erros
    IF vr_dscritic IS NOT NULL THEN
      vr_cdcritic := 0;
      RAISE vr_exc_erro;
    END IF;

    -- Liberar dados do CLOB da memória
    dbms_lob.close(vr_str_1);
    dbms_lob.freetemporary(vr_str_1);
    dbms_lob.close(vr_str_2);
    dbms_lob.freetemporary(vr_str_2);

    -- Limpa Variavel de Memoria    
    vr_typ_tab_vlrppage_fis.DELETE;
    vr_typ_tab_vlrppage_jur.DELETE;
    vr_tot_vlrprvmes_fis.DELETE;
    vr_tot_vlrprvmes_jur.DELETE;
    vr_tab_total.DELETE;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Efetuar o commit
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
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

      -- Efetuar commit pois gravaremos o que foi processo até então
      -- Efetuar o commit
      COMMIT;
    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS147;
/
