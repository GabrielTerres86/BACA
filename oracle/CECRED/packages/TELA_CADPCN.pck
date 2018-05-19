CREATE OR REPLACE PACKAGE CECRED.TELA_CADPCN AS

   /*
   Programa: TELA_CADPCN                          antigo: 
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lindon - GFT Brasil
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADNAC para permitir o gerenciamento de cnae
   Alteracoes: 
   */  
   
  --Busca as cnae cadastradas no sistema
  PROCEDURE pc_buscar_cnae(
                         pr_cdcnae IN NUMBER                       --> C�digo CNAE
                         ,pr_xmllog   IN VARCHAR2                  --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER              --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2                 --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2                 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);               --> Erros do processo
                                     
  --Inclui nacionalidade requerida pelo usuario
  PROCEDURE pc_incluir_cnae(pr_cdcnae IN NUMBER                    --> C�digo da cooperativa
                           ,pr_vlmaximo IN NUMBER                  --> QValor m�ximo do CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);             --> Erros do processo
                                 
  --Exclui nacionalidade requerida pelo usuario
  PROCEDURE pc_excluir_cnae(
                            pr_cdcnae IN NUMBER                    --> C�digo CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);             --> Erros do processo
                                    
 
 --Altear nacionalidade requerida pelo usuario
  PROCEDURE pc_alterar_cnae(
                           pr_cdcnae IN NUMBER                     --> C�digo CNAE
                           ,pr_vlmaximo IN NUMBER                  --> QValor m�ximo do CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);             --> Erros do processo                                 
                                                                                     
END TELA_CADPCN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADPCN AS
/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_CADPCN                          antigo: 
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lindon - GFT Brasil
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Diario (on-line).
   Objetivo  : Mostrar a tela CADPCN para permitir o gerenciamento de valor de desconto de t�tulo m�ximo por CNAE
   Alteracoes: 19/05/2018 - Corre��es de Erros (Luis Fernando - GFT)
  ---------------------------------------------------------------------------------------------------------------*/

  -- vari�veis para armazenar as informa�oes em xml
  vr_des_xml        clob;
  vr_texto_completo varchar2(32600);
  vr_index          PLS_INTEGER;
  procedure pc_escreve_xml( pr_des_dados in varchar2
                          , pr_fecha_xml in boolean default false
                          ) is
  begin
      gene0002.pc_escreve_xml( vr_des_xml
                             , vr_texto_completo
                             , pr_des_dados
                             , pr_fecha_xml );
  end;
  --Busca os cnaes cadastradas no sistema
  PROCEDURE pc_buscar_cnae(
                          pr_cdcnae IN NUMBER                  --> C�digo CNAE
                         ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                         ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                         ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                         ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2)IS          --> Erros do processo
