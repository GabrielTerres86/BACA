DECLARE

  vr_cdcooper INTEGER := 3;
  vr_dtrefere DATE := to_date('30/09/2023', 'dd/mm/rrrr');
  vr_cdproduto INTEGER := 1;
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(2000);
  vr_exc_erro EXCEPTION;
  
  PROCEDURE criarCentralRisco(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                             ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE 
                             ,pr_cdproduto IN INTEGER DEFAULT 0
                             ,pr_cdcritic  OUT cecred.crapcri.cdcritic%TYPE 
                             ,pr_dscritic  OUT VARCHAR2) IS

  vr_cdprograma VARCHAR2(25) := 'criarCentralRisco';
  vr_dscomple   VARCHAR2(2000);

  vr_exc_erro EXCEPTION;
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(4000);

  vr_inddocto NUMBER;
  vr_cdorigem NUMBER;
  vr_cdmodali NUMBER;
  vr_countret INTEGER;

  CURSOR cr_crapage(pr_cdcooper IN cecred.crapage.cdcooper%TYPE) IS
    SELECT a.cdagenci
      FROM cecred.crapage a
     WHERE a.cdcooper = pr_cdcooper
     ORDER BY a.cdagenci;

  CURSOR cr_modalidades IS
    SELECT o.cdmodali_aimaro
          ,o.cdmodali_bacen
      FROM gestaoderisco.tbrisco_modalidade_operacao_bacen o;
  rw_modalidades cr_modalidades%ROWTYPE;
  TYPE typ_modalidades IS TABLE OF cr_modalidades%ROWTYPE INDEX BY VARCHAR2(5);
  vr_tab_modalidades typ_modalidades;
  vr_idx_modalidades VARCHAR2(5);

  CURSOR cr_retorno(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                   ,pr_cdagenci  IN cecred.crapage.cdagenci%TYPE
                   ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE
                   ,pr_cdproduto IN INTEGER) IS
    SELECT r.dtreferencia
          ,r.cdcooper
          ,r.nrconta
          ,r.nrcontrato
          ,r.cdmodalidade
          ,r.vldivida
          ,r.tppessoa
          ,r.dtdata_risco
          ,r.nrcpfcgc
          ,r.nrnivel_risco_final
          ,r.nrgrupo_economico
          ,r.nracordo
          ,r.cdproduto
          ,JSON_VALUE(r.dsinformacoes_geral_riscos, '$.OPE') risco_operacao
      FROM gestaoderisco.htrisco_central_retorno r
          ,cecred.crapass                        a
     WHERE r.cdcooper = a.cdcooper
       AND r.nrconta = a.nrdconta
       AND r.cdcooper = pr_cdcooper
       AND a.cdagenci = pr_cdagenci
       AND r.dtreferencia = pr_dtrefere
       AND r.cdproduto = 1
       AND r.cdmodalidade = 1401;
  TYPE typ_retorno IS TABLE OF cr_retorno%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_retorno typ_retorno;

  CURSOR cr_vencimento(pr_cdcooper  IN cecred.crapcop.cdcooper%TYPE
                      ,pr_cdagenci  IN cecred.crapage.cdagenci%TYPE
                      ,pr_dtrefere  IN cecred.crapdat.dtmvtolt%TYPE
                      ,pr_cdproduto IN INTEGER) IS
    SELECT c.cdcooper
          ,o.nrdconta
          ,o.nrcontrato
          ,o.qtdiaatr
          ,o.dtinictr
          ,o.qtdparcelas
          ,e.dtprxpar
          ,e.vlprxpar
          ,v.vlvalven
          ,v.cdvencto
          ,CASE
             WHEN c.tpproduto = 1 THEN
              CASE
                WHEN v.cdvencto IN (20, 40) THEN
                 1902
                ELSE
                 201
              END
             WHEN c.tpproduto = 2 THEN
              CASE
                WHEN o.tpcontrato = 1 THEN
                 1909
                ELSE
                 302
              END
             WHEN c.tpproduto = 3 THEN
              CASE
                WHEN o.tpcontrato = 1 THEN
                 1909
                ELSE
                 301
              END
             WHEN c.tpproduto = 10 THEN
              101
             WHEN c.tpproduto = 90 THEN
              CASE
                WHEN e.cdmodali > 400 THEN
                 499
                ELSE
                 299
              END
             WHEN c.tpproduto = 95 THEN
              499
             WHEN c.tpproduto = 96 THEN
              e.cdmodali
             WHEN c.tpproduto = 97 THEN
              1513
             WHEN c.tpproduto = 98 THEN
              1513
           END cdmodali
      FROM gestaoderisco.tbrisco_operacao_vencimento v
          ,gestaoderisco.tbrisco_carga_operacao o
          ,gestaoderisco.tbrisco_central_carga c
          ,cecred.crapass a
          ,(SELECT em.idcarga_operacao
                  ,b.cdmodali_aimaro cdmodali
                  ,em.dtprxpar
                  ,em.vlprxpar
              FROM gestaoderisco.tbrisco_operacao_emprestimo       em
                  ,gestaoderisco.tbrisco_modalidade_operacao_bacen b
             WHERE em.cdmodali = b.cdmodali_bacen) e
     WHERE o.idcentral_carga = c.idcentral_carga
       AND c.cdcooper = a.cdcooper
       AND o.nrdconta = a.nrdconta
       AND c.cdcooper = pr_cdcooper
       AND a.cdagenci = pr_cdagenci
       AND c.dtrefere = pr_dtrefere
       AND c.cdstatus = 7
       AND c.tpproduto = 1
       AND o.dtdsaida IS NULL
       AND o.idcarga_operacao = e.idcarga_operacao(+)
       AND o.idcarga_operacao = v.idcarga_operacao(+);
  TYPE typ_vencimento_bulk IS TABLE OF cr_vencimento%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_vencimento_bulk typ_vencimento_bulk;

  TYPE typ_crapris IS TABLE OF cecred.crapris%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapris typ_crapris;
  vr_idx_crapris PLS_INTEGER;

  TYPE typ_crapvri IS TABLE OF crapvri%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapvri typ_crapvri;
  vr_idx_crapvri PLS_INTEGER;

  TYPE typ_reg_vencimento_operacao IS RECORD(
    vlvalven gestaoderisco.tbrisco_operacao_vencimento.vlvalven%TYPE,
    cdvencto gestaoderisco.tbrisco_operacao_vencimento.cdvencto%TYPE);

  TYPE typ_tab_vencimento_operacao IS TABLE OF typ_reg_vencimento_operacao INDEX BY PLS_INTEGER;

  TYPE typ_reg_ctb_vencimento_operacao IS RECORD(
    tb_vencimento typ_tab_vencimento_operacao);
  TYPE typ_tab_cta_vencimento_operacao IS TABLE OF typ_reg_ctb_vencimento_operacao INDEX BY VARCHAR2(30); 
  vr_tab_vencimento_operacao typ_tab_cta_vencimento_operacao; 
  vr_idx_vencimento          VARCHAR2(30);
  vr_idx_vencto              PLS_INTEGER;

  TYPE typ_reg_operacao IS RECORD(
    qtdiaatr gestaoderisco.tbrisco_carga_operacao.qtdiaatr%TYPE,
    dtinictr gestaoderisco.tbrisco_carga_operacao.dtinictr%TYPE,
    qtparcel gestaoderisco.tbrisco_carga_operacao.qtdparcelas%TYPE,
    dtprxpar gestaoderisco.tbrisco_operacao_emprestimo.dtprxpar%TYPE,
    vlprxpar gestaoderisco.tbrisco_operacao_emprestimo.vlprxpar%TYPE);
  TYPE typ_tab_operacao IS TABLE OF typ_reg_operacao INDEX BY VARCHAR2(30); 
  vr_tab_operacao typ_tab_operacao;
  vr_idx_operacao VARCHAR2(30);
