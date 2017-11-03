CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_EMAIL_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_EMAIL
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_EMAIL_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Altera��o :


  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_EMAIL';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad     tbcadast_pessoa_historico.cdoperad_altera%TYPE;
  vr_email_old    tbcadast_pessoa_email%ROWTYPE;
  vr_email_new    tbcadast_pessoa_email%ROWTYPE;

  vr_exc_erro     EXCEPTION;
  vr_cdcritic     INTEGER;
  vr_dscritic     VARCHAR2(2000);

  vr_dsmodule   VARCHAR2(100); 
  
BEGIN
  
  --> Inicializa sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 1, -- Incializa 
                              pr_dsmodule => vr_dsmodule); 


  --> Setar variaveis padr�o
  IF INSERTING THEN
    vr_tpoperac := 1; --INSERT   
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := :new.nrseq_email;
     
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := :new.nrseq_email;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.idpessoa;
    vr_nrsequen := :old.nrseq_email;
  END IF;
  
  --> Armazenar dados antigos
  vr_email_old.idpessoa               := :old.idpessoa;
  vr_email_old.nrseq_email            := :old.nrseq_email;
  vr_email_old.dsemail                := :old.dsemail;
  vr_email_old.nmpessoa_contato       := :old.nmpessoa_contato;
  vr_email_old.nmsetor_pessoa_contato := :old.nmsetor_pessoa_contato;
  vr_email_old.cdoperad_altera        := :old.cdoperad_altera;

  --> Armazenar dados novos
  vr_email_new.idpessoa               := :new.idpessoa;
  vr_email_new.nrseq_email            := :new.nrseq_email;
  vr_email_new.dsemail                := :new.dsemail;
  vr_email_new.nmpessoa_contato       := :new.nmpessoa_contato;
  vr_email_new.nmsetor_pessoa_contato := :new.nmsetor_pessoa_contato;
  vr_email_new.cdoperad_altera        := :new.cdoperad_altera;
  
  
  CADA0016.pc_atualiza_email (pr_idpessoa       => vr_idpessoa       --> Identificador de pessoa
                             ,pr_nrseq_email  => vr_nrsequen       --> Sequencial do email
                             ,pr_tpoperacao      => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Altera��o, 3-Exclus�o)
                             ,pr_email_old       => vr_email_old      --> Dados anteriores
                             ,pr_email_new       => vr_email_new      --> Dados novos
                             ,pr_dscritic        => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule); 
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PESSOA_EMAIL_ATLZ;
/
