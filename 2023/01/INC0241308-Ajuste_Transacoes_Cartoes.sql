declare 
  pr_dtmvtolt  date := to_date('31/01/2022','dd/mm/rrrr');
  pr_dtmvtolt2 date := to_date('31/12/2022','dd/mm/rrrr');
  vr_dsjobnam  VARCHAR2(100):= 'JBCRD_IMPORTA_UTLZ_CARTAO - VIA BACA';

  TYPE typ_reg_utlz_crd IS
    RECORD(dtmvtolt         tbcrd_intermed_utlz_cartao.dtmvtolt%TYPE
           ,nrconta_cartao   tbcrd_intermed_utlz_cartao.nrconta_cartao%TYPE
           ,qttransa_debito  tbcrd_intermed_utlz_cartao.qttransa_debito%TYPE
           ,qttransa_credito tbcrd_intermed_utlz_cartao.qttransa_credito%TYPE
           ,vltransa_debito  tbcrd_intermed_utlz_cartao.vltransa_debito%TYPE
           ,vltransa_credito tbcrd_intermed_utlz_cartao.vltransa_credito%TYPE); 
  TYPE typ_tab_utlz_crd IS
    TABLE OF typ_reg_utlz_crd;
    
  TYPE typ_reg_conta_crd IS
    RECORD(cdcooper        crapass.cdcooper%TYPE
           ,nrdconta        crapass.nrdconta%TYPE); 
  TYPE typ_tab_conta_crd IS
    TABLE OF typ_reg_conta_crd INDEX BY VARCHAR2(15);

  vr_tab_utlz_crd  typ_tab_utlz_crd;
  vr_tab_conta_crd typ_tab_conta_crd;     
   
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(500);
  vr_exc_erro  EXCEPTION;
	vr_qtdregis INTEGER := 0;
     
  CURSOR cr_intermedcrd IS
    SELECT inmedcrd.dtmvtolt
           ,inmedcrd.nrconta_cartao
           ,inmedcrd.qttransa_debito
           ,inmedcrd.qttransa_credito
           ,inmedcrd.vltransa_debito
           ,inmedcrd.vltransa_credito
    FROM tbcrd_intermed_utlz_cartao inmedcrd
    WHERE (inmedcrd.dtmvtolt >= pr_dtmvtolt AND inmedcrd.dtmvtolt <= pr_dtmvtolt2); 

  CURSOR cr_contacrd IS
    SELECT tbcc.cdcooper
           ,tbcc.nrdconta
           ,tbcc.nrconta_cartao
    FROM tbcrd_conta_cartao tbcc;
  rw_contacrd cr_contacrd%ROWTYPE;
   
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E'
                                  ,pr_tpocorre IN NUMBER   DEFAULT 2 
                                  ,pr_cdcricid IN NUMBER   DEFAULT 2 
                                  ,pr_tpexecuc IN NUMBER   DEFAULT 2 
                                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                  ,pr_cdcritic IN VARCHAR2 DEFAULT NULL
                                  ,pr_cdcooper IN VARCHAR2
                                  ,pr_flgsuces IN NUMBER   DEFAULT 1    
                                  ,pr_flabrchd IN INTEGER  DEFAULT 0    
                                  ,pr_textochd IN VARCHAR2 DEFAULT NULL 
                                  ,pr_desemail IN VARCHAR2 DEFAULT NULL 
                                  ,pr_flreinci IN INTEGER  DEFAULT 0    
  ) IS
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;        
  BEGIN
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog  
                           ,pr_tpocorrencia  => pr_tpocorre 
                           ,pr_cdcriticidade => pr_cdcricid 
                           ,pr_tpexecucao    => pr_tpexecuc 
                           ,pr_dsmensagem    => pr_dscritic
                           ,pr_cdmensagem    => pr_cdcritic
                           ,pr_cdcooper      => NVL(pr_cdcooper,0)
                           ,pr_flgsucesso    => pr_flgsuces
                           ,pr_flabrechamado => pr_flabrchd 
                           ,pr_texto_chamado => pr_textochd
                           ,pr_destinatario_email => pr_desemail
                           ,pr_flreincidente => pr_flreinci
                           ,pr_cdprograma    => vr_dsjobnam
                           ,pr_idprglog      => vr_idprglog);   
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => 3);                                                             
  END pc_controla_log_batch;

