CREATE OR REPLACE PACKAGE CECRED.GENE0007 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0007
  --  Sistema  : Rotinas para manipulação de XML
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Junho/2013.                   Ultima atualizacao: 29/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Executar manipulações diversas em stream XML.
  --
  -- Alteracoes: 30/06/2015 - Converte os caracteres especiais de acordo com o CHARSET
  --                          (Andre Santos - SUPERO)
  --
  --             29/08/2016 - Criacao da fn_remove_cdata. (Jaison/Anderson)
  --
  ---------------------------------------------------------------------------------------------------------------

  /* Definições de objetos de uso comum por outras rotinas */

  -- Definição array bidimensional para armazenar dados para o XML
  TYPE typ_array IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(400);
  TYPE typ_mult_array IS TABLE OF typ_array INDEX BY PLS_INTEGER;

  -- Definição de PL Table para armazenar os nomes das TAG´s do XML para iteração
  TYPE typ_reg_tagxml IS
    RECORD(tag  VARCHAR2(32767));

  -- Declaração do tipo para a PL Table de nomes das TAG´s
  TYPE typ_tab_tagxml IS TABLE OF typ_reg_tagxml INDEX BY PLS_INTEGER;


  /* Definições de procedures/functions de uso público */

  /* Função para invocar classe Java para executar parser SAX (XML) */
  FUNCTION fn_valida_xml(pr_xmldoc IN CLOB) RETURN VARCHAR2;   --> CLOB com o XML gerado

  /* Função para converter caracteres de controle para suas entidades */
  FUNCTION fn_caract_controle(pr_texto IN VARCHAR2) RETURN VARCHAR2;  --> String para limpeza

  /* Função para remover acentuação e demais sinais silábicos */
  FUNCTION fn_caract_acento(pr_texto IN VARCHAR2,                                                   --> String para limpeza
                            pr_insubsti IN PLS_INTEGER DEFAULT 0,                                   --> Flag para substituir
                            pr_dssubsin IN VARCHAR2 DEFAULT '@#$&%¹²³ªº°*!?<>/\|',                  --> String de entrada
                            pr_dssubout IN VARCHAR2 DEFAULT '                   ') RETURN VARCHAR2; --> String de saida
  
  /* Função para substituir os caractertes especiais por codigos HTML */
  FUNCTION fn_acento_xml(pr_texto IN VARCHAR2) RETURN VARCHAR2;  --> String para conversao

  /* Procedure para substituir os caractertes especiais por codigos HTML */
  PROCEDURE pc_caract_acento(pr_texto    IN  VARCHAR2,                                  --> String para limpeza
                             pr_insubsti IN  PLS_INTEGER DEFAULT 0,                     --> Flag para substituir
                             pr_clstexto OUT VARCHAR2);
                             
  /* Procedure para gerar nomes das TAG do XML */
  PROCEDURE pc_gera_tag(pr_nome_tag  IN VARCHAR2                     --> Nome da TAG
                       ,pr_tab_tag   IN OUT NOCOPY typ_tab_tagxml);  --> PL Table que armazena os nomes

  /* Procedure para gerar TAG´s do XML */
  PROCEDURE pc_gera_xml(pr_tab_dados  IN OUT NOCOPY typ_mult_array    --> Array que armazena os dados do xml
                       ,pr_tab_tag    IN OUT NOCOPY typ_tab_tagxml    --> PL Table que armazena os nomes do xml
                       ,pr_XMLType    IN OUT NOCOPY XMLType           --> Arquivo XML criado e que receberá os dados
                       ,pr_path_tag   IN VARCHAR2                     --> Path da TAG que irá receber o novo nó
                       ,pr_tag_no     IN VARCHAR2                     --> TAG que representa o novo nó
                       ,pr_des_erro   OUT VARCHAR2);                  --> Descrição do erro

  /* Procedure para criar novo atributo (com valor) em TAG XML */
  PROCEDURE pc_gera_atributo(pr_xml      IN OUT NOCOPY xmltype   --> XML que irá receber o novo atributo
                            ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                            ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                            ,pr_atval    IN VARCHAR2             --> Valor do atributo
                            ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                            ,pr_des_erro OUT VARCHAR2);          --> Descrição de erros

  /* Procedure para alterar o valor de um atributo em TAG XML */
  PROCEDURE pc_altera_atributo(pr_xml      IN OUT NOCOPY xmltype   --> XML que irá receber o novo atributo
                              ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                              ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                              ,pr_atval    IN VARCHAR2             --> Valor do atributo
                              ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                              ,pr_des_erro OUT VARCHAR2);          --> Descrição de erros

  /* Function para ler o valor de um atributo da TAG XML */
  FUNCTION fn_valor_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument     --> XML que irá receber o novo atributo
                            ,pr_tag      IN VARCHAR2                               --> Nome da TAG XML
                            ,pr_atrib    IN VARCHAR2                               --> Nome do atributo
                            ,pr_numva    IN PLS_INTEGER) RETURN VARCHAR2;          --> Número da localização da TAG na árvore XML
  
  /* Procedure para remover um atributo em TAG XML */
  PROCEDURE pc_remove_atributo(pr_xml      IN OUT NOCOPY xmltype   --> XML que irá receber o novo atributo
                              ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                              ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                              ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                              ,pr_des_erro OUT VARCHAR2);          --> Descrição de erros

  /* Procedure para contar a quantidade de atributos em uma TAG XML */
  PROCEDURE pc_lista_atributo(pr_xml      IN OUT NOCOPY xmltype  --> Stream XML
                             ,pr_tag      IN VARCHAR2            --> Nome da TAG que será pesquisada
                             ,pr_numva    IN PLS_INTEGER         --> Número da localização da TAG na árvore XML
                             ,pr_numatr   OUT PLS_INTEGER        --> Número de atributos da TAG
                             ,pr_des_erro OUT VARCHAR2);         --> Descrição de erros
  
  /* Procedure para contar a quantidade de atributos em uma TAG XML (sobrecarga) */
  PROCEDURE pc_lista_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                             ,pr_tag      IN VARCHAR2                            --> Nome da TAG que será pesquisada
                             ,pr_numva    IN PLS_INTEGER                         --> Número da localização da TAG na árvore XML
                             ,pr_numatr   OUT PLS_INTEGER                        --> Número de atributos da TAG
                             ,pr_des_erro OUT VARCHAR2);                         --> Descrição de erros
                             
  /* Function para retornar o nome de um atributo de uma determinada TAG */
  FUNCTION fn_nome_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                           ,pr_tag      IN VARCHAR2                            --> Nome da TAG que será pesquisada
                           ,pr_numva    IN PLS_INTEGER                         --> Número da localização da TAG na árvore XML
                           ,pr_numatr   IN PLS_INTEGER) RETURN VARCHAR2;       --> Número da localização do atributo dentro da TAG 
                           
  /* Procedure para contar as ocorrências de um nodo informado em um XML */
  PROCEDURE pc_lista_nodo(pr_xml      IN OUT NOCOPY xmltype  --> Stream XML
                         ,pr_nodo     IN VARCHAR2            --> Nodo que será pesquisado
                         ,pr_cont     OUT PLS_INTEGER        --> Número de ocorrências
                         ,pr_des_erro OUT VARCHAR2);         --> Descrição de erros

  /* Procedure para contar as ocorrências de um nodo informado em um XML (sobrecarga) */
  PROCEDURE pc_lista_nodo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                         ,pr_nodo     IN VARCHAR2                            --> Nodo que será pesquisado
                         ,pr_cont     OUT PLS_INTEGER                        --> Número de ocorrências
                         ,pr_des_erro OUT VARCHAR2);                         --> Descrição de erros
                         
  /* Procedure para incluir uma nova TAG em um nodo XML */
  PROCEDURE pc_insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG e seu conteúdo
                         ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Procedure para alterar conteúdo de uma TAG */
  PROCEDURE pc_altera_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                         ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Procedure para excluir uma TAG */
  PROCEDURE pc_exclui_tag(pr_xml      IN OUT NOCOPY XMLType  --> Stream XML
                         ,pr_tag_exc  IN VARCHAR2            --> TAG que será excluída
                         ,pr_pos_exc  IN PLS_INTEGER         --> Posição da TAg que será excluída na lista
                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo
                         
  /* Function para retornar o valor de uma TAG */
  FUNCTION fn_valor_tag(pr_xml     IN OUT NOCOPY XMLTYPE           --> Documento XML
                       ,pr_pos_exc IN PLS_INTEGER                  --> Posição da TAG que será pesquisada
                       ,pr_nomtag  IN VARCHAR2) RETURN VARCHAR2;   --> Nome da TAG
  
  /* Procedure para gerar PL Table com lista de valores referentes aos nodos de um nodo pai */
  PROCEDURE pc_itera_nodos(pr_xpath      IN VARCHAR2               --> Xpath do nodo a ser pesquisado
                          ,pr_xml        IN OUT NOCOPY xmltype     --> Documento XML
                          ,pr_namespace  IN VARCHAR2 DEFAULT NULL  --> Namespace do documento XML
                          ,pr_list_nodos OUT typ_tab_tagxml        --> PL Table com valores
                          ,pr_des_erro   OUT VARCHAR2);            --> Erros do processo

  /* Procedure para gerar PL Table com lista de valores referentes aos nodos de um nodo pai */
  PROCEDURE pc_itera_nodos(pr_nodo       IN DBMS_XMLDOM.DOMNode      --> Xpath do nodo a ser pesquisado
                          ,pr_nivel      IN PLS_INTEGER              --> Nível que será pesquisado
                          ,pr_list_nodos OUT typ_mult_array          --> PL Table com os nodos resgatados
                          ,pr_des_erro   OUT VARCHAR2);              --> Erros do processo

  /* Criar documento XML com base no fragmento de outro XML */
  FUNCTION fn_gera_xml_frag(pr_xml_frag  IN VARCHAR2) RETURN xmltype;    --> Fragmento do documento XML

  /* Montar namespace completo (identificador + URI) para formar dados do nodo */
  FUNCTION fn_gera_namespace(pr_attrmap IN DBMS_XMLDOM.DOMNamedNodeMap    --> Mapa DOM do elemento
                            ,pr_namesp  IN VARCHAR2) RETURN VARCHAR2;     --> URI do namespace pesquisado
                            
  /* Converte os caracteres especiais de acordo com o CHARSET */
  FUNCTION fn_convert_web_db(pr_convtext IN VARCHAR2) RETURN VARCHAR2; 
  FUNCTION fn_convert_db_web(pr_convtext IN VARCHAR2) RETURN VARCHAR2;

  /* Remover CDATA da string */
  FUNCTION fn_remove_cdata(pr_texto IN VARCHAR2) RETURN VARCHAR2;  --> String de saida
    
END GENE0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE0007 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0007
  --  Sistema  : Rotinas para manipulação de XML
  --  Sigla    : GENE
  --  Autor    : Petter R. Villa Real  - Supero
  --  Data     : Junho/2013.                   Ultima atualizacao: 06/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Executar manipulações diversas em stream XML.
  --
  -- Alteracoes: 30/06/2015 - Converte os caracteres especiais de acordo com o CHARSET
  --                          (Andre Santos - SUPERO)
  --
  --             29/08/2016 - Criacao da fn_remove_cdata. (Jaison/Anderson)
  --
  --             06/09/2017 - Criacao da procedure pc_caract_acento que remove acentuacao
  --                          e caracteres especiais conforme parametro (Tiago #722921)
  ---------------------------------------------------------------------------------------------------------------

  /* Função para invocar classe Java para executar parser SAX (XML) */
  FUNCTION fn_valida_xml(pr_xmldoc IN CLOB) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'ValidarXML.validarCLOB(oracle.sql.CLOB) returns java.lang.String';
  /*..............................................................................

       Programa: fn_valida_xml
       Autor   : Petter (Supero)
       Data    : Março/2013                      Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Invocar classe Java ancorada no Banco de Dados para realizar
                   parser de CLOB contendo XML.

       Alteracoes:

    ..............................................................................*/

  /* Função para converter caracteres de controle para suas entidades */
  FUNCTION fn_caract_controle(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS  --> String para limpeza
    -- ..........................................................................
    --
    --  Programa : fn_caract_controle
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Limpar uma string informada dos caracteres de controle para suas respectivas entidades.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    BEGIN
      RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pr_texto, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'), '"', '&quot;'), '''', '&apos;');
    END;
  END fn_caract_controle;

  /* Função para remover acentuação e demais sinais silábicos */
  FUNCTION fn_caract_acento(pr_texto IN VARCHAR2,                                                     --> String para limpeza
                            pr_insubsti IN PLS_INTEGER DEFAULT 0,                                     --> Flag para substituir
                            pr_dssubsin IN VARCHAR2 DEFAULT '@#$&%¹²³ªº°*!?<>/\|',                    --> String de entrada
                            pr_dssubout IN VARCHAR2 DEFAULT '                   ') RETURN VARCHAR2 IS --> String de saida
    -- ..........................................................................
    --
    --  Programa : fn_caract_acento
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: 13/11/2015
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Remover acentos de caracteres e demais sinais silábicos.
    --
    --  Alteracoes: 19/02/2014 - Substituir o loop com o comando replace, pelo Translate
    --                           a fim de melhorar a performace (Odirlei-AMcom)
    --
    --              22/05/2015 - Substituir os caracteres especiais por caracteres
    --                           informados. (Jaison/Thiago - SD: 286623)
    --
    --              13/11/2015 - Incluir apostofro e acentos SD358050 (Odirlei-AMcom )
    -- .............................................................................

      vr_texto VARCHAR2(32000);

  BEGIN
      --Substitui os caracteres com acento pelos caracteres sem acentuação, conforme a ordem da string
      vr_texto := TRANSLATE(pr_texto, 'áàãâäèéêëìíîïòóôõöúùûüÿñçÁÀÃÂÄÈÉÊËÌÍÎÏÒÓÔÕÖÚÙÛÜÑÇýÝ',
                                      'aaaaaeeeeiiiiooooouuuuyncAAAAAEEEEIIIIOOOOOUUUUNCyY');

      vr_texto := TRANSLATE(vr_texto,'´`^~''',
                                     '     ');

      IF pr_insubsti = 1 THEN
        --Substitui os caracteres especiais pelos caracteres informados, conforme a ordem da string
        vr_texto := TRANSLATE(vr_texto, pr_dssubsin, pr_dssubout);
      END IF;

      RETURN vr_texto;
  END fn_caract_acento;

  FUNCTION fn_acento_xml(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS  --> String para conversao
    -- ..........................................................................
    --
    --  Programa : fn_acento_xml
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Andrino Carlos de Souza Junior (RKAM)
    --  Data     : Outubro/2014.               Ultima atualizacao: 20/10/2014
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Substituir os caractertes especiais por codigos HTML
    --
    --  Alteracoes: 
    --                           
    -- .............................................................................
  BEGIN
      --Substitui os caracteres com acento pelos caracteres sem acentuação, conforme a ordem da string
      RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                     REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                     REPLACE(REPLACE(REPLACE(REPLACE(
                     REPLACE(pr_texto,'á','&aacute;'),
                                      'à','&agrave;'),
                                      'í','&iacute;'),
                                      'ô','&ocirc;'),
                                      'Á','&Aacute;'),
                                      'À','&Agrave;'),
                                      'Í','&Iacute;'),
                                      'Ô','&Ocirc;'),
                                      'ã','&atilde;'),
                                      'é','&eacute;'),
                                      'ó','&oacute;'),
                                      'ú','&uacute;'),
                                      'Ã','&Atilde;'),
                                      'É','&Eacute;'),
                                      'Ó','&Oacute;'),
                                      'Ú','&Uacute;'),
                                      'â','&acirc;'),
                                      'ê','&ecirc;'),
                                      'õ','&otilde;'),
                                      'ç','&ccedil;'),
                                      'Â','&Acirc;'),
                                      'Ê','&Ecirc;'),
                                      'Õ','&Otilde;'),
                                      'Ç','&Ccedil;');
  END fn_acento_xml;


  PROCEDURE pc_caract_acento(pr_texto    IN  VARCHAR2,                                  --> String para limpeza
                             pr_insubsti IN  PLS_INTEGER DEFAULT 0,                     --> Flag para substituir
                             pr_clstexto OUT VARCHAR2) IS
    -- ..........................................................................
    --
    --  Programa : pc_caract_acento
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Tiago 
    --  Data     : Setembro/2017.                   Ultima atualizacao: 00/00/0000
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Remover acentos de caracteres e demais sinais silábicos.
    --
    --  Alteracoes: 00/00/0000 - xxxx
    -- .............................................................................
  BEGIN
    pr_clstexto := NVL(fn_caract_acento(pr_texto    => pr_texto
                                       ,pr_insubsti => pr_insubsti                    
                                       ,pr_dssubsin => '@#$&%¹²³ªº°*!?<>/\|'
                                       ,pr_dssubout => '                    '),pr_texto);
  END pc_caract_acento;

  /* Procedure para definir nomes das TAG do XML */
  PROCEDURE pc_gera_tag(pr_nome_tag  IN VARCHAR2                       --> Nome da TAG
                       ,pr_tab_tag   IN OUT NOCOPY typ_tab_tagxml) IS  --> PL Table que armazena os nomes
    -- ..........................................................................
    --
    --  Programa : pc_gera_tag
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Definir em PL Table os nomes das TAG´s que irão formar o XML.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_index    NUMBER;   --> Indexador para PL Table

    BEGIN
      -- Gera índice para próximo registro
      vr_index := pr_tab_tag.count + 1;

      -- Grava nome na PL Table
      pr_tab_tag(vr_index).tag := pr_nome_tag;
    END;
  END pc_gera_tag;

  /* Procedure para gerar TAG´s do XML */
  PROCEDURE pc_gera_xml(pr_tab_dados  IN OUT NOCOPY typ_mult_array    --> Array que armazena os dados do xml
                       ,pr_tab_tag    IN OUT NOCOPY typ_tab_tagxml    --> PL Table que armazena os nomes do xml
                       ,pr_XMLType    IN OUT NOCOPY XMLType           --> Arquivo XML criado e que receberá os dados
                       ,pr_path_tag   IN VARCHAR2                     --> Path da TAG que irá receber o novo nó
                       ,pr_tag_no     IN VARCHAR2                     --> TAG que representa o novo nó
                       ,pr_des_erro   OUT VARCHAR2) IS                --> Descrição do erro
    -- ..........................................................................
    --
    --  Programa : pc_gera_xml
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Criar um novo nodo em um XML informado.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_tags      PLS_INTEGER;       --> Número total de TAGs do XML cadastradas
      vr_tag_xml   VARCHAR2(4000);    --> Nó do XML que será gerado
      vr_exc_erro  EXCEPTION;         --> Controle de erros

    BEGIN
      -- Assimila o número de TAG´s para o XML
      vr_tags := pr_tab_tag.count;

      -- Iteração sob os regristros de dados para formar o XML
      FOR campo IN 1..pr_tab_dados.count LOOP
        -- Limpar conteúdo da variável
        vr_tag_xml := NULL;

        -- Iteração sob as TAG´s
        IF TRIM(both ' ' FROM pr_tag_no) IS NOT NULL THEN
          vr_tag_xml := '<' || pr_tag_no || '>';
        END IF;

        FOR tag IN 1..vr_tags LOOP
          -- Formar string que será o novo nó do XML
          vr_tag_xml := vr_tag_xml || '<' || pr_tab_tag(tag).tag || '>';

          BEGIN
            -- Buscar valores em array bidimensional
            IF length(TRIM(pr_tab_dados(campo)(pr_tab_tag(tag).tag))) > 0 THEN
              vr_tag_xml := vr_tag_xml || '<![CDATA[' || pr_tab_dados(campo)(pr_tab_tag(tag).tag) || ']]>';
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              IF SQLCODE = 100 THEN
                -- Gera TAG sem dados
                NULL;
              ELSE
                -- Gera erros do processo
                pr_des_erro := 'Erro em pc_gera_xml: ' || SQLERRM;
                RAISE vr_exc_erro;
              END IF;
          END;

          -- Fechar TAG XML
          vr_tag_xml := vr_tag_xml || '</' || pr_tab_tag(tag).tag || '>';
        END LOOP;

        -- Fechar TAG pai
        IF TRIM(both ' ' FROM pr_tag_no) IS NOT NULL THEN
          vr_tag_xml := vr_tag_xml || '</' || pr_tag_no || '>';
        END IF;

        -- Gerar nó XML
        pr_XMLType := XMLTYPE.appendChildXML(pr_XMLType
                                            ,pr_path_tag
                                            ,XMLTYPE(vr_tag_xml));
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_gera_xml: ' || SQLERRM;
    END;
  END pc_gera_xml;

  /* Procedure para criar novo atributo (com valor) em TAG XML */
  PROCEDURE pc_gera_atributo(pr_xml      IN OUT NOCOPY XMLTYPE   --> XML que irá receber o novo atributo
                            ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                            ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                            ,pr_atval    IN VARCHAR2             --> Valor do atributo
                            ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                            ,pr_des_erro OUT VARCHAR2) IS        --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_gera_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Criar um novo atributo junto ao seu valor em um TAG XML informada.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nodo      DBMS_XMLDOM.DOMElement;       --> Definição do elemento XML
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag), pr_numva));
      -- Define o valor do atributo
      DBMS_XMLDOM.setAttribute(vr_nodo, pr_atrib, pr_atval);
      -- Gerar o novo atributo no XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_gera_atributo: ' || SQLERRM;
    END;
  END pc_gera_atributo;

  /* Procedure para alterar o valor de um atributo em TAG XML */
  PROCEDURE pc_altera_atributo(pr_xml      IN OUT NOCOPY XMLTYPE   --> XML que irá receber o novo atributo
                              ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                              ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                              ,pr_atval    IN VARCHAR2             --> Valor do atributo
                              ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                              ,pr_des_erro OUT VARCHAR2) IS        --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_altera_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Altera o valor de um atributo em uma TAG XML informada.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nodo      DBMS_XMLDOM.DOMElement;       --> Definição do elemento XML
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag), pr_numva));
      -- Altera o valor do atributo
      DBMS_XMLDOM.setAttribute(vr_nodo, pr_atrib, pr_atval);
      -- Gerar o novo atributo no XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_altera_atributo: ' || SQLERRM;
    END;
  END pc_altera_atributo;
  
  /* Function para ler o valor de um atributo da TAG XML */
  FUNCTION fn_valor_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument     --> XML que irá receber o novo atributo
                            ,pr_tag      IN VARCHAR2                               --> Nome da TAG XML
                            ,pr_atrib    IN VARCHAR2                               --> Nome do atributo
                            ,pr_numva    IN PLS_INTEGER) RETURN VARCHAR2 IS        --> Número da localização da TAG na árvore XML
    -- ..........................................................................
    --
    --  Programa : pc_le_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Lê e retorna o valor de um atributo.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nodo      DBMS_XMLDOM.DOMElement;       --> Definição do elemento XML
      
    BEGIN
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(pr_xml, pr_tag), pr_numva));
      -- Lê o valor do atributo
      RETURN DBMS_XMLDOM.getAttribute(vr_nodo, pr_atrib);
    END;
  END fn_valor_atributo;

  /* Procedure para remover um atributo em TAG XML */
  PROCEDURE pc_remove_atributo(pr_xml      IN OUT NOCOPY XMLTYPE   --> XML que irá receber o novo atributo
                              ,pr_tag      IN VARCHAR2             --> Nome da TAG XML
                              ,pr_atrib    IN VARCHAR2             --> Nome do atributo
                              ,pr_numva    IN PLS_INTEGER          --> Número da localização da TAG na árvore XML
                              ,pr_des_erro OUT VARCHAR2) IS        --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_remove_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Remove um atributo de uma TAG XML informada.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nodo      DBMS_XMLDOM.DOMElement;       --> Definição do elemento XML
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag), pr_numva));
      -- Remove o atributo da TAG XML
      DBMS_XMLDOM.removeAttribute(vr_nodo, pr_atrib);
      -- Gerar o novo atributo no XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em pc_remove_atributo: ' || SQLERRM;
    END;
  END pc_remove_atributo;
  
  /* Procedure para contar a quantidade de atributos em uma TAG XML */
  PROCEDURE pc_lista_atributo(pr_xml      IN OUT NOCOPY XMLTYPE  --> Stream XML
                             ,pr_tag      IN VARCHAR2            --> Nome da TAG que será pesquisada
                             ,pr_numva    IN PLS_INTEGER         --> Número da localização da TAG na árvore XML
                             ,pr_numatr   OUT PLS_INTEGER        --> Número de atributos da TAG
                             ,pr_des_erro OUT VARCHAR2) IS       --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_lista_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar o número de atributos de um nodo informado.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
       vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
       vr_nodo      DBMS_XMLDOM.DOMElement;       --> Nodo pesquisado
       vr_nodoDOM   DBMS_XMLDOM.DOMNode;          --> Criar nodo pela TAG descoberta
       vr_lstatr    DBMS_XMLDOM.DOMNamedNodeMap;  --> Mapeamento da TAG

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag), pr_numva));
      -- Criar nodo DOM
      vr_nodoDOM := DBMS_XMLDOM.makeNode(vr_nodo);
      -- Retornar nodeMap da TAG
      vr_lstatr := DBMS_XMLDOM.getAttributes(vr_nodoDOM);
      -- Contar ocorrências de atributos
      pr_numatr := DBMS_XMLDOM.getLength(vr_lstatr);
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_lista_atributo: ' || SQLERRM;
    END;    
  END pc_lista_atributo;
  
  /* Procedure para contar a quantidade de atributos em uma TAG XML (sobrecarga) */
  PROCEDURE pc_lista_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                             ,pr_tag      IN VARCHAR2                            --> Nome da TAG que será pesquisada
                             ,pr_numva    IN PLS_INTEGER                         --> Número da localização da TAG na árvore XML
                             ,pr_numatr   OUT PLS_INTEGER                        --> Número de atributos da TAG
                             ,pr_des_erro OUT VARCHAR2) IS                       --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_lista_atributo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar o número de atributos de um nodo informado.
    --               Este é um método de sobrecarga utilizando DOM diretamente.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
       vr_nodo      DBMS_XMLDOM.DOMElement;       --> Nodo pesquisado
       vr_nodoDOM   DBMS_XMLDOM.DOMNode;          --> Criar nodo pela TAG descoberta
       vr_lstatr    DBMS_XMLDOM.DOMNamedNodeMap;  --> Mapeamento da TAG

    BEGIN
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(pr_xml, pr_tag), pr_numva));
      -- Criar nodo DOM
      vr_nodoDOM := DBMS_XMLDOM.makeNode(vr_nodo);
      -- Retornar nodeMap da TAG
      vr_lstatr := DBMS_XMLDOM.getAttributes(vr_nodoDOM);
      -- Contar ocorrências de atributos
      pr_numatr := DBMS_XMLDOM.getLength(vr_lstatr);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_lista_atributo: ' || SQLERRM;
    END;    
  END pc_lista_atributo;
  
  /* Function para retornar o nome de um atributo de uma determinada TAG */
  FUNCTION fn_nome_atributo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                           ,pr_tag      IN VARCHAR2                            --> Nome da TAG que será pesquisada
                           ,pr_numva    IN PLS_INTEGER                         --> Número da localização da TAG na árvore XML
                           ,pr_numatr   IN PLS_INTEGER) RETURN VARCHAR2 IS     --> Número da localização do atributo dentro da TAG     
  BEGIN
    DECLARE
       vr_nodo      DBMS_XMLDOM.DOMElement;       --> Nodo pesquisado
       vr_nodoDOM   DBMS_XMLDOM.DOMNode;          --> Criar nodo pela TAG descoberta
       vr_lstatr    DBMS_XMLDOM.DOMNamedNodeMap;  --> Mapeamento da TAG

    BEGIN
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodo := DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(pr_xml, pr_tag), pr_numva));
      -- Criar nodo DOM
      vr_nodoDOM := DBMS_XMLDOM.makeNode(vr_nodo);
      -- Retornar nodeMap da TAG
      vr_lstatr := DBMS_XMLDOM.getAttributes(vr_nodoDOM);
      -- Contar ocorrências de atributos
      RETURN DBMS_XMLDOM.getnodename(DBMS_XMLDOM.item(vr_lstatr, pr_numatr));
    END;    
  END fn_nome_atributo;

  /* Procedure para contar as ocorrências de um nodo informado em um XML */
  PROCEDURE pc_lista_nodo(pr_xml      IN OUT NOCOPY XMLTYPE  --> Stream XML
                         ,pr_nodo     IN VARCHAR2            --> Nodo que será pesquisado
                         ,pr_cont     OUT PLS_INTEGER        --> Número de ocorrências
                         ,pr_des_erro OUT VARCHAR2) IS       --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_lista_nodo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar o número de ocorrências de um nodo informado.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
       vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
       vr_nodelist  DBMS_XMLDOM.DOMNodeList;      --> Lista de nodos localizados

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodelist := DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_nodo);
      -- Contagem das ocorrências
      pr_cont :=  DBMS_XMLDOM.getLength(vr_nodelist);
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_lista_nodo: ' || SQLERRM;
    END;
  END pc_lista_nodo;
  
  /* Procedure para contar as ocorrências de um nodo informado em um XML (sobrecarga) */
  PROCEDURE pc_lista_nodo(pr_xml      IN OUT NOCOPY DBMS_XMLDOM.DOMDocument  --> Stream XML
                         ,pr_nodo     IN VARCHAR2                            --> Nodo que será pesquisado
                         ,pr_cont     OUT PLS_INTEGER                        --> Número de ocorrências
                         ,pr_des_erro OUT VARCHAR2) IS                       --> Descrição de erros
    -- ..........................................................................
    --
    --  Programa : pc_lista_nodo
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Maio/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar o número de ocorrências de um nodo informado.
    --               Este é um método de sobrecarga utilizando DOM diretamente.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
       vr_nodelist  DBMS_XMLDOM.DOMNodeList;      --> Lista de nodos localizados

    BEGIN
      -- Localiza o nodo XML informado dentro da árvore XML
      vr_nodelist := DBMS_XMLDOM.getElementsByTagName(pr_xml, pr_nodo);
      -- Contagem das ocorrências
      pr_cont :=  DBMS_XMLDOM.getLength(vr_nodelist);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_lista_nodo: ' || SQLERRM;
    END;
  END pc_lista_nodo;

  /* Procedure para incluir uma nova TAG em um nodo XML */
  PROCEDURE pc_insere_tag(pr_xml      IN OUT NOCOPY XMLType  --> XML que receberá a nova TAG
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que receberá a nova TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_tag_nova IN VARCHAR2            --> String com a nova TAG
                         ,pr_tag_cont IN VARCHAR2            --> Conteúdo da nova TAG
                         ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : pc_insere_tag
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Inserir uma nova TAG em um nodo XML.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
      vr_elemento  DBMS_XMLDOM.DOMElement;       --> Novo elemento que será adicionado
      vr_novoNodo  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
      vr_paiNodo   DBMS_XMLDOM.DOMNode;          --> Nodo pai
      vr_texto     DBMS_XMLDOM.DOMText;          --> Texto que será incluido

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Criar novo elemento
      vr_elemento := DBMS_XMLDOM.createElement(vr_domDoc, pr_tag_nova);
      -- Criar novo nodo
      vr_novoNodo := DBMS_XMLDOM.makeNode(vr_elemento);
      -- Definir nodo pai
      vr_paiNodo := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_pai), pr_posicao)));
      -- Adiciona novo nodo no nodo pai
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_paiNodo, vr_novoNodo);
      -- Adiciona o conteúdo ao novo nodo
      vr_texto := DBMS_XMLDOM.createTextNode(vr_domDoc, pr_tag_cont);
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_novoNodo, DBMS_XMLDOM.makeNode(vr_texto));

      -- Gerar o novo stream XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_insere_tag: ' || SQLERRM;
    END;
  END pc_insere_tag;

  /* Procedure para alterar conteúdo de uma TAG */
  PROCEDURE pc_altera_tag(pr_xml      IN OUT NOCOPY XMLType  --> Stream XML
                         ,pr_tag_pai  IN VARCHAR2            --> TAG que terá o conteúdo alterado
                         ,pr_tag_cont IN VARCHAR2            --> Novo conteúdo da TAG
                         ,pr_posicao  IN PLS_INTEGER         --> Posição da tag na lista
                         ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : pc_altera_tag
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Alterar o conteúdo de um nodo.
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
      vr_texto     DBMS_XMLDOM.DOMText;          --> Texto que será incluido
      vr_nodo      DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
      vr_nodo_ant  DBMS_XMLDOM.DOMNode;          --> Nodo antigo
      vr_elemento  DBMS_XMLDOM.DOMElement;       --> Novo elemento que será adicionado
      vr_novoNodo  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento
      vr_paiNodo   DBMS_XMLDOM.DOMNode;          --> Nodo pai

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Define o nodo que terá o conteúdo alterado
      vr_nodo := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_pai)
                                                                              ,pr_posicao)));
      -- Captura nodo pai
      vr_paiNodo := DBMS_XMLDOM.getParentNode(vr_nodo);
      -- Adiciona o conteúdo ao elemento do novo nodo
      vr_texto := DBMS_XMLDOM.createTextNode(vr_domDoc, pr_tag_cont);
      -- Remove o conteúdo do nodo atual
      vr_nodo_ant := DBMS_XMLDOM.removeChild(vr_nodo, vr_nodo);
      -- Recriar elemento e nodo XML
      vr_elemento := DBMS_XMLDOM.createElement(vr_domDoc, pr_tag_pai);
      vr_novoNodo := DBMS_XMLDOM.makeNode(vr_elemento);
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_paiNodo, vr_novoNodo);
      -- Adiciona o novo conteúdo no nodo atual
      vr_novoNodo := DBMS_XMLDOM.appendChild(vr_novoNodo, DBMS_XMLDOM.makeNode(vr_texto));
      -- Gerar o novo stream XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_altera_tag: ' || SQLERRM;
    END;
  END pc_altera_tag;

  /* Procedure para excluir uma TAG */
  PROCEDURE pc_exclui_tag(pr_xml      IN OUT NOCOPY XMLType  --> Stream XML
                         ,pr_tag_exc  IN VARCHAR2            --> TAG que será excluída
                         ,pr_pos_exc  IN PLS_INTEGER         --> Posição da TAG que será excluída na lista
                         ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : pc_exclui_tag
    --  Sistema  : Rotinas de tratamento e interface para intercambio de dados com sistema Web
    --  Sigla    : GENE
    --  Autor    : Petter R. Villa Real  - Supero
    --  Data     : Junho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Excluir uma TAG (nodo).
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
  BEGIN
    DECLARE
      vr_domDoc    DBMS_XMLDOM.DOMDocument;      --> Definição do documento DOM (XML)
      vr_nodo_exc  DBMS_XMLDOM.DOMNode;          --> Novo nodo baseado no elemento

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_domDoc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Define o nodo que será excluído
      vr_nodo_exc := DBMS_XMLDOM.makeNode(DBMS_XMLDOM.makeElement(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(vr_domDoc, pr_tag_exc), pr_pos_exc)));
      -- Excluir nodo
      vr_nodo_exc := DBMS_XMLDOM.removeChild(vr_nodo_exc, vr_nodo_exc);
      -- Gerar o novo stream XML
      pr_xml := DBMS_XMLDOM.getxmltype(vr_domDoc);
      
      -- Liberar uso de memória
      dbms_xmldom.freeDocument(vr_domDoc);
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_exclui_tag: ' || SQLERRM;
    END;
  END pc_exclui_tag;
  
  /* Function para retornar o valor de uma TAG */
  FUNCTION fn_valor_tag(pr_xml     IN OUT NOCOPY XMLTYPE           --> Documento XML
                       ,pr_pos_exc IN PLS_INTEGER                  --> Posição da TAG que será pesquisada
                       ,pr_nomtag  IN VARCHAR2) RETURN VARCHAR2 IS --> Nome da TAG
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_valor_tag
  --  Sigla    : GENE
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Maio/2014.                             Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retornar o valor de uma TAG apontada no XML.
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_xmldoc    dbms_xmldom.DOMDocument;   --> Documento DOM
      vr_listanodo dbms_xmldom.DOMNodeList;   --> Lista de nodos do documento XML
      vr_nodo      dbms_xmldom.DOMNode;       --> Nodo da TAG XML
      vr_valorn    VARCHAR2(4000);            -- Valor da TAG
      
    BEGIN
      -- Gerar documento DOM
      vr_xmldoc := dbms_xmldom.newdomdocument(pr_xml);
      -- Gerar lista de nodos
      vr_listanodo := dbms_xmldom.getelementsbytagname(vr_xmldoc, pr_nomtag);
      --> Restatar TAG apontada
      vr_nodo := dbms_xmldom.getfirstchild(dbms_xmldom.item(vr_listanodo, pr_pos_exc));
      -- Valor do nodo
      vr_valorn := dbms_xmldom.getnodevalue(vr_nodo);
      -- Eliminar documento XML
      dbms_xmldom.freeDocument(vr_xmldoc);
      
      RETURN vr_valorn;
    END;
  END;

  /* Procedure para gerar PL Table com lista de valores referentes aos nodos de um nodo pai */
  PROCEDURE pc_itera_nodos(pr_xpath      IN  VARCHAR2              --> Xpath do nodo a ser pesquisado
                          ,pr_xml        IN OUT NOCOPY XMLTYPE     --> Documento XML
                          ,pr_namespace  IN VARCHAR2 DEFAULT NULL  --> Namespace do documento XML
                          ,pr_list_nodos OUT typ_tab_tagxml        --> PL Table com valores
                          ,pr_des_erro   OUT VARCHAR2) IS          --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_itera_nodos
  --  Sigla    : GENE
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Gerar PL Table com valores dos nodos XML para apenas um nível.
  --
  --             NOTA: No parâmetro PR_NAMESPACE caso seja NULL o namespace será recuperado de forma automático,
  --                   caso seja passado a string NONE o parser irá ignorar a existência do namespace, 
  --                   opcionalmente também poderá ser informado um namespace de forma arbitrária para o parser.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_nodo_pai   DBMS_XMLDOM.DOMNodeList;      --> Lista de nodos que será lido (ninho)
      vr_xml_doc    DBMS_XMLDOM.DOMDocument;      --> XML DOM
      vr_root       DBMS_XMLDOM.DOMElement;       --> Elemento ROOT (raiz) do XML
      vr_attrmap    DBMS_XMLDOM.DOMNamedNodeMap;  --> Mapa de atributos do elemento
      vr_cont       PLS_INTEGER := 0;             --> Contador para fluxo de iteração

    BEGIN
      -- Cria o documento DOM com base no XML enviado
      vr_xml_doc := DBMS_XMLDOM.newDOMDocument(pr_xml);
      -- Define elemento ROOT do XML
      vr_root := DBMS_XMLDOM.getDocumentElement(vr_xml_doc);
      -- Cria mapa de atributos do elemento
      vr_attrmap := dbms_xmldom.getAttributes(DBMS_XMLDOM.makeNode(vr_root));

      -- Seleciona nodo pai considerando a existencia de namespace
      IF pr_namespace IS NULL THEN
        IF DBMS_XMLDOM.getNamespace(vr_root) IS NOT NULL THEN
          vr_nodo_pai := DBMS_XSLPROCESSOR.selectNodes(DBMS_XMLDOM.makeNode(vr_root), pr_xpath, fn_gera_namespace(vr_attrmap
                                                                                                                 ,DBMS_XMLDOM.getNamespace(vr_root)));
        ELSE
          vr_nodo_pai := DBMS_XSLPROCESSOR.selectNodes(DBMS_XMLDOM.makeNode(vr_root), pr_xpath);
        END IF;
      ELSIF pr_namespace = 'NONE' THEN
        vr_nodo_pai := DBMS_XSLPROCESSOR.selectNodes(DBMS_XMLDOM.makeNode(vr_root), pr_xpath);
      ELSE
        vr_nodo_pai := DBMS_XSLPROCESSOR.selectNodes(DBMS_XMLDOM.makeNode(vr_root), pr_xpath, pr_namespace);
      END IF;

      -- Itera para recuperar os valores dos nodos e seus respectivos nomes
      FOR idx IN 0..DBMS_XMLDOM.getLength(vr_nodo_pai) - 1 LOOP
        IF DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(DBMS_XMLDOM.item(vr_nodo_pai, idx))) IS NOT NULL THEN
          pr_list_nodos(vr_cont).tag := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(DBMS_XMLDOM.item(vr_nodo_pai, idx)));

          -- Incrementa índice
          vr_cont := vr_cont + 1;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_itera_nodos: ' || SQLERRM;
    END;
  END pc_itera_nodos;

  /* Procedure para gerar PL Table com lista de valores referentes aos nodos de um nodo pai */
  PROCEDURE pc_itera_nodos(pr_nodo       IN DBMS_XMLDOM.DOMNode      --> Xpath do nodo a ser pesquisado
                          ,pr_nivel      IN PLS_INTEGER              --> Nível que será pesquisado
                          ,pr_list_nodos OUT typ_mult_array          --> PL Table com os nodos resgatados
                          ,pr_des_erro   OUT VARCHAR2) IS            --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_itera_nodos
  --  Sigla    : GENE
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Setembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Gerar PL Table com valores dos nodos XML para vários níveis.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_nodo_list  DBMS_XMLDOM.DOMNodeList;   --> Lista de nodos
      vr_erro       EXCEPTION;                 --> Controle de erros

    BEGIN
      -- Lista de nodos do nodo pai
      vr_nodo_list := DBMS_XMLDOM.getChildNodes(pr_nodo);

      -- Itera para recuperar os valores dos nodos e seus respectivos nomes
      FOR idx IN 0..DBMS_XMLDOM.getLength(vr_nodo_list) - 1 LOOP
        -- Verifica se é o último nível (recupera o valor, senão chama a procedure de forma recursiva)
        IF DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(DBMS_XMLDOM.item(vr_nodo_list, idx))) IS NOT NULL THEN
          pr_list_nodos(pr_nivel)(DBMS_XMLDOM.getNodeName(DBMS_XMLDOM.item(vr_nodo_list, idx))) :=
                       DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.getFirstChild(DBMS_XMLDOM.item(vr_nodo_list, idx)));
        ELSE
          pc_itera_nodos(pr_nodo       => DBMS_XMLDOM.item(vr_nodo_list, idx)
                        ,pr_nivel      => pr_nivel + 1
                        ,pr_list_nodos => pr_list_nodos
                        ,pr_des_erro   => pr_des_erro);

          -- Verifica se ocorreram erros
          IF pr_des_erro IS NOT NULL THEN
            RAISE vr_erro;
          END IF;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro pc_itera_nodos: ' || SQLERRM;
    END;
  END pc_itera_nodos;

  /* Criar documento XML com base no fragmento de outro XML */
  FUNCTION fn_gera_xml_frag(pr_xml_frag  IN VARCHAR2) RETURN xmltype IS   --> Fragmento do documento XML
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_xml_frag
  --  Sigla    : GENE
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Setembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Gerar novo documento XML com base em um fragmento de outro documento XML.
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_doc_xml  CLOB;      --> Documento XML em modo texto

    BEGIN
      vr_doc_xml := '<?xml version="1.0"?>' || pr_xml_frag;
      RETURN xmltype.createxml(vr_doc_xml);
    END;
  END fn_gera_xml_frag;

  /* Montar namespace completo (identificador + URI) para formar dados do nodo */
  FUNCTION fn_gera_namespace(pr_attrmap IN DBMS_XMLDOM.DOMNamedNodeMap    --> Mapa DOM do elemento
                            ,pr_namesp  IN VARCHAR2) RETURN VARCHAR2 IS   --> URI do namespace pesquisado
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_gera_namespace
  --  Sigla    : GENE
  --  Autor    : Petter Rafael - Supero Tecnologia
  --  Data     : Setembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Gera string completa para identificar o namespace.
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    BEGIN
      -- Iterar sobre o mapa do elemento para comparar o namespace solicitado para montar string completa
      FOR idx IN 0..DBMS_XMLDOM.getLength(pr_attrmap) - 1 LOOP
        IF pr_namesp = DBMS_XMLDOM.getValue(DBMS_XMLDOM.makeAttr(DBMS_XMLDOM.item(pr_attrmap, idx))) THEN
          RETURN DBMS_XMLDOM.getName(DBMS_XMLDOM.makeAttr(DBMS_XMLDOM.item(pr_attrmap, idx))) || '=' || pr_namesp;
        END IF;
      END LOOP;
    END;
  END fn_gera_namespace;
  
  /* Converte os caracteres especiais de acordo com o CHARSET */
  FUNCTION fn_convert_web_db(pr_convtext IN VARCHAR2) RETURN VARCHAR2 IS   --> URI do namespace pesquisado
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_convert_web_db
  --  Sigla    : GENE
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Converte os caracteres especiais de acordo com o CHARSET. Funcao criada para corrigir erro na
  --             passagem de caracteres acentuados do AyllosWEB para o banco, devido a diferenca de CHARSET.
  --
  /*
        Conjuntos de caracteres comuns incluem:
        
                 US7ASCII     : US 7-bit conjunto de caracteres ASCII
                 WE8ISO8859P1 : ISO conjunto de caracteres 8859-1 Europa Ocidental 8-bit
                 EE8MSWIN1250 : Microsoft Windows Leste Codigo Europeia
                 WE8MSWIN1252 : Microsoft Windows Oeste Codigo Europeia 
                 WE8EBCDIC1047: Codigo EBCDIC IBM Oeste Europeia
                 JA16SJISTILDE: Conjunto de caracteres Shift-JIS japones, 
                 ZHT16MSWIN950: Codigo Microsoft Windows chinês tradicional
                 UTF8         : Unicode 3.0 Universal - definir CESU-8 forma de codificacao
                 AL32UTF8     : Unicode 5.0 personagem Universal definir forma de codificacao UTF-8
                 
  */
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Converter o texto de WE8ISO8859P1 para UTF8
    RETURN CONVERT(pr_convtext, 'WE8ISO8859P1', 'UTF8');
  END fn_convert_web_db;
  
  /* Converte os caracteres especiais de acordo com o CHARSET */
  FUNCTION fn_convert_db_web(pr_convtext IN VARCHAR2) RETURN VARCHAR2 IS   --> URI do namespace pesquisado
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_convert_db_web
  --  Sigla    : GENE
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Converte os caracteres especiais de acordo com o CHARSET. Funcao criada para corrigir erro na
  --             passagem de caracteres acentuados do AyllosWEB para o banco, devido a diferenca de CHARSET.
  --
  /*
        Conjuntos de caracteres comuns incluem:
        
                 US7ASCII     : US 7-bit conjunto de caracteres ASCII
                 WE8ISO8859P1 : ISO conjunto de caracteres 8859-1 Europa Ocidental 8-bit
                 EE8MSWIN1250 : Microsoft Windows Leste Codigo Europeia
                 WE8MSWIN1252 : Microsoft Windows Oeste Codigo Europeia 
                 WE8EBCDIC1047: Codigo EBCDIC IBM Oeste Europeia
                 JA16SJISTILDE: Conjunto de caracteres Shift-JIS japones, 
                 ZHT16MSWIN950: Codigo Microsoft Windows chinês tradicional
                 UTF8         : Unicode 3.0 Universal - definir CESU-8 forma de codificacao
                 AL32UTF8     : Unicode 5.0 personagem Universal definir forma de codificacao UTF-8
                 
  */
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Converter o texto de WE8ISO8859P1 para UTF8
    RETURN CONVERT(pr_convtext, 'UTF8', 'WE8ISO8859P1');
  END fn_convert_db_web;

  /* Remover CDATA da string */
  FUNCTION fn_remove_cdata(pr_texto IN VARCHAR2) RETURN VARCHAR2 IS  --> String de saida
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_remove_cdata
  --  Sigla    : GENE
  --  Autor    : Jaison
  --  Data     : Agosto/2016                   Ultima atualizacao: 16/02/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Remover o CDATA da string recebida.
  --
  -- Alteracoes: 16/02/2017 - Remover CDATA mesmo quando tem nova linha. (Jaison/Oscar)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    BEGIN
      RETURN regexp_substr(pr_texto, '<!\[CDATA\[(.*)\]\]>', 1, 1, 'n', 1);
    END;
  END fn_remove_cdata;
  
END GENE0007;
/
