-- Created on 18/08/2020 by F0030474 
declare 

  vr_dstransa VARCHAR2(1000);
	vr_cdcritic PLS_INTEGER;
	vr_dscritic crapcri.dscritic%TYPE;

  vr_clob_agen_migr CLOB := '################################### AGENDAMENTOS MIGRADOS ###################################' || chr(10)|| chr(10);
  vr_clob_agen_canc CLOB := 'Cooperativa;Conta;PA;Telefone;Data de Agendamento;Valor;Convenio;Código de barras' || chr(10);
  vr_clob_erros     CLOB := '########################################### ERROS ###########################################' || chr(10)|| chr(10);

	
  -- Local variables here
  CURSOR cr_craplau IS
	  SELECT lau.*, lau.rowid
		  FROM craplau lau
		 WHERE lau.insitlau = 1
       AND lau.dsorigem IN ('INTERNET','TAA','CAIXA')
       AND lau.tpdvalor = 1
			 AND lau.dtmvtopg >= trunc(SYSDATE);
			 
	CURSOR cr_crapcon(pr_cdempcon IN crapcon.cdempcon%TYPE
	                 ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
	  SELECT con.tparrecd
		      ,con.cdempcon
					,con.cdsegmto
					,con.nmrescon
		  FROM crapcon con
		 WHERE con.cdempcon = pr_cdempcon
		   AND con.cdsegmto = pr_cdsegmto
			 AND con.cdcooper = 3;
	rw_crapcon cr_crapcon%ROWTYPE;
	
	CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE
	                  ,pr_nrdconta IN craptfc.nrdconta%TYPE) IS
   SELECT '(' || to_char(nrdddtfc, 'fm00') || ')' || to_char(nrtelefo) nrtelefo
     FROM craptfc
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta
      AND idsittfc = 1
      AND tptelefo IN (1, 2)
      AND ROWNUM = 1;
	rw_craptfc cr_craptfc%ROWTYPE;
	
	CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
	                  ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
		SELECT ass.cdagenci
		      ,cop.nmrescop
	    FROM crapass ass
			    ,crapcop cop
		 WHERE ass.cdcooper = pr_cdcooper
		   AND ass.nrdconta = pr_nrdconta
			 AND cop.cdcooper = ass.cdcooper;
	rw_crapass cr_crapass%ROWTYPE;
begin
  -- Test statements here
  FOR rw_craplau IN cr_craplau LOOP
		
		IF TRIM(rw_craplau.dscodbar) IS NOT NULL THEN
			OPEN cr_crapcon (pr_cdempcon => substr(rw_craplau.dscodbar,16,4)
			                ,pr_cdsegmto => substr(rw_craplau.dscodbar,2,1));
			FETCH cr_crapcon INTO rw_crapcon;
						
			IF cr_crapcon%NOTFOUND THEN
			  CLOSE cr_crapcon;
				CONTINUE;	
			END IF;
			CLOSE cr_crapcon;
			
    IF (rw_crapcon.cdempcon = 64  AND rw_crapcon.cdsegmto = 5) OR
       (rw_crapcon.cdempcon = 385 AND rw_crapcon.cdsegmto = 5) OR
       (rw_crapcon.cdempcon = 153 AND rw_crapcon.cdsegmto = 5) OR
       (rw_crapcon.cdempcon = 154 AND rw_crapcon.cdsegmto = 5) OR
       (rw_crapcon.cdempcon = 328 AND rw_crapcon.cdsegmto = 5) OR
       (rw_crapcon.cdempcon = 270 AND rw_crapcon.cdsegmto = 5) THEN
      -- Não migraremos tributos neste momento
      CONTINUE;
    END IF;
			
			IF rw_crapcon.tparrecd = 2 THEN
				BEGIN
					UPDATE craplau lau
					   SET lau.tpdvalor = 2
					 WHERE lau.rowid = rw_craplau.rowid;

					vr_clob_agen_migr := vr_clob_agen_migr || to_clob(
															 'Cooperativa: ' || rw_craplau.cdcooper || chr(10) ||
															 'Conta: ' || rw_craplau.nrdconta || chr(10) ||
															 'Docmto: ' || rw_craplau.nrdocmto || chr(10) ||
															 'Data agend.: ' || to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR') || chr(10) ||
															 'Cód. Barras: ' || rw_craplau.dscodbar || chr(10) ||
															 'Valor: ' || rw_craplau.vllanaut || chr(10) ||
															 '-----------------------------------------------------' || chr(10));
					
				EXCEPTION
					WHEN OTHERS THEN
						vr_clob_erros := vr_clob_erros || to_clob('Erro ao atualizar agendamento -> cdcooper: ' || rw_craplau.cdcooper 
						                                                 || ', nrdconta: ' || rw_craplau.nrdconta
																														 || ', nrdocmto: ' || rw_craplau.nrdocmto
																														 || ', dtmvtopg: ' || to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR')
																														 || ', dscodbar: ' || rw_craplau.dscodbar || chr(10));
				END;
