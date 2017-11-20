CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_FNC_ATLZ
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_FNC 
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_FNC_ATLZ
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

  vr_nmdatela     CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_FNC';
  vr_dhaltera     CONSTANT DATE := SYSDATE;
  vr_idpessoa     tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen     tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac     tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_juridica_fnc_old   tbcadast_pessoa_juridica_fnc%ROWTYPE;
  vr_juridica_fnc_new   tbcadast_pessoa_juridica_fnc%ROWTYPE;

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
  vr_juridica_fnc_old.idpessoa                  := :old.idpessoa;
  vr_juridica_fnc_old.vlreceita_bruta           := :old.vlreceita_bruta;
  vr_juridica_fnc_old.vlcusto_despesa_adm       := :old.vlcusto_despesa_adm;
  vr_juridica_fnc_old.vldespesa_administrativa  := :old.vldespesa_administrativa;
  vr_juridica_fnc_old.qtdias_recebimento        := :old.qtdias_recebimento;
  vr_juridica_fnc_old.qtdias_pagamento          := :old.qtdias_pagamento;
  vr_juridica_fnc_old.vlativo_caixa_banco_apl   := :old.vlativo_caixa_banco_apl;
  vr_juridica_fnc_old.vlativo_contas_receber    := :old.vlativo_contas_receber;
  vr_juridica_fnc_old.vlativo_estoque           := :old.vlativo_estoque;
  vr_juridica_fnc_old.vlativo_imobilizado       := :old.vlativo_imobilizado;
  vr_juridica_fnc_old.vlativo_outros            := :old.vlativo_outros;
  vr_juridica_fnc_old.vlpassivo_fornecedor      := :old.vlpassivo_fornecedor;
  vr_juridica_fnc_old.vlpassivo_divida_bancaria := :old.vlpassivo_divida_bancaria;
  vr_juridica_fnc_old.vlpassivo_outros          := :old.vlpassivo_outros;
  vr_juridica_fnc_old.cdoperad_altera           := :old.cdoperad_altera;
  vr_juridica_fnc_old.dtmes_base                := :old.dtmes_base;

  --> Armazenar dados novos
  vr_juridica_fnc_new.idpessoa                  := :new.idpessoa;
  vr_juridica_fnc_new.vlreceita_bruta           := :new.vlreceita_bruta;
  vr_juridica_fnc_new.vlcusto_despesa_adm       := :new.vlcusto_despesa_adm;
  vr_juridica_fnc_new.vldespesa_administrativa  := :new.vldespesa_administrativa;
  vr_juridica_fnc_new.qtdias_recebimento        := :new.qtdias_recebimento;
  vr_juridica_fnc_new.qtdias_pagamento          := :new.qtdias_pagamento;
  vr_juridica_fnc_new.vlativo_caixa_banco_apl   := :new.vlativo_caixa_banco_apl;
  vr_juridica_fnc_new.vlativo_contas_receber    := :new.vlativo_contas_receber;
  vr_juridica_fnc_new.vlativo_estoque           := :new.vlativo_estoque;
  vr_juridica_fnc_new.vlativo_imobilizado       := :new.vlativo_imobilizado;
  vr_juridica_fnc_new.vlativo_outros            := :new.vlativo_outros;
  vr_juridica_fnc_new.vlpassivo_fornecedor      := :new.vlpassivo_fornecedor;
  vr_juridica_fnc_new.vlpassivo_divida_bancaria := :new.vlpassivo_divida_bancaria;
  vr_juridica_fnc_new.vlpassivo_outros          := :new.vlpassivo_outros;
  vr_juridica_fnc_new.cdoperad_altera           := :new.cdoperad_altera;
  vr_juridica_fnc_new.dtmes_base                := :new.dtmes_base;  
  
  cada0016.pc_atualiza_juridica_fnc (pr_idpessoa          => vr_idpessoa         --> identificador de pessoa                                                          
                                    ,pr_tpoperacao        => vr_tpoperac         --> indicador de operacao (1-inclusao, 2-alteração, 3-exclusão)
                                    ,pr_juridica_fnc_old  => vr_juridica_fnc_old --> dados anteriores
                                    ,pr_juridica_fnc_new  => vr_juridica_fnc_new --> dados novos
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
END TRG_TBCADAST_PJ_FNC_ATLZ;
/
