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
   where t.cdcooper = 2;
  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;
 
                               
     vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '16757874;14',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 14,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 10,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 16757874,
                                                pr_nrdctabb    => 16757874,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 6000,
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
                                  ,''||14||';'
                                   ||to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'
                                   ||1||';'
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
              VALUES(14
                    ,vr_dtmvtolt
                    ,10
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,16757874
                    ,vr_nrdocmto
                    ,489 
                    ,6000);

        vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '16757874;14',
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
              VALUES(14
                    ,vr_dtmvtolt
                    ,10
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,16757874
                    ,vr_nrdocmto
                    ,3844 
                    ,6000);
       
        
  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;
 
                               
     vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '16290348;10',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 10,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 8,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 16290348,
                                                pr_nrdctabb    => 16290348,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 10000,
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
              VALUES(10
                    ,vr_dtmvtolt
                    ,8
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,16290348
                    ,vr_nrdocmto
                    ,489 
                    ,10000);

        vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '16290348;10',
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
              VALUES(10
                    ,vr_dtmvtolt
                    ,8
                    ,100
                    ,8503
                    ,vr_nrseqdig
                    ,16290348
                    ,vr_nrdocmto
                    ,3844 
                    ,10000);

        
  delete from CECRED.tbcc_lancamentos_pendentes t
   where t.nrdconta = 939013
     and t.cdcooper = 2
     and t.dtmvtolt = to_date('01/11/2023', 'DD/MM/RRRR')
     and t.nrdcmto = 2003
     and t.cdproduto = 3;
  i := 0;
  loop
    i := i + 1;
    if i = vr_tentativas then
      raise_application_error(-20001, vr_mensagem);
    end if;             
  vr_nrdocmto := fn_sequence(pr_nmtabela => 'CRAPLCM',
                             pr_nmdcampo => 'NRDOCMTO',
                             pr_dsdchave => '939013;2',
                             pr_flgdecre => 'N');                           
  
    BEGIN
      CECRED.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper    => 2,
                                                pr_dtmvtolt    => vr_dtmvtolt,
                                                pr_cdagenci    => 8,
                                                pr_cdbccxlt    => 0,
                                                pr_nrdolote    => 8503,
                                                pr_nrdconta    => 939013,
                                                pr_nrdctabb    => 939013,
                                                pr_nrdocmto    => vr_nrdocmto,
                                                pr_nrseqdig    => vr_nrdocmto,
                                                pr_dtrefere    => vr_dtmvtolt,
                                                pr_vllanmto    => 26361.83,
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