/*      ELSIF rw_crapcon.tparrecd = 1 THEN
				
				-- Cancelar agendamento
				PAGA0002.pc_cancelar_agendamento
													 ( pr_cdcooper => rw_craplau.cdcooper  --> Codigo da cooperativa
														,pr_cdagenci => rw_craplau.cdagenci  --> Codigo da agencia
														,pr_nrdcaixa => 900                  --> Numero do caixa
														,pr_cdoperad => '1'                  --> Codigo do operador
														,pr_nrdconta => rw_craplau.nrdconta  --> Numero da conta do cooperado
														,pr_idseqttl => rw_craplau.idseqttl  --> Sequencial do titular
														,pr_dtmvtolt => rw_craplau.dtmvtolt  --> Data do movimento
														,pr_dsorigem => rw_craplau.dsorigem  --> Descrição de origem do registro
														,pr_dtmvtage => rw_craplau.dtmvtolt  --> Data do agendamento
														,pr_nrdocmto => rw_craplau.nrdocmto  --> Numero do documento
														,pr_nmdatela => NULL                 --> Nome da tela
														--> parametros de saida
														,pr_dstransa => vr_dstransa          --> descrição de transação									                    
														,pr_dscritic => vr_dscritic );          --> Descricao critica  
	    
	    
				IF TRIM(vr_dscritic) IS NOT NULL OR
					 nvl(vr_cdcritic,0) > 0 THEN
            vr_clob_erros := vr_clob_erros || to_clob('Erro ao cancelar agendamento. Erro -> ' || vr_dscritic
						                                                 || '. Informacoes -> '
						                                                 || ' cdcooper: ' || rw_craplau.cdcooper 
                                                             || ', nrdconta: ' || rw_craplau.nrdconta
                                                             || ', nrdocmto: ' || rw_craplau.nrdocmto
                                                             || ', dtmvtopg: ' || to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR')
                                                             || ', dscodbar: ' || rw_craplau.dscodbar || chr(10));

				END IF;
				
				OPEN cr_craptfc(pr_cdcooper => rw_craplau.cdcooper
				               ,pr_nrdconta => rw_craplau.nrdconta);
				FETCH cr_craptfc INTO rw_craptfc;
				
				IF cr_craptfc%NOTFOUND THEN
					rw_craptfc.nrtelefo := 'Sem telefone';
				END IF;
				CLOSE cr_craptfc;
				
				OPEN cr_crapass(pr_cdcooper => rw_craplau.cdcooper
				               ,pr_nrdconta => rw_craplau.nrdconta);
				FETCH cr_crapass INTO rw_crapass;
				CLOSE cr_crapass;
				
				vr_clob_agen_canc := vr_clob_agen_canc || to_clob(
														 rw_crapass.nmrescop || ';' ||
														 rw_craplau.nrdconta || ';' ||
														 rw_crapass.cdagenci || ';' ||
														 rw_craptfc.nrtelefo || ';' ||
														 to_char(rw_craplau.dtmvtopg,'DD/MM/RRRR') || ';' ||
														 rw_craplau.vllanaut || ';' ||
														 rw_crapcon.nmrescon || ';' ||
														 rw_craplau.dscodbar || ';' || chr(10));*/
			END IF;
		END IF;
		
	END LOOP;
	
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_agen_migr || vr_clob_erros,
                               pr_caminho  => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                       ,pr_cdcooper => 0
                                                                       ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/reinert',
                               pr_arquivo  => 'rel_migra_agend.txt',
                               pr_des_erro => vr_dscritic);	
															 
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_clob_agen_canc,
                               pr_caminho  => gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                       ,pr_cdcooper => 0
                                                                       ,pr_cdacesso => 'ROOT_MICROS') || 'cecred/reinert',
                               pr_arquivo  => 'rel_agend_canc.csv',
                               pr_des_erro => vr_dscritic);	

															 
COMMIT;
end;
