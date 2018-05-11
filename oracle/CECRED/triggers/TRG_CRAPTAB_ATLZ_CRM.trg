CREATE OR REPLACE TRIGGER CECRED.TRG_CRAPTAB_ATLZ_CRM
  AFTER INSERT OR UPDATE OR DELETE ON CRAPTAB
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_CRAPTAB_ATLZ_CRM
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

  vr_nmtabela   CONSTANT VARCHAR2(50) := 'CRAPTAB';
  vr_dsmodule   VARCHAR2(100);
  vr_dsaction   VARCHAR2(100);

  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  vr_cdcritic   NUMBER;

  rw_dados      CRAPTAB%ROWTYPE;
  vr_tpoperac   INTEGER;

BEGIN

  IF :old.cdacesso IN ('OPETELEFON','SETORECONO','PRAZODESLIGAMENTO') OR
     :new.cdacesso IN ('OPETELEFON','SETORECONO','PRAZODESLIGAMENTO') THEN

    IF deleting THEN
      vr_tpoperac := 3; --> Exclusao
      rw_dados.nmsistem  := :old.nmsistem;
      rw_dados.tptabela  := :old.tptabela;
      rw_dados.cdempres  := :old.cdempres;
      rw_dados.cdacesso  := :old.cdacesso;
      rw_dados.tpregist  := :old.tpregist;
      rw_dados.dstextab  := :old.dstextab;
      rw_dados.cdcooper  := :old.cdcooper;

    ELSE
      IF inserting THEN
        vr_tpoperac := 1; --> Inclusao
      ELSE
        vr_tpoperac := 2; --> Alteracao
      END IF;

      rw_dados.nmsistem  := :new.nmsistem;
      rw_dados.tptabela  := :new.tptabela;
      rw_dados.cdempres  := :new.cdempres;
      rw_dados.cdacesso  := :new.cdacesso;
      rw_dados.tpregist  := :new.tpregist;
      rw_dados.dstextab  := :new.dstextab;
      rw_dados.cdcooper  := :new.cdcooper;

    END IF;


    IF :old.cdacesso IN ('OPETELEFON') OR
       :new.cdacesso IN ('OPETELEFON') THEN

      CADA0013.pc_processa_operadora_telefone( pr_rw_dados    => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                                              ,pr_tpoperacao  => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                              ,pr_dscritic    => vr_dscritic);    --> Retornar Critica


      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20500,vr_dscritic);
      END IF;

    ELSIF :old.cdacesso IN ('SETORECONO') OR
          :new.cdacesso IN ('SETORECONO') THEN
      CADA0013.pc_processa_setor_economico ( pr_rw_dados    => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                                            ,pr_tpoperacao  => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                            ,pr_dscritic    => vr_dscritic);    --> Retornar Critica


      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20500,vr_dscritic);
      END IF;
    ELSIF :old.cdacesso IN ('PRAZODESLIGAMENTO') OR
          :new.cdacesso IN ('PRAZODESLIGAMENTO') THEN
      CADA0013.pc_processa_prazo_desligamento ( pr_rw_dados    => rw_dados         --> Rowtipe contendo os dados dos Campos da tabela
                                               ,pr_tpoperacao  => vr_tpoperac      --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                               ,pr_dscritic    => vr_dscritic);    --> Retornar Critica


      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20500,vr_dscritic);
      END IF;
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20500 THEN
      vr_dscritic := 'Erro nao tratado na TRG_CRAPTAB_ATLZ_CRM: '||SQLERRM;

    ELSE
      vr_dscritic := SQLERRM;
    END IF;
    raise_application_error(-20500,vr_dscritic);
END TRG_CRAPTAB_ATLZ_CRM;
/
