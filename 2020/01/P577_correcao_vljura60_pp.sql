DECLARE

  CURSOR cr_crapepr IS 
    SELECT crapris.cdcooper,
           crapris.nrdconta,
           crapris.nrctremp
      FROM crapris
      JOIN crapepr
        ON crapepr.cdcooper = crapris.cdcooper
       AND crapepr.nrdconta = crapris.nrdconta
       AND crapepr.nrctremp = crapris.nrctremp
     WHERE crapris.dtrefere = '27/01/2020'
       AND crapris.cdorigem = 3
       AND crapepr.inprejuz = 0
       AND crapepr.tpemprst = 1
       AND crapepr.tpdescto = 1
       AND EXISTS (SELECT 1
                     FROM crapvri
                    WHERE crapvri.cdcooper = crapris.cdcooper
                      AND crapvri.nrdconta = crapris.nrdconta
                      AND crapvri.nrctremp = crapris.nrctremp
                      AND crapvri.dtrefere = crapris.dtrefere
                      AND crapvri.innivris = crapris.innivris
                      AND crapvri.cdmodali = crapris.cdmodali
                      AND crapvri.nrseqctr = crapris.nrseqctr
                      AND crapvri.vlempres = 0);
         
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel; --> Tabela com registros de pagamentos
  vr_vljura60        NUMBER(25,2);
  
  -- Erro em chamadas da pc_gera_erro
  vr_tab_erro        GENE0001.typ_tab_erro;  
  vr_exc_erro        EXCEPTION;
  vr_dscritic        VARCHAR2(2000);
  
BEGIN
            
  FOR rw_crapepr IN cr_crapepr LOOP
    -- Busca Pagamento de Parcela  
    EMPR9999.pc_calcula_juros_59_pp(pr_cdcooper        => rw_crapepr.cdcooper
                                   ,pr_nrdconta        => rw_crapepr.nrdconta
                                   ,pr_nrctremp        => rw_crapepr.nrctremp
                                   ,pr_nrparepr        => 0
                                   ,pr_tab_erro        => vr_tab_erro
                                   ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                   );

    IF vr_tab_erro.exists(vr_tab_erro.first) THEN
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).cdcritic || ' - ' || vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_erro;
    END IF;
          
    vr_vljura60 := 0;
      
    FOR idx IN vr_tab_pgto_parcel.FIRST..vr_tab_pgto_parcel.LAST LOOP
      vr_vljura60 := vr_vljura60 + vr_tab_pgto_parcel(idx).vlatupar;
        
      BEGIN
        UPDATE crappep
           SET crappep.vljura60 = vr_tab_pgto_parcel(idx).vlatupar                
         WHERE crappep.cdcooper = rw_crapepr.cdcooper
           AND crappep.nrdconta = rw_crapepr.nrdconta
           AND crappep.nrctremp = rw_crapepr.nrctremp
           AND crappep.nrparepr = vr_tab_pgto_parcel(idx).nrparepr;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar crappep. ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
            
    END LOOP;
      
  END LOOP;
    
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('ERRO Script PRJ577: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    dbms_output.put_line('ERRO Script PRJ577: ' || SQLERRM);
END;