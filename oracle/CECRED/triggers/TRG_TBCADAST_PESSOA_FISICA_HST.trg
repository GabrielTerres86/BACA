CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_FISICA_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_FISICA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_FISICA_HST
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(Amcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Alteração :
                 27/06/2018 - Campo dsvalor_novo_original e PC_INSERE_COMUNIC_SOA. Alexandre Borgmann - Mout´s Tecnologia
  ............................................................................*/


DECLARE

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_FISICA';
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
  -- Variável indicando que esta dentro da funçao insere_historico
  vr_flginsere_historico   boolean :=FALSE;

  --> Retornar descrição do tipo de sexo
  FUNCTION fn_tpsexo(pr_tpsexo tbcadast_pessoa_fisica.tpsexo%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpsexo IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpsexo ||'-'||
           CADA0014.fn_desc_tpsexo (pr_tpsexo  => pr_tpsexo,
                                    pr_dscritic  => vr_dscritic);
  END;

  --> Retornar descrição da estado civil
  FUNCTION fn_cdestado_civil(pr_cdestado_civil tbcadast_pessoa_fisica.cdestado_civil%type) 
           RETURN VARCHAR2 IS
           
   vr_flretorn  BOOLEAN;
   vr_dsestcvl  VARCHAR2(100);
           
  BEGIN
    IF pr_cdestado_civil IS NULL THEN
      RETURN NULL;
    END IF;
    
    vr_flretorn := CADA0001.fn_busca_estado_civil 
                                   (pr_cdestcvl => pr_cdestado_civil  --> Código Estado Civil
                                   ,pr_dsestcvl => vr_dsestcvl        --> Descricao Estado Civil
                                   ,pr_cdcritic => vr_cdcritic        --> Codigo de erro
                                   ,pr_dscritic => vr_dscritic);      --> Retorno de Erro
    IF vr_flretorn THEN
      RETURN pr_cdestado_civil ||'-'||vr_dsestcvl;
    ELSE
      RETURN pr_cdestado_civil ||'-Outro';
      
    END IF;
  END;

  --> Retornar descrição da naturalidade
  FUNCTION fn_desc_naturalidade(pr_cdnatura tbcadast_pessoa_fisica.cdnaturalidade%type) 
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdnatura IS NULL THEN
      RETURN NULL;
    END IF; 
  
    RETURN pr_cdnatura ||'-'||
           CADA0014.fn_desc_naturalidade (pr_cdnatura  => pr_cdnatura,
                                          pr_dscritic  => vr_dscritic);
                                                                      
  END;

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
  
  --> Retornar descrição do tipo nacionalidade
  FUNCTION fn_desc_tpnacionalidade(pr_tpnacion tbcadast_pessoa_fisica.tpnacionalidade%type) 
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_tpnacion IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_tpnacion ||'-'||
           CADA0014.fn_desc_tpnacionalidade (pr_tpnacion  => pr_tpnacion,
                                             pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Retornar descrição do tipo documento
  FUNCTION fn_tpdocumento(pr_tpdocumento tbcadast_pessoa_fisica.tpdocumento%type) RETURN VARCHAR2 IS
  BEGIN
    IF pr_tpdocumento IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_tpdocumento ||'-'||
           CADA0014.fn_desc_tpdocumento (pr_tpdocumento  => pr_tpdocumento,
                                         pr_dscritic  => vr_dscritic);
  END;
  
  --> Retornar descrição do orgão expedidor
  FUNCTION fn_desc_idorgexp (pr_idorgexp tbcadast_pessoa_fisica.idorgao_expedidor%type) 
              RETURN VARCHAR2 IS
    vr_cdorgexp tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    
  BEGIN
    IF pr_idorgexp IS NULL THEN
      RETURN NULL;
    END IF;
                              
    --> Buscar orgão expedidor
    cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => pr_idorgexp, 
                                      pr_cdorgao_expedidor => vr_cdorgexp, 
                                      pr_nmorgao_expedidor => vr_nmorgexp, 
                                      pr_cdcritic          => vr_cdcritic, 
                                      pr_dscritic          => vr_dscritic);
    RETURN pr_idorgexp ||'-'||vr_cdorgexp; 
  END;
  
  --> Retornar descrição do menor/habilitado
  FUNCTION fn_inhabilitacao_menor(pr_inhabilitacao_menor tbcadast_pessoa_fisica.inhabilitacao_menor%type) RETURN VARCHAR2 IS
  BEGIN
    IF pr_inhabilitacao_menor IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_inhabilitacao_menor ||'-'||
           CADA0014.fn_desc_inhabilitacao_menor (pr_inhabilitacao_menor  => pr_inhabilitacao_menor,
                                                 pr_dscritic  => vr_dscritic);
                                               
  END;
  
  --> Retornar descrição do grau escolaridade 
  FUNCTION fn_desc_grau_escolaridade(pr_cdgresco  IN tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdgresco IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdgresco ||'-'||
           CADA0014.fn_desc_grau_escolaridade (pr_cdgresco  => pr_cdgresco,
                                               pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Retornar descrição do curso superior
  FUNCTION fn_desc_curso_superior(pr_cdcursup  IN tbcadast_pessoa_fisica.cdcurso_superior%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdcursup IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdcursup ||'-'||
           CADA0014.fn_desc_curso_superior (pr_cdcursup  => pr_cdcursup,
                                            pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Retornar descrição do curso superior
  FUNCTION fn_desc_natureza_ocupacao (pr_cdnatocp  IN tbcadast_pessoa_fisica.cdnatureza_ocupacao%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdnatocp IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cdnatocp ||'-'||
           CADA0014.fn_desc_natureza_ocupacao (pr_cdnatocp  => pr_cdnatocp,
                                               pr_dscritic  => vr_dscritic);
                                                                      
  END;
  
  --> Grava a tabela historico
  PROCEDURE Insere_Historico(pr_nmdcampo IN VARCHAR2,
                             pr_dsvalant IN tbcadast_pessoa_historico.dsvalor_anterior%TYPE,
                             pr_dsvalnov IN tbcadast_pessoa_historico.dsvalor_novo%TYPE,
                             pr_dsvalor_novo_original IN tbcadast_pessoa_historico.dsvalor_novo_original%TYPE
                            ) IS
  BEGIN
    -- Deve-se enviar o historico para o SOA
    vr_flginsere_historico:=TRUE;

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
                         ,pr_dsvalor_novo_original => pr_dsvalor_novo_original --> Valor Original sem descrição                         
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
            37	IDPESSOA
            38	NMSOCIAL
            39	TPSEXO
            40	CDESTADO_CIVIL
            41	DTNASCIMENTO
            42	CDNATURALIDADE
            43	CDNACIONALIDADE
            44	TPNACIONALIDADE
            45	TPDOCUMENTO
            46	NRDOCUMENTO
            47	DTEMISSAO_DOCUMENTO
            48	IDORGAO_EXPEDIDOR
            49	CDUF_ORGAO_EXPEDIDOR
            50	INHABILITACAO_MENOR
            51	DTHABILITACAO_MENOR
            52	CDGRAU_ESCOLARIDADE
            53	CDCURSO_SUPERIOR
            54	CDNATUREZA_OCUPACAO
            55	DSPROFISSAO
            56	VLRENDA_PRESUMIDA
            57	DSJUSTIFIC_OUTROS_REND

  **************************************/


  IF INSERTING OR
     UPDATING  OR 
     DELETING  THEN

    --> IDPESSOA
    IF nvl(:new.IDPESSOA,0) <> nvl(:OLD.IDPESSOA,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA',
                       pr_dsvalant => :old.IDPESSOA,
                       pr_dsvalnov => :new.IDPESSOA,
                       pr_dsvalor_novo_original => :new.IDPESSOA 
                      );
    END IF;

    --> NMSOCIAL
    IF nvl(:new.NMSOCIAL,' ') <> nvl(:OLD.NMSOCIAL,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMSOCIAL',
                       pr_dsvalant => :old.NMSOCIAL,
                       pr_dsvalnov => :new.NMSOCIAL,
                       pr_dsvalor_novo_original => :new.NMSOCIAL 
                      );
    END IF;

    --> TPSEXO
    IF nvl(:new.TPSEXO,0) <> nvl(:OLD.TPSEXO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPSEXO',
                       pr_dsvalant => fn_tpsexo(:old.TPSEXO),
                       pr_dsvalnov => fn_tpsexo(:new.TPSEXO),
                       pr_dsvalor_novo_original => :new.TPSEXO 
                      );
    END IF;
    
    --> CDESTADO_CIVIL
    IF nvl(:new.CDESTADO_CIVIL,0) <> nvl(:OLD.CDESTADO_CIVIL,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDESTADO_CIVIL',
                       pr_dsvalant => fn_cdestado_civil(:old.CDESTADO_CIVIL),
                       pr_dsvalnov => fn_cdestado_civil(:new.CDESTADO_CIVIL),
                       pr_dsvalor_novo_original => :new.CDESTADO_CIVIL 
                      );
    END IF;
    
    --> DTNASCIMENTO
    IF nvl(:new.DTNASCIMENTO,vr_data) <> nvl(:OLD.DTNASCIMENTO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTNASCIMENTO',
                       pr_dsvalant => to_char(:old.DTNASCIMENTO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTNASCIMENTO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTNASCIMENTO,'DD/MM/RRRR')                       
                      );
    END IF;

    --> CDNATURALIDADE
    IF nvl(:new.CDNATURALIDADE,0) <> nvl(:OLD.CDNATURALIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDNATURALIDADE',
                       pr_dsvalant => fn_desc_naturalidade(:old.CDNATURALIDADE),
                       pr_dsvalnov => fn_desc_naturalidade(:new.CDNATURALIDADE),
                       pr_dsvalor_novo_original => :new.CDNATURALIDADE                       
                      );
    END IF;

    --> CDNACIONALIDADE
    IF nvl(:new.CDNACIONALIDADE,0) <> nvl(:OLD.CDNACIONALIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDNACIONALIDADE',
                       pr_dsvalant => fn_desc_nacionalidade(:old.CDNACIONALIDADE),
                       pr_dsvalnov => fn_desc_nacionalidade(:new.CDNACIONALIDADE),
                       pr_dsvalor_novo_original => :new.CDNACIONALIDADE                      
                      );
    END IF;
    
    --> TPNACIONALIDADE
    IF nvl(:new.TPNACIONALIDADE,0) <> nvl(:OLD.TPNACIONALIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPNACIONALIDADE',
                       pr_dsvalant => fn_desc_tpnacionalidade(:old.TPNACIONALIDADE),
                       pr_dsvalnov => fn_desc_tpnacionalidade(:new.TPNACIONALIDADE),
                       pr_dsvalor_novo_original => :new.TPNACIONALIDADE                      
                      );
    END IF;
   
    --> TPDOCUMENTO
    IF nvl(:new.TPDOCUMENTO,' ') <> nvl(:OLD.TPDOCUMENTO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'TPDOCUMENTO',
                       pr_dsvalant => fn_tpdocumento(:old.TPDOCUMENTO),
                       pr_dsvalnov => fn_tpdocumento(:new.TPDOCUMENTO),
                       pr_dsvalor_novo_original => :new.TPDOCUMENTO                                             
                      );
    END IF;
    
    --> NRDOCUMENTO
    IF nvl(:new.NRDOCUMENTO,' ') <> nvl(:OLD.NRDOCUMENTO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NRDOCUMENTO',
                       pr_dsvalant => :old.NRDOCUMENTO,
                       pr_dsvalnov => :new.NRDOCUMENTO,
                       pr_dsvalor_novo_original => :new.NRDOCUMENTO                                             
                      );
    END IF;
    
    --> DTEMISSAO_DOCUMENTO
    IF nvl(:new.DTEMISSAO_DOCUMENTO,vr_data) <> nvl(:OLD.DTEMISSAO_DOCUMENTO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTEMISSAO_DOCUMENTO',
                       pr_dsvalant => to_char(:old.DTEMISSAO_DOCUMENTO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTEMISSAO_DOCUMENTO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTEMISSAO_DOCUMENTO,'DD/MM/RRRR')                                             
                      );
    END IF;
    
    --> IDORGAO_EXPEDIDOR
    IF nvl(:new.IDORGAO_EXPEDIDOR,0) <> nvl(:OLD.IDORGAO_EXPEDIDOR,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDORGAO_EXPEDIDOR',
                       pr_dsvalant => fn_desc_idorgexp(:old.IDORGAO_EXPEDIDOR),
                       pr_dsvalnov => fn_desc_idorgexp(:new.IDORGAO_EXPEDIDOR),
                       pr_dsvalor_novo_original => :new.IDORGAO_EXPEDIDOR                                             
                      );
    END IF;
    
    --> CDUF_ORGAO_EXPEDIDOR
    IF nvl(:new.CDUF_ORGAO_EXPEDIDOR,' ') <> nvl(:OLD.CDUF_ORGAO_EXPEDIDOR,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDUF_ORGAO_EXPEDIDOR',
                       pr_dsvalant => :old.CDUF_ORGAO_EXPEDIDOR,
                       pr_dsvalnov => :new.CDUF_ORGAO_EXPEDIDOR,
                       pr_dsvalor_novo_original => :new.CDUF_ORGAO_EXPEDIDOR                                             
                      );
    END IF;
    
    --> INHABILITACAO_MENOR
    IF nvl(:new.INHABILITACAO_MENOR,0) <> nvl(:OLD.INHABILITACAO_MENOR,0) THEN
      Insere_Historico(pr_nmdcampo => 'INHABILITACAO_MENOR',
                       pr_dsvalant => fn_inhabilitacao_menor(:old.INHABILITACAO_MENOR),
                       pr_dsvalnov => fn_inhabilitacao_menor(:new.INHABILITACAO_MENOR),
                       pr_dsvalor_novo_original => :new.INHABILITACAO_MENOR                                             
                      );
    END IF;
    
    --> DTHABILITACAO_MENOR
    IF nvl(:new.DTHABILITACAO_MENOR,vr_data) <> nvl(:OLD.DTHABILITACAO_MENOR,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTHABILITACAO_MENOR',
                       pr_dsvalant => to_char(:old.DTHABILITACAO_MENOR,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTHABILITACAO_MENOR,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTHABILITACAO_MENOR,'DD/MM/RRRR')                        
                      );
    END IF;
    
    --> CDGRAU_ESCOLARIDADE
    IF nvl(:new.CDGRAU_ESCOLARIDADE,0) <> nvl(:OLD.CDGRAU_ESCOLARIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDGRAU_ESCOLARIDADE',
                       pr_dsvalant => fn_desc_grau_escolaridade(:old.CDGRAU_ESCOLARIDADE),
                       pr_dsvalnov => fn_desc_grau_escolaridade(:new.CDGRAU_ESCOLARIDADE),
                       pr_dsvalor_novo_original => :new.CDGRAU_ESCOLARIDADE                                               
                      );
    END IF;
    
    --> CDCURSO_SUPERIOR
    IF nvl(:new.CDCURSO_SUPERIOR,0) <> nvl(:OLD.CDCURSO_SUPERIOR,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDCURSO_SUPERIOR',
                       pr_dsvalant => fn_desc_curso_superior(:old.CDCURSO_SUPERIOR),
                       pr_dsvalnov => fn_desc_curso_superior(:new.CDCURSO_SUPERIOR),
                       pr_dsvalor_novo_original => :new.CDCURSO_SUPERIOR                                               
                      );
    END IF;
    
    --> CDNATUREZA_OCUPACAO
    IF nvl(:new.CDNATUREZA_OCUPACAO,0) <> nvl(:OLD.CDNATUREZA_OCUPACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDNATUREZA_OCUPACAO',
                       pr_dsvalant => fn_desc_natureza_ocupacao(:old.CDNATUREZA_OCUPACAO),
                       pr_dsvalnov => fn_desc_natureza_ocupacao(:new.CDNATUREZA_OCUPACAO),
                       pr_dsvalor_novo_original => :new.CDNATUREZA_OCUPACAO                                               
                      );
    END IF;
    
    --> DSPROFISSAO
    IF nvl(:new.DSPROFISSAO,' ') <> nvl(:OLD.DSPROFISSAO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSPROFISSAO',
                       pr_dsvalant => :old.DSPROFISSAO,
                       pr_dsvalnov => :new.DSPROFISSAO,
                       pr_dsvalor_novo_original => :new.DSPROFISSAO                                                                      
                      );
    END IF;
    
    --> VLRENDA_PRESUMIDA
    IF nvl(:new.VLRENDA_PRESUMIDA,0) <> nvl(:OLD.VLRENDA_PRESUMIDA,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLRENDA_PRESUMIDA',
                       pr_dsvalant => :old.VLRENDA_PRESUMIDA,
                       pr_dsvalnov => :new.VLRENDA_PRESUMIDA,
                       pr_dsvalor_novo_original => :new.VLRENDA_PRESUMIDA                                                                                             
                      );
    END IF;
    
    --> DSJUSTIFIC_OUTROS_REND
    IF nvl(:new.DSJUSTIFIC_OUTROS_REND,' ') <> nvl(:OLD.DSJUSTIFIC_OUTROS_REND,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSJUSTIFIC_OUTROS_REND',
                       pr_dsvalant => :old.DSJUSTIFIC_OUTROS_REND,
                       pr_dsvalnov => :new.DSJUSTIFIC_OUTROS_REND,
                       pr_dsvalor_novo_original => :new.DSJUSTIFIC_OUTROS_REND                                                                                             
                      );
    END IF;
    
    
  END IF;
  -- Se gerou historico, entao deve-se transmitir para o SOA
  IF vr_flginsere_historico THEN 

     CADA0014.PC_INSERE_COMUNIC_SOA(vr_nmdatela, -- nmtabela_oracle 
                                    vr_idpessoa, -- idpessoa 
                                    vr_nrsequen, -- nrsequencia 
                                    vr_dhaltera, --dhalteracao 
                                    vr_tpoperac, --tpoperacao --Tipo de alteracao do registro (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                                    vr_dscritic    -- descrição do erro
                                   );
     
     IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
     END IF;
  END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20100,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20100,'Erro TRG_TBCADAST_PESSOA_FISICA_HST: '||SQLERRM);

END TRG_TBCADAST_PESSOA_FISICA_HST;
/
