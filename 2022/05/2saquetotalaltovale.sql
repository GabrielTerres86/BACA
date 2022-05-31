DECLARE
   vr_excsaida             EXCEPTION;
   vr_cdcritic             crapcri.cdcritic%TYPE;
   vr_dscritic             VARCHAR2(5000) := ' ';  
   vr_nmarqimp1            VARCHAR2(100)  := 'loglancav.txt';
   vr_ind_arquiv1          utl_file.file_type;   
   vr_rootmicros           VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
   vr_nmdireto             VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/335378inc133992';        
   vr_negativo             BOOLEAN;
   vr_tab_retorno          LANC0001.typ_reg_retorno;
   vr_incrineg             INTEGER;
   vr_nrseqdig             NUMBER := 0;

   CURSOR cr_craprac is
    with
      analise as (
      SELECT rac.progress_recid
            ,rac.cdcooper
            ,rac.cdprodut
            ,rac.nrdconta
            ,rac.nraplica
            ,rac.dtmvtolt
            ,rac.dtaniver
            ,rac.vlaplica
            ,rac.idsaqtot
            ,rac.vlsldatl
            ,rac.dtatlsld
            ,nvl((SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) AS "Valor"
       FROM cecred.craphis his,
            cecred.craplac lac
      WHERE his.cdhistor = lac.cdhistor
        AND his.cdcooper = lac.cdcooper
        AND lac.nraplica = rac.nraplica
        AND lac.nrdconta = rac.nrdconta
        AND lac.cdcooper = rac.cdcooper
        )
        ,0) valor
    FROM cecred.craprac rac
   WHERE rac.idsaqtot = 1
     AND rac.dtmvtolt in ('27/10/2021', '28/09/2021',
                          '26/10/2021', '28/10/2021',
                          '29/11/2021', '30/11/2021',
                          '26/01/2022', '27/01/2022',
                          '28/01/2022', '28/12/2021')

     AND rac.cdprodut = 1109
     AND rac.cdcooper = 16)
  SELECT t.* 
    FROM cecred.analise t 
   WHERE t.valor > 0;         
  rw_craprac cr_craprac%ROWTYPE;        
   
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
     
   PROCEDURE loglanc (pr_msg VARCHAR2) IS
   BEGIN
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
   END; 
  
   PROCEDURE fecha_arquivos IS
   BEGIN
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv1); 
   END;  
   
BEGIN
   
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto      
                          ,pr_nmarquiv => vr_nmarqimp1      
                          ,pr_tipabert => 'W'              
                          ,pr_utlfileh => vr_ind_arquiv1  
                          ,pr_des_erro => vr_dscritic);      
  

  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

      
  IF btch0001.cr_crapdat%NOTFOUND THEN        
    CLOSE btch0001.cr_crapdat;
    RAISE vr_excsaida;
  ELSE      
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  FOR rw_craprac IN cr_craprac LOOP  
     
    IF (rw_craprac.cdcooper = 1  AND rw_craprac.nrdconta = 8729158 AND rw_craprac.nraplica = 113) OR
       (rw_craprac.cdcooper = 16 AND rw_craprac.nrdconta = 2063131 AND rw_craprac.nraplica = 33)  THEN
      
      CONTINUE;
    END IF;

    loglanc('cdcooper; '||rw_craprac.cdcooper||' ;nrdconta; '||rw_craprac.nrdconta||' ;aplicacao; '||rw_craprac.nraplica||' ;lancamento; '||rw_craprac.valor);
    APLI0012.pc_lcto_poupanca(pr_cdcooper => rw_craprac.cdcooper
                             ,pr_nrdconta => rw_craprac.nrdconta
                             ,pr_nraplica => rw_craprac.nraplica
                             ,pr_cdhistor => 3531
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_vllanmto => rw_craprac.valor
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro creditando aniversario poupança - ' || NVL(vr_dscritic,' ');
      RAISE vr_excsaida;
    END IF; 
      
    BEGIN     
      UPDATE cecred.craprac rac
         SET dtatlsld = rw_crapdat.dtmvtolt
       WHERE nrdconta = rw_craprac.nrdconta
         AND nraplica = rw_craprac.nraplica
         AND cdcooper = rw_craprac.cdcooper;     
    END;
                               
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
                                       ,pr_vllanmto => rw_craprac.valor
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
          
  COMMIT;
  
  fecha_arquivos;
  
  EXCEPTION 
     WHEN vr_excsaida then  
         loglanc('ERRO ' || vr_dscritic);  
         fecha_arquivos;  
         ROLLBACK;    
     WHEN OTHERS then
         vr_dscritic :=  sqlerrm;
         loglanc('ERRO ' || vr_dscritic); 
         fecha_arquivos; 
         ROLLBACK; 

END;
