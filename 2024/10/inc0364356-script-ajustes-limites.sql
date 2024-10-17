DECLARE
   vr_aux_ambiente    INTEGER       := 3;             
   vr_aux_diretor     VARCHAR2(100) := 'INC0364356';     
   vr_aux_arquivo     VARCHAR2(100) := 'registros';
   vr_handle          UTL_FILE.FILE_TYPE; 
   vr_handle_log      UTL_FILE.FILE_TYPE;
   vr_handle_regs     UTL_FILE.FILE_TYPE;
   vr_nmarq_regs      VARCHAR2(200);
   vr_nmarq_log       VARCHAR2(200);
   vr_nmarq_rollback  VARCHAR2(200);
   rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;
   vr_des_erro        VARCHAR2(10000); 
   vr_des_linha       VARCHAR2(3000);  
   vr_vet_campos      GENE0002.typ_split; 
   vr_nrcontad        PLS_INTEGER := 0; 
   vr_aux_cdcooper    NUMBER;  
   vr_aux_cddlinha    NUMBER;
   vr_aux_nrborder    NUMBER;
   vr_aux_nrdconta    NUMBER;
   vr_cont_commit     NUMBER(6) := 0;
   vr_cdcritic        crapcri.cdcritic%TYPE;
   vr_dscritic        crapcri.dscritic%TYPE;
   vr_exc_erro        EXCEPTION;
   vr_conta_ambiente  NUMBER;
   vr_aux_campo1     NUMBER;
   vr_aux_campo2     NUMBER;
   vr_aux_campo3     NUMBER;
   vr_aux_campo4     NUMBER;
   vr_aux_campo5     NUMBER;
     
  TYPE typ_reg_carga IS RECORD(cdcooper  crapbdt.cdcooper%TYPE
                              ,nrdconta  crapbdt.nrdconta%TYPE
                              ,nrborder  crapbdt.nrborder%TYPE
                              ,campo1    NUMBER
                              ,campo2    NUMBER
                              ,campo3    NUMBER
                              ,campo4    NUMBER
                              ,campo5    NUMBER);
  TYPE typ_tab_carga IS TABLE OF typ_reg_carga INDEX BY PLS_INTEGER;
  vr_tab_carga typ_tab_carga;
  
  CURSOR cr_conta_ambiente(pr_cdcooper IN crapbdt.cdcooper%TYPE
                          ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
    SELECT bdt.nrdconta
      FROM cecred.crapbdt bdt
     WHERE bdt.cdcooper = pr_cdcooper
       AND bdt.nrborder = pr_nrborder;
  rw_conta_ambiente cr_conta_ambiente%ROWTYPE;
  

  PROCEDURE pc_liberar_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE 
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrborder IN crapbdt.nrborder%TYPE    
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                               ,pr_dscritic OUT VARCHAR2) IS                                                                    
    CURSOR cr_crapbdt IS
     SELECT bdt.rowid AS id,
            bdt.*
       FROM cecred.crapbdt bdt
      WHERE bdt.cdcooper = pr_cdcooper
        AND bdt.nrdconta = pr_nrdconta
        AND bdt.nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;

    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN

       OPEN cr_crapbdt;
       FETCH cr_crapbdt INTO rw_crapbdt;
       IF (cr_crapbdt%NOTFOUND) THEN
         CLOSE cr_crapbdt;
         vr_dscritic := 'Bordero nao encontrado.';
         RAISE vr_exc_erro;
       END IF;
       CLOSE cr_crapbdt;
       
       BEGIN   
         UPDATE cecred.crapbdt
            SET insitbdt = 3
          WHERE ROWID = rw_crapbdt.id
            AND insitbdt = 4;
                     
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                          ,pr_des_text => 'UPDATE cecred.crapbdt lim ' ||
                                                          '   SET lim.insitbdt = ' || rw_crapbdt.insitbdt ||
                                                          ' WHERE lim.cdcooper = ' || rw_crapbdt.cdcooper ||
                                                          '   AND lim.nrdconta = ' || rw_crapbdt.nrdconta ||
                                                          '   AND lim.nrborder = ' || rw_crapbdt.nrborder ||
                                                          ';');      
       EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar cecred.crapbdt: ' || SQLERRM;
            RAISE vr_exc_erro;
       END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_liberar_bordero: ' ||SQLERRM;
    END pc_liberar_bordero;
    
  
    
    PROCEDURE pc_exclui_lanctos (pr_cdcooper IN crapcop.cdcooper%TYPE 
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_nrborder IN crapbdt.nrborder%TYPE    
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                                ,pr_dscritic OUT VARCHAR2) IS
                                                                    
      CURSOR cr_lcto_border(pr_cdcooper craplim.cdcooper%TYPE
                           ,pr_nrdconta craplim.nrdconta%TYPE
                           ,pr_nrborder crapbdt.nrborder%TYPE) IS
          SELECT a.rowid AS id,
                 a.*
            FROM cecred.tbdsct_lancamento_bordero a
           WHERE a.cdcooper = pr_cdcooper
             AND a.nrdconta = pr_nrdconta
             AND a.nrborder = pr_nrborder
             AND a.dtmvtolt = to_date('16/10/2024')
             AND a.cdhistor IN(2763,2876);

      vr_cdcritic    NUMBER;
      vr_dscritic    VARCHAR2(1000);
      vr_exc_erro    EXCEPTION;

    BEGIN

       BEGIN   
         FOR rw_lcto_border IN cr_lcto_border (pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nrborder => pr_nrborder) LOOP
                                             
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                          ,pr_des_text => 'INSERT INTO tbdsct_lancamento_bordero ' ||
                                                          '(cdcooper ' ||
                                                          ',nrdconta ' ||
                                                          ',nrborder ' ||
                                                          ',nrtitulo ' || 
                                                          ',nrseqdig ' ||
                                                          ',cdbandoc ' || 
                                                          ',nrdctabb ' || 
                                                          ',nrcnvcob ' || 
                                                          ',nrdocmto ' || 
                                                          ',dtmvtolt ' ||
                                                          ',cdorigem ' ||
                                                          ',cdhistor ' ||
                                                          ',vllanmto)' ||
                                                          'VALUES(' || rw_lcto_border.cdcooper ||
                                                                ',' || rw_lcto_border.nrdconta ||
                                                                ',' || rw_lcto_border.nrborder ||
                                                                ',' || rw_lcto_border.nrtitulo ||
                                                                ',' || rw_lcto_border.nrseqdig ||
                                                                ',' || rw_lcto_border.cdbandoc ||
                                                                ',' || rw_lcto_border.nrdctabb ||
                                                                ',' || rw_lcto_border.nrcnvcob ||
                                                                ',' || rw_lcto_border.nrdocmto ||
                                                                ',to_date("' || rw_lcto_border.dtmvtolt || '")' ||
                                                                ',' || rw_lcto_border.cdorigem ||
                                                                ',' || rw_lcto_border.cdhistor ||
                                                                ',' || rw_lcto_border.vllanmto ||
                                                          ';');
                                                          
             DELETE cecred.tbdsct_lancamento_bordero a
              WHERE a.cdcooper = rw_lcto_border.cdcooper
                AND a.nrdconta = rw_lcto_border.nrdconta
                AND a.nrborder = rw_lcto_border.nrborder
                AND a.dtmvtolt = rw_lcto_border.dtmvtolt
                AND a.cdhistor = rw_lcto_border.cdhistor;                                           
                                                          
        END LOOP;     
       EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar cecred.tbdsct_lancamento_bordero: ' || SQLERRM;
            RAISE vr_exc_erro;
       END;


    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_exclui_lanctos: ' ||SQLERRM;
    END pc_exclui_lanctos;
    
    
    
    PROCEDURE pc_lanctos_conta (pr_cdcooper IN crapcop.cdcooper%TYPE 
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrborder IN crapbdt.nrborder%TYPE    
                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                               ,pr_dscritic OUT VARCHAR2) IS
                                                                    
      CURSOR cr_craplcm(pr_cdcooper craplim.cdcooper%TYPE
                       ,pr_nrdconta craplim.nrdconta%TYPE
                       ,pr_nrborder crapbdt.nrborder%TYPE) IS
          SELECT a.rowid AS id,
                 a.*
            FROM cecred.craplcm a
           WHERE a.cdcooper = pr_cdcooper
             AND a.nrdconta = pr_nrdconta
             AND a.nrdocmto = pr_nrborder             
             AND a.dtmvtolt BETWEEN to_date('15/10/2024') AND to_date('16/10/2024')
             AND a.cdhistor = 2386;

      vr_cdcritic    NUMBER;
      vr_dscritic    VARCHAR2(1000);
      vr_exc_erro    EXCEPTION;
      vr_tab_retorno LANC0001.typ_reg_retorno;
      vr_incrineg    INTEGER;
      rw_crapdat     datasCooperativa;

    BEGIN

         rw_crapdat := datasCooperativa(pr_cdcooper => pr_cdcooper);
        
         FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrborder => pr_nrborder) LOOP
  
            LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => pr_cdcooper,
                                               pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                               pr_cdagenci    => rw_craplcm.cdagenci,
                                               pr_cdbccxlt    => rw_craplcm.cdbccxlt,
                                               pr_nrdolote    => rw_craplcm.nrdolote,
                                               pr_nrdocmto    => rw_craplcm.nrdocmto,
                                               pr_nrdconta    => pr_nrdconta,
                                               pr_cdhistor    => 2387,
                                               pr_vllanmto    => rw_craplcm.vllanmto,
                                               pr_cdpesqbb    => pr_nrborder, 
                                               pr_cdoperad    => 1,
                                               pr_cdcritic    => vr_cdcritic,
                                               pr_dscritic    => vr_dscritic,
                                               pr_incrineg    => vr_incrineg,
                                               pr_tab_retorno => vr_tab_retorno);
                                                                                                                                           
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
               CONTINUE; 
            ELSE 
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                            ,pr_des_text => 'DELETE cecred.craplcm a' ||
                                                            ' WHERE a.cdcooper = ' || rw_craplcm.cdcooper ||
                                                            '   AND a.nrdconta = ' || rw_craplcm.nrdconta ||
                                                            '   AND a.dtmvtolt = to_date("' || rw_crapdat.dtmvtolt || '")' ||
                                                            '   AND a.cdhistor = 2387' ||
                                                            ';');
            END IF;  
        END LOOP;                                                 

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_lanctos_conta: ' ||SQLERRM;
    END pc_lanctos_conta;
    
    
    
    PROCEDURE pc_ajustar_titulos (pr_cdcooper IN crapcop.cdcooper%TYPE 
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE
                                 ,pr_nrborder IN crapbdt.nrborder%TYPE    
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE 
                                 ,pr_dscritic OUT VARCHAR2) IS                                                                    
      
    CURSOR cr_crapcob(pr_cdcooper craptdb.cdcooper%TYPE
                     ,pr_nrdconta craptdb.nrdconta%TYPE
                     ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT tdb.rowid AS id,
             tdb.cdcooper,
             tdb.nrdconta,
             tdb.nrborder,
             tdb.insittit,
             tdb.dtdpagto,
             cob.dtdpagto AS dtdpagto_cob,
             cob.incobran
        FROM cecred.craptdb tdb,
             cecred.crapcob cob
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrdconta = pr_nrdconta
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrdocmto = cob.nrdocmto
         AND tdb.nrcnvcob = cob.nrcnvcob
         AND tdb.nrdctabb = cob.nrdctabb
         AND tdb.cdbandoc = cob.cdbandoc
         AND tdb.nrdconta = cob.nrdconta
         AND tdb.cdcooper = cob.cdcooper
         AND cob.incobran = 0
         AND cob.dtdpagto IS NULL
         AND tdb.dtdpagto BETWEEN to_date('15/10/2024') AND to_date('16/10/2024');

    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    vr_exc_erro    EXCEPTION;

    BEGIN

      
       BEGIN
            FOR rw_crapcob IN cr_crapcob (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrborder => pr_nrborder) LOOP
                                         
                IF rw_crapcob.incobran = 0 AND
                   rw_crapcob.dtdpagto_cob IS NULL AND
                   rw_crapcob.dtdpagto BETWEEN to_date('15/10/2024') AND to_date('16/10/2024') THEN 
                                           
                   UPDATE cecred.craptdb
                      SET insittit = 4,
                          dtdpagto = NULL
                    WHERE ROWID = rw_crapcob.id;                         
                                                 
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                                  ,pr_des_text => 'UPDATE cecred.craptdb lim '    ||
                                                                  '   SET lim.insittit = ' || rw_crapcob.insittit ||
                                                                  '      ,lim.dtdpagto = to_date("' || rw_crapcob.dtdpagto || '")' ||
                                                                  ' WHERE ROWID = ' || rw_crapcob.id ||
                                                                  ';'); 
                END IF;                                         
            END LOOP;                                                  
       EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar cecred.craptdb: ' || SQLERRM;
            RAISE vr_exc_erro;
       END;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
        ROLLBACK;
        pr_cdcritic := 0;
        pr_dscritic := 'Erro não tratado na rotina pc_ajustar_titulos: ' ||SQLERRM;
    END pc_ajustar_titulos;
   

