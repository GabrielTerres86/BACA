-- Created on 22/09/2021 by F0032999 
DECLARE 

  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_vllanmto NUMBER(20,4):= 0;
  vr_qtjurmfx crapcot.qtjurmfx%TYPE;
  pr_dscritic   VARCHAR2(5000) := ' ';
  vr_nmarqimp1  VARCHAR2(100) := ' ';
  vr_nmarqimp2  VARCHAR2(100) := ' ';
  vr_nmarqimp3  VARCHAR2(100) := ' ';
  vr_nmarqimp11       VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv1     utl_file.file_type;
  vr_nmarqimp22       VARCHAR2(100)  := 'loga.txt';
  vr_ind_arquiv2     utl_file.file_type;
  vr_nmarqimp33       VARCHAR2(100)  := 'erro.txt';
  vr_ind_arquiv3     utl_file.file_type;
  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0030248/micros/'; -- 
  vr_nmdireto        VARCHAR2(4000) :=  vr_rootmicros||'cpd/bacas/prj0023533';
  vr_excsaida   EXCEPTION;
  
  vr_des_xml_1         CLOB;  
  vr_des_xml_2         CLOB;    
  vr_des_xml_3         CLOB;    
  vr_texto_completo_1    VARCHAR2(32600);
  vr_texto_completo_2    VARCHAR2(32600);
  vr_texto_completo_3    VARCHAR2(32600);    
  
  TYPE typ_reg_crapcot IS
       RECORD (nrdconta crapsda.nrdconta%type
              ,cdcooper crapcot.cdcooper%TYPE
              ,qtjurmfx crapcot.qtjurmfx%TYPE);
  
  TYPE typ_tab_crapcot IS TABLE OF typ_reg_crapcot INDEX BY PLS_INTEGER;
  vr_tab_crapcot typ_tab_crapcot;
  
  CURSOR cr_crapcot(pr_cdcooper crapcot.cdcooper%TYPE,
                    pr_nrdconta crapcot.nrdconta%TYPE) IS
    SELECT cot.cdcooper,
           cot.nrdconta,
           cot.qtjurmfx
      FROM crapcot cot
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
       rw_crapcot cr_crapcot%ROWTYPE;
       
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
           last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.        
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
     rw_crapdat cr_crapdat%ROWTYPE; 
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM crapcop
     WHERE flgativo = 1
     AND cdcooper <> 3
	 and cdcooper = 13;
     rw_crapcop cr_crapcop%ROWTYPE;
   
  CURSOR cr_craplemll (pr_cdcooper IN craplem.cdcooper%TYPE,
                       pr_nrdconta IN craplem.nrdconta%TYPE,
                       pr_nrctremp IN craplem.nrctremp%TYPE)  IS
    SELECT SUM(tblem.vllanmto) vlrjuros_calc
          FROM tbepr_renegociacao_craplem tblem, 
               tbepr_renegociacao_crapepr tbepr
         WHERE tbepr.cdcooper = tblem.cdcooper
           AND tbepr.nrdconta = tblem.nrdconta
           AND tbepr.nrctremp = tblem.nrctremp
           AND tblem.cdcooper = pr_cdcooper
           AND tblem.nrdconta = pr_nrdconta
           AND tblem.nrctremp = pr_nrctremp
           AND tblem.dtmvtolt BETWEEN to_date('01/01/2021','dd/mm/yyyy') AND tbepr.dtultpag + 59
           AND tblem.cdhistor IN (1037, 1038, 2342, 2344);
         rw_craplemll cr_craplemll%ROWTYPE;
             
  CURSOR cr_craplem (pr_cdcooper IN craplem.cdcooper%TYPE,
                     pr_dtmvtolt IN craplem.dtmvtolt%TYPE) IS
        SELECT sum(tblem.vllanmto) vllanmto,           
               tbepr.cdcooper,
               tbepr.nrdconta,
               tbepr.nrctremp,
               tbepr.cdlcremp,              
               tbepr.dtultpag,
               tbepr.tpemprst,
               epr.dtmvtolt,
               epr.inprejuz        
          FROM tbepr_renegociacao_craplem tblem,
               tbepr_renegociacao_crapepr tbepr,
               crapepr epr
         WHERE tblem.nrdconta > 0
           AND tblem.cdagenci > 0
           AND tbepr.cdcooper = epr.cdcooper
           AND tbepr.nrdconta = epr.nrdconta
           AND tbepr.nrctremp = epr.nrctremp 
           AND tblem.cdcooper = pr_cdcooper
           AND tbepr.cdcooper = tblem.cdcooper
           AND tbepr.nrdconta = tblem.nrdconta
           AND tbepr.nrctremp = tblem.nrctremp
           AND tblem.dtmvtolt BETWEEN to_date('01/01/2021','dd/mm/yyyy') 
           AND (case WHEN tbepr.inprejuz = 0 AND tbepr.tpdescto <> 2 THEN last_day(add_months(pr_dtmvtolt,-1))
                     WHEN tbepr.inprejuz = 0 AND tbepr.tpdescto = 2 THEN pr_dtmvtolt
                     WHEN tbepr.inprejuz = 1 AND tbepr.tpdescto = 2 THEN tbepr.dtprejuz
                      ELSE last_day(add_months(tbepr.dtprejuz,-1)) END)
          AND tblem.cdhistor in (98, 1037, 1038, 2342, 2344)
          GROUP BY tbepr.cdcooper,
                   tbepr.nrdconta,
                   tbepr.nrctremp,
                   tbepr.cdlcremp,
                   epr.inprejuz,
                   tbepr.dtultpag,
                   tbepr.tpemprst,
                   epr.dtmvtolt;
      TYPE typ_tab_craplem IS TABLE OF cr_craplem%ROWTYPE INDEX BY PLS_INTEGER;
       vr_tab_craplem_bulk typ_tab_craplem;            
        
  procedure backup (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv1, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_1, 
                              pr_texto_completo => vr_texto_completo_1,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);
    END;  
  
  procedure loga (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv2, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_2, 
                              pr_texto_completo => vr_texto_completo_2,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
  
  procedure erro (pr_msg VARCHAR2) IS
    BEGIN
--      GENE0001.pc_escr_linha_arquivo(vr_ind_arquiv3, pr_msg);
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_3, 
                              pr_texto_completo => vr_texto_completo_3,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
  
  PROCEDURE fecha_arquivos IS
    vr_dscritic VARCHAR2(1000);
    BEGIN
      
    --- arq 1
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_1,
                            pr_texto_completo => vr_texto_completo_1,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_1
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp1 || '.txt'
                                 ,pr_des_erro => vr_dscritic);     
    dbms_lob.close(vr_des_xml_1);
    dbms_lob.freetemporary(vr_des_xml_1);     
                                 
             
    --- arq 2                        
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_2,
                            pr_texto_completo => vr_texto_completo_2,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_2
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp2 || '.txt'
                                 ,pr_des_erro => vr_dscritic);     
    dbms_lob.close(vr_des_xml_2);
    dbms_lob.freetemporary(vr_des_xml_2);                                      
             
    --- arq 3                        
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml_3,
                            pr_texto_completo => vr_texto_completo_3,
                            pr_texto_novo     => ' ',
                            pr_fecha_xml      => TRUE);                            
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml_3
                                 ,pr_caminho  => vr_nmdireto
                                 ,pr_arquivo  => rw_crapcop.cdcooper || vr_nmarqimp3 || '.txt'
                                 ,pr_des_erro => vr_dscritic);          
    dbms_lob.close(vr_des_xml_3);
    dbms_lob.freetemporary(vr_des_xml_3);                                      
    
    END;        
