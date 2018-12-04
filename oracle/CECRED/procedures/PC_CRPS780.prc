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
              30/01/2018 - Identação do código,
                           melhor tratativa de erros na rotina e
                           Exclusão da implementação referente a transferência de 
                           conta corrente conforme solicitação SM 6 - M324
                           (Rafael Monteiro - Mout'S).
              29/11/2018 - P450 - estória 12166:Transferência Desconto de titulo - Controle 
                            da situação da conta corrente (Fabio Adriano - AMcom).
                                         
    ............................................................................. */

   vl_flgprocesso integer := 3; -- para efeito de testes 1--gera só emprestimos; 2--gera so cc; 3--ambos
   vr_des_reto    varchar2(100);
   vr_tab_erro    gene0001.typ_tab_erro;
   gl_nrdolote    craplot.nrdolote%type;
 
  Procedure pc_gera_prejuizo_emprestimo IS

    CURSOR c_busca_cooper IS
      SELECT cdcooper
        FROM crapcop
       WHERE cdcooper = pr_cdcooper
       ORDER BY cdcooper;

     /* query para buscar emprestimos vencidos a mais de 180 dias e com risco H */
    CURSOR c_busca_epr(pr_cdcooper NUMBER) IS
      SELECT ris.cdcooper, 
             ris.nrdconta, 
             ris.nrctremp, 
             ris.innivris, 
             ris.dtdrisco, 
             epr.tpemprst,
             epr.dtultpag, 
             epr.cdorigem, 
             epr.cdempres, 
             epr.vlsdeved, 
             epr.cdagenci
        FROM crapris ris, 
             crapepr epr,
             crapdat dat
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.cdcooper = ris.cdcooper
         AND epr.nrdconta = ris.nrdconta
         AND epr.nrctremp = ris.nrctremp
         AND epr.tpemprst IN (0,1)
         AND epr.inprejuz = 0
         AND epr.inliquid = 0
         AND ris.innivris IN (9,10) -- risco H
         AND ris.cdorigem = 3 -- emprestimos
         AND ris.inddocto = 1
         AND (TRUNC(dat.dtmvtolt) - TRUNC(ris.dtdrisco)) > 179
         --AND ris.qtdiaatr > 179
         AND DECODE(epr.tpemprst,1,NULL,ris.qtdiaatr) > 179
         AND ris.dttrfprj IS NOT NULL
         AND ris.dttrfprj <= dat.dtmvtolt -- data atual
         AND ris.dtrefere = dat.dtmvtoan -- dia de ontem
         AND ris.cdcooper = dat.cdcooper
         ;                     
/*        SELECT ris.cdcooper, 
              ris.nrdconta, 
              ris.nrctremp, 
              ris.innivris, 
              ris.dtdrisco, 
              epr.tpemprst,
              epr.dtultpag, 
              epr.cdorigem, 
              epr.cdempres, 
              epr.vlsdeved, 
              epr.cdagenci
         FROM crapris t , 
              crapepr epr
        WHERE epr.cdcooper = t.cdcooper
          AND epr.nrdconta = t.nrdconta
          AND epr.nrctremp = t.nrctremp
          AND epr.inprejuz = 0
          AND epr.inliquid = 0
          AND t.innivris = 9 -- risco H
          AND t.cdorigem = 3 -- emprestimos0
          AND t.cdcooper = pr_cdcooper
          AND t.inddocto = 1
          AND t.dtrefere = pr_dtultdma
          AND t.dtdrisco   <= pr_dtmvtolt - 180 --to_date(pr_dtmvtolt,'dd/mm/yyyy') - 180
          AND epr.dtultpag <= pr_dtmvtolt - 180; --to_date(pr_dtmvtolt,'dd/mm/yyyy') - 180;*/

                                          
    rw_busca_epr c_busca_epr%rowtype;
    rw_crapdat   btch0001.cr_crapdat%rowtype;
    vr_texto     VARCHAR2(1000);
    vr_cdcritic  NUMBER(3);
    vr_dscritic  VARCHAR2(1000);
    vr_des_reto  VARCHAR2(10);
    vr_tab_erro  gene0001.typ_tab_erro ;
    vr_nrdrowid  ROWID;
    --
    vr_dsvlrgar  VARCHAR2(32000) := '';
    vr_tipsplit  gene0002.typ_split;   
    vr_permite_trans NUMBER(1); 
         
    /* Inicio do processo */
    BEGIN
      FOR rw_busca_cooper in c_busca_cooper LOOP
        -- Buscar data do sistema
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_busca_cooper.cdcooper);
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       CLOSE btch0001.cr_crapdat;
        -- a pedido de Fernanda Buettgen
        /*IF rw_crapdat.dtmvtolt = rw_crapdat.dtultdia THEN
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooper.cdcooper
                              ,pr_cdoperad => '1'
                              ,pr_dscritic => ''
                              ,pr_dsorigem => 'AYLLOS'
                              ,pr_dstransa => 'Nao houve transferencia Prejuizo, pois e dia de mensal'
                              ,pr_dttransa => trunc(sysdate)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'CRPS780'
                              ,pr_nrdconta => 0
                              ,pr_nrdrowid => vr_nrdrowid);
             
          COMMIT;       
        END IF;*/
        
        vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => 0,pr_cdacesso => 'BLOQ_AUTO_PREJ');
        vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');
        vr_permite_trans := 1;
        FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
          IF pr_cdcooper = vr_tipsplit(i) THEN
            vr_permite_trans := 0;     
          END IF;
        END LOOP;            
        IF vr_permite_trans = 1 THEN -- Validar se a coop esta 
        -- Cursor principal, onde ira buscar os contratos aptos para ser transferidos
          FOR rw_busca_epr in c_busca_epr(rw_busca_cooper.cdcooper) LOOP
            --
            IF rw_busca_epr.tpemprst = 1 THEN /* emprestimo PP */
              -- Transferir PP
              PREJ0001.pc_transfere_epr_prejuizo_PP(pr_cdcooper => rw_busca_cooper.cdcooper
                                                   ,pr_cdagenci => rw_busca_epr.cdagenci
                                                   ,pr_nrdcaixa => 0
                                                   ,pr_cdoperad => '1'
                                                   ,pr_nrdconta => rw_busca_epr.nrdconta
                                                   ,pr_idseqttl => 1
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_nrctremp => rw_busca_epr.nrctremp
                                                   ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                   ,pr_tab_erro => vr_tab_erro);   
   
              IF vr_des_reto <> 'OK' THEN
                IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Não foi possivel Transferir contrato PP . Conta:'||to_char(rw_busca_epr.nrdconta)
                                 ||' Contrato: '|| to_char(rw_busca_epr.nrctremp);
                END IF; 
                -- Gerar LOG
                gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooper.cdcooper
                                    ,pr_cdoperad => '1'
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => 'AIMARO'
                                    ,pr_dstransa => 'Falha Transf Prejuizo PP'
                                    ,pr_dttransa => trunc(sysdate)
                                    ,pr_flgtrans => 1
                                    ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'CRPS780'
                                    ,pr_nrdconta => rw_busca_epr.nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);

              ELSE 
                
                  --Define a situação da conta para prejuizo 
                  PREJ0003.pc_define_situacao_cc_prej(pr_cdcooper => rw_busca_cooper.cdcooper
                                                     ,pr_nrdconta => rw_busca_epr.nrdconta
                                                     ,pr_cdcritic => vr_cdcritic 
                                                     ,pr_dscritic => vr_dscritic );
                                                       
                  if TRIM(vr_dscritic) is not null then
                      -- Gerar LOG
                      gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooper.cdcooper
                                          ,pr_cdoperad => '1'
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_dsorigem => 'AIMARO'
                                          ,pr_dstransa => 'Falha ao alterar a situacao da conta para prejuizo'
                                          ,pr_dttransa => trunc(sysdate)
                                          ,pr_flgtrans => 1
                                          ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                          ,pr_idseqttl => 1
                                          ,pr_nmdatela => 'CRPS780'
                                          ,pr_nrdconta => rw_busca_epr.nrdconta
                                          ,pr_nrdrowid => vr_nrdrowid);
                  end if;   
              END IF;
              -- Confirmar a transferencia quando sem erro ou confirmar o log na base caso com erro
              COMMIT;            
            -- 
            ELSE /* emprestimo TR */
              -- Transferir TR
              PREJ0001.pc_transfere_epr_prejuizo_TR(pr_cdcooper => rw_busca_cooper.cdcooper
                                                   ,pr_cdagenci => rw_busca_epr.cdagenci
                                                   ,pr_nrdcaixa => 0
                                                   ,pr_cdoperad => '1'
                                                   ,pr_nrdconta => rw_busca_epr.nrdconta
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   ,pr_nrctremp => rw_busca_epr.nrctremp
                                                   ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                                   ,pr_tab_erro => vr_tab_erro);

              IF vr_des_reto <> 'OK' THEN

                IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                  vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Não foi possivel Transferir contrato TR . Conta:'||to_char(rw_busca_epr.nrdconta)
                                 ||' Contrato: '|| to_char(rw_busca_epr.nrctremp);
                END IF;
                -- Gerar do erro LOG
                gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooper.cdcooper
                                    ,pr_cdoperad => '1'
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => 'AIMARO'
                                    ,pr_dstransa => 'Falha Transf Prejuizo TR'
                                    ,pr_dttransa => trunc(sysdate)
                                    ,pr_flgtrans => 1
                                    ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                    ,pr_idseqttl => 1
                                    ,pr_nmdatela => 'CRPS780'
                                    ,pr_nrdconta => rw_busca_epr.nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);                               
    
              ELSE 
                
                  --Define a situação da conta para prejuizo 
                  PREJ0003.pc_define_situacao_cc_prej(pr_cdcooper => rw_busca_cooper.cdcooper
                                                     ,pr_nrdconta => rw_busca_epr.nrdconta
                                                     ,pr_cdcritic => vr_cdcritic 
                                                     ,pr_dscritic => vr_dscritic );
                                                       
                  if TRIM(vr_dscritic) is not null then
                      -- Gerar LOG
                      gene0001.pc_gera_log(pr_cdcooper => rw_busca_cooper.cdcooper
                                          ,pr_cdoperad => '1'
                                          ,pr_dscritic => vr_dscritic
                                          ,pr_dsorigem => 'AIMARO'
                                          ,pr_dstransa => 'Falha ao alterar a situacao da conta para prejuizo'
                                          ,pr_dttransa => trunc(sysdate)
                                          ,pr_flgtrans => 1
                                          ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                                          ,pr_idseqttl => 1
                                          ,pr_nmdatela => 'CRPS780'
                                          ,pr_nrdconta => rw_busca_epr.nrdconta
                                          ,pr_nrdrowid => vr_nrdrowid);
                  end if;   
              END IF;
            
              -- Confirmar a transferencia quando sem erro ou confirmar o log na base caso com erro
              COMMIT;            
            END IF;
          END LOOP;
        END IF; -- VALIDAR SE A COOP PODE TER TRANSFERENCIA
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20100,'Erro: ' || SQLERRM);
  END pc_gera_prejuizo_emprestimo;

     /*Procedure pc_gera_prejuizo_cc is
      cursor c01 is 
      
         select epr.cdcooper, epr.nrdconta, epr.vlsddisp, crapsda.vllimcre
         from crapsld epr, crapdat, crapcyc, crapass, crapcot, crapcrm, crapsda
        where crapass.cdcooper = epr.cdcooper
          --and crapass.nrdconta = 70483
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
        null;
          \*if nvl(r01.vlsddisp,0) + nvl(r01.vllimcre,0) < 0 then
              prej0001.pc_gera_prejuizo_cc(PR_CDCOOPER => r01.cdcooper
                                             ,PR_NRDCONTA => r01.nrdconta
                                             ,PR_VLSDDISP => null);
              commit;
          end if;*\
      
      end loop;
    exception
       when others then
           raise_application_error(-20100,'Erro ao gerar Estouro CC: ' || sqlerrm);
    end pc_gera_prejuizo_cc;*/

/* Inicio do processo principal */
  
BEGIN
  /* Geração dos contratos de emprestimo */
  --if vl_flgprocesso in (1,3) then
     pc_gera_prejuizo_emprestimo;
  --elsif vl_flgprocesso in (2,3) then 
  /* Geração das contas correntes com estouros */
  --  pc_gera_prejuizo_cc;
  --end if;
END PC_CRPS780;
/
