create or replace package cecred.WPRT0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : WPRT0001
      Sistema  : Rotinas referentes a comunicação com IEPTB
      Sigla    : 
      Autor    : 
      Data     : Fevereiro/2018.                   Ultima atualizacao: 12/02/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Chamadas para o servidor WS do IEPTB.

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_enviar_remessa(pr_cdcooper       IN crapcop.cdcooper%TYPE,  -- Codigo da cooperativa 
                              pr_dscritic       OUT VARCHAR2);

  PROCEDURE pc_atualiza_arquivo(pr_arquivo        IN VARCHAR2, -- Local atual
                                pr_nvarquivo      IN VARCHAR2, -- Novo local
                                pr_dscritic       OUT VARCHAR2);
                                
  PROCEDURE pc_obtem_retorno(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo da cooperativa 
                            ,pr_cdbandoc IN crapcob.cdbandoc%TYPE  -- Código do banco
                            ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE  -- Data do arquivo
                            ,pr_dscritic OUT VARCHAR2);
end WPRT0001;
/
create or replace package body cecred.WPRT0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : WPRT0001
      Sistema  : Rotinas referentes a comunicação com IEPTB
      Sigla    : 
      Autor    : Augusto Henrique da Conceição (SUPERO)
      Data     : Março/2018.                   Ultima atualizacao: 25/03/2018

      Dados referentes ao programa:

      Frequencia: ---
      Objetivo  : Chamadas para o servidor WS do IEPTB.

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  vr_cdprogra      tbgen_prglog.cdprograma%type := 'WPRT0001';

  PROCEDURE pc_carrega_param_ieptb(pr_cdcooper           IN crapcop.cdcooper%TYPE,
                                   pr_ieptb_endereco     OUT VARCHAR2,
                                   pr_ieptb_cancelamento OUT VARCHAR2,
                                   pr_ieptb_userCode     OUT VARCHAR2,
                                   pr_ieptb_userPass     OUT VARCHAR2,
                                   pr_ieptb_remessa	     OUT VARCHAR2,
                                   pr_ieptb_retorno	     OUT VARCHAR2,
                                   pr_ieptb_resposta     OUT VARCHAR2,
                                   pr_ieptb_erro         OUT VARCHAR2,
                                   pr_emails_cobranca    OUT VARCHAR2,
                                   pr_dscritic           OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_carrega_param_ieptb        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : Carregar parametros para uso na comunicacao com o IEPTB
    
    Alteração : 
        
  ..........................................................................*/  
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_ieptb_authentication VARCHAR2(100);
    vr_cdcritic NUMBER;
    
  BEGIN  
    
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      -- Encerrar o processo
      RAISE vr_exc_erro;
    END IF; 
  
    --> Buscar ieptb_endereco
    pr_ieptb_endereco := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'WS_IEPTB_ENDERECO');
    IF pr_ieptb_endereco IS NULL THEN      
      vr_dscritic := 'Parametro WSDL_IEPTB_ENDERECO não encontrado.';
      RAISE vr_exc_erro;      
    END IF;
    
    --> Buscar ieptb_cancelamento
    pr_ieptb_cancelamento := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'WS_IEPTB_CANCELAMENTO');
    IF pr_ieptb_cancelamento IS NULL THEN      
      vr_dscritic := 'Parametro WS_IEPTB_CANCELAMENTO não encontrado.';
      RAISE vr_exc_erro;      
    END IF;

    --> Buscar ieptb_authentication
    vr_ieptb_authentication := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'WS_IEPTB_AUTHENTICATION');
    IF vr_ieptb_authentication IS NULL THEN      
      vr_dscritic := 'Parametro WSDL_IEPTB_AUTHENTICATION não encontrado.';
      RAISE vr_exc_erro;      
    END IF;

    -- Explode o usuário e a seha (usuario;senha)
    pr_ieptb_userCode := SUBSTR(vr_ieptb_authentication,1,
                                INSTR(vr_ieptb_authentication,';',-1)-1);    
    pr_ieptb_userPass := SUBSTR(vr_ieptb_authentication,
                                INSTR(vr_ieptb_authentication,';',-1)+1);

    --> Buscar ieptb_remessa
    pr_ieptb_remessa := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'DIR_IEPTB_REMESSA');
    IF pr_ieptb_remessa IS NULL THEN      
      vr_dscritic := 'Parametro DIR_IEPTB_REMESSA não encontrado.';
      RAISE vr_exc_erro;      
    END IF;

    --> Buscar ieptb_retorno
    pr_ieptb_retorno := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'DIR_IEPTB_RETORNO');
    IF pr_ieptb_retorno IS NULL THEN      
      vr_dscritic := 'Parametro DIR_IEPTB_RETORNO não encontrado.';
      RAISE vr_exc_erro;      
    END IF;

    --> Buscar ieptb_retorno
    pr_ieptb_resposta := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'DIR_IEPTB_RESPOSTA');
    IF pr_ieptb_resposta IS NULL THEN      
      vr_dscritic := 'Parametro DIR_IEPTB_RESPOSTA não encontrado.';
      RAISE vr_exc_erro;      
    END IF;
    
    --> Buscar ieptb_erro
    pr_ieptb_erro := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcooper, 
                                                pr_cdacesso => 'DIR_IEPTB_ERRO');
    IF pr_ieptb_erro IS NULL THEN      
      vr_dscritic := 'Parametro DIR_IEPTB_ERRO não encontrado.';
      RAISE vr_exc_erro;      
    END IF;

    BEGIN
      --
      SELECT tpp.dsemail_cobranca
        INTO pr_emails_cobranca
        FROM tbcobran_param_protesto tpp
       WHERE tpp.cdcooper = pr_cdcooper;
      --
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possível retornar os e-mails do protesto: ' || SQLERRM;
    END;
    
    --
    IF (pr_emails_cobranca IS NULL) THEN
      vr_dscritic := 'O e-mail de cobrança ou o e-mail do IEPTB não foi configurado.';
      RAISE vr_exc_erro;      
    END IF;
    --

    IF pr_ieptb_erro IS NULL THEN      
      vr_dscritic := 'Parametro DIR_IEPTB_ERRO não encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel buscar parametros do IEPTB: '||SQLERRM;
  END pc_carrega_param_ieptb;
  
  PROCEDURE pc_gera_log(pr_cdcooper      IN crapcop.cdcooper%TYPE,
                        pr_dscritic      IN VARCHAR2,
                        pr_dstransa      IN VARCHAR2,
                        pr_flgtrans      IN VARCHAR2) IS
  /* ..........................................................................
    
    Programa : pc_gera_log        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 31/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/
  vr_nrdrowid VARCHAR2(500) := NULL;

  BEGIN
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => 1
                        ,pr_dscritic => pr_dscritic
                        ,pr_dsorigem => ''
                        ,pr_dstransa => pr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => pr_flgtrans
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => NULL
                        ,pr_nrdconta => 0
                        ,pr_nrdrowid => vr_nrdrowid);
  END pc_gera_log;
  
  PROCEDURE pc_atualiza_arquivo(pr_arquivo        IN VARCHAR2  -- Local atual
                               ,pr_nvarquivo      IN VARCHAR2  -- Novo local                
                               ,pr_dscritic       OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_atualiza_arquivo        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/  
  BEGIN
  DECLARE
    vr_typ_saida VARCHAR2(3);

    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;    
    
  BEGIN
    /*GENE0001.pc_mv_arquivo(pr_dsarqori => pr_arquivo
                          ,pr_dsarqdes => pr_nvarquivo
                          ,pr_typ_saida => vr_typ_saida
                          ,pr_des_saida => vr_dscritic);*/


    --Se ocorreu erro dar RAISE
    IF vr_typ_saida = 'ERR' THEN
          
      --Monta mensagem de critica
      vr_dscritic:= 'Nao foi possivel executar comando unix: '||
                     'mv '||pr_arquivo||' '||pr_nvarquivo||' - '||vr_dscritic;
          
      -- retornando ao programa chamador
      RAISE vr_exc_erro;
          
    END IF;

    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel atualizar o arquivo: '||SQLERRM;
    END;

  END pc_atualiza_arquivo;
  
  PROCEDURE pc_processa_retorno(pr_dsdireto IN VARCHAR2
                               ,pr_dsarquiv IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2) IS  
    
  /* ..........................................................................
    
    Programa : pc_processa_retorno        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/  
    p   xmlparser.parser;
    doc xmldom.DOMDocument;
    nl xmldom.DOMNodeList;
    len1 NUMBER;
    len2 NUMBER;
    n xmldom.DOMNode;
    n2 xmldom.DOMNode;
    nnm xmldom.DOMNamedNodeMap;
    e xmldom.DOMElement;
    
    vr_exc_erro EXCEPTION;
    vr_cdcritic VARCHAR2(50);
    vr_dscritic VARCHAR2(500);   
  BEGIN
    
    IF pr_dsdireto IS NULL or pr_dsarquiv IS NULL THEN
      vr_dscritic := 'Diretório ou arquivo não informados.';
      raise vr_exc_erro;
    END IF;
    
    IF NOT GENE0001.fn_exis_arquivo(pr_dsdireto || '/' || pr_dsarquiv) THEN
      vr_dscritic := 'Não foi possível localizar o arquivo ' || pr_dsdireto || '/' || pr_dsarquiv || '.';
      raise vr_exc_erro;  
    END IF;
  
    -- new parser
    p := xmlparser.newParser;

    -- set some characteristics
    xmlparser.setValidationMode(p, FALSE);
    xmlparser.setBaseDir(p, pr_dsdireto);

    -- parse input file
    xmlparser.parse(p, pr_dsdireto || '/' || pr_dsarquiv);

    -- get document
    doc := xmlparser.getDocument(p);

    -- Get document element attributes
    -- get all elements
    nl := xmldom.getElementsByTagName(doc, '*');    
    len1 := xmldom.getLength(nl);
    
    -- loop through elements
    for j in 0..len1-1 LOOP
      --
      n := xmldom.item(nl, j);
      e := xmldom.makeElement(n);
      
      -- get all attributes of element
      nnm := xmldom.getAttributes(n);
      --
      IF (xmldom.isNull(nnm) = FALSE) THEN
        --
        IF xmldom.getNodeName(n) = 'erro' THEN
          --
          len2 := xmldom.getLength(nnm);
          --
          for k in 0..len2-1 LOOP
            n2 := xmldom.item(nnm, k);

            IF xmldom.getNodeName(n2) = 'codigo' THEN
               vr_cdcritic := xmldom.getNodeValue(n2);
            END IF;

            IF xmldom.getNodeName(n2) = 'descricao' THEN
               vr_dscritic := xmldom.getNodeValue(n2);
            END IF;
          end loop;
          pr_dscritic := pr_dscritic || vr_cdcritic || ' - ' || vr_dscritic || ' ';
          --
        END IF;
      END IF;
      --
    END LOOP;

    IF LENGTH(pr_dscritic) > 1 THEN
        pr_dscritic := SUBSTR(pr_dscritic, 1, LENGTH(pr_dscritic) - 1);
    END IF;
    
    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel processar o arquivo: '||SQLERRM;

  END pc_processa_retorno;

  /* ..........................................................................
    
    Programa : pc_envia_requisicao        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : Carregar parametros para uso na comunicacao com o IEPTB
    
    Alteração : 
        
  ..........................................................................*/ 
  PROCEDURE pc_envia_requisicao(pr_cdcooper           IN  crapcop.cdcooper%TYPE,
                                pr_ieptb_endereco     IN VARCHAR2,
                                pr_ieptb_cancelamento IN VARCHAR2,
                                pr_ieptb_UserCode     IN VARCHAR2,
                                pr_ieptb_UserPass     IN VARCHAR2,
                                pr_ieptb_resposta     IN VARCHAR2,
                                pr_ieptb_erro         IN VARCHAR2,
                                pr_arquivo            IN VARCHAR2,
                                pr_emails_cobranca    IN VARCHAR2,
                                pr_cdcritic           OUT crapcri.cdcritic%TYPE,
                                pr_dscritic           OUT VARCHAR2) IS
    
  
  /* ..........................................................................
    
    Programa : pc_envia_requisicao        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : Carregar parametros para uso na comunicacao com o IEPTB
    
    Alteração : 
        
  ..........................................................................*/  
  
    vr_nmarqcmd  VARCHAR2(1000);
    vr_drsalvar  VARCHAR2(1000);
    vr_dscomora  VARCHAR2(1000);
    vr_comando   VARCHAR2(4000);
    vr_typ_saida VARCHAR2(3);
    vr_arqreceb  VARCHAR2(100);
    vr_nmarquiv  VARCHAR2(50);
    vr_dirarquiv  VARCHAR2(50);
    vr_nvarquivo VARCHAR2(50);
    
    vr_horaatua VARCHAR2(50);
  
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    vr_des_assunto VARCHAR2(500);
    vr_conteudo VARCHAR2(500);

  BEGIN
    GENE0001.pc_informa_acesso(pr_module => 'WPRT0001', pr_action => NULL);
    
    --Diretório ROOT da Cecred
    vr_nmarqcmd := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_cdacesso => 'ROOT_CECRED_BIN') ||
                                            'SendIEPTB.pl';
  
    --Buscar parametros 
    vr_dscomora := gene0001.fn_param_sistema('CRED', 3, 'SCRIPT_EXEC_SHELL');
    
    --Retorno do request
    vr_horaatua := to_char(SYSDATE, 'yymmddhh24miss');
    GENE0001.pc_separa_arquivo_path(pr_caminho => pr_arquivo
                           	       ,pr_direto  => vr_dirarquiv
                                   ,pr_arquivo => vr_nmarquiv);
    vr_arqreceb := 'IEPTB_CECRED_' || vr_nmarquiv || '_' || vr_horaatua || '.ret';
  
    --Gera comando para chamar o WebService
    vr_comando := vr_dscomora || ' perl_remoto ' || vr_nmarqcmd;
    vr_comando := vr_comando || ' --userArq=' || CHR(39) || vr_nmarquiv ||  CHR(39);
    
    -- Se for cancelamento o domínio é outro
    IF SUBSTR(vr_nmarquiv, 0, 2) = 'CP' THEN
      vr_comando := vr_comando || ' --url=' || CHR(39) || pr_ieptb_cancelamento ||  CHR(39);
      vr_comando := vr_comando || ' --auth=' || CHR(39) || SSPC0001.pc_encode_base64(pr_ieptb_userCode || ':' || pr_ieptb_userPass) || CHR(39);
    ELSE
      vr_comando := vr_comando || ' --url=' || CHR(39) || pr_ieptb_endereco ||  CHR(39);
      vr_comando := vr_comando || ' --userCode=' || CHR(39) || pr_ieptb_userCode || CHR(39);
      vr_comando := vr_comando || ' --userPass=' || CHR(39) || pr_ieptb_userPass ||  CHR(39);
    END IF;
    
    -- Caso for arquivo de retorno ou confirmação não haverá dados para enviar
    IF SUBSTR(vr_nmarquiv, 0, 1) = 'R' or SUBSTR(vr_nmarquiv, 0, 1) = 'C' THEN
      vr_comando := vr_comando || ' > ' ||
                    REPLACE(pr_ieptb_resposta || '/' || vr_arqreceb, 'coopd', 'coop');
                    --Remover os replaces do diretório COOPD
    ELSE
      vr_comando := vr_comando || ' < ' ||
                    REPLACE(pr_arquivo, 'coopd', 'coop') || ' > ' ||
                    REPLACE(pr_ieptb_resposta || '/' || vr_arqreceb, 'coopd', 'coop');
                    --Remover os replaces do diretório COOPD
    END IF;
  
    --Executar o comando no unix
    gene0001.pc_oscommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_comando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => pr_dscritic);

    IF pr_dscritic IS NOT NULL THEN
      --Caso for output do SSL ignora
      IF UPPER(pr_dscritic) LIKE '%SSL_CONNECT%' THEN
         pr_dscritic := NULL;
      ELSE
         RAISE vr_exc_saida;
      END IF;
    END IF;

    -- Pré processa o arquivo
    pc_processa_retorno(pr_dsdireto => pr_ieptb_resposta
                       ,pr_dsarquiv => vr_arqreceb
                       ,pr_dscritic => pr_dscritic);

    -- Caso houver algum erro no retorno, enviaremos um e-mail e moveremos o arquivo para o diretório de erros
    IF TRIM(pr_dscritic) IS NOT NULL THEN
       vr_des_assunto := 'CECRED - Erro no envio ao IEPTB';
       vr_conteudo := 'Erro ao enviar o arquivo ' || pr_ieptb_resposta || '/' || pr_arquivo || '.' ||
       '\nMotivo: ' || pr_dscritic;
       --
       GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                 ,pr_cdprogra        => '' --> Programa conectado
                                 ,pr_des_destino     => pr_emails_cobranca --> Um ou mais detinatários separados por ';' ou ','
                                 ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                 ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                 ,pr_des_anexo       => ''     --> Um ou mais anexos separados por ';' ou ','
                                 ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                 ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                 ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                 ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                 ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                 ,pr_flg_log_batch   => 'N'           --> Incluir inf. no log
                                 ,pr_des_erro        => pr_dscritic);  --> Descricao Erro
       --
       vr_nvarquivo := pr_ieptb_erro || '/' || vr_nmarquiv;
       --
       pc_atualiza_arquivo(pr_arquivo => pr_ieptb_resposta || '/' || pr_arquivo
                          ,pr_nvarquivo => vr_nvarquivo
                          ,pr_dscritic => pr_dscritic);
      -- Loga o erro
      pc_gera_log(pr_cdcooper
               ,'[IEPTB] ' || vr_conteudo
               ,NULL
               ,0);
    ELSE
      -- Caso contrário, iremos apenas mover para o dirério /salvar
      vr_nvarquivo := vr_drsalvar || '/' || vr_nmarquiv;
      --
      pc_atualiza_arquivo(pr_arquivo => pr_ieptb_resposta || '/' || pr_arquivo
                          ,pr_nvarquivo => vr_nvarquivo
                          ,pr_dscritic => pr_dscritic);
      -- Loga o registro enviado                        
      pc_gera_log(pr_cdcooper
               ,NULL
               ,'[IEPTB] Envio do arquivo ' || pr_ieptb_resposta || '/' || pr_arquivo || ' ao CRA Nacional.'
               ,1);
    END IF;
    
    EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao executar a requisição ao IEPTB: ' || pr_dscritic;
    
  END pc_envia_requisicao;
    
  PROCEDURE pc_enviar_remessa(pr_cdcooper       IN crapcop.cdcooper%TYPE,  -- Codigo da cooperativa 
                              pr_dscritic       OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_enviar_remessa        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/  
  BEGIN
  DECLARE
    vr_tab_remessa TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_tab_desistencia TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_tab_cancelamento TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();
    vr_tab_confirmacao TYP_SIMPLESTRINGARRAY := TYP_SIMPLESTRINGARRAY();            

    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
    vr_pesq VARCHAR2(50) := NULL;
    vr_ieptb_remessa VARCHAR(200) := NULL;
    vr_ieptb_endereco VARCHAR(200) := NULL;
    vr_ieptb_cancelamento VARCHAR(200) := NULL;
    vr_ieptb_userCode VARCHAR(200) := NULL;
    vr_ieptb_userPass VARCHAR(200) := NULL;
    vr_ieptb_retorno VARCHAR(200) := NULL;
    vr_ieptb_resposta VARCHAR(200) := NULL;
    vr_ieptb_erro VARCHAR(200) := NULL;
    vr_emails_cobranca VARCHAR(200) := NULL;
    
    vr_arquivo VARCHAR2(50) := NULL;
    
    vr_dia VARCHAR2(2);
    vr_mes VARCHAR2(2);
    vr_ano VARCHAR2(2);        


  BEGIN
        
    pc_carrega_param_ieptb(pr_cdcooper => pr_cdcooper
                          ,pr_ieptb_endereco => vr_ieptb_endereco
                          ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                          ,pr_ieptb_userCode => vr_ieptb_userCode
                          ,pr_ieptb_userPass => vr_ieptb_userPass
                          ,pr_ieptb_remessa => vr_ieptb_remessa
                          ,pr_ieptb_retorno => vr_ieptb_retorno
                          ,pr_ieptb_resposta => vr_ieptb_resposta
                          ,pr_ieptb_erro => vr_ieptb_erro
                          ,pr_emails_cobranca => vr_emails_cobranca
                          ,pr_dscritic => vr_dscritic);
                          
    -- Se retornou erro
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;                          
                          
    vr_dia := to_char(SYSDATE, 'dd');
    vr_mes := to_char(SYSDATE, 'mm');
    vr_ano := to_char(SYSDATE, 'yy');

    --Buscar arquivos de remessa
    vr_pesq := 'B%%%' || vr_dia || vr_mes || '.' || vr_ano || '%';
    --Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_remessa
                              ,pr_path          => vr_ieptb_remessa
                              ,pr_pesq          => vr_pesq);



    IF vr_tab_remessa.COUNT() > 0 THEN
        FOR idx IN 1..vr_tab_remessa.COUNT() LOOP
          vr_arquivo := vr_ieptb_remessa || '/' || vr_tab_remessa(idx);
          pc_envia_requisicao(pr_cdcooper => pr_cdcooper
                               ,pr_ieptb_endereco => vr_ieptb_endereco
                               ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                               ,pr_ieptb_UserCode => vr_ieptb_userCode
                               ,pr_ieptb_UserPass => vr_ieptb_userPass
                               ,pr_ieptb_resposta => vr_ieptb_resposta
                               ,pr_ieptb_erro => vr_ieptb_erro
                               ,pr_arquivo => vr_arquivo
                               ,pr_emails_cobranca => vr_emails_cobranca
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
       END LOOP;
    END IF;

    --Buscar arquivos de desistência
    vr_pesq := 'DP%%%' || vr_dia || vr_mes || '.' || vr_ano || '%';
    --Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_desistencia
                              ,pr_path          => vr_ieptb_remessa
                              ,pr_pesq          => vr_pesq);


    IF vr_tab_desistencia.COUNT() > 0 THEN
        FOR idx IN 1..vr_tab_desistencia.COUNT() LOOP
          vr_arquivo := vr_ieptb_remessa || '/' || vr_tab_desistencia(idx);
          pc_envia_requisicao(pr_cdcooper => pr_cdcooper
                               ,pr_ieptb_endereco => vr_ieptb_endereco
                               ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                               ,pr_ieptb_UserCode => vr_ieptb_userCode
                               ,pr_ieptb_UserPass => vr_ieptb_userPass
                               ,pr_ieptb_resposta => vr_ieptb_resposta
                               ,pr_ieptb_erro => vr_ieptb_erro                              
                               ,pr_arquivo => vr_arquivo
                               ,pr_emails_cobranca => vr_emails_cobranca
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
       END LOOP;
    END IF;

    --Buscar arquivos de cancelamento
    vr_pesq := 'CP%%%' || vr_dia || vr_mes || '.' || vr_ano || '%';
    --Buscar a lista de arquivos do diretorio
    gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_tab_cancelamento
                              ,pr_path          => vr_ieptb_remessa
                              ,pr_pesq          => vr_pesq);


    IF vr_tab_cancelamento.COUNT() > 0 THEN
        FOR idx IN 1..vr_tab_cancelamento.COUNT() LOOP
          vr_arquivo := vr_ieptb_remessa || '/' || vr_tab_cancelamento(idx);
          pc_envia_requisicao(pr_cdcooper => pr_cdcooper
                               ,pr_ieptb_endereco => vr_ieptb_endereco
                               ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                               ,pr_ieptb_UserCode => vr_ieptb_userCode
                               ,pr_ieptb_UserPass => vr_ieptb_userPass
                               ,pr_ieptb_resposta => vr_ieptb_resposta
                               ,pr_ieptb_erro => vr_ieptb_erro                              
                               ,pr_arquivo => vr_arquivo
                               ,pr_emails_cobranca => vr_emails_cobranca
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => pr_dscritic);
       END LOOP;
    END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN     
        --> Buscar critica
        IF nvl(vr_cdcritic,0) > 0 AND 
          TRIM(vr_dscritic) IS NULL THEN
          -- Busca descricao        
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
        END IF;  
        
        pr_dscritic := vr_dscritic;
        
        pc_gera_log(pr_cdcooper
                   ,'[IEPTB] Erro ao enviar remessas: ' || vr_dscritic
                   ,NULL
                   ,0);
      
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel enviar as remessas: '||SQLERRM;
        pc_gera_log(pr_cdcooper
                   ,'[IEPTB] ' || pr_dscritic
                   ,NULL
                   ,0);
    END;
  END pc_enviar_remessa;

  PROCEDURE pc_obtem_retorno(pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo da cooperativa 
                            ,pr_cdbandoc IN crapcob.cdbandoc%TYPE  -- Código do banco
                            ,pr_dtmvtolt IN crapcob.dtmvtolt%TYPE  -- Data do arquivo
                            ,pr_dscritic OUT VARCHAR2) IS
  
    
  /* ..........................................................................
    
    Programa : pc_obtem_retorno        
    Sistema  : 
    Sigla    : CRED
    Autor    : Augusto Henrique da Conceição (SUPERO)
    Data     : Março/2018.                   Ultima atualizacao: 25/03/2018
    
    Dados referentes ao programa:
    
    Frequencia: ---
    Objetivo  : 
    
    Alteração : 
        
  ..........................................................................*/  
  BEGIN
  DECLARE
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic NUMBER;
    
    vr_ieptb_remessa VARCHAR2(200) := NULL;
    vr_ieptb_endereco VARCHAR2(200) := NULL;
    vr_ieptb_userCode VARCHAR(200) := NULL;
    vr_ieptb_userPass VARCHAR(200) := NULL;    
    vr_ieptb_retorno VARCHAR2(200) := NULL;
    vr_ieptb_resposta VARCHAR2(200) := NULL;    
    vr_ieptb_erro VARCHAR(200) := NULL;
    vr_ieptb_cancelamento VARCHAR(200) := NULL;    
    vr_emails_cobranca VARCHAR(200) := NULL;
    
    vr_nmarqv VARCHAR(100) := NULL;
    
  BEGIN
    
    pc_carrega_param_ieptb(pr_cdcooper => pr_cdcooper
                          ,pr_ieptb_endereco => vr_ieptb_endereco
                          ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                          ,pr_ieptb_userCode => vr_ieptb_userCode
                          ,pr_ieptb_userPass => vr_ieptb_userPass
                          ,pr_ieptb_remessa => vr_ieptb_remessa
                          ,pr_ieptb_retorno => vr_ieptb_retorno
                          ,pr_ieptb_resposta => vr_ieptb_resposta
                          ,pr_ieptb_erro => vr_ieptb_erro
                          ,pr_emails_cobranca => vr_emails_cobranca                          
                          ,pr_dscritic => vr_dscritic);
                          


    ---
    vr_nmarqv := COBR0011.fn_gera_nome_arquivo_retorno(pr_cdbandoc => pr_cdbandoc
                                                      ,pr_dtmvtolt => pr_dtmvtolt);
    --
    pc_envia_requisicao(pr_cdcooper => pr_cdcooper
                       ,pr_ieptb_endereco => vr_ieptb_endereco
                       ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                       ,pr_ieptb_UserCode => vr_ieptb_userCode
                       ,pr_ieptb_UserPass => vr_ieptb_userPass
                       ,pr_ieptb_resposta => vr_ieptb_resposta
                       ,pr_emails_cobranca => vr_emails_cobranca
                       ,pr_ieptb_erro => vr_ieptb_erro                      
                       ,pr_arquivo => vr_nmarqv
                       ,pr_cdcritic => vr_nmarqv
                       ,pr_dscritic => pr_dscritic);
                       
    
    --                   
    vr_nmarqv := COBR0011.fn_gera_nome_arq_confirmacao(pr_cdbandoc => pr_cdbandoc
                                                      ,pr_dtmvtolt => pr_dtmvtolt);
    
    -- 
    pc_envia_requisicao(pr_cdcooper => pr_cdcooper
                       ,pr_ieptb_endereco => vr_ieptb_endereco
                       ,pr_ieptb_cancelamento => vr_ieptb_cancelamento
                       ,pr_ieptb_UserCode => vr_ieptb_userCode
                       ,pr_ieptb_UserPass => vr_ieptb_userPass
                       ,pr_ieptb_resposta => vr_ieptb_resposta
                       ,pr_emails_cobranca => vr_emails_cobranca
                       ,pr_ieptb_erro => vr_ieptb_erro                  
                       ,pr_arquivo => vr_nmarqv
                       ,pr_cdcritic => vr_nmarqv
                       ,pr_dscritic => pr_dscritic);
                                                          

  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_dscritic := vr_dscritic;
      pc_gera_log(pr_cdcooper
                 ,'[IEPTB] Erro ao enviar remessas: ' || vr_dscritic
                 ,NULL
                 ,0);
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel enviar o arquivo de remessa: '||SQLERRM;
      pc_gera_log(pr_cdcooper
                 ,'[IEPTB] ' || pr_dscritic
                 ,NULL
                 ,0);
  END;
END pc_obtem_retorno;

end WPRT0001;
/
