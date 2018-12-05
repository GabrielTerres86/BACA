CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PESSOA_JUR_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PESSOA_JUR_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA';
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

  --> Retornar descrição cnae
  FUNCTION fn_desc_cnae(pr_cdcnae  IN tbcadast_pessoa_juridica.cdcnae%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdcnae IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdcnae ||'-'||
           CADA0014.fn_desc_cnae (pr_cdcnae    => pr_cdcnae,
                                  pr_dscritic  => vr_dscritic);

  END;

  --> Retornar descrição da natureza_juridica
  FUNCTION fn_desc_natureza_juridica (pr_cdnatjur  IN tbcadast_pessoa_juridica.cdnatureza_juridica%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
  
    IF pr_cdnatjur IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cdnatjur ||'-'||
           CADA0014.fn_desc_natureza_juridica (pr_cdnatjur  => pr_cdnatjur,
                                               pr_dscritic  => vr_dscritic);

  END;

  --> Retornar descrição do setor_economico
  FUNCTION fn_desc_setor_economico (pr_cdseteco  IN tbcadast_pessoa_juridica.cdsetor_economico%TYPE)
              RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdseteco IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdseteco ||'-'||
           CADA0014.fn_desc_setor_economico (pr_cdseteco  => pr_cdseteco,
                                             pr_dscritic  => vr_dscritic);

  END;

  --> Retornar descrição do tipo de regime de tributacao
  FUNCTION fn_desc_tpregime_tributacao (pr_tpregime_tributacao  IN tbcadast_pessoa_juridica.tpregime_tributacao%TYPE)
           RETURN VARCHAR2 IS
  BEGIN
    IF pr_tpregime_tributacao IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_tpregime_tributacao ||'-'||
           CADA0014.fn_desc_tpregime_tributacao (pr_tpregime_tributacao  => pr_tpregime_tributacao,
                                                 pr_dscritic  => vr_dscritic);
  END;
  
  --> Retornar descrição do ramo atividade
  FUNCTION fn_desc_ramo_atividade (pr_cdrmativ  IN tbcadast_pessoa_juridica.cdramo_atividade%TYPE)
           RETURN VARCHAR2 IS
  BEGIN
    IF pr_cdrmativ IS NULL THEN
      RETURN NULL;
    END IF;
  
    RETURN pr_cdrmativ ||'-'||
           CADA0014.fn_desc_ramo_atividade (pr_cdrmativ  => pr_cdrmativ,
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


  --> Grava a tabela historico
  PROCEDURE Insere_Historico(pr_nmdcampo IN VARCHAR2,
                             pr_dsvalant IN tbcadast_pessoa_historico.dsvalor_anterior%TYPE,
                             pr_dsvalnov IN tbcadast_pessoa_historico.dsvalor_novo%TYPE,
                             pr_dsvalor_novo_original IN tbcadast_pessoa_historico.dsvalor_novo_original%TYPE
                            ) IS
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
                         ,pr_dsvalor_novo_original => pr_dsvalor_novo_original --> Valor Original sem descrição
                         ,pr_cdoperad    => vr_cdoperad   --> Valor novo
                         ,pr_dscritic    => vr_dscritic
                        );  --> Retornar Critica

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
            58	IDPESSOA
            59	CDCNAE
            60	NMFANTASIA
            61	NRINSCRICAO_ESTADUAL
            62	CDNATUREZA_JURIDICA
            63	DTCONSTITUICAO
            64	DTINICIO_ATIVIDADE
            65	QTFILIAL
            66	QTFUNCIONARIO
            67	VLCAPITAL
            68	DTREGISTRO
            69	NRREGISTRO
            70	DSORGAO_REGISTRO
            71	DTINSCRICAO_MUNICIPAL
            72	NRNIRE
            73	INREFIS
            74	DSSITE
            75	NRINSCRICAO_MUNICIPAL
            76	CDSETOR_ECONOMICO
            77	VLFATURAMENTO_ANUAL
            78	CDRAMO_ATIVIDADE
            79	NRLICENCA_AMBIENTAL
            80	DTVALIDADE_LICENCA_AMB
            81	PEUNICO_CLIENTE
            82	CDEMPRESA
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

    --> CDCNAE
    IF nvl(:new.CDCNAE,0) <> nvl(:OLD.CDCNAE,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDCNAE',
                       pr_dsvalant => fn_desc_cnae(:old.CDCNAE),
                       pr_dsvalnov => fn_desc_cnae(:new.CDCNAE),
                       pr_dsvalor_novo_original => :new.CDCNAE
                      );
    END IF;

    --> NMFANTASIA
    IF nvl(:new.NMFANTASIA,' ') <> nvl(:OLD.NMFANTASIA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'NMFANTASIA',
                       pr_dsvalant => :old.NMFANTASIA,
                       pr_dsvalnov => :new.NMFANTASIA,
                       pr_dsvalor_novo_original => :new.NMFANTASIA
                      );
    END IF;

    --> NRINSCRICAO_ESTADUAL
    IF nvl(:new.NRINSCRICAO_ESTADUAL,0) <> nvl(:OLD.NRINSCRICAO_ESTADUAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRINSCRICAO_ESTADUAL',
                       pr_dsvalant => :old.NRINSCRICAO_ESTADUAL,
                       pr_dsvalnov => :new.NRINSCRICAO_ESTADUAL,
                       pr_dsvalor_novo_original => :new.NRINSCRICAO_ESTADUAL
                      );
    END IF;

    --> CDNATUREZA_JURIDICA
    IF nvl(:new.CDNATUREZA_JURIDICA,0) <> nvl(:OLD.CDNATUREZA_JURIDICA,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDNATUREZA_JURIDICA',
                       pr_dsvalant => fn_desc_natureza_juridica(:old.CDNATUREZA_JURIDICA),
                       pr_dsvalnov => fn_desc_natureza_juridica(:new.CDNATUREZA_JURIDICA),
                       pr_dsvalor_novo_original => :new.CDNATUREZA_JURIDICA
                      );
    END IF;
    
    --> DTCONSTITUICAO
    IF nvl(:new.DTCONSTITUICAO,vr_data) <> nvl(:OLD.DTCONSTITUICAO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTCONSTITUICAO',
                       pr_dsvalant => to_char(:old.DTCONSTITUICAO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTCONSTITUICAO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTCONSTITUICAO,'DD/MM/RRRR')
                      );
    END IF;

    --> DTINICIO_ATIVIDADE
    IF nvl(:new.DTINICIO_ATIVIDADE,vr_data) <> nvl(:OLD.DTINICIO_ATIVIDADE,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTINICIO_ATIVIDADE',
                       pr_dsvalant => to_char(:old.DTINICIO_ATIVIDADE,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTINICIO_ATIVIDADE,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTINICIO_ATIVIDADE,'DD/MM/RRRR')
                      );
    END IF;

    --> QTFILIAL
    IF nvl(:new.QTFILIAL,0) <> nvl(:OLD.QTFILIAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'QTFILIAL',
                       pr_dsvalant => :old.QTFILIAL,
                       pr_dsvalnov => :new.QTFILIAL,
                       pr_dsvalor_novo_original => :new.QTFILIAL                       
                      );
    END IF;
    
    --> QTFUNCIONARIO
    IF nvl(:new.QTFUNCIONARIO,0) <> nvl(:OLD.QTFUNCIONARIO,0) THEN
      Insere_Historico(pr_nmdcampo => 'QTFUNCIONARIO',
                       pr_dsvalant => :old.QTFUNCIONARIO,
                       pr_dsvalnov => :new.QTFUNCIONARIO,
                       pr_dsvalor_novo_original => :new.QTFUNCIONARIO                       
                      );
    END IF;
    
    --> VLCAPITAL
    IF nvl(:new.VLCAPITAL,0) <> nvl(:OLD.VLCAPITAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLCAPITAL',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLCAPITAL),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLCAPITAL),
                       pr_dsvalor_novo_original => :new.VLCAPITAL                       
                      );
    END IF;
    
    --> DTREGISTRO
    IF nvl(:new.DTREGISTRO,vr_data) <> nvl(:OLD.DTREGISTRO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTREGISTRO',
                       pr_dsvalant => to_char(:old.DTREGISTRO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTREGISTRO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTREGISTRO,'DD/MM/RRRR')                     
                      );
    END IF;

    --> NRREGISTRO
    IF nvl(:new.NRREGISTRO,0) <> nvl(:OLD.NRREGISTRO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRREGISTRO',
                       pr_dsvalant => :old.NRREGISTRO,
                       pr_dsvalnov => :new.NRREGISTRO,
                       pr_dsvalor_novo_original => :new.NRREGISTRO                     
                      );
    END IF;
    
    --> DSORGAO_REGISTRO
    IF nvl(:new.DSORGAO_REGISTRO,' ') <> nvl(:OLD.DSORGAO_REGISTRO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSORGAO_REGISTRO',
                       pr_dsvalant => (:old.DSORGAO_REGISTRO),
                       pr_dsvalnov => (:new.DSORGAO_REGISTRO),
                       pr_dsvalor_novo_original => :new.DSORGAO_REGISTRO                     
                      );
    END IF;    

    --> DTINSCRICAO_MUNICIPAL
    IF nvl(:new.DTINSCRICAO_MUNICIPAL,vr_data) <> nvl(:OLD.DTINSCRICAO_MUNICIPAL,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTINSCRICAO_MUNICIPAL',
                       pr_dsvalant => to_char(:old.DTINSCRICAO_MUNICIPAL,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTINSCRICAO_MUNICIPAL,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTINSCRICAO_MUNICIPAL,'DD/MM/RRRR')                     
                      );
    END IF;

    --> NRNIRE
    IF nvl(:new.NRNIRE,0) <> nvl(:OLD.NRNIRE,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRNIRE',
                       pr_dsvalant => :old.NRNIRE,
                       pr_dsvalnov => :new.NRNIRE,
                       pr_dsvalor_novo_original => :new.NRNIRE                     
                      );
    END IF;

    --> INREFIS
    IF nvl(:new.INREFIS,0) <> nvl(:OLD.INREFIS,0) THEN
      Insere_Historico(pr_nmdcampo => 'INREFIS',
                       pr_dsvalant => (:old.INREFIS),
                       pr_dsvalnov => (:new.INREFIS),
                       pr_dsvalor_novo_original => :new.INREFIS                     
                      );
    END IF;

    --> DSSITE
    IF nvl(:new.DSSITE,' ') <> nvl(:OLD.DSSITE,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSSITE',
                       pr_dsvalant => :old.DSSITE,
                       pr_dsvalnov => :new.DSSITE,
                       pr_dsvalor_novo_original => :new.DSSITE                     
                      );
    END IF;    

    --> NRINSCRICAO_MUNICIPAL
    IF nvl(:new.NRINSCRICAO_MUNICIPAL,0) <> nvl(:OLD.NRINSCRICAO_MUNICIPAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRINSCRICAO_MUNICIPAL',
                       pr_dsvalant => :old.NRINSCRICAO_MUNICIPAL,
                       pr_dsvalnov => :new.NRINSCRICAO_MUNICIPAL,
                       pr_dsvalor_novo_original => :new.NRINSCRICAO_MUNICIPAL                     
                      );
    END IF;

    --> CDSETOR_ECONOMICO
    IF nvl(:new.CDSETOR_ECONOMICO,0) <> nvl(:OLD.CDSETOR_ECONOMICO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDSETOR_ECONOMICO',
                       pr_dsvalant => fn_desc_setor_economico(:old.CDSETOR_ECONOMICO),
                       pr_dsvalnov => fn_desc_setor_economico(:new.CDSETOR_ECONOMICO),
                       pr_dsvalor_novo_original => :new.CDSETOR_ECONOMICO                     
                      );
    END IF;

    --> VLFATURAMENTO_ANUAL
    IF nvl(:new.VLFATURAMENTO_ANUAL,0) <> nvl(:OLD.VLFATURAMENTO_ANUAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLFATURAMENTO_ANUAL',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.VLFATURAMENTO_ANUAL),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.VLFATURAMENTO_ANUAL),
                       pr_dsvalor_novo_original => :new.VLFATURAMENTO_ANUAL                    
                      );
    END IF;
    
    --> CDRAMO_ATIVIDADE
    IF nvl(:new.CDRAMO_ATIVIDADE,0) <> nvl(:OLD.CDRAMO_ATIVIDADE,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDRAMO_ATIVIDADE',
                       pr_dsvalant => fn_desc_ramo_atividade(:old.CDRAMO_ATIVIDADE),
                       pr_dsvalnov => fn_desc_ramo_atividade(:new.CDRAMO_ATIVIDADE),
                       pr_dsvalor_novo_original => :new.CDRAMO_ATIVIDADE                    
                      );
    END IF;
    
    --> NRLICENCA_AMBIENTAL
    IF nvl(:new.NRLICENCA_AMBIENTAL,0) <> nvl(:OLD.NRLICENCA_AMBIENTAL,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRLICENCA_AMBIENTAL',
                       pr_dsvalant => :old.NRLICENCA_AMBIENTAL,
                       pr_dsvalnov => :new.NRLICENCA_AMBIENTAL,
                       pr_dsvalor_novo_original => :new.NRLICENCA_AMBIENTAL                    
                      );
    END IF;
    
    --> DTVALIDADE_LICENCA_AMB
    IF nvl(:new.DTVALIDADE_LICENCA_AMB,vr_data) <> nvl(:OLD.DTVALIDADE_LICENCA_AMB,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTVALIDADE_LICENCA_AMB',
                       pr_dsvalant => to_char(:old.DTVALIDADE_LICENCA_AMB,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTVALIDADE_LICENCA_AMB,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTVALIDADE_LICENCA_AMB,'DD/MM/RRRR')                    
                      );
    END IF;
    
    --> TPREGIME_TRIBUTACAO
    IF nvl(:new.TPREGIME_TRIBUTACAO,0) <> nvl(:OLD.TPREGIME_TRIBUTACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'TPREGIME_TRIBUTACAO',
                       pr_dsvalant => fn_desc_tpregime_tributacao(:old.TPREGIME_TRIBUTACAO),
                       pr_dsvalnov => fn_desc_tpregime_tributacao(:new.TPREGIME_TRIBUTACAO),
                       pr_dsvalor_novo_original => :new.TPREGIME_TRIBUTACAO                    
                      );
    END IF;
    
    --> PEUNICO_CLIENTE
    IF nvl(:new.PEUNICO_CLIENTE,0) <> nvl(:OLD.PEUNICO_CLIENTE,0) THEN
      Insere_Historico(pr_nmdcampo => 'PEUNICO_CLIENTE',
                       pr_dsvalant => CADA0014.fn_formata_valor(:old.PEUNICO_CLIENTE),
                       pr_dsvalnov => CADA0014.fn_formata_valor(:new.PEUNICO_CLIENTE),
                       pr_dsvalor_novo_original => :new.PEUNICO_CLIENTE                    
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
      raise_application_error(-20100,'Erro TRG_TBCADAST_PESSOA_JUR_HST: '||SQLERRM);
END TRG_TBCADAST_PESSOA_JUR_HST;
/
