CREATE OR REPLACE PACKAGE CECRED.tela_cadmsp AS

  PROCEDURE pc_busca_mtv_sp(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_mtv_sp(pr_dsmotivo IN tbcotas_motivo_saqueparcial.dsmotivo%TYPE         --> Descrição do motivo
                            ,pr_flgpessf IN tbcotas_motivo_saqueparcial.flgpessoa_fisica%TYPE --> Flag pessoa física
                            ,pr_flgpessj IN tbcotas_motivo_saqueparcial.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                            ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                            ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_atualiza_mtv_sp(pr_cdmotivo IN tbcotas_motivo_saqueparcial.cdmotivo%TYPE --> Código do motivo
                              ,pr_dsmotivo IN tbcotas_motivo_saqueparcial.dsmotivo%TYPE         --> Descrição do motivo
                              ,pr_flgpessf IN tbcotas_motivo_saqueparcial.flgpessoa_fisica%TYPE --> Flag pessoa física
                              ,pr_flgpessj IN tbcotas_motivo_saqueparcial.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK


END tela_cadmsp;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_cadmsp AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADMSP
  --    Autor   : Lucas Reinert
  --    Data    : Setembro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela CADMSP
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------
  
 
  PROCEDURE pc_busca_mtv_sp(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_mtv_sp
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Setembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os motivos de saque parcial (tabela tbcotas_motivo_saqueparcial)
    
    Alteracoes: 
    ............................................................................. */
  
    --Cursor para pegar motivos de desligamento
    CURSOR cr_saque_parcial IS
      SELECT saq.cdmotivo,
             saq.dsmotivo,
             saq.flgpessoa_fisica,
             saq.flgpessoa_juridica
        FROM tbcotas_motivo_saqueparcial saq;

    rw_saque_parcial cr_saque_parcial%ROWTYPE;
  
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
    --   
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');  
    --
    -- Carregar arquivo com a tabela tbcotas_motivo_saqueparcial
    FOR rw_saque_parcial IN cr_saque_parcial LOOP
      --Escrever no XML
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'motivo',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdmotivo',
                               pr_tag_cont => rw_saque_parcial.cdmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsmotivo',
                               pr_tag_cont => rw_saque_parcial.dsmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgpessf',
                               pr_tag_cont => rw_saque_parcial.flgpessoa_fisica,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgpessj',
                               pr_tag_cont => rw_saque_parcial.flgpessoa_juridica,
                               pr_des_erro => vr_dscritic);
      
        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMSP.pc_busca_mtv_sp --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_mtv_sp;

  PROCEDURE pc_insere_mtv_sp(pr_dsmotivo IN tbcotas_motivo_saqueparcial.dsmotivo%TYPE         --> Descrição do motivo
														,pr_flgpessf IN tbcotas_motivo_saqueparcial.flgpessoa_fisica%TYPE --> Flag pessoa física
														,pr_flgpessj IN tbcotas_motivo_saqueparcial.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
			                               
														,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
														,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
														,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_mtv_sp
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Setembro/2017                       Ultima atualizacao:  
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir motivos de saque parcial (tabela tbcotas_motivo_saqueparcial)
    
    Alteracoes:
    ............................................................................. */
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
   
	  -- Vairáveis auxliares
	  vr_cdmotivo tbcotas_motivo_saqueparcial.cdmotivo%TYPE;
		
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
    --
    pr_des_erro := 'NOK';
    --
    BEGIN
    -- Busca o proximo Código
		vr_cdmotivo := fn_sequence(pr_nmtabela => 'tbcotas_motivo_saqueparcial'
															,pr_nmdcampo => 'cdmotivo'
															,pr_dsdchave => '0');
															
    INSERT INTO tbcotas_motivo_saqueparcial 
      (cdmotivo
			,dsmotivo
      ,flgpessoa_fisica
      ,flgpessoa_juridica
      )
    VALUES
      (vr_cdmotivo
			,pr_dsmotivo
      ,pr_flgpessf
      ,pr_flgpessj
      );
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;
		
		-- Retornar código cadastrado
		pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																	 '<Root><Dados><cdmotivo>' || vr_cdmotivo || '</cdmotivo></Dados></Root>');                                     

    --  
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMSP.pc_insere_mtv_sp --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
  
  END pc_insere_mtv_sp;

  PROCEDURE pc_atualiza_mtv_sp(pr_cdmotivo IN tbcotas_motivo_saqueparcial.cdmotivo%TYPE --> Código do motivo
														 ,pr_dsmotivo IN tbcotas_motivo_saqueparcial.dsmotivo%TYPE         --> Descrição do motivo
														 ,pr_flgpessf IN tbcotas_motivo_saqueparcial.flgpessoa_fisica%TYPE --> Flag pessoa física
														 ,pr_flgpessj IN tbcotas_motivo_saqueparcial.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                               
														 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
														 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
														 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
														 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
														 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
														 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_mtv_sp
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Reinert
    Data    : Setembro/2017                       Ultima atualizacao:  
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para atualizar motivos de saque parcial (tabela tbcotas_motivo_saqueparcial)
    
    Alteracoes:
    ............................................................................. */

    CURSOR cr_saque_parcial(pr_cdmotivo tbcotas_motivo_saqueparcial.cdmotivo%TYPE) IS
      SELECT saq.cdmotivo,
			       saq.dsmotivo,
						 saq.flgpessoa_fisica,
						 saq.flgpessoa_juridica
        FROM tbcotas_motivo_saqueparcial saq
       WHERE cdmotivo = pr_cdmotivo;
       
    rw_saque_parcial cr_saque_parcial%ROWTYPE;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
   
    -- Abre indicador 
    OPEN cr_saque_parcial(pr_cdmotivo);
    FETCH cr_saque_parcial INTO rw_saque_parcial;
		
    -- Se não existe
    IF cr_saque_parcial%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_saque_parcial;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Motivo não encontrado!';
        -- Levanta exceção
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_saque_parcial;
    
    BEGIN
      --
      UPDATE tbcotas_motivo_saqueparcial 
         SET dsmotivo = pr_dsmotivo,
             flgpessoa_fisica   = pr_flgpessf,
             flgpessoa_juridica = pr_flgpessj
       WHERE cdmotivo = pr_cdmotivo;
       --
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro não encontrado!';
     RAISE vr_exc_erro;
    END IF;
    --    
    COMMIT;
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMSP.pc_atualiza_mtv_sp --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_mtv_sp;


END tela_cadmsp;
/
