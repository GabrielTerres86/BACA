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

 
END TELA_ATENDA_SIMULACAO;
/
