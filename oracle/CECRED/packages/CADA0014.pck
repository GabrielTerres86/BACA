CREATE OR REPLACE PACKAGE CECRED.CADA0014 is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0014
  --  Sistema  : Rotinas para auditoria e detalhes de cadastros
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para auditoria e buscar detalhes de cadastros
  --
  -- Alteracoes:   
  --  
  --             27/06/2018 Nova procedure PC_INSERE_COMUNIC_SOA - Alexandre Borgmann - Mout´s Tecnologia
  ---------------------------------------------------------------------------------------------------------------*/
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  --TempTable para armazenar os campos
  TYPE typ_tab_campos_hist IS TABLE OF tbcadast_campo_historico%ROWTYPE
    INDEX BY VARCHAR2(100);
                                                                
  --> Variavel tipo de rendimento
  TYPE typ_tab_tpfixo_variavel IS TABLE OF VARCHAR2(100)
       INDEX BY PLS_INTEGER;
  vr_tab_tpfixo_variavel typ_tab_tpfixo_variavel; 
  
  --------->>>> PROCUDURES/FUNCTIONS <<<<----------
  
  /*****************************************************************************/
  /**            Function para retornar campo de valor formatato             **/
  /*****************************************************************************/
  FUNCTION fn_formata_valor (pr_valor IN NUMBER) RETURN VARCHAR2; 
  
  /*****************************************************************************/
  /**            Procedure para carregar os campos da tabela hist.            **/
  /*****************************************************************************/
  PROCEDURE pc_carrega_campos( pr_nmdatela    IN craptel.nmdatela%TYPE    --> Nome da tela                              
                              ,pr_tab_campos OUT typ_tab_campos_hist);    --> Retorna campos da tabela historico
  
  /*****************************************************************************/
  /**            Procedure para gravar tabela de historico de pessoa          **/
  /*****************************************************************************/
  PROCEDURE pc_grava_hist_pessoa( pr_nmdatela    IN craptel.nmdatela%TYPE                           --> Nome da tela                              
                                 ,pr_nmdcampo    IN tbcadast_campo_historico.nmcampo%TYPE           --> Nome do campo
                                 ,pr_tab_campos  IN typ_tab_campos_hist                             --> Campos da tabela historico
                                 ,pr_idpessoa    IN tbcadast_pessoa_historico.idpessoa%TYPE         --> Id pessoa   
                                 ,pr_nrsequen    IN tbcadast_pessoa_historico.nrsequencia%TYPE      --> Sequencial do cadastro de pessoa
                                 ,pr_dhaltera    IN tbcadast_pessoa_historico.dhalteracao%TYPE      --> Data e hora da alteração
                                 ,pr_tpoperac    IN tbcadast_pessoa_historico.tpoperacao%TYPE       --> Tipo de operacao (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                                 ,pr_dsvalant    IN tbcadast_pessoa_historico.dsvalor_anterior%TYPE --> Valor anterior
                                 ,pr_dsvalnov    IN tbcadast_pessoa_historico.dsvalor_novo%TYPE     --> Valor novo
                                 ,pr_dsvalor_novo_original IN tbcadast_pessoa_historico.dsvalor_novo_original%TYPE DEFAULT NULL  -- Valor Original sem descrição
                                 ,pr_cdoperad    IN  tbcadast_pessoa_historico.cdoperad_altera%TYPE --> Operador
                                 ,pr_dscritic   OUT VARCHAR2                                        --> Retornar Critica 
                                 ); 
                                 
  /******************************************************************************/
  /**   Function para retornar operador da alteração da tbcadast_pessoa        **/
  /******************************************************************************/
  FUNCTION fn_cdoperad_alt (pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                            pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**   Function para retornar descrição da situação CPF/CNPJ                  **/
  /******************************************************************************/
  FUNCTION fn_desc_situacao_cpf_cnpj (pr_cdsituacao_rfb tbcadast_pessoa.cdsituacao_rfb%type) 
             RETURN VARCHAR2;
  
  /******************************************************************************/
  /**   Function para retornar descrição da tpconsulta_rfb CPF/CNPJ            **/
  /******************************************************************************/
  FUNCTION fn_desc_tpconsulta_rfb (pr_tpconsulta_rfb tbcadast_pessoa.tpconsulta_rfb%type) 
             RETURN VARCHAR2;        
  
  /******************************************************************************/
  /**   Procedure para retornar descrição da cidade  e uf                      **/
  /******************************************************************************/
  PROCEDURE pc_ret_desc_cidade_uf (pr_idcidade  IN crapmun.idcidade%TYPE,
                                   pr_dscidade OUT crapmun.dscidade%TYPE,
                                   pr_cdestado OUT crapmun.cdestado%TYPE,
                                   pr_dscritic OUT VARCHAR2);
     
  
  /******************************************************************************/
  /**   Function para retornar descrição da cidade                             **/
  /******************************************************************************/
  FUNCTION fn_desc_cidade (pr_idcidade  IN crapmun.idcidade%TYPE,
                           pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**   Function para retornar descrição da naturalidade                      **/
  /******************************************************************************/
  FUNCTION fn_desc_naturalidade (pr_cdnatura  IN tbcadast_pessoa_fisica.cdnaturalidade%TYPE,
                                 pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;     
  
  /******************************************************************************/
  /**   Function para retornar descrição da nacionalidade                      **/
  /******************************************************************************/
  FUNCTION fn_desc_nacionalidade (pr_cdnacion  IN tbcadast_pessoa_fisica.cdnacionalidade%TYPE,
                                  pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                  
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo nacionalidade                 **/
  /******************************************************************************/
  FUNCTION fn_desc_tpnacionalidade (pr_tpnacion  IN tbcadast_pessoa_fisica.tpnacionalidade%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;              
  
  /******************************************************************************/
  /**   Function para retornar descrição do grau escolaridade                  **/
  /******************************************************************************/
  FUNCTION fn_desc_grau_escolaridade (pr_cdgresco  IN tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;    
             
  /******************************************************************************/
  /**   Function para retornar descrição do curso superior                     **/
  /******************************************************************************/
  FUNCTION fn_desc_curso_superior (pr_cdcursup  IN tbcadast_pessoa_fisica.cdcurso_superior%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;   
             
  /******************************************************************************/
  /**   Function para retornar descrição do natureza ocupacao                  **/
  /******************************************************************************/
  FUNCTION fn_desc_natureza_ocupacao (pr_cdnatocp  IN tbcadast_pessoa_fisica.cdnatureza_ocupacao%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;      
             
  /******************************************************************************/
  /**   Function para retornar descrição do cnae                               **/
  /******************************************************************************/
  FUNCTION fn_desc_cnae (pr_cdcnae  IN tbcadast_pessoa_juridica.cdcnae%TYPE,
                         pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;            
             
  /******************************************************************************/
  /**   Function para retornar descrição do natureza juridica                               **/
  /******************************************************************************/
  FUNCTION fn_desc_natureza_juridica (pr_cdnatjur  IN tbcadast_pessoa_juridica.cdnatureza_juridica%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                                
             
  /******************************************************************************/
  /**   Function para retornar descrição do setor economico                    **/
  /******************************************************************************/
  FUNCTION fn_desc_setor_economico (pr_cdseteco  IN tbcadast_pessoa_juridica.cdsetor_economico%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;    
             
  /******************************************************************************/
  /**   Function para retornar descrição do ramo atividade                     **/
  /******************************************************************************/
  FUNCTION fn_desc_ramo_atividade (pr_cdrmativ  IN tbcadast_pessoa_juridica.cdramo_atividade%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                  
             
  /******************************************************************************/
  /**   Function para retornar descrição do turno                              **/
  /******************************************************************************/
  FUNCTION fn_desc_turno (pr_cdturno  IN tbcadast_pessoa_renda.cdturno%TYPE,
                          pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**   Function para retornar descrição do nivel cargo                        **/
  /******************************************************************************/
  FUNCTION fn_desc_nivel_cargo (pr_cdnivel_cargo  IN tbcadast_pessoa_renda.cdnivel_cargo%TYPE,
                                pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;         
             
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de dependente                 **/
  /******************************************************************************/
  FUNCTION fn_desc_tpdependente (pr_tpdependente  IN tbcadast_pessoa_fisica_dep.tpdependente%TYPE,
                                 pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;       

  /******************************************************************************/
  /**   Function para retornar descrição do relacionamento                     **/
  /******************************************************************************/
  FUNCTION fn_desc_relacionamento (pr_cdrelacionamento  IN tbcadast_relacion_resp_legal.cdrelacionamento%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
 /******************************************************************************/
  /**   Function para retornar descrição do tipo cargo representante           **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcargo_representante (pr_tpcargo_representante  IN tbcadast_pessoa_juridica_rep.tpcargo_representante%TYPE,
                                          pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                                 

  /******************************************************************************/
  /**   Function para retornar descrição do tipo de politicamente exposto      **/
  /******************************************************************************/
  FUNCTION fn_desc_tpexposto (pr_tpexposto  IN tbcadast_pessoa_polexp.tpexposto%TYPE,
                              pr_dscritic OUT VARCHAR2) 
           RETURN VARCHAR2;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de relacionamento             **/
  /******************************************************************************/
  FUNCTION fn_desc_tprelacao (pr_tprelacao  IN tbcadast_pessoa_relacao.tprelacao%TYPE,
                              pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de politicamente exposto      **/
  /******************************************************************************/
  FUNCTION fn_desc_tprelacao_polexp (pr_tprelacao_polexp  IN tbcadast_pessoa_polexp.tprelacao_polexp%TYPE,
                                     pr_dscritic OUT VARCHAR2) 
           RETURN VARCHAR2;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de renda                  **/
  /******************************************************************************/
  FUNCTION fn_desc_tprenda (pr_tprenda  IN tbcadast_pessoa_rendacompl.tprenda%TYPE,
                            pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;         
             
  /******************************************************************************/
  /**       Function para retornar descrição do tipo do endereco               **/
  /******************************************************************************/
  FUNCTION fn_desc_tpendereco (pr_tpendereco  IN tbcadast_pessoa_endereco.tpendereco%TYPE,
                               pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;               
             
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de imovel               **/
  /******************************************************************************/
  FUNCTION fn_desc_tpimovel (pr_tpimovel  IN tbcadast_pessoa_endereco.tpimovel%TYPE,
                             pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;             

  /******************************************************************************/
  /**       Function para retornar descrição do tipo de origem de cadastro     **/
  /******************************************************************************/
  FUNCTION fn_desc_tporigem_cadastro (pr_tporigem_cadastro  IN tbcadast_pessoa_endereco.tporigem_cadastro%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de documento              **/
  /******************************************************************************/
  FUNCTION fn_desc_tpdocumento (pr_tpdocumento  IN tbcadast_pessoa_fisica.tpdocumento%TYPE,
                                pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;   
             
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de sexo                   **/
  /******************************************************************************/
  FUNCTION fn_desc_tpsexo (pr_tpsexo  IN tbcadast_pessoa_fisica.tpsexo%TYPE,
                           pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;     

  /***********************************************************************************/
  /**Function para retornar descrição do indicador habilitacao/emancipacao do menor **/
  /***********************************************************************************/
  FUNCTION fn_desc_inhabilitacao_menor (pr_inhabilitacao_menor  IN tbcadast_pessoa_fisica.inhabilitacao_menor%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                              
             
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de cadastro de pessoa     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcadastro (pr_tpcadastro  IN tbcadast_pessoa.tpcadastro%TYPE,
                               pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;
             
  /******************************************************************************/
  /**     Function para retornar descrição do tipo de contrato de trabalho     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcontrato_trabalho (pr_tpcontrato_trabalho  IN tbcadast_pessoa_renda.tpcontrato_trabalho%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;                        

  /******************************************************************************/
  /**     Function para retornar descrição do tipo de comprovante de renda     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcomprov_renda (pr_tpcomprov_renda  IN tbcadast_pessoa_renda.tpcomprov_renda%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;             

  /******************************************************************************/
  /**     Function para retornar descrição do tipo de regimo de tributacao     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpregime_tributacao (pr_tpregime_tributacao  IN tbcadast_pessoa_juridica.tpregime_tributacao%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2;             

  /******************************************************************************/
  /**     Procedure para inserir na tabela TBCADAST_PESSOA_COMUNIC_SOA         **/
  /******************************************************************************/
  PROCEDURE pc_insere_comunic_soa(pr_nmdatela in cecred.tbcadast_pessoa_comunic_soa.nmtabela_oracle%type,
                                  pr_idpessoa in cecred.tbcadast_pessoa_comunic_soa.idpessoa%type,
                                  pr_nrsequen in cecred.tbcadast_pessoa_comunic_soa.nrsequencia%type,
                                  pr_dhaltera in cecred.tbcadast_pessoa_comunic_soa.dhalteracao%type,
                                  pr_tpoperacao in cecred.tbcadast_pessoa_comunic_soa.tpoperacao%type,
                                  pr_dscritic OUT VARCHAR2
                                 );
END CADA0014;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0014 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0014
  --  Sistema  : Rotinas para auditoria e detalhes de cadastros
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para auditoria e buscar detalhes de cadastros
  --
  -- Alteracoes:   
  --  
  --             27/06/2018 Nova procedure PC_INSERE_COMUNIC_SOA - Alexandre Borgmann - Mout´s Tecnologia
  ---------------------------------------------------------------------------------------------------------------*/


  /*****************************************************************************/
  /**            Procedure para carregar os campos da tabela hist.            **/
  /*****************************************************************************/
  PROCEDURE pc_carrega_campos( pr_nmdatela    IN craptel.nmdatela%TYPE    --> Nome da tela                              
                              ,pr_tab_campos OUT typ_tab_campos_hist) IS  --> Retorna campos da tabela historico
     
  /* ..........................................................................
    --
    --  Programa : pc_carrega_campos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para carregar os campos da tabela hist. 
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar campo historico
    CURSOR cr_campo_historico IS
      SELECT *
        FROM tbcadast_campo_historico cmp
       WHERE cmp.nmtabela_oracle = pr_nmdatela;        
    
  BEGIN
    pr_tab_campos.delete;
  
    FOR rw_campos IN cr_campo_historico LOOP
      pr_tab_campos(rw_campos.nmcampo) := rw_campos;    
    END LOOP;
  
  EXCEPTION 
    WHEN OTHERS THEN
      pr_tab_campos.delete;                    
  END pc_carrega_campos;

  /*****************************************************************************/
  /**            Function para retornar campo de valor formatato             **/
  /*****************************************************************************/
  FUNCTION fn_formata_valor (pr_valor IN NUMBER) RETURN VARCHAR2 IS  
     
  /* ..........................................................................
    --
    --  Programa : fn_formata_valor
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para carregar os campos da tabela hist. 
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------         
    
  BEGIN
    RETURN to_char(pr_valor, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS='',.''');
  
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN pr_valor;
  END fn_formata_valor;  
  
  
  /*****************************************************************************/
  /**            Procedure para criar campo na tabela histor.                 **/
  /*****************************************************************************/
  PROCEDURE pc_cria_campo_hist( pr_nmdatela   IN craptel.nmdatela%TYPE                  --> Nome da tela                              
                               ,pr_nmdcampo   IN tbcadast_campo_historico.nmcampo%TYPE  --> Nome do campo 
                               ,pr_idcampo   OUT tbcadast_campo_historico.idcampo%TYPE  --> Retorna id do campo
                               ,pr_dscritic  OUT VARCHAR2) IS                           --> Retorna critica
     
  /* ..........................................................................
    --
    --  Programa : pc_cria_campo_hist
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para criar campo na tabela histor.   
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    -- Buscar campo historico
    CURSOR cr_campo_hist IS
      SELECT col.TABLE_NAME
            ,col.COLUMN_NAME
            ,COM.COMMENTS
            ,cmp.idcampo
        FROM All_Tab_Columns  col
            ,all_col_comments COM
            ,tbcadast_campo_historico cmp
       WHERE col.OWNER = 'CECRED'
         AND col.TABLE_NAME  = upper(pr_nmdatela)
         AND col.COLUMN_NAME = upper(pr_nmdcampo)
         AND COM.OWNER       = col.OWNER
         AND com.TABLE_NAME  = col.TABLE_NAME
         AND com.COLUMN_NAME = col.COLUMN_NAME
         AND col.TABLE_NAME  = cmp.nmtabela_oracle(+)
         AND col.COLUMN_NAME = cmp.nmcampo(+)
       ORDER BY col.COLUMN_ID;        
    rw_campo_hist cr_campo_hist%ROWTYPE;
       
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION;
    
  BEGIN
  
  
    --> Verificar se o campo existe na tabela
    OPEN cr_campo_hist;
    FETCH cr_campo_hist INTO rw_campo_hist;
    
    --> Se nao existe na tabela, nao permite cadastra-lo
    IF cr_campo_hist%NOTFOUND THEN
      vr_dscritic := 'Campo '||pr_nmdcampo||' não existe na tabela '||pr_nmdatela;
      RAISE vr_exc_erro;
    --> Se ja esta cadastrado, apenas retorna id
    ELSIF rw_campo_hist.idcampo IS NOT NULL THEN
      pr_idcampo := rw_campo_hist.idcampo;
    ELSE      
       --> Inserir na tabela
       BEGIN
         INSERT INTO tbcadast_campo_historico
                     (nmtabela_oracle, 
                      nmcampo, 
                      dscampo)
              VALUES (upper(pr_nmdatela),     --> nmtabela_oracle
                      upper(pr_nmdcampo),     --> nmcampo 
                      rw_campo_hist.COMMENTS) --> dscampo      
             RETURNING idcampo INTO pr_idcampo;
       EXCEPTION 
         WHEN OTHERS THEN
           vr_dscritic := 'Não foi possivel cadastrar campo '||
                           pr_nmdatela||'.'||pr_nmdcampo||': '||SQLERRM;
           RAISE vr_exc_erro;
       END;    
    
    END IF;
  
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic; 
    
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao criar campo tbcadast_campo_historico: '||SQLERRM;
  END pc_cria_campo_hist;
  
  
  /*****************************************************************************/
  /**            Procedure para gravar tabela de historico de pessoa          **/
  /*****************************************************************************/
  PROCEDURE pc_grava_hist_pessoa( pr_nmdatela    IN craptel.nmdatela%TYPE                           --> Nome da tela                              
                                 ,pr_nmdcampo    IN tbcadast_campo_historico.nmcampo%TYPE           --> Nome do campo
                                 ,pr_tab_campos  IN typ_tab_campos_hist                             --> Campos da tabela historico
                                 ,pr_idpessoa    IN tbcadast_pessoa_historico.idpessoa%TYPE         --> Id pessoa   
                                 ,pr_nrsequen    IN tbcadast_pessoa_historico.nrsequencia%TYPE      --> Sequencial do cadastro de pessoa
                                 ,pr_dhaltera    IN tbcadast_pessoa_historico.dhalteracao%TYPE      --> Data e hora da alteração
                                 ,pr_tpoperac    IN tbcadast_pessoa_historico.tpoperacao%TYPE       --> Tipo de operacao (1-Inclusao/ 2-Alteracao/ 3-Exclusao)
                                 ,pr_dsvalant    IN tbcadast_pessoa_historico.dsvalor_anterior%TYPE --> Valor anterior
                                 ,pr_dsvalnov    IN tbcadast_pessoa_historico.dsvalor_novo%TYPE     --> Valor novo
                                 ,pr_dsvalor_novo_original IN tbcadast_pessoa_historico.dsvalor_novo_original%TYPE DEFAULT NULL  -- Valor Original sem descrição
                                 ,pr_cdoperad    IN  tbcadast_pessoa_historico.cdoperad_altera%TYPE --> operador
                                 ,pr_dscritic   OUT VARCHAR2                                        --> Retornar Critica 
                                 ) IS 
     
  /* ..........................................................................
    --
    --  Programa : pc_carrega_campos
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gravar tabela de historico de pessoa
    --
    --  Alteração :
    --
    --
    --              27/06/2018  Novo Campo pr_dsvalor_novo_original - Alexandre Borgmann - Mout´s Tecnologia

    -- ..........................................................................*/
    
    ---------------> VARIAVEIS <----------------- 
    vr_dscritic VARCHAR2(1000);
    vr_exc_erro EXCEPTION; 
    
    vr_idcampo  tbcadast_campo_historico.idcampo%TYPE;      
    
  BEGIN
  
    --> Validar campo
    IF pr_tab_campos.exists(UPPER(pr_nmdcampo)) THEN  
      vr_idcampo := pr_tab_campos(UPPER(pr_nmdcampo)).idcampo;
    ELSE
      --> Caso nao localizar, tenta criar
      pc_cria_campo_hist( pr_nmdatela   => pr_nmdatela   --> Nome da tela                              
                         ,pr_nmdcampo   => pr_nmdcampo   --> Nome do campo 
                         ,pr_idcampo    => vr_idcampo    --> Retorna id do campo
                         ,pr_dscritic   => vr_dscritic); 
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    END IF;     
  
    --> Inserir tabela
    BEGIN
      INSERT INTO tbcadast_pessoa_historico
                  ( idpessoa, 
                    nrsequencia, 
                    dhalteracao, 
                    tpoperacao, 
                    idcampo, 
                    dsvalor_anterior, 
                    dsvalor_novo, 
                    cdoperad_altera,
                    dsvalor_novo_original
                    )
           VALUES ( pr_idpessoa,          --> idpessoa
                    pr_nrsequen,          --> nrsequencia 
                    pr_dhaltera,          --> dhalteracao 
                    pr_tpoperac,          --> tpoperacao 
                    vr_idcampo,           --> cdcampo 
                    pr_dsvalant,          --> dsvalor_anterior
                    pr_dsvalnov,          --> dsvalor_novo 
                    pr_cdoperad,           --> cdoperad_altera
                    decode(pr_dsvalor_novo_original,null,pr_dsvalnov,pr_dsvalor_novo_original) --> dsvalor_novo_original
                    );
    
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel gravar tbcadast_pessoa_historico: '||SQLERRM; 
        RAISE vr_exc_erro;
    END;  
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel gravar tbcadast_pessoa_historico: '||SQLERRM; 
  END pc_grava_hist_pessoa;
  
  /******************************************************************************/
  /**   Function para retornar operador da alteração da tbcadast_pessoa        **/
  /******************************************************************************/
  FUNCTION fn_cdoperad_alt (pr_idpessoa  IN tbcadast_pessoa.idpessoa%TYPE,
                            pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_cdoperad_alt      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar operador da alteração da tbcadast_pessoa 
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    --> Buscar operador alteração
    CURSOR cr_pessoa IS
      SELECT pes.cdoperad_altera
        FROM tbcadast_pessoa pes
       WHERE pes.idpessoa = pr_idpessoa; 
    rw_pessoa cr_pessoa%ROWTYPE;               
    
    
  BEGIN
  
     --> Buscar operador alteração
     OPEN cr_pessoa;
     FETCH cr_pessoa INTO rw_pessoa;
     IF cr_pessoa%NOTFOUND THEN
       CLOSE cr_pessoa;
       pr_dscritic := 'Cadastro de pessoa não localizado.';
       RETURN NULL;  
       
     ELSE
       CLOSE cr_pessoa;
       RETURN rw_pessoa.cdoperad_altera ;      
     END IF;  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel identificar operador: '||SQLERRM;
      RETURN NULL;    
  END fn_cdoperad_alt;
    
  
  /******************************************************************************/
  /**   Function para retornar descrição da situação CPF/CNPJ                  **/
  /******************************************************************************/
  FUNCTION fn_desc_situacao_cpf_cnpj (pr_cdsituacao_rfb tbcadast_pessoa.cdsituacao_rfb%type) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_situacao_cpf_cnpj      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da situação CPF/CNPJ
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
   BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'CDSITUACAO_RFB',        --> Nome do dominio
                                     pr_cddomini   => pr_cdsituacao_rfb);      --> Codigo que deseja retornar descrição  
  
    RETURN vr_dsdcampo;
  END fn_desc_situacao_cpf_cnpj;
  
  /******************************************************************************/
  /**   Function para retornar descrição da tpconsulta_rfb CPF/CNPJ            **/
  /******************************************************************************/
  FUNCTION fn_desc_tpconsulta_rfb (pr_tpconsulta_rfb tbcadast_pessoa.tpconsulta_rfb%type) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpconsulta_rfb      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da tpconsulta_rfb CPF/CNPJ
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
                  
    vr_dsdcampo VARCHAR2(500);
                  
   BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPCONSULTA_RFB',        --> Nome do dominio
                                     pr_cddomini   => pr_tpconsulta_rfb);      --> Codigo que deseja retornar descrição         
  
  
    RETURN vr_dsdcampo;
  END fn_desc_tpconsulta_rfb;  
  
  /******************************************************************************/
  /**   Procedure para retornar descrição da cidade  e uf                      **/
  /******************************************************************************/
  PROCEDURE pc_ret_desc_cidade_uf (pr_idcidade  IN crapmun.idcidade%TYPE,
                                   pr_dscidade OUT crapmun.dscidade%TYPE,
                                   pr_cdestado OUT crapmun.cdestado%TYPE,
                                   pr_dscritic OUT VARCHAR2)  IS
     
  /* ..........................................................................
    --
    --  Programa : pc_ret_desc_cidade_uf      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da cidade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    CURSOR cr_crapmun IS
      SELECT mun.dscidade,
             mun.cdestado
        FROM crapmun mun
       WHERE mun.idcidade = pr_idcidade; 
    rw_crapmun cr_crapmun%ROWTYPE;
     
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    
                  
  BEGIN  
    OPEN cr_crapmun;
    FETCH cr_crapmun INTO rw_crapmun;
    IF cr_crapmun%NOTFOUND THEN
      CLOSE cr_crapmun;
      vr_dscritic := 'Municipio nao encontrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapmun;
    END IF;    
    
    pr_dscidade := rw_crapmun.dscidade;
    pr_cdestado := rw_crapmun.cdestado;
  
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar cidade: '||SQLERRM;
  END pc_ret_desc_cidade_uf;
  
  /******************************************************************************/
  /**   Function para retornar descrição da cidade                             **/
  /******************************************************************************/
  FUNCTION fn_desc_cidade (pr_idcidade  IN crapmun.idcidade%TYPE,
                           pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_cidade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da cidade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dscidade crapmun.dscidade%TYPE;
                  
  BEGIN  
    
     vr_dscidade := GENE0010.fn_desc_campo( pr_nmtabela => 'CRAPMUN',    --> Nome da tabela
                                   pr_nmcmpret => 'DSCIDADE',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'IDCIDADE',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_idcidade,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dscidade;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar cidade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_cidade;
  
  
  
  /******************************************************************************/
  /**   Function para retornar descrição da naturalidade                      **/
  /******************************************************************************/
  FUNCTION fn_desc_naturalidade (pr_cdnatura  IN tbcadast_pessoa_fisica.cdnaturalidade%TYPE,
                                 pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_naturalidade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da naturalidade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsnatura crapmun.dscidade%TYPE;
                  
  BEGIN  
    
    vr_dsnatura := fn_desc_cidade (pr_idcidade  => pr_cdnatura,
                                   pr_dscritic => pr_dscritic);
    RETURN vr_dsnatura;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar naturalidade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_naturalidade;
  
  
  /******************************************************************************/
  /**   Function para retornar descrição da nacionalidade                      **/
  /******************************************************************************/
  FUNCTION fn_desc_nacionalidade (pr_cdnacion  IN tbcadast_pessoa_fisica.cdnacionalidade%TYPE,
                                  pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_nacionalidade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição da nacionalidade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                 ( pr_nmtabela => 'CRAPNAC',    --> Nome da tabela
                                   pr_nmcmpret => 'DSNACION',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDNACION',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdnacion,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar nacionalidade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_nacionalidade;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo nacionalidade                 **/
  /******************************************************************************/
  FUNCTION fn_desc_tpnacionalidade (pr_tpnacion  IN tbcadast_pessoa_fisica.tpnacionalidade%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpnacionalidade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo nacionalidade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                 ( pr_nmtabela => 'GNTPNAC',    --> Nome da tabela
                                   pr_nmcmpret => 'RESTPNAC',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'TPNACION',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_tpnacion,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo nacionalidade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpnacionalidade;
  
  /******************************************************************************/
  /**   Function para retornar descrição do grau escolaridade                  **/
  /******************************************************************************/
  FUNCTION fn_desc_grau_escolaridade (pr_cdgresco  IN tbcadast_pessoa_fisica.cdgrau_escolaridade%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_grau_escolaridade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do grau escolaridade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                 ( pr_nmtabela => 'GNGRESC',    --> Nome da tabela
                                   pr_nmcmpret => 'DSESCOLA',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'GRESCOLA',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdgresco,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar grau escolaridade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_grau_escolaridade;
  
  /******************************************************************************/
  /**   Function para retornar descrição do curso superior                     **/
  /******************************************************************************/
  FUNCTION fn_desc_curso_superior (pr_cdcursup  IN tbcadast_pessoa_fisica.cdcurso_superior%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_curso_superior      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do curso superior
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo( 
                                   pr_nmtabela => 'GNCDFRM',    --> Nome da tabela
                                   pr_nmcmpret => 'DSFRMTTL',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDFRMTTL',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdcursup,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar curso superior: '||SQLERRM;
      RETURN NULL;
  END fn_desc_curso_superior;
  
  /******************************************************************************/
  /**   Function para retornar descrição do natureza ocupacao                  **/
  /******************************************************************************/
  FUNCTION fn_desc_natureza_ocupacao (pr_cdnatocp  IN tbcadast_pessoa_fisica.cdnatureza_ocupacao%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_natureza_ocupacao      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do natureza ocupacao
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                 ( pr_nmtabela => 'GNCDNTO',    --> Nome da tabela
                                   pr_nmcmpret => 'DSNATOCP',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDNATOCP',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdnatocp,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar natureza ocupacao: '||SQLERRM;
      RETURN NULL;
  END fn_desc_natureza_ocupacao;
  
  /******************************************************************************/
  /**   Function para retornar descrição do cnae                               **/
  /******************************************************************************/
  FUNCTION fn_desc_cnae (pr_cdcnae  IN tbcadast_pessoa_juridica.cdcnae%TYPE,
                         pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_cnae      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição cnae
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo( 
                                   pr_nmtabela => 'TBGEN_CNAE',    --> Nome da tabela
                                   pr_nmcmpret => 'DSCNAE',        --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDCNAE',        --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdcnae,       --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic);    --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar cnae: '||SQLERRM;
      RETURN NULL;
  END fn_desc_cnae;
  
  /******************************************************************************/
  /**   Function para retornar descrição do natureza juridica                               **/
  /******************************************************************************/
  FUNCTION fn_desc_natureza_juridica (pr_cdnatjur  IN tbcadast_pessoa_juridica.cdnatureza_juridica%TYPE,
                                      pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_natureza_juridica      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição natureza juridica
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo 
                                  (pr_nmtabela => 'GNCDNTJ',    --> Nome da tabela
                                   pr_nmcmpret => 'DSNATJUR',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDNATJUR',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdnatjur,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar natureza juridica: '||SQLERRM;
      RETURN NULL;
  END fn_desc_natureza_juridica;
  
  /******************************************************************************/
  /**   Function para retornar descrição do setor economico                    **/
  /******************************************************************************/
  FUNCTION fn_desc_setor_economico (pr_cdseteco  IN tbcadast_pessoa_juridica.cdsetor_economico%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_setor_economico      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição setor economico
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
    vr_dstextab craptab.dstextab%TYPE;
                  
  BEGIN  
    
    -- Buscar configuração na tabela
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3  --> Cecred
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'SETORECONO'
                                             ,pr_tpregist => pr_cdseteco);
            
            
    --Se Encontrou
    IF TRIM(vr_dstextab) IS NOT NULL THEN
     vr_dsdcampo := vr_dstextab;
    ELSE
      vr_dsdcampo := 'Nao Cadastrado';
    END IF;
    
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar setor economico: '||SQLERRM;
      RETURN NULL;
  END fn_desc_setor_economico;
  
  /******************************************************************************/
  /**   Function para retornar descrição do ramo atividade                     **/
  /******************************************************************************/
  FUNCTION fn_desc_ramo_atividade (pr_cdrmativ  IN tbcadast_pessoa_juridica.cdramo_atividade%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_ramo_atividade      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição ramo atividade
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                  (pr_nmtabela => 'GNRATIV',    --> Nome da tabela
                                   pr_nmcmpret => 'NMRMATIV',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDRMATIV',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdrmativ,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar ramo atividade: '||SQLERRM;
      RETURN NULL;
  END fn_desc_ramo_atividade;
  
  /******************************************************************************/
  /**   Function para retornar descrição do turno                              **/
  /******************************************************************************/
  FUNCTION fn_desc_turno (pr_cdturno  IN tbcadast_pessoa_renda.cdturno%TYPE,
                          pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_turno      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição turno
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
    vr_dstextab craptab.dstextab%TYPE;
                  
  BEGIN  
    
    -- Buscar configuração na tabela
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3  --> Cecred
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'DSCDTURNOS'
                                             ,pr_tpregist => pr_cdturno);
            
            
    --Se Encontrou
    IF TRIM(vr_dstextab) IS NOT NULL THEN
     vr_dsdcampo := vr_dstextab;
    ELSE
      vr_dsdcampo := 'Nao Cadastrado';
    END IF;
    
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar turno: '||SQLERRM;
      RETURN NULL;
  END fn_desc_turno;
 
  /******************************************************************************/
  /**   Function para retornar descrição do nivel cargo                        **/
  /******************************************************************************/
  FUNCTION fn_desc_nivel_cargo (pr_cdnivel_cargo  IN tbcadast_pessoa_renda.cdnivel_cargo%TYPE,
                                pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_nivel_cargo      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição nivel cargo
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                  (pr_nmtabela => 'GNCDNCG',    --> Nome da tabela
                                   pr_nmcmpret => 'DSNVLCGO',   --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDNVLCGO',   --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdnivel_cargo,  --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic); --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar nivel cargo: '||SQLERRM;
      RETURN NULL;
  END fn_desc_nivel_cargo;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de dependente                 **/
  /******************************************************************************/
  FUNCTION fn_desc_tpdependente (pr_tpdependente  IN tbcadast_pessoa_fisica_dep.tpdependente%TYPE,
                                 pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpdependente      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de dependente
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
    vr_dstextab craptab.dstextab%TYPE;
                  
  BEGIN  
    
    -- Buscar configuração na tabela
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 3  --> Cecred
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'DSTPDEPEND'
                                             ,pr_tpregist => pr_tpdependente);
            
            
    --Se Encontrou
    IF TRIM(vr_dstextab) IS NOT NULL THEN
     vr_dsdcampo := vr_dstextab;
    ELSE
      vr_dsdcampo := 'Nao Cadastrado';
    END IF;
    
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de dependente: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpdependente;
  
  /******************************************************************************/
  /**   Function para retornar descrição do relacionamento                     **/
  /******************************************************************************/
  FUNCTION fn_desc_relacionamento (pr_cdrelacionamento  IN tbcadast_relacion_resp_legal.cdrelacionamento%TYPE,
                                   pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_relacionamento      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do relacionamento 
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_campo
                                  (pr_nmtabela => 'TBCADAST_RELACION_RESP_LEGAL',    --> Nome da tabela
                                   pr_nmcmpret => 'DSRELACIONAMENTO ',               --> Nome do Campo a ser retornado
                                   pr_nmcamppk => 'CDRELACIONAMENTO ',               --> Nome do Campo da chave da tabela, pode ser passado 1 ou mais deparados por pipe "|"
                                   pr_dsvalpes => pr_cdrelacionamento,                --> Valor a ser pesquisado, pode ser passado 1 ou mais deparados por pipe "|" 
                                   pr_dscritic => pr_dscritic);                      --> Retorna critica
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar relacionamento : '||SQLERRM;
      RETURN NULL;
  END fn_desc_relacionamento;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo cargo representante           **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcargo_representante (pr_tpcargo_representante  IN tbcadast_pessoa_juridica_rep.tpcargo_representante%TYPE,
                                          pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpcargo_representante      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo cargo representante
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                  --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPCARGO_REPRESENTANTE',   --> Nome do dominio
                                     pr_cddomini   => pr_tpcargo_representante); --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo cargo representante: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpcargo_representante;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de politicamente exposto      **/
  /******************************************************************************/
  FUNCTION fn_desc_tpexposto (pr_tpexposto  IN tbcadast_pessoa_polexp.tpexposto%TYPE,
                              pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpexposto      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de politicamente exposto
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',      --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPEXPOSTO',   --> Nome do dominio
                                     pr_cddomini   => pr_tpexposto); --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de politicamente exposto: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpexposto;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de relacionamento             **/
  /******************************************************************************/
  FUNCTION fn_desc_tprelacao (pr_tprelacao  IN tbcadast_pessoa_relacao.tprelacao%TYPE,
                              pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tprelacao      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de relacionamento
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',            --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPRELACAO',         --> Nome do dominio
                                     pr_cddomini   => pr_tprelacao);       --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de relacionamento: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tprelacao;
  
  /******************************************************************************/
  /**   Function para retornar descrição do tipo de politicamente exposto      **/
  /******************************************************************************/
  FUNCTION fn_desc_tprelacao_polexp (pr_tprelacao_polexp  IN tbcadast_pessoa_polexp.tprelacao_polexp%TYPE,
                                     pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tprelacao      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de politicamente exposto
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',            --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPRELACAO_POLEXP',  --> Nome do dominio
                                     pr_cddomini   => pr_tprelacao_polexp);       --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de politicamente exposto: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tprelacao_polexp;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de renda                  **/
  /******************************************************************************/
  FUNCTION fn_desc_tprenda (pr_tprenda  IN tbcadast_pessoa_rendacompl.tprenda%TYPE,
                            pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tprenda      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de renda
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',            --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPRENDA',           --> Nome do dominio
                                     pr_cddomini   => pr_tprenda);         --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de renda: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tprenda;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo do endereco               **/
  /******************************************************************************/
  FUNCTION fn_desc_tpendereco (pr_tpendereco  IN tbcadast_pessoa_endereco.tpendereco%TYPE,
                               pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpendereco      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo do endereco 
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',            --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPENDERECO',        --> Nome do dominio
                                     pr_cddomini   => pr_tpendereco);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo do endereco : '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpendereco;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de imovel               **/
  /******************************************************************************/
  FUNCTION fn_desc_tpimovel (pr_tpimovel  IN tbcadast_pessoa_endereco.tpimovel%TYPE,
                             pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpimovel      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de imovel 
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',          --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPIMOVEL',        --> Nome do dominio
                                     pr_cddomini   => pr_tpimovel);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de imovel : '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpimovel;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de origem de cadastro     **/
  /******************************************************************************/
  FUNCTION fn_desc_tporigem_cadastro (pr_tporigem_cadastro  IN tbcadast_pessoa_endereco.tporigem_cadastro%TYPE,
                             pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tporigem_cadastro      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de origem de cadastro
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                   --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPORIGEM_CADASTRO',        --> Nome do dominio
                                     pr_cddomini   => pr_tporigem_cadastro);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de origem de cadastro : '||SQLERRM;
      RETURN NULL;
  END fn_desc_tporigem_cadastro;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de documento              **/
  /******************************************************************************/
  FUNCTION fn_desc_tpdocumento (pr_tpdocumento  IN tbcadast_pessoa_fisica.tpdocumento%TYPE,
                                pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpdocumento      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de documento
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',             --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPDOCUMENTO',        --> Nome do dominio
                                     pr_cddomini   => pr_tpdocumento);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de documento: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpdocumento;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de sexo                   **/
  /******************************************************************************/
  FUNCTION fn_desc_tpsexo (pr_tpsexo  IN tbcadast_pessoa_fisica.tpsexo%TYPE,
                           pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpsexo      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de sexo
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',        --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPSEXO',        --> Nome do dominio
                                     pr_cddomini   => pr_tpsexo);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de sexo: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpsexo;
  
  /***********************************************************************************/
  /**Function para retornar descrição do indicador habilitacao/emancipacao do menor **/
  /***********************************************************************************/
  FUNCTION fn_desc_inhabilitacao_menor (pr_inhabilitacao_menor  IN tbcadast_pessoa_fisica.inhabilitacao_menor%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_inhabilitacao_menor      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do indicador habilitacao/emancipacao do menor 
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                     --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'INHABILITACAO_MENOR',        --> Nome do dominio
                                     pr_cddomini   => pr_inhabilitacao_menor);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de habilitacao/menor: '||SQLERRM;
      RETURN NULL;
  END fn_desc_inhabilitacao_menor;
  
  /******************************************************************************/
  /**       Function para retornar descrição do tipo de cadastro de pessoa     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcadastro (pr_tpcadastro  IN tbcadast_pessoa.tpcadastro%TYPE,
                               pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpcadastro      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de cadastro de pessoa
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',            --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPCADASTRO',        --> Nome do dominio
                                     pr_cddomini   => pr_tpcadastro);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de cadastro de pessoa: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpcadastro;
  
  /******************************************************************************/
  /**     Function para retornar descrição do tipo de contrato de trabalho     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcontrato_trabalho (pr_tpcontrato_trabalho  IN tbcadast_pessoa_renda.tpcontrato_trabalho%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpcontrato_trabalho      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de contrato de trabalho
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                     --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPCONTRATO_TRABALHO',        --> Nome do dominio
                                     pr_cddomini   => pr_tpcontrato_trabalho);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de contrato de trabalho: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpcontrato_trabalho;
  
  /******************************************************************************/
  /**     Function para retornar descrição do tipo de comprovante de renda     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpcomprov_renda (pr_tpcomprov_renda  IN tbcadast_pessoa_renda.tpcomprov_renda%TYPE,
                                    pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpcomprov_renda      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de comprovante de renda
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                 --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPCOMPROV_RENDA',        --> Nome do dominio
                                     pr_cddomini   => pr_tpcomprov_renda);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de comprovante de renda: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpcomprov_renda;
  
  
  /******************************************************************************/
  /**     Function para retornar descrição do tipo de regimo de tributacao     **/
  /******************************************************************************/
  FUNCTION fn_desc_tpregime_tributacao (pr_tpregime_tributacao  IN tbcadast_pessoa_juridica.tpregime_tributacao%TYPE,
                                        pr_dscritic OUT VARCHAR2) 
             RETURN VARCHAR2 IS
     
  /* ..........................................................................
    --
    --  Programa : fn_desc_tpregime_tributacao      
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Setembro/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Function para retornar descrição do tipo de regimo de tributacao
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------
    vr_dsdcampo VARCHAR2(500);
                  
  BEGIN  
    
     vr_dsdcampo := GENE0010.fn_desc_dominio 
                                   ( pr_nmmodulo   => 'CADAST',                 --> Nome do modulo(CADAST, COBRAN, etc.)
                                     pr_nmdomini   => 'TPREGIME_TRIBUTACAO',    --> Nome do dominio
                                     pr_cddomini   => pr_tpregime_tributacao);      --> Codigo que deseja retornar descrição
                                     
    RETURN vr_dsdcampo;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel buscar tipo de regimo de tributacao: '||SQLERRM;
      RETURN NULL;
  END fn_desc_tpregime_tributacao;
  
/******************************************************************************/
/**     Procedure para inserir na tabela TBCADAST_PESSOA_COMUNIC_SOA         **/
/******************************************************************************/
  PROCEDURE pc_insere_comunic_soa(pr_nmdatela in cecred.tbcadast_pessoa_comunic_soa.nmtabela_oracle%type,
                                  pr_idpessoa in cecred.tbcadast_pessoa_comunic_soa.idpessoa%type,
                                  pr_nrsequen in cecred.tbcadast_pessoa_comunic_soa.nrsequencia%type,
                                  pr_dhaltera in cecred.tbcadast_pessoa_comunic_soa.dhalteracao%type,
                                  pr_tpoperacao in cecred.tbcadast_pessoa_comunic_soa.tpoperacao%type,
                                  pr_dscritic OUT VARCHAR2
                                 ) IS
      vr_idalteracao CECRED.TBCADAST_PESSOA_COMUNIC_SOA.IDALTERACAO%TYPE;
  BEGIN
      vr_idalteracao:= fn_sequence(pr_nmtabela => 'TBCADAST_PESSOA_COMUNIC_SOA',
                                   pr_nmdcampo => 'IDALTERACAO',
                                   pr_dsdchave => '0)');
                                   
      INSERT INTO CECRED.TBCADAST_PESSOA_COMUNIC_SOA(idalteracao,
                                                     nmtabela_oracle,
                                                     idpessoa,
                                                     nrsequencia,
                                                     dhalteracao,
                                                     tpoperacao
                                                    )
     VALUES (vr_idalteracao,
             pr_nmdatela,
             pr_idpessoa,
             pr_nrsequen,
             pr_dhaltera,
             pr_tpoperacao
            );

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel inserir na TBCADAST_PESSOA_COMUNIC_SOA: '||SQLERRM;
  END;
  
BEGIN  
  
  --> Tipo de rendimento
  IF vr_tab_tpfixo_variavel.count() = 0 THEN
    vr_tab_tpfixo_variavel(0) := 'Fixo';
    vr_tab_tpfixo_variavel(1) := 'Variavel';    
  END IF;
   
  
END CADA0014;
/
