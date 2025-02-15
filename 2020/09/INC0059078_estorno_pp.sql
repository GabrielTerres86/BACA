

DECLARE

    vr_vlrsldpp    NUMBER(20,8);
    vr_dtmvtolt    craprpp.dtiniper%TYPE;
    vr_txperiod    NUMBER(20,8);
    vr_taxaddia    NUMBER(20,8);
    vr_idx_craptxi VARCHAR(008);
    vr_vlsldtot    NUMBER(20,8) := 0;
    vr_vlrendim    NUMBER(20,8) := 0;
    vr_vlslfina    NUMBER(20,8) := 0;
    vr_vlinicio    NUMBER(20,8) := 0;
    valorir        NUMBER(20,8) := 0;
    vr_qtdiasir    PLS_INTEGER;
    vr_perciirf    NUMBER(12,8);
    pr_percirrf    NUMBER(12,8);
    vr_valorend    NUMBER(20,8);
    vr_nrdolote    NUMBER(4);
    vr_cdhistor    NUMBER(4);
    pr_vlsdrdpp    NUMBER(25,8);
    vr_txaplica    NUMBER(25,8);
    vr_txaplmes    NUMBER(25,8);
    vr_dtdolote    DATE;
    vr_nrseqdig    craplot.nrseqdig%TYPE;
    vr_cdbccxlt    craplot.cdbccxlt%TYPE := 100;
    vr_cdagenci    craplot.cdagenci%TYPE := 1;
    vr_cdbccxl2    NUMBER(4) := 200;
    vr_codproduto        PLS_INTEGER := 1007; -- Codigo da aplicacao programada 
    vr_nrseqted    crapmat.nrseqted%type;
    vr_vldifpro    NUMBER(25,8);
    vr_vlajuste    NUMBER(20,2);
    vr_vlajuste_cr NUMBER(25,8);
    vr_vlajuste_db NUMBER(25,8);
    vr_vlresgat    NUMBER(25,2);
    
    vr_dscritic   VARCHAR2(5000) := ' ';
    vr_cdcritic   NUMBER(5);
    vr_excsaida   EXCEPTION;
    vr_exc_saida  EXCEPTION;
                
    TYPE typ_tab_craptxi IS
      TABLE OF NUMBER(18,8)
      INDEX BY VARCHAR2(8); 
   vr_nmarqimp4       VARCHAR2(100)  := 'backup2.txt';
    vr_ind_arquiv4     utl_file.file_type;
   
    vr_nmarqimp5       VARCHAR2(100)  := 'erro2.txt';
    vr_ind_arquiv5     utl_file.file_type;
    
    
    vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
    vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0059078_migracao';     

    rw_craplot_rvt lote0001.cr_craplot_sem_lock%rowtype;  
    vr_tab_craptxi typ_tab_craptxi;
    rw_craplot     lote0001.cr_craplot_sem_lock%ROWTYPE;
    vr_tab_care    apli0005.typ_tab_care;
    vr_nraplica    craprac.nraplica%TYPE;
    vr_tab_retorno lanc0001.typ_reg_retorno;
    vr_incrineg    NUMBER;
    vr_craplpp_rowid ROWID;
    vr_craplac_rowid ROWID;
    vr_craplci_rowid ROWID;
    vr_crapsli_rowid ROWID;
    vr_craprpp_rowid ROWID; 
    vr_tbcotas_devolucao_rowid ROWID;  
   
   --Data do sistema
   CURSOR cr_crapdat (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT dat.dtmvtolt,
             dat.dtmvtopr,
             dat.dtmvtoan,
             dat.inproces,
             dat.qtdiaute,
             dat.cdprgant,
             dat.dtmvtocd,
             trunc(dat.dtmvtolt,'mm')               dtinimes, -- Pri. Dia Mes Corr.
             trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms, -- Pri. Dia mes Seguinte
             last_day(add_months(dat.dtmvtolt,-1))  dtultdma, -- Ult. Dia Mes Ant.
             last_day(dat.dtmvtolt)                 dtultdia, -- Utl. Dia Mes Corr.
             ROWID
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;
       rw_crapdat cr_crapdat%ROWTYPE;
       
  
   CURSOR cr_craplot ( pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_dtmvtolt IN DATE
                      ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
         SELECT craplot.rowid
               ,craplot.cdagenci
               ,craplot.cdbccxlt
               ,craplot.nrdolote
               ,craplot.nrseqdig
               ,craplot.qtinfoln
               ,craplot.qtcompln
               ,craplot.cdcooper
               ,craplot.dtmvtolt
               ,craplot.vlinfodb
               ,craplot.vlcompdb
         FROM   craplot
         WHERE  craplot.cdcooper = pr_cdcooper
         AND    craplot.dtmvtolt = pr_dtmvtolt
         AND    craplot.cdagenci = 1
         AND    craplot.cdbccxlt = 100
         AND    craplot.nrdolote = pr_nrdolote;
      rw_craplot7200  cr_craplot%ROWTYPE;       
    

         

   --Contas a serem creditadas o rendimento da poupanca programada
   CURSOR cr_aplica IS
   select  13  cdcooper,  3000   nrdconta,  63    nrctrrpp, 142.71 vlamnto,2 nraplica from dual union all
   select  7   cdcooper,  222771   nrdconta,  2159    nrctrrpp, 418.23 vlamnto,10 nraplica from dual union all 
   select  11  cdcooper,  16179    nrdconta,  483     nrctrrpp, 2000.00 vlamnto,40 nraplica from dual;
   rw_aplica cr_aplica%ROWTYPE;
  

    -----------------------------------------------------------------------------
 
  PROCEDURE fecha_arquivos IS
  BEGIN
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv4); --> Handle do arquivo aberto;   
     gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv5);
  END;
  
    procedure backup2(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv4, pr_msg);
  END;  
  
  procedure erro2 (pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv5, pr_msg);
  END; 
    
