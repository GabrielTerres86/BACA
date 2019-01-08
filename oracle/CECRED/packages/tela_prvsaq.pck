CREATE OR REPLACE PACKAGE CECRED.tela_prvsaq IS

PROCEDURE pc_alterar_provisao(pr_cdcooper         IN tbcc_provisao_especie.cdcooper%TYPE      -->CODIGO COOPER
                             ,pr_dhsaqueori       IN VARCHAR2                                 --> DATA HORA SAQUE;PAGAMENTO
                             ,pr_nrcpfcnpjori     IN tbcc_provisao_especie.nrcpfcgc%TYPE      --> CPF CNPJ
                             ,pr_nrdcontaori      IN tbcc_provisao_especie.nrdconta%TYPE      --> CONTA
                             ,pr_dtsaqpagtoalt    IN VARCHAR2                                 --> DATA PAGTO ALTERADA
                             ,pr_vlsaqpagtoalt    IN tbcc_provisao_especie.vlsaque%TYPE       --> VL PAGAMENTO ALTERADO
                             ,pr_tpsituacaoalt    IN tbcc_provisao_especie.insit_provisao%TYPE--> TIPO SITUACAO
                             ,pr_ind_grava        IN NUMBER                                   --> INDICA QUE A PRIVSAO DEVE SER CADASTRADA INDEPENDETE DE REGRAS.
                             ,pr_cdope_autorizador IN crapope.cdoperad%TYPE                   --> Código do operador que autorizou a provisão -- Marcelo Telles Coelho - Projeto 420 - PLD
                             ,pr_dsprotocolo      IN tbcc_provisao_especie.dsprotocolo%TYPE   --> Protocolo da provisao. PRJ 420 - Mateus Z
                             ,pr_xmllog           IN VARCHAR2                                 --> XML com informações de LOG
                             ,pr_cdcritic         OUT PLS_INTEGER                             --> Código da crítica
                             ,pr_dscritic         OUT VARCHAR2                                --> Descrição da crítica
                             ,pr_retxml           IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                             ,pr_nmdcampo         OUT VARCHAR2                                --> Nome do campo com erro
                             ,pr_des_erro         OUT VARCHAR2);                                                   --> Erros do processo

PROCEDURE pc_consultar_provisao(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE           --> codigo da cooperativa
                                ,pr_nrdconta       IN tbcc_provisao_especie.nrdconta%TYPE           --> Número da conta do cooperado
                                ,pr_cdcoptel       IN VARCHAR2                                      --> Codigo da cooperativa escolhida pela cecred
                                ,pr_peri_ini       IN VARCHAR2                                      --> DATA INICIAL
                                ,pr_peri_fim       IN VARCHAR2                                      --> DATA FINAL
                                ,pr_cdagenci_saque IN tbcc_provisao_especie.cdagenci_saque%TYPE     --> PA DE SAQUE
                                ,pr_insit_prov     IN tbcc_provisao_especie.insit_provisao%TYPE     --> SITUACAO PROVISAO
                                ,pr_dtsaqpagto     IN VARCHAR2                                      --> DATA DO SAQUE PAGAMENTO
                                ,pr_idorigem       IN tbcc_provisao_especie.cdcanal%TYPE            --> DATA DO SAQUE PAGAMENTO
                                ,pr_vlsaqpagto     IN tbcc_provisao_especie.vlsaque%TYPE            --> VALOR SAQUE PAGAMENTO
                                ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE          --> CPF CNPJ TITULAR
                                ,pr_dsprotocolo    IN crappro.dsprotoc%TYPE                         --> PROTOCOLO
                                ,pr_cdopcao        IN VARCHAR2                                      --> opção da tela prvsaq A,I,C,E
                                ,pr_cdagenci       IN tbcc_provisao_especie.cdagenci%TYPE           --> PA da conta                  -- Marcelo Telles Coelho - Projeto 420 - PLD
                                ,pr_nrcpf_sacador  IN tbcc_provisao_especie.nrcpf_sacador%TYPE      --> CPF do sacador               -- Marcelo Telles Coelho - Projeto 420 - PLD
                                ,pr_nriniseq       IN INTEGER DEFAULT 1                             --> NUMERO INICIAL DA SEQUENCIA
                                ,pr_nrregist       IN INTEGER DEFAULT 30                            --> QUANTIDADE DE REGISTROS A RETONAR
                                ,pr_xmllog         IN VARCHAR2                                      --> XML com informações de LOG
                                ,pr_cdcritic       OUT PLS_INTEGER                                  --> Código da crítica
                                ,pr_dscritic       OUT VARCHAR2                                     --> Descrição da crítica
                                ,pr_retxml         IN OUT NOCOPY XMLType                            --> Arquivo de retorno do XML
                                ,pr_nmdcampo       OUT VARCHAR2                                     --> Nome do campo com erro
                                ,pr_des_erro       OUT VARCHAR2);

PROCEDURE pc_excluir_provisao( pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE  --> codigo da cooperativa
                               ,pr_dhsaque        IN VARCHAR2                             --> DATA DO SAQUE PAGAMENTO
                               ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE --> CPF CNPJ TITULAR
                               ,pr_nrdconta       IN tbcc_provisao_especie.nrdconta %TYPE --> NUMERO CONTA TITULAR
                               ,pr_dsprotocolo    IN tbcc_provisao_especie.dsprotocolo%TYPE   --> Protocolo da provisao. PRJ 420 - Mateus Z
                               ,pr_xmllog         IN VARCHAR2                             --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                         --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                            --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType                   --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                            --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2);

PROCEDURE pc_incluir_provisao(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE        --> codigo da cooperativa
                              ,pr_dtsaqpagto     IN VARCHAR2                                   --> DATA DO SAQUE PAGAMENTO
                              ,pr_vlsaqpagto     IN tbcc_provisao_especie.vlsaque%TYPE         --> VALOR SAQUE PAGAMENTO
                              ,pr_selsaqcheq     IN tbcc_provisao_especie.incheque%TYPE        --> INDICADOR SAQUE COM CHEQUE
                              ,pr_nrbanco        IN tbcc_provisao_especie.cdbanchq%TYPE        --> NUMERO BANCO
                              ,pr_nragencia      IN tbcc_provisao_especie.cdagechq %TYPE       --> NUMERO DA AGENCIA
                              ,pr_nrcontcheq     IN tbcc_provisao_especie.nrctachq%TYPE        --> NUMERO CONTA DO CHEQUE
                              ,pr_nrcheque       IN tbcc_provisao_especie.nrcheque%TYPE        --> NUMERO DO CHEQUE
                              ,pr_nrconttit      IN tbcc_provisao_especie.nrdconta %TYPE       --> NUMERO CONTA TITULAR
                              ,pr_nrtit          IN tbcc_provisao_especie.idseqttl%TYPE        --> NUMETO TITULAR
                              ,pr_nrcpfsacpag    IN tbcc_provisao_especie.Nrcpf_Sacador%TYPE   --> CPF SACADOR PAGADOR
                              ,pr_nmsacpag       IN tbcc_provisao_especie.nmsacador%TYPE       --> NOME SACADOR PGADOR
                              ,pr_nrpA           IN tbcc_provisao_especie.cdagenci_saque%TYPE  --> NUMERO PA
                              ,pr_txtFinPagto    IN tbcc_provisao_especie.dsfinalidade%TYPE    --> FINALIDADE DO SAQUE PAGAMENTO
                              ,pr_txtobs         IN tbcc_provisao_especie.dsobervacao%TYPE     --> OBSERVACAO
                              ,pr_selquais       IN tbcc_provisao_especie.inoferta%TYPE        --> INDICADOR OFERTA OUTROS MEIOS
                              ,pr_txtquais       IN tbcc_provisao_especie.dstransacao%TYPE     --> DESCRICAO DE QUAIS MEIOS
                              ,pr_nrcpfope       IN crapopi.nrcpfope%TYPE                      --> CPF do operador internet
                              ,pr_ind_grava      IN NUMBER                                     --> INDICA QUE A PRVSAQ DEVE SER CADASTRADA INDEPENDETE DE REGRAS DE DATAS.
                              ,pr_cdope_autorizador IN crapope.cdoperad%TYPE                   --> Código do operador que autorizou a provisão -- Marcelo Telles Coelho - Projeto 420 - PLD
                              ,pr_xmllog         IN VARCHAR2                                   --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                               --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                                  --> Descrição da crítica
                              ,pr_retxml         IN OUT NOCOPY XMLType                         --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                                  --> Nome do campo com erro
                              ,pr_des_erro       OUT VARCHAR2);

PROCEDURE pc_dados_tela_pvrsaq(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE --> codigo da coopetiva
                               ,pr_nrconta        IN tbcc_provisao_especie.nrdconta%TYPE --> numero da conta
                               ,pr_nrcpfcnpj      IN crapttl.nrcpfcgc%TYPE               --> numero cpf/cnpj
                               ,pr_nrtit          IN tbcc_provisao_especie.idseqttl%TYPE --> numero titular
                               ,pr_xmllog         IN VARCHAR2                            --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                        --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                           --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                           --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2);                         --> Erros do processo

PROCEDURE pc_busca_operacao_especie(pr_cdcooper     IN tbcc_monitoramento_parametro.cdcooper%TYPE --> codigo da cooperativa
                                    ,pr_nrdconta    IN tbcc_provisao_especie.nrdconta%TYPE        --> Numero da conta
                                    ,pr_valor       IN tbcc_provisao_especie.vlsaque%TYPE         --> Valor do saque
                                    ,pr_cm7_cheque  IN VARCHAR2                                   --> Saque cheque
                                    ,pr_insolici    OUT NUMBER);

