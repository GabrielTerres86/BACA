CREATE OR REPLACE PACKAGE CECRED.CONV0002 AS


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONV0002
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para integra��o de convenios via WS
  --
  ---------------------------------------------------------------------------------------------------------------
  
  /* Armazenagem de arquivo de conv�nio de d�bito */
  PROCEDURE pc_armazena_arquivo_conven (pr_cdconven IN gnconve.cdconven%TYPE                 --> Codigo do conv�nio
                                       ,pr_dtarquiv IN crapdat.dtmvtolt%TYPE DEFAULT SYSDATE --> Data de refer�ncia do arquivo 
                                       ,pr_tparquiv IN crapprg.cdprogra%TYPE                 --> Programa chamador
                                       ,pr_flproces IN tbconv_arquivos.flgprocessado%TYPE    --> J� Processado ou n�o
                                       ,pr_dscaminh IN VARCHAR2                              --> Caminho do arquivo a gravar
                                       ,pr_nmarquiv IN VARCHAR2                              --> Nome do arquivo a gravar
                                       ,pr_cdretorn OUT NUMBER                               --> C�digo de retorno
                                       ,pr_dsmsgret OUT VARCHAR2);                           --> Descricao do erro
  
  /* Novo procedimento que efetua as valida��es b�sicas a partir das requisi��es via WS de Conv�nios. */
  PROCEDURE pc_valida_requisi_wsconven (pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_cdretorn OUT NUMBER               --> C�digo de retorno
                                       ,pr_dsmsgret OUT VARCHAR2);           --> Descricao do erro

  /* Novo procedimento para retorno da listagem de arquivos processados */

  PROCEDURE pc_lista_retorno_conven_ws (pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_flgretor IN VARCHAR DEFAULT 'N'   --> Trazer arquivos j� retornados (S/N)
                                       ,pr_dtiniret IN VARCHAR DEFAULT NULL  --> Data inicial dos arquivos de retorno
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2);

  /* Novo procedimento para recebimento e armazenagem do arquivo de conv�nio repassado */
  PROCEDURE pc_recebe_arquivo_conven_ws(pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_tparquiv IN crapprg.cdprogra%TYPE --> Programa chamador
                                       ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo a gravar
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2);

  /* Novo procedimento para retorno de arquivo processados para determinado conv�nio */
  PROCEDURE pc_retorna_arquiv_conven_ws(pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_nmarquiv IN VARCHAR               --> Nome do arquivo solicitado
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2);
                                     
