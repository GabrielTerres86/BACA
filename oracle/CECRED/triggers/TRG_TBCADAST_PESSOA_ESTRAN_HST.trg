CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_ESTRAN_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_ESTRANGEIRA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_ESTRAN_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_ESTRANGEIRA';
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


  --> Retornar descrição da nacionalidade
  FUNCTION fn_desc_nacionalidade(pr_cdnacion tbcadast_pessoa_fisica.cdnacionalidade%type) 
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdnacion IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cdnacion ||'-'||
           CADA0014.fn_desc_nacionalidade (pr_cdnacion  => pr_cdnacion,
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
    vr_nrsequen := 0;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := 0;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := 0;
  END IF;

  vr_cdoperad := CADA0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                           pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            98	IDPESSOA
            99	CDPAIS
            100	NRIDENTIFICACAO
            101	DSNATUREZA_RELACAO
            102	DSESTADO
            103	NRPASSAPORTE
            104	TPDECLARADO
            105	INCHS
            106	INFACTA

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

    --> CDPAIS
    IF nvl(:new.CDPAIS,0) <> nvl(:OLD.CDPAIS,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDPAIS',
                       pr_dsvalant => fn_desc_nacionalidade(:old.CDPAIS),
                       pr_dsvalnov => fn_desc_nacionalidade(:new.CDPAIS));
    END IF;

    --> NRIDENTIFICACAO
    IF nvl(:new.NRIDENTIFICACAO,0) <> nvl(:OLD.NRIDENTIFICACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRIDENTIFICACAO',
                       pr_dsvalant => :old.NRIDENTIFICACAO,
                       pr_dsvalnov => :new.NRIDENTIFICACAO);
    END IF;

    --> DSNATUREZA_RELACAO
    IF nvl(:new.DSNATUREZA_RELACAO,' ') <> nvl(:OLD.DSNATUREZA_RELACAO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSNATUREZA_RELACAO',
                       pr_dsvalant => :old.DSNATUREZA_RELACAO,
                       pr_dsvalnov => :new.DSNATUREZA_RELACAO);
    END IF;
    
    --> DSESTADO
    IF nvl(:new.DSESTADO,' ') <> nvl(:OLD.DSESTADO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSESTADO',
                       pr_dsvalant => :old.DSESTADO,
                       pr_dsvalnov => :new.DSESTADO);
    END IF;

    --> NRPASSAPORTE
    IF nvl(:new.NRPASSAPORTE,0) <> nvl(:OLD.NRPASSAPORTE,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRPASSAPORTE',
                       pr_dsvalant => :old.NRPASSAPORTE,
                       pr_dsvalnov => :new.NRPASSAPORTE);
    END IF;

    --> TPDECLARADO
    IF nvl(:new.TPDECLARADO,' ') <> nvl(:OLD.TPDECLARADO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'TPDECLARADO',
                       pr_dsvalant => (:old.TPDECLARADO),
                       pr_dsvalnov => (:new.TPDECLARADO));
    END IF;

    --> INCRS
    IF nvl(:new.INCRS,0) <> nvl(:OLD.INCRS,0) THEN
      Insere_Historico(pr_nmdcampo => 'INCRS',
                       pr_dsvalant => :old.INCRS,
                       pr_dsvalnov => :new.INCRS);
    END IF;

    --> INFATCA
    IF nvl(:new.INFATCA,0) <> nvl(:OLD.INFATCA,0) THEN
      Insere_Historico(pr_nmdcampo => 'INFATCA',
                       pr_dsvalant => :old.INFATCA,
                       pr_dsvalnov => :new.INFATCA);
    END IF;
        
    --> DSNATURALIDADE
    IF nvl(:new.DSNATURALIDADE,0) <> nvl(:OLD.DSNATURALIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'DSNATURALIDADE',
                       pr_dsvalant => :old.DSNATURALIDADE,
                       pr_dsvalnov => :new.DSNATURALIDADE);
    END IF;
    
    

  END IF;

END TRG_TBCADAST_PESSOA_ESTRAN_HST;
/
