CREATE OR REPLACE PACKAGE CECRED.PREJ0003 AS

/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Move  C.C. para prejuízo

   Alteracoes:

..............................................................................*/

 /* Rotina para inclusao de C.C. pra prejuizo */
 PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                    ,pr_dscritic OUT VARCHAR2
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro); 

end PREJ0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0003 AS
/*..............................................................................

   Programa: PREJ0003                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   :Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes:

..............................................................................*/

  PROCEDURE pc_transfere_prejuizo_cc(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Coop conectada
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                     ,pr_dscritic OUT VARCHAR2
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is
    /* .............................................................................

    Programa: pc_transfere_prejuizo_cc
    Sistema :
    Sigla   : PREJ
    Autor   : Rangel Decker  AMcom
    Data    : Maio/2018.                  Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de prejuizo de conta corrente.


    Alteracoes:
    ..............................................................................*/
    --
   
    CURSOR cr_tab(pr_cdcooper IN crawepr.cdcooper%TYPE) IS
      SELECT t.dstextab
      FROM craptab t
      WHERE t.cdcooper = pr_cdcooper
      AND t.nmsistem = 'CRED'
      AND t.tptabela = 'USUARI'
      AND t.cdempres = 11
      AND t.cdacesso = 'RISCOBACEN'
      AND t.tpregist = 000;

     rw_tab cr_tab%ROWTYPE;

    --Busca contas correntes que estão na situação de prejuizo
    CURSOR cr_crapris (pr_cdcooper      crapris.cdcooper%TYPE,
                       pr_dtrefere      crapris.dtrefere%TYPE,
                       pr_valor_arrasto crapris.vldivida%TYPE) IS
      
      SELECT  ris.nrdconta,
              trunc(sysdate)  dtinc_prejuizo,
              ris.dtdrisco,
              pass.cdsitdct,
              ris.vldivida,
              ris.dtrefere,
             ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtdrisco) dias_risco, 
             ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtinictr) dias_atraso 
        FROM crapris ris,
             crapass pass
       WHERE ris.cdcooper  = pass.cdcooper
       AND   ris.nrdconta  = pass.nrdconta
       AND   ris.cdcooper  = pr_cdcooper
       AND   ris.cdmodali  = 101  --ADP
       AND   ris.cdorigem  = 1    -- Conta Corrente
       AND   ris.innivris  = 9    -- Situação H  
       AND  ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtdrisco)> = 180  -- dias_risco
       AND  ((select dat.dtmvtolt from crapdat dat where dat.cdcooper =  ris.cdcooper) - ris.dtinictr)> = 180  -- dias_risco       
       AND   ris.nrdconta  not in (SELECT epr.nrdconta
                                   FROM   crapepr epr 
                                   WHERE epr.cdcooper = ris.cdcooper 
                                   AND   epr.nrdconta = ris.nrdconta 
                                   AND   epr.inprejuz = 1 
                                   AND   epr.cdlcremp = 100)
       AND  ris.nrdconta  not in   (SELECT cyc.nrdconta
                                    FROM   crapcyc cyc 
                                    WHERE cyc.cdcooper = ris.cdcooper 
                                    AND   cyc.nrdconta = ris.nrdconta 
                                    AND   cyc.cdmotcin = 2)                            
       AND   ris.dtrefere =  pr_dtrefere
       AND   ris.vldivida > pr_valor_arrasto; -- Materialidade 
       
     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);

     rw_crapdat   btch0001.cr_crapdat%ROWTYPE;


     vr_valor_arrasto  crapris.vldivida%TYPE;
     -- Erro para parar a cadeia
     vr_exc_saida exception;
     -- Erro sem parar a cadeia
     vr_exc_fimprg exception;
     vr_tab_erro        gene0001.typ_tab_erro;


  BEGIN

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Recupera parâmetro da TAB089
      OPEN cr_tab(pr_cdcooper);
      FETCH cr_tab INTO rw_tab;
     -- CLOSE cr_tab;
   
      -- Se não encontrar
      IF cr_tab%NOTFOUND THEN
        -- Fechar o cursor 
        CLOSE cr_tab;
        vr_valor_arrasto :=0;    
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_tab;
         -- Materialidade(Arrasto)
         vr_valor_arrasto := TO_NUMBER(replace(substr(rw_tab.dstextab, 3, 9), '.', ','));
      END IF;
  

    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_crapris IN cr_crapris(pr_cdcooper,rw_crapdat.dtmvtoan,vr_valor_arrasto) LOOP
      BEGIN

        INSERT INTO TBCC_PREJUIZO(cdcooper
                                  ,nrdconta
                                  ,dtinclusao
                                  ,cdsitdct_original
                                  ,vldivida_original)
         VALUES (pr_cdcooper,
                 rw_crapris.nrdconta,
                 rw_crapris.dtinc_prejuizo,
                 rw_crapris.cdsitdct,
                 rw_crapris.vldivida);
        END;        
        
        
        UPDATE crapass pass
        SET pass.cdsitdct = 3,
            pass.inprejuz = 1
        WHERE pass.cdcooper = pr_cdcooper
        AND   pass.nrdconta = rw_crapris.nrdconta;
        
    END LOOP;

   
  EXCEPTION
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => 1
                           ,pr_nrdcaixa => 1
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);      
     
     

  END pc_transfere_prejuizo_cc;
--

END PREJ0003;
/