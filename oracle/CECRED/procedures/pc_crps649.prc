CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS649 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                       ,pr_flgresta  IN PLS_INTEGER
                                       ,pr_stprogra OUT PLS_INTEGER
                                       ,pr_infimsol OUT PLS_INTEGER
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) AS
/* ............................................................................

   Programa: PC_CRPS649                       Antigo: fontes/crps649.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Julho/2013                        Ultima atualizacao: 28/09/2016

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Gerar relatorios crrl658, crrl659 (por convenio) e crrl660.
               Sol. 4  / Ordem 43 / Cadeia 43 / Exclusividade = 3 (cecred)

   Alteracoes: 07/10/2013 - Incluido temp-table tt-rel660 e efetuado tratamento
                            para listar campos pela tt-rel660.quanti_total DESC
                            (Lucas R.)

               11/11/2013 - Conversão Progress => Oracle (Gabriel).

               09/12/2014 - Ajustando a solicitacao dos relatorios 659 e 660
                            SD 218482 (Andre Santos - SUPERO).

               05/03/2015 - Ajustando relatório 659, pois estava considerando
                            valores de lancamentos de contas migradas que ja
                            foram somadas na cooperativa nova. Esses registros
                            serao desconsiderados pelo processo. Para verificar
                            se o processo esta gerando corretamente o relatorio
                            mensal, deve-se olhar o relatorio 348 diario por
                            convenio. SD 256658 (Andre Santos - SUPERO).

               10/04/2015 - Alterar o programa afim de que o mesmo passe a gerar
                            também os relatórios que eram gerados pelo crps664.
                            O programa se baseará na cooperativa para se orientar
                            quanto a qual relatório deverá ser gerado. ( Renato - Supero)

               04/12/2015 - Retirar trecho do código onde faz a reversão (Lucas Ranghetti #326987 )
               
        			 28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                            P308 (Ricardo Linhares).
               
.............................................................................*/
  -- Variaveis de uso no programa
  vr_cdprogra        crapprg.cdprogra%TYPE := 'CRPS649';  -- Codigo do presente programa
  vr_cdprogra_rel    crapprg.cdprogra%TYPE;        -- Codigo do programa para gerar o relatório
  vr_sqcabrel        NUMBER;                       -- Sequencia de do relatório
  vr_cdcooper        crapcop.cdcooper%TYPE;        -- Codigo Da Cooperativa
  vr_nmrescop        crapcop.nmrescop%TYPE;        -- Nome da cooperativa
  vr_dtmvtolt        crapdat.dtmvtolt%TYPE;        -- Data do movimento
  vr_dtinimes        crapdat.dtmvtolt%TYPE;        -- Data inicio mes
  vr_dtfimmes        crapdat.dtmvtolt%TYPE;        -- Data fim mes
  vr_inpessoa        crapass.inpessoa%TYPE;        -- Indicador de pessoa
  vr_cdagenci        crapass.cdagenci%TYPE;        -- Código da agencia
  vr_cdageass        crapass.cdagenci%TYPE;        -- Código da agencia do associado
  vr_nrctaaux        NUMBER;                       -- Número da conta - variável auxiliar
  vr_nrctaori        NUMBER;                       -- Número da conta de origem para o arquivo
  vr_nrctades        NUMBER;                       -- Número da conta de destino para o arquivo
  vr_dsmensag        VARCHAR2(100);                -- Mensagem de cabeçalho do arquivo
  vr_dsmsgarq        VARCHAR2(120);                -- Mensagem de cabeçalho do arquivo completa
  vr_dsprefix        CONSTANT VARCHAR2(15) := 'REVERSAO '; -- Prefixo para cabe?alho do arquivo
  vr_dsdchave_659    VARCHAR2(30);                 -- Chave para tabela de convenios do rel. 659
  vr_dsdchave_660    VARCHAR2(30);                 -- Chave para tabela de convenios do rel. 660
  vr_dsdchave_671    VARCHAR2(30);                 -- Chave para tabela de convenios do rel. 671
  vr_dsdchave_nw_660 VARCHAR2(30);                 -- Nova chave para o relatorio 660
  vr_vltarifa        NUMBER(20,2);                 -- Valor da tarifa
  vr_cdconven        NUMBER(4);                    -- Codigo do convenio
  vr_contador        NUMBER(1);                    -- Contador para meio de pagamento
  vr_dsmeiola        VARCHAR2(20);                 -- Descricao meio de lancamento
  vr_valorpag        NUMBER(20,2);                 -- Valor pago COBAN
  vr_qtvlrpag        NUMBER(10);                   -- Quantidade COBAN
  vr_vltarpag        NUMBER(20,2);                 -- Valor tarifa COBAN
  vr_qtlancam        NUMBER(20);                   -- Quantidade de lancamento por convenio
  vr_vltotcvn        NUMBER;                       -- Valor total do convenio
  vr_nmarquiv        VARCHAR2(100);                -- Nomes dos arquivos gerados
  vr_cdcritic        crapcri.cdcritic%TYPE;        -- Codigo da critica
  vr_dscritic        VARCHAR2(2000);               -- Descricao da critica
  vr_dslinarq        VARCHAR2(200);                -- Linha que será escrita no arquivo
  vr_dsxmldad_658    CLOB;                         -- Relatorio 658
  vr_dsxmldad_659    CLOB;                         -- Relatorio 659
  vr_dsxmldad_660    CLOB;                         -- Relatorio 660
  vr_dsxmldad_arq    CLOB;                         -- Arquivo de informação de tarifas
  vr_nom_direto      VARCHAR2(100);                -- Diretorio /coop/rl
  vr_nmarqtxt        VARCHAR2(100);                -- Nome do arquivo RDC
  vr_dscomand        VARCHAR2(500);                -- comando Unix
  vr_exc_saida       EXCEPTION;                    -- Exeption parar cadeia
  vr_exc_fimprg      EXCEPTION;                    -- Exception para rodar fimprg
  vr_typ_saida       VARCHAR2(2000);               -- controle de erros de scripts unix

  -- Registro para armazenar os convenios
  TYPE typ_reg_convenio IS
    RECORD(cdcooper craplft.cdcooper%TYPE
          ,cdconven gnconve.cdconven%TYPE
          ,dtmvtolt craplft.dtmvtolt%TYPE
          ,nmrescop crapcop.nmrescop%TYPE
          ,nmempres VARCHAR2(50)
          ,vllanmto NUMBER(20,2)
          ,dsmeiola VARCHAR2(10)
          ,vltarifa NUMBER(20,2)
          ,qtlancam NUMBER(20));

  -- Tabela para armazenar os convenios por cooperativa
  TYPE typ_tab_convenio_658 IS
    TABLE OF typ_reg_convenio
      INDEX BY PLS_INTEGER;

  -- Tabela para armazenar os convenios por data e convenio e meio de lancamento
  TYPE typ_tab_convenio_659 IS
    TABLE OF typ_reg_convenio
      INDEX BY VARCHAR2(30);

  -- Tabela para armazenar os convenios quantidade de lancamento
  TYPE typ_tab_convenio_660 IS
    TABLE OF typ_reg_convenio
      INDEX BY VARCHAR2(15);

  -- Tabela para armazenar os convenios do dia do processamento para gerar o relatório crrl671
  TYPE typ_tab_convenio_671 IS
    TABLE OF typ_reg_convenio
      INDEX BY VARCHAR2(15);

  -- Tabela de memória para guardar as informações de tarifas por agencia - duplamente encadeada
  TYPE typ_tab_tarifa_age IS TABLE OF NUMBER             INDEX BY BINARY_INTEGER;
  TYPE typ_tab_tarifa_pes IS TABLE OF typ_tab_tarifa_age INDEX BY BINARY_INTEGER;
  vr_tab_tarifas      typ_tab_tarifa_pes; -- Tarifas divididas por tipo pessoa e agencia
  vr_tab_totagen      typ_tab_tarifa_age; -- Total de tarifas por tipo pessoa

  -- Convenios por cooperativa
  vr_tab_convenio_658 typ_tab_convenio_658;

  -- Convenios por data e meio
  vr_tab_convenio_659 typ_tab_convenio_659;

  -- Convenio por lancamentos
  vr_tab_convenio_660 typ_tab_convenio_660;
  vr_tab_conv_ord_660 typ_tab_convenio_660;
  -- Convenio por lancamentos - Pessoa Física, Pessoa Jurídica e NÃO ASSOCIADOS
  vr_tab_conv_fis_660 typ_tab_convenio_660;
  vr_tab_conv_jur_660 typ_tab_convenio_660;
  vr_tab_conv_nao_660 typ_tab_convenio_660;

  -- Convenio por lancamentos
  vr_tab_convenio_671 typ_tab_convenio_671;
  vr_tab_conv_ord_671 typ_tab_convenio_671;
  
	 vr_dircon VARCHAR2(200);
	 vr_arqcon VARCHAR2(200);
   vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
   vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
   vc_cdtodascooperativas INTEGER := 0;   

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.cdcooper
          ,cop.nmrescop
      FROM crapcop cop
      WHERE cop.cdcooper = nvl(pr_cdcooper,cop.cdcooper);

  -- Cursor de cadastro de convenios
  CURSOR cr_gnconve IS
    SELECT nve.cdconven
          ,nve.cdhiscxa
          ,nve.cdhisdeb
          ,nve.nmempres
          ,nve.vltrfnet
          ,nve.vltrftaa
          ,nve.vltrfcxa
          ,nve.vltrfdeb
      FROM gnconve nve
     WHERE nve.flgativo  = 1
       AND (nve.cdcooper IN (3,pr_cdcooper) OR pr_cdcooper = 3);

  -- Cursor com os lancamentos das faturas
  CURSOR cr_craplft (pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_cdhistor craphis.cdhistor%TYPE
                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT lft.cdagenci
          ,lft.cdhistor
          ,lft.dtmvtolt
          ,lft.vllanmto
          ,lft.vlrmulta
          ,lft.vlrjuros
          ,lft.nrdconta
      FROM craplft lft
     WHERE lft.cdcooper = pr_cdcooper
       AND lft.cdhistor = pr_cdhistor
       AND lft.dtmvtolt = pr_dtmvtolt;

  -- Cursor de lancamentos em conta corrente
  CURSOR cr_craplcm (pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_cdhistor craphis.cdhistor%TYPE
                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT lcm.cdhistor
          ,lcm.cdcooper
          ,lcm.nrdconta
          ,lcm.cdagenci
          ,lcm.dtmvtolt
          ,lcm.vllanmto
      FROM craplcm lcm
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.cdhistor = pr_cdhistor
       AND lcm.dtmvtolt = pr_dtmvtolt;

  -- Cursor verifica se o lancamento eh de conta migrada
  -- Foi identificado que alguns convenios estao criandi lcm com conta antiga
  CURSOR cr_craptco (p_cdcooper crapcop.cdcooper%TYPE
                    ,p_nrdconta crapcop.nrdconta%TYPE) IS
     SELECT 1
       FROM craptco tco
      WHERE tco.cdcopant = p_cdcooper
        AND tco.nrctaant = p_nrdconta
        AND tco.flgativo = 1;
  rw_craptco cr_craptco%ROWTYPE;

  -- Cursor com os dados do coban
  CURSOR cr_crapcbb IS
    SELECT count(*) qtd
          ,SUM(cbb.valorpag) vlr
     FROM crapcbb cbb
    WHERE cbb.cdcooper <> 3
      AND cbb.dtmvtolt >= vr_dtinimes
      AND cbb.dtmvtolt <= vr_dtfimmes
      AND cbb.flgrgatv  = 1;

  -- Buscar dados do cooperado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT t.inpessoa
         , t.cdagenci
      FROM crapass t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Procedure responsável por montar a chave da PL TABLE dos relatórios 659 e 660.
  PROCEDURE pc_traz_chave (pr_dsmeiola  IN VARCHAR2
                          ,pr_cdconven  IN gnconve.cdconven%TYPE
                          ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                          ,pr_nmempres  IN crapemp.nmresemp%TYPE
                          ,pr_dsdchave_659 OUT VARCHAR2
                          ,pr_dsdchave_660 OUT VARCHAR2) IS

    BEGIN
      -- Identificar meio de lancamento (90 -> Internet, 91 -> TAA, Outros -> Caixa)
      IF  NOT pr_dsmeiola = '4'  THEN
        IF  pr_dsmeiola = '90-lft'  THEN
          vr_dsmeiola := '3';
        ELSIF
           pr_dsmeiola = '91-lft'  THEN
          vr_dsmeiola :=  '2';
        ELSE
          vr_dsmeiola := '1';
        END IF;
      ELSE
        vr_dsmeiola := pr_dsmeiola;
      END IF;

      -- Chave para tabela por convenio, data e meio de lancamento
      pr_dsdchave_659 := to_char(pr_cdconven,'fm0000') ||
                         to_char(pr_dtmvtolt,'dd/mm/yy')  ||
                         vr_dsmeiola;

      -- Se nao acha com esta chave, inicializar
      IF NOT vr_tab_convenio_659.EXISTS(pr_dsdchave_659)  THEN
        vr_tab_convenio_659(pr_dsdchave_659).nmempres := pr_nmempres;
      END IF;

      -- Chave por convenio e meio de lancamento
      pr_dsdchave_660 := to_char(pr_cdconven,'fm0000') ||
                         vr_dsmeiola;

      -- Se nao acha com esta chave, inicializar
      IF NOT vr_tab_convenio_659.EXISTS(pr_dsdchave_660)  THEN
        vr_tab_convenio_659(pr_dsdchave_660).nmempres := pr_nmempres;
      END IF;

    END;

  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_cdrelato  IN NUMBER
                           ,pr_des_dados IN VARCHAR2) IS
    BEGIN
      IF  pr_cdrelato = 658  THEN
        dbms_lob.writeappend(vr_dsxmldad_658,length(pr_des_dados),pr_des_dados);
      ELSIF
          pr_cdrelato = 659  THEN
        dbms_lob.writeappend(vr_dsxmldad_659,length(pr_des_dados),pr_des_dados);
      ELSIF
          pr_cdrelato = 660  THEN
        dbms_lob.writeappend(vr_dsxmldad_660,length(pr_des_dados),pr_des_dados);
      END IF;

    END;

  -- Verifica a agencia e caso seja 90 ou 91 substitui pela agencia do cooperado
  FUNCTION fn_agencia(pr_cdagenci   IN crapass.cdagenci%TYPE
                     ,pr_cdageass   IN crapass.cdagenci%TYPE) RETURN crapass.cdagenci%TYPE IS

  BEGIN

    -- Se agencia é 90 ou 91
    IF pr_cdagenci IN (90,91) THEN
      RETURN pr_cdageass;
    ELSE
      RETURN pr_cdagenci;
    END IF;

  END fn_agencia;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN  cr_crapcop (pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop INTO vr_cdcooper, vr_nmrescop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN
    vr_cdcritic := 651;
    CLOSE cr_crapcop;
    RAISE vr_exc_saida;
  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN  btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;

  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN
    vr_cdcritic := 1;
    CLOSE btch0001.cr_crapdat;
    RAISE vr_exc_saida;
  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN
    RAISE vr_exc_saida;
  END IF;

  -- Limpar os registros de memória
  vr_tab_convenio_658.DELETE;
  vr_tab_convenio_659.DELETE;
  vr_tab_convenio_660.DELETE;
  vr_tab_convenio_671.DELETE;

  -- Se a cooperativa é 3 ou se for mensal
  IF pr_cdcooper = 3 OR trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') THEN
    -- Data inicio mes
    vr_dtinimes := rw_crapdat.dtinimes;
  ELSE
    -- Data de inicio e fim deve usar o dia atual
    vr_dtinimes := rw_crapdat.dtmvtolt;  -- Significa que deverá rodar apenas o diário, gerando apenas o CRRL 671
  END IF;

  -- Data fim mes ou atual quando a execução não for mensal
  vr_dtfimmes := rw_crapdat.dtmvtolt;

  -- Obter diretorio /coop/rl
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/rl');

  -- Percorrer os convenios ativos
  FOR rw_gnconve IN cr_gnconve LOOP

    -- Verifica se a deve ler uma cooperativa especifica
    IF pr_cdcooper = 3 THEN
      vr_cdcooper := NULL;
    ELSE
      vr_cdcooper := pr_cdcooper;
    END IF;

    -- Percorrer todas as cooperativas menos a CECRED
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper => vr_cdcooper) LOOP

      -- Obter codigo da cooperativa
      vr_cdcooper := rw_crapcop.cdcooper;

      -- Desconsiderar a CECRED
      IF  vr_cdcooper = 3  THEN
        CONTINUE;
      END IF;

      -- Data de inicio para leitura da craplft é o inicio do mes corrente
      vr_dtmvtolt := vr_dtinimes;

      -- Loop dos dias do mes corrente
      LOOP

        -- Leitura dos lancamentos de fatura
        FOR rw_craplft IN cr_craplft (pr_cdcooper => vr_cdcooper
                                     ,pr_cdhistor => rw_gnconve.cdhiscxa
                                     ,pr_dtmvtolt => vr_dtmvtolt) LOOP

          -- Se ainda não existe para esta coop, armazenar nome da mesma
          IF  NOT vr_tab_convenio_658.EXISTS(vr_cdcooper)  THEN
            vr_tab_convenio_658(vr_cdcooper).nmrescop := rw_crapcop.nmrescop;
          END IF;

          -- Acumular valores por cooperativa
          vr_tab_convenio_658(vr_cdcooper).vllanmto := nvl(vr_tab_convenio_658(vr_cdcooper).vllanmto,0) +
                                                        rw_craplft.vllanmto +
                                                        rw_craplft.vlrmulta +
                                                        rw_craplft.vlrjuros;

          -- Retornar a chave para PL TABLE por convenio, data e meio de lancamento
          pc_traz_chave (pr_dsmeiola     => to_char(rw_craplft.cdagenci) || '-lft'
                        ,pr_cdconven     => rw_gnconve.cdconven
                        ,pr_dtmvtolt     => vr_dtmvtolt
                        ,pr_nmempres     => rw_gnconve.nmempres
                        ,pr_dsdchave_659 => vr_dsdchave_659
                        ,pr_dsdchave_660 => vr_dsdchave_660);

          -- Obter o valor da tarifa
          IF  rw_craplft.cdagenci = 90  THEN     -- Internet
            vr_vltarifa := rw_gnconve.vltrfnet;
          ELSIF
              rw_craplft.cdagenci = 91  THEN     -- TAA
            vr_vltarifa := rw_gnconve.vltrftaa;
          ELSE                                   -- Caixa
            vr_vltarifa := rw_gnconve.vltrfcxa;
          END IF;

          -- Acumular valores por data, convenio e meio de lancamento para o relatorio 659
          vr_tab_convenio_659(vr_dsdchave_659).vllanmto := nvl(vr_tab_convenio_659(vr_dsdchave_659).vllanmto,0) +
                                                            rw_craplft.vllanmto +
                                                            rw_craplft.vlrmulta +
                                                            rw_craplft.vlrjuros;
          vr_tab_convenio_659(vr_dsdchave_659).vltarifa := nvl(vr_tab_convenio_659(vr_dsdchave_659).vltarifa,0) +
                                                        vr_vltarifa;
          vr_tab_convenio_659(vr_dsdchave_659).qtlancam := nvl(vr_tab_convenio_659(vr_dsdchave_659).qtlancam,0) + 1;

          -- Acumular por convenio e meio de lancamento para o relatorio 660
          vr_tab_convenio_659(vr_dsdchave_660).vllanmto := nvl(vr_tab_convenio_659(vr_dsdchave_660).vllanmto,0) +
                                                            rw_craplft.vllanmto +
                                                            rw_craplft.vlrmulta +
                                                            rw_craplft.vlrjuros;
          vr_tab_convenio_659(vr_dsdchave_660).vltarifa := nvl(vr_tab_convenio_659(vr_dsdchave_660).vltarifa,0) +
                                                            vr_vltarifa;
          vr_tab_convenio_659(vr_dsdchave_660).qtlancam := nvl(vr_tab_convenio_659(vr_dsdchave_660).qtlancam,0) + 1;

          -- Se o número da conta for zero, não busca não associados
          IF NVL(rw_craplft.nrdconta,0) > 0 THEN
            -- Buscar a informação da pessoa
            OPEN  cr_crapass(vr_cdcooper, rw_craplft.nrdconta);
            FETCH cr_crapass INTO vr_inpessoa, vr_cdageass;
            -- Se o associado não for encontrado
            IF cr_crapass%NOTFOUND THEN
              vr_inpessoa := 3; -- Não Associado
            ELSIF vr_inpessoa = 3 THEN
              vr_inpessoa := 2; -- Cooperativas devem ser tratadas como pessoa juridica
            END IF;
            -- Fecha o cursor
            CLOSE cr_crapass;
          ELSE
            vr_inpessoa := 3; -- Será considerado como NÃO ASSOCIADO
          END IF;

          -- Se o indice por tipo de pessoa não existe
          IF NOT vr_tab_tarifas.EXISTS(vr_inpessoa) THEN
            -- Cria a posição para gravar os valores da pessoa e tarifa
            vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplft.cdagenci,vr_cdageass)) := 0;
            -- Criar o totalizador para o tipo pessoa
            vr_tab_totagen(vr_inpessoa) := 0;
          ELSIF NOT vr_tab_tarifas(vr_inpessoa).EXISTS(fn_agencia(rw_craplft.cdagenci,vr_cdageass)) THEN -- SE o indice da agencia não existe
            -- Cria a posição para gravar os valores da tarifa
            vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplft.cdagenci,vr_cdageass)) := 0;
          END if;

          -- Acumula o valor da TARIFA para a agencia
          vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplft.cdagenci,vr_cdageass)) := vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplft.cdagenci,vr_cdageass)) + vr_vltarifa;
          -- Acumula o total das tarifas por tipo de pessoa
          vr_tab_totagen(vr_inpessoa) := vr_tab_totagen(vr_inpessoa) + vr_vltarifa;

          -- Criar o convenio independente do tipo de pessoa
          IF NOT vr_tab_conv_fis_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          IF NOT vr_tab_conv_jur_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          IF NOT vr_tab_conv_nao_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          -- Se for pessoa fisica
          IF vr_inpessoa = 1 THEN

            -- Guardar os valores
            vr_tab_conv_fis_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplft.vllanmto +
                                                             rw_craplft.vlrmulta +
                                                             rw_craplft.vlrjuros;
            vr_tab_conv_fis_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_fis_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).qtlancam,0) + 1;

          ELSIF vr_inpessoa = 2 THEN

            -- Guardar os valores
            vr_tab_conv_jur_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplft.vllanmto +
                                                             rw_craplft.vlrmulta +
                                                             rw_craplft.vlrjuros;
            vr_tab_conv_jur_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_jur_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).qtlancam,0) + 1;

          ELSE

            -- Guardar os valores
            vr_tab_conv_nao_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplft.vllanmto +
                                                             rw_craplft.vlrmulta +
                                                             rw_craplft.vlrjuros;
            vr_tab_conv_nao_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_nao_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).qtlancam,0) + 1;

          END IF;


          -- Se tiver processando a informação do dia
          IF rw_craplft.dtmvtolt = rw_crapdat.dtmvtolt THEN

            -- Chave
            vr_dsdchave_671 := vr_dsdchave_660;

            IF NOT vr_tab_convenio_671.exists(vr_dsdchave_671) THEN
              FOR vr_indice IN 1..4 LOOP
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
              END LOOP;
            END IF;

            -- Alimentar os valores na 671, por valor de lancamento
            vr_tab_convenio_671(vr_dsdchave_671).nmempres := rw_gnconve.nmempres;
            vr_tab_convenio_671(vr_dsdchave_671).vllanmto := vr_tab_convenio_659(vr_dsdchave_659).vllanmto;
            vr_tab_convenio_671(vr_dsdchave_671).vltarifa := vr_tab_convenio_659(vr_dsdchave_659).vltarifa;
            vr_tab_convenio_671(vr_dsdchave_671).qtlancam := vr_tab_convenio_659(vr_dsdchave_659).qtlancam;
          END IF;

        END LOOP;

        -- Leitura dos lancamentos em conta corrente.
        FOR rw_craplcm IN cr_craplcm (pr_cdcooper => vr_cdcooper
                                     ,pr_cdhistor => rw_gnconve.cdhisdeb
                                     ,pr_dtmvtolt => vr_dtmvtolt) LOOP

          -- Validar apenas se for o relatório mensal de todas as cooperativas, afim
          -- de evitar duplicação de informações
          IF pr_cdcooper = 3 THEN
            -- Verifica se o lancamento foi feito com a conta antiga
            OPEN cr_craptco(rw_craplcm.cdcooper
                           ,rw_craplcm.nrdconta);
            FETCH cr_craptco INTO rw_craptco;
               -- Verifica se existe registro
               IF cr_craptco%FOUND THEN
                  -- Fecha cursor
                  CLOSE cr_craptco;
                  -- Proximo registro, porque ja possui
                  -- lancamento na conta nova do cooperado.
                  CONTINUE;
               END IF;
            -- Fecha cursor
            CLOSE cr_craptco;

          END IF;

          -- Se o número da conta for zero, não busca não associados
          IF NVL(rw_craplcm.nrdconta,0) > 0 THEN
            -- Buscar a informação da pessoa
            OPEN  cr_crapass(vr_cdcooper, rw_craplcm.nrdconta);
            FETCH cr_crapass INTO vr_inpessoa, vr_cdageass;
            -- Se o associado não for encontrado
            IF cr_crapass%NOTFOUND THEN
              vr_inpessoa := 0; -- Não Associado
            ELSIF vr_inpessoa = 3 THEN
              vr_inpessoa := 2; -- Cooperativas devem ser tratadas como pessoa juridica
            END IF;
            -- Fecha o cursor
            CLOSE cr_crapass;
          ELSE
            vr_inpessoa := 3; -- Será considerado como NÃO ASSOCIADO
          END IF;

          -- Se ainda não existe para esta coop, armazenar nome da mesma
          IF  NOT vr_tab_convenio_658.EXISTS(vr_cdcooper)  THEN
            vr_tab_convenio_658(vr_cdcooper).nmrescop := rw_crapcop.nmrescop;
          END IF;

          -- Acumular valores por cooperativa
          vr_tab_convenio_658(vr_cdcooper).vllanmto := nvl(vr_tab_convenio_658(vr_cdcooper).vllanmto,0) +
                                                        rw_craplcm.vllanmto;

          -- Retornar a chave para PL TABLE por data, convenio e meio de lancamento
          pc_traz_chave (pr_dsmeiola     => '4'
                        ,pr_cdconven     => rw_gnconve.cdconven
                        ,pr_dtmvtolt     => vr_dtmvtolt
                        ,pr_nmempres     => rw_gnconve.nmempres
                        ,pr_dsdchave_659 => vr_dsdchave_659
                        ,pr_dsdchave_660 => vr_dsdchave_660);

          -- Valor da tarifa do debito
          vr_vltarifa := rw_gnconve.vltrfdeb;

          -- Acumular valores por data, convenio e meio de lancamento
          vr_tab_convenio_659(vr_dsdchave_659).vllanmto := nvl(vr_tab_convenio_659(vr_dsdchave_659).vllanmto,0) +
                                                        rw_craplcm.vllanmto;
          vr_tab_convenio_659(vr_dsdchave_659).vltarifa := nvl(vr_tab_convenio_659(vr_dsdchave_659).vltarifa,0) +
                                                        vr_vltarifa;
          vr_tab_convenio_659(vr_dsdchave_659).qtlancam := nvl(vr_tab_convenio_659(vr_dsdchave_659).qtlancam,0) + 1;

          -- Acumular valores por convenio e meio de lancamento
          vr_tab_convenio_659(vr_dsdchave_660).vllanmto := nvl(vr_tab_convenio_659(vr_dsdchave_660).vllanmto,0) +
                                                            rw_craplcm.vllanmto;
          vr_tab_convenio_659(vr_dsdchave_660).vltarifa := nvl(vr_tab_convenio_659(vr_dsdchave_660).vltarifa,0) +
                                                            vr_vltarifa;
          vr_tab_convenio_659(vr_dsdchave_660).qtlancam := nvl(vr_tab_convenio_659(vr_dsdchave_660).qtlancam,0) + 1;

          -- Se o indice por tipo de pessoa não existe
          IF NOT vr_tab_tarifas.EXISTS(vr_inpessoa) THEN
            -- Cria a posição para gravar os valores da pessoa e tarifa
            vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplcm.cdagenci,vr_cdageass)) := 0;
            -- Criar o totalizador para o tipo pessoa
            vr_tab_totagen(vr_inpessoa) := 0;
          ELSIF NOT vr_tab_tarifas(vr_inpessoa).EXISTS(fn_agencia(rw_craplcm.cdagenci,vr_cdageass)) THEN -- SE o indice da agencia não existe
            -- Cria a posição para gravar os valores da tarifa
            vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplcm.cdagenci,vr_cdageass)) := 0;
          END if;

          -- Acumula o valor da TARIFA
          vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplcm.cdagenci,vr_cdageass)) := vr_tab_tarifas(vr_inpessoa)(fn_agencia(rw_craplcm.cdagenci,vr_cdageass)) + vr_vltarifa;
          -- Acumula o total das tarifas por tipo de pessoa
          vr_tab_totagen(vr_inpessoa) := vr_tab_totagen(vr_inpessoa) + vr_vltarifa;

          -- Criar o convenio independente do tipo de pessoa
          IF NOT vr_tab_conv_fis_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_fis_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          IF NOT vr_tab_conv_jur_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_jur_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          IF NOT vr_tab_conv_nao_660.exists(vr_dsdchave_660) THEN
            FOR vr_indice IN 1..4 LOOP
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
              vr_tab_conv_nao_660(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
            END LOOP;
          END IF;

          -- Se for pessoa fisica
          IF vr_inpessoa = 1 THEN

            -- Guardar os valores
            vr_tab_conv_fis_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplcm.vllanmto;
            vr_tab_conv_fis_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_fis_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_fis_660(vr_dsdchave_660).qtlancam,0) + 1;

          ELSIF vr_inpessoa = 2 THEN

            -- Guardar os valores
            vr_tab_conv_jur_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplcm.vllanmto;
            vr_tab_conv_jur_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_jur_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_jur_660(vr_dsdchave_660).qtlancam,0) + 1;

          ELSE

            -- Guardar os valores
            vr_tab_conv_nao_660(vr_dsdchave_660).vllanmto := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).vllanmto,0) +
                                                             rw_craplcm.vllanmto;
            vr_tab_conv_nao_660(vr_dsdchave_660).vltarifa := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).vltarifa,0) +
                                                             vr_vltarifa;
            vr_tab_conv_nao_660(vr_dsdchave_660).qtlancam := nvl(vr_tab_conv_nao_660(vr_dsdchave_660).qtlancam,0) + 1;

          END IF;

          -- Se tiver processando a informação do dia
          IF rw_craplcm.dtmvtolt = rw_crapdat.dtmvtolt THEN

            -- Chave
            vr_dsdchave_671 := vr_dsdchave_660;

            IF NOT vr_tab_convenio_671.exists(vr_dsdchave_671) THEN
              FOR vr_indice IN 1..4 LOOP
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).nmempres := rw_gnconve.nmempres;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vllanmto := 0;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).vltarifa := 0;
                vr_tab_convenio_671(to_char(rw_gnconve.cdconven,'fm0000')||vr_indice).qtlancam := 0;
              END LOOP;
            END IF;

            -- Alimentar os valores na 671, por valor de lancamento
            vr_tab_convenio_671(vr_dsdchave_671).nmempres := rw_gnconve.nmempres;
            vr_tab_convenio_671(vr_dsdchave_671).vllanmto := vr_tab_convenio_659(vr_dsdchave_659).vllanmto;
            vr_tab_convenio_671(vr_dsdchave_671).vltarifa := vr_tab_convenio_659(vr_dsdchave_659).vltarifa;
            vr_tab_convenio_671(vr_dsdchave_671).qtlancam := vr_tab_convenio_659(vr_dsdchave_659).qtlancam;
          END IF;

        END LOOP;

        -- Se passou do mes corrente, encerrar loop
        EXIT WHEN vr_dtmvtolt >= vr_dtfimmes;
        -- Adicionar mais um dia
        vr_dtmvtolt := vr_dtmvtolt + 1;
      END LOOP;

    END LOOP;

  END LOOP;

  -- Imprimir os relatórios CRRL658 e CRRL659 apenas quando CECRED
  IF pr_cdcooper = 3 THEN

    -- Inicializar o CLOB (XML) para o relatorio 658 ( Relatório arrecadação singulares )
    dbms_lob.createtemporary(vr_dsxmldad_658, TRUE);
    dbms_lob.open(vr_dsxmldad_658,dbms_lob.lob_readwrite);

    -- Inicio dados
    pc_escreve_clob(pr_cdrelato  => 658
                   ,pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><raiz>');

    IF vr_tab_convenio_658.count > 0 THEN
      -- Para todas as cooperativa que haja dados
      FOR vr_cdcooper IN 1 .. vr_tab_convenio_658.LAST LOOP

        IF  NOT vr_tab_convenio_658.EXISTS(vr_cdcooper)  THEN
          CONTINUE;
        END IF;

        -- Escrever o nome da cooperativa e dados dos lancamentos
        pc_escreve_clob (pr_cdrelato  => 658
                        ,pr_des_dados => '<coop>'
                                           ||  '<nmrescop>' || vr_tab_convenio_658(vr_cdcooper).nmrescop
                                           || '</nmrescop>'
                                           ||  '<vlrbruto>' || to_char(vr_tab_convenio_658(vr_cdcooper).vllanmto,'fm999G999G999G999D00')
                                           || '</vlrbruto>'
                                      || '</coop>');
      END LOOP;
    END IF;

    -- Fechar tag raiz do XML
    pc_escreve_clob (pr_cdrelato  => 658
                    ,pr_des_dados => '</raiz>');

    -- Alimentar o nome do arquivo a ser gerado
    vr_nmarquiv := vr_nom_direto || '/crrl658.lst';

    -- Solicitar relatorio 658
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmldad_658     --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz'             --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl658.jasper'    --> Arquivo de layout do iReport
                               ,pr_dsparams  => ''                  --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nmarquiv         --> Arquivo final
                               ,pr_qtcoluna  => 80                  --> 80 colunas
                               ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel080_1.i}
                               ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                   --> Número de cópias
                               ,pr_flg_gerar => 'N'                 --> gerar PDF
                               ,pr_des_erro  => vr_dscritic);       --> Saída com erro

    -- Liberando a memória alocada pro CLOB do relatorio 658
    dbms_lob.close(vr_dsxmldad_658);
    dbms_lob.freetemporary(vr_dsxmldad_658);

    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
  END IF;

  -- Percorrer os convenios ativos para criar os relatorio 659 e 660
  FOR rw_gnconve IN cr_gnconve LOOP

    -- Codigo do convenio
    vr_cdconven := rw_gnconve.cdconven;

    -- Imprimir os relatórios CRRL658 e CRRL659 apenas quando CECRED
    IF pr_cdcooper = 3 AND trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') THEN
      -- Inicializar o CLOB (XML) para o relatorio 659 ( Relatório consolidado mensal por convenio )
      dbms_lob.createtemporary(vr_dsxmldad_659, TRUE);
      dbms_lob.open(vr_dsxmldad_659,dbms_lob.lob_readwrite);

      -- Inicio dados no relatorio 659
      pc_escreve_clob(pr_cdrelato  => 659
                     ,pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Escrever nome da empresa no relatorio 659
      pc_escreve_clob(pr_cdrelato  => 659
                     ,pr_des_dados => '<nmempres>' || rw_gnconve.nmempres || '</nmempres>');

      -- Data de inicio para geracao de relatorio
      vr_dtmvtolt := vr_dtinimes;

      -- Loop dos dias do mes corrente
      LOOP

        -- Escrever tag do dia
        pc_escreve_clob(pr_cdrelato  => 659
                       ,pr_des_dados =>  '<dtmvtolt dia ="' || to_char(vr_dtmvtolt,'dd/mm/yy') || '">' );

        -- Percorrer os meios de pagamento
        FOR vr_contador IN 1 .. 4 LOOP

          -- Alimentar chave
          vr_dsdchave_659 := to_char(vr_cdconven,'fm0000')   ||
                             to_char(vr_dtmvtolt,'dd/mm/yy') ||
                             to_char(vr_contador,'fm0');

          -- Se nao existe, inicializar
          IF  NOT vr_tab_convenio_659.EXISTS(vr_dsdchave_659)  THEN
            vr_tab_convenio_659(vr_dsdchave_659).vllanmto := 0;
            vr_tab_convenio_659(vr_dsdchave_659).vltarifa := 0;
            vr_tab_convenio_659(vr_dsdchave_659).qtlancam := 0;
          END IF;

          -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
          pc_escreve_clob(pr_cdrelato  => 659
                         ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                              to_char(vr_tab_convenio_659(vr_dsdchave_659).vllanmto,'fm99G999G999G990D00')  ||
                                           '</vllanmto_' ||  vr_contador  || '>' ||
                                           '<vltarifa_' || vr_contador || '>'    ||
                                              to_char(vr_tab_convenio_659(vr_dsdchave_659).vltarifa,'fm99G999G999G990D00')  ||
                                           '</vltarifa_' || vr_contador || '>'   ||
                                           '<qtlancam_' || vr_contador || '>'    ||
                                              to_char(vr_tab_convenio_659(vr_dsdchave_659).qtlancam,'fm999G999G990')  ||
                                           '</qtlancam_' || vr_contador || '>');
        END LOOP;

        -- Fechar tag do dia
        pc_escreve_clob(pr_cdrelato  => 659
                       ,pr_des_dados => '</dtmvtolt>');

        -- Se passou do mes corrente, encerrar loop
        EXIT WHEN vr_dtmvtolt = vr_dtfimmes;

        -- Próximo dia
        vr_dtmvtolt := vr_dtmvtolt + 1;

      END LOOP;

      -- Fechar tag raiz
      pc_escreve_clob(pr_cdrelato  => 659
                     ,pr_des_dados => '</raiz>');

      -- Nome do arquivo a ser gerado
      vr_nmarquiv := vr_nom_direto || '/crrl659_c' || to_char(vr_cdconven,'fm000') || '.lst';

      -- Solicitar relatorio 659
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper       --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra       --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtolt       --> Data do movimento atual
                                 ,pr_dsxml     => vr_dsxmldad_659   --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz'           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl659.jasper'  --> Arquivo de layout do iReport
                                 ,pr_dsparams  => ''                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nmarquiv       --> Arquivo final
                                 ,pr_qtcoluna  => 234               --> 234 colunas
                                 ,pr_sqcabrel  => 2                 --> Sequencia do Relatorio {includes/cabrel234_1.i}
                                 ,pr_flg_impri => 'S'               --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'           --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                 --> Número de cópias
                                 ,pr_flg_gerar => 'N'               --> gerar PDF na hora
                                 ,pr_des_erro  => vr_dscritic);     --> Saída com erro

      --Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_dsxmldad_659);
      dbms_lob.freetemporary(vr_dsxmldad_659);

      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
    ELSE
      -- Ajustar a data de movimento
      vr_dtmvtolt := vr_dtfimmes;
    END IF;  -- Fim PR_CDCOOPER = 3 - Gerar 658 e 659 apenas quando CECRED

    -- Limpar quantidade de lancamento
    vr_qtlancam := 0;

    -- Percorrer os meios de pagamento
    FOR vr_contador IN 1 .. 4 LOOP

      -- Alimentar chave
      vr_dsdchave_660 := to_char(vr_cdconven,'fm0000')   ||
                         to_char(vr_contador,'fm0');

      -- Se nao existe, inicializar
      IF  NOT vr_tab_convenio_659.EXISTS(vr_dsdchave_660)  THEN
        vr_tab_convenio_659(vr_dsdchave_660).vllanmto := 0;
        vr_tab_convenio_659(vr_dsdchave_660).vltarifa := 0;
        vr_tab_convenio_659(vr_dsdchave_660).qtlancam := 0;
      END IF;

      -- Quantidade
      vr_qtlancam := vr_qtlancam + vr_tab_convenio_659(vr_dsdchave_660).qtlancam;

    END LOOP;

    -- Percorrer os meios de pagamento
    FOR vr_contador IN 1 .. 4 LOOP

      -- Alimentar chave
      vr_dsdchave_660 := to_char(vr_cdconven,'fm0000')   ||
                         to_char(vr_contador,'fm0');

      -- Nova chave para o 660, agora por quantidade de lancamentos totais por convenio
      vr_dsdchave_nw_660 := to_char(vr_qtlancam,'fm000000000') || to_char(vr_cdconven,'fm0000') || to_char(vr_contador,'fm0');

      -- Alimentar as variáveis se a cooperativa é 3 ou se for mensal
      IF pr_cdcooper = 3 OR trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') THEN
        -- Alimentar os valores na 660, por quantidade de lancamento
        vr_tab_convenio_660(vr_dsdchave_nw_660).nmempres :=  rw_gnconve.nmempres;
        vr_tab_convenio_660(vr_dsdchave_nw_660).vllanmto := vr_tab_convenio_659(vr_dsdchave_660).vllanmto;
        vr_tab_convenio_660(vr_dsdchave_nw_660).vltarifa := vr_tab_convenio_659(vr_dsdchave_660).vltarifa;
        vr_tab_convenio_660(vr_dsdchave_nw_660).qtlancam := vr_tab_convenio_659(vr_dsdchave_660).qtlancam;
      END IF;

    END LOOP;

  END LOOP;

  /***** INICIO - BLOCO PARA AJUSTAR A ORDENAÇÃO DOS RELATÓRIOS *****/
  -- Percorrer a tabela de memória e ordenar os registros -- PESSOA FISICA
  IF vr_tab_conv_fis_660.COUNT() > 0 THEN
    vr_dsdchave_660 := vr_tab_conv_fis_660.FIRST;
    LOOP

      -- Soma as quantidades de lançamentos em todas as modalidades
      vr_vltotcvn := vr_tab_conv_fis_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '1').qtlancam
                   + vr_tab_conv_fis_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '2').qtlancam
                   + vr_tab_conv_fis_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '3').qtlancam
                   + vr_tab_conv_fis_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '4').qtlancam;

      -- Adiciona o registro atual, na tabela ordenada por valor
      vr_tab_conv_ord_660(to_char((vr_vltotcvn*100),'fm0000000000')||vr_dsdchave_660) := vr_tab_conv_fis_660(vr_dsdchave_660);

      -- Verificar encerramento do LOOP
      EXIT WHEN vr_dsdchave_660 = vr_tab_conv_fis_660.LAST;
      -- Buscar próximo
      vr_dsdchave_660 := vr_tab_conv_fis_660.NEXT(vr_dsdchave_660);
    END LOOP;
  END IF;

  -- Limpa a tabela original de dados
  vr_tab_conv_fis_660.DELETE;
  -- Transfere os dados da tabela ordenada para a tabela de dados
  vr_tab_conv_fis_660 := vr_tab_conv_ord_660;
  -- Limpa a tabela de ordenação
  vr_tab_conv_ord_660.DELETE;

  -- Percorrer a tabela de memória e ordenar os registros -- PESSOA JURIDICA
  IF vr_tab_conv_jur_660.COUNT() > 0 THEN
    vr_dsdchave_660 := vr_tab_conv_jur_660.FIRST;
    LOOP

      -- Soma as quantidades de lançamentos em todas as modalidades
      vr_vltotcvn := vr_tab_conv_jur_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '1').qtlancam
                   + vr_tab_conv_jur_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '2').qtlancam
                   + vr_tab_conv_jur_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '3').qtlancam
                   + vr_tab_conv_jur_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '4').qtlancam;

      -- Adiciona o registro atual, na tabela ordenada por valor
      vr_tab_conv_ord_660(to_char((vr_vltotcvn*100),'fm0000000000')||vr_dsdchave_660) := vr_tab_conv_jur_660(vr_dsdchave_660);

      -- Verificar encerramento do LOOP
      EXIT WHEN vr_dsdchave_660 = vr_tab_conv_jur_660.LAST;
      -- Buscar próximo
      vr_dsdchave_660 := vr_tab_conv_jur_660.NEXT(vr_dsdchave_660);
    END LOOP;
  END IF;

  -- Limpa a tabela original de dados
  vr_tab_conv_jur_660.DELETE;
  -- Transfere os dados da tabela ordenada para a tabela de dados
  vr_tab_conv_jur_660 := vr_tab_conv_ord_660;
  -- Limpa a tabela de ordenação
  vr_tab_conv_ord_660.DELETE;

  -- Percorrer a tabela de memória e ordenar os registros -- NAO ASSOCIADO
  IF vr_tab_conv_nao_660.COUNT() > 0 THEN
    vr_dsdchave_660 := vr_tab_conv_nao_660.FIRST;
    LOOP

      -- Soma as quantidades de lançamentos em todas as modalidades
      vr_vltotcvn := vr_tab_conv_nao_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '1').qtlancam
                   + vr_tab_conv_nao_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '2').qtlancam
                   + vr_tab_conv_nao_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '3').qtlancam
                   + vr_tab_conv_nao_660(substr(vr_dsdchave_660,0,(length(vr_dsdchave_660)-1)) || '4').qtlancam;

      -- Adiciona o registro atual, na tabela ordenada por valor
      vr_tab_conv_ord_660(to_char((vr_vltotcvn*100),'fm0000000000')||vr_dsdchave_660) := vr_tab_conv_nao_660(vr_dsdchave_660);

      -- Verificar encerramento do LOOP
      EXIT WHEN vr_dsdchave_660 = vr_tab_conv_nao_660.LAST;
      -- Buscar próximo
      vr_dsdchave_660 := vr_tab_conv_nao_660.NEXT(vr_dsdchave_660);
    END LOOP;
  END IF;

  -- Limpa a tabela original de dados
  vr_tab_conv_nao_660.DELETE;
  -- Transfere os dados da tabela ordenada para a tabela de dados
  vr_tab_conv_nao_660 := vr_tab_conv_ord_660;
  -- Limpa a tabela de ordenação
  vr_tab_conv_ord_660.DELETE;
  /***** FIM  -   BLOCO PARA AJUSTAR A ORDENAÇÃO DO RELATÓRIO *****/

  /** GERAÇÃO DO RELATÓRIO CRPS671 - Utiliza as variáveis do 660 pois é igual  **/
  -- Gerar relatório quando não for CECRED
  IF pr_cdcooper <> 3 THEN

    -- Se há registros
    IF vr_tab_convenio_671.COUNT() > 0 THEN
      /***** INICIO - BLOCO PARA AJUSTAR A ORDENAÇÃO DOS RELATÓRIOS *****/
      -- Percorrer a tabela de memória e ordenar os registros
      vr_dsdchave_671 := vr_tab_convenio_671.FIRST;
      LOOP

        -- Soma as quantidades de lançamentos em todas as modalidades
        vr_vltotcvn := vr_tab_convenio_671(substr(vr_dsdchave_671,0,(length(vr_dsdchave_671)-1)) || '1').qtlancam
                     + vr_tab_convenio_671(substr(vr_dsdchave_671,0,(length(vr_dsdchave_671)-1)) || '2').qtlancam
                     + vr_tab_convenio_671(substr(vr_dsdchave_671,0,(length(vr_dsdchave_671)-1)) || '3').qtlancam
                     + vr_tab_convenio_671(substr(vr_dsdchave_671,0,(length(vr_dsdchave_671)-1)) || '4').qtlancam;

        -- Adiciona o registro atual, na tabela ordenada por valor
        vr_tab_conv_ord_671(to_char((vr_vltotcvn*100),'fm0000000000')||vr_dsdchave_671) := vr_tab_convenio_671(vr_dsdchave_671);

        -- Verificar encerramento do LOOP
        EXIT WHEN vr_dsdchave_671 = vr_tab_convenio_671.LAST;
        -- Buscar próximo
        vr_dsdchave_671 := vr_tab_convenio_671.NEXT(vr_dsdchave_671);
      END LOOP;
    END IF;

    -- Limpa a tabela original de dados
    vr_tab_convenio_671.DELETE;
    -- Transfere os dados da tabela ordenada para a tabela de dados
    vr_tab_convenio_671 := vr_tab_conv_ord_671;
    -- Limpa a tabela de ordenação
    vr_tab_conv_ord_671.DELETE;

    /***** FIM  -   BLOCO PARA AJUSTAR A ORDENAÇÃO DO RELATÓRIO *****/


    -- Inicializar o CLOB (XML) para o relatorio 660 (Relatório movimentação financeiras dos convênios)
    dbms_lob.createtemporary(vr_dsxmldad_660, TRUE);
    dbms_lob.open(vr_dsxmldad_660,dbms_lob.lob_readwrite);

    -- Inicio dados no relatorio 660
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><raiz nmrelato="CRRL671"><total>');

    vr_dsdchave_671 := vr_tab_convenio_671.LAST;

    LOOP

      EXIT WHEN vr_dsdchave_671 IS NULL;

      -- Escrever nome da empresa no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<nmempres nome = "' || vr_tab_convenio_671(vr_dsdchave_671).nmempres || '">' );

      vr_contador := 4;

      -- Percorrer os meios de pagamentos
      LOOP

        IF  vr_contador = 0  THEN
          EXIT;
        END IF;

        -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
        pc_escreve_clob(pr_cdrelato  => 660
                       ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_671(vr_dsdchave_671).vllanmto,'fm99G999G999G990D00')  ||
                                         '</vllanmto_' ||  vr_contador  || '>' ||
                                         '<vltarifa_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_671(vr_dsdchave_671).vltarifa,'fm99G999G999G990D00')  ||
                                         '</vltarifa_' || vr_contador || '>'   ||
                                         '<qtlancam_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_671(vr_dsdchave_671).qtlancam,'fm999G999G990')  ||
                                         '</qtlancam_' || vr_contador || '>');

        -- Obter chave anterior
        vr_dsdchave_671 := vr_tab_convenio_671.PRIOR(vr_dsdchave_671);

        vr_contador := vr_contador - 1;

      END LOOP;

      -- Fechar tag da empresa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</nmempres>');

    END LOOP;

    /* DEVERA GERAR O RELATÓRIO 660, COMO SENDO O 671, QUE ORIGINALMENTE
       ERA GERADO PELO CRPS664. */

    -- Gera o relatório com o nome do que era gerado pelo antigo CRPS664
    vr_nmarquiv := vr_nom_direto || '/crrl671.lst';
    -- Gerar como sendo o CRPS664
    vr_cdprogra_rel := 'CRPS664';
    -- Deve usar o sequencial de relatório 1
    vr_sqcabrel := 1;

    -- Fechar tag raiz
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</total></raiz>');

    -- Solicitar relatorio 660
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper       --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra_rel   --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt       --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmldad_660   --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz'           --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl660.jasper'  --> Arquivo de layout do iReport
                               ,pr_dsparams  => ''                --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nmarquiv       --> Arquivo final
                               ,pr_qtcoluna  => 234               --> 234 colunas
                               ,pr_sqcabrel  => vr_sqcabrel       --> Sequencia do Relatorio {includes/cabrel234_1.i}
                               ,pr_flg_impri => 'S'               --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '234dh'           --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                 --> Número de cópias
                               ,pr_flg_gerar => 'N'               --> Gerar PDF na hora
                               ,pr_des_erro  => vr_dscritic);     --> Saída com erro

    --Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmldad_660);
    dbms_lob.freetemporary(vr_dsxmldad_660);

    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_fimprg;
    END IF;

  END IF;


  /** GERAÇÃO DO RELATÓRIO CRPS660 OU 672 **/
  IF /*pr_cdcooper = 3 OR*/ trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') THEN

    -- Inicializar o CLOB (XML) para o relatorio 660 (Relatório movimentação financeiras dos convênios)
    dbms_lob.createtemporary(vr_dsxmldad_660, TRUE);
    dbms_lob.open(vr_dsxmldad_660,dbms_lob.lob_readwrite);

    IF pr_cdcooper = 3 THEN
      -- Inicio dados no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><raiz nmrelato="CRRL660">');
    ELSE
      -- Inicio dados no relatorio 672
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<?xml version="1.0" encoding="utf-8"?><raiz nmrelato="CRRL672">');
    END IF;

    /** IMPRIMIR DADOS DE PESSOA FÍSICA **/
    -- Inicio dados no relatorio
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '<fisica>');

    vr_dsdchave_nw_660 := vr_tab_conv_fis_660.LAST;

    LOOP

      EXIT WHEN vr_dsdchave_nw_660 IS NULL;

      -- Escrever nome da empresa no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<nmempres nome = "' || vr_tab_conv_fis_660(vr_dsdchave_nw_660).nmempres || '">' );

      vr_contador := 4;

      -- Percorrer os meios de pagamentos
      LOOP

        IF  vr_contador = 0  THEN
          EXIT;
        END IF;

        -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
        pc_escreve_clob(pr_cdrelato  => 660
                       ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_fis_660(vr_dsdchave_nw_660).vllanmto,'fm99G999G999G990D00')  ||
                                         '</vllanmto_' ||  vr_contador  || '>' ||
                                         '<vltarifa_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_fis_660(vr_dsdchave_nw_660).vltarifa,'fm99G999G999G990D00')  ||
                                         '</vltarifa_' || vr_contador || '>'   ||
                                         '<qtlancam_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_fis_660(vr_dsdchave_nw_660).qtlancam,'fm999G999G990')  ||
                                         '</qtlancam_' || vr_contador || '>');

        -- Obter chave anterior
        vr_dsdchave_nw_660 := vr_tab_conv_fis_660.PRIOR(vr_dsdchave_nw_660);

        vr_contador := vr_contador - 1;

      END LOOP;

      -- Fechar tag da empresa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</nmempres>');

    END LOOP;

    -- FIM DADOS DE PESSOA FÍSICA
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</fisica>');

    /** IMPRIMIR DADOS DE PESSOA JURIDICA **/
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '<juridica>');

    vr_dsdchave_nw_660 := vr_tab_conv_jur_660.LAST;

    LOOP

      EXIT WHEN vr_dsdchave_nw_660 IS NULL;

      -- Escrever nome da empresa no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<nmempres nome = "' || vr_tab_conv_jur_660(vr_dsdchave_nw_660).nmempres || '">' );

      vr_contador := 4;

      -- Percorrer os meios de pagamentos
      LOOP

        IF  vr_contador = 0  THEN
          EXIT;
        END IF;

        -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
        pc_escreve_clob(pr_cdrelato  => 660
                       ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_jur_660(vr_dsdchave_nw_660).vllanmto,'fm99G999G999G990D00')  ||
                                         '</vllanmto_' ||  vr_contador  || '>' ||
                                         '<vltarifa_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_jur_660(vr_dsdchave_nw_660).vltarifa,'fm99G999G999G990D00')  ||
                                         '</vltarifa_' || vr_contador || '>'   ||
                                         '<qtlancam_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_jur_660(vr_dsdchave_nw_660).qtlancam,'fm999G999G990')  ||
                                         '</qtlancam_' || vr_contador || '>');

        -- Obter chave anterior
        vr_dsdchave_nw_660 := vr_tab_conv_jur_660.PRIOR(vr_dsdchave_nw_660);

        vr_contador := vr_contador - 1;

      END LOOP;

      -- Fechar tag da empresa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</nmempres>');

    END LOOP;

    -- FIM DADOS DE PESSOA JURIDICA
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</juridica>');


    /** IMPRIMIR DADOS DE PESSOA NÃO ASSOCIADOS **/
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '<naoassociados>');

    vr_dsdchave_nw_660 := vr_tab_conv_nao_660.LAST;

    LOOP

      EXIT WHEN vr_dsdchave_nw_660 IS NULL;

      -- Escrever nome da empresa no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<nmempres nome = "' || vr_tab_conv_nao_660(vr_dsdchave_nw_660).nmempres || '">' );

      vr_contador := 4;

      -- Percorrer os meios de pagamentos
      LOOP

        IF  vr_contador = 0  THEN
          EXIT;
        END IF;

        -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
        pc_escreve_clob(pr_cdrelato  => 660
                       ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_nao_660(vr_dsdchave_nw_660).vllanmto,'fm99G999G999G990D00')  ||
                                         '</vllanmto_' ||  vr_contador  || '>' ||
                                         '<vltarifa_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_nao_660(vr_dsdchave_nw_660).vltarifa,'fm99G999G999G990D00')  ||
                                         '</vltarifa_' || vr_contador || '>'   ||
                                         '<qtlancam_' || vr_contador || '>'    ||
                                           to_char(vr_tab_conv_nao_660(vr_dsdchave_nw_660).qtlancam,'fm999G999G990')  ||
                                         '</qtlancam_' || vr_contador || '>');

        -- Obter chave anterior
        vr_dsdchave_nw_660 := vr_tab_conv_nao_660.PRIOR(vr_dsdchave_nw_660);

        vr_contador := vr_contador - 1;

      END LOOP;

      -- Fechar tag da empresa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</nmempres>');

    END LOOP;

    -- FIM DADOS DE NÃO ASSOCIADOS
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</naoassociados>');

    /** IMPRIMIR DADOS TOTAIS **/
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '<total>');

    vr_dsdchave_nw_660 := vr_tab_convenio_660.LAST;

    LOOP

      EXIT WHEN vr_dsdchave_nw_660 IS NULL;

      -- Escrever nome da empresa no relatorio 660
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<nmempres nome = "' || vr_tab_convenio_660(vr_dsdchave_nw_660).nmempres || '">' );

      vr_contador := 4;

      -- Percorrer os meios de pagamentos
      LOOP

        IF  vr_contador = 0  THEN
          EXIT;
        END IF;

        -- Escrecer valor lancamento , tarifa e quantidade de lancamentos
        pc_escreve_clob(pr_cdrelato  => 660
                       ,pr_des_dados =>  '<vllanmto_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_660(vr_dsdchave_nw_660).vllanmto,'fm99G999G999G990D00')  ||
                                         '</vllanmto_' ||  vr_contador  || '>' ||
                                         '<vltarifa_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_660(vr_dsdchave_nw_660).vltarifa,'fm99G999G999G990D00')  ||
                                         '</vltarifa_' || vr_contador || '>'   ||
                                         '<qtlancam_' || vr_contador || '>'    ||
                                           to_char(vr_tab_convenio_660(vr_dsdchave_nw_660).qtlancam,'fm999G999G990')  ||
                                         '</qtlancam_' || vr_contador || '>');

        -- Obter chave anterior
        vr_dsdchave_nw_660 := vr_tab_convenio_660.PRIOR(vr_dsdchave_nw_660);

        vr_contador := vr_contador - 1;

      END LOOP;

      -- Fechar tag da empresa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</nmempres>');

    END LOOP;

    -- FIM DADOS DE PESSOA FÍSICA
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</total>');

    -- Se for a cooperativa 3 - CECRED
    IF pr_cdcooper = 3 THEN
      -- Obter valores do COBAN
      OPEN  cr_crapcbb;
      FETCH cr_crapcbb INTO vr_qtvlrpag, vr_valorpag;
      CLOSE cr_crapcbb;

      -- Obter valor da tarifa COBAN
      vr_vltarpag := vr_qtvlrpag * 0.30;

      -- Tag para os valores do COBAN
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<coban idcoban="S">');

      -- Tag quantidade, valor e tarifa
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<qtvlrpag>' || to_char(vr_qtvlrpag,'fm999G999G990')    || '</qtvlrpag>' ||
                                      '<valorpag>' || to_char(vr_valorpag,'fm999G999G990D00') || '</valorpag>' ||
                                      '<vltarpag>' || to_char(vr_vltarpag,'fm999G990D00')     || '</vltarpag>');
      -- Fechar tag COBAN
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '</coban>');

      /* Definir parametros do relatório */

      -- Nome do arquivo a ser gerado
      vr_nmarquiv := vr_nom_direto || '/crrl660.lst';
      -- Gerar como CRPS649
      vr_cdprogra_rel := vr_cdprogra;
      -- Deve usar o sequencial de relatório 3
      vr_sqcabrel := 3;
    ELSE
      /* DEVERA GERAR O RELATÓRIO 660, COMO SENDO O 672, QUE ORIGINALMENTE
         ERA GERADO PELO CRPS664. */
      pc_escreve_clob(pr_cdrelato  => 660
                     ,pr_des_dados => '<coban idcoban="N" />');

      -- Gera o relatório com o nome do que era gerado pelo antigo CRPS664
      vr_nmarquiv := vr_nom_direto || '/crrl672.lst';
      -- Gerar como sendo o CRPS664
      vr_cdprogra_rel := 'CRPS664';
      -- Deve usar o sequencial de relatório 2
      vr_sqcabrel := 2;
    END IF;

    -- Fechar tag raiz
    pc_escreve_clob(pr_cdrelato  => 660
                   ,pr_des_dados => '</raiz>');

    -- Solicitar relatorio 660
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper       --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra_rel   --> Programa chamador
                               ,pr_dtmvtolt  => vr_dtmvtolt       --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmldad_660   --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz'           --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl660.jasper'  --> Arquivo de layout do iReport
                               ,pr_dsparams  => ''                --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nmarquiv       --> Arquivo final
                               ,pr_qtcoluna  => 234               --> 234 colunas
                               ,pr_sqcabrel  => vr_sqcabrel       --> Sequencia do Relatorio {includes/cabrel234_1.i}
                               ,pr_flg_impri => 'S'               --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '234dh'           --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                 --> Número de cópias
                               ,pr_flg_gerar => 'N'               --> Gerar PDF na hora
                               ,pr_des_erro  => vr_dscritic);     --> Saída com erro

    --Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmldad_660);
    dbms_lob.freetemporary(vr_dsxmldad_660);

    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_fimprg;
    END IF;
  END IF; -- Gerar apenas se CECRED ou virada de mês

  -- Gerar o arquivo para contabilidade quando for virada de mês e não for cooperativa 3 - CECRED
  IF trunc(rw_crapdat.dtmvtopr,'MM') <> trunc(rw_crapdat.dtmvtolt,'MM') AND pr_cdcooper <> 3 AND vr_tab_tarifas.COUNT() > 0 THEN

    -- Inicializar o CLOB (XML) para o arquivo com informação das tarifas
    dbms_lob.createtemporary(vr_dsxmldad_arq, TRUE);
    dbms_lob.open(vr_dsxmldad_arq,dbms_lob.lob_readwrite);

    FOR ind IN vr_tab_totagen.FIRST..vr_tab_totagen.LAST LOOP

      -- Setar as variáveis conforme indice
      IF ind = 1 THEN
        -- PESSOA FISICA
        vr_nrctaori := 7255;
        vr_nrctades := 7367;
        vr_dsmensag := 'TARIFAS DE ARRECADACOES - COOPERADOS PESSOA FISICA';
      ELSIF ind = 2 THEN
        -- PESSOA JURIDICA
        vr_nrctaori := 7255;
        vr_nrctades := 7368;
        vr_dsmensag := 'TARIFAS DE ARRECADACOES - COOPERADOS PESSOA JURIDICA';
      ELSE
        CONTINUE; --  *** *** TIPO 3 NÃO FARÁ PARTE DO ARQUIVO *** ***

        -- NAO ASSOCIADOS -- Contas irrisórias - Serão tratadas como "Não aplicável"
        vr_nrctaori := 8888;
        vr_nrctades := 9999;
        vr_dsmensag := 'TARIFAS DE ARRECADACOES - NAO COOPERADOS';
      END IF;

      -- Executar duas vezes para normal e para reversão
