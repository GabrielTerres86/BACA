CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPBAN_ATLZ_CRM
  AFTER INSERT OR UPDATE OR DELETE ON CRAPBAN
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_CRAPBAN_ATLZ_CRM
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

  vr_nmtabela   CONSTANT VARCHAR2(50) := 'CRAPBAN';
  vr_dsmodule   VARCHAR2(100);
  vr_dsaction   VARCHAR2(100);

  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  vr_cdcritic   NUMBER;

  rw_dados      CRAPBAN%ROWTYPE;
  vr_tpoperac   INTEGER;

BEGIN

  IF deleting THEN
    vr_tpoperac := 3; --> Exclusao
    rw_dados.cdbccxlt  := :old.cdbccxlt;
    rw_dados.nmextbcc  := :old.nmextbcc;
    rw_dados.nmresbcc  := :old.nmresbcc;
    rw_dados.dtmvtolt  := :old.dtmvtolt;
    rw_dados.cdoperad  := :old.cdoperad;
    rw_dados.flgoppag  := :old.flgoppag;
    rw_dados.nrispbif  := :old.nrispbif;
    rw_dados.flgdispb  := :old.flgdispb;
    rw_dados.dtinispb  := :old.dtinispb;
    rw_dados.dtaltstr  := :old.dtaltstr;
    rw_dados.dtaltpag  := :old.dtaltpag;    
    
  ELSE
    IF inserting THEN
      vr_tpoperac := 1; --> Inclusao
    ELSE
      vr_tpoperac := 2; --> Alteracao
    END IF;
    
    rw_dados.cdbccxlt  := :new.cdbccxlt;
    rw_dados.nmextbcc  := :new.nmextbcc;
    rw_dados.nmresbcc  := :new.nmresbcc;
    rw_dados.dtmvtolt  := :new.dtmvtolt;
    rw_dados.cdoperad  := :new.cdoperad;
    rw_dados.flgoppag  := :new.flgoppag;
    rw_dados.nrispbif  := :new.nrispbif;
    rw_dados.flgdispb  := :new.flgdispb;
    rw_dados.dtinispb  := :new.dtinispb;
    rw_dados.dtaltstr  := :new.dtaltstr;
    rw_dados.dtaltpag  := :new.dtaltpag;
    
  END IF;

  CADA0013.pc_processa_banco ( pr_rw_dados    => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                              ,pr_tpoperacao  => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                              ,pr_dscritic    => vr_dscritic);    --> Retornar Critica


  IF vr_dscritic IS NOT NULL THEN
    raise_application_error(-20500,vr_dscritic);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20500 THEN
      vr_dscritic := 'Erro nao tratado na TRG_CRAPBAN_ATLZ_CRM: '||SQLERRM;
      
    ELSE
      vr_dscritic := SQLERRM;
    END IF;
    raise_application_error(-20500,vr_dscritic);
END TRG_CRAPBAN_ATLZ_CRM;
/
