PL/SQL Developer Test script 3.0
79
declare 
  CURSOR cr_crapepr IS 
        SELECT crapepr.cdcooper,
               crapepr.nrdconta,
               crapepr.nrctremp               
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
          join crapdat
            on crapdat.cdcooper = crapepr.cdcooper           
         WHERE crapepr.cdcooper = 13         
           and crapepr.tpemprst = 1
           and crapepr.inliquid = 0
           and crapepr.inprejuz = 0
           and crawepr.flgreneg = 0
           and exists (select 1
                         from crappep
                        where crappep.cdcooper = crapepr.cdcooper
                          and crappep.nrdconta = crapepr.nrdconta
                          and crappep.nrctremp = crapepr.nrctremp
                          and crappep.inliquid = 0
                          and crappep.dtvencto + 59 <= crapdat.dtmvtolt);
         
  vr_qtdiaatr        NUMBER;
  vr_qtdias_atr      NUMBER;
  vr_flgjurdia       BOOLEAN := TRUE; -- PJ577
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
  vr_tab_calculado   empr0001.typ_tab_calculado;   --> Tabela com totais calculados
  vr_dtmvtoan        DATE;
  vr_vljura60        NUMBER(25,2);
  
  -- Erro em chamadas da pc_gera_erro
  vr_des_reto        VARCHAR(4000);
  vr_tab_erro        GENE0001.typ_tab_erro;  
  vr_exc_erro        EXCEPTION;
  vr_dscritic        VARCHAR2(2000);
begin
  FOR rw_crapepr IN cr_crapepr LOOP
    -- Busca Pagamento de Parcela  
    EMPR9999.pc_calcula_juros_59_pp_baca(pr_cdcooper => rw_crapepr.cdcooper                                       
                                        ,pr_nrdconta => rw_crapepr.nrdconta
                                        ,pr_nrctremp => rw_crapepr.nrctremp
                                        ,pr_nrparepr => 0
                                        ,pr_tab_erro => vr_tab_erro
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel);

    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).cdcritic || ' - ' || vr_tab_erro(vr_tab_erro.first).dscritic;
    END IF;
        
    FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
      BEGIN
          UPDATE crappep
             SET crappep.vljura60 = vr_tab_pgto_parcel(idx).vlatupar
           WHERE crappep.cdcooper = rw_crapepr.cdcooper
             and crappep.nrdconta = rw_crapepr.nrdconta
             and crappep.nrctremp = rw_crapepr.nrctremp
             and crappep.nrparepr = vr_tab_pgto_parcel(idx).nrparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
            RAISE vr_exc_erro;
      END;
    END LOOP;
  end loop;
  
  commit;
  :result := 'Sucesso';   

exception
  WHEN vr_exc_erro THEN
    ROLLBACK;
    :result := vr_dscritic;
  when others then
    ROLLBACK;
    :result := sqlerrm;
end;
0
0
