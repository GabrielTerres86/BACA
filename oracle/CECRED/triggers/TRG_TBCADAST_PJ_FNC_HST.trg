CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_FNC_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_FNC

  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_FNC_HST
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Alteração :


  ............................................................................*/


DECLARE

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_FNC';
  vr_dhaltera   CONSTANT DATE := SYSDATE;
  vr_data       DATE := to_date('01/01/1500','DD/MM/RRRR');
  vr_tab_campos CADA0014.typ_tab_campos_hist;
  vr_idpessoa   tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen   tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac   tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad   tbcadast_pessoa_historico.cdoperad_altera%TYPE;

  vr_exc_erro   EXCEPTION;
  vr_cdcritic   INTEGER;
  vr_dscritic   VARCHAR2(2000);

  --> Retornar descrição do relacionamento
  FUNCTION fn_desc_relacionamento (pr_cdrelacionamento  IN tbcadast_relacion_resp_legal.cdrelacionamento%TYPE) 
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_cdrelacionamento IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cdrelacionamento ||'-'||
           CADA0014.fn_desc_relacionamento (pr_cdrelacionamento  => pr_cdrelacionamento,
                                          pr_dscritic  => vr_dscritic);
                                                                      
  END;

  
  --> Grava a tabela historico
  PROCEDURE Insere_Historico(pr_nmdcampo IN VARCHAR2,
                             pr_dsvalant IN tbcadast_pessoa_historico.dsvalor_anterior%TYPE,
                             pr_dsvalnov IN tbcadast_pessoa_historico.dsvalor_novo%TYPE) IS


  BEGIN

    CADA0014.pc_grava_hist_pessoa
                        ( pr_nmdatela    => vr_nmdatela   --> Nome da tela
                         ,pr_nmdcampo    => pr_nmdcampo   --> Nome do campo
                         ,pr_tab_campos  => vr_tab_campos --> Campos da tabela historico
                         ,pr_idpessoa    => vr_idpessoa   --> Id pessoa
                         ,pr_nrsequen    => vr_nrsequen   --> Sequencial do cadastro de pessoa
                         ,pr_dhaltera    => vr_dhaltera   --> Data e hora da alteração
                         ,pr_tpoperac    => vr_tpoperac   --> Tipo de operacao (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                         ,pr_dsvalant    => pr_dsvalant   --> Valor anterior
                         ,pr_dsvalnov    => pr_dsvalnov   --> Valor novo
                         ,pr_cdoperad    => vr_cdoperad   --> Valor novo
                         ,pr_dscritic    => vr_dscritic);  --> Retornar Critica

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20100,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20100,'Erro ao inserir historico: '||SQLERRM);
  END;
