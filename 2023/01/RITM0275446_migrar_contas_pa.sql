DECLARE

  CURSOR cr_crapass is
    SELECT a.cdcooper
         , a.nrdconta
         , a.cdagenci
         , ROWID dsdrowid
      FROM CECRED.CRAPASS a
     WHERE a.cdcooper = 1
       AND a.cdagenci = 67
       AND a.progress_recid NOT IN (685257,685289,1697,2846,7605,11466,12205,13445,14718,14898
                                   ,21549,24121,24128,24135,25589,25825,26721,27550,27576,29344
                                   ,31149,31357,31695,36530,39968,40075,41408,44309,46568,48465
                                   ,50651,51823,52008,53441,54930,54938,56805,57172,57302,60137
                                   ,61505,62616,63484,64648,64887,74263,74314,74329,76205,76251
                                   ,78393,78446,80394,80496,83633,88408,89949,91164,91494,91683
                                   ,93488,95171,96555,97589,99546,102106,103115,103188,103322,107122
                                   ,108845,111485,111508,112691,113027,115561,115588,115611,118979,123000
                                   ,125636,127425,129397,129554,130034,130799,132557,132571,132595,132609
                                   ,138432,142960,146492,149114,150502,150709,150728,154827,154840,154852
                                   ,154868,154875,158522,163696,163792,168250,170707,177527,177595,177610
                                   ,177629,178642,183930,185381,186453,188166,191266,193410,195255,203711
                                   ,203755,203826,206882,208034,208050,208124,216563,217392,698383,699079
                                   ,219065,224951,237387,244155,246263,249613,251205,251947,252218,253480
                                   ,256597,258983,263836,267195,267233,267237,267251,267252,267264,267269
                                   ,267277,267284,267291,267339,267340,267650,269167,269538,269567,271043
                                   ,272158,275045,276837,279791,282042,283149,283830,285827,285835,285840
                                   ,285841,285854,285861,285876,285982,297127,299908,304074,304829,311212
                                   ,311238,311249,311252,311338,311352,311381,311383,317388,320617,320725
                                   ,326581,327431,327557,327566,327631,327634,327637,327641,327675,327685
                                   ,327724,328799,714460,333660,336562,339241,343205,348047,348048,348068
                                   ,348169,348179,348180,359738,363505,363533,559991,365503,721467,578713
                                   ,572229,573570,582131,585680,565813,604822,624032,607474,624569,652438
                                   ,650307,637379,670108,671508,676275,680696,731314,666792,733679,737831
                                   ,738239,738350,692278,692275,685819,714434,702807,697188,716757,748287
                                   ,751577,751778,752865,753478,756450,764215,766650,767187,767605,774828
                                   ,775576,775900,782899,785281,790070,790483,794302,801859,810319,816389
                                   ,824244,587245,587780,587988,588071,589115,589377,590228,590428,591974
                                   ,827054,830712,832918,833286,839162,843254,843570,852232,863272,864460
                                   ,868212,872538,872702,882913,886081,886682,894043,899588,930856,941484
                                   ,954408,961499,962862,973398,974006,989433,1002819,1004480,1005483,1014836
                                   ,1028245,1050761,1051576,1053347,1079809,1081791,1090976,1127986,1156838,1165672
                                   ,1175265,1176165,1192484,1204554,1205137,1213640,1239723,1241511,1243534,1305544
                                   ,1312010,1315608,1324384,1335617,1344052,1351870,1403043,1405192,1413144,1430113
                                   ,1442355,1468806,1482814,1520036,1521322,1540584,1551544,1555594,1567483,1575677
                                   ,1658912,1661647,1723229,1767883,1767893,1793589,1871393,1886883,368768,372982
                                   ,373068,378572,379508);
  
  CURSOR cr_altera(pr_cdcooper  NUMBER
                  ,pr_nrdconta  NUMBER
                  ,pr_dtmvtolt  DATE) IS
    SELECT t.dsaltera
         , ROWID  dsdrowid
      FROM cecred.crapalt t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtaltera = pr_dtmvtolt;
  rg_altera  cr_altera%ROWTYPE;
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/RITM0275446'; 

  vr_nmarqrol    VARCHAR2(100) := 'RITM0275446_script_rollback.sql';
  vr_nmarqlog    VARCHAR2(100) := 'RITM0275446_script_log.txt';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  
  TYPE vr_tpaltdel IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltupd IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  
  vr_tbaltdel    vr_tpaltdel;
  vr_tbaltupd    vr_tpaltupd;
  vr_cdagenew    CONSTANT NUMBER := 202;
  vr_dtmvtolt    DATE := datascooperativa(1).dtmvtolt;
  vr_lgrowid     ROWID;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(2000);
  vr_exc_erro    EXCEPTION;
  
  
