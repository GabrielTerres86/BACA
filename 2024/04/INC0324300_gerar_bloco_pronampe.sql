DECLARE

  -- VARIAVEIS --
  -- Variaveis de controle geral
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  
  -- Controle de erros
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  vr_exc_erro EXCEPTION;
  
  vr_cdlcremp_pronampe    craplcr.cdlcremp%TYPE := 2600;
  vr_cdlcremp_pronampe_pf craplcr.cdlcremp%TYPE := 2610;
  vr_caminho_arquivo      crapprm.dsvlrprm%TYPE := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || '/cpd/bacas/INC0324300/';

  vr_caminho_arquivo_envia crapprm.dsvlrprm%TYPE := vr_caminho_arquivo||'envia/';
  vr_caminho_arquivo_tmp   crapprm.dsvlrprm%TYPE := vr_caminho_arquivo||'tmp/';

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
   
  -- Variaveis para busca do saldo devedor
  vr_vljurdia NUMBER; --> Juros diario
  
  vr_vlprincipal_normal NUMBER(25,6);
  vr_vlprincipal_atraso NUMBER(25,6);
  vr_vlencargos_normal  NUMBER(25,6);
  vr_vlencargos_atraso  NUMBER(25,6);
  vr_vlparcela_sjuros   NUMBER(25,6);
  vr_qt_parc_pg         NUMBER;
  vr_qt_parc_npg        NUMBER;
   
  vr_tab_parcelas cecred.empr0011.typ_tab_parcelas;
  vr_tab_calculado cecred.empr0011.typ_tab_calculado;
  vr_sit_honra        NUMBER;

  -- Data de atraso para contornar regra do FGO
  vr_data_inicio_atraso DATE;

  -- CURSORES --
  -- Dados das cooperativas
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
          ,c.cdagectl
          ,c.nmcidade
          ,c.cdufdcop
      FROM cecred.crapcop      c
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
          ,p.inliquid
          ,p.inprejuz
          ,p.vlprejuz
          ,p.vlttmupr
          ,p.vlttjmpr
          ,p.vltiofpr
          ,p.vljraprj
      FROM cecred.crapepr p
          ,cecred.crawepr w
     where p.cdcooper = pr_cdcooper
       and (p.inliquid = 0
        or (p.inliquid = 1
       and p.inprejuz = 1))
       and p.cdlcremp in (pr_cdlcremp, pr_cdlcrepf)
       and p.dtmvtolt < pr_dtmvtolt
       and w.cdcooper = p.cdcooper
       and w.nrdconta = p.nrdconta
       and w.nrctremp = p.nrctremp;  

  --Quantidade de parcelas normal e em atraso
  CURSOR cr_parcela(pr_cdcooper crappep.cdcooper%type
                   ,pr_nrdconta crappep.nrdconta%type
                   ,pr_nrctremp crappep.nrctremp%type) IS
  SELECT COUNT(A) NRPAREPR,COUNT(B) NRPARNPG
    FROM (SELECT CASE WHEN P.DTULTPAG IS NOT NULL THEN --parcelas pagas
                   1
                END AS A,
                CASE WHEN P.DTULTPAG IS NULL THEN --parcelas nao pagas
                   2
                END AS B
           FROM CECRED.CRAPPEP P
          WHERE P.CDCOOPER = PR_CDCOOPER
            AND P.NRDCONTA = PR_NRDCONTA
            AND P.NRCTREMP = PR_NRCTREMP);

  -- Dados de rating de operação, retorna mais atual.
  CURSOR cr_tco(pr_cdcooper crapris.cdcooper%TYPE
               ,pr_nrdconta crapris.nrdconta%TYPE
               ,pr_nrctremp crapris.nrctremp%TYPE) is        
    select   RISC0004.fn_traduz_risco(r.innivori) rating_operacao
    from     cecred.crapris r
    where    r.cdcooper        = pr_cdcooper
    and      r.nrdconta        = pr_nrdconta
    and      r.nrctremp        = pr_nrctremp
    and      rownum            = 1
    order by r.dtrefere          desc;
  
  -- Última remessa gerada  
  CURSOR cr_remessa IS 
    SELECT nvl(MAX(rem.nrremessa), 0) nrremessa
      FROM credito.tbcred_pronampe_remessa rem;

  --cursor que retorna se o contrato foi honrado
  CURSOR cr_sit_honra(pr_cdcooper   tbcred_pronampe_contrato.cdcooper%TYPE
                     ,pr_nrdconta   tbcred_pronampe_contrato.nrdconta%TYPE
                     ,pr_nrcontrato tbcred_pronampe_contrato.nrcontrato%TYPE) IS 
  SELECT 1
    FROM credito.tbcred_pronampe_contrato s                          
   WHERE s.tpsituacaohonra = 2
     AND s.cdcooper = pr_cdcooper
     AND s.nrdconta = pr_nrdconta
     AND s.nrcontrato = pr_nrcontrato;

  -- Data de inicio de atraso da operacao
  CURSOR cr_crapris_atraso (pr_cdcooper crapris.cdcooper%TYPE
                           ,pr_nrdconta crapris.nrdconta%TYPE
                           ,pr_nrctremp crapris.nrctremp%TYPE
                           ,pr_dtrefere crapris.dtrefere%TYPE) IS
  SELECT (r.dtrefere - r.qtdiaatr) + 1 dtiniatraso
    FROM cecred.crapris r
    WHERE r.qtdiaatr > 0
      AND r.dtrefere = pr_dtrefere
      AND r.cdcooper = pr_cdcooper
      AND r.nrdconta = pr_nrdconta
      AND r.nrctremp = pr_nrctremp;

  rw_crapcop cr_crapcop%ROWTYPE;
  rw_tco     cr_tco%ROWTYPE; 
  rw_remessa    cr_remessa%ROWTYPE;
  rw_crapris_atraso cr_crapris_atraso%ROWTYPE;
      
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
    Result := f_ret_campo(pr_linha,7,'N')||   -- Nº sequencial do registro ?0000001?  -- linha 1
              f_ret_campo('1',2,'N')||        -- Código do tipo do registro ?01?
              f_ret_campo('GFGF0010',8,'A')|| -- Nome do Arquivo Remessa ?GFGF0010?
              f_ret_campo('20170331',8,'D')|| -- Versão do leiaute ?20170331?
              f_ret_campo('20',3,'N')||       -- Código do Agente Financeiro, atribuído pelo Administrador. Exemplos: "002"=Banco do Nordeste, "003"=Caixa Econômica Federal
              f_ret_campo('2',3,'N')||        -- Código do Fundo Garantidor ?002?
              f_ret_campo(pr_seqcoop,4,'N')|| -- Nº sequencial da Remessa gerada pelo Agente. Começa em ?0001?
              f_ret_campo(' ',175,'A');       -- 176 Espaços fixo
    return(Result);
  end f_ret_header;
