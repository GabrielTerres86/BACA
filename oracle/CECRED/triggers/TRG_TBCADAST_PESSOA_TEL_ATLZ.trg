CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_TEL_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_TELEFONE
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_TEL_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Alteração :


  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_TELEFONE';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad     tbcadast_pessoa_historico.cdoperad_altera%TYPE;
  vr_telefone_old tbcadast_pessoa_telefone%ROWTYPE;
  vr_telefone_new tbcadast_pessoa_telefone%ROWTYPE;

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
    vr_nrsequen := :new.nrseq_telefone;
     
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := :new.nrseq_telefone;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.idpessoa;
    vr_nrsequen := :old.nrseq_telefone;
  END IF;
  
  --> Armazenar dados antigos
  vr_telefone_old.idpessoa               := :old.idpessoa;
  vr_telefone_old.nrseq_telefone         := :old.nrseq_telefone;
  vr_telefone_old.cdoperadora            := :old.cdoperadora;
  vr_telefone_old.tptelefone             := :old.tptelefone;
  vr_telefone_old.nmpessoa_contato       := :old.nmpessoa_contato;
  vr_telefone_old.nmsetor_pessoa_contato := :old.nmsetor_pessoa_contato;
  vr_telefone_old.nrddd                  := :old.nrddd;
  vr_telefone_old.nrtelefone             := :old.nrtelefone;
  vr_telefone_old.nrramal                := :old.nrramal;
  vr_telefone_old.insituacao             := :old.insituacao;
  vr_telefone_old.tporigem_cadastro      := :old.tporigem_cadastro;
  vr_telefone_old.cdoperad_altera        := :old.cdoperad_altera;
  vr_telefone_old.flgaceita_sms          := :old.flgaceita_sms;

  --> Armazenar dados novos
  vr_telefone_new.idpessoa               := :new.idpessoa;
  vr_telefone_new.nrseq_telefone         := :new.nrseq_telefone;
  vr_telefone_new.cdoperadora            := :new.cdoperadora;
  vr_telefone_new.tptelefone             := :new.tptelefone;
  vr_telefone_new.nmpessoa_contato       := :new.nmpessoa_contato;
  vr_telefone_new.nmsetor_pessoa_contato := :new.nmsetor_pessoa_contato;
  vr_telefone_new.nrddd                  := :new.nrddd;
  vr_telefone_new.nrtelefone             := :new.nrtelefone;
  vr_telefone_new.nrramal                := :new.nrramal;
  vr_telefone_new.insituacao             := :new.insituacao;
  vr_telefone_new.tporigem_cadastro      := :new.tporigem_cadastro;
  vr_telefone_new.cdoperad_altera        := :new.cdoperad_altera;
  vr_telefone_new.flgaceita_sms          := :new.flgaceita_sms;
  
  
  CADA0016.pc_atualiza_telefone ( pr_idpessoa         => vr_idpessoa       --> Identificador de pessoa
                                 ,pr_nrseq_telefone   => vr_nrsequen       --> Sequencial do telefone
                                 ,pr_tpoperacao       => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_telefone_old     => vr_telefone_old   --> Dados anteriores
                                 ,pr_telefone_new     => vr_telefone_new   --> Dados novos
                                 ,pr_dscritic         => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PESSOA_TEL_ATLZ;
/
