CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PES_POLEXP_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_POLEXP
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PES_POLEXP_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_POLEXP';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad     tbcadast_pessoa_historico.cdoperad_altera%TYPE;
  vr_polexp_old   tbcadast_pessoa_polexp%ROWTYPE;
  vr_polexp_new   tbcadast_pessoa_polexp%ROWTYPE;

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
  vr_polexp_old.idpessoa         := :old.idpessoa;
  vr_polexp_old.tpexposto        := :old.tpexposto;
  vr_polexp_old.dtinicio         := :old.dtinicio;
  vr_polexp_old.dttermino        := :old.dttermino;
  vr_polexp_old.idpessoa_empresa := :old.idpessoa_empresa; 
  vr_polexp_old.cdocupacao       := :old.cdocupacao;
  vr_polexp_old.tprelacao_polexp := :old.tprelacao_polexp;
  vr_polexp_old.idpessoa_politico:= :old.idpessoa_politico;


  --> Armazenar dados novos
  vr_polexp_new.idpessoa         := :new.idpessoa;
  vr_polexp_new.tpexposto        := :new.tpexposto;
  vr_polexp_new.dtinicio         := :new.dtinicio;
  vr_polexp_new.dttermino        := :new.dttermino;
  vr_polexp_new.idpessoa_empresa := :new.idpessoa_empresa; 
  vr_polexp_new.cdocupacao       := :new.cdocupacao;
  vr_polexp_new.tprelacao_polexp := :new.tprelacao_polexp;
  vr_polexp_new.idpessoa_politico:= :new.idpessoa_politico;
  
  
  CADA0016.pc_atualiza_polexp ( pr_idpessoa       => vr_idpessoa       --> Identificador de pessoa                             
                               ,pr_tpoperacao     => vr_tpoperac       --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                               ,pr_polexp_old     => vr_polexp_old      --> Dados anteriores
                               ,pr_polexp_new     => vr_polexp_new      --> Dados novos
                               ,pr_dscritic       => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PES_POLEXP_ATLZ;
/
