CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PF_DEP_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_FISICA_DEP
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PF_DEP_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_FISICA_DEP';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_pessoa_dep_old   tbcadast_pessoa_fisica_dep%ROWTYPE;
  vr_pessoa_dep_new   tbcadast_pessoa_fisica_dep%ROWTYPE;

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
  vr_pessoa_dep_old.idpessoa            := :old.idpessoa             ;
  vr_pessoa_dep_old.nrseq_dependente    := :old.nrseq_dependente     ;
  vr_pessoa_dep_old.idpessoa_dependente := :old.idpessoa_dependente  ;
  vr_pessoa_dep_old.tpdependente        := :old.tpdependente         ;
  vr_pessoa_dep_old.cdoperad_altera     := :old.cdoperad_altera      ;

  --> Armazenar dados novos
  vr_pessoa_dep_new.idpessoa            := :new.idpessoa             ;
  vr_pessoa_dep_new.nrseq_dependente    := :new.nrseq_dependente     ;
  vr_pessoa_dep_new.idpessoa_dependente := :new.idpessoa_dependente  ;
  vr_pessoa_dep_new.tpdependente        := :new.tpdependente         ;
  vr_pessoa_dep_new.cdoperad_altera     := :new.cdoperad_altera      ;
   
  
  cada0016.pc_atualiza_pessoa_fisica_dep ( pr_idpessoa        => vr_idpessoa         --> identificador de pessoa                                                          
                                          ,pr_tpoperacao      => vr_tpoperac         --> indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                          ,pr_pessoa_dep_old  => vr_pessoa_dep_old --> dados anteriores
                                          ,pr_pessoa_dep_new  => vr_pessoa_dep_new --> dados novos
                                          ,pr_dscritic        => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF; 
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PF_DEP_ATLZ;
/
