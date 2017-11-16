CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_BEM_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_BEM
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_BEM_HST
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(Amcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Alteração :


  ............................................................................*/


DECLARE

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_BEM';
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
    vr_nrsequen := :new.NRSEQ_BEM;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := :new.NRSEQ_BEM;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_BEM;
  END IF;

  vr_cdoperad := CADA0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                           pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            20	IDPESSOA
            21	NRSEQ_BEM
            22	DSBEM
            23	PEBEM
            24	QTPARCELA_BEM
            25	VLBEM
            26	VLPARCELA_BEM
            27	DTALTERACAO
            28	CDOPERAD_ALTERA
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

    --> NRSEQ_BEM
    IF nvl(:new.NRSEQ_BEM,0) <> nvl(:OLD.NRSEQ_BEM,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_BEM',
                       pr_dsvalant => :old.NRSEQ_BEM,
                       pr_dsvalnov => :new.NRSEQ_BEM);
    END IF;

    --> DSBEM
    IF nvl(:new.DSBEM,' ') <> nvl(:OLD.DSBEM,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSBEM',
                       pr_dsvalant => :old.DSBEM,
                       pr_dsvalnov => :new.DSBEM);
    END IF;

    --> PEBEM
    IF nvl(:new.PEBEM,0) <> nvl(:OLD.PEBEM,0) THEN
      Insere_Historico(pr_nmdcampo => 'PEBEM',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.PEBEM),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.PEBEM));
    END IF;
    
    --> QTPARCELA_BEM
    IF nvl(:new.QTPARCELA_BEM,0) <> nvl(:OLD.QTPARCELA_BEM,0) THEN
      Insere_Historico(pr_nmdcampo => 'QTPARCELA_BEM',
                       pr_dsvalant => :old.QTPARCELA_BEM,
                       pr_dsvalnov => :new.QTPARCELA_BEM);
    END IF;
    
    --> VLBEM
    IF nvl(:new.VLBEM,0) <> nvl(:OLD.VLBEM,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLBEM',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLBEM),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLBEM));
    END IF;
    
    --> VLPARCELA_BEM
    IF nvl(:new.VLPARCELA_BEM,0) <> nvl(:OLD.VLPARCELA_BEM,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLPARCELA_BEM',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLPARCELA_BEM),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLPARCELA_BEM));
    END IF;
    
    --> DTALTERACAO
    IF nvl(:new.DTALTERACAO,vr_data) <> nvl(:OLD.DTALTERACAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTALTERACAO',
                       pr_dsvalant => to_char(:old.DTALTERACAO,'DD/MM/RRRR HH24:MI:SS'),
                       pr_dsvalnov => to_char(:new.DTALTERACAO,'DD/MM/RRRR HH24:MI:SS'));
    END IF;
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
  END IF;

END TRG_TBCADAST_PESSOA_BEM_HST;
/