PROCEDURE pc_imprimir_protocolo(pr_cdcooper       IN tbcc_provisao_especie.cdcooper%TYPE       --> codigo da coopetiva
                               ,pr_nrpa           IN tbcc_provisao_especie.cdagenci_saque%TYPE --> NUMERO AGENCIA
                               ,pr_vlsaquepagto   IN VARCHAR2                                  --> valor do saque
                               ,pr_nrconttit      IN VARCHAR2                                  --> CONTA TITULAR
                               ,pr_dstitularidade IN VARCHAR2                                  --> NOME E CPF TITULAR
                               ,pr_dssacador      IN VARCHAR2                                  --> NOME E CPF SACADOR
                               ,pr_txtfinalidade  IN tbcc_provisao_especie.dsfinalidade%TYPE   --> texto finalidade
                               ,pr_dsprotocolo    IN crappro.dsprotoc%TYPE                     --> PROTOCOLO
                               ,pr_dtSaqPagto     VARCHAR2                                     --> DATA SAQUE
                               ,pr_xmllog         IN VARCHAR2                                  --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                              --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                                 --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                                 --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2);

  PROCEDURE pc_val_senha_operador(pr_cdcooper     IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                  ,pr_cdoperad   IN VARCHAR2 DEFAULT NULL  --Operador
                                  ,pr_nrdsenha   IN VARCHAR2               --Numero da senha
                                  ,pr_xmllog     IN VARCHAR2               --> XML com informações de LOG
                                  ,pr_cdcritic   OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic   OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo   OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_job_cancela_provisao(pr_dscritic OUT crapcri.dscritic%TYPE);

-- Calcula os dias uteis de acordo com o periodo passado como parametro
   FUNCTION fn_retorna_data_util(pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                ,pr_dtiniper IN DATE                      --> Data de Inicio do Periodo
                                ,pr_qtdialib IN PLS_INTEGER) RETURN DATE; --> Quantidade de dias para acrescentar

  -- Projeto 420 - Prevenção a Lavagem de Dinheiro (PLD)
  PROCEDURE pc_valida_data(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                          ,pr_dtprovisao   IN VARCHAR2               --> Data da provisão a ser testada
                          ,pr_xmllog       IN VARCHAR2               --> XML com informações de LOG
                          ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                          ,pr_dscritic     OUT VARCHAR2              --> Descrição da crítica
                          ,pr_retxml       IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                          ,pr_nmdcampo     OUT VARCHAR2              --> Nome do campo com erro
                          ,pr_des_erro     OUT VARCHAR2);            --> Erros do processo
END tela_prvsaq;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_prvsaq IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_PARMON
  --  Sistema  : Ayllos Web
  --  Autor    : Antonio R. Junior (mouts)
  --  Data     : Novembro - 2017.                Ultima atualizacao: 06/02/2018
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela prvsaq
  --
  --
  --  Alterações: 06/02/2018 - Ajuste para não considerar a senha na validação do operador devido a mesma ser valida através do AD
  --  						  (Adriano - SD 845176).
  
  --              12/12/2018 - Ajuste para apresentar '0,00' nos dados de consulta de agendamentos.
  --                (Guilherme Kuhnen - INC0027494)
  ---------------------------------------------------------------------------

PROCEDURE pc_alterar_provisao(pr_cdcooper         IN tbcc_provisao_especie.cdcooper%TYPE      -->CODIGO COOPER
                             ,pr_dhsaqueori       IN VARCHAR2                                 --> DATA HORA SAQUE;
                             ,pr_nrcpfcnpjori     IN tbcc_provisao_especie.nrcpfcgc%TYPE      --> CPF CNPJ
                             ,pr_nrdcontaori      IN tbcc_provisao_especie.nrdconta%TYPE      --> CONTA
                             ,pr_dtsaqpagtoalt    IN VARCHAR2                                 --> DATA PAGTO ALTERADA
                             ,pr_vlsaqpagtoalt    IN tbcc_provisao_especie.vlsaque%TYPE       --> VL PAGAMENTO ALTERADO
                             ,pr_tpsituacaoalt    IN tbcc_provisao_especie.insit_provisao%TYPE--> TIPO SITUACAO
                             ,pr_ind_grava        IN NUMBER                                   --> INDICA QUE A PRVSAQ DEVE SER CADASTRADA INDEPENDETE DE REGRAS.
                             ,pr_cdope_autorizador IN crapope.cdoperad%TYPE                   --> Código do operador que autorizou a provisão -- Marcelo Telles Coelho - Projeto 420 - PLD
                             ,pr_dsprotocolo      IN tbcc_provisao_especie.dsprotocolo%TYPE   --> Protocolo da provisao. PRJ 420 - Mateus Z 
                             ,pr_xmllog           IN VARCHAR2                                 --> XML com informações de LOG
                             ,pr_cdcritic         OUT PLS_INTEGER                             --> Código da crítica
                             ,pr_dscritic         OUT VARCHAR2                                --> Descrição da crítica
                             ,pr_retxml           IN OUT NOCOPY XMLType                       --> Arquivo de retorno do XML
                             ,pr_nmdcampo         OUT VARCHAR2                                --> Nome do campo com erro
                             ,pr_des_erro         OUT VARCHAR2) IS                            --> Erros do processo
    /* .............................................................................

        Programa: pc_alterar_provisao
        Sistema : CECRED
        Sigla   : PARM
        Autor   : Antonio Remualdo Junior
        Data    : Nov/17.                    Ultima atualizacao: 25/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar linha de parametros

        Observacao: -----

        Alteracoes: 25/05/2018 - Projeto 420 - PLD
                                (Marcelo Telles Coelho - Mouts).
    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper VARCHAR2(100);
    vr_cdcooper_aux VARCHAR2(100);
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_cdacesso VARCHAR2(100);
    vr_dsccampo VARCHAR2(1000);
    vr_emails VARCHAR2(1000);
    vr_titulo VARCHAR2(255);

    vr_horalimt NUMBER;
    vr_horalim2 NUMBER;
    vr_encontrou NUMBER(1);
    vr_dataOri DATE;
    vr_dataAlt DATE;
    vr_valor_ant tbcc_provisao_especie.vlsaque%TYPE;

    vr_lim_hora NUMBER;
    vr_lim_qtdiasprov NUMBER;
    vr_dhsaque DATE;
    vr_data_lim DATE;
    vr_lim_saq tbcc_monitoramento_parametro.vllimite_saque%TYPE;
    vr_lim_pagto tbcc_monitoramento_parametro.vllimite_pagamento%TYPE;
    vr_verifica_saldo tbcc_monitoramento_parametro.inverifica_saldo%TYPE;
    vr_provisao_email tbcc_monitoramento_parametro.vlprovisao_email%TYPE;
    vr_lim tbcc_monitoramento_parametro.vllimite_saque%TYPE;
    vr_tot_saq tbcc_provisao_especie.vlsaque%TYPE;
    vr_tot_pagto tbcc_provisao_especie.vlpagamento%TYPE;
    vr_tot tbcc_provisao_especie.vlpagamento%TYPE;
    vr_inexige_senha      VARCHAR2(1000);

    vr_dstextab VARCHAR2(2000);

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT ope.nmoperad
        FROM crapope ope
            ,crapdpo dpo
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad
         AND dpo.cddepart = ope.cddepart
         AND dpo.cdcooper = ope.cdcooper;
    rw_crapope cr_crapope%ROWTYPE;

    /* Busca conta */
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrconta  IN crapass.nrdconta%TYPE
                      ,pr_nrtit    IN crapttl.idseqttl%TYPE) IS
      select c.inpessoa,
             c.nrdconta,
             DECODE(c.inpessoa,1,t.nrcpfcgc,c.nrcpfcgc) as nrcpfcgc,
             DECODE(c.inpessoa,1,t.nmextttl,j.nmextttl) as nmprimtl
        from crapass c
        left join crapttl t on t.nrdconta = c.nrdconta and t.cdcooper = c.cdcooper and ((pr_nrtit is not null and pr_nrtit <> 0 and t.idseqttl = pr_nrtit) or(pr_nrtit is null or pr_nrtit = 0))
        left join crapjur j on j.cdcooper = c.cdcooper and j.nrdconta = c.nrdconta and ((pr_nrtit is null or pr_nrtit = 0)and ((c.inpessoa = 1 and t.idseqttl = 1) or (c.inpessoa<>1)))
       WHERE c.cdcooper = pr_cdcooper
       and c.nrdconta = pr_nrconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursos busca provisao
     CURSOR cr_prv_saq(pr_cdcooper       IN tbcc_provisao_especie.cdcooper%TYPE
                      ,pr_dtsaqpagto     IN VARCHAR2
                      ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE
                      ,pr_nrdconta       IN tbcc_provisao_especie.nrdconta%TYPE) IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.idseqttl,
           p.nrcpfcgc,
           p.vlsaque,
           p.cdagenci_saque,
           p.dsprotocolo,
           p.dhprevisao_operacao,
           p.insit_provisao
    FROM tbcc_provisao_especie p
    WHERE p.cdcooper = pr_cdcooper AND
          p.dhprevisao_operacao = TO_DATE(pr_dtsaqpagto,'DD/MM/YYYY HH24:MI:SS') AND
          p.nrcpfcgc = pr_nrcpfcnpj AND
          p.nrdconta = pr_nrdconta AND 
          p.dsprotocolo = pr_dsprotocolo;
    rw_prv_saq cr_prv_saq%ROWTYPE;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_prvsaq(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '||'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'prvsaq',
                                 pr_flfinmsg => 'N');
    END;

  BEGIN
    pr_des_erro := 'OK';
    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;

    OPEN cr_crapope(pr_cdcooper => vr_cdcooper, pr_cdoperad => vr_cdoperad);
    FETCH cr_crapope
      INTO rw_crapope;
    -- Se nao encontrar
    IF cr_crapope%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapope;
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao localizar operador!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapope;

    OPEN cr_prv_saq(pr_cdcooper   => pr_cdcooper,
                    pr_dtsaqpagto => pr_dhsaqueori,
                    pr_nrcpfcnpj  => pr_nrcpfcnpjori,
                    pr_nrdconta   => pr_nrdcontaori);
    FETCH cr_prv_saq INTO rw_prv_saq;

    -- Se nao encontrar
    IF cr_prv_saq%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_prv_saq;
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao localizar provisao!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_prv_saq;

    -- buscar conta
    OPEN cr_crapass(pr_cdcooper => rw_prv_saq.cdcooper,
                    pr_nrconta  => rw_prv_saq.nrdconta,
                    pr_nrtit    => rw_prv_saq.idseqttl);
    FETCH cr_crapass INTO rw_crapass;

    -- Se nao encontrar
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapass;
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao localizar conta!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;
    -- Fechar o cursor
    CLOSE cr_crapass;

    vr_dhsaque := TO_DATE(pr_dtsaqpagtoalt,'DD/MM/YYYY HH24:MI');

    --VALIDA DATAS
    IF(TRUNC(vr_dhsaque) < TRUNC(TO_DATE(pr_dhsaqueori,'DD/MM/YYYY HH24:MI:SS')))THEN
       -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Data alterada nao pode ser inferior a data original.';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    END IF;

    --REGRA DHSAQUE
      -- PARAMETROS MONITORAMENTO
      SELECT m.vlprovisao_saque vllimite_saque,  -- Marcelo Telles Coelho - Projeto 420 - PLD --> alterado campo DE=>VLLIMITE_SAQUE, PARA=>VLPROVISAO_SAQUE
             m.vllimite_pagamento,
             m.hrlimite_provisao,
             m.qtdias_provisao,
             m.inverifica_saldo,
             m.vlalteracao_provisao_email -- Marcelo Telles Coelho - Projeto 420 - PLD --> Buscar o prm de valor de alteração para email
                                INTO vr_lim_saq,
                                     vr_lim_pagto,
                                     vr_lim_hora,
                                     vr_lim_qtdiasprov,
                                     vr_verifica_saldo,
                                     vr_provisao_email
      FROM tbcc_monitoramento_parametro m
      WHERE m.cdcooper = pr_cdcooper;

      SELECT NVL(SUM(p.vlsaque),0) INTO vr_tot_saq
      FROM tbcc_provisao_especie p
      WHERE p.cdcooper = pr_cdcooper AND
            p.nrcpfcgc = rw_prv_saq.nrcpfcgc AND
            p.insit_provisao <> 3           AND  /* Cancelada */
            TRUNC(p.dhprevisao_operacao) = TRUNC(vr_dhsaque);

      vr_valor_ant := rw_prv_saq.vlsaque;
      vr_lim := vr_lim_saq;
      vr_tot := abs(vr_tot_saq - vr_valor_ant);

    --SE O HORARIO DO SAQUE EXCEDER O HORARIO LIMITE, JOGAR MAIS UM DIA UTIL.

    IF(TO_DATE((TO_CHAR(TRUNC(vr_dhsaque),'DDMMYYYY')||TO_CHAR(SYSDATE,'HH24MI')),'DDMMYYYYHH24MI') > TO_DATE((TO_CHAR(TRUNC(vr_dhsaque),'DDMMYYYY')||vr_lim_hora),'DDMMYYYYHH24MI'))THEN
      vr_lim_qtdiasprov := vr_lim_qtdiasprov + 1;
    END IF;
    -- SE O NOVO VALOR FOR MAIOR QUE O ANTERIOR E MAIOR QUE O LIMITE
    IF(pr_ind_grava = 0 AND (pr_vlsaqpagtoalt > vr_valor_ant AND (pr_vlsaqpagtoalt + vr_tot) >= vr_lim))THEN
       vr_data_lim := empr0008.fn_retorna_data_util(pr_cdcooper =>pr_cdcooper , pr_dtiniper =>rw_crapdat.dtmvtolt , pr_qtdialib =>vr_lim_qtdiasprov);
       IF(vr_dhsaque < vr_data_lim)THEN
         -- Montar mensagem de critica
         vr_cdcritic := 0;
         vr_dscritic := '383917 - Atenção! Provisão não autorizada. Minimo de '||vr_lim_qtdiasprov||' dias para o cadastro. Exigência BACEN - circular 3.839/17. Deseja liberar o cadastro?';
         -- volta para o programa chamador
         RAISE vr_exc_saida;
       END IF;
    END IF;

    UPDATE tbcc_provisao_especie p
    SET    p.dhprevisao_operacao = vr_dhsaque,
           p.insit_provisao = pr_tpsituacaoalt,
           p.vlsaque = pr_vlsaqpagtoalt,
           p.cdoperad_alteracao = trim(vr_cdoperad),
           p.dhalteracao = SYSDATE
    WHERE p.cdcooper = pr_cdcooper AND
          p.nrcpfcgc = pr_nrcpfcnpjori AND
          p.dhprevisao_operacao = TO_DATE(pr_dhsaqueori,'DD/MM/YYYY HH24:MI:SS') AND
          p.nrdconta = pr_nrdcontaori AND
          p.insit_provisao = 1 AND
          p.dsprotocolo = pr_dsprotocolo;


    --ENVIAR EMAIL SEG CORP, SEDE COOP, PA CADAST, PA COOP
      IF((vr_tot + pr_vlsaqpagtoalt) >= vr_provisao_email)THEN  -- Marcelo Telles Coelho - Projeto 420 - PLD --> Verificar se valor está acima do prm de segurança
        select listagg(valor, ';') within group(order by valor) INTO vr_emails
          from (select distinct valor
                  from (select c.cdcooper cdcooper,
                               c.dsemlcof emailcop,
                               a.dsdemail emailage,
                               m.dsdemail emailmon
                          from crapcop c
                          LEFT JOIN crapage a
                            ON a.cdcooper = c.cdcooper
                           and (a.cdagenci = rw_prv_saq.cdagenci_saque)
                          LEFT JOIN tbcc_monitoramento_parametro m
                            ON m.cdcooper = a.cdcooper
                         where c.cdcooper = pr_cdcooper) unpivot(valor FOR email in(EMAILCOP,
                                                                          EMAILAGE,
                                                                          EMAILMON)));

          cecred.gene0003.pc_solicita_email(pr_cdcooper => pr_cdcooper,
                                  pr_cdprogra => 'PRVSAQ',
                                  pr_des_destino => vr_emails,
                                  pr_des_assunto => 'Alteração em provisionamento saque em espécie - PA '||rw_prv_saq.cdagenci_saque,
                                  pr_des_corpo => '<b>Cooperativa:</b> '|| pr_cdcooper || '
                                  <br/>
                                  <b>Data:</b> ' || TO_CHAR(vr_dhsaque,'DD/MM/YYYY') ||'
                                  <br/>
                                  <b>Conta:</b> ' || gene0002.fn_mask_conta(rw_prv_saq.nrdconta) || '
                                  <br/>
                                  <b>Nome:</b> '|| rw_crapass.nmprimtl || '
                                  <br/>
                                  <b>CPF/CNPJ:</b> '|| gene0002.fn_mask_cpf_cnpj(rw_prv_saq.nrcpfcgc,rw_crapass.inpessoa) || '
                                  <br/>
                                  <b>Valor operação:</b> ' || cada0014.fn_formata_valor(pr_vlsaqpagtoalt) || '
                                  <br/>
                                  <b>PA saque:</b> ' || rw_prv_saq.cdagenci_saque || '
                                  <br/>
                                  <b>Operador da transação:</b> ' || vr_cdoperad || ' - ' || rw_crapope.nmoperad || '
                                  <br/>
                                  <b>Número do protocolo:</b> ' || rw_prv_saq.dsprotocolo,
                                  pr_des_anexo => null,
                                  pr_des_erro => pr_des_erro);

           IF TRIM(pr_des_erro) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
          END IF;
        END IF;

    IF rw_prv_saq.dhprevisao_operacao <> vr_dhsaque THEN
      --> gerar log da tela
      pc_log_prvsaq(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor do campo "Data do saque" de ' ||
                                    to_char(rw_prv_saq.dhprevisao_operacao,'DD/MM/YYYY HH24:MI') ||
                                    ' para ' || pr_dtsaqpagtoalt);
    END IF;

    IF (rw_prv_saq.vlsaque <> pr_vlsaqpagtoalt) THEN
      --> gerar log da tela

      pc_log_prvsaq(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o campo "Valor Saque" de ' ||
                                    vr_valor_ant ||
                                    ' para ' || pr_vlsaqpagtoalt);
    END IF;

    IF (rw_prv_saq.insit_provisao <> pr_tpsituacaoalt) THEN
      --> gerar log da tela
      pc_log_prvsaq(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'alterou o valor do campo "Situação" de ' ||
                                    rw_prv_saq.insit_provisao ||
                                    ' para ' || pr_tpsituacaoalt);
    END IF;

    --retorno protocolo
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => SQL%ROWCOUNT,
                             pr_des_erro => vr_dscritic);
      -- Marcelo Telles Coelho - Projeto 420 - PLD
      -- Gera log
      IF pr_cdope_autorizador IS NOT NULL THEN
        DECLARE
          vr_dias NUMBER;
        BEGIN
          vr_dias := TRUNC(vr_dhsaque) - TRUNC(SYSDATE);
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prvsaq.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Autorizador  '|| pr_cdope_autorizador || ' - ' ||
                                                        'Liberou a provisão da conta '||gene0002.fn_mask_conta(rw_prv_saq.nrdconta) || ' ' ||
                                                        'no valor de R$ '||TO_CHAR(pr_vlsaqpagtoalt,'9999999990.00')|| ' ' ||
                                                        '(Total provisão do dia de R$ '||TO_CHAR((vr_tot + pr_vlsaqpagtoalt),'9999999990.00')|| ') '||
                                                        'para '||TO_CHAR(vr_dias)  ||' dias.');
        END;
      END IF;

      commit;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
END pc_alterar_provisao;