/* .............................................................................
   Programa: pc_busca_cnae
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lindon - GFT Brasil
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para buscar os CNAE's
   Alteracoes: 
    ............................................................................. */                                    
    
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
    vr_nrregist INTEGER ;
    vr_qtregist INTEGER;
  
    CURSOR cr_cnae  IS
    SELECT cdcnae, vlmaximo, cdcooper
      FROM tbdsct_cdnae 
      WHERE cdcooper = vr_cdcooper AND cdcnae = pr_cdcnae;

    -- row type referente ao cnae 
    rw_cnae cr_cnae%ROWTYPE;
      
      
  BEGIN
    
    --Inicializar Variaveis
    vr_qtregist:= 0;
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADPCN'
                              ,pr_action => null);
    -- Extrai os dados dos dados que vieram do php
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
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

   
    -- Verifica a exist�ncia de item j� existente
    OPEN cr_cnae;
    FETCH cr_cnae INTO rw_cnae;
    IF cr_cnae%NOTFOUND THEN
      CLOSE cr_cnae;
      vr_dscritic := 'Valor m�ximo n�o cadastrado para este CNAE.';
      RAISE vr_exc_saida;
    END IF;  
    CLOSE cr_cnae;

    -- Insere atributo na tag Dados com a quantidade de registros
    GENE0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que ir� receber o novo atributo
                             ,pr_tag   => 'cnae'              --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> N�mero da localiza��o da TAG na �rvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descri��o de erros

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');
      -- ler os registros de titcto e incluir no xml
            pc_escreve_xml('<inf>'||
                             '<cdcnae>' || rw_cnae.cdcnae || '</cdcnae>' ||
                             '<vlmaximo>' || rw_cnae.vlmaximo || '</vlmaximo>' ||
                           '</inf>'
                          );
          /* buscar proximo */
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    --Se encontrado erro executa exception
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
      
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADPCN.pc_buscar_cnae).';

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      
      ROLLBACK;   
  
  END pc_buscar_cnae;
  
  
  
  

  --Inclui cnae requerida pelo usuario
  PROCEDURE pc_incluir_cnae(
                           pr_cdcnae IN NUMBER                  --> C�digo da cooperativa
                           ,pr_vlmaximo IN NUMBER                  --> QValor m�ximo do CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS            --> Erros do processo
        
  /* .............................................................................
   Programa: pc_incluir_cnae
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : 
   Autor   : Lindon - GFT Brasil (t0031728)
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para incluir os CNAE�s
   Alteracoes: 
    ............................................................................. */                                    

    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;

    -- Cursor contendo o select do valor por cnae
    CURSOR cr_cnae  IS
                   SELECT cdcnae, cdcooper, vlmaximo
                          FROM tbdsct_cdnae 
                          WHERE cdcnae = pr_cdcnae AND cdcooper = vr_cdcooper;    
    rw_cnae cr_cnae%ROWTYPE;
  
  BEGIN
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADPCN'
                              ,pr_action => null);
                              
    -- Extrai os dados dos dados que vieram do php
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);  
                            
    -- Verifica se houve erro de cr�tica                     
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         

    OPEN cr_cnae;
    FETCH cr_cnae INTO rw_cnae;
    IF cr_cnae%FOUND THEN
      CLOSE cr_cnae;

      vr_dscritic := 'J� existe valor cadastrado para este CNAE.';
      RAISE vr_exc_saida;
    END IF;  
    CLOSE cr_cnae;
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><cnae/>');    
    
    BEGIN 

      INSERT INTO tbdsct_cdnae(cdcnae, cdcooper, vlmaximo) VALUES(pr_cdcnae, vr_cdcooper, pr_vlmaximo);

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'N�o foi poss�vel incluir o CNAE.' || Sqlerrm;
        RAISE vr_exc_saida;          
    END;
    
    -- Gera log
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2 
                              ,pr_nmarqlog     => 'cadpcn.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a inclusao do CNAE ' ||
                                                  pr_vlmaximo || '.');
                                                     
    pr_des_erro := 'OK';
    
    COMMIT;


    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'cnae',pr_tag_cont => pr_cdcnae,pr_des_erro => vr_dscritic); 
    GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'vlmaximo',pr_tag_cont => pr_vlmaximo,pr_des_erro => vr_dscritic); 
   
    
  EXCEPTION
    WHEN vr_exc_saida THEN

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      -- no caso de possuir um codigo de critica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADPCN.pc_incluir_cnae).';
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_incluir_cnae;  

  -- Exclui cnae requerida pelo usuario
  PROCEDURE pc_excluir_cnae(
                            pr_cdcnae IN NUMBER                    --> C�digo CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS            --> Erros do processo
 
 /* .............................................................................
   Programa: pc_excluir_cnae
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lindon GFT - Brasil (t0031728)
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para excluir os cnaes
   Alteracoes: 
   ............................................................................. */                                    
    CURSOR cr_cnae(pr_cdcnae IN NUMBER
                  ,pr_cdcooper IN NUMBER) IS
           SELECT cdcnae, cdcooper, vlmaximo
                  FROM tbdsct_cdnae 
                  WHERE cdcnae = pr_cdcnae and cdcooper = pr_cdcooper;       
    rw_cnae cr_cnae%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
  
  BEGIN
    
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADPCN'
                              ,pr_action => null);
                              
    -- Extrai os dados dos dados que vieram do php
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
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

    OPEN cr_cnae(pr_cdcnae, vr_cdcooper);
    FETCH cr_cnae INTO rw_cnae;
    IF cr_cnae%NOTFOUND THEN
      CLOSE cr_cnae;
      vr_dscritic := 'Valor m�ximo n�o cadastrado para este CNAE.';
      RAISE vr_exc_saida;

    END IF;  
    CLOSE cr_cnae;


    BEGIN 
      -- Excluir o cursor
      DELETE FROM tbdsct_cdnae
            WHERE cdcnae = pr_cdcnae and cdcooper = vr_cdcooper;      
    COMMIT;


    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'N�o foi poss�vel excluir o CNAE.';
        RAISE vr_exc_saida;
    END;


    -- Gera log
    btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2
                              ,pr_nmarqlog     => 'cadpcn.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a exclusao do CNAE '   ||
                                                  ' Codigo: ' || rw_cnae.cdcnae       || 
                                                  ', Descricao: '                          || 
                                                  rw_cnae.vlmaximo || '.');
    pr_des_erro := 'OK';

    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'cnae',pr_tag_cont => pr_cdcnae,pr_des_erro => vr_dscritic); 



  EXCEPTION
    WHEN vr_exc_saida THEN

      -- se ocorreu um erro mias n�o uma descri��o da cr�tica

      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;

      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;


      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      -- gera c�digo de cr�tica gen�rico

      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADPCN.pc_excluir_cnae).';

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  END pc_excluir_cnae;  

  --Altear cnae requerida pelo usuario
  PROCEDURE pc_alterar_cnae(
                           pr_cdcnae IN NUMBER                    --> C�digo CNAE
                           ,pr_vlmaximo IN NUMBER                  --> QValor m�ximo do CNAE
                           ,pr_xmllog IN VARCHAR2                  --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER            --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2               --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2)IS            --> Erros do processo   


  /* .............................................................................
   Programa: pc_alterar_cnae
   Sistema : Desconto de T�tulo - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lindon - GFT - Brasil
   Data    : Mar�o/2018                       Ultima atualizacao: 
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar as cnae
   Alteracoes: 
   ............................................................................. */                                    
    
    -- Variaveis de log
    vr_cdcooper NUMBER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;         
    vr_exc_saida EXCEPTION;
    
    CURSOR cr_cnae  IS
      SELECT cdcnae, cdcooper, vlmaximo 
        FROM tbdsct_cdnae 
       WHERE 
             cdcooper = vr_cdcooper
             AND cdcnae = pr_cdcnae;
    rw_cnae cr_cnae%ROWTYPE;
  
  BEGIN
  
    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADPCN'
                              ,pr_action => null);
                              
    -- Extrai os dados dos dados que vieram do php
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
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
    
    OPEN cr_cnae;

    FETCH cr_cnae INTO rw_cnae;
    IF cr_cnae%NOTFOUND THEN
      CLOSE cr_cnae;
      vr_dscritic := 'Valor m�ximo n�o cadastrado para este CNAE.';
      RAISE vr_exc_saida;
      
    END IF;  
    CLOSE cr_cnae;
    
    BEGIN 

      --Alterar o cnae
    UPDATE tbdsct_cdnae
           SET vlmaximo = pr_vlmaximo
           WHERE cdcnae = pr_cdcnae AND cdcooper = vr_cdcooper;
    commit;
           
    EXCEPTION 
      WHEN OTHERS THEN 
        vr_dscritic := 'N�o foi poss�vel alterar o CNAE.';
        RAISE vr_exc_saida;
                
    END;
    
    -- Gera log
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                              ,pr_ind_tipo_log => 2
                              ,pr_nmarqlog     => 'cadnac.log'
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                  'Efetuou a alteracao do cnae ' || 
                                                  rw_cnae.cdcnae || ' - de ' ||
                                                  rw_cnae.vlmaximo || ' para ' || 
                                                  pr_vlmaximo || '.');
                                                  
    pr_des_erro := 'OK';
    
    -- Criar cabe�alho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'cnae',pr_tag_cont => pr_cdcnae,pr_des_erro => vr_dscritic);
    GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'vlmaximo',pr_tag_cont => pr_vlmaximo,pr_des_erro => vr_dscritic);
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
      IF TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic:= GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      pr_cdcritic := pr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral (TELA_CADPCN.pc_alterar_cnae).';
      
      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  
  END pc_alterar_cnae;  
  
  
END TELA_CADPCN;
/
