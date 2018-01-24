CREATE OR REPLACE TRIGGER CECRED.TRG_MTV_DESLIGAMENTO_ATLZ_CRM
  AFTER INSERT OR UPDATE OR DELETE ON TBCOTAS_MOTIVO_DESLIGAMENTO
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_MTV_DESLIGAMENTO_ATLZ_CRM
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Outubro/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para enviar dados para o CRM

     Alteração :

  ............................................................................*/


DECLARE

  vr_nmtabela   CONSTANT VARCHAR2(50) := 'TBCOTAS_MOTIVO_DESLIGAMENTO';
  vr_dsmodule   VARCHAR2(100);
  vr_dsaction   VARCHAR2(100);

  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  vr_cdcritic   NUMBER;

  rw_dados      TBCOTAS_MOTIVO_DESLIGAMENTO%ROWTYPE;
  rw_dados_ant  TBCOTAS_MOTIVO_DESLIGAMENTO%ROWTYPE;
  vr_tpoperac   INTEGER;

BEGIN


  IF deleting THEN
    vr_tpoperac := 3; --> Exclusao
    rw_dados.cdmotivo            := :old.cdmotivo          ;
    rw_dados.dsmotivo            := :old.dsmotivo          ;
    rw_dados.flgpessoa_fisica    := :old.flgpessoa_fisica  ;
    rw_dados.flgpessoa_juridica  := :old.flgpessoa_juridica;
    rw_dados.tpmotivo            := :old.tpmotivo;
    
    
    
  ELSE
    IF inserting THEN
      vr_tpoperac := 1; --> Inclusao
    ELSE
      vr_tpoperac := 2; --> Alteracao
      rw_dados_ant.cdmotivo            := :old.cdmotivo          ;
      rw_dados_ant.dsmotivo            := :old.dsmotivo          ;
      rw_dados_ant.flgpessoa_fisica    := :old.flgpessoa_fisica  ;
      rw_dados_ant.flgpessoa_juridica  := :old.flgpessoa_juridica;
      rw_dados_ant.tpmotivo            := :old.tpmotivo;
      
    END IF;
    
    rw_dados.cdmotivo            := :new.cdmotivo          ;
    rw_dados.dsmotivo            := :new.dsmotivo          ;
    rw_dados.flgpessoa_fisica    := :new.flgpessoa_fisica  ;
    rw_dados.flgpessoa_juridica  := :new.flgpessoa_juridica;
    rw_dados.tpmotivo            := :new.tpmotivo;
    
  END IF;

  CADA0013.pc_processa_mtv_desligamento ( pr_rw_dados     => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                                         ,pr_rw_dados_ant => rw_dados_ant     --> Rowtipe contendo os dados dos Campos da tabela
                                         ,pr_tpoperacao   => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                         ,pr_dscritic     => vr_dscritic);    --> Retornar Critica


  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,vr_dscritic);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20500 THEN
      vr_dscritic := 'Erro nao tratado na TRG_MTV_DESLIGAMENTO_ATLZ_CRM: '||SQLERRM;
      
    ELSE
      vr_dscritic := SQLERRM;
    END IF;
    raise_application_error(-20500,vr_dscritic);
END TRG_MTV_DESLIGAMENTO_ATLZ_CRM;
/