PROCEDURE pc_consultar_provisao(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE          --> codigo da cooperativa
                                ,pr_nrdconta       IN tbcc_provisao_especie.nrdconta%TYPE          --> Número da conta do cooperado
                                ,pr_cdcoptel       IN VARCHAR2                                     --> Codigo da cooperativa escolhida pela cecred
                                ,pr_peri_ini       IN VARCHAR2                                     --> DATA INICIAL
                                ,pr_peri_fim       IN VARCHAR2                                     --> DATA FINAL
                                ,pr_cdagenci_saque IN tbcc_provisao_especie.cdagenci_saque%TYPE    --> PA DE SAQUE
                                ,pr_insit_prov     IN tbcc_provisao_especie.insit_provisao%TYPE    --> SITUACAO PROVISAO
                                ,pr_dtsaqpagto     IN VARCHAR2                                     --> DATA DO SAQUE PAGAMENTO
                                ,pr_idorigem       IN tbcc_provisao_especie.cdcanal%TYPE --> DATA DO SAQUE PAGAMENTO
                                ,pr_vlsaqpagto     IN tbcc_provisao_especie.vlsaque%TYPE           --> VALOR SAQUE PAGAMENTO
                                ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE         --> CPF CNPJ TITULAR
                                ,pr_dsprotocolo    IN crappro.dsprotoc%TYPE                        --> PROTOCOLO
                                ,pr_cdopcao        IN VARCHAR2                                     --> opção da tela prvsaq A,I,C,E
                                ,pr_cdagenci       IN tbcc_provisao_especie.cdagenci%TYPE          --> PA da conta                  -- Marcelo Telles Coelho - Projeto 420 - PLD
                                ,pr_nrcpf_sacador  IN tbcc_provisao_especie.nrcpf_sacador%TYPE     --> CPF do sacador               -- Marcelo Telles Coelho - Projeto 420 - PLD
                                ,pr_nriniseq       IN INTEGER                                      --> NUMERO INICIAL DA SEQUENCIA
                                ,pr_nrregist       IN INTEGER                                      --> QUANTIDADE DE REGISTROS A RETONAR
                                ,pr_xmllog         IN VARCHAR2                                     --> XML com informações de LOG
                                ,pr_cdcritic       OUT PLS_INTEGER                                 --> Código da crítica
                                ,pr_dscritic       OUT VARCHAR2                                    --> Descrição da crítica
                                ,pr_retxml         IN OUT NOCOPY XMLType                           --> Arquivo de retorno do XML
                                ,pr_nmdcampo       OUT VARCHAR2                                    --> Nome do campo com erro
                                ,pr_des_erro       OUT VARCHAR2) IS                                --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_provisao
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: 25/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parametros PLD

        Observacao: -----

        Alteracoes: 25/05/2018 - Projeto 420 - PLD
                                (Marcelo Telles Coelho - Mouts).
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_aux      VARCHAR2(255);
      vr_dsprotocolo crappro.dsprotoc%TYPE;
      vr_nrregist NUMBER;
      vr_qtregist NUMBER;
      vr_aloc     NUMBER;
      vr_insit_prov tbcc_provisao_especie.insit_provisao%TYPE;
      vr_tempcooper NUMBER;

      -- Marcelo Telles Coelho - Projeto 420 - PLD
      vr_inoferta      VARCHAR2(03);
      vr_dsobservacao  VARCHAR2(03);
      vr_vlsaque_tot   NUMBER;


      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT ope.nmoperad,
               ope.cdoperad
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;

    /*BUSCA PROVISAO*/
    CURSOR cr_prv_saq(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE
                      ,pr_peri_ini       IN VARCHAR2
                      ,pr_peri_fim       IN VARCHAR2
                      ,pr_cdagenci_saque IN tbcc_provisao_especie.cdagenci_saque%TYPE
                      ,pr_insit_prov     IN tbcc_provisao_especie.insit_provisao%TYPE
                      ,pr_dtsaqpagto     IN VARCHAR2
                      ,pr_idorigem       IN tbcc_provisao_especie.cdcanal%TYPE
                      ,pr_vlsaqpagto     IN tbcc_provisao_especie.vlsaque%TYPE
                      ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE
                      ,pr_dsprotocolo    IN crappro.dsprotoc%TYPE
                      ,pr_nriniseq       IN INTEGER
                      ,pr_nrregist       IN INTEGER
                      ,pr_cdopcao        IN VARCHAR2
                      ,pr_cdagenci       IN tbcc_provisao_especie.cdagenci%TYPE          --> PA da conta                  -- Marcelo Telles Coelho - Projeto 420 - PLD
                      ,pr_nrcpf_sacador  IN tbcc_provisao_especie.nrcpf_sacador%TYPE     --> CPF do sacador               -- Marcelo Telles Coelho - Projeto 420 - PLD
                      ) IS
         SELECT ROWNUM rnum, p.*, (SELECT c.nmrescop FROM crapcop c WHERE c.cdcooper = p.cdcooper) nmrescop
         FROM tbcc_provisao_especie p
         WHERE (pr_cdcooper       IS NULL OR p.cdcooper = pr_cdcooper)                                                        AND
               (pr_nrdconta       IS NULL OR p.nrdconta = pr_nrdconta)                                                        AND
               (pr_peri_ini       IS NULL OR TRUNC(p.dhprevisao_operacao) >= TO_DATE(pr_peri_ini,'DD/MM/YYYY'))               AND
               (pr_peri_fim       IS NULL OR TRUNC(p.dhprevisao_operacao) <= TO_DATE(pr_peri_fim,'DD/MM/YYYY'))               AND
               (pr_cdagenci_saque IS NULL OR p.cdagenci_saque = pr_cdagenci_saque)                                            AND
               (pr_insit_prov     IS NULL OR p.insit_provisao = pr_insit_prov)                                                AND
               (pr_dtsaqpagto     IS NULL OR TRUNC(p.dhprevisao_operacao)=TRUNC(TO_DATE(pr_dtsaqpagto,'DD/MM/YYYY HH24:MI'))) AND
               (pr_idorigem       IS NULL OR p.cdcanal = pr_idorigem)                                                         AND
               (pr_vlsaqpagto     IS NULL OR p.vlsaque >= pr_vlsaqpagto)                                                      AND
               (pr_nrcpfcnpj      IS NULL OR p.nrcpfcgc = pr_nrcpfcnpj)                                                       AND
               (pr_dsprotocolo    IS NULL OR p.dsprotocolo = pr_dsprotocolo)                                                  AND
               -- Marcelo Telles Coelho - Projeto 420 - PLD
	       (pr_cdagenci       IS NULL OR p.cdagenci = pr_cdagenci)                                                        AND
	       (pr_nrcpf_sacador  IS NULL OR p.nrcpf_sacador = pr_nrcpf_sacador)
         ORDER BY nmrescop,
                  CASE WHEN pr_cdopcao =  'A' THEN p.cdagenci_saque             END,
                  CASE WHEN pr_cdopcao <> 'A' THEN TRUNC(p.dhprevisao_operacao) END,
                  CASE WHEN pr_cdopcao =  'A' THEN p.nrdconta                   END,
                  CASE WHEN pr_cdopcao <> 'A' THEN p.cdagenci_saque             END,
                  CASE WHEN pr_cdopcao =  'A' THEN TRUNC(p.dhprevisao_operacao) END,
                  CASE WHEN pr_cdopcao <> 'A' THEN p.nrcpfcgc                   END,
                  CASE WHEN pr_cdopcao =  'A' THEN p.nrcpfcgc                   END,
                  CASE WHEN pr_cdopcao <> 'A' THEN p.nrdconta                   END;
    rw_prv_saq cr_prv_saq%ROWTYPE;

    /* Busca cooperativas */
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
      select c.*
      from crapcop C
      WHERE c.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

	CURSOR cr_crapcop_all IS
      select c.*
      from crapcop C
      WHERE c.flgativo = 1 AND c.cdcooper <> 3;
    rw_crapcop_all cr_crapcop_all%ROWTYPE;

    /*Buscar agencia*/
    CURSOR cr_agencia(pr_cdcooper IN crapage.cdcooper%TYPE,
                      pr_cdagenci IN crapage.cdagenci%TYPE) IS
    select a.nmextage,
           a.nmcidade
    from crapage a
    where (pr_cdcooper = 3 OR a.cdcooper = pr_cdcooper) and
          a.cdagenci = pr_cdagenci;
    rw_crapage cr_agencia%ROWTYPE;

    /*buscar crapass**/
    CURSOR cr_crapass(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE)IS
    SELECT a.nrcpfcgc,
           a.nmprimtl,
           a.inpessoa
    FROM crapass a
    WHERE a.nrdconta = pr_nrdconta AND
          a.cdcooper = pr_cdcooper ;
    rw_crapass cr_crapass%ROWTYPE;

    /*buscar titular fisico**/
    CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE)IS
    SELECT t.nrcpfcgc,
           t.nmextttl
    FROM crapttl t
    WHERE t.nrdconta = pr_nrdconta AND
          t.cdcooper = pr_cdcooper AND
          t.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    --BUSCA OPERADORES INTERNET
    CURSOR cr_opi(pr_cdcooper IN crapopi.cdcooper%TYPE,
                  pr_nrdconta IN crapttl.nrdconta%TYPE,
                  pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
    SELECT opi.nmoperad
    FROM crapopi opi
    WHERE opi.cdcooper = pr_cdcooper AND
          opi.nrdconta = pr_nrdconta AND
          opi.nrcpfope = pr_nrcpfope;
    rw_opi cr_opi%ROWTYPE;


     -- busca monitor
  CURSOR cr_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
  SELECT p.inaltera_provisao_presencial
  FROM tbcc_monitoramento_parametro p
  WHERE p.cdcooper = pr_cdcooper;
  rw_monit_param cr_monit_param%ROWTYPE;

    BEGIN
      pr_des_erro := 'OK';

      vr_dsprotocolo := UPPER(pr_dsprotocolo);

      vr_nrregist := pr_nrregist;

      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
      -- Se retornou alguma crítica

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      vr_insit_prov := pr_insit_prov;
      IF vr_insit_prov = 0 THEN -- Conta Online envia com valor 0 para todos
        vr_insit_prov := NULL;
      END IF;

      IF(pr_cdagenci_saque IS NOT NULL)THEN
        OPEN cr_agencia(pr_cdcooper => pr_cdcooper,
                        pr_cdagenci => pr_cdagenci_saque);
        FETCH cr_agencia INTO rw_crapage;
         -- Se nao encontrar
        IF cr_agencia%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_agencia;
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'PA Saque nao encontrado!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_agencia;
        END IF;
      END IF;

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapope;
      END IF;

      -- Criar cabeçalho do XML
      vr_auxconta := 0;
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      vr_vlsaque_tot := 0;
      vr_aloc := 0;

      FOR rw_crapcop_all IN cr_crapcop_all LOOP

      vr_tempcooper := rw_crapcop_all.cdcooper;

      IF vr_aloc = 1 THEN
          CONTINUE;
      END IF;

      IF pr_cdcooper <> 3 AND vr_aloc = 0 THEN
          vr_aloc := 1;
          vr_tempcooper := pr_cdcooper;
      END IF;

      --> Buscar monitoramento
      OPEN cr_monit_param(pr_cdcooper => vr_tempcooper);
      FETCH cr_monit_param INTO rw_monit_param;
      -- Se nao encontrar
      IF cr_monit_param%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_monit_param;
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Monitor parametro nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_monit_param;
      END IF;

      vr_idorigem :=pr_idorigem;
      IF(pr_cdopcao = 'A')THEN
        IF(rw_monit_param.inaltera_provisao_presencial = 0)THEN
          vr_idorigem := 5;
        ELSE
          vr_idorigem := null;
        END IF;
      END IF;

      FOR rw_prv_saq IN cr_prv_saq(pr_cdcooper      => vr_tempcooper,
                                   pr_peri_ini       => pr_peri_ini,
                                   pr_peri_fim       => pr_peri_fim,
                                   pr_cdagenci_saque => pr_cdagenci_saque,
                                   pr_insit_prov     => vr_insit_prov,
                                   pr_dtsaqpagto     => pr_dtsaqpagto,
                                   pr_idorigem       => vr_idorigem,
                                   pr_vlsaqpagto     => pr_vlsaqpagto,
                                   pr_nrcpfcnpj      => pr_nrcpfcnpj,
                                   pr_dsprotocolo    => vr_dsprotocolo,
                                   pr_nriniseq       => pr_nriniseq,
                                   pr_nrregist       => pr_nrregist,
                                   pr_cdopcao        => pr_cdopcao
                                  ,pr_cdagenci       => pr_cdagenci         --> PA da conta                  -- Marcelo Telles Coelho - Projeto 420 - PLD
                                  ,pr_nrcpf_sacador  => pr_nrcpf_sacador    --> CPF do sacador               -- Marcelo Telles Coelho - Projeto 420 - PLD
                                  ) LOOP

     vr_qtregist := nvl(vr_qtregist, 0) + 1;

      -- Controles da paginação
      IF (vr_qtregist < pr_nriniseq) OR (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        CONTINUE;
      END IF;

      -- Controles da paginação
      IF (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
        CONTINUE;
      END IF;

      -- Marcelo Telles Coelho - Projeto 420 - PLD
      vr_vlsaque_tot := vr_vlsaque_tot + rw_prv_saq.vlsaque;

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => rw_prv_saq.cdcooper,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dhsaque',
                               pr_tag_cont => TO_CHAR(rw_prv_saq.dhprevisao_operacao,'DD/MM/YYYY HH24:MI:SS'),
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdagenci_saque',
                               pr_tag_cont => rw_prv_saq.cdagenci_saque,
                               pr_des_erro => vr_dscritic);

         OPEN cr_agencia(pr_cdcooper => vr_cdcooper,
                         pr_cdagenci => rw_prv_saq.cdagenci_saque);
         FETCH cr_agencia INTO rw_crapage;
         CLOSE cr_agencia;

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmagenci_saque',
                               pr_tag_cont => rw_crapage.nmextage,
                               pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmcidade_saque',
                               pr_tag_cont => rw_crapage.nmcidade,
                               pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'nrcpfcgc',
                                pr_tag_cont => rw_prv_saq.nrcpfcgc,
                                pr_des_erro => vr_dscritic);

         OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                          pr_nrdconta => rw_prv_saq.nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;

         IF rw_crapass.inpessoa = 1 THEN
           OPEN cr_crapttl(pr_cdcooper => vr_cdcooper,
                           pr_nrdconta => rw_prv_saq.nrdconta,
                           pr_idseqttl => rw_prv_saq.idseqttl);
           FETCH cr_crapttl INTO rw_crapttl;
           CLOSE cr_crapttl;

           gene0007.pc_insere_tag(pr_xml    => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'nmtitular_saque',
                                pr_tag_cont => rw_crapttl.nmextttl,
                                pr_des_erro => vr_dscritic);
         ELSE
           gene0007.pc_insere_tag(pr_xml    => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'nmtitular_saque',
                                pr_tag_cont => rw_crapass.nmprimtl,
                                pr_des_erro => vr_dscritic);
         END IF;

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'nrdconta',
                                pr_tag_cont => rw_prv_saq.nrdconta,
                                pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'vlsaque',
                                pr_tag_cont => to_char(rw_prv_saq.vlsaque,
                                                      'fm9g999g999g999g999g990d00',
                                                      'NLS_NUMERIC_CHARACTERS='',.'''),
                                pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'insit_provisao',
                                pr_tag_cont => rw_prv_saq.insit_provisao,
                                pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                pr_tag_pai  => 'inf',
                                pr_posicao  => vr_auxconta,
                                pr_tag_nova => 'dsprotocolo',
                                pr_tag_cont => rw_prv_saq.dsprotocolo,
                                pr_des_erro => vr_dscritic);

         IF(rw_prv_saq.insit_provisao = 1)THEN
            vr_nmeacao := 'PENDENTE';
         END IF;
         IF(rw_prv_saq.insit_provisao = 2)THEN
           vr_nmeacao := 'REALIZADA';
         END IF;
         IF(rw_prv_saq.insit_provisao = 3) THEN
           vr_nmeacao := 'CANCELADA';
         END IF;

          gene0007.pc_insere_tag(pr_xml    => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmsit_provisao',
                               pr_tag_cont => vr_nmeacao,
                               pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml    => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nrcpf_sacador',
                               pr_tag_cont => rw_prv_saq.nrcpf_sacador,
                               pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'nmsacador',
                                 pr_tag_cont => rw_prv_saq.nmsacador,
                                 pr_des_erro => vr_dscritic);

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nrcpfope_pj',
                                   pr_tag_cont => rw_prv_saq.nrcpfope,
                                   pr_des_erro => vr_dscritic);
            vr_aux := '';

            IF(rw_prv_saq.nrcpfope <> 0)THEN
              OPEN cr_opi(pr_cdcooper => rw_prv_saq.cdcooper,
                          pr_nrdconta => rw_prv_saq.nrdconta,
                          pr_nrcpfope => rw_prv_saq.nrcpfope);
              FETCH cr_opi INTO rw_opi;
              CLOSE cr_opi;
              vr_aux := rw_opi.nmoperad;
            END IF;

            gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                   pr_tag_pai  => 'inf',
                                   pr_posicao  => vr_auxconta,
                                   pr_tag_nova => 'nmoperador_pj',
                                   pr_tag_cont => vr_aux,
                                   pr_des_erro => vr_dscritic);

            IF(trim(rw_prv_saq.cdoperad) IS NOT NULL)THEN
               OPEN cr_crapope(pr_cdcooper => rw_prv_saq.cdcooper,
                          pr_cdoperad => rw_prv_saq.cdoperad);
               FETCH cr_crapope INTO rw_crapope;
               CLOSE cr_crapope;
               vr_aux := rw_crapope.cdoperad || ' - ' || rw_crapope.nmoperad;
            ELSE
               vr_aux :='';
            END IF;

           gene0007.pc_insere_tag(pr_xml   => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdoperad',
                               pr_tag_cont => vr_aux,
                               pr_des_erro => vr_dscritic);

           gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dhcadastro',
                               pr_tag_cont => TO_CHAR(rw_prv_saq.dhcadastro,'DD/MM/YYYY HH24:MI:SS'),
                               pr_des_erro => vr_dscritic);

          IF(trim(rw_prv_saq.cdoperad_alteracao) IS NOT NULL)THEN
               OPEN cr_crapope(pr_cdcooper => rw_prv_saq.cdcooper,
                               pr_cdoperad => rw_prv_saq.cdoperad_alteracao);
               FETCH cr_crapope INTO rw_crapope;
               CLOSE cr_crapope;
               vr_aux := rw_crapope.cdoperad || ' - ' || rw_crapope.nmoperad;
            ELSE
               vr_aux :='';
            END IF;

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdoperad_alteracao',
                               pr_tag_cont => vr_aux,
                               pr_des_erro => vr_dscritic);

          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'inf',
                                 pr_posicao  => vr_auxconta,
                                 pr_tag_nova => 'dhalteracao',
                                 pr_tag_cont => TO_CHAR(rw_prv_saq.dhalteracao,'DD/MM/YYYY HH24:MI:SS'),
                                 pr_des_erro => vr_dscritic);

         IF(trim(rw_prv_saq.cdoperad_cancelamento) IS NOT NULL)THEN
               OPEN cr_crapope(pr_cdcooper => rw_prv_saq.cdcooper,
                          pr_cdoperad => rw_prv_saq.cdoperad_cancelamento);
               FETCH cr_crapope INTO rw_crapope;
               CLOSE cr_crapope;
               vr_aux := rw_crapope.cdoperad || ' - ' || rw_crapope.nmoperad;
            ELSE
               vr_aux :='';
            END IF;

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdoperad_cancelamento',
                               pr_tag_cont => vr_aux,
                               pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dhcancelamento',
                               pr_tag_cont => TO_CHAR(rw_prv_saq.dhcancelamento,'DD/MM/YYYY HH24:MI:SS'),
                               pr_des_erro => vr_dscritic);

         gene0007.pc_insere_tag(pr_xml     => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dsfinalidade',
                               pr_tag_cont => rw_prv_saq.dsfinalidade,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml     => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dsobervacao',
                               pr_tag_cont => rw_prv_saq.dsobervacao,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmcoop',
                               pr_tag_cont => rw_prv_saq.nmrescop,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'cdcanal',
                               pr_tag_cont => rw_prv_saq.cdcanal,
                               pr_des_erro => vr_dscritic);

        -- Marcelo Telles Coelho - Projeto 420 - PLD
        IF rw_prv_saq.inoferta = 1 THEN
          vr_inoferta := 'SIM';
        ELSE
          vr_inoferta := 'NAO';
        END IF;

        -- Marcelo Telles Coelho - Projeto 420 - PLD
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'inoferta',
                               pr_tag_cont => vr_inoferta,
                               pr_des_erro => vr_dscritic);

        -- Marcelo Telles Coelho - Projeto 420 - PLD
        IF rw_prv_saq.dsobervacao IS NOT NULL THEN
          vr_dsobservacao := 'SIM';
        ELSE
          vr_dsobservacao := 'NAO';
        END IF;

        -- Marcelo Telles Coelho - Projeto 420 - PLD
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'dsobservacao',
                               pr_tag_cont => vr_dsobservacao,
                               pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;
      END LOOP;

      END LOOP;

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'vlsaque_tot',
                             pr_tag_cont => to_char(vr_vlsaque_tot, 'FM999G999G990D90', 'nls_numeric_characters='',.'''), --INC0027494
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'qtregist',
                             pr_tag_cont => vr_qtregist,
                             pr_des_erro => vr_dscritic);


  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar_provisao;

