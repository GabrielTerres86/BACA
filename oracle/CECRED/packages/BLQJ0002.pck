CREATE OR REPLACE PACKAGE CECRED.BLQJ0002 AS

  /*.............................................................................

    Programa: BLQJ0002
    Autor   : Andrino Carlos de Souza Junior (Mout's)
    Data    : Dezembro/2016                Ultima Atualizacao: 
     
    Dados referentes ao programa:
   
    Objetivo  : Efetuar a comunicacao do Ayllos com o Webjud
                 
    Alteracoes: 26/06/2017 - Ajustes no nome do favorecido da TED e no select de busca
                             de TEDs pendentes (Andrino - Mouts)

                30/08/2017 - Ajustada rotina pc_processa_ted para realizar count
                             considerando nr da conta tambem.
                             Heitor (Mouts) - BACENJUD

  .............................................................................*/

  -- Efetuar o recebimento das solicitacoes de consulta de conta
  PROCEDURE pc_recebe_solicitacao(pr_nrdocnpj_cop  IN  crapcop.nrdocnpj%TYPE, -- CNPJ da cooperativa
                                  pr_nrcpfcnpj     IN  crapass.nrcpfcgc%TYPE, -- CNPJ / CPF do réu
                                  pr_tppessoa      IN  VARCHAR2, -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                  pr_idordem       OUT tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                  pr_cdcritic      OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                  pr_dscritic      OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Efetuar o recebimento das solicitacoes de bloqueio e desbloqueio
  PROCEDURE pc_recebe_blq_desblq(pr_nrdocnpj_cop  IN  crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                                ,pr_nrcpfcnpj     IN  crapass.nrcpfcgc%TYPE -- CNPJ / CPF do réu
                                ,pr_tppessoa      IN  VARCHAR2 -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                ,pr_tpproduto     IN  VARCHAR2 -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                ,pr_dsoficio      IN  crapblj.nroficio%TYPE -- Numero do oficio
                                ,pr_nrdconta      IN  crapblj.nrdconta%TYPE -- Numero da conta
                                ,pr_cdagenci      IN  crapass.cdagenci%TYPE -- Codigo da agencia
                                ,pr_tpordem       IN  tbblqj_ordem_online.tpordem%TYPE -- Tipo de Operacao (2-Bloqueio, 3-Desbloqueio)
                                ,pr_vlordem       IN  crapblj.vlbloque%TYPE -- Valor do bloqueio
                                ,pr_dsprocesso    IN  crapblj.nrproces%TYPE -- Numero do processo
                                ,pr_nmjuiz        IN  crapblj.dsjuizem%TYPE -- Juiz emissor
                                ,pr_idordem       OUT tbblqj_ordem_online.idordem%TYPE -- Sequencial do recebimento
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE -- Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2);            -- Texto de erro/critica encontrada

  -- Efetuar o recebimento das solicitacoes de TED
  PROCEDURE pc_recebe_ted(pr_nrdocnpj_cop         IN crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                         ,pr_nrcpfcnpj            IN crapass.nrcpfcgc%TYPE -- CNPJ / CPF do titular da conta
                         ,pr_tppessoa             IN VARCHAR2 -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                         ,pr_tpproduto            IN VARCHAR2 -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                         ,pr_dsoficio             IN tbblqj_ordem_transf.dsoficio%TYPE -- Numero do oficio
                         ,pr_nrdconta             IN crapblj.nrdconta%TYPE -- Numero da conta
                         ,pr_vlordem              IN tbblqj_ordem_transf.vlordem%TYPE -- Valor   
                         ,pr_indbloqueio_saldo    IN tbblqj_ordem_transf.indbloqueio_saldo%TYPE -- Indicador de término de bloqueio de saldo remanescente (0-Não encerra bloqueio, 1-Encerra bloqueio)
                         ,pr_nrcnpj_if_destino    IN tbblqj_ordem_transf.nrcnpj_if_destino%TYPE -- Numero do CNPJ da instituicao financeira de destino
                         ,pr_nrcpfcnpj_favorecido IN tbblqj_ordem_transf.nrcpfcnpj_favorecido%TYPE --  Numero do CPF / CNPJ da conta de destino
                         ,pr_nragencia_if_destino IN tbblqj_ordem_transf.nragencia_if_destino%TYPE -- Codigo da agencia de destino
                         ,pr_nmfavorecido         IN tbblqj_ordem_transf.nmfavorecido%TYPE --  Nome da conta de destino
                         ,pr_tpdeposito           IN tbblqj_ordem_transf.tpdeposito%TYPE -- Indicador de tipo de depósito (T-Tributario, P-Previdenciario, Vazio-Demais) 
                         ,pr_cddeposito           IN tbblqj_ordem_transf.cddeposito%TYPE -- Codigo do deposito (preenchido somente quanto tipo de deposito for T ou P)
                         ,pr_cdtransf_bacenjud    IN tbblqj_ordem_transf.cdtransf_bacenjud%TYPE -- Numero de identificação da transferencia, gerado pelo BACENJUD
                         ,pr_cdcritic            OUT crapcri.cdcritic%TYPE -- Critica encontrada
                         ,pr_dscritic            OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Verifica se o processo noturno esta em execucao. Se o PR_NRDOCNPJ_COP vier como 0, verificará se todos os processos acabaram
  PROCEDURE pc_verifica_processo(pr_nrdocnpj_cop         IN crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                                ,pr_idretorno           OUT VARCHAR2); -- Identifica se o processo esta em execucao (S-Esta em execucao, N-Processo nao esta em execucao)

  -- Efetuar o processamento da solicitacao de consulta de conta
  PROCEDURE pc_processa_solicitacao(pr_idordem   IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                    pr_cdcritic  OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                    pr_dscritic  OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Efetuar o processamento da solicitacao de bloqueio e desbloqueio
  PROCEDURE pc_processa_blq_desblq(pr_idordem IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                   pr_cdcritic      OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                   pr_dscritic      OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Efetuar a devolucao dos dados de uma solicitacao
  PROCEDURE pc_devolve_solicitacao(pr_idordem  IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                   pr_xml      OUT xmltype, -- XML com os dados de retorno
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                   pr_dscritic OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Efetuar a devolucao dos dados de um bloqueio / desbloqueio
  PROCEDURE pc_devolve_blq_desblq(pr_idordem    IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                  pr_nrcnpjcop  OUT crapcop.nrdocnpj%TYPE, -- CNPJ da Cooperativa
                                  pr_nrcpfcnpj  OUT tbblqj_ordem_online.nrcpfcnpj%TYPE, -- CPF / CNPJ do reu
                                  pr_tpproduto  OUT VARCHAR2, -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                  pr_nrdconta   OUT tbblqj_ordem_bloq_desbloq.nrdconta%TYPE, -- Numero da conta
                                  pr_cdagenci   OUT tbblqj_ordem_bloq_desbloq.cdagenci%TYPE, -- Codigo da agencia
                                  pr_vlbloqueio OUT tbblqj_ordem_bloq_desbloq.vloperacao%TYPE, -- Valor de bloqueio
                                  pr_dhbloqueio OUT DATE, -- Data e hora do bloqueio
                                  pr_inbloqueio OUT PLS_INTEGER, -- Indicador de bloqueio (0-Sem retorno, 1-Processo OK, 2-Processo com Erro)
                                  pr_cdcritic   OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                  pr_dscritic   OUT VARCHAR2);           -- Texto de erro/critica encontrada

  -- Efetuar o processamento da ted
  PROCEDURE pc_processa_ted(pr_cdcritic OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                            pr_dscritic OUT VARCHAR2);           -- Texto de erro/critica encontrada

END BLQJ0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.BLQJ0002 AS

  /*.............................................................................

    Programa: BLQJ0002
    Autor   : Andrino Carlos de Souza Junior (Mout's)
    Data    : Dezembro/2016                Ultima Atualizacao: 
     
    Dados referentes ao programa:
   
    Objetivo  : Efetuar a comunicacao do Ayllos com o Webjud
                 
    Alteracoes: 

  .............................................................................*/

  -- Rotina para bloquear valores  
  PROCEDURE pc_bloqueio(pr_cdcooper IN crapblj.cdcooper%TYPE,
                        pr_nrdconta IN crapblj.nrdconta%TYPE,
                        pr_cdmodali IN crapblj.cdmodali%TYPE,
                        pr_nroficio IN crapblj.nroficio%TYPE,
                        pr_nrproces IN crapblj.nrproces%TYPE,
                        pr_dsresord IN crapblj.dsresord%TYPE,
                        pr_dsjuizem IN crapblj.dsjuizem%TYPE,
                        pr_vlbloque IN OUT crapblj.vlbloque%TYPE,
                        pr_dscritic    OUT VARCHAR2) IS

    -- Verifica se existe bloqueio pendente
    CURSOR cr_crapblj IS
      SELECT a.vlbloque
        FROM crapblj a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nroficio = pr_nroficio --LIKE pr_nroficio||'%'
         AND a.cdmodali = pr_cdmodali
         AND a.dtblqfim IS NULL; -- Que nao esteja desbloqueado
    rw_crapblj cr_crapblj%ROWTYPE;

/* Demetrius
    -- Cursor para verificar o numero de oficio que devera ser utilizado
    CURSOR cr_crapblj_2 IS
      SELECT a.nroficio
        FROM crapblj a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nroficio = pr_nroficio --LIKE pr_nroficio||'%'
         AND a.cdmodali = pr_cdmodali
       ORDER BY nroficio DESC;
    rw_crapblj_2 cr_crapblj_2%ROWTYPE;

*/
    -- Registro sobre a data do sistema
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variaveis Pl/Tables
    vr_tab_cooperado BLQJ0001.typ_tab_cooperado;
    vr_tab_saldos    EXTR0001.typ_tab_saldos;
    vr_tab_erro      GENE0001.typ_tab_erro;

    -- VARIÁVEIS
    vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do titular da conta
    vr_nroficio crapblj.nroficio%TYPE; -- Numero do oficio
    vr_dsmodali VARCHAR2(30); -- Descricao da modalidade
    vr_vlsaldo  tbblqj_ordem_bloq_desbloq.vlordem%TYPE; -- Valor de saldo da operacao

    -- Variaveis de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  
  BEGIN
    -- Verifica se ja existe bloqueio ativo para este oficio
    OPEN cr_crapblj;
    FETCH cr_crapblj INTO rw_crapblj;
      
    -- Se ja existir registro, deve-se cancelar com erro
    /* --thiago rodrigues
    IF cr_crapblj%FOUND THEN
      CLOSE cr_crapblj;
      vr_dscritic := 'Ja existe bloqueio para o oficio informado!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapblj;
    */ --fim thiago rodrigues
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Busca os dados do cooperado
    blqj0001.pc_busca_contas_cooperado(pr_cdcooper => pr_cdcooper, 
                                       pr_cdagenci => '1',
                                       pr_nrdcaixa => '1',
                                       pr_cdoperad => '1',
                                       pr_nmdatela => 'BLQJUD',
                                       pr_idorigem => 7, -- Batch
                                       pr_inproces => 1,
                                       pr_cooperad => pr_nrdconta,
                                       pr_tpcooperad => 1, -- Busca pela conta
                                       pr_nmprimtl => vr_nmprimtl,
                                       pr_tab_cooperado => vr_tab_cooperado,
                                       pr_tab_erro => vr_tab_erro);

    -- Verifica se ocorreu erro na rotina
    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Se nao existir registro no retorno, deve-se gerar erro
    IF vr_tab_cooperado.first IS NULL THEN
      vr_dscritic := 'Conta informada inexistente.';
      RAISE vr_exc_saida;
    END IF;

    -- Define o saldo conforme a modalidade passada
    IF pr_cdmodali = 1 THEN -- Deposito a vista
      
      -- Busca os valores de bloqueio
      EXTR0001.pc_obtem_saldos_anteriores(pr_cdcooper   => pr_cdcooper,
                                          pr_cdagenci   => 1,
                                          pr_nrdcaixa   => 1,
                                          pr_cdopecxa   => '1',
                                          pr_nmdatela   => 'BLQJUD',
                                          pr_idorigem   => 1,
                                          pr_nrdconta   => pr_nrdconta,
                                          pr_idseqttl   => 1,
                                          pr_dtmvtolt   => rw_crapdat.dtmvtolt,
                                          pr_dtmvtoan   => rw_crapdat.dtmvtoan,
                                          pr_dtrefere   => rw_crapdat.dtmvtoan,
                                          pr_flgerlog   => FALSE,
                                          pr_dscritic   => vr_dscritic,
                                          pr_tab_saldos => vr_tab_saldos,
                                          pr_tab_erro   => vr_tab_erro);
      
      -- Verifica se ocorreu erro na rotina
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      vr_dsmodali := 'do deposito a vista';
      vr_vlsaldo := vr_tab_cooperado(1).vlstotal;
      
      -- Se existir tabela de saldos anteriores
      IF vr_tab_saldos.exists(0) THEN
        vr_vlsaldo := vr_vlsaldo - vr_tab_saldos(0).vlsdbloq - 
                      vr_tab_saldos(0).vlsdblpr - 
                      vr_tab_saldos(0).vlsdblfp;
      END IF;
    ELSIF pr_cdmodali = 2 THEN -- Aplicacao
      vr_dsmodali := 'da aplicacao';
      vr_vlsaldo := vr_tab_cooperado(1).vlsldapl;
    ELSE -- Poupanca Programada
      vr_dsmodali := 'da poupanca';
      vr_vlsaldo := vr_tab_cooperado(1).vlsldppr;
    END IF;
    
    -- Se o saldo estiver zerado, deve-se gerar erro
    IF vr_vlsaldo <= 0 THEN
      vr_dscritic := 'Saldo '||vr_dsmodali|| ' esta zerado. Bloqueio nao permitido.';
      RAISE vr_exc_saida;
    END IF;

/* A pedido da Sabrina, nao fazer a validacao, pois a WebJud ja fara.
    -- Se a somatoria dos 3 produtos for menor que 10 reais, deve-se gerar erro
    IF nvl(vr_tab_cooperado(1).vlstotal,0) +  
       nvl(vr_tab_cooperado(1).vlsldapl,0) + 
       nvl(vr_tab_cooperado(1).vlsldppr,0) < 10 THEN
      vr_dscritic := 'Saldo Inferior a R$ 10,00. Bloqueio nao permitido.';
      RAISE vr_exc_saida;
    END IF;
*/
    -- Se o valor solicitado for maior que o saldo, utiliza o saldo como valor de bloqueio
    IF pr_vlbloque > vr_vlsaldo THEN
      pr_vlbloque := vr_vlsaldo;
    END IF;

    -- Busca o numero do oficio que sera utilizado
    vr_nroficio := pr_nroficio; --thiago rodrigues
    --thiago rodrigues
    /*
    OPEN cr_crapblj_2;
    FETCH cr_crapblj_2 INTO rw_crapblj_2;
    
    -- Se nao encontrar, utiliza o oficio do parametro
    IF cr_crapblj_2%NOTFOUND THEN
      vr_nroficio := pr_nroficio;
    ELSE -- Se encontrar, utiliza o sequencial
      -- Verifica se já existe sequencial
      IF instr(rw_crapblj_2.nroficio,'/') = 0 THEN
        vr_nroficio := rw_crapblj_2.nroficio||'/01';
      ELSE
        vr_nroficio := substr(rw_crapblj_2.nroficio,1,instr(rw_crapblj_2.nroficio,'/'))||
             to_char((SUBSTR(rw_crapblj_2.nroficio,instr(rw_crapblj_2.nroficio,'/')+1)+1),'fm00');
      END IF;
    END IF;    
    CLOSE cr_crapblj_2;
      
    */ --fim thiago rodrigues
    -- Inclui o bloqueio judicial
    blqj0001.pc_inclui_bloqueio_jud(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdtipmov => 1 -- Bloqueio judicial
                                   ,pr_cdmodali => pr_cdmodali
                                   ,pr_vlbloque => pr_vlbloque
                                   ,pr_nroficio => vr_nroficio
                                   ,pr_nrproces => pr_nrproces
                                   ,pr_dsjuizem => pr_dsjuizem
                                   ,pr_dsresord => pr_dsresord
                                   ,pr_flblcrft => FALSE -- nao tera bloqueio de creditos futuros
                                   ,pr_dtenvres => rw_crapdat.dtmvtolt
                                   ,pr_vlrsaldo => 0 -- Saldo de Bloqueio
                                   ,pr_cdoperad => '1'
                                   ,pr_dsinfadc => ' '
                                   ,pr_tab_erro => vr_tab_erro);

    -- Verifica se ocorreu erro na rotina
    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Devolvemos a critica encontrada das variaveis locais
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro BLQJ0002.pc_bloqueio: '||sqlerrm;
    
  END;


  -- Rotina para desbloquear valores  
  PROCEDURE pc_desbloqueio(pr_cdcooper IN crapblj.cdcooper%TYPE,
                           pr_nrdconta IN crapblj.nrdconta%TYPE,
                           pr_cdmodali IN crapblj.cdmodali%TYPE,
                           pr_nroficio IN crapblj.nroficio%TYPE,
                           pr_nrproces IN crapblj.nrproces%TYPE,
                           pr_dsjuizem IN crapblj.dsjuizem%TYPE,
                           pr_fldestrf IN crapblj.fldestrf%TYPE,
                           pr_vlbloque IN OUT crapblj.vlbloque%TYPE,
                           pr_dscritic    OUT VARCHAR2) IS

    -- Verifica se existe bloqueio pendente
    CURSOR cr_crapblj IS
      SELECT a.vlbloque, 
             a.nroficio,
             a.dsresord
        FROM crapblj a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.nroficio LIKE pr_nroficio||'%'
         AND a.cdmodali = pr_cdmodali
         AND a.dtblqfim IS NULL -- Que nao esteja desbloqueado
       ORDER BY nroficio DESC; 
    rw_crapblj cr_crapblj%ROWTYPE;

    -- Registro sobre a data do sistema
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variaveis Pl/Tables
    vr_tab_erro      GENE0001.typ_tab_erro;

    -- VARIÁVEIS
    vr_vlbloqueio crapblj.vlbloque%TYPE; -- Valor que sera bloqueado
    vr_fldestrf   BOOLEAN; -- Indicador de desbloqueio para transferencia
    vr_dsinfdes   crapblj.dsinfdes%TYPE; -- Informacao de desbloqueio

    -- Variaveis de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  
  BEGIN

    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Verifica se existe baixa pendente
    OPEN cr_crapblj;
    FETCH cr_crapblj INTO rw_crapblj;
      
    -- Se nao tiver registro pendente, encerra o processo
    IF cr_crapblj%NOTFOUND THEN
      CLOSE cr_crapblj;
      vr_dscritic := 'Nao foi encontrado bloqueio registrado para este desbloqueio.';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapblj;

    

/* Demetrius -- a logica de valor está na BLQJ0001.pc_efetua_desbloqueio_jud

    -- Verifica se o bloqueio solicitado eh superior ao bloqueio existente
    -- Neste caso deve-se desbloquear somente o valor existente
    IF pr_vlbloque > rw_crapblj.vlbloque THEN
      pr_vlbloque := rw_crapblj.vlbloque;
    END IF;
    
    -- Se o valor do bloqueio for inferior ao que esta bloqueado,
    -- Deve-se desbloquear tudo e fazer o bloqueio do saldo
    IF pr_vlbloque < rw_crapblj.vlbloque THEN 
      -- Desbloquear todo o valor
      pc_desbloqueio(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_cdmodali => pr_cdmodali,
                     pr_nroficio => pr_nroficio,
                     pr_nrproces => pr_nrproces,
                     pr_dsjuizem => pr_dsjuizem,
                     pr_fldestrf => pr_fldestrf,
                     pr_vlbloque => rw_crapblj.vlbloque, -- Desbloqueia integral
                     pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Calcular quanto que devera ser bloqueado
      vr_vlbloqueio := rw_crapblj.vlbloque - pr_vlbloque;
      
      -- Efetua o bloqueio com o saldo que ficou
      pc_bloqueio(pr_cdcooper => pr_cdcooper,
                  pr_nrdconta => pr_nrdconta,
                  pr_cdmodali => pr_cdmodali,
                  pr_nroficio => pr_nroficio,
                  pr_nrproces => pr_nrproces,
                  pr_dsjuizem => pr_dsjuizem,
                  pr_dsresord => rw_crapblj.dsresord,
                  pr_vlbloque => vr_vlbloqueio, -- Bloqueio o saldo calculado
                  pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    ELSE -- Se o valor solicitado eh o mesmo valor que esta bloqueado
            
*/
      IF pr_fldestrf = 0 THEN
        vr_fldestrf := FALSE;
        vr_dsinfdes := 'Desbloqueio BACENJUD';
      ELSE
        vr_fldestrf := TRUE;
        vr_dsinfdes := 'Desbloqueio/Transferência BACENJUD';
      END IF;

      vr_vlbloqueio := pr_vlbloque; --thiago rodrigues

      -- Efetua o desbloqueio judicial
      blqj0001.pc_efetua_desbloqueio_jud(pr_cdcooper  => pr_cdcooper
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                        ,pr_cdoperad  => 1
                                        ,pr_nroficio  => rw_crapblj.nroficio
                                        ,pr_cdmodali  => pr_cdmodali
                                        ,pr_nrctacon  => pr_nrdconta
                                        ,pr_nrofides  => rw_crapblj.nroficio
                                        ,pr_dtenvdes  => rw_crapdat.dtmvtolt
                                        ,pr_dsinfdes  => vr_dsinfdes
                                        ,pr_fldestrf  => vr_fldestrf
                                        ,pr_tpcooperad=> 1 -- Efetuar a busca por conta
                                        ,pr_vldesblo  => vr_vlbloqueio
                                        ,pr_tab_erro  => vr_tab_erro);
      -- Verifica se ocorreu erro na rotina
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_saida;
      END IF;
    
 --   END IF;   -- pr_vlbloque < rw_crapblj.vlbloque
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Devolvemos a critica encontrada das variaveis locais
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro BLQJ0002.pc_desbloqueio: '||sqlerrm;
    
  END;

  -- Rotina para resgatar o valor de aplicacoes
  PROCEDURE pc_resgata_aplicacao(pr_cdcooper tbblqj_ordem_online.cdcooper%TYPE, -- Codigo da cooperativa
                                 pr_nrdconta crapass.nrdconta%TYPE, -- Codigo da conta
                                 pr_vlresgat craprda.vlaplica%TYPE, -- Valor a ser resgatado
                                 pr_dscritic OUT VARCHAR2) IS -- Retorno de erro

    -- Registro sobre a data do sistema
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- Variaveis Pl/Tables
    vr_tab_dados_resgate    APLI0001.typ_tab_resgate; --> dados para resgate
    vr_tab_resposta_cliente apli0002.typ_tab_resposta_cliente; --> Retorna respostas para as aplicações
    vr_tab_msg_confirma APLI0002.typ_tab_msg_confirma; -- Pl Table com mensagens de resgate (nao utlizado, somnente como retorno de rotina)
    vr_saldo_rdca apli0001.typ_tab_saldo_rdca; -- Aplicacoes existentes na conta
    vr_tab_erro      GENE0001.typ_tab_erro;

    -- VARIÁVEIS
    vr_indice VARCHAR2(25); -- Indice da pl/table 
    vr_nrdocmto craplcm.nrdocmto%TYPE; -- Numero do documento da aplicacao
    vr_vlresgat craprda.vlaplica%TYPE; -- Valor a ser resgatado

    -- Variaveis de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida EXCEPTION; --> Excecao prevista
    vr_des_reto   VARCHAR2(10); --> Situacao do retorno do resgate

  begin
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Limpa os dados de resgate
    vr_tab_dados_resgate.DELETE;

    -- Atualiza o valor a ser resgatado
    vr_vlresgat := pr_vlresgat;

    -- Busca as aplicacoes existentes na conta
    apli0001.pc_consulta_aplicacoes(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => 1
                                   ,pr_nrdcaixa => 1
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => 0
                                   ,pr_tpaplica => 0
                                   ,pr_dtinicio => NULL
                                   ,pr_dtfim => NULL
                                   ,pr_cdprogra => 'BLQJ0002'
                                   ,pr_nrorigem => 7 -- Batch
                                   ,pr_saldo_rdca => vr_saldo_rdca 
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => vr_tab_erro);
                                               
    -- Verificar se possui alguma crítica
    IF vr_des_reto = 'NOK' THEN        
                  
      IF vr_tab_erro.COUNT > 0 THEN
                    
        -- Se existir erro adiciona na crítica
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    
        -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
        vr_tab_erro.DELETE;
                    
      ELSE  
        vr_dscritic := 'Nao foi possivel consultar as aplicacoes.';
      END IF;
                  
      RAISE vr_exc_saida;
                    
    END IF;  
        
    -- Verifica se possui saldo para resgates
    IF vr_saldo_rdca.COUNT <= 0 THEN
      vr_dscritic := 'Saldo de aplicacao insuficiente para resgate.';     
                  
      RAISE vr_exc_saida;        
                
    END IF;
                
    -- Prioriza as aplicacoes a serem resgatadas (mesmo processo que o PC_CRPS688)
    apli0002.pc_filtra_aplic_resg_auto(pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => 1
                                      ,pr_nrdcaixa => 1
                                      ,pr_cdoperad => '1'
                                      ,pr_nmdatela => 'BLQJ0002'
                                      ,pr_idorigem => 7 -- Batch
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => 1
                                      ,pr_tab_saldo_rdca => vr_saldo_rdca
                                      ,pr_tpaplica => 0 -- Todos
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                      ,pr_inproces => rw_crapdat.inproces
                                      ,pr_dtresgat => rw_crapdat.dtmvtocd
                                      ,pr_cdprogra => 'BLQJ0002'
                                      ,pr_flgerlog => 1
                                      ,pr_tab_dados_resgate => vr_tab_dados_resgate
                                      ,pr_tab_resposta_cliente => vr_tab_resposta_cliente
                                      ,pr_vltotrgt => vr_vlresgat
                                      ,pr_tab_erro => vr_tab_erro
                                      ,pr_des_reto => vr_des_reto);
                                                      
    -- Verificar se possui alguma crítica
    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
                      
        -- Se existir erro adiciona na crítica
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                      
        -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
        vr_tab_erro.DELETE;
                      
      ELSE  
        vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
      END IF;
                    
      RAISE vr_exc_saida;
                     
    END IF;   

    -- Despreza resgate quando não houver valor suficiente para suprir o valor a ser resgatado
    IF vr_vlresgat > 0 THEN
                  
      vr_dscritic := 'Saldo insuficiente para resgate.';     
      RAISE vr_exc_saida;        
                
    END IF;
                
    vr_indice := vr_tab_dados_resgate.first;
                
    --Se não foi encontrado nenhuma aplicação para efetuar o resgate então, cai fora do loop
    IF vr_indice IS NULL THEN
                  
      --Monta critica
      vr_dscritic := 'Nao foi encontrado aplicacoes para serem efetuado(s) o(s) resgate(s).';
                  
      RAISE vr_exc_saida;
                  
    END IF;  
                

   -- Loop sobre as aplicacoes a serem resgatadas
    WHILE vr_indice IS NOT NULL LOOP

      -- Efetua o resgate da aplicacao
      APLI0002.pc_cad_resgate_aplica(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => 1
                                    ,pr_nrdcaixa => 1
                                    ,pr_cdoperad => '1'
                                    ,pr_nmdatela => 'BLQJ0002'
                                    ,pr_idorigem => 7 --Batch
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nraplica => vr_tab_dados_resgate(vr_indice).saldo_rdca.nraplica
                                    ,pr_idseqttl => 1
                                    ,pr_cdprogra => 'BLQJ0002'
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                    ,pr_inproces => rw_crapdat.inproces
                                    ,pr_vlresgat => (CASE vr_tab_dados_resgate(vr_indice).tpresgat
                                                         WHEN 1 THEN
                                                           vr_tab_dados_resgate(vr_indice).vllanmto                                                                   
                                                         ELSE
                                                           0
                                                      END) 
                                    ,pr_dtresgat => rw_crapdat.dtmvtocd
                                    ,pr_flmensag => 0
                                    ,pr_tpresgat => (CASE vr_tab_dados_resgate(vr_indice).tpresgat
                                                         WHEN 1 THEN
                                                           'P'
                                                         WHEN 2 THEN
                                                           'T'
                                                         ELSE
                                                           ''
                                                      END) 
                                    ,pr_flgctain => 0
                                    ,pr_flgerlog => 1
                                    ,pr_nrdocmto => vr_nrdocmto
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tbmsconf => vr_tab_msg_confirma
                                    ,pr_tab_erro => vr_tab_erro);
                            
      -- Verificar se possui alguma crítica
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          -- Se existir erro adiciona na crítica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Limpar a tabela de erro, pois a exceção vai criar um novo registro
          vr_tab_erro.DELETE;
        ELSE  
          vr_dscritic := 'Nao foi possivel listar as aplicacoes.';
        END IF;
                      
        -- Executa a exceção
        RAISE vr_exc_saida;
      END IF;         
                    
      -- ir para o proximo
      vr_indice := vr_tab_dados_resgate.NEXT(vr_indice);                               
                      
    END LOOP;              
                  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Devolvemos a critica encontrada das variaveis locais
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro BLQJ0002.pc_resgata_aplicacao: '||sqlerrm;

  END pc_resgata_aplicacao;                                 

  -- Efetua o lancamento de resgate
  PROCEDURE pc_efetua_resgate_poupanca(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                       pr_nrdconta IN crapass.nrdconta%TYPE,
                                       pr_nrdocmto IN craplrg.nrdocmto%TYPE,
                                       pr_tpresgat IN PLS_INTEGER, --1-Parcial 2-Total
                                       pr_vllanmto IN craplrg.vllanmto%TYPE,
                                       pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS -- Retorno de erro
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
    
    -- Variaveis de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida EXCEPTION; --> Excecao prevista

  BEGIN
  
     -- Verifica Existencia de Lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                   ,pr_dtmvtolt => pr_dtmvtolt
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
                   VALUES  (pr_dtmvtolt
                           ,pr_dtmvtolt
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
                         ,pr_dtmvtolt
                         ,pr_dtmvtolt
                         ,0
                         ,pr_nrdocmto
                         ,pr_nrdconta
                         ,4
                         ,pr_tpresgat
                         ,pr_vllanmto
                         ,'1'
                         ,GENE0002.fn_busca_time -- TIME
                         ,0 -- Nao resgatar para a conta investimento
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
                  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Devolvemos a critica encontrada das variaveis locais
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro BLQJ0002.pc_resgata_aplicacao: '||sqlerrm;
  END pc_efetua_resgate_poupanca;


  -- Rotina para resgatar o valor de poupanca programada
  PROCEDURE pc_resgata_poupanca_programa(pr_cdcooper tbblqj_ordem_online.cdcooper%TYPE, -- Codigo da cooperativa
                                         pr_nrdconta crapass.nrdconta%TYPE, -- Codigo da conta
                                         pr_vlresgat craprda.vlaplica%TYPE, -- Valor a ser resgatado
                                         pr_dscritic OUT VARCHAR2) IS -- Retorno de erro

    -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
    CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
    SELECT lpp.nrdconta
          ,lpp.nrctrrpp
          ,Count(*) qtlancmto
      FROM craplpp lpp
     WHERE lpp.cdcooper = pr_cdcooper
       AND lpp.nrdconta = pr_nrdconta
       AND lpp.cdhistor IN (158,496)
       AND lpp.dtmvtolt > pr_dtmvtolt
       GROUP BY lpp.nrdconta
               ,lpp.nrctrrpp
                HAVING Count(*) > 3;
                  
    --Contar a quantidade de resgates das contas
    CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,COUNT(*) qtlancmto
      FROM craplrg lrg
     WHERE lrg.cdcooper = pr_cdcooper
       AND lrg.nrdconta = pr_nrdconta
       AND lrg.tpaplica = 4
       AND lrg.inresgat = 0
       GROUP BY lrg.nrdconta
               ,lrg.nraplica;

    --Selecionar informacoes dos lancamentos de resgate
    CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                      ,pr_dtresgat IN craplrg.dtresgat%TYPE) IS
    SELECT lrg.nrdconta
          ,lrg.nraplica
          ,lrg.tpaplica
          ,lrg.tpresgat
          ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
      FROM craplrg lrg
     WHERE lrg.cdcooper  = pr_cdcooper
       AND lrg.nrdconta  = pr_nrdconta
       AND lrg.dtresgat <= pr_dtresgat
       AND lrg.inresgat  = 0
       AND lrg.tpresgat  = 1
       GROUP BY lrg.nrdconta
               ,lrg.nraplica
               ,lrg.tpaplica
               ,lrg.tpresgat;                
               
    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
    -- Tabela para armazenar os erros
    vr_tab_erro gene0001.typ_tab_erro;
            
    -- Tabela de retorno da rotina
    vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;
    
    --Variavel usada para montar o indice da tabela de memoria
    vr_index_craplpp VARCHAR2(20);
    vr_index_craplrg VARCHAR2(20);
    vr_index_resgate VARCHAR2(25);
     
    --Definicao das tabelas de memoria da apli0001.pc_acumula_aplicacoes
    vr_tab_conta_bloq APLI0001.typ_tab_ctablq;
    vr_tab_craplpp    APLI0001.typ_tab_craplpp;
    vr_tab_craplrg    APLI0001.typ_tab_craplpp;
    vr_tab_resgate    APLI0001.typ_tab_resgate;
           
    -- Descrição e código da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
          
    -- Variavel exceção
    vr_exc_saida EXCEPTION;
      
    -- Variaveis locais
    vr_percenir  NUMBER := 0;
    vr_vlsldrpp  NUMBER := 0;
    vr_vlsaldo   craprpp.vlsdrdpp%TYPE;
    vr_vlresgate craprpp.vlsdrdpp%TYPE;
    vr_tpresgate PLS_INTEGER;
    vr_des_reto  VARCHAR(3);
    vr_ind       PLS_INTEGER;
    vr_stprogra  PLS_INTEGER;
    vr_infimsol  PLS_INTEGER;
    
  BEGIN
    -- Verifica se a cooperativa esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
          
    -- Carregar tabela de memoria de contas bloqueadas
    TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_tab_cta_bloq => vr_tab_conta_bloq);
           
    -- Carregar tabela de memoria de lancamentos na poupanca
    FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt - 180) LOOP
                                       
      -- Montar indice para acessar tabela
      vr_index_craplpp := LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
             
      -- Atribuir quantidade encontrada de cada conta ao vetor
      vr_tab_craplpp(vr_index_craplpp) := rw_craplpp.qtlancmto;
             
    END LOOP;

    -- Carregar tabela de memoria com total de resgates na poupanca
    FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper) LOOP
             
      -- Montar Indice para acesso quantidade lancamentos de resgate
      vr_index_craplrg := LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
             
      -- Popular tabela de memoria
      vr_tab_craplrg(vr_index_craplrg) := rw_craplrg.qtlancmto;
             
    END LOOP;
           
    -- Carregar tabela de memória com total resgatado por conta e aplicacao
    FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                 ,pr_dtresgat => rw_crapdat.dtmvtopr) LOOP
                                        
      -- Montar indice para selecionar total dos resgates na tabela auxiliar
      vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0') ||
                          LPad(rw_craplrg.tpaplica,05,'0') ||
                          LPad(rw_craplrg.nraplica,10,'0');
                                
      -- Popular a tabela de memoria com a soma dos lancamentos de resgate
      vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
      vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
             
    END LOOP;
           
    -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
    vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                         ,pr_nmsistem => 'CRED'
                                                                         ,pr_tptabela => 'CONFIG'
                                                                         ,pr_cdempres => 0
                                                                         ,pr_cdacesso => 'PERCIRAPLI'
                                                                         ,pr_tpregist => 0));
          
          
          
       
    -- Executar rotina consulta poupanca
    APLI0001.pc_consulta_poupanca(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => 1
                                 ,pr_nrdcaixa => 1
                                 ,pr_cdoperad => '1'
                                 ,pr_idorigem => 1
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => 1
                                 ,pr_nrctrrpp => 0
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_dtmvtopr => rw_crapdat.dtmvtolt
                                 ,pr_inproces => rw_crapdat.inproces
                                 ,pr_cdprogra => 'BLOQ0002'
                                 ,pr_flgerlog => FALSE
                                 ,pr_percenir => vr_percenir
                                 ,pr_tab_craptab => vr_tab_conta_bloq 
                                 ,pr_tab_craplpp => vr_tab_craplpp
                                 ,pr_tab_craplrg => vr_tab_craplrg
                                 ,pr_tab_resgate => vr_tab_resgate
                                 ,pr_vlsldrpp => vr_vlsldrpp
                                 ,pr_retorno  => vr_des_reto
                                 ,pr_tab_dados_rpp => vr_tab_dados_rpp
                                 ,pr_tab_erro      => vr_tab_erro);
                              
    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
       -- Tenta buscar o erro no vetor de erro
      IF vr_tab_erro.COUNT > 0 THEN
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
      ELSE
        vr_dscritic := 'Retorno "NOK" na BLOQ0001.pc_consulta_poupanca e sem informacao na pr_tab_erro, Conta: '||pr_nrdconta;
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    
    -- Verifica se o saldo da poupanca eh maior ou igual ao valor solicitado
    IF vr_vlsldrpp < pr_vlresgat THEN
      vr_dscritic := 'Valor existente na poupanca programada ('||to_char(vr_vlsldrpp,'FM999G999G990D00')||
        ') inferior ao solicitado para resgate ('||to_char(pr_vlresgat,'FM999G999G990D00')||').';
      RAISE vr_exc_saida;
    END IF;
      
    -- Busca o primeiro registro da tabela de retorno de poupancas programadas
    vr_ind := vr_tab_dados_rpp.first;
    
    -- Define o saldo para calculo do resgate
    vr_vlsaldo := pr_vlresgat;
    
    -- Efetua loop sobre as poupancas programadas
    LOOP
      EXIT WHEN vr_ind IS NULL;
      EXIT WHEN vr_vlsaldo = 0;

      -- Define o valor a ser resgatado
      IF vr_vlsaldo >= vr_tab_dados_rpp(vr_ind).vlsdrdpp THEN
        vr_vlsaldo := vr_vlsaldo - vr_tab_dados_rpp(vr_ind).vlsdrdpp;
        vr_vlresgate := vr_tab_dados_rpp(vr_ind).vlsdrdpp;
        vr_tpresgate := 2;
      ELSE
        vr_vlresgate := vr_vlsaldo;
        vr_vlsaldo := 0;
        vr_tpresgate := 1;
      END IF;

      -- Efetua o resgate
      pc_efetua_resgate_poupanca(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrdocmto => vr_tab_dados_rpp(vr_ind).nrctrrpp,
                                 pr_tpresgat => vr_tpresgate,
                                 pr_vllanmto => vr_vlresgate,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_dscritic => vr_dscritic);
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Vai para o proximo registro
      vr_ind := vr_tab_dados_rpp.next(vr_ind);
    END LOOP;
    
    -- Se sobrou saldo, entao deve-se gerar erro
    IF vr_vlsaldo > 0 THEN
      vr_dscritic := 'Valor solicitado para resgate de poupanca programada superior ao existente.';
      RAISE vr_exc_saida;
    END IF;
  
    -- Executa rotina para efetuar o resgate do lancamento da poupanca para a conta
    pc_crps156(pr_cdcooper => pr_cdcooper
              ,pr_nrdconta => pr_nrdconta
              ,pr_flgresta => 0
              ,pr_stprogra => vr_stprogra
              ,pr_infimsol => vr_infimsol
              ,pr_cdcritic => vr_cdcritic
              ,pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;  
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Devolvemos a critica encontrada das variaveis locais
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_dscritic := 'Erro BLQJ0002.pc_resgata_poupanca: '||sqlerrm;
  END pc_resgata_poupanca_programa;

  -- Atualiza a situacao da ordem WebJud
  PROCEDURE pc_atualiza_situacao(pr_idordem    tbblqj_ordem_online.idordem%TYPE,
                                 pr_instatus   tbblqj_ordem_online.instatus%TYPE,
                                 pr_dslog_erro tbblqj_ordem_online.dslog_erro%TYPE DEFAULT NULL) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE tbblqj_ordem_online
       SET instatus = pr_instatus,
           dslog_erro = substr(pr_dslog_erro,1,200),
           dhresposta = decode(pr_instatus,2,SYSDATE,dhresposta)
     WHERE idordem = pr_idordem;

    -- Grava a alteracao
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  
  -- Rotina para encerrar o processo com erro
  PROCEDURE pc_encerra_processo_erro(pr_idordem tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                     pr_cdcooper crapcop.cdcooper%TYPE, -- Codigo da cooperativa
                                     pr_dsinconsit tbgen_inconsist.dsinconsist%TYPE,
                                     pr_dsregistro_referencia tbgen_inconsist.dsregistro_referencia%TYPE) IS
    vr_des_erro VARCHAR2(10);
    vr_dscritic VARCHAR2(500);
  BEGIN
    -- Desfaz o que foi feito
    ROLLBACK;
    
    -- Coloca o registro da solicitacao como processado com Erro
    pc_atualiza_situacao(pr_idordem => pr_idordem,
                         pr_instatus => 4, -- Erro
                         pr_dslog_erro => pr_dsinconsit);
      
    -- Insere na inconsistencia
    gene0005.pc_gera_inconsistencia(pr_cdcooper => pr_cdcooper
                                   ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                   ,pr_tpincons => 2 -- Erro
                                   ,pr_dsregist => pr_dsregistro_referencia
                                   ,pr_dsincons => pr_dsinconsit
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
    
    -- Atualiza os dados
    COMMIT;
    
  END;                                     
  
  -- Efetuar o recebimento das solicitacoes de consulta de conta
  PROCEDURE pc_recebe_solicitacao(pr_nrdocnpj_cop  IN  crapcop.nrdocnpj%TYPE, -- CNPJ da cooperativa
                                  pr_nrcpfcnpj     IN  crapass.nrcpfcgc%TYPE, -- CNPJ / CPF do réu
                                  pr_tppessoa      IN  VARCHAR2, -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                  pr_idordem       OUT tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                  pr_cdcritic      OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                  pr_dscritic      OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
                                  
                                      
    -- CURSORES
    -- Busca os dados da cooperativa selecionada
    CURSOR cr_crapcop(pr_nrdocnpj crapcop.nrdocnpj%TYPE) IS
      SELECT cdcooper
        FROM crapcop
       WHERE nrdocnpj = pr_nrdocnpj;
        
    -- VARIÁVEIS
    vr_idordem tbblqj_ordem_online.idordem%TYPE; -- Sequencial do recebimento
    vr_cdcooper      crapcop.cdcooper%TYPE; -- Codigo da cooperativa
    vr_dsplsql VARCHAR2(4000); -- Bloco PLSQL para chamar a execução do job
    vr_jobname VARCHAR2(20); -- Nome do Job que sera executado

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_des_erro   VARCHAR2(10); --> Retorno com erro ou sucesso
    
    
  BEGIN
    
    -- Busca o codigo da cooperativa
    OPEN cr_crapcop(pr_nrdocnpj_cop);
    FETCH cr_crapcop INTO vr_cdcooper;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'CNPJ da cooperativa ('||pr_nrdocnpj_cop||') nao cadastrado como cooperativa!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;
  
    -- Atualiza a Sequence da tabela
    vr_idordem := fn_sequence(pr_nmtabela => 'TBBLQJUD_ORDEM_ONLINE', pr_nmdcampo => 'IDORDEM',pr_dsdchave => '0');

    -- Insere na tabela de solicitacoes do Webjud
    BEGIN
      INSERT INTO tbblqj_ordem_online
        (idordem,
         tpordem,
         cdcooper,
         nrcpfcnpj,
         tppessoa,
         dhrequisicao,
         instatus)
      VALUES
        (vr_idordem,
         1, -- COnsulta
         vr_cdcooper,
         pr_nrcpfcnpj,
         decode(pr_tppessoa,'F',1,
                            'J',2,
                                3),
         SYSDATE,
         1); --Pendente
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbblqj_ordem_online: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    -- Atualiza o numero da ordem de retorno
    pr_idordem := vr_idordem;
    
    -- Confirma a gravacao dos dados
    COMMIT;
    
    -- Declara a rotina para ser executada via job
    vr_dsplsql := 'DECLARE'||chr(13)
               || '  vr_cdcritic NUMBER;'||chr(13)
               || '  vr_dscritic VARCHAR2(4000);'||chr(13)
               || 'BEGIN'||chr(13)
               || '  BLQJ0002.pc_processa_solicitacao('||vr_idordem||',vr_cdcritic,vr_dscritic);'||chr(13)
               || 'END;';
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'blqj_'||vr_idordem||'$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                          ,pr_cdprogra  => 'BLQJ0002'   --> Código do programa
                          ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva   => NULL          --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro  => vr_dscritic);
    -- Testar saida com erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa
                                     ,pr_dsincons => 'Recebimento Solicitacao: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa
                                     ,pr_dsincons => 'Recebimento Solicitacao: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

  END pc_recebe_solicitacao;
  

  -- Efetuar o recebimento das solicitacoes de bloqueio e desbloqueio
  PROCEDURE pc_recebe_blq_desblq(pr_nrdocnpj_cop  IN  crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                                ,pr_nrcpfcnpj     IN  crapass.nrcpfcgc%TYPE -- CNPJ / CPF do réu
                                ,pr_tppessoa      IN  VARCHAR2 -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                                ,pr_tpproduto     IN  VARCHAR2 -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                ,pr_dsoficio      IN  crapblj.nroficio%TYPE -- Numero do oficio
                                ,pr_nrdconta      IN  crapblj.nrdconta%TYPE -- Numero da conta
                                ,pr_cdagenci      IN  crapass.cdagenci%TYPE -- Codigo da agencia
                                ,pr_tpordem       IN  tbblqj_ordem_online.tpordem%TYPE -- Tipo de Operacao (2-Bloqueio, 3-Desbloqueio)
                                ,pr_vlordem       IN  crapblj.vlbloque%TYPE -- Valor do bloqueio
                                ,pr_dsprocesso    IN  crapblj.nrproces%TYPE -- Numero do processo
                                ,pr_nmjuiz        IN  crapblj.dsjuizem%TYPE -- Juiz emissor
                                ,pr_idordem       OUT tbblqj_ordem_online.idordem%TYPE -- Sequencial do recebimento
                                ,pr_cdcritic      OUT crapcri.cdcritic%TYPE -- Critica encontrada
                                ,pr_dscritic      OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
                                    
                                      
    -- CURSORES
    -- Busca os dados da cooperativa selecionada
    CURSOR cr_crapcop(pr_nrdocnpj crapcop.nrdocnpj%TYPE) IS
      SELECT cdcooper
        FROM crapcop
       WHERE nrdocnpj = pr_nrdocnpj;
        
    -- VARIÁVEIS
    vr_cdcooper      crapcop.cdcooper%TYPE; -- Codigo da cooperativa
    vr_dsplsql VARCHAR2(4000); -- Bloco PLSQL para chamar a execução do job
    vr_jobname VARCHAR2(20); -- Nome do Job que sera executado
    vr_operacao VARCHAR2(11); -- Tipo de operacao

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_des_erro   VARCHAR2(10); --> Retorno com erro ou sucesso
    
    
  BEGIN
      
    -- Busca o codigo da cooperativa
    OPEN cr_crapcop(pr_nrdocnpj_cop);
    FETCH cr_crapcop INTO vr_cdcooper;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'CNPJ da cooperativa ('||pr_nrdocnpj_cop||') nao cadastrado como cooperativa!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;
  
    -- Validacoes iniciais
    IF pr_tpproduto NOT IN ('C','P','A') THEN
      vr_dscritic := 'Modalidade recebida nao prevista. Devera ser C ou P ou A';
      RAISE vr_exc_saida;
    END IF;

    -- Validacoes iniciais
    IF pr_tpordem NOT IN (2,3) THEN
      vr_dscritic := 'Tipo de ordem recebida nao prevista. Devera ser 2-Bloqueio ou 3-Desbloqueio';
      RAISE vr_exc_saida;
    END IF;

    -- Define a operacao que esta sendo realizada
    IF pr_tpordem = 2 THEN
      vr_operacao := 'Bloqueio';
    ELSE
      vr_operacao := 'Desbloqueio';
    END IF;
    
    -- Atualiza a Sequence da tabela
    pr_idordem := fn_sequence(pr_nmtabela => 'TBBLQJUD_ORDEM_ONLINE', pr_nmdcampo => 'IDORDEM',pr_dsdchave => '0');

    -- Insere na tabela de solicitacoes do Webjud
    BEGIN
      INSERT INTO tbblqj_ordem_online
        (idordem,
         tpordem,
         cdcooper,
         tppessoa,
         nrcpfcnpj,
         dhrequisicao,
         instatus)
      VALUES
        (pr_idordem,
         pr_tpordem,
         vr_cdcooper,
         decode(pr_tppessoa,'F',1,
                            'J',2,
                                3),
         pr_nrcpfcnpj,
         SYSDATE,
         1); -- Pendente
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbblqj_ordem_online: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
             
    -- Insere na tabela de solicitacoes de bloqueio / desbloqueio
    BEGIN
      INSERT INTO tbblqj_ordem_bloq_desbloq
        (idordem,
         cdmodali,
         dsoficio,
         nrdconta,
         cdagenci,
         vlordem,
         dsprocesso,
         nmjuiz
         )
      VALUES
        (pr_idordem,
         decode(pr_tpproduto,'C',1, -- Conta Corrente
                             'A',2, -- Aplicacao
                                 3),-- Poupanca Programada
         substr(pr_dsoficio,1,25),
         pr_nrdconta,
         pr_cdagenci,
         pr_vlordem,
         substr(pr_dsprocesso,1,25),
         substr(pr_nmjuiz,1,70));
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbblqj_ordem_bloq_desbloq: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
             
    -- Confirma a gravacao dos dados
    COMMIT;
    
    -- Declara a rotina para ser executada via job
    vr_dsplsql := 'DECLARE'||chr(13)
               || '  vr_cdcritic NUMBER;'||chr(13)
               || '  vr_dscritic VARCHAR2(4000);'||chr(13)
               || 'BEGIN'||chr(13)
               || '  BLQJ0002.pc_processa_blq_desblq('||pr_idordem||',vr_cdcritic,vr_dscritic);'||chr(13)
               || 'END;';
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'blqj_'||pr_idordem||'$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                          ,pr_cdprogra  => 'BLQJ0002'   --> Código do programa
                          ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva   => NULL          --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro  => vr_dscritic);
    -- Testar saida com erro
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_saida;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa||
                                                     ' Conta: '||pr_nrdconta||
                                                     ' Oficio: '||pr_dsoficio
                                     ,pr_dsincons => vr_operacao||' Solicitacao: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa||
                                                     ' Conta: '||pr_nrdconta||
                                                     ' Oficio: '||pr_dsoficio
                                     ,pr_dsincons => vr_operacao||' Solicitacao: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

  END pc_recebe_blq_desblq;

  -- Efetuar o recebimento das solicitacoes de TED
  PROCEDURE pc_recebe_ted(pr_nrdocnpj_cop         IN crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                         ,pr_nrcpfcnpj            IN crapass.nrcpfcgc%TYPE -- CNPJ / CPF do titular da conta
                         ,pr_tppessoa             IN VARCHAR2 -- Tipo de pessoa (F=Fisica, J=Juridica, R=Raiz do CNPJ)
                         ,pr_tpproduto            IN VARCHAR2 -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                         ,pr_dsoficio             IN tbblqj_ordem_transf.dsoficio%TYPE -- Numero do oficio
                         ,pr_nrdconta             IN crapblj.nrdconta%TYPE -- Numero da conta
                         ,pr_vlordem              IN tbblqj_ordem_transf.vlordem%TYPE -- Valor   
                         ,pr_indbloqueio_saldo    IN tbblqj_ordem_transf.indbloqueio_saldo%TYPE -- Indicador de término de bloqueio de saldo remanescente (0-Não encerra bloqueio, 1-Encerra bloqueio)
                         ,pr_nrcnpj_if_destino    IN tbblqj_ordem_transf.nrcnpj_if_destino%TYPE -- Numero do CNPJ da instituicao financeira de destino
                         ,pr_nrcpfcnpj_favorecido IN tbblqj_ordem_transf.nrcpfcnpj_favorecido%TYPE --  Numero do CPF / CNPJ da conta de destino
                         ,pr_nragencia_if_destino IN tbblqj_ordem_transf.nragencia_if_destino%TYPE -- Codigo da agencia de destino
                         ,pr_nmfavorecido         IN tbblqj_ordem_transf.nmfavorecido%TYPE --  Nome da conta de destino
                         ,pr_tpdeposito           IN tbblqj_ordem_transf.tpdeposito%TYPE -- Indicador de tipo de depósito (T-Tributario, P-Previdenciario, Vazio-Demais) 
                         ,pr_cddeposito           IN tbblqj_ordem_transf.cddeposito%TYPE -- Codigo do deposito (preenchido somente quanto tipo de deposito for T ou P)
                         ,pr_cdtransf_bacenjud    IN tbblqj_ordem_transf.cdtransf_bacenjud%TYPE -- Numero de identificação da transferencia, gerado pelo BACENJUD
                         ,pr_cdcritic            OUT crapcri.cdcritic%TYPE -- Critica encontrada
                         ,pr_dscritic            OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
                                    
                                      
    -- CURSORES
    -- Busca os dados da cooperativa selecionada
    CURSOR cr_crapcop(pr_nrdocnpj crapcop.nrdocnpj%TYPE) IS
      SELECT cdcooper
        FROM crapcop
       WHERE nrdocnpj = pr_nrdocnpj;
        
    -- VARIÁVEIS
    vr_idordem       tbblqj_ordem_online.idordem%TYPE; -- Sequencial do recebimento
    vr_cdcooper      crapcop.cdcooper%TYPE; -- Codigo da cooperativa

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
    vr_des_erro   VARCHAR2(10); --> Retorno com erro ou sucesso
    
    
  BEGIN
    
    -- Busca o codigo da cooperativa
    OPEN cr_crapcop(pr_nrdocnpj_cop);
    FETCH cr_crapcop INTO vr_cdcooper;
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      vr_dscritic := 'CNPJ da cooperativa ('||pr_nrdocnpj_cop||') nao cadastrado como cooperativa!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapcop;
   
    -- Atualiza a Sequence da tabela
    vr_idordem := fn_sequence(pr_nmtabela => 'TBBLQJUD_ORDEM_ONLINE', pr_nmdcampo => 'IDORDEM',pr_dsdchave => '0');

    -- Insere na tabela de solicitacoes do Webjud
    BEGIN
      INSERT INTO tbblqj_ordem_online
        (idordem,
         tpordem,
         cdcooper,
         tppessoa,
--         nrdconta,
         nrcpfcnpj,
         dhrequisicao,
         instatus)
      VALUES
        (vr_idordem,
         4, -- Transferencia
         vr_cdcooper,
         decode(pr_tppessoa,'F',1,
                            'J',2,
                                3),
--         pr_nrdconta,
         pr_nrcpfcnpj,
         SYSDATE,
         1); -- Pendente
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbblqj_ordem_online: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Insere na tabela de solicitacoes de TEDs
    BEGIN
      INSERT INTO tbblqj_ordem_transf
        (idordem,
         nrdconta,
         cdmodali,
         dsoficio,
         vlordem,
         indbloqueio_saldo,
         nrcnpj_if_destino,
         nragencia_if_destino,
         nmfavorecido,
         nrcpfcnpj_favorecido,
         tpdeposito,
         cddeposito,
         cdtransf_bacenjud,
         vltransferido)
       VALUES
        (vr_idordem,
         pr_nrdconta,
         decode(pr_tpproduto,'C',1, -- Conta Corrente
                             'A',2, -- Aplicacao
                                 3),-- Poupanca Programada
         pr_dsoficio,
         pr_vlordem,
         pr_indbloqueio_saldo,
         pr_nrcnpj_if_destino,
         pr_nragencia_if_destino,
         substr(pr_nmfavorecido,1,70),
         pr_nrcpfcnpj_favorecido,
         pr_tpdeposito,
         pr_cddeposito,
         pr_cdtransf_bacenjud,
         0);
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir na tbblqj_ordem_transf: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    -- Confirma a gravacao dos dados
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa||
                                                     ' Conta: '||pr_nrdconta||
                                                     ' Oficio: '||pr_dsoficio
                                     ,pr_dsincons => 'Solicitacao de TED: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Desfaz o que foi feito
      ROLLBACK;
      -- Insere na inconsistencia
      gene0005.pc_gera_inconsistencia(pr_cdcooper => nvl(vr_cdcooper,3)
                                     ,pr_iddgrupo => 1 -- Inconsistencia Bloqueio Judicial
                                     ,pr_tpincons => 2
                                     ,pr_dsregist => ' CPF/CNPJ: '||pr_nrcpfcnpj||
                                                     ' Tipo: '||pr_tppessoa||
                                                     ' Conta: '||pr_nrdconta||
                                                     ' Oficio: '||pr_dsoficio
                                     ,pr_dsincons => 'Solicitacao de TED: '||pr_dscritic
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
      -- Atualiza os dados
      COMMIT;

  END pc_recebe_ted;

  -- Verifica se o processo noturno esta em execucao. Se o PR_NRDOCNPJ_COP vier como 0, verificará se todos os processos acabaram
  PROCEDURE pc_verifica_processo(pr_nrdocnpj_cop         IN crapcop.nrdocnpj%TYPE -- CNPJ da cooperativa
                                ,pr_idretorno           OUT VARCHAR2) IS -- Identifica se o processo esta em execucao (S-Esta em execucao, N-Processo nao esta em execucao)
    -- Cursor para verificar se o processo esta em execucao
    CURSOR cr_crapcop IS
      SELECT MAX(b.inproces) inproces
        FROM crapdat b,
             crapcop a
       WHERE a.nrdocnpj = decode(pr_nrdocnpj_cop,0,a.nrdocnpj,pr_nrdocnpj_cop)
         AND a.flgativo = 1
         AND b.cdcooper = a.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  BEGIN
    -- Verifica se o processo esta em execucao
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    IF cr_crapcop%NOTFOUND THEN
      rw_crapcop.inproces := 2;
    END IF;
    CLOSE cr_crapcop;
    
    -- Efetua o retorno com base na situacao do processo
    IF rw_crapcop.inproces = 1 THEN
      pr_idretorno := 'N';
    ELSE
      pr_idretorno := 'S';
    END IF;
  END;


  -- Efetuar o processamento da solicitacao de consulta de conta
  PROCEDURE pc_processa_solicitacao(pr_idordem   IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                    pr_cdcritic  OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                    pr_dscritic  OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
    -- CURSORES
    -- Busca os dados da solicitacao
    CURSOR cr_solicitacao IS
      SELECT cdcooper,
             nrcpfcnpj,
             tppessoa,
             idordem
        FROM tbblqj_ordem_online
       WHERE idordem = pr_idordem;
    rw_solicitacao cr_solicitacao%ROWTYPE;

    -- VARIÁVEIS
    vr_tpcoperad PLS_INTEGER; -- Tipo de busca que sera feito no cooperado
    vr_nmprimtl crapass.nmprimtl%TYPE; -- Nome do titular da conta
    vr_ind      PLS_INTEGER; -- Indice sobre a tabela de cooperados
    vr_idordem_consulta tbblqj_ordem_consulta.idordem_consulta%TYPE; -- Sequencial do envio 
    
    -- Variaveis Pl/Tables
    vr_tab_cooperado BLQJ0001.typ_tab_cooperado;
    vr_tab_erro      GENE0001.typ_tab_erro;
    vr_tab_saldos    EXTR0001.typ_tab_saldos;

    -- Registro sobre a data do sistema
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN
    -- Busca os dados da solicitacao
    OPEN cr_solicitacao;
    FETCH cr_solicitacao INTO rw_solicitacao;
    IF cr_solicitacao%NOTFOUND THEN
      CLOSE cr_solicitacao;
      vr_dscritic := 'Solicitacao '||pr_idordem||' nao foi encontrada!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_solicitacao;

    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(rw_solicitacao.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Se o tipo de pessoa for Fisica ou Juridica, deve-se passar como parametro 2
    IF rw_solicitacao.tppessoa IN (1,2) THEN
      vr_tpcoperad := 2; -- CPF ou CNPJ
    ELSE
      vr_tpcoperad := 3; -- Raiz do CNPJ
    END IF;
    
    -- Busca os dados do cooperado
    blqj0001.pc_busca_contas_cooperado(pr_cdcooper => rw_solicitacao.cdcooper, 
                                       pr_cdagenci => 1,
                                       pr_nrdcaixa => 1,
                                       pr_cdoperad => 1,
                                       pr_nmdatela => 'BLQJUD',
                                       pr_idorigem => 7, -- Batch
                                       pr_inproces => 1,
                                       pr_cooperad => rw_solicitacao.nrcpfcnpj,
                                       pr_tpcooperad => vr_tpcoperad,
                                       pr_nmprimtl => vr_nmprimtl,
                                       pr_tab_cooperado => vr_tab_cooperado,
                                       pr_tab_erro => vr_tab_erro);

    -- Verifica se ocorreu erro na rotina
    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_saida;
    END IF;
    
    -- Se nao existir registro no retorno, deve-se popular a tabela como nao cliente
    IF vr_tab_cooperado.first IS NULL THEN
      -- Atualiza a Sequence da tabela
      vr_idordem_consulta := fn_sequence(pr_nmtabela => 'TBBLQJ_ORDEM_CONSULTA', pr_nmdcampo => 'IDORDEM_CONSULTA',pr_dsdchave => '0');

      -- Insere na tabela de retornos como nao cliente
      BEGIN
        INSERT INTO tbblqj_ordem_consulta
         (idordem_consulta 
         ,idordem
         ,nrdconta
         ,insituacao)
       VALUES
         (vr_idordem_consulta 
         ,rw_solicitacao.idordem
         ,0
         ,'N');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro insert na tbblqj_ordem_consulta: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
    
    ELSE -- Se tiver retorno

      -- Loop sobre o retorno
      vr_ind := vr_tab_cooperado.first;
      LOOP
        -- Se nao existir registro sai do loop
        EXIT WHEN vr_ind IS NULL;
        
        FOR vr_cdmodali IN 1..3 LOOP

          -- Se o saldo for zerado, nao enviar
          IF (vr_cdmodali = 1 AND vr_tab_cooperado(vr_ind).vlstotal = 0) OR -- Deposito a vista
             (vr_cdmodali = 2 AND vr_tab_cooperado(vr_ind).vlsldapl = 0) OR -- Aplicacao
             (vr_cdmodali = 3 AND vr_tab_cooperado(vr_ind).vlsldppr = 0) THEN -- Poupanca
            -- Se todos os valores forem zerados, enviar somente o deposito a vista
            IF vr_tab_cooperado(vr_ind).vlstotal = 0 AND 
               vr_tab_cooperado(vr_ind).vlsldapl = 0 AND 
               vr_tab_cooperado(vr_ind).vlsldppr = 0 AND
               vr_cdmodali = 1 THEN
              NULL; -- Nao faz nada, pois deve-se enviar pelo menos 1 registro
            ELSE
              continue;
            END IF;
          END IF;

          -- Atualiza a Sequence da tabela
          vr_idordem_consulta := fn_sequence(pr_nmtabela => 'TBBLQJ_ORDEM_CONSULTA', pr_nmdcampo => 'IDORDEM_CONSULTA',pr_dsdchave => '0');

          -- Se a modalidade for conta corrente, entao deve-se subtrair os depositos bloqueados
          IF vr_cdmodali = 1 THEN
            -- Busca os valores de bloqueio
            EXTR0001.pc_obtem_saldos_anteriores(pr_cdcooper   => rw_solicitacao.cdcooper,
                                                pr_cdagenci   => 1,
                                                pr_nrdcaixa   => 1,
                                                pr_cdopecxa   => '1',
                                                pr_nmdatela   => 'BLQJUD',
                                                pr_idorigem   => 1,
                                                pr_nrdconta   => vr_tab_cooperado(vr_ind).nrdconta,
                                                pr_idseqttl   => 1,
                                                pr_dtmvtolt   => rw_crapdat.dtmvtolt,
                                                pr_dtmvtoan   => rw_crapdat.dtmvtoan,
                                                pr_dtrefere   => rw_crapdat.dtmvtoan,
                                                pr_flgerlog   => FALSE,
                                                pr_dscritic   => vr_dscritic,
                                                pr_tab_saldos => vr_tab_saldos,
                                                pr_tab_erro   => vr_tab_erro);
            
            -- Verifica se ocorreu erro na rotina
            IF vr_tab_erro.exists(vr_tab_erro.first) THEN
              vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              RAISE vr_exc_saida;
            END IF;

            -- Se existir tabela de saldos anteriores
            IF vr_tab_saldos.exists(0) THEN
              vr_tab_cooperado(vr_ind).vlstotal := vr_tab_cooperado(vr_ind).vlstotal - 
                            vr_tab_saldos(0).vlsdbloq - 
                            vr_tab_saldos(0).vlsdblpr - 
                            vr_tab_saldos(0).vlsdblfp;
            END IF;
          END IF; -- Fim da validacao da modalidade 1

          -- Insere na tabela de retornos
          BEGIN
            INSERT INTO tbblqj_ordem_consulta
             (idordem_consulta 
             ,idordem
             ,insituacao
             ,nrcpfcnpj  
             ,nrdconta 
             ,nmtitular
             ,cdagenci  
             ,cdmodali 
             ,vlsaldo_disp
             ,dtabertura
             ,nmrua
             ,nrendereco
             ,nmbairro 
             ,nmcidade 
             ,dsuf
             ,nrcep)
            VALUES
             (vr_idordem_consulta 
             ,rw_solicitacao.idordem
             ,decode(vr_tab_cooperado(vr_ind).dtdemiss,NULL,'C','N')
             ,vr_tab_cooperado(vr_ind).nrcpfcgc 
             ,vr_tab_cooperado(vr_ind).nrdconta 
             ,vr_nmprimtl
             ,vr_tab_cooperado(vr_ind).cdagenci
             ,vr_cdmodali
             ,decode(vr_cdmodali,1,vr_tab_cooperado(vr_ind).vlstotal, -- Deposito a vista
                                 2,vr_tab_cooperado(vr_ind).vlsldapl, -- Aplicacao
                                   vr_tab_cooperado(vr_ind).vlsldppr) -- Poupanca Programada
             ,vr_tab_cooperado(vr_ind).dtadmiss 
             ,vr_tab_cooperado(vr_ind).dsendere 
             ,vr_tab_cooperado(vr_ind).nrendere 
             ,vr_tab_cooperado(vr_ind).nmbairro 
             ,vr_tab_cooperado(vr_ind).nmcidade 
             ,vr_tab_cooperado(vr_ind).cdufende
             ,vr_tab_cooperado(vr_ind).nrcepend); --Pendente
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir na tbblqj_ordem_consulta: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
        END LOOP; -- Fim do loop das modalidades
        
        -- Vai para o proximo registro
        vr_ind := vr_tab_cooperado.next(vr_ind);
        
      END LOOP; -- Fim do loop de retornos
      
    END IF; -- Fim da verificacao se teve retorno de cooperado

    -- Coloca o registro de solicitacao como processado com sucesso
    pc_atualiza_situacao(pr_idordem => pr_idordem,
                         pr_instatus => 2); -- Processada
    
    -- Grava as informacoes
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Executa rotina para encerrar o processo com erro
      pc_encerra_processo_erro(pr_idordem => rw_solicitacao.idordem
                              ,pr_cdcooper => rw_solicitacao.cdcooper
                              ,pr_dsinconsit => 'Processamento da Solicitacao: '||pr_dscritic
                              ,pr_dsregistro_referencia => 'Sequencia Recebimento: '||rw_solicitacao.idordem||
                                                           ' Cooperativa: '||rw_solicitacao.cdcooper||
                                                           ' CPF/CNPJ: '||rw_solicitacao.nrcpfcnpj||
                                                           ' Tipo: '||rw_solicitacao.tppessoa);

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_processa_solicitacao: '||sqlerrm;

      pc_encerra_processo_erro(pr_idordem => rw_solicitacao.idordem
                              ,pr_cdcooper => rw_solicitacao.cdcooper
                              ,pr_dsinconsit => 'Processamento da Solicitacao: '||pr_dscritic
                              ,pr_dsregistro_referencia => 'Sequencia Recebimento: '||rw_solicitacao.idordem||
                                                           ' Cooperativa: '||rw_solicitacao.cdcooper||
                                                           ' CPF/CNPJ: '||rw_solicitacao.nrcpfcnpj||
                                                           ' Tipo: '||rw_solicitacao.tppessoa);

  END pc_processa_solicitacao;
  
  -- Efetuar o processamento da solicitacao de bloqueio e desbloqueio
  PROCEDURE pc_processa_blq_desblq(pr_idordem IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                   pr_cdcritic      OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                   pr_dscritic      OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
    -- CURSORES
    -- Busca os dados da solicitacao
    CURSOR cr_solicitacao IS
      SELECT a.cdmodali, 
             a.dsoficio, 
             a.nrdconta, 
             b.tpordem,
             a.vlordem,
             a.dsprocesso, 
             a.nmjuiz,
             b.cdcooper
        FROM tbblqj_ordem_online b,
             tbblqj_ordem_bloq_desbloq a
       WHERE a.idordem = pr_idordem
         AND b.idordem = a.idordem;
    rw_solicitacao cr_solicitacao%ROWTYPE;

    -- VARIÁVEIS
    vr_operacao VARCHAR2(11); -- Tipo de operacao
    
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN
    -- Busca os dados da solicitacao
    OPEN cr_solicitacao;
    FETCH cr_solicitacao INTO rw_solicitacao;
    IF cr_solicitacao%NOTFOUND THEN
      CLOSE cr_solicitacao;
      vr_dscritic := 'Solicitacao '||pr_idordem||' nao foi encontrada!';
      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_solicitacao;

    -- Define a operacao que esta sendo realizada
    IF rw_solicitacao.tpordem = 2 THEN
      vr_operacao := 'Bloqueio';
    ELSE
      vr_operacao := 'Desbloqueio';
    END IF;
    
    -- Efetua as validacoes para as operacoes especificas  
    IF rw_solicitacao.tpordem = 2 THEN -- Se for um bloqueio
      -- Efetua o bloqueio
      pc_bloqueio(pr_cdcooper => rw_solicitacao.cdcooper,
                  pr_nrdconta => rw_solicitacao.nrdconta,
                  pr_cdmodali => rw_solicitacao.cdmodali,
                  pr_nroficio => rw_solicitacao.dsoficio,
                  pr_nrproces => rw_solicitacao.dsprocesso,
                  pr_dsjuizem => rw_solicitacao.nmjuiz,
                  pr_dsresord => 'BACENJUD ATE R$ '||to_char(rw_solicitacao.vlordem,'fm999G999G990D00'),
                  pr_vlbloque => rw_solicitacao.vlordem,
                  pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
    ELSE -- Processo de desbloqueio

      -- Efetua o desbloqueio
      pc_desbloqueio(pr_cdcooper => rw_solicitacao.cdcooper,
                     pr_nrdconta => rw_solicitacao.nrdconta,
                     pr_cdmodali => rw_solicitacao.cdmodali,
                     pr_nroficio => rw_solicitacao.dsoficio,
                     pr_nrproces => rw_solicitacao.dsprocesso,
                     pr_dsjuizem => rw_solicitacao.nmjuiz,
                     pr_fldestrf => 0, -- Nao eh desbloqueio para transferencia
                     pr_vlbloque => rw_solicitacao.vlordem,
                     pr_dscritic => vr_dscritic);
      -- Verifica se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

    END IF;
    
    -- Atualiza na tabela de bloqueios
    BEGIN
      UPDATE tbblqj_ordem_bloq_desbloq
         SET vloperacao = rw_solicitacao.vlordem
       WHERE idordem = pr_idordem;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar na tbblqj_ordem_bloq_desbloq: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
                
    -- Coloca o registro de solicitacao como processado com sucesso
    pc_atualiza_situacao(pr_idordem => pr_idordem,
                         pr_instatus => 2);
    
    -- Grava as informacoes
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      
      -- Executa rotina para encerrar o processo com erro
      pc_encerra_processo_erro(pr_idordem => pr_idordem
                              ,pr_cdcooper => rw_solicitacao.cdcooper
                              ,pr_dsinconsit => 'Processamento do '||vr_operacao||': '||pr_dscritic
                              ,pr_dsregistro_referencia => 'Sequencia Recebimento: '||pr_idordem||
                                              ' Conta: '||rw_solicitacao.nrdconta||
                                              ' Oficio: '||rw_solicitacao.dsoficio);

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_processa_blq_desbloq: '||sqlerrm;

      pc_encerra_processo_erro(pr_idordem => pr_idordem
                              ,pr_cdcooper => rw_solicitacao.cdcooper
                              ,pr_dsinconsit => 'Processamento do Bloqueio/Desbloqueio: '||pr_dscritic
                              ,pr_dsregistro_referencia => 'Sequencia Recebimento: '||pr_idordem||
                                              ' Conta: '||rw_solicitacao.nrdconta||
                                              ' Oficio: '||rw_solicitacao.dsoficio);

  END pc_processa_blq_desblq;

  -- Efetuar o processamento da ted
  PROCEDURE pc_processa_ted(pr_cdcritic OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                            pr_dscritic OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
    -- Busca as ordens pendentes
    CURSOR cr_solicitacao IS
      SELECT a.idordem,
             a.cdcooper,
             a.nrcpfcnpj,
             b.nrdconta,
             a.tppessoa,
             b.cdmodali,
             decode(b.cdmodali,1,'Conta Corrente',
                               2,'Aplicacao',
                                 'Poupanca Programada') dsmodali,
             b.dsoficio,
             b.vlordem,
             b.indbloqueio_saldo,
             b.nrcnpj_if_destino,
             b.nragencia_if_destino,
             substr(b.nmfavorecido,1,60) nmfavorecido,
             b.nrcpfcnpj_favorecido,
             b.tpdeposito,
             b.cddeposito,
             b.cdtransf_bacenjud,
             COUNT(1) OVER (PARTITION BY a.cdcooper,
                                         a.nrcpfcnpj,
										 b.nrdconta, -- Heitor
                                         b.dsoficio) qtreg,
             ROW_NUMBER() OVER (PARTITION BY a.cdcooper,
                                             a.nrcpfcnpj,
                                             b.nrdconta, 
                                             b.dsoficio
                                    ORDER BY a.cdcooper,
                                             a.nrcpfcnpj,
                                             b.nrdconta, 
                                             b.dsoficio) nrreg
                                             
        FROM tbblqj_ordem_transf b,
             tbblqj_ordem_online a
       WHERE a.tpordem = 4 -- Ted
         AND a.instatus = 1 -- Pendente
		 AND b.idordem = a.idordem
         AND a.dhrequisicao < trunc(SYSDATE) -- Somente buscar as do dia anterior,
                                   -- pois as teds estavam sendo devolvidas (problema com a Caixa Economica)         AND b.idordem = a.idordem
         ORDER BY a.cdcooper,
             a.nrcpfcnpj,
             b.nrdconta, 
             b.dsoficio;
      
    -- Verifica os bloqueios que possuirao a transferencia
    CURSOR cr_crapblj(pr_cdcooper crapblj.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nroficio crapblj.nroficio%TYPE,
                      pr_cdmodali crapblj.cdmodali%TYPE) IS
      SELECT nrdconta,
             nroficio,
             nrproces,
             vlbloque,
             dsjuizem
        FROM crapblj a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.cdmodali = pr_cdmodali
         AND a.nroficio LIKE pr_nroficio||'%'
         AND a.dtblqfim IS NULL; -- Que nao esteja finalizada
    rw_crapblj cr_crapblj%ROWTYPE;

    -- Cursor para buscar o codigo do banco
    CURSOR cr_crapagb(pr_nrcnpjag crapagb.nrcnpjag%TYPE,
                      pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT a.cddbanco,
             b.nrispbif
        FROM crapban b,
             crapagb a
       WHERE substr(lpad(a.nrcnpjag,14,'0'),1,8) = substr(lpad(pr_nrcnpjag,14,'0'),1,8)
         AND a.cdageban = pr_cdageban
         AND b.cdbccxlt = a.cddbanco;
    rw_crapagb cr_crapagb%ROWTYPE;
    
    -- Cursor para buscar as contas de origem para gerar as TEDs
    CURSOR cr_ted IS
      SELECT a.cdcooper,
             a.nrcpfcnpj,
             b.nrdconta, 
             b.dsoficio,
             b.nrcnpj_if_destino,
             b.nragencia_if_destino,
             b.nrcpfcnpj_favorecido,
             b.cdtransf_bacenjud,
             b.nmfavorecido,
             SUM(b.vlordem) vllanmto
        FROM tbblqj_ordem_transf b,
             tbblqj_ordem_online a
       WHERE a.instatus  = 5 -- Processada, porem sem TED gerada
         AND b.idordem   = a.idordem
       GROUP BY a.cdcooper,
             a.nrcpfcnpj,
             b.nrdconta,
             b.nrcnpj_if_destino, 
             b.nragencia_if_destino,
             b.nrcpfcnpj_favorecido,
             b.cdtransf_bacenjud,
             b.nmfavorecido,
             b.dsoficio;

    -- Cursor sobre os registros com erros
    CURSOR cr_ted_erro IS
      SELECT a.idordem,
             a.cdcooper,
             a.nrcpfcnpj,
             b.dsoficio,
             decode(b.cdmodali,1,'Conta Corrente',
                               2,'Aplicacao',
                                 'Poupanca Programada') dsmodali,
             b.vlordem,
             b.cdtransf_bacenjud
        FROM tbblqj_ordem_transf b,
             tbblqj_ordem_online a
       WHERE a.instatus  = 5 -- Processada, porem sem TED gerada
         AND b.idordem   = a.idordem;

    
    -- Registro sobre a data do sistema
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    -- VARIÁVEIS
    vr_vldesbloqueio tbblqj_ordem_transf.vlordem%TYPE; -- Valor a ser desbloqueado
    vr_vlresgate tbblqj_ordem_transf.vlordem%TYPE; -- Valor a ser resgatado

    vr_inpessoa crapass.inpessoa%TYPE; -- Indicador de tipo de pessoa do destinatario
    vr_dsprotoc crappro.dsprotoc%TYPE; -- Numero do protocolo de retorno
    vr_tab_protocolo_ted cxon0020.typ_tab_protocolo_ted; -- Tabela de retorno das teds
    vr_dsinconsist tbgen_inconsist.dsinconsist%TYPE; -- Descricao do registro que esta sendo processado
    vr_cdcooper crapcop.cdcooper%TYPE; -- Codigo da Cooperativa
    vr_idordem  tbblqj_ordem_online.idordem%TYPE; -- Sequencial do processo

    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN

    -- Busca os dados da solicitacao
    FOR rw_solicitacao IN cr_solicitacao LOOP

      BEGIN
        -- Se mudou a cooperativa
        IF nvl(vr_cdcooper,0) <> rw_solicitacao.cdcooper THEN
          -- Busca a data do sistema
          OPEN btch0001.cr_crapdat(rw_solicitacao.cdcooper);
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;
        END IF;    

        -- Atualiza o registro de inconsistencia caso ocorrer algum erro
        vr_cdcooper := rw_solicitacao.cdcooper;
        vr_idordem := rw_solicitacao.idordem;
        vr_dsinconsist := 'Sequencia: '||rw_solicitacao.idordem||
                          ' Cpf/Cnpj: '||rw_solicitacao.nrcpfcnpj||
                          ' Conta: '||rw_solicitacao.nrdconta||
                          ' Oficio: '||rw_solicitacao.dsoficio||
                          ' Modalidade: '||rw_solicitacao.dsmodali||
                          ' Valor: '||to_char(rw_solicitacao.vlordem,'FM999G999G990D00')||
                          ' Id.Deposito: '||rw_solicitacao.cdtransf_bacenjud;

        -- Busca o banco de destino
        OPEN cr_crapagb(pr_nrcnpjag => rw_solicitacao.nrcnpj_if_destino,
                        pr_cdageban => rw_solicitacao.nragencia_if_destino);
        FETCH cr_crapagb INTO rw_crapagb;
        IF cr_crapagb%NOTFOUND THEN 
          CLOSE cr_crapagb;
          vr_dscritic := 'Agencia '|| rw_solicitacao.nragencia_if_destino||
           ' nao encontrada para o CNPJ da IF de destino (CNPJ '||rw_solicitacao.nrcnpj_if_destino||').';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapagb;
               
        -- Busca o bloqueio, pois para fazer a transferencia o valor
        -- devera estar bloqueado antes
        OPEN cr_crapblj(pr_cdcooper => rw_solicitacao.cdcooper,
                        pr_nrdconta => rw_solicitacao.nrdconta,
                        pr_nroficio => rw_solicitacao.dsoficio,
                        pr_cdmodali => rw_solicitacao.cdmodali);
        FETCH cr_crapblj INTO rw_crapblj;
        
        -- se nao encontrar bloqueio gera inconsistencia
        IF cr_crapblj%NOTFOUND THEN
          CLOSE cr_crapblj;                        
          vr_dscritic := 'Nao foi encontrado bloqueios para o valor solicitado';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapblj;                        

        -- Verifica se o valor a transferir eh superior ao saldo bloqueado
        IF rw_solicitacao.vlordem > rw_crapblj.vlbloque THEN
          vr_dscritic := 'Valor a transferir ('||to_char(rw_solicitacao.vlordem,'FM999G999G990D00') ||
                         ' superior ao valor bloqueado ('||to_char(rw_crapblj.vlbloque,'FM999G999G990D00');
          RAISE vr_exc_saida;
        END IF;                       
          
        -- verifica se o que esta bloqueado eh maior que o saldo
        IF rw_crapblj.vlbloque >= rw_solicitacao.vlordem THEN
          -- Utiliza o valor do da ordem para ser desbloqueado
          vr_vlresgate := rw_solicitacao.vlordem;
        ELSE
          -- Utiliza o valor total do bloqueio para o desbloqueio
          vr_vlresgate := rw_crapblj.vlbloque;
        END IF;
          
        -- Atualiza o valor do desbloqueio com o valor do resgate
        IF rw_solicitacao.indbloqueio_saldo = 1 THEN -- Encerra o bloqueio total
          -- Atualiza o valor do desbloqueio com o valor total bloqueado
          vr_vldesbloqueio := rw_crapblj.vlbloque;
        ELSE
          -- Atualiza o valor de desbloqueio somente com o valor que sera utilizado
          vr_vldesbloqueio := vr_vlresgate;
        END IF;
          
          
        -- Desbloquear o valor para permitir fazer a transferencia
        pc_desbloqueio(pr_cdcooper => rw_solicitacao.cdcooper,
                       pr_nrdconta => rw_crapblj.nrdconta,
                       pr_cdmodali => rw_solicitacao.cdmodali,
                       pr_nroficio => rw_crapblj.nroficio,
                       pr_nrproces => rw_crapblj.nrproces,
                       pr_dsjuizem => rw_crapblj.dsjuizem,
                       pr_fldestrf => 1, -- Eh desbloqueio para transferencia
                       pr_vlbloque => vr_vldesbloqueio,
                       pr_dscritic => vr_dscritic);
                         
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Se for uma aplicacao, deve-se efetuar o resgate
        IF rw_solicitacao.cdmodali = 2 THEN
          pc_resgata_aplicacao(pr_cdcooper => rw_solicitacao.cdcooper,
                               pr_nrdconta => rw_crapblj.nrdconta,
                               pr_vlresgat => vr_vlresgate,
                               pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        ELSIF rw_solicitacao.cdmodali = 3 THEN -- Se for Poupanca Programada
          -- Solicita o resgate
          pc_resgata_poupanca_programa(pr_cdcooper => rw_solicitacao.cdcooper,
                                       pr_nrdconta => rw_crapblj.nrdconta,
                                       pr_vlresgat => vr_vlresgate,
                                       pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;        
        END IF;

        -- Coloca o registro de solicitacao como processado com sucesso
        pc_atualiza_situacao(pr_idordem => rw_solicitacao.idordem,
                             pr_instatus => 5); -- Processada, mas nao finalizada

        -- Grava os desbloqueios
        COMMIT;

      EXCEPTION
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
               
          -- Executa rotina para encerrar o processo com erro
          pc_encerra_processo_erro(pr_idordem => vr_idordem
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_dsinconsit => 'Processamento da TED: '||vr_dscritic
                                  ,pr_dsregistro_referencia => vr_dsinconsist);

          -- Limpa a critica
          vr_dscritic := NULL;

        WHEN OTHERS THEN
          -- Efetuar retorno do erro não tratado
          vr_dscritic := 'Erro BLQJ0002.pc_processa_ted: '||sqlerrm;

          pc_encerra_processo_erro(pr_idordem => vr_idordem
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_dsinconsit => 'Processamento TED: '||vr_dscritic
                                  ,pr_dsregistro_referencia => vr_dsinconsist);
          -- Limpa a critica
          vr_dscritic := NULL;
      END;
      
      -- Se for o ultimo registro da conta / oficio, envia a TED
      -- Isso se faz necessario para envio unico com a somatoria dos valores
      IF rw_solicitacao.qtreg = rw_solicitacao.nrreg THEN
        BEGIN
          -- Efetua loop sobre as contas a enviar
          FOR rw_ted IN cr_ted LOOP
            -- Busca o banco de destino
            OPEN cr_crapagb(pr_nrcnpjag => rw_ted.nrcnpj_if_destino,
                            pr_cdageban => rw_ted.nragencia_if_destino);
            FETCH cr_crapagb INTO rw_crapagb;
            IF cr_crapagb%NOTFOUND THEN 
              CLOSE cr_crapagb;
              vr_dscritic := 'Agencia '|| rw_solicitacao.nragencia_if_destino||
               ' nao encontrada para o CNPJ da IF de destino (CNPJ '||rw_solicitacao.nrcnpj_if_destino||').';
              RAISE vr_exc_saida;
            END IF;
            CLOSE cr_crapagb;

            -- Defino o tipo de pessoa do destinatario.
            -- Como nao recebemos o tipo de pessoa da origem, utilizaremos a regra de 
            --   tamanho do campo
            IF length(rw_ted.nrcpfcnpj_favorecido) > 11 THEN
              vr_inpessoa := 2; -- CNPJ
            ELSE
              vr_inpessoa := 1; -- CPF
            END IF;

            -- Efetua a TED
            cxon0020.pc_executa_envio_ted(
                                 pr_cdcooper => rw_ted.cdcooper  --> Cooperativa    
                                ,pr_cdagenci => 1  --> Agencia
                                ,pr_nrdcaixa => 900  --> Caixa Operador    
                                ,pr_cdoperad => '1'  --> Operador Autorizacao
                                ,pr_idorigem => 1 -- Alterado por Andrino para ajuste no LOGSPB 7 --Batch --> Origem                 
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento
                                ,pr_nrdconta => rw_ted.nrdconta  --> Conta Remetente        
                                ,pr_idseqttl => 1  --> Titular                
                                ,pr_nrcpfope => 0  --> CPF operador juridico
                                ,pr_cddbanco => rw_crapagb.cddbanco --> Banco destino
                                ,pr_cdageban => rw_ted.nragencia_if_destino  --> Agencia destino
                                ,pr_nrctatrf => rw_ted.cdtransf_bacenjud  --> Conta transferencia. Neste caso sera enviado o codigo de transferencia do Bacenjud
                                ,pr_nmtitula => rw_ted.nmfavorecido --> nome do titular destino
                                ,pr_nrcpfcgc => nvl(rw_ted.nrcpfcnpj_favorecido,0)  --> CPF do titular destino
                                ,pr_inpessoa => vr_inpessoa --> Tipo de pessoa
                                ,pr_intipcta => 9 -- Deposito judicial --> Tipo de conta
                                ,pr_vllanmto => rw_ted.vllanmto --> Valor do lançamento
                                ,pr_dstransf => 'Transferencia Judicial' --> Identificacao Transf.
                                ,pr_cdfinali => 100 -- Deposito Judicial --> Finalidade TED
                                ,pr_dshistor => 'Transferencia judicial' --> Descriçao do Histórico
                                ,pr_cdispbif => rw_crapagb.nrispbif             --> ISPB Banco Favorecido
                                ,pr_idagenda => 1 --> Tipo de agendamento
                                -- saida
                                ,pr_dsprotoc => vr_dsprotoc --> Retorna protocolo    
                                ,pr_tab_protocolo_ted => vr_tab_protocolo_ted --> dados do protocolo
                                ,pr_cdcritic => vr_cdcritic  --> Codigo do erro
                                ,pr_dscritic => vr_dscritic); --> Descricao do erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          
          END LOOP; -- Fim dos loop das TEDs a enviar
        EXCEPTION
          WHEN vr_exc_saida THEN
            -- Desfaz o que foi feito ate o momento
            ROLLBACK;
            
            -- Loop sobre os lancamentos processados
            FOR rw_ted_erro IN cr_ted_erro LOOP

              vr_dsinconsist := 'Sequencia: '||rw_ted_erro.idordem||
                                ' Cpf/Cnpj: '||rw_ted_erro.nrcpfcnpj||
                                ' Oficio: '||rw_ted_erro.dsoficio||
                                ' Modalidade: '||rw_ted_erro.dsmodali||
                                ' Valor: '||to_char(rw_ted_erro.vlordem,'FM999G999G990D00')||
                                ' Id.Deposito: '||rw_ted_erro.cdtransf_bacenjud;

              -- Executa rotina para encerrar o processo com erro
              pc_encerra_processo_erro(pr_idordem => rw_ted_erro.idordem
                                  ,pr_cdcooper => rw_ted_erro.cdcooper
                                  ,pr_dsinconsit => 'Envio da TED: '||vr_dscritic
                                  ,pr_dsregistro_referencia => vr_dsinconsist);
            END LOOP;
            
        END;
                
        -- Coloca os registros como processados
        BEGIN
          UPDATE tbblqj_ordem_online
             SET instatus = 2, -- Processada
                 dhresposta = SYSDATE
           WHERE instatus = 5; -- Teds Processadas
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tbblqj_ordem_online: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Grava o que foi feito ate o momento
        COMMIT;
        
      END IF; -- Fim da validacao de ultima conta/oficio
      
      -- Limpa as variaveis de critica
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    
    END LOOP; -- Loop sobre as solicitacoes
    
    -- Grava as informacoes
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_processa_ted: '||sqlerrm;

      pc_encerra_processo_erro(pr_idordem => 0
                              ,pr_cdcooper => 3
                              ,pr_dsinconsit => 'Processamento TED: '||pr_dscritic
                              ,pr_dsregistro_referencia => 'Erro Geral da rotina');
    
  END;


  -- Efetuar a devolucao dos dados de uma solicitacao
  PROCEDURE pc_devolve_solicitacao(pr_idordem  IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                   pr_xml      OUT xmltype, -- XML com os dados de retorno
                                   pr_cdcritic OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                   pr_dscritic OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
    -- CURSORES
    -- Busca os dados do retorno da solicitacao
    CURSOR cr_retorno IS
      SELECT b.idordem,
             b.cdcooper, 
             a.insituacao, 
             a.nrcpfcnpj,
             a.nrdconta, 
             a.cdagenci, 
             a.nmtitular, 
             decode(a.cdmodali,1,'C',   -- Conta Corrente
                               2,'A',   -- Aplicacao Financeira
                                 'P') cdmodali, -- Poupanca
             a.vlsaldo_disp,
             a.dtabertura, 
             a.nmrua, 
             a.nrendereco, 
             a.nmbairro, 
             a.nmcidade, 
             a.dsuf,
             a.nrcep
        FROM tbblqj_ordem_online b,
             tbblqj_ordem_consulta a
       WHERE a.idordem = pr_idordem
         AND a.idordem = b.idordem
         AND b.instatus IN (2,3); -- 2=Processada ou 3=Enviada ok

    -- Busca os dados da solicitacao
    CURSOR cr_solicitacao IS
      SELECT dslog_erro
        FROM tbblqj_ordem_online
       WHERE idordem = pr_idordem
         AND instatus = 4; -- Que ocorreu erro
    rw_solicitacao cr_solicitacao%ROWTYPE;

    -- Busca o cnpj da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT nrdocnpj
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- VARIÁVEIS
    vr_xml            CLOB;             --> XML do retorno
    vr_texto_completo VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN

    -- Inicializar as informações do XML de dados para o relatório
    dbms_lob.createtemporary(vr_xml, TRUE, dbms_lob.CALL);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><InformacoesContas><contas>'||chr(13));

    -- Loop sobre os retornos da solicitacao
    FOR rw_retorno IN cr_retorno LOOP
    
      -- Busca o CNPJ da cooperativa
      OPEN cr_crapcop(rw_retorno.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
    
      -- Popula a linha de detalhes
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
           '<conta>'||chr(13)||
             '<cnpj_cooperativa>'||rw_crapcop.nrdocnpj||'</cnpj_cooperativa>'||chr(13)||
             '<insituacao>'||rw_retorno.insituacao||'</insituacao>'||chr(13));
      
      -- Se possuir informacoes, envia todos os dados. Nao deve enviar quando o CPF/CNPJ nao eh da coopearativa
      IF rw_retorno.nrcpfcnpj IS NOT NULL THEN
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
             '<nrcpfcnpj>'||rw_retorno.nrcpfcnpj||'</nrcpfcnpj>'||chr(13)||
             '<nrdconta>'||rw_retorno.nrdconta||'</nrdconta>'||chr(13)||
             '<cdagenci>'||rw_retorno.cdagenci||'</cdagenci>'||chr(13)||
             '<nmtitular>'||rw_retorno.nmtitular||'</nmtitular>'||chr(13)||
             '<vlsddisp>'||to_char(rw_retorno.vlsaldo_disp,'99999999999990D00','NLS_NUMERIC_CHARACTERS=''.,''')||'</vlsddisp>'||chr(13)||
             '<dtinicio>'||to_char(rw_retorno.dtabertura,'dd/mm/yyyy')||'</dtinicio>'||chr(13)||
             '<dsendere>'||rw_retorno.nmrua||'</dsendere>'||chr(13)||
             '<nrendere>'||rw_retorno.nrendereco||'</nrendere>'||chr(13)||
             '<nmbairro>'||rw_retorno.nmbairro||'</nmbairro>'||chr(13)||
             '<nmcidade>'||rw_retorno.nmcidade||'</nmcidade>'||chr(13)||
             '<cdufende>'||rw_retorno.dsuf||'</cdufende>'||chr(13)||
             '<nrcepend>'||rw_retorno.nrcep||'</nrcepend>'||chr(13)||
             '<tpproduto>'||rw_retorno.cdmodali||'</tpproduto>'||chr(13));
      END IF;

      -- Finaliza o nó
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
         '</conta>'||chr(13));

      -- Coloca como enviado o retorno
      pc_atualiza_situacao(pr_idordem => rw_retorno.idordem,
                           pr_instatus => 3); -- Enviado Ok

    END LOOP;

    -- Verifica se nao entrou no loop
    IF rw_crapcop.nrdocnpj IS NULL THEN
      -- Se nao entrou, deve-se verificar se houve erro no processo
      OPEN cr_solicitacao;
      FETCH cr_solicitacao INTO rw_solicitacao;
      
      -- Se nao encontrou erro, eh que nao foi processado ainda. Neste caso retorna 
      -- como situacao pendente
      IF cr_solicitacao%NOTFOUND THEN
        -- Devolve o retorno
        gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
               '</contas><retorno>PENDENTE</retorno></InformacoesContas>',TRUE);
      ELSE
        pr_dscritic := rw_solicitacao.dslog_erro;
      END IF;       
      CLOSE cr_solicitacao;
    ELSE
      -- Cria o no de retorno com OK
      gene0002.pc_escreve_xml(vr_xml, vr_texto_completo, 
                 '</contas><retorno>OK</retorno></InformacoesContas>',TRUE);
      
    END IF;
       
    -- Se nao ocorreu erro, devolve o XML        
    IF pr_dscritic IS NULL THEN
      -- Converte o CLOB para o XML de retorno
      pr_xml := XMLType.createxml(vr_xml);
    END IF;

    -- Grava as informacoes
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Retorna as informacoes
      ROLLBACK;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Retorna as informacoes
      ROLLBACK;
    
  END;
  
  -- Efetuar a devolucao dos dados de um bloqueio / desbloqueio
  PROCEDURE pc_devolve_blq_desblq(pr_idordem    IN  tbblqj_ordem_online.idordem%TYPE, -- Sequencial do recebimento
                                  pr_nrcnpjcop  OUT crapcop.nrdocnpj%TYPE, -- CNPJ da Cooperativa
                                  pr_nrcpfcnpj  OUT tbblqj_ordem_online.nrcpfcnpj%TYPE, -- CPF / CNPJ do reu
                                  pr_tpproduto  OUT VARCHAR2, -- Tipo de Produto (C=Conta Corrente, P=Poupanca, A=Aplicacao)
                                  pr_nrdconta   OUT tbblqj_ordem_bloq_desbloq.nrdconta%TYPE, -- Numero da conta
                                  pr_cdagenci   OUT tbblqj_ordem_bloq_desbloq.cdagenci%TYPE, -- Codigo da agencia
                                  pr_vlbloqueio OUT tbblqj_ordem_bloq_desbloq.vloperacao%TYPE, -- Valor de bloqueio
                                  pr_dhbloqueio OUT DATE, -- Data e hora do bloqueio
                                  pr_inbloqueio OUT PLS_INTEGER, -- Indicador de bloqueio (0-Sem retorno, 1-Processo OK, 2-Processo com Erro)
                                  pr_cdcritic   OUT crapcri.cdcritic%TYPE, -- Critica encontrada
                                  pr_dscritic   OUT VARCHAR2) IS           -- Texto de erro/critica encontrada
    -- CURSORES
    -- Busca os dados do retorno do bloqueio / desbloqueio
    CURSOR cr_retorno IS
      SELECT a.idordem,
             b.cdcooper, 
             b.nrcpfcnpj, 
             a.nrdconta, 
             a.cdagenci, 
             decode(a.cdmodali,1,'C',   -- Conta Corrente
                             2,'A',   -- Aplicacao Financeira
                               'P') cdmodali, -- Poupanca
             a.vloperacao,
             b.dhresposta,
             b.instatus
        FROM tbblqj_ordem_online b,
             tbblqj_ordem_bloq_desbloq a
       WHERE a.idordem = pr_idordem
         AND b.idordem = a.idordem;
    rw_retorno cr_retorno%ROWTYPE;

    -- Busca os dados da solicitacao de bloqueio / desbloqueio
    CURSOR cr_solicitacao(pr_instatus tbblqj_ordem_online.instatus%TYPE) IS
      SELECT dslog_erro,
             tpordem
        FROM tbblqj_ordem_online
       WHERE idordem = pr_idordem
         AND instatus = nvl(pr_instatus, instatus);
    rw_solicitacao cr_solicitacao%ROWTYPE;

    -- Busca o cnpj da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT nrdocnpj
        FROM crapcop
       WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- VARIÁVEIS
    vr_xml            CLOB;             --> XML do retorno
    vr_texto_completo VARCHAR2(32600);  --> Variável para armazenar os dados do XML antes de incluir no CLOB
    
    -- Variaveis de erro
    vr_cdcritic   PLS_INTEGER; --> codigo retorno de erro
    vr_dscritic   VARCHAR2(4000); --> descricao do erro
    vr_exc_saida  EXCEPTION; --> Excecao prevista
  BEGIN

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_xml, vr_texto_completo,'<?xml version="1.0" encoding="utf-8"?><contas>'||chr(13));

    -- Busca o retorno do bloqueio / desbloqueio
    OPEN cr_retorno;
    FETCH cr_retorno INTO rw_retorno;
    
    -- Se nao tiver registros, verifica se ocorreu erro
    IF cr_retorno%NOTFOUND THEN
      -- Abre os dados da solicitacao
      OPEN cr_solicitacao(pr_instatus => NULL); -- Buscar todos
      FETCH cr_solicitacao INTO rw_solicitacao;

      -- Verifica a situacao do ticket
      IF cr_solicitacao%NOTFOUND THEN
        pr_dscritic := 'Ticket informado inexistente';
      ELSIF rw_solicitacao.tpordem = 1 THEN
        pr_dscritic := 'Ticket informado refere-se a uma solicitacao de consulta';
      ELSIF rw_solicitacao.tpordem = 4 THEN
        pr_dscritic := 'Ticket informado refere-se a uma solicitacao de transferencia';
      ELSE
        pr_dscritic := 'Ticket invalido';
      END IF;  
      
      -- Fecha cursor
      CLOSE cr_solicitacao;
      
    ELSIF rw_retorno.instatus NOT IN (2,3) THEN -- 2=Processada ou 3=Enviada ok
      -- Deve-se verificar se houve erro no processo
      OPEN cr_solicitacao(pr_instatus => 4); -- Que ocorreu erro
      FETCH cr_solicitacao INTO rw_solicitacao;
      
      -- Se nao encontrou erro, eh que nao foi processado ainda. Neste caso retorna 
      -- como situacao pendente
      IF cr_solicitacao%NOTFOUND THEN
        pr_inbloqueio := 0; -- Pendente
      ELSE -- Se encontrou erro
        pr_inbloqueio := 2; -- Erro
        pr_dscritic := rw_solicitacao.dslog_erro;
      END IF;
      
      -- Fecha o cursor
      CLOSE cr_solicitacao;
    ELSE
    
      -- Busca o CNPJ da cooperativa
      OPEN cr_crapcop(rw_retorno.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
    
      -- Popula as variaveis de retorno
      pr_nrcnpjcop  := rw_crapcop.nrdocnpj;
      pr_nrcpfcnpj  := rw_retorno.nrcpfcnpj;
      pr_tpproduto  := rw_retorno.cdmodali;
      pr_nrdconta   := rw_retorno.nrdconta;
      pr_cdagenci   := rw_retorno.cdagenci;
      pr_vlbloqueio := rw_retorno.vloperacao;
      pr_dhbloqueio := rw_retorno.dhresposta;
      pr_inbloqueio := 1; -- Sucesso

      -- Coloca como enviado o retorno
      pc_atualiza_situacao(pr_idordem => pr_idordem,
                           pr_instatus => 3);

    END IF;
    
    -- Fecha o cursor
    CLOSE cr_retorno;
    
    -- Grava as informacoes
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
           
      -- Retorna as informacoes
      ROLLBACK;

      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := 'Erro BLQJ0002.pc_recebe_solicitacao: '||sqlerrm;

      -- Retorna as informacoes
      ROLLBACK;
    
  END;
    
  
END BLQJ0002;
/
