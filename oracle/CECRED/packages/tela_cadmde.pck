CREATE OR REPLACE PACKAGE CECRED.tela_cadmde AS

  PROCEDURE pc_busca_mtv_desligamento(pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_mtv_desligamento(pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descri��o do motivo
                               ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa f�sica
                               ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jur�dica
                               ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                               
                               ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_atualiza_mtv_desligamento(pr_cdmotivo IN tbcotas_motivo_desligamento.cdmotivo%TYPE --> C�digo do motivo
                                 ,pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descri��o do motivo
                                 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa f�sica
                                 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jur�dica
                                 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                                 
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK


END tela_cadmde;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_cadmde AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADMDE
  --    Autor   : Everton Souza
  --    Data    : Outubro/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela CADMDE
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------
  
 
  PROCEDURE pc_busca_mtv_desligamento(pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_mvt_desligamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza
    Data    : Setembro/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar os motivos de desligamento (tabela tbcotas_motivo_desligamento)
    
    Alteracoes: 
    ............................................................................. */
  
    --Cursor para pegar motivos de desligamento
    CURSOR cr_desligamento IS
      SELECT mot.cdmotivo,
             mot.dsmotivo,
             mot.flgpessoa_fisica,
             mot.flgpessoa_juridica,
						 mot.tpmotivo,
             decode(mot.tpmotivo, 1, 'Demiss�o', 2, 'Exclus�o', 3, 'Elimina��o', 'N�o identificado') dstpmotv
        FROM tbcotas_motivo_desligamento mot;

    rw_desligamento cr_desligamento%ROWTYPE;
  
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
    -- Carregar arquivo com a tabela tbcotas_motivo_desligamento
    FOR rw_desligamento in cr_desligamento LOOP
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
                               pr_tag_cont => rw_desligamento.cdmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsmotivo',
                               pr_tag_cont => rw_desligamento.dsmotivo,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgpessf',
                               pr_tag_cont => rw_desligamento.flgpessoa_fisica,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgpessj',
                               pr_tag_cont => rw_desligamento.flgpessoa_juridica,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'tpmotivo',
                               pr_tag_cont => rw_desligamento.tpmotivo,
                               pr_des_erro => vr_dscritic);                               
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'motivo',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dstpmotv',
                               pr_tag_cont => rw_desligamento.dstpmotv,
                               pr_des_erro => vr_dscritic);															 
      
        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMDE.pc_busca_mtv_desligamento --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_mtv_desligamento;

  PROCEDURE pc_insere_mtv_desligamento(pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descri��o do motivo
																		 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa f�sica
																		 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jur�dica
																		 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
			                               
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
																		 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
																		 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_insere_mvt_desligamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza
    Data    : Setembro/2017                       Ultima atualizacao:  
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir motivos de desligamento (tabela tbcotas_motivo_desligamento)
    
    Alteracoes:
    ............................................................................. */
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
   
	  -- Vair�veis auxliares
	  vr_cdmotivo tbcotas_motivo_desligamento.cdmotivo%TYPE;
		
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
    --
    pr_des_erro := 'NOK';
    --
    BEGIN
    -- Busca o proximo C�digo
		vr_cdmotivo := fn_sequence(pr_nmtabela => 'tbcotas_motivo_desligamento'
															,pr_nmdcampo => 'cdmotivo'
															,pr_dsdchave => '0');
															
    INSERT INTO tbcotas_motivo_desligamento 
      (cdmotivo
			,dsmotivo
      ,flgpessoa_fisica
      ,flgpessoa_juridica
      ,tpmotivo
      )
    VALUES
      (vr_cdmotivo
			,pr_dsmotivo
      ,pr_flgpessf
      ,pr_flgpessj
      ,pr_tpmotivo
      );
    EXCEPTION
      WHEN dup_val_on_index THEN
         vr_dscritic := 'Registro ja existente!';
         RAISE vr_exc_erro;
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao inserir registro!';
         RAISE vr_exc_erro;
    END;
		
		-- Retornar c�digo cadastrado
		pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																	 '<Root><Dados><cdmotivo>' || vr_cdmotivo || '</cdmotivo></Dados></Root>');                                     

    --  
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMDE.pc_insere_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
  
  END pc_insere_mtv_desligamento;

  PROCEDURE pc_atualiza_mtv_desligamento(pr_cdmotivo IN tbcotas_motivo_desligamento.cdmotivo%TYPE --> C�digo do motivo
                                 ,pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descri��o do motivo
                                 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa f�sica
                                 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jur�dica
                                 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                               
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informa��es de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_atualiza_mvt_desligamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza
    Data    : Setembro/2017                       Ultima atualizacao:  
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para atualizar motivos de desligamento (tabela tbcotas_motivo_desligamento)
    
    Alteracoes:
    ............................................................................. */

    CURSOR cr_desligamento(pr_cdmotivo tbcotas_motivo_desligamento.cdmotivo%TYPE) IS
      SELECT *
        FROM tbcotas_motivo_desligamento 
       WHERE cdmotivo = pr_cdmotivo;
       
    rw_desligamento cr_desligamento%ROWTYPE;
    
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
  
    pr_des_erro := 'NOK';
   
    -- Abre indicador 
    OPEN cr_desligamento(pr_cdmotivo);
    FETCH cr_desligamento INTO rw_desligamento;
		
    -- Se n�o existe
    IF cr_desligamento%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_desligamento;
        -- Gera cr�tica
        vr_cdcritic := 0;
        vr_dscritic := 'Motivo n�o encontrado!';
        -- Levanta exce��o
        RAISE vr_exc_erro;
    END IF;

    -- Fecha cursor
    CLOSE cr_desligamento;
    
    BEGIN
      --
      UPDATE tbcotas_motivo_desligamento 
         SET dsmotivo = pr_dsmotivo,
             flgpessoa_fisica   = pr_flgpessf,
             flgpessoa_juridica = pr_flgpessj,
             tpmotivo = pr_tpmotivo
       WHERE cdmotivo = pr_cdmotivo;
       --
    EXCEPTION
      WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro!';
         RAISE vr_exc_erro;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
     vr_dscritic := 'Registro n�o encontrado!';
     RAISE vr_exc_erro;
    END IF;
    --    
    COMMIT;
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK          
      pr_des_erro := 'NOK';
      
      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_CADMDE.pc_atualiza_mtv_desligamento --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exig�ncia da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_mtv_desligamento;


END tela_cadmde;
/
