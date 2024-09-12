declare
  vr_nrdocmto    CECRED.craplci.nrdocmto%TYPE;
  vr_nrseqdig    CECRED.craplci.nrdocmto%TYPE;
  vr_cdcritic    CECRED.crapcri.cdcritic%TYPE := 0;
  vr_dscritic    CECRED.crapcri.dscritic%TYPE := NULL;
  vr_tab_retorno CECRED.LANC0001.typ_reg_retorno;
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vr_incrineg    INTEGER;
  vr_dtmvtolt    CECRED.crapdat.dtmvtolt%type;
  i              integer;
  vr_mensagem    varchar2(4000);
  vr_tentativas  integer := 50;
Begin      

  select t.dtmvtolt
    into vr_dtmvtolt
    from CECRED.crapdat t
   where t.cdcooper = 1;
  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;
 
                               
     vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '4036484;1',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 1,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 50,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 4036484,
                                                pr_nrdctabb    => 4036484,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 89500,
                                                pr_cdhistor    => 3813,
                                                pr_inprolot    => 1,
                                                pr_tplotmov    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        raise_application_error('-20001', vr_dscritic);
      end if;
      exit;
    EXCEPTION
      WHEN OTHERS THEN
        Begin
          vr_mensagem := sqlerrm;
        End;
    end;    
  end loop;
       
   
   vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||1||';'
                                   ||to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||50||';'
                                   ||100||';'
                                   ||10104);


          INSERT INTO cecred.craplci
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,vllanmto)
              VALUES(1
                    ,vr_dtmvtolt
                    ,50
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,4036484
                    ,vr_nrdocmto
                    ,489 
                    ,89500);

        vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '4036484;1',
                             pr_flgdecre => 'N');  

          INSERT INTO cecred.craplci
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,vllanmto)
              VALUES(1
                    ,vr_dtmvtolt
                    ,50
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,4036484
                    ,vr_nrdocmto
                    ,3844
                    ,89500);  

  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;
 
                               
     vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '14191580;1',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 1,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 53,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 14191580,
                                                pr_nrdctabb    => 14191580,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 108095.39,
                                                pr_cdhistor    => 3813,
                                                pr_inprolot    => 1,
                                                pr_tplotmov    => 1,
                                                pr_tab_retorno => vr_tab_retorno,
                                                pr_incrineg    => vr_incrineg,
                                                pr_cdcritic    => vr_cdcritic,
                                                pr_dscritic    => vr_dscritic);
      IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'Erro ao inserir registro de lancamento de debito. Erro: ' ||
                       vr_dscritic;
        raise_application_error('-20001', vr_dscritic);
      end if;
      exit;
    EXCEPTION
      WHEN OTHERS THEN
        Begin
          vr_mensagem := sqlerrm;
        End;
    end;    
  end loop;
       
   
   vr_nrseqdig := fn_sequence('CRAPLOT'
                                  ,'NRSEQDIG'
                                  ,''||1||';'
                                   ||to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||53||';'
                                   ||100||';'
                                   ||10104);


          INSERT INTO cecred.craplci
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,vllanmto)
              VALUES(1
                    ,vr_dtmvtolt
                    ,53
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,14191580
                    ,vr_nrdocmto
                    ,489 
                    ,108095.39);

        vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '14191580;1',
                             pr_flgdecre => 'N');  

          INSERT INTO cecred.craplci
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrseqdig
                     ,nrdconta
                     ,nrdocmto
                     ,cdhistor
                     ,vllanmto)
              VALUES(1
                    ,vr_dtmvtolt
                    ,53
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,14191580
                    ,vr_nrdocmto
                    ,3844
                    ,108095.39); 


  UPDATE investimento.tbinvest_saldo_base_fria
     SET nmproduto = 'LCI 181 ACIMA 100MIL'
   WHERE dtsaldo = '11/09/2024'
     AND nmproduto like 'LCI 181D ACIMA 100MIL';                                                        
        
  commit;
  
EXCEPTION  
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : ' || SQLERRM;
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 999,
                           pr_cdprograma => 'SCRIPTLCI',
                           pr_cdcooper   => 3,
                           pr_idprglog   => vr_idprglog);
END;  
