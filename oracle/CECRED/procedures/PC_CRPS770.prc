CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS770(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_nmdatela  in varchar2              --> Nome da tela
                                       ,pr_infimsol OUT PLS_INTEGER
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica

  cursor c01 is
        SELECT decode(epr.tpemprst,1,'PP','TR') idtpprd
             , dtultpag
              , nvl((select 1 from crapbpr
                 where  crapbpr.cdcooper = epr.cdcooper
                 and    crapbpr.nrdconta = epr.nrdconta
                 and    crapbpr.nrctrpro = epr.nrctremp
                 and    crapbpr.dscatbem in ('MOTO','AUTOMOVEL','CAMINHAO')
                 and    crapbpr.cdsitgrv not in (1,4,5)
                 and    rownum = 1),0) idgravame
              , nvl((select 1 from crapavl
                    where  crapavl.cdcooper = epr.cdcooper
                    and    crapavl.nrdconta = epr.nrdconta
                    and     rownum = 1),0) idavalista
              ,epr.cdcooper
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlsdprej vlsdvpar
              ,epr.inliquid
              ,epr.rowid
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper  
         -- and epr.nrdconta = 2853841         --> Coop conectada
           and epr.inprejuz = 1            --> Somente não liquidados
       ORDER
          BY vlsdvpar   desc
           , dtultpag
           , idgravame desc
           , idavalista desc
           , cdcooper
           , nrdconta
           , nrctremp;

 vr_cdcritic number;
 vr_dscritic varchar2(1000);
 vr_tab_erro  gene0001.typ_tab_erro;
begin
  for r01 in c01 loop
      pc_crps780_1(pr_cdcooper => r01.cdcooper,
                   pr_nrdconta => r01.nrdconta,
                   pr_nrctremp => r01.nrctremp,
                   pr_vlpagmto => 0,
                   pr_vldabono => 0,
                   pr_cdagenci => 1,
                   pr_cdoperad => '1',
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);

      if vr_dscritic is not null then
         dbms_output.put_line('E-> ' || vr_dscritic || '-' || sqlerrm);
         
          gene0001.pc_gera_erro(pr_cdcooper => r01.cdcooper
                               ,pr_cdagenci => 0 --pr_cdagenci
                               ,pr_nrdcaixa => 0
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => vr_tab_erro);

      end if;
      commit;
  end loop;

end;
/
