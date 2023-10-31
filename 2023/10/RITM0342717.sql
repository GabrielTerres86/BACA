DECLARE
 
 CURSOR cr_crapass (i_cdcooper number,i_nrdconta number) is
    SELECT a.nrdconta,
           a.cdcooper,
           a.cdsitdct,
           a.dtdemiss,
           a.cdmotdem,
           a.dtelimin,
           a.cdagenci
      FROM CECRED.CRAPASS a
     WHERE a.cdcooper = i_cdcooper
	   and a.nrdconta = i_nrdconta;
  rg_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_devolucao(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_tpdevolu NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.tpdevolucao
         , t.vlcapital
         , t.qtparcelas
         , t.dtinicio_credito
         , t.vlpago
      FROM cecred.tbcotas_devolucao t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper
       AND tpdevolucao = pr_tpdevolu;

   CURSOR cr_cotas(pr_cdcooper NUMBER
                  ,pr_nrdconta NUMBER) IS
    SELECT t.vldcotas
      FROM cecred.crapcot t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper; 
	   
  CURSOR cr_devo     (pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_tpdevolu NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.tpdevolucao
         , t.vlcapital
         , t.qtparcelas
         , t.dtinicio_credito
         , t.vlpago
      FROM cecred.tbcotas_devolucao t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper
       AND tpdevolucao = pr_tpdevolu;	   
   deva cr_devo%rowtype;

  

 
  vr_cdcriticGeral       cecred.crapcri.cdcritic%type;
  vr_dscriticGeral       cecred.crapcri.dscritic%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_vldcotasGeral       cecred.crapcot.vldcotas%type;
  vr_dtmvtolt            cecred.crapdat.dtmvtolt%type;
  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/RITM0342717';
  vr_nmarquiv            VARCHAR2(100) := 'base_conta_viacredi.txt';
  vr_nmarqbkp            VARCHAR2(100) := 'RITM0342717_script_rollback_test.sql';
  vr_nmarqcri            VARCHAR2(100) := 'RITM0342717_script_log_test.txt';

  vr_hutlfile            utl_file.file_type;
  vr_dstxtlid            VARCHAR2(1000);
  vr_contador            INTEGER := 0;
  vr_qtdctatt            INTEGER := 0;
  vr_flagfind            BOOLEAN := FALSE;
  vr_tab_linhacsv        cecred.gene0002.typ_split;
  vr_vet_dados           SISTEMA.tipoSplit.typ_split;
  vr_dstextab            varchar2(4000);
  vr_dsdrowid            VARCHAR2(50);
  vr_cdsitdct            NUMBER := 1;
  vr_nrdocmto            NUMBER;
  vr_nrseqdig            NUMBER;
  vr_lgrowid             ROWID;
  vr_vldcotas            NUMBER;
  vr_dstransa            VARCHAR2(100) := 'Reversão encerramento de conta em massa RITM0342717';
  vr_dscritic            VARCHAR2(2000);
  vr_tab_retorno         CECRED.LANC0001.typ_reg_retorno;
  vr_incrineg            INTEGER;
  vr_cdcritic            NUMBER;

  vr_flarqrol            utl_file.file_type;
  vr_flarqlog            utl_file.file_type;
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);
  vr_des_critic_xml      CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);
  vr_vlpago              NUMBER;  
  
  vr_exc_erro            EXCEPTION;
  vr_exc_clob            EXCEPTION;
  vr_des_erroGeral       VARCHAR2(4000);

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;
  

