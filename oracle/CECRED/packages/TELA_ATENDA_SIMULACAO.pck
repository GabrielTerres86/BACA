CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_SIMULACAO IS

  /* Type das parcelas do Pos-Fixado */
  TYPE typ_reg_tab_parcelas IS RECORD(
       cdcooper     tbepr_simulacao_parcela.cdcooper%TYPE
      ,nrdconta     tbepr_simulacao_parcela.nrdconta%TYPE
      ,nrsimula     tbepr_simulacao_parcela.nrsimula%TYPE
      ,nrparepr     tbepr_simulacao_parcela.nrparepr%TYPE
      ,vlparepr     tbepr_simulacao_parcela.vlparepr%TYPE
      ,dtvencto     tbepr_simulacao_parcela.dtvencto%TYPE);
      
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_parcelas IS TABLE OF typ_reg_tab_parcelas INDEX BY BINARY_INTEGER;
  
  PROCEDURE pc_grava_simulacao_parcela(pr_cdcooper IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                      ,pr_nrdconta IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                      ,pr_nrsimula IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                      ,pr_nrparepr IN tbepr_simulacao_parcela.nrparepr%type --> parcela
                                      ,pr_vlparepr IN tbepr_simulacao_parcela.vlparepr%type --> valor
                                      ,pr_dtvencto IN tbepr_simulacao_parcela.dtvencto%type --> vencimento
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2);  --> Descricao da critica

  PROCEDURE pc_retorna_simulacao_parcela (pr_cdcooper     IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                         ,pr_nrdconta     IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                         ,pr_nrsimula     IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                         ,pr_tab_parcelas OUT typ_tab_parcelas                     --> Parcelas da simulacao
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE                --> Codigo da critica
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE);              --> Descricao da critica 
  
  PROCEDURE pc_retorna_simulacao_parc_prog (pr_cdcooper     IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                           ,pr_nrdconta     IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                           ,pr_nrsimula     IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                           ,pr_tab_parcelas OUT CLOB                                 --> Parcelas do Emprestimo
                                           ,pr_cdcritic     OUT crapcri.cdcritic%TYPE                --> Codigo da critica
                                           ,pr_dscritic     OUT crapcri.dscritic%TYPE);              --> Descricao da critica
                                       
  PROCEDURE pc_remove_simulacao_parcela(pr_cdcooper IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                       ,pr_nrdconta IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                       ,pr_nrsimula IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) ; --> Descricao da critica
                                       
  PROCEDURE pc_busca_dados_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta                                   
                                    ,pr_idseqttl IN INTEGER               --> id do titular
                                    ,pr_dtmvtolt IN VARCHAR2              --> data da cooperativa
                                    ,pr_flgerlog IN INTEGER               --> falg para log da operacao
                                    ,pr_nrsimula INTEGER                  --> numero da simulacao
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK

  PROCEDURE pc_busca_simulacoes(pr_nrdconta IN crapass.nrdconta%TYPE -- Número da Conta do Cooperado
                               ,pr_idseqttl IN INTEGER   -- Titularidade do Cooperado 
                               ,pr_dtmvtolt IN VARCHAR2              --> Data de início para pesquisa
                               ,pr_flgerlog IN INTEGER               --> falg para log da operacao
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK  --
                               
  PROCEDURE pc_exclui_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE  --> nr da conta
                               ,pr_idseqttl IN INTEGER                --> id do titular da conta
                               ,pr_dtmvtolt IN VARCHAR2               --> data da cooperativa
                               ,pr_nrsimula INTEGER                   --> numero da simulacao
                               ,pr_flgerlog IN INTEGER                --> falg para log da operacao
                               ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK  --                                                              

  PROCEDURE pc_grava_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_idseqttl IN INTEGER
                              ,pr_dtmvtolt IN VARCHAR2
                              ,pr_cddopcao IN VARCHAR
                              ,pr_nrsimula IN INTEGER
                              ,pr_cdlcremp IN INTEGER
                              ,pr_vlemprst IN NUMBER
                              ,pr_qtparepr IN INTEGER
                              ,pr_dtlibera IN VARCHAR2
                              ,pr_dtdpagto IN VARCHAR2
                              ,pr_percetop IN NUMBER
                              ,pr_cdfinemp IN INTEGER
                              ,pr_idfiniof IN INTEGER
                              ,pr_flggrava IN INTEGER DEFAULT 1 
                              ,pr_idpessoa IN INTEGER
                              ,pr_nrseq_email IN tbcadast_pessoa_email.nrseq_email%TYPE
                              ,pr_nrseq_telefone IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE                                
                              ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                              ,pr_tpemprst	IN INTEGER
                              ,pr_idcarenc	IN INTEGER
                              ,pr_dtcarenc	IN VARCHAR2
                              ,pr_flgerlog IN INTEGER                --> falg para log da operacao
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) ;           --> Saida OK/NOK  --
                              

  PROCEDURE pc_imprime_simulacao(pr_nrdconta IN NUMBER,
                                 pr_idseqttl IN NUMBER,
                                 pr_dtmvtolt IN VARCHAR2,
                                 pr_nrsimula IN NUMBER,
                                 pr_dsiduser IN VARCHAR2,
                                 pr_flgerlog IN INTEGER,                --> falg para log da operacao
                                 pr_tpemprst	IN INTEGER,
                                 pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                 pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                 pr_retxml   IN OUT NOCOPY xmltype,     --> Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,              --> Nome do Campo
                                 pr_des_erro OUT VARCHAR2);             --> Saida OK/NOK  --
                                 
                                                                        