END CONV0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CONV0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CONV0002
  --  Sistema  : Procedimentos para Convenios
  --  Sigla    : CRED
  --  Autor    : Marcos Martini - Supero
  --  Data     : Junho/2016.                
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para integra��o de convenios via WS
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Verifica��o de coer�ncia do arquivo com o conv�nio e de ativa��o do conv�nio
  CURSOR cr_gnconve(pr_cdconven IN gnconve.cdconven%TYPE) IS
    SELECT nmarqatu
          ,nmarqcxa
          ,nmarqdeb
          ,nmarqint
          ,nmarqpar
      FROM gnconve
     WHERE gnconve.cdconven = pr_cdconven /* Convenio enviado */
       AND gnconve.flgativo = 1;          /* Somente convenio ativo */
  rw_conve cr_gnconve%ROWTYPE;      

  /* Armazenagem de arquivo de conv�nio de d�bito */
  PROCEDURE pc_armazena_arquivo_conven (pr_cdconven IN gnconve.cdconven%TYPE                 --> Codigo do conv�nio
                                       ,pr_dtarquiv IN crapdat.dtmvtolt%TYPE DEFAULT SYSDATE --> Data de refer�ncia do arquivo 
                                       ,pr_tparquiv IN crapprg.cdprogra%TYPE                 --> Programa chamador
                                       ,pr_flproces IN tbconv_arquivos.flgprocessado%TYPE    --> J� Processado ou n�o
                                       ,pr_dscaminh IN VARCHAR2                              --> Caminho do arquivo a gravar
                                       ,pr_nmarquiv IN VARCHAR2                              --> Nome do arquivo a gravar
                                       ,pr_cdretorn OUT NUMBER                               --> C�digo de retorno
                                       ,pr_dsmsgret OUT VARCHAR2) IS                         --> Descricao do erro
  BEGIN
    /* .............................................................................

       Programa: pc_armazena_arquivo_conven
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Procedimento para armazenagem do arquivo de conv�nio repassado. 
                   A requisi��o receber� o nome do arquivo e seu caminho para ap�s 
                   grav�-lo no banco.

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Guardar id para grava��o de tabela filha
      vr_idarquivo tbconv_arquivos.idarquivo%TYPE;
      -- Variaveis para tratamento do arquivo
      vr_utlfile   utl_file.file_type;
      vr_qtdlinhas NUMBER;
      vr_dsdlinha  VARCHAR2(4000);
    BEGIN

      -- A rotina dever� primeiramente checar se o arquivo repassado, se n�o existir
      --  ent�o gerar cr�tica:
      IF NOT gene0001.fn_exis_arquivo(pr_caminho => rtrim(pr_dscaminh,'/')||'/'||pr_nmarquiv) THEN
        -- Retornar erro e sair da rotina
        pr_cdretorn := 402;
        pr_dsmsgret := 'Problema com a grava�ao do arquivo � arquivo nao existe no destino!';
        RETURN;
      END IF;
      
      -- Ap�s, iremos verificar se o conv�nio solicitado est� ativo e 
      -- coerente com o nome do arquivo enviado:
      OPEN cr_gnconve(pr_cdconven);
      FETCH cr_gnconve
       INTO rw_conve;      
      -- N�o existindo
      IF cr_gnconve%NOTFOUND THEN
        -- Retornar erro e sair da rotina
        CLOSE cr_gnconve;
        pr_cdretorn := 402;
        pr_dsmsgret := 'Convenio inexistente ou inativo!';
        RETURN;
      ELSE
        CLOSE cr_gnconve;
        -- Validar prefixos do arquivo X prefixos permitidos no conv�nio
        -- Se nenhum estiver de acordo com o arquivo
        IF NOT (  pr_nmarquiv LIKE(lower(SUBSTR(rw_conve.nmarqatu,1,LENGTH(rw_conve.nmarqatu)-8))||'%')
               OR pr_nmarquiv LIKE(lower(SUBSTR(rw_conve.nmarqcxa,1,LENGTH(rw_conve.nmarqcxa)-8))||'%')
               OR pr_nmarquiv LIKE(lower(rw_conve.nmarqint)||'%')
               OR pr_nmarquiv LIKE(lower(SUBSTR(rw_conve.nmarqdeb,1,LENGTH(rw_conve.nmarqdeb)-8))||'%')
               OR pr_nmarquiv LIKE(lower(SUBSTR(rw_conve.nmarqpar,1,LENGTH(rw_conve.nmarqpar)-8))||'%')) THEN
          pr_cdretorn := 402;
          pr_dsmsgret := 'Arquivo invalido para o Convenio enviado!';
          RETURN;        
        END IF;
      END IF;
      --Por fim, passadas as valida��es, ent�o devemos inserir o registro de arquivo:
      BEGIN
        INSERT INTO tbconv_arquivos (nmarquivo
                                    ,dtarquivo
                                    ,cdconvenio
                                    ,tparquivo
                                    ,flgprocessado)
                             VALUES (pr_nmarquiv
                                    ,pr_dtarquiv
                                    ,pr_cdconven
                                    ,pr_tparquiv
                                    ,pr_flproces)
                          RETURNING idarquivo
                               INTO vr_idarquivo;
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro, desfazer altera��es e sair da rotina
          pr_cdretorn := 402;
          pr_dsmsgret := 'CONV0002.pc_armazena_arquivo_conven - Erro na gravacao do arquivo de convenio: '||sqlerrm;
          ROLLBACK;
          RETURN;
      END;
      -- Continuando, devemos usar as rotinas de leitura de arquivo 
      -- para que cada linha seja inserida na tabela 
      gene0001.pc_abre_arquivo(pr_nmdireto => rtrim(pr_dscaminh,'/')
                              ,pr_nmarquiv => pr_nmarquiv
                              ,pr_tipabert => 'R' -- Somente leitura
                              ,pr_utlfileh => vr_utlfile
                              ,pr_des_erro => pr_dsmsgret);
      -- Verifica se houve erros na abertura do arquivo
      IF pr_dsmsgret IS NOT NULL THEN
        -- Retornar erro, desfazer altera��es e sair da rotina
        pr_cdretorn := 402;
        pr_dsmsgret := 'CONV0002.pc_armazena_arquivo_conven - Erro na abertura do arquivo - '||pr_dsmsgret;
        ROLLBACK;
        RETURN;
      END IF;
      -- Se o arquivo estiver aberto
      IF utl_file.IS_OPEN(vr_utlfile) THEN
        -- Iniciar contagem de linhas do arquivo
        vr_qtdlinhas := 0;
        -- Percorrer as linhas do arquivo
        LOOP
          -- Limpa a vari�vel que receber� a linha do arquivo
          vr_dsdlinha := NULL;
          -- Incrementar quantidade de linhas
          vr_qtdlinhas := vr_qtdlinhas + 1;
          BEGIN
            -- L� a linha do arquivo
            GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfile
                                        ,pr_des_text => vr_dsdlinha);

          EXCEPTION
            WHEN no_data_found THEN
              -- Acabou a leitura, ent�o finaliza o loop
              EXIT;
          END;

          BEGIN
            -- Insere a linha do arquivo para a tabela 
            INSERT INTO tbconv_conteudo_arquivos (idarquivo
                                                 ,idlinha
                                                 ,dstexto_linha
                                                 ,qtcaracteres_linha)
                                          VALUES (vr_idarquivo
                                                 ,vr_qtdlinhas
                                                 ,vr_dsdlinha
                                                 ,LENGTH(vr_dsdlinha));
          EXCEPTION
            WHEN OTHERS THEN
              -- Devolver erro, desfazer altera��es, fechar arquivo e retornar 
              pr_cdretorn := 402;
              pr_dsmsgret := 'CONV0002.pc_armazena_arquivo_conven - Erro na gravacao das linhas do arquivo de convenio: '||sqlerrm;
              GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfile);
              ROLLBACK;
              RETURN;
          END;  
        END LOOP; -- Finaliza o loop das linhas do arquivo
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfile);
      END IF;
      
      
      -- AO final, podemos commitar as altera��es na base
      pr_cdretorn := 202; 
      pr_dsmsgret := 'OK';
      COMMIT;

    EXCEPTION
       WHEN OTHERS THEN
         pr_cdretorn := 402;
         pr_dsmsgret := 'CONV0002.pc_armazena_arquivo_conven - Erro nao tratado: ' || SQLERRM;
    END;

  END pc_armazena_arquivo_conven;
  
  /* Novo procedimento que efetua as valida��es b�sicas a partir das requisi��es via WS de Conv�nios. */
  PROCEDURE pc_valida_requisi_wsconven (pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_cdretorn OUT NUMBER               --> C�digo de retorno
                                       ,pr_dsmsgret OUT VARCHAR2) IS         --> Descricao do erro
  BEGIN
    /* .............................................................................

       Programa: pc_valida_requisi_wsconven
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetua as valida��es b�sicas a
                   partir das requisi��es via WS de Conv�nios.

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Chaves de acesso
      vr_chavecli VARCHAR2(200);
      vr_chavereq VARCHAR2(200);
    BEGIN
      -- Primeiramente vamos verificar se a chave de acesso est� de 
      -- acordo com o usu�rio e senha recebidos da requisi��o ao WebService, 
      -- como as credenciais de acesso estar�o armazenadas criptografa em Base64, 
      -- devemos montar o conjunto usu�rio:senha para compara��o: 
      vr_chavecli := utl_encode.text_encode(pr_dsusuari || ':' || pr_dsdsenha
                                           ,'WE8ISO8859P1', UTL_ENCODE.BASE64);
 
      -- Retornar o par�metro de sistema com as credencias aceitas:
      vr_chavereq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => 0
                                              ,pr_cdacesso => 'CHAVE_WS_SEGUROS');

      -- Retornar erro 401 caso a string montada seja diferente da parametrizada:
      IF vr_chavecli <> vr_chavereq THEN
        PR_CDRETORN := 401;
        PR_DSMSGRET := 'Credenciais de acesso invalidas.';
        RETURN;
      END IF;
      
      -- Prosseguindo, devemos validar se o conv�nio � um conv�nio 
      -- v�lido e ativo atrav�s da Query abaixo:
      OPEN cr_gnconve(pr_cdconven);
      FETCH cr_gnconve
       INTO rw_conve;      
      -- N�o existindo
      IF cr_gnconve%NOTFOUND THEN
        -- Retornar erro e sair da rotina
        CLOSE cr_gnconve;
        pr_cdretorn := 402;
        pr_dsmsgret := 'Convenio ['||pr_cdconven||'] inexistente ou inativo!';
        RETURN;
      ELSE
        CLOSE cr_gnconve;
      END IF;  
      -- Chegado ao final, ap�s o sucesso em todos os testes, retornaremos o sucesso:
      pr_cdretorn := 202; 
      pr_dsmsgret := 'OK';

    EXCEPTION
       WHEN OTHERS THEN
         pr_cdretorn := 402;
         pr_dsmsgret := 'CONV0002.pc_valida_requisi_wsconven - Erro nao tratado: ' || SQLERRM;
    END;

  END pc_valida_requisi_wsconven;  

  /* Nova fun��o que efetuar� a cria��o do retorno XML para a requisi��o do WS. */
  PROCEDURE pc_monta_retorno_ws (pr_cdretorn IN NUMBER                  --> C�digo de retorno
                                ,pr_dsmsgret IN VARCHAR2                --> Texto
                                ,pr_dsxmlret IN OUT NOCOPY XmlType) IS  --> XML de retorno da requisi��o
  BEGIN
    /* .............................................................................

       Programa: pc_monta_retorno_ws
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento que efetuar� a cria��o 
                   do retorno XML para a requisi��o do WS. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Tratamento de erro
      vr_des_erro VARCHAR2(4000);
    BEGIN
      -- Primeiramente criaremos o XmlType
      pr_dsxmlret := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      -- Ap�s adicionaremos a tag Root as tags idStatus e msgDetalhe:
      gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                            ,pr_tag_pai => 'Root'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'idStatus'
                            ,pr_tag_cont => pr_cdretorn 
                            ,pr_des_erro => vr_des_erro);
      gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                            ,pr_tag_pai => 'Root'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'msgDetalhe'
                            ,pr_tag_cont => pr_dsmsgret  
                            ,pr_des_erro => vr_des_erro);
    EXCEPTION
      WHEN OTHERS THEN
        -- criar XML com erro tratado
        pr_dsxmlret := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
        -- Ap�s adicionaremos na tag Root as tags idStatus e msgDetalhe o erro capturado:
        gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                              ,pr_tag_pai => 'Root'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'idStatus'
                              ,pr_tag_cont => 402 
                              ,pr_des_erro => vr_des_erro);
        gene0007.pc_insere_tag(pr_xml => pr_dsxmlret
                              ,pr_tag_pai => 'Root'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'msgDetalhe'
                              ,pr_tag_cont => 'conv0002.pc_monta_retorno_ws - Erro nao tratado -> '||sqlerrm  
                              ,pr_des_erro => vr_des_erro);

    END;
  END pc_monta_retorno_ws; 
  
  /* Novo procedimento para recebimento e armazenagem do arquivo de conv�nio repassado */
  PROCEDURE pc_recebe_arquivo_conven_ws(pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_tparquiv IN crapprg.cdprogra%TYPE --> Programa chamador
                                       ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo a gravar
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2) IS   --> XML de retorno da requisi��o
  BEGIN
    /* .............................................................................

       Programa: pc_recebe_arquivo_conven_ws 
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento para armazenagem do arquivo de conv�nio repassado.
                   A requisi��o receber� o nome do arquivo postado no AyllosWeb, e esta rotina
                   rotina far� o Download para somente ap�s gravar no banco. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_typ_said VARCHAR2(10);
      vr_des_erro VARCHAR2(4000);
      -- Manuten��o do arquivo
      vr_dsdireto VARCHAR2(1000);
      vr_nmarquiv VARCHAR2(1000);
      -- Retornar cooperativas ativas
      CURSOR cr_cop IS
        SELECT cop.cdcooper
          FROM gncvcop cov
              ,crapcop cop
         WHERE cov.cdconven = pr_cdconven
           AND cov.cdcooper = cop.cdcooper
           AND cop.flgativo = 1;
    BEGIN
      -- Primeiramente acionaremos a rotina das valida��es b�sicas:
      pc_valida_requisi_wsconven(pr_dsusuari => pr_dsusuari
                                ,pr_dsdsenha => pr_dsdsenha
                                ,pr_cdconven => pr_cdconven
                                ,pr_cdretorn => vr_cdretorn
                                ,pr_dsmsgret => vr_dsmsgret);
      -- Se o retorno n�o for c�digo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execu��o:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_retxml);
        RETURN;
      END IF;
      
      -- Prosseguindo devemos baixar o arquivo que est� copiado na pasta do AyllosWeb 
      -- para a pasta upload da Cecred, portanto primeiramente vamos montar o
      -- caminho relativo da pasta upload da Central:
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => 3 /* Fixo central */
                                          ,pr_nmsubdir => 'upload'); 
     
      -- Ap�s, executar o script que faz o download do arquivo do AyllosWeb para a pasta remota:
      GENE0001.pc_OScommand_Shell(gene0001.fn_param_sistema('CRED',0,'SCRIPT_RECEBE_ARQUIVOS')||' '||gene0001.fn_param_sistema('CRED',0,'SRVINTRA')||'/upload_files/'||PR_NMARQUIV||' N'
                                 ,pr_typ_saida => vr_typ_said
                                 ,pr_des_saida => vr_des_erro);
      -- Testar poss�vel erro
      IF vr_typ_said = 'ERR' THEN
        pc_monta_retorno_ws(402,'Erro no recebimento do arquivo: ' || vr_des_erro,pr_retxml);
        ROLLBACK;
        RETURN;
      END IF;
      
      -- Verifica se o arquivo existe, ou seja, se recebemos com sucesso na pasta upload:
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||pr_nmarquiv) THEN
        pc_monta_retorno_ws(402,'Erro no recebimento do arquivo: Arquivo nao copiado a pasta upload!',pr_retxml);
        ROLLBACK;
        RETURN;
      END IF;
      
      -- Ap�s, iremos renomear o arquivo recebido removendo o n�mero da cooperativa e conta, que est�o fixos 003.0.restante_nome
      vr_nmarquiv := substr(pr_nmarquiv,7);
      GENE0001.pc_OScommand_Shell('mv '|| vr_dsdireto || '/' || pr_nmarquiv || ' ' || vr_dsdireto || '/' || vr_nmarquiv
                                 ,pr_typ_saida => vr_typ_said
                                 ,pr_des_saida => vr_des_erro);
      -- Testar poss�vel erro
      IF vr_typ_said = 'ERR' THEN
        pc_monta_retorno_ws(402,'Erro ao renomear o arquivo: ' || vr_des_erro,pr_retxml);
        ROLLBACK;
        RETURN;
      END IF; 
       
      -- Prosseguindo, significa que temos o arquivo na pasta Upload e renomeado para 
      -- o padr�o desejado, e ent�o acionaremos rotina para valida��o do arquivo
      -- de arquivo conforme conv�nio enviado e tamb�m armazenagem do arquivo na base de dados: 
      pc_armazena_arquivo_conven(pr_cdconven => pr_cdconven
                                ,pr_dtarquiv => SYSDATE
                                ,pr_tparquiv => pr_tparquiv
                                ,pr_flproces => 1 /* Jah processado */
                                ,pr_dscaminh => vr_dsdireto
                                ,pr_nmarquiv => vr_nmarquiv
                                ,pr_cdretorn => vr_cdretorn
                                ,pr_dsmsgret => vr_dsmsgret);
      -- No caso de retorno de erro (vr_cdretorn <> 202), preencher a requisi��o com:
      IF vr_cdretorn <> 202 THEN
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_retxml);
        ROLLBACK;
        RETURN;
      END IF;  
      -- Passado o processo de grava��o dos arquivos em base de dados, ent�o podemos
      -- efetuar a c�pia do arquivo para a pasta integra de todas as cooperativas
      -- ativas e vinculadas ao conv�nio selecionado: 
      FOR rw_cop IN cr_cop LOOP
        GENE0001.pc_OScommand_Shell('cp '|| vr_dsdireto || '/' || vr_nmarquiv || ' ' ||gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                                                                            ,pr_cdcooper => rw_cop.cdcooper /*(loop)*/
                                                                                                            ,pr_nmsubdir => 'integra')
                                   ,pr_typ_saida => vr_typ_said
                                   ,pr_des_saida => vr_des_erro);
        -- Testar poss�vel erro
        IF vr_typ_said = 'ERR' THEN
          pc_monta_retorno_ws(402,'Erro na copia para a Integra da Coop '||rw_cop.cdcooper||', erro> '||vr_des_erro,pr_retxml);
          ROLLBACK;
          RETURN;
        END IF;    
      END LOOP;
       
      -- Chegado nesse ponto sem nenhum erro, ent�o podemos retornar o sucesso
      -- na opera��o e finalmente commitar as altera��es:
      pc_monta_retorno_ws(202,'Arquivo recebido com sucesso!',pr_retxml);
      COMMIT;     
    
    EXCEPTION
      WHEN OTHERS THEN
        pc_monta_retorno_ws(402,'CONV0002.pc_recebe_arquivo_conven_ws - Erro nao tratado: ' || SQLERRM,pr_retxml);
    END;
  END pc_recebe_arquivo_conven_ws ;   
  
  /* Novo procedimento para retorno da listagem de arquivos processados */
  PROCEDURE pc_lista_retorno_conven_ws (pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_flgretor IN VARCHAR DEFAULT 'N'   --> Trazer arquivos j� retornados (S/N)
                                       ,pr_dtiniret IN VARCHAR DEFAULT NULL  --> Data inicial dos arquivos de retorno
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2) IS   --> XML de retorno da requisi��o
  BEGIN
    /* .............................................................................

       Programa: pc_valida_requisi_wsconven
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento para retorno da listagem dos arquivos
                   processados para determinado conv�nio. A requisi��o ainda 
                   permite que sejam retornados arquivos j� processados, desde 
                   que passado um per�odo inicial. 

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_des_erro VARCHAR2(4000);
      -- Convers�o da data
      vr_dtiniretor DATE;
      -- Contador de arquivos
      vr_qtdarquivos NUMBER;
      -- Arquivos a retornar
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,SUM(cnt.qtcaracteres_linha) qtdbytes
          FROM tbconv_arquivos arq
              ,tbconv_conteudo_arquivos cnt
         WHERE arq.idarquivo = cnt.idarquivo
           AND arq.cdconvenio = pr_cdconven
           AND (-- N�o trazer os j� retornados
                 (NVL(pr_flgretor,'N') = 'N' AND arq.flgprocessado = 0)
                  OR
                -- Trazer os retornados com data superior a solicitada
                 (pr_flgretor = 'S' AND arq.dtarquivo >= vr_dtiniretor) 
               )
         -- separar por id para retornar os arquivos de mesmo nome sem agrupar
         GROUP BY arq.idarquivo, arq.nmarquivo; 
    BEGIN
      -- Primeiramente acionaremos a rotina das valida��es b�sicas:
      pc_valida_requisi_wsconven(pr_dsusuari => pr_dsusuari
                                ,pr_dsdsenha => pr_dsdsenha
                                ,pr_cdconven => pr_cdconven
                                ,pr_cdretorn => vr_cdretorn
                                ,pr_dsmsgret => vr_dsmsgret);
      -- Se o retorno n�o for c�digo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execu��o:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_retxml);
        RETURN;
      END IF;
       
      -- Prosseguindo, iremos verificar se foi repassado a data inicial de busca e neste caso 
      -- se a mesma est� dentro do per�odo permitido:
      IF pr_dtiniret IS NOT NULL THEN
        -- Converter para date
        BEGIN
          vr_dtiniretor := to_date(pr_dtiniret,'dd/mm/rrrr');
        EXCEPTION
          WHEN OTHERS THEN
            pc_monta_retorno_ws(402,'Campo DtIniRetorno invalido! Nao eh uma data valida!',pr_retxml);
            RETURN;
        END;
        -- S� podemos receber requisi��es de no m�ximo 30 dias
        IF vr_dtiniretor < add_months(SYSDATE,-1) THEN
          pc_monta_retorno_ws(402,'Campo DtIniRetorno invalido! Nao permitido retorno de arquivos com processamento superior do que 1(um) mes!',pr_retxml);
          RETURN;
        END IF;
      END IF;
      -- Iniciar a montagem da resposta com:
      pc_monta_retorno_ws(202,'OK',pr_retxml); 
      -- Iniciar o contador de arquivos:
      vr_qtdarquivos := -1;
      -- Prosseguindo, devemos buscar os arquivos do conv�nio solicitado:
      FOR rw_arq IN cr_arquivos LOOP
        --- Para cada registro encontrado, incrementar o contador e criar novo registro no Array:
        vr_qtdarquivos := vr_qtdarquivos + 1;
        -- Iniciar tag titular
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Arquivo'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_des_erro);
        -- Enviar tag nmArquiv
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Arquivo'
                              ,pr_posicao  => vr_qtdarquivos
                              ,pr_tag_nova => 'nmArquiv'
                              ,pr_tag_cont => rw_arq.nmarquivo
                              ,pr_des_erro => vr_des_erro);
        
        -- Enviar tag qtBytesArquiv
        gene0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Arquivo'
                              ,pr_posicao  => vr_qtdarquivos
                              ,pr_tag_nova => 'qtBytesArquiv'
                              ,pr_tag_cont => rw_arq.qtdbytes
                              ,pr_des_erro => vr_des_erro);
      END LOOP;
      -- Ajustar a quantidade para n�o ficar negativa
      vr_qtdarquivos := vr_qtdarquivos + 1;
      -- Ao final, devemos enviar a TAG qtArquivos com a quantidade de arquivos que foram retornados:
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'qtArquivos'
                            ,pr_tag_cont => vr_qtdarquivos
                            ,pr_des_erro => vr_des_erro);
    EXCEPTION
       WHEN OTHERS THEN
         pc_monta_retorno_ws(402,'CONV0002.pc_lista_retorno_conven_ws - Erro nao tratado: ' || SQLERRM,pr_retxml);
    END;

  END pc_lista_retorno_conven_ws;  

  /* Novo procedimento para retorno de arquivo processados para determinado conv�nio */
  PROCEDURE pc_retorna_arquiv_conven_ws(pr_dsusuari IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_dsdsenha IN VARCHAR2              --> C�digo do usu�rio da requisi��o
                                       ,pr_cdconven IN gnconve.cdconven%TYPE --> Conv�nio da requisi��o
                                       ,pr_nmarquiv IN VARCHAR               --> Nome do arquivo solicitado
                                       ,pr_xmllog   IN VARCHAR2          
                                       ,pr_cdcritic OUT PLS_INTEGER      
                                       ,pr_dscritic OUT VARCHAR2       
                                       ,pr_retxml   IN OUT NOCOPY XMLType
                                       ,pr_nmdcampo OUT VARCHAR2         
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erro - se houver
  BEGIN
    /* .............................................................................

       Programa: pc_retorna_arquiv_conven_ws
       Sistema : Convenios
       Sigla   : CRED
       Autor   : Marcos Martini - Supero
       Data    : Junho/2016.                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Novo procedimento para retorno de arquivo processados para determinado conv�nio.  

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Testes de retorno de rotinas
      vr_cdretorn NUMBER;
      vr_dsmsgret VARCHAR2(2000);
      vr_dsdbytes CLOB;
      -- Arquivo a retornar
      CURSOR cr_arquivo IS
        SELECT arq.idarquivo
          FROM tbconv_arquivos arq
         WHERE arq.cdconvenio = pr_cdconven
           AND arq.nmarquivo  = pr_nmarquiv
         ORDER BY arq.dtarquivo;  -- Retornar sempre o mais antigo primeiro
      vr_idarquivo tbconv_arquivos.idarquivo%TYPE;     
      -- Buscar as linhas do arquivo
      CURSOR cr_conteudo IS
        SELECT cnt.dstexto_linha
          FROM tbconv_conteudo_arquivos cnt
         WHERE cnt.idarquivo = vr_idArquivo
         ORDER BY cnt.idlinha;
    BEGIN
      -- Primeiramente acionaremos a rotina das valida��es b�sicas:
      pc_valida_requisi_wsconven(pr_dsusuari => pr_dsusuari
                                ,pr_dsdsenha => pr_dsdsenha
                                ,pr_cdconven => pr_cdconven
                                ,pr_cdretorn => vr_cdretorn
                                ,pr_dsmsgret => vr_dsmsgret);
      -- Se o retorno n�o for c�digo 202
      IF vr_cdretorn <> 202 THEN
        -- Devemos finalizar montando o retorno e sair da execu��o:
        pc_monta_retorno_ws(vr_cdretorn,vr_dsmsgret,pr_retxml);
        RETURN;
      END IF;
       
      -- Prosseguindo, devemos buscar o arquivo do conv�nio solicitado 
      OPEN cr_arquivo;
      FETCH cr_arquivo
       INTO vr_idarquivo;
      CLOSE cr_arquivo;
      
      -- Se n�o encontrarmos
      IF vr_idarquivo IS NULL THEN
        -- Retornar erro
        pc_monta_retorno_ws(402,'Arquivo ['||pr_cdconven||'_'||pr_nmarquiv||'] inexistente para o convenio!',pr_retxml);
        RETURN;
      END IF; 
      
      -- Com o id do arquivo encontrado, iremos buscar todas as linhas do arquivo : 
      FOR rw_cont IN cr_conteudo LOOP
        -- Para cada registro da Query, concatenar os bytes lidos para a vari�vel de sa�da:
        vr_dsdbytes := vr_dsdbytes || rw_cont.dstexto_linha || chr(10);
      END LOOP;
      
      --Ao final, removemos a �ltima quebra de linha concatenada:
      vr_dsdbytes := RTRIM(vr_dsdbytes,chr(10)); 
      
      -- Iniciar a montagem da resposta com:
      pc_monta_retorno_ws(202,'OK',pr_retxml); 
      
      -- Inserir a tag do texto do arquivo
      gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dsbytes'
                            ,pr_tag_cont => vr_dsdbytes
                            ,pr_des_erro => pr_dscritic);
      
      -- Ap�s a leitura completa do arquivo, iremos atualizar o processamento do mesmo:
      BEGIN
        UPDATE tbconv_arquivos arq
           SET arq.flgprocessado = 1
          WHERE arq.idarquivo = vr_idArquivo;
      EXCEPTION
        WHEN OTHERS THEN
          --pr_dscritic := '402 - Erro na atualiza��o do arquivo -> '||SQLERRM;
          pc_monta_retorno_ws(402,'Erro na atualiza��o do arquivo: ' || SQLERRM,pr_retxml);
          ROLLBACK;
          RETURN;
      END;
      
      -- Ao final, podemos commitar as altera��es na base de dados:
      COMMIT;
      
    EXCEPTION
       WHEN OTHERS THEN
         pc_monta_retorno_ws(402,'CONV0002.pc_retorna_arquiv_conven_ws - Erro nao tratado: ' || SQLERRM,pr_retxml);
    END;

  END pc_retorna_arquiv_conven_ws ;   

END CONV0002;
/
