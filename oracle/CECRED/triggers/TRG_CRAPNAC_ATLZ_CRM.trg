CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPNAC_ATLZ_CRM
  AFTER INSERT OR UPDATE OR DELETE ON CRAPNAC
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_CRAPNAC_ATLZ_CRM
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

  vr_nmtabela   CONSTANT VARCHAR2(50) := 'CRAPNAC';
  vr_dsmodule   VARCHAR2(100);
  vr_dsaction   VARCHAR2(100);

  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  vr_cdcritic   NUMBER;

  rw_dados      CRAPNAC%ROWTYPE;
  vr_tpoperac   INTEGER;

BEGIN


  IF deleting THEN
    vr_tpoperac := 3; --> Exclusao
    rw_dados.dsnacion  := :old.dsnacion;
    rw_dados.cdnacion  := :old.cdnacion;

  ELSE
    IF inserting THEN
      vr_tpoperac := 1; --> Inclusao
    ELSE
      vr_tpoperac := 2; --> Alteracao
    END IF;
    
    rw_dados.dsnacion  := :new.dsnacion;
    rw_dados.cdnacion  := :new.cdnacion;
    
  END IF;

  CADA0013.pc_processa_nacionalidade( pr_rw_dados    => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                                     ,pr_tpoperacao  => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                     ,pr_dscritic    => vr_dscritic);    --> Retornar Critica


  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,vr_dscritic);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20500 THEN
      vr_dscritic := 'Erro nao tratado na TRG_CRAPNAC_ATLZ_CRM: '||SQLERRM;
      
    ELSE
      vr_dscritic := SQLERRM;
    END IF;
    raise_application_error(-20500,vr_dscritic);
END TRG_CRAPNAC_ATLZ_CRM;
/
