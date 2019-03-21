PL/SQL Developer Test script 3.0
212
declare 
  -- Local variables here
  i integer;
  vr_cdcooper        crapepr.cdcooper%TYPE;
  vr_nrdconta        crapepr.nrdconta%TYPE;
  vr_nrctremp        crapepr.nrctremp%TYPE;
  vr_sql             VARCHAR2(2000);
  vr_index_crawepr   VARCHAR2(30);              

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_erro VARCHAR2(4000);
  vr_dsreturn VARCHAR2(4000);
  vr_des_reto VARCHAR2(3);
  vr_index_pos PLS_INTEGER;


  --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
  vr_tab_pgto_parcel  EMPR0001.typ_tab_pgto_parcel;
  --tabela de Memoria dos detalhes de emprestimo
  vr_tab_crawepr EMPR0001.typ_tab_crawepr;
  vr_tab_erro GENE0001.typ_tab_erro;
  vr_tab_calculado    EMPR0001.typ_tab_calculado;

  -- Cursor Genérico de Calendário
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                     pr_nrdconta IN crapepr.nrdconta%TYPE,
                     pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT epr.inliquid
          ,epr.tpemprst
          ,epr.cdlcremp
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdeved
          ,epr.vljuracu
          ,epr.dtultpag
          ,epr.qtprepag
          ,epr.flgpagto
          ,epr.txjuremp
          ,epr.cdcooper
          ,epr.cdagenci
          ,epr.dtmvtolt
          ,epr.vlpreemp
          ,epr.dtdpagto
          ,epr.qttolatr
          ,crawepr.txmensal
          ,crawepr.dtdpagto dtprivencto
          ,epr.vlsprojt
          ,epr.vlemprst
          ,epr.ROWID
          ,crawepr.idfiniof
       FROM crapepr epr
       JOIN crawepr
         ON crawepr.cdcooper = epr.cdcooper
        AND crawepr.nrdconta = epr.nrdconta
        AND crawepr.nrctremp = epr.nrctremp
      WHERE epr.cdcooper = pr_cdcooper
        AND epr.nrdconta = pr_nrdconta
        AND epr.nrctremp = pr_nrctremp
      ORDER BY epr.CDCOOPER, epr.NRDCONTA, epr.NRCTREMP;
  rw_crapepr cr_crapepr%ROWTYPE;  

    --Selecionar Detalhes Emprestimo
    CURSOR cr_crawepr_carga(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN crappep.dtvencto%TYPE
                           ,pr_nrdconta IN crappep.nrdconta%TYPE
                           ) IS
      SELECT crawepr.cdcooper
            ,crawepr.nrdconta
            ,crawepr.nrctremp
            ,crawepr.dtlibera
            ,crawepr.tpemprst
        FROM crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta;
  