PROCEDURE pc_incluir_provisao(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE        --> codigo da cooperativa
                              ,pr_dtsaqpagto     IN VARCHAR2                                   --> DATA DO SAQUE PAGAMENTO
                              ,pr_vlsaqpagto     IN tbcc_provisao_especie.vlsaque%TYPE         --> VALOR SAQUE PAGAMENTO
                              ,pr_selsaqcheq     IN tbcc_provisao_especie.incheque%TYPE        --> INDICADOR SAQUE COM CHEQUE
                              ,pr_nrbanco        IN tbcc_provisao_especie.cdbanchq%TYPE        --> NUMERO BANCO
                              ,pr_nragencia      IN tbcc_provisao_especie.cdagechq %TYPE       --> NUMERO DA AGENCIA
                              ,pr_nrcontcheq     IN tbcc_provisao_especie.nrctachq%TYPE        --> NUMERO CONTA DO CHEQUE
                              ,pr_nrcheque       IN tbcc_provisao_especie.nrcheque%TYPE        --> NUMERO DO CHEQUE
                              ,pr_nrconttit      IN tbcc_provisao_especie.nrdconta %TYPE       --> NUMERO CONTA TITULAR
                              ,pr_nrtit          IN tbcc_provisao_especie.idseqttl%TYPE        --> NUMETO TITULAR
                              ,pr_nrcpfsacpag    IN tbcc_provisao_especie.Nrcpf_Sacador%TYPE   --> CPF SACADOR PAGADOR
                              ,pr_nmsacpag       IN tbcc_provisao_especie.nmsacador%TYPE       --> NOME SACADOR PGADOR
                              ,pr_nrpa           IN tbcc_provisao_especie.cdagenci_saque%TYPE  --> NUMERO PA
                              ,pr_txtFinPagto    IN tbcc_provisao_especie.dsfinalidade%TYPE    --> FINALIDADE DO SAQUE PAGAMENTO
                              ,pr_txtobs         IN tbcc_provisao_especie.dsobervacao%TYPE     --> OBSERVACAO
                              ,pr_selquais       IN tbcc_provisao_especie.inoferta%TYPE        --> INDICADOR OFERTA OUTROS MEIOS
                              ,pr_txtquais       IN tbcc_provisao_especie.dstransacao%TYPE     --> DESCRICAO DE QUAIS MEIOS
                              ,pr_nrcpfope       IN crapopi.nrcpfope%TYPE                      --> CPF do operador internet
                              ,pr_ind_grava      IN NUMBER                                     --> INDICA QUE A PRVSAQ DEVE SER CADASTRADA INDEPENDETE DE REGRAS DE DATAS.
                              ,pr_cdope_autorizador IN crapope.cdoperad%TYPE                   --> Código do operador que autorizou a provisão -- Marcelo Telles Coelho - Projeto 420 - PLD
                              ,pr_xmllog         IN VARCHAR2                                   --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                               --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                                  --> Descrição da crítica
                              ,pr_retxml         IN OUT NOCOPY XMLType                         --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                                  --> Nome do campo com erro
                              ,pr_des_erro       OUT VARCHAR2) IS                              --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_provisao
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: 25/05/2018

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parametros PLD

        Observacao: -----

        Alteracoes: 23/04/2018 - Alterado para não exigir a informação dos cheques quando o cadastro for
                                 realizado através do IB, por solicitação do negócio. (Anderson P285).
                    25/05/2018 - Projeto 420 - PLD
                                (Marcelo Telles Coelho - Mouts).
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
      vr_emails VARCHAR2(1000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_pedesenha EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_valida   BOOLEAN;
      vr_ind_pf_pj INTEGER;
      vr_dtmvtolt DATE;
      vr_hrtransa craplcm.hrtransa%TYPE;
      vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_verifica_saldo tbcc_monitoramento_parametro.inverifica_saldo%TYPE;
      vr_tab_saldo extr0001.typ_tab_saldos;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_vlsddisp crapsda.vlsddisp%TYPE;
      vr_lim tbcc_monitoramento_parametro.vllimite_saque%TYPE;
      vr_tot tbcc_provisao_especie.vlpagamento%TYPE;

      vr_lim_hora NUMBER;
      vr_lim_qtdiasprov NUMBER;
      vr_dhsaque DATE;
      vr_dhlim DATE;
      vr_lim_saq tbcc_monitoramento_parametro.vllimite_saque%TYPE;
      vr_lim_pagto tbcc_monitoramento_parametro.vllimite_pagamento%TYPE;
      vr_tot_saq tbcc_provisao_especie.vlsaque%TYPE;
      vr_tot_pagto tbcc_provisao_especie.vlpagamento%TYPE;
      vr_provisao_email tbcc_monitoramento_parametro.vlprovisao_email%TYPE;
	  vr_lim_prov_saq tbcc_monitoramento_parametro.vlprovisao_saque%type;
      vr_nrcpfcgc tbcc_provisao_especie.nrcpfcgc%TYPE;
      vr_nmtitular VARCHAR2(255);
      vr_corpoemail VARCHAR2(32000);
      vr_pedesenha NUMBER :=0;
      vr_aux VARCHAR2(1000);
      vr_lib_prov_saque tbcc_monitoramento_parametro.inlibera_provisao_saque%TYPE;
      vr_inexige_senha  VARCHAR2(1000);

      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart,
               ope.nmoperad
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;

      -- CURSOR EXPLODE
      cursor v_cur(pr_str IN VARCHAR2,pr_limit varchar2) is
      select regexp_substr(pr_str,'[^'||pr_limit||']+',1,level) as str from dual
      connect by regexp_substr(pr_str,'[^'||pr_limit||']+',1,level) is not null;

      --CURSOR PROVISAO ESPECIE
      CURSOR cr_tbcc_provisao_especie(pr_cdcooper   IN tbcc_provisao_especie.cdcooper%TYPE,
                                      pr_nrCpfCnpj  IN tbcc_provisao_especie.nrcpfcgc%TYPE,
                                      pr_dtSaqPagto IN tbcc_provisao_especie.dhprevisao_operacao%TYPE,
                                      pr_nrContTit  IN tbcc_provisao_especie.nrdconta%TYPE) IS
        SELECT m.cdcooper
          FROM tbcc_provisao_especie m
        WHERE m.cdcooper = pr_cdcooper  AND
               m.nrcpfcgc = pr_nrCpfCnpj AND
               m.nrdconta = pr_nrContTit AND
              TRUNC(m.dhprevisao_operacao) = TRUNC(pr_dtSaqPagto)  AND
              m.insit_provisao = 1;
        rw_tbcc_provisao_especie cr_tbcc_provisao_especie%ROWTYPE;

       /* Busca cheque */
    CURSOR cr_cheque(pr_cdcooper     IN tbcc_provisao_especie.cdcooper%TYPE
                     ,pr_nrbanco     IN tbcc_provisao_especie.cdbanchq%TYPE
                     ,pr_nragencia   IN tbcc_provisao_especie.cdagechq%TYPE
                     ,pr_nrcontcheq  IN tbcc_provisao_especie.nrctachq%TYPE
                     ,pr_nrcheque    IN tbcc_provisao_especie.nrctachq%TYPE)IS
      select c.nrdconta
      from crapfdc c
      where c.cdcooper = pr_cdcooper
         and c.cdbanchq = pr_nrbanco
         and c.cdagechq = pr_nragencia
         and c.nrctachq = pr_nrcontcheq
         and c.nrcheque = pr_nrcheque;
    rw_cheque cr_cheque%ROWTYPE;

    -- busca conta
    CURSOR cr_conta(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE)IS
      select a.inpessoa,
             a.cdagenci,
             a.nrdconta,
             a.vllimcre,
             a.nrcpfcgc,
             a.nmprimtl
      from crapass a
      where a.cdcooper = pr_cdcooper
      and a.nrdconta = pr_nrdconta;
    rw_cr_conta cr_conta%ROWTYPE;

     -- busca TITULAR
    CURSOR cr_titular(pr_cdcooper IN crapttl.cdcooper%TYPE,
                      pr_nrdconta IN crapttl.nrdconta%TYPE,
                      pr_idseqttl IN crapttl.idseqttl%TYPE)IS
     select t.nrdconta,
            t.nrcpfcgc,
            t.nmextttl
     from crapttl t
     where t.cdcooper = pr_cdcooper
     and t.nrdconta = pr_nrdconta
     and t.idseqttl = pr_idseqttl;
    rw_titular cr_titular%ROWTYPE;

     -- busca CROPCOP
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
     select p.nmrescop
     from crapcop p
     where p.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- busca CRAPAGE
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE,
                      pr_cdagencia IN crapage.cdagenci%TYPE)IS
     select a.cdagenci
     from crapage a
     where a.cdcooper =pr_cdcooper and
           a.cdagenci = pr_cdagencia;
    rw_crapage cr_crapage%ROWTYPE;

    --BUSCA OPERADORES INTERNET
    CURSOR cr_opi(pr_cdcooper IN crapopi.cdcooper%TYPE,
                  pr_nrdconta IN crapttl.nrdconta%TYPE,
                  pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
    SELECT opi.nmoperad
    FROM crapopi opi
    WHERE opi.cdcooper = pr_cdcooper AND
          opi.nrdconta = pr_nrdconta AND
          opi.nrcpfope = pr_nrcpfope;
    rw_opi cr_opi%ROWTYPE;

     -- Cursor genérico de calendário
     rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      -- VALIDA CRAPDAT
     -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
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

     vr_dtmvtolt := rw_crapdat.dtmvtolt;
     vr_hrtransa  := TO_CHAR(SYSDATE,'SSSSS');

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;

      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      -- Fechar o cursor
      CLOSE cr_crapope;


	  --REGRA DHSAQUE
      -- PARAMETROS MONITORAMENTO
      --Adicionado uma trava para que não seja possivel o provisionamento de valores abaixo ao parametrizado
      SELECT m.vlprovisao_saque vllimite_saque,  -- Marcelo Telles Coelho - Projeto 420 - PLD --> alterado campo DE=>VLLIMITE_SAQUE, PARA=>VLPROVISAO_SAQUE
             m.vllimite_pagamento,
             m.hrlimite_provisao,
             m.qtdias_provisao,
             m.inverifica_saldo,
             m.vlprovisao_email,
             m.inlibera_provisao_saque,
             m.vlprovisao_saque INTO vr_lim_saq,
                                     vr_lim_pagto,
                                     vr_lim_hora,
                                     vr_lim_qtdiasprov,
                                     vr_verifica_saldo,
                                     vr_provisao_email,
                                     vr_lib_prov_saque,
                                     vr_lim_prov_saq
      FROM tbcc_monitoramento_parametro m
      WHERE m.cdcooper = vr_cdcooper;


      if (vr_idorigem = 3 ) and (pr_vlsaqpagto < vr_lim_prov_saq) then
          vr_cdcritic := 0;

          vr_dscritic := 'A provisão de saque pela Conta Online é apenas para valores iguais ou superiores a R$ ' ||           to_char(trunc(vr_lim_prov_saq), 'FM99G999D00'/*'999999.99'*/) || '.';

          RAISE vr_exc_saida;
      end if ;






      -- Marcelo Telles Coelho - Projeto 420 - PLD
      -- Não fazer a validação do cheque, pois as informações foram retiradas da tela
      -- IF(pr_selsaqcheq = 1 and
      --    ((vr_idorigem <> 3) or  -- Ou nao é pelo Canal IB
      --    ((vr_idorigem =  3) and ((pr_nrcheque > 0) or (pr_nrcontcheq > 0)))) -- Ou se for pelo IB, o cheque ou a conta devem estar preenchidos.
      --    ) THEN
      --   --> Buscar cheque
      --   OPEN cr_cheque(pr_cdcooper => vr_cdcooper
      --                  ,pr_nrbanco => pr_nrbanco
      --                  ,pr_nragencia => pr_nragencia
      --                  ,pr_nrcontcheq => pr_nrcontcheq
      --                  ,pr_nrcheque => pr_nrcheque );
      --   FETCH cr_cheque INTO rw_cheque;
      --
      --   -- Se nao encontrar
      --   IF cr_cheque%NOTFOUND THEN
      --     -- Fechar o cursor
      --     CLOSE cr_cheque;
      --
      --     -- Montar mensagem de critica
      --     vr_cdcritic := 244;
      --     vr_dscritic := 'Cheque Inexistente.';
      --     -- volta para o programa chamador
      --     RAISE vr_exc_saida;
      --   END IF;
      --
      --   -- Fechar o cursor
      --   CLOSE cr_cheque;
      -- END IF;

      --VALIDAR CONTA DO TITULAR
       --> Buscar conta
        OPEN cr_conta(pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => pr_nrconttit );
        FETCH cr_conta INTO rw_cr_conta;
        -- Se nao encontrar
        IF cr_conta%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_conta;
          -- Montar mensagem de critica
          vr_cdcritic := 564;
          vr_dscritic := 'Conta não cadastrada.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_conta;
        END IF;

       --> Buscar crapcop
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Cooperativa não cadastrada.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapcop;
        END IF;

         --> Buscar crapage
        OPEN cr_crapage(pr_cdcooper => vr_cdcooper,
                        pr_cdagencia => pr_nrpa);
        FETCH cr_crapage INTO rw_crapage;
        -- Se nao encontrar
        IF cr_crapage%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapage;
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'PA nao cadastrado.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapage;
        END IF;

      vr_ind_pf_pj := rw_cr_conta.inpessoa;
      IF(rw_cr_conta.inpessoa = 1)THEN -- PESSOA FISICA
         --VALIDAR TITULAR
         --> Buscar conta
          OPEN cr_titular(pr_cdcooper => vr_cdcooper
                        ,pr_nrdconta => pr_nrconttit
                        ,pr_idseqttl => pr_nrtit );
          FETCH cr_titular INTO rw_titular;

          -- Se nao encontrar
          IF cr_titular%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_titular;

            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Titular nao encontrado.';
            -- volta para o programa chamador
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_titular;
          END IF;

          vr_nrcpfcgc := rw_titular.nrcpfcgc;
          vr_nmtitular := rw_titular.nmextttl;
      ELSE
        vr_nrcpfcgc := rw_cr_conta.nrcpfcgc;
        vr_nmtitular := rw_cr_conta.nmprimtl;
      END IF;

      --VALIDAR CPF
      gene0005.pc_valida_cpf(pr_nrcalcul => pr_nrcpfsacpag, pr_stsnrcal => vr_valida);

      IF(NOT vr_valida)THEN
           -- Montar mensagem de critica
          vr_cdcritic := 027;
          vr_dscritic := 'CPF/CNPJ com erro.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
      END IF;

      --REGRA DHSAQUE
      -- PARAMETROS MONITORAMENTO
    /*  SELECT m.vlprovisao_saque vllimite_saque,  -- Marcelo Telles Coelho - Projeto 420 - PLD --> alterado campo DE=>VLLIMITE_SAQUE, PARA=>VLPROVISAO_SAQUE
             m.vllimite_pagamento,
             m.hrlimite_provisao,
             m.qtdias_provisao,
             m.inverifica_saldo,
             m.vlprovisao_email,
             m.inlibera_provisao_saque INTO vr_lim_saq,
                                     vr_lim_pagto,
                                     vr_lim_hora,
                                     vr_lim_qtdiasprov,
                                     vr_verifica_saldo,
                                     vr_provisao_email,
                                     vr_lib_prov_saque
      FROM tbcc_monitoramento_parametro m
      WHERE m.cdcooper = vr_cdcooper; */

      --VALIDA SALDO
      IF(vr_verifica_saldo = 1)THEN
        extr0001.pc_obtem_saldo_dia(pr_cdcooper => vr_cdcooper ,
                                    pr_rw_crapdat => rw_crapdat,
                                    pr_cdagenci => rw_cr_conta.cdagenci,
                                    pr_nrdcaixa => 0,
                                    pr_cdoperad => '1',
                                    pr_nrdconta => rw_cr_conta.nrdconta,
                                    pr_vllimcre => rw_cr_conta.vllimcre,
                                    pr_dtrefere => TRUNC(vr_dtmvtolt),
                                    pr_flgcrass => FALSE,
                                    pr_tipo_busca => 'A',
                                    pr_des_reto => vr_dscritic,
                                    pr_tab_sald => vr_tab_saldo,
                                    pr_tab_erro => vr_tab_erro);
        -- Se retornou alguma crítica
        IF TRIM(vr_dscritic) <> 'OK' THEN
          -- Levanta exceção
          RAISE vr_exc_saida;
        END IF;

        vr_dscritic:=null;

        vr_vlsddisp := NVL(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) + NVL(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
        IF(pr_vlsaqpagto > vr_vlsddisp)THEN
           -- Montar mensagem de critica
           vr_cdcritic := 717;
           vr_dscritic := 'Nao ha saldo suficiente para a operacao.';
           -- volta para o programa chamador
           RAISE vr_exc_saida;
        END IF;
      END IF;

      IF(vr_lim_saq IS NULL OR vr_lim_pagto IS NULL OR vr_lim_hora IS NULL OR vr_lim_qtdiasprov IS NULL)THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Dados Monitoramenteo Parametros inexistentes.';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;

      vr_dhsaque := TO_DATE(pr_dtSaqPagto,'DD/MM/YYYY HH24:MI');

      SELECT NVL(SUM(p.vlsaque),0),NVL(SUM(p.vlpagamento),0) INTO vr_tot_saq,vr_tot_pagto
      FROM tbcc_provisao_especie p
      WHERE p.cdcooper = vr_cdcooper AND
            p.nrcpfcgc = vr_nrcpfcgc AND
            p.insit_provisao <> 3    AND   /* Cancelada */
            TRUNC(p.dhprevisao_operacao) = TRUNC(vr_dhsaque);

      --SE DATA FOR MENOR QUE A DATA ATUAL
      IF(vr_dhsaque< rw_crapdat.dtmvtolt)THEN
          -- Montar mensagem de critica
        vr_cdcritic := 13;
        vr_dscritic := 'Data Errada.';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;

      -- SAQUE EM ESPECIE / PAGAMENTO EM ESPECIE
      vr_lim := vr_lim_saq;
      vr_tot := vr_tot_saq;
      vr_pedesenha :=0;
      vr_cdcritic := 0;

      IF(vr_lib_prov_saque = 0)THEN
          --SE O HORARIO DO SAQUE EXCEDER O HORARIO LIMITE, JOGAR MAIS UM DIA UTIL.
          IF(TO_DATE((TO_CHAR(TRUNC(vr_dhsaque),'DDMMYYYY')||TO_CHAR(SYSDATE,'HH24MI')),'DDMMYYYYHH24MI') > TO_DATE((TO_CHAR(TRUNC(vr_dhsaque),'DDMMYYYY')||vr_lim_hora),'DDMMYYYYHH24MI'))THEN
            vr_lim_qtdiasprov := vr_lim_qtdiasprov + 1;
          END IF;
          --pr_ind_grava, caso for 1 indica que o operador tem poderes para cadastrar a provisão mesmo qeu ela não respeite a regra dos dias uteis.
          IF(pr_ind_grava = 0 AND (vr_tot + pr_vlSaqPagto) >= vr_lim)THEN
              vr_dhlim := empr0008.fn_retorna_data_util(pr_cdcooper =>vr_cdcooper , pr_dtiniper =>rw_crapdat.dtmvtolt , pr_qtdialib =>vr_lim_qtdiasprov);
              IF(vr_dhsaque < vr_dhlim)THEN
               -- Montar mensagem de critica
               vr_cdcritic := 0;
               IF(vr_idorigem = 5)THEN
                 vr_pedesenha :=1;
                 vr_aux := 'Atenção! Provisão não autorizada. Minimo de '||vr_lim_qtdiasprov||' dias úteis para o cadastro. Exigência BACEN - circular 3.839/17. Deseja liberar o cadastro?';
                 -- volta para o programa chamador
                 RAISE vr_exc_pedesenha;
               ELSE
                 vr_pedesenha := 0;
                 vr_cdcritic  := 0;
                 vr_dscritic  := 'Atenção! Provisão não autorizada. Minimo de '||vr_lim_qtdiasprov||' dias úteis para o cadastro. Exigência BACEN - circular 3.839/17.';
                 -- volta para o programa chamador
                 RAISE vr_exc_saida;
               END IF;
             END IF;
          END IF;
      END IF;

/*
      -- Retirado a verificação de duplicidade de provisão,
      -- pois o projeto liberou a inclusão de mais de uma provisão para o mesmo dia
      -- Marcelo Telles Coelho - Projeto 420 - PLD
      --
      --BUSCA PROVISAO
        OPEN cr_tbcc_provisao_especie(pr_cdcooper   => vr_cdcooper,
                                      pr_nrCpfCnpj  => vr_nrcpfcgc,
                                      pr_dtSaqPagto => vr_dhsaque,
                                      pr_nrContTit  => pr_nrconttit);
        FETCH cr_tbcc_provisao_especie INTO rw_tbcc_provisao_especie;

        -- Se nao encontrar
        IF cr_tbcc_provisao_especie%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_tbcc_provisao_especie;

          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'Provisao ja cadastrada.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_tbcc_provisao_especie;
      END IF;
*/    -- Fim Projeto 420

      gene0006.pc_gera_protocolo(pr_cdcooper => vr_cdcooper,
                                 pr_dtmvtolt => vr_dtmvtolt,
                                 pr_hrtransa => vr_hrtransa,
                                 pr_nrdconta => pr_nrconttit,
                                 pr_nrdocmto => 0,
                                 pr_nrseqaut => 0,
                                 pr_vllanmto => pr_vlsaqpagto,
                                 pr_nrdcaixa => 900,
                                 pr_gravapro => true,
                                 pr_cdtippro => 22,
                                 pr_dsinfor1 => 'Provisao de Saque',
                                 pr_dsinfor2 => 'PA: '|| pr_nrpa || '#Data e Hora previsto: ' || vr_dhsaque || '#Valor: ' || pr_vlsaqpagto || '#Conta Titular:' || pr_nrContTit,
                                 pr_dsinfor3 => 'Titularidade da conta: ' || vr_nmtitular || ' - ' || vr_nrcpfcgc || '#Sacador: ' || pr_nmsacpag || ' - ' || pr_nrcpfsacpag || '#Finalidade: ' || pr_txtFinPagto,
                                 pr_dscedent => NULL,
                                 pr_flgagend => FALSE,
                                 pr_nrcpfope => NVL(pr_nrcpfope,0),
                                 pr_nrcpfpre => 0,
                                 pr_nmprepos => '',
                                 pr_dsprotoc => vr_dsprotoc,
                                 pr_dscritic => vr_dscritic,
                                 pr_des_erro => pr_des_erro);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      INSERT INTO tbcc_provisao_especie
      (cdcooper,
       dhprevisao_operacao,
       vlsaque,
       incheque,
       cdbanchq,
       cdagechq,
       nrctachq,
       nrcheque,
       nrdconta,
       idseqttl,
       nrcpfcgc,
       nrcpf_sacador,
       nmsacador,
       cdagenci_saque,
       dsfinalidade,
       dsobervacao,
       inoferta,
       dstransacao,
       cdagenci,
       cdoperad,
       insit_provisao,
       dhcadastro,
       cdcanal,
       dsprotocolo,
       nrcpfope,
       cdoperad_cancelamento,
       cdoperad_alteracao)
    VALUES
      (vr_cdcooper,
       vr_dhsaque,
       pr_vlSaqPagto,
       pr_selSaqCheq,
       pr_nrBanco,
       pr_nrAgencia,
       pr_nrContCheq,
       pr_nrCheque,
       pr_nrContTit,
       pr_nrTit,
       vr_nrcpfcgc,
       pr_nrCpfSacPag,
       pr_nmSacPag,
       pr_nrPA,
       pr_txtFinPagto,
       pr_txtObs,
       pr_selQuais,
       pr_txtQuais,
       rw_cr_conta.cdagenci,
       vr_cdoperad,
       1,
       SYSDATE,
       vr_idorigem,
       vr_dsprotoc,
       NVL(pr_nrcpfope,0),
       null,
       null);

       --ENVIAR EMAIL SEG CORP, SEDE COOP, PA CADAST, PA COOP
        select listagg(valor, ';') within group(order by valor) INTO vr_emails
          from (select distinct valor
                  from (select c.cdcooper cdcooper,
                               c.dsemlcof emailcop,
                               a.dsdemail emailage,
                               m.dsdemail emailmon
                          from crapcop c
                          LEFT JOIN crapage a
                            ON a.cdcooper = c.cdcooper
                           and (a.cdagenci = pr_nrpa)
                          LEFT JOIN tbcc_monitoramento_parametro m
                            ON m.cdcooper = a.cdcooper
                         where c.cdcooper = vr_cdcooper) unpivot(valor FOR email in(EMAILCOP,
                                                                          EMAILAGE,
                                                                          EMAILMON)));

       IF((vr_tot + pr_vlSaqPagto) >= vr_provisao_email)THEN

          vr_corpoemail := '<b>Cooperativa:</b> '|| vr_cdcooper || '
                            <br>
                            <b>Data:</b> ' || TO_CHAR(vr_dhsaque,'DD/MM/YYYY') ||'
                            <br>
                            <b>Conta:</b> ' || gene0002.fn_mask_conta(pr_nrContTit) || '
                            <br>
                            <b>Nome:</b> '|| vr_nmtitular || '
                            <br>
                            <b>CPF/CNPJ:</b> '|| gene0002.fn_mask_cpf_cnpj(vr_nrcpfcgc,vr_ind_pf_pj) || '
                            <br>
                            <b>Valor operação:</b> ' || cada0014.fn_formata_valor(pr_vlsaqpagto) || '
                            <br>
                            <b>PA saque:</b> ' || pr_nrPA || '
                            <br>
                            <b>Operador da transação:</b> ';

          IF(NVL(pr_nrcpfope,0) = 0)THEN
            vr_corpoemail := vr_corpoemail || vr_cdoperad || ' - ' || rw_crapope.nmoperad;
          ELSE
            --> Buscar operadores internet
            OPEN cr_opi(pr_cdcooper  => vr_cdcooper
                        ,pr_nrdconta => pr_nrconttit
                        ,pr_nrcpfope => pr_nrcpfope);
            FETCH cr_opi INTO rw_opi;
            -- Se nao encontrar
            IF cr_opi%NOTFOUND THEN
              -- Fechar o cursor
              CLOSE cr_opi;

              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Operador Internet não existe para a conta informada.';
              -- volta para o programa chamador
              RAISE vr_exc_saida;
            ELSE
              -- Fechar o cursor
              CLOSE cr_opi;
            END IF;

            vr_corpoemail := vr_corpoemail || pr_nrcpfope || ' - ' || rw_opi.nmoperad;
          END IF;

          vr_corpoemail := vr_corpoemail || '<br><b>Número do protocolo:</b> ' || vr_dsprotoc;

          cecred.gene0003.pc_solicita_email(pr_cdcooper => vr_cdcooper,
                                  pr_cdprogra => 'PRVSAQ',
                                  pr_des_destino => vr_emails,
                                  pr_des_assunto => 'Provisionamento saque em especie - PA '||rw_cr_conta.cdagenci,
                                  pr_des_corpo => vr_corpoemail,
                                  pr_des_anexo => null,
                                  pr_des_erro => pr_des_erro);

           IF TRIM(pr_des_erro) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
          END IF;
       END IF;
       COMMIT;

       --retorno protocolo
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dsprotocolo',
                             pr_tag_cont => vr_dsprotoc,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pedesenha',
                             pr_tag_cont => vr_pedesenha,
                             pr_des_erro => vr_dscritic);

      -- Marcelo Telles Coelho - Projeto 420 - PLD
      -- Gera log
      IF pr_cdope_autorizador IS NOT NULL THEN
        DECLARE
          vr_dias NUMBER;
        BEGIN
          vr_dias := TRUNC(vr_dhsaque) - TRUNC(SYSDATE);
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'prvsaq.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Autorizador  '|| pr_cdope_autorizador || ' - ' ||
                                                        'Liberou a provisão da conta '||gene0002.fn_mask_conta(pr_nrContTit) || ' ' ||
                                                        'no valor de R$ '||TO_CHAR(pr_vlSaqPagto,'9999999990.00')|| ' ' ||
                                                        '(Total provisão do dia de R$ '||TO_CHAR((vr_tot + pr_vlSaqPagto),'9999999990.00')|| ') '||
                                                        'para '||TO_CHAR(vr_dias)  ||' dias.');
        END;
      END IF;

      pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_pedesenha THEN
       --retorno protocolo
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

       -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pedesenha',
                             pr_tag_cont => vr_pedesenha,
                             pr_des_erro => vr_dscritic);

     gene0007.pc_insere_tag(pr_xml       => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'dscritic',
                             pr_tag_cont => vr_aux,
                             pr_des_erro => vr_dscritic);
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN DUP_VAL_ON_INDEX THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Provisao ja cadastrada.';

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
END pc_incluir_provisao;

