CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS132(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ..........................................................................

   Programa: PC_CRPS132            (Fontes/crps132.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/95.                        Ultima atualizacao: 01/12/2016

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 004.
               Emitir o acompanhamento do retorno dos emprestimos.
               Emite relatorio 109.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               10/11/2008 - Gera arquivo para Contabilidade - a ser importado
                            no Radar (Ze).

               24/12/2008 - Novos prazos(tarefa 21594) - Mirtes

               02/02/2009 - Acerto no calculo do acumulado para o arquivo
                            do Radar. Usar os 14 periodos. (Guilherme).

               02/03/2009 - Acerto no calculo do acumulado quando estiver
                            com zeros (Ze).

               03/09/2010 - Inserir o valor de retorno na crapprb separado
                            por prazos. Tarefa 34546 (Henrique).

               05/10/2010 - Inclusao de prazos. Serao utilizados 19 periodos.
                            (Henrique)

               26/10/2010 - Separar Emprestimo X Financiamento no relatorio
                            e arquivo enviado a contabilidade.
                            (Joao-RKAM / Irlan).

               30/04/2012 - Substituir qtprepag por qtprecal. (Irlan)

               23/05/2013 - Alteracao no processo de geracao relatorio
                            e implementacao de carencia (Daniel).

               13/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               20/02/2014 - Correção ref. execucao na cadeia. Alterado o tipo das
                            variaveis vr_vlmensal, vr_vlsaldev, vr_saldodev de
                            crapepr.vlsdeved%type para number(25,2). (Edison-AMcom)

               22/08/2016 - Adicionado operações de financiamento do BNDES 
							              no relatório 109. (Reinert)

               01/12/2016 - Ajuste para zerar a vr_tab_financ(vr_idfina).qtfinanc
							              quando nao tem valor para 5400 dias / 181 meses.
                            (Jaison/Diego - SD: 534498)

............................................................................. */

  DECLARE
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS132';
    -- Tratamento de erros
    vr_exc_erro exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
            ,cop.nrctactl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor generico de calendario */
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

    --Ler Cadastro de emprestimos
    CURSOR cr_crapepr (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cdlcremp,
             nrdconta,
             nrctremp,
             qtpreemp,
             qtprecal,
             vlsdeved,
             cdagenci,
             nrdolote
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.inliquid = 0
         AND crapepr.vlsdeved > 0;

    -- Financiamentos BNDES
    CURSOR cr_crapebn(pr_cdcooper IN craptab.cdcooper%TYPE) IS
		  SELECT ebn.vlaven30 -- Divida a vencer ate 30 dias.
			      ,ebn.vlaven60 -- Divida a vender de 31 a 60 dias.
						,ebn.vlaven90 -- Divida a vencer de 61 a 90 dias.
						,ebn.vlave180 -- Divida a vencer de 91 a 180 dias.
						,ebn.vlave360 -- Divida a vencer de 181 a 360 dias.
						,ebn.vlave720 -- Divida a vencer de 361 a 720 dias.
						,ebn.vlav1080 -- Divida a vencer de 721 a 1080 dias.
						,ebn.vlav1440 -- Divida a vencer de 1081 a 1440 dias.
						,ebn.vlav1800 -- Divida a vencer de 1441 a 1800 dias.
						,ebn.vlav5400 -- Divida a vencer de 1801 a 5400 dias.
						,ebn.vlaa5400 -- Divida a vencer acima de 5400 dias.
			  FROM crapebn ebn
			 WHERE ebn.cdcooper = pr_cdcooper
			   AND ebn.insitctr IN('N','A');

    -- Ler Cadastro de Linhas de Credito
    CURSOR cr_craplcr (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_cdlcremp in crapepr.cdlcremp%TYPE) IS
      SELECT dsoperac
        FROM craplcr cr
       WHERE cr.progress_recid =
                 (SELECT MIN(cr1.progress_recid) -- FIND FIRST
                    FROM craplcr cr1
                   WHERE cr1.cdcooper = pr_cdcooper
                     AND cr1.cdlcremp = pr_cdlcremp);
    rw_craplcr cr_craplcr%rowtype;

    -- ler primeiro resgistro cadastro de emprestimos
    CURSOR cr_crawepr (pr_cdcooper IN craptab.cdcooper%TYPE,
                       pr_nrdconta in crapepr.nrdconta%TYPE,
                       pr_nrctremp in crapepr.nrctremp%TYPE) IS
      SELECT dtdpagto
        FROM crawepr e
       WHERE e.progress_recid =
               (SELECT MIN(e1.progress_recid) -- FIND FIRST
                  FROM crawepr e1
                 WHERE e1.cdcooper = pr_cdcooper
                   AND e1.nrdconta = pr_nrdconta
                   AND e1.nrctremp = pr_nrctremp);
    rw_crawepr cr_crawepr%ROWTYPE;


    --Type para armazenar os valores do financiamento/emprestimo
    type typ_reg_financ is record ( qtdiames number,
                                    retfinan number,
                                    qtfinanc number,
                                    retempre number,
                                    qtempres number);

    type typ_tab_reg_financ is table of typ_reg_financ
                           index by binary_integer;
    vr_tab_financ typ_tab_reg_financ;

    --Type para armazenar os valores acumulados de financiamento/emprestimo
    type typ_reg_acumul is record ( vlacufin number,
                                    vlacuemp number,
                                    vltotacu number);

    type typ_tab_reg_acumul is table of typ_reg_acumul
                           index by binary_integer;
    vr_tab_acumul typ_tab_reg_acumul;

    -- Variaveis de controle
    vr_qtdiacar number;
    vr_qtpreres integer;

    -- Variaveis utilizadas para calculo dos valores no periodo
    vr_vlmensal NUMBER(25,2) := 0;
    vr_vlsaldev NUMBER(25,2) := 0;
    vr_saldodev NUMBER(25,2) := 0;
    vr_saldoacu number;
    vr_idfina   number;
    vr_nrmes    number;
    vr_desperio varchar2(30);

    --Valores acumulados para enviar para a contabilidade
    vr_vlacempr NUMBER;
    vr_vlacfina NUMBER;
    -- Variavel para armazenar as informacos em XML
    vr_des_xml       clob;
    vr_linhadet      varchar2(500);

    -- Variavel para criacao do relatorio
    vr_nom_direto    varchar2(100);
    vr_nom_arquivo   varchar2(100);
    vr_nom_dirmic    varchar2(100);
    vr_dscomando     varchar2(4000);
    vr_typ_saida     varchar2(100);

    --Handle do arquivo
    vr_utlfileh      UTL_FILE.file_type;

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;
    END;

    /*Procedimento para calcular os valores de saldo acumulado conforme o periodo restante*/
    PROCEDURE pc_calc_salacu(pr_qtdiacar   in number,
                             pr_nrdmes     in number,
                             pr_nrdmes_ant in number,
                             pr_qtdmes     in number,
                             pr_dsoperac   in craplcr.dsoperac%type,
                             pr_idfina     in number,
                             pr_qtpreres   in out number,
                             pr_vlmensal   in out number,
                             pr_vlsaldev   in out number,-- saldo restante
                             pr_saldodev   in out number,-- saldo total
                             pr_saldoacu   in out number
                              )is

      vr_qtdprest NUMBER;
      vr_vldivida NUMBER;

      -- Calcular diferenca para atribuir a ultima parcela
      PROCEDURE pc_compara_valores(pr_saldoacd in number,
                                   pr_saldoded in number,
                                   pr_vldividd in out number) IS
        vr_diferenc number:=0;
      BEGIN
        vr_diferenc := pr_saldoded - pr_saldoacd;

        IF vr_diferenc <> 0 THEN
          pr_vldividd := pr_vldividd + vr_diferenc;
        END IF;

      END pc_compara_valores;

    BEGIN

      IF pr_qtdiacar <= pr_nrdmes THEN
        -- Se estiver calculado do mes 181,
        -- deve usar para o calculo a qtd de parcelas restantes
        IF pr_nrdmes = 181 THEN
          vr_qtdprest := pr_qtpreres;
        ELSIF (pr_qtpreres - pr_nrdmes) > 0 THEN
          -- caso a qtd de parcelas restantes menos a qtd de mes sendo calculada for maior que zer
          -- usar a qtd mes menos o mes anterior
          vr_qtdprest := pr_nrdmes - pr_nrdmes_ant;
        ELSIF pr_qtpreres >= pr_qtdmes and
              pr_nrdmes <> 3 THEN
          --caso a qtd de parc. restantes for maior ou igual a qtd de meses usado como faixa
          -- e se for diferente do mes 3, usar a qtd de meses para o calculo
          vr_qtdprest := pr_qtdmes;
        ELSE
          --senao usar a qtd parc. restantes
          vr_qtdprest := pr_qtpreres;
        END IF;

        -- verificar se existem parcelas para calcular
        IF (pr_nrdmes = 3 and vr_qtdprest > 0) or
           (pr_nrdmes <> 3 and pr_qtpreres >  0) THEN

          -- Calcular valores
          --calcular valor devido no periodo
          vr_vldivida := pr_vlmensal * vr_qtdprest;
          -- diminuir do valor total devido o valor desse periodo
          pr_vlsaldev := pr_vlsaldev - vr_vldivida;
          -- diminuir parcela
          pr_qtpreres := pr_qtpreres - vr_qtdprest;
          -- acrescetar valor no saldo acumulado
          pr_saldoacu := pr_saldoacu + vr_vldivida;

          --caso seja a ulima parcela, calcular a diferenca
          IF pr_qtpreres = 0 THEN
            pc_compara_valores(pr_saldoacd => pr_saldoacu,
                               pr_saldoded => pr_saldodev,
                               pr_vldividd => vr_vldivida);
          END IF;

          vr_tab_financ(pr_idfina).qtdiames := pr_nrdmes*30;

          -- Armazenar valores
          IF pr_dsoperac = 'FINANCIAMENTO' THEN
            vr_tab_financ(pr_idfina).retfinan := nvl(vr_tab_financ(pr_idfina).retfinan,0) + vr_vldivida;
            vr_tab_financ(pr_idfina).qtfinanc := nvl(vr_tab_financ(pr_idfina).qtfinanc,0) + 1;

          ELSE /* EMPRESTIMO */
            vr_tab_financ(pr_idfina).retempre := nvl(vr_tab_financ(pr_idfina).retempre,0) + vr_vldivida;
            vr_tab_financ(pr_idfina).qtempres := nvl(vr_tab_financ(pr_idfina).qtempres,0) + 1;

          END IF;-- FIM  pr_dsoperac

        END IF;-- FIM pr_qtpreres
      END IF;
    END pc_calc_salacu;

    PROCEDURE pc_cria_crapprb (pr_vlretorn IN crapprb.vlretorn%TYPE,
                               pr_cddprazo IN NUMBER,
                               pr_dtmvtolt IN crapdat.dtmvtolt%type,
                               pr_nrctactl IN crapcop.nrctactl%type,
                               pr_dscritic out varchar2 ) IS
      vr_cddprazo NUMBER;
    BEGIN
      SELECT
        CASE pr_cddprazo
         WHEN 1  THEN 90
         WHEN 2  THEN 180
         WHEN 3  THEN 270
         WHEN 4  THEN 360
         WHEN 5  THEN 720
         WHEN 6  THEN 1080
         WHEN 7  THEN 1440
         WHEN 8  THEN 1800
         WHEN 9  THEN 2160
         WHEN 10 THEN 2520
         WHEN 11 THEN 2880
         WHEN 12 THEN 3240
         WHEN 13 THEN 3600
         WHEN 14 THEN 3960
         WHEN 15 THEN 4320
         WHEN 16 THEN 4680
         WHEN 17 THEN 5040
         WHEN 18 THEN 5400
         WHEN 19 THEN 5401
       END
      INTO vr_cddprazo
      FROM dual;

      BEGIN
        --Gravar prazos e valor de retorno de emprestimos
        -- para levantamento de informacoes solicitadas pelo BNDES.
        INSERT INTO crapprb
                 (cdcooper,
                  dtmvtolt,
                  cdorigem,
                  nrdconta,
                  cddprazo,
                  vlretorn)
               VALUES
                 (3,           --cdcooper(3-CECRED)
                  pr_dtmvtolt, --dtmvtolt
                  3,           --cdorigem(3-Emprestimo)
                  pr_nrctactl, --nrdconta
                  vr_cddprazo, --cddprazo
                  pr_vlretorn);-- vlretorn
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao inserir crapprb: '||SQLErrm;
      END;

    END pc_cria_crapprb;


  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    --Inicializar array, com os meses para mesmo se n?o houver valores no periodo exibir no relatorio.
    FOR vr_idx IN 1..19 LOOP
      IF vr_idx <= 4 THEN
        vr_tab_financ(vr_idx).qtdiames := (vr_idx*3)*30;
      ELSE
        vr_tab_financ(vr_idx).qtdiames :=  vr_tab_financ(vr_idx-1).qtdiames+360;
      END IF;
    END LOOP;

    --Ler Cadastro de emprestimos
    FOR rw_crapepr in cr_crapepr(pr_cdcooper => pr_cdcooper) LOOP
      
      -- Verificar se existe Cadastro de Linhas de Credito
      OPEN cr_craplcr( pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr
       INTO rw_craplcr;
      -- Se nao encontrar abortar programa
      IF cr_craplcr%NOTFOUND THEN
        CLOSE cr_craplcr;
        vr_dscritic := 'Linha de Credito nao cadastrada: '||rw_crapepr.cdlcremp ||
                       '. Cod.Cooper.: '||pr_cdcooper ||
                       ', Conta: " '||rw_crapepr.nrdconta;

        raise vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_craplcr;
      END IF;

      vr_qtdiacar := 0;

      -- ler primeiro resgistro cadastro de emprestimos
      OPEN cr_crawepr( pr_cdcooper => pr_cdcooper ,
                       pr_nrdconta => rw_crapepr.nrdconta ,
                       pr_nrctremp => rw_crapepr.nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      -- Se nao encontrar abortar programa
      IF cr_crawepr%NOTFOUND THEN
        -- Apenas fechar o cursor
        CLOSE cr_crawepr;
      ELSE
        IF rw_crapdat.dtmvtolt < rw_crawepr.dtdpagto THEN /* Esta na Carencia */
          vr_qtdiacar := rw_crawepr.dtdpagto - rw_crapdat.dtmvtolt;
          vr_qtdiacar := vr_qtdiacar / 30;
          vr_qtdiacar := TRUNC(vr_qtdiacar,0);
        END IF;
        CLOSE cr_crawepr;
      END IF;

      -- qtd de prestacoes restantes(inteiro) = Qtd de prestacoes do emprestimo. - Qtd de prestacoes calculadas.
      vr_qtpreres := rw_crapepr.qtpreemp - rw_crapepr.qtprecal;

      IF vr_qtpreres < 0 THEN
        vr_qtpreres := vr_qtpreres * -1;
      ELSIF vr_qtpreres = 0 THEN
        vr_qtpreres := 1;
      END IF;

      -- Iniciar valores
      vr_vlmensal := rw_crapepr.vlsdeved / vr_qtpreres;
      vr_vlsaldev := rw_crapepr.vlsdeved;
      vr_saldodev := rw_crapepr.vlsdeved;
      vr_saldoacu := 0;
      vr_idfina   := 1;

      /* Dias        Meses
          90           3
          180          6
          270          9
          360         12
          720         24
          1080        36
          1440        48
          1800        60
          2160        72
          2520        84
          2880        96
          3240        108
          3600        120
          3960        132
          4320        144
          4680        156
          5040        168
          5400        180
          MAIS DE 5400 DIAS*/



      -- 3 Meses
      pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                     pr_nrdmes     => 3,
                     pr_nrdmes_ant => 0,
                     pr_qtdmes     => 3,
                     pr_dsoperac   => rw_craplcr.dsoperac,
                     pr_idfina     => vr_idfina,
                     pr_qtpreres   => vr_qtpreres,
                     pr_vlmensal   => vr_vlmensal,
                     pr_vlsaldev   => vr_vlsaldev,
                     pr_saldodev   => vr_saldodev,
                     pr_saldoacu   => vr_saldoacu);

      vr_idfina := vr_idfina +1;

      -- 6 Meses
      pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                     pr_nrdmes     => 6,
                     pr_nrdmes_ant => 3,
                     pr_qtdmes     => 3,
                     pr_dsoperac   => rw_craplcr.dsoperac,
                     pr_idfina     => vr_idfina,
                     pr_qtpreres   => vr_qtpreres,
                     pr_vlmensal   => vr_vlmensal,
                     pr_vlsaldev   => vr_vlsaldev,
                     pr_saldodev   => vr_saldodev,
                     pr_saldoacu   => vr_saldoacu);

      vr_idfina := vr_idfina +1;

      -- 9 Meses
      pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                     pr_nrdmes     => 9,
                     pr_nrdmes_ant => 6,
                     pr_qtdmes     => 3,
                     pr_dsoperac   => rw_craplcr.dsoperac,
                     pr_idfina         => vr_idfina,
                     pr_qtpreres   => vr_qtpreres,
                     pr_vlmensal   => vr_vlmensal,
                     pr_vlsaldev   => vr_vlsaldev,
                     pr_saldodev   => vr_saldodev,
                     pr_saldoacu   => vr_saldoacu);

      vr_idfina := vr_idfina +1;

      -- 12 Meses
      pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                     pr_nrdmes     => 12,
                     pr_nrdmes_ant => 9,
                     pr_qtdmes     => 3,
                     pr_dsoperac   => rw_craplcr.dsoperac,
                     pr_idfina     => vr_idfina,
                     pr_qtpreres   => vr_qtpreres,
                     pr_vlmensal   => vr_vlmensal,
                     pr_vlsaldev   => vr_vlsaldev,
                     pr_saldodev   => vr_saldodev,
                     pr_saldoacu   => vr_saldoacu);


      vr_nrmes := 24;

      -- Calcular/Gravar do mes 24 ao mes 180(de 12 em 12 meses)
      LOOP
        EXIT WHEN vr_nrmes > 180;

        vr_idfina := vr_idfina +1;
        pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                       pr_nrdmes     => vr_nrmes,
                       pr_nrdmes_ant => vr_nrmes-12,
                       pr_qtdmes     => 12,
                       pr_dsoperac   => rw_craplcr.dsoperac,
                       pr_idfina     => vr_idfina,
                       pr_qtpreres   => vr_qtpreres,
                       pr_vlmensal   => vr_vlmensal,
                       pr_vlsaldev   => vr_vlsaldev,
                       pr_saldodev   => vr_saldodev,
                       pr_saldoacu   => vr_saldoacu);

        vr_nrmes := vr_nrmes + 12;
      END LOOP;

      vr_idfina := vr_idfina +1;
      -- >5400 dias -> 181 Meses
      pc_calc_salacu(pr_qtdiacar   => vr_qtdiacar,
                     pr_nrdmes     => 181,
                     pr_nrdmes_ant => 180,
                     pr_qtdmes     => 12,
                     pr_dsoperac   => rw_craplcr.dsoperac,
                     pr_idfina     => vr_idfina,
                     pr_qtpreres   => vr_qtpreres,
                     pr_vlmensal   => vr_vlmensal,
                     pr_vlsaldev   => vr_vlsaldev,
                     pr_saldodev   => vr_saldodev,
                     pr_saldoacu   => vr_saldoacu);

    END LOOP; /*  Fim do FOR --  Leitura dos resgates programados  */
		
		-- Empréstimos do BNDES
		FOR rw_crapebn IN cr_crapebn(pr_cdcooper => pr_cdcooper) LOOP
			
      -- 90 dias / 3 meses
			vr_idfina := 1;
			vr_nrmes := 3;
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlaven30 + rw_crapebn.vlaven60 + rw_crapebn.vlaven90;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;
				
      -- 180 dias / 6 meses
			vr_idfina := 2;
			vr_nrmes := 6;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlave180;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;

      -- 360 dias / 12 meses
			vr_idfina := 4;
			vr_nrmes := 12;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlave360;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;
			
      -- 720 dias / 24 meses
			vr_idfina := 5;
			vr_nrmes := 24;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlave720;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;
			
      -- 1080 dias / 36 meses
			vr_idfina := 6;
			vr_nrmes := 36;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlav1080;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;

      -- 1440 dias / 48 meses
			vr_idfina := 7;
			vr_nrmes := 48;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlav1440;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;
			
      -- 1800 dias / 60 meses
			vr_idfina := 8;
			vr_nrmes := 60;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlav1800;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;

      -- 5400 dias / 180 meses
			vr_idfina := 18;
			vr_nrmes := 180;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlav5400;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0) + 1;

      -- >5400 dias / 181 meses
			vr_idfina := 19;
			vr_nrmes := 181;			
			vr_tab_financ(vr_idfina).qtdiames := vr_nrmes*30;
			vr_tab_financ(vr_idfina).retfinan := nvl(vr_tab_financ(vr_idfina).retfinan,0) + rw_crapebn.vlaa5400;
			vr_tab_financ(vr_idfina).qtfinanc := nvl(vr_tab_financ(vr_idfina).qtfinanc,0)
                                         + (CASE WHEN rw_crapebn.vlaa5400 > 0 THEN 1 ELSE 0 END);
		END LOOP;

    --Armazenar valores acumulados
    FOR vr_idx in 1..19 LOOP
      -- Se for o primeiro somente atribui
      if vr_idx = 1 then
        vr_tab_acumul(vr_idx).vlacuemp  := nvl(vr_tab_financ(vr_idx).retempre,0);
        vr_tab_acumul(vr_idx).vlacufin  := nvl(vr_tab_financ(vr_idx).retfinan,0);
        vr_tab_acumul(vr_idx).vltotacu  := nvl(vr_tab_financ(vr_idx).retempre,0)
                                           + nvl(vr_tab_financ(vr_idx).retfinan,0);
      elsif vr_tab_financ.exists(vr_idx) then

        vr_tab_acumul(vr_idx).vlacuemp  := nvl(vr_tab_acumul(vr_idx-1).vlacuemp,0)
                                           + nvl(vr_tab_financ(vr_idx).retempre,0);

        vr_tab_acumul(vr_idx).vlacufin  := nvl(vr_tab_acumul(vr_idx-1).vlacufin,0)
                                           + nvl(vr_tab_financ(vr_idx).retfinan,0);

        vr_tab_acumul(vr_idx).vltotacu  := nvl(vr_tab_acumul(vr_idx-1).vltotacu,0)
                                           + nvl(vr_tab_financ(vr_idx).retempre,0)
                                           + nvl(vr_tab_financ(vr_idx).retfinan,0);

      else
        vr_tab_acumul(vr_idx).vlacufin  := 0;
      end if;

    END LOOP;

    --Limpar vl acumulado do periodo no qual n?o exista valor no periodo
    FOR vr_idx in 1..19 LOOP
      if  nvl(vr_tab_financ(vr_idx).retempre,0) = 0 and
          nvl(vr_tab_financ(vr_idx).qtempres,0) = 0 then
        vr_tab_acumul(vr_idx).vlacuemp  := 0;
      end if;

      if  nvl(vr_tab_financ(vr_idx).retfinan,0) = 0 and
          nvl(vr_tab_financ(vr_idx).qtfinanc,0) = 0 then
        vr_tab_acumul(vr_idx).vlacufin  := 0;
      end if;

      if  nvl(vr_tab_acumul(vr_idx).vlacufin,0) = 0 and
          nvl(vr_tab_acumul(vr_idx).vlacuemp,0) = 0 then
        vr_tab_acumul(vr_idx).vltotacu  := 0;
      end if;


    END LOOP;

    -- Inicializar o CLOB
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    pc_escreve_xml('<periodo desmes="'||gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'
                                      ||to_char(rw_crapdat.dtmvtolt,'RRRR')||'">');
    -- Gerar XML para o relatorio
    FOR vr_idx in 1..vr_tab_acumul.count LOOP
      -- Montar descricao do periodo
      IF vr_tab_financ(vr_idx).qtdiames > 5400 THEN
        vr_desperio := 'MAIS DE 5400 DIAS';
      ELSE
        vr_desperio := 'ATE '||lpad(vr_tab_financ(vr_idx).qtdiames,4,' ')||' DIAS';
      END IF;

      pc_escreve_xml('<detalhes>
                         <desperio>'||vr_desperio                          ||'</desperio>
                         <retempre>'||nvl(vr_tab_financ(vr_idx).retempre,0)||'</retempre>
                         <qtempres>'||nvl(vr_tab_financ(vr_idx).qtempres,0)||'</qtempres>
                         <vlacuemp>'||nvl(vr_tab_acumul(vr_idx).vlacuemp,0)||'</vlacuemp>
                         <vlacufin>'||nvl(vr_tab_acumul(vr_idx).vlacufin,0)||'</vlacufin>
                         <retfinan>'||nvl(vr_tab_financ(vr_idx).retfinan,0)||'</retfinan>
                         <qtfinanc>'||nvl(vr_tab_financ(vr_idx).qtfinanc,0)||'</qtfinanc>
                         <vltotacu>'||nvl(vr_tab_acumul(vr_idx).vltotacu,0)||'</vltotacu>
                      </detalhes>');

    END LOOP;
    -- Busca do diretorio base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    vr_nom_arquivo:= 'crrl109';
    pc_escreve_xml('</periodo>');

    vr_des_xml    := '<?xml version="1.0" encoding="utf-8"?><crrl109>'||vr_des_xml||'</crrl109>';

    -- Solicitar impressao
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl109'          --> No base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl109.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                --> Enviar como parametro apenas a agencia
                               ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final com codigo da agencia
                               ,pr_qtcoluna  => 234                 --> 132 colunas
                               ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                               ,pr_flg_gerar => 'N'                 --> gerar na hora
                               ,pr_nmformul  => '234dh'             --> Nome do formulario para impress?o
                               ,pr_nrcopias  => 1                   --> Numero de copias
                               ,pr_des_erro  => vr_dscritic);       --> Saida com erro

    IF vr_dscritic IS NOT NULL THEN
      -- Gerar excecao
      raise vr_exc_erro;
    END IF;

    /* Gerar Informacoes para o BNDES */
    IF pr_cdcooper <> 3 THEN -- 3- CECRED
      FOR vr_idx IN 1..19 LOOP
        IF (nvl(vr_tab_financ(vr_idx).retempre,0)+
            nvl(vr_tab_financ(vr_idx).retfinan,0)) > 0 THEN

          pc_cria_crapprb (pr_vlretorn => (nvl(vr_tab_financ(vr_idx).retempre,0)+
                                           nvl(vr_tab_financ(vr_idx).retfinan,0)),
                           pr_cddprazo => vr_idx,
                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                           pr_nrctactl => rw_crapcop.nrctactl,
                           pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
            vr_dscritic := NULL;
          END IF;

        END IF;
      END LOOP;
    END IF; -- Fim informacoes para o BNDES

    /* Gera arquivo para a Contabilidade - a ser importado no Radar */

    /* EMPRESTIMOS */
    FOR vr_idx IN REVERSE 1..19 LOOP--percorrer do 19 at? o 1(REVERSE)

      IF vr_tab_acumul(vr_idx).vlacuemp > 0 THEN
        vr_vlacempr := vr_tab_acumul(vr_idx).vlacuemp
                       - vr_tab_acumul(1).vlacuemp;
        exit; --sair do loop

      ELSIF vr_idx = 1 THEN
        vr_vlacempr := vr_tab_acumul(1).vlacuemp;
        exit; --sair do loop
      END IF;

    END LOOP;

    /* FINANCIAMENTOS */
    FOR vr_idx IN REVERSE 1..19 LOOP --percorrer do 19 at? o 1(REVERSE)

      IF vr_tab_acumul(vr_idx).vlacufin > 0 THEN
        vr_vlacfina := vr_tab_acumul(vr_idx).vlacufin
                       - vr_tab_acumul(1).vlacufin;
        exit; --sair do loop

      ELSIF vr_idx = 1 THEN
        vr_vlacfina := vr_tab_acumul(1).vlacufin;
        exit; --sair do loop
      END IF;

    END LOOP;

    -- Busca do diretorio base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/contab'); --> Utilizaremos o contab
    -- Busca do diretorio micros da cooperativa
    vr_nom_dirmic := gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/contab'); --> Utilizaremos o contab
    -- Montagem do nome do arquivo
    vr_nom_arquivo:= to_char(rw_crapdat.dtmvtolt,'RRMMDD')||'_7.txt';

    -- criar arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_direto  --> Diretorio do arquivo
                            ,pr_nmarquiv => vr_nom_arquivo --> Nome do arquivo
                            ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_utlfileh    --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Emprestimo
    IF vr_vlacempr <> 0 THEN
      vr_linhadet :=  to_char(rw_crapdat.dtmvtolt,'RRRRMMDD')||','||
                      TRIM(to_char(rw_crapdat.dtmvtolt,'DDMMRR'))||
                      ',3993,9294,'||
                      TRIM(gene0002.fn_mask(vr_vlacempr * 100,'zzzzzzzzzzzzz9.99'))||
                      ',,"EMPRESTIMO COM RETORNO SUPERIOR A 90 DIAS"';

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet );--> Texto para escrita
      --REVERSAO
      vr_linhadet :=  to_char(rw_crapdat.dtmvtopr,'RRRRMMDD')||','||
                      TRIM(to_char(rw_crapdat.dtmvtopr,'DDMMRR'))||
                      ',9294,3993,'||
                      TRIM(gene0002.fn_mask(vr_vlacempr * 100,'zzzzzzzzzzzzz9.99'))||
                      ',,"REVERSAO SALDO EMPRESTIMO C/RETORNO ACIMA DE 90 DIAS"';

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet );--> Texto para escrita
    END IF;

    -- Financiamento
    IF vr_vlacfina <> 0 THEN
      vr_linhadet :=  to_char(rw_crapdat.dtmvtolt,'RRRRMMDD')||','||
                      TRIM(to_char(rw_crapdat.dtmvtolt,'DDMMRR'))||
                      ',3985,9294,'||
                      TRIM(gene0002.fn_mask(vr_vlacfina * 100,'zzzzzzzzzzzzz9.99'))||
                      ',,"FINANCIAMENTO COM RETORNO SUPERIOR A 90 DIAS"';

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet );--> Texto para escrita

      --REVERSAO
      vr_linhadet :=  to_char(rw_crapdat.dtmvtopr,'RRRRMMDD')||','||
                      TRIM(to_char(rw_crapdat.dtmvtopr,'DDMMRR'))||
                      ',9294,3985,'||
                      TRIM(gene0002.fn_mask(vr_vlacfina * 100,'zzzzzzzzzzzzz9.99'))||
                      ',,"REVERSAO SALDO FINANCIAMENTO C/RETORNO ACIMA DE 90 DIAS"';

      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh   --> Handle do arquivo aberto
                                    ,pr_des_text => vr_linhadet );--> Texto para escrita

    END IF;

    gene0001.pc_fecha_arquivo(pr_utlfileh =>vr_utlfileh); --> Handle do arquivo aberto

    -- Ao final, converter o arquivo para DOS e enviá-lo a pasta micros/<dsdircop>/contab
    vr_dscomando := 'ux2dos '||vr_nom_direto||'/'||vr_nom_arquivo||' > '||
                               vr_nom_dirmic||'/'||vr_nom_arquivo||' 2>/dev/null';
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel executar comando unix de conversão: '||vr_dscomando||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
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
END;
/
