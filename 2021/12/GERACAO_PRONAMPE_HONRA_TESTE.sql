DECLARE
  -- VARIAVEIS --
  -- Variaveis de controle geral
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  rw_repasse  credito.tbcred_pronampe_repasse%ROWTYPE;
  rw_contrato credito.tbcred_pronampe_contrato%ROWTYPE;
  
  -- Controle de erros
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;   
  vr_tab_erro cecred.gene0001.typ_tab_erro;
  vr_des_reto VARCHAR2(100);
  
  vr_cdlcremp_pronampe    craplcr.cdlcremp%TYPE := 2600;
  vr_cdlcremp_pronampe_pf craplcr.cdlcremp%TYPE := 2610;
  vr_cdhistor_pronampe    craplcm.cdhistor%TYPE := 3280;
  vr_caminho_arquivo      crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'DIR_BB_CONNECTDIRECT');

  vr_caminho_arquivo_envia crapprm.dsvlrprm%TYPE := vr_caminho_arquivo||'log/';
  vr_caminho_arquivo_tmp   crapprm.dsvlrprm%TYPE := vr_caminho_arquivo||'tmp/';
  vr_caminho_arquivo_log   crapprm.dsvlrprm%TYPE := vr_caminho_arquivo||'log/';

  vr_dscomando VARCHAR2(4000);
  vr_typ_saida VARCHAR2(4000);
                                                   
  -- Variaveis para montagem do arquivo
  vr_arqremessa     CLOB;
  vr_arqlog_erro    CLOB;
  vr_arqlog_geracao CLOB;    
  vr_arq_csv        CLOB;  
  vr_linha          number;
  vr_seq_arquivo    NUMBER(7);
  vr_arquivo        varchar2(100);
  vr_arquivo2       varchar2(100);
  vr_progcredito    varchar2(2);  
  vr_gerou_detalhe  int;
   
  -- Variaveis para busca do saldo devedor
  vr_diapagto INTEGER; --> Dia para pagamento
  vr_qtprecal crapepr.qtprecal%TYPE; --> Quantidade de prestações calculadas até momento
  vr_vlprepag NUMBER; --> Valor acumulado pago no mês
  vr_vlpreapg NUMBER; --> Valor a pagar
  vr_vljurmes NUMBER; --> Juros no mês corrente
  vr_vljuracu NUMBER; --> Juros acumulados total
  vr_vlsdeved NUMBER; --> Saldo devedor acumulado
  vr_dtultpag crapepr.dtultpag%TYPE; --> Ultimo dia de pagamento das prestações
  vr_vlmrapar crappep.vlmrapar%TYPE; --> Valor do Juros de Mora
  vr_vlmtapar crappep.vlmtapar%TYPE; --> Valor da Multa
  vr_vliofcpl crappep.vliofcpl%TYPE; --> Valor da Multa
  vr_vlprvenc NUMBER; --> Valor a parcela a vencer
  vr_vlpraven NUMBER; --> Valor da parcela vencida
  vr_publico_alvo number(1);
  vr_tp_pes       number(1);
  
  vr_vlprincipal_normal NUMBER(25,6);
  vr_vlprincipal_atraso NUMBER(25,6);
  vr_vlencargos_normal  NUMBER(25,6);
  vr_vlencargos_atraso  NUMBER(25,6);
  vr_vlparcela_sjuros   NUMBER(25,6);
  vr_fatura_ano         NUMBER(25,6); --valor de faturamento anual
  vr_cdnatopc           crapttl.cdnatopc%type; --codigo da natureza de ocupacao
  vr_cdcnae             TBCRED_CNAEPRONAMPE.cdcnae%type;
   
  vr_tab_parcelas cecred.empr0011.typ_tab_parcelas;
  vr_tab_calculado cecred.empr0011.typ_tab_calculado;
  vr_contratospronamp credito.tiposDadosPronampe.typ_tab_contratospronamp;
  vr_liqparpronamp    credito.tiposDadosPronampe.typ_tab_liqparpronamp;
  vr_vlrepasse        credito.tbcred_pronampe_repasse.vlrepasse%TYPE;
  vr_coop_honra       cecred.crappco.dsconteu%TYPE;
  
  vr_idx              NUMBER;
  vr_vldHonra         NUMBER;
  -- CURSORES --
  -- Dados das cooperativas
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,c.cdagectl
          ,c.nmcidade
          ,c.cdufdcop
      FROM crapcop      c
     WHERE c.flgativo = 1
     ORDER BY decode(c.cdcooper, 
                     1,  1, 
                     16, 2, 
                     9,  3, 
                     7,  4, 
                     13, 5,  
                     14, 6,  
                     2,  7,  
                     10, 8, 
                     12, 9, 
                     8,  10,
                     11, 11, 
                     6,  12,
                     5,  13,
                     14);
  
  -- Dados de Emprestimos
  CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                   ,pr_dtmvtolt crawepr.dtmvtolt%TYPE
                   ,pr_cdlcremp crapepr.cdlcremp%TYPE
                   ,pr_cdlcrepf crapepr.cdlcremp%TYPE) IS
    SELECT e.*, w.vlemprst valor_solicitado
      FROM crapepr e
          ,crawepr w
     WHERE e.cdcooper = pr_cdcooper
       AND e.dtmvtolt = pr_dtmvtolt
       AND e.cdlcremp in (pr_cdlcremp, pr_cdlcrepf)
       and w.cdcooper = e.cdcooper
       and w.nrdconta = e.nrdconta
       and w.nrctremp = e.nrctremp;                       
     
  -- Dados do Associado
  CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE
                   ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT a.nrcpfcgc
          ,a.cdagenci
          ,a.inpessoa
          ,a.cdclcnae
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;
       
  -- Dados de Município por agência
  CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                   ,pr_cdagenci crapage.cdagenci%TYPE) IS    
      select substr(m.cdcomarc,1,length(m.cdcomarc)-1) cdcomarc -- Sem o Dígito.
      from   crapage       a
            ,crapmun       m
      where  a.cdufdcop  = m.cdestado
      and    a.nmcidade  = m.dscidade
      and    a.cdcooper  = pr_cdcooper
      and    a.cdagenci  = pr_cdagenci
      and    a.insitage  = 1;
  
  -- Buscar valor creditado
  CURSOR cr_craplcm(pr_cdcooper craplcm.cdcooper%TYPE
                   ,pr_cdhistor craplcm.cdhistor%TYPE
                   ,pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS
    SELECT l.cdcooper
          ,l.dtmvtolt
          ,l.vllanmto
          ,l.nrdconta
          ,e.cdagenci
          ,e.cdopeori
          ,e.nrctremp
          ,e.progress_recid
          ,e.vlemprst
      FROM craplcm l
          ,crapepr e
     WHERE l.cdcooper = pr_cdcooper
       AND l.cdhistor = pr_cdhistor
       AND l.dtmvtolt = pr_dtmvtolt
       AND e.cdcooper = l.cdcooper
       AND e.nrdconta = l.nrdconta
       AND e.nrctremp = l.nrdocmto;
       
  -- Dados de Município
  CURSOR cr_crapmun(pr_cdestado crapmun.cdestado%TYPE
                   ,pr_dscidade crapmun.dscidade%TYPE) IS    
    select substr(m.cdcomarc,1,length(m.cdcomarc)-1) cdcomarc -- Sem o Dígito.
    from   crapmun      m
    where  m.cdestado = pr_cdestado
    and    m.dscidade = pr_dscidade;
    
  -- Dados de data de vencimento
  CURSOR cr_crappep(PR_CDCOOPER CRAPPEP.CDCOOPER%TYPE
                   ,PR_NRDCONTA CRAPPEP.NRDCONTA%TYPE
                   ,PR_NRCTREMP CRAPPEP.NRCTREMP%TYPE) IS        
    SELECT MAX(DTVENCTO) DTVENCTO
    FROM   CRAPPEP    
    WHERE  CDCOOPER = PR_CDCOOPER 
    AND    NRDCONTA = PR_NRDCONTA 
    AND    NRCTREMP = PR_NRCTREMP;

  -- Dados de Natureza Jurídica
  -- Dados de Faturamento Bruto  
  CURSOR cr_crapjur(pr_cdcooper crapjur.cdcooper%TYPE
                   ,pr_nrdconta crapjur.nrdconta%TYPE) IS    
    select j.natjurid
          ,case when nvl(j.vlfatano,0) > 1 then nvl(j.vlfatano,0) else 0 end vlfatano      
    from   crapjur      j
    where  j.cdcooper = pr_cdcooper
    and    j.nrdconta = pr_nrdconta;
    
  -- Saldos
  CURSOR cr_epr_saldos(pr_cdcooper crapepr.cdcooper%TYPE
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                      ,pr_cdlcremp crapepr.cdlcremp%TYPE
                      ,pr_cdlcrepf crapepr.cdlcremp%TYPE) IS
    SELECT p.cdcooper
          ,p.nrdconta
          ,p.nrctremp
          ,p.dtmvtolt
          ,p.cdlcremp
          ,p.vlemprst
          ,p.txmensal
          ,w.dtdpagto
          ,p.vlsprojt
          ,p.progress_recid
          ,p.qtpreemp
      FROM crapepr p
          ,crawepr w
     where p.cdcooper = pr_cdcooper
       and p.inliquid = 0
       and p.cdlcremp in (pr_cdlcremp, pr_cdlcrepf)
       AND P.DTMVTOLT < pr_dtmvtolt
       and w.cdcooper = p.cdcooper
       and w.nrdconta = p.nrdconta
       and w.nrctremp = p.nrctremp;  

  -- Dados de rating de operação, retorna mais atual.
  CURSOR cr_tco(pr_cdcooper tbrisco_central_ocr.cdcooper%TYPE
               ,pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE
               ,pr_nrctremp tbrisco_central_ocr.nrctremp%TYPE) is        
    select   RISC0004.fn_traduz_risco(r.inrisco_operacao) rating_operacao
    from     tbrisco_central_ocr r
    where    r.cdcooper        = pr_cdcooper
    and      r.nrdconta        = pr_nrdconta
    and      r.nrctremp        = pr_nrctremp
    and      rownum            = 1
    order by r.dtrefere          desc;
  
  -- Última remessa gerada  
  CURSOR cr_remessa IS 
    SELECT nvl(MAX(rem.nrremessa), 0) nrremessa
      FROM tbcred_pronampe_remessa rem;

  -- Total repasse FGO
  CURSOR cr_totrepasse (pr_cdcooper   tbcred_pronampe_repasse.cdcooper%TYPE
                       ,pr_nrdconta   tbcred_pronampe_repasse.nrdconta%TYPE
                       ,pr_nrcontrato tbcred_pronampe_repasse.nrcontrato%TYPE) IS 
    SELECT SUM(vlrepasse) vlrepasse
      FROM credito.tbcred_pronampe_repasse
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrcontrato = pr_nrcontrato;

  --dados de natureza da ocupacao para pf
  cursor cr_natocup(pr_cdcooper tbrisco_central_ocr.cdcooper%TYPE
                   ,pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE) IS
  select cdnatopc 
    from crapttl 
   where cdcooper = pr_cdcooper 
   and   nrdconta = pr_nrdconta;
   
  --cnaes que irão enquadrar no programa pronampe perse
  cursor cr_cnae (pr_cdcnae TBCRED_CNAEPRONAMPE.cdcnae%TYPE) is
  select c.cdcnae
  from   tbcred_cnaepronampe c
  where  c.cdcnae = pr_cdcnae;
  
  --valor de faturamento da pessoa fisica
  cursor cr_pessoafisica(pr_cdcooper tbrisco_central_ocr.cdcooper%TYPE
                        ,pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE) is
  SELECT (vlsalari +
          (vldrendi##1
         + vldrendi##2
         + vldrendi##3
         + vldrendi##4
         + vldrendi##5
         + vldrendi##6)) * 12 fatano
      FROM crapttl
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND idseqttl = 1;
   
  rw_crapass cr_crapass%ROWTYPE;  
  rw_crapepr cr_crapepr%ROWTYPE;  
  rw_crapcop cr_crapcop%ROWTYPE;  
  rw_crapmun cr_crapmun%ROWTYPE; 
  rw_crappep cr_crappep%ROWTYPE; 
  rw_crapjur cr_crapjur%ROWTYPE; 
  rw_tco     cr_tco%ROWTYPE; 
  rw_crapage cr_crapage%ROWTYPE; 
  rw_remessa    cr_remessa%ROWTYPE; 
  rw_totrepasse cr_totrepasse%ROWTYPE; 
      
---------------------------------------------------------------------------------------- 
  function f_ret_campo(pr_vlr_campo in varchar2
                      ,pr_tam_campo in number
                      ,pr_tip_campo in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    if length(pr_vlr_campo) <= pr_tam_campo then   
      if pr_tip_campo = 'D' then -- Data  rrrrmmdd
        if length(pr_vlr_campo) = 8 then 
          Result := pr_vlr_campo;
        end if;
      end if;
      if pr_tip_campo in ('N','M') then -- Numérico ou Moeda(valores com 2 casas decimais multiplicados por 100)
        Result := lpad(to_char(to_number(pr_vlr_campo)),pr_tam_campo,'0');
      end if;
      if pr_tip_campo = 'A' then -- Alpha
        Result := rpad(upper(to_char(pr_vlr_campo)),pr_tam_campo,' ');
      end if;  
      if pr_tip_campo = 'H' then -- hora HHMMSS
        if length(pr_vlr_campo) = 6 then 
          Result := pr_vlr_campo;
        end if;
      end if; 
    end if;
    return(Result);
  end f_ret_campo;
----------------------------------------------------------------------------------------
  function f_ret_header(pr_linha   in varchar2
                       ,pr_seqcoop in varchar2) return varchar2 is
    Result       varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')||   -- Nº sequencial do registro “0000001”  -- linha 1
              f_ret_campo('1',2,'N')||        -- Código do tipo do registro “01”
              f_ret_campo('GFGF0010',8,'A')|| -- Nome do Arquivo Remessa “GFGF0010”
              f_ret_campo('20170331',8,'D')|| -- Versão do leiaute “20170331”
              f_ret_campo('20',3,'N')||       -- Código do Agente Financeiro, atribuído pelo Administrador. Exemplos: "002"=Banco do Nordeste, "003"=Caixa Econômica Federal
              f_ret_campo('2',3,'N')||        -- Código do Fundo Garantidor “002”
              f_ret_campo(pr_seqcoop,4,'N')|| -- Nº sequencial da Remessa gerada pelo Agente. Começa em “0001”
              f_ret_campo(' ',175,'A');       -- 176 Espaços fixo
    return(Result);
  end f_ret_header;
----------------------------------------------------------------------------------------
  function f_ret_detalhe_03(pr_linha       in varchar2
                           ,pr_1           in varchar2
                           ,pr_2           in varchar2
                           ,pr_3           in varchar2
                           ,pr_4           in varchar2
                           ,pr_5           in varchar2
                           ,pr_6           in varchar2
                           ,pr_7           in varchar2
                           ,pr_8           in varchar2
                           ,pr_9           in varchar2
                           ,pr_progcredito in varchar2
                           ,vr_tp_pes      in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro
              f_ret_campo('3',2,'N')|| -- Código do tipo do registro “03”
              f_ret_campo(pr_1,20,'A')|| -- COOP || NUM. CONTRATO. Código identificador da operação de crédito no âmbito do Agente
              f_ret_campo(pr_2,4,'N')|| -- Nº da agência contratante da operação de crédito (sem DV)
              f_ret_campo(pr_3,7,'N')|| -- Código IBGE do município onde se localiza a agência contratante da operação (sem DV). Exemplo: Brasília=”0530010”
              f_ret_campo(vr_tp_pes,1,'N')|| -- Código do tipo de pessoa do mutuário (item 13.3). Para FGO Pronampe informe "2" Pessoa jurídica.
              f_ret_campo(pr_4,14,'N')|| -- CPF ou CNPJ do mutuário
              f_ret_campo(pr_5,2,'N')|| -- De 1 a 5 .Código do público alvo onde o mutuário se enquadra (item 13.4).
              f_ret_campo(pr_6,17,'M')|| -- Valor do faturamento bruto anual
              f_ret_campo(pr_7,17,'M')|| -- "Valor da operação:
                                       -- - Se crédito fixo, informe o valor financiado;
                                       -- - Se crédito rotativo, informe o limite de crédito contratado."
              f_ret_campo('10000',5,'N')|| -- Percentual da garantia FGO com duas casas decimais. Para FGO Pronampe informe "10000" 100%.
              f_ret_campo('1',1,'N')|| -- 1-Crédito Fixo, 2-Crédito Rotativo. Código da modalidade de crédito (item 13.5). 
              f_ret_campo('2',1,'N')|| -- 1-Investimento, 2-Capital de Giro. Código da finalidade do crédito (item 13.6)
              f_ret_campo('11',3,'N')|| -- Código da fonte de recursos (item 13.7). Para FGO Pronampe informe "11" Recurso próprio.
              f_ret_campo(pr_progcredito,4,'N')|| -- Código do programa de crédito (item13.8). Para FGO Pronampe informe "39" Pronampe.
              f_ret_campo(pr_8,8,'D')|| -- Data da formalização da operação
              f_ret_campo(pr_9,8,'D')|| -- Data de vencimento da operação
              f_ret_campo('1',1,'N')|| -- 1-Cronogramas unificados,2-Cronogramas independentes. Código do tipo de cronograma de amortizações (item 13.9)
              f_ret_campo('1',2,'N')|| -- Código de condição especial da operação (item 13.10). Para FGO Pronampe informe "01" Sem condição especial.
              f_ret_campo('00000000',8,'D')|| -- Data do despacho externo. Para FGO Pronampe informe “00000000”
              f_ret_campo('1',1,'N')|| -- Código do tipo de formalização (item 13.15). Para FGO Pronampe informe "1" Ordinária.
              f_ret_campo('0',9,'N')|| -- Número da pré-validação do evento. Se não houve pré-validação, informe "000000000"
              f_ret_campo(' ',68,'A'); -- 69 espaços fixos.
    return(Result);
  end f_ret_detalhe_03;
----------------------------------------------------------------------------------------
  function f_ret_detalhe_04(pr_linha in varchar2
                           ,pr_1     in varchar2
                           ,pr_2     in varchar2
                           ,pr_3     in varchar2
                           ,pr_4     in varchar2
                           ,pr_5     in varchar2
                           ,pr_6     in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('4',2,'N')||      -- Código do tipo do registro “04”
              f_ret_campo(pr_1,20,'A')|| -- PROGRESS_RECID CRAPEPR. Código identificador da operação de crédito no âmbito do Agente
              f_ret_campo(pr_2,8,'D')||  -- Data da liberação de crédito.
              f_ret_campo(pr_3,17,'M')|| -- Valor da liberação de crédito.
              f_ret_campo(pr_4,8,'D')||  -- Data de vencimento da operação. Repita a data originalmente contratada.
              f_ret_campo(pr_5,17,'M')|| -- Valor da operação. Repita o valor originalmente contratado.
              f_ret_campo(pr_6,17,'M')|| -- Valor do saldo devedor da operação imediatamente antes da liberação de crédito, somados capital, encargos, acessórios, juros e correção monetária
              f_ret_campo('0',17,'M')||     -- Informe zeros.
              f_ret_campo('0',9,'N')||      -- Informe zeros
              f_ret_campo('0',17,'M')||     -- Informe zeros
              f_ret_campo(' ',71,'A');      -- 72 Espaços fixos.
    return(Result);
  end f_ret_detalhe_04;
----------------------------------------------------------------------------------------
  function f_ret_detalhe_05(pr_linha in varchar2
                           ,pr_1     in varchar2
                           ,pr_2     in varchar2
                           ,pr_3     in varchar2
                           ,pr_4     in varchar2
                           ,pr_5     in varchar2
                           ,pr_6     in varchar2
                           ,pr_7     in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('5',2,'N')|| -- Código do tipo do registro “05”
              f_ret_campo(pr_1,20,'A')|| -- PROGRESS_RECID CRAPEPR. CSódigo identificador da operação de crédito no âmbito do Agente
              f_ret_campo(pr_2,8,'D')||  -- Data de apuração dos saldos
              f_ret_campo(pr_3,17,'M')|| -- Valor do saldo devedor de capital (principal) em normalidade
              f_ret_campo(pr_4,17,'M')|| -- Valor do saldo devedor de capital (principal) em atraso
              f_ret_campo(pr_5,17,'M')|| -- Valor do saldo devedor de encargos (juros, correção monetária, acessórios, e todos os demais componentes do saldo) em normalidade.
              f_ret_campo(pr_6,17,'M')|| -- Valor do saldo devedor de encargos (juros, correção monetária, acessórios, e todos os demais componentes do saldo) em atraso.
              f_ret_campo(pr_7,2,'A')|| -- "Código do nível de risco da operação de crédito na data dos saldos informados. De “AA” até “H”, conforme resolução BACEN 2.682 de 21.12.1999"
              f_ret_campo(' ',103,'A'); -- 104 Espaços fixos.
    return(Result);
  end f_ret_detalhe_05;
----------------------------------------------------------------------------------------
  function f_ret_detalhe_06(pr_linha in varchar2
                           ,pr_1     in varchar2
                           ,pr_2     in varchar2
                           ,pr_3     in varchar2
                           ,pr_4     in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('6',2,'N')||      -- Código do tipo do registro “06”
              f_ret_campo(pr_1,20,'A')||    -- PROGRESS_RECID CRAPEPR. Código identificador da operação de crédito no âmbito do Agente
              f_ret_campo(pr_2,8,'D')||     -- Data de início da inadimplência
              f_ret_campo(pr_3,8,'D')||     -- Data da solicitação de honra da garantia
              f_ret_campo(pr_4,17,'M')||    -- Valor do saldo base para cálculo do valor a ser honrado
              f_ret_campo(' ',149,'A');     -- 149 Espaços fixos.
    return(Result);
  end f_ret_detalhe_06;  
----------------------------------------------------------------------------------------
  function f_ret_trailer(pr_linha in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('99',2,'N')||     -- Código do tipo do registro “99”.
              f_ret_campo(pr_linha,7,'N')|| -- Quantidade de registros no arquivo (inclusive header e trailer).
              f_ret_campo(' ',194,'A');     -- 195 Espaços fixos.
    return(Result);
  end f_ret_trailer;
----------------------------------------------------------------------------------------
begin
  --
  vr_gerou_detalhe := 0;
  --
  
  -- Busca o numero da última remessa gerada
  OPEN cr_remessa;
  FETCH cr_remessa INTO rw_remessa;
  IF rw_remessa.nrremessa > 0 THEN
    vr_seq_arquivo := rw_remessa.nrremessa + 1;    
  ELSE
    vr_dscritic := 'Erro ao buscar sequencial de remessa. Tabela TBCRED_PRONAMPE_REMESSA não inicializada.';
  END IF; 
  CLOSE cr_remessa;
 
  -- Monta o header  
  vr_linha      := 1;                        
  vr_arqremessa := to_clob(f_ret_header(to_char(vr_linha)
                                       ,to_char(vr_seq_arquivo))); --4N 
                                
  vr_arqlog_erro    := to_clob(' ');                               
  vr_arqlog_geracao := vr_arqlog_geracao || to_clob('HEADER Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Sequencial de Remessa:  ' || vr_seq_arquivo || chr(10));
  vr_arq_csv        := to_clob('Codigo da Cooperativa'||';'||
                               'Numero da Conta'||';'||
                               'Numero do Contrato'||';'||
                               'Valor Solicitado');
                               
  -- Percorre as cooperativas ativas
  FOR rw_crapcop IN cr_crapcop LOOP 
    --
    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1; 
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    vr_coop_honra := NVL(credito.obterStatusBloqHonraPronampe(pr_cdcooper => rw_crapcop.cdcooper), 'NAO');
    
    --
    -- Busca emprestimos da cooperativa feitos no dia
    -- Loop de registros 03 - Formalização
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_cdlcremp => vr_cdlcremp_pronampe
                                ,pr_cdlcrepf => vr_cdlcremp_pronampe_pf) LOOP

      -- Busca dados do Associado
      OPEN cr_crapass(pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_nrdconta => rw_crapepr.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Sem dados do associado: Cooperativa ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta); 
        CONTINUE;
        CLOSE cr_crapass;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      --
      -- Dados de Município
      OPEN cr_crapmun(pr_cdestado => rw_crapcop.cdufdcop
                     ,pr_dscidade => rw_crapcop.nmcidade);
      FETCH cr_crapmun INTO rw_crapmun;
      
      IF cr_crapmun%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Associado sem dados de Município: Cooperativa ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || ' UF ' ||rw_crapcop.cdufdcop || ' Cidade '||rw_crapcop.nmcidade);
        CLOSE cr_crapmun;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapmun;
      END IF;            
      --   
      -- Dados de Município por agência
      OPEN cr_crapage(pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_cdagenci => rw_crapass.cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      CLOSE cr_crapage;
      --
      -- Dados de data de vencimento
      OPEN cr_crappep(pr_cdcooper => rw_crapepr.cdcooper
                     ,pr_nrdconta => rw_crapepr.nrdconta
                     ,pr_nrctremp => rw_crapepr.nrctremp);
      FETCH cr_crappep INTO rw_crappep;
      IF cr_crappep%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Associado sem dados de Data de Vencimento: Cooperativa ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || 'Contrato '||rw_crapepr.nrctremp); 
        CLOSE cr_crappep;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crappep;
      END IF; 
      --
      --se pessoa fisica
      IF rw_crapass.inpessoa = 1 THEN
        vr_tp_pes := 1;
        open cr_natocup(pr_cdcooper => rw_crapepr.cdcooper
                       ,pr_nrdconta => rw_crapepr.nrdconta);
        fetch cr_natocup into vr_cdnatopc;
        close cr_natocup;  
      
        IF vr_cdnatopc = 2 THEN
          vr_publico_alvo := 6;
        ELSE
          vr_publico_alvo := 2;
        END IF;
        
        open cr_pessoafisica( pr_cdcooper => rw_crapepr.cdcooper
                             ,pr_nrdconta => rw_crapepr.nrdconta);
        fetch cr_pessoafisica into vr_fatura_ano;
        close cr_pessoafisica;
      ELSE
        -- Dados de Natureza Jurídica
        -- Dados de Faturamento Bruto
        vr_tp_pes := 2;
        
        OPEN cr_crapjur(pr_cdcooper => rw_crapepr.cdcooper
                       ,pr_nrdconta => rw_crapepr.nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        CLOSE cr_crapjur;
        --
        vr_fatura_ano := rw_crapjur.vlfatano;
        --
        -- Cálculo do Código Público alvo
        if    (nvl(rw_crapjur.vlfatano,0) <=    360000) then
          vr_publico_alvo := 1; -- Microempresa
        elsif (nvl(rw_crapjur.vlfatano,0) >     360000) and 
              (nvl(rw_crapjur.vlfatano,0) <=   4800000) then
          vr_publico_alvo := 4; -- Pequena empresa
        elsif (nvl(rw_crapjur.vlfatano,0) >    4800000)then
          vr_publico_alvo := 5; -- Média empresa        
        end if;  
      end if; 
      --
      --verifica se o cnae se enquadra no programa pronampe perse
      --
      open cr_cnae(rw_crapass.cdclcnae);
      fetch cr_cnae into vr_cdcnae;
      if cr_cnae%notfound then
        vr_progcredito := '39';
      else
        vr_progcredito := '40';
      end if;
      close cr_cnae;
      --
      -- Monta detalhe 
      vr_gerou_detalhe := 1;
      vr_linha      := vr_linha+1;  
      vr_arqremessa := vr_arqremessa||to_clob(chr(10)||
                       f_ret_detalhe_03(to_char(vr_linha)
                                       ,to_char(rw_crapepr.progress_recid)        --20A
                                       ,to_char(nvl(rw_crapcop.cdagectl,0))       --4N                                 
                                       ,to_char(nvl(rw_crapage.cdcomarc,nvl(rw_crapmun.cdcomarc,0)))--7N
                                       ,to_char(nvl(rw_crapass.nrcpfcgc,0))       --14N
                                       ,to_char(vr_publico_alvo)                  --2N
                                       ,to_char((nvl(vr_fatura_ano,0)*100)) --17M
                                       ,to_char((nvl(rw_crapepr.vlemprst,0)*100)) --17M
                                       ,nvl(to_char(rw_crapepr.dtmvtolt,'rrrrmmdd'),'00000000')   --8D
                                       ,nvl(to_char(rw_crappep.dtvencto,'rrrrmmdd'),'00000000')
                                       ,vr_progcredito
                                       ,to_char(vr_tp_pes))); --8D
      
      vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 03 Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Id Unico Emprestimo:  ' || rw_crapepr.progress_recid 
                                             || ' Cooperativa: ' || rw_crapcop.cdcooper || ' Conta: '|| rw_crapepr.nrdconta || ' Contrato: '|| rw_crapepr.nrctremp 
                                             || ' Valor Financiado: ' || rw_crapepr.vlemprst 
                                             || ' Valor Solicitado: ' || rw_crapepr.valor_solicitado 
                                             || ' Financia Tarifas: ' || case when nvl(rw_crapepr.idfiniof,0) > 0 then 'SIM' else 'NAO' end ||chr(10));                                   
                                             
      vr_arq_csv := vr_arq_csv||to_clob(chr(10)||to_char(rw_crapcop.cdcooper)||';'||
                                                 to_char(rw_crapepr.nrdconta)||';'||
                                                 to_char(rw_crapepr.nrctremp)||';'||
                                                 to_char(nvl(rw_crapepr.valor_solicitado ,0)));
                                                 
    END LOOP; -- Loop de registros 03 - Formalização
    
    -- Monta registros de Liberação de Crédito
    FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_cdhistor => vr_cdhistor_pronampe
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
    
      begin
        -- Calculo de saldo devedor em emprestimos baseado na includes/lelem.i.
        empr0001.pc_calc_saldo_deved_epr_lem(pr_cdcooper   => rw_craplcm.cdcooper --> Cooperativa conectada
                                             ,pr_cdprogra   => 'CREDITO.GerarArquivoPronampe' --> Código do programa corrente
                                             ,pr_cdagenci   => rw_craplcm.cdagenci --> Código da agência
                                             ,pr_nrdcaixa   => 90                  --> Número do caixa
                                             ,pr_cdoperad   => rw_craplcm.cdopeori --> Código do Operador
                                             ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                             ,pr_nrdconta   => rw_craplcm.nrdconta --> Número da conta
                                             ,pr_idseqttl   => 1                   --> Seq titular
                                             ,pr_nrctremp   => rw_craplcm.nrctremp --> Numero ctrato empréstimo
                                             ,pr_idorigem   => 5                   --> Id do módulo de sistema
                                             ,pr_txdjuros   => 0                   --> Taxa de juros aplicada
                                             ,pr_dtcalcul   => rw_crapdat.dtmvtolt --> Data para calculo do empréstimo
                                             ,pr_diapagto   => vr_diapagto         --> Dia para pagamento
                                             ,pr_qtprecal   => vr_qtprecal         --> Quantidade de prestações calculadas até momento
                                             ,pr_vlprepag   => vr_vlprepag         --> Valor acumulado pago no mês
                                             ,pr_vlpreapg   => vr_vlpreapg         --> Valor a pagar
                                             ,pr_vljurmes   => vr_vljurmes         --> Juros no mês corrente
                                             ,pr_vljuracu   => vr_vljuracu         --> Juros acumulados total
                                             ,pr_vlsdeved   => vr_vlsdeved         --> Saldo devedor acumulado
                                             ,pr_dtultpag   => vr_dtultpag         --> Ultimo dia de pagamento das prestações
                                             ,pr_vlmrapar   => vr_vlmrapar         --> Valor do Juros de Mora
                                             ,pr_vlmtapar   => vr_vlmtapar         --> Valor da Multa
                                             ,pr_vliofcpl   => vr_vliofcpl         --> IOF complementar de atraso
                                             ,pr_vlprvenc   => vr_vlprvenc         --> Valor Vencido da parcela
                                             ,pr_vlpraven   => vr_vlpraven         --> Valor a Vencer
                                             ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                             ,pr_des_reto   => vr_des_reto --> Retorno OK / NOK
                                             ,pr_tab_erro   => vr_tab_erro); --> Tabela com possíveis erros
      exception
        when others then 
           vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Erro na chamada de empr0001.pc_calc_saldo_deved_epr_lem ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || 'Contrato '||rw_crapepr.nrctremp||' Erro:'||sqlerrm(sqlcode));           
      end;
      -- Se a rotina retornou erro
      IF vr_des_reto = 'NOK' THEN
         vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Erro na execução de empr0001.pc_calc_saldo_deved_epr_lem ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || 'Contrato '||rw_crapepr.nrctremp||' Erro:'||sqlerrm(sqlcode)); 
         vr_vlsdeved := null;          
      END IF; 
      
      -- Dados de data de vencimento
      OPEN cr_crappep(pr_cdcooper => rw_craplcm.cdcooper
                     ,pr_nrdconta => rw_craplcm.nrdconta
                     ,pr_nrctremp => rw_craplcm.nrctremp);
      FETCH cr_crappep INTO rw_crappep;
      IF cr_crappep%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Associado sem dados de Data de Vencimento: Cooperativa ' || rw_crapepr.cdcooper || ' Conta ' || rw_crapepr.nrdconta || 'Contrato '||rw_crapepr.nrctremp); 
        CLOSE cr_crappep;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crappep;
      END IF; 
      
      -- Monta liberação do crédito
      vr_gerou_detalhe := 1;
      vr_linha      := vr_linha+1; 
      vr_arqremessa := vr_arqremessa||to_clob(chr(10)||
                       f_ret_detalhe_04(to_char(vr_linha)
                                       ,to_char(rw_craplcm.progress_recid)        --20A
                                       ,nvl(to_char(rw_craplcm.dtmvtolt,'rrrrmmdd'),'00000000') --8D                                    
                                       ,to_char((nvl(rw_craplcm.vllanmto,0)*100)) --17M
                                       ,nvl(to_char(rw_crappep.dtvencto,'rrrrmmdd'),'00000000') --8D
                                       ,to_char((nvl(rw_craplcm.vlemprst,0)*100)) --17M
                                       ,to_char((nvl(vr_vlsdeved,0)*100))));      --17M
                                  
      vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 04 Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Id Unico Emprestimo:  ' || rw_craplcm.progress_recid 
                                             || ' Cooperativa: ' || rw_craplcm.cdcooper || ' Conta: '|| rw_craplcm.nrdconta || ' Contrato: '|| rw_craplcm.nrctremp 
                                             || ' Valor Liberado: ' || rw_craplcm.vllanmto ||chr(10)); 
                                                                                        
    END LOOP; -- Loop de registros 04 - Liberação de Crédito
    --vai entrar na rotina apenas para a cooperativa 10
    IF rw_crapcop.cdcooper =10/*nvl(vr_coop_honra,'NAO') = 'SIM'*/ THEN

      IF 1=1 THEN--alterado if pois é para simular o pedido da honra

        -- Loop de registros 06 - Solicitação da Honra da Garantia
        --O pedido de solicitação de honra é feito quando o contrato estiver entre 181 e 320 dias de atraso
        cecred.tela_pronam.pc_consultar_contratos(pr_cdcooper         => rw_crapcop.cdcooper
                                                 ,pr_nrdconta         => 0
                                                 ,pr_nrctremp         => 0
                                                 ,pr_nriniseq         => NULL
                                                 ,pr_nrregist         => NULL                                              
                                                 ,pr_datrini          => 181 
                                                 ,pr_datrfim          => 320
                                                 ,pr_contratospronamp => vr_contratospronamp
                                                 ,pr_cdcritic         => vr_cdcritic             
                                                 ,pr_dscritic         => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;       
                                               
        vr_idx := vr_contratospronamp.first;
        WHILE vr_idx IS NOT NULL LOOP  
          -- Somente contrato que não esteja bloqueado a honra e que não tenha sido solicitado a honra
          IF (vr_contratospronamp(vr_idx).inbloqueiohonra = 0 AND vr_contratospronamp(vr_idx).tpsituacaohonra = 0) THEN
            credito.calcularValorHonraPronampe(pr_cdcooper   => vr_contratospronamp(vr_idx).cdcooper   --> Codigo da cooperativa
                                              ,pr_nrdconta   => vr_contratospronamp(vr_idx).nrdconta   --> Numero da conta do cooperado
                                              ,pr_nrctremp   => vr_contratospronamp(vr_idx).nrctremp   --> Numero do emprestimo
                                              ,pr_dtcontrato => vr_contratospronamp(vr_idx).dtcontrato --> Data da efetivação do contrato
                                              ,pr_dtmvtolt   => rw_crapdat.dtmvtolt                    --> Data para calculo
                                              ,pr_vlempres   => vr_contratospronamp(vr_idx).vlemprst   --> Valor do emprestimo liberado ao cooperado
                                              ,pr_qtpreemp   => vr_contratospronamp(vr_idx).qtpreemp   --> Qtd de prestacoes                                          
                                              ,pr_vldHonra   => vr_vldHonra                            --> Valor a ser Honrado
                                              ,pr_cdcritic   => vr_cdcritic                            --> Codigo da critica
                                              ,pr_dscritic   => vr_dscritic);                          --> Descricao da critica      
            IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;                                        

            vr_gerou_detalhe := 1;
            vr_linha      := vr_linha + 1; 
            vr_arqremessa := vr_arqremessa || to_clob(chr(10) ||
                             f_ret_detalhe_06(to_char(vr_linha)
                                             ,to_char(vr_contratospronamp(vr_idx).progress_recid)                                       
                                             ,nvl(to_char(vr_contratospronamp(vr_idx).dtiniatraso,'rrrrmmdd'),'00000000')                                 
                                             ,nvl(to_char(rw_crapdat.dtmvtolt,'rrrrmmdd'),'00000000')                                 
                                             ,to_char(ROUND(nvl(vr_vldHonra,0),2)*100)));                                           
            vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 06 Linha: ' 
                                                   || f_ret_campo(vr_linha,7,'N') 
                                                   || ' Id Unico Emprestimo:  ' || vr_contratospronamp(vr_idx).progress_recid 
                                                   || '. Cooperativa: ' || vr_contratospronamp(vr_idx).cdcooper 
                                                   || ' Conta: '|| vr_contratospronamp(vr_idx).nrdconta 
                                                   || ' Contrato: '|| vr_contratospronamp(vr_idx).nrctremp 
                                                   || '. Valor do Emprestimo: ' || TO_CHAR(vr_contratospronamp(vr_idx).vlemprst) 
                                                   || '. Valor do Saldo Atualizado: ' || TO_CHAR(vr_vldHonra) || chr(10));        
            -- Atualiza dados da solicitação da honra
            BEGIN
              UPDATE tbcred_pronampe_contrato
                 SET dtsolicitacaohonra    = rw_crapdat.dtmvtolt
                    ,vlsolicitacaohonra    = vr_vldHonra
                    ,tpsituacaohonra = 1 -- Solicitado a Honra
               WHERE cdcooper = vr_contratospronamp(vr_idx).cdcooper
                 AND nrdconta = vr_contratospronamp(vr_idx).nrdconta
                 AND nrcontrato = vr_contratospronamp(vr_idx).nrctremp;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao alterar TBCRED_PRONAMPE_CONTRATO: '|| SQLERRM;
                RAISE vr_exc_erro;
            END;
          END IF;
          vr_idx := vr_contratospronamp.next(vr_idx);      
        END LOOP; -- Loop de registros 06 - Solicitação da Honra da Garantia 
      END IF;
    END IF;
    
  END LOOP; -- Loop de cooperativas
  --
  -- Monta trailer 
  vr_linha      := vr_linha+1;                       
  vr_arqremessa := vr_arqremessa||to_clob(chr(10)||f_ret_trailer(to_char(vr_linha)));

  if vr_gerou_detalhe = 1 then
    -- 
    -- Gerar o arquivo de Remessa em UTF-8(Unix)
    --Formato do nome do arquivo principal BRP.CDT.SSS99999.DAAMMDD.BR.OEAIL.HNNNNNN
    vr_arquivo  := 'BRP.CDT.GFG010.D'||to_char(sysdate,'rrmmdd')||'.BR.OEAIL.H'||to_char(sysdate,'HH24MISS');
    vr_arquivo2 := 'BRP.CDT.GFG010.D'||to_char(sysdate,'rrmmdd')||'.BR.OEAIL.H'||to_char(sysdate,'HH24MISS')||'_UNIX';
    gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqremessa)
                                 ,pr_caminho  => vr_caminho_arquivo_tmp
                                 ,pr_arquivo  => vr_arquivo2
                                 ,pr_flappend => 'N'
                                 ,pr_des_erro => vr_dscritic);
    -- Em caso de erro
    IF vr_dscritic IS NOT NULL THEN
      -- Propagar a critica
      vr_cdcritic := 1044;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' Caminho: '||vr_caminho_arquivo_tmp||vr_arquivo2||', erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    --
    -- Comando UNIX para converter arquivo UTF-8(Unix) para ASCII(DOS)
    vr_dscomando := 'ux2dos < ' ||vr_caminho_arquivo_tmp||vr_arquivo2 || ' | tr -d "\032" ' ||
                    ' > ' || vr_caminho_arquivo_envia|| vr_arquivo || ' 2>/dev/null';
    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;  
    --
    -- Apaga arquivo de remessa em modo UTF-8(Unix)
    gene0001.pc_oscommand_shell('rm '||vr_caminho_arquivo_tmp||vr_arquivo2);  
  end if; --if vr_gerou_detalhe = 1 then
  
  if vr_gerou_detalhe = 1 then
    --
    -- Gerar o arquivo CSV
    vr_arquivo := to_char(sysdate,'rrrrmmdd')||'_'||lpad(to_char(vr_seq_arquivo),4,'0')||'_CSV.CSV';
    gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arq_csv)
                                 ,pr_caminho  => vr_caminho_arquivo_log
                                 ,pr_arquivo  => vr_arquivo
                                 ,pr_flappend => 'N'
                                 ,pr_des_erro => vr_dscritic);
    -- Em caso de erro
    IF vr_dscritic IS NOT NULL THEN
      -- Propagar a critica
      vr_cdcritic := 1044;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                     ' Caminho: '||vr_caminho_arquivo_log||vr_arquivo||', erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
  end if; 
  --
  -- Gerar o arquivo de Erros
  vr_arquivo := to_char(sysdate,'rrrrmmdd')||'_'||lpad(to_char(vr_seq_arquivo),4,'0')||'_ERROS.TXT';
  gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqlog_erro)
                               ,pr_caminho  => vr_caminho_arquivo_log
                               ,pr_arquivo  => vr_arquivo
                               ,pr_flappend => 'N'
                               ,pr_des_erro => vr_dscritic);
  -- Em caso de erro
  IF vr_dscritic IS NOT NULL THEN
    -- Propagar a critica
    vr_cdcritic := 1044;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                   ' Caminho: '||vr_caminho_arquivo_log||vr_arquivo||', erro: '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF;
  --
  --  
  -- Gerar o arquivo de log
  vr_arquivo := to_char(sysdate,'rrrrmmdd')||'_'||lpad(to_char(vr_seq_arquivo),4,'0')||'_LOG.TXT';
  gene0002.pc_clob_para_arquivo(pr_clob     => to_clob(vr_arqlog_geracao)
                               ,pr_caminho  => vr_caminho_arquivo_log
                               ,pr_arquivo  => vr_arquivo
                               ,pr_flappend => 'N'
                               ,pr_des_erro => vr_dscritic);
  -- Em caso de erro
  IF vr_dscritic IS NOT NULL THEN
    -- Propagar a critica
    vr_cdcritic := 1044;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                   ' Caminho: '||vr_caminho_arquivo_log||vr_arquivo||', erro: '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF;    
  ROLLBACK;
EXCEPTION
  WHEN vr_exc_erro THEN
    
    ROLLBACK;
    -- Apenas retornar a variável de saida
    IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
       vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    END IF; 
    RAISE_APPLICATION_ERROR(-20500,vr_cdcritic||'-'||vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20500,sqlcode||'-'||sqlerrm);
end GerarArquivoPronampe;