END TELA_ATENDA_SIMULACAO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_SIMULACAO IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_SIMULACAO
  --  Sistema  : Ayllos Web
  --  Autor    : Rafael faria - Supero
  --  Data     : Marco - 2017                 Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela Simulacao dentro da ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  FUNCTION format_date(pr_dt IN DATE) RETURN VARCHAR2 IS
    
  BEGIN
   RETURN to_char(pr_dt,'DD/MM/RRRR');

  END format_date;   

  FUNCTION format_vlr(pr_vlr IN NUMBER ) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_vlr,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''');
  END format_vlr;

  PROCEDURE pc_grava_simulacao_parcela(pr_cdcooper IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                      ,pr_nrdconta IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                      ,pr_nrsimula IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                      ,pr_nrparepr IN tbepr_simulacao_parcela.nrparepr%type --> parcela
                                      ,pr_vlparepr IN tbepr_simulacao_parcela.vlparepr%type --> valor
                                      ,pr_dtvencto IN tbepr_simulacao_parcela.dtvencto%type --> vencimento
                                      ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

  /* .............................................................................

    Programa: pc_grava_simulacao_parcela
    Sistema : Ayllos Web
    Autor   : Rafael faria - Supero
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Grava as parcelas da simulacao

    Alteracoes: 
    ..............................................................................*/
  
  BEGIN
    
    BEGIN
			INSERT INTO tbepr_simulacao_parcela
                 (cdcooper
                 ,nrdconta
                 ,nrsimula
                 ,nrparepr
                 ,vlparepr
                 ,dtvencto)
          VALUES (pr_cdcooper
						     ,pr_nrdconta
                 ,pr_nrsimula
                 ,pr_nrparepr
                 ,pr_vlparepr
                 ,pr_dtvencto);

		EXCEPTION
      WHEN OTHERS THEN
				pr_cdcritic := 0;
        pr_dscritic := 'Erro ao inserir tbepr_simulacao_parcela: ' || SQLERRM;
    END;
  END pc_grava_simulacao_parcela;

  PROCEDURE pc_retorna_simulacao_parcela (pr_cdcooper     IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                         ,pr_nrdconta     IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                         ,pr_nrsimula     IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                         ,pr_tab_parcelas OUT typ_tab_parcelas                  --> Parcelas da simulacao
                                         ,pr_cdcritic     OUT crapcri.cdcritic%TYPE                --> Codigo da critica
                                         ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS            --> Descricao da critica

    
    /* .............................................................................

    Programa: pc_retorna_simulacao_parcela
    Sistema : Ayllos Web
    Autor   : Rafael faria - Supero
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retorna as parcelas

    Alteracoes: 
    ..............................................................................*/
    CURSOR cr_parcela IS
      SELECT s.cdcooper
            ,s.nrdconta
            ,s.nrsimula
            ,s.nrparepr
            ,s.vlparepr
            ,s.dtvencto
        FROM tbepr_simulacao_parcela s
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta
         AND s.nrsimula = pr_nrsimula;
    rw_parcela cr_parcela%rowtype;

  BEGIN

    FOR rw_parcela in cr_parcela LOOP

      pr_tab_parcelas(rw_parcela.nrparepr).cdcooper := rw_parcela.cdcooper;
      pr_tab_parcelas(rw_parcela.nrparepr).nrdconta := rw_parcela.nrdconta;
      pr_tab_parcelas(rw_parcela.nrparepr).nrsimula := rw_parcela.nrsimula;
      pr_tab_parcelas(rw_parcela.nrparepr).nrparepr := rw_parcela.nrparepr;
      pr_tab_parcelas(rw_parcela.nrparepr).vlparepr := rw_parcela.vlparepr;
      pr_tab_parcelas(rw_parcela.nrparepr).dtvencto := rw_parcela.dtvencto;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao retornar simulacao parcelas: ' || SQLERRM;
  END pc_retorna_simulacao_parcela;

  PROCEDURE pc_retorna_simulacao_parc_prog (pr_cdcooper     IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                           ,pr_nrdconta     IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                           ,pr_nrsimula     IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                           ,pr_tab_parcelas OUT CLOB                                 --> Parcelas do Emprestimo
                                           ,pr_cdcritic     OUT crapcri.cdcritic%TYPE                --> Codigo da critica
                                           ,pr_dscritic     OUT crapcri.dscritic%TYPE) IS            --> Descricao da critica

    
    /* .............................................................................

    Programa: pc_retorna_simulacao_parc_prog
    Sistema : Ayllos Web
    Autor   : Rafael faria - Supero
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Retorna as parcelas

    Alteracoes: 
    ..............................................................................*/

    --
    vr_tab_parcelas typ_tab_parcelas;
    vr_index        VARCHAR(24);
    --
    vr_dstexto      VARCHAR2(32767);
    vr_string       VARCHAR2(32767);
    vr_cdcritic     crapcri.cdcritic%type;
    vr_dscritic     crapcri.dscritic%type;
    
    --
    vr_exc_erro               EXCEPTION;
  BEGIN
 
    pc_retorna_simulacao_parcela (pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrsimula => pr_nrsimula
                                 ,pr_tab_parcelas => vr_tab_parcelas
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      raise vr_exc_erro;
    END IF;
                                            
    -- Montar CLOB
		IF vr_tab_parcelas.COUNT > 0 THEN
        
			-- Criar documento XML
			dbms_lob.createtemporary(pr_tab_parcelas, TRUE); 
			dbms_lob.open(pr_tab_parcelas, dbms_lob.lob_readwrite);
        
			-- Insere o cabeçalho do XML 
			gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
														 ,pr_texto_completo => vr_dstexto 
														 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>'
														 );
         
			--Buscar Primeiro beneficiario
			vr_index:= vr_tab_parcelas.FIRST;

      --Percorrer todos os beneficiarios
			WHILE vr_index IS NOT NULL LOOP

        vr_string := '<parcela>'        ||
                     '<cdcooper>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).cdcooper),' ')              || '</cdcooper>'     ||
                     '<nrdconta>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).nrdconta),' ')              || '</nrdconta>'     ||
                     '<nrsimula>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).nrsimula),' ')              || '</nrsimula>'     ||
                     '<nrparepr>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).nrparepr),' ')              || '</nrparepr>'     ||
                     '<vlparepr>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).vlparepr),' ')              || '</vlparepr>'     ||
                     '<dtvencto>'     || NVL(TO_CHAR(vr_tab_parcelas(vr_index).dtvencto,'DD/MM/YYYY'),' ') || '</dtvencto>'     ||
                     '</parcela>';

				-- Escrever no XML
				gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
															 ,pr_texto_completo => vr_dstexto 
															 ,pr_texto_novo     => vr_string
															 ,pr_fecha_xml      => FALSE
															 );   
                                                    
				--Proximo Registro
				vr_index:= vr_tab_parcelas.NEXT(vr_index);
          
			END LOOP;  
        
			-- Encerrar a tag raiz 
			gene0002.pc_escreve_xml(pr_xml            => pr_tab_parcelas 
														 ,pr_texto_completo => vr_dstexto 
														 ,pr_texto_novo     => '</root>' 
														 ,pr_fecha_xml      => TRUE
														 );
                               
		END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao retornar simulacao parcelas: ' || SQLERRM;
  END pc_retorna_simulacao_parc_prog;
  
  PROCEDURE pc_remove_simulacao_parcela(pr_cdcooper IN tbepr_simulacao_parcela.cdcooper%type --> Cooperativa
                                       ,pr_nrdconta IN tbepr_simulacao_parcela.nrdconta%type --> Conta
                                       ,pr_nrsimula IN tbepr_simulacao_parcela.nrsimula%type --> simulacao
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica

  /* .............................................................................

    Programa: pc_remove_simulacao_parcela
    Sistema : Ayllos Web
    Autor   : Rafael faria - Supero
    Data    : Dezembro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Remover as parcelas da simulacao

    Alteracoes: 
    ..............................................................................*/

  BEGIN
   
    BEGIN
			DELETE FROM tbepr_simulacao_parcela
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND nrsimula = pr_nrsimula;

		EXCEPTION
      WHEN OTHERS THEN
				pr_cdcritic := 0;
        pr_dscritic := 'Erro ao remover tbepr_simulacao_parcela: ' || SQLERRM;
    END;
  END pc_remove_simulacao_parcela;

  PROCEDURE pc_busca_dados_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE --> nr da conta                                   
                                    ,pr_idseqttl IN INTEGER               --> id do titular
                                    ,pr_dtmvtolt IN VARCHAR2              --> data da cooperativa
                                    ,pr_flgerlog IN INTEGER               --> falg para log da operacao
                                    ,pr_nrsimula INTEGER                  --> numero da simulacao
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
  --
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_dados_simulacao
  --  Sistema  : Ayllos Web
  --  Sigla    : EMPR
  --  Autor    : Rafael R. Santos (AmCom) Projeto P438 - Simulação e Contratação
  --  Data     : Fevereiro/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que for chamada
  -- Objetivo  : recuperar dados de simulação
  --
  ---------------------------------------------------------------------------------------------------------------														
  --
  -- VARIAVEIS --
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  vr_des_reto VARCHAR2(10);
  vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);   
  vr_dscritic_param VARCHAR2(4000);   
  vr_exc_param EXCEPTION; 
  vr_dtmvtolt DATE;
  
  --
  vr_tcrapsim  empr0018.typ_tab_sim;
  vr_tparcepr  empr0018.typ_tab_parc_epr;
  vr_tab_erro  gene0001.typ_tab_erro;
  --
  --Controle de erro
  vr_exc_erro EXCEPTION;
  --
  --
  PROCEDURE pc_monta_xml_retorno(pr_tcrapsim IN empr0018.typ_tab_sim,
                                 pr_tparcepr IN empr0018.typ_tab_parc_epr,
                                 pr_nrdconta IN crapass.nrdconta%TYPE,
                                 pr_xml IN OUT xmltype ) IS
  --/
  vr_count_simulac NUMBER := 0;
  vr_count_parc NUMBER := 0;
  vr_nrdconta crapass.nrdconta%TYPE;
  idx INTEGER;
  --
  PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS  
  BEGIN
    gene0007.pc_insere_tag(pr_xml => pr_xml, 
                           pr_tag_pai => pr_tag_pai, 
                           pr_posicao => pr_posicao, 
                           pr_tag_nova => pr_tag_nova, 
                           pr_tag_cont => pr_tag_cont, 
                           pr_des_erro => pr_des_erro);
  END insere_tag;

  BEGIN
    --/
    pr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    vr_nrdconta := pr_nrdconta; 
    --/
    insere_tag(pr_xml      => pr_xml
              ,pr_tag_pai  => 'Dados'
              ,pr_posicao  =>  0
              ,pr_tag_nova => 'Simulacao'
              ,pr_tag_cont => NULL  
              ,pr_des_erro => pr_dscritic);
    --
    insere_tag(pr_xml => pr_xml,
               pr_tag_pai => 'Simulacao', 
               pr_posicao => vr_count_simulac, 
               pr_tag_nova => 'cdcooper', 
               pr_tag_cont => pr_tcrapsim(vr_nrdconta).cdcooper, 
               pr_des_erro => pr_des_erro);
      --/
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrdconta',pr_tcrapsim(vr_nrdconta).nrdconta,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrsimula',pr_tcrapsim(vr_nrdconta).nrsimula,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlemprst',format_vlr(pr_tcrapsim(vr_nrdconta).vlemprst),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'qtparepr',pr_tcrapsim(vr_nrdconta).qtparepr,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlparepr',format_vlr(pr_tcrapsim(vr_nrdconta).vlparepr),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'txmensal',format_vlr(pr_tcrapsim(vr_nrdconta).txmensal),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'txdiaria',format_vlr(pr_tcrapsim(vr_nrdconta).txdiaria),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdlcremp',pr_tcrapsim(vr_nrdconta).cdlcremp,pr_des_erro);
      --
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtdpagto',format_date(pr_tcrapsim(vr_nrdconta).dtdpagto),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofepr',format_vlr(pr_tcrapsim(vr_nrdconta).vliofepr),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlrtarif',format_vlr(pr_tcrapsim(vr_nrdconta).vlrtarif),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vllibera',format_vlr(pr_tcrapsim(vr_nrdconta).vllibera),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtmvtolt',format_date(pr_tcrapsim(vr_nrdconta).dtmvtolt),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'hrtransa',pr_tcrapsim(vr_nrdconta).hrtransa,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdoperad',pr_tcrapsim(vr_nrdconta).cdoperad,pr_des_erro);                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtlibera',format_date(pr_tcrapsim(vr_nrdconta).dtlibera),pr_des_erro);
                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlajuepr',format_vlr(pr_tcrapsim(vr_nrdconta).vlajuepr),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'percetop',format_vlr(pr_tcrapsim(vr_nrdconta).percetop),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdfinemp',pr_tcrapsim(vr_nrdconta).cdfinemp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idfiniof',pr_tcrapsim(vr_nrdconta).idfiniof,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofcpl',format_vlr(pr_tcrapsim(vr_nrdconta).vliofcpl),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofadc',format_vlr(pr_tcrapsim(vr_nrdconta).vliofadc),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdagenci',pr_tcrapsim(vr_nrdconta).cdagenci,pr_des_erro);            
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrdialib',pr_tcrapsim(vr_nrdconta).nrdialib,pr_des_erro);
                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dslcremp',pr_tcrapsim(vr_nrdconta).dslcremp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dsfinemp',pr_tcrapsim(vr_nrdconta).dsfinemp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdmodali',pr_tcrapsim(vr_nrdconta).cdmodali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dsmodali',pr_tcrapsim(vr_nrdconta).dsmodali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'tpfinali',pr_tcrapsim(vr_nrdconta).tpfinali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlrtotal',format_vlr(pr_tcrapsim(vr_nrdconta).vlrtotal),pr_des_erro);      
      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'tpemprst',pr_tcrapsim(vr_nrdconta).tpemprst,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idcarenc',pr_tcrapsim(vr_nrdconta).idcarenc,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlprecar',format_vlr(pr_tcrapsim(vr_nrdconta).vlprecar),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtcarenc',format_date(pr_tcrapsim(vr_nrdconta).dtcarenc),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtvalidade',format_date(pr_tcrapsim(vr_nrdconta).dtvalidade),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idsegmento',pr_tcrapsim(vr_nrdconta).idsegmento,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdorigem',pr_tcrapsim(vr_nrdconta).cdorigem,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idpessoa',pr_tcrapsim(vr_nrdconta).idpessoa,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrseq_telefone',pr_tcrapsim(vr_nrdconta).nrseq_telefone,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrseq_email',pr_tcrapsim(vr_nrdconta).nrseq_email,pr_des_erro);                  

      vr_count_simulac := vr_count_simulac+1;
      --
      --/
      insere_tag(pr_xml      => pr_xml
                ,pr_tag_pai  => 'Dados'
                ,pr_posicao  =>  0
                ,pr_tag_nova => 'Parcelas'
                ,pr_tag_cont => NULL  
                ,pr_des_erro => pr_dscritic);
      --
      FOR idx IN 1..pr_tparcepr.count
       LOOP
        --/
        insere_tag(pr_xml => pr_xml,
                   pr_tag_pai => 'Parcelas', 
                   pr_posicao => 0, 
                   pr_tag_nova => 'Parcela', 
                   pr_tag_cont => NULL, 
                   pr_des_erro => pr_des_erro);

        insere_tag(pr_xml => pr_xml,
                   pr_tag_pai => 'Parcela', 
                   pr_posicao =>  vr_count_parc, 
                   pr_tag_nova => 'cdcooper', 
                   pr_tag_cont => pr_tparcepr(idx).cdcooper, 
                   pr_des_erro => pr_des_erro);
        --/                               
        insere_tag(pr_xml,'Parcela',vr_count_parc,'nrdconta',pr_tparcepr(idx).nrdconta,pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'nrctremp',pr_tparcepr(idx).nrctremp,pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'nrparepr',pr_tparcepr(idx).nrparepr,pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'vlparepr',format_vlr(pr_tparcepr(idx).vlparepr),pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'dtparepr',format_date(pr_tparcepr(idx).dtparepr),pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'indpagto',pr_tparcepr(idx).indpagto,pr_des_erro);
        insere_tag(pr_xml,'Parcela',vr_count_parc,'dtvencto',pr_tparcepr(idx).dtvencto,pr_des_erro);
        --/
        vr_count_parc := vr_count_parc+1;
        --/        
      END LOOP;
                           
  END pc_monta_xml_retorno;
  --
  --/  
  BEGIN
   --/
   vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
   --
   --/ Recupera dados de log para consulta posterior
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
   --
   -- Verifica se houve erro recuperando informacoes de log
   --
   IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
   END IF;
   --/
   empr0018.pc_busca_dados_simulacao(pr_cdcooper => vr_cdcooper,
                                     pr_cdagenci => vr_cdagenci,
                                     pr_nrdcaixa => vr_nrdcaixa,
                                     pr_cdoperad => vr_cdoperad,
                                     pr_nmdatela => vr_nmdatela,
                                     pr_cdorigem => vr_idorigem,
                                     pr_nrdconta => pr_nrdconta,
                                     pr_idseqttl => pr_idseqttl,
                                     pr_dtmvtolt => vr_dtmvtolt,
                                     pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog),
                                     pr_nrsimula => pr_nrsimula,
                                     pr_tcrapsim => vr_tcrapsim, 
                                     pr_tparcepr => vr_tparcepr, 
                                     pr_cdcritic => vr_cdcritic, 
                                     pr_des_erro => vr_dscritic, 
                                     pr_des_reto => vr_des_reto, 
                                     pr_tab_erro => vr_tab_erro);                                       
    --/
    IF ( vr_cdcritic <> 0 OR  NOT ( vr_dscritic IS NULL ) )
     THEN
       RAISE vr_exc_erro;
    END IF;                                   
    --
    --/
    pc_monta_xml_retorno(vr_tcrapsim,vr_tparcepr,pr_nrdconta,pr_retxml);
    --
   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_atenda_simulacao.pc_busca_dados_simulacao: ' || SQLERRM;      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');  
  END  pc_busca_dados_simulacao;  
  
  PROCEDURE pc_busca_simulacoes(pr_nrdconta IN crapass.nrdconta%TYPE --> Número da Conta do Cooperado
                               ,pr_idseqttl IN INTEGER               --> Titularidade do Cooperado 
                               ,pr_dtmvtolt IN VARCHAR2              --> Data de início para pesquisa
                               ,pr_flgerlog IN INTEGER               --> falg para log da operacao
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK  --
  -- VARIAVEIS --
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  vr_des_reto VARCHAR2(10);
  vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);   
  vr_dscritic_param VARCHAR2(4000);   
  vr_exc_param EXCEPTION; 
  vr_tcrapsim  empr0018.typ_tab_sim; 
  vr_dtmvtolt DATE;

  vr_tparcepr  empr0018.typ_tab_parc_epr;
  vr_tab_erro  gene0001.typ_tab_erro;
  --
  --Controle de erro
  vr_exc_erro EXCEPTION;
  --
  PROCEDURE pc_monta_xml_retorno(pr_tcrapsim IN empr0018.typ_tab_sim,
                                 pr_xml IN OUT xmltype ) IS
  --/
  vr_count_simulac NUMBER := 0;
  vr_count_parc NUMBER := 0;
  vr_nrdconta crapass.nrdconta%TYPE;
  idx INTEGER;
  --
  PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS  
  BEGIN
    gene0007.pc_insere_tag(pr_xml => pr_xml, 
                           pr_tag_pai => pr_tag_pai, 
                           pr_posicao => pr_posicao, 
                           pr_tag_nova => pr_tag_nova, 
                           pr_tag_cont => pr_tag_cont, 
                           pr_des_erro => pr_des_erro);
  END insere_tag;


  BEGIN
    --/
    pr_xml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    vr_nrdconta := pr_nrdconta; 
    --/
    insere_tag(pr_xml      => pr_xml
              ,pr_tag_pai  => 'Dados'
              ,pr_posicao  =>  0
              ,pr_tag_nova => 'Simulacoes'
              ,pr_tag_cont => NULL  
              ,pr_des_erro => pr_dscritic);
    --    
    FOR idx IN 1..pr_tcrapsim.count LOOP
      --/
      insere_tag(pr_xml => pr_xml,
                 pr_tag_pai => 'Simulacoes', 
                 pr_posicao =>  0, 
                 pr_tag_nova => 'Simulacao', 
                 pr_tag_cont => NULL,
                 pr_des_erro => pr_des_erro);
      --/
      insere_tag(pr_xml => pr_xml,
                 pr_tag_pai => 'Simulacao', 
                 pr_posicao => vr_count_simulac, 
                 pr_tag_nova => 'cdcooper', 
                 pr_tag_cont => pr_tcrapsim(idx).cdcooper, 
                 pr_des_erro => pr_des_erro);
      --/
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrdconta',pr_tcrapsim(idx).nrdconta,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrsimula',pr_tcrapsim(idx).nrsimula,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlemprst',pr_tcrapsim(idx).vlemprst,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'qtparepr',pr_tcrapsim(idx).qtparepr,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlparepr',pr_tcrapsim(idx).vlparepr,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'txmensal',format_vlr(pr_tcrapsim(idx).txmensal),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'txdiaria',format_vlr(pr_tcrapsim(idx).txdiaria),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdlcremp',pr_tcrapsim(idx).cdlcremp,pr_des_erro);
      --
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtdpagto',format_date(pr_tcrapsim(idx).dtdpagto),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofepr',format_vlr(pr_tcrapsim(idx).vliofepr),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlrtarif',format_vlr(pr_tcrapsim(idx).vlrtarif),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vllibera',format_vlr(pr_tcrapsim(idx).vllibera),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtmvtolt',format_date(pr_tcrapsim(idx).dtmvtolt),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'hrtransa',pr_tcrapsim(idx).hrtransa,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdoperad',pr_tcrapsim(idx).cdoperad,pr_des_erro);                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtlibera',format_date(pr_tcrapsim(idx).dtlibera),pr_des_erro);
                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlajuepr',format_vlr(pr_tcrapsim(idx).vlajuepr),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'percetop',format_vlr(pr_tcrapsim(idx).percetop),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdfinemp',pr_tcrapsim(idx).cdfinemp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idfiniof',pr_tcrapsim(idx).idfiniof,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofcpl',format_vlr(pr_tcrapsim(idx).vliofcpl),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vliofadc',format_vlr(pr_tcrapsim(idx).vliofadc),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdagenci',pr_tcrapsim(idx).cdagenci,pr_des_erro);            
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrdialib',pr_tcrapsim(idx).nrdialib,pr_des_erro);
                  
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dslcremp',pr_tcrapsim(idx).dslcremp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dsfinemp',pr_tcrapsim(idx).dsfinemp,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdmodali',pr_tcrapsim(idx).cdmodali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dsmodali',pr_tcrapsim(idx).dsmodali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'tpfinali',pr_tcrapsim(idx).tpfinali,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlrtotal',format_vlr(pr_tcrapsim(idx).vlrtotal),pr_des_erro);      
      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'tpemprst',pr_tcrapsim(idx).tpemprst,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idcarenc',pr_tcrapsim(idx).idcarenc,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'vlprecar',format_vlr(pr_tcrapsim(idx).vlprecar),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtcarenc',format_date(pr_tcrapsim(idx).dtcarenc),pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'dtvalidade',format_date(pr_tcrapsim(idx).dtvalidade),pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idsegmento',pr_tcrapsim(idx).idsegmento,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'cdorigem',pr_tcrapsim(idx).cdorigem,pr_des_erro);
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'idpessoa',pr_tcrapsim(idx).idpessoa,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrseq_telefone',pr_tcrapsim(idx).nrseq_telefone,pr_des_erro);      
      insere_tag(pr_xml,'Simulacao',vr_count_simulac,'nrseq_email',pr_tcrapsim(idx).nrseq_email,pr_des_erro);                  


      vr_count_simulac := vr_count_simulac+1;
      --
      END LOOP;
                           
  END pc_monta_xml_retorno;
  
  
  --
  BEGIN
   --
   -- Recupera dados de log para consulta posterior
   --/
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
   --
   -- Verifica se houve erro recuperando informacoes de log
   --
   IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
   END IF;
   --
   --
   vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
   empr0018.pc_busca_simulacoes(pr_cdcooper => vr_cdcooper,
                                pr_cdagenci => vr_cdagenci,
                                pr_nrdcaixa => vr_nrdcaixa,
                                pr_cdoperad => vr_nrdcaixa,
                                pr_nmdatela => vr_nmdatela,
                                pr_cdorigem => vr_idorigem,
                                pr_nrdconta => pr_nrdconta,
                                pr_idseqttl => pr_idseqttl,
                                pr_dtmvtolt => vr_dtmvtolt,
                                pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog),
                                pr_tcrapsim => vr_tcrapsim,
                                pr_cdcritic => vr_cdcritic,
                                pr_des_erro => pr_des_erro,
                                pr_des_reto => vr_des_reto,
                                pr_tab_erro => vr_tab_erro );
   
   pc_monta_xml_retorno(vr_tcrapsim,pr_retxml);

   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_atenda_simulacao.pc_busca_simulacoes: ' || SQLERRM;      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');  
  END pc_busca_simulacoes;

  PROCEDURE pc_exclui_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE  --> nr da conta
                               ,pr_idseqttl IN INTEGER                --> id do titular da conta
                               ,pr_dtmvtolt IN VARCHAR2               --> data da cooperativa
                               ,pr_nrsimula INTEGER                   --> numero da simulacao
                               ,pr_flgerlog IN INTEGER                --> falg para log da operacao
                               ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK  --
  -- VARIAVEIS --
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  vr_des_reto VARCHAR2(10);
  vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);   
  vr_dscritic_param VARCHAR2(4000);   
  vr_exc_param EXCEPTION; 
  vr_dtmvtolt DATE;
  
  vr_tab_erro  gene0001.typ_tab_erro;
  --
  --Controle de erro
  vr_exc_erro EXCEPTION;
  --
  --
  BEGIN
    
   vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
   --
   -- Recupera dados de log para consulta posterior
   --/
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
   --
   -- Verifica se houve erro recuperando informacoes de log
   --
   IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
   END IF;
   --
   --
   empr0018.pc_exclui_simulacao(pr_cdcooper => vr_cdcooper, 
                                pr_cdagenci => vr_cdagenci, 
                                pr_nrdcaixa => vr_nrdcaixa, 
                                pr_cdoperad => vr_cdoperad, 
                                pr_nmdatela => vr_nmdatela, 
                                pr_cdorigem => vr_idorigem, 
                                pr_nrdconta => pr_nrdconta, 
                                pr_idseqttl => pr_idseqttl, 
                                pr_dtmvtolt => vr_dtmvtolt, 
                                pr_flgerlog => SYS.DIUTIL.int_to_bool(pr_flgerlog),
                                pr_nrsimula => pr_nrsimula, 
                                pr_cdcritic => vr_cdcritic,
                                pr_des_erro => vr_dScritic, 
                                pr_des_reto => vr_des_reto, 
                                pr_tab_erro => vr_tab_erro);

   IF NOT ( vr_des_reto = 'OK' )
     THEN
       RAISE vr_exc_erro;
   END IF;    
           
   pr_des_erro := vr_des_reto;
                        
   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic || '</Erro></Root>');    
   WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_atenda_simulacao.pc_exclui_simulacao '|| pr_dtmvtolt||' : ' || SQLERRM;      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');  
  END pc_exclui_simulacao;

  PROCEDURE pc_grava_simulacao(pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_idseqttl IN INTEGER
                              ,pr_dtmvtolt IN VARCHAR2
                              ,pr_cddopcao IN VARCHAR
                              ,pr_nrsimula IN INTEGER
                              ,pr_cdlcremp IN INTEGER
                              ,pr_vlemprst IN NUMBER
                              ,pr_qtparepr IN INTEGER
                              ,pr_dtlibera IN VARCHAR2
                              ,pr_dtdpagto IN VARCHAR2
                              ,pr_percetop IN NUMBER
                              ,pr_cdfinemp IN INTEGER
                              ,pr_idfiniof IN INTEGER
                              ,pr_flggrava IN INTEGER DEFAULT 1 
                              ,pr_idpessoa IN INTEGER
                              ,pr_nrseq_email IN tbcadast_pessoa_email.nrseq_email%TYPE
                              ,pr_nrseq_telefone IN tbcadast_pessoa_telefone.nrseq_telefone%TYPE                                
                              ,pr_idsegmento tbepr_segmento.idsegmento%TYPE
                              ,pr_tpemprst	IN INTEGER
                              ,pr_idcarenc	IN INTEGER
                              ,pr_dtcarenc	IN VARCHAR2
                              ,pr_flgerlog IN INTEGER                --> falg para log da operacao
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK  --
                             

  --
  -- VARIAVEIS --
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  vr_des_reto VARCHAR2(10);
  vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
  vr_retorno  empr0018.typ_reg_crapsim;
  vr_dtmvtolt DATE;
  Vr_dtlibera DATE;
  Vr_dtdpagto DATE;
  vr_dtcarenc DATE;
  
  vr_nrgravad INTEGER;
  vr_txcetano NUMBER;  
  --
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);   
  vr_dscritic_param VARCHAR2(4000);   
  vr_exc_param EXCEPTION;   
  --/
  vr_tab_erro  gene0001.typ_tab_erro;
  --
  --Controle de erro
  vr_exc_erro EXCEPTION;
  --
  PROCEDURE monta_xml_retorno(pr_retxml IN OUT xmltype) IS
    
   PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                      ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                      ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                      ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                      ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                      ,pr_des_erro OUT VARCHAR2) IS  
   BEGIN
     gene0007.pc_insere_tag(pr_xml => pr_xml, 
                            pr_tag_pai => pr_tag_pai, 
                            pr_posicao => pr_posicao, 
                            pr_tag_nova => pr_tag_nova, 
                            pr_tag_cont => pr_tag_cont, 
                            pr_des_erro => pr_des_erro);
   END insere_tag;
 
  BEGIN
    
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    insere_tag(pr_xml      => pr_retxml
              ,pr_tag_pai  => 'Dados'
              ,pr_posicao  =>  0
              ,pr_tag_nova => 'nrgravad'
              ,pr_tag_cont => vr_nrgravad  
              ,pr_des_erro => pr_dscritic);

     insere_tag(pr_xml      => pr_retxml
               ,pr_tag_pai  => 'Dados'
               ,pr_posicao  =>  0
               ,pr_tag_nova => 'txcetano'
               ,pr_tag_cont => vr_txcetano  
               ,pr_des_erro => pr_dscritic);
               
  END monta_xml_retorno;

  --
 BEGIN   
  --
  BEGIN
    vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
    vr_dtlibera := to_date(pr_dtlibera,'DD/MM/RRRR');
    vr_dtdpagto := to_date(pr_dtdpagto,'DD/MM/RRRR');
    vr_dtcarenc := to_date(pr_dtcarenc,'DD/MM/RRRR');
    
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Data inválida!';
      pr_nmdcampo := 'dtdpagto';
      RAISE vr_exc_erro;
  END;

  
  --
  -- Recupera dados de log para consulta posterior
  --/
  gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nmeacao  => vr_nmeacao
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_nrdcaixa => vr_nrdcaixa
                          ,pr_idorigem => vr_idorigem
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic);
   --
   -- Verifica se houve erro recuperando informacoes de log
   --
   IF NOT ( vr_dscritic IS NULL )
      THEN
        RAISE vr_exc_erro;
   END IF;
   --
   --/
   empr0018.pc_grava_simulacao(pr_cdcooper => vr_cdcooper,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_cdoperad => vr_cdoperad,
                               pr_nmdatela => vr_nmdatela,
                               pr_cdorigem => vr_idorigem,
                               pr_nrdconta => pr_nrdconta,
                               pr_idseqttl => pr_idseqttl, 
                               pr_dtmvtolt => vr_dtmvtolt, 
                               pr_flgerlog => sys.diutil.int_to_bool(pr_flgerlog),
                               pr_cddopcao => pr_cddopcao, 
                               pr_nrsimula => pr_nrsimula, 
                               pr_cdlcremp => pr_cdlcremp, 
                               pr_vlemprst => pr_vlemprst,
                               pr_qtparepr => pr_qtparepr,
                               pr_dtlibera => vr_dtlibera,
                               pr_dtdpagto => vr_dtdpagto,
                               pr_percetop => pr_percetop,
                               pr_cdfinemp => pr_cdfinemp,
                               pr_idfiniof => pr_idfiniof,
                               pr_nrgravad => vr_nrgravad,
                               pr_txcetano => vr_txcetano,
                               pr_cdcritic => vr_cdcritic,
                               pr_des_erro => vr_dscritic, 
                               pr_des_reto => vr_des_reto, 
                               pr_tab_erro => vr_tab_erro,
                               pr_retorno  => vr_retorno,
                               pr_flggrava => pr_flggrava ,
                               pr_idpessoa => pr_idpessoa ,
                               pr_nrseq_email => pr_nrseq_email ,
                               pr_nrseq_telefone => pr_nrseq_telefone,
                               pr_idsegmento => pr_idsegmento,
                               pr_tpemprst => pr_tpemprst,
                               pr_idcarenc => pr_idcarenc,
                               pr_dtcarenc => vr_dtcarenc);
  --
   IF NOT ( vr_des_reto = 'OK' )
     THEN
       RAISE vr_exc_erro;
   END IF;    
       
   monta_xml_retorno(pr_retxml);
   pr_des_erro := 'OK';
 
  --/ 
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_atenda_simulacao.pc_grava_simulacao: ' || SQLERRM;
      vr_dscritic := pr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic ||'</Erro></Root>');  
  END pc_grava_simulacao;
  
  PROCEDURE pc_imprime_simulacao(pr_nrdconta IN NUMBER,
                                 pr_idseqttl IN NUMBER,
                                 pr_dtmvtolt IN VARCHAR2,
                                 pr_nrsimula IN NUMBER,
                                 pr_dsiduser IN VARCHAR2,
                                 pr_flgerlog IN INTEGER,                --> falg para log da operacao
                                 pr_tpemprst	IN INTEGER,
                                 pr_xmllog   IN VARCHAR2,               --> XML com informações de LOG
                                 pr_cdcritic OUT PLS_INTEGER,           --> Código da crítica
                                 pr_dscritic OUT VARCHAR2,              --> Descrição da crítica
                                 pr_retxml   IN OUT NOCOPY xmltype,     --> Arquivo de retorno do XML
                                 pr_nmdcampo OUT VARCHAR2,              --> Nome do Campo
                                 pr_des_erro OUT VARCHAR2 ) IS          --> Saida OK/NOK  --
                                
  --
  -- VARIAVEIS --
  --
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;        
  vr_des_reto VARCHAR2(10);
  vr_tppessoa tbepr_segmento_tppessoa_perm.tppessoa%TYPE;
  vr_retorno  empr0018.typ_reg_crapsim;
  vr_dtmvtolt DATE;
  vr_nmarqimp VARCHAR2(200);
  vr_nmarqpdf VARCHAR2(200);  
  --
  -- Variaveis de log
  vr_cdcooper crapcop.cdcooper%TYPE;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);   
  vr_dscritic_param VARCHAR2(4000);   
  vr_exc_param EXCEPTION; 
  --/
  vr_tab_erro  gene0001.typ_tab_erro;
  --
  --Controle de erro
  vr_exc_erro EXCEPTION;
  --  
   PROCEDURE monta_xml_retorno(pr_retxml IN OUT xmltype) IS
      
     PROCEDURE insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                        ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                        ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                        ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                        ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                        ,pr_des_erro OUT VARCHAR2) IS  
     BEGIN
       gene0007.pc_insere_tag(pr_xml => pr_xml, 
                              pr_tag_pai => pr_tag_pai, 
                              pr_posicao => pr_posicao, 
                              pr_tag_nova => pr_tag_nova, 
                              pr_tag_cont => pr_tag_cont, 
                              pr_des_erro => pr_des_erro);
     END insere_tag;
   
    BEGIN
      
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      insere_tag(pr_xml      => pr_retxml
                ,pr_tag_pai  => 'Dados'
                ,pr_posicao  =>  0
                ,pr_tag_nova => 'nmarqimp'
                ,pr_tag_cont => vr_nmarqimp  
                ,pr_des_erro => pr_dscritic);

       insere_tag(pr_xml      => pr_retxml
                 ,pr_tag_pai  => 'Dados'
                 ,pr_posicao  =>  0
                 ,pr_tag_nova => 'nmarqpdf'
                 ,pr_tag_cont => vr_nmarqpdf  
                 ,pr_des_erro => pr_dscritic);
                 
   END monta_xml_retorno;
  
  
  BEGIN

    vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
    --
    -- Recupera dados de log para consulta posterior
    --/
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
     --
     -- Verifica se houve erro recuperando informacoes de log
     --
     IF NOT ( vr_dscritic IS NULL )
        THEN
          RAISE vr_exc_erro;
     END IF;
     --
     --/
     EMPR0018.pc_imprime_simulacao(pr_cdcooper => vr_cdcooper,
                                   pr_cdagenci => vr_cdagenci,
                                   pr_nrdcaixa => vr_nrdcaixa,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_nmdatela => vr_nmdatela,
                                   pr_cdorigem => vr_idorigem,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_idseqttl => pr_idseqttl,
                                   pr_dtmvtolt => vr_dtmvtolt,
                                   pr_flgerlog => SYS.diutil.int_to_bool(pr_flgerlog),
                                   pr_nrsimula => pr_nrsimula,
                                   pr_dsiduser => pr_dsiduser,
                                   pr_tpemprst => pr_tpemprst,
                                   pr_nmarqimp => vr_nmarqimp,
                                   pr_nmarqpdf => vr_nmarqpdf,
                                   pr_tab_erro => vr_tab_erro,
                                   pr_des_reto => vr_des_reto,
                                   pr_retorno => pr_retxml);
                                   
     IF NOT ( vr_des_reto = 'OK' )
       THEN
         vr_dscritic := pr_retxml.extract('Root/Dados/Resultado').getstringval();         
         RAISE vr_exc_erro;
     END IF;    
         
     monta_xml_retorno(pr_retxml);

     pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      --/
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic || '</Erro></Root>');    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado na tela_atenda_simulacao.pc_imprime_simulacao: ' || SQLERRM;
      vr_dscritic := pr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dscritic ||'</Erro></Root>');  
   END pc_imprime_simulacao;

 
END TELA_ATENDA_SIMULACAO;
/