begin  
  DELETE tbcrd_utilizacao_cartao c
   WHERE (c.dtmvtolt >= pr_dtmvtolt AND c.dtmvtolt <= pr_dtmvtolt2);
  
  OPEN  cr_intermedcrd;
  FETCH cr_intermedcrd BULK COLLECT INTO vr_tab_utlz_crd;     
  CLOSE cr_intermedcrd;

  FOR rw_contacrd IN cr_contacrd LOOP
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).cdcooper := rw_contacrd.cdcooper;
    vr_tab_conta_crd(rw_contacrd.nrconta_cartao).nrdconta := rw_contacrd.nrdconta;                  
  END LOOP;
   
  IF vr_tab_utlz_crd.COUNT = 0 THEN
    vr_dscritic := 'Sem dados para importacao!';
    raise vr_exc_erro;
  ELSE
    FOR idx IN vr_tab_utlz_crd.FIRST .. vr_tab_utlz_crd.LAST LOOP             
      IF vr_tab_conta_crd.EXISTS(vr_tab_utlz_crd(idx).nrconta_cartao) = FALSE THEN                     
				vr_cdcritic := 9;
				vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;                        
				pc_controla_log_batch(pr_dstiplog => 'O'
														 ,pr_tpocorre => 1
														 ,pr_cdcricid => 0
														 ,pr_cdcritic => NVL(vr_cdcritic,0)
														 ,pr_dscritic => vr_dscritic
														 ,pr_cdcooper => 3);                                 
				CONTINUE;
      END IF;

			BEGIN
			INSERT INTO tbcrd_utilizacao_cartao (
								 dtmvtolt
								 ,nrconta_cartao
								 ,cdcooper
								 ,nrdconta
								 ,qttransa_debito
								 ,qttransa_credito
								 ,vltransa_debito
								 ,vltransa_credito
			) VALUES (
								 vr_tab_utlz_crd(idx).dtmvtolt
								 ,vr_tab_utlz_crd(idx).nrconta_cartao
								 ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).cdcooper
								 ,vr_tab_conta_crd(vr_tab_utlz_crd(idx).nrconta_cartao).nrdconta
								 ,vr_tab_utlz_crd(idx).qttransa_debito
								 ,vr_tab_utlz_crd(idx).qttransa_credito
								 ,vr_tab_utlz_crd(idx).vltransa_debito
								 ,vr_tab_utlz_crd(idx).vltransa_credito
			);
			EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
					vr_cdcritic := 285;
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || 'Nr Conta Cartao = ' || vr_tab_utlz_crd(idx).nrconta_cartao;
					
					pc_controla_log_batch(pr_dstiplog => 'O'
															 ,pr_tpocorre => 4
															 ,pr_cdcricid => 0
															 ,pr_cdcritic => NVL(vr_cdcritic,0)
															 ,pr_dscritic => vr_dscritic
															 ,pr_cdcooper => 3);                
					
			WHEN OTHERS THEN
					vr_cdcritic := 9999;
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || SQLERRM;
					
					pc_controla_log_batch(pr_dstiplog => 'O'
															 ,pr_tpocorre => 4
															 ,pr_cdcricid => 0
															 ,pr_cdcritic => NVL(vr_cdcritic,0)
															 ,pr_dscritic => vr_dscritic
															 ,pr_cdcooper => 3);                                               
			 
			END;
			vr_qtdregis := vr_qtdregis + 1;
			IF MOD(vr_qtdregis, 10000) = 0 THEN
				COMMIT;
			END IF;
		END LOOP;
  END IF;  

	vr_dscritic := 'SUCESSO';
	pc_controla_log_batch(pr_dstiplog => 'F'
                       ,pr_flgsuces => 1
                       ,pr_cdcooper => 3);
											 
  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      vr_dscritic := 'ERRO ' ||nvl(vr_dscritic,' ');      
        pc_controla_log_batch(pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_cdcricid => 0
                             ,pr_cdcritic => NVL(vr_cdcritic,0)
                             ,pr_dscritic => vr_dscritic
                             ,pr_cdcooper => 3
                             ,pr_flgsuces => 0);  
end;
