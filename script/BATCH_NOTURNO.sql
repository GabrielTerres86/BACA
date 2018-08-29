DECLARE
  vr_cdcritic   crapcri.cdcritic%TYPE;
  vr_dscritic   crapcri.dscritic%TYPE;  
  vr_blnfound   BOOLEAN;
  rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE;
  
  vr_dtmvtolt     DATE;
  vr_cdcooper     NUMBER;
  
  vr_dtproxim     DATE;
  vr_dtanteri     DATE;
  vr_dtultdia     DATE;
  vr_dtultdma     DATE;
  vr_erro         CHAR;
  
  idx INTEGER;
  
  vr_sair         BOOLEAN; 
  
  result VARCHAR2(400);
  
  vr_nmtelant VARCHAR2(400);
  vr_nmdatela VARCHAR2(400);
  
  vr_flgresta PLS_INTEGER;
  vr_stprogra PLS_INTEGER;
  vr_infimsol PLS_INTEGER;
  
  vr_tab_erro GENE0001.typ_tab_erro;
  
  CURSOR cr_crapfer(pr_cdcooper IN crapfer.cdcooper%TYPE
                   ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
  SELECT *
    FROM crapfer
    WHERE crapfer.cdcooper = pr_cdcooper
      AND crapfer.dtferiad = pr_dtferiad;
  rw_crapfer cr_crapfer%ROWTYPE;
  
  CURSOR cr_crapcop(pr_cdcooper IN crapfer.cdcooper%TYPE) IS
  SELECT *
    FROM crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  
  PROCEDURE pc_gera_log_batch(pr_dslog IN VARCHAR2) IS
  BEGIN
    -- diretório do log: \\pkghomol3\coop\"nome da cooperativa"\log\proc_batch.log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratado
                              ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR HH24:MI:SS')||': '||
                                                  vr_cdcooper||' '||
                                                  to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' --> '||
                                                  pr_dslog );
  END;
  
