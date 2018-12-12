CREATE OR REPLACE TRIGGER CECRED.TRG_TBCADAST_PJ_BCO_HST
  AFTER INSERT OR UPDATE OR DELETE ON TBCADAST_PESSOA_JURIDICA_BCO
  FOR EACH ROW
  /* ..........................................................................

     Programa : TRG_TBCADAST_PJ_BCO_HST
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

  vr_nmdatela   CONSTANT VARCHAR2(50) := 'TBCADAST_PESSOA_JURIDICA_BCO';
  vr_dhaltera   CONSTANT DATE := SYSDATE;
  vr_data       DATE := to_date('01/01/1500','DD/MM/RRRR');
  vr_tab_campos CADA0014.typ_tab_campos_hist;
  vr_idpessoa   tbcadast_pessoa_historico.idpessoa%TYPE;
  vr_nrsequen   tbcadast_pessoa_historico.nrsequencia%TYPE;
  vr_tpoperac   tbcadast_pessoa_historico.tpoperacao%TYPE;
  vr_cdoperad   tbcadast_pessoa_historico.cdoperad_altera%TYPE;

  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(2000);
  -- Variável indicando que esta dentro da funçao insere_historico
  vr_flginsere_historico   boolean :=FALSE;
  

  --> Retornar descrição do relacionamento
  FUNCTION fn_desc_relacionamento (pr_cdrelacionamento  IN tbcadast_relacion_resp_legal.cdrelacionamento%TYPE) 
           RETURN VARCHAR2 IS
  BEGIN
    
    IF pr_cdrelacionamento IS NULL THEN
      RETURN NULL;
    END IF;
    
    RETURN pr_cdrelacionamento ||'-'||
           CADA0014.fn_desc_relacionamento (pr_cdrelacionamento  => pr_cdrelacionamento,
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
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := :new.NRSEQ_BANCO;    
  ELSIF UPDATING THEN
    vr_tpoperac := 2; --UPDATE
    vr_idpessoa := :new.IDPESSOA;
    vr_cdoperad := :new.CDOPERAD_ALTERA;
    vr_nrsequen := :new.NRSEQ_BANCO;
  ELSIF DELETING THEN
    vr_tpoperac := 3; --DELETE
    vr_idpessoa := :old.IDPESSOA;
    vr_nrsequen := :old.NRSEQ_BANCO;
    
    vr_cdoperad := cada0014.fn_cdoperad_alt( pr_idpessoa => vr_idpessoa,
                                             pr_dscritic => vr_dscritic);
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20100,vr_dscritic);
    END IF;    
  END IF;  
  

  /**************************************
   ****** TBCADAST_CAMPO_HISTORICO ******
            152	IDPESSOA
            153	NRSEQ_BANCO
            154	CDBANCO
            155	DSOPERACAO
            156	VLOPERACAO
            157	DSGARANTIA
            158	DTVENCIMENTO
            159	CDOPERAD_ALTERA
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

    --> NRSEQ_BANCO
    IF nvl(:new.NRSEQ_BANCO,0) <> nvl(:OLD.NRSEQ_BANCO,0) THEN
      Insere_Historico(pr_nmdcampo => 'NRSEQ_BANCO',
                       pr_dsvalant => :old.NRSEQ_BANCO,
                       pr_dsvalnov => :new.NRSEQ_BANCO,
                       pr_dsvalor_novo_original => :new.NRSEQ_BANCO
                      );
    END IF;
    
    --> CDBANCO
    IF nvl(:new.CDBANCO,0) <> nvl(:OLD.CDBANCO,0) THEN
      Insere_Historico(pr_nmdcampo => 'CDBANCO',
                       pr_dsvalant => :old.CDBANCO,
                       pr_dsvalnov => :new.CDBANCO,
                       pr_dsvalor_novo_original => :new.CDBANCO
                      );
    END IF;
  
    --> DSOPERACAO
    IF nvl(:new.DSOPERACAO,' ') <> nvl(:OLD.DSOPERACAO,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSOPERACAO',
                       pr_dsvalant => :old.DSOPERACAO,
                       pr_dsvalnov => :new.DSOPERACAO,
                       pr_dsvalor_novo_original => :new.DSOPERACAO                       
                      );
    END IF;
    
    --> VLOPERACAO
    IF nvl(:new.VLOPERACAO,0) <> nvl(:OLD.VLOPERACAO,0) THEN
      Insere_Historico(pr_nmdcampo => 'VLOPERACAO',
                       pr_dsvalant => cada0014.fn_formata_valor(:old.VLOPERACAO),
                       pr_dsvalnov => cada0014.fn_formata_valor(:new.VLOPERACAO),
                       pr_dsvalor_novo_original => :new.VLOPERACAO                      
                      );
    END IF;

    --> DSGARANTIA
    IF nvl(:new.DSGARANTIA,' ') <> nvl(:OLD.DSGARANTIA,' ') THEN
      Insere_Historico(pr_nmdcampo => 'DSGARANTIA',
                       pr_dsvalant => :old.DSGARANTIA,
                       pr_dsvalnov => :new.DSGARANTIA,
                       pr_dsvalor_novo_original => :new.DSGARANTIA                      
                      );
    END IF;             
    
    --> DTVENCIMENTO
    IF nvl(:new.DTVENCIMENTO,vr_data) <> nvl(:OLD.DTVENCIMENTO,vr_data) THEN
      Insere_Historico(pr_nmdcampo => 'DTVENCIMENTO',
                       pr_dsvalant => to_char(:old.DTVENCIMENTO,'DD/MM/RRRR'),
                       pr_dsvalnov => to_char(:new.DTVENCIMENTO,'DD/MM/RRRR'),
                       pr_dsvalor_novo_original => to_char(:new.DTVENCIMENTO,'DD/MM/RRRR')                     
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
      raise_application_error(-20100,'Erro TRG_TBCADAST_PJ_BCO_HST: '||SQLERRM);

END TRG_TBCADAST_PJ_BCO_HST;
/
