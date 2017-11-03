CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_RELAC_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_RELACAO
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_RELAC_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_RELACAO';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_pessoa_relac_old   tbcadast_pessoa_relacao%ROWTYPE;
  vr_pessoa_relac_new   tbcadast_pessoa_relacao%ROWTYPE;

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
  vr_pessoa_relac_old.idpessoa          := :old.idpessoa         ;
  vr_pessoa_relac_old.nrseq_relacao     := :old.nrseq_relacao    ;
  vr_pessoa_relac_old.idpessoa_relacao  := :old.idpessoa_relacao ;
  vr_pessoa_relac_old.tprelacao         := :old.tprelacao        ;
  vr_pessoa_relac_old.cdoperad_altera   := :old.cdoperad_altera  ;

  --> Armazenar dados novos
  vr_pessoa_relac_new.idpessoa          := :new.idpessoa         ;
  vr_pessoa_relac_new.nrseq_relacao     := :new.nrseq_relacao    ;
  vr_pessoa_relac_new.idpessoa_relacao  := :new.idpessoa_relacao ;
  vr_pessoa_relac_new.tprelacao         := :new.tprelacao        ;
  vr_pessoa_relac_new.cdoperad_altera   := :new.cdoperad_altera  ;    
  
  cada0016.pc_atualiza_pessoa_relacao ( pr_idpessoa          => vr_idpessoa         --> identificador de pessoa                                                          
                                       ,pr_tpoperacao        => vr_tpoperac         --> indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                       ,pr_pessoa_relac_old  => vr_pessoa_relac_old --> dados anteriores
                                       ,pr_pessoa_relac_new  => vr_pessoa_relac_new --> dados novos
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
END TRG_TBCADAST_PESSOA_RELAC_ATLZ;
/
