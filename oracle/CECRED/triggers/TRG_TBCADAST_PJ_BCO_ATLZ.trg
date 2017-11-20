CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_BCO_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_BCO 
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_BCO_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para atualizar tabela estrutura antiga

     Alteração :


  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_BCO';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_juridica_bco_old   tbcadast_pessoa_juridica_bco%ROWTYPE;
  vr_juridica_bco_new   tbcadast_pessoa_juridica_bco%ROWTYPE;

  vr_exc_erro     EXCEPTION;
  vr_cdcritic     INTEGER;
  vr_dscritic     VARCHAR2(2000);

vr_dsmodule   VARCHAR2(100); 
  
BEGIN
  
  --> Inicializa sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 1, -- Incializa 
                              pr_dsmodule => vr_dsmodule);  

  --> Setar variaveis padrão
  IF INSERTING THEN
    vr_tpoperac := 1; --INSERT   
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := 0;
     
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := 0;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.idpessoa;
    vr_nrsequen := 0;
  END IF;

  
  --> Armazenar dados antigos
  vr_juridica_bco_old.idpessoa          := :old.idpessoa;
  vr_juridica_bco_old.nrseq_banco       := :old.nrseq_banco;
  vr_juridica_bco_old.cdbanco           := :old.cdbanco;
  vr_juridica_bco_old.dsoperacao        := :old.dsoperacao;
  vr_juridica_bco_old.vloperacao        := :old.vloperacao;
  vr_juridica_bco_old.dsgarantia        := :old.dsgarantia;
  vr_juridica_bco_old.dtvencimento      := :old.dtvencimento;
  vr_juridica_bco_old.cdoperad_altera   := :old.cdoperad_altera;

  --> Armazenar dados novos
  vr_juridica_bco_new.idpessoa          := :new.idpessoa;
  vr_juridica_bco_new.nrseq_banco       := :new.nrseq_banco;
  vr_juridica_bco_new.cdbanco           := :new.cdbanco;
  vr_juridica_bco_new.dsoperacao        := :new.dsoperacao;
  vr_juridica_bco_new.vloperacao        := :new.vloperacao;
  vr_juridica_bco_new.dsgarantia        := :new.dsgarantia;
  vr_juridica_bco_new.dtvencimento      := :new.dtvencimento;
  vr_juridica_bco_new.cdoperad_altera   := :new.cdoperad_altera;
  
  
  CADA0016.pc_atualiza_juridica_bco (pr_idpessoa          => vr_idpessoa         --> Identificador de pessoa                                                          
                                    ,pr_tpoperacao        => vr_tpoperac         --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                    ,pr_juridica_bco_old  => vr_juridica_bco_old --> Dados anteriores
                                    ,pr_juridica_bco_new  => vr_juridica_bco_new --> Dados novos
                                    ,pr_dscritic          => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF; 

  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PJ_BCO_ATLZ;
/