PROCEDURE pc_excluir_provisao(pr_cdcooper       IN tbcc_provisao_especie.cdcooper%TYPE        --> codigo da cooperativa
                             ,pr_dhsaque        IN VARCHAR2                                   --> DATA DO SAQUE PAGAMENTO
                             ,pr_nrcpfcnpj      IN tbcc_provisao_especie.nrcpfcgc %TYPE       --> CPF CNPJ TITULAR
                             ,pr_nrdconta       IN tbcc_provisao_especie.nrdconta %TYPE       --> NUMERO CONTA TITULAR
                             ,pr_dsprotocolo    IN tbcc_provisao_especie.dsprotocolo%TYPE   --> Protocolo da provisao. PRJ 420 - Mateus Z 
                             ,pr_xmllog         IN VARCHAR2             --> XML com informações de LOG
                             ,pr_cdcritic       OUT PLS_INTEGER         --> Código da crítica
                             ,pr_dscritic       OUT VARCHAR2            --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                             ,pr_nmdcampo       OUT VARCHAR2            --> Nome do campo com erro
                             ,pr_des_erro       OUT VARCHAR2) IS        --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_provisao
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parametros PLD

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_valor tbcc_provisao_especie.vlsaque%TYPE;
      vr_dhsaque tbcc_provisao_especie.dhprevisao_operacao%TYPE;

      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;


     /* Busca cooperativas */
    CURSOR cr_crapcop IS
      select c.cdcooper,c.nmrescop
      from crapcop C
      WHERE c.flgativo = 1
      order by c.nmrescop;
    rw_crapcop cr_crapcop%ROWTYPE;

     --CURSOR PROVISAO ESPECIE
      CURSOR cr_tbcc_provisao_especie(pr_cdcooper   IN tbcc_provisao_especie.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN tbcc_provisao_especie.nrcpfcgc%TYPE,
                                      pr_dhsaque IN tbcc_provisao_especie.dhprevisao_operacao%TYPE,
                                      pr_nrdconta IN tbcc_provisao_especie.nrdconta%TYPE) IS
        SELECT m.*
          FROM tbcc_provisao_especie m
         WHERE m.cdcooper = pr_cdcooper AND
               m.nrcpfcgc = pr_nrcpfcgc AND
               m.nrdconta = pr_nrdconta AND
               m.dhprevisao_operacao  = pr_dhsaque;
      rw_tbcc_provisao_especie tbcc_provisao_especie%ROWTYPE;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_provisao_exc(pr_cdcooper IN crapcop.cdcooper%TYPE,
                              pr_cdoperad IN crapope.cdoperad%TYPE,
                              pr_nrcpfcgc IN tbcc_provisao_especie.nrcpfcgc%TYPE,
                              pr_nrdconta IN tbcc_provisao_especie.nrdconta%TYPE,
                              pr_dtsaque  IN tbcc_provisao_especie.dhprevisao_operacao%TYPE,
                              pr_vlsaque  IN tbcc_provisao_especie.vlsaque%TYPE) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                     ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' - cancelou a provisao do CPF/CNPJ '||pr_nrcpfcgc
                     ||' da conta '||pr_nrdconta || ' para o dia '|| TO_CHAR(pr_dtsaque,'DD/MM/YYYY HH24:MI:SS') || ' no valor de ' || pr_vlsaque;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'prvsaq',
                                 pr_flfinmsg => 'N');
    END;

    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_crapope;
      END IF;

      vr_dhsaque := TO_DATE(pr_dhsaque,'DD/MM/YYYY HH24:MI:SS');
      --> Buscar dados do PROVISAO
      OPEN cr_tbcc_provisao_especie(pr_cdcooper => pr_cdcooper,
                                    pr_nrcpfcgc => pr_nrcpfcnpj,
                                    pr_dhsaque  => vr_dhsaque,
                                    pr_nrdconta => pr_nrdconta);
      FETCH cr_tbcc_provisao_especie INTO rw_tbcc_provisao_especie;
      -- Se nao encontrar
      IF cr_tbcc_provisao_especie%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_tbcc_provisao_especie;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Provisao nao encontrada!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_tbcc_provisao_especie;
      END IF;

      UPDATE
      tbcc_provisao_especie p
      SET p.insit_provisao = 3,
          p.cdoperad_cancelamento = trim(vr_cdoperad),
          p.dhcancelamento = SYSDATE
      WHERE p.cdcooper = pr_cdcooper AND
            p.dhprevisao_operacao = vr_dhsaque AND
            p.nrcpfcgc = pr_nrcpfcnpj AND
            p.nrdconta = pr_nrdconta AND
            p.dsprotocolo = pr_dsprotocolo AND
            p.insit_provisao = 1;

      vr_valor := rw_tbcc_provisao_especie.vlsaque;

      pc_log_provisao_exc(pr_cdcooper => pr_cdcooper,
                          pr_cdoperad => vr_cdoperad,
                          pr_nrcpfcgc => pr_nrcpfcnpj,
                          pr_nrdconta => pr_nrdconta,
                          pr_dtsaque  => vr_dhsaque ,
                          pr_vlsaque  => vr_valor);

      COMMIT;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
