CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS100 (pr_cdcooper  IN crapcop.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER
                     ,pr_stprogra OUT PLS_INTEGER
                     ,pr_infimsol OUT PLS_INTEGER
                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                     ,pr_dscritic OUT VARCHAR2) AS
/*..........................................................................

   Programa: PC_CRPS100                          Antigo: Fontes/crps100.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94                         Ultima atualizacao: 02/05/2014

   Dados referentes ao programa:

   Frequencia: Batch - Background.

   Objetivo  : Emitir a listagem de acompanhamento do utilizado, saque e
               adiantamento.
               Relatorio 84.
               Atende a solicitacao  55.
               Ordem da Solicitacao 043.
               Exclusividade 2.
               Ordem do programa na solicitacao = 1.

   Alteracoes: Tratar conversao para v8 (Odair)

               05/05/2000 - Listar o pac (Odair)

               01/06/2000 - Alterar formulario (Odair)

               04/10/2001 - Incluir qtddusol (Margarete).

               28/02/2002 - Separar por PAC (Ze Eduardo).

               23/07/2003 - Incluir "CL-" no nome dos associados que estao em
                            "credito em liquidacao" (Julio).

               12/08/2003 - Mudanca no calculo do utilizado (Deborah).

               29/08/2005 - Incluido total de associados que possuem limite de
                            credito, e total de associados que utilizam esse
                            limite de credito (Diego).

               14/02/2006 - Alterado Resumo Geral Por PAC, para listar o total
                            separado entre Contas Fisicas e Juridicas (Diego).

               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               07/04/2008 - Lista todos os PACs que tenham associados com
                            limite de credito, mesmo que o limite nao esteja
                            sendo utilizado (Elton).

               20/08/2013 - Conversao Progress => Oracle (Gabriel).

               10/10/2013 - Ajuste para controle de criticas (Gabriel)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)
                            
               02/05/2014 - Ajustes devido estouro de campo (Marcos-Supero)             

............................................................................. */

  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS100';  -- Codigo do presente programa
  vr_nmrescop crapcop.nmrescop%TYPE;               -- Nome da cooperativa
  vr_inpessoa crapass.inpessoa%TYPE;               -- Tipo de pessoa
  vr_cdagenci crapass.cdagenci%TYPE;               -- PAC do cooperado
  vr_nmresage crapage.nmresage%TYPE;               -- Nome do PAC
  vr_index_pac_tipo  VARCHAR2(6);                  -- Index para a tabela dos limites por inpessoa e cdagenci
  vr_index_pac_conta VARCHAR2(15);                 -- Index para a tabela do relatorio
  vr_cdcritic        crapcri.cdcritic%TYPE;        -- Codigo da critica
  vr_dscritic        VARCHAR2(2000);               -- Descricao da critica
  vr_exc_saida       EXCEPTION;                    -- Exeption parar cadeia
  vr_exc_fimprg      EXCEPTION;                    -- Exception para rodar fimprf

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;

  -- Cursor dos cooperadoros
  CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT ass.nrdconta
          ,ass.dtdemiss
          ,ass.nmprimtl
          ,ass.inpessoa
          ,ass.cdagenci
          ,ass.vllimcre
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper;

  -- Cursor com o saldo dos associados
  CURSOR cr_crapsld (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT sld.nrdconta
          ,sld.vlsddisp
          ,sld.vlsdchsl
          ,sld.vlsdblfp
          ,sld.vlsdblpr
          ,sld.qtddusol
          ,sld.vlsdbloq
          ,sld.dtdsdclq
      FROM crapsld sld
     WHERE sld.cdcooper = pr_cdcooper;

  -- Cursor com os PAC
  CURSOR cr_crapage (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT age.cdagenci
          ,age.nmresage
      FROM crapage age
     WHERE age.cdcooper = pr_cdcooper;

  -- Registro para manter dados dos associados
  TYPE typ_reg_crapass IS
    RECORD(nmprimtl crapass.nmprimtl%TYPE
          ,dtdemiss crapass.dtdemiss%TYPE
          ,inpessoa crapass.inpessoa%TYPE
          ,cdagenci crapass.cdagenci%TYPE
          ,vllimcre crapass.vllimcre%TYPE);

  -- Registro para manter dados dos saldos
  TYPE typ_reg_crapsld IS
    RECORD(vlsddisp crapsld.vlsddisp%TYPE
          ,vlsdchsl crapsld.vlsdchsl%TYPE
          ,vlsdblfp crapsld.vlsdblfp%TYPE
          ,vlsdblpr crapsld.vlsdblpr%TYPE
          ,qtddusol crapsld.qtddusol%TYPE
          ,vlsdbloq crapsld.vlsdbloq%TYPE
          ,dtdsdclq crapsld.dtdsdclq%TYPE);

  -- Registro para manter a quantidade de associados com limite
  TYPE typ_reg_valores IS
    RECORD(qtdcomlm NUMBER(25,0),
           qtdutili NUMBER(25,0),
           vldisblq NUMBER(25,2),
           vllimite NUMBER(25,2),
           vlchqblq NUMBER(25,2),
           vlutiliz NUMBER(25,2),
           vlsaqblq NUMBER(25,2),
           vladiant NUMBER(25,2));

  -- Registro para relatorio
  TYPE typ_reg_rel IS
    RECORD(cdagenci crapage.cdagenci%TYPE
          ,nrdconta crapass.nrdconta%TYPE
          ,vllimcre crapass.vllimcre%TYPE
          ,inpessoa crapass.inpessoa%TYPE
          ,nmprimtl crapass.nmprimtl%TYPE
          ,qtddusol crapsld.qtddusol%TYPE
          ,vlbqprfr NUMBER(10,2)
          ,vldichbq NUMBER(10,2)
          ,dtdsdclq crapsld.dtdsdclq%TYPE);

  -- Tabela tipo crapass
  TYPE typ_tab_crapass IS
    TABLE OF typ_reg_crapass
      INDEX BY PLS_INTEGER; --> Nossa chave será apenas o código da conta

  -- Tabela do tipo crapsld
  TYPE typ_tab_crapsld IS
    TABLE OF typ_reg_crapsld
      INDEX BY PLS_INTEGER; --> Nossa chave será apenas o código da conta

   -- Tabela de registros do tipo LIMITES por inpessoa
  TYPE typ_tab_limites IS
    TABLE OF typ_reg_valores
      INDEX BY PLS_INTEGER;

  -- Tabela do tipo LIMITES por inpessoa e cdagenci
  TYPE typ_tab_limites_pac IS
    TABLE OF typ_reg_valores
      INDEX BY VARCHAR2(6);

  -- Tabela para relatorio
  TYPE typ_tab_rel IS
    TABLE OF typ_reg_rel
      INDEX BY VARCHAR2(15);

  -- Vetor que armazenará uma instancia com o formato da crapass
  vr_tab_crapass typ_tab_crapass;

  -- Vetor que armazenará uma instancia com o formato da crapsld
  vr_tab_crapsld typ_tab_crapsld;

  -- Vetor que armazenará uma instancia com o formato limites
  vr_tab_valores typ_tab_limites;

  -- Vetor que armazenará uma instancia com o formato limites pac
  vr_tab_valores_pac typ_tab_limites_pac;

  -- Vetor que armazenará uma instancia do relatorio
  vr_tab_rel typ_tab_rel;

  -- Dados dos associados
  rw_crapass cr_crapass%rowtype;

  -- Dados do saldos
  rw_crapsld cr_crapsld%rowtype;

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%rowtype;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO vr_nmrescop;

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

    RAISE vr_exc_saida;

  END IF;

  -- Guardar os associados
  FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP

    vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
    vr_tab_crapass(rw_crapass.nrdconta).dtdemiss := rw_crapass.dtdemiss;
    vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
    vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
    vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;

  END LOOP;

  -- Guardar os saldos dos cooperados
  FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP

    vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
    vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
    vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
    vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
    vr_tab_crapsld(rw_crapsld.nrdconta).qtddusol := rw_crapsld.qtddusol;
    vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
    vr_tab_crapsld(rw_crapsld.nrdconta).dtdsdclq := rw_crapsld.dtdsdclq;

  END LOOP;

  -- Inicializando o vetor de totais por tipo de pessoa para não gerar
  -- erro no_data_found no final do processo (Edison - AMcom)
  FOR vr_ind IN 1 .. 2 LOOP
    vr_tab_valores(vr_ind).vldisblq := 0;
    vr_tab_valores(vr_ind).vllimite := 0;
    vr_tab_valores(vr_ind).vlchqblq := 0;
    vr_tab_valores(vr_ind).vlutiliz := 0;
    vr_tab_valores(vr_ind).vlsaqblq := 0;
    vr_tab_valores(vr_ind).vladiant := 0;
    vr_tab_valores(vr_ind).qtdcomlm := 0;
    vr_tab_valores(vr_ind).qtdutili := 0;
  END LOOP;


  -- Percorrer todos os cooperados com limite e admitidos
  FOR vr_nrdconta IN vr_tab_crapass.FIRST .. vr_tab_crapass.LAST LOOP

    -- Se nao existe, proximo
    IF  NOT vr_tab_crapass.EXISTS(vr_nrdconta)  THEN
      CONTINUE;
    END IF;

    -- Se nao tiver limite ou se estiver demitido, proximo
    IF  NOT (vr_tab_crapass(vr_nrdconta).vllimcre <> 0      AND
             vr_tab_crapass(vr_nrdconta).dtdemiss IS NULL)  THEN
      CONTINUE;
    END IF;

    -- Guardar INPESSOA e CDAGENCI
    vr_inpessoa := vr_tab_crapass(vr_nrdconta).inpessoa;
    vr_cdagenci := vr_tab_crapass(vr_nrdconta).cdagenci;
    -- Chave por INPESSOA e CDAGENCI
    vr_index_pac_tipo := lpad(vr_inpessoa,1,'0') || lpad(vr_cdagenci,5,'0');

     -- Contabilizar qtd de cooperados com limites por INPESSOA
    IF  NOT vr_tab_valores.EXISTS(vr_inpessoa)  THEN
      vr_tab_valores(vr_inpessoa).qtdcomlm := 1;
    ELSE
      vr_tab_valores(vr_inpessoa).qtdcomlm := vr_tab_valores(vr_inpessoa).qtdcomlm + 1;
    END IF;

    -- Contabilizar qtd de cooperados com limites por INPESSOA e CDAGENCI
    IF  NOT vr_tab_valores_pac.EXISTS(vr_index_pac_tipo)  THEN
      vr_tab_valores_pac(vr_index_pac_tipo).qtdcomlm := 1;
    ELSE
      vr_tab_valores_pac(vr_index_pac_tipo).qtdcomlm :=  vr_tab_valores_pac(vr_index_pac_tipo).qtdcomlm + 1;
    END IF;

    -- Se o cooperado tem o saldo
    IF  vr_tab_crapsld.EXISTS(vr_nrdconta)  THEN

      -- Se tiver saldo negativo
      IF  vr_tab_crapsld(vr_nrdconta).vlsddisp < 0  THEN
        vr_tab_valores(vr_inpessoa).qtdutili := nvl(vr_tab_valores(vr_inpessoa).qtdutili,0) + 1;
        vr_tab_valores_pac(vr_index_pac_tipo).qtdutili := nvl(vr_tab_valores_pac(vr_index_pac_tipo).qtdutili,0) + 1;

      END IF;

    END IF;

  END LOOP; -- Fim loop associado

  -- Loop dos saldos
  FOR vr_nrdconta IN vr_tab_crapsld.FIRST .. vr_tab_crapsld.LAST LOOP

    -- Se nao existe proximo
    IF  NOT vr_tab_crapsld.EXISTS(vr_nrdconta)  THEN
      CONTINUE;
    END IF;

    -- Se saldo disponivel + saldo cheque especial menor que 0
    IF  vr_tab_crapsld(vr_nrdconta).vlsddisp + vr_tab_crapsld(vr_nrdconta).vlsdchsl < 0  THEN

      -- Se nao acha cooperado, criticar
      IF  NOT vr_tab_crapass.EXISTS(vr_nrdconta)  THEN

        vr_cdcritic := 251;

        RAISE vr_exc_saida;

      END IF;

      -- Montar a chave com o CDAGENCI e NRDCONTA
      vr_cdagenci := vr_tab_crapass(vr_nrdconta).cdagenci;
      vr_index_pac_conta := lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0');

      -- Alimentar dados para o relatorio
      vr_tab_rel(vr_index_pac_conta).cdagenci := vr_tab_crapass(vr_nrdconta).cdagenci;
      vr_tab_rel(vr_index_pac_conta).nrdconta := vr_nrdconta;
      vr_tab_rel(vr_index_pac_conta).vllimcre := vr_tab_crapass(vr_nrdconta).vllimcre;
      vr_tab_rel(vr_index_pac_conta).nmprimtl := vr_tab_crapass(vr_nrdconta).nmprimtl;
      vr_tab_rel(vr_index_pac_conta).inpessoa := vr_tab_crapass(vr_nrdconta).inpessoa;
      vr_tab_rel(vr_index_pac_conta).qtddusol := vr_tab_crapsld(vr_nrdconta).qtddusol;
      vr_tab_rel(vr_index_pac_conta).vlbqprfr := vr_tab_crapsld(vr_nrdconta).vlsdblfp +
                                                 vr_tab_crapsld(vr_nrdconta).vlsdblpr +
                                                 vr_tab_crapsld(vr_nrdconta).vlsdbloq;
      vr_tab_rel(vr_index_pac_conta).vldichbq := vr_tab_crapsld(vr_nrdconta).vlsddisp +
                                                 vr_tab_crapsld(vr_nrdconta).vlsdchsl;
      vr_tab_rel(vr_index_pac_conta).dtdsdclq := vr_tab_crapsld(vr_nrdconta).dtdsdclq;

    END IF;

  END LOOP; -- Fim loop saldos

  -- Geracao do XML
  DECLARE

    vr_chave_rel VARCHAR2(15);                 -- Chave para tabela do relatorio
    vr_dsxmldad  CLOB;                         -- Dados do XML em memória
    vr_nrdconta  crapass.nrdconta%TYPE;        -- Conta do cooperado
    vr_nmprimtl  crapass.nmprimtl%TYPE;        -- Nome do cooperado
    vr_vldichbq  NUMBER(10,2);                 -- DISP+CHSAL+BLQ
    vr_vllimcre  crapass.vllimcre%TYPE;        -- Limite do cooperado
    vr_qtddusol  crapsld.qtddusol%TYPE;        -- Dias usando o limite
    vr_vlbqprfr  NUMBER(10,2);                 -- Cheques bloqueados
    vr_vlcalcul  NUMBER(10,2);                 -- Calculo auxiliar
    vr_vlutiliz  NUMBER(10,2);                 -- Valor utilizado
    vr_vlsaqblq  NUMBER(10,2);                 -- Saldo Bloqueado
    vr_vladiant  NUMBER(10,2);                 -- Adiantamento
    vr_dsdireto  VARCHAR2(50);

    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_dsxmldad,length(pr_des_dados),pr_des_dados);
    END;

  BEGIN

    -- Inicializar o CLOB (XML)
    dbms_lob.createtemporary(vr_dsxmldad, TRUE);
    dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

    -- Inicio
    pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');

    -- Obter o primeiro indice da tabela do relatorio
    vr_chave_rel := vr_tab_rel.FIRST;

    -- Iterar pelos registros do relatorio
    LOOP

      -- Sair quando nao existir a chave
      EXIT WHEN vr_chave_rel IS NULL;

      -- Se nao achar o cooperado, gerar critica
      IF  NOT vr_tab_crapass.EXISTS(vr_tab_rel(vr_chave_rel).nrdconta)  THEN

        vr_cdcritic := 251;

        RAISE vr_exc_saida;

      END IF;

      -- Armazenar dados do cooperado
      vr_nrdconta := vr_tab_rel(vr_chave_rel).nrdconta;
      vr_inpessoa := vr_tab_rel(vr_chave_rel).inpessoa;
      vr_cdagenci := vr_tab_rel(vr_chave_rel).cdagenci;
      vr_vldichbq := vr_tab_rel(vr_chave_rel).vldichbq;
      vr_vlcalcul := vr_vldichbq + vr_tab_rel(vr_chave_rel).vllimcre;
      vr_vlbqprfr := vr_tab_rel(vr_chave_rel).vlbqprfr;
      vr_vladiant := 0;
      vr_vlsaqblq := 0;

      -- Armazenar o VALOR UTILIZADO , SAQUE S/BLOQ. e ADIANTAMENTO
      IF  vr_vlcalcul > 0  THEN
        vr_vlutiliz := vr_vldichbq;
      ELSE
        vr_vlcalcul := vr_vlcalcul + vr_vlbqprfr;

        IF  vr_vlcalcul > 0  THEN
          vr_vlutiliz := vr_tab_rel(vr_chave_rel).vllimcre * -1;
          vr_vlsaqblq := vr_vlcalcul - vr_vlbqprfr;
        ELSE
          vr_vlutiliz := vr_tab_rel(vr_chave_rel).vllimcre * -1;
          vr_vlsaqblq := vr_vlbqprfr * -1;
          vr_vladiant := vr_vlcalcul;
        END IF;

      END IF;

      -- Nome do Cooperado
      IF  vr_tab_rel(vr_chave_rel).dtdsdclq IS NULL  THEN
        vr_nmprimtl := substr(vr_tab_rel(vr_chave_rel).nmprimtl,0,26);
      ELSE
        vr_nmprimtl := 'CL - ' || substr(vr_tab_rel(vr_chave_rel).nmprimtl,0,21);
      END IF;

      -- Se Limite de credito zerado, deixar nulo
      IF  nvl(vr_tab_rel(vr_chave_rel).vllimcre,0) = 0  THEN
        vr_vllimcre := NULL;
      ELSE
        vr_vllimcre := vr_tab_rel(vr_chave_rel).vllimcre;
      END IF;

      -- Qtd. dias usando o limite
      IF  nvl(vr_tab_rel(vr_chave_rel).qtddusol,0) = 0  THEN
        vr_qtddusol := NULL;
      ELSE
        vr_qtddusol := vr_tab_rel(vr_chave_rel).qtddusol;
      END IF;

      -- Cheques bloqueados
      IF  nvl(vr_tab_rel(vr_chave_rel).vlbqprfr,0) = 0  THEN
        vr_vlbqprfr := NULL;
      END IF;

      -- Valor utilizado, atribuir null se estiver zerado para nao aparecer no relatorio
      IF  nvl(vr_vlutiliz,0) = 0  THEN
        vr_vlutiliz := NULL;
      END IF;

      -- Saldo bloqueado, atribuir null se estiver zerado para nao aparecer no relatorio
      IF  nvl(vr_vlsaqblq,0) = 0  THEN
        vr_vlsaqblq := NULL;
      END IF;

      -- Adiantamento, atribuir null se estiver zerado para nao aparecer no relatorio
      IF  nvl(vr_vladiant,0) = 0  THEN
        vr_vladiant := NULL;
      END IF;

      -- escreve tag a tag de detalhe
      pc_escreve_clob( '<conta>' ||
                       ' <nrdconta>' || gene0002.fn_mask_conta(vr_nrdconta)    || '</nrdconta>' ||
                       ' <cdagenci>' || to_char(vr_cdagenci,'fm990')           || '</cdagenci>' ||
                       ' <nmprimtl>' || vr_nmprimtl                            || '</nmprimtl>' ||
                       ' <vldichbq>' || to_char(vr_vldichbq,'fm99G999G990D00') || '</vldichbq>' ||
                       ' <vllimcre>' || to_char(vr_vllimcre,'fm999999G999')    || '</vllimcre>' ||
                       ' <qtddusol>' || to_char(vr_qtddusol,'fm9990')          || '</qtddusol>' ||
                       ' <vlbqprfr>' || to_char(vr_vlbqprfr,'fm999999G990D00') || '</vlbqprfr>' ||
                       ' <vlutiliz>' || to_char(vr_vlutiliz,'fm999999G990D00') || '</vlutiliz>' ||
                       ' <vlsaqblq>' || to_char(vr_vlsaqblq,'fm999999G990D00') || '</vlsaqblq>' ||
                       ' <vladiant>' || to_char(vr_vladiant,'fm99G999G990D00') || '</vladiant>' ||
                       '</conta>');

      -- Chave da tabela INPESSOA e CDAGENCI
      vr_index_pac_tipo := lpad(vr_inpessoa,1,'0') || lpad(vr_cdagenci,5,'0');

      -- Verificar se ja existem valores por INPESSOA E CDAGENCI
      IF  NOT vr_tab_valores_pac.EXISTS(vr_index_pac_tipo)  THEN
        vr_tab_valores_pac(vr_index_pac_tipo).vldisblq := vr_vldichbq;
      ELSE
        vr_tab_valores_pac(vr_index_pac_tipo).vldisblq := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vldisblq,0) + nvl(vr_vldichbq,0);
      END IF;

      -- Guardar totais por INPESSOA E CDAGENCI
      vr_tab_valores_pac(vr_index_pac_tipo).vllimite := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vllimite,0) + nvl(vr_vllimcre,0);
      vr_tab_valores_pac(vr_index_pac_tipo).vlchqblq := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vlchqblq,0) + nvl(vr_vlbqprfr,0);
      vr_tab_valores_pac(vr_index_pac_tipo).vlutiliz := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vlutiliz,0) + nvl(vr_vlutiliz,0);
      vr_tab_valores_pac(vr_index_pac_tipo).vlsaqblq := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vlsaqblq,0) + nvl(vr_vlsaqblq,0);
      vr_tab_valores_pac(vr_index_pac_tipo).vladiant := nvl(vr_tab_valores_pac(vr_index_pac_tipo).vladiant,0) + nvl(vr_vladiant,0);

      -- Verificar se ja existe valores por INPESSOA
      IF  NOT vr_tab_valores.EXISTS(vr_inpessoa)  THEN
        vr_tab_valores(vr_inpessoa).vldisblq := vr_vldichbq;
      ELSE
        vr_tab_valores(vr_inpessoa).vldisblq := nvl(vr_tab_valores(vr_inpessoa).vldisblq,0) + nvl(vr_vldichbq,0);
      END IF;

      -- Guardar totais por INPESSOA
      vr_tab_valores(vr_inpessoa).vllimite := nvl(vr_tab_valores(vr_inpessoa).vllimite,0) + nvl(vr_vllimcre,0);
      vr_tab_valores(vr_inpessoa).vlchqblq := nvl(vr_tab_valores(vr_inpessoa).vlchqblq,0) + nvl(vr_vlbqprfr,0);
      vr_tab_valores(vr_inpessoa).vlutiliz := nvl(vr_tab_valores(vr_inpessoa).vlutiliz,0) + nvl(vr_vlutiliz,0);
      vr_tab_valores(vr_inpessoa).vlsaqblq := nvl(vr_tab_valores(vr_inpessoa).vlsaqblq,0) + nvl(vr_vlsaqblq,0);
      vr_tab_valores(vr_inpessoa).vladiant := nvl(vr_tab_valores(vr_inpessoa).vladiant,0) + nvl(vr_vladiant,0);

      -- Proximo na sequencia da CHAVE
      vr_chave_rel := vr_tab_rel.NEXT(vr_chave_rel);

    END LOOP;

    -- Abrir cursor do PAC
    OPEN cr_crapage (pr_cdcooper => pr_cdcooper);

    -- Percorrer os PAC
    LOOP

      FETCH cr_crapage INTO vr_cdagenci, vr_nmresage;

      -- Sair se nao encontrar mais nenhum PAC
      EXIT WHEN cr_crapage%NOTFOUND;

      IF vr_cdagenci = 38 THEN
        vr_cdagenci := vr_cdagenci;
      END IF;

      -- Chave por INPESSOA e PAC
      vr_index_pac_tipo := lpad(vr_cdagenci,5,'0');

      -- Se não existem dados, proximo PAC
      IF  NOT vr_tab_valores_pac.EXISTS('1' || vr_index_pac_tipo)  OR
          NOT vr_tab_valores_pac.EXISTS('2' || vr_index_pac_tipo)  THEN
        CONTINUE;
      END IF;

       -- Sem valores, proximo PAC
      IF  nvl(vr_tab_valores_pac('1' || vr_index_pac_tipo).qtdcomlm,0) = 0  OR
          nvl(vr_tab_valores_pac('2' || vr_index_pac_tipo).qtdcomlm,0) = 0 THEN
        CONTINUE;
      END IF;

      -- Sem valor para PJ, inicializa zerados
      IF  NOT vr_tab_valores_pac.EXISTS('2' ||  vr_index_pac_tipo)  THEN

        vr_tab_valores_pac('2' || vr_index_pac_tipo).vldisblq := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).vldisblq := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).vllimite := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).vlutiliz := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).vlsaqblq := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).vladiant := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).qtdcomlm := 0;
        vr_tab_valores_pac('2' || vr_index_pac_tipo).qtdutili := 0;

      END IF;

      -- Totais do PAC por INPESSOA E CDAGENCI
      pc_escreve_clob('<pac>' ||
                      ' <cdagenci>' || vr_cdagenci || '</cdagenci>' ||
                      ' <nmresage>' || vr_nmresage || '</nmresage>' ||
                      ' <vldisblq_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vldisblq,'fm99G999G990D00') || '</vldisblq_f>' ||
                      ' <vllimite_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vllimite,'fm999999G990')    || '</vllimite_f>' ||
                      ' <vlchqblq_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vlchqblq,'fm999999G990D00') || '</vlchqblq_f>' ||
                      ' <vlutiliz_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vlutiliz,'fm999999G990D00') || '</vlutiliz_f>' ||
                      ' <vlsaqblq_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vlsaqblq,'fm999999G990D00') || '</vlsaqblq_f>' ||
                      ' <vladiant_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).vladiant,'fm99G999G990D00') || '</vladiant_f>' ||
                      ' <qtdcomlm_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).qtdcomlm,'999990')          || '</qtdcomlm_f>' ||
                      ' <qtdutili_f>' || to_char(vr_tab_valores_pac('1' || vr_index_pac_tipo).qtdutili,'fm9999990')       || '</qtdutili_f>' ||

                      ' <vldisblq_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vldisblq,'fm99G999G990D00') || '</vldisblq_j>' ||
                      ' <vllimite_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vllimite,'fm999999G990')    || '</vllimite_j>' ||
                      ' <vlchqblq_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vlchqblq,'fm999999G990D00') || '</vlchqblq_j>' ||
                      ' <vlutiliz_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vlutiliz,'fm999999G990D00') || '</vlutiliz_j>' ||
                      ' <vlsaqblq_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vlsaqblq,'fm999999G990D00') || '</vlsaqblq_j>' ||
                      ' <vladiant_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).vladiant,'fm99G999G990D00') || '</vladiant_j>' ||
                      ' <qtdcomlm_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).qtdcomlm,'999990')          || '</qtdcomlm_j>' ||
                      ' <qtdutili_j>' || to_char(vr_tab_valores_pac('2' || vr_index_pac_tipo).qtdutili,'fm9999990')       || '</qtdutili_j>' ||
                      '</pac>');

    END LOOP;

    -- Fechar cursor do PAC
    CLOSE cr_crapage;

    -- Iniciar a tag TOTAIS
    pc_escreve_clob('<totais>');

    -- Totais para tipo de pessoa Fisica
    pc_escreve_clob('<fisica>' ||
                    ' <vldisblq_f>' || vr_tab_valores('1').vldisblq || '</vldisblq_f>' ||
                    ' <vllimite_f>' || vr_tab_valores('1').vllimite || '</vllimite_f>' ||
                    ' <vlchqblq_f>' || vr_tab_valores('1').vlchqblq || '</vlchqblq_f>' ||
                    ' <vlutiliz_f>' || vr_tab_valores('1').vlutiliz || '</vlutiliz_f>' ||
                    ' <vlsaqblq_f>' || vr_tab_valores('1').vlsaqblq || '</vlsaqblq_f>' ||
                    ' <vladiant_f>' || vr_tab_valores('1').vladiant || '</vladiant_f>' ||
                    ' <qtdcomlm_f>' || vr_tab_valores('1').qtdcomlm || '</qtdcomlm_f>' ||
                    ' <qtdutili_f>' || vr_tab_valores('1').qtdutili || '</qtdutili_f>' ||
                    '</fisica>');

    -- totais para tipo de pessoa Juridica
    pc_escreve_clob('<juridica>' ||
                    ' <vldisblq_j>' || vr_tab_valores('2').vldisblq || '</vldisblq_j>' ||
                    ' <vllimite_j>' || vr_tab_valores('2').vllimite || '</vllimite_j>' ||
                    ' <vlchqblq_j>' || vr_tab_valores('2').vlchqblq || '</vlchqblq_j>' ||
                    ' <vlutiliz_j>' || vr_tab_valores('2').vlutiliz || '</vlutiliz_j>' ||
                    ' <vlsaqblq_j>' || vr_tab_valores('2').vlsaqblq || '</vlsaqblq_j>' ||
                    ' <vladiant_j>' || vr_tab_valores('2').vladiant || '</vladiant_j>' ||
                    ' <qtdcomlm_j>' || vr_tab_valores('2').qtdcomlm || '</qtdcomlm_j>' ||
                    ' <qtdutili_j>' || vr_tab_valores('2').qtdutili || '</qtdutili_j>' ||
                    '</juridica>');

    -- Fechar tag TOTAIS
    pc_escreve_clob('</totais>');

    -- ao fina do loop, prcisamos encerrar a raiz
    pc_escreve_clob('</raiz>');

    -- Obter diretorio rl da cooperativa logada
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'rl');

    -- Solicitar relatorio crrl084.lst
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                        --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                        --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmldad                        --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz'                            --> Nó do XML para iteração
                               ,pr_dsjasper  => 'crrl084.jasper'                   --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                               --> Array de parametros diversos
                               ,pr_dsarqsaid => vr_dsdireto || '/crrl084.lst'      --> Path/Nome do arquivo PDF gerado
                               ,pr_flg_gerar => 'N'                                --> Gerar o arquivo na hora
                               ,pr_qtcoluna  => 132                                --> Qtd colunas do relatório (80,132,234)
                               ,pr_sqcabrel  => 1                                  --> Sequencia do relatorio (cabrel 1..5)
                               ,pr_flg_impri => 'S'                                --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '132dm'                            --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                                  --> Número de cópias para impressão
                               ,pr_parser    => 'D'                                --> Novo metodo de parse XML
                               ,pr_des_erro  => vr_dscritic);

    -- Se retornar critica, sair
    IF  vr_dscritic IS NOT NULL  THEN
      RAISE vr_exc_saida;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsxmldad);
    dbms_lob.freetemporary(vr_dsxmldad);

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    COMMIT;

  END;


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

END PC_CRPS100;
/

