CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS700_1(PR_CDCOOPER IN CRAPCOP.CDCOOPER%TYPE,
                                                PR_NRDCONTA IN CRAPCOP.NRDCONTA%TYPE,
                                                PR_CDAGESIC IN CRAPCOP.CDAGESIC%TYPE,
                                                PR_DTMVTOAN IN NUMBER -- YYYYMMDD
                                               ,
                                                PR_DTINIMES IN NUMBER -- YYYYMMDD
                                               ,
                                                PR_DTULTDIA IN NUMBER -- yyyymmdd
                                               ,
                                                PR_IDPARALE IN CRAPPAR.IDPARALE%TYPE --> Indicador de processo paralelo
                                               ,
                                                PR_CDCRITIC OUT CRAPCRI.CDCRITIC%TYPE --> Critica encontrada
                                               ,
                                                PR_DSCRITIC OUT VARCHAR2) IS
BEGIN
  /* .............................................................................
  
     Programa: pc_crps700_1
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Tiago Castro (RKAM)
     Data    : Janeiro/2016                     Ultima atualizacao: 99/99/99
  
     Dados referentes ao programa:
  
     Frequencia: Diário (JOB)
     Objetivo  : Popular a tabela de beneficiarios do INSS
  
     Alteracoes: 
  
  ............................................................................ */

  DECLARE
  
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
  
    -- Código do programa
    VR_CDPROGRA CONSTANT CRAPPRG.CDPROGRA%TYPE := 'CRPS700_1';
    -- Cursor genérico de calendário
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;
  
    -- Tratamento de erros
    VR_EXC_SAIDA  EXCEPTION;
    VR_EXC_FIMPRG EXCEPTION;
    VR_CDCRITIC PLS_INTEGER;
    VR_DSCRITIC VARCHAR2(4000);
  
    ------------------------------- CURSORES ---------------------------------
  
    -- verifica se ja existe o nro beneficio no mes corrente 
    CURSOR CR_TBINSS_DCB(PR_CDCOOPER IN TBINSS_DCB.CDCOOPER%TYPE,
                         PR_NRDCONTA IN TBINSS_DCB.NRDCONTA%TYPE,
                         PR_CDAGESIC IN TBINSS_DCB.CDAGENCIA_CONV%TYPE,
                         PR_NRRECBEN IN TBINSS_DCB.NRRECBEN%TYPE) IS
      SELECT TBINSS_DCB.ID_DCB, TBINSS_DCB.NRRECBEN
        FROM TBINSS_DCB
       WHERE TBINSS_DCB.CDCOOPER = PR_CDCOOPER
         AND TBINSS_DCB.NRDCONTA = PR_NRDCONTA
         AND TBINSS_DCB.DTCOMPET >= TO_DATE(PR_DTINIMES, 'yyyymmdd')
         AND TBINSS_DCB.DTCOMPET <= TO_DATE(PR_DTULTDIA, 'yyyymmdd')
         AND TBINSS_DCB.CDAGENCIA_CONV = PR_CDAGESIC
         AND TBINSS_DCB.NRRECBEN = PR_NRRECBEN;
    RW_TBINSS_DCB CR_TBINSS_DCB%ROWTYPE;
  
    -- verifica se conta ja existe lancamento da conta no dia.  
    CURSOR CR_TBINSS_DCB2(PR_CDCOOPER IN TBINSS_DCB.CDCOOPER%TYPE,
                          PR_NRDCONTA IN TBINSS_DCB.NRDCONTA%TYPE,
                          PR_DTCOMPET IN TBINSS_DCB.DTCOMPET%TYPE,
                          PR_CDAGESIC IN TBINSS_DCB.CDAGENCIA_CONV%TYPE) IS
      SELECT TBINSS_DCB.ID_DCB, TBINSS_DCB.NRRECBEN
        FROM TBINSS_DCB
       WHERE TBINSS_DCB.CDCOOPER = PR_CDCOOPER
         AND TBINSS_DCB.NRDCONTA = PR_NRDCONTA
         AND TBINSS_DCB.DTCOMPET = PR_DTCOMPET
         AND TBINSS_DCB.CDAGENCIA_CONV = PR_CDAGESIC;
    RW_TBINSS_DCB2 CR_TBINSS_DCB%ROWTYPE;
  
    -- Buscar cpf do beneficiario
    CURSOR CR_CRAPDBI(PR_NRRECBEN IN CRAPDBI.NRRECBEN%TYPE) IS
      SELECT DBI.NRCPFCGC
        FROM CRAPDBI DBI
       WHERE DBI.NRRECBEN = PR_NRRECBEN
         AND ROWNUM = 1;
    RW_CRAPDBI CR_CRAPDBI%ROWTYPE;
  
    -- Verificar se existe rubrica
    CURSOR CR_TBINSS_RUBRICA(PR_CDRUBRIC TBINSS_RUBRICA.CDRUBRIC%TYPE) IS
      SELECT 1 FROM TBINSS_RUBRICA RBC WHERE RBC.CDRUBRIC = PR_CDRUBRIC;
    RW_TBINSS_RUBRICA CR_TBINSS_RUBRICA%ROWTYPE;
  
    -- Trazer último lcm do beneficiario
    CURSOR CR_TBINSS_LANDCB(PR_IDDCB IN TBINSS_LANDCB.ID_DCB%TYPE) IS
      SELECT NVL(MAX(LDCB.NRSEQLAN), 0) NRSEQLAN
        FROM TBINSS_LANDCB LDCB
       WHERE LDCB.ID_DCB = PR_IDDCB;
    RW_TBINSS_LANDCB CR_TBINSS_LANDCB%ROWTYPE;
  
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
  
    ------------------------------- VARIAVEIS -------------------------------
  
    --Variaveis Locais
    VR_QTLINHA  INTEGER;
    VR_NMDIRETO VARCHAR2(1000);
    VR_NMARQLOG VARCHAR2(32767);
    VR_DSTIME   VARCHAR2(100);
    VR_MSGENVIO VARCHAR2(32767);
    VR_MSGRECEB VARCHAR2(32767);
    VR_MOVARQTO VARCHAR2(32767);
    VR_DES_RETO VARCHAR2(3);
    VR_DSTEXTO  VARCHAR2(32767);
    VR_NMPARAM  VARCHAR2(1000);
    VR_NRCPFCGC CRAPDBI.NRCPFCGC%TYPE;
    VR_DTDVENCI DATE;
  
    --Variaveis DOM
    VR_XML        XMLTYPE;
    VR_XMLDOC     XMLDOM.DOMDOCUMENT;
    VR_LISTA_NODO DBMS_XMLDOM.DOMNODELIST;
    VR_NODO       XMLDOM.DOMNODE;
    VR_XMLPARSER  DBMS_XMLPARSER.PARSER;
  
    --Tabelas de Memoria
    VR_TAB_RUBRICA INSS0001.TYP_TAB_RUBRICA;
    VR_TAB_DEMONST INSS0001.TYP_TAB_DEMONSTRATIVOS;
  
    --Indices para tabelas memoria
    VR_INDEX_DEMONST PLS_INTEGER;
    VR_INDEX_RUBRICA PLS_INTEGER;
  
    --------------------------- SUBROTINAS INTERNAS --------------------------
    PROCEDURE PC_BUSCA_PROVA_VIDA IS
      -- buscar a data de vencimento 
    
    BEGIN
      -- verifica se existe lancamento para a conta no dia
      OPEN CR_TBINSS_DCB2(PR_CDCOOPER => PR_CDCOOPER,
                          PR_NRDCONTA => PR_NRDCONTA,
                          PR_DTCOMPET => TO_DATE(PR_DTMVTOAN, 'yyyymmdd'),
                          PR_CDAGESIC => PR_CDAGESIC);
      FETCH CR_TBINSS_DCB2
        INTO RW_TBINSS_DCB2;
      IF CR_TBINSS_DCB2%FOUND AND RW_TBINSS_DCB2.NRRECBEN <> 0 THEN
      
        --Buscar o Horario
        VR_DSTIME := LPAD(GENE0002.FN_BUSCA_TIME, 5, '0');
      
        --Determinar Nomes do Arquivo de Envio
        VR_MSGENVIO := VR_NMDIRETO || '/arq/INSS.SOAP.ECONBEN' ||
                       TO_CHAR(TO_DATE(PR_DTMVTOAN, 'yyyymmdd'), 'DDMMYYYY') ||
                       VR_DSTIME || 'crps700_1';
      
        --Determinar Nome do Arquivo de Recebimento    
        VR_MSGRECEB := VR_NMDIRETO || '/arq/INSS.SOAP.RCONBEN' ||
                       TO_CHAR(TO_DATE(PR_DTMVTOAN, 'yyyymmdd'), 'DDMMYYYY') ||
                       PR_NRDCONTA || VR_DSTIME || 'crps700_1';
      
        --Determinar Nome Arquivo movido              
        VR_MOVARQTO := VR_NMDIRETO || '/salvar';
      
        /*Monta as tags de envio
        OBS.: O valor das tags deve respeitar a formatacao presente na
              base do SICREDI do contrario, a operacao nao sera realizada. */
      
        --Gerar cabecalho XML
        INSS0001.PC_GERA_CABECALHO_SOAP(PR_IDSERVIC => 1 /* idservic */,
                                        PR_NMMETODO => 'ben:InConsultarBeneficiarioINSS' --Nome Metodo
                                       ,
                                        PR_USERNAME => 'app_cecred_client' --Username
                                       ,
                                        PR_PASSWORD => 'Sicredi123' --Senha
                                       ,
                                        PR_DSTEXTO  => VR_DSTEXTO --Texto do Arquivo de Dados
                                       ,
                                        PR_DES_RETO => VR_DES_RETO --Retorno OK/NOK
                                       ,
                                        PR_DSCRITIC => VR_DSCRITIC); --Descricao da Critica
      
        --Se ocorreu erro
        IF VR_DES_RETO = 'NOK' THEN
          -- Gerar critica no log
          BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                     PR_IND_TIPO_LOG => 1,
                                     PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                'DD/MM/YYYY HH24:MI:SS') ||
                                                        ' - crps700 - Erro ao gerar cabecalho InConsultarBeneficiarioINSS. Conta: ' ||
                                                        PR_NRDCONTA ||
                                                        ' .Erro: ' ||
                                                        VR_DSCRITIC,
                                     PR_NMARQLOG     => 'log_crps700_PLL');
        
          CLOSE CR_TBINSS_DCB2;
          -- encerra paralelo
          RAISE VR_EXC_FIMPRG;
        END IF;
      
        --Montar o XML      
        VR_DSTEXTO := VR_DSTEXTO || '<ben:codBeneficiario>' ||
                      LPAD(RW_TBINSS_DCB2.NRRECBEN, 10, '0') ||
                      '</ben:codBeneficiario>';
      
        VR_DSTEXTO := VR_DSTEXTO || '</ben:InConsultarBeneficiarioINSS>' ||
                      '</soapenv:Body></soapenv:Envelope>';
      
        /* gene0002.pc_XML_para_arquivo(pr_XML => vr_dstexto
        , pr_caminho => '/microsd/cecred/tiagocastro/'
        , pr_arquivo => 'xml_ProvaVida.xml'
        , pr_des_erro => vr_dscritic);*/
        --Efetuar Requisicao Soap
        INSS0001.PC_EFETUA_REQUISICAO_SOAP(PR_CDCOOPER => PR_CDCOOPER --Codigo Cooperativa 
                                          ,
                                           PR_CDAGENCI => 1 --Codigo Agencia
                                          ,
                                           PR_NRDCAIXA => 100 --Numero Caixa
                                          ,
                                           PR_IDSERVIC => 1 --Identificador Servico
                                          ,
                                           PR_DSSERVIC => 'Consulta' --Descricao Servico
                                          ,
                                           PR_NMMETODO => 'OutConsultarBeneficiarioINSS' --Nome Método
                                          ,
                                           PR_DSTEXTO  => VR_DSTEXTO --Texto com a msg XML
                                          ,
                                           PR_MSGENVIO => VR_MSGENVIO --Mensagem Envio
                                          ,
                                           PR_MSGRECEB => VR_MSGRECEB --Mensagem Recebimento
                                          ,
                                           PR_MOVARQTO => VR_MOVARQTO --Nome Arquivo mover
                                          ,
                                           PR_NMARQLOG => VR_NMARQLOG --Nome Arquivo Log
                                          ,
                                           PR_NMDATELA => 'CRPS700' --Nome da Tela
                                          ,
                                           PR_DES_RETO => VR_DES_RETO --Saida OK/NOK
                                          ,
                                           PR_DSCRITIC => VR_DSCRITIC); --Descrição Erros
      
        --Se ocorreu erro
        IF VR_DES_RETO = 'NOK' THEN
          -- Gerar critica no log
          BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                     PR_IND_TIPO_LOG => 1,
                                     PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                'DD/MM/YYYY HH24:MI:SS') ||
                                                        ' - crps700 - Erro ao efetuar requisicao soap InConsultarBeneficiarioINSS. Conta: ' ||
                                                        PR_NRDCONTA ||
                                                        ' .Erro: ' ||
                                                        VR_DSCRITIC,
                                     PR_NMARQLOG     => 'log_crps700_PLL');
        
          CLOSE CR_TBINSS_DCB2;
          -- encerra paralelo
          RAISE VR_EXC_FIMPRG;
        END IF;
      
        --Verifica Falha no Pacote
        INSS0001.PC_OBTEM_FAULT_PACKET(PR_CDCOOPER => PR_CDCOOPER --Codigo Cooperativa 
                                      ,
                                       PR_NMDATELA => 'CRPS700' --Nome da Tela
                                      ,
                                       PR_CDAGENCI => 1 --Codigo Agencia
                                      ,
                                       PR_NRDCAIXA => 100 --Numero Caixa
                                      ,
                                       PR_DSDERROR => '0000' --Descricao Servico
                                      ,
                                       PR_MSGENVIO => VR_MSGENVIO --Mensagem Envio
                                      ,
                                       PR_MSGRECEB => VR_MSGRECEB --Mensagem Recebimento
                                      ,
                                       PR_MOVARQTO => VR_MOVARQTO --Nome Arquivo mover
                                      ,
                                       PR_NMARQLOG => VR_NMARQLOG --Nome Arquivo log
                                      ,
                                       PR_DES_RETO => VR_DES_RETO --Saida OK/NOK
                                      ,
                                       PR_DSCRITIC => VR_DSCRITIC); --Mensagem Erro
      
        --Se ocorreu erro
        IF VR_DES_RETO <> 'OK' THEN
        
          -- Gerar critica no log
          BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                     PR_IND_TIPO_LOG => 1,
                                     PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                'DD/MM/YYYY HH24:MI:SS') ||
                                                        ' - crps700 - Erro InConsultarBeneficiarioINSS. Conta: ' ||
                                                        PR_NRDCONTA ||
                                                        ' .Erro: ' ||
                                                        VR_DSCRITIC,
                                     PR_NMARQLOG     => 'log_crps700_PLL');
        
          CLOSE CR_TBINSS_DCB2;
          -- encerra paralelo
          RAISE VR_EXC_FIMPRG;
        ELSE
          /** Valida SOAP retornado pelo WebService **/
          GENE0002.PC_ARQUIVO_PARA_XML(PR_NMARQUIV => VR_MSGRECEB --> Nome do caminho completo) 
                                      ,
                                       PR_XMLTYPE  => VR_XML --> Saida para o XML
                                      ,
                                       PR_DES_RETO => VR_DES_RETO --> Descrição OK/NOK
                                      ,
                                       PR_DSCRITIC => VR_DSCRITIC --> Descricao Erro 
                                      ,
                                       PR_TIPMODO  => 2);
        
          --Se Ocorreu erro
          IF VR_DES_RETO = 'NOK' THEN
          
            -- Gerar critica no log
            BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                       PR_IND_TIPO_LOG => 1,
                                       PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                  'DD/MM/YYYY HH24:MI:SS') ||
                                                          ' - crps700 - Erro ao converter arquivo para xml. Conta: ' ||
                                                          PR_NRDCONTA ||
                                                          ' .Erro: ' ||
                                                          VR_DSCRITIC,
                                       PR_NMARQLOG     => 'log_crps700_PLL');
          
            CLOSE CR_TBINSS_DCB2;
            -- encerra paralelo
            RAISE VR_EXC_FIMPRG;
          END IF;
        
          /* Precisamos instanciar o Parser e efetuar a conversão do XML local para o XMLDOm usando UTF-8
          pois o SICREDI, esta nos enviando informações com acentuação em outro tipo de enconding*/
          VR_XMLPARSER := DBMS_XMLPARSER.NEWPARSER;
          DBMS_XMLPARSER.PARSE(VR_XMLPARSER,
                               VR_MSGRECEB,
                               NLS_CHARSET_ID('UTF8'));
          VR_XMLDOC := DBMS_XMLPARSER.GETDOCUMENT(VR_XMLPARSER);
          DBMS_XMLPARSER.FREEPARSER(VR_XMLPARSER);
        
          --Lista de nodos
          VR_LISTA_NODO := XMLDOM.GETELEMENTSBYTAGNAME(VR_XMLDOC,
                                                       'Beneficiario');
        
          --Se nao encontrou nenhum nodo 
          IF DBMS_XMLDOM.GETLENGTH(VR_LISTA_NODO) = 0 THEN
          
            --Monta mensagem de critica
            VR_DSCRITIC := 'Beneficiario nao encontrado.';
          
            -- Gerar critica no log
            BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                       PR_IND_TIPO_LOG => 1,
                                       PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                  'DD/MM/YYYY HH24:MI:SS') ||
                                                          ' - crps700 - Erro. Conta: ' ||
                                                          PR_NRDCONTA ||
                                                          ' Coop: ' ||
                                                          PR_CDCOOPER ||
                                                          ' .Erro: ' ||
                                                          VR_DSCRITIC,
                                       PR_NMARQLOG     => 'log_crps700_PLL');
          
            CLOSE CR_TBINSS_DCB2;
            -- encerra paralelo
            RAISE VR_EXC_FIMPRG;
          END IF;
        
          --Arquivo OK, percorrer as tags
        
          --Lista de nodos
          VR_LISTA_NODO := XMLDOM.GETELEMENTSBYTAGNAME(VR_XMLDOC, '*');
        
          --Quantidade tags no XML
          VR_QTLINHA := XMLDOM.GETLENGTH(VR_LISTA_NODO);
        
          /* Para cada um dos filhos do DadosDemonstrativo */
          FOR VR_LINHA IN 1 .. (VR_QTLINHA - 1) LOOP
          
            --Buscar Nodo Corrente
            VR_NODO := XMLDOM.ITEM(VR_LISTA_NODO, VR_LINHA);
          
            --Nome Parametro Nodo corrente
            VR_NMPARAM := XMLDOM.GETNODENAME(VR_NODO);
          
            --Buscar somente sufixo (o que tem apos o caracter :)
            VR_NMPARAM := SUBSTR(VR_NMPARAM, INSTR(VR_NMPARAM, ':') + 1);
          
            --Tratar parametros que possuem dados  
            IF VR_NMPARAM = 'DataVencimento' THEN
            
              VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
            
              --Se possui informacao
              IF INSTR(XMLDOM.GETNODEVALUE(VR_NODO), '4713') = 0 THEN
                --Data Vencimento Prova Vida
                VR_DTDVENCI := TO_DATE(XMLDOM.GETNODEVALUE(VR_NODO),
                                       'YYYY-MM-DD-HH24:MI');
              END IF;
            
            END IF;
          
          END LOOP; --vr_linha IN 1..(vr_qtlinha-1)            
        
          --Se nao Encontrou nada na temp-table
          IF VR_DTDVENCI IS NULL THEN
          
            --Monta mensagem de critica
            VR_DSCRITIC := 'Beneficiario nao encontrado.';
          
            -- Gerar critica no log
            BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                       PR_IND_TIPO_LOG => 1,
                                       PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                  'DD/MM/YYYY HH24:MI:SS') ||
                                                          ' - crps700 - Erro. Conta: ' ||
                                                          PR_NRDCONTA ||
                                                          ' Coop: ' ||
                                                          PR_CDCOOPER ||
                                                          ' .Erro: ' ||
                                                          VR_DSCRITIC,
                                       PR_NMARQLOG     => 'log_crps700_PLL');
          
            CLOSE CR_TBINSS_DCB2;
            -- encerra paralelo
            RAISE VR_EXC_FIMPRG;
          END IF;
        
          -- atualiza informacoes da conta/beneficio com a data de vencimento(prova de vida)
          BEGIN
            UPDATE TBINSS_DCB DCB
               SET DCB.DTVENCPV = VR_DTDVENCI
             WHERE DCB.NRRECBEN = RW_TBINSS_DCB2.NRRECBEN;
            --dcb.id_dcb = rw_tbinss_dcb2.id_dcb;               
          EXCEPTION
            WHEN OTHERS THEN
              VR_DSCRITIC := 'Erro ao atualizar na tbinss_dcb. Erro: ' ||
                             SQLERRM;
              RAISE VR_EXC_SAIDA;
          END;
        END IF;
      
      END IF;
      CLOSE CR_TBINSS_DCB2;
    
      --Remove o arquivo XML fisico de envio
      GENE0001.PC_OSCOMMAND(PR_TYP_COMANDO => 'S',
                            PR_DES_COMANDO => 'rm ' || VR_MSGENVIO ||
                                              ' 2> /dev/null',
                            PR_TYP_SAIDA   => VR_DES_RETO,
                            PR_DES_SAIDA   => VR_DSCRITIC);
      --Se ocorreu erro dar RAISE
      IF VR_DES_RETO = 'ERR' THEN
        RAISE VR_EXC_SAIDA;
      END IF;
    
      --Remove o arquivo XML fisico de recebimento
      GENE0001.PC_OSCOMMAND(PR_TYP_COMANDO => 'S',
                            PR_DES_COMANDO => 'rm ' || VR_MSGRECEB ||
                                              ' 2> /dev/null',
                            PR_TYP_SAIDA   => VR_DES_RETO,
                            PR_DES_SAIDA   => VR_DSCRITIC);
      --Se ocorreu erro dar RAISE
      IF VR_DES_RETO = 'ERR' THEN
        RAISE VR_EXC_SAIDA;
      END IF;
    
    END PC_BUSCA_PROVA_VIDA;
  
    --------------- VALIDACOES INICIAIS -----------------
  BEGIN
    -- Gerar hora inicio no log
    BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                               PR_IND_TIPO_LOG => 1,
                               PR_DES_LOG      => 'Inicio: ' || PR_CDCOOPER || '_' ||
                                                  PR_NRDCONTA || '_' ||
                                                  PR_CDAGESIC || '_' ||
                                                  PR_DTMVTOAN || '_' ||
                                                  PR_IDPARALE,
                               PR_NMARQLOG     => 'log_crps700_PLL');
  
    -- Incluir nome do módulo logado
    GENE0001.PC_INFORMA_ACESSO(PR_MODULE => 'PC_' || VR_CDPROGRA,
                               PR_ACTION => NULL);
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
    --Buscar Diretorio Padrao da Cooperativa
    VR_NMDIRETO := GENE0001.FN_DIRETORIO(PR_TPDIRETO => 'C' --> Usr/Coop
                                        ,
                                         PR_CDCOOPER => PR_CDCOOPER,
                                         PR_NMSUBDIR => NULL);
  
    --Determinar Nomes do Arquivo de Log
    VR_NMARQLOG := 'SICREDI_Soap_LogErros';
  
    --Buscar o Horario
    VR_DSTIME := LPAD(GENE0002.FN_BUSCA_TIME, 5, '0');
  
    --Determinar Nomes do Arquivo de Envio
    VR_MSGENVIO := VR_NMDIRETO || '/arq/INSS.SOAP.ECONBEN' ||
                   TO_CHAR(TO_DATE(PR_DTMVTOAN, 'yyyymmdd'), 'DDMMYYYY') ||
                   PR_NRDCONTA || VR_DSTIME || 'crps700_1';
  
    --Determinar Nome do Arquivo de Recebimento    
    VR_MSGRECEB := VR_NMDIRETO || '/arq/INSS.SOAP.RCONBEN' ||
                   TO_CHAR(TO_DATE(PR_DTMVTOAN, 'yyyymmdd'), 'DDMMYYYY') ||
                   PR_NRDCONTA || VR_DSTIME || 'crps700_1';
  
    --Determinar Nome Arquivo movido              
    VR_MOVARQTO := VR_NMDIRETO || '/salvar';
  
    /*Monta as tags de envio
    OBS.: O valor das tags deve respeitar a formatacao presente na
          base do SICREDI do contrario, a operacao nao sera realizada. */
  
    --Gerar cabecalho XML
    INSS0001.PC_GERA_CABECALHO_SOAP(PR_IDSERVIC => 1 /* idservic */,
                                    PR_NMMETODO => 'ben:InConsultarDemonstrativoINSS' --Nome Metodo
                                   ,
                                    PR_USERNAME => 'app_cecred_client' --Username
                                   ,
                                    PR_PASSWORD => 'Sicredi123' --Senha
                                   ,
                                    PR_DSTEXTO  => VR_DSTEXTO --Texto do Arquivo de Dados
                                   ,
                                    PR_DES_RETO => VR_DES_RETO --Retorno OK/NOK
                                   ,
                                    PR_DSCRITIC => VR_DSCRITIC); --Descricao da Critica
  
    --Se ocorreu erro
    IF VR_DES_RETO = 'NOK' THEN
      -- Gerar critica no log
      BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                 PR_IND_TIPO_LOG => 1,
                                 PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                            'DD/MM/YYYY HH24:MI:SS') ||
                                                    ' - crps700 - Erro ao gerar cabecalho. Conta: ' ||
                                                    PR_NRDCONTA ||
                                                    ' .Erro: ' ||
                                                    VR_DSCRITIC,
                                 PR_NMARQLOG     => 'log_crps700_PLL');
      -- encerra paralelo
      RAISE VR_EXC_FIMPRG;
    END IF;
  
    --Montar o XML      
    VR_DSTEXTO := VR_DSTEXTO || '<ben:dadosContaCorrente>' ||
                  '<ben:numAgencia>' || PR_CDAGESIC || '</ben:numAgencia>' ||
                  '<ben:contaCorrente>' || LPAD(PR_NRDCONTA, 10, '0') ||
                  '</ben:contaCorrente>' || '<ben:dataInicialValidade>' ||
                  TO_CHAR(TO_DATE(PR_DTINIMES, 'yyyymmdd'), 'rrrr-mm-dd') ||
                  'T00:00:00</ben:dataInicialValidade>' ||
                  '<ben:dataFinalValidade>' ||
                  TO_CHAR(TO_DATE(PR_DTULTDIA, 'yyyymmdd'), 'rrrr-mm-dd') ||
                  'T24:00:00</ben:dataFinalValidade>' ||
                  '</ben:dadosContaCorrente>';
  
    VR_DSTEXTO := VR_DSTEXTO || '</ben:InConsultarDemonstrativoINSS>' ||
                  '</soapenv:Body></soapenv:Envelope>';
  
    --Efetuar Requisicao Soap
    INSS0001.PC_EFETUA_REQUISICAO_SOAP(PR_CDCOOPER => PR_CDCOOPER --Codigo Cooperativa 
                                      ,
                                       PR_CDAGENCI => 1 --Codigo Agencia
                                      ,
                                       PR_NRDCAIXA => 100 --Numero Caixa
                                      ,
                                       PR_IDSERVIC => 4 --Identificador Servico
                                      ,
                                       PR_DSSERVIC => 'Consulta' --Descricao Servico
                                      ,
                                       PR_NMMETODO => 'OutConsultarDemonstrativoINSS' --Nome Método
                                      ,
                                       PR_DSTEXTO  => VR_DSTEXTO --Texto com a msg XML
                                      ,
                                       PR_MSGENVIO => VR_MSGENVIO --Mensagem Envio
                                      ,
                                       PR_MSGRECEB => VR_MSGRECEB --Mensagem Recebimento
                                      ,
                                       PR_MOVARQTO => VR_MOVARQTO --Nome Arquivo mover
                                      ,
                                       PR_NMARQLOG => VR_NMARQLOG --Nome Arquivo Log
                                      ,
                                       PR_NMDATELA => 'CRPS700' --Nome da Tela
                                      ,
                                       PR_DES_RETO => VR_DES_RETO --Saida OK/NOK
                                      ,
                                       PR_DSCRITIC => VR_DSCRITIC); --Descrição Erros
    --Se ocorreu erro
    IF VR_DES_RETO = 'NOK' THEN
      -- Gerar critica no log
      BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                 PR_IND_TIPO_LOG => 1,
                                 PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                            'DD/MM/YYYY HH24:MI:SS') ||
                                                    ' - crps700 - Erro ao efetuar requisicao. Conta: ' ||
                                                    PR_NRDCONTA ||
                                                    ' .Erro: ' ||
                                                    VR_DSCRITIC,
                                 PR_NMARQLOG     => 'log_crps700_PLL');
    
      -- encerra paralelo
      RAISE VR_EXC_FIMPRG;
    END IF;
  
    --Verifica Falha no Pacote
    INSS0001.PC_OBTEM_FAULT_PACKET(PR_CDCOOPER => PR_CDCOOPER --Codigo Cooperativa 
                                  ,
                                   PR_NMDATELA => 'CRPS700' --Nome da Tela
                                  ,
                                   PR_CDAGENCI => 1 --Codigo Agencia
                                  ,
                                   PR_NRDCAIXA => 100 --Numero Caixa
                                  ,
                                   PR_DSDERROR => 'SOAP-ENV:-950' --Descricao Servico
                                  ,
                                   PR_MSGENVIO => VR_MSGENVIO --Mensagem Envio
                                  ,
                                   PR_MSGRECEB => VR_MSGRECEB --Mensagem Recebimento
                                  ,
                                   PR_MOVARQTO => VR_MOVARQTO --Nome Arquivo mover
                                  ,
                                   PR_NMARQLOG => VR_NMARQLOG --Nome Arquivo log
                                  ,
                                   PR_DES_RETO => VR_DES_RETO --Saida OK/NOK
                                  ,
                                   PR_DSCRITIC => VR_DSCRITIC); --Mensagem Erro
  
    --Se ocorreu erro
    IF VR_DES_RETO <> 'OK' THEN
      -- Gerar critica no log
      BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                 PR_IND_TIPO_LOG => 1,
                                 PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                            'DD/MM/YYYY HH24:MI:SS') ||
                                                    ' - crps700 - Erro. Conta: ' ||
                                                    PR_NRDCONTA ||
                                                    ' .Erro: ' ||
                                                    VR_DSCRITIC,
                                 PR_NMARQLOG     => 'log_crps700_PLL');
    
      -- encerra paralelo
      RAISE VR_EXC_FIMPRG;
    ELSE
      /** Valida SOAP retornado pelo WebService **/
      GENE0002.PC_ARQUIVO_PARA_XML(PR_NMARQUIV => VR_MSGRECEB --> Nome do caminho completo) 
                                  ,
                                   PR_XMLTYPE  => VR_XML --> Saida para o XML
                                  ,
                                   PR_DES_RETO => VR_DES_RETO --> Descrição OK/NOK
                                  ,
                                   PR_DSCRITIC => VR_DSCRITIC --> Descricao Erro 
                                  ,
                                   PR_TIPMODO  => 2);
    
      --Se Ocorreu erro
      IF VR_DES_RETO = 'NOK' THEN
        -- Gerar critica no log
        BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                   PR_IND_TIPO_LOG => 1,
                                   PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                              'DD/MM/YYYY HH24:MI:SS') ||
                                                      ' - crps700 - Erro conversao do arquivo para xml. Conta: ' ||
                                                      PR_NRDCONTA ||
                                                      ' .Erro: ' ||
                                                      VR_DSCRITIC,
                                   PR_NMARQLOG     => 'log_crps700_PLL');
      
        -- encerra paralelo
        RAISE VR_EXC_FIMPRG;
      END IF;
    
      --Realizar o Parse do Arquivo XML
      VR_XMLDOC := XMLDOM.NEWDOMDOCUMENT(VR_XML);
    
      --Verificar se existe tag "Demonstrativos"
      VR_LISTA_NODO := XMLDOM.GETELEMENTSBYTAGNAME(VR_XMLDOC,
                                                   'Demonstrativos');
    
      --Se nao encontrou nenhum nodo 
      IF DBMS_XMLDOM.GETLENGTH(VR_LISTA_NODO) = 0 THEN
      
        --Monta mensagem de critica
        VR_DSCRITIC := 'Demonstrativo nao encontrado.';
      
        -- Gerar critica no log
        BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                   PR_IND_TIPO_LOG => 1,
                                   PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                              'DD/MM/YYYY HH24:MI:SS') ||
                                                      ' - crps700 - Erro. Conta: ' ||
                                                      PR_NRDCONTA ||
                                                      ' Coop: ' ||
                                                      PR_CDCOOPER ||
                                                      ' .Erro: ' ||
                                                      VR_DSCRITIC,
                                   PR_NMARQLOG     => 'log_crps700_PLL');
      
        -- encerra paralelo
        RAISE VR_EXC_FIMPRG;
      
      END IF;
    
      --Arquivo OK, percorrer as tags
    
      --Lista de nodos
      VR_LISTA_NODO := XMLDOM.GETELEMENTSBYTAGNAME(VR_XMLDOC, '*');
    
      --Quantidade tags no XML
      VR_QTLINHA := XMLDOM.GETLENGTH(VR_LISTA_NODO);
    
      -- limpa temp table para proximo demonstrativo
      VR_INDEX_DEMONST := 0;
      VR_INDEX_RUBRICA := 0;
      VR_TAB_DEMONST.DELETE;
      VR_TAB_RUBRICA.DELETE;
    
      /* Para cada um dos filhos do DadosDemonstrativo */
      FOR VR_LINHA IN 1 .. (VR_QTLINHA - 1) LOOP
      
        --Buscar Nodo Corrente
        VR_NODO := XMLDOM.ITEM(VR_LISTA_NODO, VR_LINHA);
      
        --Nome Parametro Nodo corrente
        VR_NMPARAM := XMLDOM.GETNODENAME(VR_NODO);
      
        --Buscar somente sufixo (o que tem apos o caracter :)
        VR_NMPARAM := SUBSTR(VR_NMPARAM, INSTR(VR_NMPARAM, ':') + 1);
      
        --Tratar parametros que possuem dados  
        CASE VR_NMPARAM
        
          WHEN 'DadosDemonstrativo' THEN
          
            --Incrementar Contador
            VR_INDEX_DEMONST := VR_TAB_DEMONST.COUNT + 1;
          
            --Incrementar Contador
            VR_INDEX_RUBRICA := VR_TAB_RUBRICA.COUNT + 1;
          
          WHEN 'cnpjEmissor' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --CNPJ Emissor
            VR_TAB_DEMONST(VR_INDEX_DEMONST).CNPJEMIS := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'nomeEmissor' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Nome Emissor
            VR_TAB_DEMONST(VR_INDEX_DEMONST).NOMEEMIS := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'orgaoPagador' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Orgao Pagador
            VR_TAB_DEMONST(VR_INDEX_DEMONST).CDORGINS := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'numeroBeneficio' THEN
          
            --Buscar o Nodo        
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Numero beneficio
            VR_TAB_DEMONST(VR_INDEX_DEMONST).NRBENEFI := XMLDOM.GETNODEVALUE(VR_NODO);
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).NRBENEFI := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'numeroNit' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --NIT
            VR_TAB_DEMONST(VR_INDEX_DEMONST).NRRECBEN := XMLDOM.GETNODEVALUE(VR_NODO);
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).NRRECBEN := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'competencia' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Data Competencia
            VR_TAB_DEMONST(VR_INDEX_DEMONST).DTDCOMPE := SUBSTR(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                5,
                                                                2) || '/' ||
                                                         SUBSTR(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                1,
                                                                4);
          
          WHEN 'nomeBeneficiario' THEN
          
            --Buscar o Nodo     
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Nome beneficiario
            VR_TAB_DEMONST(VR_INDEX_DEMONST).NMBENEFI := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'dataInicialPeriodo' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            IF INSTR(XMLDOM.GETNODEVALUE(VR_NODO), '4713') = 0 THEN
              --Data Inicio Periodo
              VR_TAB_DEMONST(VR_INDEX_DEMONST).DTINIPRD := TO_DATE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                   'YYYY-MM-DD-HH24:MI');
            END IF;
          
          WHEN 'dataFinalPeriodo' THEN
          
            --Buscar o Nodo                
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            IF INSTR(XMLDOM.GETNODEVALUE(VR_NODO), '4713') = 0 THEN
              --Data Final Periodo
              VR_TAB_DEMONST(VR_INDEX_DEMONST).DTFINPRD := TO_DATE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                   'YYYY-MM-DD-HH24:MI');
            END IF;
          
          WHEN 'vlrBruto' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Valor Bruto
            VR_TAB_DEMONST(VR_INDEX_DEMONST).VLRBRUTO := REPLACE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                 '.',
                                                                 ',');
          
          WHEN 'vlrDesconto' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Valor Desconto                  
            VR_TAB_DEMONST(VR_INDEX_DEMONST).VLDESCTO := REPLACE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                 '.',
                                                                 ',');
          
          WHEN 'vlrLiquido' THEN
          
            --Buscar o Nodo   
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Valor Liquido                  
            VR_TAB_DEMONST(VR_INDEX_DEMONST).VLLIQUID := REPLACE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                 '.',
                                                                 ',');
          
          WHEN 'codRubrica' THEN
          
            --Buscar o Nodo   
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Codigo Rubrica
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).CDRUBRIC := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'nomeRubrica' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Nome Rubrica
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).NMRUBRIC := XMLDOM.GETNODEVALUE(VR_NODO);
          
          WHEN 'valorRubrica' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Valor Rubrica
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).VLRUBRIC := REPLACE(XMLDOM.GETNODEVALUE(VR_NODO),
                                                                 '.',
                                                                 ',');
          
          WHEN 'tpoNatureza' THEN
          
            --Buscar o Nodo  
            VR_NODO := XMLDOM.GETFIRSTCHILD(VR_NODO);
          
            --Tipo Natureza
            VR_TAB_RUBRICA(VR_INDEX_RUBRICA).TPNATURE := XMLDOM.GETNODEVALUE(VR_NODO);
          
          ELSE
            NULL;
          
        END CASE;
      
      END LOOP; --vr_linha IN 1..(vr_qtlinha-1)            
    
      --Se nao Encontrou nada na temp-table
      IF VR_TAB_DEMONST.COUNT = 0 THEN
      
        --Monta mensagem de critica
        VR_DSCRITIC := 'Demonstrativo nao encontrado.';
      
        -- Gerar critica no log
        BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                   PR_IND_TIPO_LOG => 1,
                                   PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                              'DD/MM/YYYY HH24:MI:SS') ||
                                                      ' - crps700 - Erro. Conta: ' ||
                                                      PR_NRDCONTA ||
                                                      ' Coop: ' ||
                                                      PR_CDCOOPER ||
                                                      ' .Erro: ' ||
                                                      VR_DSCRITIC,
                                   PR_NMARQLOG     => 'log_crps700_PLL');
      
        -- encerra paralelo
        RAISE VR_EXC_FIMPRG;
      
      END IF;
      -- busca primeiro registro quando houver demonstrativos
      VR_INDEX_DEMONST := VR_TAB_DEMONST.FIRST;
      -- Verifica se existem demonstrativos.
      IF VR_TAB_DEMONST.EXISTS(VR_INDEX_DEMONST) THEN
        -- varre demonstrativos encontrados para possivel insercao ou atualizacao
        WHILE VR_INDEX_DEMONST IS NOT NULL LOOP
          -- busca cpf do beneficiario
          OPEN CR_CRAPDBI(PR_NRRECBEN => VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                         .NRBENEFI);
          FETCH CR_CRAPDBI
            INTO RW_CRAPDBI;
          CLOSE CR_CRAPDBI;
          -- verifica se nro beneficio ja foi inserido no mes corrente
          OPEN CR_TBINSS_DCB(PR_CDCOOPER => PR_CDCOOPER,
                             PR_NRDCONTA => PR_NRDCONTA,
                             PR_CDAGESIC => PR_CDAGESIC,
                             PR_NRRECBEN => VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                            .NRBENEFI);
          FETCH CR_TBINSS_DCB
            INTO RW_TBINSS_DCB;
          IF CR_TBINSS_DCB%NOTFOUND THEN
            -- insere caso beneficio ainda nao exista no mes
            BEGIN
              -- Cria
              INSERT INTO TBINSS_DCB
                (ID_DCB,
                 DTCOMPET,
                 CDCOOPER,
                 NRDCONTA,
                 CDAGENCIA_CONV,
                 NMEMISSOR,
                 NRCNPJ_EMISSOR,
                 NMBENEFI,
                 NRRECBEN,
                 NRNITINS,
                 CDORGINS,
                 VLBRUTO,
                 VLDESCONTO,
                 VLLIQUIDO,
                 NRCPF_BENEFI)
              VALUES
                (FN_SEQUENCE('TBINSS_DCB', 'ID_DCB', 'ID_DCB'),
                 TO_DATE(PR_DTMVTOAN, 'yyyymmdd'),
                 PR_CDCOOPER,
                 PR_NRDCONTA,
                 PR_CDAGESIC,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).NOMEEMIS,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).CNPJEMIS,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).NMBENEFI,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).NRBENEFI,
                 0,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).CDORGINS,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).VLRBRUTO,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).VLDESCTO,
                 VR_TAB_DEMONST(VR_INDEX_DEMONST).VLLIQUID,
                 NVL(RW_CRAPDBI.NRCPFCGC, 0))
              RETURNING ID_DCB INTO RW_TBINSS_DCB.ID_DCB;
            EXCEPTION
              WHEN OTHERS THEN
                VR_DSCRITIC := 'Erro ao inserir na tbinss_dcb. Erro: ' ||
                               SQLERRM;
                RAISE VR_EXC_SAIDA;
            END;
          ELSE
            -- atualiza caso o beneficio ja exista no mes
            BEGIN
              UPDATE TBINSS_DCB DCB
                 SET DCB.NMEMISSOR      = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .NOMEEMIS,
                     DCB.NRCNPJ_EMISSOR = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .CNPJEMIS,
                     DCB.NMBENEFI       = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .NMBENEFI,
                     DCB.NRRECBEN       = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .NRBENEFI,
                     DCB.NRNITINS       = 0,
                     DCB.CDORGINS       = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .CDORGINS,
                     DCB.VLBRUTO        = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .VLRBRUTO,
                     DCB.VLDESCONTO     = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .VLDESCTO,
                     DCB.VLLIQUIDO      = VR_TAB_DEMONST(VR_INDEX_DEMONST)
                                          .VLLIQUID,
                     DCB.NRCPF_BENEFI   = VR_NRCPFCGC
               WHERE DCB.ID_DCB = RW_TBINSS_DCB.ID_DCB;
            EXCEPTION
              WHEN OTHERS THEN
                VR_DSCRITIC := 'Erro ao atualizar na tbinss_dcb. Erro: ' ||
                               SQLERRM;
                RAISE VR_EXC_SAIDA;
            END;
          END IF;
        
          --Se nao Encontrou nada na temp-table
          IF VR_TAB_RUBRICA.COUNT = 0 THEN
          
            --Monta mensagem de critica
            VR_DSCRITIC := 'Rubrica nao encontrada.';
          
            -- Gerar critica no log
            BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                       PR_IND_TIPO_LOG => 1,
                                       PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                                  'DD/MM/YYYY HH24:MI:SS') ||
                                                          ' - crps700 - Erro. Conta: ' ||
                                                          PR_NRDCONTA ||
                                                          ' Coop: ' ||
                                                          PR_CDCOOPER ||
                                                          ' .Erro: ' ||
                                                          VR_DSCRITIC,
                                       PR_NMARQLOG     => 'log_crps700_PLL');
          
            CLOSE CR_TBINSS_DCB;
            -- encerra paralelo
            RAISE VR_EXC_FIMPRG;
          END IF;
          IF VR_TAB_RUBRICA.EXISTS(VR_INDEX_DEMONST) THEN
            -- Procura se rubrica já está cadastrada
            OPEN CR_TBINSS_RUBRICA(PR_CDRUBRIC => VR_TAB_RUBRICA(VR_INDEX_DEMONST)
                                                  .CDRUBRIC);
            FETCH CR_TBINSS_RUBRICA
              INTO RW_TBINSS_RUBRICA;
          
            -- Se não está cadastrada cria
            IF CR_TBINSS_RUBRICA%NOTFOUND THEN
              BEGIN
                INSERT INTO TBINSS_RUBRICA
                  (CDRUBRIC, DSRUBRIC, DSNATUREZA)
                VALUES
                  (VR_TAB_RUBRICA(VR_INDEX_DEMONST).CDRUBRIC,
                   VR_TAB_RUBRICA(VR_INDEX_DEMONST).NMRUBRIC,
                   VR_TAB_RUBRICA(VR_INDEX_DEMONST).TPNATURE);
              EXCEPTION
                WHEN OTHERS THEN
                  VR_DSCRITIC := 'Erro ao inserir na tbinss_rubrica. Erro: ' ||
                                 SQLERRM;
                  RAISE VR_EXC_SAIDA;
              END;
            END IF;
            CLOSE CR_TBINSS_RUBRICA;
          
            -- Verifica se já possui algum lançamento
            OPEN CR_TBINSS_LANDCB(PR_IDDCB => RW_TBINSS_DCB.ID_DCB);
            FETCH CR_TBINSS_LANDCB
              INTO RW_TBINSS_LANDCB;
            CLOSE CR_TBINSS_LANDCB;
            -- Quando a Natureza for Debito, grava na tabela o valor negativo.
            IF VR_TAB_RUBRICA(VR_INDEX_DEMONST).TPNATURE = 'DEBITO' THEN
              VR_TAB_RUBRICA(VR_INDEX_DEMONST).VLRUBRIC := VR_TAB_RUBRICA(VR_INDEX_DEMONST)
                                                           .VLRUBRIC * -1;
            END IF;
            -- Se encontrou lançamento incrementa sequencial
            BEGIN
              INSERT INTO TBINSS_LANDCB
                (ID_DCB, NRSEQLAN, CDRUBRIC, VLRUBRIC)
              VALUES
                (RW_TBINSS_DCB.ID_DCB,
                 (RW_TBINSS_LANDCB.NRSEQLAN + 1),
                 VR_TAB_RUBRICA(VR_INDEX_DEMONST).CDRUBRIC,
                 VR_TAB_RUBRICA(VR_INDEX_DEMONST).VLRUBRIC);
            EXCEPTION
              WHEN OTHERS THEN
                VR_DSCRITIC := 'Erro ao inserir na tbinss_landcb. Erro: ' ||
                               SQLERRM;
                RAISE VR_EXC_SAIDA;
            END;
          END IF;
          CLOSE CR_TBINSS_DCB;
          -- Consulta data vencimento          
          PC_BUSCA_PROVA_VIDA;
        
          -- Buscar o proximo
          VR_INDEX_DEMONST := VR_TAB_DEMONST.NEXT(VR_INDEX_DEMONST);
        END LOOP;
      END IF;
    END IF;
  
    IF VR_MSGENVIO IS NOT NULL THEN
      --Remove o arquivo XML fisico de envio
      GENE0001.PC_OSCOMMAND(PR_TYP_COMANDO => 'S',
                            PR_DES_COMANDO => 'rm ' || VR_MSGENVIO ||
                                              ' 2> /dev/null',
                            PR_TYP_SAIDA   => VR_DES_RETO,
                            PR_DES_SAIDA   => VR_DSCRITIC);
      --Se ocorreu erro dar RAISE
      IF VR_DES_RETO = 'ERR' THEN
        RAISE VR_EXC_SAIDA;
      END IF;
    END IF;
  
    IF VR_MSGRECEB IS NOT NULL THEN
      --Remove o arquivo XML fisico de recebimento
      GENE0001.PC_OSCOMMAND(PR_TYP_COMANDO => 'S',
                            PR_DES_COMANDO => 'rm ' || VR_MSGRECEB ||
                                              ' 2> /dev/null',
                            PR_TYP_SAIDA   => VR_DES_RETO,
                            PR_DES_SAIDA   => VR_DSCRITIC);
      --Se ocorreu erro dar RAISE
      IF VR_DES_RETO = 'ERR' THEN
        RAISE VR_EXC_SAIDA;
      END IF;
    END IF;
  
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
  
    -- Gerar hora inicio no log
    BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                               PR_IND_TIPO_LOG => 1,
                               PR_DES_LOG      => TO_CHAR(SYSDATE,
                                                          'DD/MM/YYYY HH24:MI:SS') ||
                                                  ' - crps700 - FIM.',
                               PR_NMARQLOG     => 'log_crps700_PLL');
  
    -- Novament tenta encerrar o JOB
    GENE0001.PC_ENCERRA_PARALELO(PR_IDPARALE => PR_IDPARALE,
                                 PR_IDPROGRA => PR_NRDCONTA,
                                 PR_DES_ERRO => PR_DSCRITIC);
  
    -- Salvar informações atualizadas
    COMMIT;
  
  EXCEPTION
    WHEN VR_EXC_SAIDA THEN
      -- Se foi retornado apenas código
      IF VR_CDCRITIC > 0 AND VR_DSCRITIC IS NULL THEN
        -- Buscar a descrição
        VR_DSCRITIC := GENE0001.FN_BUSCA_CRITICA(VR_CDCRITIC);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      PR_CDCRITIC := NVL(VR_CDCRITIC, 0);
      PR_DSCRITIC := VR_DSCRITIC;
      -- Novament tenta encerrar o JOB
      GENE0001.PC_ENCERRA_PARALELO(PR_IDPARALE => PR_IDPARALE,
                                   PR_IDPROGRA => PR_NRDCONTA,
                                   PR_DES_ERRO => PR_DSCRITIC);
    
      -- Efetuar rollback
      ROLLBACK;
    WHEN VR_EXC_FIMPRG THEN
      -- gera log do erro
      BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => PR_CDCOOPER,
                                 PR_IND_TIPO_LOG => 1, -- somente mensagem
                                 PR_NMARQLOG     => 'log_crps700_PLL', --gerar log no prprev,
                                 PR_DES_LOG      => 'vr_exc_FIMPRG: ' ||
                                                    PR_CDCOOPER || '_' ||
                                                    PR_NRDCONTA || '_' ||
                                                    PR_CDAGESIC || '_' ||
                                                    PR_DTMVTOAN || '_' ||
                                                    PR_IDPARALE);
    
      -- Encerrar o job do processamento paralelo dessa agência
      GENE0001.PC_ENCERRA_PARALELO(PR_IDPARALE => PR_IDPARALE,
                                   PR_IDPROGRA => PR_NRDCONTA,
                                   PR_DES_ERRO => VR_DSCRITIC);
    
      COMMIT;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      PR_CDCRITIC := 0;
      PR_DSCRITIC := SQLERRM;
      -- Gerar hora inicio no log
      BTCH0001.PC_GERA_LOG_BATCH(PR_CDCOOPER     => 3,
                                 PR_IND_TIPO_LOG => 1,
                                 PR_NMARQLOG     => 'log_crps700_PLL' --gerar log no prprev,
                                ,
                                 PR_DES_LOG      => 'vr_exc_FIMPRG: ' ||
                                                    PR_CDCOOPER || '_' ||
                                                    PR_NRDCONTA || '_' ||
                                                    PR_CDAGESIC || '_' ||
                                                    PR_DTMVTOAN || '_' ||
                                                    PR_IDPARALE);
    
      -- Encerrar o job do processamento paralelo dessa agência
      GENE0001.PC_ENCERRA_PARALELO(PR_IDPARALE => PR_IDPARALE,
                                   PR_IDPROGRA => PR_NRDCONTA,
                                   PR_DES_ERRO => VR_DSCRITIC);
      -- Efetuar rollback
      ROLLBACK;
  END;

END PC_CRPS700_1;