END pc_excluir_provisao;

PROCEDURE pc_dados_tela_pvrsaq(pr_cdcooper        IN tbcc_provisao_especie.cdcooper%TYPE --> codigo da coopetiva
                               ,pr_nrconta        IN tbcc_provisao_especie.nrdconta%TYPE --> numero da conta
                               ,pr_nrcpfcnpj      IN crapttl.nrcpfcgc%TYPE               --> numero cpf/cnpj
                               ,pr_nrtit          IN tbcc_provisao_especie.idseqttl%TYPE --> numero titular
                               ,pr_xmllog         IN VARCHAR2                            --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                        --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                           --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType                  --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                           --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2) IS                       --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_provisao
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parametros PLD

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_banco    crapcop.cdbcoctl%type;
      vr_agencia  crapcop.cdagectl%type;
      vr_cpfcgc   integer default 0;

      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;


     /* Busca cooperativas */
    CURSOR cr_crapcop IS
      select c.cdcooper,c.nmrescop
      from crapcop C
      WHERE c.flgativo = 1
      order by c.nmrescop;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Busca conta */
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrconta  IN crapass.nrdconta%TYPE
                      ,pr_nrtit    IN crapttl.idseqttl%TYPE) IS
      select c.inpessoa,
             c.nrdconta,
             DECODE(c.inpessoa,1,t.nrcpfcgc,c.nrcpfcgc) as nrcpfcgc,
             DECODE(c.inpessoa,1,t.nmextttl,j.nmextttl) as nmprimtl
        from crapass c
        left join crapttl t on t.nrdconta = c.nrdconta and t.cdcooper = c.cdcooper and ((pr_nrtit is not null and pr_nrtit <> 0 and t.idseqttl = pr_nrtit) or(pr_nrtit is null or pr_nrtit = 0))
        left join crapjur j on j.cdcooper = c.cdcooper and j.nrdconta = c.nrdconta and ((pr_nrtit is null or pr_nrtit = 0)and ((c.inpessoa = 1 and t.idseqttl = 1) or (c.inpessoa<>1)))
       WHERE c.cdcooper = pr_cdcooper
       and c.nrdconta = pr_nrconta;
    rw_crapass cr_crapass%ROWTYPE;

    /* Busca CNPJ/CPF */
    CURSOR cr_crapttl(pr_nrcpfcnpj IN crapttl.nrcpfcgc%TYPE) IS
      select c.nrcpfcgc,
             c.nmextttl
        from crapttl c
        where c.nrcpfcgc = pr_nrcpfcnpj;
    rw_crapttl cr_crapttl%ROWTYPE;

    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;

      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;

      -- Fechar o cursor
      CLOSE cr_crapope;

      select c.cdbcoctl,c.cdagectl INTO vr_banco,vr_agencia
      from crapcop c
      where c.cdcooper = vr_cdcooper;

      IF(pr_nrconta IS NOT NULL AND pr_nrconta <> 0)THEN
          --> Buscar CONTA
          OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                          pr_nrconta  => pr_nrconta,
                          pr_nrtit    => null);
          FETCH cr_crapass INTO rw_crapass;

          -- Se nao encontrar
          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapass;

            -- Montar mensagem de critica
            vr_cdcritic := 564;
            vr_dscritic := 'Conta não cadastrada.';
            -- volta para o programa chamador
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapass;
          END IF;

          IF rw_crapass.inpessoa = 1 AND pr_nrtit IS NOT NULL AND pr_nrtit <> 0 THEN --PESSOA FISICA
              OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                              pr_nrconta => pr_nrconta,
                              pr_nrtit => pr_nrtit);
              FETCH cr_crapass INTO rw_crapass;

              -- Se nao encontrar
              IF cr_crapass%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_crapass;

                -- Montar mensagem de critica
                vr_cdcritic := 564;
                vr_dscritic := 'Conta não cadastrada.';
                -- volta para o programa chamador
                RAISE vr_exc_saida;
              ELSE
                -- Fechar o cursor
                CLOSE cr_crapass;
              END IF;

              IF rw_crapass.nmprimtl IS NULL THEN
                 -- Fechar o cursor
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Titular nao encontrado.';
                -- volta para o programa chamador
                RAISE vr_exc_saida;
              END IF;
          END IF;

      END IF;

      IF pr_nrcpfcnpj IS NOT NULL AND pr_nrcpfcnpj <> 0 THEN
          /*--VALIDAR CPF
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfcnpj, pr_stsnrcal => vr_valida , pr_inpessoa => vr_ind_pf_pj);
          IF(NOT vr_valida)THEN
               -- Montar mensagem de critica
              vr_cdcritic := 027;
              vr_dscritic := 'CPF/CNPJ com erro.';
              -- volta para o programa chamador
              RAISE vr_exc_saida;
          END IF;*/

          IF(pr_nrcpfcnpj IS NOT NULL AND pr_nrcpfcnpj <> 0)THEN
              --> Buscar CPF/CNPJ
              OPEN cr_crapttl(pr_nrcpfcnpj => pr_nrcpfcnpj);
              FETCH cr_crapttl INTO rw_crapttl;
              IF cr_crapttl%NOTFOUND THEN
                vr_cpfcgc := 0;
              ELSE
                vr_cpfcgc :=1;
              END IF;
              -- Fechar o cursor
              CLOSE cr_crapttl;
          END IF;
       END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrbanco',
                             pr_tag_cont => vr_banco,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nragencia',
                             pr_tag_cont => vr_agencia,
                             pr_des_erro => vr_dscritic);

      IF(pr_nrconta IS NOT NULL AND pr_nrconta<>0)THEN
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'inpessoa',
                               pr_tag_cont => rw_crapass.inpessoa,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nrcpfcgc',
                               pr_tag_cont => rw_crapass.nrcpfcgc,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmprimtl',
                               pr_tag_cont => rw_crapass.nmprimtl,
                               pr_des_erro => vr_dscritic);
      END IF;

      IF(pr_nrcpfcnpj IS NOT NULL AND pr_nrcpfcnpj <> 0 AND vr_cpfcgc = 1)THEN
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_auxconta,
                               pr_tag_nova => 'nmextttl',
                               pr_tag_cont => rw_crapttl.nmextttl,
                               pr_des_erro => vr_dscritic);
      END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
