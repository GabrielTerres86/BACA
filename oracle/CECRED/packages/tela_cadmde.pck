CREATE OR REPLACE PACKAGE CECRED.tela_cadmde AS

  PROCEDURE pc_busca_mtv_desligamento(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_insere_mtv_desligamento(pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descrição do motivo
                               ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa física
                               ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                               ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                               
                               ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_atualiza_mtv_desligamento(pr_cdmotivo IN tbcotas_motivo_desligamento.cdmotivo%TYPE --> Código do motivo
                                 ,pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descrição do motivo
                                 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa física
                                 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                                 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                                 
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_pesq_mtv_desligamento(pr_cdmotdem IN tbcotas_motivo_desligamento.cdmotivo%TYPE -->Código da nacionalidade
                                   ,pr_dsmotdem IN tbcotas_motivo_desligamento.dsmotivo%TYPE --> Descrição da nacionalidade
                                   ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);                                   

END tela_cadmde;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_cadmde AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADMDE
  --    Autor   : Everton Souza
  --    Data    : Setembro/2017                   Ultima Atualizacao:  12/04/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela CADMDE
  --
  --    Alteracoes: 12/04/2028 - Inserido procedure pc_pesq_mtv_desligamento
  --    
  ---------------------------------------------------------------------------------------------------------------
  
 
  PROCEDURE pc_busca_mtv_desligamento(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
             decode(mot.tpmotivo, 1, 'Demissão', 2, 'Exclusão', 3, 'Eliminação', 'Não identificado') dstpmotv
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
      pr_dscritic := 'Erro na TELA_CADMDE.pc_busca_mtv_desligamento --> ' ||
                     SQLERRM;
                                  
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
    
  END pc_busca_mtv_desligamento;

  PROCEDURE pc_insere_mtv_desligamento(pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descrição do motivo
																		 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa física
																		 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
																		 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
			                               
																		 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
   
	  -- Vairáveis auxliares
	  vr_cdmotivo tbcotas_motivo_desligamento.cdmotivo%TYPE;
		
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
  BEGIN
    --
    pr_des_erro := 'NOK';
    --
    BEGIN
    -- Busca o proximo Código
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
      pr_dscritic := 'Erro na TELA_CADMDE.pc_insere_categoria --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                     
  
  END pc_insere_mtv_desligamento;

  PROCEDURE pc_atualiza_mtv_desligamento(pr_cdmotivo IN tbcotas_motivo_desligamento.cdmotivo%TYPE --> Código do motivo
                                 ,pr_dsmotivo IN tbcotas_motivo_desligamento.dsmotivo%TYPE         --> Descrição do motivo
                                 ,pr_flgpessf IN tbcotas_motivo_desligamento.flgpessoa_fisica%TYPE --> Flag pessoa física
                                 ,pr_flgpessj IN tbcotas_motivo_desligamento.flgpessoa_juridica%TYPE --> Flag pessoa jurídica
                                 ,pr_tpmotivo IN number --> Tipo do Motivo de desligamento
                               
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
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
		
    -- Se não existe
    IF cr_desligamento%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_desligamento;
        -- Gera crítica
        vr_cdcritic := 0;
        vr_dscritic := 'Motivo não encontrado!';
        -- Levanta exceção
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
      pr_dscritic := 'Erro na TELA_CADMDE.pc_atualiza_mtv_desligamento --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_atualiza_mtv_desligamento;

   
 --Busca as nacionalidades cadastradas no sistema
  PROCEDURE pc_pesq_mtv_desligamento(pr_cdmotdem IN tbcotas_motivo_desligamento.cdmotivo%TYPE -->Código da nacionalidade
                                   ,pr_dsmotdem IN tbcotas_motivo_desligamento.dsmotivo%TYPE --> Descrição da nacionalidade
                                   ,pr_nrregist IN INTEGER               -- Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER               -- Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
   Programa: pc_pesq_mtv_desligamento
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Everton - CECRED
   Data    : Abril/2018                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para buscar os motivos de desligamento

   Alteracoes:
                
    ............................................................................. */                                    
    CURSOR cr_motdem  (pr_cdmotdem IN crapnac.cdnacion%TYPE
                      ,pr_dsmotdem IN crapnac.dsnacion%TYPE) IS
     
    SELECT mot.cdmotivo  cdmotdem
          ,Upper(mot.dsmotivo)  dsmotdem
      FROM tbcotas_motivo_desligamento mot
     WHERE (pr_cdmotdem = 0 
        OR mot.cdmotivo = pr_cdmotdem)
       AND UPPER(mot.dsmotivo) LIKE '%' || pr_dsmotdem || '%';     
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
    
    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER;
  
  BEGIN
    
    --Inicializar Variaveis
    vr_qtregist:= 0;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADMDE'
                              ,pr_action => null);
      
    -- Extrai os dados dos dados que vieram do php
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro                      
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'motdem',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        
    --Loop nas nacionalidades   
    FOR rw_motdem IN cr_motdem(pr_cdmotdem => nvl(pr_cdmotdem,0)
                                ,pr_dsmotdem => upper(pr_dsmotdem)) LOOP
      
      --Incrementar Quantidade Registros do Parametro
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
    
      /* controles da paginacao */
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo Titular
        CONTINUE;
      END IF; 
          
      --Numero Registros
      IF vr_nrregist > 0 THEN 
      
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'motdem',pr_posicao => 0,pr_tag_nova => 'motivos',pr_tag_cont => NULL,pr_des_erro => vr_dscritic); 
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'motivos',pr_posicao => vr_auxconta, pr_tag_nova => 'cdmotdem', pr_tag_cont => rw_motdem.cdmotdem, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'motivos',pr_posicao => vr_auxconta, pr_tag_nova => 'dsmotdem', pr_tag_cont => rw_motdem.dsmotdem, pr_des_erro => vr_dscritic);
       
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;  
              
      END IF;
        
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'motdem'           --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADNAC.pc_buscar_nacionalidades).';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_pesq_mtv_desligamento;  


END tela_cadmde;
/