BEGIN
 
  FOR rw_crapcop IN cr_crapcop LOOP 
  
    vr_tab_crapcot.delete;  
  
    OPEN cr_crapdat (pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;
    CLOSE cr_crapdat;
      
    OPEN cr_craplem(pr_cdcooper => rw_crapcop.cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    vr_nmarqimp1 := rw_crapcop.cdcooper || vr_nmarqimp11 ||to_char(sysdate,'HH24:MI:SS');
      vr_nmarqimp2 := rw_crapcop.cdcooper || vr_nmarqimp22 ||to_char(sysdate,'HH24:MI:SS');
      vr_nmarqimp3 := rw_crapcop.cdcooper || vr_nmarqimp33 ||to_char(sysdate,'HH24:MI:SS');
      
    vr_des_xml_1 := NULL;
    dbms_lob.createtemporary(vr_des_xml_1, TRUE);
    dbms_lob.open(vr_des_xml_1, dbms_lob.lob_readwrite);
      
      --Criar arquivo
/*      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarqimp1
                              ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_ind_arquiv1     --> handle do arquivo aberto
                              ,pr_des_erro => pr_dscritic);      --> erro
      -- em caso de crítica
      IF pr_dscritic IS NOT NULL THEN        
        RAISE vr_excsaida;
      END IF; */
      
    vr_des_xml_2 := NULL;
    dbms_lob.createtemporary(vr_des_xml_2, TRUE);
    dbms_lob.open(vr_des_xml_2, dbms_lob.lob_readwrite);
      
  
/*      --Criar arquivo
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarqimp2       --> Nome do arquivo
                              ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_ind_arquiv2     --> handle do arquivo aberto
                              ,pr_des_erro => pr_dscritic);      --> erro
      -- em caso de crítica
      IF pr_dscritic IS NOT NULL THEN        
        RAISE vr_excsaida;
      END IF;  */
      
    vr_des_xml_3 := NULL;
    dbms_lob.createtemporary(vr_des_xml_3, TRUE);
    dbms_lob.open(vr_des_xml_3, dbms_lob.lob_readwrite);
      
/*  
      --Criar arquivo
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarqimp3       --> Nome do arquivo
                              ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_ind_arquiv3     --> handle do arquivo aberto
                              ,pr_des_erro => pr_dscritic);      --> erro
      -- em caso de crítica
      IF pr_dscritic IS NOT NULL THEN        
        RAISE vr_excsaida;
      END IF;  */
      
      
    LOOP     
      FETCH cr_craplem BULK COLLECT INTO vr_tab_craplem_bulk LIMIT 1000;
      EXIT WHEN vr_tab_craplem_bulk.COUNT = 0; 
          
      loga('INICIO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
      FOR idx IN vr_tab_craplem_bulk.first..vr_tab_craplem_bulk.last LOOP
        
        IF (vr_tab_craplem_bulk(idx).cdlcremp IN(6901,900) OR vr_tab_craplem_bulk(idx).inprejuz = 1) THEN
          
          vr_vllanmto := vr_vllanmto + vr_tab_craplem_bulk(idx).vllanmto;     
        
        ELSIF vr_tab_craplem_bulk(idx).dtmvtolt > vr_tab_craplem_bulk(idx).dtultpag + 59 THEN
          
          OPEN cr_craplemll (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                             pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta,
                             pr_nrctremp => vr_tab_craplem_bulk(idx).nrctremp);
          FETCH cr_craplemll INTO rw_craplemll;
          
          vr_vllanmto := vr_vllanmto + (vr_tab_craplem_bulk(idx).vllanmto - NVL(rw_craplemll.vlrjuros_calc, 0));        
          
          CLOSE cr_craplemll;        
        
        END IF;  
        
        IF vr_vllanmto > 0 THEN
          vr_vllanmto := ROUND(vr_vllanmto / 0.82870000,4);
          OPEN cr_crapcot (pr_cdcooper => vr_tab_craplem_bulk(idx).cdcooper,
                             pr_nrdconta => vr_tab_craplem_bulk(idx).nrdconta);
          FETCH cr_crapcot INTO rw_crapcot;
          
          CLOSE cr_crapcot;                              
          
          loga(vr_tab_craplem_bulk(idx).cdcooper||';'||vr_tab_craplem_bulk(idx).nrdconta||';'||vr_tab_craplem_bulk(idx).nrctremp||';'||vr_tab_craplem_bulk(idx).cdlcremp||';'||vr_tab_craplem_bulk(idx).inprejuz||';'||vr_tab_craplem_bulk(idx).dtultpag||';'||vr_vllanmto);
          
          
            IF NOT vr_tab_crapcot.exists(vr_tab_craplem_bulk(idx).nrdconta) THEN
              backup('update crapcot set qtjurmfx = ' || replace(rw_crapcot.qtjurmfx,',','.') || ' where cdcooper = ' || rw_crapcot.cdcooper ||' and nrdconta =  '||rw_crapcot.nrdconta||';');
              vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).cdcooper := vr_tab_craplem_bulk(idx).cdcooper;
              vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).nrdconta := vr_tab_craplem_bulk(idx).nrdconta;
              vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx := rw_crapcot.qtjurmfx;
            END IF;
            
            vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx := NVL(vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx,0) - vr_vllanmto;         
            
           
          IF vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx  < 0 THEN
          
             vr_tab_crapcot(vr_tab_craplem_bulk(idx).nrdconta).qtjurmfx := 0;                                
          END IF;

        END IF; 
      vr_vllanmto := 0;   
      END LOOP; --vr_tab_craplem_bulk
      
    END LOOP;  --cr_craplem  
    
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapcot SAVE EXCEPTIONS
          UPDATE crapcot
             SET crapcot.qtjurmfx = vr_tab_crapcot(idx).qtjurmfx
           WHERE crapcot.cdcooper  = vr_tab_crapcot(idx).cdcooper
             AND crapcot.nrdconta  = vr_tab_crapcot(idx).nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic:= 'Erro ao atualizar tabela crapcot. '||
                        SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
          --Levantar Exceção
          RAISE vr_excsaida;
    END;

    COMMIT;
      
    loga('FIM ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||' cooperativa: '||rw_crapcop.cdcooper);
     fecha_arquivos;
    close cr_craplem;
  END LOOP; --cr_crapcop      
  commit;
 
  EXCEPTION
    WHEN vr_excsaida then 
      pr_dscritic := 'ERRO ' || pr_dscritic;  
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos;       
      ROLLBACK;
    WHEN OTHERS then
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      loga('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos; 
      ROLLBACK;       
END;
