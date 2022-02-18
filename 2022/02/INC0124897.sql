DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';  
   vr_nmarqimp1            VARCHAR2(100)  := 'backup2.txt';
   vr_nmarqimp             VARCHAR2(100)  := 'log2.txt';
   vr_ind_arquiv           utl_file.file_type;
   vr_ind_arquiv1          utl_file.file_type;  
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0120603';        
   vr_dtcalcul_considerado crapdat.dtmvtolt%TYPE;
   vr_negativo             BOOLEAN;  
   vr_cdhistor             craphis.cdhistor%TYPE;    
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vidtxfixa               NUMBER;
   vcddindex               NUMBER;
   vr_nrseqdig             NUMBER := 0;   
   vr_idtipbas NUMBER := 2;
   vr_idgravir NUMBER := 0;
   vr_vlbascal NUMBER := 0; 
   vr_vlsldtot NUMBER := 0;
   vr_vlsldrgt NUMBER := 0;
   vr_vlultren NUMBER := 0;
   vr_vlrentot NUMBER := 0;
   vr_vlrevers NUMBER := 0;
   vr_vlrdirrf NUMBER := 0;
   vr_percirrf NUMBER := 0;
   pr_vlsldtot NUMBER;
   pr_vlsldrgt NUMBER;
   pr_vlultren NUMBER;
   pr_vlrentot NUMBER;
   pr_vlrevers NUMBER;
   pr_vlrdirrf NUMBER;
   pr_percirrf NUMBER;
   
   CURSOR cr_crapcpc IS
      SELECT cdprodut
            ,cddindex
            ,idsitpro
            ,idtxfixa          
            ,cdhsraap
            ,cdhsprap
            ,cdhsrvap        
        FROM crapcpc cpc
       WHERE cpc.cddindex = 6 
         AND cpc.indanive = 1
         AND cpc.idsitpro = 1
         AND cpc.cdprodut = 1109;
   
         rw_crapcpc cr_crapcpc%ROWTYPE;      
   
   CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE ) IS
      SELECT distinct rac.cdcooper, 
             rac.nrdconta, 
             rac.nraplica, 
             rac.dtaniver,
             rac.dtmvtolt,
             rac.txaplica,            
             rac.qtdiacar,
             cpc.cdhsvrcc,
             rac.vlbasapl, 
             rac.vlsldatl,
             rac.cdprodut
        FROM craprac rac,
             craplac lac,
             crapcpc cpc
       WHERE rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND rac.cdprodut = cpc.cdprodut          
         AND rac.dtmvtolt >= to_date('29/11/2021','dd/mm/yyyy') AND rac.dtmvtolt <= to_date('30/11/2021','dd/mm/yyyy') 
         AND lac.dtmvtolt >= to_date('01/02/2022','dd/mm/yyyy')
         AND rac.cdcooper = pr_cdcooper 
         AND rac.idsaqtot = 1 
         AND lac.cdhistor = 3528      
         AND rac.cdprodut = 1109;        
     
         rw_craprac cr_craprac%ROWTYPE;        
   
   CURSOR cr_crapdat IS
      SELECT dat.cdcooper,
             dat.dtmvtolt 
        FROM crapdat dat 
       WHERE cdcooper IN(1,16);
       
       rw_crapdat cr_crapdat%ROWTYPE;
     
   PROCEDURE backup (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
   
  PROCEDURE loga(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
   
   FUNCTION fn_proximo_aniv_poupanca(pr_dtaplica IN craprac.dtaniver%TYPE) return craprac.dtaniver%TYPE IS
     vr_dia integer;
     vr_mes integer;
     vr_ano integer;
     vr_exc_data_errada exception;
  BEGIN

     BEGIN

       vr_dia := EXTRACT(day FROM pr_dtaplica);
       vr_mes := EXTRACT(month FROM pr_dtaplica);
       vr_ano := EXTRACT(year FROM pr_dtaplica);

       IF vr_dia in (29, 30, 31) THEN
          vr_dia := 1;
          vr_mes := vr_mes + 2;

          IF vr_mes > 12 THEN
             vr_mes := vr_mes - 12;
             vr_ano := vr_ano + 1;
          END IF;
       ELSE
          vr_mes := vr_mes + 1;

          IF vr_mes > 12 THEN
             vr_mes := 1;
             vr_ano := vr_ano + 1;
          END IF;
       END IF;

       RETURN to_date(vr_dia || '/' || vr_mes || '/' || vr_ano,'dd/mm/rrrr');

    EXCEPTION
       WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => 3
                                    ,pr_compleme => 'Erro calculando proximo aniversario poupança!' ||
                                                    ' pr_dtaplica = ' || to_char(pr_dtaplica,'dd/mm/rrrr') ||
                                                    ' Erro = ' || SQLERRM);
         RAISE vr_exc_data_errada;

    END;

  END fn_proximo_aniv_poupanca;
  
  PROCEDURE pc_lanctos_historicos_periodo(pr_cdcooper IN craplac.cdcooper%TYPE
                                         ,pr_nrdconta IN craplac.nrdconta%TYPE
                                         ,pr_nraplica IN craplac.nraplica%TYPE
                                         ,pr_cdhistor IN craplac.cdhistor%TYPE
                                         ,pr_dtinicio IN craplac.dtmvtolt%TYPE
                                         ,pr_dtfim    IN craplac.dtmvtolt%TYPE
                                         ,pr_vltotmto OUT craplac.vllanmto%TYPE
                                         ,pr_cdcritic OUT PLS_INTEGER
                                         ,pr_dscritic OUT VARCHAR2) IS

    vr_cdcritic crapcri.cdcritic%TYPE := 0;

    CURSOR cr_craplac IS
      SELECT nvl(SUM(lac.vllanmto), 0) AS vltotmto
        FROM craplac lac
       WHERE lac.cdcooper = pr_cdcooper
         AND lac.nrdconta = pr_nrdconta
         AND lac.nraplica = pr_nraplica
         AND lac.cdhistor = pr_cdhistor
         AND trunc(lac.dtmvtolt) >= pr_dtinicio
         AND trunc(lac.dtmvtolt) <= pr_dtfim;

    rw_craplac cr_craplac%ROWTYPE;

  BEGIN

    OPEN cr_craplac;
    FETCH cr_craplac
      INTO rw_craplac;
    CLOSE cr_craplac;

    pr_vltotmto := nvl(rw_craplac.vltotmto, 0);

  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'pc_lanctos_historicos_periodo');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_lanctos_historicos_periodo: ' || pr_nraplica || ' ' ||
                     pr_dtinicio || ' ' || pr_dtfim || ' ' || SQLERRM;
  END pc_lanctos_historicos_periodo;
    
  PROCEDURE pc_taxa_poupanca(pr_datataxa     IN  craptxi.dtiniper%TYPE
                            ,pr_vlrdtaxa     OUT craptxi.vlrdtaxa%TYPE
                            ,pr_cdcritic     OUT PLS_INTEGER
                            ,pr_dscritic     OUT VARCHAR2) IS

    vr_exc_saida EXCEPTION;
    vr_cdcritic        crapcri.cdcritic%TYPE := 0;
    vr_dscritic        crapcri.dscritic%TYPE := NULL;

    CURSOR cr_craptxi IS
      SELECT txi.vlrdtaxa
      FROM craptxi txi
      WHERE txi.cddindex = 6
        AND txi.dtiniper = pr_datataxa
        AND txi.dtfimper = pr_datataxa;

    rw_craptxi cr_craptxi%ROWTYPE;

  BEGIN
   
    pr_vlrdtaxa := null;

    OPEN cr_craptxi;
    FETCH cr_craptxi
      INTO rw_craptxi;
    IF cr_craptxi%NOTFOUND THEN
      CLOSE cr_craptxi;
      vr_dscritic := 'Taxa não encontrada: ' || pr_datataxa;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craptxi;
    END IF;

    pr_vlrdtaxa := rw_craptxi.vlrdtaxa;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3
                                  ,pr_compleme => 'pc_taxa_poupanca');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_taxa_poupanca: ' || SQLERRM;
  END pc_taxa_poupanca;

  PROCEDURE pc_poupanca_clc_rendimento(pr_cdcooper                  craprac.cdcooper%TYPE
                                      ,pr_nrdconta                  craprac.nrdconta%TYPE
                                      ,pr_nraplica                  craprac.nraplica%TYPE
                                      ,pr_dtaporte                  craprac.dtmvtolt%TYPE
                                      ,pr_dtaniversario             craprac.dtaniver%TYPE
                                      ,pr_cdhsnrap                  crapcpc.cdhsnrap%TYPE 
                                      ,pr_cdhsrgap                  crapcpc.cdhsrgap%TYPE 
                                      ,pr_vlrentabilidade_acumulada OUT NUMBER
                                      ,pr_cdcritic                  OUT PLS_INTEGER
                                      ,pr_dscritic                  OUT VARCHAR2) IS
    
    vr_dtinicio_rentab          DATE;
    vr_dtfim_rentab             DATE;
    vr_dtprimeiroaniversario    DATE := NULL;
    vr_qtaniversariosdecorridos NUMBER := 0;
    vr_dtinicioperiodorentab    DATE := NULL;
    vr_txinicioperiodorentab    NUMBER := 0;
    vr_vlindicecorrecao         NUMBER := 0;
    vr_vlaporte_periodo         craplac.vllanmto%TYPE;
    vr_vlresgate_periodo        craplac.vllanmto%TYPE;
    vr_vlbasecalculo            NUMBER;
    vr_vlbasecalculo_corrigida  NUMBER;    
    vr_cdcritic crapcri.cdcritic%TYPE := 0;
    vr_dscritic crapcri.dscritic%TYPE := NULL;
    vr_exc_saida EXCEPTION;
    
  BEGIN
    
    vr_dtprimeiroaniversario := fn_proximo_aniv_poupanca(trunc(pr_dtaporte));
    
    vr_qtaniversariosdecorridos := trunc(months_between(pr_dtaniversario, vr_dtprimeiroaniversario)) + 1;
    
    pr_vlrentabilidade_acumulada := 0;
    vr_vlbasecalculo             := 0;
    vr_vlbasecalculo_corrigida   := 0;
        
    FOR i IN REVERSE 1 .. vr_qtaniversariosdecorridos
    LOOP
      
      vr_dtinicioperiodorentab := add_months(pr_dtaniversario, (-i));
              
      IF i = vr_qtaniversariosdecorridos THEN
        
        vr_dtinicio_rentab := pr_dtaporte;
        
        vr_dtfim_rentab := vr_dtprimeiroaniversario - 1;
        
      ELSE
        
        vr_dtinicio_rentab := vr_dtinicioperiodorentab;
        vr_dtfim_rentab := add_months(pr_dtaniversario, (-i + 1)) - 1;
        
      END IF;
      
      vr_vlaporte_periodo := 0;
      pc_lanctos_historicos_periodo(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_cdhistor => pr_cdhsnrap
                                   ,pr_dtinicio => vr_dtinicio_rentab
                                   ,pr_dtfim    => vr_dtfim_rentab
                                   ,pr_vltotmto => vr_vlaporte_periodo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_vlresgate_periodo := 0;
      
      pc_lanctos_historicos_periodo(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nraplica => pr_nraplica
                                   ,pr_cdhistor => pr_cdhsrgap
                                   ,pr_dtinicio => vr_dtinicio_rentab
                                   ,pr_dtfim    => vr_dtfim_rentab
                                   ,pr_vltotmto => vr_vlresgate_periodo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_vlbasecalculo           := vr_vlbasecalculo +
                                    (nvl(vr_vlaporte_periodo, 0) - nvl(vr_vlresgate_periodo, 0));
      vr_vlbasecalculo_corrigida := vr_vlbasecalculo_corrigida +
                                    (nvl(vr_vlaporte_periodo, 0) - nvl(vr_vlresgate_periodo, 0));
      
      vr_txinicioperiodorentab := 0;
      
      pc_taxa_poupanca(pr_datataxa => vr_dtinicioperiodorentab
                      ,pr_vlrdtaxa => vr_txinicioperiodorentab
                      ,pr_cdcritic => vr_cdcritic
                      ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_vlindicecorrecao := (1 + (vr_txinicioperiodorentab / 100));
      
      vr_vlbasecalculo_corrigida := vr_vlbasecalculo_corrigida * vr_vlindicecorrecao;
      
    END LOOP;
    
    pr_vlrentabilidade_acumulada := vr_vlbasecalculo_corrigida - vr_vlbasecalculo;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 3, pr_compleme => 'pc_taxa_poupanca');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_poupanca_clc_rendimento: ' || SQLERRM;
  END pc_poupanca_clc_rendimento;
      
  FUNCTION fn_pode_rentabilizar_poupanca(pr_cdcooper IN  craprac.cdcooper%TYPE
                                        ,pr_dtaniver IN  craprac.dtaniver%TYPE
                                        ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE) RETURN INTEGER IS

     vr_dtaniver         DATE := trunc(pr_dtaniver);
     vr_dtmvtolt         DATE := trunc(pr_dtmvtolt);
     vr_proximo_dia_util DATE;

     vr_exc_data_errada exception;

  BEGIN

    BEGIN
      
      IF vr_dtmvtolt >= vr_dtaniver THEN
        RETURN 1;
      END IF;

      vr_proximo_dia_util := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => (vr_dtmvtolt+1));

      if trim(to_char(vr_dtmvtolt,'mm')) <> trim(to_char(vr_proximo_dia_util,'mm')) then

        if vr_dtaniver > vr_dtmvtolt and trim(to_char(vr_dtaniver,'mm')) = trim(to_char(vr_dtmvtolt,'mm')) then
          RETURN 1;
        end if;
      end if;

      RETURN 0;

    EXCEPTION
       WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'Erro fn_pode_rentabilizar_poupanca' || SQLERRM);
         RAISE vr_exc_data_errada;

    END;

  END fn_pode_rentabilizar_poupanca;
  
  PROCEDURE pc_lanctos_historicos(pr_cdcooper  IN  craplac.cdcooper%TYPE
                                 ,pr_nrdconta  IN  craplac.nrdconta%TYPE
                                 ,pr_nraplica  IN  craplac.nraplica%TYPE
                                 ,pr_cdhistor  IN  craplac.cdhistor%TYPE
                                 ,pr_vltotmto  OUT craplac.vllanmto%TYPE
                                 ,pr_cdcritic  OUT PLS_INTEGER
                                 ,pr_dscritic  OUT VARCHAR2) IS

    vr_exc_saida EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE := 0;
    vr_dscritic  crapcri.dscritic%TYPE := NULL;

    CURSOR cr_craplac IS
      SELECT nvl(sum(lac.vllanmto), 0) AS vltotmto
      FROM craplac lac
      WHERE lac.cdcooper = pr_cdcooper
        AND lac.nrdconta = pr_nrdconta
        AND lac.nraplica = pr_nraplica
        AND lac.cdhistor = pr_cdhistor;

    rw_craplac cr_craplac%ROWTYPE;

  BEGIN

    OPEN cr_craplac;
    FETCH cr_craplac
      INTO rw_craplac;
    IF cr_craplac%NOTFOUND THEN
      CLOSE cr_craplac;
      vr_dscritic := 'Histórico não encontrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac;
    END IF;

    pr_vltotmto := rw_craplac.vltotmto;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        vr_cdcritic := vr_cdcritic;
        vr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                  ,pr_compleme => 'pc_lanctos_historicos');
      vr_cdcritic := vr_cdcritic;
      vr_dscritic := 'Erro geral em pc_lanctos_historicos: ' || SQLERRM;
  END pc_lanctos_historicos;
    PROCEDURE pc_saldo_atual_poupanca(pr_cdcooper IN craprac.cdcooper%TYPE 
                                   ,pr_nrdconta IN craprac.nrdconta%TYPE 
                                   ,pr_nraplica IN craprac.nraplica%TYPE 
                                   ,pr_vlaplica IN craprac.vlaplica%TYPE 
                                   ,pr_cdprodut IN crapcpc.cdprodut%type 
                                   ,pr_idcalren IN PLS_INTEGER DEFAULT 0 
                                   ,pr_idtipbas IN PLS_INTEGER           
                                   ,pr_vlbascal IN  NUMBER               
                                   ,pr_vlsldtot OUT NUMBER               
                                   ,pr_vlsldrgt OUT NUMBER               
                                   ,pr_vlultren OUT NUMBER               
                                   ,pr_vlrentot OUT NUMBER               
                                   ,pr_vlrevers OUT NUMBER               
                                   ,pr_vlrdirrf OUT NUMBER               
                                   ,pr_percirrf OUT NUMBER               
                                   ,pr_cdcritic OUT PLS_INTEGER          
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    DECLARE

      vr_vlrentabilidade_acumulada NUMBER;

      vr_provisao     NUMBER(20,8) := 0; 
      vr_reversao     NUMBER(20,8) := 0; 
      vr_rendimento   NUMBER(20,8) := 0; 

      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     crapcri.dscritic%TYPE;
      vr_exc_saida    EXCEPTION;


      CURSOR cr_crapcpc IS
       SELECT cpc.cdhsprap, 
              cpc.cdhsrvap, 
              cpc.cdhsrdap, 
              cpc.cdhsrgap,
              cpc.cdhsnrap
         FROM crapcpc cpc
        WHERE cpc.cdprodut = pr_cdprodut;
      rw_crapcpc cr_crapcpc%ROWTYPE;


      CURSOR cr_craprac IS
        SELECT cdcooper, nrdconta, nraplica, dtmvtolt, dtaniver, vlsldatl
        FROM craprac
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
          AND nraplica = pr_nraplica;
      rw_craprac cr_craprac%ROWTYPE;


      CURSOR cr_crapdat IS
        SELECT dtmvtolt
        FROM crapdat
        WHERE cdcooper = pr_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;


    BEGIN
      vr_cdcritic := NULL;
      
      OPEN cr_crapdat;
      FETCH cr_crapdat
        INTO rw_crapdat;
      IF cr_crapdat%NOTFOUND THEN
        CLOSE cr_crapdat;
        vr_dscritic := 'Erro ao buscar a data de movimento.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapdat;
      END IF;
      
      OPEN cr_craprac;
      FETCH cr_craprac
        INTO rw_craprac;
      IF cr_craprac%NOTFOUND THEN
        CLOSE cr_craprac;
        vr_dscritic := 'Aplicação não encontrada para a conta.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craprac;
      END IF;

      OPEN cr_crapcpc;
      FETCH cr_crapcpc
        INTO rw_crapcpc;
      IF cr_crapcpc%NOTFOUND THEN
        CLOSE cr_crapcpc;
        vr_dscritic := 'Produto não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapcpc;
      END IF;

      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsprap
                           ,pr_vltotmto  => vr_provisao
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsrvap
                           ,pr_vltotmto  => vr_reversao
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pc_lanctos_historicos(pr_cdcooper  => pr_cdcooper
                           ,pr_nrdconta  => pr_nrdconta
                           ,pr_nraplica  => pr_nraplica
                           ,pr_cdhistor  => rw_crapcpc.cdhsrdap
                           ,pr_vltotmto  => vr_rendimento
                           ,pr_cdcritic  => vr_cdcritic
                           ,pr_dscritic  => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      pr_vlultren := 0;
     
      IF fn_pode_rentabilizar_poupanca(pr_cdcooper => pr_cdcooper
                                      ,pr_dtaniver =>  rw_craprac.dtaniver
                                      ,pr_dtmvtolt =>  rw_crapdat.dtmvtolt) = 1 THEN

         IF pr_idcalren = 1 THEN
            pc_poupanca_clc_rendimento(pr_cdcooper                  => rw_craprac.cdcooper
                                      ,pr_nrdconta                  => rw_craprac.nrdconta
                                      ,pr_nraplica                  => rw_craprac.nraplica
                                      ,pr_dtaporte                  => rw_craprac.dtmvtolt
                                      ,pr_dtaniversario             => rw_craprac.dtaniver
                                      ,pr_cdhsnrap                  => rw_crapcpc.cdhsnrap
                                      ,pr_cdhsrgap                  => rw_crapcpc.cdhsrgap
                                      ,pr_vlrentabilidade_acumulada => vr_vlrentabilidade_acumulada
                                      ,pr_cdcritic                  => vr_cdcritic
                                      ,pr_dscritic                  => vr_dscritic);

            pr_vlultren := round(nvl(vr_vlrentabilidade_acumulada,0) - nvl(vr_rendimento,0),2);
         END IF;

         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;

      END IF;

      pr_vlsldtot := pr_vlaplica + pr_vlultren;

      pr_vlsldrgt := pr_vlsldtot;

      pr_vlrentot := vr_rendimento;

      pr_vlrevers := vr_provisao - vr_reversao;

      IF pr_idtipbas = 1 THEN

        pr_vlrentot := trunc(pr_vlrentot * pr_vlbascal / rw_craprac.vlsldatl,2);

        
        pr_vlrevers := trunc(pr_vlrevers * pr_vlbascal / rw_craprac.vlsldatl,2);

      END IF;
     
     
      pr_vlrdirrf := 0;

    
      pr_percirrf := 0;

    EXCEPTION
      WHEN vr_exc_saida THEN
        vr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'pc_saldo_atual_poupanca');
        vr_dscritic := 'Erro nao tratado na pc_saldo_atual_poupanca. ' || SQLERRM;
    END;
  END pc_saldo_atual_poupanca;
  

BEGIN
   
 
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimp1       
                          ,pr_tipabert => 'W'                
                          ,pr_utlfileh => vr_ind_arquiv1     
                          ,pr_des_erro => vr_dscritic);      
  

  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        
                          ,pr_nmarquiv => vr_nmarqimp        
                          ,pr_tipabert => 'W'                
                          ,pr_utlfileh => vr_ind_arquiv      
                          ,pr_des_erro => vr_dscritic);      
                          

  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
                         
  FOR rw_crapcpc IN cr_crapcpc LOOP                        
      vidtxfixa := rw_crapcpc.idtxfixa;  
      vcddindex := rw_crapcpc.cddindex;  
  END LOOP;
  
  FOR  rw_crapdat in cr_crapdat LOOP 
  
      FOR rw_craprac in cr_craprac(rw_crapdat.cdcooper) LOOP
       
        BACKUP('UPDATE CRAPRAC SET DTANIVER = ''01/02/2022'' WHERE CDCOOPER = '||rw_craprac.cdcooper ||' AND '||' NRDCONTA = '||rw_craprac.nrdconta|| ' AND NRAPLICA = '||rw_craprac.nraplica||';'); 
        loga ('cdcooper ; '||rw_craprac.cdcooper||' ; '||'nrdconta ; '||rw_craprac.nrdconta || ' ; '|| 'nraplica ; '||rw_craprac.nraplica) ;                          
        UPDATE craprac craprac 
           SET craprac.dtaniver = to_date('01/02/2022','dd/mm/yyyy') 
         WHERE craprac.cdcooper = rw_craprac.cdcooper
           AND craprac.nrdconta = rw_craprac.nrdconta
           AND craprac.nraplica = rw_craprac.nraplica;
           

      pr_vlsldtot := 0;
      pr_vlsldrgt := 0;
      vr_vlultren := 0;
      pr_vlrentot := 0;
      pr_vlrevers := 0;
      pr_vlrdirrf := 0;
      pr_percirrf := 0;


            pc_saldo_atual_poupanca(pr_cdcooper => rw_craprac.cdcooper,           
                                             pr_nrdconta => rw_craprac.nrdconta,  
                                             pr_nraplica => rw_craprac.nraplica,   
                                             pr_vlaplica => rw_craprac.vlsldatl,   
                                             pr_cdprodut => rw_craprac.cdprodut,   
                                             pr_idtipbas => 2,
                                             pr_idcalren => 1,
                                             pr_vlbascal => rw_craprac.vlbasapl,   
                                             pr_vlsldtot => pr_vlsldtot,           
                                             pr_vlsldrgt => pr_vlsldrgt,           
                                             pr_vlultren => vr_vlultren,           
                                             pr_vlrentot => pr_vlrentot,           
                                             pr_vlrevers => pr_vlrevers,           
                                             pr_vlrdirrf => pr_vlrdirrf,           
                                             pr_percirrf => pr_percirrf,           
                                             pr_cdcritic => vr_cdcritic,           
                                             pr_dscritic => vr_dscritic);               

                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    RAISE vr_excsaida;
                  END IF;
                    
                  vr_negativo := false;
                  vr_cdhistor := rw_crapcpc.cdhsprap;
                                     
                  IF vr_vlultren <= 0 THEN
                    
                    BACKUP('Conta com rendimento negativo->'||rw_craprac.nrdconta);
                    CONTINUE;
                  END IF;
           
                LANC0001.pc_gerar_lancamento_conta( pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => 1 
                                                   ,pr_cdbccxlt => 100 
                                                   ,pr_nrdolote => 8599
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nrdctabb => rw_craprac.nrdconta
                                                   ,pr_nrdocmto => rw_craprac.nraplica 
                                                   ,pr_nrseqdig => vr_nrseqdig
                                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                   ,pr_vllanmto => vr_vlultren         
                                                   ,pr_cdhistor => 362
                                                   ,pr_nraplica => rw_craprac.nraplica

                                                   ,pr_tab_retorno => vr_tab_retorno
                                                   ,pr_incrineg => vr_incrineg
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
                                                   
            IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN                              
                  vr_cdcritic := 0;
                  vr_dscritic := 'Erro ao inserir registro de lancamento de credito. Erro: ' || SQLERRM;
                  RAISE vr_excsaida;
            END IF; 
            
            vr_nrseqdig := vr_nrseqdig + 1;                                                                                                                                                                

      END LOOP;
      
  END LOOP;
    
  COMMIT;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
  
  EXCEPTION 
     WHEN vr_excsaida then  
         backup('ERRO ' || vr_dscritic);  
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1);    
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         backup('ERRO ' || vr_dscritic); 
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
         gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
         ROLLBACK; 

END;