BEGIN

  vr_cdcooper := 1;
  vr_nrdconta := 3806324;
  vr_nrctremp := 552419;
 
  -- Leitura do calendário da cooperativa
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;


  --Carregar Tabela crawepr
  FOR rw_crawepr IN cr_crawepr_carga(pr_cdcooper => vr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_nrdconta => vr_nrdconta) LOOP
    --Montar Indice
    vr_index_crawepr := lpad(rw_crawepr.cdcooper, 10, '0') ||
                        lpad(rw_crawepr.nrdconta, 10, '0') ||
                        lpad(rw_crawepr.nrctremp, 10, '0');
    vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
    vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;
  END LOOP;
 



  -- Test statements here
  OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                 ,pr_nrdconta => vr_nrdconta
                 ,pr_nrctremp => vr_nrctremp);
  FETCH cr_crapepr INTO rw_crapepr;

  IF cr_crapepr%NOTFOUND THEN

    -- Fecha Cursor
    CLOSE cr_crapepr;

    vr_cdcritic := 484; -- 484 - Contrato nao encontrado.
    vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
    
    dbms_output.put_line('ERRO: ' || vr_dscritic);
  ELSE
    -- Fecha Cursor
    CLOSE cr_crapepr;
  END IF;
    



  -- Limpar tabelas de Memorias de Pagamentos de parcelas
  vr_tab_pgto_parcel.DELETE;
  vr_tab_calculado.DELETE;

  --Buscar pagamentos Parcela
  EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => rw_crapepr.cdcooper
                                 ,pr_cdagenci        => rw_crapepr.cdagenci
                                 ,pr_nrdcaixa        => 0
                                 ,pr_cdoperad        => '1'
                                 ,pr_nmdatela        => 'CRPS149'
                                 ,pr_idorigem        => 1 -- Ayllos
                                 ,pr_nrdconta        => rw_crapepr.nrdconta
                                 ,pr_idseqttl        => 1 -- Seq titula
                                 ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                 ,pr_flgerlog        => 'S'
                                 ,pr_nrctremp        => rw_crapepr.nrctremp
                                 ,pr_dtmvtoan        => rw_crapdat.dtmvtoan
                                 ,pr_nrparepr        => 0  /* Todas */
                                 ,pr_des_reto        => vr_des_erro -- Retorno OK / NOK
                                 ,pr_tab_erro        => vr_tab_erro -- Tabela com possíves erros
                                 ,pr_tab_pgto_parcel => vr_tab_pgto_parcel -- Tabela com registros de pagamentos
                                 ,pr_tab_calculado   => vr_tab_calculado); -- Tabela com totais calculados
  --Se ocorreu erro
  IF vr_des_erro <> 'OK' THEN
    -- Se tem erro
    IF vr_tab_erro.count > 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      dbms_output.put_line('ERRO: ' || vr_dscritic);

    END IF;
  END IF;

  dbms_output.put_line('QTD EPR: ' || vr_tab_crawepr.count()
                     ||' QTD PGT: ' || vr_tab_pgto_parcel.count()
                     ||' QTD CALC: ' || vr_tab_calculado.count()
                      );

  --Efetuar a Liquidacao do Emprestimo
  empr0001.pc_efetua_liquidacao_empr(pr_cdcooper => rw_crapepr.cdcooper --> Cooperativa conectada
                                    ,pr_cdagenci => 0                   --> Código da agência
                                    ,pr_nrdcaixa => 0                   --> Número do caixa
                                    ,pr_cdoperad => '1'                 --> Código do Operador
                                    ,pr_nmdatela => 'CRPS149'         --> Nome da tela
                                    ,pr_idorigem => 1                   --> Id do módulo de sistema
                                    ,pr_cdpactra => rw_crapepr.cdagenci --> P.A. da transação
                                    ,pr_nrdconta => rw_crapepr.nrdconta --> Número da conta
                                    ,pr_idseqttl => 1                   --> Seq titular
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                    ,pr_flgerlog => 'S'                 --> Indicador S/N para geração de log
                                    ,pr_nrctremp => rw_crapepr.nrctremp --> Número do contrato de empréstimo
                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan --> Data Movimento Anterior
                                    ,pr_ehprcbat => 'S'                 --> Indicador Processo Batch (S/N)
                                    ,pr_tab_pgto_parcel => vr_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                    ,pr_tab_crawepr => vr_tab_crawepr   --> Tabela com Contas e Contratos
                                    ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                    ,pr_des_erro => vr_des_erro         --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);       --> Tabela de Erros

  --Se ocorreu erro
  IF vr_des_erro = 'NOK' THEN
    --Se possui erro na tabela
    IF vr_tab_erro.COUNT > 0 THEN
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
    ELSE
      vr_dscritic := 'Erro na liquidacao';
    END IF;
    --Concatenar conta e contrato
    vr_dscritic := vr_dscritic ||
                   ' Conta: '||gene0002.fn_mask_conta(rw_crapepr.nrdconta)||
                   ' Contrato: '||gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9');
    --Sair do programa
      dbms_output.put_line('ERRO: ' || vr_dscritic);
  END IF;


  COMMIT;

END;
0
0
