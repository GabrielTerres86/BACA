CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_LIBERA_PRE_MANUL(pr_dscritic OUT VARCHAR2) IS
/* .............................................................................

   Programa: PC_JOB_LIBERA_PRE_MANUL
   Sistema : Crédito
   Sigla   : CRED
   Autor   : Petter Rafael
   Data    : Junho/2019                      Ultima Atualizacao: 
   Dados referente ao programa:

   Frequencia: Diario.

   Objetivo  : Executa liberação de cargas manuais até a entrada da nova versão
               do projeto Rating.
               Deve ser executado antes do processamento de motivos de bloqueio.
                   
   Alteracoes :            
                
............................................................................ */   
BEGIN
  DECLARE
    CURSOR cr_busca_cargas IS
      SELECT cdcooper, idcarga
      FROM tbepr_carga_pre_aprv
      WHERE indsituacao_carga = 1
           AND tpcarga = 1;
           
    vr_exc_erro  EXCEPTION;
  BEGIN
    FOR rw_busca_cargas IN cr_busca_cargas LOOP
      empr0002.pc_libera_manual_rating(pr_cdcooper   => rw_busca_cargas.cdcooper
                                      ,pr_idcarga    => rw_busca_cargas.idcarga
                                      ,pr_des_erro   => pr_dscritic);
                                   
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END LOOP;

	COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := 'Erro ao executar pc_libera_manual_rating: ' || pr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      ROLLBACK;
  END;
END PC_JOB_LIBERA_PRE_MANUL;
/
