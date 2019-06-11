CREATE OR REPLACE PACKAGE CECRED.APLI0007 AS

  -- ------------------------------------------------------------------------------------
  -- Programa: APLI0007
  -- Sistema : Conta-Corrente - Cooperativa de Credito
  -- Sigla   : CRED
  -- 
  -- Autor   : Marcos - Envolti
  -- Data    : Março/2018                       Ultima atualizacao: 
  -- 
  -- Dados referentes ao programa:
  -- 
  -- Frequencia: On-line
  -- Objetivo  : Manter as rotinas específica do processo de Captação e
  --             Custódia das Aplicações junto ao B3
  -- 
  -- Alterações: 21/09/2018 - Ajuste na query da pc_gera_arquivos_envio, incluindo novo índice
  --                        - Alterar nome dos arquivos de conciliação recebidos da B3, incluindo
  --                          o horário no final do nome, pois os nomes não são únicos e ocorria 
  --                          perda de arquivos
  --                        - Remover o tempo de espera para o envio dos arquivos gerados. Passa
  --                          a considerar como processados os arquivos quando são colocados na 
  --                          pasta envia. (Daniel - Envolti)
  --
  --
  -- Alterações: 05/03/2019 - P411 
  --				          Ajuste Calculo da quantidade de cotas referente a operação atual
  --						  alterado para compatibilizar com a B3;							  
  --						  REGRA ANTIGA -> vr_qtcotas_resg := trunc(rw_lcto.vllanmto / vr_vlpreco_unit);
  --						  REGRA NOVA   -> vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto.valorbase);						  
  --                        - (David Valente - Envolti)
	
																		  
														 
	
  -- ----------------------------------------------------------------------------------- 
  
  -- Retornar tipo da Aplicação enviada
  FUNCTION fn_tip_aplica(pr_cdcooper IN NUMBER
                        ,pr_tpaplica IN NUMBER
                        ,pr_nrdconta IN NUMBER
                        ,pr_nraplica IN NUMBER) RETURN VARCHAR2;

  -- Retornar true caso a aplicação esteja em carencia
  FUNCTION fn_tem_carencia(pr_dtmvtapl crapdat.dtmvtolt%type
                          ,pr_qtdiacar craprac.qtdiacar%TYPE
                          ,pr_dtmvtres crapdat.dtmvtolt%TYPE) RETURN VARCHAR2;      
  
  -- Função para mostrar a descrição conforme o tipo do Arquivo enviado 
  FUNCTION fn_tparquivo_custodia(pr_idtipo_arquivo IN NUMBER        -- Tipo do Arquivo (1-Registro,2-Resgate,3-Exclusão,9-Conciliação)
                                ,pr_idtipo_retorno IN VARCHAR2)     -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                               RETURN VARCHAR2;
  
  -- Função para mostrar a descrição conforme o tipo lancto enviado
  FUNCTION fn_tpregistro_custodia(pr_idtipo_lancto  IN NUMBER    -- Tipo do Registro
                                 ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2;  
                          
  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processo_controle(pr_tipexec   IN NUMBER     --> Tipo da Execução
                                ,pr_dsinform OUT CLOB       --> Descrição de informativos na execução
                                ,pr_dscritic OUT VARCHAR2); --> Descrição de critica
  

END APLI0007;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0007 AS
  
  -- Constantes
  vr_nomdojob CONSTANT VARCHAR2(30) := 'JBCAPT_CUSTOD_B3';     -- Nome do JOB
  vr_nmsimplf CONSTANT VARCHAR2(20) := RPAD('CECRED',20,' '); -- Nome Simplificado do Participante
  vr_dsdirarq CONSTANT VARCHAR2(30) := gene0001.fn_diretorio('C',1,'arq'); -- Diretório temporário para arquivos
  vr_qtdexjob CONSTANT NUMBER(5)    := 500; -- Quantidade de arquivos enviados / recebidos por execução                  
  -- Pastas Padrão Connect Direct 
  vr_dsdirenv CONSTANT VARCHAR2(30) := 'envia'; 
  vr_dsdirevd CONSTANT VARCHAR2(30) := 'enviados'; 
  vr_dsdirrec CONSTANT VARCHAR2(30) := 'recebe'; 
  vr_dsdirrcb CONSTANT VARCHAR2(30) := 'recebidos';
  -- Caracteres de Quebra
  vr_dscarque CONSTANT VARCHAR2(30) := chr(10)||chr(13); 
  vr_dstagque CONSTANT VARCHAR2(30) := '<br><br>'; 
  vr_dsfimlin CONSTANT VARCHAR2(01) := '<'; 
  -- Fator conversão R$ X Cota Unitária
  vr_qtftcota CONSTANT  NUMBER(3,2) := 0.01; -- Cada cota = R$0,01 (1 Centavo)
  
  -- Tratamento de criticas
  vr_idcritic  NUMBER;
  vr_cdcritic  NUMBER;
  vr_dscritic  VARCHAR2(32767);
  vr_exc_saida EXCEPTION;  
  vr_des_reto  VARCHAR2(3);
  vr_tab_erro  cecred.gene0001.typ_tab_erro;
  
  -- Retornar tipo da Aplicação enviada
  FUNCTION fn_tip_aplica(pr_cdcooper IN NUMBER
                        ,pr_tpaplica IN NUMBER
                        ,pr_nrdconta IN NUMBER
                        ,pr_nraplica IN NUMBER) RETURN VARCHAR2 IS
    -- Para aplicações de Captação
    CURSOR cr_craprac IS
      SELECT cpc.nmprodut
        FROM crapind ind
            ,crapcpc cpc  
            ,craprac rac
       WHERE cpc.cddindex = ind.cddindex
         AND cpc.cdprodut = rac.cdprodut
         AND rac.cdcooper = pr_cdcooper
         AND rac.nrdconta = pr_nrdconta
         AND rac.nraplica = pr_nraplica;
    vr_nmprodut crapcpc.nmprodut%TYPE;
    -- Para aplicações RDA
    CURSOR cr_craprda IS
      SELECT dtc.dsaplica
        FROM craprda rda
            ,crapdtc dtc
       WHERE rda.cdcooper = dtc.cdcooper
         AND rda.tpaplica = dtc.tpaplica
         AND rda.cdcooper = pr_cdcooper
         AND rda.nrdconta = pr_nrdconta
         AND rda.nraplica = pr_nraplica;
  BEGIN
    -- PAra aplicações de Captação
    IF pr_tpaplica IN(3,4) THEN
      -- Buscar CRAPRAC    
      OPEN cr_craprac;
      FETCH cr_craprac
       INTO vr_nmprodut;
      CLOSE cr_craprac; 
    ELSE
      -- Buscar CRAPRDA
      OPEN cr_craprda;
      FETCH cr_craprda
       INTO vr_nmprodut;
      CLOSE cr_craprda;      
    END IF;
    -- Retornar descrição encontrada
    RETURN vr_nmprodut;
  END;
  
  -- Retornar true caso a aplicação esteja em carencia
  FUNCTION fn_tem_carencia(pr_dtmvtapl crapdat.dtmvtolt%type
                          ,pr_qtdiacar craprac.qtdiacar%TYPE
                          ,pr_dtmvtres crapdat.dtmvtolt%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- Se a data enviada menos a data do movimento da aplicacao, for inferior a quantidade de dias da aplicacao
    IF (pr_dtmvtres - pr_dtmvtapl) < pr_qtdiacar THEN
      -- Tem carencia
      RETURN 'S';
    ELSE
      -- Não satisfez nenhuma condicao, não tem carencia
      RETURN 'N';
    END IF;
  END;

  -- Função para transformar a taxa ao dia em taxa anual
  -- Exemplo: Taxa ao dia: 0,024583 -> taxa anual: 6,39
  FUNCTION fn_get_taxa_anual (pr_txapldia craplap.txaplica%TYPE) RETURN NUMBER IS
  BEGIN 
    RETURN round((power(1+pr_txapldia/100,252)-1)*100,4);
  END;

  -- Função para transformar hora atual em texto para LOGS
  FUNCTION fn_get_time_char RETURN VARCHAR2 IS
  BEGIN 
    RETURN to_char(sysdate,'DD/MM/RRRR hh24:mi:ss - ');
  END;
    
  -- Função para mostrar a descrição conforme o tipo do Arquivo enviado
  FUNCTION fn_tparquivo_custodia(pr_idtipo_arquivo IN NUMBER   -- Tipo do Arquivo (1-Registro,2-Operação,3-Exclusão,9-Conciliação)
                                ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2 IS
  BEGIN                           
    -- Retornar conforme o tipo do Arquivo
    IF pr_idtipo_arquivo = 1 THEN
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'REG';
      ELSE
        RETURN 'Registro';
      END IF;
    ELSIF pr_idtipo_arquivo = 2 THEN 
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'OPE';
      ELSE
        RETURN 'Operação';
      END IF;
    ELSIF pr_idtipo_arquivo = 5 THEN 
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'RET';
      ELSE
        RETURN 'Retorno';
      END IF;  
    ELSE
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'CNC';
      ELSE
        RETURN 'Conciliação';
      END IF;
    END IF;       
  END;
  
  -- Função para mostrar a descrição conforme o tipo lancto enviado
  FUNCTION fn_tpregistro_custodia(pr_idtipo_lancto  IN NUMBER    -- Tipo do Registro
                                 ,pr_idtipo_retorno IN VARCHAR2) -- Tipo do Retorno (A-Abreviado ou E-Extenso)
                          RETURN VARCHAR2 IS
  BEGIN                           
    -- Retornar conforme o tipo do Arquivo
    IF pr_idtipo_lancto = 1 THEN
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'REG';
      ELSE
        RETURN 'Registro';
      END IF;
    ELSIF pr_idtipo_lancto = 2 THEN 
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'RGT';
      ELSE
        RETURN 'Resgate';
      END IF;
    ELSIF pr_idtipo_lancto = 3 THEN 
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'RIR';
      ELSE
        RETURN 'Ret.IR';
      END IF;      
    ELSE
      IF pr_idtipo_retorno = 'A' THEN 
        RETURN 'CNC';
      ELSE
        RETURN 'Conciliação';
      END IF;
    END IF;       
  END;
  
  
  -- Função para gerar nome de arquivo conforme ID, Coop, Tipo e Data passada
  FUNCTION fn_nmarquivo_custodia(pr_idarquivo      tbcapt_custodia_arquivo.idarquivo%TYPE       -- ID do arquivo
                                ,pr_cdcooper       crapcop.cdcooper%TYPE                        -- Código da Cooperativa
                                ,pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                ,pr_dtarquivo      tbcapt_custodia_arquivo.dtcriacao%TYPE)      -- Data Arquivo
                         RETURN VARCHAR2 IS
  BEGIN
    -- Padrão 
    --   CodigoCliente(5 primeiras posições+000 (Miolo)).AAMMDD_DMOVTRANSF_Tipo_IDArquivo.TXT onde
    RETURN 
      substr(gene0001.fn_param_sistema('CRED',pr_cdcooper,'CD_REGISTRADOR_CUSTOD_B3'),1,5)||'000'
      ||'.'||to_char(pr_dtarquivo,'yymmdd')
      ||'_DMOVTRANSF'
      ||'_'||fn_tparquivo_custodia(pr_idtipo_arquivo,'A')
      ||'_'||pr_idarquivo
      ||'.TXT';
  END;
  
  -- Função para converter o valor enviado em Cota UNitária
  FUNCTION fn_converte_valor_em_cota(pr_vllancto IN NUMBER) RETURN NUMBER IS
  BEGIN
    -- Dividir pelo fator de conversão R$ X Cota Unitária
    RETURN nvl(pr_vllancto,0) / vr_qtftcota;
  END;
  
  -- Função para remover quebras de linha
  FUNCTION fn_remove_quebra(pr_dstexto IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    -- REmover quebras a direita
    RETURN rtrim(rtrim(pr_dstexto,chr(10)),chr(13));
  END;
  
  -- Função para validar se codigo cetip recebido está cadastrado em alguma cooperativa do grupo
  FUNCTION fn_valida_codigo_cetip(pr_codcetip VARCHAR2) RETURN BOOLEAN IS
    CURSOR cr_crapcop IS
      SELECT cdcooper
        FROM crapcop
       WHERE substr(gene0001.fn_param_sistema('CRED',cdcooper,'CD_REGISTRADOR_CUSTOD_B3'),1,5) = pr_codcetip;
    vr_cdcooper crapcop.cdcooper%TYPE;       
  BEGIN
    -- Buscar alguma cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO vr_cdcooper;
    CLOSE cr_crapcop;
    -- Se não achou nenhuma
    IF vr_cdcooper IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END; 
  
  -- Função para validar se o histórico passado é de provisão ou rendicimento
  -- pois estes, quando encontrados no dia do resgate, terão o saldo corredto da aplicação
  FUNCTION fn_valida_histor_rendim(pr_tpaplica IN NUMBER
                                  ,pr_cdprodut IN NUMBER
                                  ,pr_cdhistor IN NUMBER) RETURN BOOLEAN IS
    
    CURSOR cr_hiscapt IS
      SELECT 1
        FROM crapcpc cpc
       WHERE cpc.cdprodut = pr_cdprodut
         AND pr_cdhistor in(cpc.cdhsprap,cpc.cdhsrdap);
    vr_id_exist NUMBER := 0;
  BEGIN
    -- Para produto novo de captação
    IF pr_tpaplica IN(3,4) THEN
      OPEN cr_hiscapt;
      FETCH cr_hiscapt
       INTO vr_id_exist;
      CLOSE cr_hiscapt;
      -- Se encontrou
      IF vr_id_exist = 1 THEN
        RETURN TRUE;
      END IF;
    ELSE
      -- Históricos fixos
      IF pr_cdhistor IN(474,475,529,532) THEN
         RETURN TRUE;
      END IF;
    END IF;
    -- Se não encontrou nenhum dos históricos, retornar false
    RETURN FALSE;
  END;
  
  -- Procedimento que recebe um arquivo e alerta por email a equipe responsável 
  PROCEDURE pc_envia_email_alerta_arq(pr_dsdemail  IN VARCHAR2                               --> Destinatários
                                     ,pr_dsjanexe  IN VARCHAR2                               --> Descrição horário execução
                                     ,pr_idarquivo IN tbcapt_custodia_arquivo.idarquivo%TYPE --> ID do arquivo
                                     ,pr_dsdirbkp  IN VARCHAR2                               --> Caminho de backup linux
                                     ,pr_dsredbkp  IN VARCHAR2                               --> Caminho da rede de Backup
                                     ,pr_flgerrger IN BOOLEAN                                --> erro geral do arquivo
                                     ,pr_idcritic OUT NUMBER                                 --> Criticidade da saida
                                     ,pr_cdcritic OUT NUMBER                                 --> Código da critica
                                     ,pr_dscritic OUT VARCHAR2) IS                           --> Descrição da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_email_alerta_arq
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 07/12/2018  
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer as criticas geradas no processamento do arquivo
    --             e montar email para os responsáveis pela conferência dos problemas
    --    
    -- Alteracoes: 07/12/2018 - P411 - Melhoria do anexo e Ajustes no email para guardar anexo em pasta (Marcos-Envolti)
    --
    ---------------------------------------------------------------------------------------------------------------  
    DECLARE

      -- Variaveis para Email
      vr_assunto    VARCHAR2(500);
      vr_conteudo   VARCHAR2(4000);      
      vr_dsarqanx   VARCHAR2(500);
      -- Guardar HMTL texto
      vr_dshmtl     clob;
      vr_dshmtl_aux varchar2(32767);

      vr_dtmvtoan   crapdat.dtmvtoan%TYPE;      
      -- tipo de aplicacao (1 - rdc pos e pre / 2 - pcapta / 3 - aplic programada)
      vr_tpaplicacao tbcapt_saldo_aplica.tpaplicacao%TYPE;
      vr_sldaplic    tbcapt_saldo_aplica.vlsaldo_concilia%TYPE;
      vr_qtde_b3     tbcapt_custodia_aplicacao.qtcotas%TYPE;
      vr_vlpu_b3     tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE;
      vr_vltotal_b3  tbcapt_saldo_aplica.vlsaldo_concilia%TYPE;
      
      -- Busca das linhas com critica no arquivo enviado
      CURSOR cr_arq IS
        SELECT arqRet.nmarquivo
              ,fn_tparquivo_custodia(arqRet.idtipo_arquivo,'E') dstipo_arquivo
              ,cnt.nrseq_linha
              ,cnt.dslinha
              ,cnt.dscritica
              ,arqRet.idtipo_Arquivo
              ,cnt.idaplicacao
              ,cnt.dscodigo_b3
              ,to_char(arqRet.Dtregistro,'dd/mm/rrrr') dtregistro 
              ,to_char(arqRet.Dtcriacao,'dd/mm/rrrr hh24:mi:ss') dtcriacao
              ,to_char(arqRet.Dtprocesso,'dd/mm/rrrr hh24:mi:ss') dtprocesso
          FROM tbcapt_custodia_arquivo      arqRet
              ,tbcapt_custodia_conteudo_arq cnt
         WHERE arqRet.idarquivo = cnt.idarquivo
           AND arqRet.idarquivo = pr_idarquivo
           AND cnt.dscritica IS NOT NULL
           AND cnt.idtipo_linha = 'L' -- Somente registros
         ORDER BY cnt.nrseq_linha;
      vr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE;      
      
      -- Buscar aplicação em Custódia
      CURSOR cr_aplica(pr_idaplic tbcapt_custodia_aplicacao.idaplicacao%TYPE) IS
        SELECT apl.idaplicacao
              ,apl.tpaplicacao
              ,0 cdcooper
              ,0 nrdconta
              ,0 nraplica
              ,rpad(' ',50,' ') tpaplica
			  ,apl.qtcotas
          FROM tbcapt_custodia_aplicacao apl
        WHERE apl.idaplicacao = pr_idaplic;
      rw_aplica cr_aplica%ROWTYPE;        
      
      -- Buscar aplicação RDA
      CURSOR cr_craprda(pr_idaplcus craprda.idaplcus%TYPE) IS
        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
          FROM craprda rda
         WHERE rda.idaplcus = pr_idaplcus;
      
      -- Buscar aplicação RAC
      CURSOR cr_craprac(pr_idaplcus craprac.idaplcus%TYPE) IS
        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,cpc.nmprodut
          FROM craprac rac
              ,crapcpc cpc
         WHERE rac.idaplcus = pr_idaplcus
           AND rac.cdprodut = cpc.cdprodut;      

      -- Busca o saldo da aplicacao
      CURSOR cr_saldo(pr_cdcooper    craprda.cdcooper%TYPE   
                     ,pr_nrdconta    craprda.nrdconta%TYPE   
                     ,pr_nraplica    craprda.nraplica%TYPE   
                     ,pr_tpaplicacao craprda.tpaplica%TYPE
                     ,pr_dtmvtolt    craprda.dtmvtolt%TYPE) IS
        SELECT sl.VLSALDO_CONCILIA
          FROM tbcapt_saldo_aplica sl
         WHERE sl.cdcooper    = pr_cdcooper   
           AND sl.nrdconta    = pr_nrdconta   
           AND sl.nraplica    = pr_nraplica   
           AND sl.tpaplicacao = pr_tpaplicacao
           AND sl.dtmvtolt    = pr_dtmvtolt;
           
    BEGIN
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_envia_email_alerta_arq');      

      vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                ,pr_dtmvtolt  => trunc(SYSDATE)-1
                                                ,pr_tipo      => 'A');

      -- Busca de todas as linhas com erro 
      FOR rw_arq IN cr_arq LOOP
      -- Quando não for um erro geral
      IF NOT pr_flgerrger THEN 
        -- Buscar diretório Arq e montar nome do anexo
          vr_dsarqanx := 'PROC_'||rw_arq.nmarquivo||'.html';
      END IF;
        -- No primeiro registro 
        IF vr_conteudo IS NULL THEN 
          -- Guardar tipo
          vr_idtipo_arquivo := rw_arq.idtipo_arquivo;
          -- Montar assunto 
          vr_assunto := 'Criticas ao processar o arquivo '||rw_arq.nmarquivo||' de '||rw_arq.dstipo_arquivo||' de operações na B3 Ref '||rw_arq.dtregistro;
          -- Se não for um erro geral 
          IF NOT pr_flgerrger THEN 
            -- Montar corpo do email 
            vr_conteudo := 'Prezados, '||vr_dstagque;
            -- Caso conciliação
            IF rw_arq.idtipo_arquivo = 9 THEN
              vr_conteudo := vr_conteudo || 'Houve diferença na '||rw_arq.dstipo_arquivo||' das aplicações registradas na B3 em comparação com o Aimaro. '||vr_dstagque;
            ELSE
              vr_conteudo := vr_conteudo || 'Os registros listados no anexo apresentaram criticas e não foram processados pela B3. '||vr_dstagque;
            END IF;      
            -- Montar o início da tabela (Num clob para evitar estouro)
            dbms_lob.createtemporary(vr_dshmtl, TRUE, dbms_lob.CALL);
            dbms_lob.open(vr_dshmtl,dbms_lob.lob_readwrite);
            -- Enviar dados do arquivo
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<div align="left" style="margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;">');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Dados do arquivo:'||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'ID: '||pr_idarquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Nome: '||rw_arq.nmarquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Tipo: '||rw_arq.dstipo_arquivo||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Data Base: '||rw_arq.dtregistro||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Data Recebimento: '||rw_arq.dtcriacao||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Data Processamento: '||rw_arq.dtprocesso||vr_dstagque||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'Lista de Criticas:'||vr_dstagque);
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'</div>');
             
            -- Preparar tabela de erros
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<table border="1" style="width:500px; margin: 10px auto; font-family: Tahoma,sans-serif; font-size: 12px; color: #686868;" >');
            -- Montando header
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Nro.Linha</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Cod.B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Conta</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Tp.Aplica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Aplica</th>');

            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Qtd. Aimaro</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Valor Aimaro</th>');            
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Qtd. B3</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Valor B3</th>');
            
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Critica</th>');
            gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<th>Linha Enviada</th>');
          ELSE 
            -- Erro geral
            vr_conteudo := 'Prezados, '||vr_dstagque
                        || 'O arquivo apresentou o erro abaixo e não foi processado';
            -- Caso conciliação
            IF rw_arq.idtipo_arquivo = 9 THEN
              vr_conteudo := vr_conteudo || ' pelo Aimaro '||vr_dstagque;
            ELSE
              vr_conteudo := vr_conteudo || ' pela B3: '||vr_dstagque;
            END IF;
            -- Continuar            
            vr_conteudo := vr_conteudo || '<b>'||rw_arq.dscritica||'</b>'||vr_dstagque;
            -- Quando erro geral processaremos apenas o primeiro registro
            EXIT;                
          END IF;
        END IF;
        -- Cada registro deve ser enviado ao arquivo a anexar
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<tr>');
        -- E os detalhes do registro
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td align="right">'||to_char(rw_arq.nrseq_linha)||'</td>');
        -- Buscar dados da aplicação
        rw_aplica := NULL;
        OPEN cr_aplica(rw_arq.idaplicacao);
        FETCH cr_aplica
         INTO rw_aplica;
        -- Se não encontrar
        IF cr_aplica%NOTFOUND THEN 
          -- Só fechar o cursor
          CLOSE cr_aplica;
        ELSE
          -- Fechar o cursor
          CLOSE cr_aplica;
          -- Buscar aplicação RDA ou RAC relacionada
          IF rw_aplica.tpaplicacao IN(3,4) THEN 
            -- Buscar aplicação RAC
            OPEN cr_craprac(rw_aplica.idaplicacao);
            FETCH cr_craprac
             INTO rw_aplica.cdcooper
                 ,rw_aplica.nrdconta
                 ,rw_aplica.nraplica
                 ,rw_aplica.tpaplica;
            CLOSE cr_craprac;
            vr_tpaplicacao := 2;
          ELSE
            -- Buscar aplicação RDA
            OPEN cr_craprda(rw_aplica.idaplicacao);
            FETCH cr_craprda
             INTO rw_aplica.cdcooper
                 ,rw_aplica.nrdconta
                 ,rw_aplica.nraplica;
            CLOSE cr_craprda;                
            -- Montar tipo aplicação
            IF rw_aplica.tpaplicacao = 1 THEN
              rw_aplica.tpaplica := 'RDC Pré';
            ELSE
              rw_aplica.tpaplica := 'RDC Pós';
            END IF;
            vr_tpaplicacao := 1;
          END IF;
          vr_sldaplic := 0;
          OPEN cr_saldo(rw_aplica.cdcooper
                       ,rw_aplica.nrdconta
                       ,rw_aplica.nraplica
                       ,vr_tpaplicacao
                       ,vr_dtmvtoan);                                      
          FETCH cr_saldo                                       
           INTO vr_sldaplic;   
          CLOSE cr_saldo;
        END IF;
        
        BEGIN
          /* Tenta buscar os dados do arquivo da B3*/
          vr_qtde_b3 := to_number(gene0002.fn_busca_entrada('14' -- posicao 14
                                                           ,rw_arq.dslinha
                                                           ,';'));
          vr_vlpu_b3 := to_number(gene0002.fn_busca_entrada('16' -- posicao 16
                                                           ,rw_arq.dslinha
                                                           ,';'));
          vr_vltotal_b3 := vr_qtde_b3 * vr_vlpu_b3;
        EXCEPTION
          WHEN OTHERS THEN
             vr_vltotal_b3 := 0;
             vr_qtde_b3    := 0;
             vr_vlpu_b3    := 0;
        END;
        
        -- Enviar dados da aplicacao
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_arq.dscodigo_b3||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_aplica.nrdconta||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_aplica.tpaplica||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_aplica.nraplica||'</td>');
        
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_aplica.qtcotas||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||CADA0014.fn_formata_valor(vr_sldaplic)||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||vr_qtde_b3||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||CADA0014.fn_formata_valor(vr_vltotal_b3)||'</td>');
        -- Enviar linha e critica
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_arq.dscritica||'</td>');
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'<td>'||rw_arq.dslinha||'</td>');
        -- Encerrar a tr
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'</tr>');
      END LOOP;
      
      -- Se há arquivo com erros para anexar ao email ou copiar para uma pasta
      IF vr_dsarqanx IS NOT NULL THEN 
        -- Encerrar o texto e o clob
        gene0002.pc_escreve_xml(vr_dshmtl,vr_dshmtl_aux,'',true);
        -- Caso conciliação
        IF vr_idtipo_arquivo = 9 THEN
          -- Gerar o arquivo na pasta de backup do financeiro
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl
                                       ,pr_caminho  => pr_dsdirbkp
                                       ,pr_arquivo  => vr_dsarqanx
                                       ,pr_des_erro => vr_dscritic);          
        ELSE
        -- Gerar o arquivo na pasta converte
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_dshmtl
                                     ,pr_caminho  => vr_dsdirarq
                                     ,pr_arquivo  => vr_dsarqanx
                                     ,pr_des_erro => vr_dscritic);
        END IF;
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_dshmtl);
        dbms_lob.freetemporary(vr_dshmtl);
        -- Em caso de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Propagar a critica
          vr_cdcritic := 1044;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Caminho: '||vr_dsdirarq||'/'||vr_dsarqanx||', erro: '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
      -- Se não for conciliação
      IF vr_idtipo_arquivo <> 9 THEN
      -- Complementar o conteudo do email caso não seja de conciliação
        vr_conteudo := vr_conteudo
                    || 'Lembre que o registro deve ocorrer até 2 dias úteis após sua realização, favor providenciar a correção e re-envio deste(s).'||vr_dstagque
                    || 'O processamento diário ocorre no período de '||pr_dsjanexe||' horas.'||vr_dstagque;
        -- Adicionar o caminho completo ao nome do arquivo
        vr_dsarqanx := vr_dsdirarq||'/'||vr_dsarqanx;
      ELSE 
        -- Conciliação teremos o caminho de rede para copiar o anexo
        vr_conteudo := vr_conteudo
                    || 'O arquivo encontra-se no caminho de rede abaixo: '||vr_dstagque
                    || pr_dsredbkp||'\'||vr_dsarqanx||' '||vr_dstagque;
        -- Limpar a variavel de nome de anexo pois não será enviado por email, mas somente na pasta
        vr_dsarqanx := NULL;
      END IF;           
                  
      -- Complementar o conteudo do email com texto comum
      vr_conteudo := vr_conteudo|| 'Atenciosamente,'||vr_dstagque
                  || 'Sistema AILOS';
      
      -- Ao final, solicitar o envio do Email
      gene0003.pc_solicita_email(pr_cdcooper        => 3 -- Fixo Central
                                ,pr_cdprogra        => 'APLI0007'
                                ,pr_des_destino     => pr_dsdemail
                                ,pr_des_assunto     => vr_assunto
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => vr_dsarqanx
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      -- Se houver erros
      IF vr_dscritic IS NOT NULL THEN
        -- Gera critica
        vr_cdcritic := 1046;
        vr_dscritic := gene0001.fn_busca_critica||pr_dsdemail||'. Detalhes: '|| vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := 'Rotina : APLI0007.pc_envia_email_alerta_arq' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := 'Rotina : APLI0007.pc_envia_email_alerta_arq' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                 
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;  
  END pc_envia_email_alerta_arq;
  
  -- Função para buscar o saldo da aplicação no dia anterior a data passada
  PROCEDURE pc_busca_saldo_anterior(pr_cdcooper  IN craprda.cdcooper%TYPE                  --> Cooperativa
                                   ,pr_nrdconta  IN craprda.nrdconta%TYPE                  --> Conta
                                   ,pr_nraplica  IN craprda.nraplica%TYPE                  --> Aplicação
                                   ,pr_tpaplica  IN crapdtc.tpaplica%TYPE                  --> Tipo aplicacao
                                   ,pr_cdprodut  IN craprac.cdprodut%TYPE                  --> Codigo produto 
                                   ,pr_dtmvtolt  IN craprda.dtmvtolt%TYPE                  --> Data movimento
                                   ,pr_dtmvtsld  IN craprda.dtmvtolt%TYPE                  --> Data do saldo desejado
                                   ,pr_tpconsul  IN VARCHAR2                               --> [C]onciliação ou [R]esgate                            
                                   ,pr_sldaplic OUT craprda.vlsdrdca%TYPE                  --> Saldo no dia desejado
                                   ,pr_idcritic OUT NUMBER                                 --> Criticidade da saida
                                   ,pr_cdcritic OUT NUMBER                                 --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2) IS                           --> Descrição da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_saldo_anterior
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Maio/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer o extrato de aplicação buscando pelo saldo no dia
    --             anterior ao resgate para cálculo da P.U. naquele dia
    --    
    -- Alteracoes:
    --
    --------------------------------------------------------------------------------------------------------------- 
    DECLARE 
      -- Busca dos dados da Aplicação em rotina já preparada
      vr_tbsaldo_rdca     APLI0001.typ_tab_saldo_rdca;
      vr_tab_extrato_rdca cecred.APLI0002.typ_tab_extrato_rdca; 
      vr_tab_extrato      apli0005.typ_tab_extrato;   
      -- Auxiliares
      vr_vlresgat NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_txacumul NUMBER;                  -- Taxa acumulada durante o período total da aplicação
      vr_txacumes NUMBER;                  -- Taxa acumulada durante o mês vigente
      vr_percirrf NUMBER;
      vr_vlsldapl NUMBER;
      vr_cdagenci crapage.cdagenci%TYPE := 1;
      -- Indices das temp-tables
      vr_index_extrato_rdca PLS_INTEGER;
    BEGIN
      -- Inclusão do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_busca_saldo_anterior');   
      -- Inicializar retorno
      pr_sldaplic := 0; 
      -- Limpar toda a tabela de memória
      vr_tbsaldo_rdca.DELETE();
      
      -- Caso aplicação nova
      IF pr_tpaplica > 2 THEN
        -- Busca a listagem de aplicacoes 
        APLI0008.pc_lista_aplicacoes_progr(pr_cdcooper   => pr_cdcooper          -- Código da Cooperativa 
                                    ,pr_cdoperad   => '1'                  -- Código do Operador
                                    ,pr_nmdatela   => 'CUSAPL'             -- Nome da Tela
                                    ,pr_idorigem   => 5                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                    ,pr_nrdcaixa   => 1                    -- Numero do Caixa
                                    ,pr_nrdconta   => pr_nrdconta          -- Número da Conta
                                    ,pr_idseqttl   => 1                    -- Titular da Conta 
                                    ,pr_cdagenci   => 1                    -- Codigo da Agencia
                                    ,pr_cdprogra   => 'CUSAPL'             -- Codigo do Programa
                                    ,pr_nraplica   => pr_nraplica          -- Número da Aplicaçao 
                                    ,pr_cdprodut   => pr_cdprodut          -- Código do Produto
                                    ,pr_dtmvtolt   => pr_dtmvtolt          -- Data de Movimento
                                    ,pr_idconsul   => 5                    -- Todas
                                    ,pr_idgerlog   => 0                    -- Identificador de Log (0 – Nao / 1 – Sim)
                                    ,pr_tpaplica   => 2                    -- Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                    ,pr_cdcritic   => vr_cdcritic          -- Código da crítica 
                                    ,pr_dscritic   => vr_dscritic          -- Descriçao da crítica 
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca);   -- Retorno das aplicações
                 
        -- Verifica se ocorreram erros
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Montar mensagem de critica
          RAISE vr_exc_saida;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;   
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                      ||' Coop: '||pr_cdcooper
                      ||',Conta: '||pr_nrdconta
                      ||',NrAplica: '||pr_nraplica
                      ||',Produto: '||pr_cdprodut;
          RAISE vr_exc_saida;
        END IF;
      ELSE
        -- Consulta de aplicacoes antigas
        APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   --> Cooperativa
                                       ,pr_cdagenci   => 1             --> Codigo da agencia
                                       ,pr_nrdcaixa   => 1             --> Numero do caixa
                                       ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                                       ,pr_nraplica   => pr_nraplica   --> Numero da aplicacao
                                       ,pr_tpaplica   => 0             --> Tipo de aplicacao
                                       ,pr_dtinicio   => pr_dtmvtsld   --> Data de inicio da aplicacao
                                       ,pr_dtfim      => pr_dtmvtolt   --> Data final da aplicacao
                                       ,pr_cdprogra   => 'CUSAPL'      --> Codigo do programa chamador da rotina
                                       ,pr_nrorigem   => 5             --> Origem da chamada da rotina
                                       ,pr_saldo_rdca => vr_tbsaldo_rdca --> Tipo de tabela com o saldo RDCA
                                       ,pr_des_reto   => vr_dscritic   --> OK ou NOK
                                       ,pr_tab_erro   => vr_tab_erro); --> Tabela com erros
        -- Verifica se ocorreram erros
        IF vr_dscritic = 'NOK' THEN
          -- Se existir erro adiciona na crítica
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Montar mensagem de critica
          RAISE vr_exc_saida;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;   
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                      ||' Coop: '||pr_cdcooper
                      ||',Conta: '||pr_nrdconta
                      ||',NrAplica: '||pr_nraplica
                      ||',Produto: '||pr_cdprodut;
          RAISE vr_exc_saida;
        END IF;     
      END IF;
      
      -- Retornaremos o saldo já encontrado
      IF vr_tbsaldo_rdca.exists(vr_tbsaldo_rdca.FIRST) THEN
        pr_sldaplic := vr_tbsaldo_rdca(vr_tbsaldo_rdca.FIRST).VLSDRDAD;
      ELSE
        pr_sldaplic := 0;
      END IF;
      
      -- Somente quando resgate
      IF pr_tpconsul = 'R' AND pr_dtmvtsld IS NOT NULL THEN 
        -- Buscar na pltable dos dados da aplicação
        FOR vr_idx IN vr_tbsaldo_rdca.FIRST..vr_tbsaldo_rdca.LAST LOOP 
          IF vr_tbsaldo_rdca.exists(vr_idx) THEN
            -- Buscar o extrato da aplicação para termos a posição do saldo em determinado dia
            --Limpar tabela extrato rdca
            vr_tab_extrato_rdca.DELETE;
            IF vr_tbsaldo_rdca(vr_idx).idtipapl = 'N' THEN
              -- Procedure para buscar informações da aplicação
              APLI0005.pc_busca_extrato_aplicacao(pr_cdcooper => pr_cdcooper        -- Código da Cooperativa
                                                 ,pr_cdoperad => '1'                -- Código do Operador
                                                 ,pr_nmdatela => 'EXTRDA'           -- Nome da Tela
                                                 ,pr_idorigem => 5                  -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                                 ,pr_nrdconta => pr_nrdconta        -- Número da Conta
                                                 ,pr_idseqttl => 1                  -- Titular da Conta
                                                 ,pr_dtmvtolt => pr_dtmvtolt        -- Data de Movimento
                                                 ,pr_nraplica => vr_tbsaldo_rdca(vr_idx).nraplica        -- Número da Aplicação
                                                 ,pr_idlstdhs => 0                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                                 ,pr_idgerlog => 0                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                                 ,pr_tab_extrato => vr_tab_extrato  -- PLTable com os dados de extrato
                                                 ,pr_vlresgat => vr_vlresgat        -- Valor de resgate
                                                 ,pr_vlrendim => vr_vlrendim        -- Valor de rendimento
                                                 ,pr_vldoirrf => vr_vldoirrf        -- Valor do IRRF
                                                 ,pr_txacumul => vr_txacumul        -- Taxa acumulada durante o período total da aplicação
                                                 ,pr_txacumes => vr_txacumes        -- Taxa acumulada durante o mês vigente
                                                 ,pr_percirrf => vr_percirrf         -- Valor de aliquota de IR
                                                 ,pr_cdcritic => vr_cdcritic        -- Código da crítica
                                                 ,pr_dscritic => vr_dscritic);       -- Descrição da crítica

              -- Se retornou alguma critica
              IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                RAISE vr_exc_saida;
              ELSE
                -- Converter o vetor de extrato de aplicações captação em aplicações antigas para reaproveitamento de código  
                IF vr_tab_extrato.COUNT > 0 THEN
                  -- Percorre todos os registros da aplicação                      
                  FOR vr_contador IN vr_tab_extrato.FIRST..vr_tab_extrato.LAST LOOP
                    -- Proximo indice da tabela vr_tab_extrato
                    vr_index_extrato_rdca:= vr_tab_extrato_rdca.COUNT + 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt := vr_tab_extrato(vr_contador).DTMVTOLT;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dshistor := vr_tab_extrato(vr_contador).DSHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).nrdocmto := vr_tab_extrato(vr_contador).NRDOCMTO;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).indebcre := vr_tab_extrato(vr_contador).INDEBCRE;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vllanmto := NVL(vr_tab_extrato(vr_contador).VLLANMTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl := NVL(vr_tab_extrato(vr_contador).VLSLDTOT,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).txaplica := NVL(vr_tab_extrato(vr_contador).TXLANCTO,0);
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsaplica := vr_tbsaldo_rdca(vr_idx).DSAPLICA;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdagenci := vr_cdagenci;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).vlpvlrgt := vr_vlresgat;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor := vr_tab_extrato(vr_contador).CDHISTOR;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).tpaplrdc := 1;
                    vr_tab_extrato_rdca(vr_index_extrato_rdca).dsextrat := vr_tab_extrato(vr_contador).DSEXTRAT;
                  END LOOP;
                END IF; 
              END IF;   
            ELSE
              --Consultar Extrato RDCA
              APLI0002.pc_consulta_extrato_rdca (pr_cdcooper    => pr_cdcooper       --Codigo Cooperativa
                                                ,pr_cdageope    => 1                 --Codigo Agencia
                                                ,pr_nrcxaope    => 1                 --Numero do Caixa
                                                ,pr_cdoperad    => '1'               --Codigo Operador
                                                ,pr_nmdatela    => 'IMPRES'          --Nome da Tela
                                                ,pr_nrdconta    => pr_nrdconta       --Numero da Conta do Associado
                                                ,pr_idseqttl    => 1                 --Sequencial do Titular
                                                ,pr_dtmvtolt    => pr_dtmvtolt       --Data do movimento
                                                ,pr_nraplica    => vr_tbsaldo_rdca(vr_idx).nraplica       --Numero Aplicacao
                                                ,pr_tpaplica    => 0                 --Tipo Aplicacao
                                                ,pr_vlsdrdca    => vr_vlsldapl       --Valor Saldo RDCA
                                                ,pr_dtiniper    => NULL              --Periodo inicial
                                                ,pr_dtfimper    => NULL              --Periodo Final
                                                ,pr_cdprogra    => 'IMPRES'          --Nome da Tela
                                                ,pr_idorigem    => 5                 --Origem dos Dados
                                                ,pr_flgerlog    => FALSE             --Imprimir log
                                                ,pr_tab_extrato_rdca => vr_tab_extrato_rdca  --Tabela Extrato Aplicacao RDCA
                                                ,pr_des_reto     => vr_des_reto        --Retorno OK ou NOK
                                                ,pr_tab_erro     => vr_tab_erro);      --Tabela de Erros
              -- Se retornou erro
              IF vr_des_reto = 'NOK' THEN
                --Se possuir erro na temp-table
                IF vr_tab_erro.COUNT > 0 THEN
                  vr_dscritic:= 'Conta/dv: '||to_char(pr_nrdconta,'fm99g999g999g9')||' - '||
                                                vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  vr_dscritic:= 'Conta/dv: '||to_char(pr_nrdconta,'fm99g999g999g9')||' - '||
                                                'Nao foi possivel carregar o extrato.';
                END IF;   
                RAISE vr_exc_saida;                         
              END IF; 
            END IF;    
            
            -- Percorrer todos os extratos rdca
            vr_index_extrato_rdca:= vr_tab_extrato_rdca.FIRST;
            WHILE vr_index_extrato_rdca IS NOT NULL LOOP
              -- Se o próximo evento for de data posterior ao resgate
              -- ou chegarmos no dia do resgate e for um histórico de provisão ou rendimento              
              IF vr_index_extrato_rdca = vr_tab_extrato_rdca.last
              OR vr_tab_extrato_rdca(vr_tab_extrato_rdca.next(vr_index_extrato_rdca)).dtmvtolt > pr_dtmvtsld
              OR (vr_tab_extrato_rdca(vr_index_extrato_rdca).dtmvtolt = pr_dtmvtsld AND fn_valida_histor_rendim(pr_tpaplica,pr_cdprodut,vr_tab_extrato_rdca(vr_index_extrato_rdca).cdhistor)) THEN 
                -- Guardar o saldo
                pr_sldaplic := vr_tab_extrato_rdca(vr_index_extrato_rdca).vlsldapl;
                -- Não necessário mais efetuar busca
                vr_index_extrato_rdca := vr_tab_extrato_rdca.last;
              END IF;
              -- Proximo registro
              vr_index_extrato_rdca:= vr_tab_extrato_rdca.NEXT(vr_index_extrato_rdca);    
            END LOOP;
          END IF;
        END LOOP;
      END IF;
      
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := 'Rotina : APLI0007.pc_busca_saldo_anterior' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := 'Rotina : APLI0007.pc_busca_saldo_anterior' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                 
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;  
  END pc_busca_saldo_anterior;
  
  
  -- Varrer os lançamentos e criar registros para envio de Custódia
  PROCEDURE pc_verifi_lanctos_custodia(pr_flenvreg IN VARCHAR2      --> Envio de Registros Habilidade
                                      ,pr_flenvrgt IN VARCHAR2      --> Envio de Operações Habilitado
                                      ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                      ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                      ,pr_cdcritic OUT NUMBER       --> Código da critica
                                      ,pr_dscritic OUT VARCHAR2) IS --> Saida de possível critica no processo
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_verifi_lanctos_custodia
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Diário
    -- Objetivo  : Procedimento responsável por varrer as tabelas de Lançamento das Aplicações
    --             e identificar registros de Cadastro ou Operações da Aplicação para então gerar
    --             pendências de envio ao B3
    
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------  
    DECLARE
      -- Dia útil anterior ao dtmvtoan (2 dias atrás)
      vr_dtmvto2a DATE;
      
      -- Busca de todas as Cooperativas ativas com exceção da Central
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop 
         WHERE cdcooper <> 3  
           AND flgativo = 1;
           
      -- Parâmetros de Sistema
      vr_dtinictd DATE;        --> Data de início da Custódia
      vr_vlinictd NUMBER;      --> Valor mínimo envio Custódia
      
      -- Busca do calendário da Cooperativa
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Busca dos lançamentos de aplicação dos ultimos 2 dias
      CURSOR cr_lctos(pr_cdcooper NUMBER
                     ,pr_dtmvtoan DATE
                     ,pr_dtmvtolt DATE
                     ,pr_dtinictd DATE
                     ,pr_vlminctd NUMBER) IS
        -- RDC Pré e RDC Pós
        SELECT rda.rowid rowid_apl
              ,lap.rowid rowid_lct
              ,hst.tpaplicacao tpaplrdc
              ,lap.dtmvtolt
              ,lap.cdhistor
              ,lap.vllanmto
              ,hst.idtipo_arquivo
              ,hst.idtipo_lancto
              ,hst.cdoperacao_b3
          FROM craplap lap
              ,craprda rda
              ,crapdtc dtc
              ,vw_capt_histor_operac hst
         WHERE rda.cdcooper = dtc.cdcooper
           AND rda.tpaplica = dtc.tpaplica
           AND lap.cdcooper = rda.cdcooper
           AND lap.nrdconta = rda.nrdconta
           AND lap.nraplica = rda.nraplica
           AND lap.cdcooper = pr_cdcooper
           -- Históricos de Aplicação
           AND hst.idtipo_arquivo = 1 -- Aplicação
           AND hst.tpaplicacao = dtc.tpaplrdc
           AND hst.cdhistorico = lap.cdhistor
           -- Utilizar a maior data entre os dois dias úteis anteriores
           -- e a data de início de envio das aplicações para custódia B3
           AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
		   -- E não podem ser do dia atual
           AND lap.dtmvtolt < pr_dtmvtolt
           --> Aplicação não custodiada ainda
           AND nvl(rda.idaplcus,0) = 0 
           --> Registro não custodiado ainda
           AND nvl(lap.idlctcus,0) = 0
           --> Valor de aplicação maior ou igual ao valor mínimo
           AND lap.vllanmto >= nvl(pr_vlminctd,0) 
        UNION
        -- Produtos de Captação
        SELECT rac.rowid 
              ,lac.rowid 
              ,hst.tpaplicacao 
              ,lac.dtmvtolt
              ,lac.cdhistor
              ,lac.vllanmto
              ,hst.idtipo_arquivo
              ,hst.idtipo_lancto
              ,hst.cdoperacao_b3            
          FROM craplac lac
              ,craprac rac
              ,vw_capt_histor_operac hst
         WHERE rac.cdcooper = lac.cdcooper
           AND rac.nrdconta = lac.nrdconta
           AND rac.nraplica = lac.nraplica
           AND lac.cdcooper = pr_cdcooper
           -- Históricos de Aplicação
           AND hst.idtipo_arquivo = 1 -- Aplicação
           AND hst.tpaplicacao in(3,4)
           AND hst.cdprodut    = rac.cdprodut
           AND hst.cdhistorico = lac.cdhistor
           -- Utilizar a maior data entre os dois dias úteis anteriores
           -- e a data de início de envio das aplicações para custódia B3
           AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
		   -- E não podem ser do dia atual
           AND lac.dtmvtolt < pr_dtmvtolt
           --> Aplicação não custodiada ainda
           AND nvl(rac.idaplcus,0) = 0 
           --> Registro não custodiado ainda           
           AND nvl(lac.idlctcus,0) = 0
           --> Valor de aplicação maior ou igual ao valor mínimo
           AND lac.vllanmto >= nvl(pr_vlminctd,0); 
           
      -- Busca das Operações nas aplicações custodiadas não enviados a B3
      CURSOR cr_lctos_rgt(pr_cdcooper NUMBER
                         ,pr_dtmvtoan DATE
                         ,pr_dtmvtolt DATE
                         ,pr_dtinictd DATE) IS
        -- RDC Pré e RDC Pós
        SELECT *
          FROM (SELECT rda.idaplcus
                      ,lap.rowid rowid_lct
                      ,hst.tpaplicacao tpaplrdc
                      ,lap.nrdconta
                      ,lap.nraplica
                      ,0 cdprodut
                      ,lap.dtmvtolt
                      ,lap.cdhistor
                      ,lap.vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rda.dtmvtolt dtmvtapl
                      ,decode(capl.tpaplicacao,1,rda.qtdiaapl,rda.qtdiauti) qtdiacar
                      ,lap.progress_recid
					  ,lap.vlpvlrgt valorbase
					  ,hst.cdhistorico		
                  FROM craplap lap
                      ,craprda rda
                      ,crapdtc dtc
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                 WHERE rda.cdcooper = dtc.cdcooper
                   AND rda.tpaplica = dtc.tpaplica
                   AND lap.cdcooper = rda.cdcooper
                   AND lap.nrdconta = rda.nrdconta
                   AND lap.nraplica = rda.nraplica
                   AND lap.cdcooper = pr_cdcooper
                   AND rda.idaplcus = capl.idaplicacao
                   -- Somente resgates antecipados 
                   AND ( lap.dtmvtolt < rda.dtvencto)
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lap.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lap.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = dtc.tpaplrdc
                   AND hst.cdhistorico = lap.cdhistor
                   --> Registro não custodiado ainda
                   AND nvl(lap.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rda.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL
                UNION
                  -- Produtos de Captação
                SELECT rac.idaplcus
                      ,lac.rowid  
                      ,hst.tpaplicacao
                      ,lac.nrdconta
                      ,lac.nraplica
                      ,rac.cdprodut
                      ,lac.dtmvtolt
                      ,lac.cdhistor
                      ,lac.vllanmto
                      ,hst.idtipo_arquivo
                      ,hst.idtipo_lancto
                      ,hst.cdoperacao_b3 
                      ,capl.qtcotas
                      ,capl.vlpreco_registro
                      ,rac.dtmvtolt dtmvtapl
                      ,rac.qtdiacar
                      ,lac.progress_recid
					  ,lac.vlbasren valorbase
					  ,hst.cdhistorico
                  FROM craplac lac
                      ,craprac rac
                      ,tbcapt_custodia_aplicacao capl
                      ,vw_capt_histor_operac hst
                 WHERE rac.cdcooper = lac.cdcooper
                   AND rac.nrdconta = lac.nrdconta
                   AND rac.nraplica = lac.nraplica
                   AND lac.cdcooper = pr_cdcooper
                   AND rac.idaplcus = capl.idaplicacao
                   -- Somente resgates antecipados OU IRRF
                   AND ( lac.dtmvtolt < rac.dtvencto OR hst.idtipo_lancto = 3 )
                   -- Utilizar a maior data entre os dois dias úteis anteriores
                   -- e a data de início de envio das aplicações para custódia B3
                   AND lac.dtmvtolt >= greatest(pr_dtmvtoan,pr_dtinictd)
                   -- E não podem ser do dia atual
                   AND lac.dtmvtolt < pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao IN(3,4)
                   AND hst.cdprodut    = rac.cdprodut
                   AND hst.cdhistorico = lac.cdhistor
                   --> Registro não custodiado ainda                    
                   AND nvl(lac.idlctcus,0) = 0
                   --> Aplicação já custodiada
                   AND nvl(rac.idaplcus,0) > 0
                   AND capl.dscodigo_b3 IS NOT NULL) lct
         ORDER BY lct.dtmvtolt
                 ,lct.nrdconta
                 ,lct.nraplica
                 ,lct.idtipo_lancto
                 ,lct.vllanmto desc;
      rw_lcto_rgt cr_lctos_rgt%ROWTYPE;
      
      -- Valor total de resgate no dia
      CURSOR cr_resgat(pr_cdcooper crapcop.cdcooper%TYPE     --> Cooperativa
                      ,pr_nrdconta craprda.nrdconta%TYPE     --> Conta
                      ,pr_nraplica craprda.nraplica%TYPE     --> Aplicação
                      ,pr_tpaplrdc craprda.tpaplica%TYPE     --> TIpo da aplicação
                      ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS --> Data
        SELECT sum(nvl(lct.vllanmto,0))
          FROM (SELECT lap.vllanmto
                  FROM craplap lap
                      ,vw_capt_histor_operac hst
                 WHERE lap.cdcooper = pr_cdcooper
                   AND lap.nrdconta = pr_nrdconta
                   AND lap.nraplica = pr_nraplica
                   AND lap.dtmvtolt = pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = pr_tpaplrdc
                   AND hst.cdhistorico = lap.cdhistor
                   AND hst.idtipo_lancto = 2 -- Somente Resgate
                UNION
                  -- Produtos de Captação
                SELECT lac.vllanmto
                  FROM craplac lac
                      ,vw_capt_histor_operac hst
                 WHERE lac.cdcooper = pr_cdcooper
                   AND lac.nrdconta = pr_nrdconta
                   AND lac.nraplica = pr_nraplica
                   AND lac.dtmvtolt = pr_dtmvtolt
                   -- Históricos de Resgate
                   AND hst.idtipo_arquivo = 2 -- Resgate
                   AND hst.tpaplicacao = pr_tpaplrdc
                   AND hst.cdhistorico = lac.cdhistor
                   AND hst.idtipo_lancto = 2 -- Somente Resgate
                 ) lct;
                   

      TYPE typ_tab_reg_lanctos IS
        TABLE OF cr_lctos_rgt%ROWTYPE
        INDEX BY PLS_INTEGER;
                
      TYPE typ_reg_aplicacao IS
        TABLE OF typ_tab_reg_lanctos
        INDEX BY VARCHAR(028);
        
      vr_tab_reg_aplicacao typ_reg_aplicacao;
      vr_idx_aplic         VARCHAR(028);
      vr_idx               pls_integer;
      vr_tipo_lancto       tbcapt_custodia_lanctos.idtipo_lancto%TYPE;
      vr_aplicacao         tbcapt_custodia_aplicacao.idaplicacao%TYPE;

                   
      -- Conversão valor em cota
      vr_qtcotas      tbcapt_custodia_aplicacao.qtcotas%TYPE;  
         
      -- Variaveis para armazenar os IDs de aplicação e Registros Lanctos criados
      vr_idaplicacao  tbcapt_custodia_aplicacao.idaplicacao%TYPE;
      vr_idlancamento tbcapt_custodia_lanctos.idlancamento%TYPE;
      
      -- Variaveis para controle de troca de Data+Conta+Aplica
      vr_dtmvtolt DATE;
      vr_nrdconta craprda.nrdconta%TYPE;
      vr_nraplica craprda.nraplica%TYPE;
      
      -- Saldo da aplicação + cotas do resgate
      vr_sldaplic     craprda.vlsdrdca%TYPE;
      --vr_vlpreco_unit tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE; --NUMBER(25,8)
      vr_vlpreco_unit NUMBER(38,30);
      vr_vlbase       NUMBER(38,30);
      vr_qtcotas_resg tbcapt_custodia_aplicacao.qtcotas%TYPE; 
      
      -- Controle de lançamento anterior
      /*vr_cdhistor_ant craphis.cdhistor%TYPE;
      vr_idlancto_ant tbcapt_custodia_lanctos.idlancamento%TYPE;*/
         
      -- variaveis de contadores para geração de LOG
      vr_qtregrgt NUMBER := 0;
      vr_qtregreg NUMBER := 0;
              
    BEGIN
	    -- Inclusão do módulo e ação logado
	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_verifi_lanctos_custodia');
      
      -- Incluir LOG 
      pr_dsdaviso := fn_get_time_char||'Iniciando processo de Busca de Eventos para Criação de Registros e Operações a enviar...';
      
      -- Buscar todas as cooperatiVas ativas com exceção da Central
      FOR rw_cop IN cr_crapcop LOOP 
        -- Verifica se a data esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_cop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
        
        -- Buscar o dia útil anterior ao dtmvtoan, ou seja, iremos buscar 2 dias úteis atrás
        vr_dtmvto2a := gene0005.fn_valida_dia_util(pr_cdcooper => rw_cop.cdcooper
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtoan -1
                                                  ,pr_tipo => 'A');
        -- Se por acaso der algum erro
        IF vr_dtmvto2a IS NULL THEN
          -- Montar mensagem de critica
          vr_cdcritic:= 13;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
        
        -- Buscar parâmetros de sistema
        vr_dtinictd := to_date(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'INIC_CUSTODIA_APLICA_B3'),'dd/mm/rrrr');
        vr_vlinictd := to_number(gene0001.fn_param_sistema('CRED',rw_cop.cdcooper,'VLMIN_CUSTOD_APLICA_B3'),'FM999999990D00');
        
        -- Caso esteja habilitado o processo de registro das aplicações na B3
        IF pr_flenvreg = 'S' THEN 
          -- Buscar todos os movimentos de aplicação dos últimos 2 dias  
          -- que ainda não estejam marcados para envio (idlctcus is null)
          FOR rw_lcto IN cr_lctos(rw_cop.cdcooper,vr_dtmvto2a,rw_crapdat.dtmvtolt,vr_dtinictd,vr_vlinictd) LOOP
            -- Converter valor aplicação em contas
            vr_qtcotas := fn_converte_valor_em_cota(rw_lcto.vllanmto);
			
		   
            -- Devemos gerar o registro de Custódia Aplicação
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_APLICACAO
                         (tpaplicacao
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_registro
                         ,vlpreco_unitario)
                   VALUES(rw_lcto.tpaplrdc
                         ,rw_lcto.vllanmto
                         ,vr_qtcotas
                         ,vr_qtftcota
                         ,vr_qtftcota)
                RETURNING idaplicacao
                     INTO vr_idaplicacao;
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1034;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_APLICACAO: '
                            || 'tpaplicacao: '||rw_lcto.tpaplrdc
                            || ', vlregistro: '||rw_lcto.vllanmto
                            || ', qtcotas: '||vr_qtcotas
                            || ', vlpreco_registro: '||vr_qtftcota
                            || ', vlpreco_unitario: '||vr_qtftcota
                            ||'. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Devemos gerar o registro de CUstódia do Lançamento
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LANCTOS
                         (idaplicacao
                         ,idtipo_arquivo
                         ,idtipo_lancto
                         ,cdhistorico
                         ,cdoperacao_b3
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_unitario
                         ,idsituacao
                         ,dtregistro)
                   VALUES(vr_idaplicacao
                         ,rw_lcto.idtipo_arquivo
                         ,rw_lcto.idtipo_lancto
                         ,rw_lcto.cdhistor
                         ,rw_lcto.cdoperacao_b3
                         ,rw_lcto.vllanmto
                         ,vr_qtcotas
                         ,vr_qtftcota
                         ,0 -- Pendente de Envio
                         ,rw_lcto.dtmvtolt)
                RETURNING idlancamento
                     INTO vr_idlancamento;
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1034;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LANCTOS: '
                            || 'idaplicacao: '||vr_idaplicacao
                            || ', idtipo_arquivo: '||rw_lcto.idtipo_arquivo
                            || ', idtipo_lancto: '||rw_lcto.idtipo_lancto
                            || ', cdhistor: '||rw_lcto.cdhistor
                            || ', cdoperacao_b3: '||rw_lcto.cdoperacao_b3
                            || ', vlregistro: '||rw_lcto.vllanmto
                            || ', qtcotas: '||vr_qtcotas
                            || ', vlpreco_unitario: '||vr_qtftcota
                            || ', idsituacao: '||0 -- Pendente de Envio
                            || ', dtregistro: '||rw_lcto.dtmvtolt
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Para aplicações de captação
            IF rw_lcto.tpaplrdc IN(3,4) THEN 
              -- Atualizar a tabela CRAPRAC
              BEGIN
                UPDATE craprac
                   SET idaplcus = vr_idaplicacao
                 WHERE ROWID = rw_lcto.rowid_apl;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprac: '
                              || 'idaplcus:' || vr_idaplicacao 
                              || ' com ROWID: '||rw_lcto.rowid_apl||'. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Atualizar a tabela CRAPLAC
              BEGIN
                UPDATE craplac
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craplac: '
                              || 'idlctcus:' || vr_idlancamento 
                              || ' com ROWID: '||rw_lcto.rowid_lct||'. '||sqlerrm;
                  RAISE vr_exc_saida;
              END; 
            ELSE 
              -- Atualizar a tabela CRAPRDA 
              BEGIN
                UPDATE craprda
                   SET idaplcus = vr_idaplicacao
                 WHERE ROWID = rw_lcto.rowid_apl;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craprda: '
                              || 'idaplcus:' || vr_idaplicacao 
                              || ' com ROWID: '||rw_lcto.rowid_apl||'. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Atualizar a tabela CRAPLAP
              BEGIN
                UPDATE craplap 
                   SET idlctcus = vr_idlancamento
                 WHERE ROWID = rw_lcto.rowid_lct;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craplap: '
                              || 'idlctcus:' || vr_idlancamento 
                              || ' com ROWID: '||rw_lcto.rowid_lct||'. '||sqlerrm;
                  RAISE vr_exc_saida;
              END; 
            END IF;
            -- Incrementar contador de Registros
            vr_qtregreg := vr_qtregreg + 1;
          END LOOP;
        END IF;
        
        -- Caso esteja habilitado o processo de envio das Operações a B3
        IF pr_flenvrgt = 'S' THEN 
          -- Inicializar variáveis
          vr_dtmvtolt := to_date('01011900','ddmmrrrr');
          vr_nrdconta := 0;
          vr_nraplica := 0;
          vr_qtcotas  := 0;
          vr_sldaplic := 0;
          /*vr_cdhistor_ant := 0;
          vr_idlancto_ant := 0;*/
          
          
          /* Logica responsavel por agrupar os lancamentos de RESGATE, IR e RENDIMENTO. Como nao existe
             um campo que vincule esses lancamentos, vamos realizar o vinculo através da ordenacao
             sobre o tipo de lancamento e o valor.
             O objetivo eh povoar um tabela de memoria com as aplicacoes (indice vr_idx_aplic) com uma
             posicao para cada resgate daquele dia (vr_idx). Como o valor estah ordenado descrescente,
             cada vez que estiver no cursor um lcto de IR ou RENDIMENTO, ele agruparah com os resgates
             de forma decrescente.
             - Pode existir resgates que nao tenham IR e RENDIMENTO, nesse caso ficarah apenas o registro
             do resgate mesmo.
             - O SQL pode retornar lctos de IR e RENDIMENTO que nao possuem resgate, pois os resgates jah
             foram enviados em outra ocasiao. Nesse cenario apenas ignoraremos os registros.
          */                 
          vr_idx_aplic   := '';
          vr_idx         := 0;
          vr_tipo_lancto := 0;
          vr_aplicacao   := 0;
          vr_tab_reg_aplicacao.delete();
          
          FOR rw_lcto IN cr_lctos_rgt(rw_cop.cdcooper,vr_dtmvto2a,rw_crapdat.dtmvtolt,vr_dtinictd) LOOP
          
                                         
             -- Se mudou aplicacao ou o historico reinicia o vr_idx de resgate
             IF vr_aplicacao <> rw_lcto.idaplcus or vr_dtmvtolt <> rw_lcto.dtmvtolt or vr_tipo_lancto <> rw_lcto.idtipo_lancto THEN
                vr_idx := 0;
             END IF;
               
             -- indice sera a aplicacao + data do lcto
             vr_idx_aplic := lpad(rw_lcto.idaplcus,20,'0') || to_char(trunc(rw_lcto.dtmvtolt),'rrrrmmdd');
             
             IF rw_lcto.idtipo_lancto = 2 THEN /* Resgate */
                vr_idx := vr_idx + 1;
                vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx) := rw_lcto;
                vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := rw_lcto.vllanmto;
             ELSIF rw_lcto.idtipo_lancto = 3 THEN /* IR */
               vr_idx := vr_idx + 1;
               IF vr_tab_reg_aplicacao.exists(vr_idx_aplic) THEN
                 IF vr_tab_reg_aplicacao(vr_idx_aplic).exists(vr_idx) THEN
                   vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase + rw_lcto.vllanmto;
                 END IF;
               END IF;
             ELSIF rw_lcto.idtipo_lancto = 4 THEN /* Rendimento */
               vr_idx := vr_idx + 1;
               IF vr_tab_reg_aplicacao.exists(vr_idx_aplic) THEN
                 IF vr_tab_reg_aplicacao(vr_idx_aplic).exists(vr_idx) THEN
                   vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx).valorbase - rw_lcto.vllanmto;
                 END IF;
               END IF;
             END IF;             
             -- Armazena ultimos valores aplicacao, tipo lcto e data
             vr_aplicacao   := rw_lcto.idaplcus;
             vr_tipo_lancto := rw_lcto.idtipo_lancto;
             vr_dtmvtolt    := rw_lcto.dtmvtolt;          
          END LOOP;
          
          -- Navega a tabela de memoria
          vr_idx_aplic:= vr_tab_reg_aplicacao.FIRST;
          WHILE vr_idx_aplic IS NOT NULL LOOP
            
            -- Navegar todos os resgates daquela aplicacao
            vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).FIRST;
            WHILE vr_idx IS NOT NULL LOOP
              rw_lcto_rgt := vr_tab_reg_aplicacao(vr_idx_aplic)(vr_idx);
              
              /* No primeiro resgate, busca o PU da aplicacao */
              IF vr_idx = 1 THEN
                -- Armazenar quantidade de cotas 
                vr_qtcotas := rw_lcto_rgt.qtcotas;
                -- Quando não houver carencia
                IF fn_tem_carencia(pr_dtmvtapl => rw_lcto_rgt.dtmvtapl
                                  ,pr_qtdiacar => rw_lcto_rgt.qtdiacar
                                  ,pr_dtmvtres => rw_lcto_rgt.dtmvtolt) = 'N' THEN  
                  -- Calcular saldo da aplicação anteriormente ao(s) resgates
                  vr_sldaplic := 0;
                  pc_busca_saldo_anterior(pr_cdcooper  => rw_cop.cdcooper         --> Cooperativa
                                         ,pr_nrdconta  => rw_lcto_rgt.nrdconta        --> Conta
                                         ,pr_nraplica  => rw_lcto_rgt.nraplica        --> Aplicação
                                         ,pr_tpaplica  => rw_lcto_rgt.tpaplrdc        --> Tipo aplicação
                                         ,pr_cdprodut  => rw_lcto_rgt.cdprodut        --> Codigo produto 
                                         ,pr_dtmvtolt  => rw_crapdat.dtmvtolt     --> Data movimento
                                         ,pr_dtmvtsld  => rw_lcto_rgt.dtmvtolt        --> Data do saldo desejado
                                         ,pr_tpconsul  => 'R'                     --> Resgates
                                         ,pr_sldaplic  => vr_sldaplic             --> Saldo na data
                                         ,pr_idcritic => vr_idcritic              --> Identificador critica
                                         ,pr_cdcritic => vr_cdcritic              --> Codigo da critica
                                         ,pr_dscritic => vr_dscritic);            --> Retorno de críticaca
                  -- Código comum, para gravação do LOG independente de sucesso ou não
                  IF vr_dscritic IS NOT NULL THEN
                    -- Houve erro
                    vr_dscritic := 'Nao foi possivel buscar saldo Anterior Cooper '||rw_cop.cdcooper
                                || ',Conta '||rw_lcto_rgt.nrdconta
                                || ',Aplica '||rw_lcto_rgt.nraplica
                                || ',Data Solicitada '||rw_lcto_rgt.dtmvtolt
                                ||' -> '|| vr_dscritic;
                    RAISE vr_exc_saida;
                  END IF;
                  -- Se o saldo for zero, significa que houve um resgate total, então precisamos buscar 
                  -- o valor dos resgates efetuados neste dia para a conta e aplicação
                  IF vr_sldaplic = 0 THEN
                    OPEN cr_resgat(pr_cdcooper  => rw_cop.cdcooper    --> Cooperativa
                                  ,pr_nrdconta  => rw_lcto_rgt.nrdconta   --> Conta
                                  ,pr_nraplica  => rw_lcto_rgt.nraplica   --> Aplicação
                                  ,pr_tpaplrdc  => rw_lcto_rgt.tpaplrdc   --> TIpo da aplicação
                                  ,pr_dtmvtolt  => rw_lcto_rgt.dtmvtolt); --> Data
                  
                    FETCH cr_resgat 
                     INTO vr_sldaplic;
                    CLOSE cr_resgat;
                  END IF; 
                  -- Se mesmo assim ainda está zero, vamos usar o próprio valor do lançamento como saldo
                  IF vr_sldaplic = 0 THEN
                    vr_sldaplic := rw_lcto_rgt.vllanmto;
                  END IF;
                  -- Calcular preço unitario
                  IF vr_qtcotas = 0 THEN
                    -- pula para o proximo resgate, se houver
                    vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);
                    continue;
                  ELSE
                    vr_vlpreco_unit := vr_sldaplic / vr_qtcotas;
                  END IF;
                ELSE
                  -- Quando carencia usar sempre a pu da emissão
                  vr_vlpreco_unit := rw_lcto_rgt.vlpreco_registro;
                END IF;
              END IF;
            
              vr_qtcotas_resg := fn_converte_valor_em_cota(rw_lcto_rgt.valorbase);

              -- Devemos gerar o registro de CUstódia do Lançamento
              BEGIN
                INSERT INTO TBCAPT_CUSTODIA_LANCTOS
                         (idaplicacao
                         ,idtipo_arquivo
                         ,idtipo_lancto
                         ,cdhistorico
                         ,cdoperacao_b3
                         ,vlregistro
                         ,qtcotas
                         ,vlpreco_unitario
                         ,idsituacao
                         ,dtregistro
                         /*,idlancto_origem*/)
                     VALUES(rw_lcto_rgt.idaplcus
                           ,rw_lcto_rgt.idtipo_arquivo
                           ,rw_lcto_rgt.idtipo_lancto
                           ,rw_lcto_rgt.cdhistor
                           ,rw_lcto_rgt.cdoperacao_b3
                           ,rw_lcto_rgt.vllanmto
                           ,vr_qtcotas_resg
                           ,vr_vlpreco_unit
                           ,0 -- Pendente de Envio
                           ,rw_lcto_rgt.dtmvtolt
                           /*,vr_idlancto_ant*/)
                 RETURNING idlancamento
                      INTO vr_idlancamento;
              EXCEPTION
                WHEN OTHERS THEN
                 -- Erro não tratado 
                  vr_cdcritic := 1034;   
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LANCTOS: '
                              || 'idaplicacao: '||rw_lcto_rgt.idaplcus
                              || ', idtipo_arquivo: '||rw_lcto_rgt.idtipo_arquivo
                              || ', idtipo_lancto: '||rw_lcto_rgt.idtipo_lancto
                              || ', cdhistor: '||rw_lcto_rgt.cdhistor
                              || ', cdoperacao_b3: '||rw_lcto_rgt.cdoperacao_b3
                              || ', vlregistro: '||rw_lcto_rgt.vllanmto
                              || ', qtcotas: '||vr_qtcotas_resg
                              || ', vlpreco_unitario: '||vr_vlpreco_unit
                              || ', idsituacao: '||0 -- Pendente de Envio
                              || ', dtregistro: '||rw_lcto_rgt.dtmvtolt
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
            
              -- Guardar id do lançamento gerado
              --vr_idlancto_ant := vr_idlancamento;
            
              -- Para aplicações de captação
              IF rw_lcto_rgt.tpaplrdc in(3,4) THEN 
                -- Atualizar a tabela CRAPLAC
                BEGIN
                  UPDATE craplac
                     SET idlctcus = vr_idlancamento
                     WHERE ROWID = rw_lcto_rgt.rowid_lct;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craplac: '
                                || 'idlctcus:' || vr_idlancamento 
                                || ' com ROWID: '||rw_lcto_rgt.rowid_lct||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                END; 
              ELSE 
                -- Atualizar a tabela CRAPLAP
                BEGIN
                  UPDATE craplap 
                     SET idlctcus = vr_idlancamento
                     WHERE ROWID = rw_lcto_rgt.rowid_lct;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' craplap: '
                                || 'idlctcus:' || vr_idlancamento 
                                  || ' com ROWID: '||rw_lcto_rgt.rowid_lct||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                END; 
              END IF;
            
              -- Atualizar a quantidade de cotas e valor unitário no registro da aplicação
              BEGIN 
                UPDATE tbcapt_custodia_aplicacao apl
                   SET apl.qtcotas = greatest(0,apl.qtcotas-vr_qtcotas_resg)
                      ,apl.vlpreco_unitario = vr_vlpreco_unit
                   WHERE apl.idaplicacao = rw_lcto_rgt.idaplcus;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_aplicacao: '
                              || 'qtcotas: qtcotas-'||vr_qtcotas_resg
                              || ' com idaplicacao : '||rw_lcto_rgt.idaplcus
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida;
              END; 
              -- Incrementar contador de Registros
              vr_qtregrgt := vr_qtregrgt + 1;
              
              vr_idx := vr_tab_reg_aplicacao(vr_idx_aplic).NEXT(vr_idx);
            END LOOP;
          
          
            vr_idx_aplic:= vr_tab_reg_aplicacao.NEXT(vr_idx_aplic);
          END LOOP;
        END IF;
      END LOOP;  
      
      -- Caso não esteja habilitado o processo de registro das aplicações na B3
      IF pr_flenvreg <> 'S' THEN 
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro será criado pois a opção está Desativada!';
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Registros de Aplicação Gerados: '||vr_qtregreg;
      END IF;  
      
      -- Caso não esteja habilitado o processo de envio dos Resgates a B3
      IF pr_flenvrgt <> 'S' THEN 
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum Registro de Operação será criado pois a opção está Desativada!';        
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de Operações em Aplicação Gerados: '||vr_qtregrgt;
      END IF;
      
      -- Gravação dos registros atualizados
      COMMIT;
     
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_verifi_lanctos_custodia' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_verifi_lanctos_custodia' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                 
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_verifi_lanctos_custodia;
  
  -- Função para montar o Header conforme o tipo do arquivo
  FUNCTION fn_gera_header_arquivo(pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                 ,pr_dtarquivo      tbcapt_custodia_arquivo.dtcriacao%TYPE)      -- Data Arquivo
                         RETURN VARCHAR2 IS
  -- Pr_idtipo_arquivo:
  --  1 - Registro  : Layout 4.1.19
  --  2 - Operações : Layout 4.1.37
  BEGIN 
    DECLARE   
      vr_dsretorn VARCHAR2(44);    
    BEGIN
      -- Tipo IF e Tipo Registro
      vr_dsretorn := 'RDB  0'; 
      -- Ação
      IF pr_idtipo_arquivo = 1 THEN
        vr_dsretorn := vr_dsretorn || 'INCL';
      ELSIF pr_idtipo_arquivo = 2 THEN
        vr_dsretorn := vr_dsretorn || 'LCOP';        
      ELSE
        vr_dsretorn := vr_dsretorn || '????';
      END IF;
      -- Nome Simplificado e Data 
      vr_dsretorn := vr_dsretorn || vr_nmsimplf || to_char(pr_dtarquivo,'RRRRMMDD');      
      -- Versão conforme tipo
      IF pr_idtipo_arquivo = 1 THEN
        vr_dsretorn := vr_dsretorn || '00009';
      ELSIF pr_idtipo_arquivo = 2 THEN
        vr_dsretorn := vr_dsretorn || '00014';        
      ELSE
        vr_dsretorn := vr_dsretorn || '00000';
      END IF;
      -- E finalizar com Delimintador de término de linha para tipos 1 e 2
      IF pr_idtipo_arquivo IN(1,2) THEN
        vr_dsretorn := vr_dsretorn || vr_dsfimlin;
      END IF;  
      -- Retornar Header montado
      RETURN vr_dsretorn;
    END;  
  END fn_gera_header_arquivo;  
  
  -- Função para gerar Lançamento de Registro de Operação
  FUNCTION fn_gera_lancto_operacao(pr_cd_registrador NUMBER                                    -- Código Registrador 
                                  ,pr_cd_favorecido  NUMBER                                    -- Código Favorecido
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE -- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                     -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE)                    -- Conta
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.37
  BEGIN 
    DECLARE   
      -- LInha montada
      vr_dsretorn VARCHAR2(523);    
      -- BUsca detalhes do lançamento 
      CURSOR cr_lcto IS
        SELECT apl.dscodigo_b3
              ,lct.cdoperacao_b3
              ,lct.vlregistro
              ,lct.dtregistro
              ,lct.qtcotas
              ,lct.vlpreco_unitario
              ,lct.idlancto_origem
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;
      -- Quantidade, valores de cotas, e valor aplicado
      vr_vlqtcota VARCHAR2(14); 
      vr_vluntemi VARCHAR2(18); 
      vr_vlfinemi VARCHAR2(18);       
      -- Data quando resgate retroativo
      vr_dsdtretr VARCHAR2(8);
      -- Busca dos dados da conta
      CURSOR cr_crapass IS
        SELECT decode(ass.inpessoa,1,to_char(ass.nrcpfcgc,'fm00000000000'),to_char(ass.nrcpfcgc,'fm00000000000000')) nrcpfcgc
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_ass cr_crapass%ROWTYPE;
      -- Busca da operação cetip do registro origem
      CURSOR cr_origem(pr_idlancto_origem tbcapt_custodia_lanctos.idlancto_origem%TYPE) IS
        SELECT to_char(lct.cdoperac_cetip,'fm0000000000000000')
          FROM tbcapt_custodia_lanctos lct
         WHERE lct.idlancamento = pr_idlancto_origem
           AND lct.Idsituacao = 8;
      vr_cdoperac_cetip VARCHAR2(16);
    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- Busca dos dados da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_ass;
      CLOSE cr_crapass;
      
      -- Montar data do resgate retroativa pois sempre estamos rodando no dia posterior
      vr_dsdtretr := to_char(rw_lcto.dtregistro,'rrrrmmdd');
      
      -- Somente para operações de resgate
      IF rw_lcto.cdoperacao_b3 <> '0064' THEN
        -- Converter quantidade de cotas em texto
        vr_vlqtcota := to_char(rw_lcto.qtcotas,'fm00000000000000');
        -- Converter valor unitário para o formato esperado
        vr_vluntemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      ELSE
        vr_vlqtcota := '              ';
        vr_vluntemi := '                  ';
      END IF;
      
      -- Converter valor da operação
      vr_vlfinemi := replace(replace(to_char(rw_lcto.vlregistro,'fm0000000000000d00'),',',''),'.','');
      
      -- Se houver operação origem
      IF rw_lcto.idlancto_origem IS NOT NULL THEN
        -- Busca da operação cetip do registro origem
        OPEN cr_origem(rw_lcto.idlancto_origem);
        FETCH cr_origem
         INTO vr_Cdoperac_Cetip;
        CLOSE cr_origem;
      ELSE
        vr_cdoperac_cetip := RPAD(' ',16,' ');
      END IF;
      
      -- Enfim, enviar as informações para a linha 
      vr_dsretorn /* Registro da Operação */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '1'                                           -- 02 - TIpo Registro
                  || lpad(rw_lcto.cdoperacao_b3,4,'0')             -- 03 - Código da Operação
                  || lpad(rw_lcto.dscodigo_b3,14,' ')              -- 04 - Código IF
                  || ' '                                           -- 05 - IF Com Restrição
                  || '01'                                          -- 06 - Tipo Compra/Venda
                  || TO_CHAR(pr_cd_favorecido,'fm00000000')        -- 07 - Conta da Parte Transferidor
                  || to_char(fn_sequence('TBCAPT_CUSTODIA_CONTEUDO_ARQ','NRMEUNUM',TO_CHAR(SYSDATE,'rrrrmmdd')),'fm0000000000') -- 08 - Meu Numero
                  || RPAD(' ',16,' ')                              -- 09 - Filler(16)
                  || '      '                                      -- 10 - Número de Associação
                  || TO_CHAR(pr_cd_registrador,'fm00000000')       -- 11 - Conta da Contraparte / Adquirente
                  || vr_vlqtcota                                   -- 12 - Quantidade da operação
                  || vr_vlfinemi                                   -- 13 - Valor da Operação
                  || vr_vluntemi                                   -- 14 - Preço Unitário da Operação
                  || '0'                                           -- 15 - Código da Modalidade de Liquidação
                  || '        '                                    -- 16 - Conta do Banco Liquidate 
                  /* Retorno de Compromisso */
                  || '        '                                    -- 17 - Data de Compromisso
                  || '                  '                          -- 18 - Preço Unitário do COmpromisso
                  /* Antecipações/Desvinculações/Lançamentos PU de COmpromisso/TRansferências/Cancelamentos */
                  || ' '                                           -- 19 - Reserva técnica
                  || vr_dsdtretr                                   -- 20 - Data da Operação Original / DAta da Subscrição / Data Operação Original Antecipação
                  || vr_cdoperac_cetip                             -- 21 - Número da Operação Cetip Original
                  /* Transferência de Ativos para Garantia / Margem */
                  || ' '                                           -- 22 - Direitos do Caucionante
                  || '        '                                    -- 23 - Conta Investido / Garantidor
                  || ' '                                           -- 24 - Tipo de Garantia
                  /* Dados Complementares para Especificação Automática do Comitente */
                  || rpad(rw_ass.nrcpfcgc,18,' ')                  -- 25 - CPF/CNPJ Cliente
                  || rw_ass.dspessoa                               -- 26 - Natureza (Emitente)
                  || RPAD(' ',100,' ')                             -- 27 - MOtivo [X(100)] Livre
                  || RPAD(' ',100,' ')                             -- 28 - Filler(100)
                  /* Dados Complementares para TrasnferÊncia de IF Bolsa */
                  || '        '                                    -- 29 - Conta Corretora
                  || '                  '                          -- 30 - CNPJ Corretora
                  || '                  '                          -- 31 - CPF/CNPJ Detentor
                  || ' '                                           -- 32 - Filler (1)
                  || ' '                                           -- 33 - RetiraDEB
                  || '  '                                          -- 34 - Filler(2)
                  || '  '                                          -- 35 - Tipo de Bloqueio
                  || '        '                                    -- 36 - Data de Liquidação
                  || ' '                                           -- 37 - Ciência de Liquidação Antecipada
                  /* Dados Complementares para Depósito de CSEC */   
                  || ' '                                           -- 38 - Gerar Eventos Vencidos Não Pagos
                  || '        '                                    -- 39 - Data de Pagamento Eventos Vencidos Não Pagos
                  || '                  '                          -- 40 - CPF /CNPJ Eventos Vencidos Não PAgos
                  || '  '                                          -- 41 - Natureza Eventos Vencidos Não Pagos
                  || RPAD(' ',20,' ')                              -- 42 - Filler (20)
                  || '  '                                          -- 43 - Tipo de Carteira
                  || vr_dsfimlin;                                  -- 44 - Delimitador de Final de Linha   
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;  
  END fn_gera_lancto_operacao;   
  
  -- Função para gerar registro das Aplicações
  FUNCTION fn_gera_regist_operacao(pr_cd_registrador NUMBER                                   -- Código Registrador 
                                  ,pr_cd_favorecido  NUMBER                                   -- Código Favorecido
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE-- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                    -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE                    -- Conta
                                  ,pr_vet_aplica     APLI0001.typ_reg_saldo_rdca)             -- Tabela com informações da aplicacao
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.19
  BEGIN 
    DECLARE   
      -- LInha montada
      vr_dsretorn VARCHAR2(1578); 
      -- BUsca detalhes do lançamento 
      CURSOR cr_lcto IS
        SELECT apl.idaplicacao
              ,apl.dscodigo_b3
              ,lct.cdoperacao_b3
              ,lct.vlregistro
              ,apl.tpaplicacao
              ,lct.dtregistro
              ,lct.qtcotas
              ,lct.vlpreco_unitario
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;
      
      -- Busca dos dados da conta
      CURSOR cr_crapass IS
        SELECT decode(ass.inpessoa,1,to_char(ass.nrcpfcgc,'fm00000000000'),to_char(ass.nrcpfcgc,'fm00000000000000')) nrcpfcgc
              ,decode(ass.inpessoa,1,'PF','PJ') dspessoa
          FROM crapass ass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_ass cr_crapass%ROWTYPE;
      
      -- Buscar as taxas contratadas
      CURSOR cr_craplap IS
        SELECT lap.txaplica
          FROM craplap lap
         WHERE lap.cdcooper = pr_cdcooper
           AND lap.nrdconta = pr_nrdconta
           AND lap.nraplica = pr_vet_aplica.nraplica
           AND lap.dtmvtolt = pr_vet_aplica.dtmvtolt
         ORDER BY lap.progress_recid ASC; --> Retornar a primeira encontrada
      
      -- Campos genéricos cfme tipo
      vr_cdfrmpag VARCHAR2(2);
      vr_nrrentab VARCHAR2(4);
      vr_cricljur VARCHAR2(2);
      vr_vlfinrgt VARCHAR2(18);
      vr_prtaxflt VARCHAR2(7);
      vr_vltxjrsp VARCHAR2(8);
      
      -- Calculo para RDC PRé
      vr_txaplica NUMBER(18,8); --> Taxa de aplicacao
      vr_dtcalcul DATE;         --> Receber a data de parametro a acumular os dias
      vr_vlrendim NUMBER(18,8); --> Auxiliar para calculo dos rendimentos da aplicacao
      vr_vlsdrdca NUMBER(18,4) := 0; --> Totalizador do saldo rdca
      
      -- Quantidade, valores de cotas, e valor aplicado
      vr_vlqtcota VARCHAR2(14); 
      vr_vluntemi VARCHAR2(18); 
      vr_vlfinemi VARCHAR2(18); 
      vr_vlunitar VARCHAR2(18);
      vr_dsdataem VARCHAR2(8);
      
      
    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- Busca dos dados da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_ass;
      CLOSE cr_crapass;
      -- Para aplicações Pré
      IF rw_lcto.tpaplicacao in(1,3) THEN
        vr_cdfrmpag := '01';
        vr_nrrentab := '0099';
        vr_cricljur := '01';
        -- Se houve retorno da taxa já no vetor (Produto nOvo de captação
        IF trim(pr_vet_aplica.txaplmax) IS NOT NULL THEN
          -- Utilizar a mesma 
          vr_txaplica := gene0002.fn_char_para_number(pr_vet_aplica.txaplmax);
        ELSE
          -- Buscaremos a taxa contratada 
          OPEN cr_craplap;
          FETCH cr_craplap
           INTO vr_txaplica;
          CLOSE cr_craplap; 
        END IF;
        -- Calcular percentual
        vr_txaplica := TRUNC(vr_txaplica / 100,8);
        -- Iniciar saldo com valor aplicado
        vr_vlsdrdca := pr_vet_aplica.vlaplica;
        -- Iniciar data para calculo com data inicial enviada
        vr_dtcalcul := pr_vet_aplica.dtmvtolt;
        -- Verifica dias uteis e calcula os rendimentos
        LOOP
          -- Validar se a data auxiliar e util e se não for trazer a primeira apos
          vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtcalcul);
          -- Continuar enquanto a data auxiliar de calculo for inferior a data final
          EXIT WHEN vr_dtcalcul >= pr_vet_aplica.dtvencto;
          -- Acumular os rendimentos com base no saldo RCA * taxa
          vr_vlrendim := TRUNC((vr_vlsdrdca * vr_txaplica),8);
          -- Acumular no saldo RCA o rendimento calculado
          vr_vlsdrdca := vr_vlsdrdca + vr_vlrendim;
          -- Incrementar mais um dia na data auxiliar para processar o proximo dia
          vr_dtcalcul := vr_dtcalcul + 1;
        END LOOP; --> Fim da do calculos nos dias uteis
        -- Arredondar saidas de rendimento total e saldo
        --vr_vlsdrdca := apli0001.fn_round(vr_vlsdrdca,2);        
        -- Saldo previsto de resgate
        --vr_vlfinrgt := replace(replace(to_char(vr_vlsdrdca,'fm0000000000000000D00'),',',''),'.',''); 
        vr_prtaxflt := '       ';
        -- Retornar ao valor original
        vr_txaplica := TRUNC(vr_txaplica * 100,8);
		-- Converte para taxa anual
        vr_txaplica := fn_get_taxa_anual(vr_txaplica);
        vr_vltxjrsp := REPLACE(REPLACE(TO_CHAR(vr_txaplica,'fm0000d0000'),',',''),'.','');
      ELSE
        vr_cdfrmpag := '01';
        vr_nrrentab := '0003';  
        vr_cricljur := '  ';
        vr_prtaxflt := replace(replace(to_char(gene0002.fn_char_para_number(pr_vet_aplica.txaplmax),'fm00000d00'),',',''),'.','');
        vr_vltxjrsp := '        ';
      END IF;
      -- valor financeiro para resgate
      vr_vlfinrgt := '                  ';
      -- Converter quantidade de cotas em texto
      vr_vlqtcota := to_char(rw_lcto.qtcotas,'fm00000000000000');
      -- Converter valor unitário para o formato esperado
      vr_vluntemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      -- Trasnformar data em texto
      vr_dsdataem := to_char(pr_vet_aplica.dtmvtolt,'RRRRMMDD');      
      -- Converter valor unitário para o formato esperado
      vr_vlunitar := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlpreco_unitario,'fm0000000000d00000000'),',',''),'.','');
      -- Converter valor emissão para o formato esperado      
      vr_vlfinemi := REPLACE(REPLACE(TO_CHAR(rw_lcto.vlregistro,'fm0000000000000000d00'),',',''),'.','');
      -- Enfim, montar o registro com as informações retornadas
      vr_dsretorn /* Registro da RDB */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '1'                                           -- 02 - TIpo Registro
                  || 'INCL'                                        -- 03 - Ação
                  || lpad(nvl(rw_lcto.dscodigo_b3,' '),14,' ')     -- 04 - Codigo IF
                  || '0000'                                        -- 05 - Quantidade de Linhas Adicionais
                  || TO_CHAR(pr_cd_registrador,'fm00000000')       -- 06 - Conta do Registrador
                  || '            '                                -- 07 - Código ISIN
                  || to_char(pr_vet_aplica.dtmvtolt,'RRRRMMDD')    -- 08 - Data da Emissão
                  || to_char(pr_vet_aplica.dtvencto,'RRRRMMDD')    -- 09 - Data de Vencimento
                  || to_char(pr_vet_aplica.qtdiaapl,'fm0000000000')-- 10 - Prazo de Emissão
                  || vr_vlqtcota                                   -- 11 - Quantidade Emitida
                  || vr_vluntemi                                   -- 12 - VAlor Unitário de Emissão
                  || vr_vlfinemi                                   -- 13 - Valor Financeiro de Emissão
                  || vr_vlunitar                                   -- 14 - Valor Unitário
                  || vr_dsdataem                                   -- 15 - Data Em
                  || vr_vlfinrgt                                   -- 16 - Valor FInanceiro de Resgate
                  || ' '                                           -- 17 - Cód. Múltiplas Curvas
                  || ' '                                           -- 18 - Escalonamento
                  || RPAD(' ',200,' ')                             -- 19 - Descrição Adicional (Campo Livre)
                  || 'N'                                           -- 20 - Condição de Resgate Antecipado
                  || vr_cdfrmpag                                   -- 21 - Forma de PAgamento
                  /*Forma de Pagamento*/
                  || vr_nrrentab                                   -- 22 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 23 - Periodicidade de Correção
                  || ' '                                           -- 24 - Pro-Rata de Correção
                  || ' '                                           -- 25 - Tipo de Correção
                  || vr_prtaxflt                                   -- 26 - % Taxa Flutuante
                  || vr_vltxjrsp                                   -- 27 - TAxa de Juros/Spread
                  || vr_cricljur                                   -- 28 - Critério de Cálculo de Juros
                  || '     '                                       -- 29 - Qualificação VCP
                  || RPAD(' ',200,' ')                             -- 30 - Descrição VCP
                  || 'N'                                           -- 31 - Incorpora JUros
                  || '        '                                    -- 32 - Data da Incorporação de JUros
                  || '  '                                          -- 33 - Dia de Atualização
                  || '    '                                        -- 34 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 35 - Periodicidade de Correção
                  || ' '                                           -- 36 - Pro-rata de Correção
                  || ' '                                           -- 37 - TIpo de Correção
                  || '       '                                     -- 38 - % da Taxa Flutuante
                  || '        '                                    -- 39 - Taxa de Juros/Spread
                  || '  '                                          -- 40 - Critério de cálculo de juros
                  || '    '                                        -- 41 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 42 - Periodicidade de Correção
                  || ' '                                           -- 43 - Pro-rata de Correção
                  || ' '                                           -- 44 - Tipo de Correção
                  || '       '                                     -- 45 - % da TAxa Flutuante
                  || '        '                                    -- 46 - Taxa de Juros/Spread 
                  || '  '                                          -- 47 - Critério de cálculo de juros
                  || '    '                                        -- 48 - Rentabilidade / Indexador / Taxa
                  || ' '                                           -- 49 - Periodicidade de Correção
                  || ' '                                           -- 50 - Pro-rata de Correção
                  || ' '                                           -- 51 - Tipo de Correção
                  || '       '                                     -- 52 - %Taxa Flutuante
                  || '        '                                    -- 53 - TAxa de Juros/Spread
                  || '  '                                          -- 54 - Critério de Cálculo de JUros
                  /* Fluxo de PAgamento de JUros Periódicos */
                  || ' '                                           -- 55 - Periodicidade de Juros
                  || '          '                                  -- 56 - Juros a cada
                  || ' '                                           -- 57 - Tipo Unidade de Tempo
                  || ' '                                           -- 58 - Tipo Prazo
                  || '        '                                    -- 59 - Data Início dos JUros
                  || '  '                                          -- 60 - Dia do Evento dos JUros
                  /* Fluxo de Pagamento de Amortização Periódicas */
                  || ' '                                           -- 61 - Tipo de Amortização
                  || '          '                                  -- 62 - Amortização a cada
                  || ' '                                           -- 63 - Tipo Unidade de Tempo
                  || ' '                                           -- 64 - TIpo Prazo
                  || '        '                                    -- 65 - Data Inicio da Amortização
                  || '  '                                          -- 66 - Dia do Evento da Amortização
                  /* Dados para Depósito */
                  || TO_CHAR(pr_cd_favorecido,'fm00000000')        -- 67 - Conta do FAvorecido
                  || rpad(rw_ass.nrcpfcgc,18,' ')                  -- 68 - CPF/CNPJ do Cliente
                  || rw_ass.dspessoa                               -- 69 - NAtureza CLiente
                  || to_char(fn_sequence('TBCAPT_CUSTODIA_CONTEUDO_ARQ','NRMEUNUM',TO_CHAR(SYSDATE,'rrrrmmdd')),'fm0000000000') -- 70 - Meu nùmero
                  || vr_vluntemi                                   -- 71 - P.U.
                  || '0'                                           -- 72 - Modalidade
                  || '        '                                    -- 73 - Banco Liquidante
                  /* Valor após Incorporação de Juros Inicial */
                  || '                  '                          -- 74 - Valor após incorporação
                  /* Descrição dos Direitos Creditórios (DI com Garantia) */
                  || RPAD(' ',200,' ')                             -- 75 - Descrição dos Direitos Creditórios
                  /* LF com Distribuição Pública */
                  || ' '                                           -- 76 - Distribuição Púbica
                  /* DPGE Emitido no âmbito Res. 4.115/12 */
                  || ' '                                           -- 77 - Emitido com Garantia ao FGC
                  /* LF - Possui Opções */
                  || ' '                                           -- 78 - Possui Opção de Recompra / Resgate pelo Emissor
                  /* Cláusulo de Conversibilidade/Extinção para LFSC e LFSN */
                  || ' '                                           -- 79 - Cláusula de Conversão / Extinção
                  || '                '                            -- 80 - Limite Máximo de COnversibilidade
                  || RPAD(' ',500,' ')                             -- 81 - Critérios para Conversão
                  || ' '                                           -- 82 - Forma de Integralização
                  || ' '                                           -- 83 - Tipo de Cálculo
                  /* Alterações de LFSC e LFSCN com depósito ou sem depósito posterior a data de registro */
                  || ' '                                           -- 84 - Tipo de ALteração
                  || '                  '                          -- 85 - Valor de (BAse de Cálculo)
                  || '        '                                    -- 86 - DAta em (Base de Cálculo)
                  || ' '                                           -- 87 - Alterar Agenda de Eventos
                  /* Recompra pelo Emissor e Autorização do BAnco Central para Elegibilidade do Ativo para LFSC e LFSN */
                  || ' '                                           -- 88 - Recompra pelo Emissor
                  || ' '                                           -- 89 - Obteve Autorização do Banco Central
                  || '          '                                  -- 90 - Controle Interno
                  || vr_dsfimlin;                                  -- 91 - Delimitador de Final de Linha      
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;  
  END fn_gera_regist_operacao; 
  
  -- Função para montar a linha do registro conforme o tipo do arquivo
  FUNCTION fn_gera_registro_lancto(pr_cd_registrador NUMBER                                       -- Código Registrador 
                                  ,pr_cd_favorecido  NUMBER                                       -- Código Favorecido
                                  ,pr_idtipo_arquivo tbcapt_custodia_arquivo.idtipo_arquivo%TYPE  -- Tipo do Arquivo
                                  ,pr_idlancamento   tbcapt_custodia_lanctos.idlancamento%TYPE    -- ID do lançamento
                                  ,pr_cdcooper       crapcop.cdcooper%TYPE                        -- Cooperativa
                                  ,pr_nrdconta       crapass.nrdconta%TYPE                        -- Conta
                                  ,pr_vet_aplica   APLI0001.typ_reg_saldo_rdca)                   -- Vetor com informações da aplicação
                         RETURN VARCHAR2 IS
  BEGIN 
    -- Direcionar a chamada conforme tipo enviado
    IF pr_idtipo_arquivo = 2 THEN 
      RETURN fn_gera_lancto_operacao(pr_cd_registrador,pr_cd_favorecido,pr_idlancamento,pr_cdcooper,pr_nrdconta);
    ELSE
      RETURN fn_gera_regist_operacao(pr_cd_registrador,pr_cd_favorecido,pr_idlancamento,pr_cdcooper,pr_nrdconta,pr_vet_aplica);
    END IF;  
  END fn_gera_registro_lancto; 
  
  -- Função para gerar registro de Resgate Antecipado
  FUNCTION fn_gera_regist_resg_antec(pr_idlancamento tbcapt_custodia_lanctos.idlancamento%TYPE  -- ID do lançamento
                                    ,pr_vet_aplica   APLI0001.typ_reg_saldo_rdca)               -- Vetor com informações da aplicação
                         RETURN VARCHAR2 IS
  -- Layout Operações : Layout 4.1.19
  BEGIN 
    DECLARE   
      -- LInha montada
      vr_dsretorn VARCHAR2(84); 
      -- BUsca detalhes do lançamento 
      CURSOR cr_lcto IS
        SELECT apl.tpaplicacao
          FROM tbcapt_custodia_lanctos   lct
              ,tbcapt_custodia_aplicacao apl
         WHERE lct.idaplicacao  = apl.idaplicacao
           AND lct.idlancamento = pr_idlancamento;
      rw_lcto cr_lcto%ROWTYPE;
      -- Taxas de Juros      
      vr_prtaxflt VARCHAR2(7);
      vr_vltxjrsp VARCHAR2(8);
    BEGIN
      -- Busca detalhes do lançamento
      OPEN cr_lcto;
      FETCH cr_lcto
       INTO rw_lcto;
      CLOSE cr_lcto;
      -- PAra aplicações Pré
      IF rw_lcto.tpaplicacao in(1,3) THEN
        -- Enviar os zeros na taxa juros spread
        vr_prtaxflt := '       ';
        vr_vltxjrsp := '00000000';
      ELSE
        -- Enviar .00001 na taxa flutuante
        vr_prtaxflt := '0000001';
        vr_vltxjrsp := '        ';
      END IF;
      -- Enfim, montar o registro com as informações retornadas
      vr_dsretorn /* Condições de Resgate Antecipado */
                  := 'RDB  '                                       -- 01 - Tipo IF
                  || '3'                                           -- 02 - TIpo Registro
                  || 'INCL'                                        -- 03 - Ação
                  || '   '                                         -- 04 - Filler
                  || to_char(least((pr_vet_aplica.dtvencto-1),pr_vet_aplica.dtcarenc),'RRRRMMDD')    -- 05 - Data do Resgate Antecipado
                  || vr_prtaxflt                                   -- 06 - % da Taxa Flutuante
                  || vr_vltxjrsp                                   -- 07 - Taxa de Juros / Spread
                  || RPAD(' ',47,' ')                              -- 08 - Filler
                  || vr_dsfimlin;                                  -- 09 - Delimitador de Final de Linha      
      -- Retornar Linha montada
      RETURN vr_dsretorn;
    END;  
  END fn_gera_regist_resg_antec; 
  
  -- Procedimento para criação em tabela dos arquivos a serem enviados posteriormente 
  PROCEDURE pc_gera_arquivos_envio(pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                  ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                  ,pr_cdcritic OUT NUMBER       --> Código da critica
                                  ,pr_dscritic OUT VARCHAR2) IS --> Saida de possível critica no processo
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_arquivos_envio
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 20/08/2018 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Várias vezes ao dia
    -- Objetivo  : Procedimento responsável por varrer a tabela de pendências de envio e criar
    --             os arquivos para envio na tabela TBCAPT_CUSTODIA_ARQUIVO
    -- 
    -- Alteracoes:
    --             20/08/2018 - P411 - Usar sempre a Cooperativa zero para montagem do nome do 
    --                          arquivo conforme solicitação DAniel Heinen (Marcos-Envolti)
    --      
    -- 		       10/10/2018 - P411 - Não mais checar tabela de conteudo de arquivos, mas sim 
    --                          setar novas situações de lançamentos em arquivos e assim os mesmos
    --                          serão desprezados em novas execuções (Daniel - Envolti)
    --
    --             06/12/2018 - P411 - Ordernar os registros por idlancamento para eviar
    --                          que resgates do mesmo dia sejam enviadas em ordens diferentes (MArcos-Envolti)
    ---------------------------------------------------------------------------------------------------------------  
    DECLARE
      -- Busca dos lançamentos ainda não gerados em arquivos
      CURSOR cr_lctos IS        
        select lct.*,
               count(1) over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) qtregis,
               row_number() over(partition by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro order by lct.cdcooper, lct.idtipo_arquivo, lct.dtregistro) nrseqreg
          from (
                -- Registros ligados a RDC PRé e Pós
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rda.cdcooper,
                       rda.nrdconta,
                       rda.nraplica,
                       0 cdprodut,
                       lct.*
                  from craprda                   rda,
                       tbcapt_custodia_aplicacao apl,
                       tbcapt_custodia_lanctos   lct
                 where lct.idsituacao in (0, 2) -- Pendente de Envio ou Re-envio
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (1, 2) -- RDC PRé e Pós
                   and rda.idaplcus = apl.idaplicacao
                union
                -- Registros ligados a novo produto de Captação
                select /*+ index (lct tbcapt_custodia_lanctos_idx01) */
                       rac.cdcooper,
                       rac.nrdconta,
                       rac.nraplica,
                       rac.cdprodut,
                       lct.*
                  from craprac                   rac,
                       tbcapt_custodia_aplicacao apl,
                       tbcapt_custodia_lanctos   lct
                 where lct.idsituacao in (0, 2) -- Pendente de Envio ou Re-envio
                   and apl.idaplicacao = lct.idaplicacao
                   and apl.tpaplicacao in (3, 4) -- PCAPTA Pré e Pós
                   and rac.idaplcus = apl.idaplicacao
               ) lct
         WHERE lct.idtipo_arquivo <> 9 -- Não trazer COnciliação
           -- Se este possui registros de origem, os registros de origem devem 
           -- ter gerado Numero CETIP e estarem OK 
           and (   lct.idlancto_origem is null
                or exists (select 1
                             from tbcapt_custodia_lanctos lctori
                            where lctori.idlancamento = lct.idlancto_origem
                              and lctori.idsituacao = 8
                              and lctori.cdoperac_cetip is not null))
         order by lct.cdcooper,
                  lct.idtipo_arquivo,
                  lct.dtregistro,
                  lct.idlancamento;
      -- Busca dos dados da Aplicação em rotina já preparada
      vr_tbsaldo_rdca APLI0001.typ_tab_saldo_rdca;
                
      -- Nome, Id e Header do Arquivo 
      vr_nmarquivo tbcapt_custodia_arquivo.nmarquivo%TYPE;
      vr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE;        
      vr_nrseqlinh NUMBER;
      vr_dsdheader VARCHAR2(100);
      vr_dsregistr VARCHAR2(4000);
      -- Calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Contas Registrador e Favorecido cfme cooperativa
      vr_cdcooper NUMBER := 0;
      vr_cdregist NUMBER(8);
      vr_cdfavore NUMBER(8);
      -- variaveis de contadores para geração de LOG
      vr_qtarqrgt NUMBER := 0;
      vr_qtarqreg NUMBER := 0;
      vr_qtdlinhas NUMBER;
      vr_tpaplica  PLS_INTEGER;
    BEGIN
	    -- Inclusão do módulo e ação logado
	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_gera_arquivos_envio');
      -- Incluir LOG 
      pr_dsdaviso := fn_get_time_char || 'Iniciando processo de agrupamento de Registros para criação de Arquivos a Enviar...';
      -- Trazemos todos os registros pendentes de geração de arquivos
      -- agrupados por cooperativa, tipo e data, e então criaremos arquivos 
      -- para cada quebra
      FOR rw_lct IN cr_lctos LOOP 
        -- Para o primeiro registro
        IF rw_lct.nrseqreg = 1 THEN 
          -- Reiniciar contadores 
          vr_qtdlinhas := 0;
          vr_nrseqlinh := 1;
          -- Gerar ID do arquivo
          vr_idarquivo := tbcapt_custudia_arquivo_seq.NEXTVAL;          
          -- Gerar nome único do arquivo
          vr_nmarquivo := fn_nmarquivo_custodia(vr_idarquivo,0,rw_lct.idtipo_arquivo,rw_lct.dtregistro); 
          -- Criaremos o registro de arquivo
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_ARQUIVO
                       (idarquivo
                       ,nmarquivo
                       ,idtipo_arquivo
                       ,idtipo_operacao
                       ,idarquivo_origem
                       ,idsituacao
                       ,dtcriacao
                       ,dtregistro)
                 VALUES(vr_idarquivo
                       ,vr_nmarquivo
                       ,rw_lct.idtipo_arquivo
                       ,'E' -- Envio
                       ,NULL -- Sem origem
                       ,0 -- Não enviado
                       ,SYSDATE
                       ,rw_lct.dtregistro);
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_ARQUIVO: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', nmarquiv: '||vr_nmarquivo
                          || ', idtipo_arquivo: '||rw_lct.idtipo_arquivo
                          || ', idtipo_operacao: E'
                          || ', idarquivo_origem: NULL'
                          || ', idsituacao: '||0 -- Não enviado
                          || ', dtcriacao: '||SYSDATE
                          || ', dtregistro: '||rw_lct.dtregistro
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Gerar LOG
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_LOG
                       (idarquivo 
                       ,dtlog
                       ,dslog)
                 VALUES(vr_idarquivo
                       ,SYSDATE
                       ,'Iniciando criação do arquivo '||vr_nmarquivo||' tipo: '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')); 
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', dtlog: '||SYSDATE
                          || ', dslog: '||'Iniciando criação do arquivo '||vr_nmarquivo||' tipo: '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Incrementar contador de registros conforme o tipo do arquivo
          IF rw_lct.idtipo_arquivo = 1 THEN 
            vr_qtarqreg := vr_qtarqreg+1;
          ELSE
            vr_qtarqrgt := vr_qtarqrgt+1;
          END IF;
          -- Gerar o HEADER, sempre utilizando a data do dia
          vr_dsdheader := fn_gera_header_arquivo(rw_lct.idtipo_arquivo,TRUNC(SYSDATE));
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                       (idarquivo 
                       ,nrseq_linha
                       ,idtipo_linha
                       ,dslinha
                       ,idaplicacao 
                       ,idlancamento)
                 VALUES(vr_idarquivo
                       ,vr_nrseqlinh
                       ,'C'
                       ,vr_dsdheader
                       ,NULL   -- Header nao possui vinculo com aplicação
                       ,NULL); -- Header nao possui vinculo com lançamento
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', nrseq_linha: '||rw_lct.nrseqreg
                          || ', idtipo_linha: '||rw_lct.idtipo_lancto
                          || ', dslinha: '||vr_dsdheader
                          || ', idaplicacao: NULL '
                          || ', idlancamento: NULL '
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Se mudou a cooperativa
          IF vr_cdcooper <> rw_lct.cdcooper THEN 
            vr_cdcooper := rw_lct.cdcooper;
            vr_cdregist := gene0001.fn_param_sistema('CRED',rw_lct.cdcooper,'CD_REGISTRADOR_CUSTOD_B3');
            vr_cdfavore := gene0001.fn_param_sistema('CRED',rw_lct.cdcooper,'CD_FAVORECIDO_CUSTOD_B3');
            -- Verifica se a data esta cadastrada
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_lct.cdcooper);
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
            -- Se nao encontrar
            IF BTCH0001.cr_crapdat%NOTFOUND THEN
              -- Fechar o cursor pois havera raise
              CLOSE BTCH0001.cr_crapdat;
              -- Montar mensagem de critica
              vr_cdcritic:= 1;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_saida;
            ELSE
              -- Apenas fechar o cursor
              CLOSE BTCH0001.cr_crapdat;
            END IF;
          END IF;
        END IF;
        
        IF (rw_lct.cdprodut = 0) THEN
          vr_tpaplica := 1; /* Não Pcapta */
        ELSE
          vr_tpaplica := 2; /* Pcapta */
        END IF;
        
        -- Limpar toda a tabela de memória
        vr_tbsaldo_rdca.DELETE();
              
        -- Busca a listagem de aplicacoes 
        APLI0008.pc_lista_aplicacoes_progr(pr_cdcooper   => rw_lct.cdcooper      -- Código da Cooperativa 
                                    ,pr_cdoperad   => '1'                  -- Código do Operador
                                    ,pr_nmdatela   => 'EXTRDA'             -- Nome da Tela
                                    ,pr_idorigem   => 5                    -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA )
                                    ,pr_nrdcaixa   => 1                    -- Numero do Caixa
                                    ,pr_nrdconta   => rw_lct.nrdconta      -- Número da Conta
                                    ,pr_idseqttl   => 1                    -- Titular da Conta 
                                    ,pr_cdagenci   => 1                    -- Codigo da Agencia
                                    ,pr_cdprogra   => 'EXTRDA'             -- Codigo do Programa
                                    ,pr_nraplica   => rw_lct.nraplica      -- Número da Aplicaçao 
                                    ,pr_cdprodut   => rw_lct.cdprodut      -- Código do Produto
                                    ,pr_dtmvtolt   => rw_crapdat.dtmvtolt  -- Data de Movimento
                                    ,pr_idconsul   => 5                    -- Todas
                                    ,pr_idgerlog   => 0                    -- Identificador de Log (0 – Nao / 1 – Sim)
                                    ,pr_tpaplica   => vr_tpaplica          -- Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                    ,pr_cdcritic   => vr_cdcritic          -- Código da crítica 
                                    ,pr_dscritic   => vr_dscritic          -- Descriçao da crítica 
                                    ,pr_saldo_rdca => vr_tbsaldo_rdca);   -- Retorno das aplicações
              
        -- Verifica se ocorreram erros
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Montar mensagem de critica
          RAISE vr_exc_saida;
        ELSIF vr_tbsaldo_rdca.count() = 0 THEN
          vr_cdcritic := 426;   
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                      ||' Coop: '||rw_lct.cdcooper
                      ||',Conta: '||rw_lct.nrdconta
                      ||',NrAplica: '||rw_lct.nraplica 
                      ||',Produto: '||rw_lct.cdprodut;
          RAISE vr_exc_saida;
        END IF;
        
        -- Acionar rotina para gerar o Registro do Lançamento
        vr_nrseqlinh := vr_nrseqlinh + 1;
        vr_dsregistr := fn_gera_registro_lancto(vr_cdregist,vr_cdfavore,rw_lct.idtipo_arquivo,rw_lct.idlancamento,rw_lct.cdcooper,rw_lct.nrdconta,vr_tbsaldo_rdca(vr_tbsaldo_rdca.first));
        -- GErar registro na tabela de conteudo do arquivo
        BEGIN
          INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                     (idarquivo 
                     ,nrseq_linha
                     ,idtipo_linha
                     ,dslinha
                     ,idaplicacao 
                     ,idlancamento)
               VALUES(vr_idarquivo
                     ,vr_nrseqlinh
                     ,'L'
                     ,vr_dsregistr
                     ,rw_lct.idaplicacao
                     ,rw_lct.idlancamento);
        EXCEPTION
          WHEN OTHERS THEN
            -- Erro não tratado 
            vr_cdcritic := 1034;   
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                        || 'idarquivo: '||vr_idarquivo
                        || ', nrseq_linha: '||(rw_lct.nrseqreg + 1)
                        || ', idtipo_linha: '||rw_lct.idtipo_lancto
                        || ', idaplicacao: '||rw_lct.idaplicacao
                        || ', idlancamento: '||rw_lct.idlancamento
                        || ', dslinha: '||vr_dsregistr
                        || '. '||sqlerrm;
            RAISE vr_exc_saida;
        END;
        -- Marca o lançamento como incluído no arquivo
        begin
          update tbcapt_custodia_lanctos l
             set l.idsituacao = decode(l.idsituacao, 0, 4, 2, 5)
           where l.idlancamento = rw_lct.idlancamento;
        exception
          when others then
            -- Erro não tratado 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LANCTO: '
                        || 'idarquivo: '||vr_idarquivo
                        || ', nrseq_linha: '||(rw_lct.nrseqreg + 1)
                        || ', idtipo_linha: '||rw_lct.idtipo_lancto
                        || ', idaplicacao: '||rw_lct.idaplicacao
                        || ', idlancamento: '||rw_lct.idlancamento
                        || ', dslinha: '||vr_dsregistr
                        || '. '||sqlerrm;
            raise vr_exc_saida;
        end;
        
        -- Para Registro de Operação, também vamos enviar as condições de resgate (Carência)
        /*IF rw_lct.idtipo_lancto = 1 THEN 
          
          -- Acionar rotina para gerar as informações de Resgate Antecipado (Carência)
          vr_dsregistr := fn_gera_regist_resg_antec(rw_lct.idlancamento,vr_tbsaldo_rdca(vr_tbsaldo_rdca.first));
          vr_nrseqlinh := vr_nrseqlinh + 1;
          -- GErar registro na tabela de conteudo do arquivo
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                       (idarquivo 
                       ,nrseq_linha
                       ,idtipo_linha
                       ,dslinha
                       ,idaplicacao 
                       ,idlancamento)
                 VALUES(vr_idarquivo
                       ,vr_nrseqlinh
                       ,'D'
                       ,vr_dsregistr
                       ,rw_lct.idaplicacao
                       ,rw_lct.idlancamento);
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', nrseq_linha: '||(rw_lct.nrseqreg + 1)
                          || ', idtipo_linha: '||rw_lct.idtipo_lancto
                          || ', idaplicacao: '||rw_lct.idaplicacao
                          || ', idlancamento: '||rw_lct.idlancamento
                          || ', dslinha: '||vr_dsregistr
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
        END IF;*/
        
        -- Incementar contador de linhas
        vr_qtdlinhas := vr_qtdlinhas+1;
        
        -- Para o ultimo registro OU para casos em que o registro 
        -- seja igual a quantidade máxima de registros por arquivo 
        IF rw_lct.qtregis = rw_lct.nrseqreg THEN 
          -- Gerar LOG
          BEGIN
            INSERT INTO TBCAPT_CUSTODIA_LOG
                       (idarquivo 
                       ,dtlog
                       ,dslog)
                 VALUES(vr_idarquivo
                       ,SYSDATE
                       ,rw_lct.qtregis||' registros de '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||' incluídos no arquivo');
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1034;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                          || 'idarquivo: '||vr_idarquivo
                          || ', dtlog: '||SYSDATE
                          || ', dslog: '||rw_lct.qtregis||' registros de '||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||' incluídos no arquivo'
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Incrementar o LOG
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Arquivo '||vr_nmarquivo||'('||fn_tparquivo_custodia(rw_lct.idtipo_arquivo,'E')||') gerado com um total de : '||vr_qtdlinhas||' linha(s)';
          -- Gravar a cada arquivo gerado
          COMMIT;
          
          
        END IF;
      END LOOP;
      -- Enviar ao LOG resumo da execução
      IF vr_qtarqrgt + vr_qtarqreg > 0 THEN 
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos gerados:'
                    ||vr_dscarque||'Registro = '||vr_qtarqreg
                    ||vr_dscarque||'Operação = '||vr_qtarqrgt;
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo foi gerado!';
      END IF;
     
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_gera_arquivos_envio' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_gera_arquivos_envio' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                               
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_gera_arquivos_envio;
  
  -- Rotina para enviar o arquivo repassado
  PROCEDURE pc_envia_arquivo_cd(pr_nmarquiv IN VARCHAR2       --> Nome do arquivo a enviar
                               ,pr_nmdireto IN VARCHAR2       --> Caminho dos arquivos a enviar
                               ,pr_dsdirenv IN VARCHAR2       --> Diretório Envia
                               ,pr_dsdirend IN VARCHAR2       --> Diretório Enviados
                               ,pr_flaguard IN BOOLEAN        --> Aguardar
                               ,pr_idcritic OUT NUMBER        --> Criticidade da saida
                               ,pr_cdcritic OUT NUMBER        --> Código da critica
                               ,pr_dscritic OUT VARCHAR2) IS  --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_arquivo_cd
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o envio dos arquivos repassados ao ConnectDirect
    --             Precisamos apenas mover os arquivos para a pasta correspondente
    --             do envio e aguardar o Software enviar o arquivos. Após, o Software
    --             move estes arquivos para a pasta enviados
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_saida  VARCHAR2(3);      --> Saída do comando no OS
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_envia_arquivo_cd');      

      -- Primeiramente checamos se o arquivo por ventura já não está na pasta enviados
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
        -- O que ocorreu é que a cópia anterior não havia sido enviada na última execução,
        -- mas o envio ocorreu com sucesso entre as duas execuções do job.
        -- Devemos remover o arquivo da pasta temporária, caso exista.
        if gene0001.fn_exis_arquivo(pr_caminho => pr_nmdireto||'/'||pr_nmarquiv) then
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||pr_nmdireto||'/'||pr_nmarquiv
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => pr_dscritic);
        end if;
        RETURN;
      ELSE
        -- Checamos se o arquivo já não foi copiado a envia
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirenv||'/'||pr_nmarquiv) THEN
          -- Devemos movê-lo para a pasta envia
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_nmdireto||'/'||pr_nmarquiv||' '||pr_dsdirenv
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => pr_dscritic);
          -- Se retornou erro, incrementar a mensagem e retornar
          IF vr_typ_saida = 'ERR' THEN
            RETURN;
          END IF;
        else
          -- Se já está na pasta envia, devemos remover o arquivo da pasta temporária
          if gene0001.fn_exis_arquivo(pr_caminho => pr_nmdireto||'/'||pr_nmarquiv) then
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||pr_nmdireto||'/'||pr_nmarquiv
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => pr_dscritic);
          end if;
          -- Se retornou erro, incrementar a mensagem e retornar
          IF vr_typ_saida = 'ERR' THEN
            RETURN;
          END IF;
        END IF;
        -- Agora devemos checar o envio do arquivo, que é garantido quando o arquivo
        -- é movido da envia para enviados pelo Connect Direct.
          -- Testar envio (Existencia na enviados)
        IF pr_flaguard and not gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
          -- Se não conseguiu enviar
          pr_dscritic := 'Arquivo persiste na pasta ENVIA';
          RETURN;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_envia_arquivo_cd' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                   
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_envia_arquivo_cd;
  
  
  -- Rotina para preparar e direcionar o envio dos arquivos pendentes para Custódia
  PROCEDURE pc_processa_envio_arquivos(pr_flenvreg IN VARCHAR2      --> Envio de Registros Habilidade
                                      ,pr_flenvrgt IN VARCHAR2      --> Envio de Resgates Habilitado
                                      ,pr_dsdircnd IN VARCHAR2      --> Caminho raiz Connect Direct
                                      ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                                      ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                      ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                      ,pr_cdcritic OUT NUMBER       --> Código da critica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_processa_envio_arquivos
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Identificar arquivos pendentes de envio, gerá-los na pasta temporária, e enviar via Connect Direct
    -- Alteracoes:
    --
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_utl_file utl_file.file_type; 
      
      -- Quantidade de arquivos processados
      vr_qtdaruiv NUMBER := 0;

      -- Busca dos arquivps pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'E'
           AND arq.idsituacao = 0 -- Pendente envio
           -- Conferir Flag de envio ativo
           AND ((arq.idtipo_arquivo = 1 AND pr_flenvreg = 'S')
                OR
                (arq.idtipo_arquivo = 2 AND pr_flenvrgt = 'S'))
         ORDER BY arq.idarquivo
         FOR UPDATE;
      
      -- Busca do conteudo do arquivo 
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
         ORDER BY cnt.nrseq_linha;
      
      -- Variaveis de contadores para geração de LOG
      vr_qtdsuces NUMBER := 0;
      vr_qtderros NUMBER := 0;
      
      --> Vetor de arquivos a ignorar (erro no primeiro laço)
      TYPE vr_typ_tab_arquivos_erro IS TABLE OF tbcapt_custodia_arquivo.nmarquivo%TYPE INDEX BY PLS_INTEGER;
      vr_tab_arqerros vr_typ_tab_arquivos_erro;
            
      --> Saída do comando no OS
      vr_typ_saida  VARCHAR2(3);      
      vr_dsdaviso   VARCHAR2(32767);
      
    BEGIN
  	  -- Inclusão do módulo e ação logado
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_processa_envio_arquivos');      
      -- Incluir LOG 
      pr_dsdaviso := fn_get_time_char || 'Iniciando processo de Envio de Arquivos A B3...';
      -- Tentaremos duas vezes, a primeira não aguardamos, pois os arquivos são enviados de 1 em 1 minuto,
      -- então primeiro copiamos todos os arquivos e na segunda conferimos se foram enviados
      FOR vr_tentativ IN 1..2 LOOP
        -- Buscamos todos os arquivos pendentes de envio 
        FOR rw_arq IN cr_arquivos LOOP 
          -- Incrementar contador
          vr_qtdaruiv := vr_qtdaruiv + 1;
          -- Caso o arquivo esteja na lista de arquivos com erro
          IF vr_tab_arqerros.exists(rw_arq.idarquivo) THEN
            -- Ignorá-lo
            CONTINUE;
          END IF;
          -- Somente na primeira vez
          IF vr_tentativ = 1 THEN                     
            -- Efetuar a criação do arquivo no diretório temporário 
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdirarq
                                    ,pr_nmarquiv => rw_arq.nmarquivo
                                    ,pr_tipabert => 'W'
                                    ,pr_utlfileh => vr_utl_file
                                    ,pr_des_erro => vr_dscritic);
            -- Se houve erro, não podemos criar o arquivo
            IF vr_dscritic IS NOT NULL THEN
              -- Gerar LOG para o arquivo e continuar
              BEGIN
                INSERT INTO TBCAPT_CUSTODIA_LOG
                           (idarquivo 
                           ,dtlog
                           ,dslog)
                     VALUES(rw_arq.idarquivo
                           ,SYSDATE
                           ,'Erro ao criar o arquivo '||rw_arq.nmarquivo||' no diretório temporário '||vr_dsdirarq||' --> '||vr_dscritic);
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1034;   
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                              || 'idarquivo: '||rw_arq.idarquivo
                              || ', dtlog: '||SYSDATE
                              || ', dslog: '||'Erro ao criar o arquivo '||rw_arq.nmarquivo||' no diretório temporário '||vr_dsdirarq||' --> '||vr_dscritic
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              vr_qtderros := vr_qtderros +1;
              -- Adicionar a lista de ignorados
              vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
              -- Ir ao proximo arquivo 
              CONTINUE;
            END IF;
              
            -- Buscar todas as linhas do arquivo 
            FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP 
              -- Adicionar linha ao arquivo
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utl_file
                                            ,pr_des_text => rw_cnt.dslinha);
              
            END LOOP;
              
            -- AO final, fechar o arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file);
          END IF;
          -- Chamar processo de envio via Connect Direct
          -- Na primeira vez não aguardaremos, na segunda sim
          pc_envia_arquivo_cd(pr_nmarquiv => rw_arq.nmarquivo         --> Nome do arquivo a enviar
                             ,pr_nmdireto => vr_dsdirarq              --> Caminho dos arquivos a enviar
                             ,pr_dsdirenv => pr_dsdircnd||vr_dsdirenv --> Diretório a enviar ao CD
                             ,pr_dsdirend => pr_dsdircnd||vr_dsdirevd --> Diretório enviados ao CD
                             ,pr_flaguard => vr_tentativ=2            --> Aguardar na segunda vez
                             ,pr_idcritic => vr_idcritic              --> Identificador critica
                             ,pr_cdcritic => vr_cdcritic              --> Codigo da critica
                             ,pr_dscritic => vr_dscritic);            --> Retorno de crítica

          -- Código comum, para gravação do LOG independente de sucesso ou não
          IF vr_dscritic IS NOT NULL THEN
            -- Houve erro
            vr_dscritic := 'Nao foi possivel enviar arquivo '||rw_arq.nmarquivo||' -> '|| vr_dscritic;
            -- Adicionar a lista de ignorados
            vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
          ELSE
            -- Somente no segundo laço
            IF vr_tentativ=2 THEN
              -- Gerar cópia do arquivo que está na enviados para a pasta de Backup, de onde o financeiro terá acesso
              gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdircnd||vr_dsdirevd||'/'||rw_arq.nmarquivo||' '||pr_dsdirbkp||vr_dsdirevd
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
              -- Se retornou erro, incrementar a mensagem e retornoar
              IF vr_typ_saida = 'ERR' THEN
                -- Houve erro
                vr_dsdaviso := 'Arquivo enviado, porém nao foi possivel copiar arquivo '||rw_arq.nmarquivo||' para pasta de Backup, motivo:  '|| vr_dscritic||vr_dscarque;
                vr_dscritic := NULL;
              END IF;
            
              -- Gerar LOG 
              BEGIN
                INSERT INTO TBCAPT_CUSTODIA_LOG
                           (idarquivo 
                           ,dtlog
                           ,dslog)
                     VALUES(rw_arq.idarquivo
                           ,SYSDATE
                           ,'Arquivo '||rw_arq.nmarquivo||' enviado com sucesso!');
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1034;   
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                              || 'idarquivo: '||rw_arq.idarquivo
                              || ', dtlog: '||SYSDATE
                              || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' enviado com sucesso!'
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Caso não tenha encontrado erro acima
              IF vr_dscritic IS NULL THEN 
                -- Atualizaremos a tabela de envio
                BEGIN 
                  UPDATE tbcapt_custodia_arquivo arq
                     SET arq.idsituacao = 1       -- Enviado
                        ,arq.dtprocesso = SYSDATE -- Momento do Envio
                   WHERE arq.idarquivo = rw_arq.idarquivo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_arquivo: '
                                || 'idsituacao: 1' 
                                || ', dtprocesso: '||SYSDATE
                                || ' com idarquivo: '||rw_arq.idarquivo||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;
              END IF;  
              -- Caso não tenha encontrado erro acima
              IF vr_dscritic IS NULL THEN 
                -- Atualizaremos a tabela de Lançamentos em todos os 
                -- registros relacionados as linhas deste arquivo
                BEGIN 
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao = decode(lct.idsituacao,4,1,5,3,1) -- Enviado ou Re-envio e aguardando retorno 
                        ,lct.dtenvio = SYSDATE 
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                                || 'idsituacao: 1 ou 3 (De acordo com situação anterior)'
                                || ', dtenvio: '||SYSDATE 
                                || ' com idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;
              END IF;
            END IF;
          END IF;
          -- Em caso de critica
          IF vr_dscritic IS NOT NULL THEN 
            -- Adicionar arquivo a lista de ignorados
            vr_tab_arqerros(rw_arq.idarquivo) := rw_arq.nmarquivo;
            -- Gerar LOG 
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo 
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,vr_dscritic);
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1034;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                            || 'idarquivo: '||rw_arq.idarquivo
                            || ', dtlog: '||SYSDATE
                            || ', dslog: '||vr_dscritic
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            vr_qtderros := vr_qtderros +1;
          ELSE
            -- Somente no segundo laço
            IF vr_tentativ = 2 THEN   
              vr_qtdsuces := vr_qtdsuces +1;
            END IF;
          END IF;
          -- Sair se processou a quantidade máxima de arquivos por execução
          IF vr_qtdaruiv >= vr_qtdexjob THEN 
            EXIT;
          END IF;
        END LOOP;
      END LOOP;
      -- Gravar
      COMMIT; 
      -- Enviar ao LOG resumo da execução
      IF vr_qtdsuces + vr_qtderros > 0 THEN 
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos enviados: '||(vr_qtdsuces + vr_qtderros)||', sendo: '
                    ||vr_dscarque||'Sucesso = '||vr_qtdsuces
                    ||vr_dscarque||'Erro = '||vr_qtderros;
        -- Se há avisos
        IF vr_dsdaviso IS NOT NULL THEN
          pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
        END IF;
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo enviado!';
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_envio_arquivos' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_envio_arquivos' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                  
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_processa_envio_arquivos;
  
  
  -- Rotina checar possives retornos recebidas na pasta repassada
  PROCEDURE pc_checar_recebe_cd(pr_idtiparq IN NUMBER        --> TIpo de Busca (0-Todas,9-Conciliação,5-Retornos)
                               ,pr_dsdirrec IN VARCHAR2      --> Diretorio Recebe
                               ,pr_dsdirrcb IN VARCHAR2      --> Diretório Recebidos
                               ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                               ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                               ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                               ,pr_cdcritic OUT NUMBER       --> Código da critica
                               ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_checar_recebe
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 21/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Verificar o retorno dos arquivos na pasta de recebe
    --             do Connect Direct, gravá-los na tabela e gerar para Recebidos
    --
    -- Alteracoes: 
    --    
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_dspadrao         VARCHAR2(100);                             --> Padrão de busca
      vr_dslstarq         VARCHAR2(32767);                            --> Lista de arquivos encontrados
      vr_lstarqre         gene0002.typ_split;                        --> Split de arquivos encontrados
      vr_utl_file         utl_file.file_type;                        --> Handle
      vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_idarquivo_origem tbcapt_custodia_arquivo.idarquivo%TYPE;    --> Arquivo de origem 
      vr_idarquivo        tbcapt_custodia_arquivo.idarquivo%TYPE;    --> Sequencia de gravação do arquivo
      vr_qtdregist        NUMBER;                                    --> Quantidade de registros
      vr_dslinha          tbcapt_custodia_conteudo_arq.dslinha%TYPE; --> Conteudo das linhas
      vr_idtipo_arquivo   tbcapt_custodia_arquivo.idtipo_arquivo%TYPE; --> Tipo do Arquivo
      vr_dtrefere         DATE;                                        --> Data de referência do arquivo
      vr_idtipo_linha     tbcapt_custodia_conteudo_arq.idtipo_linha%TYPE; --> Tipo da Linha
      v_hora              varchar2(6);
      
      --> Checar se arquivo já não foi retornado
      CURSOR cr_arq_duplic(pr_nmarquiv VARCHAR2) IS
        SELECT arq.idarquivo  
              ,arq.idtipo_arquivo
              ,arq.dtregistro
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.nmarquivo = pr_nmarquiv;
           
      --> Busca do arquivo de origem 
      CURSOR cr_arq_origem(pr_nmarquiv VARCHAR2) IS
        SELECT arq.idarquivo  
              ,arq.idtipo_arquivo
              ,arq.dtregistro
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'E'
           -- Remover o começo do arquivo enviado e o final do arquivo recebeido, o interior deverá ser o mesmo
           AND SUBSTR(arq.nmarquivo,INSTR(arq.nmarquivo,'.',1)+1) = SUBSTR(pr_nmarquiv,1,INSTR(pr_nmarquiv,'.','-1')-1);
      --> Contador de registros
      vr_qtdencon NUMBER := 0;
      vr_qtdignor NUMBER := 0;
      -- Flag de ignorar
      vr_flignore BOOLEAN;
      -- Alertas
      vr_idtiparq NUMBER;
      vr_dsdaviso VARCHAR2(32767);
    BEGIN
  	  -- Inclusão do módulo e ação logado
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_checar_recebe_cd');   
      -- Efetuar laço para buscar tanto conciliação quanto retorno, caso solicitado
      FOR vr_loop IN 1..2 LOOP
        -- Somente processar na segunda iteração se foi solicitado todas
        IF vr_loop = 2 AND pr_idtiparq <> 0 THEN
          CONTINUE;
        END IF;
        -- Se solicitado todas
        IF pr_idtiparq = 0 THEN
          IF vr_loop = 1 THEN 
            -- Primeiro processar retornos 
            vr_idtiparq := 5;
          ELSE
            -- Depois conciliação
            vr_idtiparq := 9;
          END IF;
        ELSE
          -- Processar somente a repassada
          vr_idtiparq := pr_idtiparq;
        END IF;
        -- Incluir LOG 
        pr_dsdaviso := fn_get_time_char || 'Iniciando Checagem de Arquivos de '||fn_tparquivo_custodia(vr_idtiparq,'E')||' Devolvidos pela B3...';      
        -- BUsca específica conforme a opção
        IF vr_idtiparq = 9 THEN 
          -- Conciliação
          vr_dspadrao := 'CETIP%DPOSICAOCUSTODIA%';
          vr_idtipo_arquivo := 9; -- Conciliação
          vr_idarquivo_origem := NULL; -- Sem origem
        ELSE
          -- Retorno
          vr_dspadrao := '%.TXT.S%';
          vr_idtipo_arquivo := 0; -- Será definido depois
        END IF;
        
        -- Usamos rotina para listar os arquivos da pasta conforme padrão definido acima
        gene0001.pc_lista_arquivos(pr_path     => pr_dsdirrec   --> Dir busca
                                  ,pr_pesq     => vr_dspadrao   --> Chave busca(Padrão passado)
                                  ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                  ,pr_des_erro => vr_dscritic); --> Possível erro
        -- Se retorno erro:
        IF vr_dscritic IS NOT NULL THEN
          -- Ajuste rastrear Log - Chamado 719114 - 07/08/2017  
          vr_dscritic := 'pc_retorno_arquivo_cd - gene0001.pc_lista_arquivos - ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        -- Separar a lista de arquivos encontradas com função existente
        vr_lstarqre := gene0002.fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
        -- Se encontrou pelo menos um registro
        IF vr_lstarqre.count() > 0 THEN
          -- Para cada arquivo encontrado na pasta
          FOR vr_idx IN 1..vr_lstarqre.count LOOP
            -- Reiniciar controle de ignore
            vr_flignore := FALSE;
            --
            if vr_dspadrao = 'CETIP%DPOSICAOCUSTODIA%' then
              -- Renomeia arquivo, para que não haja duplicidade com os próximos ZIPs
              v_hora := to_char(sysdate, 'hh24miss');
              gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'_'||v_hora
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
              vr_lstarqre(vr_idx) := vr_lstarqre(vr_idx)||'_'||v_hora;
            end if;
            -- Devemos checar se o arquivo em questão já não foi retornado
            OPEN cr_arq_duplic(vr_lstarqre(vr_idx));
            FETCH cr_arq_duplic
             INTO vr_idarquivo_origem
                 ,vr_idtipo_arquivo
                 ,vr_dtrefere;
            -- Se encontrar, ignoraremos este arquivo pois ele já foi retornado anteriormente
            IF cr_arq_duplic%FOUND THEN 
              CLOSE cr_arq_duplic;
              vr_qtdignor := vr_qtdignor + 1;
              -- 
              vr_flignore := TRUE;
            ELSE
              CLOSE cr_arq_duplic;
            END IF;
            -- Se não for para ignorar
            IF NOT vr_flignore THEN
              -- Reiniciar o contador
              vr_qtdregist := 1;
              vr_dtrefere  := NULL;
              -- Para retorno vamos buscar o arquivo de envio relacionado
              IF vr_idtiparq = 5 THEN 
                --> Busca do arquivo de origem 
                OPEN cr_arq_origem(vr_lstarqre(vr_idx));
                FETCH cr_arq_origem
                 INTO vr_idarquivo_origem
                     ,vr_idtipo_arquivo
                     ,vr_dtrefere;
                -- Se não encontrar, ignoraremos este arquivo pois não é relacionado a nenhum envio 
                IF cr_arq_origem%NOTFOUND THEN 
                  CLOSE cr_arq_origem;
                  vr_qtdignor := vr_qtdignor + 1;
                  -- 
                  vr_flignore := TRUE;
                ELSE
                  CLOSE cr_arq_origem;
                END IF;
              END IF;
              -- Se não ignorar o mesmo
              IF NOT vr_flignore THEN  
                
                -- Criaremos o registro de arquivo
                BEGIN
                  INSERT INTO TBCAPT_CUSTODIA_ARQUIVO
                             (nmarquivo
                             ,idtipo_arquivo
                             ,idtipo_operacao
                             ,idarquivo_origem
                             ,idsituacao
                             ,dtcriacao
                             ,dtregistro 
                             )
                       VALUES(vr_lstarqre(vr_idx)
                             ,vr_idtipo_arquivo
                             ,'R'  -- Retorno
                             ,vr_idarquivo_origem
                             ,0 -- Não Processado 
                             ,SYSDATE
                             ,vr_dtrefere
                             )
                       RETURNING idarquivo 
                            INTO vr_idarquivo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1034;   
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_ARQUIVO: '
                                || ' nmarquiv: '||vr_lstarqre(vr_idx)
                                || ', idtipo_arquivo: '||vr_idtipo_arquivo
                                || ', idtipo_operacao: '||'R'
                                || ', idarquivo_origem: '||vr_idarquivo_origem
                                || ', idsituacao: '||0 -- Não processado
                                || ', dtcriacao: '||SYSDATE
                                || ', dtregistro: '||vr_dtrefere
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;        
                -- Abrir cada arquivo encontrado
                gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdirrec
                                        ,pr_nmarquiv => vr_lstarqre(vr_idx)
                                        ,pr_tipabert => 'R'
                                        ,pr_utlfileh => vr_utl_file
                                        ,pr_des_erro => vr_dscritic);
                -- Se houve erro, parar o processo 
                IF vr_dscritic IS NOT NULL THEN
                  -- Retornar com a critica
                  RAISE vr_exc_saida;
                END IF;
                -- Buscar todas as linhas do arquivo 
                LOOP
                  BEGIN  
                    -- Adicionar linha ao arquivo
                    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                                ,pr_des_text => vr_dslinha);
                    -- Arquivo de retorno na primeira linha
                    IF vr_idtiparq = 5 AND vr_qtdregist = 1 THEN
                      vr_idtipo_linha := 'C'; --> Cabeçalho
                    ELSE
                      vr_idtipo_linha := 'L'; --> Linhas normais
                    END IF;                     
                    -- GErar registro na tabela de conteudo do arquivo
                    BEGIN
                      INSERT INTO TBCAPT_CUSTODIA_CONTEUDO_ARQ
                                 (idarquivo 
                                 ,nrseq_linha
                                 ,idtipo_linha
                                 ,dslinha
                                 ,idaplicacao 
                                 ,idlancamento)
                           VALUES(vr_idarquivo
                                 ,vr_qtdregist
                                 ,vr_idtipo_linha
                                 ,vr_dslinha
                                 ,NULL   -- Será atualizado posteriormente
                                 ,NULL); -- Será atualizado posteriormente
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Erro não tratado 
                        vr_cdcritic := 1034;   
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_CONTEUDO_ARQ: '
                                    || 'idarquivo: '||vr_idarquivo
                                    || ', nrseq_linha: '||vr_qtdregist
                                    || ', idtipo_linha: C se Linha=1, senão L'
                                    || ', dslinha: '||vr_dslinha
                                    || ', idaplicacao: NULL'
                                    || ', idlancamento: NULL'
                                    || '. '||sqlerrm;
                        RAISE vr_exc_saida;
                    END;
                    -- Incrementar o contador
                    vr_qtdregist := vr_qtdregist + 1;
                  EXCEPTION
                    WHEN vr_exc_saida THEN
                      RAISE vr_exc_saida;
                    WHEN no_data_found THEN
                      EXIT;
                  END;  
                END LOOP;  
                -- AO final, fechar o arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file);
                    
                -- Gerar LOG 
                BEGIN
                  INSERT INTO TBCAPT_CUSTODIA_LOG
                             (idarquivo 
                             ,dtlog
                             ,dslog)
                       VALUES(vr_idarquivo
                             ,SYSDATE
                             ,'Arquivo '||vr_lstarqre(vr_idx)||' recebido com sucesso! Total de registros: '||(vr_qtdregist-1)); -- Diminuir um registro do Incremento do LOOP
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1034;   
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                                || 'idarquivo: '||vr_idarquivo
                                || ', dtlog: '||SYSDATE
                                || ', dslog: '||'Arquivo '||vr_lstarqre(vr_idx)||' recebido com sucesso! Total de registros: '||(vr_qtdregist-2)
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;
              END IF;
            END IF;      
            -- Mover o arquivo da pasta recebe para recebidos
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirrcb
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_dscritic := 'Não foi possivel mover arquivo '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' para '||pr_dsdirrcb
                          || ' --> '|| vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Copiar arquivo recebido para a pasta de backup, de onde o financeiro terá acesso
            gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdirrcb||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirbkp
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, incrementar a mensagem e retornoar
            IF vr_typ_saida = 'ERR' THEN
              -- Houve erro
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Arquivo recebido, porém nao foi possivel copiar arquivo '||vr_lstarqre(vr_idx)||' para pasta de Backup, motivo:  '|| vr_dscritic||vr_dscarque;
              vr_dscritic := NULL;
            END IF;
            -- Incrementar contador
            vr_qtdencon := vr_qtdencon + 1;
            -- Gravar
            COMMIT;
          END LOOP; --> Arquivos retornados
        END IF;
        -- Enviar ao LOG resumo da execução
        IF vr_qtdencon + vr_qtdignor > 0 THEN 
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos recebidos: '||(vr_qtdencon + vr_qtdignor)||', sendo: '
                      ||vr_dscarque||'Armazenados = '||vr_qtdencon
                      ||vr_dscarque||'Ignorados = '||vr_qtdignor;
          -- Se há avisos
          IF vr_dsdaviso IS NOT NULL THEN
            pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
          END IF;                    
        ELSE
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo recebido!';
        END IF;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_checar_recebe_cd' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_checar_recebe_cd' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                 
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_checar_recebe_cd;
  
  -- Rotina checar possives retornos compactados recebidas na pasta repassada
  PROCEDURE pc_checar_zips_recebe_cd(pr_dsdircnd IN VARCHAR2      --> Diretório Connect Direct Raiz
                                    ,pr_dsdirbkp IN VARCHAR2      --> Diretório Backup dos arquivos
                                    ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                    ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                    ,pr_cdcritic OUT NUMBER       --> Código da critica
                                    ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_checar_zips_recebe_cd
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 21/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Verificar o retorno de arquivos compactados na pasta de recebe
    --             do Connect Direct, descompacta-los, chamar a rotina para checagem de possiveis
    --             arquivos para processamento, e gerar para Recebidos
    --
    -- Alteracoes: 
    --    
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_dspadrao         VARCHAR2(100);                             --> Padrão de busca
      vr_dslstarq         VARCHAR2(4000);                            --> Lista de arquivos encontrados
      vr_lstarqre         gene0002.typ_split;                        --> Split de arquivos encontrados
      vr_typ_saida        VARCHAR2(3);                               --> Saída do comando no OS
      vr_qtdarquiv        NUMBER := 0;                               --> Quantidade de registros
      vr_qtdignora        NUMBER := 0;                               --> Quantidade de registros
      -- Alertas
      vr_dsdaviso VARCHAR2(4000);
    BEGIN
  	  -- Inclusão do módulo e ação logado
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_checar_zips_recebe_cd');      
      -- Incluir LOG 
      pr_dsdaviso := fn_get_time_char || 'Iniciando Checagem de Arquivos Compactados Devolvidos pela B3...'; 
      -- Arquivos possuem o seguinte padrão:
      -- 03021_180504_ArqsBatch.zip.S3379466
      -- onde: 03021 - É a conta Cetip da Cecred
      --       180504 - AAMMDD do arquivo
      --       ArqsBatch - Texto padrão
      --       .zip - Extensão
      --       S - Fixo
      --       S3379466 - Numero referente ao sequencial de processamento
      vr_dspadrao := '%Batch.zip.S%';
      -- Usamos rotina para listar os arquivos da pasta conforme padrão definido acima
      gene0001.pc_lista_arquivos(pr_path     => pr_dsdircnd||vr_dsdirrec --> Dir busca
                                ,pr_pesq     => vr_dspadrao   --> Chave busca(Padrão passado)
                                ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                ,pr_des_erro => vr_dscritic); --> Possível erro
      -- Se retorno erro:
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'pc_checar_zips_recebe_cd - gene0001.pc_lista_arquivos - ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      -- Separar a lista de arquivos encontradas com função existente
      vr_lstarqre := gene0002.fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
      -- Se encontrou pelo menos um registro
      IF vr_lstarqre.count() > 0 THEN
        -- Para cada arquivo encontrado na pasta
        FOR vr_idx IN 1..vr_lstarqre.count LOOP
          -- Somente descompactar o ZIP caso seu código CETP (Primeiras 5 posições) seja algum código CETIP das Cooperativas do grupo Cecred
          -- ou seja um arquivo do tipo ArqsBatch, ou seja, os RelsBatch apenas é copiado para a pasta Backup
          IF NOT fn_valida_codigo_cetip(substr(vr_lstarqre(vr_idx),1,5)) THEN
            -- Incrementar quantidade de ignorados
            vr_qtdignora := vr_qtdignora + 1;
            -- Adicionar alerta
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, arquivo recebido não possui codigo CETIP válido nas cooperativas do grupo, arquivo: '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx);
          ELSIF vr_lstarqre(vr_idx) NOT LIKE '%ArqsBatch%' THEN
            -- Incrementar quantidade de ignorados
            vr_qtdignora := vr_qtdignora + 1;
            -- Adicionar alerta
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, arquivo RelBatchs recebido : '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||', será apenas copiado para a pasta de Backups';
          ELSE
            -- Criaremos uma pasta temporária para descompactação do arquivo
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mkdir '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, não foi possivel criar pasta '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp para descompactação '|| ' --> '|| vr_dscritic;
              vr_dscritic := NULL;
            END IF;
            
            -- Descompactaremos o arquivo Zip encontrado criando uma pasta com o mesmo nome na Recebe:
            gene0002.pc_zipcecred(pr_cdcooper => 3
                                 ,pr_tpfuncao => 'E' -- Extrair
                                 ,pr_dsorigem => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)
                                 ,pr_dsdestin => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                 ,pr_dspasswd => NULL
                                 ,pr_des_erro => vr_dscritic);
            -- Se retorno erro:
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;          
            -- Chamaremos a rotina que checa se retornou conciliação no diretório
            -- Neste caso enviaremos o diretório recém criado e resultado da descompactação
            pc_checar_recebe_cd(pr_idtiparq => 9                                                                   --> TIpo de Busca (0-Todas,9-Conciliação,5-Retornos)
                               ,pr_dsdirrec => pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'          --> Diretório dos arquivos compactados
                               ,pr_dsdirrcb => pr_dsdircnd||vr_dsdirrcb                                            --> Diretório Recebidos
                               ,pr_dsdirbkp => pr_dsdirbkp||vr_dsdirrcb                                            --> Diretório Backup dos arquivos
                               ,pr_dsdaviso => pr_dsdaviso                                                         --> Avisos dos eventos ocorridos no processo
                               ,pr_idcritic => pr_idcritic                                                         --> Criticidade da saida
                               ,pr_cdcritic => vr_cdcritic                                                         --> Código da critica
                               ,pr_dscritic => vr_dscritic);                                                       --> Retorno de crítica
            -- Em caso de critica
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            -- Remover a pasta temporária criada (descompactação)
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm -r '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'
                                       ,pr_typ_saida   => vr_typ_saida
                                       ,pr_des_saida   => vr_dscritic);
            -- Se retornou erro, retornoar
            IF vr_typ_saida = 'ERR' THEN
              vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Atenção, não foi possivel remover pasta descompactada '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||'.tmp'|| ' --> '|| vr_dscritic;
              vr_dscritic := NULL;
            END IF;
            -- Incrementar o contador
            vr_qtdarquiv := vr_qtdarquiv + 1;
          END IF;  
              
          -- Mover o arquivo Zip da pasta recebe para recebidos
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdircnd||vr_dsdirrcb
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          -- Se retornou erro, retornoar
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic := 'Não foi possivel mover arquivo '||pr_dsdircnd||vr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' para '||pr_dsdircnd||vr_dsdirrcb
                        || ' --> '|| vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          -- Copiar arquivo recebido para a pasta de backup, de onde o financeiro terá acesso
          gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||pr_dsdircnd||vr_dsdirrcb||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirbkp||vr_dsdirrcb
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => vr_dscritic);
          -- Se retornou erro, incrementar a mensagem e retornoar
          IF vr_typ_saida = 'ERR' THEN
            -- Houve erro
            vr_dsdaviso := vr_dsdaviso || vr_dscarque || 'Arquivo recebido, porém nao foi possivel copiar arquivo '||vr_lstarqre(vr_idx)||' para pasta de Backup, motivo:  '|| vr_dscritic||vr_dscarque;
            vr_dscritic := NULL;
          END IF;
          
          -- Gravar
          COMMIT;
        END LOOP; --> Arquivos retornados
      END IF;
      
      -- Enviar ao LOG resumo da execução
      IF vr_qtdarquiv + vr_qtdignora > 0 THEN 
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Total de arquivos compactados recebidos: '||(vr_qtdarquiv+vr_qtdignora)||', onde: '
                      ||vr_dscarque||'Descompactados e processados = '||vr_qtdarquiv
                      ||vr_dscarque||'Ignorados(CETIP desconhecido ou RelBatchs) = '||vr_qtdignora
                      ||vr_dscarque||'Todos os arquivos encontram-se na pasta de backup';
        -- Se há avisos
        IF vr_dsdaviso IS NOT NULL THEN
          pr_dsdaviso := pr_dsdaviso ||vr_dscarque||'Avisos: '||vr_dsdaviso;
        END IF;                    
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhum arquivo recebido!';
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_checar_zips_recebe_cd' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := nvl(pr_idcritic,1); -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_checar_zips_recebe_cd' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                 
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_checar_zips_recebe_cd;
  
  -- Rotina para processar retorno de arquivos pendentes de processamento
  PROCEDURE pc_processa_retorno_arquivos(pr_dsdemail  IN VARCHAR2     --> Destinatários
                                        ,pr_dsjanexe  IN VARCHAR2     --> Descrição horário execução
                                        ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                        ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                        ,pr_cdcritic OUT NUMBER       --> Código da critica
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_processa_retorno_arquivos
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Processar e integrar arquivos de Retorno pendentes de processamento
    -- Alteracoes:
    --
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_txretorn    gene0002.typ_split; --> Separação da linha em vetor
      vr_nrobusca    NUMBER;             --> Variavel para soma no idx da coluna pois o Registro possui um campo adicional
      vr_qtdsuces    NUMBER;             --> Quantidade de Sucessos
      vr_qtderros    NUMBER;             --> Quantidade de Erros
      vr_flerrger    BOOLEAN;            --> Flag de erro geral
      vr_dscodigB3   tbcapt_custodia_aplicacao.dscodigo_b3%TYPE; --> Codigo da aplicação na B3
      vr_cdopercetip tbcapt_custodia_lanctos.cdoperac_cetip%TYPE; -- Codigo da operação Cetip
      -- Quantidade de arquivos processados
      vr_qtdaruiv NUMBER := 0;

      -- Busca dos arquivps pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
              ,arq.idarquivo_origem
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.idsituacao = 0 -- Pendente Processamento
           AND arq.idtipo_arquivo <> 9 -- Ignorar arquivos de conciliação
         ORDER BY arq.idarquivo
         FOR UPDATE;
      rw_arq cr_arquivos%ROWTYPE;
      
      -- Busca do conteudo do arquivo 
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.nrseq_linha
              ,cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
           AND cnt.idtipo_linha IN('L','D') --> Somente as linhas de informações ou detalhes
         ORDER BY cnt.nrseq_linha;

      -- Busca do registro no arquivo de origem
      CURSOR cr_cont_orig(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE
                         ,pr_nrseq_linha tbcapt_custodia_conteudo_arq.nrseq_linha%TYPE) IS
        SELECT cnt.dslinha
              ,cnt.idaplicacao
              ,cnt.idlancamento
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo   = pr_idarquivo
           AND cnt.nrseq_linha = pr_nrseq_linha;
      rw_cont_orig cr_cont_orig%ROWTYPE;
      
    BEGIN
  	  -- Inclusão do módulo e ação logado
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_processa_retorno_arquivos'); 
      -- Incluir LOG 
      pr_dsdaviso := fn_get_time_char || 'Iniciando Processamento e Integração de Arquivos de Retorno Devolvidos pela B3...';      
      -- Buscamos todos os arquivos pendentes de envio 
      LOOP
        OPEN cr_arquivos;
        FETCH cr_arquivos
         INTO rw_arq;
        -- Sair ao não encontrar
        IF cr_arquivos%NOTFOUND THEN 
          CLOSE cr_arquivos;
          EXIT;
        ELSE
          CLOSE cr_arquivos;
        END IF;
        -- Incrementar contador
        vr_qtdaruiv := vr_qtdaruiv + 1;
        -- Resetar contadores internos
        vr_qtdsuces := 0;
        vr_qtderros := 0;
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
        rw_cont_orig := NULL;
        vr_flerrger := FALSE;
        -- Arquivo de Registro posusi a coluna Código IF, portanto 
        -- buscaremos o texto e linha original somando +1 no idx de busca
        IF rw_arq.idtipo_arquivo = 1 THEN 
          vr_nrobusca := 1;
        ELSE
          vr_nrobusca := 0;
        END IF;  
        -- Processar todas as linhas do arquivo 
        FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP 
          -- Cada linha será separada em vetor para facilitar o processamento 
          vr_txretorn := gene0002.fn_quebra_string(rw_cnt.dslinha, ';');
          -- Verifica se a quebra resultou em um array válido
          -- e com pelo menos 4 posições para RGT e 5 posições para REG
          IF vr_txretorn.count() = 0 
          OR (rw_arq.idtipo_arquivo = 2 AND vr_txretorn.count() <> 4)
          OR (rw_arq.idtipo_arquivo = 1 AND vr_txretorn.count() <> 5) THEN 
            -- Invalidar a linha pois o Layout da mesma não confere
            BEGIN 
              UPDATE tbcapt_custodia_conteudo_arq cnt
                 SET cnt.dscritica = 'Retorno não confere com o Layout definido! O mesmo não será processado!'
               WHERE cnt.idarquivo   = rw_arq.idarquivo
                 AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                            || 'dscritica: Retorno não confere com o Layout definido! O mesmo não será processado!'
                            || ' com idarquivo: '||rw_arq.idarquivo
                            || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Incrementar erro
            vr_qtderros := vr_qtderros + 1;
          ELSE 
            -- Testar se o retorno não é um erro geral do arquivo, ou seja, todas as linhas serão invalidadas
            IF vr_txretorn(1) IS NULL AND vr_txretorn(3+vr_nrobusca) IS NOT NULL THEN 
              -- Invalidaremos todas as linhas com esta critica 
              BEGIN 
                UPDATE tbcapt_custodia_conteudo_arq cnt
                   SET cnt.dscritica = vr_txretorn(3+vr_nrobusca)
                 WHERE cnt.idarquivo   IN(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                   AND cnt.idtipo_linha IN('L','D'); --> Somente as linhas de informações
                -- Quantidade de erros é 1 pois é um erro único e geral
                vr_qtderros := 1;
                vr_flerrger := TRUE;
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                              || 'dscritica: '||vr_txretorn(3+vr_nrobusca)
                              || ' com idarquivo in('||rw_arq.idarquivo||','||rw_arq.idarquivo_origem||')'
                              || ' , idtipo_linha: L'
                              || '. '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
              -- Atualizaremos todos os lançamentos vinculados ao envio com o erro retornado
              BEGIN 
                UPDATE tbcapt_custodia_lanctos lct
                   SET lct.idsituacao = 9 -- Critica
                      ,lct.dtretorno = SYSDATE
                 WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                             FROM tbcapt_custodia_conteudo_arq cnt
                                            WHERE cnt.idarquivo = rw_arq.idarquivo_origem);
              EXCEPTION
                WHEN OTHERS THEN
                  -- Erro não tratado 
                  vr_cdcritic := 1035;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                              || 'idsituacao: 9'
                              || ' ,dtretorno = '||SYSDATE
                              || ' com idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||'. '||sqlerrm;
                  RAISE vr_exc_saida;
                END;
            ELSE
              -- Remover quebras de linha 
              vr_txretorn(4+vr_nrobusca) := fn_remove_quebra(vr_txretorn(4+vr_nrobusca));
              -- Buscaremos o mesmo registro no arquivo de envio 
              OPEN cr_cont_orig(rw_arq.idarquivo_origem,vr_txretorn(1));
              FETCH cr_cont_orig
               INTO rw_cont_orig;
              -- Se não encontrou 
              -- OU encontrou mas o conteudo da linha é diferente do recebido
              -- OU encontrou, o conteudo é igual, mas recebemos critica
              IF cr_cont_orig%NOTFOUND 
              OR rw_cont_orig.dslinha <> vr_txretorn(4+vr_nrobusca)
              OR UPPER(vr_txretorn(3+vr_nrobusca)) <> 'EXECUCAO OK' THEN 
                -- Montar critica conforme a opção que entrou
                IF cr_cont_orig%NOTFOUND THEN
                  vr_dscritic := 'Linha Original retornada não encontrada no arquivo de envio';
                ELSIF rw_cont_orig.dslinha <> vr_txretorn(4+vr_nrobusca) THEN
                  vr_dscritic := 'Conteudo da Linha Original retornado não confere com a linha Original enviada';
                ELSE
                  vr_dscritic := vr_txretorn(3+vr_nrobusca);
                END IF;
                CLOSE cr_cont_orig;
                -- Geraremos erro 
                BEGIN 
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.dscritica = vr_dscritic
                   WHERE cnt.idarquivo   in(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  -- Quantidade de erros incrementada
                  vr_qtderros := vr_qtderros + 1;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                                || 'dscritica: '||vr_dscritic
                                || ' com idarquivo: in('||rw_arq.idarquivo||','||rw_arq.idarquivo_origem||')'
                                || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;
                -- Atualizaremos o lançamento correspondente vinculado ao envio
                BEGIN 
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao = 9 -- Critica
                        ,lct.dtretorno = SYSDATE
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                                AND cnt.nrseq_linha = rw_cnt.nrseq_linha);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                                || 'idsituacao: 9'
                                || ' ,dtretorno = '||SYSDATE
                                || ' com idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||' AND cnt.nrseq_linha = '||rw_cnt.nrseq_linha||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                  END;
              ELSE
                CLOSE cr_cont_orig;
                -- Execução OK, guardar codigo B3 para registros e codigo operação cetip para todos
                IF rw_arq.idtipo_arquivo = 1 THEN 
                  vr_dscodigB3 := vr_txretorn(2);
                  vr_cdopercetip := vr_txretorn(3);
                  -- Atualizar registro de Custodia Aplicação
                  -- caso ainda não tenhamos o feito
                  BEGIN 
                    UPDATE tbcapt_custodia_aplicacao apl
                       SET apl.dscodigo_b3 = vr_dscodigB3
                          ,apl.dtregistro = SYSDATE
                     WHERE apl.idaplicacao = rw_cont_orig.idaplicacao
                       AND apl.dscodigo_b3 IS NULL;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Erro não tratado 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_aplicacao: '
                                  || 'dscodigo_b3: '||vr_dscodigB3
                                  || ' ,dtregistro = '||SYSDATE
                                  || ' com idaplicacao : '||rw_cont_orig.idaplicacao
                                  || ' , dscodigo_b3 : null '
                                  || '. '||sqlerrm;
                      RAISE vr_exc_saida;
                  END; 
                ELSE
                  vr_dscodigB3 := NULL;
                  vr_cdopercetip := vr_txretorn(2);
                END IF;
                -- Atualizaremos o registro de envio e de retorno
                BEGIN 
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.idaplicacao  = rw_cont_orig.idaplicacao
                        ,cnt.idlancamento = rw_cont_orig.idlancamento
                        ,cnt.dscodigo_b3  = nvl(vr_dscodigB3,cnt.dscodigo_b3)
                        ,cnt.cdoperac_cetip = vr_cdopercetip
                        ,cnt.dscritica    = NULL
                   WHERE cnt.idarquivo   IN(rw_arq.idarquivo,rw_arq.idarquivo_origem)
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  -- Quantidade de erros incrementada
                  vr_qtdsuces := vr_qtdsuces + 1;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                                || 'idaplicacao: '||rw_cont_orig.idaplicacao
                                || ', idlancamento: '||rw_cont_orig.idlancamento
                                || ', dscodigo_b3: '||vr_dscodigB3
                                || ' com idarquivo in('||rw_arq.idarquivo||','||rw_arq.idarquivo_origem||')'
                                || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;                  
                -- Atualizaremos o lançamento correspondente vinculado ao envio
                BEGIN 
                  UPDATE tbcapt_custodia_lanctos lct
                     SET lct.idsituacao     = 8 -- Custodiado com sucesso 
                        ,lct.dtretorno      = SYSDATE
                        ,lct.cdoperac_cetip = vr_cdopercetip
                   WHERE lct.idlancamento IN(SELECT cnt.idlancamento
                                               FROM tbcapt_custodia_conteudo_arq cnt
                                              WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                                AND cnt.nrseq_linha = rw_cnt.nrseq_linha);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                                || 'idsituacao: 8'
                                || ' ,dtretorno = '||SYSDATE
                                || ' com idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||' AND cnt.nrseq_linha = '||rw_cnt.nrseq_linha||'. '||sqlerrm;
                    RAISE vr_exc_saida;
                  END;
              END IF;
            END IF;
          END IF;
        END LOOP;
        -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
        BEGIN
          INSERT INTO TBCAPT_CUSTODIA_LOG
                     (idarquivo 
                     ,dtlog
                     ,dslog)
               VALUES(rw_arq.idarquivo
                     ,SYSDATE
                     ,'Arquivo '||rw_arq.nmarquivo||' processado com:'||vr_dscarque||
                      'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                      'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                      'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros));
        EXCEPTION
          WHEN OTHERS THEN
            -- Erro não tratado 
            vr_cdcritic := 1034;   
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                        || 'idarquivo: '||rw_arq.idarquivo
                        || ', dtlog: '||SYSDATE
                        || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' processado com:'||vr_dscarque||
                                        'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                                        'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                                        'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros)
                        || '. '||sqlerrm;
            RAISE vr_exc_saida;
        END;
          
        -- Atualizaremos o arquivo de retorno
        BEGIN 
          UPDATE tbcapt_custodia_arquivo arq
             SET arq.idsituacao = 1       -- Processado
                ,arq.dtprocesso = SYSDATE -- Momento do Processo
           WHERE arq.idarquivo = rw_arq.idarquivo;
        EXCEPTION
          WHEN OTHERS THEN
            -- Erro não tratado 
            vr_cdcritic := 1035;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_arquivo: '
                        || 'idsituacao: 1' 
                        || ', dtprocesso: '||SYSDATE
                        || ' com idarquivo: '||rw_arq.idarquivo||'. '||sqlerrm;
            RAISE vr_exc_saida;
        END;
        
        -- Se existe arquivo de origem
        IF rw_arq.idarquivo_origem IS NOT NULL THEN 
          -- Atualizar registros no arquivo de Origem que não existe no de Retorno para Erro
          BEGIN 
            UPDATE tbcapt_custodia_conteudo_arq cnt
               SET cnt.dscritica = 'Registro sem retorno'
             WHERE cnt.idarquivo = rw_arq.idarquivo_origem
               AND cnt.idtipo_linha IN('L','D') --> Somente as linhas de informações e detalhes
               AND cnt.idlancamento NOT IN(SELECT cnt.idlancamento
                                             FROM tbcapt_custodia_conteudo_arq cnt
                                            WHERE cnt.idarquivo = rw_arq.idarquivo);
            -- Incrementar quantidade de erros
            vr_qtderros := vr_qtderros + SQL%ROWCOUNT;
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                          || 'dscritica: Registro sem retorno'
                          || ' com idarquivo = '||rw_arq.idarquivo_origem
                          || ' , idtipo_linha: L'
                          || ' , idlancamento not in(SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo||')'
                          || '. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          -- Atualizar possíveis lançamentos que não foram retornados no arquivo para erro
          -- pois se encontramos retorno todos os registros devem estar no mesmo
          BEGIN 
            UPDATE tbcapt_custodia_lanctos lct
               SET lct.idsituacao = 9 -- Erro
                  ,lct.dtretorno = SYSDATE
             WHERE lct.idsituacao NOT IN(8,9) -- Aqueles não processados ainda
               AND lct.idlancamento IN(SELECT cnt.idlancamento
                                         FROM tbcapt_custodia_conteudo_arq cnt
                                        WHERE cnt.idarquivo = rw_arq.idarquivo_origem
                                          AND cnt.dscritica = 'Registro sem retorno');
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_lanctos: '
                          || 'idsituacao: 9'
                          || ' ,dtretorno = '||SYSDATE
                          || ' com idsituacao NOT IN(8,9) '
                          || ' , idlancamento in: SELECT cnt.idlancamento FROM tbcapt_custodia_conteudo_arq cnt WHERE cnt.idarquivo = '||rw_arq.idarquivo_origem||' and cnt.dscritica = Registro sem retorno. '||sqlerrm;
              RAISE vr_exc_saida;
          END;
          
        END IF;  
          
        -- Após processar o arquivo, se houve algum erro
        IF vr_qtderros > 0 THEN 
           pc_envia_email_alerta_arq(pr_dsdemail  => pr_dsdemail      --> Destinatários
                                    ,pr_dsjanexe  => pr_dsjanexe      --> Descrição horário execução
                                    ,pr_idarquivo => rw_arq.idarquivo --> ID do arquivo
                                    ,pr_dsdirbkp  => NULL             --> Caminho de backup linux
                                    ,pr_dsredbkp  => NULL             --> Caminho da rede de Backup
                                    ,pr_flgerrger => vr_flerrger      --> erro geral do arquivo
                                    ,pr_idcritic  => vr_idcritic      --> Criticidade da saida
                                    ,pr_cdcritic  => vr_cdcritic      --> Código da critica
                                    ,pr_dscritic  => vr_dscritic);    --> Descrição da critica
          -- Em caso de erro
          IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        -- Enviar ao LOG resumo da execução
        IF vr_qtderros + vr_qtdsuces > 0 THEN 
          pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 
                      'Arquivo '||rw_arq.nmarquivo||' processado com:'||vr_dscarque||
                      'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                      'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque;
        END IF;
        -- Gravar a cada arquivo com sucesso
        COMMIT;
        -- Sair se processou a quantidade máxima de arquivos por execução
        IF vr_qtdaruiv >= vr_qtdexjob THEN 
          EXIT;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_retorno_arquivos' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := nvl(vr_idcritic,2); -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_retorno_arquivos' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                   
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_processa_retorno_arquivos;
  
  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processa_conciliacao(pr_flprccnc  IN VARCHAR2     --> Conciliação ativa
                                   ,pr_dtultcnc  IN DATE         --> Data da ultima conciiação
                                   ,pr_dsdemail  IN VARCHAR2     --> Destinatários
                                   ,pr_dsjanexe  IN VARCHAR2     --> Descrição horário execução
                                   ,pr_dsdirbkp  IN VARCHAR2     --> Caminho de backup linux
                                   ,pr_dsredbkp  IN VARCHAR2      --> Caminho da rede de Backup
                                   ,pr_dsdaviso OUT VARCHAR2     --> Avisos dos eventos ocorridos no processo
                                   ,pr_idcritic OUT NUMBER       --> Criticidade da saida
                                   ,pr_cdcritic OUT NUMBER       --> Código da critica
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_processa_conciliacao
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 12/12/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Processar e integrar arquivos de conciliação
    -- Alteracoes:
    --             06/12/2018 - P411 - Remocao da conciliação por saldo, manter apenas por quantidade (Marcos-Envolti)
    -- 
    --             12/12/2018 - P411 - Ajustes para o Layout para 15 posições (Marcos-Envolti)
	--
	--				19/03/2019 - P411 - Ajustes na conciliação para considerar percentuais de tolerancia (Martini)																											   
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_txretorn   gene0002.typ_split; --> Separação da linha em vetor
      vr_qtdsuces   NUMBER;             --> Quantidade de Sucessos
      vr_qtderros   NUMBER;             --> Quantidade de Erros
      vr_dtmvtolt   DATE;               --> Data do arquivo
      vr_flerrger   BOOLEAN;            --> Flag de erro geral
      vr_qtdausen   NUMBER;             --> Quantidade de aplicações ausentes no arquivo
      -- Quantidade de arquivos processados
      vr_qtdaruiv NUMBER := 0;
      
      -- Busca dos arquivos pendentes e seu conteudo
      CURSOR cr_arquivos IS
        SELECT arq.idarquivo
              ,arq.nmarquivo
              ,arq.idtipo_arquivo
              ,arq.idarquivo_origem
          FROM tbcapt_custodia_arquivo arq
         WHERE arq.idtipo_operacao = 'R'
           AND arq.idsituacao = 0 -- Pendente Processamento
           AND arq.idtipo_arquivo = 9 -- Concliação
         ORDER BY arq.idarquivo
         FOR UPDATE;
      rw_arq cr_arquivos%ROWTYPE;   

      -- Busca do conteudo do arquivo 
      CURSOR cr_conteudo(pr_idarquivo tbcapt_custodia_arquivo.idarquivo%TYPE) IS
        SELECT cnt.nrseq_linha
              ,cnt.dslinha
          FROM tbcapt_custodia_conteudo_arq cnt
         WHERE cnt.idarquivo = pr_idarquivo
           AND cnt.idtipo_linha = 'L' --> Somente as linhas de informações
         ORDER BY cnt.nrseq_linha;
      
      -- Buscar aplicação em Custódia
      CURSOR cr_aplica(pr_dscodigB3 tbcapt_custodia_aplicacao.dscodigo_b3%TYPE) IS
        SELECT apl.idaplicacao
              ,apl.tpaplicacao
              ,0 cdcooper
              ,0 nrdconta
              ,0 nraplica
              ,0 cdprodut
              ,to_date(NULL) dtmvtolt
              ,to_date(NULL) dtvencto
              ,apl.qtcotas
              ,apl.vlpreco_registro
          FROM tbcapt_custodia_aplicacao apl
        WHERE apl.dscodigo_b3 = pr_dscodigB3;
      rw_aplica cr_aplica%ROWTYPE;  
      
      -- Buscar aplicação RDA
      CURSOR cr_craprda(pr_idaplcus craprda.idaplcus%TYPE) IS
        SELECT rda.cdcooper
              ,rda.nrdconta
              ,rda.nraplica
              ,rda.dtmvtolt
              ,rda.dtvencto
          FROM craprda rda
         WHERE rda.idaplcus = pr_idaplcus;
      
      -- Buscar aplicação RAC
      CURSOR cr_craprac(pr_idaplcus craprac.idaplcus%TYPE) IS
        SELECT rac.cdcooper
              ,rac.nrdconta
              ,rac.nraplica
              ,rac.cdprodut
              ,rac.dtmvtolt
              ,rac.dtvencto
          FROM craprac rac
         WHERE rac.idaplcus = pr_idaplcus;

      
      -- Buscar todas as aplicações existentes no Ayllos e que não foram conciliadas
      CURSOR cr_aplica_sem_concil IS
        SELECT COUNT(1)
          FROM tbcapt_custodia_aplicacao apl
         WHERE apl.dscodigo_b3 IS NOT NULL
           AND apl.qtcotas > 0
           AND apl.dtconcilia < trunc(SYSDATE);

      -- Saldo da aplicação e preço unitário
      vr_sldaplic craprda.vlsdrdca%TYPE;
      vr_vlpreco_unit tbcapt_custodia_aplicacao.vlpreco_unitario%TYPE; 
      vr_valor_tot_b3 NUMBER(38,8);
      
		 -- Busca do valor conciliado
      CURSOR cr_saldo(pr_cdcooper    tbcapt_saldo_aplica.cdcooper%TYPE   
                     ,pr_nrdconta    tbcapt_saldo_aplica.nrdconta%TYPE   
                     ,pr_nraplica    tbcapt_saldo_aplica.nraplica%TYPE   
                     ,pr_tpaplicacao tbcapt_saldo_aplica.tpaplicacao%TYPE
                     ,pr_dtmvtolt    tbcapt_saldo_aplica.dtmvtolt%TYPE) IS
        SELECT sl.VLSALDO_CONCILIA
          FROM tbcapt_saldo_aplica sl
         WHERE sl.cdcooper    = pr_cdcooper   
           AND sl.nrdconta    = pr_nrdconta   
           AND sl.nraplica    = pr_nraplica   
           AND sl.tpaplicacao = pr_tpaplicacao
           AND sl.dtmvtolt    = pr_dtmvtolt;
          
      -- Percentual de tolerancia
      vr_vlpertol NUMBER(25,5);	   
      
      -- Flag de conciliação OK
      vr_flgconcil BOOLEAN := FALSE;
      
      -- Busca do dia util anterior
      vr_dtmvtoan DATE;
      
	  -- Tipo de aplicação da tabela TBCAPT_SALDO_APLICA
	  -- tipo de aplicacao (1 - rdc pos e pre / 2 - pcapta / 3 - aplic programada) 
	  -- David Valente (Envolti) 							 
      vr_tpaplicacao NUMBER(2);
	
    BEGIN
  	  -- Inclusão do módulo e ação logado
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_processa_conciliacao'); 
      -- Incluir LOG
      pr_dsdaviso := fn_get_time_char || 'Iniciando Processamento e Integração de Arquivos Conciliação Devolvidos pela B3...';      
      
	  -- Buscar o percentual de tolerancia
      BEGIN
         vr_vlpertol := gene0001.fn_param_sistema('CRED',3,'CD_TOLERANCIA_DIF_VALOR');
      EXCEPTION
         WHEN OTHERS THEN  
           vr_vlpertol := 0;
      END;
      	  
      -- Somente proceder se conciliação estiver ativa e ainda não efetuada para o dia
      IF pr_flprccnc = 'S' AND pr_dtultcnc < trunc(SYSDATE) THEN 
        -- Busca do dia util anterior
        vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper  => 3
                                                  ,pr_dtmvtolt  => trunc(SYSDATE)-1
                                                  ,pr_tipo      => 'A');
        -- Buscamos todos os arquivos pendentes de conciliação 
        LOOP
          OPEN cr_arquivos;
          FETCH cr_arquivos
           INTO rw_arq;
          -- Sair ao não encontrar
          IF cr_arquivos%NOTFOUND THEN 
            CLOSE cr_arquivos;
            EXIT;
          ELSE
            CLOSE cr_arquivos;
          END IF;              
          -- Incrementar contador
          vr_qtdaruiv := vr_qtdaruiv + 1;
          -- Resetar contadores internos do arquivo
          vr_qtdsuces := 0;
          vr_qtderros := 0;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          vr_dtmvtolt := NULL;
          vr_flerrger := FALSE;
          -- Buscar data do arquivo ('CETIP_[0-9][0-9][0-9][0-9][0-9][0-9]_[A-Z][A-Z]_.*DPOSICAOCUSTODIA')
          BEGIN
            vr_dtmvtolt := to_date(SUBSTR(rw_arq.nmarquivo,7,6),'rrmmdd');
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao definir data a partir do nome do Arquivo';
          END;
          -- A data do arquivo não pode ser inferior ao dia util anterior
          IF vr_dtmvtoan > vr_dtmvtolt THEN
            -- Gerar critica
            vr_dscritic := 'Recebido arquivo de conciliação com data antiga ('||to_char(vr_dtmvtolt,'dd/mm/rrrr')||'), será processado apenas o arquivo de '||to_char(vr_dtmvtoan,'dd/mm/rrrr');
          END IF;
          -- Em caso de erro na definição acima
          IF vr_dscritic IS NOT NULL THEN 
            -- Geraremos erro em todas as linhas do arquivo
            BEGIN 
              UPDATE tbcapt_custodia_conteudo_arq cnt
                 SET cnt.dscritica = vr_dscritic
               WHERE cnt.idarquivo   = rw_arq.idarquivo;
              -- Quantidade de erros incrementada
              vr_qtderros := SQL%ROWCOUNT;
              vr_flerrger := TRUE; -- Erro geral
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1035;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                            || 'dscritica: '||vr_dscritic
                            || ' com idarquivo: '||rw_arq.idarquivo
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
            -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo 
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,'Arquivo '||rw_arq.nmarquivo||' não conciliado!'||vr_dscarque||
                          'Problema encontrado: '||vr_dscritic||vr_dscarque);
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1034;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                            || 'idarquivo: '||rw_arq.idarquivo
                            || ', dtlog: '||SYSDATE
                            || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' não conciliado!'||vr_dscarque||
                                            'Problema encontrado: '||vr_dscritic||vr_dscarque
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
          ELSE 
            -- Setar a flag de encontro do arquivo de conciliação do dia
            vr_flgconcil := TRUE;
            -- Processar todas as linhas do arquivo 
            FOR rw_cnt IN cr_conteudo(rw_arq.idarquivo) LOOP 
              -- Limpar criticas
              vr_dscritic := NULL;
              -- Cada linha será separada em vetor para facilitar o processamento 
              vr_txretorn := gene0002.fn_quebra_string(rw_cnt.dslinha, ';');
              -- Verifica se a quebra resultou em um array válido e com pelo menos 27 posições 
              IF vr_txretorn.count() = 0 OR vr_txretorn.count() < 27 THEN 
                -- Invalidar a linha pois o Layout da mesma não confere
                BEGIN 
                  UPDATE tbcapt_custodia_conteudo_arq cnt
                     SET cnt.dscritica = 'Conciliação não confere com o Layout definido! O mesmo não será processado!'
                   WHERE cnt.idarquivo   = rw_arq.idarquivo
                     AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- Erro não tratado 
                    vr_cdcritic := 1035;
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                                || 'dscritica: Conciliação não confere com o Layout definido! O mesmo não será processado!'
                                || ' com idarquivo: '||rw_arq.idarquivo
                                || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                                || '. '||sqlerrm;
                    RAISE vr_exc_saida;
                END;
                -- Incrementar erro
                vr_qtderros := vr_qtderros + 1;
              ELSE   
                -- Validar Tipo ID
                IF vr_txretorn(4) <> 'RDB' THEN  
                  vr_dscritic := 'Tipo de Instrumento Financeiro ('||vr_txretorn(4)||') diferente de (RDB)!';
                -- Validar TIpo de Posição de Custódia
                ELSIF vr_txretorn(13) <> '1' THEN
                  vr_dscritic := 'Tipo de Posição em Custódia ('||vr_txretorn(13)||') diferente de (1)!';
                ELSE
                  -- Busca da aplicação conforme códigoIF
                  rw_aplica := NULL;
                  OPEN cr_aplica(vr_txretorn(5));
                  FETCH cr_aplica
                   INTO rw_aplica;
                  -- Se não encontrar
                  IF cr_aplica%NOTFOUND THEN 
                    CLOSE cr_aplica;
                    vr_dscritic := 'Aplicação '||vr_txretorn(5) ||' não encontrada para Conciliação!';
                  ELSIF rw_aplica.qtcotas = 0 THEN
                    CLOSE cr_aplica;
                    vr_dscritic := 'Aplicação '||vr_txretorn(5) ||' com Qtde Cotas igual a zero!';
                  ELSE
                    CLOSE cr_aplica;
					
					-- Variavel de controle com o tipo de aplicação
                    -- se for aplicações do tipo 3 ou 4, recebe 2 senão recebe 1 
                    -- para compatibilizar com os dados da tbcapt_saldo_aplica que recebe somente 1,2 ou 3
                    vr_tpaplicacao := 0; 
					
                    -- Buscar aplicação RDA ou RAC relacionada
                    IF rw_aplica.tpaplicacao IN(3,4) THEN 
                      -- Buscar aplicação RAC
                      OPEN cr_craprac(rw_aplica.idaplicacao);
                      FETCH cr_craprac
                       INTO rw_aplica.cdcooper
                           ,rw_aplica.nrdconta
                           ,rw_aplica.nraplica
                           ,rw_aplica.cdprodut
                           ,rw_aplica.dtmvtolt
                           ,rw_aplica.dtvencto;
                      CLOSE cr_craprac;
					  
					  vr_tpaplicacao := 2;				  
					  
                    ELSE
                      -- Buscar aplicação RDA
                      OPEN cr_craprda(rw_aplica.idaplicacao);
                      FETCH cr_craprda
                       INTO rw_aplica.cdcooper
                           ,rw_aplica.nrdconta
                           ,rw_aplica.nraplica
                           ,rw_aplica.dtmvtolt
                           ,rw_aplica.dtvencto;
                      CLOSE cr_craprda;                
					  
					  vr_tpaplicacao := 1;				  
					  
                    END IF;
                    -- Caso não tenha encontrado a aplicação correspondente
                    IF rw_aplica.cdcooper + rw_aplica.nrdconta + rw_aplica.nraplica = 0 THEN 
                      vr_dscritic := 'Aplicação (RDA ou RAC) ID '||rw_aplica.idaplicacao||' não encontrada para Conciliação!';
                    ELSE
                      -- Validar DAta de Vencimento e Emissão da Aplicação
                      IF TO_CHAR(rw_aplica.dtmvtolt,'RRRRMMDD') <> vr_txretorn(9) THEN 
                        vr_dscritic := 'Data de Emissão ('||vr_txretorn(9)||') diferente da Data Emissão Aplicação ('||TO_CHAR(rw_aplica.dtmvtolt,'RRRRMMDD')||').';
                      ELSIF TO_CHAR(rw_aplica.dtvencto,'RRRRMMDD') <> vr_txretorn(10) THEN 
                        vr_dscritic := 'Data de Vencimento ('||vr_txretorn(10)||') diferente da Data Vencimento Aplicação ('||TO_CHAR(rw_aplica.dtvencto,'RRRRMMDD')||').';
					  /* Conciliar quantidade em cotas */
                      ELSIF TO_NUMBER(rw_aplica.qtcotas) <> TO_NUMBER(vr_txretorn(14)) THEN
                        vr_dscritic := 'Quantidade em Carteira ('||vr_txretorn(14)||') diferente da Quantidade de Cotas da Aplicação ('||rw_aplica.qtcotas||').';
                      ELSE
                        -- Buscar  saldo calculado da aplicação
                        vr_sldaplic := 0;
                        OPEN cr_saldo(rw_aplica.cdcooper
                                     ,rw_aplica.nrdconta
                                     ,rw_aplica.nraplica
                                     ,vr_tpaplicacao
                                     ,vr_dtmvtoan);																		  
                        FETCH cr_saldo																			 
                         INTO vr_sldaplic;   
                        CLOSE cr_saldo;     
						
                        -- Calcular valor unitário novamente com base no Saldo Ayllos X Quantidade de cotas
                        vr_vlpreco_unit := vr_sldaplic / rw_aplica.qtcotas; 

                        vr_valor_tot_b3 := TO_NUMBER(vr_txretorn(14)) * vr_txretorn(16);  -- qtde b3 * pu b3;
                        
                        -- Validar valor nominal 
                        IF rw_aplica.vlpreco_registro <> vr_txretorn(15) THEN
                          vr_dscritic := 'Valor Nominal ('||vr_txretorn(15)||') diferente do Registrado da Aplicação ('||rw_aplica.vlpreco_registro||'), tolerancia ('||vr_vlpertol||'%).';
                        -- Validar a PA atual recebida versus a calculada no 445 no processo
                     --   ELSIF ABS(((vr_vlpreco_unit - vr_txretorn(16)) / vr_txretorn(16)) * 100) < vr_vlpertol THEN
                     --     vr_dscritic := 'Valor da P.U. ('||vr_txretorn(16)||') diferente da P.U. calculada da Aplicação ('||vr_vlpreco_unit||'), tolerancia ('||vr_vlpertol||'%).';
                        ELSIF ABS(((vr_sldaplic - vr_valor_tot_b3) / vr_valor_tot_b3) * 100) > vr_vlpertol THEN
                          vr_dscritic := 'Valor da Aplic. B3 ('||vr_valor_tot_b3||') diferente do valor da aplicação no Aimaro ('||vr_sldaplic||'), tolerancia ('||vr_vlpertol||'%).';
                        END IF;
                      END IF;  
                    END IF;
                  END IF; 
                END IF;  
                
                -- Em caso de erro
                IF vr_dscritic IS NOT NULL THEN 
                  -- Quantidade de erros incrementada
                  vr_qtderros := vr_qtderros + 1;
                  -- Atualizar erro na conciliação da aplicação
                  IF rw_aplica.idaplicacao IS NOT NULL THEN 
                    BEGIN 
                      UPDATE tbcapt_custodia_aplicacao apl
                         SET apl.idsitua_concilia = 2
                            ,apl.dtconcilia = SYSDATE
                       WHERE apl.idaplicacao = rw_aplica.idaplicacao;
                    EXCEPTION
                      WHEN OTHERS THEN
                        -- Erro não tratado 
                        vr_cdcritic := 1035;
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_aplicacao: '
                                    || 'dtconcilia: '||SYSDATE
                                    || ' ,idsitua_concilia = 2'
                                    || ' com idaplicacao : '||rw_aplica.idaplicacao
                                    || '. '||sqlerrm;
                        RAISE vr_exc_saida;
                    END; 
                  END IF;
                  -- Geraremos erro no lançamento
                  BEGIN 
                    UPDATE tbcapt_custodia_conteudo_arq cnt
                       SET cnt.dscritica = vr_dscritic
                          ,cnt.dscodigo_b3 = vr_txretorn(5)
                          ,cnt.idaplicacao = rw_aplica.idaplicacao
                     WHERE cnt.idarquivo   = rw_arq.idarquivo
                       AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Erro não tratado 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                                  || 'dscritica: '||vr_dscritic
                                  || ' ,dscodigo_b3: '||vr_txretorn(5)
                                  || ' ,idaplicacao: '||rw_aplica.idaplicacao
                                  || ' com idarquivo: '||rw_arq.idarquivo
                                  || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                                  || '. '||sqlerrm;
                      RAISE vr_exc_saida;
                  END;
                ELSE    
                  -- Quantidade de sucessos incrementada
                  vr_qtdsuces := vr_qtdsuces + 1; 
                  -- Atualizar aplicação como conciiada         
                  BEGIN 
                    UPDATE tbcapt_custodia_aplicacao apl
                       SET apl.idsitua_concilia = 1
                          ,apl.dtconcilia = SYSDATE
                          --,apl.vlpreco_unitario = vr_vlpreco_unit
                     WHERE apl.idaplicacao = rw_aplica.idaplicacao;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Erro não tratado 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_aplicacao: '
                                  || 'dtconcilia: '||SYSDATE
                                  || ' ,idsitua_concilia = 1'
                                  || ' com idaplicacao : '||rw_aplica.idaplicacao
                                  || '. '||sqlerrm;
                      RAISE vr_exc_saida;
                  END;
                  -- Atualizar dados do registro conciliado
                  BEGIN 
                    UPDATE tbcapt_custodia_conteudo_arq cnt
                       SET cnt.dscodigo_b3 = vr_txretorn(5)
                          ,cnt.idaplicacao = rw_aplica.idaplicacao
                          ,cnt.dscritica   = NULL
                     WHERE cnt.idarquivo   = rw_arq.idarquivo
                       AND cnt.nrseq_linha = rw_cnt.nrseq_linha;
                  EXCEPTION
                    WHEN OTHERS THEN
                      -- Erro não tratado 
                      vr_cdcritic := 1035;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_conteudo_arq: '
                                  || 'dscodigo_b3: '||vr_txretorn(5)
                                  || ' ,idaplicacao: '||rw_aplica.idaplicacao
                                  || ' com idarquivo: '||rw_arq.idarquivo
                                  || ' , nrseq_linha: '||rw_cnt.nrseq_linha
                                  || '. '||sqlerrm;
                      RAISE vr_exc_saida;
                  END;
                END IF;  
              END IF;
            END LOOP;
            -- Buscar todas as aplicações existentes no Ayllos e que não foram conciliadas
            OPEN cr_aplica_sem_concil;
            FETCH cr_aplica_sem_concil
             INTO vr_qtdausen;
            CLOSE cr_aplica_sem_concil;
            -- Gerar LOG após processar todas as linhas retornadas daquele arquivo
            BEGIN
              INSERT INTO TBCAPT_CUSTODIA_LOG
                         (idarquivo 
                         ,dtlog
                         ,dslog)
                   VALUES(rw_arq.idarquivo
                         ,SYSDATE
                         ,'Arquivo '||rw_arq.nmarquivo||' conciliado com:'||vr_dscarque||
                          'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                          'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                          'QUantidade de Aplicações ausentes no arquivo: '||vr_qtdausen||vr_dscarque||
                          'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros));
            EXCEPTION
              WHEN OTHERS THEN
                -- Erro não tratado 
                vr_cdcritic := 1034;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' TBCAPT_CUSTODIA_LOG: '
                            || 'idarquivo: '||rw_arq.idarquivo
                            || ', dtlog: '||SYSDATE
                            || ', dslog: '||'Arquivo '||rw_arq.nmarquivo||' conciliado com:'||vr_dscarque||
                                            'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                                            'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                                            'Quantidade de Aplicações ausentes no arquivo: '||vr_qtdausen||vr_dscarque||
                                            'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros)
                            || '. '||sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;  
          -- Atualizaremos o arquivo de retorno
          BEGIN 
            UPDATE tbcapt_custodia_arquivo arq
               SET arq.idsituacao = 1           -- Processado
                  ,arq.dtregistro = vr_dtmvtolt -- DAta Ref Arquivo
                  ,arq.dtprocesso = SYSDATE     -- Momento do Processo
             WHERE arq.idarquivo = rw_arq.idarquivo;
          EXCEPTION
            WHEN OTHERS THEN
              -- Erro não tratado 
              vr_cdcritic := 1035;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' tbcapt_custodia_arquivo: '
                          || 'idsituacao: 1' 
                          || ', dtregistro: '||vr_dtmvtolt
                          || ', dtprocesso: '||SYSDATE
                          || ' com idarquivo: '||rw_arq.idarquivo||'. '||sqlerrm;
              RAISE vr_exc_saida;
          END;          
          -- Após processar o arquivo, se houve algum erro
          IF vr_qtderros > 0 THEN 
             -- Enviar as informações por Email
             pc_envia_email_alerta_arq(pr_dsdemail  => pr_dsdemail      --> Destinatários
                                      ,pr_dsjanexe  => pr_dsjanexe      --> Descrição horário execução
                                      ,pr_idarquivo => rw_arq.idarquivo --> ID do arquivo
                                      ,pr_dsdirbkp  => pr_dsdirbkp      --> Caminho de backup linux
                                      ,pr_dsredbkp  => pr_dsredbkp      --> Caminho da rede de Backup
                                      ,pr_flgerrger => vr_flerrger      --> erro geral do arquivo
                                      ,pr_idcritic  => vr_idcritic      --> Criticidade da saida
                                      ,pr_cdcritic  => vr_cdcritic      --> Código da critica
                                      ,pr_dscritic  => vr_dscritic);    --> Descrição da critica
            -- Em caso de erro
            IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;      
          -- Enviar ao LOG resumo da execução
          IF vr_qtderros + vr_qtdsuces > 0 THEN 
            pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 
                        'Arquivo '||rw_arq.nmarquivo||' conciliado com:'||vr_dscarque||
                        'Quantidade de Erros: '||vr_qtderros||vr_dscarque||
                        'Quantidade de Sucessos: '||vr_qtdsuces||vr_dscarque||
                        'QUantidade de Aplicações ausentes no arquivo: '||vr_qtdausen||vr_dscarque||
                        'Total de linhas processadas:'||(vr_qtdsuces+vr_qtderros);
          END IF;
          -- Gravar a cada arquivo com sucesso
          COMMIT;
          -- Sair se processou a quantidade máxima de arquivos por execução
          IF vr_qtdaruiv >= vr_qtdexjob THEN 
            EXIT;
          END IF;
        END LOOP;
        
        -- Se encontrou o arquivo correto da conciliação
        IF vr_flgconcil THEN
          -- Atualizamos o registro que indica quando ocorreu a ultima conciliação com sucesso
          UPDATE crapprm
             SET dsvlrprm = to_char(trunc(SYSDATE),'dd/mm/rrrr')
           WHERE nmsistem = 'CRED'
             AND cdcooper = 0
             AND cdacesso = 'DAT_CONCILIA_CUSTODIA_B3'; 
        END IF;
      ELSE
        pr_dsdaviso := pr_dsdaviso || vr_dscarque || fn_get_time_char || 'Nenhuma Conciliação será efetuada pois a opção está Desativada ou já foi efetuada no dia!';        
      END IF;  
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_conciliacao' ||vr_dscarque
                    || '-------------------'
                    || 'Critica gerada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 1; -- Media
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processa_conciliacao' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Devolver a critica 
        pr_idcritic := 2; -- Alta
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;                                                                 
        -- Efetuar rollback
        ROLLBACK;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_processa_conciliacao;
  
  -- Rotina para processar retorno de conciliação pendentes de processamento
  PROCEDURE pc_processo_controle(pr_tipexec   IN NUMBER       --> Tipo da Execução
                                ,pr_dsinform OUT CLOB         --> Descrição de informativos na execução
                                ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_processo_controle
    --  Sistema  : Captação
    --  Sigla    : CRED
    --  Autor    : Marcos - Envolti
    --  Data     : Março/2018.                   Ultima atualizacao: 18/10/2018
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Acionado via JOB
    -- Objetivo  : Esta rotina será encarregada de controlar todo o Workflow
    --             das remessas para Custódia das Aplicações no B3. 
    --
    --             A mesma só será executada de 2ª a 6ª.
    --
    --             Em resumo, o processo irá gerar as remessas pendentes caso ainda
    --             não existam, e apóps buscar as mesmas e gerar os arquivos para 
    --             envio do Registro e Operação no B3. 
    --
    --             Haverá também a busca e processamento dos arquivos de retorno
    --             e dos arquivos de Conciliações Diárias
    -- 
    --             pr_tipexec: 0 - Tudo
    --                         1 - Conciliação do dia anterior
    --                         2 - Envio dos Lançamentos Pendentes
    --                         3 - Retorno de Lançamentos PEndentes
    -- 
    -- Alteracoes:
    --			    18/10/2018 - P411 - Inclusão de tags para monitoramento (Daniel - Envolti)
    -- 
    --          07/12/2018 - P411 - Passagem de parametros de caminhos de Backup windows (Marcos-Envolti)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Parâmetros
      vr_dsdaviso VARCHAR2(32767); --> Variaveis para retornar avisos durante o processo
      vr_nmarqlog VARCHAR2(1000); --> Nome do arquivo de LOG
      vr_hriniprc DATE;           --> Horário Inicial da Janela de Processamento
      vr_hrfimprc DATE;           --> Horário Final da Janela de Processamento
      vr_dsdircnd VARCHAR2(1000); --> Diretório Raiz do Connect Direct
      vr_dsdirbkp VARCHAR2(1000); --> Diretório Backup Connect Direct
      vr_dsredbkp VARCHAR2(1000); --> Diretório Backup Connect Direct pelo caminho Windows
      vr_dsdemail VARCHAR2(1000); --> Lista de destinatários
      vr_dsjanexe VARCHAR2(1000); --> Texto com os horários da janela de execução
      vr_flenvreg VARCHAR2(1); --> Flag de Envio do Registro das Aplicações
      vr_flenvrgt VARCHAR2(1); --> Flag de Envio do Resgate das Aplicações                 
      vr_flprccnc VARCHAR2(1); --> Flag de Processamento da Conciliação das Aplicações    
      vr_dtultcnc DATE;        --> DAta da ultima conciliação                   
      vr_tag_hora varchar2(14) := to_char(sysdate, 'yyyymmddhh24miss');
      -- Busca do calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
    BEGIN
  	  -- Inclusão do módulo e ação logado
--GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'APLI0007.pc_processo_controle');
 gene0001.pc_informa_acesso(pr_module => null, pr_action => 'APLI0007.pc_processo_controle');
      -- Buscar Parâmetros Sistema
      vr_nmarqlog := gene0001.fn_param_sistema('CRED',0,'NOM_ARQUIVO_LOG_B3');  
      vr_hriniprc := to_date(to_char(sysdate,'ddmmrrrr')||gene0001.fn_param_sistema('CRED',0,'HOR_INICIO_CUSTODIA_B3'),'ddmmrrrrhh24:mi');
      vr_hrfimprc := to_date(to_char(sysdate,'ddmmrrrr')||gene0001.fn_param_sistema('CRED',0,'HOR_FINAL_CUSTODIA_B3'),'ddmmrrrrhh24:mi');
      vr_dsdircnd := gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_ENVI_B3');
      vr_dsdirbkp := gene0002.fn_busca_entrada(1,gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_BKP_B3'),';');   
      vr_dsredbkp := gene0002.fn_busca_entrada(2,gene0001.fn_param_sistema('CRED',0,'NOM_CAMINHO_ARQ_BKP_B3'),';');
      vr_dsdemail := gene0001.fn_param_sistema('CRED',0,'DES_EMAILS_PROC_B3');
      vr_flenvreg := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_REG_CUSTODIA_B3'); 
      vr_flenvrgt := gene0001.fn_param_sistema('CRED',0,'FLG_ENV_RGT_CUSTODIA_B3'); 
      vr_flprccnc := gene0001.fn_param_sistema('CRED',0,'FLG_CONCILIA_CUSTODIA_B3'); 
      vr_dtultcnc := to_date(gene0001.fn_param_sistema('CRED',0,'DAT_CONCILIA_CUSTODIA_B3'),'dd/mm/rrrr'); 
      
      -- Montar o texto da janela de execução
      vr_dsjanexe := 'das '||to_char(vr_hriniprc,'hh24:mi')||' até as '||to_char(vr_hrfimprc,'hh24:mi');
      
      -- Esta rotina somente poderá ser executada de 2ª a 6ª
      IF to_char(SYSDATE,'d') NOT IN(1,7) THEN        
        -- Buscar o calendário 
        OPEN btch0001.cr_crapdat(3);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat; 
        
        -- Somente executar quando ocorreu virada do dia, estamos em dia útil e sem o processo em execução
        IF rw_crapdat.dtmvtolt = TRUNC(SYSDATE) AND rw_crapdat.inproces = 1 THEN 
          -- Caso estejamos dentro da janela de comunição entre Ayllos X B3
          IF SYSDATE BETWEEN vr_hriniprc AND vr_hrfimprc THEN
            -- Incluir tag para monitoramento do job
            if pr_tipexec = 0 then
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_nmarqlog     => vr_nmarqlog,
                                         pr_flfinmsg     => 'N',
                                         pr_des_log      => vr_dscarque||'INICIO_APLI0007_'||vr_tag_hora||' '||substr(fn_get_time_char, 1, 19));
            end if;
            -- Iniciando LOG
            pr_dsinform := fn_get_time_char || 'Iniciando execução do processo controlador '||vr_dscarque
                                            || 'Tipo da Execução : '||pr_tipexec|| ' - ' 
                                            || CASE pr_tipexec
                                                 WHEN 0 THEN 'Completa'
                                                 WHEN 1 THEN 'Retorno da Conciliação da B3'
                                                 WHEN 2 THEN 'Envio dos Lançamentos a B3'
                                                 WHEN 3 THEN 'Retorno dos Lançamentos da B3'
                                                 ELSE '???'
                                              END;
            
            -- Se solicitado tudo ou só COnciliação
            IF pr_tipexec IN(0,1) THEN 
              
              -- Busca dos Zips recebidos 
              pc_checar_zips_recebe_cd(pr_dsdircnd => vr_dsdircnd
                                      ,pr_dsdirbkp => vr_dsdirbkp
                                      ,pr_dsdaviso => vr_dsdaviso
                                      ,pr_idcritic => vr_idcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
              -- Caso tenhamos recebido algum erro 
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2
                                          ,pr_nmarqlog      => vr_nmarqlog  
                                          ,pr_dstiplog      => 'E'
                                          ,pr_cdprograma    => vr_nomdojob                      
                                          ,pr_tpexecucao    => 2 -- JOB
                                          ,pr_cdcriticidade => vr_idcritic
                                          ,pr_cdmensagem    => vr_cdcritic    
                                          ,pr_des_log       => vr_dscritic);
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN 
                  -- Devemos devolver a critica e e sair
                  pr_dscritic := vr_dscritic;
                  RETURN;
                END IF;                                            
              ELSE
                -- Se não estamos na execução total, então incrementamos os alertas 
                -- devolvidos  para propagarmos na saida desta rotina 
                pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
              END IF;
                
              -- Checagem do diretório RECEBE de CONCILIAÇÃO
              pc_checar_recebe_cd(pr_idtiparq => 9
                                 ,pr_dsdirrec => vr_dsdircnd||vr_dsdirrec  --> Diretório dos arquivos compactados
                                 ,pr_dsdirrcb => vr_dsdircnd||vr_dsdirrcb  --> Diretório Recebidos
                                 ,pr_dsdirbkp => vr_dsdirbkp||vr_dsdirrcb  --> Diretório Backup dos arquivos
                                 ,pr_dsdaviso => vr_dsdaviso
                                 ,pr_idcritic => vr_idcritic
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
              -- Caso tenhamos recebido algum erro 
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2
                                          ,pr_nmarqlog      => vr_nmarqlog  
                                          ,pr_dstiplog      => 'E'
                                          ,pr_cdprograma    => vr_nomdojob                      
                                          ,pr_tpexecucao    => 2 -- JOB
                                          ,pr_cdcriticidade => vr_idcritic
                                          ,pr_cdmensagem    => vr_cdcritic    
                                          ,pr_des_log       => vr_dscritic);
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN 
                  -- Devemos devolver a critica e e sair
                  pr_dscritic := vr_dscritic;
                  RETURN;
                END IF;                                           
              ELSE 
                -- Se não estamos na execução total, então incrementamos os alertas 
                -- devolvidos  para propagarmos na saida desta rotina 
                pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
              END IF;
                
              -- Processamento dos arquivos de conciliação pendentes                    
              pc_processa_conciliacao(pr_flprccnc => vr_flprccnc --> Conciliação ativa
                                     ,pr_dtultcnc => vr_dtultcnc --> Data Ultima Conciliação
                                     ,pr_dsdemail => vr_dsdemail --> Destinatários
                                     ,pr_dsjanexe => vr_dsjanexe --> Descrição horário execução
                                     ,pr_dsdirbkp => vr_dsdirbkp||'concilia' --> Caminho de backup linux
                                     ,pr_dsredbkp => vr_dsredbkp --> Caminho da rede de Backup
                                     ,pr_dsdaviso => vr_dsdaviso
                                     ,pr_idcritic => vr_idcritic
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
              -- Caso tenhamos recebido algum erro 
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2
                                          ,pr_nmarqlog      => vr_nmarqlog  
                                          ,pr_dstiplog      => 'E'
                                          ,pr_cdprograma    => vr_nomdojob                      
                                          ,pr_tpexecucao    => 2 -- JOB
                                          ,pr_cdcriticidade => vr_idcritic
                                          ,pr_cdmensagem    => vr_cdcritic    
                                          ,pr_des_log       => vr_dscritic);
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN 
                  -- Devemos devolver a critica e e sair
                  pr_dscritic := vr_dscritic;
                  RETURN;
                END IF;                                           
              ELSE
                -- Se não estamos na execução total, então incrementamos os alertas 
                -- devolvidos  para propagarmos na saida desta rotina 
                pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
              END IF; 
            
            END IF;
            
            -- Se solicitado tudo ou Só Envio
            IF pr_tipexec IN(0,2) THEN 
              -- Se conciliação estiver ativa e a ultima conciliação não foi feita no dia
              IF vr_flprccnc = 'S' AND vr_dtultcnc < rw_crapdat.dtmvtolt THEN 
                  -- Envio só poderá ser feito depois da conciliação do dia
                  pr_dsinform := pr_dsinform ||vr_dscarque|| 'Não será possível enviar! A conciliação do dia anterior ainda não foi efetuada!';
              ELSE
                -- Acionar o processo de busca dos registros pendentes de evnio
                pc_verifi_lanctos_custodia(pr_flenvreg => vr_flenvreg --> Flag de Envio do Registro das Aplicações
                                          ,pr_flenvrgt => vr_flenvrgt --> Flag de Envio do Resgate das Aplicações    
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                -- Caso tenhamos recebido algum erro 
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                  -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                  btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                            ,pr_ind_tipo_log  => 2
                                            ,pr_nmarqlog      => vr_nmarqlog  
                                            ,pr_dstiplog      => 'E'
                                            ,pr_cdprograma    => vr_nomdojob                      
                                            ,pr_tpexecucao    => 2 -- JOB
                                            ,pr_cdcriticidade => vr_idcritic
                                            ,pr_cdmensagem    => vr_cdcritic    
                                            ,pr_des_log       => vr_dscritic);
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN 
                    -- Devemos devolver a critica e e sair
                    pr_dscritic := vr_dscritic;
                    RETURN;
                  END IF;                          
                ELSE
                  -- Se não estamos na execução total, então incrementamos os alertas 
                  -- devolvidos  para propagarmos na saida desta rotina 
                  pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
                END IF;            
                
                -- Acionar rotina para geração de arquivos para envio
                pc_gera_arquivos_envio(pr_dsdaviso => vr_dsdaviso
                                      ,pr_idcritic => vr_idcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                -- Caso tenhamos recebido algum erro 
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                  -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                  btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                            ,pr_ind_tipo_log  => 2
                                            ,pr_nmarqlog      => vr_nmarqlog  
                                            ,pr_dstiplog      => 'E'
                                            ,pr_cdprograma    => vr_nomdojob                      
                                            ,pr_tpexecucao    => 2 -- JOB
                                            ,pr_cdcriticidade => vr_idcritic
                                            ,pr_cdmensagem    => vr_cdcritic    
                                            ,pr_des_log       => vr_dscritic);
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN 
                    -- Devemos devolver a critica e e sair
                    pr_dscritic := vr_dscritic;
                    RETURN;
                  END IF;                                            
                ELSE
                  -- Se não estamos na execução total, então incrementamos os alertas 
                  -- devolvidos  para propagarmos na saida desta rotina 
                  pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
                END IF;              
                
                -- Acionar rotina para preparação e envio dos arquivos gerado acima
                pc_processa_envio_arquivos(pr_flenvreg => vr_flenvreg --> Flag de Envio do Registro das Aplicações
                                          ,pr_flenvrgt => vr_flenvrgt --> Flag de Envio do Resgate das Aplicações    
                                          ,pr_dsdircnd => vr_dsdircnd
                                          ,pr_dsdirbkp => vr_dsdirbkp
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                -- Caso tenhamos recebido algum erro 
                IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                  -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                  btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                            ,pr_ind_tipo_log  => 2
                                            ,pr_nmarqlog      => vr_nmarqlog  
                                            ,pr_dstiplog      => 'E'
                                            ,pr_cdprograma    => vr_nomdojob                      
                                            ,pr_tpexecucao    => 2 -- JOB
                                            ,pr_cdcriticidade => vr_idcritic
                                            ,pr_cdmensagem    => vr_cdcritic    
                                            ,pr_des_log       => vr_dscritic);
                  -- Quando não estivermos na execução total
                  IF pr_tipexec <> 0 THEN 
                    -- Devemos devolver a critica e e sair
                    pr_dscritic := vr_dscritic;
                    RETURN;
                  END IF;                                            
                ELSIF pr_tipexec <> 0 THEN 
                  -- Se não estamos na execução total, então incrementamos os alertas 
                  -- devolvidos  para propagarmos na saida desta rotina 
                  pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
                END IF; 
              END IF;  
            END IF;
            
            -- Se solicitado tudo ou Só Retornos
            IF pr_tipexec in(0,3) THEN   
              
              -- Checagem do diretório RECEBE de retornos
              pc_checar_recebe_cd(pr_idtiparq => 5
                                 ,pr_dsdirrec => vr_dsdircnd||vr_dsdirrec  --> Diretório dos arquivos compactados
                                 ,pr_dsdirrcb => vr_dsdircnd||vr_dsdirrcb  --> Diretório Recebidos
                                 ,pr_dsdirbkp => vr_dsdirbkp||vr_dsdirrcb  --> Diretório Backup dos arquivos
                                 ,pr_dsdaviso => vr_dsdaviso
                                 ,pr_idcritic => vr_idcritic
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
              -- Caso tenhamos recebido algum erro 
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2
                                          ,pr_nmarqlog      => vr_nmarqlog  
                                          ,pr_dstiplog      => 'E'
                                          ,pr_cdprograma    => vr_nomdojob                      
                                          ,pr_tpexecucao    => 2 -- JOB
                                          ,pr_cdcriticidade => vr_idcritic
                                          ,pr_cdmensagem    => vr_cdcritic    
                                          ,pr_des_log       => vr_dscritic);
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN 
                  -- Devemos devolver a critica e e sair
                  pr_dscritic := vr_dscritic;
                  RETURN;
                END IF;                                            
              ELSE
                -- Se não estamos na execução total, então incrementamos os alertas 
                -- devolvidos  para propagarmos na saida desta rotina 
                pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
              END IF;  

              -- Processamento dos arquivos de retorno encontratos e pendentes
              pc_processa_retorno_arquivos(pr_dsdemail => vr_dsdemail --> Destinatários
                                          ,pr_dsjanexe => vr_dsjanexe --> Descrição horário execução
                                          ,pr_dsdaviso => vr_dsdaviso
                                          ,pr_idcritic => vr_idcritic
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
              -- Caso tenhamos recebido algum erro 
              IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
                -- Acionar o envio do log (Commit ou Rollback já são efetuados internamente)
                btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2
                                          ,pr_nmarqlog      => vr_nmarqlog  
                                          ,pr_dstiplog      => 'E'
                                          ,pr_cdprograma    => vr_nomdojob                      
                                          ,pr_tpexecucao    => 2 -- JOB
                                          ,pr_cdcriticidade => vr_idcritic
                                          ,pr_cdmensagem    => vr_cdcritic    
                                          ,pr_des_log       => vr_dscritic);
                -- Quando não estivermos na execução total
                IF pr_tipexec <> 0 THEN 
                  -- Devemos devolver a critica e e sair
                  pr_dscritic := vr_dscritic;
                  RETURN;
                END IF;                                           
              ELSE
                -- Se não estamos na execução total, então incrementamos os alertas 
                -- devolvidos  para propagarmos na saida desta rotina 
                pr_dsinform := pr_dsinform ||vr_dscarque|| vr_dsdaviso;
              END IF;
            
            END IF;
            
            -- Finalizando LOG
            pr_dsinform := pr_dsinform ||vr_dscarque||fn_get_time_char || 'Finalização da execução do processo controlador.';
            
            -- Enviar para o arquivo de LOG o texto informativo montado, quebrando a cada 3900 caracteres para evitar estouro de variável na pc_gera_log_batch
            if length(pr_dsinform) <= 3900 then
            -- Enviar para o arquivo de LOG o texto informativo montado
            btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_flfinmsg     => 'N'
                                      ,pr_des_log      => pr_dsinform);                                          
            else
              for i in 1..trunc(length(pr_dsinform)/3900)+1 loop
                btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_nmarqlog     => vr_nmarqlog
                                          ,pr_flfinmsg     => 'N'
                                          ,pr_des_log      => substr(pr_dsinform, (i-1)*3900+1, 3900));
              end loop;
            end if;
            -- Incluir tag para monitoramento do job
            if pr_tipexec = 0 then
              btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_nmarqlog     => vr_nmarqlog,
                                         pr_flfinmsg     => 'N',
                                         pr_des_log      => chr(13)||'FINAL_APLI0007_'||vr_tag_hora||' '||substr(fn_get_time_char, 1, 19));
            end if;
          ELSE
            pr_dsinform := 'Operação não realizada! Execução liberada somente '||vr_dsjanexe;
          END IF;
        ELSE
          pr_dsinform := 'Operação não realizada! Processo em Execução ou Sistema Aimaro não liberado!';      
        END IF;
      ELSE
        pr_dsinform := 'Operação não realizada! Execução só será efetuada de 2a a 6a feira.';
      END IF;  
    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar retorno do erro nao tratado
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'. '||dbms_utility.format_error_backtrace||' '||SQLERRM;
        -- Incluir dados do programa em execução 
        vr_dscritic := fn_get_time_char ||vr_nomdojob||'-->'
                    || 'Rotina : APLI0007.pc_processo_controle' ||vr_dscarque
                    || '-------------------'
                    || 'Critica encontrada: '||vr_dscritic;
        -- Acionar o envio do log 
        btch0001.pc_gera_log_batch(pr_cdcooper      => 3
                                  ,pr_ind_tipo_log  => 2
                                  ,pr_nmarqlog      => vr_nmarqlog  
                                  ,pr_dstiplog      => 'E'
                                  ,pr_cdprograma    => vr_nomdojob                      
                                  ,pr_tpexecucao    => 2 -- JOB
                                  ,pr_cdcriticidade => 2 -- Alta
                                  ,pr_cdmensagem    => vr_cdcritic    
                                  ,pr_des_log       => vr_dscritic);
        -- Efetuar rollback
        ROLLBACK;
        -- Devolver criticas
        pr_dscritic := vr_dscritic;
        -- Acionar log exceções internas
        cecred.pc_internal_exception;
    END;
  END pc_processo_controle;
  
END APLI0007;
/
