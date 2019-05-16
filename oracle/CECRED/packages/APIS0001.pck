CREATE OR REPLACE PACKAGE CECRED.APIS0001 is

  /* ---------------------------------------------------------------------------------------------------------------
      Programa : APIS0001
      Sistema  : Rotinas generica referentes PLATAFORMA DE API
      Sigla    : APIS0001
      Autor    : Andrey Formigari - Supero
      Data     : Fevereiro/2019.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela plataforma de API
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Formatar o GUID recebido via parametro
  FUNCTION fn_format_guid(pr_dsguid IN VARCHAR2) RETURN VARCHAR2;

  -- Sortear e retornar a frase de identifica��o do desenvolvedor
  PROCEDURE pc_gerar_frase(pr_dsfrase  OUT tbapi_desenvolvedor.dsfrase_Desenvolvedor%TYPE);
  
  -- Verifica o n�vel de for�a da senha
  FUNCTION fn_check_forca_senha(pr_dsdsenha     IN VARCHAR2) RETURN NUMBER;
  
  -- Grava a credencial de acesso
  PROCEDURE pc_grava_credencial_acesso(pr_cdcooper     IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta     IN crapsnh.nrdconta%TYPE
                                      ,pr_dsdsenha     IN VARCHAR2  -- Senha por extenso
                                      ,pr_cdoperad     IN VARCHAR2  -- C�digo do operador
                                      ,pr_idsenhok    OUT NUMBER    -- Indica que a senha est� ok
                                      ,pr_dserrshn    OUT VARCHAR2  -- Retornar a mensagem de cr�tica de valida��o de senha
                                     );
                                     
  -- Verificar se a senha informada est� correta e bloquear a mesma na ocorrencia de muitas tentativas
  PROCEDURE pc_check_credencial_acesso(pr_cdcooper     IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta     IN crapsnh.nrdconta%TYPE
                                      ,pr_dssnhmd5     IN VARCHAR2  -- SENHA -> MD5
                                      ,pr_idsenhok    OUT NUMBER    -- Indica que a senha � valida
                                      ,pr_dserrshn    OUT VARCHAR2  -- Retornar a mensagem referente ao erro de acesso
                                     );
  
  -- Gerar, gravar e retornar a identifica��o do desenvolvedor: UUID
  PROCEDURE pc_gera_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                  ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                  ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                  ,pr_cdoperad     IN VARCHAR2
                                  ,pr_idformat     IN NUMBER DEFAULT 0 -- 0-N�o / 1-Sim
                                  ,pr_dsuuidds    OUT VARCHAR2);
  
  -- Buscar a identifica��o ativa do desenvolvedor: UUID
  PROCEDURE pc_busca_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                   ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                   ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                   ,pr_idformat     IN NUMBER DEFAULT 0 -- 0-N�o / 1-Sim
                                   ,pr_dsuuidds    OUT VARCHAR2);
                                   
  -- Validar o UUID do desenvolvedor
  FUNCTION pc_check_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                  ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                  ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                  ,pr_dsuuidds     IN VARCHAR2)  RETURN NUMBER;
                                  
  -- Validar identifica��o informada
  PROCEDURE pc_check_identificacao(pr_dsuuidds     IN VARCHAR2
                                  ,pr_cdcooper     IN NUMBER
                                  ,pr_nrdconta     IN NUMBER
                                  ,pr_nmdesenv    OUT VARCHAR2
                                  ,pr_lspermis    OUT CLOB
                                  ,pr_dsmsgerr    OUT VARCHAR2);
  
  -- Retornar data da ultima altera��o do cadastro das APIs do desenvolvedor
  PROCEDURE pc_get_data_alteracao(pr_cdcooper     IN NUMBER
                                 ,pr_nrdconta     IN NUMBER
                                 ,pr_dsxmlret    OUT CLOB
                                 ,pr_dsmsgerr    OUT VARCHAR2);
  
END APIS0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APIS0001 IS
  
  /* ---------------------------------------------------------------------------------------------------------------
      Programa : APIS0001
      Sistema  : Rotinas generica referentes PLATAFORMA DE API
      Sigla    : APIS0001
      Autor    : Andrey Formigari - Supero
      Data     : Fevereiro/2019.

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas utilizadas pela plataforma de API
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Formatar o GUID recebido via parametro
  FUNCTION fn_format_guid(pr_dsguid IN VARCHAR2) RETURN VARCHAR2 IS
    /* .............................................................................
      Programa: fn_format_guid
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Formatar o GUID recebido via parametro

      Observacao: -----

      Alteracoes:
    ..............................................................................*/
    
  BEGIN
    
    -- Formata o GUID passado via parametros -> Formato: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    RETURN REGEXP_REPLACE(LOWER(pr_dsguid)
                         ,'([a-f0-9]{8})([a-f0-9]{4})([a-f0-9]{4})([a-f0-9]{4})([a-f0-9]{12})'
                         ,'\1-\2-\3-\4-\5');
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20010, 'Erro ao formatar GUID: '||SQLERRM);
  END fn_format_guid;
  
  
  PROCEDURE pc_gerar_frase(pr_dsfrase  OUT tbapi_desenvolvedor.dsfrase_desenvolvedor%TYPE) IS --> Retorno da Frase
    /* .............................................................................
      Programa: pc_gerar_frase
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Andrey Formigari (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Sortear e retornar a frase de identifica��o do desenvolvedor

      Observacao: -----

      Alteracoes:
    ..............................................................................*/

    TYPE typ_alfabt IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    vr_tbalfabt    typ_alfabt;
          
    vr_dsfrase    VARCHAR2(10);
    vr_nrdindex    NUMBER;

  BEGIN

    -- Define o alfabeto para gera��o da chave
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'A';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'B';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'C';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'D';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'E';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'F';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'G';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'H';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'I';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'J';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'K';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'L';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'M';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'N';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'O';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'P';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'Q';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'R';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'S';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'T';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'U';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'V';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'W';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'X';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'Y';
    vr_tbalfabt(vr_tbalfabt.count()+1) := 'Z';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '0';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '1';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '2';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '3';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '4';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '5';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '6';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '7';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '8';
    vr_tbalfabt(vr_tbalfabt.count()+1) := '9';
        
    vr_dsfrase := '';
        
    LOOP 
          
      -- Sorteia um indice aleat�rio
      vr_nrdindex := trunc((vr_tbalfabt.count()+1) * dbms_random.value);
          
      -- Verifica se o indice sorteado est� no alfabeto
      IF vr_tbalfabt.EXISTS(vr_nrdindex) THEN
        -- Adiciona a letra do alfabeto na frase
        vr_dsfrase := vr_dsfrase||vr_tbalfabt(vr_nrdindex);
      END IF;
          
      -- Quando alcan�ar o tamanho da chave... sai da itera��o
      EXIT WHEN LENGTH(vr_dsfrase) = 10;
    
    END LOOP;
        
    pr_dsfrase := vr_dsfrase;
    
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'Erro ao gerar Frase do Desenvolvedor: '||SQLERRM);
  END pc_gerar_frase;
  
  -- Verifica o n�vel de for�a da senha
  FUNCTION fn_check_forca_senha(pr_dsdsenha     IN VARCHAR2) RETURN NUMBER IS 
    /* .............................................................................
      Programa: fn_check_forca_senha
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Pontuar o n�vel de seguran�a de senha

      Observacao: A for�a de senha � baseada na pontua��o que uma senha possui. Cada 
                  tipo de caracte utilizado gera 1 ponto e a soma total de pontos �
                  a pontua��o final da senha:
                    -> Utiliza caracter MAI�SCULO
                    -> Utiliza caracter MIN�SCULO
                    -> Utiliza caracter NUM�RICO
                    -> Utiliza caracter S�MBOLO
      

      Alteracoes:
    ..............................................................................*/  
    
    -- Vari�veis
    vr_dscrtasc   NUMBER;
    vr_idmaiusc   BOOLEAN := FALSE;
    vr_idminusc   BOOLEAN := FALSE;
    vr_idnumber   BOOLEAN := FALSE;
    vr_idsimbol   BOOLEAN := FALSE;
    
    vr_qtpontos   NUMBER := 0;
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
  BEGIN
    
    -- Percorre cada um dos d�gitos da senha
    FOR vr_index IN 1..length(pr_dsdsenha) LOOP
      
      -- RESERVAR O CARACTER DA SENHA - C�digo da tabela ASC
      vr_dscrtasc :=  ASCII(                                    -- Retornar o c�digo ASC
                          gene0007.fn_caract_acento(            -- Remover acentua��o
                             SUBSTR(pr_dsdsenha , vr_index , 1) -- Ler o caracter
                          )
                      );
      
      -- Verifica se � caracter Mai�sculo
      IF vr_dscrtasc BETWEEN 65 AND 90 THEN
        vr_idmaiusc := TRUE;
        CONTINUE;
      END IF;
      
      -- Verifica se � caracter Min�sculo
      IF vr_dscrtasc BETWEEN 97 AND 122 THEN
        vr_idminusc := TRUE;
        CONTINUE;
      END IF;
      
      -- Verifica se � caracter Num�rico
      IF vr_dscrtasc BETWEEN 48 AND 57 THEN
        vr_idnumber := TRUE;
        CONTINUE;
      END IF;
      
      -- Verificar se o caracter � um S�mbolo esperado
      IF vr_dscrtasc BETWEEN  32 AND  47 OR   --  !"#$%&'()*+,-./
         vr_dscrtasc BETWEEN  58 AND  64 OR   -- :;<=>?@
         vr_dscrtasc BETWEEN  91 AND  96 OR   -- [\]^_`
         vr_dscrtasc BETWEEN 123 AND 126 THEN -- {|}~
        vr_idsimbol := TRUE;
        CONTINUE;
      END IF;
      
      -- Se n�o identificar o caracter, deve criticar existencia de caracter inv�lido
      vr_dscritic := 'Senha possui caracteres inv�lidos.';
      RAISE vr_exc_erro;
      
    END LOOP;
    
    -- VERIFICAR PONTUA��O DA SENHA 
    -- MAI�SCULAS
    IF vr_idmaiusc THEN
      vr_qtpontos := vr_qtpontos + 1;
    END IF;
    -- MIN�SCULAS
    IF vr_idminusc THEN
      vr_qtpontos := vr_qtpontos + 1;
    END IF;
    -- NUM�RICAS
    IF vr_idnumber THEN
      vr_qtpontos := vr_qtpontos + 1;
    END IF;
    -- SIMBOLOS
    IF vr_idsimbol THEN
      vr_qtpontos := vr_qtpontos + 1;
    END IF;
    
    -- Retornar a pontua��o
    RETURN vr_qtpontos;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20003,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20004,'Erro ao verificar for�a de senha: '||SQLERRM);
  END fn_check_forca_senha;
  
  
  -- Grava a credencial de acesso
  PROCEDURE pc_grava_credencial_acesso(pr_cdcooper     IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta     IN crapsnh.nrdconta%TYPE
                                      ,pr_dsdsenha     IN VARCHAR2  -- Senha por extenso
                                      ,pr_cdoperad     IN VARCHAR2  -- C�digo do operador
                                      ,pr_idsenhok    OUT NUMBER    -- Indica que a senha est� ok
                                      ,pr_dserrshn    OUT VARCHAR2  -- Retornar a mensagem de cr�tica de valida��o de senha
                                      ) IS 
    /* .............................................................................
      Programa: pc_grava_credencial_acesso
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Manter as senhas de acesso a API

      Observacao: -----

      Alteracoes:
    ..............................................................................*/
            
    -- Vari�veis
    vr_dshexsnh     VARCHAR2(32);  -- Para comportar o hexadecimal de RAW(16)
    vr_qtpontos     NUMBER;

    vr_dscritic     VARCHAR2(2000);
    vr_exc_erro     EXCEPTION;
    
  BEGIN
    
    -- Verificar se a senha possui ao menos 10 caracteres
    IF LENGTH(pr_dsdsenha) < 10 THEN
      pr_idsenhok := 0; -- Senha n�o � valida
      pr_dserrshn := 'Senha deve ter no m�nimo 10 caracteres.';
      
      -- Encerra a execu��o da rotina
      RETURN;
    END IF;
  
    -- Verificar a FOR�A da Senha
    BEGIN
      -- Calcular a pontua��o da senha
      vr_qtpontos := fn_check_forca_senha(pr_dsdsenha);
    EXCEPTION
      WHEN OTHERS THEN
        pr_idsenhok := 0; -- Senha n�o � valida
        pr_dserrshn := SUBSTR(SQLERRM,12); -- Ignorar o c�digo oracle, retornando apenas a mensagem

        -- Encerra a execu��o da rotina
        RETURN;
    END;
    
    -- Se a senha n�o alca�ou ao menos 3 pontos
    IF vr_qtpontos < 3 THEN
      pr_idsenhok := 0; -- Senha n�o � valida
      pr_dserrshn := 'For�a de senha muito baixa.';
      
      -- Encerra a execu��o da rotina
      RETURN;
    END IF;
    
    -- Converter a senha para MD5
    vr_dshexsnh := rawtohex( dbms_obfuscation_toolkit.md5(input => UTL_RAW.cast_to_raw( pr_dsdsenha )) );
  
    BEGIN
      -- Inserir o registro da senha
      INSERT INTO crapsnh(cdcooper
                         ,nrdconta
                         ,tpdsenha
                         ,idseqttl
                         ,cdsitsnh
                         ,dtaltsit
                         ,cdoperad
                         ,dtlibera
                         ,hrtransa
                         ,dssenweb
                         ,dtinsori
                         ,cdopeori)  
                  VALUES (pr_cdcooper             -- cdcooper
                         ,pr_nrdconta             -- nrdconta
                         ,4  -- ACESSO API        -- tpdsenha 
                         ,1  -- Sempre titular    -- idseqttl 
                         ,1  -- ATIVA             -- cdsitsnh
                         ,trunc(SYSDATE)          -- dtaltsit 
                         ,pr_cdoperad             -- cdoperad
                         ,trunc(SYSDATE)          -- dtlibera
                         ,GENE0002.fn_busca_time  -- hrtransa
                         ,vr_dshexsnh             -- dssenweb 
                         ,trunc(SYSDATE)          -- dtinsori
                         ,pr_cdoperad);           -- cdopeori
      
      /***************************
        OBSERVA��O: A senha ser� gravada no campo DSSENWEB, pois o campo CDDSENHA n�o suporta 
                    o hexadecimal de 32 d�gitos, retornado pela fun��o MD5
      ***************************/
    
    EXCEPTION
      WHEN dup_val_on_index THEN

        BEGIN
          -- Atualizar a senha, pois a mesma j� existe
          UPDATE crapsnh  snh
             SET snh.cdsitsnh = 1 -- Ativa a senha
               , snh.dtaltsit = TRUNC(SYSDATE)
               , snh.dtaltsnh = TRUNC(SYSDATE)
               , snh.dtlibera = TRUNC(SYSDATE)
               , snh.hrtransa = GENE0002.fn_busca_time
               , snh.cdoperad = pr_cdoperad
               , snh.dssenweb = vr_dshexsnh
               , snh.qtacerro = 0 -- Limpar tentativas com erro
           WHERE snh.cdcooper = pr_cdcooper
             AND snh.nrdconta = pr_nrdconta
             AND snh.tpdsenha = 4  -- Acesso API
             AND snh.idseqttl = 1; -- Primeiro titular
        EXCEPTION
          WHEN OTHERS THEN
            -- gerar erro
            vr_dscritic := 'Erro ao atualizar credencial: '||SQLERRM;
            RAISE vr_exc_erro;
        END;   

      WHEN OTHERS THEN
        -- gerar erro
        vr_dscritic := 'Erro ao incluir credencial: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Indica que a senha est� ok e gravada
    pr_idsenhok := 1; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20002, vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20001, 'Erro ao gravar Credencial: '||SQLERRM);
  END pc_grava_credencial_acesso;
  
  -- Verificar se a senha informada est� correta e bloquear a mesma na ocorrencia de muitas tentativas
  PROCEDURE pc_check_credencial_acesso(pr_cdcooper     IN crapsnh.cdcooper%TYPE
                                      ,pr_nrdconta     IN crapsnh.nrdconta%TYPE
                                      ,pr_dssnhmd5     IN VARCHAR2  -- SENHA -> MD5
                                      ,pr_idsenhok    OUT NUMBER    -- Indica que a senha � valida
                                      ,pr_dserrshn    OUT VARCHAR2  -- Retornar a mensagem referente ao erro de acesso
                                     ) IS 
    /* .............................................................................
      Programa: pc_check_credencial_acesso
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Verificar se a senha informada est� correta e bloquear a mesma
                  na ocorrencia de muitas tentativas

      Observacao: -----

      Alteracoes:
    ..............................................................................*/  
    
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    -- Buscar a senha de acesso a API
    CURSOR cr_crapsnh IS
      SELECT ROWID  dsdrowid
           , snh.cdsitsnh
           , snh.dssenweb
           , snh.qtacerro
           , snh.dtultace
           , snh.hrultace
           , snh.dtvldsnh  -- Ser� utilizada para guardar a ultima valida��o de senha realizada
        FROM crapsnh  snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = 1  -- Sempre primeiro titular
         AND snh.tpdsenha = 4  -- ACESSO API
       FOR UPDATE; -- Lock do registro
    rw_crapsnh   cr_crapsnh%ROWTYPE;    
    
    -- Vari�veis
    vr_exc_erro   EXCEPTION;
    vr_exc_sucs   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
    -- Atualizar o registro de acesso
    PROCEDURE pc_atualiza_ctrl_erro(pr_dsdrowid IN VARCHAR2) IS
      
    BEGIN
      
      -- Atualiza os indicadores de bloqueio de senha
      UPDATE crapsnh  snh
         SET snh.qtacerro = 0
           , snh.dtultace = TRUNC(SYSDATE)
           , snh.hrultace = GENE0002.fn_busca_time
           , snh.dtvldsnh = TRUNC(SYSDATE)
       WHERE ROWID = pr_dsdrowid;
      
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20100,'Erro ao atualizar indicadores da senha: ' ||SQLERRM);
    END pc_atualiza_ctrl_erro;
    
    -- Bloquear a senha de acesso a plataforma de API
    PROCEDURE pc_bloqueia_senha_acesso(pr_dsdrowid IN VARCHAR2
                                      ,pr_idbloque IN NUMBER) IS -- 0 para contabilizar / 1 para bloquear / 2 - Para reiniciar
      
    BEGIN
      
      -- Atualiza os indicadores de bloqueio de senha
      UPDATE crapsnh  snh
         SET snh.qtacerro = DECODE(pr_idbloque, 2, 1 -- Registra o primeiro erro
                                              , NVL(snh.qtacerro,0) + 1) -- contabiliza
           , snh.cdsitsnh = DECODE(pr_idbloque, 1, 2 -- Bloqueia a senha
                                              , snh.cdsitsnh) -- manter a situa��o atual
           , snh.dtaltsit = DECODE(pr_idbloque, 1, TRUNC(SYSDATE)
                                              , snh.dtaltsit)
           , snh.dtvldsnh = TRUNC(SYSDATE) -- Guarda o dia da �ltima valida��o de senha
       WHERE ROWID = pr_dsdrowid;
    
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20101,'Erro ao bloquear senha de acesso: ' ||SQLERRM);
    END pc_bloqueia_senha_acesso;
    
  BEGIN
    
    -- Buscar a senha para acesso 
    OPEN  cr_crapsnh;
    FETCH cr_crapsnh INTO rw_crapsnh;
    
    -- Se n�o encontrou registro de senha
    IF cr_crapsnh%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapsnh;  
    
      pr_idsenhok := 0; -- Acesso n�o permitido
      pr_dserrshn := 'Cooperado n�o possui acesso a plataforma API.';
      
      -- Encerra o processo de valida��o
      RAISE vr_exc_sucs;
    END IF;
    
    -- Fechar p cursor
    CLOSE cr_crapsnh;
    
    -- Verifica a situa��o da senha - INATIVA
    IF rw_crapsnh.cdsitsnh = 0 THEN
      pr_idsenhok := 0; -- Acesso n�o permitido
      pr_dserrshn := 'Credencial de acesso da plataforma API est� INATIVA.';
      
      -- Encerra o processo de valida��o
      RAISE vr_exc_sucs;
    END IF;
    
    -- Verifica a situa��o da senha - BLOQUEADA
    IF rw_crapsnh.cdsitsnh = 2 THEN
      pr_idsenhok := 0; -- Acesso n�o permitido
      pr_dserrshn := 'Credencial de acesso da plataforma API est� BLOQUEADA.';
      
      -- Encerra o processo de valida��o
      RAISE vr_exc_sucs;
    END IF;
    
    -- Verifica a situa��o da senha - CANCELADA
    IF rw_crapsnh.cdsitsnh = 3 THEN
      pr_idsenhok := 0; -- Acesso n�o permitido
      pr_dserrshn := 'Credencial de acesso da plataforma API est� CANCELADA.';
      
      -- Encerra o processo de valida��o
      RAISE vr_exc_sucs;
    END IF;
    
    /***** VERIFICAR SE A SENHA INFORMADA CONFERE COM A SENHA CADASTRADA *****/
    IF rw_crapsnh.dssenweb = pr_dssnhmd5 THEN
      -- Atualizar o contador de acessos com erro 
      pc_atualiza_ctrl_erro(rw_crapsnh.dsdrowid);  
      
      -- Retorna o ok da senha  
      pr_idsenhok := 1; -- Acesso permitido
      pr_dserrshn := NULL;
      
    ELSE
      
      -- Verificar quanto a quanto tempo ocorreu a ultima tentativa de acesso
      -- Se foi no mesmo dia
      IF NVL(rw_crapsnh.dtvldsnh,TRUNC(SYSDATE)) = TRUNC(SYSDATE) THEN
        
        -- Se ultrapassou 3 tentativas sem sucesso (1 - qt=0 / 2 - qt=1 / 3 - qt=2)
        IF rw_crapsnh.qtacerro >= 2 THEN
          -- Realizar o bloqueio da senha de acesso
          pc_bloqueia_senha_acesso(rw_crapsnh.dsdrowid,1);
        ELSE
          -- Contabiliza bloqueio de acesso
          pc_bloqueia_senha_acesso(rw_crapsnh.dsdrowid,0);
        END IF;
      
      ELSE 
        -- Reiniciar / registrar erro de acesso
        pc_bloqueia_senha_acesso(rw_crapsnh.dsdrowid,2);
      END IF;
      
      -- Retorna o ok da senha  
      pr_idsenhok := 0; -- Acesso n�o permitido
      pr_dserrshn := 'Credencial de acesso inv�lida.';
      
    END IF;
    
    -- Sucesso
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_sucs THEN
      COMMIT; -- Sucesso
    WHEN vr_exc_erro THEN
      ROLLBACK;
      raise_application_error(-20005,vr_dscritic);
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20006,'Erro ao verificar acesso: '||SQLERRM);
  END pc_check_credencial_acesso;
  
  -- Gerar, gravar e retornar a identifica��o do desenvolvedor: UUID
  PROCEDURE pc_gera_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                  ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                  ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                  ,pr_cdoperad     IN VARCHAR2
                                  ,pr_idformat     IN NUMBER DEFAULT 0 -- 0-N�o / 1-Sim
                                  ,pr_dsuuidds    OUT VARCHAR2) IS 
    /* .............................................................................
      Programa: pc_gera_identif_desenv
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Gerar, gravar e retornar a identifica��o do desenvolvedor: UUID

      Observacao: Quando for informado o c�digo do operador, a rotina utilizar� este c�digo
                  como referencia ao desenvolvedor que tera seu UUID gerado. Quando for 
                  omitido o c�digo e informado a pessoa e documento, o sistema ir� buscar
                  o c�digo do desenvolvedor no cadastro. Caso o INPESSOA n�o seja passado
                  e apenas um desenvolvedor for encontrado, este ser� considerado, todavia
                  se mais de um desenvolvedor for encontrado, ser� retornado erro.

      Alteracoes:
    ..............................................................................*/  
    
    -- Buscar o desenvolvedor informado 
    CURSOR cr_desenv IS
      SELECT t.cddesenvolvedor
           , COUNT(1) OVER (PARTITION BY 1) qtdesenv
        FROM tbapi_desenvolvedor t
       WHERE (t.cddesenvolvedor = pr_cddesenv     
          OR     (t.inpessoa    = NVL(pr_inpessoa,t.inpessoa)
             AND  t.nrdocumento = pr_nrdocdsv
             AND  pr_cddesenv   IS NULL));
    
    -- Buscar o pr�ximo valor da sequencia
    CURSOR cr_acesso(pr_cddesenv IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE) IS
      SELECT NVL(MAX(ace.idsequencia_chave),0) + 1
        FROM tbapi_acesso_desenvolvedor  ace
       WHERE ace.cddesenvolvedor = pr_cddesenv;
    
    -- Vari�veis
    vr_cddesenv   tbapi_desenvolvedor.cddesenvolvedor%TYPE;
    vr_qtdesenv   NUMBER;
    vr_dschvdes   VARCHAR2(32);  -- GUID gerado para o desenvolvedor
    
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
  BEGIN
    
    -- Buscar os desenvolvedores conforme parametros informados
    OPEN  cr_desenv;
    FETCH cr_desenv INTO vr_cddesenv, vr_qtdesenv;
    CLOSE cr_desenv;
  
    -- Verifica se foi encontrado desenvolvedor 
    IF vr_cddesenv IS NULL THEN
      -- Retornar critica informando que n�o foi encontrado desenvolvedor
      vr_dscritic := 'Cadastro do desenvolvedor n�o encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se foi encontrado mais de um desenvolvedor
    IF NVL(vr_qtdesenv,0) > 1 THEN
      -- Retornar critica informando que mais de um desenvolvedor foi encontrado
      vr_dscritic := 'Mais de um desenvolvedor encontrado para os par�metros informados.';
      RAISE vr_exc_erro;
    END IF;
  
    BEGIN
      -- Realizar o cancelamento de todas as UUIDs do desenvolvedor
      UPDATE tbapi_acesso_desenvolvedor ace
         SET ace.cdsituacao_chave = 2 -- Cancelada
       WHERE ace.cddesenvolvedor  = vr_cddesenv
         AND ace.cdsituacao_chave = 1;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro do UPDATE
        vr_dscritic := 'Erro ao cancelar UUIDs ativas: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  
    -- Reinicializa
    vr_qtdesenv := 0;
  
    -- Buscar o valor de sequencia para inserir o registro do UUID
    OPEN  cr_acesso(vr_cddesenv);
    FETCH cr_acesso INTO vr_qtdesenv;
    
    -- Se n�o retornar registros
    IF cr_acesso%NOTFOUND THEN
      vr_qtdesenv := 1;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_acesso;
  
    -- Gerar e inserir a nova UUID do desenvolvedor
    BEGIN
      INSERT INTO tbapi_acesso_desenvolvedor
                       (cddesenvolvedor
                       ,idsequencia_chave
                       ,cdsituacao_chave
                       ,dtgeracao_chave
                       ,cdoperador)
                 VALUES(vr_cddesenv  -- cddesenvolvedor
                       ,vr_qtdesenv  -- idsequencia_chave
                       ,1  -- ATIVA  -- cdsituacao_chave
                       ,SYSDATE      -- dtgeracao_chave
                       ,pr_cdoperad) -- cdoperador
          RETURNING tbapi_acesso_desenvolvedor.dschave
               INTO vr_dschvdes;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retornar erro do INSERT
        vr_dscritic := 'Erro gerar nova UUIDs: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
  
    -- Se n�o h� GUID gerado
    IF vr_dschvdes IS NULL THEN
      -- Retornar erro do UPDATE
      vr_dscritic := 'Falha na gera��o da UUID do desenvolvedor.';
      RAISE vr_exc_erro;
    END IF;
    
    
    -- Verifica se deve retornar formatado 
    IF NVL(pr_idformat,0) = 0 THEN
      -- Retorna o UUID gerado
      pr_dsuuidds := vr_dschvdes;
    ELSE 
      -- Formatar e retornar o UUID gerado
      pr_dsuuidds := fn_format_guid(vr_dschvdes);
    END IF;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20008,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20009,'Erro ao gerar identifica��o do desenvolvedor: '||SQLERRM);
  END pc_gera_identif_desenv;
  
  -- Buscar a identifica��o ativa do desenvolvedor: UUID
  PROCEDURE pc_busca_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                   ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                   ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                   ,pr_idformat     IN NUMBER DEFAULT 0 -- 0-N�o / 1-Sim
                                   ,pr_dsuuidds    OUT VARCHAR2) IS 
    /* .............................................................................
      Programa: pc_busca_identif_desenv
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Retornar a identifica��o do desenvolvedor: UUID

      Observacao: Quando for informado o c�digo do operador, a rotina utilizar� este c�digo
                  como referencia ao desenvolvedor que tera seu UUID gerado. Quando for 
                  omitido o c�digo e informado a pessoa e documento, o sistema ir� buscar
                  o c�digo do desenvolvedor no cadastro. Caso o INPESSOA n�o seja passado
                  e apenas um desenvolvedor for encontrado, este ser� considerado, todavia
                  se mais de um desenvolvedor for encontrado, ser� retornado erro.

      Alteracoes:
    ..............................................................................*/  
    
    -- Buscar o desenvolvedor informado 
    CURSOR cr_desenv IS
      SELECT t.cddesenvolvedor
           , COUNT(1) OVER (PARTITION BY 1) qtdesenv
        FROM tbapi_desenvolvedor t
       WHERE (t.cddesenvolvedor = pr_cddesenv     
          OR     (t.inpessoa    = NVL(pr_inpessoa,t.inpessoa)
             AND  t.nrdocumento = pr_nrdocdsv
             AND  pr_cddesenv   IS NULL));
    
    -- Buscar o pr�ximo valor da sequencia
    CURSOR cr_acesso(pr_cddesenv IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE) IS
      SELECT ace.dschave
           , COUNT(1) OVER (PARTITION BY 1) qtchaves
        FROM tbapi_acesso_desenvolvedor  ace
       WHERE ace.cddesenvolvedor  = pr_cddesenv
         AND ace.cdsituacao_chave = 1; -- ATIVA
    
    -- Vari�veis
    vr_cddesenv   tbapi_desenvolvedor.cddesenvolvedor%TYPE;
    vr_qtdesenv   NUMBER;
    vr_dschvdes   VARCHAR2(32);  -- GUID gerado para o desenvolvedor
    vr_qtchaves   NUMBER;
    
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
  BEGIN
    
    -- Buscar os desenvolvedores conforme parametros informados
    OPEN  cr_desenv;
    FETCH cr_desenv INTO vr_cddesenv, vr_qtdesenv;
    CLOSE cr_desenv;
  
    -- Verifica se foi encontrado desenvolvedor 
    IF vr_cddesenv IS NULL THEN
      -- Retornar critica informando que n�o foi encontrado desenvolvedor
      vr_dscritic := 'Cadastro do desenvolvedor n�o encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se foi encontrado mais de um desenvolvedor
    IF NVL(vr_qtdesenv,0) > 1 THEN
      -- Retornar critica informando que mais de um desenvolvedor foi encontrado
      vr_dscritic := 'Mais de um desenvolvedor encontrado para os par�metros informados.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Buscar o valor de sequencia para inserir o registro do UUID
    OPEN  cr_acesso(vr_cddesenv);
    FETCH cr_acesso INTO vr_dschvdes
                       , vr_qtchaves;
    -- Fechar o cursor
    CLOSE cr_acesso;
  
    -- Se h� mais de uma chave ativa, � problema
    IF NVL(vr_qtchaves,0) > 1 THEN
      -- Retornar erro do UPDATE
      vr_dscritic := 'Foi encontrada mais de uma chave ativa para o desenvolvedor';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se deve retornar formatado 
    IF NVL(pr_idformat,0) = 0 THEN
      -- Retorna o UUID gerado
      pr_dsuuidds := vr_dschvdes;
    ELSE 
      -- Formatar e retornar o UUID gerado
      pr_dsuuidds := fn_format_guid(vr_dschvdes);
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20008,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20009,'Erro ao gerar identifica��o do desenvolvedor: '||SQLERRM);
  END pc_busca_identif_desenv;
  
  -- Validar o UUID do desenvolvedor
  FUNCTION pc_check_identif_desenv(pr_cddesenv     IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE DEFAULT NULL
                                  ,pr_inpessoa     IN tbapi_desenvolvedor.inpessoa%TYPE               DEFAULT NULL
                                  ,pr_nrdocdsv     IN tbapi_desenvolvedor.nrdocumento%TYPE            DEFAULT NULL
                                  ,pr_dsuuidds     IN VARCHAR2)  RETURN NUMBER IS 
    /* .............................................................................
      Programa: pc_check_identif_desenv
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Fevereiro/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Verificar se o UUID informado para o desenvolvedor confere.

      Observacao: ------

      Alteracoes:
    ..............................................................................*/  
    
    -- Buscar o desenvolvedor informado 
    CURSOR cr_desenv IS
      SELECT t.cddesenvolvedor
           , COUNT(1) OVER (PARTITION BY 1) qtdesenv
        FROM tbapi_desenvolvedor t
       WHERE (t.cddesenvolvedor = pr_cddesenv     
          OR     (t.inpessoa    = NVL(pr_inpessoa,t.inpessoa)
             AND  t.nrdocumento = pr_nrdocdsv
             AND  pr_cddesenv   IS NULL));
    
    -- Buscar o pr�ximo valor da sequencia
    CURSOR cr_acesso(pr_cddesenv IN tbapi_acesso_desenvolvedor.cddesenvolvedor%TYPE) IS
      SELECT ace.dschave
           , COUNT(1) OVER (PARTITION BY 1) qtchaves
        FROM tbapi_acesso_desenvolvedor  ace
       WHERE ace.cddesenvolvedor  = pr_cddesenv
         AND ace.cdsituacao_chave = 1; -- ATIVA
    
    -- Vari�veis
    vr_cddesenv   tbapi_desenvolvedor.cddesenvolvedor%TYPE;
    vr_qtdesenv   NUMBER;
    vr_dschvdes   VARCHAR2(32);  -- GUID gerado para o desenvolvedor
    vr_dsuuidds   VARCHAR2(50);
    vr_qtchaves   NUMBER;
    
    vr_exc_erro   EXCEPTION;
    vr_dscritic   VARCHAR2(1000);
    
  BEGIN
    
    -- Buscar os desenvolvedores conforme parametros informados
    OPEN  cr_desenv;
    FETCH cr_desenv INTO vr_cddesenv, vr_qtdesenv;
    CLOSE cr_desenv;
  
    -- Verifica se foi encontrado desenvolvedor 
    IF vr_cddesenv IS NULL THEN
      -- Retornar critica informando que n�o foi encontrado desenvolvedor
      vr_dscritic := 'Cadastro do desenvolvedor n�o encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verificar se foi encontrado mais de um desenvolvedor
    IF NVL(vr_qtdesenv,0) > 1 THEN
      -- Retornar critica informando que mais de um desenvolvedor foi encontrado
      vr_dscritic := 'Mais de um desenvolvedor encontrado para os par�metros informados.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Buscar o valor de sequencia para inserir o registro do UUID
    OPEN  cr_acesso(vr_cddesenv);
    FETCH cr_acesso INTO vr_dschvdes
                       , vr_qtchaves;
    -- Fechar o cursor
    CLOSE cr_acesso;
  
    -- Se h� mais de uma chave ativa, � problema
    IF NVL(vr_qtchaves,0) > 1 THEN
      -- Retornar erro do UPDATE
      vr_dscritic := 'Foi encontrada mais de uma chave ativa para o desenvolvedor';
      RAISE vr_exc_erro;
    END IF;
    
    -- Guid
    vr_dsuuidds := UPPER(REPLACE(pr_dsuuidds,'-',NULL));
    
    -- VErifica a chave informada
    IF vr_dschvdes = vr_dsuuidds THEN
      RETURN 1;
    ELSE 
      RETURN 0;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      raise_application_error(-20011,vr_dscritic);
    WHEN OTHERS THEN
      raise_application_error(-20012,'Erro ao validar identifica��o do desenvolvedor: '||SQLERRM);
  END pc_check_identif_desenv;
  
  -- Validar as informa��es de acesso do desenvolvedor e cooperado
  PROCEDURE pc_check_identificacao(pr_dsuuidds     IN VARCHAR2
                                  ,pr_cdcooper     IN NUMBER
                                  ,pr_nrdconta     IN NUMBER
                                  ,pr_nmdesenv    OUT VARCHAR2
                                  ,pr_lspermis    OUT CLOB
                                  ,pr_dsmsgerr    OUT VARCHAR2)   IS 
    /* .............................................................................
      Programa: pc_check_identificacao
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Abril/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Verificar se as informa��es do desenvolvedor e do cooperado est�o corretas

      Observacao: ------

      Alteracoes:
    ..............................................................................*/  
    
    -- Verificar se o cooperado existe
    CURSOR cr_crapass IS
      SELECT ass.dtdemiss
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rg_crapass   cr_crapass%ROWTYPE;
    
    -- Buscar a credencial de acesso do cooperado
    CURSOR cr_crapsnh IS
      SELECT snh.cdsitsnh
           , snh.dssenweb
           , snh.qtacerro
           , snh.dtultace
           , snh.hrultace
           , snh.dtvldsnh  -- Ser� utilizada para guardar a ultima valida��o de senha realizada
        FROM crapsnh  snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.idseqttl = 1  -- Sempre primeiro titular
         AND snh.tpdsenha = 4;
    rg_crapsnh   cr_crapsnh%ROWTYPE;
    
    -- Buscar o UUID do desenvolvedor
    CURSOR cr_desenvl(pr_dsuuidds  VARCHAR2) IS
      SELECT ace.cddesenvolvedor
           , ace.cdsituacao_chave
           , dsv.dsnome
        FROM tbapi_desenvolvedor         dsv
           , tbapi_acesso_desenvolvedor  ace
       WHERE dsv.cddesenvolvedor = ace.cddesenvolvedor
         AND UPPER(ace.dschave)  = pr_dsuuidds;
    rg_desenvl     cr_desenvl%ROWTYPE;
    
    -- Buscar todos os servi�os do cooperado e do desenvolvedor informado
    CURSOR cr_apisdsv(pr_cddesenv NUMBER) IS
      SELECT s.idservico_api
           , s.dsservico_api
           , s.dspermissao_api
        FROM tbapi_produto_servico         s
           , tbapi_cooperado_servico       c
           , tbapi_desenvolvedor_cooperado t
       WHERE s.idservico_api   = c.idservico_api
         AND c.cdcooper        = t.cdcooper
         AND c.nrdconta        = t.nrdconta
         AND c.idservico_api   = t.idservico_api
         AND c.idsituacao_adesao = 1 -- ATIVA
         AND t.cdcooper        = pr_cdcooper
         AND t.nrdconta        = pr_nrdconta
         AND t.cddesenvolvedor = pr_cddesenv
       ORDER BY s.idservico_api;
    
    -- Vari�veis
    vr_dsuuidds   VARCHAR2(50);
    vr_idservic   BOOLEAN;
    vr_dsxmlarq   xmltype;
    vr_nrindice   NUMBER;
    vr_dscritic   VARCHAR2(1000);
    
  BEGIN
    
    -- Monta a estrutura base para retorno
    vr_dsxmlarq := XMLTYPE.createXML('<?xml version="1.0" encoding="ISO-8859-1"?>'
                                   ||'<servicos> '
                                   ||'</servicos>');
  
    -- Buscar pelo cooperado
    OPEN  cr_crapass;
    FETCH cr_crapass INTO rg_crapass;
    
    -- Se n�o encontrar o cooperado
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapass;  
    
      -- Retornar mensagem informando que o cooperado n�o foi encontrado
      pr_dsmsgerr := 'Cooperado n�o encontrado.';
      
      -- Encerra o processo de valida��o
      RETURN;
    END IF;
    
    -- Fecha o cursor
    CLOSE cr_crapass;
  
    -- Verificar se conta j� n�o est� demitida
    IF rg_crapass.dtdemiss IS NOT NULL THEN
      -- Retornar mensagem informando que a conta j� est� demitida
      pr_dsmsgerr := 'Conta do Cooperado est� encerrada.';
      
      -- Encerra o processo de valida��o
      RETURN;
    END IF;
  
    -- Buscar a credencial de acesso do cooperado
    OPEN  cr_crapsnh;
    FETCH cr_crapsnh INTO rg_crapsnh;
    
    -- Se n�o encontrar credencial cadastrada
    IF cr_crapsnh%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapsnh;  
    
      -- Retornar mensagem informando que o cooperado n�o possui acesso
      pr_dsmsgerr := 'Cooperado n�o possui acesso a plataforma API.';
      
      -- Encerra o processo de valida��o
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_crapsnh;
  
    -- Retirar os h�fens do uuid
    vr_dsuuidds := UPPER(REPLACE(pr_dsuuidds,'-',NULL));
  
    -- Buscar o desenvolvedor pelo UUID
    OPEN  cr_desenvl(vr_dsuuidds);
    FETCH cr_desenvl INTO rg_desenvl;
    
    -- Se n�o encontrar o desenvolvedor 
    IF cr_desenvl%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_desenvl;  
    
      -- Retornar mensagem informando que o cooperado n�o possui acesso
      pr_dsmsgerr := 'Nenhum Desenvolvedor encontrado com o UUID informado.';
      
      -- Encerra o processo de valida��o
      RETURN;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_desenvl;
    
    -- Verificar se o UUID informado est� ativo
    IF rg_desenvl.cdsituacao_chave <> 1 THEN -- ATIVA
      -- Retonar critica
      pr_dsmsgerr := 'UUID do Desenvolvedor informada est� inativa.';
      
      -- Sair da rotina 
      RETURN;
    END IF;
    
    -- Retornar o nome do desenvolvedor
    pr_nmdesenv := rg_desenvl.dsnome;
    
    -- Indicar que n�o foi encontrado servi�os
    vr_idservic := FALSE;
    
    -- Contador de �ndice
    vr_nrindice := 0;
    
    -- Percorrer todos os servi�os de API ativos para o cooperado, conforme desenvolvedor
    FOR rg_apisdsv IN cr_apisdsv(rg_desenvl.cddesenvolvedor) LOOP
      -- Indicar que encontrou servi�o
      vr_idservic := TRUE;
      
      -- Adicionar cada uma das APIs no xml de retorno
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => 'servicos'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'servico'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
      
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20013,'Erro ao incluir tag no XML: '||vr_dscritic);
      END IF;  
      
      -- Adicionar cada uma das APIs no xml de retorno
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => 'servico'
                            ,pr_posicao  => vr_nrindice
                            ,pr_tag_nova => 'idservico'
                            ,pr_tag_cont => rg_apisdsv.idservico_api
                            ,pr_des_erro => vr_dscritic);
      
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20014,'Erro ao incluir tag no XML: '||vr_dscritic);
      END IF;  
      
      -- Adicionar cada uma das APIs no xml de retorno
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => 'servico'
                            ,pr_posicao  => vr_nrindice
                            ,pr_tag_nova => 'dsservico'
                            ,pr_tag_cont => rg_apisdsv.dsservico_api
                            ,pr_des_erro => vr_dscritic);
      
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20015,'Erro ao incluir tag no XML: '||vr_dscritic);
      END IF;  
      
      -- Adicionar cada uma das APIs no xml de retorno
      GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                            ,pr_tag_pai  => 'servico'
                            ,pr_posicao  => vr_nrindice
                            ,pr_tag_nova => 'dspermissao'
                            ,pr_tag_cont => rg_apisdsv.dspermissao_api
                            ,pr_des_erro => vr_dscritic);
      
      -- Se ocorrer erro
      IF vr_dscritic IS NOT NULL THEN
        raise_application_error(-20016,'Erro ao incluir tag no XML: '||vr_dscritic);
      END IF; 
      
      -- Contador de �ndice
      vr_nrindice := vr_nrindice + 1;
      
    END LOOP;
    
    -- Se nenhuma api foi encontrada liberada, deve retornar critica
    IF NOT vr_idservic THEN
      -- Retonar critica
      pr_dsmsgerr := 'Cooperado e Desenvolvedor n�o possuem acesso a APIs ativas.';
      
      -- Sair da rotina
      RETURN;
    END IF;
    
    -- Retornar o XML
    pr_lspermis := vr_dsxmlarq.getClobVal();
    
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20017,'Erro ao validar identifica��o: '||SQLERRM);
  END pc_check_identificacao;
  
  -- Retornar data da ultima altera��o do cadastro das APIs do desenvolvedor
  PROCEDURE pc_get_data_alteracao(pr_cdcooper     IN NUMBER
                                 ,pr_nrdconta     IN NUMBER
                                 ,pr_dsxmlret    OUT CLOB
                                 ,pr_dsmsgerr    OUT VARCHAR2)   IS 
    /* .............................................................................
      Programa: pc_get_data_alteracao
      Sistema : Aimaro
      Sigla   : APIS
      Autor   : Renato Darosci (Supero)
      Data    : Abril/2019.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Retornar a data da �ltima altera��o dos servi�os de API do cooperado

      Observacao: ------

      Alteracoes:
    ..............................................................................*/  
    
    -- Verificar se o cooperado existe
    CURSOR cr_crapass IS
      SELECT ass.dtdemiss
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rg_crapass   cr_crapass%ROWTYPE;
    
    -- Buscar a maior data de altera��o 
    CURSOR cr_dtaltera IS
      SELECT MAX(csr.dhultima_alteracao) dhultima_alteracao
        FROM tbapi_cooperado_servico csr
       WHERE csr.cdcooper = pr_cdcooper
         AND csr.nrdconta = pr_nrdconta;      
    
    -- Vari�veis
    vr_dsxmlarq     xmltype;
    vr_dtultalt     DATE;
    vr_dscritic     VARCHAR2(1000);
    
  BEGIN
    
    -- Monta a estrutura base para retorno
    vr_dsxmlarq := XMLTYPE.createXML('<?xml version="1.0" encoding="ISO-8859-1"?>'
                                   ||'<root>'
                                   ||'</root>');
  
    -- Buscar pelo cooperado
    OPEN  cr_crapass;
    FETCH cr_crapass INTO rg_crapass;
    
    -- Se n�o encontrar o cooperado
    IF cr_crapass%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapass;  
    
      -- Retornar mensagem informando que o cooperado n�o foi encontrado
      pr_dsmsgerr := 'Cooperado n�o encontrado.';
      
      -- Encerra o processo de valida��o
      RETURN;
    END IF;
    
    -- Buscar a data da �ltima altera��o de servi�os do cooperado
    OPEN  cr_dtaltera;
    FETCH cr_dtaltera INTO vr_dtultalt;
    CLOSE cr_dtaltera; 
    
    -- Se n�o foi encontrada nenhuma data, retorna a data atual
    IF vr_dtultalt IS NULL THEN
      vr_dtultalt := SYSDATE;
    END IF;
    
    -- Adicionar cada uma das APIs no xml de retorno
    GENE0007.pc_insere_tag(pr_xml      => vr_dsxmlarq
                          ,pr_tag_pai  => 'root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtaltera'
                          ,pr_tag_cont => to_char(vr_dtultalt,'dd/mm/yyyy hh24:mi:ss')
                          ,pr_des_erro => vr_dscritic);
      
    -- Se ocorrer erro
    IF vr_dscritic IS NOT NULL THEN
      raise_application_error(-20018,'Erro ao incluir tag no XML: '||vr_dscritic);
    END IF;  
      
    -- Retornar o XML gerado
    pr_dsxmlret := vr_dsxmlarq.getClobVal();
    
  EXCEPTION
    WHEN OTHERS THEN 
      raise_application_error(-20019,'Erro na rotina PC_GET_DATA_ALTERACAO: '||SQLERRM);
  END pc_get_data_alteracao;
  
END APIS0001;
/
