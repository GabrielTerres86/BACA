DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';  
   vr_nmarqimp1            VARCHAR2(100)  := 'backup2.txt';
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
   -- Variáveis de retorno
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
             cpc.cdhsvrcc
        FROM craprac rac,
             craplac lac,
             crapcpc cpc
       WHERE rac.cdcooper = lac.cdcooper
         AND rac.nrdconta = lac.nrdconta
         AND rac.nraplica = lac.nraplica
         AND rac.cdprodut = cpc.cdprodut 
         AND rac.dtaniver = to_date('01/02/2022','dd/mm/yyyy') --Aniversário errado
         AND rac.dtmvtolt >= to_date('29/11/2021','dd/mm/yyyy') AND rac.dtmvtolt <= to_date('30/11/2021','dd/mm/yyyy') -- Data de movimento do aporte
         AND lac.dtmvtolt >= to_date('01/01/2022','dd/mm/yyyy')
         AND rac.cdcooper = pr_cdcooper -- cooperativas Viacredi e Alto Vale
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
  
   PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;  
   
BEGIN
   
  -- Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp1       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro  
  
  -- Em caso de crítica
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
                                    
        UPDATE craprac craprac 
           SET craprac.dtaniver = to_date('01/01/2022','dd/mm/yyyy') 
         WHERE craprac.cdcooper = rw_craprac.cdcooper
           AND craprac.nrdconta = rw_craprac.nrdconta
           AND craprac.nraplica = rw_craprac.nraplica;  
                 
           APLI0006.pc_posicao_saldo_aplicacao_pos( pr_cdcooper => rw_craprac.cdcooper,
                                                                  pr_nrdconta => rw_craprac.nrdconta,
                                                                  pr_nraplica => rw_craprac.nraplica,
                                                                  pr_dtiniapl => rw_craprac.dtmvtolt,
                                                                  pr_txaplica => rw_craprac.txaplica,
                                                                  pr_idtxfixa => vidtxfixa,
                                                                  pr_cddindex => vcddindex,
                                                                  pr_qtdiacar => rw_craprac.qtdiacar,
                                                                  pr_idgravir => vr_idgravir,
                                                                  pr_flgcaren => 2, -- IMPORTANTE: O valor 2 indica que deve ser calculada a rentabilidade da poupança
                                                                  pr_idaplpgm => 0,                   -- Aplicação Programada  (0-Não/1-Sim)
                                                                  pr_dtinical => to_date('01/01/2022','dd/mm/yyyy'),
                                                                  pr_dtfimcal => to_date('01/01/2022','dd/mm/yyyy'),
                                                                  pr_idtipbas => vr_idtipbas,
                                                                  pr_incalliq => 0,                   --> Nao calcula saldo liquido
                                                                  -- OUT
                                                                  pr_vlbascal => vr_vlbascal,                                                              
                                                                  pr_vlsldtot => vr_vlsldtot,
                                                                  pr_vlsldrgt => vr_vlsldrgt,
                                                                  pr_vlultren => vr_vlultren,
                                                                  pr_vlrentot => vr_vlrentot,
                                                                  pr_vlrevers => vr_vlrevers,
                                                                  pr_vlrdirrf => vr_vlrdirrf,
                                                                  pr_percirrf => vr_percirrf,
                                                                  pr_cdcritic => vr_cdcritic,
                                                                  pr_dscritic => vr_dscritic);    
           
           -- tratamento para possiveis erros gerados pelas rotinas anteriores
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    RAISE vr_excsaida;
                  END IF;
                    
                  vr_negativo := false;
                  vr_cdhistor := rw_crapcpc.cdhsprap;
                    
                  -- se rendimento for negativo
                  IF vr_vlultren <= 0 THEN
                    -- remove o sinal e usa o historico de reversao de provisao
                    
                    CONTINUE;
                  END IF;
           
            -- LANÇA A RENTABILIDADE EM CONTA CORRENTE 
                LANC0001.pc_gerar_lancamento_conta( pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_cdagenci => 1 
                                                   ,pr_cdbccxlt => 100 
                                                   ,pr_nrdolote => 8599
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nrdctabb => rw_craprac.nrdconta
                                                   ,pr_nrdocmto => rw_craprac.nraplica --nraplica
                                                   ,pr_nrseqdig => vr_nrseqdig
                                                   ,pr_dtrefere => rw_crapdat.dtmvtolt
                                                   ,pr_vllanmto => vr_vlultren         -- Valor do resgate
                                                   ,pr_cdhistor => 362
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   -- OUTPUT --
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
  
  fecha_arquivos;
  
  EXCEPTION 
     WHEN vr_excsaida then  
         backup('ERRO ' || vr_dscritic);  
         fecha_arquivos;  
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         backup('ERRO ' || vr_dscritic); 
         fecha_arquivos; 
         ROLLBACK; 

END;
