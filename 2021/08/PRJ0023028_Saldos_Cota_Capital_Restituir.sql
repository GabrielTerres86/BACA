declare

  -- Esta procedure tem como objetivo gerar o valores a devolver na Transpocred
  procedure pc_cota_valores_a_devolver(pr_cdcooper IN craplct.cdcooper%TYPE
                                      ,pr_nrdconta IN craplct.nrdconta%TYPE
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                      ,pr_inpessoa IN crapass.inpessoa%TYPE
                                      ,pr_vllanmto IN craplct.vllanmto%TYPE
                                      ) is
    -- Com base no programa CADA0003
    vc_cdagenci_lct CONSTANT craplct.cdagenci%type := 28;
    vc_cdbccxlt_lct CONSTANT craplct.cdbccxlt%type := 100;
    vc_nrdolote_lct CONSTANT craplct.nrdolote%type := 600038;
    vr_cdhistor_lct craplct.cdhistor%type;
    vr_cdopeori craplct.cdopeori%type := '1';
    vr_cdageori craplct.cdageori%type := 0;
    vr_nrseqdig craplct.nrseqdig%type;
    vr_nrdrowid ROWID;
  begin

    if nvl(pr_inpessoa,0) = 1 then
      vr_cdhistor_lct := 2079;
    else
      vr_cdhistor_lct := 2080;
    end if;

    ----------------------------------------------------------- 
    -- Gera o lançamento de inclusão da cota capital.
    ----------------------------------------------------------- 
    begin
      vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                vc_cdagenci_lct||';'||
                                                vc_cdbccxlt_lct||';'||
                                                vc_nrdolote_lct);
    end;

    begin
      INSERT INTO craplct
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,nrdconta
        ,nrdocmto
        ,cdhistor
        ,nrseqdig
        ,cdopeori
        ,cdageori
        ,dtinsori
        ,vllanmto)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,28
        ,100
        ,10002
        ,pr_nrdconta
        ,vr_nrseqdig
        ,61
        ,vr_nrseqdig
        ,vr_cdopeori
        ,vr_cdageori
        ,SYSDATE
        ,pr_vllanmto);
    exception
      when others then
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'insert craplct2:('
                                                   ||pr_cdcooper
                                              ||','||pr_nrdconta
                                              ||','||pr_vllanmto||')');
        raise;
    end;

    begin
      insert into crapcot cot
        (cdcooper
        ,nrdconta
        ,vldcotas)
      values
        (pr_cdcooper
        ,pr_nrdconta
        ,pr_vllanmto);
    exception
      when dup_val_on_index then
        begin
          update crapcot cot
          set cot.vldcotas = nvl(cot.vldcotas,0) + pr_vllanmto
          where cot.cdcooper = pr_cdcooper
            and cot.nrdconta = pr_nrdconta;            
        exception
          when others then
            begin
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                          ,pr_compleme => 'update crapcot1:('
                                                         ||pr_cdcooper
                                                    ||','||pr_nrdconta
                                                    ||','||pr_vllanmto||')');
              raise;
            end;
        end;
      when others then
        begin
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                      ,pr_compleme => 'insert crapcot:('
                                                     ||pr_cdcooper
                                                ||','||pr_nrdconta
                                                ||','||pr_vllanmto||')');
          raise;
       end;
    end;


    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => SUBSTR(vr_cdopeori,1,10)
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => SUBSTR(GENE0001.vr_vet_des_origens(7),1,13) --7=Processo
                        ,pr_dstransa => 'Carga saldo capital CredCorreios'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time()
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => SUBSTR('CARGAINCORP',1,12)
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log de item
    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Documento'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => vr_nrseqdig);

    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Valor'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => pr_vllanmto);

    -- Gera o lançamento de devolução de cota capital.
    begin
      vr_nrseqdig := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRSEQDIG'
                                ,pr_dsdchave => to_char(pr_cdcooper)||';'||
                                                to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                vc_cdagenci_lct||';'||
                                                vc_cdbccxlt_lct||';'||
                                                vc_nrdolote_lct);
    end;


    begin
      INSERT INTO craplct
        (cdcooper
        ,dtmvtolt
        ,cdagenci
        ,cdbccxlt
        ,nrdolote
        ,nrdconta
        ,nrdocmto
        ,cdhistor
        ,nrseqdig
        ,cdopeori
        ,cdageori
        ,dtinsori
        ,vllanmto)
      VALUES
        (pr_cdcooper
        ,pr_dtmvtolt
        ,vc_cdagenci_lct
        ,vc_cdbccxlt_lct
        ,vc_nrdolote_lct
        ,pr_nrdconta
        ,vr_nrseqdig
        ,vr_cdhistor_lct
        ,vr_nrseqdig
        ,vr_cdopeori
        ,vr_cdageori
        ,SYSDATE
        ,pr_vllanmto);
    exception
      when others then
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'insert craplct2:('
                                                   ||pr_cdcooper
                                              ||','||pr_nrdconta
                                              ||','||pr_vllanmto||')');
        raise;
    end;

    -- Atualiza o saldo consolidado de cota capital.
    begin
      update crapcot cot
      set cot.vldcotas = nvl(cot.vldcotas,0) - pr_vllanmto
      where cot.cdcooper = pr_cdcooper
        and cot.nrdconta = pr_nrdconta;
    exception
      when others then
        begin
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                      ,pr_compleme => 'update crapcot2:('
                                                     ||pr_cdcooper
                                                ||','||pr_nrdconta
                                                ||','||pr_vllanmto||')');
          raise;
       end;
    end;
    
    ----------------------------------------------------------- 
    -- Gera o lançamento de "Valores a devolver".
    ----------------------------------------------------------- 
    begin
      insert into tbcotas_devolucao
        (cdcooper
        ,nrdconta 
        ,tpdevolucao
        ,vlcapital)
      values
        (pr_cdcooper
        ,pr_nrdconta      
        ,3 --3-Sobras Cotas Demitido
        ,pr_vllanmto);
    exception
      when dup_val_on_index then
        begin
          update tbcotas_devolucao 
          set vlcapital = nvl(vlcapital,0) + pr_vllanmto
          where cdcooper = pr_cdcooper
            and nrdconta = pr_nrdconta;            
        exception
          when others then
            begin
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                          ,pr_compleme => 'update tbcotas_devolucao:('
                                                         ||pr_cdcooper
                                                    ||','||pr_nrdconta
                                                    ||','||pr_vllanmto||')');
              raise;
            end;
        end;
      when others then
        begin
          cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                      ,pr_compleme => 'insert tbcotas_devolucao:('
                                                     ||pr_cdcooper
                                                ||','||pr_nrdconta
                                                ||','||pr_vllanmto||')');
          raise;
       end;
    end;

    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => SUBSTR(vr_cdopeori,1,10)
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => SUBSTR(GENE0001.vr_vet_des_origens(7),1,13) --7=Processo
                        ,pr_dstransa => 'Devolver capital CredCorreios'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time()
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => SUBSTR('CARGAINCORP',1,12)
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    -- Log de item
    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Documento'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => vr_nrseqdig);

    GENE0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                              ,pr_nmdcampo => 'Valor'
                              ,pr_dsdadant => ' '
                              ,pr_dsdadatu => pr_vllanmto);

  exception
    when others then
      begin
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'pc_cota_valores_a_devolver:('
                                                   ||pr_cdcooper
                                              ||','||pr_nrdconta
                                              ||','||pr_vllanmto||')');
        raise;
     end;
  end pc_cota_valores_a_devolver;



