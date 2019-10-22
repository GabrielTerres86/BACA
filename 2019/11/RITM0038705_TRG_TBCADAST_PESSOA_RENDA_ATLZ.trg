CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_RENDA_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_RENDA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PES_RENDACOM_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_RENDA';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_renda_old    tbcadast_pessoa_renda%ROWTYPE;
  vr_renda_new    tbcadast_pessoa_renda%ROWTYPE;

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
    vr_nrsequen := :new.nrseq_renda;
     
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := :new.nrseq_renda;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.idpessoa;
    vr_nrsequen := :old.nrseq_renda;
  END IF;

  
  --> Armazenar dados antigos
  vr_renda_old.idpessoa                := :old.idpessoa;
  vr_renda_old.nrseq_renda             := :old.nrseq_renda;
  vr_renda_old.tpcontrato_trabalho     := :old.tpcontrato_trabalho;
  vr_renda_old.cdturno                 := :old.cdturno;
  vr_renda_old.cdnivel_cargo           := :old.cdnivel_cargo;
  vr_renda_old.dtadmissao              := :old.dtadmissao;
  vr_renda_old.cdocupacao              := :old.cdocupacao;
  vr_renda_old.nrcadastro              := :old.nrcadastro;
  vr_renda_old.vlrenda                 := :old.vlrenda;
  vr_renda_old.tpfixo_variavel         := :old.tpfixo_variavel;
  vr_renda_old.tpcomprov_renda         := :old.tpcomprov_renda;
  vr_renda_old.idpessoa_fonte_renda    := :old.idpessoa_fonte_renda;
  vr_renda_old.cdoperad_altera         := :old.cdoperad_altera;
	vr_renda_old.inrendacomprovada       := :old.inrendacomprovada;

  --> Armazenar dados novos
  vr_renda_new.idpessoa                := :new.idpessoa;
  vr_renda_new.nrseq_renda             := :new.nrseq_renda;
  vr_renda_new.tpcontrato_trabalho     := :new.tpcontrato_trabalho;
  vr_renda_new.cdturno                 := :new.cdturno;
  vr_renda_new.cdnivel_cargo           := :new.cdnivel_cargo;
  vr_renda_new.dtadmissao              := :new.dtadmissao;
  vr_renda_new.cdocupacao              := :new.cdocupacao;
  vr_renda_new.nrcadastro              := :new.nrcadastro;
  vr_renda_new.vlrenda                 := :new.vlrenda;
  vr_renda_new.tpfixo_variavel         := :new.tpfixo_variavel;
  vr_renda_new.tpcomprov_renda         := :new.tpcomprov_renda;
  vr_renda_new.idpessoa_fonte_renda    := :new.idpessoa_fonte_renda;
  vr_renda_new.cdoperad_altera         := :new.cdoperad_altera;
	vr_renda_new.inrendacomprovada       := :new.inrendacomprovada;
    
  
  CADA0016.pc_atualiza_renda (pr_idpessoa    => vr_idpessoa   --> Identificador de pessoa                             
                             ,pr_nrseq_renda => vr_nrsequen   --> Sequencial do registro      
                             ,pr_tpoperacao  => vr_tpoperac   --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                             ,pr_renda_old   => vr_renda_old  --> Dados anteriores
                             ,pr_renda_new   => vr_renda_new  --> Dados novos
                             ,pr_dscritic    => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF; 
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PESSOA_RENDA_ATLZ;
/
