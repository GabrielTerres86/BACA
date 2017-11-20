CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_REP_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_REP

  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_REP_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_REP';
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

  --> Function para retornar descri��o do tipo cargo representante  
  FUNCTION fn_desc_tpcargo_representante (pr_tpcargo_representante  IN tbcadast_pessoa_juridica_rep.tpcargo_representante%TYPE) 
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpcargo_representante IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpcargo_representante ||'-'||
           CADA0014.fn_desc_tpcargo_representante (pr_tpcargo_representante  => pr_tpcargo_representante,
                                                   pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Function para retornar descri��o do tipo cargo representante  
  FUNCTION fn_desc_sim_nao ( pr_cddomini   IN VARCHAR2)        --> Codigo que deseja retornar descri��o) 
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_cddomini IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cddomini ||'-'||
           GENE0010.fn_desc_sim_nao (pr_cddomini  => pr_cddomini);
                                                                      
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
    vr_nrsequen := :new.NRSEQ_REPRESENTANTE;    
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := :new.NRSEQ_REPRESENTANTE;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_REPRESENTANTE;
    
    vr_cdoperad := cada0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;    
  END IF;  
  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            187	IDPESSOA
            188	NRSEQ_REPRESENTANTE
            189	IDPESSOA_REPRESENTANTE
            190	TPCARGO_REPRESENTANTE
            191	DTVIGENCIA
            192	DTADMISSAO
            193	PERSOCIO
            194	FLGDEPENDENCIA_ECONOMICA
            195	CDOPERAD_ALTERA

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

    --> NRSEQ_REPRESENTANTE
    IF nvl(:new.NRSEQ_REPRESENTANTE,0) <> nvl(:OLD.NRSEQ_REPRESENTANTE,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_REPRESENTANTE',
                       pr_dsvalant => (:old.NRSEQ_REPRESENTANTE),
                       pr_dsvalnov => (:new.NRSEQ_REPRESENTANTE ));
    END IF;
    
    --> IDPESSOA_REPRESENTANTE
    IF nvl(:new.IDPESSOA_REPRESENTANTE,0) <> nvl(:OLD.IDPESSOA_REPRESENTANTE,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA_REPRESENTANTE',
                       pr_dsvalant => (:old.IDPESSOA_REPRESENTANTE),
                       pr_dsvalnov => (:new.IDPESSOA_REPRESENTANTE ));
    END IF;
    
    --> TPCARGO_REPRESENTANTE
    IF nvl(:new.TPCARGO_REPRESENTANTE,0) <> nvl(:OLD.TPCARGO_REPRESENTANTE,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPCARGO_REPRESENTANTE',
                       pr_dsvalant => fn_desc_tpcargo_representante(:old.TPCARGO_REPRESENTANTE),
                       pr_dsvalnov => fn_desc_tpcargo_representante(:new.TPCARGO_REPRESENTANTE));
    END IF;
    
    --> DTVIGENCIA
    IF nvl(:new.DTVIGENCIA,vr_data) <> nvl(:OLD.DTVIGENCIA,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTVIGENCIA',
                       pr_dsvalant => to_char(:old.DTVIGENCIA,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTVIGENCIA,'DD/MM/RRRR'));
    END IF; 
    
    --> DTADMISSAO
    IF nvl(:new.DTADMISSAO,vr_data) <> nvl(:OLD.DTADMISSAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTADMISSAO',
                       pr_dsvalant => to_char(:old.DTADMISSAO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTADMISSAO,'DD/MM/RRRR'));
    END IF; 
        
    --> PERSOCIO
    IF nvl(:new.PERSOCIO,0) <> nvl(:OLD.PERSOCIO,0) THEN
      Insere_Historico(pr_nmdcampo => 'PERSOCIO',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.PERSOCIO),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.PERSOCIO));
    END IF;
       
    --> FLGDEPENDENCIA_ECONOMICA
    IF nvl(:new.FLGDEPENDENCIA_ECONOMICA,0) <> nvl(:OLD.FLGDEPENDENCIA_ECONOMICA,0) THEN
      Insere_Historico(pr_nmdcampo => 'FLGDEPENDENCIA_ECONOMICA',
                       pr_dsvalant => fn_desc_sim_nao(:old.FLGDEPENDENCIA_ECONOMICA),
                       pr_dsvalnov => fn_desc_sim_nao(:new.FLGDEPENDENCIA_ECONOMICA));
    END IF;
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    
  END IF;

END TRG_TBCADAST_PJ_REP_HST;
/
