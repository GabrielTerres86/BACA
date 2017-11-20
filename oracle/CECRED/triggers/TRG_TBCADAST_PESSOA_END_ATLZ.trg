CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_END_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_ENDERECO
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_END_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para replicar alterações

     Alteração :


  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_ENDERECO';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad     tbcadast_pessoa_historico.cdoperad_altera%TYPE;
  vr_endereco_old tbcadast_pessoa_endereco%ROWTYPE;
  vr_endereco_new tbcadast_pessoa_endereco%ROWTYPE;

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
    vr_nrsequen := :new.nrseq_endereco;
     
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.idpessoa;
    vr_nrsequen := :new.nrseq_endereco;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.idpessoa;
    vr_nrsequen := :old.nrseq_endereco;
  END IF;
  
  --> Armazenar dados antigos
  vr_endereco_old.idpessoa               := :old.idpessoa;
  vr_endereco_old.nrseq_endereco         := :old.nrseq_endereco;
  vr_endereco_old.tpendereco             := :old.tpendereco;
  vr_endereco_old.nmlogradouro           := :old.nmlogradouro;
  vr_endereco_old.nrlogradouro           := :old.nrlogradouro;
  vr_endereco_old.dscomplemento          := :old.dscomplemento;
  vr_endereco_old.nmbairro               := :old.nmbairro;
  vr_endereco_old.idcidade               := :old.idcidade;
  vr_endereco_old.nrcep                  := :old.nrcep;
  vr_endereco_old.tpimovel               := :old.tpimovel;
  vr_endereco_old.vldeclarado            := :old.vldeclarado;
  vr_endereco_old.dtalteracao            := :old.dtalteracao;
  vr_endereco_old.dtinicio_residencia    := :old.dtinicio_residencia;
  vr_endereco_old.tporigem_cadastro      := :old.tporigem_cadastro;
  vr_endereco_old.cdoperad_altera        := :old.cdoperad_altera;


  --> Armazenar dados novos
  vr_endereco_new.idpessoa               := :new.idpessoa;
  vr_endereco_new.nrseq_endereco         := :new.nrseq_endereco;
  vr_endereco_new.tpendereco             := :new.tpendereco;
  vr_endereco_new.nmlogradouro           := :new.nmlogradouro;
  vr_endereco_new.nrlogradouro           := :new.nrlogradouro;
  vr_endereco_new.dscomplemento          := :new.dscomplemento;
  vr_endereco_new.nmbairro               := :new.nmbairro;
  vr_endereco_new.idcidade               := :new.idcidade;
  vr_endereco_new.nrcep                  := :new.nrcep;
  vr_endereco_new.tpimovel               := :new.tpimovel;
  vr_endereco_new.vldeclarado            := :new.vldeclarado;
  vr_endereco_new.dtalteracao            := :new.dtalteracao;
  vr_endereco_new.dtinicio_residencia    := :new.dtinicio_residencia;
  vr_endereco_new.tporigem_cadastro      := :new.tporigem_cadastro;
  vr_endereco_new.cdoperad_altera        := :new.cdoperad_altera;
  
  
  CADA0016.pc_atualiza_endereco ( pr_idpessoa         => vr_idpessoa       --> Identificador de pessoa
                                 ,pr_nrseq_endereco   => vr_nrsequen       --> Sequencial do endereco
                                 ,pr_tpoperacao       => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                 ,pr_endereco_old     => vr_endereco_old   --> Dados anteriores
                                 ,pr_endereco_new     => vr_endereco_new   --> Dados novos
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
END TRG_TBCADAST_PESSOA_END_ATLZ;
/
