CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS780(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_nmdatela  in varchar2              --> Nome da tela
                                       ,pr_infimsol OUT PLS_INTEGER
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica

  /* .............................................................................

  Programa: PC_CRPS780          
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Jean (Mout´S)
  Data    : Abril/2017.                    Ultima atualizacao: 

  Dados referentes ao programa:

  Frequencia: Diaria
  
  Objetivo  : Rotina para automatizar envio de contas / empréstimos para prejuízo
              Deve gerar contratos de empréstimos e contas correntes com estouro para prejuízo,
              levando em consideração as regras de mínimo 180 dias em atraso e mínimo 180 dias no risco H.
              Não serão considerados contratos que estão em acordo.

  Alteracoes: 17/04/2017 - Criação da rotina (Jean / Mout´S)

    ............................................................................. */

   vl_flgprocesso integer := 3; -- para efeito de testes 1--gera só emprestimos; 2--gera so cc; 3--ambos
   vr_des_reto    varchar2(100);
   vr_tab_erro    gene0001.typ_tab_erro;
   gl_nrdolote    craplot.nrdolote%type;
 
    Procedure pc_gera_prejuizo_emprestimo IS

       cursor c_busca_cooper is
          select cdcooper
            from crapcop
            where  cdcooper = pr_cdcooper
           order by cdcooper;

       /* query para buscar emprestimos vencidos a mais de 180 dias e com risco H */
       cursor c_busca_epr(pr_cdcooper number
                 ,pr_dtmvtolt date
                 ,pr_dtultdma date) is
            select t.cdcooper, t.nrdconta, t.nrctremp, t.innivris, t.dtdrisco, epr.tpemprst,
                   epr.dtultpag, epr.cdorigem, epr.cdempres, epr.vlsdeved, epr.cdagenci--, t.*
              from crapris t , crapepr epr
             where epr.cdcooper = t.cdcooper
               and epr.nrdconta = t.nrdconta
               and epr.nrctremp = t.nrctremp
               and epr.inprejuz = 0
               and epr.inliquid = 0
               and t.innivris = 9 -- risco H
               and t.cdorigem = 3 -- emprestimos0
               and t.cdcooper = pr_cdcooper
               and t.inddocto = 1
               and t.dtrefere = pr_dtultdma
               and t.dtdrisco   <= pr_dtmvtolt - 180 --to_date(pr_dtmvtolt,'dd/mm/yyyy') - 180
               and epr.dtultpag <= pr_dtmvtolt - 180; --to_date(pr_dtmvtolt,'dd/mm/yyyy') - 180;

                                          
            rw_busca_epr            c_busca_epr%rowtype;
            
            rw_crapdat              btch0001.cr_crapdat%rowtype;
            vr_texto                varchar2(1000);
            vr_cdcritic             number(3);
            vr_dscritic             varchar2(1000);
            vr_des_reto             varchar2(10);
            vr_tab_erro             gene0001.typ_tab_erro ;
                      
         
      /* Inicio do processo */
      begin
        for rw_busca_cooper in c_busca_cooper loop
            open btch0001.cr_crapdat(pr_cdcooper => rw_busca_cooper.cdcooper);
            fetch btch0001.cr_crapdat into rw_crapdat;
            close btch0001.cr_crapdat;

            for rw_busca_epr in c_busca_epr(rw_busca_cooper.cdcooper
                          ,rw_crapdat.dtmvtolt
                          ,rw_crapdat.dtultdma) loop

                        
                          if rw_busca_epr.tpemprst = 1 then /* emprestimo PP */
                           
                             PREJ0001.pc_transfere_epr_prejuizo_PP(pr_cdcooper => rw_busca_cooper.cdcooper
                                                  ,pr_cdagenci => rw_busca_epr.cdagenci
                                                  ,pr_nrdcaixa => 0
                                                  ,pr_cdoperad => user
                                                  ,pr_nrdconta => rw_busca_epr.nrdconta
                                                  ,pr_idseqttl => 1
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                  ,pr_nrctremp => rw_busca_epr.nrctremp
                                                  ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro  );

                              if vr_des_reto <> 'OK' then
                                 vr_cdcritic := 0;
                                 vr_dscritic := 'Erro execucao da rotina transfere_prejuizo: ' || sqlerrm;

                                 gene0001.pc_gera_erro(pr_cdcooper => rw_busca_cooper.cdcooper 
                                                                 ,pr_cdagenci => 0 --pr_cdagenci
                                                                 ,pr_nrdcaixa => 0
                                                                 ,pr_nrsequen => 1 --> Fixo
                                                                 ,pr_cdcritic => vr_cdcritic
                                                                 ,pr_dscritic => vr_dscritic
                                                                 ,pr_tab_erro => vr_tab_erro);

                                 vr_des_reto := 'NOK';
                              end if;


                          else                     /* emprestimo TR */
                             PREJ0001.pc_transfere_epr_prejuizo_TR(pr_cdcooper => rw_busca_cooper.cdcooper
                                                  ,pr_cdagenci => rw_busca_epr.cdagenci
                                                  ,pr_nrdcaixa => 0
                                                  ,pr_cdoperad => user
                                                  ,pr_nrdconta => rw_busca_epr.nrdconta
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                  ,pr_nrctremp => rw_busca_epr.nrctremp
                                                  ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                  ,pr_tab_erro => vr_tab_erro  );

                              if vr_des_reto <> 'OK' then
                                 vr_cdcritic := 0;
                                 vr_dscritic := 'Erro execucao da rotinça transfere_prejuizo: ' || sqlerrm;

                                 gene0001.pc_gera_erro(pr_cdcooper => rw_busca_cooper.cdcooper 
                                                                 ,pr_cdagenci => 0 --pr_cdagenci
                                                                 ,pr_nrdcaixa => 0
                                                                 ,pr_nrsequen => 1 --> Fixo
                                                                 ,pr_cdcritic => vr_cdcritic
                                                                 ,pr_dscritic => vr_dscritic
                                                                 ,pr_tab_erro => vr_tab_erro);

                                 vr_des_reto := 'NOK';
                              end if;

                          end if;

                          --
                          if vr_des_reto = 'OK' then
                             commit;
                          end if;

            end loop;
            
        end loop;
      exception
        when others then
            raise_application_error(-20100,'Erro: ' || sqlerrm);
      end pc_gera_prejuizo_emprestimo;
    

     Procedure pc_gera_prejuizo_cc is
      cursor c01 is 
      
         select epr.cdcooper, epr.nrdconta, epr.vlsddisp, crapsda.vllimcre
         from crapsld epr, crapdat, crapcyc, crapass, crapcot, crapcrm, crapsda
        where crapass.cdcooper = epr.cdcooper
          and crapass.nrdconta = epr.nrdconta
          and crapdat.cdcooper = epr.cdcooper
          and crapass.cdcooper = pr_cdcooper
          and crapcyc.cdcooper(+) = epr.cdcooper
          and crapcyc.nrdconta(+) = epr.nrdconta
          and crapcyc.nrctremp(+) = epr.nrdconta
          and crapcot.cdcooper = epr.cdcooper
          and crapcot.nrdconta = epr.nrdconta
          and crapcrm.cdcooper(+) = epr.cdcooper
          and crapcrm.nrdconta(+) = epr.nrdconta
          and crapsda.cdcooper = epr.cdcooper
          and crapsda.nrdconta = epr.nrdconta
          and crapsda.dtmvtolt = crapdat.dtmvtoan
          and crapcrm.dtvalcar =
              (select max(dtvalcar)
                 from crapcrm x
                where x.cdcooper = crapcrm.cdcooper
                  and x.nrdconta = crapcrm.nrdconta)
          and epr.vlsddisp < 0
          and crapass.dsnivris in ('H', 'HH')
          and epr.qtddsdev >= 180
          and not exists (select 1 from crapepr t
                            where t.cdcooper = epr.cdcooper
                            and   t.nrdconta = epr.nrdconta
                            and   t.nrctremp = epr.nrdconta
                            and   t.inprejuz = 1)
        order by epr.cdcooper, epr.nrdconta;
   
      wexistec03 integer;   
      wdata      date;
      wprimvez   integer;
      vr_vllimcre number;
    begin
      wprimvez := 0;
      for r01 in c01 loop
        
          if nvl(r01.vlsddisp,0) + nvl(r01.vllimcre,0) < 0 then
              prej0001.pc_gera_prejuizo_cc(PR_CDCOOPER => r01.cdcooper
                                             ,PR_NRDCONTA => r01.nrdconta
                                             ,PR_VLSDDISP => null);
              commit;
          end if;
      
      end loop;
    exception
       when others then
           raise_application_error(-20100,'Erro ao gerar Estouro CC: ' || sqlerrm);
    end pc_gera_prejuizo_cc;

/* Inicio do processo principal */
  
BEGIN
  /* Geração dos contratos de emprestimo */
  if vl_flgprocesso in (1,3) then
     pc_gera_prejuizo_emprestimo;
  elsif vl_flgprocesso in (2,3) then 
  /* Geração das contas correntes com estouros */
     pc_gera_prejuizo_cc;
  end if;
END PC_CRPS780;
/