--      FOR qtd IN 1..2 LOOP
        -- Se existe o valor
        IF vr_tab_totagen.exists(ind) THEN
          -- VErifica se é ou não reversão
  --        IF qtd = 1 THEN
            vr_dtmvtolt := rw_crapdat.dtmvtolt;

            vr_dsmsgarq := vr_dsmensag;
    /*      ELSE
            -- Inversão das contas
            vr_nrctaaux := vr_nrctaori;
            vr_nrctaori := vr_nrctades;
            vr_nrctades := vr_nrctaaux;

            vr_dtmvtolt := rw_crapdat.dtmvtopr;

            -- Incluir a palavra REVERSAO
            vr_dsmsgarq := vr_dsprefix||vr_dsmensag;
          END IF;*/

          /* Imprimir dados de pessoa FISICA */
          vr_dslinarq := '70'||to_char(vr_dtmvtolt,'YYMMDD')
                      || ',' ||to_char(vr_dtmvtolt,'DDMMYY') || ','||vr_nrctaori||','||vr_nrctades||','
                      || to_char(vr_tab_totagen(ind),'FM99999999999990D00','NLS_NUMERIC_CHARACTERS=.,')
                      || ',1434,"'|| vr_dsmsgarq ||'"'
                      || CHR(10);

          -- Escrever CLOB
          dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);

          -- Deve imprimir duas vezes as agencias
          FOR repete IN 1..2 LOOP
            -- Percorrer as agencias para pessoa fisic
            vr_cdagenci := vr_tab_tarifas(ind).FIRST;

            LOOP
              -- Monta a linha para o arquivo
              vr_dslinarq := to_char(vr_cdagenci,'FM000')||','||
                             to_char(vr_tab_tarifas(ind)(vr_cdagenci),'fm99999999990D00','NLS_NUMERIC_CHARACTERS=.,')||
                             CHR(10);

              -- Escrever a linha no CLOB
              dbms_lob.writeappend(vr_dsxmldad_arq,length(vr_dslinarq),vr_dslinarq);

              -- Verifica se deve encerrar o loop
              EXIT WHEN vr_cdagenci = vr_tab_tarifas(ind).LAST;
              vr_cdagenci := vr_tab_tarifas(ind).NEXT(vr_cdagenci);
            END LOOP; -- Agencias
          END LOOP;
        END IF;
      --END LOOP; -- Normal e reversão
    END LOOP; -- Pessoas 1 e 2, tipo 3 não irá para o arquivo

    -- Buscar os diretórios
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/contab');

    -- Define o nome do arquivo
    vr_nmarqtxt := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_CONVEN.txt';

    -- Se foi incluído conteúdo no CLOB
    IF dbms_lob.getlength(vr_dsxmldad_arq) > 0 THEN

      -- Criar o arquivo de dados
      GENE0002.pc_clob_para_arquivo(pr_clob     => vr_dsxmldad_arq
                                   ,pr_caminho  => vr_nom_direto
                                   ,pr_arquivo  => vr_nmarqtxt
                                   ,pr_des_erro => vr_dscritic);

    END IF;

    --Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmldad_arq);
    dbms_lob.freetemporary(vr_dsxmldad_arq);

    -- Testa
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;
    
     -- Busca o diretório para contabilidade
     vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
     vr_dircon := vr_dircon || vc_dircon;
     vr_arqcon := to_char(rw_crapdat.dtmvtolt,'YYMMDD')||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CONVEN.txt';

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

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Efetuar Commit de informações pendentes de gravação
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

END PC_CRPS649;
/
