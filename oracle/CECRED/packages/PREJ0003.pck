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

FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN;

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
   Autor   : Rangel Decker - AMCom
   Data    : Maio/2018                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Transferencia do prejuizo de conta corrente

   Alteracoes:

..............................................................................*/

-- Verifica se a conta está em prejuízo
FUNCTION fn_verifica_preju_conta(pr_cdcooper craplcm.cdcooper%TYPE
                                , pr_nrdconta craplcm.nrdconta%TYPE)
  RETURN BOOLEAN AS vr_conta_em_prejuizo BOOLEAN;

	CURSOR cr_conta IS
	SELECT ass.inprejuz
	  FROM crapass ass
	 WHERE ass.cdcooper = pr_cdcooper
	   AND ass.nrdconta = pr_nrdconta;

	vr_inprejuz  crapass.inprejuz%TYPE;
BEGIN
	OPEN cr_conta;
	FETCH cr_conta INTO vr_inprejuz;
	CLOSE cr_conta;

	vr_conta_em_prejuizo := vr_inprejuz = 1;

	RETURN vr_conta_em_prejuizo;
END fn_verifica_preju_conta;

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
                       pr_dtmvtolt      crapris.dtrefere%TYPE,
                       pr_valor_arrasto crapris.vldivida%TYPE) IS
      
      SELECT  ris.nrdconta,
              pr_dtmvtolt  dtinc_prejuizo,
              ris.dtdrisco,
              ass.cdsitdct,
              ris.vldivida,
              ris.dtrefere
        FROM crapris ris,
             crapass ass
       WHERE ass.cdcooper  = ris.cdcooper
         AND ass.nrdconta  = ris.nrdconta
         AND ass.inprejuz = 0 -- APENAS CONTAS QUE NAO ESTAO EM PREJUIZO
         AND ris.cdcooper  = pr_cdcooper
         AND ris.dtrefere =  pr_dtrefere
         AND ris.cdmodali  = 101  --ADP
         AND ris.cdorigem  = 1    -- Conta Corrente
         AND ris.innivris  = 9    -- Situação H  
         AND (pr_dtmvtolt - ris.dtdrisco) >= 180  -- dias_risco
         AND ris.qtdiaatr >=180 -- dias_atraso
         AND ris.nrdconta  not in (SELECT epr.nrdconta
                                     FROM crapepr epr 
                                    WHERE epr.cdcooper = ris.cdcooper 
                                      AND epr.nrdconta = ris.nrdconta 
                                      AND epr.inprejuz = 1 
                                      AND epr.cdlcremp = 100)
         AND ris.nrdconta  not in   (SELECT cyc.nrdconta
                                       FROM crapcyc cyc 
                                      WHERE cyc.cdcooper = ris.cdcooper 
                                        AND cyc.nrdconta = ris.nrdconta 
                                        AND cyc.cdmotcin = 2)                            
         AND ris.vldivida > pr_valor_arrasto -- Materialidade 
       ;
       
     vr_cdcritic  NUMBER(3);
     vr_dscritic  VARCHAR2(1000);

     rw_crapdat   btch0001.cr_crapdat%ROWTYPE;


     vr_valor_arrasto  crapris.vldivida%TYPE;
     -- Erro para parar a cadeia
     vr_exc_saida exception;
     -- Erro sem parar a cadeia
     vr_exc_fimprg exception;
     vr_tab_erro        gene0001.typ_tab_erro;
     
     vr_dtrefere_aux  DATE;


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
  

      --Verificar data
      IF to_char(rw_crapdat.dtmvtoan, 'MM') <> to_char(rw_crapdat.dtmvtolt, 'MM') THEN
          -- Utilizar o final do mês como data
          vr_dtrefere_aux := rw_crapdat.dtultdma;
      ELSE
          -- Utilizar a data atual
          vr_dtrefere_aux := rw_crapdat.dtmvtoan;
      END IF;  
  

    --Transfere as contas em prejuizo para a tabela HIST...
    FOR rw_crapris IN cr_crapris(pr_cdcooper
                                ,vr_dtrefere_aux
                                ,rw_crapdat.dtmvtolt
                                ,vr_valor_arrasto) LOOP
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
        
        
        UPDATE crapass ass
           SET ass.cdsitdct = 2, -- 2-Em Prejuizo
               ass.inprejuz = 1
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = rw_crapris.nrdconta;
        
    END LOOP;

    -- Commita a alteração. Controlado por esta procedure
    COMMIT;
   
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
      -- Desfaz processo
      ROLLBACK;
     

  END pc_transfere_prejuizo_cc;
--

END PREJ0003;
/