begin
  declare
    vr_dtmvtolt date;
    x varchar(10);

  begin
    DBMS_OUTPUT.ENABLE (buffer_size => NULL);
    dbms_output.put_line('"Data de movimento";"Coop CC";"Matricula CC";"Pessoa CC";" Nome Pessoa CC";"Conta CC";"Capital CC";"Cdcooper TR";"Nrdconta TR";"Nome TR";"Tipo Pessoa TR"');

--    vr_dtmvtolt := TRUNC(sysdate);
    vr_dtmvtolt := TRUNC(datascooperativa(9).dtmvtolt);

    for r_ccor in (
                    SELECT 
                      cap."cd_coop" cd_coop
                      ,cap."nr_matricula" nr_matricula
                      ,pes."nm_pessoa" nm_pessoa
                      ,pes."cd_pessoa" cd_pessoa
                      ,pss."cd_conta" cd_conta
                      ,cap."vl_saldo_cap" vl_saldo_cap
                      ,trp.nrdconta nrdconta
                      ,pessoa.cdcooper
                      ,pessoa.inpessoa inpessoa
                      ,pessoa.cdsitdct
                      ,sit.dssituacao
                    FROM
                      "saldo_capital_restituir"@credcorreiosinc cap, 
                      "associado"@credcorreiosinc ass, 
                      "pessoa_conta"@credcorreiosinc pss, 
                      "pessoa"@credcorreiosinc pes
                      ,contacorrente.tbcc_conta_incorporacao trp
                      ,crapass pessoa
                      ,tbcc_situacao_conta sit
                    WHERE cap."cd_coop" = ass."cd_coop"
                      and cap."nr_matricula" = ass."nr_matricula"
                      and pss."cd_coop" = ass."cd_coop"
                      and pss."cd_pessoa" = ass."cd_pessoa"
                      and cap."dt_ano_mes_sld" = '202107'
                      and trp.cd_conta = pss."cd_conta"
                      and pes."cd_coop" = ass."cd_coop"
                      and pes."cd_pessoa" = ass."cd_pessoa"
                      and trp.cdcooper = pessoa.cdcooper
                      and trp.nrdconta = pessoa.nrdconta
                      and pessoa.cdsitdct = sit.cdsituacao
                      and cap."vl_saldo_cap" > 0
                    ORDER BY cap."cd_coop", pes."nm_pessoa", cap."nr_matricula", pss."cd_conta", trp.nrdconta
                  )
    loop
      -- Exceções da regra: cooperado que possui mais de uma conta para restituição de saldo de cotas
      if (r_ccor.nr_matricula = 8968160 and r_ccor.cd_conta = 8692691 and r_ccor.nrdconta = 525855) or
         (r_ccor.nr_matricula = 4030907 and r_ccor.cd_conta = 8686807 and r_ccor.nrdconta = 516643) or
         (r_ccor.nr_matricula = 8712740 and r_ccor.cd_conta = 8694866 and r_ccor.nrdconta = 529338) or
         (r_ccor.nr_matricula = 8691656 and r_ccor.cd_conta = 662950 and r_ccor.nrdconta = 502308) or
         (r_ccor.nr_matricula = 5542860 and r_ccor.cd_conta = 5656630 and r_ccor.nrdconta = 503967) or
         (r_ccor.nr_matricula = 8692220 and r_ccor.cd_conta = 8692220 and r_ccor.nrdconta = 525243) or
         (r_ccor.nr_matricula = 8692913 and r_ccor.cd_conta = 9914358 and r_ccor.nrdconta = 533483) or
         (r_ccor.nr_matricula = 7725735 and r_ccor.cd_conta = 691119 and r_ccor.nrdconta = 502901) or
         -- Marcia Torres Alves - Tem duas matrículas que devem ser tratadas na próxima condição
         (r_ccor.nr_matricula = 6336421 and r_ccor.cd_conta = 8687639 and r_ccor.nrdconta = 518247) or 
         (r_ccor.nr_matricula = 8687639 and r_ccor.cd_conta = 8687639 and r_ccor.nrdconta = 518247) or
         (r_ccor.nr_matricula = 8687639 and r_ccor.cd_conta = 8695610 and r_ccor.nrdconta = 530441) THEN
         -- Ignora essas contas
         x := '';
      elsif (r_ccor.nr_matricula = 6336421 and r_ccor.cd_conta = 8695610 and r_ccor.nrdconta = 530441) THEN 
         -- Marcia Torres Alves - Faz lançamento específico
        pc_cota_valores_a_devolver(pr_cdcooper => r_ccor.cdcooper
                                  ,pr_nrdconta => r_ccor.nrdconta
                                  ,pr_dtmvtolt => vr_dtmvtolt
                                  ,pr_inpessoa => r_ccor.inpessoa
                                  ,pr_vllanmto => 1176.36); -- Valor Fixo, soma os valores acumulando as duas matrículas
      else
        -- As demais contas que não foram ignoradas acima, serão processadas dentro da regra
        pc_cota_valores_a_devolver(pr_cdcooper => r_ccor.cdcooper
                                  ,pr_nrdconta => r_ccor.nrdconta
                                  ,pr_dtmvtolt => vr_dtmvtolt
                                  ,pr_inpessoa => r_ccor.inpessoa
                                  ,pr_vllanmto => r_ccor.vl_saldo_cap);
      end if; 

      -- Geramos log de todos os lançamentos para posterior conferência.
      dbms_output.put_line('"'||to_char(vr_dtmvtolt,'dd/mm/yyyy')
                       ||'";"'||r_ccor.cd_coop
                       ||'";"'||r_ccor.nr_matricula
                       ||'";"'||r_ccor.cd_pessoa
                       ||'";"'||trim(r_ccor.nm_pessoa)
                       ||'";"'||r_ccor.cd_conta
                       ||'";"'||r_ccor.vl_saldo_cap
                       ||'";"'||r_ccor.cdcooper
                       ||'";"'||r_ccor.nrdconta
                       ||'";"'||r_ccor.inpessoa
                       ||'"'
                          );

    end loop;
     
    commit;

  exception
    when others then
      begin
        CECRED.pc_internal_exception(pr_cdcooper => '9'
                                    ,pr_compleme => 'Geral Script carga saldo capital CredCorreios');
        rollback;
        raise;
     end;
  end;

end;
