CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_FIS_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_FISICA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_FIS_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_FISICA';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_pessoa_fis_old   tbcadast_pessoa_fisica%ROWTYPE;
  vr_pessoa_fis_new   tbcadast_pessoa_fisica%ROWTYPE;

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
  vr_pessoa_fis_old.idpessoa                  := :old.idpessoa;
  vr_pessoa_fis_old.nmsocial                  := :old.nmsocial;
  vr_pessoa_fis_old.tpsexo                    := :old.tpsexo;
  vr_pessoa_fis_old.cdestado_civil            := :old.cdestado_civil;
  vr_pessoa_fis_old.dtnascimento              := :old.dtnascimento;
  vr_pessoa_fis_old.cdnaturalidade            := :old.cdnaturalidade;
  vr_pessoa_fis_old.cdnacionalidade           := :old.cdnacionalidade;
  vr_pessoa_fis_old.tpnacionalidade           := :old.tpnacionalidade;
  vr_pessoa_fis_old.tpdocumento               := :old.tpdocumento;
  vr_pessoa_fis_old.nrdocumento               := :old.nrdocumento;
  vr_pessoa_fis_old.dtemissao_documento       := :old.dtemissao_documento;
  vr_pessoa_fis_old.idorgao_expedidor         := :old.idorgao_expedidor;
  vr_pessoa_fis_old.cduf_orgao_expedidor      := :old.cduf_orgao_expedidor;
  vr_pessoa_fis_old.inhabilitacao_menor       := :old.inhabilitacao_menor;
  vr_pessoa_fis_old.dthabilitacao_menor       := :old.dthabilitacao_menor;
  vr_pessoa_fis_old.cdgrau_escolaridade       := :old.cdgrau_escolaridade;
  vr_pessoa_fis_old.cdcurso_superior          := :old.cdcurso_superior;
  vr_pessoa_fis_old.cdnatureza_ocupacao       := :old.cdnatureza_ocupacao;
  vr_pessoa_fis_old.dsprofissao               := :old.dsprofissao;
  vr_pessoa_fis_old.vlrenda_presumida         := :old.vlrenda_presumida;
  vr_pessoa_fis_old.dsjustific_outros_rend    := :old.dsjustific_outros_rend;
	vr_pessoa_fis_old.tppreferenciacontato      := :old.tppreferenciacontato;
	vr_pessoa_fis_old.tppcd                     := :old.tppcd;
	vr_pessoa_fis_old.tpnecessidadepcd          := :old.tppcd;


  --> Armazenar dados novos
  vr_pessoa_fis_new.idpessoa                  := :new.idpessoa;
  vr_pessoa_fis_new.nmsocial                  := :new.nmsocial;
  vr_pessoa_fis_new.tpsexo                    := :new.tpsexo;
  vr_pessoa_fis_new.cdestado_civil            := :new.cdestado_civil;
  vr_pessoa_fis_new.dtnascimento              := :new.dtnascimento;
  vr_pessoa_fis_new.cdnaturalidade            := :new.cdnaturalidade;
  vr_pessoa_fis_new.cdnacionalidade           := :new.cdnacionalidade;
  vr_pessoa_fis_new.tpnacionalidade           := :new.tpnacionalidade;
  vr_pessoa_fis_new.tpdocumento               := :new.tpdocumento;
  vr_pessoa_fis_new.nrdocumento               := :new.nrdocumento;
  vr_pessoa_fis_new.dtemissao_documento       := :new.dtemissao_documento;
  vr_pessoa_fis_new.idorgao_expedidor         := :new.idorgao_expedidor;
  vr_pessoa_fis_new.cduf_orgao_expedidor      := :new.cduf_orgao_expedidor;
  vr_pessoa_fis_new.inhabilitacao_menor       := :new.inhabilitacao_menor;
  vr_pessoa_fis_new.dthabilitacao_menor       := :new.dthabilitacao_menor;
  vr_pessoa_fis_new.cdgrau_escolaridade       := :new.cdgrau_escolaridade;
  vr_pessoa_fis_new.cdcurso_superior          := :new.cdcurso_superior;
  vr_pessoa_fis_new.cdnatureza_ocupacao       := :new.cdnatureza_ocupacao;
  vr_pessoa_fis_new.dsprofissao               := :new.dsprofissao;
  vr_pessoa_fis_new.vlrenda_presumida         := :new.vlrenda_presumida;
  vr_pessoa_fis_new.dsjustific_outros_rend    := :new.dsjustific_outros_rend;
	vr_pessoa_fis_new.tppreferenciacontato      := :new.tppreferenciacontato;
	vr_pessoa_fis_new.tppcd                     := :new.tppcd;
	vr_pessoa_fis_new.tpnecessidadepcd          := :new.tppcd;	
  
  cada0016.pc_atualiza_pessoa_fisica ( pr_idpessoa     => vr_idpessoa           --> Identificador de pessoa                                                          
                                      ,pr_tpoperacao   => vr_tpoperac           --> Indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                      ,pr_pessoa_fis_old   => vr_pessoa_fis_old --> Dados anteriores
                                      ,pr_pessoa_fis_new   => vr_pessoa_fis_new --> Dados novos
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
END TRG_TBCADAST_PESSOA_FIS_ATLZ;
/
