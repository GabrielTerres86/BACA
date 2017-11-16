CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_PTP_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_PTP 
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_PTP_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_PTP';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_juridica_ptp_old   tbcadast_pessoa_juridica_ptp%ROWTYPE;
  vr_juridica_ptp_new   tbcadast_pessoa_juridica_ptp%ROWTYPE;

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
  vr_juridica_ptp_old.idpessoa              := :old.idpessoa;
  vr_juridica_ptp_old.nrseq_participacao    := :old.nrseq_participacao;
  vr_juridica_ptp_old.idpessoa_participacao := :old.idpessoa_participacao;
  vr_juridica_ptp_old.persocio              := :old.persocio;
  vr_juridica_ptp_old.dtadmissao            := :old.dtadmissao;
  vr_juridica_ptp_old.cdoperad_altera       := :old.cdoperad_altera;
  

  --> Armazenar dados novos
  vr_juridica_ptp_new.idpessoa               := :new.idpessoa;
  vr_juridica_ptp_new.nrseq_participacao     := :new.nrseq_participacao;
  vr_juridica_ptp_new.idpessoa_participacao  := :new.idpessoa_participacao;
  vr_juridica_ptp_new.persocio               := :new.persocio;
  vr_juridica_ptp_new.dtadmissao             := :new.dtadmissao;
  vr_juridica_ptp_new.cdoperad_altera        := :new.cdoperad_altera;
  
  cada0016.pc_atualiza_juridica_ptp (pr_idpessoa          => vr_idpessoa         --> identificador de pessoa                                                          
                                    ,pr_tpoperacao        => vr_tpoperac         --> indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                    ,pr_juridica_ptp_old  => vr_juridica_ptp_old --> dados anteriores
                                    ,pr_juridica_ptp_new  => vr_juridica_ptp_new --> dados novos
                                    ,pr_dscritic          => vr_dscritic);
  
  IF trim(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF; 
  
  --> Finaliza sessao da trigger
  CADA0016.pc_sessao_trigger( pr_tpmodule => 2, -- Finaliza
                              pr_dsmodule => vr_dsmodule);  
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20100,'Nao foi possivel atualizar: '||SQLERRM);
END TRG_TBCADAST_PJ_PTP_ATLZ;
/