BEGIN

  --> Carrega os campos da tabela
  CADA0014.pc_carrega_campos( pr_nmdatela   => vr_nmdatela        --> Nome da tela
                             ,pr_tab_campos => vr_tab_campos);    --> Retorna campos da tabela historico

  --> Setar variaveis padrão
  IF INSERTING THEN
    vr_tpoperac := 1; --INSERT
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := 0;    
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := 0;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := 0;
    
    vr_cdoperad := cada0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;    
  END IF;  
  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            165	IDPESSOA
            166	VLRECEITA_BRUTA
            167	VLCUSTO_DESPESA_ADM
            168	VLDESPESA_ADMINISTRATIVA
            169	QTDIAS_RECEBIMENTO
            170	QTDIAS_PAGAMENTO
            171	VLATIVO_CAIXA_BANCO_APL
            172	VLATIVO_CONTAS_RECEBER
            173	VLATIVO_ESTOQUE
            174	VLATIVO_IMOBILIZADO
            175	VLATIVO_OUTROS
            176	VLPASSIVO_FORNECEDOR
            177	VLPASSIVO_DIVIDA_BANCARIA
            178	VLPASSIVO_OUTROS
            179	CDOPERAD_ALTERA
            180	DTMES_BASE


  **************************************/


  IF INSERTING OR
     UPDATING  OR 
     DELETING  THEN

    --> IDPESSOA
    IF nvl(:new.IDPESSOA,0) <> nvl(:OLD.IDPESSOA,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA',
                       pr_dsvalant => :old.IDPESSOA,
                       pr_dsvalnov => :new.IDPESSOA);
    END IF;

    --> VLRECEITA_BRUTA
    IF nvl(:new.VLRECEITA_BRUTA,0) <> nvl(:OLD.VLRECEITA_BRUTA,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLRECEITA_BRUTA',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLRECEITA_BRUTA),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLRECEITA_BRUTA));
    END IF;
    
    --> VLCUSTO_DESPESA_ADM
    IF nvl(:new.VLCUSTO_DESPESA_ADM,0) <> nvl(:OLD.VLCUSTO_DESPESA_ADM,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLCUSTO_DESPESA_ADM',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLCUSTO_DESPESA_ADM),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLCUSTO_DESPESA_ADM));
    END IF;
    
    --> VLDESPESA_ADMINISTRATIVA
    IF nvl(:new.VLDESPESA_ADMINISTRATIVA,0) <> nvl(:OLD.VLDESPESA_ADMINISTRATIVA,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLDESPESA_ADMINISTRATIVA',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLDESPESA_ADMINISTRATIVA),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLDESPESA_ADMINISTRATIVA));
    END IF;
    
    --> QTDIAS_RECEBIMENTO
    IF nvl(:new.QTDIAS_RECEBIMENTO,0) <> nvl(:OLD.QTDIAS_RECEBIMENTO,0) THEN
      Insere_Historico(pr_nmdcampo => 'QTDIAS_RECEBIMENTO',
                       pr_dsvalant => (:old.QTDIAS_RECEBIMENTO),
                       pr_dsvalnov => (:new.QTDIAS_RECEBIMENTO));
    END IF;
    
    --> QTDIAS_PAGAMENTO
    IF nvl(:new.QTDIAS_PAGAMENTO,0) <> nvl(:OLD.QTDIAS_PAGAMENTO,0) THEN
      Insere_Historico(pr_nmdcampo => 'QTDIAS_PAGAMENTO',
                       pr_dsvalant => (:old.QTDIAS_PAGAMENTO),
                       pr_dsvalnov => (:new.QTDIAS_PAGAMENTO));
    END IF;
    
    --> VLATIVO_CAIXA_BANCO_APL
    IF nvl(:new.VLATIVO_CAIXA_BANCO_APL,0) <> nvl(:OLD.VLATIVO_CAIXA_BANCO_APL,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLATIVO_CAIXA_BANCO_APL',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLATIVO_CAIXA_BANCO_APL),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLATIVO_CAIXA_BANCO_APL));
    END IF;
    
    --> VLATIVO_CONTAS_RECEBER
    IF nvl(:new.VLATIVO_CONTAS_RECEBER,0) <> nvl(:OLD.VLATIVO_CONTAS_RECEBER,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLATIVO_CONTAS_RECEBER',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLATIVO_CONTAS_RECEBER),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLATIVO_CONTAS_RECEBER));
    END IF;
    
    --> VLATIVO_ESTOQUE
    IF nvl(:new.VLATIVO_ESTOQUE,0) <> nvl(:OLD.VLATIVO_ESTOQUE,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLATIVO_ESTOQUE',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLATIVO_ESTOQUE),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLATIVO_ESTOQUE));
    END IF;
    
    --> VLATIVO_IMOBILIZADO
    IF nvl(:new.VLATIVO_IMOBILIZADO,0) <> nvl(:OLD.VLATIVO_IMOBILIZADO,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLATIVO_IMOBILIZADO',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLATIVO_IMOBILIZADO),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLATIVO_IMOBILIZADO));
    END IF;
    
    --> VLATIVO_OUTROS
    IF nvl(:new.VLATIVO_OUTROS,0) <> nvl(:OLD.VLATIVO_OUTROS,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLATIVO_OUTROS',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLATIVO_OUTROS),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLATIVO_OUTROS));
    END IF;
    
    --> VLPASSIVO_FORNECEDOR
    IF nvl(:new.VLPASSIVO_FORNECEDOR,0) <> nvl(:OLD.VLPASSIVO_FORNECEDOR,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLPASSIVO_FORNECEDOR',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLPASSIVO_FORNECEDOR),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLPASSIVO_FORNECEDOR));
    END IF;
    
    --> VLPASSIVO_DIVIDA_BANCARIA
    IF nvl(:new.VLPASSIVO_DIVIDA_BANCARIA,0) <> nvl(:OLD.VLPASSIVO_DIVIDA_BANCARIA,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLPASSIVO_DIVIDA_BANCARIA',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLPASSIVO_DIVIDA_BANCARIA),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLPASSIVO_DIVIDA_BANCARIA));
    END IF;
    
    --> VLPASSIVO_OUTROS
    IF nvl(:new.VLPASSIVO_OUTROS,0) <> nvl(:OLD.VLPASSIVO_OUTROS,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLPASSIVO_OUTROS',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLPASSIVO_OUTROS),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLPASSIVO_OUTROS));
    END IF;    
    
    --> DTMES_BASE
    IF nvl(:new.DTMES_BASE,vr_data) <> nvl(:OLD.DTMES_BASE,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTMES_BASE',
                       pr_dsvalant => to_char(:old.DTMES_BASE,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTMES_BASE,'DD/MM/RRRR'));
    END IF;    
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    
  END IF;

END TRG_TBCADAST_PJ_FNC_HST;
/
