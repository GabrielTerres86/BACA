DECLARE

  vc_cdhistor_PF    CONSTANT NUMBER := 4595;
  vc_cdhistor_PJ    CONSTANT NUMBER := 4596;
  vc_cdhistor_caixa CONSTANT NUMBER := 4597;
  vc_cdoperad       CONSTANT VARCHAR2(20) := 'f0010002';

  CURSOR cd_cooperativa IS
    SELECT cop.cdcooper
         , dat.dtmvtolt
         , dat.dtmvtocd
         , DECODE(cop.cdcooper, 1,  1,  2, 14,  5,  9
                              , 6,  2,  7,  1,  8,  1
                              , 9,  1, 10,  3, 11, 95
                              , 12, 1, 13,  1, 14,  1, 16, 1) cdagenci
         , DECODE(cop.cdcooper, 1,  22,  2,  5,  5,  4
                              , 6,  1,  7,100,  8,  1
                              , 9,  7, 10,  1, 11,  1
                              , 12,10, 13,  6, 14, 10, 16, 1) nrdcaixa
         , DECODE(cop.cdcooper, 1,vc_cdoperad, 2,vc_cdoperad, 3,vc_cdoperad, 4,vc_cdoperad
                              , 5,vc_cdoperad, 6,vc_cdoperad, 7,vc_cdoperad, 8,vc_cdoperad
                              , 9,vc_cdoperad,10,vc_cdoperad,11,vc_cdoperad,12,vc_cdoperad
                              ,13,vc_cdoperad,14,vc_cdoperad,15,vc_cdoperad,16,vc_cdoperad
                              ,17,vc_cdoperad) cdoperad
      FROM crapcop cop
     INNER JOIN crapdat dat
        ON dat.cdcooper = cop.cdcooper
     WHERE cop.flgativo = 1 AND cop.cdcooper = 1
       AND cop.cdcooper <> 3;

  CURSOR cr_valores(pr_cdcooper NUMBER) IS
    SELECT ass.cdcooper
         , ass.nrdconta
         , ass.inpessoa
         , decode(ass.inpessoa,1,vc_cdhistor_PF,vc_cdhistor_PJ) cdhistor
         , dev.dtinicio_credito
         , dev.vlcapital - dev.vlpago vldsaldo
      FROM crapass ass
     INNER JOIN tbcotas_devolucao dev
        ON dev.cdcooper = ass.cdcooper
       AND dev.nrdconta = ass.nrdconta
     WHERE ass.cdcooper    = pr_cdcooper
       AND dev.tpdevolucao = 4
       AND dev.vlcapital   > dev.vlpago
       AND ass.dtdemiss   <= to_date('16/09/2024','dd/mm/yyyy') AND ROWNUM <= 500
       AND NOT EXISTS (SELECT 1 
                         FROM crapttl ttl
                        WHERE ttl.cdcooper = ass.cdcooper
                          AND ttl.nrdconta = ass.nrdconta
                          AND ttl.cdsitcpf = 6);

  CURSOR cr_crapbcx(pr_cdcooper  NUMBER
                   ,pr_dtmvtocd  DATE
                   ,pr_cdagenci  NUMBER
                   ,pr_nrdcaixa  NUMBER
                   ,pr_cdoperad  VARCHAR2) IS
    SELECT bcx.nrdmaqui
      FROM crapbcx bcx
     WHERE bcx.cdcooper = pr_cdcooper   
       AND bcx.dtmvtolt = pr_dtmvtocd     
       AND bcx.cdagenci = pr_cdagenci
       AND bcx.nrdcaixa = pr_nrdcaixa  
       AND bcx.cdopecxa = pr_cdoperad 
       AND bcx.cdsitbcx = 1;
  rw_crapbcx     cr_crapbcx%ROWTYPE;
  
  vr_nrdrowid    ROWID;
  vr_literal     VARCHAR2(100);
  vr_sequencia   INTEGER;
  vr_registro    ROWID;
  vr_cdcritic    INTEGER;
  vr_dscritic    VARCHAR2(2000);
  vr_nrdocmto    NUMBER;
  vr_vltotcop    NUMBER;
  vr_nrseqdig    NUMBER;
  
