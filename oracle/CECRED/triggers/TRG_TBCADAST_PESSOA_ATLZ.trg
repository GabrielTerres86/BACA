CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_ATLZ
  AFTER INSERT OR UPDATE OR DELETE 
  OF idpessoa, 
     nrcpfcgc, 
     nmpessoa, 
     nmpessoa_receita, 
     tppessoa, 
     dtconsulta_spc, 
     dtconsulta_rfb, 
     cdsituacao_rfb, 
     tpconsulta_rfb, 
     dtatualiza_telefone, 
     dtconsulta_scr, 
     tpcadastro, 
     cdoperad_altera, 
     idcorrigido,      
     dtrevisao_cadastral
  ON TBCADAST_PESSOA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_ATLZ
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao: 29/01/2018

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para atualizar tabela estrutura antiga

     Alteração : 29/01/2018 - Inclui campos na config da trigger para desprezar campo dtalteracao.
                              PRJ339-CRM(Odirlei-AMcom)

  ............................................................................*/


DECLARE

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_pessoa_old   tbcadast_pessoa%ROWTYPE;
  vr_pessoa_new   tbcadast_pessoa%ROWTYPE;

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
  vr_pessoa_old.idpessoa           := :old.idpessoa            ;
  vr_pessoa_old.nrcpfcgc           := :old.nrcpfcgc            ;
  vr_pessoa_old.nmpessoa           := :old.nmpessoa            ;
  vr_pessoa_old.nmpessoa_receita   := :old.nmpessoa_receita    ;
  vr_pessoa_old.tppessoa           := :old.tppessoa            ;
  vr_pessoa_old.dtconsulta_spc     := :old.dtconsulta_spc      ;
  vr_pessoa_old.dtconsulta_rfb     := :old.dtconsulta_rfb      ;
  vr_pessoa_old.cdsituacao_rfb     := :old.cdsituacao_rfb      ;
  vr_pessoa_old.tpconsulta_rfb     := :old.tpconsulta_rfb      ;
  vr_pessoa_old.dtatualiza_telefone:= :old.dtatualiza_telefone ;
  vr_pessoa_old.dtconsulta_scr     := :old.dtconsulta_scr      ;   
  vr_pessoa_old.tpcadastro         := :old.tpcadastro          ;
  vr_pessoa_old.cdoperad_altera    := :old.cdoperad_altera     ;
  vr_pessoa_old.idcorrigido        := :old.idcorrigido         ;
  vr_pessoa_old.dtalteracao        := :old.dtalteracao         ;

  --> Armazenar dados novos
  vr_pessoa_new.idpessoa           := :new.idpessoa            ;
  vr_pessoa_new.nrcpfcgc           := :new.nrcpfcgc            ;
  vr_pessoa_new.nmpessoa           := :new.nmpessoa            ;
  vr_pessoa_new.nmpessoa_receita   := :new.nmpessoa_receita    ;
  vr_pessoa_new.tppessoa           := :new.tppessoa            ;
  vr_pessoa_new.dtconsulta_spc     := :new.dtconsulta_spc      ;
  vr_pessoa_new.dtconsulta_rfb     := :new.dtconsulta_rfb      ;
  vr_pessoa_new.cdsituacao_rfb     := :new.cdsituacao_rfb      ;
  vr_pessoa_new.tpconsulta_rfb     := :new.tpconsulta_rfb      ;
  vr_pessoa_new.dtatualiza_telefone:= :new.dtatualiza_telefone ;
  vr_pessoa_new.dtconsulta_scr     := :new.dtconsulta_scr      ;   
  vr_pessoa_new.tpcadastro         := :new.tpcadastro          ;
  vr_pessoa_new.cdoperad_altera    := :new.cdoperad_altera     ;
  vr_pessoa_new.idcorrigido        := :new.idcorrigido         ;
  vr_pessoa_new.dtalteracao        := :new.dtalteracao         ;
  
  cada0016.pc_atualiza_pessoa ( pr_idpessoa     => vr_idpessoa   --> Identificador de pessoa                                                          
                               ,pr_tpoperacao   => vr_tpoperac   --> Indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                               ,pr_pessoa_old   => vr_pessoa_old --> Dados anteriores
                               ,pr_pessoa_new   => vr_pessoa_new --> Dados novos
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
END TRG_TBCADAST_PESSOA_ATLZ;
/