END pc_dados_tela_pvrsaq;

PROCEDURE pc_busca_operacao_especie(pr_cdcooper     IN tbcc_monitoramento_parametro.cdcooper%TYPE --> codigo da cooperativa
                                    ,pr_nrdconta    IN tbcc_provisao_especie.nrdconta%TYPE        --> Numero da conta
                                    ,pr_valor       IN tbcc_provisao_especie.vlsaque%TYPE         --> Valor do saque
                                    ,pr_cm7_cheque  IN VARCHAR2                                   --> Saque cheque
                                    ,pr_insolici    OUT NUMBER) IS                                --> Retorno da proc
    /* .............................................................................

        Programa: pc_busca_operacao_especie
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio R. Junior (mouts)
        Data    : Dezembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar buscar outros saques do mesmo cnpj da conta passada no parametro.

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  -- variaveis
  vr_tot_operacoes tbcc_provisao_especie.vlsaque%TYPE;

  ---------->> CURSORES <<--------

  -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- busca monitor
  CURSOR cr_monit_param(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
  SELECT p.inlibera_saque,
         p.vlprovisao_saque vllimite_saque  -- Marcelo Telles Coelho - Projeto 420 - PLD --> alterado campo DE=>VLLIMITE_SAQUE, PARA=>VLPROVISAO_SAQUE
  FROM tbcc_monitoramento_parametro p
  WHERE p.cdcooper = pr_cdcooper;
  rw_monit_param cr_monit_param%ROWTYPE;

  --CURSOR CRAPASS
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                    ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
  SELECT c.nrcpfcgc,
         c.inpessoa,
         c.nrdconta
  FROM crapass c
  WHERE c.cdcooper = pr_cdcooper AND
        c.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  -- Buscar saques Pessoa Fisica
  CURSOR cr_saques_pf(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE,
                   pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE,
                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
  select SUM(o.vloperacao) as vl_tot_operacao
  from tbcc_operacoes_diarias o
 WHERE o.cdcooper = pr_cdcooper
   AND (o.nrdconta IN (select t.nrdconta
                        from crapttl t
                       where t.cdcooper = pr_cdcooper
                         and t.nrcpfcgc = pr_nrcpfcgc) OR
       o.nrdconta IN (select a.nrdconta
                        from crapavt a
                       where a.cdcooper = pr_cdcooper
                         and a.nrcpfcgc = pr_nrcpfcgc
                         and a.tpctrato = 6
                         and a.dtvalida>=pr_dtmvtolt))
   AND o.cdoperacao = 22
   AND o.dtoperacao = pr_dtmvtolt;
   rw_saques_pf cr_saques_pf%ROWTYPE;

   -- Buscar saques Pessoa Juridica
  CURSOR cr_saques_pj(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE,
                      pr_nrdconta IN crapass.nrdconta%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE)IS
  select SUM(o.vloperacao) as vl_tot_operacao
  from tbcc_operacoes_diarias o
 WHERE o.cdcooper = pr_cdcooper
   AND (o.nrdconta IN (select t.nrdconta
                        from crapttl t
                       where t.cdcooper = pr_cdcooper
                         and t.nrcpfcgc IN (  select a.nrcpfcgc
                                              from crapavt a
                                             where a.cdcooper = pr_cdcooper
                                               and a.nrdconta = pr_nrdconta
                                               and a.tpctrato = 6
                                               and a.dtvalida >= pr_dtmvtolt)) OR
        o.nrdconta IN (select a.nrdconta
                        from crapjur a
                       where a.cdcooper = pr_cdcooper
                         and a.nrdconta = pr_nrdconta))
   AND o.cdoperacao = 22
   AND o.dtoperacao = pr_dtmvtolt;
   rw_saques_pj cr_saques_pj%ROWTYPE;

   --Buscar provisoes
   CURSOR cr_provisoes(pr_cdcooper    IN tbcc_provisao_especie.cdcooper%TYPE
                       ,pr_dtmvtolt   IN tbcc_provisao_especie.dhprevisao_operacao%TYPE
                       ,pr_nrdconta   IN crapass.nrdconta%TYPE
                       ,pr_cm7_cheque IN VARCHAR2
                       ,pr_vl_comp    IN tbcc_provisao_especie.vlsaque%TYPE)IS
   SELECT p.cdcooper
   FROM tbcc_provisao_especie p
   WHERE p.cdcooper = pr_cdcooper
         AND TRUNC(p.dhprevisao_operacao)<= pr_dtmvtolt
         AND p.nrdconta = pr_nrdconta
         AND p.insit_provisao = 1
 --        AND ((pr_cm7_cheque IS NULL AND p.incheque = 0) OR (pr_cm7_cheque IS NOT NULL AND p.incheque = 1))
         AND (pr_cm7_cheque IS NULL OR p.cdbanchq = SUBSTR(pr_cm7_cheque,2,3))
         AND (pr_cm7_cheque IS NULL OR p.cdagechq = SUBSTR(pr_cm7_cheque,5,4))
         AND (pr_cm7_cheque IS NULL OR p.nrctachq = SUBSTR(pr_cm7_cheque,23,10))
         AND (pr_cm7_cheque IS NULL OR p.nrcheque = SUBSTR(pr_cm7_cheque,14,6))
         AND p.vlsaque >= pr_vl_comp;
   rw_provisoes cr_provisoes%ROWTYPE;

  BEGIN
    DECLARE
      --Variaveis erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      pr_cdcritic PLS_INTEGER;
      pr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      pr_insolici:=0;
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;

      --> Buscar parametros
      OPEN cr_monit_param(pr_cdcooper => pr_cdcooper);
      FETCH cr_monit_param INTO rw_monit_param;

      -- Se nao encontrar
      IF cr_monit_param%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_monit_param;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Parametro nao encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE cr_monit_param;
      END IF;

      IF rw_monit_param.inlibera_saque <> 1 THEN
          --> Buscar crapass
          OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta);
          FETCH cr_crapass INTO rw_crapass;

          -- Se nao encontrar
          IF cr_crapass%NOTFOUND THEN
            -- Fechar o cursor
            CLOSE cr_crapass;

            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Conta nao encontrada.';
            -- volta para o programa chamador
            RAISE vr_exc_saida;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapass;
          END IF;

          --Realizar somas dos saques
          IF rw_crapass.inpessoa = 1 THEN
              --PESSOA FISICA
              --> Buscar saques
              OPEN cr_saques_pf(pr_cdcooper => pr_cdcooper,
                                pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                pr_dtmvtolt => rw_crapdat.dtmvtolt);
              FETCH cr_saques_pf INTO rw_saques_pf;

              -- Se nao encontrar
              IF cr_saques_pf%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_saques_pf;

                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Conta nao encontrada.';
                -- volta para o programa chamador
                RAISE vr_exc_saida;
              ELSE
                -- Fechar o cursor
                CLOSE cr_saques_pf;
              END IF;

              vr_tot_operacoes := NVL(rw_saques_pf.vl_tot_operacao,0);
          ELSE
            --PESOA JURIDICA
            --> Buscar saques
              OPEN cr_saques_pj(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapass.nrdconta,
                             pr_dtmvtolt => rw_crapdat.dtmvtolt);
              FETCH cr_saques_pj INTO rw_saques_pj;

              -- Se nao encontrar
              IF cr_saques_pj%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_saques_pj;
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Conta nao encontrada.';
                -- volta para o programa chamador
                RAISE vr_exc_saida;
              ELSE
                -- Fechar o cursor
                CLOSE cr_saques_pj;
              END IF;

              vr_tot_operacoes := NVL(rw_saques_pj.vl_tot_operacao,0);
          END IF;

          IF ((vr_tot_operacoes + pr_valor) >= rw_monit_param.vllimite_saque)THEN
              	--> Buscarprovisoes
                OPEN cr_provisoes(pr_cdcooper    => pr_cdcooper
                                  ,pr_dtmvtolt   => rw_crapdat.dtmvtolt
                                  ,pr_nrdconta   => rw_crapass.nrdconta
                                  ,pr_cm7_cheque => trim(pr_cm7_cheque)
                                  ,pr_vl_comp    => vr_tot_operacoes + pr_valor);
                FETCH cr_provisoes INTO rw_provisoes;

                -- Se nao encontrar
                IF cr_provisoes%NOTFOUND THEN
                  -- Fechar o cursor
                  CLOSE cr_provisoes;
                  pr_insolici := 1;
                ELSE
                  -- Fechar o cursor
                  CLOSE cr_provisoes;
                  pr_insolici := 0;
                END IF;
          END IF;
      END IF;

    EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_PRVSAQ.pc_busca_operacao_especie: ' || SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      ROLLBACK;
    END;
  END pc_busca_operacao_especie;

PROCEDURE pc_imprimir_protocolo(pr_cdcooper       IN tbcc_provisao_especie.cdcooper%TYPE       --> codigo da coopetiva
                               ,pr_nrpa           IN tbcc_provisao_especie.cdagenci_saque%TYPE --> NUMERO AGENCIA
                               ,pr_vlsaquepagto   IN VARCHAR2                                  --> valor do saque
                               ,pr_nrconttit      IN VARCHAR2                                  --> CONTA TITULAR
                               ,pr_dstitularidade IN VARCHAR2                                  --> NOME E CPF TITULAR
                               ,pr_dssacador      IN VARCHAR2                                  --> NOME E CPF SACADOR
                               ,pr_txtfinalidade  IN tbcc_provisao_especie.dsfinalidade%TYPE   --> texto finalidade
                               ,pr_dsprotocolo    IN crappro.dsprotoc%TYPE                     --> PROTOCOLO
                               ,pr_dtSaqPagto     VARCHAR2                                     --> DATA SAQUE
                               ,pr_xmllog         IN VARCHAR2                                  --> XML com informações de LOG
                               ,pr_cdcritic       OUT PLS_INTEGER                              --> Código da crítica
                               ,pr_dscritic       OUT VARCHAR2                                 --> Descrição da crítica
                               ,pr_retxml         IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
                               ,pr_nmdcampo       OUT VARCHAR2                                 --> Nome do campo com erro
                               ,pr_des_erro       OUT VARCHAR2) IS                             --> Erros do processo
    /* .............................................................................

        Programa: pc_consulta_provisao
        Sistema : CECRED
        Sigla   : PRVSAQ
        Autor   : Antonio Remualdo Junior
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parametros PLD

        Observacao: -----

        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper VARCHAR2(100);
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_des_xml    CLOB;
      vr_txtcompl   VARCHAR2(32600);
      vr_xml varchar2(32600);
      vr_nom_direto  VARCHAR2(400);
      vr_nom_arquivo VARCHAR2(100);
      vr_des_erro VARCHAR2(250);
      vr_tab_erro  gene0001.typ_tab_erro;
      vr_typ_said VARCHAR2(3);
      pr_nmarquiv VARCHAR(300);

      ---------->> CURSORES <<--------
      --> Buscar dados operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dpo.dsdepart
          FROM crapope ope
              ,crapdpo dpo
         WHERE ope.cdcooper = pr_cdcooper
           AND ope.cdoperad = pr_cdoperad
           AND dpo.cddepart = ope.cddepart
           AND dpo.cdcooper = ope.cdcooper;
      rw_crapope cr_crapope%ROWTYPE;


   -- busca CROPCOP
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE)IS
     select p.nrtelsac,
            p.nmrescop,
            p.hrinisac,
            p.hrfimsac,
            p.nrtelouv,
            p.hriniouv,
            p.hrfimouv
     from crapcop p
     where p.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- busca CRAPAGE
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE,
                      pr_cdagencia IN crapage.cdagenci%TYPE)IS
     select a.nmcidade
     from crapage a
     where a.cdcooper =pr_cdcooper and
           a.cdagenci = pr_cdagencia;
    rw_crapage cr_crapage%ROWTYPE;

     --CURSOR PROTOCOLO
    CURSOR cr_protocolo(pr_dsprotocolo IN crappro.dsprotoc%TYPE)IS
    SELECT p.dsprotoc
    FROM crappro p
    WHERE p.dsprotoc = pr_dsprotocolo;
    rw_protocolo cr_protocolo%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;

    BEGIN
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

       -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      --> Buscar dados do operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;

      -- Se nao encontrar
      IF cr_crapope%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapope;
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador não encontrado!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;
      -- Fechar o cursor
      CLOSE cr_crapope;

       --> Buscar crapcop
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        -- Se nao encontrar
        IF cr_crapcop%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapcop;
          -- Montar mensagem de critica
          vr_cdcritic := 564;
          vr_dscritic := 'Cooperativa não cadastrada.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapcop;
        END IF;

         --> Buscar crapage
        OPEN cr_crapage(pr_cdcooper => vr_cdcooper,
                        pr_cdagencia => pr_nrpa);
        FETCH cr_crapage INTO rw_crapage;
        -- Se nao encontrar
        IF cr_crapage%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapage;
          -- Montar mensagem de critica
          vr_cdcritic := 564;
          vr_dscritic := 'Agencia não cadastrada.';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapage;
        END IF;

      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>' ||
                     '<dados>'||
                       '<cdcooper>'|| rw_crapcop.nmrescop ||'</cdcooper>'||
                       '<nrpa>'|| pr_nrpa  ||'</nrpa>'||
                       '<dtsaqpagto>'|| pr_dtSaqPagto ||'</dtsaqpagto>'||
                       '<datsaqextenso>' || gene0005.fn_data_extenso(to_date(substr(pr_dtSaqPagto, 0 , 10), 'DD/MM/RRRR')) || '</datsaqextenso>'||
                       '<vlsaquepagto>'||pr_vlsaquepagto ||'</vlsaquepagto>'||
                       '<nrdconta>'|| pr_nrconttit ||'</nrdconta>'||
                       '<nmtitular>'|| pr_dstitularidade ||'</nmtitular>'||
                       '<nmsacado>'|| pr_dssacador ||'</nmsacado>'||
                       '<dsfinalidade>'|| pr_txtfinalidade  ||'</dsfinalidade>'||
                       '<nrprotocolo>'|| pr_dsprotocolo ||'</nrprotocolo>'||
                       '<cidadepa>'|| rw_crapage.nmcidade ||'</cidadepa>'||
                       '<telsac>'|| rw_crapcop.nrtelsac ||'</telsac>'||
                       '<horinisac>'|| to_char(to_date(rw_crapcop.hrinisac, 'SSSSS'), 'HH24') ||'</horinisac>'||
                       '<horfimsac>'|| to_char(to_date(rw_crapcop.hrfimsac, 'SSSSS'), 'HH24') ||'</horfimsac>'||
                       '<telouvi>'|| rw_crapcop.nrtelouv ||'</telouvi>'||
                       '<horiniouvi>'|| to_char(to_date(rw_crapcop.hriniouv, 'SSSSS'), 'HH24') ||'</horiniouvi>' ||
                       '<horfimouvi>'|| to_char(to_date(rw_crapcop.hrfimouv, 'SSSSS'), 'HH24') ||'</horfimouvi>'||
                     '</dados></raiz>', TRUE);

      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/rlnsv'); --> Utilizaremos o não salvo

      vr_nom_arquivo := 'TELA_PRVSAQ_PROTOCOLO_' || pr_nrpa ||'_'|| pr_nrconttit; --> Nome do arquivo é igual a PA + Número de Conta

      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                                --> Cooperativa conectada
                                 ,pr_cdprogra  => 'PRVSAQ'                                   --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                        --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml                                 --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/dados'                              --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrlProvSaque.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                                       --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.pdf' --> Arquivo final
                                 ,pr_qtcoluna  => 80                                         --> 80 colunas
                                 ,pr_sqcabrel  => 1                                          --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                 ,pr_flg_impri => 'S'                                        --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => ''                                         --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                          --> Número de cópias
                                 ,pr_flg_gerar => 'S'                                        --> gerar PDF
                                 ,pr_cdrelato  => 1                                          --> Número do relatório
                                 ,pr_nrvergrl  => 1                                          --> 1 pois foi gerado pelo JasperSoft
                                 ,pr_des_erro  => vr_des_erro);                              --> Saída com erro

      IF vr_des_erro IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

       -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

      -- Chamar a rotina que irá copiar o arquivo para o servidor do AyllosWeb
      gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper                                 --> Coop
                                  ,pr_cdagenci => 1
                                  ,pr_nrdcaixa => 0
                                  ,pr_nmarqpdf => vr_nom_direto||'/'||vr_nom_arquivo||'.pdf' --> Caminho completo
                                  ,pr_des_reto => vr_des_erro                                --> OK/NOK
                                  ,pr_tab_erro => vr_tab_erro);                              --> tabela de erros

      -- Caso apresente erro na operação
      IF nvl(vr_des_erro, 'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Retorna o caminho do arquivo pdf gerado
      pr_nmarquiv := vr_nom_arquivo||'.pdf';

      -- Removemos o arquivo gerado na NSV
      gene0001.pc_OScommand_Shell(pr_des_comando => 'rm "'||vr_nom_direto||'/'||vr_nom_arquivo||'.pdf"'
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => pr_dscritic);
      -- Testar retorno de erro
      IF vr_typ_said = 'ERR' THEN
         -- Incrementar o erro
         vr_des_erro := 'Erro ao apagar o arquivo auxiliar do sistema. '||vr_nom_direto||'/'||vr_nom_arquivo||'.pdf';
         RAISE vr_exc_saida;
      END IF;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_imprimir_protocolo;

 /* Rotina referente a verificacao de senha de usuario operador */
  PROCEDURE pc_val_senha_operador (pr_cdcooper        IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                  ,pr_cdoperad        IN VARCHAR2 DEFAULT NULL  --> Operador
                                  ,pr_nrdsenha        IN VARCHAR2               --> Numero da senha
                                  ,pr_xmllog          IN VARCHAR2               --> XML com informações de LOG
                                  ,pr_cdcritic        OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic        OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml          IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                  ,pr_nmdcampo        OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro        OUT VARCHAR2) IS          --> Erros do processo
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_valida_senha_operador
    Sistema : PRVSAQ
    Sigla   : PRVSAQ

    Autor   : Antonio R. Jr
    Data    : 11/12/2017                        Ultima atualizacao: 06/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Validar o operador para a rotina de alterar dados da tela PRVSAQ

    Alteracoes: 06/02/2018 - Ajuste para não considerar a senha na validação do operador devido a mesma ser valida através do AD
               							(Adriano - SD 845176).

  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  -- Busca os dados do operador
  CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%TYPE,
                     pr_cdoperad IN crapope.cdoperad%TYPE) IS
  SELECT ope.nvoperad
        ,ope.cdsitope
        ,ope.insaqesp
    FROM crapope ope
   WHERE ope.cdcooper = pr_cdcooper
     AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);

  --Variaveis gerais
  vr_dsorigem VARCHAR2(40);
  vr_dstransa VARCHAR2(100);

  -- Rowid para tabela de log
  vr_nrdrowid ROWID;

  --Variaveis de Excecoes
  vr_exc_saida EXCEPTION;

  BEGIN
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;

      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
     RAISE vr_exc_saida;

    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Verificar os dados do operador
    OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                     pr_cdoperad => pr_cdoperad);

    FETCH cr_crapope INTO rw_crapope;

    -- Se não encontrar registro
    IF cr_crapope%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapope;

      -- Montar mensagem de critica
      vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
      vr_dscritic := NULL;

      RAISE vr_exc_saida;
    ELSE
      -- Operador bloqueado
      IF rw_crapope.cdsitope <> 1 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 627;
        vr_dscritic := NULL;

        RAISE vr_exc_saida;
      END IF;

       -- Operador sem permissao
      IF rw_crapope.insaqesp <> 1 THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Operador sem permissão de liberação.';

        RAISE vr_exc_saida;
      END IF;

      -- Apenas fechar o cursor
      CLOSE cr_crapope;
    END IF;

    --retorno protocolo
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => 0,
                             pr_tag_nova => 'retnvl',
                             pr_tag_cont => 'OK',
                             pr_des_erro => vr_dscritic);

   EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela PRVSAQ: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_val_senha_operador;

