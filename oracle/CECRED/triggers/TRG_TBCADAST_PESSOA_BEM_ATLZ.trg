CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_BEM_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_BEM
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_BEM_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para atualizar tabela estrutura antiga

     Altera��o :

  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_BEM';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_bem_old      tbcadast_pessoa_bem%ROWTYPE;
  vr_bem_new      tbcadast_pessoa_bem%ROWTYPE;

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
  vr_bem_old.idpessoa           := :old.idpessoa;
  vr_bem_old.nrseq_bem          := :old.nrseq_bem;
  vr_bem_old.dsbem              := :old.dsbem;
  vr_bem_old.pebem              := :old.pebem;
  vr_bem_old.qtparcela_bem      := :old.qtparcela_bem;
  vr_bem_old.vlbem              := :old.vlbem;
  vr_bem_old.vlparcela_bem      := :old.vlparcela_bem;
  vr_bem_old.dtalteracao        := :old.dtalteracao;
  vr_bem_old.cdoperad_altera    := :old.cdoperad_altera;

  --> Armazenar dados novos
  vr_bem_new.idpessoa           := :new.idpessoa;
  vr_bem_new.nrseq_bem          := :new.nrseq_bem;
  vr_bem_new.dsbem              := :new.dsbem;
  vr_bem_new.pebem              := :new.pebem;
  vr_bem_new.qtparcela_bem      := :new.qtparcela_bem;
  vr_bem_new.vlbem              := :new.vlbem;
  vr_bem_new.vlparcela_bem      := :new.vlparcela_bem;
  vr_bem_new.dtalteracao        := :new.dtalteracao;
  vr_bem_new.cdoperad_altera    := :new.cdoperad_altera;  
  
  cada0016.pc_atualiza_bem( pr_idpessoa     => vr_idpessoa  --> Identificador de pessoa                                                          
                           ,pr_tpoperacao   => vr_tpoperac  --> Indicador de operacao (1-inclusao, 2-altera��o, 3-exclus�o)
                           ,pr_bem_old      => vr_bem_old   --> Dados anteriores
                           ,pr_bem_new      => vr_bem_new   --> Dados novos
                           ,pr_dscritic     => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF; 
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PESSOA_BEM_ATLZ;
/
