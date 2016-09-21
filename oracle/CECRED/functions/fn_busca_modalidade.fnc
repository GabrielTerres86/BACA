create or replace function cecred.fn_busca_modalidade (pr_cdmodali      IN PLS_INTEGER,
                                                pr_cdcooper      IN crapepr.cdcooper%TYPE,
                                                pr_nrdconta      IN crapepr.nrdconta%TYPE,
                                                pr_nrctremp      IN crapepr.nrctremp%TYPE,
                                                pr_inpessoa      IN crapris.inpessoa%TYPE,
                                                pr_cdorigem      IN crapris.cdorigem%TYPE,
                                                pr_dsinfaux      IN crapris.dsinfaux%TYPE) return varchar2 is

-- ..........................................................................

    -- Programa: fn_busca_modalidade
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Alisson (AMCOM)
    -- Data    : Novembro/2014.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia : As views do cadastro positivo utilizam esta function
    -- Objetivo   : Retornar a modalidade de cr�dito para as views do cadastro positivo - a mesma modalidade que � enviada
    --              no arquivo do banco central (3040) gerado pelo crps 573.

    -- Par�metros : pr_cdmodali: modalidade de cr�dito (0299 ou 0499)
    --              pr_cdcooper: Cooperativa da conta em quest�o
    --              pr_nrdconta: conta em quest�o
    --              pr_nrctremp: contrato de empr�stimo em quest�o
    --              pr_inpessoa: inpessoa - crapass (PF ou PJ)
    --              pr_cdorigem: sempre 3 - pois � empr�stimo
    --              pr_dsinfaux: passar vazio ... pois n�o temos caso de BNDES
    --
    -- Alteracoes:  27/01/2015 - Quando o empr�stimo tiver apenas 1 parcela, a data do 1�
    --                           pagamento � tamb�m a data da �ltima.  Quando tiver mais de 1 parcela,
    --                           descontamos a parcela 01 para calculo de meses, j� que a mesma j� �
    --                           cobrada na data de in�cio do pagamento. SD 248861 (Alisson - AMcom)
    --
    -- .............................................................................

  --Dados Emprestimo BNDES
  CURSOR cr_crapebn (pr_cdcooper IN crapebn.cdcooper%type
                    ,pr_nrdconta IN crapebn.nrdconta%type
                    ,pr_nrctremp IN crapebn.nrctremp%type) IS
    SELECT crapebn.cdsubmod
          ,crapebn.dtinictr
          ,crapebn.dtfimctr
    FROM crapebn
    WHERE crapebn.cdcooper = pr_cdcooper
    AND   crapebn.nrdconta = pr_nrdconta
    AND   crapebn.nrctremp = pr_nrctremp;
  rw_crapebn cr_crapebn%rowtype;
  --Dados do Emprestimo
  CURSOR cr_crapepr (pr_cdcooper IN crapebn.cdcooper%type
                    ,pr_nrdconta IN crapebn.nrdconta%type
                    ,pr_nrctremp IN crapebn.nrctremp%type) IS
    SELECT crapepr.cdcooper
          ,crapepr.cdlcremp
          ,crapepr.dtmvtolt
          ,crapepr.qtpreemp
          ,crawepr.dtdpagto dtdpripg
    FROM crapepr, crawepr
    WHERE crapepr.cdcooper = pr_cdcooper
    AND   crapepr.nrdconta = pr_nrdconta
    AND   crapepr.nrctremp = pr_nrctremp
    AND   crapepr.cdcooper = crawepr.cdcooper (+)
    AND   crapepr.nrdconta = crawepr.nrdconta (+)
    AND   crapepr.nrctremp = crawepr.nrctremp (+);
  rw_crapepr cr_crapepr%rowtype;
  --Selecionar Linha Credito
  CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%type
                    ,pr_cdlcremp IN craplcr.cdlcremp%type) IS
    SELECT craplcr.cdmodali
          ,craplcr.cdsubmod
    FROM craplcr
    WHERE craplcr.cdcooper = pr_cdcooper
    AND   craplcr.cdlcremp = pr_cdlcremp;
  rw_craplcr cr_craplcr%rowtype;

  vr_cdmodali    VARCHAR2(4);
  vr_data_inictr DATE;
  vr_data_fimctr DATE;
