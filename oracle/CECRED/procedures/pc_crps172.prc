create or replace procedure cecred.pc_crps172(pr_cdcooper  in craptab.cdcooper%type,
                     pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                     pr_stprogra out pls_integer,            --> Saída de termino da execução
                     pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                     pr_cdcritic out crapcri.cdcritic%type,
                     pr_dscritic out varchar2) as
/* ..........................................................................
   Programa: pc_crps172 - Antigo Fontes/crps172.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/96                     Ultima atualizacao: 19/07/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente a prestacao do plano de capital.

   Alteracoes: 16/01/97 - Tratar CPMF (Odair).

               04/02/97 - Arrumar calculo de saldo tratar abono (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               02/12/97 - Alterado o numero do lote (Deborah).

               30/01/98 - Alterado para usar a rotina calcdata (Deborah).

               16/02/98 - Tratar final da CPMF (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               02/06/1999 - Tratar CPMF (Deborah).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               11/04/2003 - Comparar com o total de prestacoes plano capital.
                            (Ze Eduardo).

               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplct, craplcm, crapavs e craprej (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               22/02/2008 - Alterado para mostrar turno a partir de
                            crapttl.cdturnos (Gabriel).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               26/05/2009 - Quando primeiro dia util do mes pagando cotas
                            do mes anterior por feriado ou fim de semana
                            deixar indpagto como 0 para cobrar o debito
                            do mes (Magui).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).

               15/08/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               19/08/2013 - Quando nao possuir saldo suficiente para o debito
                            de cotas, mantem o indpagto = 0 e atribui o valor
                            da prestacao de cotas ao campo vlpenden. (Fabricio)

               16/01/2014 - Inclusao de VALIDATE craplot, craplcm, crapavs e
                            craplct (Carlos)

               06/02/2014 - Nao considerar saldo bloqueado (Diego).

               10/03/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
               
               27/03/2014 - Atualizacao do campo crappla.flgatupl 
                            (identificador de necessidade de correcao do valor
                             do plano de capital). (Fabricio)
                             
               03/07/2015 - Incluso correção para tratar a variavel vr_indatupl
                            quando não deve atualizar o plano (Daniel). 
                            
               28/07/2015 - Ajuste para cadastrar data de pagamento corretamente no 
                            plano de cotas. Condicao especial para mes de Fev.
                            Adicionado na insercao da craplcm o campo hrtransa e 
                            nome do programa no campo cdpesqbb.
                            (Jorge/Thiago) - SD 294256
                            
               06/04/2017 - Forçar o índice do cursor cr_craplcm para 
                            INDEX(lcm craplcm##craplcm2) (Carlos)

               24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
			                Heitor (Mouts) - Melhoria 440

               19/12/2017 - Desconsiderar do valor pendente o que foi debitado no mes
                            Demetrius (Mouts) - Chamado 813105

			   07/03/2018 - Revertendo alteração realizada no chamado 813105 - (Antonio R Jr - Mouts)
							 
               05/07/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom).
				 
               11/07/2018 - Ao fazer update Controle restart, se não encontrar o registro, criar,
                            pois programa passou a executar durante o dia no Debitador.
                            (Elton - AMcom)
							
               13/12/2018 - Remoção da atualização da capa de lote
                            Yuri - Mouts
							
		       19/07/2019 - Mudanças referentes a requisição RITM0011923
						    (Daniel Lombardi Mout's)
............................................................................. */
  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;
  -- Planos de capitalizacao.
  cursor cr_crappla (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrctares in crappla.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select pla.nrdconta,
           pla.vlprepla,
           pla.nrctrpla,
           pla.vlpagmes,
           pla.qtprepag,
           pla.vlprepag,
           pla.qtpremax,
           pla.dtmvtolt,
           pla.dtdpagto,
           pla.dtultcor,
           pla.cdtipcor,
           pla.rowid,
           cot.rowid rowid_cot,
           sld.rowid rowid_sld,
           ass.nrdconta nrdconta_ass,
           ass.cdagenci,
           ass.cdsecext,
           sld.vlsddisp - sld.vlipmfap - sld.vlipmfpg vlsldtot,
           ass.vllimcre 
      from crapass ass,
           crapsld sld,
           crapcot cot,
           crappla pla
     where pla.cdcooper = pr_cdcooper
       and pla.nrdconta > pr_nrctares
       and pla.tpdplano = 1
       and pla.cdsitpla = 1
       and pla.flgpagto = 0
       and pla.indpagto = 0
       and pla.dtdpagto <= pr_dtmvtolt
       and pla.qtprepag <= pla.qtpremax
       and cot.cdcooper (+) = pla.cdcooper
       and cot.nrdconta (+) = pla.nrdconta
       and sld.cdcooper (+) = pla.cdcooper
       and sld.nrdconta (+) = pla.nrdconta
       and ass.cdcooper (+) = pla.cdcooper
       and ass.nrdconta (+) = pla.nrdconta
     order by pla.nrdconta;
  -- Lançamentos em depositos a vista
  cursor cr_craplcm (pr_cdcooper in crapcop.cdcooper%type,
                     pr_nrdconta in craplcm.nrdconta%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select /*+ INDEX(lcm craplcm##craplcm2) */
           lcm.cdhistor,
           lcm.dtrefere,
           sum(lcm.vllanmto) vllanmto,
           his.cdhistor cdhistor_his,
           his.inhistor,
           his.indoipmf
      from craphis his,
           craplcm lcm
     where lcm.cdcooper = pr_cdcooper
       and lcm.nrdconta = pr_nrdconta
       and lcm.dtmvtolt = pr_dtmvtolt
       and lcm.cdhistor <> 289
       and his.cdcooper (+) = lcm.cdcooper
       and his.cdhistor (+) = lcm.cdhistor
     group by lcm.cdhistor,
              lcm.dtrefere,
              his.cdhistor,
              his.inhistor,
              his.indoipmf
     order by lcm.cdhistor;
  -- Capa dos lotes
  cursor cr_craplot (pr_cdcooper  in crapcop.cdcooper%type
                    ,pr_dtmvtopr  in date
                    ,pr_cdagenci  in craplot.cdagenci%type
                    ,pr_cdbccxlt  in craplot.cdbccxlt%type
                    ,pr_nrdolote  in craplot.nrdolote%type) is
    select co.rowid,
           co.dtmvtolt,
           co.cdagenci,
           co.cdbccxlt,
           co.nrdolote,
           co.nrseqdig,
           count(1) over() retorno
      from craplot co
     where co.cdcooper = pr_cdcooper
       and co.dtmvtolt = pr_dtmvtopr
       and co.cdagenci = pr_cdagenci
       and co.cdbccxlt = pr_cdbccxlt
       and co.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%rowtype;
  --
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  -- Código do programa
  vr_cdprogra        crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida       exception;
  vr_exc_fimprg      exception;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);
  -- Variáveis para controle de reprocesso
  vr_dsrestar        crapres.dsrestar%type;
  vr_nrctares        crapres.nrdconta%type;
  vr_inrestar        number(1);
  -- Variáveis de retorno da pc_busca_cpmf
  vr_dtinipmf        date;
  vr_dtfimpmf        date;
  vr_txcpmfcc        number(13,6);
  vr_txrdcpmf        number(13,6);
  vr_indabono        number(1);
  vr_dtiniabo        date;
  -- Variável que indica se debitou a parcela
  vr_flgrejei        number(1);  -- 1 = debitou, 0 = não debitou
  -- Saldo total
  vr_vlsldtot        crapsld.vlsddisp%type;
  -- Atributos do histórico
  vr_inhistor        craphis.inhistor%type;
  vr_indoipmf        craphis.indoipmf%type;
  vr_txdoipmf        number(13,6);
  -- Variáveis para retorno das informações inseridas na craplcm
  vr_nrdconta_lcm    craplcm.nrdconta%type;
  vr_nrdocmto_lcm    craplcm.nrdocmto%type;
  vr_nrseqdig_lcm    craplcm.nrseqdig%type;
  vr_vllanmto_lcm    craplcm.vllanmto%type;
  -- data do proximo debito no mes seguinte
  vr_dtdpagto        crappla.dtmvtolt%type;
  -- data em que o plano sofreu o ultimo reajuste de valor da prestacao
  vr_dtultcor crappla.dtdpagto%TYPE;
  -- indica se plano deve ser corrigido (0 = false / 1 = true)
  vr_indatupl        INTEGER   := 0;
  vr_hrtransa        NUMBER(5) := 0; --> Hora da transacao
  vr_diapagto        VARCHAR2(2);
  vr_mesanopt        VARCHAR2(7);
  vr_indpagto        INTEGER   := 0;
  
  -- Tabela de retorno LANC0001 (PRJ450 05/07/2018).
  vr_tab_retorno     lanc0001.typ_reg_retorno;
  vr_incrineg        number;
	
BEGIN
  
  -- Hora da transacao
  vr_hrtransa := gene0002.fn_busca_time;
  -- Nome do programa
  vr_cdprogra := 'CRPS172';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS172',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;
  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;
  -- Buscar informações de reprocesso
  btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              vr_cdcritic,
                              vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;
  -- Buscar CPMF
  gene0005.pc_busca_cpmf(pr_cdcooper,
                         rw_crapdat.dtmvtolt,
                         vr_dtinipmf,
                         vr_dtfimpmf,
                         vr_txcpmfcc,
                         vr_txrdcpmf,
                         vr_indabono,
                         vr_dtiniabo,
                         vr_cdcritic,
                         vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;
  
  -- Busca data de referencia da ultima correcao de planos
  vr_dtultcor := add_months(rw_crapdat.dtmvtolt, -12);
        
  -- Leitura dos planos de capital
  for rw_crappla in cr_crappla (pr_cdcooper,
                                vr_nrctares,
                                rw_crapdat.dtmvtolt) loop
    vr_flgrejei := 0;
    -- Verifica se existe informação de cotas e de saldo.
    if rw_crappla.rowid_cot is null or
       rw_crappla.rowid_sld is null then
      vr_cdcritic := 10;
      raise vr_exc_saida;
    end if;
    -- Verifica se encontrou o associado.
    if rw_crappla.nrdconta_ass is null then
      vr_cdcritic := 251;
      raise vr_exc_saida;
    end if;
    -- Verifica se a cooperativa considera ou não o limite de crédito.(Daniel Lombardi Mout'S)
    if APLI0009.UsarLimCredParaDebPlanoCotas(pr_cdcooper=>pr_cdcooper) then
      vr_vlsldtot := rw_crappla.vlsldtot + rw_crappla.vllimcre;      
    else
      -- Inicializa a variável com o saldo total
      vr_vlsldtot := rw_crappla.vlsldtot;
    end if;
    -- Leitura dos lançamentos em depositos a vista, agrupados por histórico e data de referência
    for rw_craplcm in cr_craplcm (pr_cdcooper,
                                  rw_crappla.nrdconta,
                                  rw_crapdat.dtmvtolt) loop
      -- Verifica se encontrou o histórico e armazena os atributos necessários
      if rw_craplcm.cdhistor_his is null then
        vr_cdcritic := 83;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || to_char(rw_craplcm.cdhistor, 'fm9900') || ' '
                                                   || vr_dscritic );
        vr_inhistor := 0;
        vr_indoipmf := 0;
        vr_txdoipmf := 0;
        vr_cdcritic := 0;
      else
        vr_inhistor := rw_craplcm.inhistor;
        vr_indoipmf := rw_craplcm.indoipmf;
        vr_txdoipmf := vr_txcpmfcc;
        --
        if vr_indabono = 0 and -- sem abono
           rw_craplcm.cdhistor in (114, 127, 160, 177) then
           -- 114 = DB.APLIC.RDCA
           -- 127 = DB. COTAS
           -- 160 = DB.POUP.PROGR
           -- 177 = DB.APL.RDCA60
          vr_indoipmf := 1;
          vr_txdoipmf := 0;
        end if;
      end if;
      --
      if vr_indabono = 0 and
         vr_dtiniabo <= rw_craplcm.dtrefere and
         rw_craplcm.cdhistor in (186, 498, 187, 500) then
        vr_vlsldtot := vr_vlsldtot - TRUNC((rw_craplcm.vllanmto * vr_txcpmfcc),2);
      end if;
      --
      if vr_inhistor in (1) then
        -- 1  credito no vlsddisp
        -- 3  credito no vlsdbloq
        -- 4  credito no vlsdblpr
        -- 5  credito no vlsdblfp
        -- Inicia tratamento CPMF
        if vr_indoipmf = 2  then
          -- incide IPMF
          vr_vlsldtot := vr_vlsldtot + (trunc(rw_craplcm.vllanmto * (1 + vr_txdoipmf),2));
        else
          -- Termina tratamento CPMF
          vr_vlsldtot := vr_vlsldtot + rw_craplcm.vllanmto;
        end if;
      end if;
        --
        if vr_inhistor in (11) then
          -- 11  debito no vlsddisp
          -- 13  debito no vlsdbloq
          -- 14  debito no vlsdblpr
          -- 15  debito no vlsdblfp
          -- Inicia tratamento CPMF
          if vr_indoipmf = 2  then
            -- incide IPMF
            vr_vlsldtot := vr_vlsldtot - trunc(rw_craplcm.vllanmto * (1 + vr_txdoipmf),2);
          else
            -- Termina tratamento CPMF
            vr_vlsldtot := vr_vlsldtot - rw_craplcm.vllanmto;
          end if;
        end if;
    end loop;
    -- Calcula o valor dos descontos
    if rw_crappla.vlprepla > vr_vlsldtot then
      vr_flgrejei := 1;
    end if;
    -- Se não debitou parcela
    if vr_flgrejei = 0 then
      -- Buscar lote
      open cr_craplot(pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, 8454);
      fetch cr_craplot into rw_craplot;
      -- Se não localizar o lote, irá gerar um novo registro
      if cr_craplot%notfound or rw_craplot.retorno > 1 then
        close cr_craplot;
        begin
          insert into craplot(dtmvtolt,
                              cdagenci,
                              cdbccxlt,
                              nrdolote,
                              tplotmov,
                              cdcooper,
                              nrseqdig,
                              vlcompcr,
                              vlinfocr,
                              cdhistor,
                              cdoperad,
                              dtmvtopg)
          values(rw_crapdat.dtmvtolt,
                 1,
                 100,
                 8454,
                 1,
                 pr_cdcooper,
                 0,
                 0,
                 0,
                 0,
                 '1',
                 null)
          returning rowid,
                    dtmvtolt,
                    cdagenci,
                    cdbccxlt,
                    nrdolote,
                    nrseqdig
               into rw_craplot.rowid,
                    rw_craplot.dtmvtolt,
                    rw_craplot.cdagenci,
                    rw_craplot.cdbccxlt,
                    rw_craplot.nrdolote,
                    rw_craplot.nrseqdig;
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir em CRAPLOT. ' || sqlerrm;
        end;
      else
        close cr_craplot;
      end if;
      -- Atualiza tabela CRAPLOT
      -- Comentado por Yuri - Remoção atualização capa de lote
/*      begin
        update craplot ct
           set ct.qtinfoln = ct.qtcompln + 1,
               ct.qtcompln = ct.qtcompln + 1,
               ct.vlinfodb = ct.vlcompdb + rw_crappla.vlprepla,
               ct.vlcompdb = ct.vlcompdb + rw_crappla.vlprepla,
               ct.nrseqdig = rw_craplot.nrseqdig + 1
         where ct.rowid = rw_craplot.rowid
        returning nrseqdig into rw_craplot.nrseqdig;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
      end; */
      -- Como não faz mais o update e incremento, Busca o sequencial 
      rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                             pr_nmdcampo => 'NRSEQDIG',
                             pr_dsdchave => to_char(pr_cdcooper)||';'||
                                            to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||
                                            ';1;100;8454');
  
      -- PRJ450 - 05/07/2018.
      lanc0001.pc_gerar_lancamento_conta (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        , pr_cdagenci => rw_craplot.cdagenci
                                        , pr_cdbccxlt => rw_craplot.cdbccxlt
                                        , pr_nrdolote => rw_craplot.nrdolote
                                        , pr_nrdconta => rw_crappla.nrdconta
                                        , pr_nrdocmto => rw_crappla.nrctrpla
                                        , pr_cdhistor => 127   
                                        , pr_nrseqdig => rw_craplot.nrseqdig
                                        , pr_vllanmto => rw_crappla.vlprepla
                                        , pr_nrdctabb => rw_crappla.nrdconta
                                        , pr_cdpesqbb => vr_cdprogra
                                        --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                        --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                        --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                        --, pr_cdbanchq => lt_d_nrbanori
                                        --, pr_cdcmpchq => lt_d_cdcmpori
                                        --, pr_cdagechq => lt_d_nrageori
                                        --, pr_nrctachq => lt_d_nrctarem
                                        --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                        --, pr_sqlotchq => lt_d_nrsequen
                                        --, pr_dtrefere => rw_craprda.dtmvtolt
                                        , pr_hrtransa => vr_hrtransa
                                        --, pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                        --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                        , pr_cdcooper => pr_cdcooper
                                        , pr_nrdctitg => to_char(rw_crappla.nrdconta, '00000000')
                                        --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                        --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                        --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                        --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                        --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                        --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                        --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                        --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                        --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                        -------------------------------------------------
                                        -- Dados do lote (Opcional)
                                        -------------------------------------------------
                                        --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                        --, pr_tplotmov  => 1
                                        , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                        , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                        , pr_cdcritic  => vr_cdcritic      -- OUT
                                        , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)
      
      vr_nrdconta_lcm := rw_crappla.nrdconta;
      vr_nrdocmto_lcm := rw_crappla.nrctrpla;
      vr_nrseqdig_lcm := rw_craplot.nrseqdig;
      vr_vllanmto_lcm := rw_crappla.vlprepla;
					
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
         -- Se vr_incrineg = 0, se trata de um erro de Banco de Dados e deve abortar a sua execução
         IF vr_incrineg = 0 THEN  
            vr_dscritic := 'Problemas ao criar lancamento:'||vr_dscritic;
            RAISE vr_exc_saida;	
         ELSE
            -- Neste caso se trata de uma crítica de Negócio e o lançamento não pode ser efetuado
            -- Para CREDITO: Utilizar o CONTINUE ou gerar uma mensagem de retorno(se for chamado por uma tela); 
            -- Para DEBITO: Será necessário identificar se a rotina ignora esta inconsistência(CONTINUE) ou se devemos tomar alguma ação(efetuar algum cancelamento por exemplo, gerar mensagem de retorno ou abortar o programa)
            CONTINUE;  
         END IF;  
      END IF;		  

      -- Gera aviso de debito em conta corrente
      begin
        insert into crapavs(cdagenci,
                            cdempres,
                            cdhistor,
                            cdsecext,
                            dtdebito,
                            dtmvtolt,
                            dtrefere,
                            insitavs,
                            nrdconta,
                            nrdocmto,
                            nrseqdig,
                            tpdaviso,
                            vldebito,
                            vlestdif,
                            vllanmto,
                            flgproce,
                            cdcooper)
          values(rw_crappla.cdagenci,
                 0,
                 127,
                 rw_crappla.cdsecext,
                 rw_crapdat.dtmvtolt,
                 rw_crapdat.dtmvtolt,
                 rw_crapdat.dtmvtolt,
                 0,
                 vr_nrdconta_lcm,
                 vr_nrdocmto_lcm,
                 vr_nrseqdig_lcm,
                 2,
                 0,
                 0,
                 vr_vllanmto_lcm,
                 0,
                 pr_cdcooper);
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir em CRAPAVS. ' || sqlerrm;
      end;
      -- Buscar lote
      open cr_craplot(pr_cdcooper, rw_crapdat.dtmvtolt, 1, 100, 8464);
      fetch cr_craplot into rw_craplot;
      -- Se não localizar o lote, irá gerar um novo registro
      if cr_craplot%notfound or rw_craplot.retorno > 1 then
        close cr_craplot;
        begin
          insert into craplot(dtmvtolt,
                              cdagenci,
                              cdbccxlt,
                              nrdolote,
                              tplotmov,
                              cdcooper,
                              nrseqdig,
                              vlcompdb,
                              vlinfodb,
                              tpdmoeda,
                              cdoperad)
          values(rw_crapdat.dtmvtolt,
                 1,
                 100,
                 8464,
                 3,
                 pr_cdcooper,
                 0,
                 0,
                 0,
                 1,
                 '1')
          returning rowid,
                    dtmvtolt,
                    cdagenci,
                    cdbccxlt,
                    nrdolote,
                    nrseqdig
               into rw_craplot.rowid,
                    rw_craplot.dtmvtolt,
                    rw_craplot.cdagenci,
                    rw_craplot.cdbccxlt,
                    rw_craplot.nrdolote,
                    rw_craplot.nrseqdig;
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir em CRAPLOT. ' || sqlerrm;
        end;
      else
        close cr_craplot;
      end if;
      -- Atualiza tabela CRAPLOT
      -- Comentado por Yuri - Mouts
/*      begin
        update craplot ct
           set ct.qtinfoln = ct.qtcompln + 1,
               ct.qtcompln = ct.qtcompln + 1,
               ct.vlinfocr = ct.vlcompcr + rw_crappla.vlprepla,
               ct.vlcompcr = ct.vlcompcr + rw_crappla.vlprepla,
               ct.nrseqdig = rw_craplot.nrseqdig + 1
         where ct.rowid = rw_craplot.rowid
        returning nrseqdig into rw_craplot.nrseqdig;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPLOT. ' || sqlerrm;
      end; */

      -- Como não incrementa mais no update, Busca o sequencial 
      rw_craplot.nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT',
                             pr_nmdcampo => 'NRSEQDIG',
                             pr_dsdchave => to_char(pr_cdcooper)||';'||
                                            to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||
                                            ';1;100;8464');
      -- Gera lancamentos de cotas/capital
      begin
        insert into craplct(cdagenci,
                            cdbccxlt,
                            nrdolote,
                            dtmvtolt,
                            cdhistor,
                            nrctrpla,
                            nrdconta,
                            nrdocmto,
                            nrseqdig,
                            vllanmto,
                            cdcooper)
          values(rw_craplot.cdagenci,
                 rw_craplot.cdbccxlt,
                 rw_craplot.nrdolote,
                 rw_crapdat.dtmvtolt,
                 75,
                 rw_crappla.nrctrpla,
                 rw_crappla.nrdconta,
                 rw_crappla.nrctrpla,
                 rw_craplot.nrseqdig,
                 rw_crappla.vlprepla,
                 pr_cdcooper);
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir em CRAPLCT. ' || sqlerrm;
      end;
      -- Atualiza informacoes referentes a cotas e recursos
      begin
        update crapcot
           set vldcotas = vldcotas + rw_crappla.vlprepla,
               qtprpgpl = qtprpgpl + 1
         where rowid = rw_crappla.rowid_cot;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPCOT: ' || sqlerrm;
      end;
          
      -- Atualiza plano de capital
      begin
        update crappla
           set crappla.dtultpag = rw_crapdat.dtmvtolt,
               crappla.vlpagmes = decode(crappla.dtultpag,
                                         to_date('01010001','ddmmyyyy'), crappla.vlpagmes + crappla.vlprepla,
                                         decode(to_char(crappla.dtultpag, 'mm'),
                                                to_char(rw_crapdat.dtmvtolt, 'mm'), crappla.vlpagmes + crappla.vlprepla,
                                                crappla.vlprepla)),
               crappla.qtprepag = crappla.qtprepag + 1,
               crappla.vlprepag = crappla.vlprepag + crappla.vlprepla,

               crappla.dtcancel = decode(crappla.qtprepag+1,
                                         crappla.qtpremax, rw_crapdat.dtmvtolt,
                                         crappla.dtcancel),
               crappla.cdsitpla = decode(crappla.qtprepag+1,
                                         crappla.qtpremax, 2,
                                         crappla.cdsitpla)
         where crappla.rowid = rw_crappla.rowid;
      exception
        when others then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPPLA: ' || sqlerrm;
      end;
    end if;
                                             
    -- Verifica se o plano necessita de nova correcao de valor
    IF (rw_crappla.dtultcor <= vr_dtultcor) AND rw_crappla.cdtipcor > 0 THEN
      vr_indatupl := 1;
    ELSE
      vr_indatupl := 0;  
    END IF;
    
    -- data do pagto sera composto pelo (dia do plano + mes e ano da data atual).
    vr_diapagto := to_char(rw_crappla.dtdpagto,'DD');
    vr_mesanopt := to_char(rw_crapdat.dtmvtolt,'MM/RRRR');
    vr_dtdpagto := to_date(vr_diapagto || '/' || vr_mesanopt,'DD/MM/RRRR');
    
    -- Caso especifico para dia 28/02 que caia no final de semana e seja cobrado no mes seguinte
    -- Ex: rw_crappla.dtdpagto := 28/02/2015 (sabado)
    --     rw_crapdat.dtmvtolt := 02/03/2015 (segunda-feira)
    --     vr_dtdpagto         := 28/03/2015     
    IF (to_char(rw_crappla.dtdpagto,'MM') = '02') AND 
       (to_char(rw_crapdat.dtmvtolt,'MM') = '03') THEN
        vr_indpagto := 0;
    ELSE
        vr_indpagto := CASE WHEN vr_flgrejei = 1 THEN 0 ELSE 1 END;
        -- Atribui data do proximo debito no mes seguinte
        vr_dtdpagto := gene0005.fn_calc_data(vr_dtdpagto,1,'M',vr_dscritic);
    END IF;
    
    -- Atualiza plano de capital
    begin
      update crappla
         set crappla.dtdpagto = vr_dtdpagto,
             crappla.indpagto = vr_indpagto,
             crappla.vlpenden = decode(vr_flgrejei,
                                       1, crappla.vlprepla,
                                       0),
             crappla.flgatupl = vr_indatupl
       where crappla.rowid = rw_crappla.rowid;
    exception
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar dados de pagamento na CRAPPLA: ' || sqlerrm;
    end;
    -- Atualiza controle de restart
    begin
      update crapres
         set nrdconta = rw_crappla.nrdconta
       where cdcooper = pr_cdcooper
         and cdprogra = vr_cdprogra;
      if sql%rowcount = 0 then
        -- Criar o registro se não existir
        BEGIN
          INSERT INTO crapres (cdprogra
                              ,nrdconta
                              ,dsrestar
                              ,cdcooper)
                      VALUES  (vr_cdprogra
                              ,rw_crappla.nrdconta
                              ,' '
                              ,pr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            --Montar mensagem de erro
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela crapres. '||sqlerrm;
            raise vr_exc_saida;
        END;
      end if;
    exception
      when vr_exc_saida then
        raise vr_exc_saida;
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao inserir em CRAPAVS. ' || sqlerrm;
    end;
    -- Salva as alterações da conta
    commit;
  end loop;
  -- Eliminar controle de reprocesso
  btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_dscritic);
  if vr_dscritic is not null then
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  -- Salva todas as informações pendentes
  commit;
exception
  when vr_exc_fimprg then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    commit;
  when vr_exc_saida then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
end;
/
