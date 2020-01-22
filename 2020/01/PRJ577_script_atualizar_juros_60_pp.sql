DECLARE

  CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper = nvl(pr_cdcooper, cop.cdcooper)
       AND cop.flgativo = 1;
       
  CURSOR cr_crapepr(pr_cdcooper crapcop.cdcooper%TYPE
                   ) IS 
    SELECT crapepr.cdcooper
          ,crapepr.nrdconta
          ,crapepr.nrctremp               
      FROM crapepr
      JOIN crapdat
        ON crapdat.cdcooper = crapepr.cdcooper           
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.tpemprst = 1
       AND crapepr.inliquid = 0
       AND crapepr.inprejuz = 0
       AND EXISTS(SELECT 1
                    FROM crappep
                    WHERE crappep.cdcooper = crapepr.cdcooper
                      AND crappep.nrdconta = crapepr.nrdconta
                      AND crappep.nrctremp = crapepr.nrctremp
                      AND crappep.inliquid = 0
                      AND crappep.dtvencto + 59 <= crapdat.dtmvtolt);
         
  vr_qtdiaatr        NUMBER;                 --> Qtde dias em atraso
  vr_qtdias_atr      NUMBER; --> Qtde dias em atraso    
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
  
  -- Arquivo
  vr_arqhandl    utl_file.file_type;
  vr_linha       VARCHAR2(5000);
  vr_nmdireto    VARCHAR2(3000);
  
  vr_cdcooper    crapcop.cdcooper%TYPE := NULL; -- Informar NULL para todas as cooperativas
  
BEGIN
  
  vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3, pr_nmsubdir => '/log');
  
  -- Abrir arquivo
  GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => 'atualizacao_juros_60_pp.txt'
                          ,pr_tipabert => 'A'
                          ,pr_utlfileh => vr_arqhandl
                          ,pr_des_erro => vr_dscritic
                          );
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
  
  vr_linha := 'Cooperativa;Conta;Contrato;Valor até 59 dias';
  GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
  GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);
  
  FOR rw_crapcop IN cr_crapcop(vr_cdcooper) LOOP
                           
    FOR rw_crapepr IN cr_crapepr(rw_crapcop.cdcooper) LOOP
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
      
      -- Abrir arquivo
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                              ,pr_nmarquiv => 'atualizacao_juros_60_pp.txt'
                              ,pr_tipabert => 'A'
                              ,pr_utlfileh => vr_arqhandl
                              ,pr_des_erro => vr_dscritic
                              );
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_linha := rw_crapepr.cdcooper||';'||
                  rw_crapepr.nrdconta||';'||
                  rw_crapepr.nrctremp||';'||
                  vr_vljura60;
      
      GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);
      
    END LOOP;
    
    vr_linha := 'Sucesso';
    
    dbms_output.put_line(vr_linha);
    --COMMIT;
    
  END LOOP;

EXCEPTION
  WHEN vr_exc_erro THEN
    vr_linha := 'ERRO Script PRJ577: ' || vr_dscritic;
    -- Abrir arquivo
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                            ,pr_nmarquiv => 'atualizacao_juros_60_pp.txt'
                            ,pr_tipabert => 'A'
                            ,pr_utlfileh => vr_arqhandl
                            ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);
    
  WHEN OTHERS THEN
    vr_linha := 'ERRO Script PRJ577: ' || SQLERRM;
    -- Abrir arquivo
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                            ,pr_nmarquiv => 'atualizacao_juros_60_pp.txt'
                            ,pr_tipabert => 'A'
                            ,pr_utlfileh => vr_arqhandl
                            ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    GENE0001.pc_escr_linha_arquivo(vr_arqhandl,vr_linha);
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandl);
END;