---------------INICIO    
BEGIN
  
  
/*  update craplac 
     set vllanmto = vllanmto - 2000.00 
   where progress_recid = 55978348;*/
   
  update craplpp
     set vllanmto = vllanmto - 2000.00
   where progress_recid = 97819758;
 
  update craplpp
     set vllanmto = vllanmto - 418.23
   where progress_recid = 97819498; 
 
/*  update craplac 
     set vllanmto = vllanmto - 418.23 
   where progress_recid = 55978287; */

 /* update craplac 
     set vllanmto = vllanmto - 142.71 
   where progress_recid = 55978437;*/
 
  update craplpp
     set vllanmto = vllanmto - 142.71
   where progress_recid = 97820134; 
   
 --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp4       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv4     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp5       --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv5     --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;  
  
       
  FOR rw_aplica IN cr_aplica LOOP
    OPEN cr_crapdat (pr_cdcooper => rw_aplica.cdcooper);
     FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
     
  -------------------------------------------------------   
      vr_dtdolote := rw_crapdat.dtmvtolt;
      vr_nrdolote := 8384;
      vr_cdhistor := 154;
        
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_aplica.cdcooper
                                 ,pr_dtmvtolt => vr_dtdolote
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_cdbccxlt => vr_cdbccxlt
                                 ,pr_nrdolote => vr_nrdolote
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 14
                                 ,pr_cdhistor => 0
                                 ,pr_craplot  => rw_craplot
                                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
         raise vr_excsaida;
      END IF;
      
   --Busca numero sequencial
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_aplica.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);

      -- Insere historico de ajuste nos lancamentos da poupanca programada
      BEGIN
        INSERT INTO craplpp (dtmvtolt,
                             cdagenci,
                             cdbccxlt,
                             nrdolote,
                             nrdconta,
                             nrctrrpp,
                             nrdocmto,
                             txaplica,
                             txaplmes,
                             cdhistor,
                             nrseqdig,
                             vllanmto,
                             dtrefere,
                             cdcooper)
                     VALUES (vr_dtdolote,
                             vr_cdagenci,
                             vr_cdbccxlt,
                             8384,
                             rw_aplica.nrdconta,
                             rw_aplica.nrctrrpp,
                             NVL(vr_nrseqdig,0),
                             0,
                             0,
                             vr_cdhistor,
                             NVL(vr_nrseqdig,0),
                            abs(rw_aplica.vlamnto),
                            vr_dtdolote,
                            rw_aplica.cdcooper)
        RETURNING
          craplpp.rowid
        INTO
          vr_craplpp_rowid;            
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir o histórico '||vr_cdhistor||' nos lançamentos da poupança programada: '||sqlerrm;          
            erro2('craplpp - Conta ' || rw_aplica.nrdconta || ' - Cooperativa: ' ||rw_aplica.cdcooper || ' - ' || vr_dscritic); 
            RAISE vr_excsaida;
      END;
             backup2('delete from craplpp where rowid = ''' || vr_craplpp_rowid ||''';');                  
     
      ----------------
    
      vr_nrdolote := 8502;
      vr_cdhistor := 2747;
        
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_aplica.cdcooper
                                 ,pr_dtmvtolt => vr_dtdolote
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_cdbccxlt => vr_cdbccxlt
                                 ,pr_nrdolote => vr_nrdolote
                                 ,pr_cdoperad => '1'
                                 ,pr_nrdcaixa => 0
                                 ,pr_tplotmov => 9
                                 ,pr_cdhistor => 0
                                 ,pr_craplot  => rw_craplot
                                 ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;         
         raise vr_excsaida;
      END IF;
      
   --Busca numero sequencial
      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_aplica.cdcooper||';'
                                   ||to_char(vr_dtdolote,'DD/MM/RRRR')||';'
                                   ||vr_cdagenci||';'
                                   ||vr_cdbccxlt||';'
                                   ||vr_nrdolote);
                                   
         BEGIN
          INSERT INTO craplac
            (cdcooper,
             dtmvtolt,
             cdagenci,
             cdbccxlt,
             nrdolote,
             nrdconta,
             nraplica,
             nrdocmto,
             nrseqdig,
             vllanmto,
             cdhistor)
          VALUES
            (rw_aplica.cdcooper,
             vr_dtdolote,
             vr_cdagenci,
             vr_cdbccxlt,
             vr_nrdolote,
             rw_aplica.nrdconta,
             rw_aplica.nraplica,
             vr_nrseqdig,
             vr_nrseqdig,
             rw_aplica.vlamnto,
             vr_cdhistor)
      RETURNING
          craplac.rowid
        INTO
          vr_craplac_rowid;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir registro de lancamento de aplicacao. Conta: ' ||
                           GENE0002.fn_mask_conta(rw_aplica.nrdconta) || ', Aplic.: '  || '. Erro: ' || SQLERRM;
             erro2('craplac Conta ' || rw_aplica.nrdconta || ' - Cooperativa: ' ||rw_aplica.cdcooper || ' - ' || vr_dscritic); 
            RAISE vr_excsaida;
        END;
          backup2('delete from craplac where rowid = ''' || vr_craplac_rowid ||''';');   
      
   END LOOP; --cr_aplica
   COMMIT;
   fecha_arquivos;
 
    EXCEPTION
      WHEN vr_excsaida then 
       vr_dscritic := 'ERRO ' || vr_dscritic; 
       fecha_arquivos; 
       ROLLBACK;
      WHEN OTHERS then
       vr_dscritic := 'ERRO ' || vr_dscritic || sqlerrm;
       fecha_arquivos;
       ROLLBACK;       
END;
