-- Created on 20/11/2021 by F0030248 
declare 
  -- Local variables here
  i integer;
  
  pr_dscritic          VARCHAR2(5000) := ' ';
  vr_nmarqimp1         VARCHAR2(100) := ' ';
  vr_nmarqimp2         VARCHAR2(100) := ' ';
  vr_nmarqimp3         VARCHAR2(100) := ' ';
  vr_nmarqimp11        VARCHAR2(100)  := 'SM_backup_';
  vr_nmarqimp22        VARCHAR2(100)  := 'SM_log_';
  vr_nmarqimp33        VARCHAR2(100)  := 'SM_erro_';  
  vr_rootmicros        VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS'); -- '/progress/f0030248/micros/'; -- 
  vr_nmdireto          VARCHAR2(4000) := vr_rootmicros || 'cpd/bacas/prj0023533'; 
  vr_excsaida          EXCEPTION;  
  vr_des_xml_1         CLOB;  
  vr_des_xml_2         CLOB;    
  vr_des_xml_3         CLOB;    
  vr_texto_completo_1  VARCHAR2(32600);
  vr_texto_completo_2  VARCHAR2(32600);
  vr_texto_completo_3  VARCHAR2(32600);    
  vr_mesmovto          INTEGER;
  vr_vlsmpmes             crapsld.vlsmpmes%TYPE;
  
  TYPE typ_reg_crapsld IS
     RECORD (nrdconta     crapsld.nrdconta%type
            ,cdcooper     crapsld.cdcooper%TYPE
            ,smposano##1  crapsld.smposano##1%TYPE
            ,smposano##2  crapsld.smposano##1%TYPE
            ,smposano##3  crapsld.smposano##1%TYPE
            ,smposano##4  crapsld.smposano##1%TYPE
            ,smposano##5  crapsld.smposano##1%TYPE
            ,smposano##6  crapsld.smposano##1%TYPE
            ,smposano##7  crapsld.smposano##1%TYPE
            ,smposano##8  crapsld.smposano##1%TYPE
            ,smposano##9  crapsld.smposano##1%TYPE
            ,smposano##10 crapsld.smposano##1%TYPE
            ,smposano##11 crapsld.smposano##1%TYPE
            ,smposano##12 crapsld.smposano##1%TYPE
            ,vlsmstre##1  crapsld.vlsmstre##1%TYPE
            ,vlsmstre##2  crapsld.vlsmstre##1%TYPE
            ,vlsmstre##3  crapsld.vlsmstre##1%TYPE
            ,vlsmstre##4  crapsld.vlsmstre##1%TYPE
            ,vlsmstre##5  crapsld.vlsmstre##1%TYPE
            ,vlsmstre##6  crapsld.vlsmstre##1%TYPE                                                            
            );
              
  TYPE typ_tab_crapsld IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER; 
  vr_tab_sld typ_tab_crapsld;
  
  CURSOR cr_smposano (pr_cdcooper IN crapass.cdcooper%TYPE) IS
    SELECT ass.cdcooper, 
           ass.nrdconta, 
           ass.dtdemiss, 
           (CASE to_char(ass.dtdemiss,'MM') 
             WHEN '01' THEN sld.smposano##1
             WHEN '02' THEN sld.smposano##2
             WHEN '03' THEN sld.smposano##3
             WHEN '04' THEN sld.smposano##4
             WHEN '05' THEN sld.smposano##5
             WHEN '06' THEN sld.smposano##6
             WHEN '07' THEN sld.smposano##7
             WHEN '08' THEN sld.smposano##8
             WHEN '09' THEN sld.smposano##9
             WHEN '10' THEN sld.smposano##10
             WHEN '11' THEN sld.smposano##11
             WHEN '12' THEN sld.smposano##12
            END) SMPOSANO,
           (SELECT 
              CASE WHEN to_char(ass.dtdemiss,'MM') = '12' AND sld.vlsmpmes > 0 THEN 
                sld.vlsmpmes 
              ELSE NVL(ROUND(AVG(CASE WHEN sda.vlsddisp > 0 THEN 
 		  			    sda.vlsddisp ELSE 0 END),2),0) 
              END FROM crapsda sda
             WHERE sda.cdcooper = ass.cdcooper
               AND sda.nrdconta = ass.nrdconta
               AND sda.dtmvtolt BETWEEN TRUNC(ass.dtdemiss,'MM') AND last_day(TRUNC(ass.dtdemiss,'MM'))) saldo_medio, 
           sld.vlsmpmes,               
           sld.smposano##1,
           sld.smposano##2,
           sld.smposano##3,
           sld.smposano##4,
           sld.smposano##5,
           sld.smposano##6,
           sld.smposano##7,
           sld.smposano##8,
           sld.smposano##9,
           sld.smposano##10,
           sld.smposano##11,
           sld.smposano##12,
           sld.vlsmstre##1,
           sld.vlsmstre##2,
           sld.vlsmstre##3,
           sld.vlsmstre##4,
           sld.vlsmstre##5,
           sld.vlsmstre##6                                                       
      FROM crapass ass, crapsld sld, crapage age
    WHERE age.cdcooper = pr_cdcooper
      AND age.cdagenci NOT IN (90,91)
      AND ass.cdcooper = age.cdcooper
      AND ass.cdagenci = age.cdagenci
      AND ass.nrdconta > 0
      AND ass.cdsitdtl < 5
      AND ass.vllimcre = 0
      AND TRUNC(ass.dtdemiss,'YYYY') = to_date('01/01/2021','DD/MM/YYYY')
      AND sld.cdcooper = ass.cdcooper
      AND sld.nrdconta = ass.nrdconta;  
      
  rw_smposano cr_smposano%ROWTYPE;
  
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
           
  
  