BEGIN
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqlog   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqlog   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqlog||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqrol   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqrol   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 

  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                       ,pr_des_text => 'Inicio do script'); 
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN'); 

  
  FOR conta IN cr_crapass LOOP
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Alterando PA da conta: '||conta.nrdconta); 
  
    BEGIN 
      UPDATE CECRED.crapass t 
         SET t.cdagenci = vr_cdagenew
           , t.dtultalt = vr_dtmvtolt
       WHERE ROWID      = conta.dsdrowid;
        
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                           ,pr_des_text => '  UPDATE cecred.crapass SET cdagenci = '||to_char(conta.cdagenci)||'  WHERE rowid = '''||conta.dsdrowid||'''; ');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar saldo dia: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    gene0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => 'Altera dados da Conta Corrente'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ''
                        ,pr_nrdconta => conta.nrdconta
                        ,pr_nrdrowid => vr_lgrowid);
      
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                             ,pr_nmdcampo => 'cdagenci'
                             ,pr_dsdadant => conta.cdagenci
                             ,pr_dsdadatu => vr_cdagenew);
  
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                             ,pr_nmdcampo => 'dtultalt'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => vr_dtmvtolt);
    
    OPEN  cr_altera(conta.cdcooper,conta.nrdconta,vr_dtmvtolt);
    FETCH cr_altera INTO rg_altera;
      
    IF cr_altera%NOTFOUND THEN
        
      BEGIN
        INSERT INTO cecred.crapalt
                           (nrdconta
                           ,dtaltera
                           ,cdoperad
                           ,dsaltera
                           ,tpaltera
                           ,cdcooper)
                    VALUES (conta.nrdconta
                           ,vr_dtmvtolt
                           ,'1'
                           ,'PA '||conta.cdagenci||'-'||vr_cdagenew||','
                           ,2
                           ,conta.cdcooper) RETURNING ROWID INTO rg_altera.dsdrowid;
          
        IF NOT vr_tbaltdel.EXISTS(rg_altera.dsdrowid) THEN
          vr_tbaltdel(rg_altera.dsdrowid) := 'DELETE cecred.crapalt WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
        END IF;     
                      
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20003,'Erro ao incluir registro na ALTERA: '||SQLERRM);
      END;
        
    ELSE
        
      BEGIN
        UPDATE cecred.crapalt
           SET dsaltera = rg_altera.dsaltera||'PA '||conta.cdagenci||'-'||vr_cdagenew||','
         WHERE ROWID    = rg_altera.dsdrowid;
          
          IF NOT vr_tbaltupd.EXISTS(rg_altera.dsdrowid) THEN
            vr_tbaltupd(rg_altera.dsdrowid) := 'UPDATE cecred.crapalt SET dsaltera = '''||rg_altera.dsaltera||''' WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
          END IF;
                           
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20004,'Erro ao atualizar registro na ALTERA: '||SQLERRM);
        END;
        
    END IF;
      
    CLOSE cr_altera;
    
  END LOOP;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => '  COMMIT;');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => 'END;');
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog ,pr_des_text => 'Fim do script.'); 
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20001, vr_dscritic);
    
  WHEN OTHERS THEN
    ROLLBACK;
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
