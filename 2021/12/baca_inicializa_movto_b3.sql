-- Created on 01/12/2021 by F0030248 
declare 
  -- Local variables here
  vr_qtd INTEGER := 0;
  vr_idx_aplic VARCHAR2(32);
  vr_idx VARCHAR2(32);  

  vr_dtinictd DATE;
  vr_vlinictd NUMBER(10,2);
  vr_dtmvtolt_dat DATE;
  vr_dtmvtoan_dat DATE;
  vr_dtmvtoan_2_dat DATE;  
  vr_dtmvto2a DATE;
  
  pr_dscritic          VARCHAR2(5000) := ' ';
  vr_nmarqimp1         VARCHAR2(100) := ' ';
  vr_nmarqimp2         VARCHAR2(100) := ' ';
  vr_nmarqimp3         VARCHAR2(100) := ' ';
  vr_nmarqimp11        VARCHAR2(100)  := 'backup_';
  vr_nmarqimp22        VARCHAR2(100)  := 'log_';
  vr_nmarqimp33        VARCHAR2(100)  := 'erro_';  
  vr_rootmicros        VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0030248/micros/'; -- 
  vr_nmdireto          VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/PRB0046157'; 
  vr_excsaida          EXCEPTION;  
  vr_des_xml_1         CLOB;  
  vr_des_xml_2         CLOB;    
  vr_des_xml_3         CLOB;    
  vr_texto_completo_1  VARCHAR2(32600);
  vr_texto_completo_2  VARCHAR2(32600);
  vr_texto_completo_3  VARCHAR2(32600);      
  
  TYPE typ_reg IS
     RECORD (rowid_lct ROWID);
     
  TYPE typ_tab_reg IS TABLE OF typ_reg INDEX BY VARCHAR2(32);
  
  vr_tab_reg typ_tab_reg;
  
  
  -- Busca dos lançamentos de aplicação dos ultimos 2 dias
  CURSOR cr_lctos(pr_cdcooper NUMBER
                 ,pr_dtmvtoan DATE
                 ,pr_dtmvtolt DATE
                 ,pr_dtinictd DATE
                 ,pr_vlminctd NUMBER) IS
    -- RDC Pré e RDC Pós
    SELECT rda.rowid rowid_apl
          ,lap.rowid rowid_lct
          ,hst.tpaplicacao tpaplrdc
          ,lap.dtmvtolt
          ,lap.cdhistor
          ,lap.vllanmto
          ,hst.idtipo_arquivo
          ,hst.idtipo_lancto
          ,hst.cdoperacao_b3
          ,rda.nrdconta nrdconta
          ,rda.nraplica nraplica
          ,0            cdprodut
          ,rda.cdcooper
      FROM craplap lap
          ,craprda rda
          ,crapdtc dtc
          ,vw_capt_histor_operac hst
     WHERE rda.cdcooper = dtc.cdcooper
       AND rda.tpaplica = dtc.tpaplica
       AND lap.cdcooper = rda.cdcooper
       AND lap.nrdconta = rda.nrdconta
       AND lap.nraplica = rda.nraplica
       AND lap.cdcooper = pr_cdcooper  
       -- Históricos de Aplicação
       AND hst.idtipo_arquivo = 1 -- Aplicação
       AND hst.tpaplicacao = dtc.tpaplrdc
       AND hst.cdhistorico = lap.cdhistor
       -- Utilizar a maior data entre os dois dias úteis anteriores
       -- e a data de início de envio das aplicações para custódia B3
       AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
   -- E não podem ser do dia atual
       AND lap.dtmvtolt < pr_dtmvtolt
       --> Aplicação não custodiada ainda
       AND nvl(rda.idaplcus,0) = 0
       --> Registro não custodiado ainda
       AND nvl(lap.idlctcus,0) = 0
       --> Valor de aplicação maior ou igual ao valor mínimo
       AND lap.vllanmto >= nvl(pr_vlminctd,0)
    UNION
    -- Produtos de Captação
    SELECT rac.rowid
          ,lac.rowid
          ,hst.tpaplicacao
          ,lac.dtmvtolt
          ,lac.cdhistor
          ,lac.vllanmto
          ,hst.idtipo_arquivo
          ,hst.idtipo_lancto
          ,hst.cdoperacao_b3
          ,rac.nrdconta nrdconta
          ,rac.nraplica nraplica
          ,rac.cdprodut cdprodut
          ,rac.cdcooper
      FROM craplac lac
          ,craprac rac
          ,vw_capt_histor_operac hst
     WHERE rac.cdcooper = lac.cdcooper
       AND rac.nrdconta = lac.nrdconta
       AND rac.nraplica = lac.nraplica
       AND lac.cdcooper = pr_cdcooper   
       -- Históricos de Aplicação
       AND hst.idtipo_arquivo = 1 -- Aplicação
       AND hst.tpaplicacao in(3,4)
       AND hst.cdprodut    = rac.cdprodut
       AND hst.cdhistorico = lac.cdhistor
       -- Utilizar a maior data entre os dois dias úteis anteriores
       -- e a data de início de envio das aplicações para custódia B3
       AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
   -- E não podem ser do dia atual
       AND lac.dtmvtolt < pr_dtmvtolt
       --> Aplicação não custodiada ainda
       AND nvl(rac.idaplcus,0) = 0
       --> Registro não custodiado ainda
       AND nvl(lac.idlctcus,0) = 0
       --> Valor de aplicação maior ou igual ao valor mínimo
       AND lac.vllanmto >= nvl(pr_vlminctd,0);
       
      -- Busca das Operações nas aplicações custodiadas não enviados a B3
      CURSOR cr_lctos_rgt(pr_cdcooper NUMBER
                         ,pr_dtmvtoan DATE
                         ,pr_dtmvtolt DATE
                         ,pr_dtinictd DATE) IS
        -- RDC Pré e RDC Pós
        SELECT *
          FROM (SELECT lap.cdcooper
                      ,rda.idaplcus
                      ,lap.rowid rowid_lct
                      ,hst.tpaplicacao tpaplrdc
                      ,lap.nrdconta
                      ,lap.nraplica
                      ,0 cdprodut
                      ,lap.dtmvtolt
                      ,lap.cdhistor
                      ,lap.vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rda.dtmvtolt dtmvtapl
                      ,decode(capl.tpaplicacao,1,rda.qtdiaapl,rda.qtdiauti) qtdiacar
                      ,lap.progress_recid
                      ,lap.vlpvlrgt valorbase
                      ,hst.cdhistorico
                      ,rda.insaqtot idsaqtot
                      ,his.indebcre
                      ,capl.dscodigo_b3
                  FROM craplap lap
                      ,craprda rda
                      ,crapdtc dtc
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                      ,craphis his
                 WHERE rda.cdcooper = dtc.cdcooper
                   AND rda.tpaplica = dtc.tpaplica
                   AND lap.cdcooper = rda.cdcooper
                   AND lap.nrdconta = rda.nrdconta  
                   AND lap.nraplica = rda.nraplica
                   AND lap.cdcooper = pr_cdcooper
                   AND rda.idaplcus = capl.idaplicacao
                   AND his.cdcooper = lap.cdcooper
                   AND his.cdhistor = lap.cdhistor
                   -- Somente resgates antecipados
                   AND ( lap.dtmvtolt < rda.dtvencto)
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lap.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = dtc.tpaplrdc
                   AND hst.cdhistorico = lap.cdhistor
                   --> Registro não custodiado ainda
                   AND nvl(lap.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rda.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL
                UNION
                  -- Produtos de Captação
                SELECT rac.cdcooper
                      ,rac.idaplcus
                      ,lac.rowid
                      ,hst.tpaplicacao
                      ,lac.nrdconta
                      ,lac.nraplica
                      ,rac.cdprodut
                      ,lac.dtmvtolt
                      ,lac.cdhistor
                      ,lac.vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rac.dtmvtolt dtmvtapl
                      ,rac.qtdiacar
                      ,lac.progress_recid
                      ,lac.vlbasren valorbase
                      ,hst.cdhistorico
                      ,rac.idsaqtot
                      ,his.indebcre
                      ,capl.dscodigo_b3
                  FROM craplac lac
                      ,craprac rac
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                      ,craphis his
                 WHERE rac.cdcooper = lac.cdcooper
                   AND rac.nrdconta = lac.nrdconta  
                   AND rac.nraplica = lac.nraplica
                   AND lac.cdcooper = pr_cdcooper
                   AND rac.idaplcus = capl.idaplicacao
                   AND his.cdcooper = lac.cdcooper
                   AND his.cdhistor = lac.cdhistor
                   -- Somente resgates antecipados OU IRRF
                   AND ( lac.dtmvtolt < rac.dtvencto OR hst.idtipo_lancto = 3 )
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lac.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao IN(3,4)
                   AND hst.cdprodut    = rac.cdprodut
                   AND hst.cdhistorico = lac.cdhistor
                   --> Registro não custodiado ainda
                   AND nvl(lac.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rac.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL) lct
         -- Removido histórico de IRRF (David Valente P411.3 RF1) lct.cdhistorico NOT IN(2744,476, 533) 
         ORDER BY lct.dtmvtolt
                 ,lct.nrdconta
                 ,lct.nraplica
                 ,lct.idtipo_lancto -- Anderson 2019/06/13
                 ,lct.vllanmto desc;
                 
    PROCEDURE abre_arquivos (pr_cdcooper IN INTEGER) IS
	  BEGIN
      vr_nmarqimp1 := pr_cdcooper || '_' || vr_nmarqimp11 ||to_char(sysdate,'HH24MISS');
      vr_nmarqimp2 := pr_cdcooper || '_' || vr_nmarqimp22 ||to_char(sysdate,'HH24MISS');
      vr_nmarqimp3 := pr_cdcooper || '_' || vr_nmarqimp33 ||to_char(sysdate,'HH24MISS');
        
      vr_des_xml_1 := NULL;
      dbms_lob.createtemporary(vr_des_xml_1, TRUE);
      dbms_lob.open(vr_des_xml_1, dbms_lob.lob_readwrite);

      vr_des_xml_2 := NULL;
      dbms_lob.createtemporary(vr_des_xml_2, TRUE);
      dbms_lob.open(vr_des_xml_2, dbms_lob.lob_readwrite);
        
      vr_des_xml_3 := NULL;
      dbms_lob.createtemporary(vr_des_xml_3, TRUE);
      dbms_lob.open(vr_des_xml_3, dbms_lob.lob_readwrite);  			
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
                                   ,pr_arquivo  => vr_nmarqimp1 || '.txt'
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
                                   ,pr_arquivo  => vr_nmarqimp2 || '.txt'
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
                                   ,pr_arquivo  => vr_nmarqimp3 || '.txt'
                                   ,pr_des_erro => vr_dscritic);          
      dbms_lob.close(vr_des_xml_3);
      dbms_lob.freetemporary(vr_des_xml_3);                                      
      
    END;       
    
    PROCEDURE backup (pr_msg VARCHAR2) IS
    BEGIN
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_1, 
                              pr_texto_completo => vr_texto_completo_1,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);
    END;  
  
    PROCEDURE log (pr_msg VARCHAR2) IS
    BEGIN
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_2, 
                              pr_texto_completo => vr_texto_completo_2,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END; 
  
    PROCEDURE erro (pr_msg VARCHAR2) IS
    BEGIN
      gene0002.pc_escreve_xml(pr_xml => vr_des_xml_3, 
                              pr_texto_completo => vr_texto_completo_3,
                              pr_texto_novo => pr_msg || chr(10),
                              pr_fecha_xml => FALSE);

    END;                  
  
