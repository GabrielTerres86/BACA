DECLARE

  vc_cdhistor_PF    CONSTANT NUMBER := 4595;
  vc_cdhistor_PJ    CONSTANT NUMBER := 4596;
  vc_cdhistor_caixa CONSTANT NUMBER := 4597;
  vc_cdagenci       CONSTANT NUMBER := 1;
  vc_nrdcaixa       CONSTANT NUMBER := 1;
  vc_cdoperad       CONSTANT VARCHAR2(20) := '1';
  
  CURSOR cd_cooperativa IS
    SELECT cop.cdcooper
         , dat.dtmvtolt
         , dat.dtmvtocd
      FROM crapcop cop
     INNER JOIN crapdat dat
        ON dat.cdcooper = cop.cdcooper;

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
       AND ass.dtdemiss   <= to_date('16/09/2024','dd/mm/yyyy') AND rownum <= 200;

  CURSOR cr_crapbcx(pr_cdcooper  NUMBER
                   ,pr_dtmvtocd  DATE) IS
    SELECT bcx.nrdmaqui
      FROM crapbcx bcx
     WHERE bcx.cdcooper = pr_cdcooper   
       AND bcx.dtmvtolt = pr_dtmvtocd     
       AND bcx.cdagenci = vc_cdagenci       
       AND bcx.nrdcaixa = vc_nrdcaixa  
       AND bcx.cdopecxa = vc_cdoperad 
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
    
    OPEN  cr_crapbcx(coop.cdcooper, coop.dtmvtocd);
    FETCH cr_crapbcx INTO rw_crapbcx;
    
    IF cr_crapbcx%NOTFOUND THEN
      CLOSE cr_crapbcx;
      rw_crapbcx.nrdmaqui := vc_nrdcaixa;
    END IF;
    
    IF cr_crapbcx%ISOPEN THEN
      CLOSE cr_crapbcx;
    END IF;
    
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
             ,pr_cdoperad => vc_cdoperad
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
                    VALUES (vc_cdagenci
                           ,reg.cdhistor
                           ,vc_cdoperad
                           ,coop.dtmvtolt
                           ,vc_nrdcaixa
                           ,rw_crapbcx.nrdmaqui
                           ,vr_nrdocmto
                           ,vr_nrseqdig
                           ,reg.vldsaldo
                           ,'Agencia: ' || LPAD(vc_cdagenci,3,'0') || ' Conta/DV: ' || LPAD(reg.nrdconta,8,'0')
                           ,vr_sequencia
                           ,reg.cdcooper
                           ,reg.nrdconta);
                        
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20006,'Erro incluir lançamento craplcx('||coop.cdcooper||'/'||reg.nrdconta||'): '||SQLERRM);
      END;
      
    END LOOP;
    
    vr_nrdocmto := gene0002.fn_busca_time;
    
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
                  VALUES (vc_cdagenci
                         ,vc_cdhistor_caixa
                         ,vc_cdoperad
                         ,coop.dtmvtolt
                         ,vc_nrdcaixa
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
