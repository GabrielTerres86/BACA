CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_RENDA_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_RENDA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_RENDA_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_RENDA';
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
  
  --> Retornar descrição do tipo de contrato_trabalho
  FUNCTION fn_tpcontrato_trabalho(pr_tpcontrato_trabalho tbcadast_pessoa_renda.tpcontrato_trabalho%type) RETURN VARCHAR2 IS
  BEGIN

    IF pr_tpcontrato_trabalho IS NULL THEN
      RETURN NULL;
    END IF;

    RETURN pr_tpcontrato_trabalho ||'-'||
           CADA0014.fn_desc_tpcontrato_trabalho (pr_tpcontrato_trabalho   => pr_tpcontrato_trabalho,
                                                 pr_dscritic  => vr_dscritic);
  END;
  
  --> Retornar descrição do turno
  FUNCTION fn_desc_turno (pr_cdturno  IN tbcadast_pessoa_renda.cdturno%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdturno IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdturno ||'-'||
           CADA0014.fn_desc_turno (pr_cdturno   => pr_cdturno,
                                   pr_dscritic  => vr_dscritic);

  END;
  
  --> Retornar descrição do nivel cargo
  FUNCTION fn_desc_nivel_cargo (pr_cdnivel_cargo  IN tbcadast_pessoa_renda.cdnivel_cargo%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdnivel_cargo IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdnivel_cargo ||'-'||
           CADA0014.fn_desc_nivel_cargo (pr_cdnivel_cargo   => pr_cdnivel_cargo,
                                         pr_dscritic        => vr_dscritic);

  END;

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
  
  --> Retornar descrição do tipo de renda
  FUNCTION fn_tprenda(pr_tpfixo_variavel tbcadast_pessoa_renda.tpfixo_variavel%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpfixo_variavel IS NULL THEN
      RETURN NULL;
    END IF;
    
    IF CADA0014.vr_tab_tpfixo_variavel.exists(pr_tpfixo_variavel) THEN
      RETURN pr_tpfixo_variavel ||'-'|| CADA0014.vr_tab_tpfixo_variavel(pr_tpfixo_variavel);
    ELSE
      RETURN pr_tpfixo_variavel ||'-'|| 'Outro';
    END IF;
  END;
  
  --> Retornar descrição do tipo de comprovante de renda
  FUNCTION fn_tpcomprov_renda(pr_tpcomprov_renda tbcadast_pessoa_renda.tpcomprov_renda%type) RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_tpcomprov_renda IS NULL THEN
      RETURN NULL;
    END IF;
        
    RETURN pr_tpcomprov_renda ||'-'||
           CADA0014.fn_desc_tpcomprov_renda (pr_tpcomprov_renda   => pr_tpcomprov_renda,
                                             pr_dscritic          => vr_dscritic);
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
    vr_nrsequen := :new.NRSEQ_RENDA;
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_nrsequen := :new.NRSEQ_RENDA;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_RENDA;
  END IF;

  vr_cdoperad := CADA0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                           pr_dscritic => vr_dscritic);
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    raise_application_error(-20100,vr_dscritic);
  END IF;

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            112	IDPESSOA
            113	NRSEQ_RENDA
            114	TPCONTRATO_TRABALHO
            115	CDTURNO
            116	CDNIVEL_CARGO
            117	DTADMISSAO
            118	CDOCUPACAO
            119	NRCADASTRO
            120	VLRENDA
            121	TPRENDA
            122	TPCOMPROV_RENDA
            123	IDPESSOA_FONTE_RENDA

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

    --> NRSEQ_RENDA
    IF nvl(:new.NRSEQ_RENDA,0) <> nvl(:OLD.NRSEQ_RENDA,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_RENDA',
                       pr_dsvalant => :old.NRSEQ_RENDA,
                       pr_dsvalnov => :new.NRSEQ_RENDA,
                       pr_dsvalor_novo_original => :new.NRSEQ_RENDA
                       );
    END IF;

    --> TPCONTRATO_TRABALHO
    IF nvl(:new.TPCONTRATO_TRABALHO,0) <> nvl(:OLD.TPCONTRATO_TRABALHO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPCONTRATO_TRABALHO',
                       pr_dsvalant => fn_tpcontrato_trabalho(:old.TPCONTRATO_TRABALHO),
                       pr_dsvalnov => fn_tpcontrato_trabalho(:new.TPCONTRATO_TRABALHO),
                       pr_dsvalor_novo_original => :new.TPCONTRATO_TRABALHO
                      );
    END IF;
    
    --> CDTURNO
    IF nvl(:new.CDTURNO,0) <> nvl(:OLD.CDTURNO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDTURNO',
                       pr_dsvalant => fn_desc_turno(:old.CDTURNO),
                       pr_dsvalnov => fn_desc_turno(:new.CDTURNO),
                       pr_dsvalor_novo_original => :new.CDTURNO
                      );
    END IF;

    --> CDNIVEL_CARGO
    IF nvl(:new.CDNIVEL_CARGO,0) <> nvl(:OLD.CDNIVEL_CARGO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDNIVEL_CARGO',
                       pr_dsvalant => fn_desc_nivel_cargo(:old.CDNIVEL_CARGO),
                       pr_dsvalnov => fn_desc_nivel_cargo(:new.CDNIVEL_CARGO),
                       pr_dsvalor_novo_original => :new.CDNIVEL_CARGO
                      );
    END IF;
    
    --> DTADMISSAO
    IF nvl(:new.DTADMISSAO,vr_data) <> nvl(:OLD.DTADMISSAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTADMISSAO',
                       pr_dsvalant => to_char(:old.DTADMISSAO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTADMISSAO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTADMISSAO,'DD/MM/RRRR')
                      );
    END IF;
    
    --> CDOCUPACAO
    IF nvl(:new.CDOCUPACAO,0) <> nvl(:OLD.CDOCUPACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDOCUPACAO',
                       pr_dsvalant => fn_cdocupacao(:old.CDOCUPACAO),
                       pr_dsvalnov => fn_cdocupacao(:new.CDOCUPACAO),
                       pr_dsvalor_novo_original => :new.CDOCUPACAO
                      );
    END IF;
    

    --> NRCADASTRO
    IF nvl(:new.NRCADASTRO,0) <> nvl(:OLD.NRCADASTRO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRCADASTRO',
                       pr_dsvalant => :old.NRCADASTRO,
                       pr_dsvalnov => :new.NRCADASTRO,
                       pr_dsvalor_novo_original => :new.NRCADASTRO
                      );
    END IF;

    --> VLRENDA
    IF nvl(:new.VLRENDA,0) <> nvl(:OLD.VLRENDA,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLRENDA',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLRENDA),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLRENDA),
                       pr_dsvalor_novo_original => :new.VLRENDA
                      );
    END IF;
    
    --> TPFIXO_VARIAVEL
    IF nvl(:new.tpfixo_variavel,0) <> nvl(:OLD.tpfixo_variavel,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPFIXO_VARIAVEL',
                       pr_dsvalant => fn_tprenda(:old.tpfixo_variavel),
                       pr_dsvalnov => fn_tprenda(:new.tpfixo_variavel),
                       pr_dsvalor_novo_original => :new.tpfixo_variavel
                      );
    END IF;
    
    --> TPCOMPROV_RENDA
    IF nvl(:new.TPCOMPROV_RENDA,0) <> nvl(:OLD.TPCOMPROV_RENDA,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPCOMPROV_RENDA',
                       pr_dsvalant => fn_tpcomprov_renda(:old.TPCOMPROV_RENDA),
                       pr_dsvalnov => fn_tpcomprov_renda(:new.TPCOMPROV_RENDA),
                       pr_dsvalor_novo_original => :new.TPCOMPROV_RENDA
                      );
    END IF;
    
    --> IDPESSOA_FONTE_RENDA
    IF nvl(:new.IDPESSOA_FONTE_RENDA,0) <> nvl(:OLD.IDPESSOA_FONTE_RENDA,0) THEN
      Insere_Historico(pr_nmdcampo => 'IDPESSOA_FONTE_RENDA',
                       pr_dsvalant => :old.IDPESSOA_FONTE_RENDA,
                       pr_dsvalnov => :new.IDPESSOA_FONTE_RENDA,
                       pr_dsvalor_novo_original => :new.IDPESSOA_FONTE_RENDA
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
      raise_application_error(-20100,'Erro TRG_TBCADAST_PESSOA_RENDA_HST: '||SQLERRM);
END TRG_TBCADAST_PESSOA_RENDA_HST;
/
