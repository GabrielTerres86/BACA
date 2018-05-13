CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_HST
  AFTER INSERT OR UPDATE ON TBCADAST_PESSOA
  FOR EACH ROW  
  /* ..........................................................................
    
     Programa : TRG_TBCADAST_PESSOA_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA';
  vr_dhaltera   CONSTANT DATE := SYSDATE;
  vr_data       DATE := to_date('01/01/1500','DD/MM/RRRR');
  vr_tab_campos CADA0014.typ_tab_campos_hist;
  vr_idpessoa   tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen   tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac   tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad   tbcadast_pessoa_historico.cdoperad_altera%TYPE;
  
  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);

  --> Retornar descrição da situação do CPF/CNPJ
  FUNCTION fn_situacao_cpf_cnpj(pr_cdsituacao_rfb tbcadast_pessoa.cdsituacao_rfb%type) RETURN VARCHAR2 IS
  BEGIN    
    IF pr_cdsituacao_rfb IS NOT NULL THEN
      RETURN pr_cdsituacao_rfb||'-'||CADA0014.fn_desc_situacao_cpf_cnpj(pr_cdsituacao_rfb);
    ELSE
      RETURN NULL;
    END IF;
  END;
  
  --> Retornar descrição do tipo de consulta
  FUNCTION fn_tipo_consulta_rfb(pr_tpconsulta_rfb tbcadast_pessoa.tpconsulta_rfb%type) RETURN VARCHAR2 IS
  BEGIN
    IF pr_tpconsulta_rfb IS NOT NULL THEN
      RETURN pr_tpconsulta_rfb ||'-'|| CADA0014.fn_desc_tpconsulta_rfb(pr_tpconsulta_rfb);
    ELSE
      RETURN NULL; 
    END IF;
  END;

  --> Retornar descrição do tipo de cadastro
  FUNCTION fn_tipo_cadastro(pr_tpcadastro tbcadast_pessoa.tpcadastro%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpcadastro IS NOT NULL THEN
      RETURN pr_tpcadastro ||'-'|| CADA0014.fn_desc_tpcadastro( pr_tpcadastro => pr_tpcadastro,
                                                                pr_dscritic => vr_dscritic);
    ELSE
      RETURN NULL; 
    END IF;    
  
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
  CADA0014.pc_carrega_campos( pr_nmdatela   => 'TBCADAST_PESSOA'  --> Nome da tela                              
                             ,pr_tab_campos => vr_tab_campos);    --> Retorna campos da tabela historico

  --> Setar variaveis padrão
  IF INSERTING THEN
    vr_tpoperac := 1; --INSERT
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := 0;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := 0;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := 0;
    vr_cdoperad := NULL; --> Verificar Andrino
  END IF;

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            1	- IDPESSOA
            2	- NRCPFCGC
            3	- NMPESSOA
            4	- NMPESSOA_RECEITA
            5	- TPPESSOA
            6	- DTCONSULTA_SPC
            7	- DTCONSULTA_RFB
            8	- CDSITUACAO_RFB
            9	- TPCONSULTA_RFB
           10	- DTATUALIZA_TELEFONE
           11	- DTCONSULTA_SCR
           12	- TPCADASTRO
           13	- CDOPERAD_ALTERA
           14	- IDCORRIGIDO
           15	- DTALTERACAO
  **************************************/


  IF INSERTING OR 
     UPDATING THEN
  
    --> IDPESSOA
    IF nvl(:new.IDPESSOA,0) <> nvl(:OLD.IDPESSOA,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA',
                       pr_dsvalant => :old.IDPESSOA,
                       pr_dsvalnov => :new.IDPESSOA);
    END IF;
  
    --> NRCPFCGC
    IF nvl(:new.NRCPFCGC,0) <> nvl(:OLD.NRCPFCGC,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRCPFCGC',
                       pr_dsvalant => :old.NRCPFCGC,
                       pr_dsvalnov => :new.NRCPFCGC);
    END IF;
    
    --> NMPESSOA  
    IF nvl(:new.NMPESSOA,' ') <> nvl(:OLD.NMPESSOA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMPESSOA',
                       pr_dsvalant => :old.NMPESSOA,
                       pr_dsvalnov => :new.NMPESSOA);
    END IF;
    
    --> NMPESSOA_RECEITA
    IF nvl(:new.NMPESSOA_RECEITA,' ') <> nvl(:OLD.NMPESSOA_RECEITA,' ') THEN      
      Insere_Historico(pr_nmdcampo => 'NMPESSOA_RECEITA',
                       pr_dsvalant => :old.NMPESSOA_RECEITA,
                       pr_dsvalnov => :new.NMPESSOA_RECEITA);
    END IF;
    
    --> TPPESSOA
    IF nvl(:new.TPPESSOA,0) <> nvl(:OLD.TPPESSOA,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPPESSOA',
                       pr_dsvalant => :old.TPPESSOA,
                       pr_dsvalnov => :new.TPPESSOA);
    END IF;
    
    --> DTCONSULTA_SPC    
    IF nvl(:new.DTCONSULTA_SPC,vr_data) <> nvl(:OLD.DTCONSULTA_SPC,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTCONSULTA_SPC',
                       pr_dsvalant => to_char(:old.DTCONSULTA_SPC,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTCONSULTA_SPC,'DD/MM/RRRR'));      
    END IF;
    
    --> DTCONSULTA_RFB        
    IF nvl(:new.DTCONSULTA_RFB,vr_data) <> nvl(:OLD.DTCONSULTA_RFB,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTCONSULTA_RFB',
                       pr_dsvalant => to_char(:old.DTCONSULTA_RFB,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTCONSULTA_RFB,'DD/MM/RRRR'));      
    END IF;   

    --> CDSITUACAO_RFB
    IF nvl(:new.CDSITUACAO_RFB,0) <> nvl(:OLD.CDSITUACAO_RFB,0) THEN      
      Insere_Historico(pr_nmdcampo => 'CDSITUACAO_RFB',
                       pr_dsvalant => fn_situacao_cpf_cnpj(:old.CDSITUACAO_RFB),
                       pr_dsvalnov => fn_situacao_cpf_cnpj(:new.CDSITUACAO_RFB));
    END IF;
    
    --> TPCONSULTA_RFB
    IF nvl(:new.TPCONSULTA_RFB,0) <> nvl(:OLD.TPCONSULTA_RFB,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPCONSULTA_RFB',
                       pr_dsvalant => fn_tipo_consulta_rfb(:old.TPCONSULTA_RFB),
                       pr_dsvalnov => fn_tipo_consulta_rfb(:new.TPCONSULTA_RFB));
    END IF;
    
    --> DTATUALIZA_TELEFONE
    IF nvl(:new.DTATUALIZA_TELEFONE,vr_data) <> nvl(:OLD.DTATUALIZA_TELEFONE,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTATUALIZA_TELEFONE',
                       pr_dsvalant => to_char(:old.DTATUALIZA_TELEFONE,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTATUALIZA_TELEFONE,'DD/MM/RRRR'));      
    END IF;
    
    --> DTCONSULTA_SCR
    IF nvl(:new.DTCONSULTA_SCR,vr_data) <> nvl(:OLD.DTCONSULTA_SCR,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTCONSULTA_SCR',
                       pr_dsvalant => to_char(:old.DTCONSULTA_SCR,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTCONSULTA_SCR,'DD/MM/RRRR'));      
    END IF;
    
    --> TPCADASTRO
    IF nvl(:new.TPCADASTRO,0) <> nvl(:OLD.TPCADASTRO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPCADASTRO',
                       pr_dsvalant => fn_tipo_cadastro(:old.TPCADASTRO),
                       pr_dsvalnov => fn_tipo_cadastro(:new.TPCADASTRO));
    END IF;
    
    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    --> IDCORRIGIDO
    IF nvl(:new.IDCORRIGIDO,0) <> nvl(:OLD.IDCORRIGIDO,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDCORRIGIDO',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA);
    END IF;
    
    --> DTALTERACAO
    IF nvl(:new.DTALTERACAO,vr_data) <> nvl(:OLD.DTALTERACAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTALTERACAO',
                       pr_dsvalant => to_char(:old.DTALTERACAO,'DD/MM/RRRR HH24:MI:SS'),
                       pr_dsvalnov => to_char(:new.DTALTERACAO,'DD/MM/RRRR HH24:MI:SS'));      
    END IF;
  
  END IF;

END TRG_TBCADAST_PESSOA_HST;
/