BEGIN

  FOR coop IN cd_cooperativa LOOP
    
    vr_vltotcop := 0;
    
    OPEN  cr_crapbcx(coop.cdcooper, coop.dtmvtocd, coop.cdagenci, coop.nrdcaixa, coop.cdoperad);
    FETCH cr_crapbcx INTO rw_crapbcx;
    
    IF cr_crapbcx%NOTFOUND THEN
      CLOSE cr_crapbcx;
      vr_cdcritic := 698;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      raise_application_error(-20005,vr_cdcritic||' - '||vr_dscritic);
    END IF;
    
    CLOSE cr_crapbcx;
    
    FOR reg IN cr_valores(coop.cdcooper) LOOP
      
      BEGIN
        UPDATE cecred.tbcotas_devolucao dev
           SET dev.dtinicio_credito = coop.dtmvtolt
             , dev.vlpago           = (dev.vlpago + reg.vldsaldo)
         WHERE dev.cdcooper         = reg.cdcooper
           AND dev.nrdconta         = reg.nrdconta
           AND dev.tpdevolucao      = 4;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20001,'Erro ao atualizar tbcotas_devolucao('||coop.cdcooper||'/'||reg.nrdconta||'): '||SQLERRM);
      END;
      
      BEGIN
        INSERT INTO contacorrente.tbcc_controle_devolucoes
                         (cdcooper
                         ,nrdconta
                         ,dtcreant 
                         ,vldsaldo)
                   VALUES(reg.cdcooper
                         ,reg.nrdconta
                         ,reg.dtinicio_credito
                         ,reg.vldsaldo);
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20002,'Erro ao incluir tbcc_controle_devolucoes('||coop.cdcooper||'/'||reg.nrdconta||'): '||SQLERRM);
      END;
      
      geralog(pr_cdcooper => reg.cdcooper
             ,pr_nrdconta => reg.nrdconta
             ,pr_cdoperad => coop.cdoperad
             ,pr_dscritic => NULL
             ,pr_dsorigem => 'SCRIPT'
             ,pr_dstransa => 'Captação de Recursos Esquecidos para União conf. Lei 14973/23 arts. 45-47'
             ,pr_dttransa => TRUNC(SYSDATE)
             ,pr_flgtrans => 1
             ,pr_hrtransa => gene0002.fn_busca_time
             ,pr_idseqttl => 1
             ,pr_nmdatela => 'ATENDA'
             ,pr_nrdrowid => vr_nrdrowid);

      geralogitem(pr_nrdrowid => vr_nrdrowid
                 ,pr_nmdcampo => 'Valor Total Captado'
                 ,pr_dsdadant => reg.vldsaldo
                 ,pr_dsdadatu => 0);
      
      vr_nrdocmto := gene0002.fn_busca_time;
      vr_vltotcop := NVL(vr_vltotcop,0) + reg.vldsaldo;
      
      BEGIN
          
        CXON0000.pc_grava_autenticacao(pr_cooper       => reg.cdcooper
                                      ,pr_cod_agencia  => coop.cdagenci 
                                      ,pr_nro_caixa    => coop.nrdcaixa
                                      ,pr_cod_operador => coop.cdoperad
                                      ,pr_valor        => reg.vldsaldo
                                      ,pr_docto        => vr_nrdocmto
                                      ,pr_operacao     => TRUE
                                      ,pr_status       => 1
                                      ,pr_estorno      => FALSE
                                      ,pr_histor       => reg.cdhistor
                                      ,pr_data_off     => NULL
                                      ,pr_sequen_off   => 0
                                      ,pr_hora_off     => 0
                                      ,pr_seq_aut_off  => 0
                                      ,pr_literal      => vr_literal  
                                      ,pr_sequencia    => vr_sequencia
                                      ,pr_registro     => vr_registro 
                                      ,pr_cdcritic     => vr_cdcritic 
                                      ,pr_dscritic     => vr_dscritic );
        
        IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
          raise_application_error(-20003,'Erro gravar autenticação('||coop.cdcooper||'/'||reg.nrdconta||'): '||vr_cdcritic||' - '||vr_dscritic);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20004,'Erro pc_grava_autenticacao('||coop.cdcooper||'/'||reg.nrdconta||'): '||SQLERRM);
      END;
      
      vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(reg.cdcooper)
                                ,pr_flgdecre => 'N');
      
      BEGIN
        INSERT INTO craplcx(cdagenci
                           ,cdhistor
                           ,cdopecxa
                           ,dtmvtolt
                           ,nrdcaixa
                           ,nrdmaqui
                           ,nrdocmto
                           ,nrseqdig
                           ,vldocmto
                           ,dsdcompl
                           ,nrautdoc
                           ,cdcooper
                           ,nrdconta)
                    VALUES (coop.cdagenci
                           ,reg.cdhistor
                           ,coop.cdoperad
                           ,coop.dtmvtolt
                           ,coop.nrdcaixa
                           ,rw_crapbcx.nrdmaqui
                           ,vr_nrdocmto
                           ,vr_nrseqdig
                           ,reg.vldsaldo
                           ,'Agencia: ' || LPAD(coop.cdagenci,3,'0') || ' Conta/DV: ' || LPAD(reg.nrdconta,8,'0')
                           ,vr_sequencia
                           ,reg.cdcooper
                           ,reg.nrdconta);
                        
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20006,'Erro incluir lançamento craplcx('||coop.cdcooper||'/'||reg.nrdconta||'): '||SQLERRM);
      END;
      
    END LOOP;
    
    vr_nrdocmto := gene0002.fn_busca_time;
    
    BEGIN
          
      CXON0000.pc_grava_autenticacao(pr_cooper       => coop.cdcooper
                                    ,pr_cod_agencia  => coop.cdagenci 
                                    ,pr_nro_caixa    => coop.nrdcaixa
                                    ,pr_cod_operador => coop.cdoperad
                                    ,pr_valor        => vr_vltotcop
                                    ,pr_docto        => vr_nrdocmto
                                    ,pr_operacao     => TRUE
                                    ,pr_status       => 1
                                    ,pr_estorno      => FALSE
                                    ,pr_histor       => vc_cdhistor_caixa
                                    ,pr_data_off     => NULL
                                    ,pr_sequen_off   => 0
                                    ,pr_hora_off     => 0
                                    ,pr_seq_aut_off  => 0
                                    ,pr_literal      => vr_literal  
                                    ,pr_sequencia    => vr_sequencia
                                    ,pr_registro     => vr_registro 
                                    ,pr_cdcritic     => vr_cdcritic 
                                    ,pr_dscritic     => vr_dscritic );
        
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        raise_application_error(-20007,'Erro gravar autenticação('||coop.cdcooper||'): '||vr_cdcritic||' - '||vr_dscritic);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20008,'Erro pc_grava_autenticacao('||coop.cdcooper||'): '||SQLERRM);
    END;
    
    vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRSEQDIG'
                              ,pr_dsdchave => to_char(coop.cdcooper)
                              ,pr_flgdecre => 'N');
    BEGIN
      INSERT INTO craplcx(cdagenci
                         ,cdhistor
                         ,cdopecxa
                         ,dtmvtolt
                         ,nrdcaixa
                         ,nrdmaqui
                         ,nrdocmto
                         ,nrseqdig
                         ,vldocmto
                         ,dsdcompl
                         ,nrautdoc
                         ,cdcooper
                         ,nrdconta)
                  VALUES (coop.cdagenci
                         ,vc_cdhistor_caixa
                         ,coop.cdoperad
                         ,coop.dtmvtolt
                         ,coop.nrdcaixa
                         ,rw_crapbcx.nrdmaqui
                         ,vr_nrdocmto
                         ,vr_nrseqdig
                         ,vr_vltotcop
                         ,'VALORES A DEVOLVER'
                         ,vr_sequencia
                         ,coop.cdcooper
                         ,0);
                        
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20009,'Erro incluir lançamento craplcx('||coop.cdcooper||'): '||SQLERRM);
    END;

    COMMIT;
  END LOOP;

  COMMIT;

END;