BEGIN
 
  FOR rw IN (SELECT cdcooper FROM crapcop WHERE cdcooper > 0 AND cdcooper <> 3 AND flgativo = 1) LOOP
	 
    abre_arquivos(pr_cdcooper => rw.cdcooper);
    
    log('INICIO - ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));    
    
    vr_tab_sld.delete();
  
    FOR rw_smposano IN cr_smposano (pr_cdcooper => rw.cdcooper) LOOP
		 
      log(rw_smposano.cdcooper || ';' ||
          rw_smposano.nrdconta || ';' ||
          to_char(rw_smposano.dtdemiss,'DD/MM/RRRR') || ';' ||
          rw_smposano.smposano || ';' ||
          rw_smposano.saldo_medio);
  	 
      backup('update crapsld set ' || 
             ' smposano##1 = ' || replace(rw_smposano.smposano##1,',','.') || ',' ||
             ' smposano##2 = ' || replace(rw_smposano.smposano##2,',','.') || ',' || 
             ' smposano##3 = ' || replace(rw_smposano.smposano##3,',','.') || ',' ||
             ' smposano##4 = ' || replace(rw_smposano.smposano##4,',','.') || ',' ||
             ' smposano##5 = ' || replace(rw_smposano.smposano##5,',','.') || ',' ||
             ' smposano##6 = ' || replace(rw_smposano.smposano##6,',','.') || ',' ||
             ' smposano##7 = ' || replace(rw_smposano.smposano##7,',','.') || ',' ||
             ' smposano##8 = ' || replace(rw_smposano.smposano##8,',','.') || ',' ||
             ' smposano##9 = ' || replace(rw_smposano.smposano##9,',','.') || ',' ||
             ' smposano##10 = ' || replace(rw_smposano.smposano##10,',','.') || ',' ||
             ' smposano##11 = ' || replace(rw_smposano.smposano##11,',','.') || ',' ||
             ' smposano##12 = ' || replace(rw_smposano.smposano##12,',','.') || ',' ||
             ' vlsmstre##1 = ' || replace(rw_smposano.vlsmstre##1,',','.') || ',' ||
             ' vlsmstre##2 = ' || replace(rw_smposano.vlsmstre##2,',','.') || ',' ||
             ' vlsmstre##3 = ' || replace(rw_smposano.vlsmstre##3,',','.') || ',' ||
             ' vlsmstre##4 = ' || replace(rw_smposano.vlsmstre##4,',','.') || ',' ||
             ' vlsmstre##5 = ' || replace(rw_smposano.vlsmstre##5,',','.') || ',' ||
             ' vlsmstre##6 = ' || replace(rw_smposano.vlsmstre##6,',','.')                                                                 
             || ' where cdcooper = ' || rw_smposano.cdcooper ||' and nrdconta = '||rw_smposano.nrdconta||';'); 
      
      vr_tab_sld(rw_smposano.nrdconta).cdcooper := rw_smposano.cdcooper;
      vr_tab_sld(rw_smposano.nrdconta).nrdconta := rw_smposano.nrdconta;
           
      vr_tab_sld(rw_smposano.nrdconta).smposano##1 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '01' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##1 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##2 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '02' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##2 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##3 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '03' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##3 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##4 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '04' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##4 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##5 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '05' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##5 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##6 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '06' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##6 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##7 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '07' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##7 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##8 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '08' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##8 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##9 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '09' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##9 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##10 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '10' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##10 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##11 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '11' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##11 END;
      vr_tab_sld(rw_smposano.nrdconta).smposano##12 := CASE WHEN to_char(rw_smposano.dtdemiss,'MM') = '12' THEN rw_smposano.saldo_medio ELSE rw_smposano.smposano##12 END;
      
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##1 := rw_smposano.vlsmstre##1;
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##2 := rw_smposano.vlsmstre##2;
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##3 := rw_smposano.vlsmstre##3;
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##4 := rw_smposano.vlsmstre##4;
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##5 := rw_smposano.vlsmstre##5;
      vr_tab_sld(rw_smposano.nrdconta).vlsmstre##6 := rw_smposano.vlsmstre##6;                              
            
      CASE to_number(To_Char(rw_smposano.dtdemiss,'MM'))
			  WHEN  1 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##1;
			  WHEN  2 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##2;
			  WHEN  3 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##3;
			  WHEN  4 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##4;
			  WHEN  5 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##5;
			  WHEN  6 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##6;
			  WHEN  7 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##7;
			  WHEN  8 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##8;
			  WHEN  9 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##9;
			  WHEN 10 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##10;
			  WHEN 11 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##11;
			  WHEN 12 THEN vr_vlsmpmes := vr_tab_sld(rw_smposano.nrdconta).smposano##12;
      END CASE;                                                                                        
      
      --Variavel recebe o mes do movimento 1..12
      vr_mesmovto:= to_number(To_Char(rw_smposano.dtdemiss,'MM'));
      --Se passou da metade do ano
      IF vr_mesmovto > 6 THEN
        --Diminuir 6 do mes encontrado
        vr_mesmovto:= vr_mesmovto-6;
      END IF;      

      --Valor do saldo medio mensal recebe o valor positivo no mes
      CASE vr_mesmovto
        WHEN 1 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##1:= Nvl(vr_vlsmpmes,0);
        WHEN 2 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##2:= Nvl(vr_vlsmpmes,0);
        WHEN 3 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##3:= Nvl(vr_vlsmpmes,0);
        WHEN 4 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##4:= Nvl(vr_vlsmpmes,0);
        WHEN 5 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##5:= Nvl(vr_vlsmpmes,0);
        WHEN 6 THEN
          vr_tab_sld(rw_smposano.nrdconta).vlsmstre##6:= Nvl(vr_vlsmpmes,0);
      END CASE;      
    END LOOP; -- cr_smposano
       
    log('TOTAL CONTAS - ' || to_char(vr_tab_sld.count) || ' - ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS'));
           
    log('FIM ' || to_char(sysdate,'DD/MM/YYYY HH24:MI:SS')||' cooperativa: '|| rw.cdcooper);
    
    fecha_arquivos;   
    
    BEGIN
      FORALL idx IN INDICES OF vr_tab_sld SAVE EXCEPTIONS
          UPDATE crapsld
             SET smposano##1 = vr_tab_sld(idx).smposano##1,
                 smposano##2 = vr_tab_sld(idx).smposano##2,
                 smposano##3 = vr_tab_sld(idx).smposano##3,
                 smposano##4 = vr_tab_sld(idx).smposano##4,
                 smposano##5 = vr_tab_sld(idx).smposano##5,
                 smposano##6 = vr_tab_sld(idx).smposano##6,
                 smposano##7 = vr_tab_sld(idx).smposano##7,
                 smposano##8 = vr_tab_sld(idx).smposano##8,
                 smposano##9 = vr_tab_sld(idx).smposano##9,
                 smposano##10 = vr_tab_sld(idx).smposano##10,
                 smposano##11 = vr_tab_sld(idx).smposano##11,
                 smposano##12 = vr_tab_sld(idx).smposano##12,
                 vlsmstre##1  = vr_tab_sld(idx).vlsmstre##1,
                 vlsmstre##2  = vr_tab_sld(idx).vlsmstre##2,
                 vlsmstre##3  = vr_tab_sld(idx).vlsmstre##3,
                 vlsmstre##4  = vr_tab_sld(idx).vlsmstre##4,
                 vlsmstre##5  = vr_tab_sld(idx).vlsmstre##5,
                 vlsmstre##6  = vr_tab_sld(idx).vlsmstre##6                                                            
           WHERE cdcooper = vr_tab_sld(idx).cdcooper
             AND nrdconta = vr_tab_sld(idx).nrdconta;                     
      EXCEPTION
        WHEN OTHERS THEN
          erro('Erro ao atualizar tabela crapsld. '||
                   SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          --Levantar Exceção
          RAISE vr_excsaida;
    END;
    
    COMMIT;    
    
  END LOOP; -- loop por cooperativa
   
  COMMIT;
   
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
  
end;