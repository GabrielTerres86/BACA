CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_END_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_ENDERECO
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_END_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_ENDERECO';
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
  
  --> Retornar descrição do tipo de endereco
  FUNCTION fn_tpendereco(pr_tpendereco tbcadast_pessoa_endereco.tpendereco%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpendereco IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpendereco ||'-'||
           CADA0014.fn_desc_tpendereco (pr_tpendereco  => pr_tpendereco,
                                        pr_dscritic  => vr_dscritic);
  END;
  
  --> Retornar descrição da cidade
  FUNCTION fn_desc_cidade (pr_idcidade  IN crapmun.idcidade%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_idcidade IS NULL THEN
      RETURN NULL;
    END IF; 
  
    RETURN pr_idcidade ||'-'||
           CADA0014.fn_desc_cidade (pr_idcidade  => pr_idcidade,
                                          pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Retornar descrição do tipo de imovel
  FUNCTION fn_tpimovel(pr_tpimovel tbcadast_pessoa_endereco.tpimovel%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpimovel IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpimovel ||'-'||
           CADA0014.fn_desc_tpimovel (pr_tpimovel  => pr_tpimovel,
                                      pr_dscritic  => vr_dscritic);
  END;
  
  --> Retornar descrição do tipo origem_cadastro
  FUNCTION fn_tporigem_cadastro(pr_tporigem_cadastro tbcadast_pessoa_endereco.tporigem_cadastro%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tporigem_cadastro IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN pr_tporigem_cadastro ||'-'||
           CADA0014.fn_desc_tporigem_cadastro (pr_tporigem_cadastro  => pr_tporigem_cadastro,
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
    vr_nrsequen := :new.NRSEQ_ENDERECO;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := :new.NRSEQ_ENDERECO;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_ENDERECO;
    vr_cdoperad := CADA0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;
    
  END IF;  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            83	IDPESSOA
            84	NRSEQ_ENDERECO
            85	TPENDERECO
            86	NMLOGRADOURO
            87	NRLOGRADOURO
            88	DSCOMPLEMENTO
            89	NMBAIRRO
            90	IDCIDADE
            91	NRCEP
            92	TPIMOVEL
            93	VLDECLARADO
            94	DTALTERA_ENDERECO
            95	DTINICIO_RESIDENCIA
            96	TPORIGEM_CADASTRO
            97	CDOPERAD_ALTERA

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

    --> NRSEQ_ENDERECO
    IF nvl(:new.NRSEQ_ENDERECO,0) <> nvl(:OLD.NRSEQ_ENDERECO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_ENDERECO',
                       pr_dsvalant => :old.NRSEQ_ENDERECO,
                       pr_dsvalnov => :new.NRSEQ_ENDERECO);
    END IF;
    
    --> TPENDERECO
    IF nvl(:new.TPENDERECO,0) <> nvl(:OLD.TPENDERECO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPENDERECO',
                       pr_dsvalant => fn_tpendereco(:old.TPENDERECO),
                       pr_dsvalnov => fn_tpendereco(:new.TPENDERECO));
    END IF;

    --> NMLOGRADOURO
    IF nvl(:new.NMLOGRADOURO,' ') <> nvl(:OLD.NMLOGRADOURO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMLOGRADOURO',
                       pr_dsvalant => :old.NMLOGRADOURO,
                       pr_dsvalnov => :new.NMLOGRADOURO);
    END IF;

    --> NRLOGRADOURO
    IF nvl(:new.NRLOGRADOURO,0) <> nvl(:OLD.NRLOGRADOURO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRLOGRADOURO',
                       pr_dsvalant => :old.NRLOGRADOURO,
                       pr_dsvalnov => :new.NRLOGRADOURO);
    END IF;

    --> DSCOMPLEMENTO
    IF nvl(:new.DSCOMPLEMENTO,' ') <> nvl(:OLD.DSCOMPLEMENTO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSCOMPLEMENTO',
                       pr_dsvalant => :old.DSCOMPLEMENTO,
                       pr_dsvalnov => :new.DSCOMPLEMENTO);
    END IF;
    
    --> NMBAIRRO
    IF nvl(:new.NMBAIRRO,' ') <> nvl(:OLD.NMBAIRRO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMBAIRRO',
                       pr_dsvalant => :old.NMBAIRRO,
                       pr_dsvalnov => :new.NMBAIRRO);
    END IF;
    
    --> IDCIDADE
    IF nvl(:new.IDCIDADE,0) <> nvl(:OLD.IDCIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDCIDADE',
                       pr_dsvalant => fn_desc_cidade(:old.IDCIDADE),
                       pr_dsvalnov => fn_desc_cidade(:new.IDCIDADE));
    END IF;
    
    --> NRCEP
    IF nvl(:new.NRCEP,0) <> nvl(:OLD.NRCEP,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRCEP',
                       pr_dsvalant => fn_tpendereco(:old.NRCEP),
                       pr_dsvalnov => fn_tpendereco(:new.NRCEP));
    END IF;
    
    --> TPIMOVEL
    IF nvl(:new.TPIMOVEL,0) <> nvl(:OLD.TPIMOVEL,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPIMOVEL',
                       pr_dsvalant => fn_tpimovel(:old.TPIMOVEL),
                       pr_dsvalnov => fn_tpimovel(:new.TPIMOVEL));
    END IF;
    
    --> Vldeclarado
    IF nvl(:new.VLDECLARADO,0) <> nvl(:OLD.VLDECLARADO,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLDECLARADO',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLDECLARADO),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLDECLARADO));
    END IF;
    
    --> DTALTERACAO
    IF nvl(:new.DTALTERACAO,vr_data) <> nvl(:OLD.DTALTERACAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTALTERACAO',
                       pr_dsvalant => to_char(:old.DTALTERACAO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTALTERACAO,'DD/MM/RRRR'));
    END IF;
    
    --> DTINICIO_RESIDENCIA
    IF nvl(:new.DTINICIO_RESIDENCIA,vr_data) <> nvl(:OLD.DTINICIO_RESIDENCIA,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTINICIO_RESIDENCIA',
                       pr_dsvalant => to_char(:old.DTINICIO_RESIDENCIA,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTINICIO_RESIDENCIA,'DD/MM/RRRR'));
    END IF;
    
    --> TPORIGEM_CADASTRO
    IF nvl(:new.TPORIGEM_CADASTRO,0) <> nvl(:OLD.TPORIGEM_CADASTRO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPORIGEM_CADASTRO',
                       pr_dsvalant => fn_tporigem_cadastro(:old.TPORIGEM_CADASTRO),
                       pr_dsvalnov => fn_tporigem_cadastro(:new.TPORIGEM_CADASTRO));
    END IF;

    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;

  END IF;

END TRG_TBCADAST_PESSOA_END_HST;
/
