CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS599" (pr_cdcooper in crapcop.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) is
/* ..........................................................................

   Programa: pc_crps599 (antigo Fontes/crps599.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Henrique
   Data    : Maio/2011.                      Ultima atualizacao: 25/04/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Verificar contas que apresentaram movimentacoes suspeitas
               de lavagem de dinheiro. Solicitacao 4 e ordem 8.

   Alteracoes: 30/06/2011 - Incluidos os historicos 47, 191, 338, 573 para serem
                            desprezados (Henrique).

               20/07/2011 - Alteracao na busca do faturamento para inpessoa = 2
                            (Adriano).

               24/08/2011 - Incluidos os historicos 600,766,794,801,802,803,
                            804,887 para serem desprezados (Magui).

               03/07/2013 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero)

               25/04/2016 - Adicionar o historico 478 - CR.APL.RDCPRE, na lista de 
                            historicos ignorados para geração do controle de 
                            lavagem de dinheiro (Douglas - Chamado 405588)
............................................................................. */
  -- Busca lançamentos em depósitos a vista
  cursor cr_craplcm (pr_cdcooper in craplcm.cdcooper%type,
                     pr_dtinimes in craplcm.dtmvtolt%type,
                     pr_dtfimmes in craplcm.dtmvtolt%type) is
     WITH his AS
       (select h.cdhistor
          from craphis h
         where h.cdcooper = pr_cdcooper
           and h.indebcre = 'C'
           and h.cdhistor not in (2, 15, 47, 191, 270, 338, 478, 483, 497, 499, 501, 530,
                                  573, 600, 622, 686, 766, 794, 801, 802, 803, 804, 887))
    select craplcm.nrdconta,
           crapass.inpessoa,
           crapass.cdagenci,
           sum(craplcm.vllanmto) vlcredit
      from his,
           crapass,
           craplcm
     where craplcm.cdcooper = pr_cdcooper
       and craplcm.dtmvtolt between pr_dtinimes and pr_dtfimmes
       and craplcm.cdhistor in his.cdhistor
       and crapass.cdcooper = craplcm.cdcooper
       and crapass.nrdconta = craplcm.nrdconta
     group by craplcm.nrdconta,
              crapass.inpessoa,
              crapass.cdagenci;
  -- Buscar rendimentos dos titulares da conta
  cursor cr_crapttl (pr_cdcooper in crapttl.cdcooper%type,
                     pr_nrdconta in crapttl.nrdconta%type) is
    select vldrendi##1 + vldrendi##2 + vldrendi##3 + vldrendi##4 + vldrendi##5 + vldrendi##6 + vlsalari vlrendim,
           idseqttl,
           nrcpfcgc
      from crapttl
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta;
  -- Buscar salário do cônjuge do titular, caso este não seja cotitular da conta
  cursor cr_crapcje (pr_cdcooper in crapcje.cdcooper%type,
                     pr_nrdconta in crapcje.nrdconta%type,
                     pr_idseqttl in crapcje.idseqttl%type) is
    select vlsalari
      from crapcje
     where crapcje.cdcooper = pr_cdcooper
       and crapcje.nrdconta = pr_nrdconta
       and crapcje.idseqttl = pr_idseqttl
       and not exists (select 1
                         from crapttl
                        where crapttl.cdcooper = crapcje.cdcooper
                          and crapttl.nrdconta = crapcje.nrdconta
                          and crapttl.nrcpfcgc = crapcje.nrcpfcjg);
  rw_crapcje       cr_crapcje%rowtype;
  -- Busca o ano e mês mais recente (anoftbru e mesftbru), depois busca o valor correspondente ao mesmo mês (vlrftbru).
  -- Dados financeiros dos cooperados pessoa jurídica.
  cursor cr_crapjfn (pr_cdcooper in crapjfn.cdcooper%type,
                     pr_nrdconta in crapjfn.nrdconta%type) is
    select anomes,
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
                  anomes12, valor12) vlfatmes
      from (select greatest (anomes1, anomes2, anomes3, anomes4, anomes5, anomes6, anomes7, anomes8, anomes9, anomes10, anomes11, anomes12) anomes,
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
              from (select vlrftbru##1 valor1,
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
                    from crapjfn
                   where cdcooper = pr_cdcooper
                     and nrdconta = pr_nrdconta));
  rw_crapjfn       cr_crapjfn%rowtype;
  -- Busca valor de faturamento anual no cadastro da pessoa jurídica
  cursor cr_crapjur (pr_cdcooper in crapjur.cdcooper%type,
                     pr_nrdconta in crapjur.nrdconta%type) is
    select crapjur.vlfatano
      from crapjur
     where crapjur.cdcooper = pr_cdcooper
       and crapjur.nrdconta = pr_nrdconta;
  rw_crapjur       cr_crapjur%rowtype;
  --
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  -- Exception para tratamento de erros tratáveis sem abortar a execução
  vr_exc_mensagem  exception;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  --Informacoes tabelas genericas
  vr_dstextab      craptab.dstextab%type;
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  vr_dtinimes      crapdat.dtmvtolt%type;
  vr_dtfimmes      crapdat.dtmvtolt%type;
  -- Valor mensal para pessoa física e jurídica
  vr_vlmenfis      craplcm.vllanmto%type;
  vr_vlmenjur      craplcm.vllanmto%type;
  -- Rendimento da conta
  vr_vlrendim      crapcld.vlrendim%type;
  -- Variáveis auxiliares para cálculo do rendimento da pessoa jurídica (faturamento)
  vr_vlfatmes      crapjfn.vlrftbru##1%type;
  vr_vlfatano      crapjur.vlfatano%type;
  -- Tratamento de erros
  vr_exc_erro      exception;
