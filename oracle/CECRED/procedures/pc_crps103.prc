CREATE OR REPLACE PROCEDURE CECRED.pc_crps103(pr_cdcooper  in craptab.cdcooper%type,
                                              pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                              pr_stprogra out pls_integer,            --> Saída de termino da execução
                                              pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                              pr_cdcritic out crapcri.cdcritic%type,
                                              pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps103 (antigo Fontes/crps103.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/94.                    Ultima atualizacao: 15/03/2017

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular o rendimento mensal e liquido das aplicacoes RDCA e lis-
               tar o resumo mensal.
               Ordem da solicitacao: 10
               Ordem do programa na solicitacao: 3
               Relatorios 86 e 559

   Alteracoes: 16/02/95 - Alteracoes em funcao da nova rotina de calculo
                          (Deborah).

               07/03/95 - Alterado o layout do relatorio (nome do campo) (Debo-
                          rah).

               11/10/95 - Alterado para incluir na leitura do lap o tratamento
                          para o historico 143. (Odair).

               22/11/96 - Alterado para selecionar somente registros com
                          tpaplica = 3 (Odair).

               17/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               03/03/98 - Acerto da alteracao anterior (Deborah).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/05/98 - Nao atualizar a solicitacao como processada (Odair).

               25/01/98 - Alterado para guardar no crapcot o valor de IOF
                          abonado (Deborah).

               07/01/2000 - Nao gerar relatorio (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               07/01/2004 - Incluir IRRF pago durante o mes (Margarete).

               28/01/2004 - Nao atualizar campos do abono de cpmf (Margarete).

               19/04/2004 - Atualizar novos campos do craprda (Margarete).

               24/05/2004 - Lista total do histor 866 (Margarete).

               05/07/2004 - Quando saque na carencia atualizacao vlslfmes
                            errada (Margarete).

              22/09/2004 - Incluidos historicos 492/493(CI)(Mirtes)

              07/10/2004 - Quando saque total nao esta zerando saldo
                           do final do mes (Margarete).

              16/12/2004 - Incluidos historicos 875/877(Ajuste IR)(Mirtes)

              28/12/2004 - Alinhados os campos no relatorio (Evandro).

              01/09/2005 - Tratar leitura do craprda (Margarete).

              06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).

              15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

              13/04/2006 - Acertar atualizacao do campo vlslfmes (Magui)

              26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).

              11/07/2007 - Incluido na leitura do craplap para emissao do
                           relatorio os historicos possiveis (Magui).

              03/12/2007 - Substituir chamada da include aplicacao.i pela
                           BO b1wgen0004.i. (Sidnei - Precise).

              07/05/2010 - Incluido relatorio crrl559.lst - Analitico RDCA30
                           (Elton).

              26/08/2010 - Inserir na crapprb o somatorio das aplicacoes.
                           Tarefa 34646 (Henrique).

              26/11/2010 - Retirar da sol 3 ordem 8 e colocar na sol 83
                           ordem 5.E na CECRED sol 83 e ordem 6 (Magui).

              26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)

              30/10/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

              24/07/2014 - Incluido as colunas dtsdfmea e vlslfmea na CRAPRDA
                           (Andrino - RKAM)
                           
              10/04/2015 - Projeto de separação contábeis de PF e PJ.
                           (Andre Santos - SUPERO)
                           
              08/05/2015 - Ajuster a geração do arquivo de capital, utilizando a 
                           data+1 para os dados de reversão e alterando o separador
                           dos valores para vírgula. ( Renato - Supero)
                           
              03/08/2015 - Não exibir no arquivo informações de agencias com valor 
                           zero. Conforme chamado 315716. ( Renato - Supero )
                           
	            28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                           P308 (Ricardo Linhares). 
                           
              15/03/2017 - Remover lançamentos de reversão das contas de resultado
                           para envio ao Radar ou Matera P307. (Jonatas - Supero) 
                                                     
              25/06/2019 - Remover lancamentos de segregacao/reversao para contas PF/PJ.
                           Apos atualizacao do plano de contas, nao e mais necessaria realizar essa segregacao.
                           Solicitacao Contabilidade - Heitor (Mouts)
                           