BEGIN
    RESULT := 'ERRO';
    
    vr_cdcooper := 2; -- ALTERAR NÚMERO DA COOPERATIVA
    vr_nmtelant := '';
    
    vr_flgresta := 0;
    vr_stprogra := 0;
    vr_infimsol := 0;
    
    FOR idx IN 1..1 LOOP
    
    -- Verifica se a data esta cadastrada
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Alimenta a booleana
    vr_blnfound := BTCH0001.cr_crapdat%FOUND;
    -- Fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 1;
      pc_gera_log_batch('cr_crapdat erro: '||vr_cdcritic);
      dbms_output.put_line('cr_crapdat erro: '||vr_cdcritic);
      RETURN;
    END IF;
    
    UPDATE crapdat set inproces = 3 WHERE crapdat.cdcooper = vr_cdcooper;
    commit;
    
    /*
    -- Gerar lancamento de cobranca de taxa de contrato de emprestimo
    pc_gera_log_batch('crps149 inicio');
    cecred.pc_crps149(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
                      
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps149 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS149 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps149 termino');

    
    -- Pagamento PP/TR
    pc_gera_log_batch('crps750 inicio');
    cecred.pc_crps750(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => 0,
                      pr_nmdatela => vr_nmdatela,
                      pr_idparale => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps750 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps750 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;  
    pc_gera_log_batch('crps750 termino');
      
      
    -- Pagamento do Pós Fixado
    pc_gera_log_batch('crps724 inicio');
    cecred.pc_crps724(pr_cdcooper => vr_cdcooper,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps724 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS724 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps724 termino');
    
    
    -- Atualiza Saldo TR                 
    pc_gera_log_batch('crps665 inicio');
    cecred.pc_crps665(pr_cdcooper => vr_cdcooper,
                      pr_cdoperad => '1',
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps665 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps665 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps665 termino');
    
    
    -- Atualiza Saldo PP
    pc_gera_log_batch('crps616 inicio');
    cecred.pc_crps616(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => 0,
                      pr_idparale => 0,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps616 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps616 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;                    
    pc_gera_log_batch('crps616 termino');                  
    
    
    -- Atualiza o Saldo POS
    pc_gera_log_batch('crps723 inicio');
    cecred.pc_crps723(pr_cdcooper => vr_cdcooper,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps723 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS723 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('CRPS723 termino');   


    -- Calcula Parcela do Pos Fixado
    pc_gera_log_batch('crps720 inicio');
    cecred.pc_crps720(pr_cdcooper => vr_cdcooper,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps720 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS720 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('CRPS720 termino'); 
    */
    
    -- Rotina de pagamento de boletos
    pc_gera_log_batch('crps538 inicio');
    cecred.pc_crps538(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => 0,
                      pr_idparale => 0,
                      pr_flgresta => 0,
                      pr_nmtelant => NULL,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps538 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS538 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('CRPS538 termino'); 
    
    
    -- Rotina de pagamento de títulos vencidos via raspada
    pc_gera_log_batch('crps735 inicio');
    cecred.pc_crps735(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => NULL,
                      pr_idparale => 1,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps735 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS735 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps735 termino');
    
    
    -- rotina antiga de estouro de conta corrente
    pc_gera_log_batch('pc_efetua_baixa_tit_car inicio');
    DSCT0001.pc_efetua_baixa_tit_car(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => 1
                                    ,pr_nrdcaixa => 100
                                    ,pr_idorigem => 1
                                    ,pr_cdoperad => 1
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);

    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      END IF;
       pc_gera_log_batch('pc_efetua_baixa_tit_car erro: '||vr_cdcritic||' - '||vr_dscritic);
       dbms_output.put_line('pc_efetua_baixa_tit_car - '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    ELSE
      COMMIT;
    END IF;
    pc_gera_log_batch('pc_efetua_baixa_tit_car termino');
    
    
    -- Calcula o vencimento dos titulos
    pc_gera_log_batch('crps734 inicio');
    cecred.pc_crps734(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => NULL,
                      pr_idparale => 1,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps734 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS734 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps734 termino');
    
    -- rotina de saldo
    pc_gera_log_batch('crps001 inicio');
    cecred.pc_crps001(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
           
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps001 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('CRPS001 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps001 termino');
    
    
    -- Gerar arquivo com saldo devedor dos emprestimos - Risco.
    pc_gera_log_batch('crps515 inicio');
    cecred.pc_crps515(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps515 erro: '||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps515 erro: '||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps515 termino');
  
    
    -- Realiza a formacao do grupo economico
    pc_gera_log_batch('crps634 inicio');
    cecred.pc_crps634(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps634 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps634 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps634 termino');
    
    -- ATUALIZAR RISCO SISBACEN DE ACORDO COM O GE.
    pc_gera_log_batch('crps635 inicio');
    cecred.pc_crps635(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
                        
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps635 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps635 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;  
    pc_gera_log_batch('crps635 termino');
    
    -- Mensal                 
    IF (TO_CHAR(rw_crapdat.dtmvtolt, 'MM') <> TO_CHAR(rw_crapdat.dtmvtopr, 'MM')) THEN
      /*
      -- Atualiza Saldo na Mensal TR
      pc_gera_log_batch('crps078 inicio');
      cecred.pc_crps078(pr_cdcooper => vr_cdcooper,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdoperad => '1',
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);     
                        
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps078 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps078 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;  
      pc_gera_log_batch('crps078 termino');

    
      -- Atualiza Saldo PP
      pc_gera_log_batch('crps575 inicio');
      cecred.pc_crps575(pr_cdcooper => vr_cdcooper,
                        pr_cdoperad => '1',
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
    
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps575 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps575 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps575 termino');
      
      
      -- Atualiza Saldo na Mensal POS
      pc_gera_log_batch('crps721 inicio');
      cecred.pc_crps721(pr_cdcooper => vr_cdcooper,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);                    
             
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps721 erro: '||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('CRPS721 erro: '||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps721 terminio');
      */
      

      -- Realiza os lançamentos mensais dos titulos
      pc_gera_log_batch('crps736 inicio');
      cecred.pc_crps736(pr_cdcooper => vr_cdcooper,
                        pr_cdagenci => NULL,
                        pr_idparale => 1,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
      
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps736 erro: '||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('CRPS736 erro: '||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps736 termino');
      
      
      -- Gerar arquivo com saldo devedor dos emprestimos - Risco
      pc_gera_log_batch('crps310 inicio');
      cecred.pc_crps310(pr_cdcooper => vr_cdcooper,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps310 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps310 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps310 termino');


      -- Realiza a formacao do grupo economico
      pc_gera_log_batch('crps627 inicio');
      cecred.pc_crps627(pr_cdcooper => vr_cdcooper,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);
                        
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps627 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps627 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;                
      pc_gera_log_batch('crps627 termino');              


      -- Atualizar risco sisbacen de acordo com o ge
      pc_gera_log_batch('crps628 inicio');
      cecred.pc_crps628(pr_cdcooper => vr_cdcooper,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic);            

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps628 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps628 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps628 termino');

      
      -- Emite relatorio da provisao para creditos de liquidacao duvidosa (227)
      pc_gera_log_batch('crps280 inicio');
      cecred.pc_crps280(pr_cdcooper => vr_cdcooper,
                        pr_flgresta => 0,
                        pr_stprogra => vr_stprogra,
                        pr_infimsol => vr_infimsol,
                        pr_cdcritic => vr_cdcritic,
                        pr_dscritic => vr_dscritic); 
                          
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps280 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps280 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;   
      pc_gera_log_batch('crps280 termino'); 
      
      
      /*-- Inicio Arquivo 3040
      UPDATE craptab
      SET    dstextab = '1'||SUBSTR(dstextab, 2, LENGTH(dstextab))
      WHERE  craptab.cdcooper = vr_cdcooper
      AND    craptab.nmsistem = 'CRED'
      AND    craptab.tptabela = 'USUARI'
      AND    craptab.cdempres = 11
      AND    craptab.cdacesso = 'RISCOBACEN'
      AND    craptab.tpregist = 000;

      -- gera arquivo 3040
      pc_gera_log_batch('crps573 inicio');
      cecred.pc_crps573(pr_cdcooper => vr_cdcooper
                       ,pr_stprogra => vr_stprogra
                       ,pr_infimsol => vr_infimsol
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic );
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        pc_gera_log_batch('crps573 erro:'||vr_cdcritic||' - '||vr_dscritic);
        dbms_output.put_line('crps573 erro:'||vr_cdcritic||' - '||vr_dscritic);
        RETURN;
      END IF;
      pc_gera_log_batch('crps573 termino');

      UPDATE craptab
      SET    dstextab = '0'||SUBSTR(dstextab, 2, LENGTH(dstextab))
      WHERE  craptab.cdcooper = vr_cdcooper
      AND    craptab.nmsistem = 'CRED'
      AND    craptab.tptabela = 'USUARI'
      AND    craptab.cdempres = 11
      AND    craptab.cdacesso = 'RISCOBACEN'
      AND    craptab.tpregist = 000;
      -- Final Arquivo 3040*/
    END IF;
    
    -- Relatorio crrl354
    pc_gera_log_batch('crps516 inicio');
    cecred.pc_crps516(pr_cdcooper => vr_cdcooper,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);
    
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps516 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps516 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps516 termino');
     
 
/*    pc_gera_log_batch('crps445 inicio');
    cecred.pc_crps445(pr_cdcooper => vr_cdcooper,
                      pr_cdagenci => 0,
                      pr_idparale => 0,
                      pr_flgresta => 0,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps445 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps445 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps445 termino');*/
    
    
    pc_gera_log_batch('crps249_gft inicio');
    cecred.pc_crps249_gft(pr_cdcooper => vr_cdcooper,
                          pr_flgresta => 0,
                          pr_stprogra => vr_stprogra,
                          pr_infimsol => vr_infimsol,
                          pr_cdcritic => vr_cdcritic,
                          pr_dscritic => vr_dscritic);
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps249 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps249 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps249 termino');
    
    
    SELECT dtmvtopr INTO vr_dtmvtolt FROM crapdat WHERE cdcooper = vr_cdcooper;
    --vr_dtmvtolt := vr_dtmvtolt;
    vr_erro := 'N';
    vr_cdcooper := vr_cdcooper;
    vr_dscritic := NULL;
    
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
   
    
    IF cr_crapcop%NOTFOUND THEN
      vr_dscritic := 'Erro. Cooperativa não Cadastrada!';
      CLOSE cr_crapcop;
      RETURN;
    END IF;
    
    CLOSE cr_crapcop;
    
    OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                   ,pr_dtferiad => vr_dtmvtolt);
    FETCH cr_crapfer INTO rw_crapfer;
   
    
    IF cr_crapfer%FOUND AND NOT (to_char(vr_dtmvtolt,'MM') = '12' AND to_char(vr_dtmvtolt,'DD') = '31')  THEN
      vr_dscritic := 'Erro. A data digitada eh um feriado de ' || rw_crapfer.dsferiad;
      CLOSE cr_crapfer;
      UPDATE crapdat set inproces = 1 WHERE crapdat.cdcooper = vr_cdcooper;
      RETURN;
    END IF;
    
     CLOSE cr_crapfer;
                   
    IF to_char(vr_dtmvtolt,'D') = '7' THEN
      vr_dscritic := 'Erro. A data digitada é um sabado.'; 
      UPDATE crapdat set inproces = 1 WHERE crapdat.cdcooper = vr_cdcooper; 
      RETURN;
    END IF;
    
    IF to_char(vr_dtmvtolt,'D') = '1' THEN
      vr_dscritic := 'Erro. A data digitada é um domingo.';
      UPDATE crapdat set inproces = 1 WHERE crapdat.cdcooper = vr_cdcooper;  
      RETURN;
    END IF;
    
    vr_sair := FALSE;  
    
    vr_dtanteri := vr_dtmvtolt;
    
    -- Bloco de repetição para calcular a data anterior
    LOOP  
                   
      vr_dtanteri := vr_dtanteri - 1;
                        
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                     ,pr_dtferiad => vr_dtanteri);
      FETCH cr_crapfer INTO rw_crapfer;
      
      IF ( (to_char(vr_dtanteri,'D') <> '1') AND
           (to_char(vr_dtanteri,'D') <> '7') AND
           cr_crapfer%NOTFOUND ) THEN
           
           vr_sair := TRUE;
           
      END IF;     
      
      CLOSE cr_crapfer;
                                                             
      EXIT WHEN vr_sair = TRUE;                                          
    END LOOP;
    
    vr_sair := FALSE;
    vr_dtproxim := vr_dtmvtolt;
    
    -- Bloco de repetição para calcular a data proxima
    LOOP  
                   
      vr_dtproxim := vr_dtproxim + 1;
                        
      OPEN cr_crapfer(pr_cdcooper => vr_cdcooper
                     ,pr_dtferiad => vr_dtproxim);
      FETCH cr_crapfer INTO rw_crapfer;
      
      IF ( (to_char(vr_dtproxim,'D') <> '1') AND
           (to_char(vr_dtproxim,'D') <> '7') AND
           cr_crapfer%NOTFOUND ) THEN
           
           vr_sair := TRUE;
           
      END IF;     
      
      CLOSE cr_crapfer;
                                                             
      EXIT WHEN vr_sair = TRUE;                                          
    END LOOP;
    
    vr_dtultdia := last_day(vr_dtmvtolt); 
    
    vr_dtultdma := vr_dtmvtolt - to_char(vr_dtmvtolt,'DD');
    
    UPDATE crapdat
      SET crapdat.dtmvtolt = vr_dtmvtolt,
          crapdat.dtmvtoan = vr_dtanteri,
          crapdat.dtmvtopr = vr_dtproxim,
          crapdat.dtmvtocd = vr_dtmvtolt,
          crapdat.dtultdia = vr_dtultdia,
          crapdat.dtultdma = vr_dtultdma
    WHERE crapdat.cdcooper = vr_cdcooper;
            
    vr_dscritic := 'Data Atualizada! ' ||
                    'Data Atual: '      || to_char(vr_dtmvtolt,'DD/MM/YYYY') || ' - ' ||
                    'Data Anterior: '   || to_char(vr_dtanteri,'DD/MM/YYYY') || ' - ' ||
                    'Data Posterior: '  || to_char(vr_dtproxim,'DD/MM/YYYY') || ' - ' ||
               --     'dtultdma: '  || to_char(vr_dtultdma,'DD/MM/YYYY') || ' - ' ||
               --     'dtultdia: '  || to_char(vr_dtultdia,'DD/MM/YYYY') || ' - ' ||
                    'Data Tocd: '       || to_char(vr_dtmvtolt,'DD/MM/YYYY'); 
    
    UPDATE crapdat set inproces = 1 WHERE crapdat.cdcooper = vr_cdcooper;
    COMMIT;
    
    /*
    -- Gera os arquivos para a CYBER
    pc_gera_log_batch('crps652_gft inicio');
    cecred.pc_crps652_gft(pr_cdcooper => vr_cdcooper,
                      pr_nmtelant => vr_nmtelant,
                      pr_flgresta => vr_flgresta,
                      pr_stprogra => vr_stprogra,
                      pr_infimsol => vr_infimsol,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('crps652 erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('crps652 erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('crps652 termino');*/
    
    
    /*-- atualiza risco central
    pc_gera_log_batch('pc_risco_central_ocr inicio');
    cecred.risc0003.pc_risco_central_ocr(pr_cdcooper => vr_cdcooper,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_gera_log_batch('pc_risco_central_ocr erro:'||vr_cdcritic||' - '||vr_dscritic);
      dbms_output.put_line('pc_risco_central_ocr erro:'||vr_cdcritic||' - '||vr_dscritic);
      RETURN;
    END IF;
    pc_gera_log_batch('pc_risco_central_ocr termino');*/
    
    result := 'Sucesso';
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    result := 'ERRO: ' || SQLERRM;
end;
