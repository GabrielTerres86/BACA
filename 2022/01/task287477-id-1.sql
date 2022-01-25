DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';  
   vr_nmarqimp1            VARCHAR2(100)  := 'backup2.txt';
   vr_nmarqimp             VARCHAR2(100)  := 'log2.txt';
   vr_ind_arquiv           utl_file.file_type;
   vr_ind_arquiv1          utl_file.file_type;  
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0120603';        
   vr_dtcalcul_considerado crapdat.dtmvtolt%TYPE;
   vr_negativo             BOOLEAN;  
   vr_cdhistor             craphis.cdhistor%TYPE;    
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vidtxfixa               NUMBER;
   vcddindex               NUMBER;
   vr_nrseqdig             NUMBER := 0;  
   -- Variáveis de retorno
   vr_idtipbas NUMBER := 2;
   vr_idgravir NUMBER := 0;
   vr_vlbascal NUMBER := 0; 
   vr_vlsldtot NUMBER := 0;
   vr_vlsldrgt NUMBER := 0;
   vr_vlultren NUMBER := 0;
   vr_vlrentot NUMBER := 0;
   vr_vlrevers NUMBER := 0;
   vr_vlrdirrf NUMBER := 0;
   vr_percirrf NUMBER := 0;
   pr_vlsldtot NUMBER;
   pr_vlsldrgt NUMBER;
   pr_vlultren NUMBER;
   pr_vlrentot NUMBER;
   pr_vlrevers NUMBER;
   pr_vlrdirrf NUMBER;
   pr_percirrf NUMBER;
   
   CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,idsitpro
            ,idtxfixa          
            ,cdhsraap
            ,cdhsprap
            ,cdhsrvap        
        FROM crapcpc cpc
       WHERE cpc.cddindex = 6 
         AND cpc.indanive = 1
         AND cpc.idsitpro = 1
         AND cpc.cdprodut = 1109;
   
         rw_crapcpc cr_crapcpc%ROWTYPE;      
   
   CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE ) IS
      SELECT distinct rac.cdcooper, 
             rac.nrdconta, 
             rac.nraplica, 
             rac.dtaniver,
             rac.dtmvtolt,
             rac.txaplica,            
             rac.qtdiacar,
             cpc.cdhsvrcc,
             rac.vlbasapl, 
             rac.vlsldatl,
             rac.cdprodut
        FROM craprac rac,
             craplac lac,
             crapcpc cpc
       WHERE rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND rac.cdprodut = cpc.cdprodut 
         AND rac.dtaniver = to_date('01/02/2022','dd/mm/yyyy') --Aniversário errado
         AND rac.dtmvtolt >= to_date('29/11/2021','dd/mm/yyyy') AND rac.dtmvtolt <= to_date('30/11/2021','dd/mm/yyyy') -- Data de movimento do aporte
         AND lac.dtmvtolt >= to_date('01/01/2022','dd/mm/yyyy')
         AND rac.cdcooper = pr_cdcooper -- cooperativas Viacredi e Alto Vale
         AND rac.idsaqtot = 1 
         AND lac.cdhistor = 3528      
         AND rac.cdprodut = 1109;        
     
         rw_craprac cr_craprac%ROWTYPE;        
   
   CURSOR cr_crapdat IS
      SELECT dat.cdcooper,
             dat.dtmvtolt 
        FROM crapdat dat 
       WHERE cdcooper IN(1,16);
       
       rw_crapdat cr_crapdat%ROWTYPE;
     
   PROCEDURE backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
   
  PROCEDURE loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
  
  /* PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;*/  
   
   FUNCTION fn_proximo_aniv_poupanca(pr_dtaplica IN craprac.dtaniver%TYPE) return craprac.dtaniver%TYPE IS
     vr_dia integer;
     vr_mes integer;
     vr_ano integer;
     vr_exc_data_errada exception;
  BEGIN

     BEGIN

       vr_dia := EXTRACT(day FROM pr_dtaplica);
       vr_mes := EXTRACT(month FROM pr_dtaplica);
       vr_ano := EXTRACT(year FROM pr_dtaplica);

       IF vr_dia in (29, 30, 31) THEN
          vr_dia := 1;
          vr_mes := vr_mes + 2;

          IF vr_mes > 12 THEN
             vr_mes := vr_mes - 12;
             vr_ano := vr_ano + 1;
          END IF;
       ELSE
          vr_mes := vr_mes + 1;

          IF vr_mes > 12 THEN
             vr_mes := 1;
             vr_ano := vr_ano + 1;
          END IF;
       END IF;

       RETURN to_date(vr_dia || '/' || vr_mes || '/' || vr_ano,'dd/mm/rrrr');

    EXCEPTION
       WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3
                                    ,pr_compleme => 'Erro calculando proximo aniversario poupança!' ||
                                                    ' pr_dtaplica = ' || to_char(pr_dtaplica,'dd/mm/rrrr') ||
                                                    ' Erro = ' || SQLERRM);
         RAISE vr_exc_data_errada;

    END;

  END fn_proximo_aniv_poupanca;
  --  Retorna a soma dos lançamentos encontrados para a cooperativa, conta, aplicação, histórico e período
  --  informados nos parâmetros
  --  Quando não forem encontrados lançamentos,será retornado o valor ZERO
  --
  PROCEDURE pc_lanctos_historicos_periodo(pr_cdcooper IN craplac.cdcooper%TYPE
                                         ,pr_nrdconta IN craplac.nrdconta%TYPE
                                         ,pr_nraplica IN craplac.nraplica%TYPE
                                         ,pr_cdhistor IN craplac.cdhistor%TYPE
                                         ,pr_dtinicio IN craplac.dtmvtolt%TYPE
                                         ,pr_dtfim    IN craplac.dtmvtolt%TYPE
                                         ,pr_vltotmto OUT craplac.vllanmto%TYPE
                                         ,pr_cdcritic OUT PLS_INTEGER
                                         ,pr_dscritic OUT VARCHAR2) IS

    vr_cdcritic crapcri.cdcritic%TYPE := 0;

    CURSOR cr_craplac IS
      SELECT nvl(SUM(lac.vllanmto), 0) AS vltotmto
        FROM craplac lac
       WHERE lac.cdcooper = pr_cdcooper
         AND lac.nrdconta = pr_nrdconta
         AND lac.nraplica = pr_nraplica
         AND lac.cdhistor = pr_cdhistor
         AND trunc(lac.dtmvtolt) >= pr_dtinicio
         AND trunc(lac.dtmvtolt) <= pr_dtfim;

    rw_craplac cr_craplac%ROWTYPE;

  BEGIN

    OPEN cr_craplac;
    FETCH cr_craplac
      INTO rw_craplac;
    CLOSE cr_craplac;

    pr_vltotmto := nvl(rw_craplac.vltotmto, 0);

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'pc_lanctos_historicos_periodo');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_lanctos_historicos_periodo: ' || pr_nraplica || ' ' ||
                     pr_dtinicio || ' ' || pr_dtfim || ' ' || SQLERRM;
  END pc_lanctos_historicos_periodo;
  
   --  Retorna a taxa da poupança referente a data informada no parâmetro
  --
  --
  PROCEDURE pc_taxa_poupanca(pr_datataxa     IN  craptxi.dtiniper%TYPE
                            ,pr_vlrdtaxa     OUT craptxi.vlrdtaxa%TYPE
                            ,pr_cdcritic     OUT PLS_INTEGER
                            ,pr_dscritic     OUT VARCHAR2) IS

    vr_exc_saida EXCEPTION;
    vr_cdcritic        crapcri.cdcritic%TYPE := 0;
    vr_dscritic        crapcri.dscritic%TYPE := NULL;

    CURSOR cr_craptxi IS
      SELECT txi.vlrdtaxa
      FROM craptxi txi
      WHERE txi.cddindex = 6
        AND txi.dtiniper = pr_datataxa
        AND txi.dtfimper = pr_datataxa;

    rw_craptxi cr_craptxi%ROWTYPE;

  BEGIN

    --Como padrão a taxa é nula
    pr_vlrdtaxa := null;

    OPEN cr_craptxi;
    FETCH cr_craptxi
      INTO rw_craptxi;
    IF cr_craptxi%NOTFOUND THEN
      CLOSE cr_craptxi;
      vr_dscritic := 'Taxa não encontrada: ' || pr_datataxa;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craptxi;
    END IF;

    --se localizou a taxa então retorna o valor encontrado
    pr_vlrdtaxa := rw_craptxi.vlrdtaxa;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3
                                  ,pr_compleme => 'pc_taxa_poupanca');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_taxa_poupanca: ' || SQLERRM;
  END pc_taxa_poupanca;
  
   --  Procedure responsável por calcular os rendimentos acumulados da aplicação poupança
  --
  --
  PROCEDURE pc_poupanca_clc_rendimento(pr_cdcooper                  craprac.cdcooper%TYPE
                                      ,pr_nrdconta                  craprac.nrdconta%TYPE
                                      ,pr_nraplica                  craprac.nraplica%TYPE
                                      ,pr_dtaporte                  craprac.dtmvtolt%TYPE
                                      ,pr_dtaniversario             craprac.dtaniver%TYPE
                                      ,pr_cdhsnrap                  crapcpc.cdhsnrap%TYPE --historico de aporte
                                      ,pr_cdhsrgap                  crapcpc.cdhsrgap%TYPE --historico de resgate
                                      ,pr_vlrentabilidade_acumulada OUT NUMBER
                                      ,pr_cdcritic                  OUT PLS_INTEGER
                                      ,pr_dscritic                  OUT VARCHAR2) IS
    --
    vr_dtinicio_rentab          DATE;
    vr_dtfim_rentab             DATE;
    vr_dtprimeiroaniversario    DATE := NULL;
    vr_qtaniversariosdecorridos NUMBER := 0;
    vr_dtinicioperiodorentab    DATE := NULL;
    vr_txinicioperiodorentab    NUMBER := 0;
    vr_vlindicecorrecao         NUMBER := 0;
    vr_vlaporte_periodo         craplac.vllanmto%TYPE;
    vr_vlresgate_periodo        craplac.vllanmto%TYPE;
    vr_vlbasecalculo            NUMBER;
    vr_vlbasecalculo_corrigida  NUMBER;
    --
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := NULL;
    vr_exc_saida EXCEPTION;
    --
  BEGIN
    --
    --calcula a data do primeiro aniversario tendo como referencia a data de aporte
    vr_dtprimeiroaniversario := fn_proximo_aniv_poupanca(trunc(pr_dtaporte));
    --calcula a quantidade de meses decorridos entre o primeiro aniversario e o aniversario atual
    vr_qtaniversariosdecorridos := trunc(months_between(pr_dtaniversario, vr_dtprimeiroaniversario)) + 1;
    --
    pr_vlrentabilidade_acumulada := 0;
    vr_vlbasecalculo             := 0;
    vr_vlbasecalculo_corrigida   := 0;
    --
    --processa em modo reverso para processar na ordem das datas mais antigas para as datas mais recentes
    FOR i IN REVERSE 1 .. vr_qtaniversariosdecorridos
    LOOP
      --
      --calcula o inicio do período de rentabilidade com base no aniversário atual,
      --diminuindo a quantidad de meses decorridos
      vr_dtinicioperiodorentab := add_months(pr_dtaniversario, (-i));
      --
      /*
         Exemplo das datas de inicio e fim de periodo de rentabilidade
           Aniversário = 20/02/2020
           Periodo de rentabilidade:
           Inicio      = 20/01/2020
           Fim         = 19/02/2020
      */
      --
      IF i = vr_qtaniversariosdecorridos THEN
        --
        --para o primeiro vencimento da aplicação o inicio do periodo eh a data de aporte
        vr_dtinicio_rentab := pr_dtaporte;
        --para o primeiro vencimento da aplicação o fim do periodo eh a data do primeiro aniversário - 1 dia
        vr_dtfim_rentab := vr_dtprimeiroaniversario - 1;
        --
      ELSE
        --
        --como padrão o inicio do periodo é a data de inicio do periodo de rentabilidade já calculada
        vr_dtinicio_rentab := vr_dtinicioperiodorentab;
        --a data fim do periodo é a data de fim do periodo de rentabilidade
        --ou seja a data do aniversário - 1 dia
        vr_dtfim_rentab := add_months(pr_dtaniversario, (-i + 1)) - 1;
        --
      END IF;
      --
      vr_vlaporte_periodo := 0;
      --
      --buscar o valor de aporte realizado durante o periodo de rentabilidade
      pc_lanctos_historicos_periodo(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_cdhistor => pr_cdhsnrap
                                   ,pr_dtinicio => vr_dtinicio_rentab
                                   ,pr_dtfim    => vr_dtfim_rentab
                                   ,pr_vltotmto => vr_vlaporte_periodo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      --
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      --
      vr_vlresgate_periodo := 0;
      --
      --buscar o valor de resgate realizado durante o periodo de rentabilidade
      pc_lanctos_historicos_periodo(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_cdhistor => pr_cdhsrgap
                                   ,pr_dtinicio => vr_dtinicio_rentab
                                   ,pr_dtfim    => vr_dtfim_rentab
                                   ,pr_vltotmto => vr_vlresgate_periodo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      --
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      --
      --usa duas bases de calculo por que uma delas sera rentabilizada
      --e ao final do processo vamos calcular o rendimento total
      vr_vlbasecalculo           := vr_vlbasecalculo +
                                    (nvl(vr_vlaporte_periodo, 0) - nvl(vr_vlresgate_periodo, 0));
      vr_vlbasecalculo_corrigida := vr_vlbasecalculo_corrigida +
                                    (nvl(vr_vlaporte_periodo, 0) - nvl(vr_vlresgate_periodo, 0));
      --
      vr_txinicioperiodorentab := 0;
      --
      --busca a taxa de rentabilidade do inicio do periodo de rentabilidade
      pc_taxa_poupanca(pr_datataxa => vr_dtinicioperiodorentab
                      ,pr_vlrdtaxa => vr_txinicioperiodorentab
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
      --
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      --
      --calcula o indice de correcao
      vr_vlindicecorrecao := (1 + (vr_txinicioperiodorentab / 100));
      --
      --rentabilizar a base de calculo preservando todas as casas decimais
      --no loop essa base recebe a rentabilizacao acumulada de todo o periodo da aplicacao
      vr_vlbasecalculo_corrigida := vr_vlbasecalculo_corrigida * vr_vlindicecorrecao;
      --
    END LOOP;
    --
    pr_vlrentabilidade_acumulada := vr_vlbasecalculo_corrigida - vr_vlbasecalculo;
    --
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'pc_taxa_poupanca');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_poupanca_clc_rendimento: ' || SQLERRM;
  END pc_poupanca_clc_rendimento;
  
     --  Função para verificar se a poupança está habilitada a ser rentabilizada, ou seja, se a poupança completou novo aniversário (+30 dias) desde sua última rentabilização
  --
  -- Retorna:
  --   0 => Não habilitada para rentabilizar
  --   1 => Habilitada para rentabilizar
  --
  FUNCTION fn_pode_rentabilizar_poupanca(pr_cdcooper IN  craprac.cdcooper%TYPE
                                        ,pr_dtaniver IN  craprac.dtaniver%TYPE
                                        ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE) RETURN INTEGER IS

     vr_dtaniver         DATE := trunc(pr_dtaniver);
     vr_dtmvtolt         DATE := trunc(pr_dtmvtolt);
     vr_proximo_dia_util DATE;

     vr_exc_data_errada exception;

  BEGIN

    BEGIN

      /*
      O cálculo da rentabilidade pode acontecer:
      - No próprio dia do aniversário;
      - No primeiro dia útil após o aniversário, quando o próximo dia útil é dentro do mesmo mês;
      - Em um dia anterior ao aniversário, quando próximo dia útil é no mês seguinte;
      */

      -- Se a data de movimento é maior ou igual a data do aniversário
      IF vr_dtmvtolt >= vr_dtaniver THEN
        RETURN 1;
      END IF;

      -- Descobre qual o próximo dia útil
      vr_proximo_dia_util := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => (vr_dtmvtolt+1));

      --Quando o próximo dia útil fica no mês seguinte
      if trim(to_char(vr_dtmvtolt,'mm')) <> trim(to_char(vr_proximo_dia_util,'mm')) then
        --se a data de aniversário é maior que a data de movimento e dentro do mesmo mês
        if vr_dtaniver > vr_dtmvtolt and trim(to_char(vr_dtaniver,'mm')) = trim(to_char(vr_dtmvtolt,'mm')) then
          RETURN 1;
        end if;
      end if;

      RETURN 0;

    EXCEPTION
       WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'Erro fn_pode_rentabilizar_poupanca' || SQLERRM);
         RAISE vr_exc_data_errada;

    END;

  END fn_pode_rentabilizar_poupanca;
  
   --  Retorna a soma dos lançamentos encontrados para a cooperativa, conta, aplicação e histórico informados nos parâmetros
  --  Quando não forem encontrados lançamentos,será retornado o valor ZERO
  --
  PROCEDURE pc_lanctos_historicos(pr_cdcooper  IN  craplac.cdcooper%TYPE
                                 ,pr_nrdconta  IN  craplac.nrdconta%TYPE
                                 ,pr_nraplica  IN  craplac.nraplica%TYPE
                                 ,pr_cdhistor  IN  craplac.cdhistor%TYPE
                                 ,pr_vltotmto  OUT craplac.vllanmto%TYPE
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2) IS

    vr_exc_saida EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE := 0;
    vr_dscritic  crapcri.dscritic%TYPE := NULL;

    CURSOR cr_craplac IS
      SELECT nvl(sum(lac.vllanmto), 0) AS vltotmto
      FROM craplac lac
      WHERE lac.cdcooper = pr_cdcooper
        AND lac.nrdconta = pr_nrdconta
        AND lac.nraplica = pr_nraplica
        AND lac.cdhistor = pr_cdhistor;

    rw_craplac cr_craplac%ROWTYPE;

  BEGIN

    OPEN cr_craplac;
    FETCH cr_craplac
      INTO rw_craplac;
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;
      vr_dscritic := 'Histórico não encontrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac;
    END IF;

    pr_vltotmto := rw_craplac.vltotmto;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'pc_lanctos_historicos');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_lanctos_historicos: ' || SQLERRM;
  END pc_lanctos_historicos;
    PROCEDURE pc_saldo_atual_poupanca(pr_cdcooper IN craprac.cdcooper%TYPE --> Código da Cooperativa
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE --> Número da Conta
                                   ,pr_nraplica IN craprac.nraplica%TYPE --> Número da Aplicação
                                   ,pr_vlaplica IN craprac.vlaplica%TYPE --> Valor para atualizacao
                                   ,pr_cdprodut IN crapcpc.cdprodut%type --> Produto PCAPTA
                                   ,pr_idcalren IN PLS_INTEGER DEFAULT 0 --> Indica se é processo de cálculo rentabilidade => 0-Não / 1-Sim)
                                   ,pr_idtipbas IN PLS_INTEGER           --> Tipo Base Cálculo => 1-Parcial/2-Total)
                                   ,pr_vlbascal IN  NUMBER               --> Valor Base Cálculo
                                   ,pr_vlsldtot OUT NUMBER               --> Saldo Total da Aplicação
                                   ,pr_vlsldrgt OUT NUMBER               --> Saldo Total para Resgate
                                   ,pr_vlultren OUT NUMBER               --> Valor Último Rendimento
                                   ,pr_vlrentot OUT NUMBER               --> Valor Rendimento Total
                                   ,pr_vlrevers OUT NUMBER               --> Valor de Reversão
                                   ,pr_vlrdirrf OUT NUMBER               --> Valor do IRRF
                                   ,pr_percirrf OUT NUMBER               --> Percentual do IRRF
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    DECLARE

      vr_vlrentabilidade_acumulada NUMBER;

      vr_provisao     NUMBER(20,8) := 0; -- Valor de lancamento de provisoes
      vr_reversao     NUMBER(20,8) := 0; -- Valor de lancamento de reversoes
      vr_rendimento   NUMBER(20,8) := 0; -- Valor de lancamento de rendimento

      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_exc_saida    EXCEPTION;


      CURSOR cr_crapcpc IS
       SELECT cpc.cdhsprap, -- Historico de provisões
              cpc.cdhsrvap, -- Histórico de reversões
              cpc.cdhsrdap, -- Historico de rendimentos
              cpc.cdhsrgap,
              cpc.cdhsnrap
         FROM crapcpc cpc
        WHERE cpc.cdprodut = pr_cdprodut;
      rw_crapcpc cr_crapcpc%ROWTYPE;


      CURSOR cr_craprac IS
        SELECT cdcooper, nrdconta, nraplica, dtmvtolt, dtaniver, vlsldatl
        FROM craprac
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nraplica = pr_nraplica;
      rw_craprac cr_craprac%ROWTYPE;


      CURSOR cr_crapdat IS
        SELECT dtmvtolt
        FROM crapdat
        WHERE cdcooper = pr_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;


    BEGIN
      vr_cdcritic := NULL;

      -- Busca a data de movimento
      OPEN cr_crapdat;
      FETCH cr_crapdat
        INTO rw_crapdat;
      IF cr_crapdat%NOTFOUND THEN
        CLOSE cr_crapdat;
        vr_dscritic := 'Erro ao buscar a data de movimento.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapdat;
      END IF;

      -- Busca os dados da aplicação
      OPEN cr_craprac;
      FETCH cr_craprac
        INTO rw_craprac;
      IF cr_craprac%NOTFOUND THEN
        CLOSE cr_craprac;
        vr_dscritic := 'Aplicação não encontrada para a conta.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craprac;
      END IF;


      -- Obtém dados da aplicação poupança para buscar os históricos de: Rendimentos / Provisão / Reversão
      OPEN cr_crapcpc;
      FETCH cr_crapcpc
        INTO rw_crapcpc;
      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;


      -- Histórico provisão
      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsprap
                           ,pr_vltotmto  => vr_provisao
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Histórico reversão
      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsrvap
                           ,pr_vltotmto  => vr_reversao
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Histórico rendimentos
      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsrdap
                           ,pr_vltotmto  => vr_rendimento
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pr_vlultren := 0;
      -- Busca a taxa do dia de início do período, somente se a aplicação pode ser rentabilizada na data do movimento
      IF fn_pode_rentabilizar_poupanca(pr_cdcooper => pr_cdcooper
                                      ,pr_dtaniver =>  rw_craprac.dtaniver
                                      ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt) = 1 THEN

         IF pr_idcalren = 1 THEN
            pc_poupanca_clc_rendimento(pr_cdcooper                  => rw_craprac.cdcooper
                                      ,pr_nrdconta                  => rw_craprac.nrdconta
                                      ,pr_nraplica                  => rw_craprac.nraplica
                                      ,pr_dtaporte                  => rw_craprac.dtmvtolt
                                      ,pr_dtaniversario             => rw_craprac.dtaniver
                                      ,pr_cdhsnrap                  => rw_crapcpc.cdhsnrap
                                      ,pr_cdhsrgap                  => rw_crapcpc.cdhsrgap
                                      ,pr_vlrentabilidade_acumulada => vr_vlrentabilidade_acumulada
                                      ,pr_cdcritic                  => vr_cdcritic
                                      ,pr_dscritic                  => vr_dscritic);
            -- Valor último rendimento
            pr_vlultren := round(nvl(vr_vlrentabilidade_acumulada,0) - nvl(vr_rendimento,0),2);
         END IF;

         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;

      END IF;


      -- POPULA OS VALORES DE RETORNO DA PROCEDUR

      -- Calcula o Saldo Atual
      pr_vlsldtot := pr_vlaplica + pr_vlultren;

      -- Saldo total para resgate
      pr_vlsldrgt := pr_vlsldtot;

      -- Total dos Rendimentos
      pr_vlrentot := vr_rendimento;

      -- Valor de reversão
      pr_vlrevers := vr_provisao - vr_reversao;

      -- Calcular proporcional --
      IF pr_idtipbas = 1 THEN

        -- Total dos Rendimentos
        pr_vlrentot := trunc(pr_vlrentot * pr_vlbascal / rw_craprac.vlsldatl,2);

        -- Valor de reversão
        pr_vlrevers := trunc(pr_vlrevers * pr_vlbascal / rw_craprac.vlsldatl,2);

      END IF;
     
      -- Valor do IRRF
      pr_vlrdirrf := 0;

      -- Percentual do IRRF
      pr_percirrf := 0;

    EXCEPTION
      WHEN vr_exc_saida THEN
        vr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'pc_saldo_atual_poupanca');
        vr_dscritic := 'Erro nao tratado na pc_saldo_atual_poupanca. ' || SQLERRM;
    END;
  END pc_saldo_atual_poupanca;
  

