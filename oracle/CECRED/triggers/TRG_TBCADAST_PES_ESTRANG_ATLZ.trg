CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PES_ESTRANG_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_ESTRANGEIRA 
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PES_ESTRANG_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_ESTRANGEIRA';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_estrangeira_old    tbcadast_pessoa_estrangeira%ROWTYPE;
  vr_estrangeira_new    tbcadast_pessoa_estrangeira%ROWTYPE;

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
  vr_estrangeira_old.idpessoa          := :old.idpessoa;
  vr_estrangeira_old.cdpais            := :old.cdpais;
  vr_estrangeira_old.nridentificacao   := :old.nridentificacao;
  vr_estrangeira_old.dsnatureza_relacao:= :old.dsnatureza_relacao;
  vr_estrangeira_old.dsestado          := :old.dsestado;
  vr_estrangeira_old.nrpassaporte      := :old.nrpassaporte;
  vr_estrangeira_old.tpdeclarado       := :old.tpdeclarado;
  vr_estrangeira_old.incrs             := :old.incrs;
  vr_estrangeira_old.infatca           := :old.infatca;
  vr_estrangeira_old.dsnaturalidade    := :old.dsnaturalidade;


  --> Armazenar dados novos
  vr_estrangeira_new.idpessoa          := :new.idpessoa;
  vr_estrangeira_new.cdpais            := :new.cdpais;
  vr_estrangeira_new.nridentificacao   := :new.nridentificacao;
  vr_estrangeira_new.dsnatureza_relacao:= :new.dsnatureza_relacao;
  vr_estrangeira_new.dsestado          := :new.dsestado;
  vr_estrangeira_new.nrpassaporte      := :new.nrpassaporte;
  vr_estrangeira_new.tpdeclarado       := :new.tpdeclarado;
  vr_estrangeira_new.incrs             := :new.incrs;
  vr_estrangeira_new.infatca           := :new.infatca;
  vr_estrangeira_new.dsnaturalidade    := :new.dsnaturalidade;
    
  
  CADA0016.pc_atualiza_estrangeira (pr_idpessoa         => vr_idpessoa        --> Identificador de pessoa                                                          
                                   ,pr_tpoperacao       => vr_tpoperac        --> Indicador de operacao (1-Inclusao, 2-Alteração, 3-Exclusão)
                                   ,pr_estrangeira_old  => vr_estrangeira_old --> Dados anteriores
                                   ,pr_estrangeira_new  => vr_estrangeira_new --> Dados novos
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
END TRG_TBCADAST_PES_ESTRANG_ATLZ;
/