............................................................................. */

  -- Leituras para include da BO de Aplicacao
  CURSOR cr_crapcop IS
    SELECT nrctactl
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%ROWTYPE;

  -- Aplicações RDCA não calculadas no mês
  CURSOR cr_craprda (pr_cdcooper IN craprda.cdcooper%TYPE) IS
    SELECT craprda.nrdconta,
           DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa, /* Tratamento para considerar pessoas do tipo 3 como PJ */
           crapass.cdagenci,
           craprda.nraplica,
           craprda.dtcalcul,
           craprda.insaqtot,
           craprda.dtmvtolt,
           craprda.vlabdiof,
           craprda.qtrgtmfx,
           craprda.qtaplmfx,
           craprda.flgctain,
           craprda.vlaplica,
           craprda.vlabcpmf,
           craprda.vlslfmes,
           craprda.cdageass,
           craprda.tpaplica,
           craprda.rowid row_id,
           crapage.nmresage,
           crapass.nmprimtl
      FROM crapass,
           crapage,
           craprda
     WHERE craprda.cdcooper = pr_cdcooper
       AND craprda.tpaplica = 3
       AND crapage.cdcooper = craprda.cdcooper
       AND crapage.cdagenci = craprda.cdageass
       AND crapass.cdcooper = craprda.cdcooper
       AND crapass.nrdconta = craprda.nrdconta
     ORDER BY nrdconta,
              nraplica;

  -- Lançamentos do mês
  CURSOR cr_craplap (pr_cdcooper in craplap.cdcooper%TYPE,
                     pr_dtinimes in craplap.dtmvtolt%TYPE,
                     pr_dtfimmes in craplap.dtmvtolt%TYPE) IS
    SELECT /*+ index (craplap craplap##craplap4)*/
           craplap.nrdconta,
           DECODE(crapass.inpessoa,3,2,crapass.inpessoa) inpessoa,
           crapass.cdagenci,
           craplap.nraplica,
           craplap.cdhistor,
           craplap.dtmvtolt,
           craplap.vllanmto,
           craplap.nrdolote
      FROM craplap,
           crapass      
     WHERE craplap.cdcooper = crapass.cdcooper
       AND craplap.nrdconta = crapass.nrdconta
       AND craplap.cdcooper = pr_cdcooper
       AND craplap.dtmvtolt > pr_dtinimes
       AND craplap.dtmvtolt < pr_dtfimmes
       AND craplap.cdhistor in (118,492,143,116,117,119,124,121,125,126,493,861,875,877,868)
     ORDER BY craplap.dtmvtolt,
              craplap.cdhistor;

  -- Rendimento da aplicação
  CURSOR cr_craprda2 (pr_cdcooper in craprda.cdcooper%TYPE,
                      pr_nrdconta in craprda.nrdconta%TYPE,
                      pr_nraplica in craprda.nraplica%TYPE) IS
    SELECT /*+ index (craprda craprda##craprda2)*/
           craprda.cdcooper,
           craprda.nrdconta,
           craprda.nraplica,
           craprda.insaqtot,
           craprda.flgctain,
           craprda.cdageass
      FROM craprda
     WHERE craprda.cdcooper = pr_cdcooper
       AND craprda.nrdconta = pr_nrdconta
       AND craprda.nraplica = pr_nraplica;

  -- Inicializando Variaveis
  rw_craprda2    cr_craprda2%ROWTYPE;
  rw_crapdat     btch0001.cr_crapdat%ROWTYPE;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%TYPE;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;
  vr_dtmvtopr      crapdat.dtmvtopr%TYPE;
  vr_inproces      crapdat.inproces%TYPE;
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_exc_fimprg    EXCEPTION;
  vr_cdcritic      PLS_INTEGER;
  vr_dscritic      VARCHAR2(4000);
  vr_typ_saida     VARCHAR2(4000);
  vr_dscomand      VARCHAR2(1000);

  -- PL/Table para armazenar informações para o BNDES
  TYPE typ_reg_faixa_ir_rdca IS RECORD (vlaplica crapprb.vlretorn%type);
  type typ_tab_faixa_ir_rdca IS TABLE OF typ_reg_faixa_ir_rdca INDEX BY BINARY_INTEGER;
  
  -- Instancia e indexa por agencia as aplicacoes ativas de pessoa fisica
  TYPE typ_tab_vlrdcage_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlrdcage_fis typ_tab_vlrdcage_fis;

  -- Instancia e indexa por agencia as aplicacoes ativas de pessoa juridica
  TYPE typ_tab_vlrdcage_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlrdcage_jur typ_tab_vlrdcage_jur;
  
  -- Instancia e indexa por agencia as provisoes mensais de pessoa fisica
  TYPE typ_tab_vlpvrmes_fis IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlpvrmes_fis typ_tab_vlpvrmes_fis;

  -- Instancia e indexa por agencia as provisoes mensais de pessoa juridica
  TYPE typ_tab_vlpvrmes_jur IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  vr_tab_vlpvrmes_jur typ_tab_vlpvrmes_jur;

  vr_cta_bndes     typ_tab_faixa_ir_rdca;
  vr_indice        NUMBER;

  -- PL/Table para armazenar o detalhamento da aplicacão
  TYPE typ_reg_detalhe IS RECORD (tpaplica  craprda.tpaplica%TYPE,
                                  cdagenci  craprda.cdagenci%TYPE,
                                  nrdconta  craprda.nrdconta%TYPE,
                                  nraplica  craprda.nraplica%TYPE,
                                  dtaplica  craprda.dtmvtolt%TYPE,
                                  vlaplica  craprda.vlaplica%TYPE,
                                  vlrgtmes  craplap.vllanmto%TYPE,
                                  vlsldrdc  craprda.vlslfmes%TYPE,
                                  txaplica  number(25,8),
                                  nmresage  crapage.nmresage%TYPE,
                                  nmprimtl  crapass.nmprimtl%TYPE);

  -- PL/Table para armazenar o detalhamento da aplicacão
  TYPE typ_tab_detalhe IS TABLE OF typ_reg_detalhe INDEX BY VARCHAR2(25);

  vr_detalhe       typ_tab_detalhe;
  vr_ind_detalhe   VARCHAR2(25);
  vr_cdagenci_det  craprda.cdageass%TYPE;
  
  -- Constante de complemento inicial das mensagens de reversão
  vr_dsprefix      CONSTANT VARCHAR2(15) := 'REVERSAO ';

  -- Definicao do tipo de registro para tabela aplicacao separadas por PF e PJ
  TYPE typ_reg_aplicacao IS RECORD (qtaplati NUMBER    -- QUANTIDADE DE TITULOS ATIVOS
                                   ,qtaplmes NUMBER    -- QUANTIDADE DE TITULOS APLICADOS NO MES
                                   ,vlsdapat NUMBER    -- SALDO TOTAL DOS TITULOS ATIVOS
                                   ,vlaplmes NUMBER    -- VALOR TOTAL APLICADO NO MES
                                   ,vlresmes NUMBER    -- VALOR TOTAL DOS RESGATES DO MES
                                   ,vlrenmes NUMBER    -- RENDIMENTO CREDITADO NO MES
                                   ,vlprvmes NUMBER    -- VALOR TOTAL DA PROVISAO DO MES
                                   ,vlprvlan NUMBER    -- PROVISAO DE APLICACOES A VENCER
                                   ,vlajuprv NUMBER    -- AJUSTE DE PROVISAO
                                   ,vlsaques NUMBER    -- SAQUES SEM RENDIMENTO
                                   ,vlrtirrf NUMBER    -- VALOR TOTAL DO IRRF
                                   ,vlrtirab NUMBER    -- VALOR TOTAL DO IR SOBRE ABONO
                                   ,vlirajrg NUMBER    -- VALOR TOTAL DO IR AJUSTE RESGATE
                                   ,vlirajrn NUMBER    -- VALOR TOTAL DO IR AJUSTE REND
                                   ,bsabcpmf NUMBER    -- ABONOS ADIANTADOS A RECUPERAR
                                   ,qtrenmfx NUMBER);  -- RENDIMENTO LIQUIDO ACUMULADO EM UFIR

  -- Pl-table para separacao dos totais de capitalizacao por PF e PJ
  TYPE typ_tab_aplicacao IS TABLE OF typ_reg_aplicacao INDEX BY PLS_INTEGER;
  vr_tab_aplicacao  typ_tab_aplicacao;

  -- Variáveis auxiliares para o processamento
  vr_qtaplati      NUMBER(6) := 0;
  vr_qtaplmes      NUMBER(6) := 0;
  vr_vlsdapat      NUMBER(16,2) := 0;
  vr_vlaplmes      NUMBER(16,2) := 0;
  vr_qtrenmfx      NUMBER(16,4) := 0;
  vr_bsabcpmf      NUMBER(16,4) := 0;
  vr_qtaplati_a    NUMBER(6) := 0;
  vr_qtaplmes_a    NUMBER(6) := 0;
  vr_vlsdapat_a    NUMBER(16,2) := 0;
  vr_vlaplmes_a    NUMBER(16,2) := 0;
  vr_qtrenmfx_a    NUMBER(16,4) := 0;
  vr_bsabcpmf_a    NUMBER(16,4) := 0;
  vr_qtaplati_n    NUMBER(6) := 0;
  vr_qtaplmes_n    NUMBER(6) := 0;
  vr_vlsdapat_n    NUMBER(16,2) := 0;
  vr_vlaplmes_n    NUMBER(16,2) := 0;
  vr_qtrenmfx_n    NUMBER(16,4) := 0;
  vr_bsabcpmf_n    NUMBER(16,4) := 0;

  vr_vlresmes_n    craplap.vllanmto%TYPE := 0;
  vr_vlrenmes_n    craplap.vllanmto%TYPE := 0;
  vr_vlprvmes_n    craplap.vllanmto%TYPE := 0;
  vr_vlprvlan_n    craplap.vllanmto%TYPE := 0;
  vr_vlajuprv_n    craplap.vllanmto%TYPE := 0;
  vr_vlsaques_n    craplap.vllanmto%TYPE := 0;
  vr_vlrtirrf_n    craplap.vllanmto%TYPE := 0;
  vr_vlirajrg_n    craplap.vllanmto%TYPE := 0;
  vr_vlirajrn_n    craplap.vllanmto%TYPE := 0;
  vr_vlrtirab_n    craplap.vllanmto%TYPE := 0;
  vr_vlresmes_a    craplap.vllanmto%TYPE := 0;
  vr_vlrenmes_a    craplap.vllanmto%TYPE := 0;
  vr_vlprvmes_a    craplap.vllanmto%TYPE := 0;
  vr_vlprvlan_a    craplap.vllanmto%TYPE := 0;
  vr_vlajuprv_a    craplap.vllanmto%TYPE := 0;
  vr_vlsaques_a    craplap.vllanmto%TYPE := 0;
  vr_vlrtirrf_a    craplap.vllanmto%TYPE := 0;
  vr_vlirajrg_a    craplap.vllanmto%TYPE := 0;
  vr_vlirajrn_a    craplap.vllanmto%TYPE := 0;
  vr_vlrtirab_a    craplap.vllanmto%TYPE := 0;
  vr_vlresmes      craplap.vllanmto%TYPE := 0;
  vr_vlrenmes      craplap.vllanmto%TYPE := 0;
  vr_vlprvmes      craplap.vllanmto%TYPE := 0;
  vr_vlprvlan      craplap.vllanmto%TYPE := 0;
  vr_vlajuprv      craplap.vllanmto%TYPE := 0;
  vr_vlsaques      craplap.vllanmto%TYPE := 0;
  vr_vlrtirrf      craplap.vllanmto%TYPE := 0;
  vr_vlirajrg      craplap.vllanmto%TYPE := 0;
  vr_vlirajrn      craplap.vllanmto%TYPE := 0;
  vr_vlrtirab      craplap.vllanmto%TYPE := 0;
  vr_sldpresg_tmp  craplap.vllanmto%TYPE; --> Valor saldo de resgate
  vr_dup_vlsdrdca  craplap.vllanmto%TYPE; --> Acumulo do saldo da aplicacao RDCA
  vr_nom_direto     VARCHAR2(400);        --> Nome da pasta para arquivo de dados
  vr_nmarqtxt       VARCHAR2(100);        --> Nome do arquivo TXT
  vr_input_file     UTL_FILE.file_type;   --> Handle Utl File
  vr_setlinha       VARCHAR2(400);        --> Linhas do arquivo
  vr_tot_rdcagefis  NUMBER := 0;          --> Valor Total
  vr_tot_rdcagejur  NUMBER := 0;          --> Valor Total
  vr_tot_prvmesfis      craplap.vllanmto%TYPE := 0;
  vr_tot_prvmesjur      craplap.vllanmto%TYPE := 0;  
   
  vr_dircon VARCHAR2(200);
  vr_arqcon VARCHAR2(200);
 
  aux_ttslfmes     NUMBER(16,2) := 0;
  aux_dtinimes     DATE;
  aux_dtfimmes     DATE;
  aux_qtrenmfx     NUMBER(16,4) := 0;
  aux_vlsdextr     craprda.vlsdrdca%TYPE := 0;
  aux_vlslfmes     craprda.vlsdrdca%TYPE := 0;
  aux_flgdomes     BOOLEAN;
  -- Variáveis de retorno do cálculo da aplicação
  aux_vlsdrdca     craprda.vlsdrdca%TYPE;
  vr_vlsldapl      craprda.vlsdrdca%TYPE;
  vr_txaplica      craptrd.txofidia%TYPE;
  vr_vldperda      craprda.vlsdrdca%TYPE;
  vr_tab_erro      gene0001.typ_tab_erro;       --> Tabela com erros da gene0001.pc_gera_erro
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       CLOB;
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);
  vr_nom_arquivo   VARCHAR2(200);

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR) IS
     BEGIN
       dbms_lob.writeappend(vr_des_xml, length(pr_des_dados), pr_des_dados);
     END;
     
-------------------------------------
-- Inicio Bloco Principal pc_crps103
-------------------------------------     