PROCEDURE pc_job_cancela_provisao(pr_dscritic OUT crapcri.dscritic%TYPE) IS
  /* .............................................................................

     Programa: pc_job_cancela_provisao
     Sistema : Rotina acessada através de job
     Autor   : Antonio R. Junior
     Data    : Dezembro/2017.                  Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina chamada por job para cancelar as provisões antigas.

     Alteracoes:
    ..............................................................................*/
    -- Selecionar os dados da Cooperativa
   CURSOR cr_crapcop IS
      select c.cdcooper
      from crapcop C
      WHERE c.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- provisao cancelamento
    CURSOR cr_monitor(pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE) IS
      SELECT m.qtdias_provisao_cancelamento
      FROM tbcc_monitoramento_parametro m
      WHERE m.cdcooper = pr_cdcooper;
    rw_monitor cr_monitor%ROWTYPE;

     -- Cursos busca provisao
    CURSOR cr_prv_saq(pr_cdcooper     IN tbcc_provisao_especie.cdcooper%TYPE
                      ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE) IS
    SELECT prv.cdcooper,
           prv.dhprevisao_operacao,
           prv.nrcpfcgc,
           prv.nrdconta,
           prv.vlsaque
    FROM tbcc_provisao_especie prv
    WHERE prv.cdcooper = pr_cdcooper
          AND TRUNC(prv.dhprevisao_operacao) <= pr_dtmvtolt
          AND prv.insit_provisao = 1;
    rw_prv_saq cr_prv_saq%ROWTYPE;

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --Variaveis auxiliares
    vr_idprglog NUMBER;

    --Variaveis de excecoes
    vr_exc_error EXCEPTION;

  BEGIN

    CECRED.pc_log_programa(pr_dstiplog => 'I'
                         , pr_cdprograma => 'JBCC_CANCELA_PROVISAO'
                         , pr_idprglog => vr_idprglog);

    --Busca todos os operadores ativos
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);

       FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;

      --Verifica se o operador esta na tbcadast_colaborador
      OPEN cr_monitor(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_monitor
          INTO rw_monitor;

        --Se não retornar nada inativa o operador
        IF cr_monitor%NOTFOUND THEN
          CLOSE cr_monitor;
        ELSE
          CLOSE cr_monitor;

          BEGIN

            FOR rw_prv_saq IN cr_prv_saq(pr_cdcooper    => rw_crapcop.cdcooper,
                                         pr_dtmvtolt    => fn_retorna_data_util(pr_cdcooper => rw_crapcop.cdcooper, pr_dtiniper => rw_crapdat.dtmvtolt , pr_qtdialib => rw_monitor.qtdias_provisao_cancelamento * -1)) LOOP

              UPDATE tbcc_provisao_especie prv
               SET prv.insit_provisao = 3
              WHERE prv.cdcooper = rw_prv_saq.cdcooper
                   AND prv.dhprevisao_operacao = rw_prv_saq.dhprevisao_operacao
                   AND prv.nrcpfcgc = rw_prv_saq.nrcpfcgc
                   AND prv.nrdconta = rw_prv_saq.nrdconta
                   AND prv.insit_provisao = 1;

              -- Log de sucesso.
              CECRED.pc_log_programa(pr_dstiplog => 'O'
                                     ,pr_cdprograma => 'JBCC_CANCELA_PROVISAO'
                                     ,pr_cdcooper => rw_prv_saq.cdcooper
                                     ,pr_tpexecucao => 0
                                     ,pr_tpocorrencia => 4
                                     ,pr_dsmensagem => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') ||
                                                       ' - Provisão cancelada com sucesso na rotina pc_job_cancela_provisao. Cooperativa: ' ||
                                                       rw_prv_saq.cdcooper || ' Conta: ' || rw_prv_saq.nrdconta || ' Valor: ' || rw_prv_saq.vlsaque
                                   , pr_idprglog => vr_idprglog);
            END LOOP;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE vr_exc_error;
          END;
        END IF;
    END LOOP;
    CECRED.pc_log_programa(pr_dstiplog => 'F'
                         , pr_cdprograma => 'JBOPE_BLOQUEIA_OPERADORES'
                         , pr_idprglog => vr_idprglog);
    COMMIT;

  EXCEPTION
    WHEN vr_exc_error THEN

      pr_dscritic := TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - TELA_PRVSAQ --> Erro ao atualizar a tabela tbcc_provisao_especie na rotina pc_job_cancela_provisao. Detalhes: ' || SQLERRM;

      CECRED.pc_log_programa(pr_dstiplog => 'O'
                           , pr_cdprograma => 'JBCC_CANCELA_PROVISAO'
                           , pr_cdcooper => 0
                           , pr_tpexecucao => 0
                           , pr_tpocorrencia => 2
                           , pr_dsmensagem => pr_dscritic
                           , pr_idprglog => vr_idprglog);

      ROLLBACK;
    WHEN OTHERS THEN
      --Gera log
      cecred.pc_internal_exception(pr_cdcooper => 0);

      pr_dscritic := 'Erro nao tratado na TELA_PRVSAQ.pc_job_cancela_provisao: ' || SQLERRM;

      ROLLBACK;
  END pc_job_cancela_provisao;

  FUNCTION fn_retorna_data_util(pr_cdcooper IN crapcop.cdcooper%TYPE        --> Cooperativa
                               ,pr_dtiniper IN DATE                        --> Data de Inicio do Periodo
                               ,pr_qtdialib IN PLS_INTEGER) RETURN DATE IS --> Quantidade de dias para acrescentar
	BEGIN
	  /* .............................................................................

      Programa: pc_retorna_data_util
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : Antonio R. Jr (mouts)
      Data    : Janeiro/18.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para calcular proxima ou anterior data util a partir do numero de dias uteis informado

      Observacao: Para data anterior passar parametro PR_QTDIALIB negativo.

      Alteracoes:
    ..............................................................................*/

		DECLARE
      -- Buscar informacoes dos feriados
      CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE,
                        pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT 1
          FROM crapfer
         WHERE cdcooper = pr_cdcooper
           AND dtferiad = pr_dtferiad;

      vr_flgferia NUMBER;
      vr_qtdialib NUMBER;

      vr_nrdialib PLS_INTEGER := 0;
      vr_datadper DATE;
    BEGIN
      vr_datadper := pr_dtiniper;
      vr_qtdialib := ABS(pr_qtdialib);

      WHILE vr_nrdialib < vr_qtdialib LOOP
        IF(pr_qtdialib < 0)THEN
          vr_datadper := vr_datadper - 1;
        ELSE
          vr_datadper := vr_datadper + 1;
        END IF;
        -- Condicao para verificar se eh Final de Semana
        IF (TO_CHAR(vr_datadper,'d') NOT IN(1,7)) THEN
          -- Condicao para verificar se eh Feriado
          OPEN cr_crapfer(pr_cdcooper => pr_cdcooper,
                          pr_dtferiad => vr_datadper);
          FETCH cr_crapfer INTO vr_flgferia;
          -- Se nao tiver cr_crapfer
          IF cr_crapfer%NOTFOUND THEN
            vr_nrdialib := vr_nrdialib + 1;
          END IF;

          CLOSE cr_crapfer;

        END IF;

      END LOOP;


      RETURN vr_datadper;

		END;

  END fn_retorna_data_util;

 /* Rotina referente a Validar se data a está em umm fim de semana ou feriado */
  PROCEDURE pc_valida_data(pr_cdcooper     IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                          ,pr_dtprovisao   IN VARCHAR2               --> Data da provisão a ser testada
                          ,pr_xmllog       IN VARCHAR2               --> XML com informações de LOG
                          ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                          ,pr_dscritic     OUT VARCHAR2              --> Descrição da crítica
                          ,pr_retxml       IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                          ,pr_nmdcampo     OUT VARCHAR2              --> Nome do campo com erro
                          ,pr_des_erro     OUT VARCHAR2) IS          --> Erros do processo
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_valida_data
    Sistema : PRVSAQ
    Sigla   : PRVSAQ

    Autor   : Marcelo Telles Coelho
    Data    : 25/05/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Validar se a data está em umm fim de semana ou feriado

    Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Verifica se a data é um feriado
  CURSOR cr_crapfer (pr_cdcooper  IN crapfer.cdcooper%TYPE
                    ,pr_dtvalidar IN DATE) IS
  SELECT 1
    FROM crapfer
   WHERE cdcooper = pr_cdcooper
     AND dtferiad = pr_dtvalidar
     AND tpferiad = 1;

  -- Verifica se a data é um fim de semana
  CURSOR cr_fim_semana (pr_dtvalidar IN DATE) IS
  SELECT 1
    FROM dual
   WHERE TO_CHAR(pr_dtvalidar, 'd') in (1,7);

  ------------------------------- VARIÁVEIS --------------------------------
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);

  --Variaveis gerais
  vr_dsorigem VARCHAR2(40);
  vr_dstransa VARCHAR2(100);

  -- Rowid para tabela de log
  vr_nrdrowid ROWID;

  --Variaveis de Excecoes
  vr_exc_saida EXCEPTION;

  --Variaveis de Trabalho
  vr_indata_invalida NUMBER;

  BEGIN -- pc_valida_data
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;

      -- Montar mensagem de critica
      vr_cdcritic := 651;
      -- Busca critica
      vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;

    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    vr_indata_invalida := 0;

    FOR rw_fim_semana in cr_fim_semana (pr_dtvalidar => TO_DATE(pr_dtprovisao,'dd/mm/yyyy')) LOOP
      vr_indata_invalida := 1;
    END LOOP;

    FOR rw_crapfer in cr_crapfer (pr_cdcooper  => pr_cdcooper
                                 ,pr_dtvalidar => TO_DATE(pr_dtprovisao,'dd/mm/yyyy')) LOOP
      vr_indata_invalida := 1;
    END LOOP;

    IF vr_indata_invalida = 1 THEN
      vr_dscritic := 'Atenção! Não é possível incluir provisão para essa data, pois não se trata de dia útil.';
      RAISE vr_exc_saida;
    END IF;

    --retorno protocolo
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    -- Insere as tags
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'retnvl',
                           pr_tag_cont => 'OK',
                           pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_PRVSAQ.PC_VALIDA_DATA: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_valida_data;

END tela_prvsaq;
/
