CREATE OR REPLACE PACKAGE CECRED.CADA0010 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0010
  --  Sistema  : Rotinas para cadastros de Pessoas
  --  Sigla    : CADA
  --  Autor    : Andrino Carlos de Souza Junior (Mouts)
  --  Data     : Julho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: OnLine
  -- Objetivo  : 
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Tipo de registro de relacao de pessoa com outras pessoas
  /* TpRelacao ==> 1-Conjuge
                   2-Empresa de trabalho do conjuge
                   3-Pai
                   4-Mae
                   5-Empresa de trabalho
                   10-Pessoa de referencia (contato)
                   20-Representante de uma PJ
                   23-Pai do Representante 
                   24-Mae do Representante 
                   30-Responsavel Legal
                   33-Pai do Responsavel Legal
                   34-Mae do Responsavel Legal
                   40-Dependente
                   50-Pessoa politicamente Exposta
                   51-Empresa do Politico Exposto
                   60-Empresa de Participacao (PJ)


  Ex.: Se for passado um CNPJ e vier tipo de relacao 2(empresa do conjuge),
       no ID_PESSOA vira a pessoa do conjuge (CRAPCJE) e no ID_PESSOA_PRINCIPAL vira o titular (CRAPASS)
                   
  */                   
  TYPE typ_reg_relacao IS
      RECORD (idpessoa           tbcadast_pessoa.idpessoa%TYPE, -- Pessoa na qual a pessoa solicitada possui relacao
              tprelacao          NUMBER(02),   -- Tipo de relacao
              idpessoa_principal tbcadast_pessoa.idpessoa%TYPE); -- Pessoa principal do cadastro 
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_relacao IS
    TABLE OF typ_reg_relacao
    INDEX BY BINARY_INTEGER;
  /* Vetor com as informacoes de faixas*/
  vr_relacao typ_tab_relacao;



  /* Para contas
     TpRelacao ==> 1-Conjuge (crapcje)
                   2-Empresa de trabalho do conjuge (crapcje)
                   3-Pai (crapttl)
                   4-Mae (crapttl)
                   5-Empresa de trabalho (crapttl)
                   6-Titular (crapttl)
                   7-Titular (crapjur)
                   10-Pessoa de referencia (contato) (crapavt onde tpctato = 5)
                   20-Representante de uma PJ (crapavt onde tpctato = 6)
                   23-Pai do Representante (crapavt onde tpctato = 6)
                   24-Mae do Representante (crapavt onde tpctato = 6)
                   30-Responsavel Legal (crapcrl)
                   33-Pai do Responsavel Legal (crapcrl)
                   34-Mae do Responsavel Legal (crapcrl)
                   40-Dependente (crapdep)
                   50-Pessoa politicamente Exposta (tbcadast_politico_exposto)
                   51-Empresa do Politico Exposto (tbcadast_politico_exposto)
                   60-Empresa de Participacao (PJ) (crapepa)
  */

  -- Tipo com o relacionamento das contas
  TYPE typ_reg_conta IS
      RECORD (cdcooper crapass.cdcooper%TYPE,
              nrdconta crapass.nrdconta%TYPE,
              idseqttl crapttl.idseqttl%TYPE,
              idpessoa tbcadast_pessoa.idpessoa%TYPE,
              tprelacao          NUMBER(02));
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_conta IS
    TABLE OF typ_reg_conta
    INDEX BY BINARY_INTEGER;
  /* Vetor com as informacoes de faixas*/
  vr_conta typ_tab_conta;

  -- Rotina para cadastro de pessoa fisica
  PROCEDURE pc_cadast_pessoa_fisica(pr_pessoa_fisica IN OUT vwcadast_pessoa_fisica%ROWTYPE -- Registro de pessoa fisica
                                   ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                   ,pr_dscritic OUT VARCHAR2);               -- Retorno de Erro
    
  -- Rotina para cadastro de pessoa juridica
  PROCEDURE pc_cadast_pessoa_juridica(pr_pessoa_juridica IN OUT vwcadast_pessoa_juridica%ROWTYPE -- Registro de pessoa juridica
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2);                          -- Retorno de Erro

  -- Rotina para cadastrar email
  PROCEDURE pc_cadast_pessoa_email(pr_pessoa_email IN OUT tbcadast_pessoa_email%ROWTYPE -- Registro de email
                                   ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                   ,pr_dscritic OUT VARCHAR2);               -- Retorno de Erro
    
  -- Rotina para excluir email
  PROCEDURE pc_exclui_pessoa_email(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_nrseq_email     IN tbcadast_pessoa_email.nrseq_email%TYPE
                                  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic       OUT INTEGER                      -- Codigo de erro
                                  ,pr_dscritic       OUT VARCHAR2);                 -- Retorno de Erro

  -- Rotina para cadastro de renda da pessoa fisica
  PROCEDURE pc_cadast_pessoa_renda(pr_pessoa_renda IN OUT tbcadast_pessoa_renda%ROWTYPE -- Registro de renda
                                  ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2);               -- Retorno de Erro
																	
  -- Rotina para excluir renda da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE          -- Identificador de pessoa
		                              ,pr_nrseq_renda     IN tbcadast_pessoa_renda.nrseq_renda%TYPE -- Nr. de sequência de renda
                                  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE   -- Operador que esta efetuando a exclusao																	
                                  ,pr_cdcritic        OUT INTEGER                               -- Codigo de erro
                                  ,pr_dscritic        OUT VARCHAR2);                            -- Retorno de Erro

  -- Rotina para cadastro de renda complementar da pessoa fisica
  PROCEDURE pc_cadast_pessoa_renda_compl(pr_pessoa_renda_compl IN OUT tbcadast_pessoa_rendacompl%ROWTYPE -- Registro de renda complementar da pessoa fisica
                                        ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                        ,pr_dscritic OUT VARCHAR2);               -- Retorno de Erro

  -- Rotina para excluir renda complementar da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda_compl(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE               -- Identificador de pessoa
		                                    ,pr_nrseq_renda     IN tbcadast_pessoa_rendacompl.nrseq_renda%TYPE -- Nr. de sequência de renda complementar
                                        ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE        -- Operador que esta efetuando a exclusao																	
                                        ,pr_cdcritic        OUT INTEGER                                    -- Codigo de erro
                                        ,pr_dscritic        OUT VARCHAR2);                                 -- Retorno de Erro

  -- Rotina para cadastro de telefones
  PROCEDURE pc_cadast_pessoa_telefone(pr_pessoa_telefone IN OUT tbcadast_pessoa_telefone%ROWTYPE -- Registro de telefone
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2);                          -- Retorno de Erro
																		 
  -- Rotina para excluir telefone
  PROCEDURE pc_exclui_pessoa_telefone(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE                -- Identificador de pessoa
																		 ,pr_nrseq_telefone  IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE -- Nr. de sequência de telefone
																		 ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE         -- Operador que esta efetuando a exclusao																	
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2);                                  -- Retorno de Erro																		 

  -- Rotina para cadastro de enderecos
  PROCEDURE pc_cadast_pessoa_endereco(pr_pessoa_endereco IN OUT tbcadast_pessoa_endereco%ROWTYPE -- Registro de endereco
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2);                          -- Retorno de Erro

  -- Rotina para excluir endereço    
  PROCEDURE pc_exclui_pessoa_endereco(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE                -- Identificador de pessoa
																		 ,pr_nrseq_endereco  IN tbcadast_pessoa_endereco.nrseq_endereco%TYPE -- Nr. de sequência de endereço
																		 ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE         -- Operador que esta efetuando a exclusao																	
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2);                                  -- Retorno de Erro	
	
  -- Rotina para cadastro de bens
  PROCEDURE pc_cadast_pessoa_bem(pr_pessoa_bem IN OUT tbcadast_pessoa_bem%ROWTYPE -- Registro de bens
                                ,pr_cdcritic OUT INTEGER                   -- Codigo de erro
                                ,pr_dscritic OUT VARCHAR2);                -- Retorno de Erro

  -- Rotina para excluir bem
  PROCEDURE pc_exclui_pessoa_bem(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE        -- Identificador de pessoa
															  ,pr_nrseq_bem       IN tbcadast_pessoa_bem.nrseq_bem%TYPE   -- Nr. de sequência de bem
															  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE -- Operador que esta efetuando a exclusao																	
															  ,pr_cdcritic        OUT INTEGER                             -- Codigo de erro
															  ,pr_dscritic        OUT VARCHAR2);                          -- Retorno de Erro

  -- Rotina para cadastro de relacionamentos da pessoa
  PROCEDURE pc_cadast_pessoa_relacao(pr_pessoa_relacao IN OUT tbcadast_pessoa_relacao%ROWTYPE -- Registro de pessoas de relacao
                                    ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                    ,pr_dscritic          OUT VARCHAR2);                -- Retorno de Erro

  -- Rotina para excluir relacionamento
  PROCEDURE pc_exclui_pessoa_relacao(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
															      ,pr_nrseq_relacao   IN tbcadast_pessoa_relacao.nrseq_relacao%TYPE -- Nr. de sequência de relacionamento
																		,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
																		,pr_cdcritic        OUT INTEGER                                   -- Codigo de erro
																		,pr_dscritic        OUT VARCHAR2);                                -- Retorno de Erro

  -- Rotina para Cadastro de pessoa dependente
  PROCEDURE pc_cadast_pessoa_fisica_dep( pr_pessoa_fisica_dep IN OUT tbcadast_pessoa_fisica_dep%ROWTYPE -- Registro de pessoa dependente
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2);                -- Retorno de Erro

  -- Rotina para excluir Cadastro de pessoa dependente
  PROCEDURE pc_exclui_pessoa_fisica_dep( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                        ,pr_nrseq_dependente  IN tbcadast_pessoa_fisica_dep.nrseq_dependente%TYPE -- Nr. de sequência de relacionamento
                                        ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                        ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2);                                -- Retorno de Erro

  -- Rotina para Cadastrar de resposansavel legal de pessoa de fisica
  PROCEDURE pc_cadast_pessoa_fisica_resp(pr_pessoa_fisica_resp IN OUT tbcadast_pessoa_fisica_resp%ROWTYPE -- Registro de pessoa dependente
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para excluir Cadastro de resposansavel legal de pessoa de fisica
  PROCEDURE pc_exclui_pessoa_fisica_resp( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                         ,pr_nrseq_resp_legal  IN tbcadast_pessoa_fisica_resp.nrseq_resp_legal%TYPE -- Nr. de sequência de relacionamento
                                         ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                         ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para Cadastrar de pessoa de referencia
  PROCEDURE pc_cadast_pessoa_referencia (pr_pessoa_referencia IN OUT tbcadast_pessoa_referencia%ROWTYPE -- Registro de pessoa referencia
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para excluir Cadastro de pessoa de referencia
  PROCEDURE pc_exclui_pessoa_referencia ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                         ,pr_nrseq_referencia  IN tbcadast_pessoa_referencia.nrseq_referencia%TYPE -- Nr. de sequência de relacionamento
                                         ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                         ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_cadast_pessoa_juridica_bco( pr_pessoa_juridica_bco IN OUT tbcadast_pessoa_juridica_bco%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para  excluir Cadastro dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_exclui_pessoa_juridica_bco ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_banco       IN tbcadast_pessoa_juridica_bco.nrseq_banco%TYPE -- Nr. de sequência de banco
                                           ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic         OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para Cadastrar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_cadast_pessoa_juridica_fat( pr_pessoa_juridica_fat IN OUT tbcadast_pessoa_juridica_fat%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para excluir faturamento mensal de Pessoas Juridica
  PROCEDURE pc_exclui_pessoa_juridica_fat ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_faturamento IN tbcadast_pessoa_juridica_fat.nrseq_faturamento%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic         OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para Cadastrar participacao societaria em outras empresas
  PROCEDURE pc_cadast_pessoa_juridica_ptp( pr_pessoa_juridica_ptp IN OUT tbcadast_pessoa_juridica_ptp%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para excluir participacao societaria em outras empresas
  PROCEDURE pc_exclui_pessoa_juridica_ptp ( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_participacao IN tbcadast_pessoa_juridica_ptp.nrseq_participacao%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera    IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic          OUT VARCHAR2);                             -- Retorno de Erro

  -- Rotina para Cadastrar representantes da pessoa juridica.
  PROCEDURE pc_cadast_pessoa_juridica_rep( pr_pessoa_juridica_rep IN OUT tbcadast_pessoa_juridica_rep%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2);             -- Retorno de Erro

  -- Rotina para excluir representantes da pessoa juridica.
  PROCEDURE pc_exclui_pessoa_juridica_rep ( pr_idpessoa            IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_representante IN tbcadast_pessoa_juridica_rep.nrseq_representante%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera     IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic          OUT VARCHAR2);                             -- Retorno de Erro
  
  -- Rotina para Cadastrar pessoas politicamente expostas.
  PROCEDURE pc_cadast_pessoa_polexp( pr_pessoa_polexp IN OUT tbcadast_pessoa_polexp%ROWTYPE -- Registros de pessoa
                                    ,pr_cdcritic         OUT INTEGER                        -- Codigo de erro
                                    ,pr_dscritic         OUT VARCHAR2);                     -- Retorno de Erro
                                    
  -- Rotina para excluir pessoas politicamente expostas.
  PROCEDURE pc_exclui_pessoa_polexp ( pr_idpessoa            IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa                                     
                                     ,pr_cdoperad_altera     IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                     ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                     ,pr_dscritic          OUT VARCHAR2);

  -- Rotina para incluir registro que o cadastro de pessoa foi atualizado no sistema legado
  PROCEDURE pc_cadast_pessoa_atualiza( pr_cdcooper   IN tbcadast_pessoa_atualiza.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta   IN tbcadast_pessoa_atualiza.nrdconta%TYPE --> Numero da conta
                                      ,pr_idseqttl   IN tbcadast_pessoa_atualiza.idseqttl%TYPE --> Sequencial do titular
                                      ,pr_nmtabela   IN tbcadast_pessoa_atualiza.nmtabela%TYPE --> Nome da tabela alteradoa
                                      ,pr_dschave    IN tbcadast_pessoa_atualiza.dschave%TYPE DEFAULT NULL  --> Dados que compoem a chave da tabela   
                                      ,pr_cdcritic  OUT INTEGER                                --> Codigo de erro
                                      ,pr_dscritic  OUT VARCHAR2);                                     
                                      
  -- Rotina para buscar a relacao da pessoa com demais pessoas
  PROCEDURE pc_busca_relacao_pessoa(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                                    pr_relacao  OUT vr_relacao%TYPE,
                                    pr_dscritic OUT VARCHAR2);
                                        
  -- Rotina para buscar a relacao da pessoa com demais pessoas
  PROCEDURE pc_busca_relacao_conta(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                                   pr_conta    OUT vr_conta%TYPE,
                                   pr_dscritic OUT VARCHAR2);

  -- Rotina para cadastrar aprovação de saque de cotas.
  PROCEDURE pc_cadast_aprov_saque_cotas( pr_tbcotas_saque_controle IN OUT tbcotas_saque_controle%ROWTYPE -- Registros de cotas aprovadas saque
                                        ,pr_cdcritic         OUT INTEGER                        -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2);                                   
                                      
  PROCEDURE pc_revalida_nome_cad_unc(pr_nrcpfcgc  IN tbcadast_pessoa.nrcpfcgc%TYPE --Numero do CPF/CNPJ
                                    ,pr_nmpessoa  IN tbcadast_pessoa.nmpessoa%TYPE --Nome da pessoa entrada 
                                    ,pr_nmpesout OUT tbcadast_pessoa.nmpessoa%TYPE --Nome da pessoa saida
                                    ,pr_cdcritic OUT INTEGER                       -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2); 
                                    
  PROCEDURE pc_revalida_cnpj_cad_unc(pr_cdcooper  IN crapcop.cdcooper%TYPE         --Cooperativa
                                    ,pr_cdempres  IN crapemp.cdempres%TYPE         --Codigo da empresa
                                    ,pr_nrdocnpj  IN tbcadast_pessoa.nrcpfcgc%TYPE --CNPJ
                                    ,pr_nrcnpjot OUT tbcadast_pessoa.nrcpfcgc%TYPE --CNPJ saida
                                    ,pr_cdcritic OUT INTEGER                       -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2);                                                                          

END CADA0010;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0010 IS

  --> Verificar pessoa
  CURSOR cr_pessoa (pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT pes.idpessoa,
           pes.tppessoa
      FROM tbcadast_pessoa pes
     WHERE pes.nrcpfcgc = pr_nrcpfcgc;
  rw_pessoa cr_pessoa%ROWTYPE;


  -- Rotina para cadastro de pessoa fisica
  PROCEDURE pc_cadast_pessoa_fisica(pr_pessoa_fisica IN OUT vwcadast_pessoa_fisica%ROWTYPE -- Registro de pessoa fisica
                                   ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                   ,pr_dscritic OUT VARCHAR2) IS             -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    rw_pessoa cr_pessoa%ROWTYPE;

  BEGIN
    -- Insere a tabela principal de pessoa
    BEGIN
      INSERT INTO tbcadast_pessoa
        (idpessoa,
         nrcpfcgc, 
         nmpessoa, 
         nmpessoa_receita, 
         tppessoa, 
         dtconsulta_spc, 
         dtconsulta_rfb, 
         cdsituacao_rfb, 
         tpconsulta_rfb, 
         dtatualiza_telefone, 
         dtconsulta_scr, 
         tpcadastro, 
         cdoperad_altera,
         idcorrigido,
         dtalteracao,
         dtrevisao_cadastral)
      VALUES
        (pr_pessoa_fisica.idpessoa,
         pr_pessoa_fisica.nrcpf, 
         pr_pessoa_fisica.nmpessoa, 
         pr_pessoa_fisica.nmpessoa_receita, 
         pr_pessoa_fisica.tppessoa, 
         pr_pessoa_fisica.dtconsulta_spc, 
         pr_pessoa_fisica.dtconsulta_rfb, 
         pr_pessoa_fisica.cdsituacao_rfb, 
         pr_pessoa_fisica.tpconsulta_rfb, 
         pr_pessoa_fisica.dtatualiza_telefone, 
         pr_pessoa_fisica.dtconsulta_scr, 
         pr_pessoa_fisica.tpcadastro, 
         pr_pessoa_fisica.cdoperad_altera,
         pr_pessoa_fisica.idcorrigido,
         SYSDATE,
         pr_pessoa_fisica.dtrevisao_cadastral) RETURNING idpessoa INTO pr_pessoa_fisica.idpessoa;
    EXCEPTION
      WHEN dup_val_on_index THEN

        IF pr_pessoa_fisica.idpessoa IS NULL THEN
          --> Verificar pessoa
          rw_pessoa := NULL;
          OPEN cr_pessoa (pr_nrcpfcgc => pr_pessoa_fisica.nrcpf);
          FETCH cr_pessoa INTO rw_pessoa;
          IF cr_pessoa%NOTFOUND THEN
            CLOSE cr_pessoa;
            vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA: Pessoa nao encontrada.';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_pessoa;
            pr_pessoa_fisica.idpessoa := rw_pessoa.idpessoa;
          END IF;
        END IF;

        -- Atualiza o registro
        BEGIN
          UPDATE tbcadast_pessoa
             SET nrcpfcgc            = pr_pessoa_fisica.nrcpf,
                 nmpessoa            = pr_pessoa_fisica.nmpessoa,
                 nmpessoa_receita    = pr_pessoa_fisica.nmpessoa_receita, 
                 tppessoa            = pr_pessoa_fisica.tppessoa, 
                 dtconsulta_spc      = pr_pessoa_fisica.dtconsulta_spc, 
                 dtconsulta_rfb      = pr_pessoa_fisica.dtconsulta_rfb, 
                 cdsituacao_rfb      = pr_pessoa_fisica.cdsituacao_rfb, 
                 tpconsulta_rfb      = pr_pessoa_fisica.tpconsulta_rfb, 
                 dtatualiza_telefone = pr_pessoa_fisica.dtatualiza_telefone, 
                 dtconsulta_scr      = pr_pessoa_fisica.dtconsulta_scr, 
                 tpcadastro          = pr_pessoa_fisica.tpcadastro, 
                 cdoperad_altera     = pr_pessoa_fisica.cdoperad_altera,
                 idcorrigido         = pr_pessoa_fisica.idcorrigido,
                 dtalteracao         = SYSDATE,
                 dtrevisao_cadastral = pr_pessoa_fisica.dtrevisao_cadastral
           WHERE idpessoa = pr_pessoa_fisica.idpessoa;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se possuir algum campo do detalhe, gera a tabela
    IF pr_pessoa_fisica.nmsocial IS NOT NULL OR 
       pr_pessoa_fisica.tpsexo IS NOT NULL OR 
       pr_pessoa_fisica.cdestado_civil IS NOT NULL OR 
       pr_pessoa_fisica.dtnascimento IS NOT NULL OR 
       pr_pessoa_fisica.cdnaturalidade IS NOT NULL OR 
       pr_pessoa_fisica.cdnacionalidade IS NOT NULL OR 
       pr_pessoa_fisica.tpnacionalidade IS NOT NULL OR 
       pr_pessoa_fisica.tpdocumento IS NOT NULL OR 
       pr_pessoa_fisica.nrdocumento IS NOT NULL OR 
       pr_pessoa_fisica.dtemissao_documento IS NOT NULL OR 
       pr_pessoa_fisica.idorgao_expedidor IS NOT NULL OR 
       pr_pessoa_fisica.cduf_orgao_expedidor IS NOT NULL OR 
       pr_pessoa_fisica.inhabilitacao_menor IS NOT NULL OR 
       pr_pessoa_fisica.dthabilitacao_menor IS NOT NULL OR 
       pr_pessoa_fisica.cdgrau_escolaridade IS NOT NULL OR 
       pr_pessoa_fisica.cdcurso_superior IS NOT NULL OR 
       pr_pessoa_fisica.cdnatureza_ocupacao IS NOT NULL OR 
       pr_pessoa_fisica.dsprofissao IS NOT NULL OR 
       pr_pessoa_fisica.vlrenda_presumida IS NOT NULL OR 
       pr_pessoa_fisica.dsjustific_outros_rend IS NOT NULL THEN
      BEGIN
        INSERT INTO tbcadast_pessoa_fisica
          (idpessoa,
           nmsocial, 
           tpsexo, 
           cdestado_civil, 
           dtnascimento, 
           cdnaturalidade, 
           cdnacionalidade, 
           tpnacionalidade, 
           tpdocumento, 
           nrdocumento, 
           dtemissao_documento, 
           idorgao_expedidor, 
           cduf_orgao_expedidor, 
           inhabilitacao_menor, 
           dthabilitacao_menor, 
           cdgrau_escolaridade, 
           cdcurso_superior, 
           cdnatureza_ocupacao, 
           dsprofissao, 
           vlrenda_presumida, 
           dsjustific_outros_rend)
         VALUES
          (pr_pessoa_fisica.idpessoa, 
           pr_pessoa_fisica.nmsocial, 
           pr_pessoa_fisica.tpsexo, 
           pr_pessoa_fisica.cdestado_civil, 
           pr_pessoa_fisica.dtnascimento, 
           pr_pessoa_fisica.cdnaturalidade, 
           pr_pessoa_fisica.cdnacionalidade, 
           pr_pessoa_fisica.tpnacionalidade, 
           pr_pessoa_fisica.tpdocumento, 
           pr_pessoa_fisica.nrdocumento, 
           pr_pessoa_fisica.dtemissao_documento, 
           pr_pessoa_fisica.idorgao_expedidor, 
           pr_pessoa_fisica.cduf_orgao_expedidor, 
           pr_pessoa_fisica.inhabilitacao_menor, 
           pr_pessoa_fisica.dthabilitacao_menor, 
           pr_pessoa_fisica.cdgrau_escolaridade, 
           pr_pessoa_fisica.cdcurso_superior, 
           pr_pessoa_fisica.cdnatureza_ocupacao, 
           pr_pessoa_fisica.dsprofissao, 
           pr_pessoa_fisica.vlrenda_presumida, 
           pr_pessoa_fisica.dsjustific_outros_rend);
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Atualiza o registro
          BEGIN
            UPDATE tbcadast_pessoa_fisica
               SET nmsocial                = pr_pessoa_fisica.nmsocial, 
                   tpsexo                  = pr_pessoa_fisica.tpsexo, 
                   cdestado_civil          = pr_pessoa_fisica.cdestado_civil, 
                   dtnascimento            = pr_pessoa_fisica.dtnascimento, 
                   cdnaturalidade          = pr_pessoa_fisica.cdnaturalidade, 
                   cdnacionalidade         = pr_pessoa_fisica.cdnacionalidade, 
                   tpnacionalidade         = pr_pessoa_fisica.tpnacionalidade, 
                   tpdocumento             = pr_pessoa_fisica.tpdocumento, 
                   nrdocumento             = pr_pessoa_fisica.nrdocumento, 
                   dtemissao_documento     = pr_pessoa_fisica.dtemissao_documento, 
                   idorgao_expedidor       = pr_pessoa_fisica.idorgao_expedidor, 
                   cduf_orgao_expedidor    = pr_pessoa_fisica.cduf_orgao_expedidor, 
                   inhabilitacao_menor     = pr_pessoa_fisica.inhabilitacao_menor, 
                   dthabilitacao_menor     = pr_pessoa_fisica.dthabilitacao_menor, 
                   cdgrau_escolaridade     = pr_pessoa_fisica.cdgrau_escolaridade, 
                   cdcurso_superior        = pr_pessoa_fisica.cdcurso_superior, 
                   cdnatureza_ocupacao     = pr_pessoa_fisica.cdnatureza_ocupacao, 
                   dsprofissao             = pr_pessoa_fisica.dsprofissao, 
                   vlrenda_presumida       = pr_pessoa_fisica.vlrenda_presumida, 
                   dsjustific_outros_rend  = pr_pessoa_fisica.dsjustific_outros_rend
             WHERE idpessoa = pr_pessoa_fisica.idpessoa;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_FISICA: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_FISICA. CPF: '||pr_pessoa_fisica.nrcpf||'. ' ||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF; 
    
    -- Se possui dados do FACTA, deve ser incluido
    IF pr_pessoa_fisica.cdpais IS NOT NULL OR
       pr_pessoa_fisica.nridentificacao IS NOT NULL OR
       pr_pessoa_fisica.dsnatureza_relacao IS NOT NULL OR
       pr_pessoa_fisica.dsestado IS NOT NULL OR
       pr_pessoa_fisica.nrpassaporte IS NOT NULL OR
       pr_pessoa_fisica.tpdeclarado IS NOT NULL OR
       pr_pessoa_fisica.incrs IS NOT NULL OR
       pr_pessoa_fisica.infatca IS NOT NULL OR
       pr_pessoa_fisica.dsnaturalidade IS NOT NULL THEN
      BEGIN
        INSERT INTO tbcadast_pessoa_estrangeira
          (idpessoa, 
           cdpais, 
           nridentificacao, 
           dsnatureza_relacao, 
           dsestado, 
           nrpassaporte, 
           incrs, 
           infatca,
           tpdeclarado,
           dsnaturalidade)
         VALUES
          (pr_pessoa_fisica.idpessoa,
           pr_pessoa_fisica.cdpais, 
           pr_pessoa_fisica.nridentificacao, 
           pr_pessoa_fisica.dsnatureza_relacao, 
           pr_pessoa_fisica.dsestado, 
           pr_pessoa_fisica.nrpassaporte, 
           pr_pessoa_fisica.incrs, 
           pr_pessoa_fisica.infatca,
           pr_pessoa_fisica.tpdeclarado,
           pr_pessoa_fisica.dsnaturalidade);
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Atualiza o registro
          BEGIN
            UPDATE tbcadast_pessoa_estrangeira
               SET cdpais             = pr_pessoa_fisica.cdpais, 
                   nridentificacao    = pr_pessoa_fisica.nridentificacao, 
                   dsnatureza_relacao = pr_pessoa_fisica.dsnatureza_relacao,
                   dsestado           = pr_pessoa_fisica.dsestado, 
                   nrpassaporte       = pr_pessoa_fisica.nrpassaporte, 
                   incrs              = pr_pessoa_fisica.incrs, 
                   infatca            = pr_pessoa_fisica.infatca, 
                   tpdeclarado        = pr_pessoa_fisica.tpdeclarado
             WHERE idpessoa = pr_pessoa_fisica.idpessoa;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_ESTRANGEIRA: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_ESTRANGEIRA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    END IF; 
      
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica: ' ||SQLERRM;
  END;  

  -- Rotina para cadastro de pessoa juridica
  PROCEDURE pc_cadast_pessoa_juridica(pr_pessoa_juridica IN OUT vwcadast_pessoa_juridica%ROWTYPE -- Registro de pessoa juridica
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    rw_pessoa cr_pessoa%ROWTYPE;



  BEGIN

    -- Insere a tabela principal de pessoa
    BEGIN
      INSERT INTO tbcadast_pessoa
        (idpessoa,
         nrcpfcgc, 
         nmpessoa, 
         nmpessoa_receita, 
         tppessoa, 
         dtconsulta_spc, 
         dtconsulta_rfb, 
         cdsituacao_rfb, 
         tpconsulta_rfb, 
         dtatualiza_telefone, 
         dtconsulta_scr, 
         tpcadastro, 
         cdoperad_altera,
         idcorrigido,
         dtalteracao,
         dtrevisao_cadastral)
      VALUES
        (pr_pessoa_juridica.idpessoa,
         pr_pessoa_juridica.nrcnpj, 
         pr_pessoa_juridica.nmpessoa, 
         pr_pessoa_juridica.nmpessoa_receita, 
         pr_pessoa_juridica.tppessoa, 
         pr_pessoa_juridica.dtconsulta_spc, 
         pr_pessoa_juridica.dtconsulta_rfb, 
         pr_pessoa_juridica.cdsituacao_rfb, 
         pr_pessoa_juridica.tpconsulta_rfb, 
         pr_pessoa_juridica.dtatualiza_telefone, 
         pr_pessoa_juridica.dtconsulta_scr, 
         pr_pessoa_juridica.tpcadastro, 
         pr_pessoa_juridica.cdoperad_altera,
         pr_pessoa_juridica.idcorrigido,
         SYSDATE,
         pr_pessoa_juridica.dtrevisao_cadastral) RETURNING idpessoa INTO pr_pessoa_juridica.idpessoa;
    EXCEPTION
      WHEN dup_val_on_index THEN

        IF pr_pessoa_juridica.idpessoa IS NULL THEN
          --> Verificar pessoa
          rw_pessoa := NULL;
          OPEN cr_pessoa (pr_nrcpfcgc => pr_pessoa_juridica.nrcnpj);
          FETCH cr_pessoa INTO rw_pessoa;
          IF cr_pessoa%NOTFOUND THEN
            CLOSE cr_pessoa;
            vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA: Pessoa nao encontrada.';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_pessoa;
            pr_pessoa_juridica.idpessoa := rw_pessoa.idpessoa;
          END IF;
        END IF;

        -- Atualiza o registro
        BEGIN
          UPDATE tbcadast_pessoa
             SET nrcpfcgc            = pr_pessoa_juridica.nrcnpj,
                 nmpessoa            = pr_pessoa_juridica.nmpessoa,
                 nmpessoa_receita    = pr_pessoa_juridica.nmpessoa_receita, 
                 tppessoa            = pr_pessoa_juridica.tppessoa, 
                 dtconsulta_spc      = pr_pessoa_juridica.dtconsulta_spc, 
                 dtconsulta_rfb      = pr_pessoa_juridica.dtconsulta_rfb, 
                 cdsituacao_rfb      = pr_pessoa_juridica.cdsituacao_rfb, 
                 tpconsulta_rfb      = pr_pessoa_juridica.tpconsulta_rfb, 
                 dtatualiza_telefone = pr_pessoa_juridica.dtatualiza_telefone, 
                 dtconsulta_scr      = pr_pessoa_juridica.dtconsulta_scr, 
                 tpcadastro          = pr_pessoa_juridica.tpcadastro, 
                 cdoperad_altera     = pr_pessoa_juridica.cdoperad_altera,
                 idcorrigido         = pr_pessoa_juridica.idcorrigido,
                 dtalteracao         = SYSDATE
         WHERE idpessoa = pr_pessoa_juridica.idpessoa;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Se possuir algum campo do detalhe, gera a tabela
    IF pr_pessoa_juridica.cdcnae IS NOT NULL OR 
       pr_pessoa_juridica.nmfantasia IS NOT NULL OR 
       pr_pessoa_juridica.nrinscricao_estadual IS NOT NULL OR 
       pr_pessoa_juridica.cdnatureza_juridica IS NOT NULL OR 
       pr_pessoa_juridica.dtconstituicao IS NOT NULL OR 
       pr_pessoa_juridica.dtinicio_atividade IS NOT NULL OR 
       pr_pessoa_juridica.qtfilial IS NOT NULL OR 
       pr_pessoa_juridica.qtfuncionario IS NOT NULL OR 
       pr_pessoa_juridica.vlcapital IS NOT NULL OR 
       pr_pessoa_juridica.dtregistro IS NOT NULL OR 
       pr_pessoa_juridica.nrregistro IS NOT NULL OR 
       pr_pessoa_juridica.dsorgao_registro IS NOT NULL OR 
       pr_pessoa_juridica.dtinscricao_municipal IS NOT NULL OR 
       pr_pessoa_juridica.nrnire IS NOT NULL OR 
       pr_pessoa_juridica.inrefis IS NOT NULL OR 
       pr_pessoa_juridica.dssite IS NOT NULL OR 
       pr_pessoa_juridica.nrinscricao_municipal IS NOT NULL OR 
       pr_pessoa_juridica.cdsetor_economico IS NOT NULL OR 
       pr_pessoa_juridica.vlfaturamento_anual IS NOT NULL OR 
       pr_pessoa_juridica.cdramo_atividade IS NOT NULL OR 
       pr_pessoa_juridica.nrlicenca_ambiental IS NOT NULL OR 
       pr_pessoa_juridica.dtvalidade_licenca_amb IS NOT NULL OR 
       pr_pessoa_juridica.peunico_cliente IS NOT NULL OR
       pr_pessoa_juridica.tpregime_tributacao IS NOT NULL THEN
      BEGIN
        INSERT INTO tbcadast_pessoa_juridica
          (idpessoa, 
           cdcnae, 
           nmfantasia, 
           nrinscricao_estadual, 
           cdnatureza_juridica, 
           dtconstituicao, 
           dtinicio_atividade, 
           qtfilial, 
           qtfuncionario, 
           vlcapital, 
           dtregistro, 
           nrregistro, 
           dsorgao_registro, 
           dtinscricao_municipal, 
           nrnire, 
           inrefis, 
           dssite, 
           nrinscricao_municipal, 
           cdsetor_economico, 
           vlfaturamento_anual, 
           cdramo_atividade, 
           nrlicenca_ambiental, 
           dtvalidade_licenca_amb, 
           peunico_cliente,
           tpregime_tributacao)
         VALUES
          (pr_pessoa_juridica.idpessoa, 
           pr_pessoa_juridica.cdcnae, 
           pr_pessoa_juridica.nmfantasia, 
           pr_pessoa_juridica.nrinscricao_estadual, 
           pr_pessoa_juridica.cdnatureza_juridica, 
           pr_pessoa_juridica.dtconstituicao, 
           pr_pessoa_juridica.dtinicio_atividade, 
           pr_pessoa_juridica.qtfilial, 
           pr_pessoa_juridica.qtfuncionario, 
           pr_pessoa_juridica.vlcapital, 
           pr_pessoa_juridica.dtregistro, 
           pr_pessoa_juridica.nrregistro, 
           pr_pessoa_juridica.dsorgao_registro, 
           pr_pessoa_juridica.dtinscricao_municipal, 
           pr_pessoa_juridica.nrnire, 
           pr_pessoa_juridica.inrefis, 
           pr_pessoa_juridica.dssite, 
           pr_pessoa_juridica.nrinscricao_municipal, 
           pr_pessoa_juridica.cdsetor_economico, 
           pr_pessoa_juridica.vlfaturamento_anual, 
           pr_pessoa_juridica.cdramo_atividade, 
           pr_pessoa_juridica.nrlicenca_ambiental, 
           pr_pessoa_juridica.dtvalidade_licenca_amb, 
           pr_pessoa_juridica.peunico_cliente,
           pr_pessoa_juridica.tpregime_tributacao);
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Atualiza o registro
          BEGIN
            UPDATE tbcadast_pessoa_juridica
               SET cdcnae                 = pr_pessoa_juridica.cdcnae,
                   nmfantasia             = pr_pessoa_juridica.nmfantasia,            
                   nrinscricao_estadual   = pr_pessoa_juridica.nrinscricao_estadual,  
                   cdnatureza_juridica    = pr_pessoa_juridica.cdnatureza_juridica,   
                   dtconstituicao         = pr_pessoa_juridica.dtconstituicao,        
                   dtinicio_atividade     = pr_pessoa_juridica.dtinicio_atividade,    
                   qtfilial               = pr_pessoa_juridica.qtfilial,              
                   qtfuncionario          = pr_pessoa_juridica.qtfuncionario,         
                   vlcapital              = pr_pessoa_juridica.vlcapital,             
                   dtregistro             = pr_pessoa_juridica.dtregistro,            
                   nrregistro             = pr_pessoa_juridica.nrregistro,            
                   dsorgao_registro       = pr_pessoa_juridica.dsorgao_registro,     
                   dtinscricao_municipal  = pr_pessoa_juridica.dtinscricao_municipal, 
                   nrnire                 = pr_pessoa_juridica.nrnire,                
                   inrefis                = pr_pessoa_juridica.inrefis,               
                   dssite                 = pr_pessoa_juridica.dssite,                
                   nrinscricao_municipal  = pr_pessoa_juridica.nrinscricao_municipal, 
                   cdsetor_economico      = pr_pessoa_juridica.cdsetor_economico,     
                   vlfaturamento_anual    = pr_pessoa_juridica.vlfaturamento_anual,   
                   cdramo_atividade       = pr_pessoa_juridica.cdramo_atividade,      
                   nrlicenca_ambiental    = pr_pessoa_juridica.nrlicenca_ambiental,   
                   dtvalidade_licenca_amb = pr_pessoa_juridica.dtvalidade_licenca_amb,
                   peunico_cliente        = pr_pessoa_juridica.peunico_cliente,
                   tpregime_tributacao    = pr_pessoa_juridica.tpregime_tributacao
             WHERE idpessoa = pr_pessoa_juridica.idpessoa;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIDICA: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIDICA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF; 
    
    -- Se possui dados do FACTA, deve ser incluido
    IF pr_pessoa_juridica.cdpais IS NOT NULL OR
       pr_pessoa_juridica.nridentificacao IS NOT NULL OR
       pr_pessoa_juridica.dsnatureza_relacao IS NOT NULL OR
       pr_pessoa_juridica.dsestado IS NOT NULL OR
       pr_pessoa_juridica.nrpassaporte IS NOT NULL OR
       pr_pessoa_juridica.tpdeclarado IS NOT NULL OR
       pr_pessoa_juridica.incrs IS NOT NULL OR
       pr_pessoa_juridica.infatca IS NOT NULL OR
       pr_pessoa_juridica.dsnaturalidade IS NOT NULL THEN
      BEGIN
        INSERT INTO tbcadast_pessoa_estrangeira
          (idpessoa, 
           cdpais, 
           nridentificacao, 
           dsnatureza_relacao, 
           dsestado, 
           nrpassaporte, 
           incrs, 
           infatca,
           tpdeclarado,
           dsnaturalidade)
         VALUES
          (pr_pessoa_juridica.idpessoa,
           pr_pessoa_juridica.cdpais, 
           pr_pessoa_juridica.nridentificacao, 
           pr_pessoa_juridica.dsnatureza_relacao, 
           pr_pessoa_juridica.dsestado, 
           pr_pessoa_juridica.nrpassaporte, 
           pr_pessoa_juridica.incrs, 
           pr_pessoa_juridica.infatca,
           pr_pessoa_juridica.tpdeclarado,
           pr_pessoa_juridica.dsnaturalidade);
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Atualiza o registro
          BEGIN
            UPDATE tbcadast_pessoa_estrangeira
               SET cdpais             = pr_pessoa_juridica.cdpais, 
                   nridentificacao    = pr_pessoa_juridica.nridentificacao, 
                   dsnatureza_relacao = pr_pessoa_juridica.dsnatureza_relacao,
                   dsestado           = pr_pessoa_juridica.dsestado, 
                   nrpassaporte       = pr_pessoa_juridica.nrpassaporte, 
                   incrs              = pr_pessoa_juridica.incrs, 
                   infatca            = pr_pessoa_juridica.infatca, 
                   tpdeclarado        = pr_pessoa_juridica.tpdeclarado
             WHERE idpessoa = pr_pessoa_juridica.idpessoa;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_ESTRANGEIRA: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_ESTRANGEIRA: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
    END IF; 
    
    -- Trata os dados financeiros
    IF pr_pessoa_juridica.vlreceita_bruta IS NOT NULL OR
      pr_pessoa_juridica.vlcusto_despesa_adm IS NOT NULL OR
      pr_pessoa_juridica.vldespesa_administrativa IS NOT NULL OR
      pr_pessoa_juridica.qtdias_recebimento IS NOT NULL OR
      pr_pessoa_juridica.qtdias_pagamento IS NOT NULL OR
      pr_pessoa_juridica.vlativo_caixa_banco_apl IS NOT NULL OR
      pr_pessoa_juridica.vlativo_contas_receber IS NOT NULL OR
      pr_pessoa_juridica.vlativo_estoque IS NOT NULL OR
      pr_pessoa_juridica.vlativo_imobilizado IS NOT NULL OR
      pr_pessoa_juridica.vlativo_outros IS NOT NULL OR
      pr_pessoa_juridica.vlpassivo_fornecedor IS NOT NULL OR
      pr_pessoa_juridica.vlpassivo_divida_bancaria IS NOT NULL OR
      pr_pessoa_juridica.vlpassivo_outros IS NOT NULL THEN
      BEGIN
        INSERT INTO tbcadast_pessoa_juridica_fnc
          (idpessoa, 
           vlreceita_bruta, 
           vlcusto_despesa_adm, 
           vldespesa_administrativa, 
           qtdias_recebimento, 
           qtdias_pagamento, 
           vlativo_caixa_banco_apl, 
           vlativo_contas_receber, 
           vlativo_estoque, 
           vlativo_imobilizado, 
           vlativo_outros, 
           vlpassivo_fornecedor, 
           vlpassivo_divida_bancaria, 
           vlpassivo_outros, 
           cdoperad_altera,
           dtmes_base )
         VALUES
          (pr_pessoa_juridica.idpessoa, 
           pr_pessoa_juridica.vlreceita_bruta, 
           pr_pessoa_juridica.vlcusto_despesa_adm, 
           pr_pessoa_juridica.vldespesa_administrativa, 
           pr_pessoa_juridica.qtdias_recebimento, 
           pr_pessoa_juridica.qtdias_pagamento, 
           pr_pessoa_juridica.vlativo_caixa_banco_apl, 
           pr_pessoa_juridica.vlativo_contas_receber, 
           pr_pessoa_juridica.vlativo_estoque, 
           pr_pessoa_juridica.vlativo_imobilizado, 
           pr_pessoa_juridica.vlativo_outros, 
           pr_pessoa_juridica.vlpassivo_fornecedor, 
           pr_pessoa_juridica.vlpassivo_divida_bancaria, 
           pr_pessoa_juridica.vlpassivo_outros, 
           pr_pessoa_juridica.cdoperad_altera,
           pr_pessoa_juridica.dtmes_base );
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- Atualiza o registro
          BEGIN
            UPDATE tbcadast_pessoa_juridica_fnc
               SET vlreceita_bruta           = pr_pessoa_juridica.vlreceita_bruta,
                   vlcusto_despesa_adm       = pr_pessoa_juridica.vlcusto_despesa_adm,
                   vldespesa_administrativa  = pr_pessoa_juridica.vldespesa_administrativa,
                   qtdias_recebimento        = pr_pessoa_juridica.qtdias_recebimento,
                   qtdias_pagamento          = pr_pessoa_juridica.qtdias_pagamento,
                   vlativo_caixa_banco_apl   = pr_pessoa_juridica.vlativo_caixa_banco_apl,
                   vlativo_contas_receber    = pr_pessoa_juridica.vlativo_contas_receber,
                   vlativo_estoque           = pr_pessoa_juridica.vlativo_estoque,
                   vlativo_imobilizado       = pr_pessoa_juridica.vlativo_imobilizado,
                   vlativo_outros            = pr_pessoa_juridica.vlativo_outros,
                   vlpassivo_fornecedor      = pr_pessoa_juridica.vlpassivo_fornecedor,
                   vlpassivo_divida_bancaria = pr_pessoa_juridica.vlpassivo_divida_bancaria,
                   vlpassivo_outros          = pr_pessoa_juridica.vlpassivo_outros,
                   dtmes_base                = pr_pessoa_juridica.dtmes_base,
                   cdoperad_altera           = pr_pessoa_juridica.cdoperad_altera
             WHERE idpessoa = pr_pessoa_juridica.idpessoa;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIODICA_FNC: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIODICA_FNC: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
      
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica: ' ||SQLERRM;
  END;  

  
  -- Rotina para cadastrar email
  PROCEDURE pc_cadast_pessoa_email(pr_pessoa_email IN OUT tbcadast_pessoa_email%ROWTYPE -- Registro de email
                                   ,pr_cdcritic OUT INTEGER                      -- Codigo de erro
                                   ,pr_dscritic OUT VARCHAR2) IS                 -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_email IS
      SELECT nvl(MAX(nrseq_email),0) + 1
        FROM tbcadast_pessoa_email
       WHERE idpessoa = pr_pessoa_email.idpessoa;
  
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de e-mail, busca a maior sequencia
    IF pr_pessoa_email.nrseq_email IS NULL THEN
      OPEN cr_email;
      FETCH cr_email INTO pr_pessoa_email.nrseq_email;
      CLOSE cr_email;
    END IF;
    
    -- Efetua a inclusao do email
    BEGIN
      INSERT INTO tbcadast_pessoa_email
        (idpessoa, 
         nrseq_email, 
         dsemail, 
         nmpessoa_contato, 
         nmsetor_pessoa_contato, 
         cdoperad_altera,
		 insituacao)
       VALUES
        (pr_pessoa_email.idpessoa, 
         pr_pessoa_email.nrseq_email, 
         pr_pessoa_email.dsemail, 
         pr_pessoa_email.nmpessoa_contato, 
         pr_pessoa_email.nmsetor_pessoa_contato, 
         pr_pessoa_email.cdoperad_altera,
		 pr_pessoa_email.insituacao);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao do e-mail
        BEGIN
          UPDATE tbcadast_pessoa_email
             SET dsemail                = pr_pessoa_email.dsemail, 
                 nmpessoa_contato       = pr_pessoa_email.nmpessoa_contato, 
                 nmsetor_pessoa_contato = pr_pessoa_email.nmsetor_pessoa_contato,
                 cdoperad_altera        = pr_pessoa_email.cdoperad_altera
           WHERE idpessoa    = pr_pessoa_email.idpessoa
             AND nrseq_email = pr_pessoa_email.nrseq_email;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_EMAIL: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_EMAIL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_email: ' ||SQLERRM;
  END;  

  -- Rotina para excluir email
  PROCEDURE pc_exclui_pessoa_email(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE -- Identificador de pessoa
                                  ,pr_nrseq_email     IN tbcadast_pessoa_email.nrseq_email%TYPE
                                  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE -- Operador que esta efetuando a exclusao
                                  ,pr_cdcritic       OUT INTEGER                      -- Codigo de erro
                                  ,pr_dscritic       OUT VARCHAR2) IS                 -- Retorno de Erro
  
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao do email
    BEGIN
      DELETE tbcadast_pessoa_email
       WHERE idpessoa    = pr_idpessoa
         AND nrseq_email = pr_nrseq_email;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_EMAIL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_email: ' ||SQLERRM;
  END;  

  -- Rotina para cadastro de renda da pessoa fisica
  PROCEDURE pc_cadast_pessoa_renda(pr_pessoa_renda IN OUT tbcadast_pessoa_renda%ROWTYPE -- Registro de pessoa fisica
                                  ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                  ,pr_dscritic OUT VARCHAR2) IS             -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_renda IS
      SELECT nvl(MAX(nrseq_renda),0) + 1
        FROM tbcadast_pessoa_renda
       WHERE idpessoa = pr_pessoa_renda.idpessoa;
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de renda, busca a maior sequencia
    IF pr_pessoa_renda.nrseq_renda IS NULL THEN
      OPEN cr_renda;
      FETCH cr_renda INTO pr_pessoa_renda.nrseq_renda;
      CLOSE cr_renda;
    END IF;
    
    -- Por enquanto o sistema Ayllos nao esta preparado para receber
    -- mais de uma renda. Neste caso deve-se cancelar a inclusao
    IF pr_pessoa_renda.nrseq_renda > 1 THEN
      vr_dscritic := 'Sistema nao preparado para receber mais de uma renda';
      RAISE vr_exc_erro;
    END IF;
    
    -- Efetua a inclusao da renda
    BEGIN
      INSERT INTO tbcadast_pessoa_renda
        (idpessoa, 
         nrseq_renda, 
         tpcontrato_trabalho, 
         cdturno, 
         cdnivel_cargo, 
         dtadmissao, 
         cdocupacao, 
         nrcadastro, 
         vlrenda, 
         tpfixo_variavel, 
         tpcomprov_renda,
         idpessoa_fonte_renda,
         cdoperad_altera)
       VALUES
        (pr_pessoa_renda.idpessoa, 
         pr_pessoa_renda.nrseq_renda, 
         pr_pessoa_renda.tpcontrato_trabalho, 
         pr_pessoa_renda.cdturno, 
         pr_pessoa_renda.cdnivel_cargo, 
         pr_pessoa_renda.dtadmissao, 
         pr_pessoa_renda.cdocupacao, 
         pr_pessoa_renda.nrcadastro, 
         pr_pessoa_renda.vlrenda, 
         pr_pessoa_renda.tpfixo_variavel, 
         pr_pessoa_renda.tpcomprov_renda,
         pr_pessoa_renda.idpessoa_fonte_renda,
         pr_pessoa_renda.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_renda 
             SET tpcontrato_trabalho = pr_pessoa_renda.tpcontrato_trabalho,
                 cdturno             = pr_pessoa_renda.cdturno, 
                 cdnivel_cargo       = pr_pessoa_renda.cdnivel_cargo, 
                 dtadmissao          = pr_pessoa_renda.dtadmissao, 
                 cdocupacao          = pr_pessoa_renda.cdocupacao, 
                 nrcadastro          = pr_pessoa_renda.nrcadastro, 
                 vlrenda             = pr_pessoa_renda.vlrenda, 
                 tpfixo_variavel     = pr_pessoa_renda.tpfixo_variavel, 
                 tpcomprov_renda     = pr_pessoa_renda.tpcomprov_renda,
                 idpessoa_fonte_renda= pr_pessoa_renda.idpessoa_fonte_renda,
                 cdoperad_altera     = pr_pessoa_renda.cdoperad_altera
           WHERE idpessoa       = pr_pessoa_renda.idpessoa
             AND nrseq_renda    = pr_pessoa_renda.nrseq_renda;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_RENDA: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_RENDA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_renda: ' ||SQLERRM;
  END;  
	
  -- Rotina para excluir renda da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE          -- Identificador de pessoa
		                              ,pr_nrseq_renda     IN tbcadast_pessoa_renda.nrseq_renda%TYPE -- Nr. de sequência de renda
                                  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE   -- Operador que esta efetuando a exclusao																	
                                  ,pr_cdcritic        OUT INTEGER                               -- Codigo de erro
                                  ,pr_dscritic        OUT VARCHAR2) IS                          -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao da renda
    BEGIN
      DELETE tbcadast_pessoa_renda
       WHERE idpessoa    = pr_idpessoa
         AND nrseq_renda = pr_nrseq_renda;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_RENDA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_renda: ' ||SQLERRM;		
	END;

  -- Rotina para cadastro de renda complementar da pessoa fisica
  PROCEDURE pc_cadast_pessoa_renda_compl(pr_pessoa_renda_compl IN OUT tbcadast_pessoa_rendacompl%ROWTYPE -- Registro de renda complementar da pessoa fisica
                                        ,pr_cdcritic OUT INTEGER                  -- Codigo de erro
                                        ,pr_dscritic OUT VARCHAR2) IS             -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_renda IS
      SELECT nvl(MAX(nrseq_renda),0) + 1
        FROM tbcadast_pessoa_rendacompl
       WHERE idpessoa = pr_pessoa_renda_compl.idpessoa;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN

    -- Se nao possui sequencia de renda, busca a maior sequencia
    IF pr_pessoa_renda_compl.nrseq_renda IS NULL THEN
      OPEN cr_renda;
      FETCH cr_renda INTO pr_pessoa_renda_compl.nrseq_renda;
      CLOSE cr_renda;
    END IF;
    
    IF pr_pessoa_renda_compl.nrseq_renda > 7 THEN
      vr_dscritic := 'Somente 7 rendas complementares podem ser informadas';
      RAISE vr_exc_erro;
    END IF;

    -- Efetua a inclusao da renda
    BEGIN
      INSERT INTO tbcadast_pessoa_rendacompl
        (idpessoa, 
         nrseq_renda, 
         tprenda, 
         vlrenda, 
         tpfixo_variavel, 
         cdoperad_altera)
       VALUES
        (pr_pessoa_renda_compl.idpessoa,
         pr_pessoa_renda_compl.nrseq_renda, 
         pr_pessoa_renda_compl.tprenda, 
         pr_pessoa_renda_compl.vlrenda, 
         pr_pessoa_renda_compl.tpfixo_variavel, 
         pr_pessoa_renda_compl.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_rendacompl
             SET tprenda         = pr_pessoa_renda_compl.tprenda, 
                 vlrenda         = pr_pessoa_renda_compl.vlrenda, 
                 tpfixo_variavel = pr_pessoa_renda_compl.tpfixo_variavel, 
                 cdoperad_altera = pr_pessoa_renda_compl.cdoperad_altera
           WHERE idpessoa        = pr_pessoa_renda_compl.idpessoa
             AND nrseq_renda     = pr_pessoa_renda_compl.nrseq_renda;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_RENDACOMPL: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_RENDACOMPL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_renda_compl: ' ||SQLERRM;
  END;  

  -- Rotina para excluir renda complementar da pessoa fisica
  PROCEDURE pc_exclui_pessoa_renda_compl(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE               -- Identificador de pessoa
		                                    ,pr_nrseq_renda     IN tbcadast_pessoa_rendacompl.nrseq_renda%TYPE -- Nr. de sequência de renda complementar
                                        ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE        -- Operador que esta efetuando a exclusao																	
                                        ,pr_cdcritic        OUT INTEGER                                    -- Codigo de erro
                                        ,pr_dscritic        OUT VARCHAR2) IS                               -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao da renda complementar
    BEGIN
      DELETE tbcadast_pessoa_rendacompl
       WHERE idpessoa    = pr_idpessoa
         AND nrseq_renda = pr_nrseq_renda;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_RENDACOMPL: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_renda_compl: ' ||SQLERRM;		
	END;

  -- Rotina para cadastro de telefones
  PROCEDURE pc_cadast_pessoa_telefone(pr_pessoa_telefone IN OUT tbcadast_pessoa_telefone%ROWTYPE -- Registro de pessoa fisica
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_telefone IS
      SELECT nvl(MAX(nrseq_telefone),0) + 1
        FROM tbcadast_pessoa_telefone
       WHERE idpessoa = pr_pessoa_telefone.idpessoa;
         
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de telefone, busca a maior sequencia
    IF pr_pessoa_telefone.nrseq_telefone IS NULL THEN
      OPEN cr_telefone;
      FETCH cr_telefone INTO pr_pessoa_telefone.nrseq_telefone;
      CLOSE cr_telefone;
    END IF;
    
    -- Efetua a inclusao da renda
    BEGIN
      INSERT INTO tbcadast_pessoa_telefone
        (idpessoa, 
         nrseq_telefone, 
         cdoperadora, 
         tptelefone, 
         nmpessoa_contato, 
         nmsetor_pessoa_contato, 
         nrddd, 
         nrtelefone, 
         nrramal, 
         insituacao, 
         tporigem_cadastro, 
         flgaceita_sms,
         cdoperad_altera)
       VALUES
        (pr_pessoa_telefone.idpessoa, 
         pr_pessoa_telefone.nrseq_telefone, 
         pr_pessoa_telefone.cdoperadora, 
         pr_pessoa_telefone.tptelefone, 
         pr_pessoa_telefone.nmpessoa_contato, 
         pr_pessoa_telefone.nmsetor_pessoa_contato, 
         pr_pessoa_telefone.nrddd, 
         pr_pessoa_telefone.nrtelefone, 
         pr_pessoa_telefone.nrramal, 
         pr_pessoa_telefone.insituacao, 
         pr_pessoa_telefone.tporigem_cadastro, 
         pr_pessoa_telefone.flgaceita_sms,
         pr_pessoa_telefone.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_telefone
             SET cdoperadora            = pr_pessoa_telefone.cdoperadora, 
                 tptelefone             = pr_pessoa_telefone.tptelefone, 
                 nmpessoa_contato       = pr_pessoa_telefone.nmpessoa_contato, 
                 nmsetor_pessoa_contato = pr_pessoa_telefone.nmsetor_pessoa_contato,
                 nrddd                  = pr_pessoa_telefone.nrddd, 
                 nrtelefone             = pr_pessoa_telefone.nrtelefone, 
                 nrramal                = pr_pessoa_telefone.nrramal, 
                 insituacao             = pr_pessoa_telefone.insituacao, 
                 tporigem_cadastro      = pr_pessoa_telefone.tporigem_cadastro, 
                 flgaceita_sms          = pr_pessoa_telefone.flgaceita_sms,
                 cdoperad_altera        = pr_pessoa_telefone.cdoperad_altera
           WHERE idpessoa       = pr_pessoa_telefone.idpessoa
             AND nrseq_telefone = pr_pessoa_telefone.nrseq_telefone;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_TELEFONE: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_TELEFONE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_telefone: ' ||SQLERRM;
  END;  

  -- Rotina para excluir telefone
  PROCEDURE pc_exclui_pessoa_telefone(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE                -- Identificador de pessoa
																		 ,pr_nrseq_telefone  IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE -- Nr. de sequência de telefone
																		 ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE         -- Operador que esta efetuando a exclusao																	
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2) IS                                -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao de telefone
    BEGIN
      DELETE tbcadast_pessoa_telefone
       WHERE idpessoa    = pr_idpessoa
         AND nrseq_telefone = pr_nrseq_telefone;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_TELEFONE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_telefone: ' ||SQLERRM;		
	END;

  -- Rotina para cadastro de enderecos
  PROCEDURE pc_cadast_pessoa_endereco(pr_pessoa_endereco IN OUT tbcadast_pessoa_endereco%ROWTYPE -- Registro de pessoa fisica
                                     ,pr_cdcritic OUT INTEGER                             -- Codigo de erro
                                     ,pr_dscritic OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_endereco IS
      SELECT nvl(MAX(nrseq_endereco),0) + 1
        FROM tbcadast_pessoa_endereco
       WHERE idpessoa = pr_pessoa_endereco.idpessoa;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de endereco, busca a maior sequencia
    IF pr_pessoa_endereco.nrseq_endereco IS NULL THEN
      OPEN cr_endereco;
      FETCH cr_endereco INTO pr_pessoa_endereco.nrseq_endereco;
      CLOSE cr_endereco;
    END IF;

    -- Efetua a inclusao do endereco
    BEGIN
      INSERT INTO tbcadast_pessoa_endereco
        (idpessoa, 
         nrseq_endereco, 
         tpendereco, 
         nmlogradouro, 
         nrlogradouro, 
         dscomplemento, 
         nmbairro, 
         idcidade, 
         nrcep, 
         tpimovel, 
         vldeclarado, 
         dtalteracao, 
         dtinicio_residencia, 
         tporigem_cadastro, 
         cdoperad_altera)
       VALUES
        (pr_pessoa_endereco.idpessoa,
         pr_pessoa_endereco.nrseq_endereco, 
         pr_pessoa_endereco.tpendereco, 
         pr_pessoa_endereco.nmlogradouro, 
         pr_pessoa_endereco.nrlogradouro, 
         pr_pessoa_endereco.dscomplemento, 
         pr_pessoa_endereco.nmbairro, 
         pr_pessoa_endereco.idcidade, 
         pr_pessoa_endereco.nrcep, 
         pr_pessoa_endereco.tpimovel, 
         pr_pessoa_endereco.vldeclarado, 
         pr_pessoa_endereco.dtalteracao, 
         pr_pessoa_endereco.dtinicio_residencia,
         pr_pessoa_endereco.tporigem_cadastro, 
         pr_pessoa_endereco.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_endereco
             SET tpendereco          = pr_pessoa_endereco.tpendereco,         
                 nmlogradouro        = pr_pessoa_endereco.nmlogradouro,       
                 nrlogradouro        = pr_pessoa_endereco.nrlogradouro,       
                 dscomplemento       = pr_pessoa_endereco.dscomplemento,      
                 nmbairro            = pr_pessoa_endereco.nmbairro,           
                 idcidade            = pr_pessoa_endereco.idcidade,           
                 nrcep               = pr_pessoa_endereco.nrcep,              
                 tpimovel            = pr_pessoa_endereco.tpimovel,           
                 vldeclarado         = pr_pessoa_endereco.vldeclarado,          
                 dtalteracao         = pr_pessoa_endereco.dtalteracao,  
                 dtinicio_residencia = pr_pessoa_endereco.dtinicio_residencia,
                 tporigem_cadastro   = pr_pessoa_endereco.tporigem_cadastro,  
                 cdoperad_altera     = pr_pessoa_endereco.cdoperad_altera    
           WHERE idpessoa       = pr_pessoa_endereco.idpessoa
             AND nrseq_endereco = pr_pessoa_endereco.nrseq_endereco;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_ENDERECO: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_ENDERECO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_endereco: ' ||SQLERRM;
  END;  

  -- Rotina para excluir endereço
  PROCEDURE pc_exclui_pessoa_endereco(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE                -- Identificador de pessoa
																		 ,pr_nrseq_endereco  IN tbcadast_pessoa_endereco.nrseq_endereco%TYPE -- Nr. de sequência de endereço
																		 ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE         -- Operador que esta efetuando a exclusao																	
																		 ,pr_cdcritic        OUT INTEGER                                     -- Codigo de erro
																		 ,pr_dscritic        OUT VARCHAR2) IS                                -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao de endereço
    BEGIN
      DELETE tbcadast_pessoa_endereco
       WHERE idpessoa    = pr_idpessoa
         AND nrseq_endereco = pr_nrseq_endereco;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_ENDERECO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_endereco: ' ||SQLERRM;		
	END;

  -- Rotina para cadastro de bens
  PROCEDURE pc_cadast_pessoa_bem(pr_pessoa_bem IN OUT tbcadast_pessoa_bem%ROWTYPE -- Registro de bens
                                ,pr_cdcritic OUT INTEGER                   -- Codigo de erro
                                ,pr_dscritic OUT VARCHAR2) IS              -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_bem IS
      SELECT nvl(MAX(nrseq_bem),0) + 1
        FROM tbcadast_pessoa_bem
       WHERE idpessoa = pr_pessoa_bem.idpessoa;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de bem, busca a maior sequencia
    IF pr_pessoa_bem.nrseq_bem IS NULL THEN
      OPEN cr_bem;
      FETCH cr_bem INTO pr_pessoa_bem.nrseq_bem;
      CLOSE cr_bem;
    END IF;

    -- Efetua a inclusao do bem
    BEGIN
      INSERT INTO tbcadast_pessoa_bem
        (idpessoa, 
         nrseq_bem, 
         dsbem, 
         pebem, 
         qtparcela_bem, 
         vlbem, 
         vlparcela_bem, 
         dtalteracao, 
         cdoperad_altera)
       VALUES
        (pr_pessoa_bem.idpessoa, 
         pr_pessoa_bem.nrseq_bem, 
         pr_pessoa_bem.dsbem, 
         pr_pessoa_bem.pebem, 
         pr_pessoa_bem.qtparcela_bem, 
         pr_pessoa_bem.vlbem, 
         pr_pessoa_bem.vlparcela_bem, 
         pr_pessoa_bem.dtalteracao, 
         pr_pessoa_bem.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_bem 
             SET dsbem           = pr_pessoa_bem.dsbem, 
                 pebem           = pr_pessoa_bem.pebem,
                 qtparcela_bem   = pr_pessoa_bem.qtparcela_bem, 
                 vlbem           = pr_pessoa_bem.vlbem, 
                 vlparcela_bem   = pr_pessoa_bem.vlparcela_bem, 
                 dtalteracao     = pr_pessoa_bem.dtalteracao, 
                 cdoperad_altera = pr_pessoa_bem.cdoperad_altera
           WHERE idpessoa  = pr_pessoa_bem.idpessoa
             AND nrseq_bem = pr_pessoa_bem.nrseq_bem;
        EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_BEM: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_BEM: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_bem: ' ||SQLERRM;
  END;  

  -- Rotina para excluir bem
  PROCEDURE pc_exclui_pessoa_bem(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE        -- Identificador de pessoa
															  ,pr_nrseq_bem       IN tbcadast_pessoa_bem.nrseq_bem%TYPE   -- Nr. de sequência de bem
															  ,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE -- Operador que esta efetuando a exclusao																	
															  ,pr_cdcritic        OUT INTEGER                             -- Codigo de erro
															  ,pr_dscritic        OUT VARCHAR2) IS                        -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao de bens
    BEGIN
      DELETE tbcadast_pessoa_bem
       WHERE idpessoa  = pr_idpessoa
         AND nrseq_bem = pr_nrseq_bem;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_BEM: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_bem: ' ||SQLERRM;		
	END;

  -- Rotina para cadastro de relacionamentos da pessoa
  PROCEDURE pc_cadast_pessoa_relacao(pr_pessoa_relacao IN OUT tbcadast_pessoa_relacao%ROWTYPE -- Registro de pessoas de relacao
                                    ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                    ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
    -- Cursor para buscar a maior sequencia
    CURSOR cr_relacao IS
      SELECT nvl(MAX(nrseq_relacao),0) + 1
        FROM tbcadast_pessoa_relacao
       WHERE idpessoa = pr_pessoa_relacao.idpessoa;

    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia de relacao, busca a maior sequencia
    IF pr_pessoa_relacao.nrseq_relacao IS NULL THEN
      OPEN cr_relacao;
      FETCH cr_relacao INTO pr_pessoa_relacao.nrseq_relacao;
      CLOSE cr_relacao;
    END IF;

    -- Efetua a inclusao do bem
    BEGIN
      INSERT INTO tbcadast_pessoa_relacao
        (idpessoa, 
         nrseq_relacao, 
         idpessoa_relacao, 
         tprelacao, 
         cdoperad_altera)
       VALUES
        (pr_pessoa_relacao.idpessoa, 
         pr_pessoa_relacao.nrseq_relacao, 
         pr_pessoa_relacao.idpessoa_relacao, 
         pr_pessoa_relacao.tprelacao, 
         pr_pessoa_relacao.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao da renda
        BEGIN
          UPDATE tbcadast_pessoa_relacao
             SET idpessoa_relacao = pr_pessoa_relacao.idpessoa_relacao,
                 tprelacao        = pr_pessoa_relacao.tprelacao, 
                 cdoperad_altera  = pr_pessoa_relacao.cdoperad_altera
           WHERE idpessoa      = pr_pessoa_relacao.idpessoa
             AND nrseq_relacao = pr_pessoa_relacao.nrseq_relacao;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Este relacionamento ja existe. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_RELACAO: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_RELACAO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_relacao: ' ||SQLERRM;
  END;  

  -- Rotina para excluir relacionamento
  PROCEDURE pc_exclui_pessoa_relacao(pr_idpessoa        IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
															      ,pr_nrseq_relacao   IN tbcadast_pessoa_relacao.nrseq_relacao%TYPE -- Nr. de sequência de relacionamento
																		,pr_cdoperad_altera IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
																		,pr_cdcritic        OUT INTEGER                                   -- Codigo de erro
																		,pr_dscritic        OUT VARCHAR2) IS                              -- Retorno de Erro
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao de relacionamento
    BEGIN
      DELETE tbcadast_pessoa_relacao
       WHERE idpessoa      = pr_idpessoa
         AND nrseq_relacao = pr_nrseq_relacao;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_RELACAO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_relacao: ' ||SQLERRM;		
	END;

  -- Rotina para Cadastro de pessoa dependente
  PROCEDURE pc_cadast_pessoa_fisica_dep( pr_pessoa_fisica_dep IN OUT tbcadast_pessoa_fisica_dep%ROWTYPE -- Registro de pessoa dependente
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cadastro de pessoa dependente
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_dependente),0) + 1
        FROM tbcadast_pessoa_fisica_dep tb
       WHERE idpessoa = pr_pessoa_fisica_dep.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_fisica_dep.nrseq_dependente IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_fisica_dep.nrseq_dependente;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_fisica_dep
        ( idpessoa, 
          nrseq_dependente, 
          idpessoa_dependente, 
          tpdependente, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_fisica_dep.idpessoa, 
          pr_pessoa_fisica_dep.nrseq_dependente, 
          pr_pessoa_fisica_dep.idpessoa_dependente, 
          pr_pessoa_fisica_dep.tpdependente, 
          pr_pessoa_fisica_dep.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_fisica_dep
             SET idpessoa_dependente = pr_pessoa_fisica_dep.idpessoa_dependente, 
                 tpdependente        = pr_pessoa_fisica_dep.tpdependente, 
                 cdoperad_altera     = pr_pessoa_fisica_dep.cdoperad_altera 
           WHERE idpessoa         = pr_pessoa_fisica_dep.idpessoa
             AND nrseq_dependente = pr_pessoa_fisica_dep.nrseq_dependente;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Esta pessoa dependente ja existe. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_FISICA_DEP: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_FISICA_DEP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica_dep: ' ||SQLERRM;
  END pc_cadast_pessoa_fisica_dep;  
  
  -- Rotina para excluir Cadastro de pessoa dependente
  PROCEDURE pc_exclui_pessoa_fisica_dep( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                        ,pr_nrseq_dependente  IN tbcadast_pessoa_fisica_dep.nrseq_dependente%TYPE -- Nr. de sequência de relacionamento
                                        ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                        ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_fisica_dep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para excluir Cadastro de pessoa dependente
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_fisica_dep
       WHERE idpessoa         = pr_idpessoa
         AND nrseq_dependente = pr_nrseq_dependente;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_FISICA_DEP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_fisica_dep: ' ||SQLERRM;		
	END pc_exclui_pessoa_fisica_dep;
  
  -- Rotina para Cadastrar de resposansavel legal de pessoa de fisica
  PROCEDURE pc_cadast_pessoa_fisica_resp(pr_pessoa_fisica_resp IN OUT tbcadast_pessoa_fisica_resp%ROWTYPE -- Registro de pessoa dependente
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar de resposansavel legal de pessoa de fisica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_resp_legal),0) + 1
        FROM tbcadast_pessoa_fisica_resp tb
       WHERE idpessoa = pr_pessoa_fisica_resp.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_fisica_resp.nrseq_resp_legal IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_fisica_resp.nrseq_resp_legal;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_fisica_resp
        ( idpessoa, 
          nrseq_resp_legal, 
          idpessoa_resp_legal, 
          cdrelacionamento, 
          cdoperad_altera)

       VALUES
        ( pr_pessoa_fisica_resp.idpessoa, 
          pr_pessoa_fisica_resp.nrseq_resp_legal, 
          pr_pessoa_fisica_resp.idpessoa_resp_legal, 
          pr_pessoa_fisica_resp.cdrelacionamento, 
          pr_pessoa_fisica_resp.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_fisica_resp
             SET idpessoa_resp_legal = pr_pessoa_fisica_resp.idpessoa_resp_legal, 
                 cdrelacionamento    = pr_pessoa_fisica_resp.cdrelacionamento,   
                 cdoperad_altera     = pr_pessoa_fisica_resp.cdoperad_altera    
           WHERE idpessoa         = pr_pessoa_fisica_resp.idpessoa
             AND nrseq_resp_legal = pr_pessoa_fisica_resp.nrseq_resp_legal;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Esta pessoa responsavel legal ja existe. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_FISICA_RESP: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_FISICA_RESP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_fisica_resp: ' ||SQLERRM;
  END pc_cadast_pessoa_fisica_resp;  
  
  -- Rotina para excluir Cadastro de resposansavel legal de pessoa de fisica
  PROCEDURE pc_exclui_pessoa_fisica_resp( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                         ,pr_nrseq_resp_legal  IN tbcadast_pessoa_fisica_resp.nrseq_resp_legal%TYPE -- Nr. de sequência de relacionamento
                                         ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                         ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_fisica_resp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para excluir Cadastro de resposansavel legal de pessoa de fisica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_fisica_resp
       WHERE idpessoa         = pr_idpessoa
         AND nrseq_resp_legal = pr_nrseq_resp_legal;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_FISICA_RESP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_fisica_resp: ' ||SQLERRM;		
	END pc_exclui_pessoa_fisica_resp;
  
  -- Rotina para Cadastrar de pessoa de referencia
  PROCEDURE pc_cadast_pessoa_referencia (pr_pessoa_referencia IN OUT tbcadast_pessoa_referencia%ROWTYPE -- Registro de pessoa referencia
                                        ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                        ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar de pessoa de referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_referencia),0) + 1
        FROM tbcadast_pessoa_referencia tb
       WHERE idpessoa = pr_pessoa_referencia.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_referencia.nrseq_referencia IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_referencia.nrseq_referencia;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_referencia
        ( idpessoa, 
          nrseq_referencia, 
          idpessoa_referencia, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_referencia.idpessoa, 
          pr_pessoa_referencia.nrseq_referencia, 
          pr_pessoa_referencia.idpessoa_referencia, 
          pr_pessoa_referencia.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_referencia
             SET idpessoa_referencia = pr_pessoa_referencia.idpessoa_referencia,                  
                 cdoperad_altera     = pr_pessoa_referencia.cdoperad_altera    
           WHERE idpessoa         = pr_pessoa_referencia.idpessoa
             AND nrseq_referencia = pr_pessoa_referencia.nrseq_referencia;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Esta pessoa de referencia ('||pr_pessoa_referencia.idpessoa_referencia||
                          ') para a pessoa '||pr_pessoa_referencia.idpessoa||' ja existe. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_REFERENCIA: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_REFERENCIA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_referencia: ' ||SQLERRM;
  END pc_cadast_pessoa_referencia; 
  
  -- Rotina para excluir Cadastro de pessoa de referencia
  PROCEDURE pc_exclui_pessoa_referencia ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                         ,pr_nrseq_referencia  IN tbcadast_pessoa_referencia.nrseq_referencia%TYPE -- Nr. de sequência de relacionamento
                                         ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                         ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                         ,pr_dscritic         OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_referencia
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para excluir Cadastro de pessoa de referencia
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_referencia
       WHERE idpessoa         = pr_idpessoa
         AND nrseq_referencia = pr_nrseq_referencia;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_REFERENCIA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_referencia: ' ||SQLERRM;		
	END pc_exclui_pessoa_referencia;

  -- Rotina para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_cadast_pessoa_juridica_bco( pr_pessoa_juridica_bco IN OUT tbcadast_pessoa_juridica_bco%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cadastrar dados financeiros de pessoa juridica em outrao bancos.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_banco),0) + 1
        FROM tbcadast_pessoa_juridica_bco tb
       WHERE idpessoa = pr_pessoa_juridica_bco.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_juridica_bco.nrseq_banco IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_juridica_bco.nrseq_banco;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_juridica_bco
        ( idpessoa, 
          nrseq_banco, 
          cdbanco, 
          dsoperacao, 
          vloperacao, 
          dsgarantia, 
          dtvencimento, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_juridica_bco.idpessoa, 
          pr_pessoa_juridica_bco.nrseq_banco, 
          pr_pessoa_juridica_bco.cdbanco, 
          pr_pessoa_juridica_bco.dsoperacao, 
          pr_pessoa_juridica_bco.vloperacao, 
          pr_pessoa_juridica_bco.dsgarantia, 
          pr_pessoa_juridica_bco.dtvencimento, 
          pr_pessoa_juridica_bco.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_juridica_bco
             SET cdbanco         = pr_pessoa_juridica_bco.cdbanco, 
                 dsoperacao      = pr_pessoa_juridica_bco.dsoperacao, 
                 vloperacao      = pr_pessoa_juridica_bco.vloperacao, 
                 dsgarantia      = pr_pessoa_juridica_bco.dsgarantia, 
                 dtvencimento    = pr_pessoa_juridica_bco.dtvencimento, 
                 cdoperad_altera = pr_pessoa_juridica_bco.cdoperad_altera
           WHERE idpessoa        = pr_pessoa_juridica_bco.idpessoa
             AND nrseq_banco     = pr_pessoa_juridica_bco.nrseq_banco;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Dados financeiros ja existem. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIDICA_BCO: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIDICA_BCO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_bco: ' ||SQLERRM;
  END pc_cadast_pessoa_juridica_bco;  
  
  -- Rotina para  excluir Cadastro dados financeiros de pessoa juridica em outrao bancos.
  PROCEDURE pc_exclui_pessoa_juridica_bco ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_banco       IN tbcadast_pessoa_juridica_bco.nrseq_banco%TYPE -- Nr. de sequência de banco
                                           ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic         OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_bco
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir Cadastro dados financeiros de pessoa juridica em outrao bancos.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_juridica_bco tb
       WHERE tb.idpessoa    = pr_idpessoa
         AND tb.nrseq_banco = pr_nrseq_banco;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_JURIDICA_BCO: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_bco: ' ||SQLERRM;		
	END pc_exclui_pessoa_juridica_bco;

  -- Rotina para Cadastrar faturamento mensal de Pessoas Juridica
  PROCEDURE pc_cadast_pessoa_juridica_fat( pr_pessoa_juridica_fat IN OUT tbcadast_pessoa_juridica_fat%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cadastrar faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_faturamento),0) + 1
        FROM tbcadast_pessoa_juridica_fat tb
       WHERE idpessoa = pr_pessoa_juridica_fat.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_juridica_fat.nrseq_faturamento IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_juridica_fat.nrseq_faturamento;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_juridica_fat
        ( idpessoa, 
          nrseq_faturamento, 
          dtmes_referencia, 
          vlfaturamento_bruto, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_juridica_fat.idpessoa, 
          pr_pessoa_juridica_fat.nrseq_faturamento, 
          pr_pessoa_juridica_fat.dtmes_referencia, 
          pr_pessoa_juridica_fat.vlfaturamento_bruto,
          pr_pessoa_juridica_fat.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_juridica_fat
             SET dtmes_referencia     = pr_pessoa_juridica_fat.dtmes_referencia, 
                 vlfaturamento_bruto  = pr_pessoa_juridica_fat.vlfaturamento_bruto,
                 cdoperad_altera      = pr_pessoa_juridica_fat.cdoperad_altera
           WHERE idpessoa          = pr_pessoa_juridica_fat.idpessoa
             AND nrseq_faturamento = pr_pessoa_juridica_fat.nrseq_faturamento;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Dados de faturamento ja existem. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIDICA_FAT: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIDICA_FAT: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_fat: ' ||SQLERRM;
  END pc_cadast_pessoa_juridica_fat;  
  
  -- Rotina para excluir faturamento mensal de Pessoas Juridica
  PROCEDURE pc_exclui_pessoa_juridica_fat ( pr_idpessoa          IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_faturamento IN tbcadast_pessoa_juridica_fat.nrseq_faturamento%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera   IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic         OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic         OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_fat
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_juridica_fat tb
       WHERE tb.idpessoa          = pr_idpessoa
         AND tb.nrseq_faturamento = pr_nrseq_faturamento;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_JURIDICA_FAT: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_fat: ' ||SQLERRM;		
	END pc_exclui_pessoa_juridica_fat;

  -- Rotina para Cadastrar participacao societaria em outras empresas
  PROCEDURE pc_cadast_pessoa_juridica_ptp( pr_pessoa_juridica_ptp IN OUT tbcadast_pessoa_juridica_ptp%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cadastrar faturamento mensal de Pessoas Juridica
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_participacao),0) + 1
        FROM tbcadast_pessoa_juridica_ptp tb
       WHERE idpessoa = pr_pessoa_juridica_ptp.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_juridica_ptp.nrseq_participacao IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_juridica_ptp.nrseq_participacao;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_juridica_ptp
        ( idpessoa, 
          nrseq_participacao, 
          idpessoa_participacao, 
          persocio, 
          dtadmissao, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_juridica_ptp.idpessoa, 
          pr_pessoa_juridica_ptp.nrseq_participacao, 
          pr_pessoa_juridica_ptp.idpessoa_participacao, 
          pr_pessoa_juridica_ptp.persocio, 
          pr_pessoa_juridica_ptp.dtadmissao, 
          pr_pessoa_juridica_ptp.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_juridica_ptp
             SET idpessoa_participacao = pr_pessoa_juridica_ptp.idpessoa_participacao, 
                 persocio              = pr_pessoa_juridica_ptp.persocio, 
                 dtadmissao            = pr_pessoa_juridica_ptp.dtadmissao, 
                 cdoperad_altera       = pr_pessoa_juridica_ptp.cdoperad_altera
           WHERE idpessoa           = pr_pessoa_juridica_ptp.idpessoa
             AND nrseq_participacao = pr_pessoa_juridica_ptp.nrseq_participacao;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Participação ja existem. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIDICA_PTP: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIDICA_PTP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_ptp: ' ||SQLERRM;
  END pc_cadast_pessoa_juridica_ptp;  
  
  -- Rotina para excluir participacao societaria em outras empresas
  PROCEDURE pc_exclui_pessoa_juridica_ptp ( pr_idpessoa           IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_participacao IN tbcadast_pessoa_juridica_ptp.nrseq_participacao%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera    IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic          OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_ptp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir participacao societaria em outras empresas
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_juridica_ptp tb
       WHERE tb.idpessoa           = pr_idpessoa
         AND tb.nrseq_participacao = pr_nrseq_participacao;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_JURIDICA_PTP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_ptp: ' ||SQLERRM;		
	END pc_exclui_pessoa_juridica_ptp;

  -- Rotina para Cadastrar representantes da pessoa juridica.
  PROCEDURE pc_cadast_pessoa_juridica_rep( pr_pessoa_juridica_rep IN OUT tbcadast_pessoa_juridica_rep%ROWTYPE -- Registro de pessoa
                                          ,pr_cdcritic          OUT INTEGER                   -- Codigo de erro
                                          ,pr_dscritic          OUT VARCHAR2) IS              -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Cadastrar representantes da pessoa juridica.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Cursor para buscar a maior sequencia
    CURSOR cr_nrseq IS
      SELECT nvl(MAX(tb.nrseq_representante),0) + 1
        FROM tbcadast_pessoa_juridica_rep tb
       WHERE idpessoa = pr_pessoa_juridica_rep.idpessoa;   
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Se nao possui sequencia, busca a maior sequencia
    IF pr_pessoa_juridica_rep.nrseq_representante IS NULL THEN
      OPEN cr_nrseq;
      FETCH cr_nrseq INTO pr_pessoa_juridica_rep.nrseq_representante;
      CLOSE cr_nrseq;
    END IF;

    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_juridica_rep
        ( idpessoa, 
          nrseq_representante, 
          idpessoa_representante, 
          tpcargo_representante, 
          dtvigencia, 
          dtadmissao, 
          persocio, 
          flgdependencia_economica, 
          cdoperad_altera)
       VALUES
        ( pr_pessoa_juridica_rep.idpessoa, 
          pr_pessoa_juridica_rep.nrseq_representante, 
          pr_pessoa_juridica_rep.idpessoa_representante, 
          pr_pessoa_juridica_rep.tpcargo_representante, 
          pr_pessoa_juridica_rep.dtvigencia, 
          pr_pessoa_juridica_rep.dtadmissao, 
          pr_pessoa_juridica_rep.persocio, 
          pr_pessoa_juridica_rep.flgdependencia_economica, 
          pr_pessoa_juridica_rep.cdoperad_altera);
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_juridica_rep
             SET idpessoa_representante = pr_pessoa_juridica_rep.idpessoa_representante, 
                 tpcargo_representante  = pr_pessoa_juridica_rep.tpcargo_representante, 
                 dtvigencia             = pr_pessoa_juridica_rep.dtvigencia, 
                 dtadmissao             = pr_pessoa_juridica_rep.dtadmissao, 
                 persocio               = pr_pessoa_juridica_rep.persocio, 
                 flgdependencia_economica = pr_pessoa_juridica_rep.flgdependencia_economica, 
                 cdoperad_altera          = pr_pessoa_juridica_rep.cdoperad_altera
           WHERE idpessoa               = pr_pessoa_juridica_rep.idpessoa
             AND nrseq_representante    = pr_pessoa_juridica_rep.nrseq_representante;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Representante ja existem. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_JURIDICA_REP: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_JURIDICA_REP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_juridica_rep: ' ||SQLERRM;
  END pc_cadast_pessoa_juridica_rep; 
  
  -- Rotina para excluir representantes da pessoa juridica.
  PROCEDURE pc_exclui_pessoa_juridica_rep ( pr_idpessoa            IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa
                                           ,pr_nrseq_representante IN tbcadast_pessoa_juridica_rep.nrseq_representante%TYPE -- Nr. de sequência
                                           ,pr_cdoperad_altera     IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                           ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                           ,pr_dscritic          OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_juridica_rep
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir representantes da pessoa juridica.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_juridica_rep tb
       WHERE tb.idpessoa           = pr_idpessoa
         AND tb.nrseq_representante = pr_nrseq_representante;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_JURIDICA_REP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_juridica_rep: ' ||SQLERRM;		
	END pc_exclui_pessoa_juridica_rep;
  
  -- Rotina para Cadastrar pessoas politicamente expostas.
  PROCEDURE pc_cadast_pessoa_polexp( pr_pessoa_polexp IN OUT tbcadast_pessoa_polexp%ROWTYPE -- Registros de pessoa
                                    ,pr_cdcritic         OUT INTEGER                        -- Codigo de erro
                                    ,pr_dscritic         OUT VARCHAR2) IS                   -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_polexp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
      
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    
  
    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_polexp
        ( idpessoa,
          tpexposto,
          dtinicio,
          dttermino,
          idpessoa_empresa,
          cdocupacao,
          tprelacao_polexp,
          idpessoa_politico,
          cdoperad_altera
          )
       VALUES
        ( pr_pessoa_polexp.idpessoa,
          pr_pessoa_polexp.tpexposto,
          pr_pessoa_polexp.dtinicio,
          pr_pessoa_polexp.dttermino,
          pr_pessoa_polexp.idpessoa_empresa,
          pr_pessoa_polexp.cdocupacao,
          pr_pessoa_polexp.tprelacao_polexp,
          pr_pessoa_polexp.idpessoa_politico,
          pr_pessoa_polexp.cdoperad_altera
          );
    EXCEPTION
      WHEN dup_val_on_index THEN
        -- Efetua a atualizacao
        BEGIN
          UPDATE tbcadast_pessoa_polexp
             SET tpexposto         = pr_pessoa_polexp.tpexposto,
                 dtinicio          = pr_pessoa_polexp.dtinicio,
                 dttermino         = pr_pessoa_polexp.dttermino,
                 idpessoa_empresa  = pr_pessoa_polexp.idpessoa_empresa,
                 cdocupacao        = pr_pessoa_polexp.cdocupacao,
                 tprelacao_polexp  = pr_pessoa_polexp.tprelacao_polexp,
                 idpessoa_politico = pr_pessoa_polexp.idpessoa_politico,
                 cdoperad_altera   = pr_pessoa_polexp.cdoperad_altera
           WHERE idpessoa          = pr_pessoa_polexp.idpessoa;
        EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Pessoa politicamente exposta ja existem. Favor verificar!';
              RAISE vr_exc_erro;
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar TBCADAST_PESSOA_POLEXP: '||SQLERRM;
              RAISE vr_exc_erro;
        END;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCADAST_PESSOA_POLEXP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_polexp: ' ||SQLERRM;
  END pc_cadast_pessoa_polexp; 
  
  -- Rotina para excluir pessoas politicamente expostas.
  PROCEDURE pc_exclui_pessoa_polexp ( pr_idpessoa            IN tbcadast_pessoa.idpessoa%TYPE              -- Identificador de pessoa                                     
                                     ,pr_cdoperad_altera     IN tbcadast_pessoa.cdoperad_altera%TYPE       -- Operador que esta efetuando a exclusao																	
                                     ,pr_cdcritic          OUT INTEGER                                   -- Codigo de erro
                                     ,pr_dscritic          OUT VARCHAR2) IS                              -- Retorno de Erro
    /* ..........................................................................
    --
    --  Programa : pc_exclui_pessoa_polexp
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para excluir pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
       
    ---------------> VARIAVEIS <-----------------    
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    
    -- Atualiza a pessoa com o operador da exclusao
    BEGIN
      UPDATE tbcadast_pessoa
         SET cdoperad_altera = pr_cdoperad_altera,
             dtalteracao     = SYSDATE
        WHERE idpessoa       = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar TBCADAST_PESSOA: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
    -- Efetua a exclusao
    BEGIN
      DELETE tbcadast_pessoa_polexp tb
       WHERE tb.idpessoa           = pr_idpessoa;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir TBCADAST_PESSOA_POLEXP: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_exclui_pessoa_polexp: ' ||SQLERRM;		
	END pc_exclui_pessoa_polexp;
  
  -- Rotina para incluir registro que o cadastro de pessoa foi atualizado no sistema legado
  PROCEDURE pc_cadast_pessoa_atualiza( pr_cdcooper   IN tbcadast_pessoa_atualiza.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta   IN tbcadast_pessoa_atualiza.nrdconta%TYPE --> Numero da conta
                                      ,pr_idseqttl   IN tbcadast_pessoa_atualiza.idseqttl%TYPE --> Sequencial do titular
                                      ,pr_nmtabela   IN tbcadast_pessoa_atualiza.nmtabela%TYPE --> Nome da tabela alteradoa
                                      ,pr_dschave    IN tbcadast_pessoa_atualiza.dschave%TYPE DEFAULT NULL  --> Dados que compoem a chave da tabela   
                                      ,pr_cdcritic  OUT INTEGER                                --> Codigo de erro
                                      ,pr_dscritic  OUT VARCHAR2) IS                           --> Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_pessoa_atualiza
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Agosto/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar pessoas politicamente expostas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------       
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN        
  
    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcadast_pessoa_atualiza
        ( cdcooper, 
          nrdconta, 
          idseqttl, 
          nmtabela, 
          dschave, 
          insit_atualiza, 
          dhatualiza, 
          dhprocessa)
       VALUES
        ( pr_cdcooper,     --> cdcooper
          pr_nrdconta,     --> nrdconta
          pr_idseqttl,     --> idseqttl
          pr_nmtabela,     --> nmtabela
          pr_dschave,      --> dschave
          1, -- PENDENTE   --> insit_atualiza
          SYSDATE,         --> dhatualiza 
          NULL );          --> dhprocessa
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;       
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir tbcadast_pessoa_atualiza: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_cadast_pessoa_atualiza: ' ||SQLERRM;
  END pc_cadast_pessoa_atualiza; 

  -- Rotina para buscar a relacao da pessoa com demais pessoas
  PROCEDURE pc_busca_relacao_pessoa(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                                    pr_relacao  OUT vr_relacao%TYPE,
                                    pr_dscritic OUT VARCHAR2) IS
/*
     TpRelacao ==> 1-Conjuge
                   2-Empresa de trabalho do conjuge
                   3-Pai
                   4-Mae
                   5-Empresa de trabalho
                   10-Pessoa de referencia (contato)
                   20-Representante de uma PJ
                   23-Pai do Representante 
                   24-Mae do Representante 
                   30-Responsavel Legal
                   33-Pai do Responsavel Legal
                   34-Mae do Responsavel Legal
                   40-Dependente
                   50-Pessoa politicamente Exposta
                   51-Empresa do Politico Exposto
                   60-Empresa de Participacao (PJ)
*/
    -- Cursor para verificar se a pessoa eh conjuge, pai ou mae
    CURSOR cr_relacao(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE,
                      pr_tprelacao tbcadast_pessoa_relacao.tprelacao%TYPE) IS
      SELECT idpessoa,
             tprelacao
        FROM tbcadast_pessoa_relacao a
       WHERE a.idpessoa_relacao = pr_idpessoa
         AND a.tprelacao        = nvl(pr_tprelacao, a.tprelacao);
       
    -- Cursor para verificar se a pessoa eh uma empresa de trabalho
    CURSOR cr_fonte_renda IS
      SELECT idpessoa
        FROM tbcadast_pessoa_renda a
       WHERE a.idpessoa_fonte_renda = pr_idpessoa;

    -- Cursor para verificar se a pessoa eh pessoa de referencia (contato)
    CURSOR cr_referencia IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_referencia a
       WHERE a.idpessoa_referencia = pr_idpessoa;

    -- Cursor para verificar se a pessoa eh representante
    CURSOR cr_representante(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_juridica_rep a
       WHERE a.idpessoa_representante = pr_idpessoa;
       
    -- Cursor para verificar se a pessoa eh um responsavel legal
    CURSOR cr_resp_legal(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_fisica_resp a
       WHERE a.idpessoa_resp_legal = pr_idpessoa;    

    -- Cursor para verificar se a pessoa eh um dependente
    CURSOR cr_dependente IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_fisica_dep a
       WHERE a.idpessoa_dependente = pr_idpessoa;    

    -- Cursor para verificar se a pessoa eh um politico exposto
    CURSOR cr_pessoa_polexp IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_polexp a
       WHERE a.idpessoa_politico = pr_idpessoa;    

    -- Cursor para verificar se a pessoa eh um politico exposto
    CURSOR cr_empresa_polexp IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_polexp a
       WHERE a.idpessoa_empresa = pr_idpessoa;    

    -- Cursor para verificar se a pessoa eh uma empresa de participacao
    CURSOR cr_participacao IS
      SELECT a.idpessoa
        FROM tbcadast_pessoa_juridica_ptp a
       WHERE a.idpessoa_participacao = pr_idpessoa;    

    -- Tratamento de erros
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- Variaveis gerais
    ind PLS_INTEGER := 0; -- Indice da PL/Table de retorno

  BEGIN
    -- Verifica se a pessoa eh conjuge ou pai ou mae
    FOR rw_relacao IN cr_relacao(pr_idpessoa => pr_idpessoa,
                                 pr_tprelacao => NULL) LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_relacao.idpessoa;
      pr_relacao(ind).tprelacao := rw_relacao.tprelacao;
      
      -- Se for pai ou mae, deve-se verificar se eh de 
      -- algum responsavel legal ou representante
      IF rw_relacao.tprelacao IN (3,4) THEN
        -- Verifica se pai ou mae de algum responsavel legal
        FOR rw_resp_legal IN cr_resp_legal(rw_relacao.idpessoa) LOOP
          -- Inclui no cadastro de relacionamento
          ind := ind + 1;
          pr_relacao(ind).idpessoa := rw_relacao.idpessoa;
          pr_relacao(ind).tprelacao := 30 + rw_relacao.tprelacao;
          pr_relacao(ind).idpessoa_principal := rw_resp_legal.idpessoa;
        END LOOP;

        -- Verifica se pai ou mae de algum representante
        FOR rw_representante IN cr_representante(rw_relacao.idpessoa) LOOP
          -- Inclui no cadastro de relacionamento
          ind := ind + 1;
          pr_relacao(ind).idpessoa := rw_relacao.idpessoa;
          pr_relacao(ind).tprelacao := 20 + rw_relacao.tprelacao;
          pr_relacao(ind).idpessoa_principal := rw_representante.idpessoa;
        END LOOP;
        
      END IF; -- Fim da verificacao se eh pai ou mae
      
      
    END LOOP;

    -- Verifica se a pessoa eh uma empresa de trabalho
    FOR rw_fonte_renda IN cr_fonte_renda LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_fonte_renda.idpessoa;
      pr_relacao(ind).tprelacao := 5;
      
      -- Verifica se a pessoa da fonte de renda eh o conjuge de alguem
      FOR rw_relacao IN cr_relacao(pr_idpessoa => rw_fonte_renda.idpessoa,
                                   pr_tprelacao => 1) LOOP -- Somente conjuge
        -- Inclui no cadastro de relacionamento
        ind := ind + 1;
        pr_relacao(ind).idpessoa := rw_relacao.idpessoa;
        pr_relacao(ind).tprelacao := 2; -- Empresa de trabalho do conjuge
      END LOOP;
    END LOOP;

    -- Verifica se a pessoa eh pessoa de referencia
    FOR rw_referencia IN cr_referencia LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_referencia.idpessoa;
      pr_relacao(ind).tprelacao := 10;
    END LOOP;

    -- Verifica se a pessoa eh um representante
    FOR rw_representante IN cr_representante(pr_idpessoa) LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_representante.idpessoa;
      pr_relacao(ind).tprelacao := 20;
    END LOOP;

    -- Verifica se a pessoa eh um responsavel legal
    FOR rw_resp_legal IN cr_resp_legal(pr_idpessoa) LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_resp_legal.idpessoa;
      pr_relacao(ind).tprelacao := 30;
    END LOOP;

    -- Verifica se a pessoa eh um dependente
    FOR rw_dependente IN cr_dependente LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_dependente.idpessoa;
      pr_relacao(ind).tprelacao := 40;
    END LOOP;

    -- Verifica se a pessoa eh um politico exposto
    FOR rw_pessoa_polexp IN cr_pessoa_polexp LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_pessoa_polexp.idpessoa;
      pr_relacao(ind).tprelacao := 50;
    END LOOP;

    -- Verifica se a pessoa eh uma empresa de um politico exposto
    FOR rw_empresa_polexp IN cr_empresa_polexp LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_empresa_polexp.idpessoa;
      pr_relacao(ind).tprelacao := 51;
    END LOOP;

    -- Verifica se a pessoa eh uma empresa de participacao
    FOR rw_participacao IN cr_participacao LOOP
      -- Inclui no cadastro de relacionamento
      ind := ind + 1;
      pr_relacao(ind).idpessoa := rw_participacao.idpessoa;
      pr_relacao(ind).tprelacao := 60;
    END LOOP;

	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_relacao_pessoa: ' ||SQLERRM;
  END pc_busca_relacao_pessoa; 

  -- Retorna o CPF / CNPJ da pessoa
  FUNCTION fn_busca_cpfcgc(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) 
        RETURN NUMBER IS
    -- Cursor sobre as pessoas
    CURSOR cr_pessoa IS
      SELECT nrcpfcgc
        FROM tbcadast_pessoa
       WHERE idpessoa = pr_idpessoa;
    rw_pessoa cr_pessoa%ROWTYPE;
  BEGIN
    -- Busca o CPF/CNPJ com base no ID da pessoa
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    CLOSE cr_pessoa;
    
    -- Retorna o CPF / CNPJ encontrado
    RETURN rw_pessoa.nrcpfcgc;
  END;

  -- Procedure para retornar as contas PJ da CRAPASS
  PROCEDURE pc_busca_crapass(pr_nrcpfcgc  IN tbcadast_pessoa.nrcpfcgc%TYPE,
                             pr_tprelacao IN PLS_INTEGER,
                             pr_idpessoa tbcadast_pessoa.idpessoa%TYPE,
                             pr_conta     IN OUT vr_conta%TYPE) IS
    -- Cursor para buscar as contas dos PJs
    CURSOR cr_crapass IS
      SELECT cdcooper,
             nrdconta
        FROM crapass
       WHERE nrcpfcgc = pr_nrcpfcgc
         AND inpessoa <> 1;
    ind PLS_INTEGER;
  BEGIN
    -- Atualiza o indicador
    ind := pr_conta.count();
    
    IF pr_nrcpfcgc IS NOT NULL THEN
      -- Loop sobre os associados PJ
      FOR rw_crapass IN cr_crapass LOOP
        ind := ind + 1;
        pr_conta(ind).cdcooper := rw_crapass.cdcooper;
        pr_conta(ind).nrdconta := rw_crapass.nrdconta;
        pr_conta(ind).idseqttl := 1;
        pr_conta(ind).idpessoa := pr_idpessoa;
        pr_conta(ind).tprelacao:= pr_tprelacao;
      END LOOP;
    END IF;
  END;
                               
  -- Procedure para retornar as contas PF da CRAPTTL
  PROCEDURE pc_busca_crapttl(pr_nrcpfcgc  IN tbcadast_pessoa.nrcpfcgc%TYPE,
                             pr_tprelacao IN PLS_INTEGER,
                             pr_idpessoa tbcadast_pessoa.idpessoa%TYPE,
                             pr_conta     IN OUT vr_conta%TYPE) IS
    -- Cursor para buscar as contas dos titulares
    CURSOR cr_crapttl IS
      SELECT cdcooper,
             nrdconta,
             idseqttl
        FROM crapttl
       WHERE nrcpfcgc = pr_nrcpfcgc;
    ind PLS_INTEGER;
  BEGIN
    -- Atualiza o indicador
    ind := pr_conta.count();
    
    -- Verifica se o CPF nao eh nulo, pois pode ser um prospect
    IF pr_nrcpfcgc IS NOT NULL THEN
      -- Loop sobre os associados PJ
      FOR rw_crapttl IN cr_crapttl LOOP
        ind := ind + 1;
        pr_conta(ind).cdcooper := rw_crapttl.cdcooper;
        pr_conta(ind).nrdconta := rw_crapttl.nrdconta;
        pr_conta(ind).idseqttl := rw_crapttl.idseqttl;
        pr_conta(ind).idpessoa := pr_idpessoa;
        pr_conta(ind).tprelacao:= pr_tprelacao;
      END LOOP;
    END IF;
  END;
                             

  -- Rotina para buscar a relacao da pessoa com demais pessoas
  PROCEDURE pc_busca_relacao_conta(pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                                   pr_conta    OUT vr_conta%TYPE,
                                   pr_dscritic OUT VARCHAR2) IS
/*
     TpRelacao ==> 1-Conjuge
                   2-Empresa de trabalho do conjuge
                   3-Pai
                   4-Mae
                   5-Empresa de trabalho
                   10-Pessoa de referencia (contato)
                   20-Representante de uma PJ
                   23-Pai do Representante 
                   24-Mae do Representante 
                   30-Responsavel Legal
                   33-Pai do Responsavel Legal
                   34-Mae do Responsavel Legal
                   40-Dependente
                   50-Pessoa politicamente Exposta
                   51-Empresa do Politico Exposto
                   60-Empresa de Participacao (PJ)
*/       
    -- Tratamento de erros
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;

    -- Variaveis gerais
    vr_relacao cada0010.vr_relacao%TYPE; -- Relacao do IDPESSOA com as demais pessoas
    vr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE; -- Numero do CPF/CNPJ
    vr_inpessoa tbcadast_pessoa.tppessoa%TYPE; -- Tipo de pessoa
    
    PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
    -- Busca as relacoes
    cada0010.pc_busca_relacao_pessoa(pr_idpessoa => pr_idpessoa,
                                     pr_relacao => vr_relacao,
                                     pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    -- Encontra o CPF / CNPJ
    vr_nrcpfcgc := fn_busca_cpfcgc(pr_idpessoa => pr_idpessoa);
    
    -- Se encontrou CPF / CNPJ
    IF vr_nrcpfcgc IS NOT NULL THEN
      -- Busca as contas principais para PF
      pc_busca_crapttl(pr_nrcpfcgc  => vr_nrcpfcgc,
                       pr_tprelacao => 6, -- Principal da CRAPTTL
                       pr_idpessoa  => pr_idpessoa,
                       pr_conta     => pr_conta);
                       
      vr_inpessoa := 1;

      -- Se nao encontrou como titular, busca como PJ
      IF pr_conta.count() = 0 THEN
        vr_inpessoa := 2;
        -- Busca os associados PJ
        pc_busca_crapass(pr_nrcpfcgc  => vr_nrcpfcgc,
                         pr_tprelacao => 7, -- Principal da CRAPJUR
                         pr_idpessoa  => pr_idpessoa,
                         pr_conta     => pr_conta);
      END IF;
    END IF;
    
    -- Loop sobre os registros encontrados
    FOR x IN 1..vr_relacao.count LOOP
      -- Se o tipo de relacao for de conjuge ou empresa do conjuge
      IF vr_relacao(x).tprelacao IN (1,  -- Conjuge (crapcje)
                                     2,  -- Empresa de trabalho do conjuge (crapcje)
                                     3,  -- Pai (crapttl)
                                     4,  -- Mae (crapttl)
                                     5,  -- Empresa de trabalho (crapttl)
                                     10, -- Pessoa de referencia (crapavt onde tpctato = 5)
                                     20, -- Representante de uma PJ (crapavt onde tpctato = 6)
                                     23, -- Pai do Representante (crapavt onde tpctato = 6)
                                     24, -- Mae do Representante (crapavt onde tpctato = 6)
                                     30, -- Responsavel Legal (crapcrl)
                                     33, -- Pai do Responsavel Legal (crapcrl)
                                     34, -- Mae do Responsavel Legal (crapcrl)
                                     40, -- Dependente (crapdep)
                                     50, -- Pessoa politicamente Exposta (tbcadast_politico_exposto)
                                     51, -- Empresa do Politico Exposto (tbcadast_politico_exposto)
                                     60) -- Empresa de Participacao (PJ) (crapepa)
                                     THEN
        -- Encontra o CPF / CNPJ
        vr_nrcpfcgc := fn_busca_cpfcgc(pr_idpessoa => nvl(vr_relacao(x).idpessoa_principal, vr_relacao(x).idpessoa));
        
        -- Busca as contas principais
        pc_busca_crapttl(pr_nrcpfcgc  => vr_nrcpfcgc,
                         pr_tprelacao => vr_relacao(x).tprelacao,
                         pr_idpessoa  => nvl(vr_relacao(x).idpessoa_principal, vr_relacao(x).idpessoa),
                         pr_conta     => pr_conta);        

        -- Buscar somente se for PJ
        IF vr_inpessoa = 2 OR vr_relacao(x).tprelacao IN (10,20,23,24,60) THEN
          -- Busca os dados em contas PJ
          pc_busca_crapass(pr_nrcpfcgc  => vr_nrcpfcgc,
                           pr_tprelacao => vr_relacao(x).tprelacao,
                           pr_idpessoa  => nvl(vr_relacao(x).idpessoa_principal, vr_relacao(x).idpessoa),
                           pr_conta     => pr_conta);
        END IF;
      END IF;
    END LOOP;
    
	EXCEPTION
    WHEN vr_exc_erro THEN
      --Variavel de erro recebe erro ocorrido
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_busca_relacao_conta: ' ||SQLERRM;
  END pc_busca_relacao_conta; 

  -- Rotina para cadastrar aprovação de saque de cotas.
  PROCEDURE pc_cadast_aprov_saque_cotas( pr_tbcotas_saque_controle IN OUT tbcotas_saque_controle%ROWTYPE -- Registros de cotas aprovadas saque
                                        ,pr_cdcritic         OUT INTEGER                        -- Codigo de erro
                                        ,pr_dscritic         OUT VARCHAR2) IS                   -- Retorno de Erro
  
   /* ..........................................................................
    --
    --  Programa : pc_cadast_aprov_saque_cotas
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Everton Souza (Mouts)
    --  Data     : Setembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Cadastrar aprovação de saque de cotas.
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    cursor cr_tbcotas_saque_controle is
      select 1 flgpendente
        from tbcotas_saque_controle a
       where a.cdcooper = pr_tbcotas_saque_controle.cdcooper
         and a.nrdconta = pr_tbcotas_saque_controle.nrdconta
         and a.tpsaque  = pr_tbcotas_saque_controle.tpsaque 
         and a.dtefetivacao is null;

		rw_tbcotas_saque_controle cr_tbcotas_saque_controle%ROWTYPE;      
       
    ---------------> VARIAVEIS <-----------------     
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
  BEGIN
    -- Verifica aprovação de worflow saque cotas parcial pendente de efetivação
		OPEN cr_tbcotas_saque_controle;
		FETCH cr_tbcotas_saque_controle INTO rw_tbcotas_saque_controle;
			
		-- Se encontrou worflow pendente de efetivação
		IF rw_tbcotas_saque_controle.flgpendente = 1 THEN
			-- Fechar cursor
			CLOSE cr_tbcotas_saque_controle;
			-- Gerar crítica
			vr_dscritic := 'Já existe um workflow de saque de cotas parcial pendente de efetivação para esta conta';
			-- Levantar exceção
			RAISE vr_exc_erro;
		END IF;
    --
    -- Fechar cursor
		CLOSE cr_tbcotas_saque_controle;
    --
    -- Efetua a inclusao
    BEGIN
      INSERT INTO tbcotas_saque_controle
        (cdcooper,
         nrdconta,
         cdmotivo,
         tpsaque,
         iddevolucao,
         vlsaque,
         tpiniciativa,
         tpsituacao,
         dtintegracao,
         dtaprovwork,
         dtefetivacao,
         dtdesligamento,
         dtago,
         dtsolicitacao,
         dtcredito,
         cdoperad_aprov
          )
       VALUES
        ( pr_tbcotas_saque_controle.cdcooper,
          pr_tbcotas_saque_controle.nrdconta,
          pr_tbcotas_saque_controle.cdmotivo,
          pr_tbcotas_saque_controle.tpsaque,
          pr_tbcotas_saque_controle.iddevolucao,
          pr_tbcotas_saque_controle.vlsaque,
          pr_tbcotas_saque_controle.tpiniciativa,
          1,
          sysdate,
          pr_tbcotas_saque_controle.dtaprovwork,
          null,
          pr_tbcotas_saque_controle.dtdesligamento,
          null,
          pr_tbcotas_saque_controle.dtsolicitacao,
          pr_tbcotas_saque_controle.dtcredito,
          pr_tbcotas_saque_controle.cdoperad_aprov
          );
    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
        vr_dscritic := 'Erro de chave primária. Para esta Cooperativa/Conta já existe um aprovação cadastrada nesta data.';
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir TBCOTAS_SAQUE_CONTROLE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
	EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Montar descrição de erro não tratado
      pr_dscritic := 'CADA0010-Erro não tratado na pc_cadast_aprov_saque_cotas: ' ||SQLERRM;
  END pc_cadast_aprov_saque_cotas;   

  -- Rotina para Cadastrar de pessoa de referencia
  PROCEDURE pc_revalida_nome_cad_unc(pr_nrcpfcgc  IN tbcadast_pessoa.nrcpfcgc%TYPE --Numero do CPF/CNPJ
                                    ,pr_nmpessoa  IN tbcadast_pessoa.nmpessoa%TYPE --Nome da pessoa entrada 
                                    ,pr_nmpesout OUT tbcadast_pessoa.nmpessoa%TYPE --Nome da pessoa saida
                                    ,pr_cdcritic OUT INTEGER                       -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2) IS                  -- Retorno de Erro

   /* ..........................................................................
    --
    --  Programa : pc_revalida_nome_cad_unc
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Kelvin Ott
    --  Data     : Junho/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Rotina para devolver o nome da pessoa de acordo com o tipo da conta
    --             vinculada ao cadastro unificado (INC0018113).
    --
    -- Alteração : 
    -- ..........................................................................*/
    CURSOR cr_tbcadast_pessoa(pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
      SELECT cap.nmpessoa
            ,cap.tpcadastro
        FROM tbcadast_pessoa cap
       WHERE cap.nrcpfcgc = pr_nrcpfcgc;      
      rw_tbcadast_pessoa cr_tbcadast_pessoa%ROWTYPE;
  
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
  BEGIN

    /* Quando vir CPFCGC zerado não realiza busca de informação, devido poder ter 
       o cadastro desta pessoa na base (ALLEN DUNLAP COPELAND)  */  
    IF pr_nrcpfcgc = 0 THEN
      pr_nmpesout := pr_nmpessoa;
      RETURN;
    END IF;

    OPEN cr_tbcadast_pessoa(pr_nrcpfcgc);
      FETCH cr_tbcadast_pessoa     
        INTO rw_tbcadast_pessoa;
        
        IF cr_tbcadast_pessoa%NOTFOUND THEN
          rw_tbcadast_pessoa.tpcadastro := 0;        
        END IF;
        
    CLOSE cr_tbcadast_pessoa;
    
    /* 4 = Completo 3 = Intermediario */
    IF NVL(rw_tbcadast_pessoa.tpcadastro,0) IN (3,4) THEN
      pr_nmpesout := rw_tbcadast_pessoa.nmpessoa;
    ELSE
      pr_nmpesout := pr_nmpessoa;
    END IF;
    
	EXCEPTION      
    WHEN OTHERS THEN      
      CECRED.pc_internal_exception;            
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_revalida_nome_cad_unc: ' ||SQLERRM;
  END pc_revalida_nome_cad_unc;

  -- Rotina para Cadastrar de pessoa de referencia
  PROCEDURE pc_revalida_cnpj_cad_unc(pr_cdcooper  IN crapcop.cdcooper%TYPE         --Cooperativa
                                    ,pr_cdempres  IN crapemp.cdempres%TYPE         --Codigo da empresa
                                    ,pr_nrdocnpj  IN tbcadast_pessoa.nrcpfcgc%TYPE --CNPJ
                                    ,pr_nrcnpjot OUT tbcadast_pessoa.nrcpfcgc%TYPE --CNPJ saida
                                    ,pr_cdcritic OUT INTEGER                       -- Codigo de erro
                                    ,pr_dscritic OUT VARCHAR2) IS                  -- Retorno de Erro

   /* ..........................................................................
    --
    --  Programa : pc_revalida_cnpj_cad_unc
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Kelvin Ott
    --  Data     : Junho/2018.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    -- Frequencia: Sempre que for chamado
    -- Objetivo  : Rotina para devolver o cnpj da pessoa de acordo com o codigo da empresa (INC0018113).
    --
    -- Alteração :
    -- ..........................................................................*/
    CURSOR cr_crapemp(pr_cdcooper crapemp.cdcooper%TYPE
                     ,pr_cdempres crapemp.cdempres%TYPE) IS
      SELECT emp.nrdocnpj
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.cdempres = pr_cdempres;         
      rw_crapemp cr_crapemp%ROWTYPE;
  
    -- Tratamento de erros
	  vr_cdcritic crapcri.cdcritic%TYPE;
		vr_dscritic crapcri.dscritic%TYPE;
		vr_exc_erro EXCEPTION;
    
  BEGIN
    /* Quando vir EMPRESA zerado não realiza busca de informação, devido poder ter 
       o cadastro desta pessoa na base*/  
    IF pr_cdempres = 0 THEN
      pr_nrcnpjot := pr_nrdocnpj;
      RETURN;
    END IF;
    
    OPEN cr_crapemp(pr_cdcooper
                   ,pr_cdempres);
      FETCH cr_crapemp     
        INTO rw_crapemp;
                
        IF cr_crapemp%NOTFOUND THEN
          rw_crapemp.nrdocnpj := 0;        
        END IF;
        
    CLOSE cr_crapemp;
    
    IF NVL(rw_crapemp.nrdocnpj,0) <> 0 THEN
      pr_nrcnpjot := rw_crapemp.nrdocnpj;
    ELSE
      pr_nrcnpjot := pr_nrdocnpj;
    END IF;
    
	EXCEPTION      
    WHEN OTHERS THEN      
      CECRED.pc_internal_exception;            
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_revalida_cnpj_cad_unc: ' ||SQLERRM;
  END pc_revalida_cnpj_cad_unc;

END CADA0010;
/