begin
  vr_cdprogra := 'CRPS599';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS599',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  if pr_cdcritic <> 0 then
    -- Buscar descrição do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_erro;
  end if;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor pois haverá raise
      close btch0001.cr_crapdat;
      pr_cdcritic:= 1;
      -- Montar mensagem de critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      raise vr_exc_erro;
    else
      -- Atribuir a data do movimento
      vr_dtmvtolt := rw_crapdat.dtmvtolt;
    end if;
  close btch0001.cr_crapdat;
  -- Define data inicial e final
  vr_dtinimes := trunc(vr_dtmvtolt, 'mm');
  vr_dtfimmes := vr_dtmvtolt;
  -- Busca informação de valor mensal para pessoa física e jurídica
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'LAV',
                                            pr_tptabela => 'CONFIG',
                                            pr_cdempres => 0,
                                            pr_cdacesso => 'PARLVDNCP',
                                            pr_tpregist => null);
  if vr_dstextab is not null then
    vr_vlmenfis := gene0002.fn_busca_entrada(5, vr_dstextab, ';');
    vr_vlmenjur := gene0002.fn_busca_entrada(6, vr_dstextab, ';');
  end if;
  -- Leitura dos lançamentos em depósitos a vista
  for rw_craplcm in cr_craplcm (pr_cdcooper,
                                vr_dtinimes,
                                vr_dtfimmes) loop
    -- Zerar as variáveis
    vr_vlrendim := 0;
    vr_vlfatmes := 0;
    vr_vlfatano := 0;
    --
    if rw_craplcm.inpessoa = 1 then
      -- Pessoa física
      if rw_craplcm.vlcredit >= vr_vlmenfis then
        -- Busca o rendimento de cada titular da conta
        for rw_crapttl in cr_crapttl (pr_cdcooper,
                                      rw_craplcm.nrdconta) loop
          vr_vlrendim := vr_vlrendim + rw_crapttl.vlrendim;
          -- Soma o salário do cônjuge, caso este não seja cotitular da conta
          open cr_crapcje (pr_cdcooper,
                           rw_craplcm.nrdconta,
                           rw_crapttl.idseqttl);
            fetch cr_crapcje into rw_crapcje;
            if cr_crapcje%found then
              vr_vlrendim := vr_vlrendim + rw_crapcje.vlsalari;
            end if;
          close cr_crapcje;
        end loop;
        -- Cria registro de controle de lavagem de dinheiro
        begin
          insert into crapcld (cdcooper,
                               dtmvtolt,
                               cdagenci,
                               cdtipcld,
                               nrdconta,
                               vlrendim,
                               vltotcre)
          values (pr_cdcooper,
                  vr_dtfimmes,
                  rw_craplcm.cdagenci,
                  2, -- mensal da cooperativa
                  rw_craplcm.nrdconta,
                  vr_vlrendim,
                  rw_craplcm.vlcredit);
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar crapcld PF para ag '||rw_craplcm.cdagenci||
                           ', conta '||rw_craplcm.nrdconta||
                           ', rend '||vr_vlrendim||
                           ', credito '||rw_craplcm.vlcredit||
                           ': '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
    elsif rw_craplcm.inpessoa = 2 then
      -- Pessoa jurídica
      if rw_craplcm.vlcredit >= vr_vlmenjur then
        -- Busca o valor do faturamento mais recente
        open cr_crapjfn (pr_cdcooper,
                         rw_craplcm.nrdconta);
          fetch cr_crapjfn into rw_crapjfn;
          if cr_crapjfn%found then
            vr_vlfatmes := rw_crapjfn.vlfatmes;
          else
            vr_vlfatmes := 0;
          end if;
        close cr_crapjfn;
        -- Busca o valor de faturamento anual cadastrado para a pessoa jurídica
        open cr_crapjur (pr_cdcooper,
                         rw_craplcm.nrdconta);
          fetch cr_crapjur into rw_crapjur;
          if cr_crapjur%found then
            vr_vlfatano := rw_crapjur.vlfatano;
          else
            vr_vlfatano := 0;
          end if;
        close cr_crapjur;
        -- Verifica se o valor de faturamento do mês mais recente é maior que a média mensal. Utiliza o maior valor.
        vr_vlrendim := greatest(vr_vlfatano / 12, vr_vlfatmes);
        -- Cria registro de controle de lavagem de dinheiro
        begin
          insert into crapcld (cdcooper,
                               dtmvtolt,
                               cdagenci,
                               cdtipcld,
                               nrdconta,
                               vlrendim,
                               vltotcre)
          values (pr_cdcooper,
                  vr_dtfimmes,
                  rw_craplcm.cdagenci,
                  2, -- mensal da cooperativa
                  rw_craplcm.nrdconta,
                  vr_vlrendim,
                  rw_craplcm.vlcredit);
        exception
          when others then
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao criar crapcld PJ para ag '||rw_craplcm.cdagenci||
                           ', conta '||rw_craplcm.nrdconta||
                           ', rend '||vr_vlrendim||
                           ', credito '||rw_craplcm.vlcredit||
                           ': '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
    end if;
  end loop;
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  commit;
exception
  when vr_exc_erro then
    -- Se foi retornado apenas código
    IF nvl(pr_cdcritic,0) > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END;
/
