CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_TEL_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_TELEFONE
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_TEL_HST
     Sistema  : Conta-Corrente - Cooperativa de Credito
     Sigla    : CRED
     Autor    : Odirlei Busana(AMcom)
     Data     : Julho/2017.                   Ultima atualizacao:

     Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Trigger para gravar Historico/Auditoria da tabela

     Alteração :
                 27/06/2018 - Campo dsvalor_novo_original e PC_INSERE_COMUNIC_SOA. Alexandre Borgmann - Mout´s Tecnologia
  ............................................................................*/


DECLARE

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_TELEFONE';
  vr_dhaltera   CONSTANT DATE := SYSDATE;
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

  --> Retornar descrição da operadora
  FUNCTION fn_cdoperadora(pr_cdoperadora tbcadast_pessoa_telefone.cdoperadora%type)
           RETURN VARCHAR2 IS

   vr_tab_operadoras tbrecarga_operadora%ROWTYPE;

  BEGIN
    IF pr_cdoperadora IS NULL THEN
      RETURN NULL;
    END IF;

    --> Buscar a Operadora
    RCEL0001.pc_busca_operadora( pr_cdoperadora    => pr_cdoperadora     --> Código da Operadora
                                ,pr_tab_operadoras => vr_tab_operadoras  --> Record com as informações da operadora
                                ,pr_cdcritic       => vr_cdcritic        --> Codigo da critica
                                ,pr_dscritic       => vr_dscritic);      --> Descricao da critica

    IF vr_tab_operadoras.nmoperadora IS NOT NULL THEN
      RETURN pr_cdoperadora ||'-'||vr_tab_operadoras.nmoperadora;
    ELSE
      RETURN pr_cdoperadora ||'-Nao cadast.';
    END IF;
    
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
    vr_nrsequen := :new.NRSEQ_TELEFONE;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := :new.NRSEQ_TELEFONE;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_TELEFONE;
    
    vr_cdoperad := CADA0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;
      
  END IF;


  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            130	IDPESSOA
            131	NRSEQ_TELEFONE
            132	CDOPERADORA
            133	TPTELEFONE
            134	NMPESSOA_CONTATO
            135	NMSETOR_PESSOA_CONTATO
            136	NRDDD
            137	NRTELEFONE
            138	NRRAMAL
            139	INSITUACAO
            140	TPORIGEM_CADASTRO
            141	CDOPERAD_ALTERA

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

    --> NRSEQ_TELEFONE
    IF nvl(:new.NRSEQ_TELEFONE,0) <> nvl(:OLD.NRSEQ_TELEFONE,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_TELEFONE',
                       pr_dsvalant => :old.NRSEQ_TELEFONE,
                       pr_dsvalnov => :new.NRSEQ_TELEFONE,
                       pr_dsvalor_novo_original => :new.NRSEQ_TELEFONE
                      );
    END IF;

    --> CDOPERADORA
    IF nvl(:new.CDOPERADORA,0) <> nvl(:OLD.CDOPERADORA,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERADORA',
                       pr_dsvalant => fn_cdoperadora(:old.CDOPERADORA),
                       pr_dsvalnov => fn_cdoperadora(:new.CDOPERADORA),
                       pr_dsvalor_novo_original => :new.CDOPERADORA
                      );
    END IF;

    --> TPTELEFONE
    IF nvl(:new.TPTELEFONE,0) <> nvl(:OLD.TPTELEFONE,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPTELEFONE',
                       pr_dsvalant => (:old.TPTELEFONE),
                       pr_dsvalnov => (:new.TPTELEFONE),
                       pr_dsvalor_novo_original => :new.TPTELEFONE
                      );
    END IF;
    
    --> NMPESSOA_CONTATO
    IF nvl(:new.NMPESSOA_CONTATO,' ') <> nvl(:OLD.NMPESSOA_CONTATO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMPESSOA_CONTATO',
                       pr_dsvalant => :old.NMPESSOA_CONTATO,
                       pr_dsvalnov => :new.NMPESSOA_CONTATO,
                       pr_dsvalor_novo_original => :new.NMPESSOA_CONTATO
                      );
    END IF;
    
    --> NMSETOR_PESSOA_CONTATO
    IF nvl(:new.NMSETOR_PESSOA_CONTATO,' ') <> nvl(:OLD.NMSETOR_PESSOA_CONTATO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMSETOR_PESSOA_CONTATO',
                       pr_dsvalant => :old.NMSETOR_PESSOA_CONTATO,
                       pr_dsvalnov => :new.NMSETOR_PESSOA_CONTATO,
                       pr_dsvalor_novo_original => :new.NMSETOR_PESSOA_CONTATO
                      );
    END IF;
    
    --> NRDDD
    IF nvl(:new.NRDDD,0) <> nvl(:OLD.NRDDD,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRDDD',
                       pr_dsvalant => (:old.NRDDD),
                       pr_dsvalnov => (:new.NRDDD),
                       pr_dsvalor_novo_original => :new.NRDDD
                      );
    END IF;
    
    --> NRTELEFONE
    IF nvl(:new.NRTELEFONE,0) <> nvl(:OLD.NRTELEFONE,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRTELEFONE',
                       pr_dsvalant => (:old.NRTELEFONE),
                       pr_dsvalnov => (:new.NRTELEFONE),
                       pr_dsvalor_novo_original => :new.NRTELEFONE
                      );
    END IF;
    
    --> NRRAMAL
    IF nvl(:new.NRRAMAL,0) <> nvl(:OLD.NRRAMAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRRAMAL',
                       pr_dsvalant => (:old.NRRAMAL),
                       pr_dsvalnov => (:new.NRRAMAL),
                       pr_dsvalor_novo_original => :new.NRRAMAL
                      );
    END IF;
    
    --> INSITUACAO
    IF nvl(:new.INSITUACAO,0) <> nvl(:OLD.INSITUACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'INSITUACAO',
                       pr_dsvalant => (:old.INSITUACAO),
                       pr_dsvalnov => (:new.INSITUACAO),
                       pr_dsvalor_novo_original => :new.INSITUACAO
                      );
    END IF;
    
    --> TPORIGEM_CADASTRO
    IF nvl(:new.TPORIGEM_CADASTRO,0) <> nvl(:OLD.TPORIGEM_CADASTRO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPORIGEM_CADASTRO',
                       pr_dsvalant => fn_tporigem_cadastro(:old.TPORIGEM_CADASTRO),
                       pr_dsvalnov => fn_tporigem_cadastro(:new.TPORIGEM_CADASTRO),
                       pr_dsvalor_novo_original => :new.TPORIGEM_CADASTRO
                      );
    END IF;
    
    --> FLGAGEITA_SMS
    IF nvl(:new.FLGACEITA_SMS,0) <> nvl(:OLD.FLGACEITA_SMS,0) THEN
      Insere_Historico(pr_nmdcampo => 'FLGACEITA_SMS',
                       pr_dsvalant => (:old.FLGACEITA_SMS),
                       pr_dsvalnov => (:new.FLGACEITA_SMS),
                       pr_dsvalor_novo_original => :new.FLGACEITA_SMS                          
                      );
    END IF;

    --> CDOPERAD_ALTERA
    IF nvl(:new.CDOPERAD_ALTERA,' ') <> nvl(:OLD.CDOPERAD_ALTERA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'CDOPERAD_ALTERA',
                       pr_dsvalant => :old.CDOPERAD_ALTERA,
                       pr_dsvalnov => :new.CDOPERAD_ALTERA,
                       pr_dsvalor_novo_original => :new.CDOPERAD_ALTERA                       
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
      raise_application_error(-20100,'Erro TRG_TBCADAST_PESSOA_TEL_HST: '||SQLERRM);
END TRG_TBCADAST_PESSOA_TEL_HST;
/
