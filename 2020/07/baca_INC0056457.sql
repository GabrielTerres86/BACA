-- Created on 29/07/2020 by F0030248 
declare 
  -- Local variables here
  i integer;
	vr_dscritic VARCHAR2(1000);
begin
  -- Test statements here
  FOR rw IN ( SELECT cob.rowid, r.cdcooper, r.nrdconta, r.nrcnvcob, r.nrdocmto 
                FROM crapret r, crapcop c, crapcob cob
              WHERE r.cdcooper > 0
                AND c.cdcooper = r.cdcooper
                AND r.dtocorre = TO_DATE('21/07/2020','DD/MM/RRRR')
                AND r.cdocorre IN (6,17,76,77)
                AND (r.cdbcorec = 85 AND r.cdagerec <> c.cdagectl)
                AND cob.cdcooper = r.cdcooper
                AND cob.nrdconta = r.nrdconta
                AND cob.nrcnvcob = r.nrcnvcob
                AND cob.nrdocmto = r.nrdocmto) LOOP
								
    paga0001.pc_solicita_crapdda(pr_cdcooper => rw.cdcooper
                                , pr_dtmvtolt => trunc(SYSDATE)
                                , pr_cobrowid => rw.rowid
                                , pr_dscritic => vr_dscritic);
															 
    IF TRIM(vr_dscritic) IS NOT NULL THEN															 
			btch0001.pc_gera_log_batch(pr_cdcooper     => rw.cdcooper
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_cdprograma   => 'BACA_CRAPDDA'																
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - baca solicita_crapdda --> '||
                                                    'ALERTA: '|| vr_dscritic ||
                                                    ' ,cdcooper:'||rw.cdcooper||',nrdconta:'||rw.nrdconta||
                                                    ',nrcnvcob:'||rw.nrcnvcob||',nrdocmto:'||rw.nrdocmto); 																										
    END IF;
								
  END LOOP;									
	
	btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                            ,pr_ind_tipo_log => 1 -- Mensagem
                            ,pr_cdprograma   => 'BACA_CRAPDDA'
                            ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||	
                                                ' - baca solicita_crapdda --> OK');	
																								
	COMMIT;																								
	
	EXCEPTION 
		WHEN OTHERS THEN
			btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 1 -- Mensagem
                                ,pr_cdprograma   => 'BACA_CRAPDDA'																
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' - baca solicita_crapdda --> '||
                                                    'Erro: '|| SQLERRM);
    ROLLBACK;
end;