BEGIN
    CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_hutlfile
                          ,pr_des_erro => vr_dscriticGeral);

  IF vr_dscriticGeral IS NOT NULL THEN
    vr_dscriticGeral := 'Erro na leitura do arquivo -> '||vr_dscriticGeral;
    pc_escreve_xml_critica(vr_dscriticGeral || chr(10));
    RAISE vr_exc_erro;
  END IF;

  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;

  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN
      LOOP
        SAVEPOINT sessao_associado;
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile
                                           ,pr_des_text => vr_dstxtlid);

        IF length(vr_dstxtlid) <= 1 THEN
          continue;
        END IF;

        vr_contador := vr_contador + 1;
        vr_flagfind := FALSE;

        vr_tab_linhacsv := CECRED.gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := CECRED.gene0002.fn_char_para_number(vr_tab_linhacsv(2));
        
        vr_dtmvtolt := sistema.datascooperativa(vr_cdcooper).dtmvtolt;

        IF nvl(vr_cdcooper,0) = 0 OR nvl(vr_nrdconta,0) = 0 THEN
          pc_escreve_xml_critica('Erro ao encontrar cooperativa e conta ' || vr_dstxtlid  || chr(10));
          CONTINUE;
        END IF;
        
		open cr_crapass(vr_cdcooper,vr_nrdconta);
		fetch cr_crapass into rg_crapass;
		close cr_crapass;
		
		BEGIN
		
		 pc_escreve_xml_critica('Alterar situacao da conta : '||rg_crapass.nrdconta);
		 
		 UPDATE cecred.crapass SET cdsitdct = vr_cdsitdct
                                 , dtdemiss = NULL
                                 , dtelimin = NULL
                                 , cdmotdem = 0
          WHERE nrdconta = rg_crapass.nrdconta 
            AND cdcooper = rg_crapass.cdcooper;
		  
		  pc_escreve_xml_rollback('UPDATE CECRED.crapass '||chr(10)||
		                          '   SET cdsitdct = '||rg_crapass.cdsitdct||chr(10)||
		                          '     , dtdemiss = to_date('''||to_char(rg_crapass.dtdemiss,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'||chr(10)||
                                  case 
		  					    when rg_crapass.dtelimin is null THEN
                                  '     , dtelimin = NULL'
                                  else
		    					  '     , dtelimin = to_date('''||to_char(rg_crapass.dtelimin,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                                  end||chr(10)||
		                          '     , cdmotdem = '||NVL(rg_crapass.cdmotdem,0)||chr(10)||                            								
		                          ' WHERE cdcooper = '||rg_crapass.cdcooper||chr(10)|| 
	                              '   AND nrdconta = '||rg_crapass.nrdconta||';'||chr(10)||chr(10));
	      
	      
	    EXCEPTION
		   WHEN OTHERS THEN
		        pc_escreve_xml_critica('Erro ao atualizar registro da conta: '||sqlerrm);
			    vr_dscriticGeral := 'Erro ao atualizar registro da conta: '||sqlerrm;
                Raise vr_exc_erro;				
		END;
		
		pc_escreve_xml_critica('Gerar Logs da conta');
		
		gene0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper
                            ,pr_cdoperad => '1'
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => 'AIMARO'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => ''
                            ,pr_nrdconta => rg_crapass.nrdconta
                            ,pr_nrdrowid => vr_lgrowid);
      
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                 ,pr_nmdcampo => 'crapass.cdsitdct'
                                 ,pr_dsdadant => rg_crapass.cdsitdct
                                 ,pr_dsdadatu => vr_cdsitdct);
  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                 ,pr_nmdcampo => 'crapass.dtdemiss'
                                 ,pr_dsdadant => rg_crapass.dtdemiss
                                 ,pr_dsdadatu => NULL);
  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                 ,pr_nmdcampo => 'crapass.dtelimin'
                                 ,pr_dsdadant => rg_crapass.dtelimin
                                 ,pr_dsdadatu => NULL);
  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                 ,pr_nmdcampo => 'crapass.cdmotdem'
                                 ,pr_dsdadant => rg_crapass.cdmotdem
                                 ,pr_dsdadatu => 0);
		
		pc_escreve_xml_rollback('DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '||chr(10)||
		                        ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '||chr(10)||
		                        ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);'||chr(10)||chr(10));
		
		pc_escreve_xml_rollback('DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; ');
		
		
		vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';'||rg_crapass.cdagenci||';100;600040');
		
		pc_escreve_xml_critica('Verificando e estornando valores a devolver - Cotas');
		
		
		FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 1) LOOP
    
            vr_vlpago := 0;
			open cr_devo(rg_crapass.cdcooper, rg_crapass.nrdconta, 4);
			loop
			   fetch cr_devo into deva;
			   exit when cr_devo%notfound;
			   vr_vlpago := vr_vlpago + deva.vlpago;
			end loop;
			close cr_devo;
			
			IF vr_vlpago = 0 THEN
			   BEGIN
                 INSERT INTO CECRED.craplct
                             (cdcooper
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,dtmvtolt
                             ,cdhistor
                             ,nrctrpla
                             ,nrdconta
                             ,nrdocmto
                             ,nrseqdig
                             ,vllanmto
                             ,cdopeori
                             ,dtinsori)
                     VALUES (rg_crapass.cdcooper
                            ,rg_crapass.cdagenci
                            ,100
                            ,600040
                            ,vr_dtmvtolt
                            ,61
                            ,0
                            ,rg_crapass.nrdconta 
                            ,vr_nrdocmto
                            ,vr_nrseqdig
                            ,valor.vlcapital
                            ,1
                            ,SYSDATE) RETURN ROWID INTO vr_dsdrowid; 
    
                  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                           ,pr_nmdcampo => 'craplct.vllanmto'
                                           ,pr_dsdadant => NULL
                                           ,pr_dsdadatu => valor.vlcapital);
	              
                  pc_escreve_xml_rollback('DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ');   
               
               EXCEPTION
                  WHEN OTHERS THEN
                       pc_escreve_xml_critica('Erro ao realizar lançamento de cota: '||SQLERRM);     
                       vr_dscriticGeral := 'Erro ao realizar lançamento de cota: '||SQLERRM;
                       RAISE vr_exc_erro;
               END; 
		
		       cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper       => rg_crapass.cdcooper
                                                           ,pr_dtmvtolt    => vr_dtmvtolt
                                                           ,pr_cdagenci    => rg_crapass.cdagenci
                                                           ,pr_cdbccxlt    => 1
                                                           ,pr_nrdolote    => 600040
                                                           ,pr_nrdctabb    => rg_crapass.nrdconta
                                                           ,pr_nrdocmto    => vr_nrdocmto
                                                           ,pr_cdhistor    => 127
                                                           ,pr_vllanmto    => valor.vlcapital
                                                           ,pr_nrdconta    => rg_crapass.nrdconta
                                                           ,pr_hrtransa    => gene0002.fn_busca_time
                                                           ,pr_cdorigem    => 0
                                                           ,pr_inprolot    => 1
                                                           ,pr_tab_retorno => vr_tab_retorno
                                                           ,pr_incrineg    => vr_incrineg
                                                           ,pr_cdcritic    => vr_cdcritic
                                                           ,pr_dscritic    => vr_dscritic);
			   
                  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                     IF TRIM(vr_dscritic) IS NULL THEN
                        vr_dscriticGeral := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  END IF;
			   
                  pc_escreve_xml_critica('Erro ao incluir lancamento em conta: '||vr_dscritic); 
			   
                  vr_dscriticGeral := 'Erro ao incluir lancamento em conta: '||vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;
  
    
                gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                         ,pr_nmdcampo => 'craplcm.vllanmto'
                                         ,pr_dsdadant => NULL
                                         ,pr_dsdadatu => valor.vlcapital);
			    
                pc_escreve_xml_rollback('DELETE cecred.craplcm '||chr(10)||
                                        ' WHERE cdcooper = '||rg_crapass.cdcooper ||chr(10)||
                                        '   AND nrdconta = '||rg_crapass.nrdconta ||chr(10)||
                                        '   AND dtmvtolt = to_date('''||TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||chr(10)||
                                        '   AND cdagenci = '||rg_crapass.cdagenci||chr(10)||
                                        '   AND cdbccxlt = 1 '||chr(10)||
                                        '   AND nrdolote = 600040 '||chr(10)||
                                        '   AND nrdocmto = '||vr_nrdocmto||';'||chr(10)||chr(10));
		        
                pc_escreve_xml_critica('Lançado em saldo de conta o montande de: '||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
			
			
			
			
			    BEGIN
                  vr_vldcotas := 0;
      
                  OPEN  cr_cotas(rg_crapass.cdcooper, rg_crapass.nrdconta);
                  FETCH cr_cotas INTO vr_vldcotas;
                  CLOSE cr_cotas;
              
                  UPDATE CECRED.crapcot SET vldcotas = ( NVL(vldcotas,0) + NVL(valor.vlcapital,0) )
                   WHERE cdcooper = rg_crapass.cdcooper
                     AND nrdconta = rg_crapass.nrdconta;
              
                  pc_escreve_xml_rollback('UPDATE cecred.crapcot SET vldcotas = '||to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||' WHERE cdcooper = '||rg_crapass.cdcooper||' AND nrdconta = '||rg_crapass.nrdconta||'; '||chr(10)||chr(10)); 
      
                EXCEPTION
                   WHEN OTHERS THEN
                        pc_escreve_xml_critica('Erro ao atualizar valor de cota: '||SQLERRM); 
                       vr_dscriticGeral := 'Erro ao atualizar valor de cota: '||SQLERRM;
                       RAISE vr_exc_erro;
                END; 
	         	
		        BEGIN
                 DELETE cecred.tbcotas_devolucao
                  WHERE ROWID = valor.dsdrowid;
       
                pc_escreve_xml_rollback ('INSERT INTO cecred.tbcotas_devolucao '||chr(10)|| 
                                         '        (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) '||chr(10)|| 
                                         ' VALUES ('||valor.cdcooper||chr(10)|| 
                                         '        ,'||valor.nrdconta||chr(10)|| 
                                         '        ,'||valor.tpdevolucao||chr(10)|| 
                                         '        ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||chr(10)|| 
                                         Case 
                                           When valor.qtparcelas IS NULL THEN
                                         '        ,NULL' 
                                         else
                                         '        ,'||valor.qtparcelas 
                                         end||chr(10)||
                                         Case 
							               when valor.dtinicio_credito IS NULL THEN
                                         '        ,NULL' 
                                         else
                                         '        ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')' 
                                         end||chr(10)||
                                         '        ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');'||chr(10)||chr(10)); 
                EXCEPTION
                   WHEN OTHERS THEN
                        pc_escreve_xml_critica('Erro ao excluir registro de devolução tipo 1: '||SQLERRM); 
      
                        vr_dscriticGeral := 'Erro ao excluir registro de devolução tipo 1: '||SQLERRM;
                        RAISE vr_exc_erro;
                END; 
    
                pc_escreve_xml_critica('Lançado em cotas o montande de: '||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
            end if;
        END LOOP; 
		
		pc_escreve_xml_critica('Verificando e estornando valores a devolver - Saldo'); 
  
        vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';'||rg_crapass.cdagenci||';100;600040');
		FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 4) LOOP
    
            if valor.vlpago = 0 then
			   IF valor.vlcapital > 0  THEN
			   
                  cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => rg_crapass.cdcooper
                                                           ,pr_dtmvtolt    => vr_dtmvtolt
                                                           ,pr_cdagenci    => rg_crapass.cdagenci
                                                           ,pr_cdbccxlt    => 1
                                                           ,pr_nrdolote    => 600040
                                                           ,pr_nrdctabb    => rg_crapass.nrdconta
                                                           ,pr_nrdocmto    => vr_nrdocmto
                                                           ,pr_cdhistor    => 2520
                                                           ,pr_vllanmto    => valor.vlcapital
                                                           ,pr_nrdconta    => rg_crapass.nrdconta
                                                           ,pr_hrtransa    => gene0002.fn_busca_time
                                                           ,pr_cdorigem    => 0
                                                           ,pr_inprolot    => 1
                                                           ,pr_tab_retorno => vr_tab_retorno
                                                           ,pr_incrineg    => vr_incrineg
                                                           ,pr_cdcritic    => vr_cdcritic
                                                           ,pr_dscritic    => vr_dscritic);
			   
                  IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                     IF TRIM(vr_dscritic) IS NULL THEN
                        vr_dscriticGeral := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                  END IF;
			   
                  pc_escreve_xml_critica('Erro ao incluir lancamento em conta: '||vr_dscritic); 
			   
                  vr_dscriticGeral := 'Erro ao incluir lancamento em conta: '||vr_dscritic;
                  RAISE vr_exc_erro;
               END IF;
  
    
               gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                                        ,pr_nmdcampo => 'craplcm.vllanmto'
                                        ,pr_dsdadant => NULL
                                        ,pr_dsdadatu => valor.vlcapital);
			   
               pc_escreve_xml_rollback('DELETE cecred.craplcm '||chr(10)||
                                       ' WHERE cdcooper = '||rg_crapass.cdcooper ||chr(10)||
                                       '   AND nrdconta = '||rg_crapass.nrdconta ||chr(10)||
                                       '   AND dtmvtolt = to_date('''||TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')'||chr(10)||
                                       '   AND cdagenci = '||rg_crapass.cdagenci||chr(10)||
                                       '   AND cdbccxlt = 1 '||chr(10)||
                                       '   AND nrdolote = 600040 '||chr(10)||
                                       '   AND nrdocmto = '||vr_nrdocmto||';');
		       
               pc_escreve_xml_critica('Lançado em saldo de conta o montande de: '||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||chr(10)||chr(10)); 
			   
        END IF;  
        
        BEGIN
          DELETE cecred.tbcotas_devolucao
           WHERE ROWID = valor.dsdrowid;
            
           pc_escreve_xml_rollback('INSERT INTO cecred.tbcotas_devolucao '||chr(10)|| 
                                   '        (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) '||chr(10)|| 
                                   ' VALUES ('||valor.cdcooper||chr(10)|| 
                                   '        ,'||valor.nrdconta||chr(10)|| 
                                   '        ,'||valor.tpdevolucao||chr(10)|| 
                                   '        ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||chr(10)|| 
          
                                   case 
	                                 when valor.qtparcelas IS NULL THEN
                                   '        ,NULL' 
                                   else
                                   '        ,'||valor.qtparcelas 
                                   end||chr(10)||
        
                                   case 
	      						  when valor.dtinicio_credito IS NULL THEN
                                   '        ,NULL' 
                                   else
                                   '        ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')' 
                                   end||chr(10)||
                                   '        ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');'||chr(10)||chr(10)); 
          
        EXCEPTION
          WHEN OTHERS THEN
               pc_escreve_xml_critica('Erro ao excluir registro de devolução tipo 4: '||SQLERRM); 
           
               vr_dscriticGeral := 'Erro ao excluir registro de devolução tipo 4: '||SQLERRM;
               RAISE vr_exc_erro;
        END; 
     End if;
  END LOOP;
  
  		
  vr_qtdctatt := vr_qtdctatt + 1;
        
  IF mod(vr_qtdctatt,100) = 0 THEN
     COMMIT;
     dbms_output.put_line('Commit de ' || vr_qtdctatt || ' registros.');
  END IF;
        
  END LOOP;      

    EXCEPTION
      WHEN no_data_found THEN
        pc_escreve_xml_critica('Qtde contas lidas:'||vr_contador||chr(10));
        pc_escreve_xml_critica('Qtde contas atualizadas:'||vr_qtdctatt);
        pc_escreve_xml_critica(' ',TRUE);

        pc_escreve_xml_rollback('COMMIT;');
        pc_escreve_xml_rollback(' ',TRUE);

        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                             pr_caminho  => vr_arq_path,
                                             pr_arquivo  => vr_nmarqbkp,
                                             pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
           dbms_lob.close(vr_des_rollback_xml);
           dbms_lob.freetemporary(vr_des_rollback_xml);
           RAISE vr_exc_clob;
        END IF;

        CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                             pr_caminho  => vr_arq_path,
                                             pr_arquivo  => vr_nmarqcri,
                                             pr_des_erro => vr_des_erroGeral);
        IF (vr_des_erroGeral IS NOT NULL) THEN
           dbms_lob.close(vr_des_critic_xml);
           dbms_lob.freetemporary(vr_des_critic_xml);
           RAISE vr_exc_clob;
        END IF;

        dbms_lob.close(vr_des_rollback_xml);
        dbms_lob.freetemporary(vr_des_rollback_xml);

        dbms_lob.close(vr_des_critic_xml);
        dbms_lob.freetemporary(vr_des_critic_xml);

        dbms_output.put_line('Rotina finalizada, verifique arquivo de criticas em :' || vr_arq_path);
      WHEN OTHERS THEN
        dbms_output.put_line('Erro inesperado 1 - ' || SQLERRM);
        cecred.pc_internal_exception;
    END;
  END IF;
  
COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
       ROLLBACK;
       CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
       CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
       raise_application_error(-20001, vr_dscriticGeral);

  WHEN OTHERS THEN
       ROLLBACK;
       CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
       CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
       raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);  
END;
