PL/SQL Developer Test script 3.0
170
-- Created on 05/01/2021 by F0031800 
declare 
  wpr_cdcooper NUMBER                := 2;
  wpr_flgrelat NUMBER                := 1; -- 1 para somente relatórios, ou 0 para completo (integra Cyber).
  wpr_dtmvtolt DATE                  := to_date('31/12/2020','dd/mm/yyyy');
  wpr_dtmvtoan DATE;
  wpr_dtmvtopr DATE;
  vr_cdprogra  crapprg.cdprogra%TYPE := 'CRPS280';
  
  vr_exc_saida EXCEPTION;
  vr_cdcritic  crapcri.cdcritic%TYPE;
  vr_dscritic  VARCHAR2(2000);
  vr_stprogra  PLS_INTEGER; 
  vr_infimsol  PLS_INTEGER; 
  vr_vltotprv  NUMBER(14,2); 
  vr_vltotdiv  NUMBER(14,2); 

  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nrctactl
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT wpr_dtmvtolt dtmvtolt
          ,wpr_dtmvtopr dtmvtopr
          ,wpr_dtmvtoan dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,wpr_dtmvtolt dtmvtocd
          ,trunc(wpr_dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(wpr_dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(wpr_dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(wpr_dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  CURSOR cr_crapfer(pr_dtferiad IN crapfer.dtferiad%TYPE) IS
    SELECT *
      FROM crapfer
     WHERE crapfer.cdcooper = wpr_cdcooper
       AND crapfer.dtferiad = pr_dtferiad;
  rw_crapfer cr_crapfer%ROWTYPE;
  
  FUNCTION fn_calcular_data(pr_dtcalculo IN DATE,
                            pr_flgant    IN BOOLEAN,
                            pr_flgprx    IN BOOLEAN) RETURN DATE AS
    vr_dtctrl DATE := pr_dtcalculo;
    vr_sair   BOOLEAN := FALSE;
  BEGIN
    LOOP                     
      IF pr_flgant THEN
        vr_dtctrl := vr_dtctrl - 1;  
      ELSIF pr_flgprx THEN
        vr_dtctrl := vr_dtctrl + 1;  
      END IF;
                              
      OPEN cr_crapfer(pr_dtferiad => vr_dtctrl);
      FETCH cr_crapfer INTO rw_crapfer;      
      IF ( (to_char(vr_dtctrl,'D') <> '1') AND
           (to_char(vr_dtctrl,'D') <> '7') AND
           cr_crapfer%NOTFOUND ) THEN           
           vr_sair := TRUE;           
      END IF;
      CLOSE cr_crapfer;                                                             
      EXIT WHEN vr_sair = TRUE;                                          
    END LOOP; 
    
    RETURN vr_dtctrl; 
  
  END fn_calcular_data;
      
      
BEGIN  
  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS280'
                            ,pr_action => null);

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper => wpr_cdcooper);
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
     -- Fechar o cursor pois haveria raise
     CLOSE cr_crapcop;
     -- Montar mensagem de critica
     vr_cdcritic := 651;
     RAISE vr_exc_saida;
  ELSE
     -- Apenas fechar o cursor
     CLOSE cr_crapcop;
  END IF;
  
  -- calcular datas conforme o parametro.
  wpr_dtmvtoan := fn_calcular_data(wpr_dtmvtolt,true,false);
  wpr_dtmvtopr := fn_calcular_data(wpr_dtmvtolt,false,true);
  
  -- Leitura do calendário da cooperativa
  OPEN cr_crapdat(pr_cdcooper => wpr_cdcooper);
  FETCH cr_crapdat
   INTO rw_crapdat;
  -- Se não encontrar
  IF cr_crapdat%NOTFOUND THEN
     -- Fechar o cursor pois efetuaremos raise
     CLOSE cr_crapdat;
     -- Montar mensagem de critica
     vr_cdcritic := 1;
     RAISE vr_exc_saida;
  ELSE
     -- Apenas fechar o cursor
     CLOSE cr_crapdat;
  END IF;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => wpr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => vr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  IF vr_cdcritic <> 0 THEN
     RAISE vr_exc_saida;
  END IF;
        
  dbms_output.put_line('Realizando geração dos relatórios 227 e 354...'); 
  dbms_output.put_line('...'); 
  
  -- Test statements here
  cecred.pc_crps280_i_wag( pr_cdcooper   => wpr_cdcooper        --> Coop. conectada
                          ,pr_rw_crapdat => rw_crapdat          --> Vetor com calendário
                          ,pr_dtrefere   => rw_crapdat.dtultdia --> Data ref - Ultimo dia mês corrente
                          ,pr_cdprogra   => vr_cdprogra         --> Codigo programa conectado
                          ,pr_dsdircop   => rw_crapcop.dsdircop --> Diretório base da cooperativa
                          ,pr_flgresta   => NULL                --> Sem restart
                          ,pr_flgrelat   => wpr_flgrelat        --> Somente relatórios?
                          ----
                          ,pr_stprogra  => vr_stprogra          --> Saída de termino da execução
                          ,pr_infimsol  => vr_infimsol          --> Saída de termino da solicitação                                               
                          ----
                          ,pr_vltotprv   => vr_vltotprv         --> Total acumulado de provisÃ£o
                          ,pr_vltotdiv   => vr_vltotdiv         --> Total acumulado de dívida
                          ,pr_cdcritic   => vr_cdcritic         --> Código de erro encontrado
                          ,pr_dscritic   => vr_dscritic);       --> Descrição de erro encontrado                  
  IF vr_cdcritic >0 OR vr_dscritic IS NOT NULL THEN
    dbms_output.put_line('Erro pc_crps280_i_wag. Descrição: '||vr_cdcritic||' e '||vr_dscritic);
  ELSE
    dbms_output.put_line('..');
    dbms_output.put_line('.');
    dbms_output.put_line('Sucesso na execução da pc_crps280_i_wag.'); 
  END IF;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    dbms_output.put_line('Erro geral. Descrição: '||vr_cdcritic||' e '||vr_dscritic); 
    
    ROLLBACK;
END;
0
0
