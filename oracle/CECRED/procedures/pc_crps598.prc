CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS598 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER
                     ,pr_stprogra OUT PLS_INTEGER
                     ,pr_infimsol OUT PLS_INTEGER
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                     ,pr_dscritic OUT VARCHAR2) AS

/* ..........................................................................

   Programa: PC_CRPS598                      Antigo: Fontes/crps598.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Henrique
   Data    : Maio/2011.                      Ultima atualizacao: 25/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Verificar contas que apresentaram movimentacoes suspeitas
               de lavagem de dinheiro. Solicitacao 2 e ordem 8.

   Alteracoes: 30/06/2011 - Incluidos os historicos 47, 191, 338, 573 para serem
                            desprezados (Henrique).

               20/07/2011 - Alteracao na busca do faturamento para inpessoa = 2
                            (Adriano).

               24/08/2011 - Incluidos os historicos 600,766,794,801,802,803,
                            804,887 para serem desprezados (Magui).

               25/09/2013 - Conversao Progress => Oracle (Gabriel).

               10/10/2013 - Ajuste para controle de criticas (Gabriel)
               
               25/04/2016 - Adicionar o historico 478 - CR.APL.RDCPRE, na lista de 
                            historicos ignorados para geração do controle de 
                            lavagem de dinheiro (Douglas - Chamado 405588)
                            
               05/12/2017 - Alterado cursor cr_craplcm para utilizar os historicos indicados no campo inmonpld - Antonio R. Jr (Mouts)
............................................................................. */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS598';  -- Codigo do presente programa
  vr_crapcop          NUMBER(1);                   -- Identifica se existe a crapcop
  vr_dstextab         VARCHAR2(100);               -- Descricao da tabela CRAPTAB
  vr_vet_craptab      gene0002.typ_split;          -- Array contendo os parametros da craptab
  vr_vet_nrcpfcgc     gene0002.typ_split;          -- Array contendo os CPF titulares
  vr_flgconta         BOOLEAN;                     -- Verifica se conjuge eh titular tambem
  vr_qtcopfis         NUMBER(3);                   -- Multiplicador de renda pessoa fisica
  vr_qtcopjur         NUMBER(3);                   -- Multiplicador de renda pessoa juridica
  vr_vldirfis         NUMBER(10);                  -- Valor base movimentacao pessoa fisica
  vr_vldirjur         NUMBER(10);                  -- Valor base movimentacao pessoa juridica
  vr_cdagenci         NUMBER(5);                   -- P.A do cooperado
  vr_inpessoa         NUMBER(1);                   -- Tipo de pessoa do cooperado
  vr_vlrendim         NUMBER(20,2);                -- Valor do rendimento
  vr_anomes           NUMBER(6);                   -- Numero contendo o ano e mes de faturamento
  vr_vlfatmes         NUMBER(20,2);                -- Valor do faturamento do mes
  vr_vlfatano         NUMBER(20,2);                -- Valor do faturamento anual
  vr_lscpfcgc         VARCHAR2(100);               -- Verificador de conjuge na ttl
  vr_cdcritic         crapcri.cdcritic%TYPE;       -- Codigo da critica
  vr_dscritic         VARCHAR2(2000);              -- Descricao da critica
  vr_exc_saida        EXCEPTION;                   -- Tratamento de excecao generica
  vr_exc_fimprg       EXCEPTION;                   -- Tratamento de excecao generica
  vr_indrenda         tbcc_monitoramento_parametro.inrenda_zerada%TYPE; -- indica renda zerada

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT 1
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Cursor de lancamentos de credito
  CURSOR cr_craplcm (pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
    SELECT SUM(lcm.vllanmto) vlcredit
              ,lcm.nrdconta
      FROM craplcm lcm
          ,craphis his
     WHERE lcm.cdcooper = pr_cdcooper
       AND lcm.dtmvtolt = pr_dtmvtolt
       -- Join com a tabela de historicos
       AND lcm.cdcooper = his.cdcooper
       AND lcm.cdhistor = his.cdhistor
       -- Historicos de credito
       AND his.indebcre = 'C'
       AND his.inmonpld = 1
     GROUP BY lcm.nrdconta
    HAVING SUM(lcm.vllanmto) > 0;

  -- Cursor com os cooperados
  CURSOR cr_crapass (pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
          ,ass.inpessoa
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;

  -- Cursor com os titulares da conta
  CURSOR cr_crapttl (pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT ttl.idseqttl
          ,ttl.vldrendi##1 + ttl.vldrendi##2 + ttl.vldrendi##3 + ttl.vldrendi##4 + ttl.vldrendi##5 + ttl.vldrendi##6 vldrendi
          ,ttl.vlsalari
          ,ttl.nrcpfcgc
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta;

  -- Cursor para obter tabela das pessoas juridicas
  CURSOR cr_crapjur (pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT jur.vlfatano
     FROM crapjur jur
    WHERE jur.cdcooper = pr_cdcooper
      AND jur.nrdconta = pr_nrdconta;

  -- Cursor para obter os parametros da tabela TBCC_MONITOR_PARAMETROS
  CURSOR cr_monitora (pr_cdcooper IN tbcc_monitoramento_parametro.cdcooper%TYPE)IS
  SELECT mon.qtrenda_diario_pf,
         mon.qtrenda_diario_pj,
         mon.vlcredito_diario_pf,
         mon.vlcredito_diario_pj,
         mon.inrenda_zerada
  FROM tbcc_monitoramento_parametro mon
  WHERE mon.cdcooper = pr_cdcooper;  

  -- Busca o ano e mês mais recente (anoftbru e mesftbru), depois busca o valor correspondente ao mesmo mês (vlrftbru).
  -- Dados financeiros dos cooperados pessoa jurídica.
  CURSOR cr_crapjfn (pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT anomes,
           decode(anomes,
                  anomes1, valor1,
                  anomes2, valor2,
                  anomes3, valor3,
                  anomes4, valor4,
                  anomes5, valor5,
                  anomes6, valor6,
                  anomes7, valor7,
                  anomes8, valor8,
                  anomes9, valor9,
                  anomes10, valor10,
                  anomes11, valor11,
                  anomes12, valor12)
           vlfatmes
      FROM (SELECT greatest (anomes1, anomes2, anomes3, anomes4, anomes5, anomes6, anomes7, anomes8, anomes9, anomes10, anomes11, anomes12) anomes,
                   anomes1, valor1,
                   anomes2, valor2,
                   anomes3, valor3,
                   anomes4, valor4,
                   anomes5, valor5,
                   anomes6, valor6,
                   anomes7, valor7,
                   anomes8, valor8,
                   anomes9, valor9,
                   anomes10, valor10,
                   anomes11, valor11,
                   anomes12, valor12
              FROM (SELECT vlrftbru##1 valor1,
                           decode(vlrftbru##1,
                                  0, 0,
                                  lpad(anoftbru##1, 4, '0') || lpad(mesftbru##1, 2, '0')) anomes1,
                           vlrftbru##2 valor2,
                           decode(vlrftbru##2,
                                  0, 0,
                                  lpad(anoftbru##2, 4, '0') || lpad(mesftbru##2, 2, '0')) anomes2,
                           vlrftbru##3 valor3,
                           decode(vlrftbru##3,
                                  0, 0,
                                  lpad(anoftbru##3, 4, '0') || lpad(mesftbru##3, 2, '0')) anomes3,
                           vlrftbru##4 valor4,
                           decode(vlrftbru##4,
                                  0, 0,
                                  lpad(anoftbru##4, 4, '0') || lpad(mesftbru##4, 2, '0')) anomes4,
                           vlrftbru##5 valor5,
                           decode(vlrftbru##5,
                                  0, 0,
                                  lpad(anoftbru##5, 4, '0') || lpad(mesftbru##5, 2, '0')) anomes5,
                           vlrftbru##6 valor6,
                           decode(vlrftbru##6,
                                  0, 0,
                                  lpad(anoftbru##6, 4, '0') || lpad(mesftbru##6, 2, '0')) anomes6,
                           vlrftbru##7 valor7,
                           decode(vlrftbru##7,
                                  0, 0,
                                  lpad(anoftbru##7, 4, '0') || lpad(mesftbru##7, 2, '0')) anomes7,
                           vlrftbru##8 valor8,
                         decode(vlrftbru##8,
                                0, 0,
                                lpad(anoftbru##8, 4, '0') || lpad(mesftbru##8, 2, '0')) anomes8,
                         vlrftbru##9 valor9,
                         decode(vlrftbru##9,
                                0, 0,
                                lpad(anoftbru##9, 4, '0') || lpad(mesftbru##9, 2, '0')) anomes9,
                         vlrftbru##10 valor10,
                         decode(vlrftbru##10,
                                0, 0,
                                lpad(anoftbru##10, 4, '0') || lpad(mesftbru##10, 2, '0')) anomes10,
                         vlrftbru##11 valor11,
                         decode(vlrftbru##11,
                                0, 0,
                                lpad(anoftbru##11, 4, '0') || lpad(mesftbru##11, 2, '0')) anomes11,
                         vlrftbru##12 valor12,
                         decode(vlrftbru##12,
                                0, 0,
                                lpad(anoftbru##12, 4, '0') || lpad(mesftbru##12, 2, '0')) anomes12
                    FROM crapjfn
                   WHERE cdcooper = pr_cdcooper
                     AND nrdconta = pr_nrdconta));

  -- Cursor com os dados do conjuge do cooperado
  CURSOR cr_crapcje (pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT cje.nrcpfcjg
          ,cje.vlsalari
      FROM crapcje cje
     WHERE cje.cdcooper = pr_cdcooper
       AND cje.nrdconta = pr_nrdconta;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  -- Procedure para criar o registro de controle de lavagem de dinheiro
  PROCEDURE cria_controle_lavagem (pr_dtmvtolt IN crapcld.dtmvtolt%TYPE
                                  ,pr_nrdconta IN crapcld.nrdconta%TYPE
                                  ,pr_cdagenci IN crapcld.cdagenci%TYPE
                                  ,pr_vlrendim IN crapcld.vlrendim%TYPE
                                  ,pr_vltotcre IN crapcld.vltotcre%TYPE) IS
    BEGIN

      INSERT INTO crapcld
                 (cdcooper
                 ,dtmvtolt
                 ,cdagenci
                 ,cdtipcld
                 ,nrdconta
                 ,vlrendim
                 ,vltotcre)
         VALUES (pr_cdcooper
                ,pr_dtmvtolt
                ,pr_cdagenci
                ,1 -- Diario da cooperativa
                ,pr_nrdconta
                ,pr_vlrendim
                ,pr_vltotcre);

    EXCEPTION

      WHEN OTHERS THEN

        vr_dscritic := 'Erro na inclusão da crapcld. ' || sqlerrm;

        RAISE vr_exc_saida;

  END;


BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO vr_crapcop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN

    vr_cdcritic := 651;

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;

  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);

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

    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

    RAISE vr_exc_saida;

  END IF;

  -- Obter dados parametrizados
  OPEN cr_monitora(pr_cdcooper => pr_cdcooper);
  FETCH cr_monitora INTO vr_qtcopfis,
                         vr_qtcopjur,
                         vr_vldirfis,
                         vr_vldirjur,
                         vr_indrenda;
  
  IF cr_monitora%NOTFOUND THEN
    vr_cdcritic := 055;
    CLOSE cr_monitora;
    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_monitora;
  END IF;

  -- Leitura dos lancamentos agrupados por conta
  FOR rw_craplcm IN cr_craplcm (pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP

    -- Obtem o cooperado do lancamento
    OPEN cr_crapass (pr_nrdconta => rw_craplcm.nrdconta);

    -- Salvar o PA e o tipo de pessoa
    FETCH cr_crapass INTO vr_cdagenci, vr_inpessoa;

    -- Desconsiderar e ir para o proximo se nao achar
    IF  cr_crapass%NOTFOUND  THEN
      CLOSE cr_crapass;
      CONTINUE;
    END IF;

    CLOSE cr_crapass;

    -- Limpar rendimento e lista de titulares
    vr_vlrendim := 0;
    vr_lscpfcgc := NULL;
    vr_flgconta := FALSE;

    -- Se pessoa fisica
    IF  vr_inpessoa = 1  AND
        rw_craplcm.vlcredit >= vr_vldirfis  THEN

      -- Somar os rendimentos e juntar os CPF dos titulares
      FOR rw_crapttl IN cr_crapttl (pr_nrdconta => rw_craplcm.nrdconta) LOOP

        -- Somar o salario ao rendimento
        vr_vlrendim := vr_vlrendim + rw_crapttl.vldrendi + rw_crapttl.vlsalari;

        -- Guardar os CPF dos titulares
        IF  vr_lscpfcgc IS NULL  THEN
          vr_lscpfcgc := rw_crapttl.nrcpfcgc;
        ELSE
          vr_lscpfcgc := vr_lscpfcgc || ',' || rw_crapttl.nrcpfcgc;
        END IF;

      END LOOP;

      -- Separar os CPF em um array
      vr_vet_nrcpfcgc := gene0002.fn_quebra_string (pr_string  => vr_lscpfcgc
                                                   ,pr_delimit => ',');

      -- Somar os rendimentos do conjuge mas desconsiderar os que sao titulares
      FOR rw_crapcje IN cr_crapcje (pr_nrdconta => rw_craplcm.nrdconta) LOOP

        -- Percorrer os CPFs dos titulares para verificar que nenhum deles seja o conjuge em questao
        FOR vr_ind IN 1 .. vr_vet_nrcpfcgc.COUNT LOOP

          -- Se o Conjuge tambem eh titular, desconsiderar
          IF  rw_crapcje.nrcpfcjg = vr_vet_nrcpfcgc(vr_ind)  THEN
            vr_flgconta := TRUE;
            EXIT;
          END IF;

        END LOOP;

        -- Se o conjuge nao eh titular, somar o salario
        IF  NOT vr_flgconta  THEN
          vr_vlrendim := vr_vlrendim + rw_crapcje.vlsalari;
        END IF;

      END LOOP;

      /*** Indicador de renda zerada ****/
      IF vr_indrenda = 0 AND 
         vr_vlrendim = 0 THEN
         CONTINUE;
      END IF;

      -- Se o valor do credito >= que rendimento vezes uma quantidade estipulada (10)
      -- cria o controle de lavagem de dinheiro
      IF  rw_craplcm.vlcredit >= (vr_vlrendim * vr_qtcopfis)  THEN
        cria_controle_lavagem (pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdconta => rw_craplcm.nrdconta
                              ,pr_vlrendim => vr_vlrendim
                              ,pr_vltotcre => rw_craplcm.vlcredit);
      END IF;

    -- Se pessoa juridica
    ELSIF
      vr_inpessoa = 2  AND
      rw_craplcm.vlcredit >= vr_vldirjur  THEN

      -- Obter o ultimo periodo e valor do faturamento mensal
      OPEN cr_crapjfn (pr_nrdconta => rw_craplcm.nrdconta);

      FETCH cr_crapjfn INTO vr_anomes, vr_vlfatmes;

      CLOSE cr_crapjfn;

      -- Obter o faturamento anual da pessoa juridica
      OPEN cr_crapjur (pr_nrdconta => rw_craplcm.nrdconta);

      FETCH cr_crapjur INTO vr_vlfatano;

      CLOSE cr_crapjur;

      -- Se a media do faturamento do ano for maior que o faturamento do
      -- ultimo mes, entao considerar esta media.
      IF  vr_vlfatano / 12 > vr_vlfatmes  THEN
        vr_vlrendim := vr_vlfatano / 12;
      ELSE -- Senao considerar o rendimento do ultimo faturamento
        vr_vlrendim := vr_vlfatmes;
      END IF;
      
      /*** Indicador de renda zerada ****/
      IF  vr_indrenda = 0 AND
          vr_vlrendim = 0 THEN
          CONTINUE;
      END IF;

      -- Se o valor do credito > que rendimento vezes uma quantidade estipulada (10)
      -- cria o controle de lavagem de dinheiro
      IF  rw_craplcm.vlcredit > (vr_vlrendim * vr_qtcopjur)  THEN
        cria_controle_lavagem (pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdconta => rw_craplcm.nrdconta
                              ,pr_vlrendim => vr_vlrendim
                              ,pr_vltotcre => rw_craplcm.vlcredit);
      END IF;

    END IF;

  END LOOP;

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

END PC_CRPS598;
/