BEGIN
    IF vr_aux_ambiente = 1 THEN 
      vr_nmarq_regs     := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';  
      vr_nmarq_log      := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := '/progress/t0032597/micros/script_renovacao/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql';       
    ELSIF vr_aux_ambiente = 2 THEN   
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';     
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';     
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/evandro/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSIF vr_aux_ambiente = 3 THEN 
      vr_nmarq_regs     := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'.csv';
      vr_nmarq_log      := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_LOG.txt';      
      vr_nmarq_rollback := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/fabricio/'|| vr_aux_diretor ||'/'|| vr_aux_arquivo ||'_ROLLBACK.sql'; 
    ELSE
      vr_dscritic := 'Erro ao apontar ambiente de execucao.';
      RAISE vr_exc_erro;
    END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_log
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle_log   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de LOG: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if;
    
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_regs
                            ,pr_tipabert => 'R'
                            ,pr_utlfileh => vr_handle_regs
                            ,pr_des_erro => vr_dscritic);                                                                       
      IF vr_dscritic IS NOT NULL THEN 
         vr_dscritic := 'Erro ao abrir o arquivo para leitura: '||vr_nmarq_regs || ' - ' || vr_dscritic;
         RAISE vr_exc_erro;
      END IF;

    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nmarq_rollback
                            ,pr_tipabert => 'W'              
                            ,pr_utlfileh => vr_handle   
                            ,pr_des_erro => vr_des_erro);
    if vr_des_erro is not null then
      vr_dscritic := 'Erro ao abrir arquivo de ROLLBACK: ' || vr_des_erro;
      RAISE vr_exc_erro;
    end if; 
      
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Inicio da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS') || chr(10) || 'Cooperativa;Conta;Contrato;Erro');
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'BEGIN');                                                                  

  
    LOOP 
      BEGIN
        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_regs 
                                    ,pr_des_text => vr_des_linha); 
      
        vr_nrcontad := vr_nrcontad + 1; 
          
        vr_des_linha := REPLACE(REPLACE(vr_des_linha,chr(13),''),chr(10),''); 

        vr_vet_campos := gene0002.fn_quebra_string(TRIM(vr_des_linha),';'); 

        BEGIN
           vr_aux_cdcooper := TO_NUMBER(vr_vet_campos(1));  
           vr_aux_nrdconta := TO_NUMBER(vr_vet_campos(2));
           vr_aux_nrborder := TO_NUMBER(vr_vet_campos(3));
           vr_aux_campo1   := TO_NUMBER(NVL(vr_vet_campos(4),0));
           vr_aux_campo2   := TO_NUMBER(NVL(vr_vet_campos(5),0));
           vr_aux_campo3   := TO_NUMBER(NVL(vr_vet_campos(6),0));
           vr_aux_campo4   := TO_NUMBER(NVL(vr_vet_campos(7),0));                                      
        EXCEPTION
          WHEN OTHERS THEN
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                          ,pr_des_text => 'Erro na leitura da linha: ' || vr_nrcontad || ' => ' || SQLERRM);
              
          CONTINUE;
        END;             

        vr_tab_carga(vr_nrcontad).cdcooper := vr_aux_cdcooper;
        vr_tab_carga(vr_nrcontad).nrdconta := vr_aux_nrdconta;
        vr_tab_carga(vr_nrcontad).nrborder := vr_aux_nrborder;
        vr_tab_carga(vr_nrcontad).campo1   := vr_aux_campo1;
        vr_tab_carga(vr_nrcontad).campo2   := vr_aux_campo2;
        vr_tab_carga(vr_nrcontad).campo3   := vr_aux_campo3;
        vr_tab_carga(vr_nrcontad).campo4   := vr_aux_campo4;

      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
        WHEN vr_exc_erro THEN
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na leitura da linha '||vr_nrcontad||' => '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END LOOP;


    FOR vr_idx1 IN vr_tab_carga.first .. vr_tab_carga.last LOOP
        IF vr_tab_carga.exists(vr_idx1) THEN
         
         vr_conta_ambiente := '';   
         vr_cont_commit  := vr_cont_commit + 1;
              
         OPEN BTCH0001.cr_crapdat(pr_cdcooper =>  vr_tab_carga(vr_idx1).cdcooper);
         FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
         CLOSE BTCH0001.cr_crapdat;

           
         IF vr_aux_ambiente = 3 THEN 
            vr_conta_ambiente := vr_tab_carga(vr_idx1).nrdconta;
         ELSE  
             OPEN cr_conta_ambiente (pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                    ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder);
             FETCH cr_conta_ambiente INTO rw_conta_ambiente;
             IF cr_conta_ambiente%NOTFOUND THEN
                CLOSE cr_conta_ambiente;
                gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                              ,pr_des_text => 'Coop: ' || vr_tab_carga(vr_idx1).cdcooper ||' - Bordero nao encontrado: ' || vr_tab_carga(vr_idx1).nrborder);
                CONTINUE;
             END IF;
             CLOSE cr_conta_ambiente;
                 
             vr_conta_ambiente := rw_conta_ambiente.nrdconta;
         END IF;

          IF vr_tab_carga(vr_idx1).campo1 = 1 THEN
               pc_liberar_bordero(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                 ,pr_nrdconta => vr_conta_ambiente
                                 ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

               IF vr_dscritic IS NOT NULL THEN
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                vr_conta_ambiente || ';' || 
                                                                vr_tab_carga(vr_idx1).nrborder || ';' || 
                                                                vr_dscritic);                                                                     
               END IF;
          END IF;

          IF vr_tab_carga(vr_idx1).campo2 = 1 THEN
               pc_exclui_lanctos(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                ,pr_nrdconta => vr_conta_ambiente
                                ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

               IF vr_dscritic IS NOT NULL THEN
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                vr_conta_ambiente || ';' || 
                                                                vr_tab_carga(vr_idx1).nrborder || ';' || 
                                                                vr_dscritic);                                                                     
               END IF;
          END IF;
          
          IF vr_tab_carga(vr_idx1).campo3 = 1 THEN
                pc_lanctos_conta(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                ,pr_nrdconta => vr_conta_ambiente
                                ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);

               IF vr_dscritic IS NOT NULL THEN
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                vr_conta_ambiente || ';' || 
                                                                vr_tab_carga(vr_idx1).nrborder || ';' || 
                                                                vr_dscritic);                                                                     
               END IF;
          END IF;

          IF vr_tab_carga(vr_idx1).campo4 = 1 THEN
                pc_ajustar_titulos(pr_cdcooper => vr_tab_carga(vr_idx1).cdcooper
                                  ,pr_nrdconta => vr_conta_ambiente
                                  ,pr_nrborder => vr_tab_carga(vr_idx1).nrborder
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);

               IF vr_dscritic IS NOT NULL THEN
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                                ,pr_des_text => vr_tab_carga(vr_idx1).cdcooper || ';' || 
                                                                vr_conta_ambiente || ';' || 
                                                                vr_tab_carga(vr_idx1).nrborder || ';' || 
                                                                vr_dscritic);                                                                     
               END IF;
          END IF;
                         
         IF vr_cont_commit = 50 THEN
            vr_cont_commit := 0;
            COMMIT;
         END IF;
         
        END IF;
    END LOOP;
    
  
    BEGIN
      INSERT INTO cecred.tbdsct_lancamento_bordero(cdcooper ,
                                                   nrdconta ,
                                                   nrborder ,
                                                   nrtitulo ,
                                                   nrseqdig ,
                                                   cdbandoc ,
                                                   nrdctabb ,
                                                   nrcnvcob ,
                                                   nrdocmto ,
                                                   dtmvtolt ,
                                                   cdorigem ,
                                                   cdhistor ,
                                                   vllanmto)
                                                   VALUES(14,
                                                          268402,
                                                          129033,
                                                          0,
                                                          11,
                                                          0,
                                                          0,
                                                          0,
                                                          0,
                                                          to_date('15/10/2024'),
                                                          5,
                                                          2876,
                                                          to_char(821.11));
                                                                   
      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                    ,pr_des_text => 'DELETE cecred.tbdsct_lancamento_bordero a' ||
                                                    ' WHERE a.cdcooper = 14'     ||
                                                    '   AND a.nrdconta = 268402' ||
                                                    '   AND a.nrborder = 129033' ||
                                                    '   AND a.dtmvtolt = to_date("15/10/2024")' ||
                                                    '   AND a.cdhistor = 2876' ||
                                                    ';'); 
                                                            
     EXCEPTION
        WHEN OTHERS THEN
           gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => '14;' || 
                                                        '268402;' || 
                                                        '129033;' || 
                                                        'Erro ao atualizar cecred.tbdsct_lancamento_bordero: ' || SQLERRM);
     END;
       
       
     BEGIN
        INSERT INTO cecred.tbdsct_lancamento_bordero(cdcooper ,
                                                     nrdconta ,
                                                     nrborder ,
                                                     nrtitulo ,
                                                     nrseqdig ,
                                                     cdbandoc ,
                                                     nrdctabb ,
                                                     nrcnvcob ,
                                                     nrdocmto ,
                                                     dtmvtolt ,
                                                     cdorigem ,
                                                     cdhistor ,
                                                     vllanmto)
                                                     VALUES(14,
                                                            268402,
                                                            129044,
                                                            0,
                                                            11,
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                            to_date('15/10/2024'),
                                                            5,
                                                            2876,
                                                            to_char(816.35));
                                                                       
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                      ,pr_des_text => 'DELETE cecred.tbdsct_lancamento_bordero a' ||
                                                      ' WHERE a.cdcooper = 14'     ||
                                                      '   AND a.nrdconta = 268402' ||
                                                      '   AND a.nrborder = 129044' ||
                                                      '   AND a.dtmvtolt = to_date("15/10/2024")' ||
                                                      '   AND a.cdhistor = 2876' ||
                                                      ';'); 
                                                            
     EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                        ,pr_des_text => '14;' || 
                                                        '268402;' || 
                                                        '129044;' || 
                                                        'Erro ao atualizar cecred.tbdsct_lancamento_bordero: ' || SQLERRM);
     END;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Fim da execucao - ' ||  to_char(SYSDATE, 'HH24:MI:SS'));
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle
                                  ,pr_des_text => 'EXCEPTION' || chr(10) || 'WHEN OTHERS THEN' || chr(10) || 'ROLLBACK;' || chr(10) || 'END;');                                                                                                                        
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);          
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);             

    COMMIT;
EXCEPTION  
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro arquivos: ' || vr_dscritic);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro arquivos: ' || vr_dscritic || ' SQLERRM: ' || SQLERRM);      
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;  
  WHEN OTHERS THEN
    dbms_output.put_line('Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log
                                  ,pr_des_text => 'Erro geral: ' || ' SQLERRM: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    ROLLBACK;
END;
