CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_POLEXP_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_POLEXP

  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_POLEXP_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_POLEXP';
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

  --> Retornar descrição da ocupacao
  FUNCTION fn_cdocupacao(pr_cdocupacao tbcadast_pessoa_renda.cdocupacao%type) 
           RETURN VARCHAR2 IS
           
   vr_flretorn  BOOLEAN;
   vr_dsdcampo  VARCHAR2(100);
           
  BEGIN
    IF pr_cdocupacao IS NULL THEN
      RETURN NULL;
    END IF;
    
    --> Buscar a Ocupacao do Associado 
    vr_flretorn := CADA0001.fn_busca_ocupacao
                                    (pr_cddocupa => pr_cdocupacao   --> Código da ocupacao
                                    ,pr_rsdocupa => vr_dsdcampo     --> Descricao Ocupacao
                                    ,pr_cdcritic => vr_cdcritic     --> Codigo de erro
                                    ,pr_dscritic => vr_dscritic);   --> Retorno de Erro

    IF vr_flretorn THEN
      RETURN pr_cdocupacao ||'-'||vr_dsdcampo;
    ELSE
      RETURN pr_cdocupacao ||'-Outro';
      
    END IF;
  END;

  -->Function para retornar descrição do tipo de politicamente exposto
  FUNCTION fn_desc_tpexposto (pr_tpexposto  IN tbcadast_pessoa_polexp.tpexposto%TYPE) 
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpexposto IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpexposto ||'-'||
           CADA0014.fn_desc_tpexposto (pr_tpexposto  => pr_tpexposto,
                                       pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Function para retornar descrição do tipo de politicamente exposto 
  FUNCTION fn_desc_tprelacao_polexp (pr_tprelacao_polexp  IN VARCHAR2)    
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tprelacao_polexp IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tprelacao_polexp ||'-'||
           CADA0014.fn_desc_tprelacao_polexp (pr_tprelacao_polexp  => pr_tprelacao_polexp,
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
    vr_cdoperad := vr_cdoperad;
    vr_nrsequen := 0;    
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := vr_cdoperad;
    vr_nrsequen := 0;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := 0;
    
    vr_cdoperad := vr_cdoperad;   
  END IF;  
  
  vr_cdoperad := cada0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                           pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;  
  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            196	IDPESSOA
            197	TPEXPOSTO
            198	DTINICIO
            199	DTTERMINO
            200	IDPESSOA_EMPRESA
            201	CDOCUPACAO
            202	TPRELACAO
            203	IDPESSOA_POLITICO


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

    --> TPEXPOSTO
    IF nvl(:new.TPEXPOSTO,0) <> nvl(:OLD.TPEXPOSTO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPEXPOSTO',
                       pr_dsvalant => fn_desc_tpexposto(:old.TPEXPOSTO),
                       pr_dsvalnov => fn_desc_tpexposto(:new.TPEXPOSTO ));
    END IF;
    
     --> DTINICIO
    IF nvl(:new.DTINICIO,vr_data) <> nvl(:OLD.DTINICIO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTINICIO',
                       pr_dsvalant => to_char(:old.DTINICIO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTINICIO,'DD/MM/RRRR'));
    END IF; 
    
    --> DTTERMINO
    IF nvl(:new.DTTERMINO,vr_data) <> nvl(:OLD.DTTERMINO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTTERMINO',
                       pr_dsvalant => to_char(:old.DTTERMINO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTTERMINO,'DD/MM/RRRR'));
    END IF; 
    
    --> IDPESSOA_EMPRESA
    IF nvl(:new.IDPESSOA_EMPRESA,0) <> nvl(:OLD.IDPESSOA_EMPRESA,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA_EMPRESA',
                       pr_dsvalant => (:old.IDPESSOA_EMPRESA),
                       pr_dsvalnov => (:new.IDPESSOA_EMPRESA ));
    END IF;            
        
    --> CDOCUPACAO
    IF nvl(:new.CDOCUPACAO,0) <> nvl(:OLD.CDOCUPACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDOCUPACAO',
                       pr_dsvalant => fn_cdocupacao(:old.CDOCUPACAO),
                       pr_dsvalnov => fn_cdocupacao(:new.CDOCUPACAO));
    END IF;
    
    --> TPRELACAO
    IF nvl(:new.Tprelacao_Polexp,0) <> nvl(:OLD.TPRELACAO_POLEXP,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPRELACAO_POLEXP',
                       pr_dsvalant => fn_desc_tprelacao_polexp(:old.Tprelacao_Polexp),
                       pr_dsvalnov => fn_desc_tprelacao_polexp(:new.Tprelacao_Polexp ));
    END IF;
       
    --> IDPESSOA_POLITICO
    IF nvl(:new.IDPESSOA_POLITICO,0) <> nvl(:OLD.IDPESSOA_POLITICO,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA_POLITICO',
                       pr_dsvalant => (:old.IDPESSOA_POLITICO),
                       pr_dsvalnov => (:new.IDPESSOA_POLITICO));
    END IF;
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    
  END IF;

END TRG_TBCADAST_PESSOA_POLEXP_HST;
/
