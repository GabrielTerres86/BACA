CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_PTP_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_PTP

  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_PTP_HST
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Altera��o :


  ............................................................................*/


DECLARE

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_PTP';
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

  --> Retornar descri��o do relacionamento
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
                         ,pr_dhaltera    => vr_dhaltera   --> Data e hora da altera��o
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

  --> Setar variaveis padr�o
  IF INSERTING THEN
    vr_tpoperac := 1; --INSERT
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := :new.NRSEQ_PARTICIPACAO;    
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := :new.NRSEQ_PARTICIPACAO;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_PARTICIPACAO;
    
    vr_cdoperad := cada0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;    
  END IF;  
  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            181	IDPESSOA
            182	NRSEQ_PARTICIPACAO
            183	IDPESSOA_PARTICIPACAO
            184	PERSOCIO
            185	DTADMISSAO
            186	CDOPERAD_ALTERA
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

    --> NRSEQ_PARTICIPACAO
    IF nvl(:new.NRSEQ_PARTICIPACAO,0) <> nvl(:OLD.NRSEQ_PARTICIPACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_PARTICIPACAO',
                       pr_dsvalant => (:old.NRSEQ_PARTICIPACAO),
                       pr_dsvalnov => (:new.NRSEQ_PARTICIPACAO ));
    END IF;
    
    --> IDPESSOA_PARTICIPACAO
    IF nvl(:new.IDPESSOA_PARTICIPACAO,0) <> nvl(:OLD.IDPESSOA_PARTICIPACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA_PARTICIPACAO',
                       pr_dsvalant => (:old.IDPESSOA_PARTICIPACAO),
                       pr_dsvalnov => (:new.IDPESSOA_PARTICIPACAO ));
    END IF;
    
    --> PERSOCIO
    IF nvl(:new.PERSOCIO,0) <> nvl(:OLD.PERSOCIO,0) THEN
      Insere_Historico(pr_nmdcampo => 'PERSOCIO',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.PERSOCIO),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.PERSOCIO));
    END IF;
        
    --> DTADMISSAO
    IF nvl(:new.DTADMISSAO,vr_data) <> nvl(:OLD.DTADMISSAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTADMISSAO',
                       pr_dsvalant => to_char(:old.DTADMISSAO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTADMISSAO,'DD/MM/RRRR'));
    END IF;    
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    
  END IF;

END TRG_TBCADAST_PJ_PTP_HST;
/
