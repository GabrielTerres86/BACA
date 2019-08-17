-- Created on 26/02/2019 by F0030248 
-- Baca para realizar cobrança de tarifa cartorária (Histórico 2610) 
-- de boletos não cobrados desde dez/2018 - INC0033882
declare 
  vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
  -- Local variables here
  i integer;
  CURSOR cr_crapcob IS 
    SELECT cco.cdbccxlt, cco.nrdolote, cco.cdagenci, dat.dtmvtolt, cob.rowid, cob.cdcooper, cob.nrdconta, cob.nrcnvcob, ret.vltarass, ret.dtocorre
      FROM crapret ret, crapcco cco, crapcob cob, crapdat dat
    WHERE cco.cdcooper >= 2    
      AND cco.cddbanco = 85
      AND dat.cdcooper = cco.cdcooper
      AND ret.cdcooper = cco.cdcooper
      AND ret.nrcnvcob = cco.nrconven
      AND ret.dtocorre >= to_date('01/12/2018','DD/MM/RRRR')
      AND ret.dtocorre <= trunc(sysdate)
      AND ret.cdocorre = 23
      AND ret.cdmotivo = '00'
      AND cob.cdcooper = ret.cdcooper
      AND cob.nrdconta = ret.nrdconta
      AND cob.nrcnvcob = ret.nrcnvcob
      AND cob.nrdocmto = ret.nrdocmto
      AND cob.cdbandoc = cco.cddbanco
      AND cob.nrdctabb = cco.nrdctabb;
  rw_crapcob cr_crapcob%ROWTYPE;        
  
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(1000);
  vr_index    VARCHAR2(40);  
begin
  -- Test statements here
  
  FOR rw_crapcob IN cr_crapcob LOOP   
    
    -- ignorar boletos com tarifa de protesto da transpocred anterior a 31/01/2019
    IF rw_crapcob.cdcooper = 9 AND rw_crapcob.dtocorre <= to_date('31/01/2019','DD/MM/RRRR') THEN
      CONTINUE;
    END IF;
  
    vr_tab_lcm_consolidada.delete;  
    
    PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob.rowid --ROWID da cobranca
                                        ,pr_cdocorre => 23      --Codigo Ocorrencia /* 24. Retir. Cartor. */
                                        ,pr_tplancto => 'T'     --Tipo Lancamento  /* tplancto = "C" Cartorio */
                                        ,pr_vltarifa => 0       --Valor Tarifa
                                        ,pr_cdhistor => 0       --Codigo Historico
                                        ,pr_cdmotivo => '00'    --Codigo motivo
                                        ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela de Lancamentos
                                  		,pr_cdcritic => vr_cdcritic      --Codigo Critica
										,pr_dscritic => vr_dscritic);    --Descricao Critica
  
    IF vr_tab_lcm_consolidada.count() > 0 THEN
      --
      vr_index:= vr_tab_lcm_consolidada.FIRST;      
      IF vr_tab_lcm_consolidada(vr_index).vllancto <> rw_crapcob.vltarass THEN
        dbms_output.put_line(rw_crapcob.rowid || ' - tarifa diferente: ' || vr_tab_lcm_consolidada(vr_index).vllancto || ' - ' || rw_crapcob.vltarass);
      END IF;
      
      paga0001.pc_realiza_lancto_cooperado(pr_cdcooper            => rw_crapcob.cdcooper    -- IN
                                          ,pr_dtmvtolt            => rw_crapcob.dtmvtolt    -- IN
                                          ,pr_cdagenci            => rw_crapcob.cdagenci    -- IN
                                          ,pr_cdbccxlt            => rw_crapcob.cdbccxlt    -- IN
                                          ,pr_nrdolote            => rw_crapcob.nrdolote    -- IN
                                          ,pr_cdpesqbb            => rw_crapcob.nrcnvcob    -- IN
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada -- IN
                                          ,pr_cdcritic            => vr_cdcritic            -- OUT
                                          ,pr_dscritic            => vr_dscritic            -- OUT
                                          );
      IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         dbms_output.put_line(rw_crapcob.rowid || ' - ' || vr_cdcritic || ' - ' || vr_dscritic);
      END IF;     
        
    END IF;
    
  END LOOP;
  
  COMMIT;    
  
end;
