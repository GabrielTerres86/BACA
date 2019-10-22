CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_JUR_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_JUR_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_pessoa_old   tbcadast_pessoa_juridica%ROWTYPE;
  vr_pessoa_new   tbcadast_pessoa_juridica%ROWTYPE;

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
  vr_pessoa_old.idpessoa               := :old.idpessoa               ;
  vr_pessoa_old.cdcnae                 := :old.cdcnae                 ;
  vr_pessoa_old.nmfantasia             := :old.nmfantasia             ;
  vr_pessoa_old.nrinscricao_estadual   := :old.nrinscricao_estadual   ;
  vr_pessoa_old.cdnatureza_juridica    := :old.cdnatureza_juridica    ;
  vr_pessoa_old.dtconstituicao         := :old.dtconstituicao         ;
  vr_pessoa_old.dtinicio_atividade     := :old.dtinicio_atividade     ;
  vr_pessoa_old.qtfilial               := :old.qtfilial               ;
  vr_pessoa_old.qtfuncionario          := :old.qtfuncionario          ;
  vr_pessoa_old.vlcapital              := :old.vlcapital              ;
  vr_pessoa_old.dtregistro             := :old.dtregistro             ;   
  vr_pessoa_old.nrregistro             := :old.nrregistro             ;
  vr_pessoa_old.dsorgao_registro       := :old.dsorgao_registro      ;
  vr_pessoa_old.dtinscricao_municipal  := :old.dtinscricao_municipal  ;
  vr_pessoa_old.nrnire                 := :old.nrnire                 ;
  vr_pessoa_old.inrefis                := :old.inrefis                ;
  vr_pessoa_old.dssite                 := :old.dssite                 ;
  vr_pessoa_old.nrinscricao_municipal  := :old.nrinscricao_municipal  ;
  vr_pessoa_old.cdsetor_economico      := :old.cdsetor_economico      ; 
  vr_pessoa_old.vlfaturamento_anual    := :old.vlfaturamento_anual    ;
  vr_pessoa_old.cdramo_atividade       := :old.cdramo_atividade       ;
  vr_pessoa_old.nrlicenca_ambiental    := :old.nrlicenca_ambiental    ;
  vr_pessoa_old.dtvalidade_licenca_amb := :old.dtvalidade_licenca_amb ;
  vr_pessoa_old.peunico_cliente        := :old.peunico_cliente        ;
	vr_pessoa_old.tppreferenciacontato   := :old.tppreferenciacontato   ;


  --> Armazenar dados novos
  vr_pessoa_new.idpessoa               := :new.idpessoa               ;
  vr_pessoa_new.cdcnae                 := :new.cdcnae                 ;
  vr_pessoa_new.nmfantasia             := :new.nmfantasia             ;
  vr_pessoa_new.nrinscricao_estadual   := :new.nrinscricao_estadual   ;
  vr_pessoa_new.cdnatureza_juridica    := :new.cdnatureza_juridica    ;
  vr_pessoa_new.dtconstituicao         := :new.dtconstituicao         ;
  vr_pessoa_new.dtinicio_atividade     := :new.dtinicio_atividade     ;
  vr_pessoa_new.qtfilial               := :new.qtfilial               ;
  vr_pessoa_new.qtfuncionario          := :new.qtfuncionario          ;
  vr_pessoa_new.vlcapital              := :new.vlcapital              ;
  vr_pessoa_new.dtregistro             := :new.dtregistro             ;   
  vr_pessoa_new.nrregistro             := :new.nrregistro             ;
  vr_pessoa_new.dsorgao_registro       := :new.dsorgao_registro      ;
  vr_pessoa_new.dtinscricao_municipal  := :new.dtinscricao_municipal  ;
  vr_pessoa_new.nrnire                 := :new.nrnire                 ;
  vr_pessoa_new.inrefis                := :new.inrefis                ;
  vr_pessoa_new.dssite                 := :new.dssite                 ;
  vr_pessoa_new.nrinscricao_municipal  := :new.nrinscricao_municipal  ;
  vr_pessoa_new.cdsetor_economico      := :new.cdsetor_economico      ; 
  vr_pessoa_new.vlfaturamento_anual    := :new.vlfaturamento_anual    ;
  vr_pessoa_new.cdramo_atividade       := :new.cdramo_atividade       ;
  vr_pessoa_new.nrlicenca_ambiental    := :new.nrlicenca_ambiental    ;
  vr_pessoa_new.dtvalidade_licenca_amb := :new.dtvalidade_licenca_amb ;
  vr_pessoa_new.peunico_cliente        := :new.peunico_cliente        ;
  vr_pessoa_new.tpregime_tributacao    := :new.tpregime_tributacao    ;
	vr_pessoa_new.tppreferenciacontato   := :new.tppreferenciacontato   ;
  
  
  cada0016.pc_atualiza_pessoa_juridica ( pr_idpessoa         => vr_idpessoa   --> Identificador de pessoa                                                          
                                        ,pr_tpoperacao       => vr_tpoperac   --> Indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                        ,pr_pessoa_jur_old   => vr_pessoa_old --> Dados anteriores
                                        ,pr_pessoa_jur_new   => vr_pessoa_new --> Dados novos
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
END TRG_TBCADAST_PESSOA_JUR_ATLZ;
/
