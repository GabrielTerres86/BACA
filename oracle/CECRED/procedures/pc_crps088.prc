CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS088 (pr_cdcooper IN crapcop.cdcooper%type
                                         ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                         ,pr_cdcritic OUT crapcri.cdcritic%type
                                         ,pr_dscritic OUT VARCHAR2)
AS
  BEGIN
    /* .........................................................................
    Programa: PC_CRPS088 (Antigo Fontes/crps088.p)
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Deborah/Edson
    Data    : Janeiro/94.                       Ultima atualizacao: 05/06/2017

    Dados referentes ao programa:

    Frequencia: Mensal (Batch - Background).
    Objetivo  : Atende a solicitacao 046.
               Emite listagem dos emprestimos em atraso (70).

    Alteracao : 13/06/96 - Alterado para ajustar layout do relatorio (Odair).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               30/12/97 - Alterar o layout (Odair)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/09/98 - Ajuste na selecao dos contratos (Deborah).

               09/10/00 - Alterar formato do campo telefone (Margarete/Planner)

               30/06/2004 - Prever avalistas terceiros(Mirtes)

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               31/10/2007 - Mostrar secao a partir da ttl.nmdsecao(Guilherme).

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               23/08/2013 - Conversao Progress -> PL/SQL (Douglas Pagel).

               03/10/2013 - Alteração para pegar o numero de telefone da
                            craptfc e não da crapass. (Douglas Pagel).

               14/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                            das criticas e chamadas a fimprg.p (Douglas Pagel).
                            
               22/06/2016 - Correcao para o uso da function fn_busca_dstextab 
                            da TABE0001. (Carlos Rafael Tanholi).

			   05/06/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
						    (Adriano - P339).
    ......................................................................... */
    DECLARE
      -- Identificacao do programa
      vr_cdprogra crapprg.cdprogra%type := 'CRPS088';

      -- Cursor para validação da cooperativa
      cursor cr_crapcop is
        SELECT nmrescop
          FROM crapcop
         WHERE cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%rowtype;

      -- Cursor para listagem de PAs
      cursor cr_crapage is
        SELECT crapage.cdagenci, -- Código do PA
               substr(crapage.nmresage, 0, 50) as nmresage  -- Nome do PA
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper;
      rw_crapage cr_crapage%rowtype;

      -- Tipo de registro para PlTable de PA
      type typ_reg_pa is
        record(cdagenci crapage.cdagenci%type
              ,dsagenci varchar2(50));

      -- Tipo de tabela para PlTable de PA
      type typ_tab_pa is
        table of typ_reg_pa
          index by pls_integer; -- Index por cdagenci

      -- Variavel para PlTable de Pa
      vr_tab_pa typ_tab_pa;

      -- Cursor para pesquisa de titular
      cursor cr_crapttl is
        SELECT crapttl.cdempres, -- Código da empresa
               decode(crapttl.cdturnos, 0, null, crapttl.cdturnos) cdturnos, -- Turno de trabalho
               crapttl.nrdconta  -- Nr da conta
          FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper AND
               crapttl.idseqttl = 1; -- Primeiro Titular
      rw_crapttl cr_crapttl%rowtype;

      -- Cursor para pesquisa de PJ
      cursor cr_crapjur is
        SELECT cdempres, nrdconta
          FROM crapjur
         WHERE crapjur.cdcooper = pr_cdcooper;
      rw_crapjur cr_crapjur%rowtype;

      -- Cursor para busca dos contratos de emprestimos
      cursor cr_crapepr is
        SELECT crapepr.nrdconta, -- NR da Conta
               crapepr.nrctremp, -- Nr Contrato
               crapepr.dtmvtolt, -- Data Movimento
               crapepr.dtultpag, -- Data Ultimo Pagamento
               crapepr.vlsdeved, -- Valor saldo devedor
               crapepr.nrctaav1, -- Conta Aval 1
               crapepr.nrctaav2  -- Conta Aval 2
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper AND
               crapepr.vlsdeved > 0 AND
               crapepr.inliquid = 0; -- Indicador de Liquidacao
      rw_crapepr cr_crapepr%rowtype;

      -- Cursor para busca dos associados
      cursor cr_crapass is
        SELECT crapass.nrdconta,
               crapass.cdagenci,
               substr(crapass.nmprimtl, 0, 40) nmprimtl,
               crapass.dtdemiss
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper;
      rw_crapass cr_crapass%rowtype;

      -- Cursor para busca de avalistas terceiros
      cursor cr_crapavt (pr_nrdconta crapavt.nrdconta%type  -- Nr conta no emprestimo
                        ,pr_nrctremp crapavt.nrctremp%type) -- Nr do contrato de emprestimo
                        is
        SELECT crapavt.nrcpfcgc,
               crapavt.nmdavali,
               crapavt.nrfonres
          FROM crapavt
         WHERE crapavt.cdcooper = pr_cdcooper AND
               crapavt.nrdconta = pr_nrdconta AND
               crapavt.nrctremp = pr_nrctremp AND
               crapavt.tpctrato = 1;
      rw_crapavt cr_crapavt%rowtype;

      -- Cursor para telefone do titular da conta
      cursor cr_craptfc is
        SELECT craptfc.nrtelefo,
               craptfc.nrdddtfc,
               craptfc.nrdramal,
               craptfc.nrdconta
          FROM craptfc
         WHERE craptfc.cdcooper = pr_cdcooper
           AND craptfc.idseqttl = 1
         ORDER BY craptfc.cdseqtfc desc;
      rw_craptfc cr_craptfc%rowtype;

      -- Variavel de auxilio para sequencial de avalista
      vr_seq_ava integer;

      -- Variaveis temporarias para avalista
      vr_av1nmpri varchar2(100);
      vr_av1nmsec varchar2(100);
      vr_av1nrfon varchar2(100);
      vr_av1cdtur crapttl.cdturnos%type;
      vr_av1cdemp crapttl.cdempres%type;
      vr_av1cdage crapass.cdagenci%type;

      -- Variavel para numero da conta do avalista dentro da busca
      vr_nrdconta_aval crapepr.nrctaav2%type;

      -- Tipo de registro para PlTable de Emprestimos
      type typ_reg_epr is
        record(cdagenci crapass.cdagenci%type
              ,dsagenci varchar2(50)
              ,nrdconta crapass.nrdconta%type
              ,nrdiasat integer
              ,nmprimtl crapass.nmprimtl%type
              ,dtdemiss crapass.dtdemiss%type
              ,nrfonres crapavt.nrfonres%type
              ,nrctremp crapepr.nrctremp%type
              ,dtmvtolt crapepr.dtmvtolt%type
              ,dtultpag crapepr.dtultpag%type
              ,vlsdeved crapepr.vlsdeved%type
              ,nrctaav1 crapepr.nrctaav1%type
              ,nrctaav2 crapepr.nrctaav2%type
              ,cdturnos crapttl.cdturnos%type
              ,cdempres crapttl.cdempres%type
              ,av1nmpri crapass.nmprimtl%type
              ,av1nmsec crapdes.nmsecext%type
              ,av1nrfon crapavt.nrfonres%type
              ,av1cdtur crapttl.cdturnos%type
              ,av1cdemp crapttl.cdempres%type
              ,av1cdage crapass.cdagenci%type
              ,av2nmpri crapass.nmprimtl%type
              ,av2nmsec crapdes.nmsecext%type
              ,av2nrfon crapavt.nrfonres%type
              ,av2cdtur crapttl.cdturnos%type
              ,av2cdemp crapttl.cdempres%type
              ,av2cdage crapass.cdagenci%type);

      -- Tipo de tabela para PlTable de Emprestimos
      type typ_tab_epr is
        table of typ_reg_epr
          index by varchar2(25); --> PAC(5) + Conta(10) + Contrato(10)

      -- Variavel para PlTable de emprestimos
      vr_tab_epr typ_tab_epr;

      -- Variavel de auxilio para chave da vr_tab_epr
      vr_des_chaveepr VARCHAR2(25);

      -- Tipo de registro para PlTable de cadastro de telefones
      type typ_reg_tfc is
        record(nrtelefo craptfc.nrtelefo%type
              ,nrdddtfc craptfc.nrdddtfc%type
              ,nrdramal craptfc.nrdramal%type);

      -- Tipo de tabela para PlTable de cadastro de telefones
      type typ_tab_tfc is
        table of typ_reg_tfc
          index by pls_integer; -- crapass.nrdconta

      -- Variavel para PlTable de cadastro de telefones
      vr_tab_tfc typ_tab_tfc;

      -- Tipo de registro para PlTable de cadastro de associado
      type typ_reg_ass is
        record(nrdconta crapass.nrdconta%type
              ,cdagenci crapass.cdagenci%type
              ,nmprimtl crapass.nmprimtl%type
              ,dtdemiss crapass.dtdemiss%type);

      -- Tipo de tabela para PlTable de cadastro de associado
      type typ_tab_ass is
        table of typ_reg_ass
          index by varchar2(15); --> PAC(5) + Conta(10)

      -- Variavel de auxilio para chave da vr_tab_ass
      vr_des_chavereg VARCHAR2(15);

      -- PlTable de associados
      vr_tab_ass typ_tab_ass;

      -- Tipo de Registro para PlTable de cadastro de titular
      type typ_reg_emp is
        record(cdempres crapjur.cdempres%type
              ,cdturnos crapttl.cdturnos%type);

      -- Tipo de tabela para PlTable de cadastro de titular
      type typ_tab_emp is
        table of typ_reg_emp
          index by pls_integer;

      -- Variavel para PlTable de cadastro de titular
      vr_tab_emp typ_tab_emp;
      -- Rowtype para validacao da data
      rw_crapdat btch0001.cr_crapdat%rowtype;
      -- Variavel para controle de entrada no relatorio
      vr_flgentra boolean := false;
      -- Variavel para data limite
      vr_dtlimite date;
      -- Variavel para descricao da data limite
      vr_dslimite varchar2(20);
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      -- Variavel de excecao para saida sem log
      vr_exc_fim exception;
      -- Variavel de dados do XML em memória (CLOB)
      vr_dsxmldad  CLOB;
      -- Diretorio da cooperativa
      vr_dircoop varchar2(300);
      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      

      -- Procedimento auxiliar para escrita no CLOB vr_dsxmldad
      PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(vr_dsxmldad,length(pr_des_dados),pr_des_dados);
      END;

    BEGIN
      -- Informa acesso
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
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
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Inicio da regra de negocio

      -- Buscar configuração na tabela
      -- Le a tabela de controle de execucao
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => 0
                     ,pr_cdacesso => 'EXEEMPATRA'
                     ,pr_tpregist => 1);

      IF TRIM(vr_dstextab) IS NULL THEN 
        -- Se não encontrar o registro, gera log e sai do programa.
        vr_cdcritic := 55;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)
                       || ' CRED-GENERI-00-EXEEMPATRA-001';
        raise vr_exc_saida;
      ELSE
        -- Se encontrar, mas o valor for diferente de 0 e 1
        IF vr_dstextab <> '0' AND vr_dstextab <> '1' THEN
          -- Alimenta parametro de saida e sai do programa sem log.
          pr_infimsol := 1;
          raise vr_exc_fimprg;
        END IF;
      END IF;

      -- Monta data limite para emprestimos em atraso
      -- Se é mudanca de mes
      if to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtopr, 'mm') then
        vr_dtlimite := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd') + 1;
        vr_dslimite := to_char(rw_crapdat.dtmvtopr - to_char(rw_crapdat.dtmvtopr, 'dd') , 'dd/mm/yyyy');
      else
        vr_dtlimite := rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd');
        vr_dtlimite := vr_dtlimite - to_char(vr_dtlimite, 'dd') + 1;
        vr_dslimite := to_char(rw_crapdat.dtmvtolt - to_char(rw_crapdat.dtmvtolt, 'dd') , 'dd/mm/yyyy');
      end if;

      -- Alimenta PlTable vr_tab_pa com dados dos PAs
      FOR rw_crapage IN cr_crapage LOOP
        vr_tab_pa(rw_crapage.cdagenci).cdagenci := rw_crapage.cdagenci;
        vr_tab_pa(rw_crapage.cdagenci).dsagenci := rw_crapage.nmresage;
      END LOOP;

      -- Alimenta PlTable vr_tab_emp com dados de P. Juridica
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_emp(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
        vr_tab_emp(rw_crapjur.nrdconta).cdturnos := 0;
      END LOOP;

      -- Alimenta PlTable vr_tab_emp com dados de P. Fisica
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_emp(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
        vr_tab_emp(rw_crapttl.nrdconta).cdturnos := rw_crapttl.cdturnos;
      END LOOP;

      -- Alimenta PlTable vr_tab_ass com dados de Associados
      FOR rw_crapass IN cr_crapass LOOP
        vr_tab_ass(rw_crapass.nrdconta).nrdconta := rw_crapass.nrdconta;
        vr_tab_ass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_ass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        vr_tab_ass(rw_crapass.nrdconta).dtdemiss := rw_crapass.dtdemiss;
      END LOOP;

      -- Alimenta PlTable vr_tab_tfc com o cadastro de telefones de primeiros titulares
      FOR rw_craptfc IN cr_craptfc LOOP
        vr_tab_tfc(rw_craptfc.nrdconta).nrtelefo := rw_craptfc.nrtelefo;
        vr_tab_tfc(rw_craptfc.nrdconta).nrdddtfc := rw_craptfc.nrdddtfc;
        vr_tab_tfc(rw_craptfc.nrdconta).nrdramal := rw_craptfc.nrdramal;
      END LOOP;

      -- Listando os  emprestimos
      Open cr_crapepr;
      loop
        fetch cr_crapepr
          into rw_crapepr;
        -- Sai do loop quando nao encontrar mais emprestimos
        exit when cr_crapepr%notfound;

        -- Busca associado do emprestimo
        if not vr_tab_ass.exists(rw_crapepr.nrdconta) then
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)
                       || ' CONTA = ' || rw_crapepr.nrdconta;
          raise vr_exc_saida;
        end if;

        -- Limpa a variavel de controle de entrada no relatorio
        vr_flgentra := false;

        -- Verificacoes para entrada no relatorio

        -- Associado com data de demissao
        if vr_tab_ass(rw_crapepr.nrdconta).dtdemiss is not null then
          vr_flgentra := true;
        else
          -- Se a data de ultimo pgto for menor que a data limite
          if rw_crapepr.dtultpag < vr_dtlimite then
            -- E se a data do emprestimo <> da data do ultimo pgto
            if rw_crapepr.dtmvtolt <> rw_crapepr.dtultpag then
              -- E se data limite - data do ultimo pgto for > 10
              if vr_dtlimite - rw_crapepr.dtultpag > 10 then
                vr_flgentra := true;
              end if;
            -- Se data do emprestimo = da data do ultimo pgto
            else
              -- Se data limite - data do ultimo pgto for > 45
              if vr_dtlimite - rw_crapepr.dtultpag > 45 then
                vr_flgentra := true;
              end if;
            end if;
          end if;
        end if;
        -- Fim verificacoes para entrada no relatorio

        -- Entra no relatorio
        if vr_flgentra then
          -- Monta a chave da PlTable
          vr_des_chaveepr := LPad(vr_tab_ass(rw_crapepr.nrdconta).cdagenci,5,'0') || LPad(rw_crapepr.nrdconta,10,'0') || LPad(rw_crapepr.nrctremp,10,'0');

          vr_tab_epr(vr_des_chaveepr).nrdiasat := rw_crapdat.dtmvtolt - rw_crapepr.dtultpag;
          vr_tab_epr(vr_des_chaveepr).cdagenci := vr_tab_ass(rw_crapepr.nrdconta).cdagenci;
          vr_tab_epr(vr_des_chaveepr).nrdconta := vr_tab_ass(rw_crapepr.nrdconta).nrdconta;
          vr_tab_epr(vr_des_chaveepr).nmprimtl := vr_tab_ass(rw_crapepr.nrdconta).nmprimtl;
          vr_tab_epr(vr_des_chaveepr).dtdemiss := vr_tab_ass(rw_crapepr.nrdconta).dtdemiss;
          -- Monta telefone do titular do emprestimo
          -- Se tiver telefone cadastrado para o titular da conta
          if vr_tab_tfc.exists(rw_crapepr.nrdconta) then
            -- Se tiver numero valido
            if vr_tab_tfc(rw_crapepr.nrdconta).nrtelefo <> 9999 and vr_tab_tfc(rw_crapepr.nrdconta).nrtelefo <> 0 then
              -- Se tiver DDD cadastrado
              if vr_tab_tfc(rw_crapepr.nrdconta).nrdddtfc <> 0 then
                -- Monta DDD + Telefone
                vr_tab_epr(vr_des_chaveepr).nrfonres := '(' || vr_tab_tfc(rw_crapepr.nrdconta).nrdddtfc || ') ';
                vr_tab_epr(vr_des_chaveepr).nrfonres := vr_tab_epr(vr_des_chaveepr).nrfonres || vr_tab_tfc(rw_crapepr.nrdconta).nrtelefo;
              else
                -- Monta só telefone
                vr_tab_epr(vr_des_chaveepr).nrfonres := vr_tab_tfc(rw_crapepr.nrdconta).nrtelefo;
              end if;
            else
              -- Monta só Ramal
              vr_tab_epr(vr_des_chaveepr).nrfonres := vr_tab_tfc(rw_crapepr.nrdconta).nrdramal;
            end if;
          else
            -- Não tem telefone cadastrado
            vr_tab_epr(vr_des_chaveepr).nrfonres := '';
          end if; -- Fim do telefone do titular
          vr_tab_epr(vr_des_chaveepr).nrctremp := rw_crapepr.nrctremp;
          vr_tab_epr(vr_des_chaveepr).dtmvtolt := rw_crapepr.dtmvtolt;
          vr_tab_epr(vr_des_chaveepr).dtultpag := rw_crapepr.dtultpag;
          vr_tab_epr(vr_des_chaveepr).vlsdeved := rw_crapepr.vlsdeved;
          vr_tab_epr(vr_des_chaveepr).nrctaav1 := rw_crapepr.nrctaav1;
          vr_tab_epr(vr_des_chaveepr).nrctaav2 := rw_crapepr.nrctaav2;

          -- Busca Turno, Código da Empresa e Secao
          if vr_tab_emp.exists(vr_tab_ass(rw_crapepr.nrdconta).nrdconta) then
            vr_tab_epr(vr_des_chaveepr).cdturnos := nvl(vr_tab_emp(vr_tab_ass(rw_crapepr.nrdconta).nrdconta).cdturnos, 0);
            vr_tab_epr(vr_des_chaveepr).cdempres := vr_tab_emp(vr_tab_ass(rw_crapepr.nrdconta).nrdconta).cdempres;
          end if;

          -- Reinicia variaveis para sequencia de avalista
          vr_seq_ava := 1;
          vr_nrdconta_aval := 0;

          -- Busca da agencia do Associado
          if vr_tab_pa.exists(vr_tab_epr(vr_des_chaveepr).cdagenci) then
            vr_tab_epr(vr_des_chaveepr).dsagenci := vr_tab_epr(vr_des_chaveepr).cdagenci || ' - ' || vr_tab_pa(vr_tab_epr(vr_des_chaveepr).cdagenci).dsagenci;
          else
            vr_tab_epr(vr_des_chaveepr).dsagenci := vr_tab_epr(vr_des_chaveepr).cdagenci || ' - ' || '***************';
          end if;

          -- Busca dos avalistas do contrato
          loop
            -- Sai do loop quando encontrar dois avalistas
            exit when vr_seq_ava = 3;

            -- Limpa variaveis temporarias de avalista
            vr_av1nmpri := '';
            vr_av1nmsec := '';
            vr_av1nrfon := '';
            vr_av1cdtur := NULL;
            vr_av1cdemp := NULL;
            vr_av1cdage := NULL;

            -- Busca numero da conta do avalista da sequencia
            if vr_seq_ava = 1 then
              vr_nrdconta_aval := rw_crapepr.nrctaav1;
            else
               vr_nrdconta_aval := rw_crapepr.nrctaav2;
            end if;

            -- Se contrato não tem numero da conta do avalista
            if vr_nrdconta_aval = 0 then
              -- Busca avalista na table de avalistas terceiros
              open cr_crapavt(rw_crapepr.nrdconta, rw_crapepr.nrctremp);
              loop
                fetch cr_crapavt
                  into rw_crapavt;
                exit when cr_crapavt%notfound;
                -- Se for o segundo avalista
                if vr_seq_ava = 2 then
                  -- E o nome do primeiro for igual ao recebido agora
                  if vr_tab_epr(vr_des_chaveepr).av1nmpri = rw_crapavt.nrcpfcgc || ' -  ' || rw_crapavt.nmdavali then
                    -- Avanca um registro da cr_crapvt
                    continue;
                  end if;
                end if;
                vr_av1nmpri := rw_crapavt.nrcpfcgc || ' -  ' || rw_crapavt.nmdavali;
                vr_av1nrfon := rw_crapavt.nrfonres;
                -- Sai do Loop
                exit;
              end loop;
              close cr_crapavt;
            else
              --Se contrato tem numero da conta do avalista
              --Busca avalista na tabela de associados
              if vr_tab_ass.exists(vr_nrdconta_aval) then
                -- Se encontrou avalista no cadastro de associados
                -- Alimenta variaveis temporarias do avalista
                vr_av1nmpri := vr_tab_ass(vr_nrdconta_aval).nmprimtl;

                -- Monta telefone do avalista
                -- Se tiver telefone cadastrado para o titular da conta de avalista
                if vr_tab_tfc.exists(vr_nrdconta_aval) then
                  -- Se tiver numero valido
                  if vr_tab_tfc(vr_nrdconta_aval).nrtelefo <> 9999 and vr_tab_tfc(vr_nrdconta_aval).nrtelefo <> 0 then
                    -- Se tiver DDD cadastrado
                    if vr_tab_tfc(vr_nrdconta_aval).nrdddtfc <> 0 then
                      -- Monta DDD + Telefone
                      vr_av1nrfon := '(' || vr_tab_tfc(vr_nrdconta_aval).nrdddtfc || ') ';
                      vr_av1nrfon := vr_av1nrfon || vr_tab_tfc(vr_nrdconta_aval).nrtelefo;
                    else
                      -- Monta só telefone
                      vr_av1nrfon := vr_tab_tfc(vr_nrdconta_aval).nrtelefo;
                    end if;
                  else
                    -- Monta só Ramal
                    vr_av1nrfon := vr_tab_tfc(vr_nrdconta_aval).nrdramal;
                  end if;
                else
                  -- Não tem telefone cadastrado
                  vr_av1nrfon := '';
                end if; -- Fim do telefone do avalista

                -- Se encontrar dados na table crapttl ou crapjur
                if vr_tab_emp.exists(vr_nrdconta_aval) then
                  vr_av1cdtur := vr_tab_emp(vr_nrdconta_aval).cdturnos;
                  vr_av1cdemp := vr_tab_emp(vr_nrdconta_aval).cdempres;
                end if;
                vr_av1cdage := vr_tab_ass(vr_nrdconta_aval).cdagenci;
              else
                -- Se não encontrou avalista no cadastro de associados
                vr_av1nmpri := 'NAO CADASTRADO';
                vr_av1nmsec := '';
                vr_av1nrfon := '';
                vr_av1cdtur := 0;
                vr_av1cdemp := 0;
                vr_av1cdage := 0;
              -- Fim se encontrou avalista no cadastro de associados
              end if;
            -- Fim da verificacao do numero da conta do avalista no contrato
            end if;

            -- Se estiver no primeiro avalista
            if vr_seq_ava = 1 then
              -- Preenche dados do primeiro avalista
              vr_tab_epr(vr_des_chaveepr).av1nmpri := vr_av1nmpri;
              vr_tab_epr(vr_des_chaveepr).av1nmsec := vr_av1nmsec;
              vr_tab_epr(vr_des_chaveepr).av1nrfon := vr_av1nrfon;
              vr_tab_epr(vr_des_chaveepr).av1cdtur := vr_av1cdtur;
              vr_tab_epr(vr_des_chaveepr).av1cdemp := vr_av1cdemp;
              vr_tab_epr(vr_des_chaveepr).av1cdage := vr_av1cdage;
            else
              -- Se não, preenche os dados do segundo avalista
              vr_tab_epr(vr_des_chaveepr).av2nmpri := vr_av1nmpri;
              vr_tab_epr(vr_des_chaveepr).av2nmsec := vr_av1nmsec;
              vr_tab_epr(vr_des_chaveepr).av2nrfon := vr_av1nrfon;
              vr_tab_epr(vr_des_chaveepr).av2cdtur := vr_av1cdtur;
              vr_tab_epr(vr_des_chaveepr).av2cdemp := vr_av1cdemp;
              vr_tab_epr(vr_des_chaveepr).av2cdage := vr_av1cdage;
            end if;

            -- Incrementa sequencial de avalista
            vr_seq_ava := vr_seq_ava + 1;

            -- Fim da busca dos avalistas
          end loop;

        -- Fim do entra no relatorio
        end if;

      -- Fim do loop de emprestimos
      end loop;

      -- Bloco para montagem do arquivo XML
      begin
        -- Inicializar o CLOB (XML)
        dbms_lob.createtemporary(vr_dsxmldad, TRUE);
        dbms_lob.open(vr_dsxmldad, dbms_lob.lob_readwrite);

        -- Escreve cabecalho padrao
        pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?><raiz>');
        pc_escreve_clob(' <emprestimos>');
        pc_escreve_clob('<dtlimite>' || vr_dslimite || '</dtlimite>');

        -- Inicio da chave da PlTable
        vr_des_chaveepr := vr_tab_epr.FIRST;

        -- Leitura da PlTable de emprestimos para montagem do xml
        loop
          EXIT WHEN vr_des_chaveepr IS NULL;
          pc_escreve_clob(' <contrato>');
          pc_escreve_clob('<cdagenci>' || vr_tab_epr(vr_des_chaveepr).cdagenci || '</cdagenci>');
          pc_escreve_clob('<dsagenci>' || vr_tab_epr(vr_des_chaveepr).dsagenci || '</dsagenci>');
          pc_escreve_clob('<nrdconta>' || GENE0002.FN_MASK_CONTA(vr_tab_epr(vr_des_chaveepr).nrdconta) || '</nrdconta>');
          pc_escreve_clob('<nrdiasat>' || vr_tab_epr(vr_des_chaveepr).nrdiasat || '</nrdiasat>');
          pc_escreve_clob('<nmprimtl>' || substr(vr_tab_epr(vr_des_chaveepr).nmprimtl, 1, 31) || '</nmprimtl>');
          pc_escreve_clob('<dtdemiss>' || to_char(vr_tab_epr(vr_des_chaveepr).dtdemiss,'DD/MM/YYYY') || '</dtdemiss>');
          pc_escreve_clob('<nrfonres>' || vr_tab_epr(vr_des_chaveepr).nrfonres || '</nrfonres>');
          pc_escreve_clob('<nrctremp>' || GENE0002.FN_MASK_CONTRATO(vr_tab_epr(vr_des_chaveepr).nrctremp) || '</nrctremp>');
          pc_escreve_clob('<dtmvtolt>' || to_char(vr_tab_epr(vr_des_chaveepr).dtmvtolt,'DD/MM/YYYY') || '</dtmvtolt>');
          pc_escreve_clob('<dtultpag>' || to_char(vr_tab_epr(vr_des_chaveepr).dtultpag,'DD/MM/YYYY') || '</dtultpag>');
          pc_escreve_clob('<vlsdeved>' || to_char(vr_tab_epr(vr_des_chaveepr).vlsdeved,'fm999G999G999G990D00') || '</vlsdeved>');
          pc_escreve_clob('<nrctaav1>' || GENE0002.FN_MASK_CONTA(vr_tab_epr(vr_des_chaveepr).nrctaav1) || '</nrctaav1>');
          pc_escreve_clob('<nrctaav2>' || GENE0002.FN_MASK_CONTA(vr_tab_epr(vr_des_chaveepr).nrctaav2) || '</nrctaav2>');
          pc_escreve_clob('<cdturnos>' || vr_tab_epr(vr_des_chaveepr).cdturnos || '</cdturnos>');
          pc_escreve_clob('<cdempres>' || vr_tab_epr(vr_des_chaveepr).cdempres || '</cdempres>');
          pc_escreve_clob('<av1nmpri>' || substr(vr_tab_epr(vr_des_chaveepr).av1nmpri, 1, 36) || '</av1nmpri>');
          pc_escreve_clob('<av1nmsec>' || vr_tab_epr(vr_des_chaveepr).av1nmsec || '</av1nmsec>');
          pc_escreve_clob('<av1nrfon>' || substr(vr_tab_epr(vr_des_chaveepr).av1nrfon,1,20) || '</av1nrfon>');
          pc_escreve_clob('<av1cdtur>' || vr_tab_epr(vr_des_chaveepr).av1cdtur || '</av1cdtur>');
          pc_escreve_clob('<av1cdemp>' || vr_tab_epr(vr_des_chaveepr).av1cdemp || '</av1cdemp>');
          pc_escreve_clob('<av1cdage>' || vr_tab_epr(vr_des_chaveepr).av1cdage || '</av1cdage>');
          pc_escreve_clob('<av2nmpri>' || substr(vr_tab_epr(vr_des_chaveepr).av2nmpri, 1, 36) || '</av2nmpri>');
          pc_escreve_clob('<av2nmsec>' || vr_tab_epr(vr_des_chaveepr).av2nmsec || '</av2nmsec>');
          pc_escreve_clob('<av2nrfon>' || substr(vr_tab_epr(vr_des_chaveepr).av2nrfon,1,20) || '</av2nrfon>');
          pc_escreve_clob('<av2cdtur>' || vr_tab_epr(vr_des_chaveepr).av2cdtur || '</av2cdtur>');
          pc_escreve_clob('<av2cdemp>' || vr_tab_epr(vr_des_chaveepr).av2cdemp || '</av2cdemp>');
          pc_escreve_clob('<av2cdage>' || vr_tab_epr(vr_des_chaveepr).av2cdage || '</av2cdage>');
          pc_escreve_clob(' </contrato>');

          -- Passa para proximo registro
          vr_des_chaveepr := vr_tab_epr.NEXT(vr_des_chaveepr);

          -- Fim da leiturada PlTable de emprestimos
        end loop;

        -- Fecha tags do xml
        pc_escreve_clob(' </emprestimos>');
        pc_escreve_clob('</raiz>');

        -- Busca diretorio rl da cooperativa
        vr_dircoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'rl');

        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
                                   ,pr_dsxml     => vr_dsxmldad                   --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/emprestimos/contrato'  --> Nó do XML para iteração
                                   ,pr_dsjasper  => 'crrl070.jasper'              --> Arquivo de layout do iReport
                                   ,pr_dsparams  => NULL                          --> Array de parametros diversos
                                   ,pr_dsarqsaid => vr_dircoop || '/crrl070.lst'  --> Path/Nome do arquivo PDF gerado
                                   ,pr_flg_gerar => 'N'                           --> Gerar o arquivo na hora
                                   ,pr_qtcoluna  => 132                           --> Qtd colunas do relatório (80,132,234)
                                   ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
                                   ,pr_des_erro  => vr_dscritic                   --> Saída com erro
                                   ,pr_nrcopias  => 2);                           --> Número de cópias para impressão

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_dsxmldad);
        dbms_lob.freetemporary(vr_dsxmldad);

        -- Verificando retorno da PC_SOLICITA_RELATO
        if vr_dscritic <> '' then
          raise vr_exc_saida;
        end if;
      exception
        when others then
          vr_dscritic := 'Erro ao montar relatorio: ' || sqlerrm;
          raise vr_exc_saida;
      end;

      -- Fim da regra de negocio

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
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
  END PC_CRPS088;
/
