-- Script para ajustar cargas anteriores a liberação bloqueando e exibindo o motivo de bloqueio
DECLARE
  vr_cdcooper PLS_INTEGER;
  vr_idorigem PLS_INTEGER := 5;
  vr_nmdatela VARCHAR2(400) := 'TELA_ATENDA_PREAPV';
  vr_dscritic VARCHAR2(32700);
  
  CURSOR cr_busca_registros IS
    SELECT apr.cdcooper
          ,apr.nrdconta
          ,ass.inpessoa
          ,ass.nrcpfcnpj_base
          ,apr.dtatualiza_pre_aprv
     FROM tbepr_param_conta apr
         ,crapass ass
     WHERE apr.idmotivo IS NULL
       AND apr.flglibera_pre_aprv = 0
       AND ass.cdcooper = apr.cdcooper
       AND ass.nrdconta = apr.nrdconta;

BEGIN
  FOR rw_busca_registros IN cr_busca_registros LOOP
    cada0006.pc_mantem_param_pessoa_prod(pr_cdcooper           => rw_busca_registros.cdcooper
                                        ,pr_nrdconta           => rw_busca_registros.nrdconta
                                        ,pr_cdproduto          => 25 -- Pré-Aprovado
                                        ,pr_cdoperac_produto   => 1  -- Oferta
                                        ,pr_flglibera          => 0
                                        ,pr_dtvigencia_paramet => NULL
                                        ,pr_idmotivo           => 79
                                        ,pr_cdoperad           => 1
                                        ,pr_idorigem           => vr_idorigem
                                        ,pr_nmdatela           => vr_nmdatela
                                        ,pr_dscritic           => vr_dscritic);
  END LOOP;
END;