begin

  FOR rw_cop IN (SELECT cdcooper FROM crapcop WHERE cdcooper = 11) LOOP
	 
    abre_arquivos(pr_cdcooper => rw_cop.cdcooper);
    
    -- Buscar parâmetros de sistema  
    vr_dtinictd := to_date(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'INIC_CUSTODIA_APLICA_B3'),'dd/mm/rrrr');
    vr_vlinictd := to_number(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'VLMIN_CUSTOD_APLICA_B3'),'FM999999990D00');
    
    FOR rw_crapdat IN (SELECT * FROM crapdat WHERE cdcooper = rw_cop.cdcooper) LOOP
		 
      rw_crapdat.dtmvtolt := to_date('15/10/2021','DD/MM/RRRR');
      rw_crapdat.dtmvtoan := to_date('14/10/2021','DD/MM/RRRR');      
    
      vr_dtmvtolt_dat := rw_crapdat.dtmvtolt;
      vr_dtmvtoan_dat := rw_crapdat.dtmvtoan;       
      vr_dtmvtoan_2_dat := vr_dtmvtoan_dat - 1;    
      
      -- Buscar o dia útil anterior ao dtmvtoan, ou seja, iremos buscar 2 dias úteis atrás
      vr_dtmvto2a := gene0005.fn_valida_dia_util(pr_cdcooper => rw_cop.cdcooper
                                                ,pr_dtmvtolt => vr_dtmvtoan_2_dat
                                                ,pr_tipo => 'A');                                              
    END LOOP;        

    log(to_char(SYSDATE,'HH24:MI:SS'));
    
    log('--------------- INICIALIZACAO ---------------');      
    FOR rw IN (
        SELECT cst.nmarquivo, 
               cst.idtipo_arquivo, 
               cst.idtipo_operacao, 
               arq.dslinha, 
               lct.idtipo_lancto, 
               lct.idsituacao,
               lct.idaplicacao,
               lct.idlancamento,
               lac.nraplica nraplica_lac, 
               lap.nraplica nraplica_lap, 
               lac.cdcooper cdcooper_lac, 
               lac.nrdconta nrdconta_lac, 
               lap.cdcooper cdcooper_lap, 
               lap.nrdconta nrdconta_lap, 
               lac.dtmvtolt dtmvtolt_lac, 
               lap.dtmvtolt dtmvtolt_lap,
               lap.rowid rowid_lap,
               lac.rowid rowid_lac,
               arq.rowid arq_rowid,
               lct.rowid lct_rowid
          FROM tbcapt_custodia_conteudo_arq arq, 
               tbcapt_custodia_arquivo cst, 
               tbcapt_custodia_lanctos lct,
               craplac lac,
               craplap lap
        WHERE arq.idarquivo = cst.idarquivo
          AND TRUNC(cst.dtcriacao) = to_date('08/12/2021','DD/MM/RRRR')
          AND lct.idlancamento = arq.idlancamento
          AND lac.idlctcus(+) = arq.idlancamento
          AND lap.idlctcus(+) = arq.idlancamento
          AND cst.idtipo_operacao = 'E'
  --        AND lct.idtipo_lancto = 2
          AND (lac.cdcooper = rw_cop.cdcooper OR lap.cdcooper = rw_cop.cdcooper)) LOOP
          
      IF rw.idtipo_lancto = 2 THEN
        IF rw.rowid_lap IS NOT NULL THEN
          vr_tab_reg(rw.rowid_lap).rowid_lct := '0';
        ELSE
          vr_tab_reg(rw.rowid_lac).rowid_lct := '0';
        END IF;
      END IF;
    
      /*IF rw.nraplica_lac IS NOT NULL THEN
         UPDATE craplac lac 
            SET lac.idlctcus = 0
          WHERE lac.idlctcus = rw.idlancamento;
      ELSE
         UPDATE craplap lap 
            SET lap.idlctcus = 0
          WHERE lap.idlctcus = rw.idlancamento;		 
      END IF;
      
      IF rw.idtipo_lancto = 1 THEN
        IF rw.nraplica_lac IS NOT NULL THEN
           UPDATE craprac rac
              SET rac.idaplcus = 0
            WHERE rac.idaplcus = rw.idaplicacao;
        ELSE
           UPDATE craprda rda
              SET rda.idaplcus = 0
            WHERE rda.idaplcus = rw.idaplicacao;			 
        END IF;
              
      END IF;*/
      
      log(
        rw.idaplicacao || ' - ' ||
        rw.idlancamento || ' - ' ||
        rw.dslinha             
      );      
                        
    END LOOP;
    
    vr_qtd := 0;
    log('--------------- APORTES ---------------');  
    -- cr_lctos(rw_cop.cdcooper,vr_dtmvto2a,vr_dtmvtolt_dat,vr_dtinictd,vr_vlinictd)
    FOR rw_lctos IN cr_lctos(pr_cdcooper => rw_cop.cdcooper
                            ,pr_dtmvtoan => vr_dtmvto2a
                            ,pr_dtmvtolt => vr_dtmvtolt_dat
                            ,pr_dtinictd => vr_dtinictd
                            ,pr_vlminctd => vr_vlinictd) LOOP
                            
      log(rw_lctos.rowid_apl || ' - ' || 
          rw_lctos.rowid_lct || ' - ' || 
          rw_lctos.cdcooper || ' - ' || 
          rw_lctos.nrdconta || ' - ' || 
          rw_lctos.nraplica || ' - ' || 
          rw_lctos.vllanmto);
      vr_qtd := vr_qtd + 1;
      
  --    vr_tab_reg(rw_lctos.rowid_lct).rowid_lct := rw_lctos.rowid_lct;
      
    END LOOP;              
    
    log('APORTES=' || vr_qtd);            
    
    log('--------------- RESGATES ---------------');
    
    vr_qtd := 0;
    vr_idx_aplic := ' ';
    --  cr_lctos_rgt(rw_cop.cdcooper,vr_dtmvto2a,vr_dtmvtolt_dat,vr_dtinictd)
    FOR rw_lctos_rgt IN cr_lctos_rgt(pr_cdcooper => rw_cop.cdcooper
                                    ,pr_dtmvtoan => vr_dtmvto2a
                                    ,pr_dtmvtolt => vr_dtmvtolt_dat
                                    ,pr_dtinictd => vr_dtinictd) LOOP
                            
      log(lpad(rw_lctos_rgt.idaplcus,20,'0') || to_char(trunc(rw_lctos_rgt.dtmvtolt),'rrrrmmdd') || ' - ' || rw_lctos_rgt.rowid_lct || ' - ' || 
                           rw_lctos_rgt.cdcooper || ' - ' || 
                           rw_lctos_rgt.nrdconta || ' - ' || 
                           rw_lctos_rgt.nraplica || ' - ' || 
                           rw_lctos_rgt.vllanmto
                           || rw_lctos_rgt.idtipo_lancto
                           );
                      
      IF rw_lctos_rgt.idtipo_lancto = 2 THEN
        vr_qtd := vr_qtd + 1;
      END IF;
      
      vr_tab_reg(rw_lctos_rgt.rowid_lct).rowid_lct := rw_lctos_rgt.rowid_lct;        
      
    END LOOP;                          
    
    log('RESGATES=' || vr_qtd);  
    
    vr_idx := vr_tab_reg.first();
    LOOP	
      IF vr_tab_reg(vr_idx).rowid_lct = '0' THEN
        log('NÃO ENCONTROU - ' || vr_idx);
      END IF;
      vr_idx := vr_tab_reg.next(vr_idx);
      EXIT WHEN vr_idx IS NULL;
    END LOOP;  	 
          
    log('FIM ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||' cooperativa: '|| rw_cop.cdcooper);
    
    fecha_arquivos;   
    
    COMMIT;    
    
  END LOOP;
  
  EXCEPTION
    WHEN vr_excsaida then 
      pr_dscritic := 'ERRO ' || pr_dscritic;  
      log('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos;       
      ROLLBACK;
    WHEN OTHERS then
      pr_dscritic := 'ERRO ' || pr_dscritic || sqlerrm;
      log('ERRO ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')); 
      erro(pr_dscritic);
      fecha_arquivos; 
      ROLLBACK;          
  
END;