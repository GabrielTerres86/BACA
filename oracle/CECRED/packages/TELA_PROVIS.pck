CREATE OR REPLACE PACKAGE CECRED.TELA_PROVIS AS

  -- Efetua a consulta dos parametros da Provisão CL
  PROCEDURE pc_consulta_provisaocl(pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo
  
  -- Efetua a gravação dos parametros da Provisão CL
  PROCEDURE pc_grava_provisaocl(pr_vlriscoA   IN VARCHAR2             --> Valor do Risco A
                               ,pr_vlriscoB   IN VARCHAR2             --> Valor do Risco B
                               ,pr_vlriscoC   IN VARCHAR2             --> Valor do Risco C
                               ,pr_vlriscoD   IN VARCHAR2             --> Valor do Risco D
                               ,pr_vlriscoE   IN VARCHAR2             --> Valor do Risco E
                               ,pr_vlriscoF   IN VARCHAR2             --> Valor do Risco F
                               ,pr_vlriscoG   IN VARCHAR2             --> Valor do Risco G
                               ,pr_vlriscoH   IN VARCHAR2             --> Valor do Risco H
                               ,pr_vlriscAA   IN VARCHAR2             --> Valor do Risco AA
                               ,pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo
  

END TELA_PROVIS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PROVIS AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PROVIS
  --    Autor   : Renato Darosci / SUPERO
  --    Data    : Agosto/2016                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela PROVIS
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_gera_log_arquivo(pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_dslogtel  IN VARCHAR2
                               ,pr_dscritic OUT VARCHAR2) IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_log_arquivo                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Renato Darosci - Supero
    Data     : Agosto/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para gerar log da memória no arquivo
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
   
   BEGIN
     
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 -- Erro tratato
                               ,pr_nmarqlog     => 'provis.log'
                               ,pr_des_log      => rtrim(pr_dslogtel,chr(10)));
   EXCEPTION
    WHEN OTHERS THEN   
      pr_dscritic := 'Erro ao gravar LOG: '||SQLERRM;    
   END pc_gera_log_arquivo;  
  
  
  PROCEDURE pc_consulta_provisaocl(pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_consulta_provisaocl
      Sistema : AyllosWeb
      Autor   : Renato Darosci - Supero
      Data    : Agosto/2016.                  Ultima atualizacao: 29/08/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a consulta dos parametros da Provisão CL
      Observacao: -----

      Alteracoes: 

     ..............................................................................*/
     -- Cursores
     CURSOR cr_craptab(pr_cdcooper  craptab.cdcooper%TYPE) IS
       SELECT to_char(GENE0002.fn_char_para_number(SUBSTR(t.dstextab,0,6)),'FM990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') vlprovis   
            , TRIM(SUBSTR(t.dstextab,7,4))                          dsdrisco   
         FROM craptab t
        WHERE t.cdacesso = 'PROVISAOCL'
          AND t.cdempres = 0
          AND t.tptabela = 'GENERI'
          AND t.nmsistem = 'CRED'
          AND t.cdcooper = pr_cdcooper;

     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     
     -- Indicar registro
     vr_idregist         BOOLEAN;
     
     -- Excessões
     vr_exc_erro         EXCEPTION;

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
      -- inicializa
      vr_idregist := FALSE;
      
      -- Percorre os riscos
      FOR reg_provis IN cr_craptab(vr_cdcooper) LOOP

        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root'
                                           ,XMLTYPE('<risco_'||reg_provis.dsdrisco||'>'||reg_provis.vlprovis||'</risco_'||reg_provis.dsdrisco||'>'));

        -- Indica que encontrou registro
        vr_idregist := TRUE;
      END LOOP;
      
      -- Se não encontrou registro... deve retornar erro
      IF NOT vr_idregist THEN
        pr_dscritic := 'Nenhum parametro encontrado. Favor verificar!';
        RAISE vr_exc_erro;
      END IF;
          
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
       pr_dscritic := 'Erro na PC_CONSULTA_PROVISAOCL: '||SQLERRM;
       pr_des_erro := pr_dscritic;
     
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_consulta_provisaocl;


  PROCEDURE pc_grava_provisaocl(pr_vlriscoA   IN VARCHAR2             --> Valor do Risco A
                               ,pr_vlriscoB   IN VARCHAR2             --> Valor do Risco B
                               ,pr_vlriscoC   IN VARCHAR2             --> Valor do Risco C
                               ,pr_vlriscoD   IN VARCHAR2             --> Valor do Risco D
                               ,pr_vlriscoE   IN VARCHAR2             --> Valor do Risco E
                               ,pr_vlriscoF   IN VARCHAR2             --> Valor do Risco F
                               ,pr_vlriscoG   IN VARCHAR2  	         --> Valor do Risco G
                               ,pr_vlriscoH   IN VARCHAR2             --> Valor do Risco H
                               ,pr_vlriscAA   IN VARCHAR2             --> Valor do Risco AA
                               ,pr_xmllog     IN VARCHAR2             --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType   --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_consulta_provisaocl
      Sistema : AyllosWeb
      Autor   : Renato Darosci - Supero
      Data    : Agosto/2016.                  Ultima atualizacao: 29/08/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a gravação dos parametros da Provisão CL
      Observacao: -----

      Alteracoes: 

     ..............................................................................*/
     -- Cursores
     CURSOR cr_craptab(pr_cdcooper  craptab.cdcooper%TYPE) IS
       SELECT t.rowid  dsrowid
            , GENE0002.fn_char_para_number(SUBSTR(t.dstextab,0,6)) vlprovis   
            , TRIM(SUBSTR(t.dstextab,7,4))                         dsdrisco   
            , t.dstextab
         FROM craptab t
        WHERE t.cdacesso = 'PROVISAOCL'
          AND t.cdempres = 0
          AND t.tptabela = 'GENERI'
          AND t.nmsistem = 'CRED'
          AND t.cdcooper = pr_cdcooper;

     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     
     vr_vlrisco          NUMBER;
     vr_dslogtel         VARCHAR2(2000);
     
     -- Excessões
     vr_exc_erro         EXCEPTION;

   BEGIN

     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      -- Percorre os riscos
      FOR reg_provis IN cr_craptab(vr_cdcooper) LOOP

        -- Verifica o Risco encontrado
        CASE 
           WHEN reg_provis.dsdrisco = 'A' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoA);
           WHEN reg_provis.dsdrisco = 'B' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoB);
           WHEN reg_provis.dsdrisco = 'C' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoC);
           WHEN reg_provis.dsdrisco = 'D' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoD);
           WHEN reg_provis.dsdrisco = 'E' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoE);
           WHEN reg_provis.dsdrisco = 'F' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoF);
           WHEN reg_provis.dsdrisco = 'G' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoG);
           WHEN reg_provis.dsdrisco = 'H' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscoH);
           WHEN reg_provis.dsdrisco = 'AA' THEN 
              vr_vlrisco := GENE0002.fn_char_para_number(pr_vlriscAA);
           ELSE 
             pr_dscritic := 'Risco "'||reg_provis.dsdrisco||'" não está previsto. Favor verificar!';
             RAISE vr_exc_erro;
        END CASE;
        
        -- Se mudou o valor do risco
        IF vr_vlrisco <> reg_provis.vlprovis THEN
          
          BEGIN
            UPDATE craptab t
               SET t.dstextab = to_char(vr_vlrisco,'FM000D00')  ||
                                LPAD(reg_provis.dsdrisco,4,' ') ||
                                SUBSTR(reg_provis.dstextab,11)
             WHERE rowid = reg_provis.dsrowid;
              
            -- Montar a mensagem de log
            vr_dslogtel := to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                         || ' --> Operador '|| vr_cdoperad ||': '
                         || 'Risco '||reg_provis.dsdrisco
                         || ' alterado de [' || to_char(reg_provis.vlprovis,'FM990D00') ||']'
                         || ' para [' || to_char(vr_vlrisco,'FM990D00') ||'].';

            -- Gerar o Log da tela
            pc_gera_log_arquivo(vr_cdcooper
                               ,vr_dslogtel
                               ,pr_dscritic);
           
            -- Verificar ocorrencia de erro ao gerar log...
            IF pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
                   
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar Risco "'||reg_provis.dsdrisco||'": '||SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        END IF;
      END LOOP;
      
      -- Efetivar os dados 
      COMMIT;
      
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer as alterações
       ROLLBACK;  
     
       pr_des_erro := pr_dscritic;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
       -- Desfazer as alterações
       ROLLBACK;
       
       pr_dscritic := 'Erro na PC_GRAVA_PROVISAOCL: '||SQLERRM;
       pr_des_erro := pr_dscritic;
     
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_grava_provisaocl;

END TELA_PROVIS;
/