BEGIN

  vr_tab_modalidades.delete;
  FOR rw_modalidades IN cr_modalidades LOOP
    vr_idx_modalidades := lpad(rw_modalidades.cdmodali_bacen, 5, 0);
    vr_tab_modalidades(vr_idx_modalidades).cdmodali_aimaro := rw_modalidades.cdmodali_aimaro;
    vr_tab_modalidades(vr_idx_modalidades).cdmodali_bacen := rw_modalidades.cdmodali_bacen;
  END LOOP;

  FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper) LOOP
    vr_tab_operacao.delete;
    vr_tab_vencimento_bulk.delete;
    vr_tab_vencimento_operacao.delete;
    vr_tab_retorno.delete;  
  
    OPEN cr_vencimento(pr_cdcooper  => pr_cdcooper,
                       pr_cdagenci  => rw_crapage.cdagenci,
                       pr_dtrefere  => pr_dtrefere,
                       pr_cdproduto => pr_cdproduto);
    LOOP
      FETCH cr_vencimento BULK COLLECT
        INTO vr_tab_vencimento_bulk LIMIT 10000;
      EXIT WHEN vr_tab_vencimento_bulk.count = 0;
    
      FOR idx IN vr_tab_vencimento_bulk.first .. vr_tab_vencimento_bulk.last LOOP
        vr_idx_vencimento := lpad(vr_tab_vencimento_bulk(idx).cdcooper, 5, 0) ||
                             lpad(vr_tab_vencimento_bulk(idx).nrdconta, 10, 0) ||
                             lpad(vr_tab_vencimento_bulk(idx).nrcontrato, 10, 0) ||
                             lpad(vr_tab_vencimento_bulk(idx).cdmodali, 5, 0);
      
        IF vr_tab_vencimento_operacao.exists(vr_idx_vencimento) THEN
          vr_idx_vencto := vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento.count + 1;
        ELSE
          vr_idx_vencto := 1;
        END IF;
        vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento(vr_idx_vencto).cdvencto := vr_tab_vencimento_bulk(idx).cdvencto;
        vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento(vr_idx_vencto).vlvalven := vr_tab_vencimento_bulk(idx).vlvalven;
      
        vr_idx_operacao := lpad(vr_tab_vencimento_bulk(idx).cdcooper, 5, 0) ||
                           lpad(vr_tab_vencimento_bulk(idx).nrdconta, 10, 0) ||
                           lpad(vr_tab_vencimento_bulk(idx).nrcontrato, 10, 0) ||
                           lpad(vr_tab_vencimento_bulk(idx).cdmodali, 5, 0);
        IF NOT vr_tab_operacao.exists(vr_idx_operacao) THEN
          vr_tab_operacao(vr_idx_operacao).qtdiaatr := vr_tab_vencimento_bulk(idx).qtdiaatr;
          vr_tab_operacao(vr_idx_operacao).dtinictr := vr_tab_vencimento_bulk(idx).dtinictr;
          vr_tab_operacao(vr_idx_operacao).qtparcel := vr_tab_vencimento_bulk(idx).qtdparcelas;
          vr_tab_operacao(vr_idx_operacao).dtprxpar := vr_tab_vencimento_bulk(idx).dtprxpar;
          vr_tab_operacao(vr_idx_operacao).vlprxpar := vr_tab_vencimento_bulk(idx).vlprxpar;
        END IF;
      END LOOP;
    END LOOP;
    CLOSE cr_vencimento;
  
    vr_countret := 0;
  
    OPEN cr_retorno(pr_cdcooper  => pr_cdcooper,
                    pr_cdagenci  => rw_crapage.cdagenci,
                    pr_dtrefere  => pr_dtrefere,
                    pr_cdproduto => pr_cdproduto);
    LOOP
      FETCH cr_retorno BULK COLLECT
        INTO vr_tab_retorno LIMIT 10000;
      EXIT WHEN vr_tab_retorno.count = 0;
      
      vr_tab_crapris.delete;
      vr_tab_crapvri.delete;
      
      vr_countret := nvl(vr_countret, 0) + 1;
      vr_dscomple := 'RETORNO PASSO 03 - Iteracao: ' || vr_countret || ' tab_retorno.count: ' || vr_tab_retorno.count;
    
      FOR idx IN vr_tab_retorno.first .. vr_tab_retorno.last LOOP

        IF NOT vr_tab_modalidades.exists(lpad(vr_tab_retorno(idx).cdmodalidade, 5, 0)) THEN
          CONTINUE;
        END IF;

        vr_cdmodali := vr_tab_modalidades(lpad(vr_tab_retorno(idx).cdmodalidade, 5, 0)).cdmodali_aimaro;
        IF pr_cdcooper = 3 THEN
          IF vr_tab_retorno(idx).cdmodalidade = 1401 AND vr_tab_retorno(idx).cdproduto = 1 THEN
            vr_cdmodali := 201;
          END IF;
        END IF;
      
        vr_idx_operacao := lpad(vr_tab_retorno(idx).cdcooper, 5, 0) ||
                           lpad(vr_tab_retorno(idx).nrconta, 10, 0) ||
                           lpad(vr_tab_retorno(idx).nrcontrato, 10, 0) || 
                           lpad(vr_cdmodali, 5, 0);
        IF NOT vr_tab_operacao.exists(vr_idx_operacao) THEN
          CONTINUE;
        END IF;
      
        vr_inddocto := 1;
        vr_cdorigem := 3;
      
        vr_idx_crapris := vr_tab_crapris.count() + 1;
      
        vr_tab_crapris(vr_idx_crapris).dtrefere := vr_tab_retorno(idx).dtreferencia;
        vr_tab_crapris(vr_idx_crapris).cdcooper := vr_tab_retorno(idx).cdcooper;
        vr_tab_crapris(vr_idx_crapris).nrdconta := vr_tab_retorno(idx).nrconta;
        vr_tab_crapris(vr_idx_crapris).nrctremp := vr_tab_retorno(idx).nrcontrato;

        IF vr_cdmodali = 1513 AND vr_tab_retorno(idx).cdproduto = 1 THEN
          vr_tab_crapris(vr_idx_crapris).cdmodali := 1902;
        ELSE
          vr_tab_crapris(vr_idx_crapris).cdmodali := vr_cdmodali;
        END IF;
        vr_tab_crapris(vr_idx_crapris).vldivida := vr_tab_retorno(idx).vldivida;
        vr_tab_crapris(vr_idx_crapris).inpessoa := vr_tab_retorno(idx).tppessoa;
        vr_tab_crapris(vr_idx_crapris).dtdrisco := vr_tab_retorno(idx).dtdata_risco;
        vr_tab_crapris(vr_idx_crapris).nrcpfcgc := vr_tab_retorno(idx).nrcpfcgc;
        vr_tab_crapris(vr_idx_crapris).innivris := vr_tab_retorno(idx).nrnivel_risco_final;
        vr_tab_crapris(vr_idx_crapris).nrdgrupo := vr_tab_retorno(idx).nrgrupo_economico;
        vr_tab_crapris(vr_idx_crapris).nracordo := vr_tab_retorno(idx).nracordo;
        vr_tab_crapris(vr_idx_crapris).innivori := RISC0004.fn_traduz_nivel_risco(TRIM(vr_tab_retorno(idx).risco_operacao));
        vr_tab_crapris(vr_idx_crapris).nrseqctr := vr_tab_retorno(idx).cdproduto;
      
        IF vr_cdmodali IN (1902) THEN
          vr_inddocto := 3;
          vr_cdorigem := 1;
        ELSIF vr_cdmodali IN (1513) THEN
          IF vr_tab_retorno(idx).cdproduto = 97 THEN
            vr_inddocto := 4;
            vr_cdorigem := 6;
          ELSIF vr_tab_retorno(idx).cdproduto = 98 THEN
            vr_inddocto := 5;
            vr_cdorigem := 7;
          ELSIF vr_tab_retorno(idx).cdproduto = 1 THEN 
            vr_inddocto := 3;
            vr_cdorigem := 1;
          END IF;
        ELSIF vr_cdmodali = 201 THEN
          vr_cdorigem := 1;
        ELSIF vr_cdmodali = 1909 THEN
          vr_inddocto := 3;
        ELSIF vr_cdmodali = 101 THEN
          vr_cdorigem := 1;
        END IF;
      
        IF vr_tab_retorno(idx).cdproduto IN (2, 92) THEN
          vr_cdorigem := 2;
        ELSIF vr_tab_retorno(idx).cdproduto IN (3, 91) THEN
          vr_cdorigem := 5;
        END IF;
      
        vr_tab_crapris(vr_idx_crapris).inddocto := vr_inddocto;
        vr_tab_crapris(vr_idx_crapris).cdorigem := vr_cdorigem;
      
        vr_idx_operacao := lpad(vr_tab_retorno(idx).cdcooper, 5, 0) ||
                           lpad(vr_tab_retorno(idx).nrconta, 10, 0) ||
                           lpad(vr_tab_retorno(idx).nrcontrato, 10, 0) || 
                           lpad(vr_cdmodali, 5, 0);
        IF vr_tab_operacao.exists(vr_idx_operacao) THEN
          vr_tab_crapris(vr_idx_crapris).dtinictr := vr_tab_operacao(vr_idx_operacao).dtinictr;
          vr_tab_crapris(vr_idx_crapris).qtdiaatr := vr_tab_operacao(vr_idx_operacao).qtdiaatr;
          vr_tab_crapris(vr_idx_crapris).dtprxpar := vr_tab_operacao(vr_idx_operacao).dtprxpar;
          vr_tab_crapris(vr_idx_crapris).vlprxpar := vr_tab_operacao(vr_idx_operacao).vlprxpar;
          vr_tab_crapris(vr_idx_crapris).qtparcel := vr_tab_operacao(vr_idx_operacao).qtparcel;
        END IF;
      
        vr_idx_vencimento := lpad(vr_tab_retorno(idx).cdcooper, 5, 0) ||
                             lpad(vr_tab_retorno(idx).nrconta, 10, 0) ||
                             lpad(vr_tab_retorno(idx).nrcontrato, 10, 0) || 
                             lpad(vr_cdmodali, 5, 0);
        IF vr_tab_vencimento_operacao.exists(vr_idx_vencimento) THEN
          IF vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento.count > 0 THEN
            FOR i IN 1 .. vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento.count LOOP
              vr_idx_crapvri := vr_tab_crapvri.count + 1;
              vr_tab_crapvri(vr_idx_crapvri).cdcooper := vr_tab_retorno(idx).cdcooper;
              vr_tab_crapvri(vr_idx_crapvri).nrdconta := vr_tab_retorno(idx).nrconta;
              vr_tab_crapvri(vr_idx_crapvri).nrctremp := vr_tab_retorno(idx).nrcontrato;
              vr_tab_crapvri(vr_idx_crapvri).dtrefere := vr_tab_retorno(idx).dtreferencia;
              vr_tab_crapvri(vr_idx_crapvri).cdvencto := vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento(i).cdvencto;
              vr_tab_crapvri(vr_idx_crapvri).vldivida := vr_tab_vencimento_operacao(vr_idx_vencimento).tb_vencimento(i).vlvalven;

              IF vr_cdmodali = 1513 AND vr_tab_retorno(idx).cdproduto = 1 THEN
                vr_tab_crapvri(vr_idx_crapvri).cdmodali := 1902;
              ELSE
                vr_tab_crapvri(vr_idx_crapvri).cdmodali := vr_cdmodali;
              END IF;
              vr_tab_crapvri(vr_idx_crapvri).nrseqctr := vr_tab_retorno(idx).cdproduto;
            END LOOP;
          END IF;
        END IF;
      END LOOP;
    
      vr_dscomple := 'RETORNO PASSO 04 - Inicio forall ris - Iteracao: ' || vr_countret || ' tab_retorno.count: ' || vr_tab_retorno.count;
    
      BEGIN
        FORALL idx IN INDICES OF vr_tab_crapris SAVE EXCEPTIONS
          INSERT INTO GESTAODERISCO.tbrisco_crapris
            (dtrefere
            ,cdcooper
            ,nrdconta
            ,nrctremp
            ,cdmodali
            ,inddocto
            ,cdorigem
            ,vldivida
            ,inpessoa
            ,dtdrisco
            ,nrcpfcgc
            ,innivris
            ,nrdgrupo
            ,nracordo
            ,innivori
            ,dtinictr
            ,qtdiaatr
            ,dtprxpar
            ,vlprxpar
            ,qtparcel
            ,nrseqctr)
          VALUES
            (vr_tab_crapris(idx).dtrefere
            ,vr_tab_crapris(idx).cdcooper
            ,vr_tab_crapris(idx).nrdconta
            ,vr_tab_crapris(idx).nrctremp
            ,vr_tab_crapris(idx).cdmodali
            ,vr_tab_crapris(idx).inddocto
            ,vr_tab_crapris(idx).cdorigem
            ,nvl(vr_tab_crapris(idx).vldivida, 0)
            ,vr_tab_crapris(idx).inpessoa
            ,vr_tab_crapris(idx).dtdrisco
            ,vr_tab_crapris(idx).nrcpfcgc
            ,vr_tab_crapris(idx).innivris
            ,vr_tab_crapris(idx).nrdgrupo
            ,vr_tab_crapris(idx).nracordo
            ,vr_tab_crapris(idx).innivori
            ,vr_tab_crapris(idx).dtinictr
            ,vr_tab_crapris(idx).qtdiaatr
            ,vr_tab_crapris(idx).dtprxpar
            ,nvl(vr_tab_crapris(idx).vlprxpar, 0)
            ,vr_tab_crapris(idx).qtparcel
            ,vr_tab_crapris(idx).nrseqctr);
      EXCEPTION
        WHEN OTHERS THEN
          FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            sistema.gravarLogPrograma(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 3,
                                      pr_des_log      => 'vr_tab_crapris - Iteracao: ' ||
                                                         vr_countret || ' cdcooper: ' || vr_tab_crapris(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                         ' nrdconta: ' || vr_tab_crapris(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                         ' dtrefere: ' || vr_tab_crapris(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).dtrefere ||
                                                         ' innivris: ' || vr_tab_crapris(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).innivris ||
                                                         ' nrctremp: ' || vr_tab_crapris(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                         ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                      pr_cdprograma   => vr_cdprograma,
                                      pr_nmarqlog     => 'finaliza_central.log',
                                      pr_tpexecucao   => 1);
          END LOOP;
        
          vr_dscritic := 'Erro ao inserir na tabela crapris. ' || ' - ' || SQL%BULK_EXCEPTIONS(1).ERROR_INDEX || ' ' ||
                         SQLERRM(- (SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_erro;
      END;
    
      vr_dscomple := 'RETORNO PASSO 05 - Inicio forall vri - Iteracao: ' || vr_countret || ' tab_retorno.count: ' || vr_tab_retorno.count;
    
      BEGIN
        FORALL idx IN 1 .. vr_tab_crapvri.count SAVE EXCEPTIONS
          INSERT INTO GESTAODERISCO.tbrisco_crapvri
            (cdcooper
            ,nrdconta
            ,nrctremp
            ,dtrefere
            ,cdvencto
            ,vldivida
            ,cdmodali
            ,nrseqctr)
          VALUES
            (vr_tab_crapvri(idx).cdcooper
            ,vr_tab_crapvri(idx).nrdconta
            ,vr_tab_crapvri(idx).nrctremp
            ,vr_tab_crapvri(idx).dtrefere
            ,vr_tab_crapvri(idx).cdvencto
            ,nvl(vr_tab_crapvri(idx).vldivida, 0)
            ,vr_tab_crapvri(idx).cdmodali
            ,vr_tab_crapvri(idx).nrseqctr);
      EXCEPTION
        WHEN OTHERS THEN
          FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
            sistema.gravarLogPrograma(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 3,
                                      pr_des_log      => 'vr_tab_crapvri - Iteracao: ' ||
                                                         vr_countret || ' cdcooper: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdcooper ||
                                                         ' nrdconta: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrdconta ||
                                                         ' dtrefere: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).dtrefere ||
                                                         ' nrseqctr: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrseqctr ||
                                                         ' cdmodali: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdmodali ||
                                                         ' nrctremp: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).nrctremp ||
                                                         ' cdvencto: ' || vr_tab_crapvri(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).cdvencto ||
                                                         ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE),
                                      pr_nmarqlog     => 'finaliza_central.log',
                                      pr_cdprograma   => vr_cdprograma,
                                      pr_tpexecucao   => 1);
          END LOOP;
        
          vr_dscritic := 'Erro ao inserir na tabela crapvri: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          RAISE vr_exc_erro;
      END;

      COMMIT;           
    
    END LOOP;
    CLOSE cr_retorno;
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN

    IF nvl(vr_cdcritic, 0) > 0 AND TRIM(vr_dscritic) IS NULL THEN

      vr_dscritic := obterCritica(vr_cdcritic);
    END IF;

    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' ||
                   vr_dscomple || ' Data Referencia: ' || pr_dtrefere;
  
    ROLLBACK;
  
    sistema.gravarLogPrograma(pr_cdcooper     => pr_cdcooper,
                              pr_ind_tipo_log => 3,
                              pr_des_log      => vr_cdprograma || ' --> PROGRAMA COM ERRO' || pr_dscritic,
                              pr_nmarqlog     => 'finaliza_central.log',
                              pr_cdprograma   => vr_cdprograma,
                              pr_tpexecucao   => 1);
  WHEN OTHERS THEN
    ROLLBACK;
  
    pr_dscritic := 'Erro na : ' || vr_cdprograma || ': ' || SQLERRM || ' - ' ||
                   DBMS_UTILITY.FORMAT_ERROR_BACKTRACE || ' - ' || vr_dscomple ||
                   ' Data Referencia: ' || pr_dtrefere;
  
    sistema.excecaoInterna(pr_cdcooper => pr_cdcooper, pr_compleme => vr_dscomple || pr_dscritic);
  
    sistema.gravarLogPrograma(pr_cdcooper     => pr_cdcooper,
                              pr_ind_tipo_log => 3,
                              pr_des_log      => vr_cdprograma || ' --> PROGRAMA COM ERRO' || pr_dscritic,
                              pr_nmarqlog     => 'finaliza_central.log',
                              pr_cdprograma   => vr_cdprograma,
                              pr_tpexecucao   => 1);
END criarCentralRisco;

BEGIN

  criarCentralRisco(pr_cdcooper  => vr_cdcooper 
                   ,pr_dtrefere  => vr_dtrefere 
                   ,pr_cdproduto => vr_cdproduto
                   ,pr_cdcritic  => vr_cdcritic 
                   ,pr_dscritic  => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;

  COMMIT;
  
EXCEPTION 
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20000, vr_dscritic);
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM);
END;