BEGIN
  
  -- Nome do programa
  vr_cdprogra := 'CRPS103';

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS103',
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  IF vr_cdcritic <> 0 THEN
     -- Envio centralizado de log de erro
     RAISE vr_exc_saida;
  END IF;
  
  -- Buscar a data do movimento
  OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gera erro caso não exista
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
  CLOSE btch0001.cr_crapdat;
   
  vr_dtmvtolt := rw_crapdat.dtmvtolt;
  vr_dtmvtopr := rw_crapdat.dtmvtopr;
  vr_inproces := rw_crapdat.inproces;

  -- Leitura das aplicacoes resgatadas no mes
  aux_dtinimes := trunc(vr_dtmvtolt, 'mm') - 1; -- Último dia do mês anterior
  aux_dtfimmes := last_day(vr_dtmvtolt) + 1; -- Primeiro dia do próximo mês

  vr_cdcritic := 0;
  vr_tab_aplicacao.DELETE;
  vr_tab_vlrdcage_fis.DELETE;
  vr_tab_vlrdcage_jur.DELETE;
  vr_tab_vlpvrmes_fis.DELETE;
  vr_tab_vlpvrmes_jur.DELETE;  

  -- Inicializa os valores de memoria
  FOR idx IN 1..2 LOOP
     vr_tab_aplicacao(idx).qtaplati := 0;
     vr_tab_aplicacao(idx).qtaplmes := 0;
     vr_tab_aplicacao(idx).vlsdapat := 0;
     vr_tab_aplicacao(idx).vlaplmes := 0;
     vr_tab_aplicacao(idx).vlresmes := 0;
     vr_tab_aplicacao(idx).vlrenmes := 0;
     vr_tab_aplicacao(idx).vlprvmes := 0;
     vr_tab_aplicacao(idx).vlprvlan := 0;
     vr_tab_aplicacao(idx).vlajuprv := 0;
     vr_tab_aplicacao(idx).vlsaques := 0;
     vr_tab_aplicacao(idx).vlrtirrf := 0;
     vr_tab_aplicacao(idx).vlrtirab := 0;
     vr_tab_aplicacao(idx).vlirajrg := 0;
     vr_tab_aplicacao(idx).vlirajrn := 0;
     vr_tab_aplicacao(idx).bsabcpmf := 0;
     vr_tab_aplicacao(idx).qtrenmfx := 0;
  END LOOP;

  -- Busca faixas de IR
  apli0001.pc_busca_faixa_ir_rdca(pr_cdcooper);

  -- Leituras para include da BO de Aplicacao
  OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa não cadastrada';
      RAISE vr_exc_saida;
    END IF;
  CLOSE cr_crapcop;

  -- Busca aplicações RDCA não calculadas no mês
  FOR rw_craprda IN cr_craprda (pr_cdcooper) LOOP

    aux_qtrenmfx := 0;
    vr_cdcritic  := 0;
    aux_vlsdextr := 0;
    aux_vlslfmes := 0;
    aux_flgdomes := FALSE;

    -- Se a data for no mês atual
    IF rw_craprda.dtcalcul > aux_dtinimes AND
       rw_craprda.dtcalcul < aux_dtfimmes THEN
      aux_flgdomes := TRUE;
    END IF;

    -- Verifica se foi saque total (0 = não)
    IF rw_craprda.insaqtot = 0 THEN

      -- Rotina de calculo da aplicacao
      apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper,         --> Cooperativa
                                            pr_dtmvtolt => vr_dtmvtolt,         --> Data do processo
                                            pr_inproces => vr_inproces, --> Indicador do processo
                                            pr_dtmvtopr => vr_dtmvtopr,         --> Próximo dia util
                                            pr_cdprogra => vr_cdprogra,         --> Programa em execução
                                            pr_cdagenci => 0,                   --> Código da agência
                                            pr_nrdcaixa => 0,                   --> Número do caixa
                                            pr_nrdconta => rw_craprda.nrdconta, --> Nro da conta da aplicação RDCA
                                            pr_nraplica => rw_craprda.nraplica, --> Nro da aplicação RDCA
                                            pr_vlsdrdca => aux_vlsdrdca,        --> Saldo da aplicação
                                            pr_vlsldapl => vr_vlsldapl,         --> Saldo da aplicação RDCA
                                            pr_sldpresg => vr_sldpresg_tmp,     --> Valor saldo de resgate
                                            pr_dup_vlsdrdca => vr_dup_vlsdrdca, --> Acumulo do saldo da aplicacao RDCA
                                            pr_vldperda => vr_vldperda,         --> Valor calculado da perda
                                            pr_txaplica => vr_txaplica,         --> Taxa aplicada sob o empréstimo
                                            pr_des_reto => vr_dscritic,         --> OK ou NOK
                                            pr_tab_erro => vr_tab_erro);        --> Tabela com erros
      -- Se retornou erro
      IF vr_dscritic = 'NOK' THEN
         -- Tenta buscar o erro no vetor de erro
         IF vr_tab_erro.count > 0 THEN
           vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
           vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic|| ' Conta: '||rw_craprda.nrdconta;
         ELSE
           vr_cdcritic := 0;
           vr_dscritic := 'Retorno "NOK" na apli0001.pc_consul_saldo_aplic_rdca30 e sem informação na pr_tab_erro, Conta: '||rw_craprda.nrdconta;
         END IF;
         --Levantar Excecao
         RAISE vr_exc_saida;
      END IF;

      -- Atribui valores calculados
      vr_qtaplati := vr_qtaplati + 1;
      -- Atribui valores calculados por tipo de pessoa      
      vr_tab_aplicacao(rw_craprda.inpessoa).qtaplati := vr_tab_aplicacao(rw_craprda.inpessoa).qtaplati + 1;

      vr_vlsdapat := vr_vlsdapat + aux_vlsdrdca;
      -- Separando por tipo de pessoa
      vr_tab_aplicacao(rw_craprda.inpessoa).vlsdapat := vr_tab_aplicacao(rw_craprda.inpessoa).vlsdapat + aux_vlsdrdca;

      -- Guarda as informacoes de aplicacoes ativas por agencia. Dados para Contabilidade
      IF rw_craprda.inpessoa = 1 THEN
         -- Verifica se existe valor para agencia corrente de pessoa fisica
         IF vr_tab_vlrdcage_fis.EXISTS(rw_craprda.cdagenci) THEN
            -- Soma os valores por agencia de pessoa fisica
            vr_tab_vlrdcage_fis(rw_craprda.cdagenci) := vr_tab_vlrdcage_fis(rw_craprda.cdagenci) + aux_vlsdrdca;
         ELSE
            -- Inicializa o array com o valor inicial de pessoa fisica
            vr_tab_vlrdcage_fis(rw_craprda.cdagenci) := aux_vlsdrdca;
         END IF;

         -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa fisica
         vr_tot_rdcagefis := vr_tot_rdcagefis + aux_vlsdrdca;
      ELSE
         -- Verifica se existe valor para agencia corrente de pessoa juridica
         IF vr_tab_vlrdcage_jur.EXISTS(rw_craprda.cdagenci) THEN
            -- Soma os valores por agencia de pessoa juridica
            vr_tab_vlrdcage_jur(rw_craprda.cdagenci) := vr_tab_vlrdcage_jur(rw_craprda.cdagenci) + aux_vlsdrdca;
         ELSE
            -- Inicializa o array com o valor inicial de pessoa juridica
            vr_tab_vlrdcage_jur(rw_craprda.cdagenci) := aux_vlsdrdca;
         END IF;
         
         -- Gravando as informacoe para gerar o valor total de poup ativas de pessoa juridica
         vr_tot_rdcagejur := vr_tot_rdcagejur + aux_vlsdrdca;
      END IF;

      aux_vlsdextr := aux_vlsdrdca;
      aux_vlslfmes := aux_vlsdrdca;

      -- Verifica se é conta investimento
      IF rw_craprda.flgctain = 1 THEN
         vr_qtaplati_n := vr_qtaplati_n + 1;
         vr_vlsdapat_n := vr_vlsdapat_n + aux_vlsdrdca;
      ELSE
         vr_qtaplati_a := vr_qtaplati_a + 1;
         vr_vlsdapat_a := vr_vlsdapat_a + aux_vlsdrdca;
      END IF;

    ELSE

      IF NOT aux_flgdomes THEN
         CONTINUE;
      ELSE
         aux_qtrenmfx := rw_craprda.qtrgtmfx - rw_craprda.qtaplmfx;
         vr_qtrenmfx  := vr_qtrenmfx + aux_qtrenmfx;
         
         -- Separando por tipo de pessoa
         vr_tab_aplicacao(rw_craprda.inpessoa).qtrenmfx := vr_tab_aplicacao(rw_craprda.inpessoa).qtrenmfx + aux_qtrenmfx;

         aux_vlsdextr := 0;
         -- Verifica se é conta investimento
         IF rw_craprda.flgctain = 1 THEN
            vr_qtrenmfx_n := vr_qtrenmfx_n + aux_qtrenmfx;
         ELSE
            vr_qtrenmfx_a := vr_qtrenmfx_a + aux_qtrenmfx;
         END IF;
      END IF;

    END IF;

    -- se a data for do mês atual
    IF rw_craprda.dtmvtolt > aux_dtinimes AND
       rw_craprda.dtmvtolt < aux_dtfimmes THEN
  
       vr_qtaplmes := vr_qtaplmes + 1;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craprda.inpessoa).qtaplmes := vr_tab_aplicacao(rw_craprda.inpessoa).qtaplmes + 1;

       vr_vlaplmes := vr_vlaplmes + rw_craprda.vlaplica;
       -- Separando por tipo de pessoa       
       vr_tab_aplicacao(rw_craprda.inpessoa).vlaplmes := vr_tab_aplicacao(rw_craprda.inpessoa).vlaplmes + rw_craprda.vlaplica;

       -- Verifica se é conta investimento
       IF rw_craprda.flgctain = 1 THEN
          vr_qtaplmes_n := vr_qtaplmes_n + 1;
          vr_vlaplmes_n := vr_vlaplmes_n + rw_craprda.vlaplica;
       ELSE
          vr_qtaplmes_a := vr_qtaplmes_a + 1;
          vr_vlaplmes_a := vr_vlaplmes_a + rw_craprda.vlaplica;
       END IF;
    END IF;

    -- Se o valor dos resgates for diferente do valor das aplicações em moeda de renda fixa
    -- ou se houver abono sobre o iof na aplicação
    IF aux_qtrenmfx <> 0 OR
       rw_craprda.vlabdiof <> 0 THEN
       BEGIN
         UPDATE crapcot
            SET crapcot.qtrenmfx = crapcot.qtrenmfx + aux_qtrenmfx,
                crapcot.vlabiord = crapcot.vlabiord + rw_craprda.vlabdiof,
                crapcot.vlrentot##1 = decode(to_char(vr_dtmvtolt, 'mm'),
                                            '01', crapcot.vlrentot##1 + rw_craprda.vlabdiof,
                                            crapcot.vlrentot##1),
                crapcot.vlrentot##2 = decode(to_char(vr_dtmvtolt, 'mm'),
                                            '02', crapcot.vlrentot##2 + rw_craprda.vlabdiof,
                                            crapcot.vlrentot##2),
                crapcot.vlrentot##3 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '03', crapcot.vlrentot##3 + rw_craprda.vlabdiof,
                                            crapcot.vlrentot##3),
                crapcot.vlrentot##4 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '04', crapcot.vlrentot##4 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##4),
                crapcot.vlrentot##5 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '05', crapcot.vlrentot##5 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##5),
                crapcot.vlrentot##6 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '06', crapcot.vlrentot##6 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##6),
                crapcot.vlrentot##7 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '07', crapcot.vlrentot##7 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##7),
                crapcot.vlrentot##8 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '08', crapcot.vlrentot##8 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##8),
                crapcot.vlrentot##9 = decode(to_char(vr_dtmvtolt, 'mm'),
                                             '09', crapcot.vlrentot##9 + rw_craprda.vlabdiof,
                                             crapcot.vlrentot##9),
                crapcot.vlrentot##10 = decode(to_char(vr_dtmvtolt, 'mm'),
                                              '10', crapcot.vlrentot##10 + rw_craprda.vlabdiof,
                                              crapcot.vlrentot##10),
                crapcot.vlrentot##11 = decode(to_char(vr_dtmvtolt, 'mm'),
                                              '11', crapcot.vlrentot##11 + rw_craprda.vlabdiof,
                                              crapcot.vlrentot##11),
                crapcot.vlrentot##12 = decode(to_char(vr_dtmvtolt, 'mm'),
                                              '12', crapcot.vlrentot##12 + rw_craprda.vlabdiof,
                                              crapcot.vlrentot##12)
         WHERE crapcot.cdcooper = pr_cdcooper
           AND crapcot.nrdconta = rw_craprda.nrdconta;
         
         IF SQL%ROWCOUNT = 0 THEN
            vr_cdcritic := 169;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Conta = '||rw_craprda.nrdconta;
            RAISE vr_exc_saida;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar CRAPCOT: '||sqlerrm;
            RAISE vr_exc_saida;
       END;
       --
       BEGIN
         UPDATE craprda
            SET craprda.vlabiord = craprda.vlabiord + craprda.vlabdiof,
                craprda.vlabdiof = 0
          WHERE craprda.rowid = rw_craprda.row_id
          RETURNING craprda.vlabdiof into rw_craprda.vlabdiof;
       EXCEPTION
          WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar valor na CRAPRDA: '||sqlerrm;
             RAISE vr_exc_saida;
       END;
    END IF;

    BEGIN
      UPDATE craprda
         SET craprda.dtsdfmea = vr_dtmvtolt,
             craprda.vlslfmea = aux_vlslfmes,
             craprda.vlsdextr = aux_vlsdextr,
             craprda.dtsdfmes = vr_dtmvtolt,
             craprda.vlslfmes = aux_vlslfmes
       WHERE craprda.rowid = rw_craprda.row_id
       RETURNING craprda.vlslfmes into rw_craprda.vlslfmes;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar valor e data na CRAPRDA: '||sqlerrm;
        RAISE vr_exc_saida;
    END;
    
    vr_bsabcpmf := vr_bsabcpmf + rw_craprda.vlabcpmf;
    -- Separando por tipo de pessoa
    vr_tab_aplicacao(rw_craprda.inpessoa).bsabcpmf := vr_tab_aplicacao(rw_craprda.inpessoa).bsabcpmf + rw_craprda.vlabcpmf;
    -- Verifica se é conta investimento
    IF rw_craprda.flgctain = 1 THEN
       vr_bsabcpmf_n := vr_bsabcpmf_n + rw_craprda.vlabcpmf;
    ELSE
       vr_bsabcpmf_a := vr_bsabcpmf_a + rw_craprda.vlabcpmf;
    END IF;

    -- Verifica se é saque total (0 = não)
    IF rw_craprda.insaqtot = 0 THEN
       -- cria_registro_detalhe
       vr_ind_detalhe := to_char(rw_craprda.cdageass, 'fm00000')||to_char(rw_craprda.nrdconta, 'fm0000000000')||to_char(rw_craprda.nraplica, 'fm0000000000');
       vr_detalhe(vr_ind_detalhe).tpaplica := rw_craprda.tpaplica;
       vr_detalhe(vr_ind_detalhe).cdagenci := rw_craprda.cdageass;
       vr_detalhe(vr_ind_detalhe).nrdconta := rw_craprda.nrdconta;
       vr_detalhe(vr_ind_detalhe).nraplica := rw_craprda.nraplica;
       vr_detalhe(vr_ind_detalhe).dtaplica := rw_craprda.dtmvtolt;
       vr_detalhe(vr_ind_detalhe).vlaplica := rw_craprda.vlaplica;
       vr_detalhe(vr_ind_detalhe).vlrgtmes := 0;
       vr_detalhe(vr_ind_detalhe).vlsldrdc := rw_craprda.vlslfmes;
       vr_detalhe(vr_ind_detalhe).txaplica := vr_txaplica;
       vr_detalhe(vr_ind_detalhe).nmresage := rw_craprda.nmresage;
       vr_detalhe(vr_ind_detalhe).nmprimtl := rw_craprda.nmprimtl;
    END IF;

    -- Se já existe a conta na pl/table, soma. Caso contrário, cria o registro.
    IF vr_cta_bndes.exists(rw_craprda.nrdconta) THEN
       vr_cta_bndes(rw_craprda.nrdconta).vlaplica := vr_cta_bndes(rw_craprda.nrdconta).vlaplica + rw_craprda.vlslfmes;
    ELSE
       vr_cta_bndes(rw_craprda.nrdconta).vlaplica := rw_craprda.vlslfmes;
    END IF;

    aux_ttslfmes := nvl(aux_ttslfmes, 0) + rw_craprda.vlslfmes;

    COMMIT; 
    
  END LOOP;

  -- Se a soma das aplicações ao final do mês for diferente de zero
  IF aux_ttslfmes <> 0 THEN
     BEGIN
       INSERT INTO crapprb (cdcooper,
                            dtmvtolt,
                            nrdconta,
                            cdorigem,
                            cddprazo,
                            vlretorn)
       VALUES (3,
              vr_dtmvtolt,
              rw_crapcop.nrctactl,
              6,
              90,
              aux_ttslfmes);
     EXCEPTION
       WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao criar CRAPPRB: '||sqlerrm;
          RAISE vr_exc_saida;
     END;
  END IF;

  -- Leitura das contas com valor de aplicação positivo
  vr_indice := vr_cta_bndes.first;
  WHILE vr_indice IS NOT NULL LOOP
    IF vr_cta_bndes(vr_indice).vlaplica > 0 THEN
       BEGIN
         INSERT INTO crapprb (cdcooper,
                              dtmvtolt,
                              nrdconta,
                              cdorigem,
                              cddprazo,
                              vlretorn)
         VALUES (pr_cdcooper,
                 vr_dtmvtolt,
                 vr_indice,
                 6,
                 0,
                 vr_cta_bndes(vr_indice).vlaplica);
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao criar CRAPPRB: '||sqlerrm;
           RAISE vr_exc_saida;
       END;
    END IF;
    vr_indice := vr_cta_bndes.next(vr_indice);
  END LOOP;

  IF vr_cdcritic > 0 THEN  -- Deu erro na includes/aplicacao.i
     RAISE vr_exc_saida;
  END IF;

  -- Leitura dos lancamentos do mes
  FOR rw_craplap in cr_craplap (pr_cdcooper,
                                aux_dtinimes,
                                aux_dtfimmes) LOOP

     OPEN cr_craprda2 (pr_cdcooper,
                       rw_craplap.nrdconta,
                       rw_craplap.nraplica);
     FETCH cr_craprda2 into rw_craprda2;
     IF cr_craprda2%NOTFOUND THEN
        CLOSE cr_craprda2;
        CONTINUE;
     END IF;
     CLOSE cr_craprda2;

     -- Verifica se é saque total (0 = não)
     IF rw_craprda2.insaqtot = 0 THEN
        vr_ind_detalhe := to_char(rw_craprda2.cdageass, 'fm00000')||to_char(rw_craprda2.nrdconta, 'fm0000000000')||to_char(rw_craprda2.nraplica, 'fm0000000000');
     END IF;

     -- Verifica se é conta integração
     IF rw_craprda2.flgctain = 1 THEN
        -- acumula_aplicacoes_novas.
        IF rw_craplap.cdhistor in (118, 492, 143) THEN
           -- 118	RESGATE
           -- 492	RESGATE
           -- 143	RESG.P/UNIF.
           vr_vlresmes_n := vr_vlresmes_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 116 THEN
           -- 116	RENDIMENTO
           vr_vlrenmes_n := vr_vlrenmes_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 117 THEN
           -- 117	PROVISAO
           vr_vlprvmes_n := vr_vlprvmes_n + rw_craplap.vllanmto;
           IF rw_craplap.nrdolote = 8380 THEN
              vr_vlprvlan_n := vr_vlprvlan_n + rw_craplap.vllanmto;
           END if;
        ELSIF rw_craplap.cdhistor in (119, 124) THEN
           -- 119	DIF.TX. MAIOR
           -- 124	AJUSTE PROV.
           vr_vlajuprv_n := vr_vlajuprv_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor in (121, 125) THEN
          -- 121	DIF.TX. MENOR
          -- 125	AJUSTE PROV.
          vr_vlajuprv_n := vr_vlajuprv_n - rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor in (126, 493) THEN
          -- 126	SAQ.S/REND.30
          -- 493	SAQ.S/REND.30
          vr_vlsaques_n := vr_vlsaques_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 861 THEN
          -- 861	DB.IRRF
          vr_vlrtirrf_n := vr_vlrtirrf_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 875 THEN
          -- 875	AJT RGT IR-30
          vr_vlirajrg_n := vr_vlirajrg_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 877 THEN
          -- 877	AJT REN IR-30
          vr_vlirajrn_n := vr_vlirajrn_n + rw_craplap.vllanmto;
        ELSIF rw_craplap.cdhistor = 868 THEN
          -- 868	IR ABONO APLIC
          vr_vlrtirab_n := vr_vlrtirab_n + rw_craplap.vllanmto;
        END IF;
    ELSE
      -- acumula_aplicacoes_antigas.
      IF rw_craplap.cdhistor in (118, 492, 143) THEN
         -- 118	RESGATE
         -- 492	RESGATE
         -- 143	RESG.P/UNIF.
         vr_vlresmes_a := vr_vlresmes_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 116 THEN
         -- 116	RENDIMENTO
         vr_vlrenmes_a := vr_vlrenmes_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 117 THEN
         -- 117	PROVISAO
         vr_vlprvmes_a := vr_vlprvmes_a + rw_craplap.vllanmto;
         IF rw_craplap.nrdolote = 8380 THEN
            vr_vlprvlan_a := vr_vlprvlan_a + rw_craplap.vllanmto;
         END IF;
      ELSIF rw_craplap.cdhistor in (119, 124) THEN
         -- 119	DIF.TX. MAIOR
         -- 124	AJUSTE PROV.
         vr_vlajuprv_a := vr_vlajuprv_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor in (121, 125) THEN
        -- 121	DIF.TX. MENOR
        -- 125	AJUSTE PROV.
        vr_vlajuprv_a := vr_vlajuprv_a - rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor in (126, 493) THEN
         -- 126	SAQ.S/REND.30
         -- 493	SAQ.S/REND.30
         vr_vlsaques_a := vr_vlsaques_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 861 THEN
         -- 861	DB.IRRF
         vr_vlrtirrf_a := vr_vlrtirrf_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 875 THEN  -- Ajuste IR Resgate
         -- 875	AJT RGT IR-30
         vr_vlirajrg_a := vr_vlirajrg_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 877 THEN  -- Ajuste IR Rendimento
         -- 877	AJT REN IR-30
         vr_vlirajrn_a := vr_vlirajrn_a + rw_craplap.vllanmto;
      ELSIF rw_craplap.cdhistor = 868 THEN
         -- 868	IR ABONO APLIC
         vr_vlrtirab_a := vr_vlrtirab_a + rw_craplap.vllanmto;
      END IF;
    END IF;

    IF rw_craplap.cdhistor IN (118, 492, 143) THEN
       -- 118	RESGATE
       -- 492	RESGATE
       -- 143	RESG.P/UNIF.
       
       vr_vlresmes := vr_vlresmes + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlresmes := vr_tab_aplicacao(rw_craplap.inpessoa).vlresmes + rw_craplap.vllanmto;

       IF vr_detalhe.exists(vr_ind_detalhe) AND
          rw_craprda2.insaqtot = 0 THEN
          vr_detalhe(vr_ind_detalhe).vlrgtmes := vr_detalhe(vr_ind_detalhe).vlrgtmes + rw_craplap.vllanmto;
       END IF;
    ELSIF rw_craplap.cdhistor = 116 THEN
       -- 116	RENDIMENTO
      vr_vlrenmes := vr_vlrenmes + rw_craplap.vllanmto;
      -- Separando por tipo de pessoa
      vr_tab_aplicacao(rw_craplap.inpessoa).vlrenmes := vr_tab_aplicacao(rw_craplap.inpessoa).vlrenmes + rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor = 117 THEN
       -- 117	PROVISAO
       vr_vlprvmes := vr_vlprvmes + rw_craplap.vllanmto;
       -- Dados para contabilidade - Informacoes de provisao separados por agencia e tipo de pessoa
       IF rw_craplap.inpessoa = 1 THEN
          IF vr_tab_vlpvrmes_fis.EXISTS(rw_craplap.cdagenci) THEN
             vr_tab_vlpvrmes_fis(rw_craplap.cdagenci) := vr_tab_vlpvrmes_fis(rw_craplap.cdagenci) + rw_craplap.vllanmto;
          ELSE
             vr_tab_vlpvrmes_fis(rw_craplap.cdagenci) := rw_craplap.vllanmto;
          END IF;
          -- Valor total de Provisao
          vr_tot_prvmesfis := vr_tot_prvmesfis + rw_craplap.vllanmto;
       ELSE
          IF vr_tab_vlpvrmes_jur.EXISTS(rw_craplap.cdagenci) THEN
             vr_tab_vlpvrmes_jur(rw_craplap.cdagenci) := vr_tab_vlpvrmes_jur(rw_craplap.cdagenci) + rw_craplap.vllanmto;
          ELSE
             vr_tab_vlpvrmes_jur(rw_craplap.cdagenci) := rw_craplap.vllanmto;
          END IF;
          -- Valor total de Provisao
          vr_tot_prvmesjur := vr_tot_prvmesjur + rw_craplap.vllanmto;
       END IF;       
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlprvmes := vr_tab_aplicacao(rw_craplap.inpessoa).vlprvmes + rw_craplap.vllanmto;

       IF rw_craplap.nrdolote = 8380 THEN
          vr_vlprvlan := vr_vlprvlan + rw_craplap.vllanmto;
          -- Separando por tipo de pessoa
          vr_tab_aplicacao(rw_craplap.inpessoa).vlprvlan := vr_tab_aplicacao(rw_craplap.inpessoa).vlprvlan + rw_craplap.vllanmto;
       END IF;
    ELSIF rw_craplap.cdhistor IN (119, 124) THEN
       -- 119	DIF.TX. MAIOR
       -- 124	AJUSTE PROV.
       vr_vlajuprv := vr_vlajuprv + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlajuprv := vr_tab_aplicacao(rw_craplap.inpessoa).vlajuprv + rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor IN (121, 125) THEN
       -- 121	DIF.TX. MENOR
       -- 125	AJUSTE PROV.
       vr_vlajuprv := vr_vlajuprv - rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlajuprv := vr_tab_aplicacao(rw_craplap.inpessoa).vlajuprv - rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor in (126, 493) THEN
       -- 126	SAQ.S/REND.30
       -- 493	SAQ.S/REND.30
       vr_vlsaques := vr_vlsaques + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlsaques := vr_tab_aplicacao(rw_craplap.inpessoa).vlsaques + rw_craplap.vllanmto;

       IF vr_detalhe.exists(vr_ind_detalhe) AND
          rw_craprda2.insaqtot = 0 then
          vr_detalhe(vr_ind_detalhe).vlrgtmes := vr_detalhe(vr_ind_detalhe).vlrgtmes + rw_craplap.vllanmto;
       END IF;
    ELSIF rw_craplap.cdhistor = 861 THEN
       -- 861	DB.IRRF
       vr_vlrtirrf := vr_vlrtirrf + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlrtirrf := vr_tab_aplicacao(rw_craplap.inpessoa).vlrtirrf + rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor = 875 THEN  -- Ajuste IR Resgate
       -- 875	AJT RGT IR-30
       vr_vlirajrg := vr_vlirajrg + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlirajrg := vr_tab_aplicacao(rw_craplap.inpessoa).vlirajrg + rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor = 877 THEN  -- Ajuste IR Rendimento
       -- 877	AJT REN IR-30
       vr_vlirajrn := vr_vlirajrn + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlirajrn := vr_tab_aplicacao(rw_craplap.inpessoa).vlirajrn + rw_craplap.vllanmto;
    ELSIF rw_craplap.cdhistor = 868 THEN
       -- 868	IR ABONO APLIC
       vr_vlrtirab := vr_vlrtirab + rw_craplap.vllanmto;
       -- Separando por tipo de pessoa
       vr_tab_aplicacao(rw_craplap.inpessoa).vlrtirab := vr_tab_aplicacao(rw_craplap.inpessoa).vlrtirab + rw_craplap.vllanmto;
    END IF;
  END LOOP;  -- Fim do FOR EACH  --  Leitura dos lancamentos

  -- RELATÓRIOS

  -- Busca do diretório base da cooperativa
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                            pr_cdcooper => pr_cdcooper,
                                            pr_nmsubdir => '/rl'); --> Utilizaremos o rl

  -- Geração do XML para o crrl086.lst (Resumo Mensal)
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl086>');

  -- Incluir os valores mensais
  pc_escreve_xml('<qtaplati_a>'||to_char(vr_qtaplati_a, 'fm999G990')||'</qtaplati_a>'||
                 '<qtaplati_n>'||to_char(vr_qtaplati_n, 'fm999G990')||'</qtaplati_n>'||
                 '<qtaplati>'||  to_char(vr_qtaplati, 'fm999G990')||  '</qtaplati>'||                 
                 '<qtaplati_fis>'||  to_char(vr_tab_aplicacao(1).qtaplati, 'fm999G990')||  '</qtaplati_fis>'||
                 '<qtaplati_jur>'||  to_char(vr_tab_aplicacao(2).qtaplati, 'fm999G990')||  '</qtaplati_jur>'||
                 '<qtaplmes_a>'||to_char(vr_qtaplmes_a, 'fm999G990')||'</qtaplmes_a>'||
                 '<qtaplmes_n>'||to_char(vr_qtaplmes_n, 'fm999G990')||'</qtaplmes_n>'||
                 '<qtaplmes>'||  to_char(vr_qtaplmes, 'fm999G990')||  '</qtaplmes>'||
                 '<qtaplmes_fis>'||  to_char(vr_tab_aplicacao(1).qtaplmes, 'fm999G990')||  '</qtaplmes_fis>'||
                 '<qtaplmes_jur>'||  to_char(vr_tab_aplicacao(2).qtaplmes, 'fm999G990')||  '</qtaplmes_jur>'||
                 '<vlsdapat_a>'||to_char(vr_vlsdapat_a, 'fm9G999G999G990D00')||'</vlsdapat_a>'||
                 '<vlsdapat_n>'||to_char(vr_vlsdapat_n, 'fm9G999G999G990D00')||'</vlsdapat_n>'||
                 '<vlsdapat>'||  to_char(vr_vlsdapat, 'fm9G999G999G990D00')||  '</vlsdapat>'||
                 '<vlsdapat_fis>'||  to_char(vr_tab_aplicacao(1).vlsdapat, 'fm9G999G999G990D00')||  '</vlsdapat_fis>'||
                 '<vlsdapat_jur>'||  to_char(vr_tab_aplicacao(2).vlsdapat, 'fm9G999G999G990D00')||  '</vlsdapat_jur>'||                 
                 '<vlaplmes_a>'||to_char(vr_vlaplmes_a, 'fm9G999G999G990D00')||'</vlaplmes_a>'||
                 '<vlaplmes_n>'||to_char(vr_vlaplmes_n, 'fm9G999G999G990D00')||'</vlaplmes_n>'||
                 '<vlaplmes>'||  to_char(vr_vlaplmes, 'fm9G999G999G990D00')||  '</vlaplmes>'||
                 '<vlaplmes_fis>'||  to_char(vr_tab_aplicacao(1).vlaplmes, 'fm9G999G999G990D00')||  '</vlaplmes_fis>'||
                 '<vlaplmes_jur>'||  to_char(vr_tab_aplicacao(2).vlaplmes, 'fm9G999G999G990D00')||  '</vlaplmes_jur>'||
                 '<vlresmes_a>'||to_char(vr_vlresmes_a, 'fm9G999G999G990D00')||'</vlresmes_a>'||
                 '<vlresmes_n>'||to_char(vr_vlresmes_n, 'fm9G999G999G990D00')||'</vlresmes_n>'||
                 '<vlresmes>'||  to_char(vr_vlresmes, 'fm9G999G999G990D00')||  '</vlresmes>'||
                 '<vlresmes_fis>'||  to_char(vr_tab_aplicacao(1).vlresmes, 'fm9G999G999G990D00')||  '</vlresmes_fis>'||
                 '<vlresmes_jur>'||  to_char(vr_tab_aplicacao(2).vlresmes, 'fm9G999G999G990D00')||  '</vlresmes_jur>'||                
                 '<vlrenmes_a>'||to_char(vr_vlrenmes_a, 'fm9G999G999G990D00')||'</vlrenmes_a>'||
                 '<vlrenmes_n>'||to_char(vr_vlrenmes_n, 'fm9G999G999G990D00')||'</vlrenmes_n>'||
                 '<vlrenmes>'||  to_char(vr_vlrenmes, 'fm9G999G999G990D00')||  '</vlrenmes>'||
                 '<vlrenmes_fis>'||  to_char(vr_tab_aplicacao(1).vlrenmes, 'fm9G999G999G990D00')||  '</vlrenmes_fis>'||
                 '<vlrenmes_jur>'||  to_char(vr_tab_aplicacao(2).vlrenmes, 'fm9G999G999G990D00')||  '</vlrenmes_jur>'||
                 '<vlprvmes_a>'||to_char(vr_vlprvmes_a, 'fm9G999G999G990D00')||'</vlprvmes_a>'||
                 '<vlprvmes_n>'||to_char(vr_vlprvmes_n, 'fm9G999G999G990D00')||'</vlprvmes_n>'||
                 '<vlprvmes>'||  to_char(vr_vlprvmes, 'fm9G999G999G990D00')||  '</vlprvmes>'||
                 '<vlprvmes_fis>'||  to_char(vr_tab_aplicacao(1).vlprvmes, 'fm9G999G999G990D00')||  '</vlprvmes_fis>'||
                 '<vlprvmes_jur>'||  to_char(vr_tab_aplicacao(2).vlprvmes, 'fm9G999G999G990D00')||  '</vlprvmes_jur>'||
                 '<vlprvlan_a>'||to_char(vr_vlprvlan_a, 'fm9G999G999G990D00')||'</vlprvlan_a>'||
                 '<vlprvlan_n>'||to_char(vr_vlprvlan_n, 'fm9G999G999G990D00')||'</vlprvlan_n>'||
                 '<vlprvlan>'||  to_char(vr_vlprvlan, 'fm9G999G999G990D00')||  '</vlprvlan>'||
                 '<vlprvlan_fis>'||  to_char(vr_tab_aplicacao(1).vlprvlan, 'fm9G999G999G990D00')||  '</vlprvlan_fis>'||
                 '<vlprvlan_jur>'||  to_char(vr_tab_aplicacao(2).vlprvlan, 'fm9G999G999G990D00')||  '</vlprvlan_jur>'||
                 '<vlajuprv_a>'||to_char(vr_vlajuprv_a, 'fm9G999G999G990D00')||'</vlajuprv_a>'||
                 '<vlajuprv_n>'||to_char(vr_vlajuprv_n, 'fm9G999G999G990D00')||'</vlajuprv_n>'||
                 '<vlajuprv>'||  to_char(vr_vlajuprv, 'fm9G999G999G990D00')||  '</vlajuprv>'||
                 '<vlajuprv_fis>'||  to_char(vr_tab_aplicacao(1).vlajuprv, 'fm9G999G999G990D00')||  '</vlajuprv_fis>'||
                 '<vlajuprv_jur>'||  to_char(vr_tab_aplicacao(2).vlajuprv, 'fm9G999G999G990D00')||  '</vlajuprv_jur>'||
                 '<vlsaques_a>'||to_char(vr_vlsaques_a, 'fm9G999G999G990D00')||'</vlsaques_a>'||
                 '<vlsaques_n>'||to_char(vr_vlsaques_n, 'fm9G999G999G990D00')||'</vlsaques_n>'||
                 '<vlsaques>'||  to_char(vr_vlsaques, 'fm9G999G999G990D00')||  '</vlsaques>'||
                 '<vlsaques_fis>'||  to_char(vr_tab_aplicacao(1).vlsaques, 'fm9G999G999G990D00')||  '</vlsaques_fis>'||
                 '<vlsaques_jur>'||  to_char(vr_tab_aplicacao(2).vlsaques, 'fm9G999G999G990D00')||  '</vlsaques_jur>'||
                 '<vlrtirrf_a>'||to_char(vr_vlrtirrf_a, 'fm9G999G999G990D00')||'</vlrtirrf_a>'||
                 '<vlrtirrf_n>'||to_char(vr_vlrtirrf_n, 'fm9G999G999G990D00')||'</vlrtirrf_n>'||
                 '<vlrtirrf>'||  to_char(vr_vlrtirrf, 'fm9G999G999G990D00')||  '</vlrtirrf>'||
                 '<vlrtirrf_fis>'||  to_char(vr_tab_aplicacao(1).vlrtirrf, 'fm9G999G999G990D00')||  '</vlrtirrf_fis>'||
                 '<vlrtirrf_jur>'||  to_char(vr_tab_aplicacao(2).vlrtirrf, 'fm9G999G999G990D00')||  '</vlrtirrf_jur>'||
                 '<vlrtirab_a>'||to_char(vr_vlrtirab_a, 'fm9G999G999G990D00')||'</vlrtirab_a>'||
                 '<vlrtirab_n>'||to_char(vr_vlrtirab_n, 'fm9G999G999G990D00')||'</vlrtirab_n>'||
                 '<vlrtirab>'||  to_char(vr_vlrtirab, 'fm9G999G999G990D00')||  '</vlrtirab>'||
                 '<vlrtirab_fis>'||  to_char(vr_tab_aplicacao(1).vlrtirab, 'fm9G999G999G990D00')||  '</vlrtirab_fis>'||
                 '<vlrtirab_jur>'||  to_char(vr_tab_aplicacao(2).vlrtirab, 'fm9G999G999G990D00')||  '</vlrtirab_jur>'||
                 '<vlirajrg_a>'||to_char(vr_vlirajrg_a, 'fm9G999G999G990D00')||'</vlirajrg_a>'||
                 '<vlirajrg_n>'||to_char(vr_vlirajrg_n, 'fm9G999G999G990D00')||'</vlirajrg_n>'||
                 '<vlirajrg>'||  to_char(vr_vlirajrg, 'fm9G999G999G990D00')||  '</vlirajrg>'||
                 '<vlirajrg_fis>'||  to_char(vr_tab_aplicacao(1).vlirajrg, 'fm9G999G999G990D00')||  '</vlirajrg_fis>'||
                 '<vlirajrg_jur>'||  to_char(vr_tab_aplicacao(2).vlirajrg, 'fm9G999G999G990D00')||  '</vlirajrg_jur>'||
                 '<vlirajrn_a>'||to_char(vr_vlirajrn_a, 'fm9G999G999G990D00')||'</vlirajrn_a>'||
                 '<vlirajrn_n>'||to_char(vr_vlirajrn_n, 'fm9G999G999G990D00')||'</vlirajrn_n>'||
                 '<vlirajrn>'||  to_char(vr_vlirajrn, 'fm9G999G999G990D00')||  '</vlirajrn>'||
                 '<vlirajrn_fis>'||  to_char(vr_tab_aplicacao(1).vlirajrn, 'fm9G999G999G990D00')||  '</vlirajrn_fis>'||
                 '<vlirajrn_jur>'||  to_char(vr_tab_aplicacao(2).vlirajrn, 'fm9G999G999G990D00')||  '</vlirajrn_jur>'||                 
                 '<bsabcpmf_a>'||to_char(vr_bsabcpmf_a, 'fm9G999G999G990D00')||'</bsabcpmf_a>'||
                 '<bsabcpmf_n>'||to_char(vr_bsabcpmf_n, 'fm9G999G999G990D00')||'</bsabcpmf_n>'||
                 '<bsabcpmf>'||  to_char(vr_bsabcpmf, 'fm9G999G999G990D00')||  '</bsabcpmf>'||
                 '<bsabcpmf_fis>'||  to_char(vr_tab_aplicacao(1).bsabcpmf, 'fm9G999G999G990D00')||  '</bsabcpmf_fis>'||
                 '<bsabcpmf_jur>'||  to_char(vr_tab_aplicacao(2).bsabcpmf, 'fm9G999G999G990D00')||  '</bsabcpmf_jur>'||
                 '<qtrenmfx_a>'||to_char(vr_qtrenmfx_a, 'fm99G999G990D0000')||'</qtrenmfx_a>'||
                 '<qtrenmfx_n>'||to_char(vr_qtrenmfx_n, 'fm99G999G990D0000')||'</qtrenmfx_n>'||
                 '<qtrenmfx>'||  to_char(vr_qtrenmfx, 'fm99G999G990D0000')||  '</qtrenmfx>'||
                 '<qtrenmfx_fis>'||  to_char(vr_tab_aplicacao(1).qtrenmfx, 'fm99G999G990D0000')||  '</qtrenmfx_fis>'||
                 '<qtrenmfx_jur>'||  to_char(vr_tab_aplicacao(2).qtrenmfx, 'fm99G999G990D0000')||  '</qtrenmfx_jur>');

  -- Encerra a Tag
  pc_escreve_xml('</crrl086>');

  -- Nome base do arquivo é crrl086
  vr_nom_arquivo := 'crrl086';
  
  -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl086',          --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl086.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => null,                --> Nome do formulário para impressão
                              pr_nrcopias  => 1,                   --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
     -- Gerar exceção
     vr_cdcritic := 0;
     RAISE vr_exc_saida;
  END IF;

  -- Geração do XML para o crrl559.lst (Analítico)
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl559>');

  -- Leitura da PL/Table com o detalhamento das aplicações
  vr_ind_detalhe := vr_detalhe.first;
  vr_cdagenci_det := 0;
  WHILE vr_ind_detalhe IS NOT NULL LOOP

     IF vr_detalhe(vr_ind_detalhe).cdagenci <> vr_cdagenci_det THEN
        -- Cabeçalho da agência
        IF vr_cdagenci_det <> 0 THEN
           pc_escreve_xml('</agencia>');
        END IF;
        vr_cdagenci_det := vr_detalhe(vr_ind_detalhe).cdagenci;
        pc_escreve_xml('<agencia cdagenci="'||lpad(vr_cdagenci_det, 3, ' ')||' - '||vr_detalhe(vr_ind_detalhe).nmresage||'">'||
                       '<tpaplica>'||lpad(vr_detalhe(vr_ind_detalhe).tpaplica, 2, ' ')||'</tpaplica>');
     END IF;

     -- Contas
     pc_escreve_xml('<conta nrdconta="'||to_char(vr_detalhe(vr_ind_detalhe).nrdconta, 'fm9999G999G9')||'">'||
                     '<nmprimtl>'||substr(vr_detalhe(vr_ind_detalhe).nmprimtl, 1, 32)||'</nmprimtl>'||
                     '<nraplica>'||to_char(vr_detalhe(vr_ind_detalhe).nraplica, 'fm999G990')||'</nraplica>'||
                     '<dtaplica>'||to_char(vr_detalhe(vr_ind_detalhe).dtaplica, 'dd/mm/yyyy')||'</dtaplica>'||
                     '<vlaplica>'||to_char(vr_detalhe(vr_ind_detalhe).vlaplica, 'fm9G999G999G990D00')||'</vlaplica>'||
                     '<vlrgtmes>'||to_char(vr_detalhe(vr_ind_detalhe).vlrgtmes, 'fm9G999G999G990D00')||'</vlrgtmes>'||
                     '<vlsldrdc>'||to_char(vr_detalhe(vr_ind_detalhe).vlsldrdc, 'fm9G999G999G990D00')||'</vlsldrdc>'||
                     '<txaplica>'||to_char(vr_detalhe(vr_ind_detalhe).txaplica, 'fm990D000000')||'</txaplica>'||
                   '</conta>');

     vr_ind_detalhe := vr_detalhe.next(vr_ind_detalhe);

  END LOOP;

  -- Finaliza o arquivo
  IF vr_cdagenci_det <> 0 THEN
     pc_escreve_xml('</agencia>');
  END IF;

  pc_escreve_xml('</crrl559>');

  -- Nome base do arquivo é crrl559
  vr_nom_arquivo := 'crrl559';

  -- Gerar o arquivo de XML com mesmo nome e na mesma pasta do arquivo de saída
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl559/agencia/conta',          --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl559.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,                --> Enviar como parâmetro apenas a agência
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo||'.lst', --> Arquivo final com código da agência
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 2,                   --> Sequencia do relatorio (cabrel 1..5)
                              pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '132col',            --> Nome do formulário para impressão
                              pr_nrcopias  => 1,                   --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
     -- Gerar exceção
     vr_cdcritic := 0;
     RAISE vr_exc_saida;
  END IF;

  -----------------------------------------------
  -- Inicio de geracao de arquivo AAMMDD_RDCA.txt
  -----------------------------------------------

  -- Arquivo gerado somente no processo mensal e quando não for CECRED
  IF TRUNC(rw_crapdat.dtmvtopr,'MM') <> TRUNC(rw_crapdat.dtmvtolt,'MM') AND pr_cdcooper <> 3 THEN
      
     -- Busca o caminho padrao do arquivo no unix + /integra
     vr_nom_direto:= GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'contab');

     -- Determinar o nome do arquivo baseado no ano, mes e dia da data movimento
     vr_nmarqtxt:=  TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_RDCA30.txt';

     -- Tenta abrir o arquivo de log em modo gravacao
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretório do arquivo
                             ,pr_nmarquiv => vr_nmarqtxt    --> Nome do arquivo
                             ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                             ,pr_des_erro => vr_dscritic);  --> Erro
     IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_saida;
     END IF;
     
     -- Se o valor total é maior que zero
     /* 
     Remover lancamentos de segregacao/reversao para contas PF/PJ.
     Apos atualizacao do plano de contas, nao e mais necessaria realizar essa segregacao.
     Solicitacao Contabilidade - Heitor (Mouts)
     
     IF NVL(vr_tot_rdcagefis,0) > 0 THEN
     
       \*** Montando as informacoes de PESSOA FISICA ***\     
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                      TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                      TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(4232, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(4269, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_rdcagefis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"SALDO TOTAL DE TITULOS ATIVOS RDCA 30 - COOPERADOS PESSOA FISICA"';                       --> Descricao

       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

       -- Verifica se existe valores       
       IF vr_tab_vlrdcage_fis.COUNT > 0 THEN
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlrdcage_fis.FIRST()..vr_tab_vlrdcage_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlrdcage_fis.EXISTS(vr_idx_agencia) THEN
               -- Verifica o valor é maior que zero
               IF vr_tab_vlrdcage_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrdcage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
       vr_setlinha := '70'||                                                                                     --> Informacao inicial
                      TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||                                               --> Data AAMMDD do Arquivo
                      TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||','||                                               --> Data DDMMAA
                      gene0002.fn_mask(4269, pr_dsforma => '9999')||','||                                        --> Conta Destino
                      gene0002.fn_mask(4232, pr_dsforma => '9999')||','||                                        --> Conta Origem
                      TRIM(TO_CHAR(vr_tot_rdcagefis,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                              	         --> Fixo
                      '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS RDCA 30 - COOPERADOS PESSOA FISICA"';                      --> Descricao

       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

       -- Verifica se existe valores       
       IF vr_tab_vlrdcage_fis.COUNT > 0 THEN
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP  
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlrdcage_fis.FIRST()..vr_tab_vlrdcage_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlrdcage_fis.EXISTS(vr_idx_agencia) THEN
               -- Verifica se valor maior que zero
               IF vr_tab_vlrdcage_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrdcage_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
                 -- Escrever linha no arquivo
                 gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                               ,pr_des_text => vr_setlinha); --> Texto para escrita
               END IF;
             END IF;
             -- Limpa variavel
             vr_setlinha := '';       
           END LOOP;
         END LOOP; --  fim repete
       END IF;
     END IF; -- Se maior que zero
     
     -- Se o valor total é maior que zero
     IF NVL(vr_tot_rdcagejur,0) > 0 THEN
       \*** Montando as informacoes de PESSOA JURIDICA ***\
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                      TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                      TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(4232, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(4270, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_rdcagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"SALDO TOTAL DE TITULOS ATIVOS RDCA 30 - COOPERADOS PESSOA JURIDICA"';                     --> Descricao

       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
                                     
       -- Verifica se existe valores       
       IF vr_tab_vlrdcage_jur.COUNT > 0 THEN   
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP  
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlrdcage_jur.FIRST()..vr_tab_vlrdcage_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlrdcage_jur.EXISTS(vr_idx_agencia) THEN       
               -- Verifica se o valor eh maior que zero
               IF vr_tab_vlrdcage_jur(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrdcage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
                      gene0002.fn_mask(4270, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      gene0002.fn_mask(4232, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      TRIM(TO_CHAR(vr_tot_rdcagejur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"'||vr_dsprefix||'SALDO TOTAL DE TITULOS ATIVOS RDCA 30 - COOPERADOS PESSOA JURIDICA"';                     --> Descricao
                      
       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

       -- Verifica se existe valores       
       IF vr_tab_vlrdcage_jur.COUNT > 0 THEN   
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP    
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlrdcage_jur.FIRST()..vr_tab_vlrdcage_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlrdcage_jur.EXISTS(vr_idx_agencia) THEN       
               -- Verifica se valor maior que zero
               IF vr_tab_vlrdcage_jur(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlrdcage_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
     END IF;
     */ -- Se maior que zero
     
     -- Se o valor total é maior que zero
     IF NVL(vr_tot_prvmesfis,0) > 0 THEN
       /*** Montando as informacoes de PESSOA FISICA ***/     
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                      TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                      TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8051, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8112, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_prvmesfis, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PF
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"PROVISAO DO MES - RDCA 30 COOPERADOS PESSOA FISICA"';                                     --> Descricao

       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita
                                     
       -- Verifica se existe valores       
       IF vr_tab_vlpvrmes_fis.COUNT > 0 THEN
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP   
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlpvrmes_fis.FIRST()..vr_tab_vlpvrmes_fis.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlpvrmes_fis.EXISTS(vr_idx_agencia) THEN
               -- Verifica se valor maior que zero
               IF vr_tab_vlpvrmes_fis(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlpvrmes_fis(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
     END IF; -- Se maior que zero
     
     -- Se o valor total é maior que zero
     IF NVL(vr_tot_prvmesjur,0) > 0 THEN
       /*** Montando as informacoes de PESSOA JURIDICA ***/
       -- Montando o cabecalho das contas do dia atual
       vr_setlinha := '70'||                                                                                      --> Informacao inicial
                      TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||                                                --> Data AAMMDD do Arquivo
                      TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||','||                                                --> Data DDMMAA
                      gene0002.fn_mask(8052, pr_dsforma => '9999')||','||                                         --> Conta Origem
                      gene0002.fn_mask(8112, pr_dsforma => '9999')||','||                                         --> Conta Destino
                      TRIM(TO_CHAR(vr_tot_prvmesjur, 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','|| --> Total Valor PJ
                      gene0002.fn_mask(5210, pr_dsforma => '9999')||','||                                         --> Fixo
                      '"PROVISAO DO MES - RDCA 30 COOPERADOS PESSOA JURIDICA"';                                   --> Descricao

       gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                     ,pr_des_text => vr_setlinha); --> Texto para escrita

       -- Verifica se existe valores
       IF vr_tab_vlpvrmes_jur.COUNT > 0 THEN
         -- Duplicar a listagem de agencia
         FOR repete IN 1..2 LOOP
           -- Gravas as informacoes de valores por agencia
           FOR vr_idx_agencia IN vr_tab_vlpvrmes_jur.FIRST()..vr_tab_vlpvrmes_jur.LAST() LOOP
             -- Verifica se existe a informacao
             IF vr_tab_vlpvrmes_jur.EXISTS(vr_idx_agencia) THEN
               -- Verifica se existe a informacao
               IF vr_tab_vlpvrmes_jur(vr_idx_agencia) > 0 THEN
                 -- Montar linha para gravar no arquivo
                 vr_setlinha := to_char(vr_idx_agencia,'FM009')||','||TRIM(TO_CHAR(vr_tab_vlpvrmes_jur(vr_idx_agencia), 'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
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
     END IF; -- Se maior que zero
     
     --Fechar Arquivo
     BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
     EXCEPTION
        WHEN OTHERS THEN
        -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
        vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_direto||'/'||vr_nmarqtxt||'>: ' || sqlerrm;
        RAISE vr_exc_saida;
     END;

     -- Busca o diretório para contabilidade
     vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => 0
                                           ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');
                                           
     vr_arqcon := TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_RDCA30.txt';
     
     -- Executa comando UNIX para converter arq para Dos
     vr_dscomand := 'ux2dos '||vr_nom_direto||'/'||vr_nmarqtxt||' > '||
                                vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

     -- Executar o comando no unix
     GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_dscomand
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);
     IF vr_typ_saida = 'ERR' THEN
       RAISE vr_exc_saida;
     END IF;
     
  END IF;

  -- Limpa as PL-Tables
  vr_tab_vlrdcage_fis.DELETE;
  vr_tab_vlrdcage_jur.DELETE;
  vr_tab_vlpvrmes_fis.DELETE;
  vr_tab_vlpvrmes_jur.DELETE;

  -----------------------------------------------
  -- Fim de geracao de arquivo AAMMDD_RDCA.txt       
  -----------------------------------------------

  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);

  COMMIT;

EXCEPTION
   WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 and vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_nmarqlog => vr_cdprogra,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
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
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
END;
/