BEGIN
   
  -- Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro  
  
  -- Em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
                          
  -- Em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
                         
  FOR rw_crapcpc IN cr_crapcpc LOOP                        
      vidtxfixa := rw_crapcpc.idtxfixa;  
      vcddindex := rw_crapcpc.cddindex;  
  END LOOP;
  
  FOR  rw_crapdat in cr_crapdat LOOP 
  
      FOR rw_craprac in cr_craprac(rw_crapdat.cdcooper) LOOP
       
        BACKUP('UPDATE CRAPRAC SET DTANIVER = ''01/02/2022'' WHERE CDCOOPER = '||rw_craprac.cdcooper ||' AND '||' NRDCONTA = '||rw_craprac.nrdconta|| ' AND NRAPLICA = '||rw_craprac.nraplica||';'); 
        loga ('cdcooper ; '||rw_craprac.cdcooper||' ; '||'nrdconta ; '||rw_craprac.nrdconta || ' ; '|| 'nraplica ; '||rw_craprac.nraplica) ;                          
        UPDATE craprac craprac 
           SET craprac.dtaniver = to_date('01/01/2022','dd/mm/yyyy') 
         WHERE craprac.cdcooper = rw_craprac.cdcooper
           AND craprac.nrdconta = rw_craprac.nrdconta
           AND craprac.nraplica = rw_craprac.nraplica;
           
           -- Inicializar parametros de saída
      pr_vlsldtot := 0;
      pr_vlsldrgt := 0;
      vr_vlultren := 0;
      pr_vlrentot := 0;
      pr_vlrevers := 0;
      pr_vlrdirrf := 0;
      pr_percirrf := 0;

          -- Chama procedure para produto com aniversario
            pc_saldo_atual_poupanca(pr_cdcooper => rw_craprac.cdcooper,           --> Código da cooperativa
                                             pr_nrdconta => rw_craprac.nrdconta,           --> Nr. da conta
                                             pr_nraplica => rw_craprac.nraplica,           --> Nr. da aplicação
                                             pr_vlaplica => rw_craprac.vlsldatl,           --> Saldo atualizado
                                             pr_cdprodut => rw_craprac.cdprodut,   --> Codigo do produto PCAPTA
                                             pr_idtipbas => 2,
                                             pr_idcalren => 1,
                                             pr_vlbascal => rw_craprac.vlbasapl,           --> Valor Base Cálculo
                                             pr_vlsldtot => pr_vlsldtot,           --> Valor saldo total da aplicação
                                             pr_vlsldrgt => pr_vlsldrgt,           --> Valor saldo total para resgate
                                             pr_vlultren => vr_vlultren,           --> Valor último rendimento
                                             pr_vlrentot => pr_vlrentot,           --> Valor rendimento total
                                             pr_vlrevers => pr_vlrevers,           --> Valor de reversão
                                             pr_vlrdirrf => pr_vlrdirrf,           --> Valor do IRRF
                                             pr_percirrf => pr_percirrf,           --> Percentual do IRRF
                                             pr_cdcritic => vr_cdcritic,           --> Código da crítica
                                             pr_dscritic => vr_dscritic);    
           
           -- tratamento para possiveis erros gerados pelas rotinas anteriores
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    RAISE vr_excsaida;
                  END IF;
                    
                  vr_negativo := false;
                  vr_cdhistor := rw_crapcpc.cdhsprap;
                    
                  -- se rendimento for negativo
                  IF vr_vlultren <= 0 THEN
                    -- remove o sinal e usa o historico de reversao de provisao
                    
                    CONTINUE;
                  END IF;
           
            -- LANÇA A RENTABILIDADE EM CONTA CORRENTE 
                LANC0001.pc_gerar_lancamento_conta( pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => 1 
                                                   ,pr_cdbccxlt => 100 
                                                   ,pr_nrdolote => 8599
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nrdctabb => rw_craprac.nrdconta
                                                   ,pr_nrdocmto => rw_craprac.nraplica --nraplica
                                                   ,pr_nrseqdig => vr_nrseqdig
                                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                   ,pr_vllanmto => vr_vlultren         -- Valor do resgate
                                                   ,pr_cdhistor => 362
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   -- OUTPUT --
                                                   ,pr_tab_retorno => vr_tab_retorno
                                                   ,pr_incrineg => vr_incrineg
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                   
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                              
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: ' || SQLERRM;
                  RAISE vr_excsaida;
            END IF; 
            
            vr_nrseqdig := vr_nrseqdig + 1;                                                                                                                                                                

      END LOOP;
      
  END LOOP;
    
  COMMIT;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
  
  EXCEPTION 
     WHEN vr_excsaida then  
         backup('ERRO ' || vr_dscritic);  
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1);    
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         backup('ERRO ' || vr_dscritic); 
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
         ROLLBACK; 

END;