begin

  -- Para Outros Emprestimos ou Outros Financiamentos
  if pr_cdmodali in(0299,0499) then
    -- Somente origem 3 - Emprestimos
    if pr_cdorigem = 3 then
      -- Verifica se possui emprestimo pelo BNDES
      if pr_dsinfaux = 'BNDES' then
        -- Usar submodalidade do empr�stimo BNDES
        open cr_crapebn (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        fetch cr_crapebn into rw_crapebn;
        if cr_crapebn%FOUND then
          vr_cdmodali := rw_crapebn.cdsubmod;
        end if;
        close cr_crapebn;
      else
        -- Buscaremos da Linha de Cr�dito Cfme Crapepr
        open cr_crapepr (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        fetch cr_crapepr into rw_crapepr;
        --Se encontrou
        if cr_crapepr%found then
          --Selecionar Linha Credito
          open cr_craplcr (pr_cdcooper => pr_cdcooper
                          ,pr_cdlcremp => rw_crapepr.cdlcremp);
          fetch cr_craplcr into rw_craplcr;
          --Se encontrou
          if cr_craplcr%found then
            if trim(rw_craplcr.cdmodali) IS NOT NULL AND trim(rw_craplcr.cdsubmod) IS NOT NULL then
              vr_cdmodali := lpad(rw_craplcr.cdmodali,2,'0') || lpad(rw_craplcr.cdsubmod,2,'0');
            end if;
          end if;
          close cr_craplcr;
        end if;
        close cr_crapepr;
      end if;
    end if;
    -- Se n�o achou modalidade cfme linha cr�dito
    if vr_cdmodali IS NULL then
      -- Usar a modalidade enviada
      vr_cdmodali := lpad(pr_cdmodali,4,'0');
    end if;
    -- Somente para capital de giro de pessoa f�sica
    if pr_inpessoa = 1 and vr_cdmodali = '0206' then -- capital de giro
      vr_cdmodali := '0203';
    -- Para Pessoa Juridica, modalidades 203 e 206 e Origem 3
    elsif pr_inpessoa = 2 and vr_cdmodali IN('0203','0206') and pr_cdorigem = 3 then
      -- Para empr�stimo do BNDES
      if pr_dsinfaux = 'BNDES' then
        open cr_crapebn (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        fetch cr_crapebn into rw_crapebn;
        if cr_crapebn%FOUND then
          -- Buscar Data de termino e in�cio que j� existem na tabela
          vr_data_fimctr := rw_crapebn.dtfimctr;
          vr_data_inictr := rw_crapebn.dtinictr;
        end if;
        close cr_crapebn;
      else
        -- Buscaremos da Linha de Cr�dito Cfme Crapepr
        open cr_crapepr (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => pr_nrctremp);
        fetch cr_crapepr into rw_crapepr;
        --Se encontrou
        if cr_crapepr%found then
          -- Montar a data prevista do ultimo vencimento com base na data do
          -- primeiro pagamento * qtde de parcelas do empr�stimo
          -- Obs: Quando empr�stimo tiver apenas 1 parcela, a data do 1�
          -- pagamento � tamb�m a data da �ltima
          -- Quando tiver mais de 1 parcela, descontamos a parcela 01
          -- para calculo de meses, j� que a mesma j� � cobrada na data
          -- de in�cio do pagamento
          IF rw_crapepr.qtpreemp = 1 THEN
            vr_data_fimctr:= rw_crapepr.dtdpripg;
          ELSE
            vr_data_fimctr:= gene0005.fn_dtfun(pr_dtcalcul => rw_crapepr.dtdpripg
                                              ,pr_qtdmeses => rw_crapepr.qtpreemp-1);
          END IF;
          -- Data do in�cio j� existe no cadastro
          vr_data_inictr := rw_crapepr.dtmvtolt;
        end if;
        close cr_crapepr;
      end if;
      -- Se o empr�stimo possui per�odo inferior a 365 dias
      if ( vr_data_fimctr - vr_data_inictr) <= 365 then
        -- capital de giro com prazo de vencimento at� 365 d
        vr_cdmodali := '0215';
      else
        -- capital de giro com prazo vencimento superior 365 d
        vr_cdmodali := '0216';
      end if;
    end if;
  else
    -- Manter a modalidade enviada
    vr_cdmodali := lpad(pr_cdmodali,4,'0');
  end if;
  -- Substituir modalidade excluida (0201 - Antiga Chq Esp. e Conta Garantida)
  return(replace(vr_cdmodali,'0201','0213'));

end fn_busca_modalidade;
/