----------------------------------------------------------------------------------------
  function f_ret_detalhe_05(pr_linha in varchar2
                           ,pr_1     in varchar2
                           ,pr_2     in varchar2
                           ,pr_3     in varchar2
                           ,pr_4     in varchar2
                           ,pr_5     in varchar2
                           ,pr_6     in varchar2
                           ,pr_7     in varchar2
                           ,pr_8     in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('5',2,'N')|| -- Código do tipo do registro ?05?
              f_ret_campo(pr_1,20,'A')|| -- PROGRESS_RECID CRAPEPR. CSódigo identificador da operação de crédito no âmbito do Agente
              f_ret_campo(pr_2,8,'D')||  -- Data de apuração dos saldos
              f_ret_campo(pr_3,17,'M')|| -- Valor do saldo devedor de capital (principal) em normalidade
              f_ret_campo(pr_4,17,'M')|| -- Valor do saldo devedor de capital (principal) em atraso
              f_ret_campo(pr_5,17,'M')|| -- Valor do saldo devedor de encargos (juros, correção monetária, acessórios, e todos os demais componentes do saldo) em normalidade.
              f_ret_campo(pr_6,17,'M')|| -- Valor do saldo devedor de encargos (juros, correção monetária, acessórios, e todos os demais componentes do saldo) em atraso.
              f_ret_campo(pr_7,2,'A')|| -- "Código do nível de risco da operação de crédito na data dos saldos informados. De ?AA? até ?H?, conforme resolução BACEN 2.682 de 21.12.1999"
              f_ret_campo(pr_8,8,'D')|| -- Data de início da inadimplência da operação. Preencher para todas as operações em situação Atrasada. Caso não exista saldo em atraso, preencher com zeros (?00000000?).
              f_ret_campo(' ',96,'A'); -- 96 Espaços fixos.
    return(Result);
  end f_ret_detalhe_05;
----------------------------------------------------------------------------------------
  function f_ret_trailer(pr_linha in varchar2) return varchar2 is
    Result varchar2(4000);
  begin
    Result := f_ret_campo(pr_linha,7,'N')|| -- Nº sequencial do registro.
              f_ret_campo('99',2,'N')||     -- Código do tipo do registro ?99?.
              f_ret_campo(pr_linha,7,'N')|| -- Quantidade de registros no arquivo (inclusive header e trailer).
              f_ret_campo(' ',194,'A');     -- 195 Espaços fixos.
    return(Result);
  end f_ret_trailer;
----------------------------------------------------------------------------------------
  procedure geralog(pr_dsexecut in varchar2 default null) is
    vr_nmarqlog varchar2(500);
    vr_desdolog varchar2(4000);
  begin

    vr_nmarqlog := 'GerarArquivoPronampe.log';
    vr_desdolog := to_char(SYSDATE,'DD/MM/RRRR HH24:MI:SS')||' Coop: 3 ' ||' - '||pr_dsexecut;

    btch0001.pc_gera_log_batch(pr_cdcooper => 3,
    pr_ind_tipo_log => 1,
    pr_des_log => vr_desdolog,
    pr_nmarqlog => vr_nmarqlog,
    pr_cdprograma => 'GerarArquivoPronampe',
    pr_dstiplog => 'O');

  end geralog;

BEGIN

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
    
    -- Loop de registros 05 - Saldos 
    FOR rw_epr_saldo IN cr_epr_saldos(pr_cdcooper => rw_crapcop.cdcooper
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_cdlcremp => vr_cdlcremp_pronampe
                                      ,pr_cdlcrepf => vr_cdlcremp_pronampe_pf) LOOP

      vr_sit_honra := 0;        
      OPEN cr_sit_honra(pr_cdcooper   => rw_epr_saldo.cdcooper
                        ,pr_nrdconta   => rw_epr_saldo.nrdconta
                        ,pr_nrcontrato => rw_epr_saldo.nrctremp);
      FETCH cr_sit_honra INTO vr_sit_honra;
      CLOSE cr_sit_honra;
      
      IF NVL(vr_sit_honra,0) = 0 THEN        
      --Zera valores
      vr_vlprincipal_normal := 0;
      vr_vlprincipal_atraso := 0;
      vr_vlencargos_normal  := 0; 
      vr_vlencargos_atraso  := 0; 
      vr_vlparcela_sjuros   := 0;
      
      --Tratamento de operações liquidadas e em prejuizo
      IF rw_epr_saldo.inliquid = 1 AND rw_epr_saldo.inprejuz = 1 THEN
          -- Dados de rating de operação, retorna mais atual.
          OPEN cr_tco(pr_cdcooper => rw_epr_saldo.cdcooper
                    ,pr_nrdconta => rw_epr_saldo.nrdconta
                    ,pr_nrctremp => rw_epr_saldo.nrctremp);
          FETCH cr_tco INTO rw_tco;
          IF cr_tco%NOTFOUND THEN
            -- Montar mensagem de critica
            vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Associado sem dados de Rating de Operação: Cooperativa ' || rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta || ' Contrato '||rw_epr_saldo.nrctremp);
            CLOSE cr_tco;
            rw_tco.rating_operacao := 'A';
          ELSE
            IF rw_tco.rating_operacao = 'HH' THEN
              rw_tco.rating_operacao := 'H';
            END IF;           
            --Fechar o cursor
            CLOSE cr_tco;
          END IF;

          vr_vljurdia := 0;

          --busca os juros diario
          prej0001.pc_calcula_juros_diario(pr_cdcooper => rw_epr_saldo.cdcooper  -- IN
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt    -- IN
                                          ,pr_dtmvtoan => rw_crapdat.dtmvtoan    -- IN
                                          ,pr_nrdconta => rw_epr_saldo.nrdconta  -- IN
                                          ,pr_nrctremp => rw_epr_saldo.nrctremp  -- IN
                                          ,pr_flconlan => FALSE                  -- IN
                                          ,pr_vljurdia => vr_vljurdia            -- OUT
                                          ,pr_cdcritic => vr_cdcritic            -- OUT
                                          ,pr_dscritic => vr_dscritic            -- OUT
                                          );
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Erro ao chamar prej0001.pc_calcula_juros_diario: Cooperativa ' || rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta || 'Contrato '||rw_epr_saldo.nrctremp);
            CONTINUE;
          END IF;

          vr_qt_parc_pg := 0;
          vr_qt_parc_npg := 0;

          OPEN cr_parcela(pr_cdcooper => rw_epr_saldo.cdcooper
                        ,pr_nrdconta => rw_epr_saldo.nrdconta
                        ,pr_nrctremp => rw_epr_saldo.nrctremp);
          FETCH cr_parcela INTO vr_qt_parc_pg,
                                vr_qt_parc_npg;
          CLOSE cr_parcela;

          -- Data de inicio da inadimplencia da operacao
          OPEN cr_crapris_atraso (pr_cdcooper => rw_epr_saldo.cdcooper
                                ,pr_nrdconta => rw_epr_saldo.nrdconta
                                ,pr_nrctremp => rw_epr_saldo.nrctremp
                                ,pr_dtrefere => rw_crapdat.dtmvcentral);
          FETCH cr_crapris_atraso INTO rw_crapris_atraso;

          IF cr_crapris_atraso%NOTFOUND THEN
          rw_crapris_atraso := NULL;
          CLOSE cr_crapris_atraso;
          ELSE
          CLOSE cr_crapris_atraso;
          END IF; 

          vr_vlprincipal_normal := 0;
          vr_vlprincipal_atraso := rw_epr_saldo.vlemprst/(vr_qt_parc_pg+vr_qt_parc_npg);--valor que entrou em prejuizo
          vr_vlprincipal_atraso := ROUND(vr_vlprincipal_atraso*vr_qt_parc_npg,2);
          vr_vlencargos_normal  := 0;
          vr_vlencargos_atraso  := (rw_epr_saldo.vlprejuz+
                                    rw_epr_saldo.vlttmupr+
                                    rw_epr_saldo.vlttjmpr+
                                    rw_epr_saldo.vltiofpr+
                                    vr_vljurdia+
                                    rw_epr_saldo.vljraprj)-vr_vlprincipal_atraso; --valor total com todos os encargos sem o valor da parcela
          
          -- Tratativa para adicionar dois dias a data de inicio de atraso para quando essa data for menor que 01/01/2024
          -- FGO recebeu data incorreta no mes de jan/24 e nao aceita mais a data correta por conta da politica de fraude
          IF rw_crapris_atraso.dtiniatraso < to_date('01/01/2024','dd/mm/yyyy') THEN
          vr_data_inicio_atraso := rw_crapris_atraso.dtiniatraso + 2;
          ELSE
          vr_data_inicio_atraso := rw_crapris_atraso.dtiniatraso;
          END IF;


          vr_linha      := vr_linha+1;
          vr_arqremessa := vr_arqremessa||to_clob(chr(10)||
                            f_ret_detalhe_05(to_char(vr_linha)
                                            ,to_char(rw_epr_saldo.progress_recid)        --20A
                                            ,nvl(to_char(rw_crapdat.dtultdma,'rrrrmmdd'),'00000000') --8D
                                            ,to_char(ROUND(nvl(vr_vlprincipal_normal,0),2)*100) --17M
                                            ,to_char(ROUND(nvl(vr_vlprincipal_atraso,0),2)*100) --17M
                                            ,to_char(ROUND(nvl(vr_vlencargos_normal,0),2)*100)  --17M
                                            ,to_char(ROUND(nvl(vr_vlencargos_atraso,0),2)*100)  --17M
                                            ,rw_tco.rating_operacao                    --2A
                                            ,nvl(to_char(vr_data_inicio_atraso,'rrrrmmdd'),'00000000') --8D
                                            ));

          vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid
                                                || '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: '|| rw_epr_saldo.nrdconta || ' Contrato: '|| rw_epr_saldo.nrctremp
                                                || '. Rating da Operação: ' || TO_CHAR(rw_tco.rating_operacao)
                                                || '. Saldo Principal normal: ' || to_char(ROUND(nvl(vr_vlprincipal_normal,0),2))
                                                || '. Saldo Principal atraso: ' || to_char(ROUND(nvl(vr_vlprincipal_atraso,0),2))
                                                || '. Saldo Encargos normal: ' || to_char(ROUND(nvl(vr_vlencargos_normal,0),2))
                                                || '. Saldo Encargos atraso: ' || to_char(ROUND(nvl(vr_vlencargos_atraso,0),2))
                                                || '. Valor do Emprestimo: ' || TO_CHAR(rw_epr_saldo.vlemprst)  ||chr(10));
      ELSE
      -- Busca os dados de parcela do POS
      cecred.empr0011.pc_busca_pagto_parc_pos(pr_cdcooper      => rw_epr_saldo.cdcooper,
                                              pr_cdprogra      => 'PRON',
                                              pr_flgbatch      => false,
                                              pr_dtmvtolt      => rw_crapdat.dtmvtolt,
                                              pr_dtmvtoan      => rw_crapdat.dtmvtoan,
                                              pr_nrdconta      => rw_epr_saldo.nrdconta,
                                              pr_nrctremp      => rw_epr_saldo.nrctremp,
                                              pr_dtefetiv      => rw_epr_saldo.dtmvtolt,
                                              pr_cdlcremp      => rw_epr_saldo.cdlcremp,
                                              pr_vlemprst      => rw_epr_saldo.vlemprst,
                                              pr_txmensal      => rw_epr_saldo.txmensal,
                                              pr_dtdpagto      => rw_epr_saldo.dtdpagto,
                                              pr_vlsprojt      => rw_epr_saldo.vlsprojt,
                                              pr_qttolatr      => 0,
                                              pr_tab_parcelas  => vr_tab_parcelas,
                                              pr_tab_calculado => vr_tab_calculado,
                                              pr_cdcritic      => vr_cdcritic,
                                              pr_dscritic      => vr_dscritic);
                                              
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Erro ao chamar empr0011.pc_busca_pagto_parc_pos: Cooperativa ' || rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta || 'Contrato '||rw_epr_saldo.nrctremp); 
        CONTINUE;
      END IF;
      
      IF NVL(rw_epr_saldo.qtpreemp,0) > 0 then
        vr_vlparcela_sjuros := NVL(rw_epr_saldo.vlemprst,0) / NVL(rw_epr_saldo.qtpreemp,0);
      ELSE
        vr_vlparcela_sjuros := 0;
      END IF;
      
      IF vr_tab_parcelas.COUNT > 0 THEN                                    
        FOR idx IN vr_tab_parcelas.FIRST..vr_tab_parcelas.LAST LOOP
          IF vr_tab_parcelas(idx).insitpar = 2 THEN -- ATRASO
            vr_vlprincipal_atraso := nvl(vr_vlprincipal_atraso,0) + nvl(vr_vlparcela_sjuros,0);
            IF nvl(vr_tab_parcelas(idx).vlatrpag,0) > nvl(vr_vlparcela_sjuros,0) THEN
              vr_vlencargos_atraso := nvl(vr_vlencargos_atraso,0) + (nvl(vr_tab_parcelas(idx).vlatrpag,0) - nvl(vr_vlparcela_sjuros,0));
            END IF;
          ELSE
            vr_vlprincipal_normal := nvl(vr_vlprincipal_normal,0) + nvl(vr_vlparcela_sjuros,0);
            IF nvl(vr_tab_parcelas(idx).vlatrpag,0) > nvl(vr_vlparcela_sjuros,0) THEN
              vr_vlencargos_normal := nvl(vr_vlencargos_normal,0) + (nvl(vr_tab_parcelas(idx).vlatrpag,0) - nvl(vr_vlparcela_sjuros,0));   
            END IF;
          END IF;   
        END LOOP;
        --
        -- Dados de rating de operação, retorna mais atual.
        OPEN cr_tco(pr_cdcooper => rw_epr_saldo.cdcooper
                    ,pr_nrdconta => rw_epr_saldo.nrdconta
                    ,pr_nrctremp => rw_epr_saldo.nrctremp);
        FETCH cr_tco INTO rw_tco;
        IF cr_tco%NOTFOUND THEN
          -- Montar mensagem de critica
          vr_arqlog_erro := vr_arqlog_erro || to_clob(chr(10) || 'Associado sem dados de Rating de Operação: Cooperativa ' || rw_epr_saldo.cdcooper || ' Conta ' || rw_epr_saldo.nrdconta || ' Contrato '||rw_epr_saldo.nrctremp); 
          CLOSE cr_tco;
          rw_tco.rating_operacao := 'A';
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_tco;
        END IF;           
        --
        --Tratamento para critica de valor de saldo
        --A soma dos saldos de capital em normalidade e capital em atraso deve ser menor ou igual ao valor da operação;
        IF ROUND(nvl(vr_vlprincipal_normal,0),2) + ROUND(nvl(vr_vlprincipal_atraso,0),2) > NVL(rw_epr_saldo.vlemprst,0) THEN
          vr_vlprincipal_normal := vr_vlprincipal_normal - ((ROUND(nvl(vr_vlprincipal_normal,0),2) + ROUND(nvl(vr_vlprincipal_atraso,0),2)) - NVL(rw_epr_saldo.vlemprst,0) );    
        END IF;
        
        -- Data de inicio da inadimplencia da operacao
        OPEN cr_crapris_atraso (pr_cdcooper => rw_epr_saldo.cdcooper
                              ,pr_nrdconta => rw_epr_saldo.nrdconta
                              ,pr_nrctremp => rw_epr_saldo.nrctremp
                              ,pr_dtrefere => rw_crapdat.dtmvcentral);
        FETCH cr_crapris_atraso INTO rw_crapris_atraso;

        IF cr_crapris_atraso%NOTFOUND THEN
          rw_crapris_atraso := NULL;
          CLOSE cr_crapris_atraso;
          ELSE
          CLOSE cr_crapris_atraso;
          END IF;

        -- Tratativa para adicionar dois dias a data de inicio de atraso para quando essa data for menor que 01/01/2024
        -- FGO recebeu data incorreta no mes de jan/24 e nao aceita mais a data correta por conta da politica de fraude
        IF rw_crapris_atraso.dtiniatraso < to_date('01/01/2024','dd/mm/yyyy') THEN
          vr_data_inicio_atraso := rw_crapris_atraso.dtiniatraso + 2;
        ELSE
          vr_data_inicio_atraso := rw_crapris_atraso.dtiniatraso;
        END IF; 
        

        vr_linha      := vr_linha+1; 
        vr_arqremessa := vr_arqremessa||to_clob(chr(10)||
                          f_ret_detalhe_05(to_char(vr_linha)
                                          ,to_char(rw_epr_saldo.progress_recid)        --20A
                                          ,nvl(to_char(rw_crapdat.dtultdma,'rrrrmmdd'),'00000000') --8D                                  
                                          ,to_char(ROUND(nvl(vr_vlprincipal_normal,0),2)*100) --17M
                                          ,to_char(ROUND(nvl(vr_vlprincipal_atraso,0),2)*100) --17M
                                          ,to_char(ROUND(nvl(vr_vlencargos_normal,0),2)*100)  --17M
                                          ,to_char(ROUND(nvl(vr_vlencargos_atraso,0),2)*100)  --17M
                                          ,rw_tco.rating_operacao                    --2A
                                          ,nvl(to_char(vr_data_inicio_atraso,'rrrrmmdd'),'00000000') --8D
                                          ));
                                    
        vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid 
                                                || '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: '|| rw_epr_saldo.nrdconta || ' Contrato: '|| rw_epr_saldo.nrctremp 
                                                || '. Rating da Operação: ' || TO_CHAR(rw_tco.rating_operacao) 
                                                || '. Saldo Principal normal: ' || to_char(ROUND(nvl(vr_vlprincipal_normal,0),2))
                                                || '. Saldo Principal atraso: ' || to_char(ROUND(nvl(vr_vlprincipal_atraso,0),2)) 
                                                || '. Saldo Encargos normal: ' || to_char(ROUND(nvl(vr_vlencargos_normal,0),2))   
                                                || '. Saldo Encargos atraso: ' || to_char(ROUND(nvl(vr_vlencargos_atraso,0),2))
                                                || '. Valor do Emprestimo: ' || TO_CHAR(rw_epr_saldo.vlemprst)  ||chr(10));
        END IF;
      END IF;
      ELSE --valida se operacao ja foi honrada, caso tenha sido, grava log com a informacao                                                 
        vr_arqlog_geracao := vr_arqlog_geracao || to_clob('REG 05 Linha: ' || f_ret_campo(vr_linha,7,'N') || ' Id Unico Emprestimo:  ' || rw_epr_saldo.progress_recid
                                                || '. Cooperativa: ' || rw_epr_saldo.cdcooper || ' Conta: '|| rw_epr_saldo.nrdconta || ' Contrato: '|| rw_epr_saldo.nrctremp
                                                || '. Motivo: Saldo nao enviado em funcao da operacao ja ter sido honrada.' ||chr(10));
      END IF;
        -- Atualiza o valor de saldo do capital para o contrato
        BEGIN
          UPDATE credito.tbcred_pronampe_contrato
              SET tbcred_pronampe_contrato.vlsaldocontrato = ROUND(nvl(vr_vlprincipal_normal, 0) + nvl(vr_vlprincipal_atraso,0),2)
            WHERE cdcooper = rw_epr_saldo.cdcooper
              AND nrdconta = rw_epr_saldo.nrdconta
              AND nrcontrato = rw_epr_saldo.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao alterar TBCRED_PRONAMPE_CONTRATO: '|| SQLERRM;
            RAISE vr_exc_erro;
        END;

    END LOOP; -- Loop de registros 05 - Saldos
  END LOOP; -- Loop de cooperativa

  -- Monta trailer 
  vr_linha      := vr_linha+1;                       
  vr_arqremessa := vr_arqremessa||to_clob(chr(10)||f_ret_trailer(to_char(vr_linha)));

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

    COMMIT;

    geraLog(pr_dsexecut => 'Operação realizada com sucesso.');

EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Apenas retornar a variável de saida
      IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      --Grava Log
      geraLog(pr_dsexecut => vr_cdcritic||' - '||vr_dscritic);
      
    WHEN OTHERS THEN
      ROLLBACK;
      --Grava Log  
      geraLog(pr_dsexecut => sqlcode||' - '||sqlerrm);         
END;