CREATE OR REPLACE PACKAGE CECRED.WPGD0190 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0190                     
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Jonathan Cristiano da Silva - RKAM
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --
  -- Alteracoes:   
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0190 na tabela tbead_limite_inscricoes
 PROCEDURE pc_tbead_limite_inscricoes(pr_cddopcao       IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                     ,pr_cdcooper       IN tbead_limite_inscricoes.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_qtpptspf       IN tbead_limite_inscricoes.nr_particip_pf%TYPE --> Quantidade de inscritos por PF
                                     ,pr_qtpptspj       IN tbead_limite_inscricoes.nr_particip_pj%TYPE --> Quantidade de inscritos por PJ
                                     ,pr_nriniseq       IN PLS_INTEGER           --> Incicio da Sequencia para paginação
                                     ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de Registros a serem mostrados na paginação
                                     ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro       OUT VARCHAR2) ;
                         
 PROCEDURE pc_tbead_inscricao_cooperado(pr_cddopcao     IN VARCHAR2              --> Tipo de acao que sera executada (C - Create / R - Read / U - Update / D - Delete)
                                       ,pr_cdcadead     IN tbead_inscricao_participante.idcadast_ead%TYPE--> Codigo que identifica o auto incremento da tabela
                                       ,pr_cdcooper     IN tbead_inscricao_participante.cdcooper%TYPE--> Codigo que identifica a cooperativa
                                       ,pr_nrdconta     IN tbead_inscricao_participante.nrdconta%TYPE--> Numero da conta/dv do associado
                                       ,pr_inpessoa     IN tbead_inscricao_participante.inpessoa%TYPE--> Tipo de pessoa (1 - fisica, 2 - juridica) 
                                       ,pr_invclopj     IN tbead_inscricao_participante.tpvinculo_pj%TYPE--> Tipo de Vinculo PJ (1 - colaborador, 2 - outros)
                                       ,pr_idseqttl     IN tbead_inscricao_participante.idseqttl%TYPE--> Sequencia do Titular
                                       ,pr_nmextptp     IN tbead_inscricao_participante.nmparticip%TYPE--> Nome por extenso do participante
                                       ,pr_nrcpfptp     IN tbead_inscricao_participante.nrcpf_particip%TYPE--> Numero do CPF/CGC do participante
                                       ,pr_dsemlptp     IN tbead_inscricao_participante.dsemail_particip%TYPE--> E-mail do participante
                                       ,pr_nrfonptp     IN tbead_inscricao_participante.nrfone_particip%TYPE--> Numero do telefone do participante                                      
                                       ,pr_nmlogptp     IN tbead_inscricao_participante.nmlogin_particip%TYPE--> Nome por extenso do participante
                                       ,pr_dscritic     OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml       OUT CLOB                 --> Arquivo de retorno do XML
                                       ) ;
                                       
 PROCEDURE pc_envio_parametro_curl(pr_dscritic OUT VARCHAR2); --> Retorno de crítica
  
END WPGD0190;
/
CREATE OR REPLACE PACKAGE BODY CECRED.WPGD0190 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0190                     
  --  Sistema  : CECRED
  --  Sigla    : WPGD
  --  Autor    : Jonathan Cristiano da Silva - RKAM
  --  Data     : Setembro/2015.                   Ultima atualizacao: 12/05/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Cadastro de Distância Origem x Destino.
  --
  -- Alteracoes: 12/05/2016 - Ajustado para buscar o CPF do participante da crapsnh, quando for pessoa
  --                          juridica e possuir idseqttl(socios/procudadores)(Odirlei-AMcom) 
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina geral de insert, update, select e delete da tela WPGD0190 na tabela tbead_limite_inscricoes
  PROCEDURE pc_tbead_limite_inscricoes(pr_cddopcao        IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                       ,pr_cdcooper       IN tbead_limite_inscricoes.cdcooper%TYPE --> Código da Cooperativa                        
                                       ,pr_qtpptspf       IN tbead_limite_inscricoes.nr_particip_pf%TYPE --> Quantidade de inscritos por PF
                                       ,pr_qtpptspj       IN tbead_limite_inscricoes.nr_particip_pj%TYPE --> Quantidade de inscritos por PJ
                                       ,pr_nriniseq       IN PLS_INTEGER           --> Incicio da Sequencia para paginação
                                       ,pr_qtregist       IN PLS_INTEGER           --> Quantidade de Registros a serem mostrados na paginação
                                       ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                                       ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro       OUT VARCHAR2) IS         --> Erros do processo

    	-- Cursor sobre a tabela de limite de inscritos
      CURSOR cr_ead IS
         SELECT ead.cdcooper,
                cop.nmrescop, 
                ead.nr_particip_pf,
                ead.nr_particip_pj, 
                ROW_NUMBER() OVER(ORDER BY 1, 2, 3 DESC) nrdseque
         FROM tbead_limite_inscricoes ead
         INNER JOIN crapcop cop ON
               cop.cdcooper = ead.cdcooper         
         WHERE ead.cdcooper = pr_cdcooper OR pr_cdcooper = 0                   
         ORDER BY 1, 2, 3 DESC;
                 
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variáveis
      vr_cdcooper    NUMBER;
      vr_nmdatela    VARCHAR2(25);
      vr_nmeacao     VARCHAR2(25);
      vr_cdagenci    VARCHAR2(25);
      vr_nrdcaixa    VARCHAR2(25);
      vr_idorigem    VARCHAR2(25);
      vr_cdoperad    VARCHAR2(25);
      
      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;
      VR_EXISTE   NUMBER:=0;
     
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
      
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                                     
      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                      
    
      -- Verifica o tipo de acao que sera executada
      CASE pr_cddopcao

        WHEN 'A' THEN -- Alteracao
          BEGIN
            -- Atualizacao de registro da quantidade de inscritos
            UPDATE tbead_limite_inscricoes
            SET 
              nr_particip_pf = pr_qtpptspf,
              nr_particip_pj = pr_qtpptspj
            WHERE cdcooper = pr_cdcooper;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar crapdod: ' || sqlerrm;
              RAISE vr_exc_saida;
          END;

        WHEN 'C' THEN -- Consulta
          -- Criar cabeçalho do XML
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
           -- Loop sobre as quantidades de inscritos por Cooperativa
          FOR rw_ead IN cr_ead LOOP
              IF ((pr_nriniseq <= rw_ead.nrdseque)AND (rw_ead.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper'      , pr_tag_cont => rw_ead.cdcooper                       , pr_des_erro => vr_dscritic);                                             
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop'      , pr_tag_cont => rw_ead.nmrescop                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtpptspf'      , pr_tag_cont => rw_ead.nr_particip_pf                       , pr_des_erro => vr_dscritic);  
                GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtpptspj'      , pr_tag_cont => rw_ead.nr_particip_pj                       , pr_des_erro => vr_dscritic);
                vr_contador := vr_contador + 1;
             END IF;
             vr_totregis := vr_totregis +1;    
          END LOOP;
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis'   , pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);           

        WHEN 'E' THEN -- Exclusao               
          -- Efetua a exclusao da quantidade de inscritos por cooperativa
            BEGIN
              DELETE tbead_limite_inscricoes
              WHERE cdcooper = pr_cdcooper;
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir a Cooperativa.'||sqlerrm ;
                RAISE vr_exc_saida;
            END;

        WHEN 'I' THEN -- Inclusao
         BEGIN
            SELECT COUNT(cdcooper)
            INTO 
                   VR_EXISTE
            FROM 
                   tbead_limite_inscricoes
            WHERE cdcooper = pr_cdcooper;
                 
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              VR_EXISTE:=0;
          END;        
          --
          BEGIN 
              
          IF VR_EXISTE > 0 THEN
             RAISE dup_val_on_index; 
          END IF;
             
          -- Efetua a inclusao na quantidade de inscritos por cooperativa
          
            INSERT INTO tbead_limite_inscricoes
               (cdcooper ,
                nr_particip_pf ,
                nr_particip_pj                      
                )
            VALUES
               (pr_cdcooper,
                pr_qtpptspf,
                pr_qtpptspj                      
                );
                  
          -- Verifica se houve problema na insercao de registros
         EXCEPTION
            WHEN dup_val_on_index THEN
              vr_dscritic := 'Esta Cooperativa já foi cadastrado. Favor verificar!';
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              vr_dscritic := 'Problema ao inserir tbead_limite_inscricoes: ' || sqlerrm;
              RAISE vr_exc_saida;
         END;
            
          -- Retorna a sequencia criada
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><pr_cdcooper>' || pr_cdcooper || '</pr_cdcooper>
                                      </Root>');

      END CASE;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em crappri: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
 END pc_tbead_limite_inscricoes;
 
 PROCEDURE pc_tbead_inscricao_cooperado(pr_cddopcao     IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                                       ,pr_cdcadead     IN tbead_inscricao_participante.idcadast_ead%TYPE--> Codigo que identifica o auto incremento da tabela
                                       ,pr_cdcooper     IN tbead_inscricao_participante.cdcooper%TYPE--> Codigo que identifica a cooperativa
                                       ,pr_nrdconta     IN tbead_inscricao_participante.nrdconta%TYPE--> Numero da conta/dv do associado
                                       ,pr_inpessoa     IN tbead_inscricao_participante.inpessoa%TYPE--> Tipo de pessoa (1 - fisica, 2 - juridica) 
                                       ,pr_invclopj     IN tbead_inscricao_participante.tpvinculo_pj%TYPE--> Tipo de Vinculo PJ (1 - colaborador, 2 - outros)
                                       ,pr_idseqttl     IN tbead_inscricao_participante.idseqttl%TYPE--> Sequencia do Titular
                                       ,pr_nmextptp     IN tbead_inscricao_participante.nmparticip%TYPE--> Nome por extenso do participante
                                       ,pr_nrcpfptp     IN tbead_inscricao_participante.nrcpf_particip%TYPE--> Numero do CPF/CGC do participante
                                       ,pr_dsemlptp     IN tbead_inscricao_participante.dsemail_particip%TYPE--> E-mail do participante
                                       ,pr_nrfonptp     IN tbead_inscricao_participante.nrfone_particip%TYPE--> Numero do telefone do participante                                      
                                       ,pr_nmlogptp     IN tbead_inscricao_participante.nmlogin_particip%TYPE--> Nome por extenso do participante
                                       ,pr_dscritic     OUT VARCHAR2             --> Descrição da crítica
                                       ,pr_retxml       OUT CLOB) IS             --> XML do processo

      
      -- Cursor sobre limite de inscricoes por cooperativa
      CURSOR cr_crapcop(p_cdcooper tbead_inscricao_participante.cdcooper%TYPE) IS
       SELECT nr_particip_pf, nr_particip_pj
         FROM tbead_limite_inscricoes 
        WHERE cdcooper = p_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor sobre a tabela de limite de inscritos
      CURSOR cr_ead(p_cdcooper tbead_inscricao_participante.cdcooper%TYPE
                   ,p_nrdconta tbead_inscricao_participante.nrdconta%TYPE) IS
        SELECT ead.idcadast_ead,
               ead.cdcooper,
               ead.nrdconta,
               ead.inpessoa,
               ead.tpvinculo_pj,
               ead.idseqttl,
               UPPER(DECODE(ead.inpessoa, 1, ttl.nmextttl, 
                     DECODE(ead.tpvinculo_pj, 1, nvl(opi.nmoperad,ead.nmparticip), 
                     ead.nmparticip))) AS nmparticip,
               ead.nrcpf_particip,
               ead.dsemail_particip,
               ead.nrfone_particip,
               ead.nmlogin_particip,
               ead.dtadmiss
        FROM tbead_inscricao_participante ead 
             LEFT JOIN crapttl ttl ON 
             ttl.cdcooper = ead.cdcooper AND
             ttl.nrdconta = ead.nrdconta AND 
             ttl.idseqttl = ead.idseqttl
             LEFT JOIN crapopi opi ON
             opi.cdcooper = ead.cdcooper AND
             opi.nrdconta = ead.nrdconta AND 
             opi.nrcpfope = ead.nrcpf_particip
        WHERE 
            ead.cdcooper = p_cdcooper AND 
            ead.nrdconta = p_nrdconta AND 
            ead.dtdemiss IS NULL;
      rw_ead cr_ead%ROWTYPE;
      
      -- Buscar a informação de Sequencia da TBEAD
      CURSOR cr_ead_seq IS
      SELECT nvl(max(idcadast_ead),0)+1 AS idcadast_ead
        FROM tbead_inscricao_participante;
      rw_ead_seq cr_ead_seq%ROWTYPE;
      
      -- Cursor busca informacao do inscrito
      CURSOR cr_inscricao(pr_idcadast tbead_inscricao_participante.idcadast_ead%TYPE) IS
        SELECT 
          ead.cdcooper,
          ass.cdagenci,
          ead.nmparticip,
          ead.dsemail_particip,
          ead.nmlogin_particip,
          'coop' || LPAD(ead.cdcooper, 4, 0) || '-P' || LPAD(ass.cdagenci, 4, 0) AS codcoop_cdagenci
        FROM 
          tbead_inscricao_participante ead 
          INNER JOIN crapass ass ON 
                ass.cdcooper = ead.cdcooper AND 
                ass.nrdconta = ead.nrdconta 
        WHERE 
          ead.idcadast_ead = pr_idcadast;
      rw_inscricao cr_inscricao%ROWTYPE;
      
      --> Buscar CPF da pessoa que possui acesso IB da conta PJ
      CURSOR cr_crapsnh(pr_cdcooper  crapsnh.cdcooper%TYPE,
                        pr_nrdconta  crapsnh.nrdconta%TYPE,
                        pr_idseqttl  crapsnh.idseqttl%TYPE) IS
        SELECT snh.nrcpfcgc                     
          FROM crapsnh snh
         WHERE snh.cdcooper = pr_cdcooper
           AND snh.nrdconta = pr_nrdconta
           AND snh.idseqttl = pr_idseqttl
           AND snh.tpdsenha = 1; 
      rw_crapsnh cr_crapsnh%ROWTYPE;
      
      -- Variável de críticas
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis gerais
      VR_POSICAO              NUMBER:=0;
      VR_EXISTE               NUMBER:=0;
      VR_EXISTE_LOGIN         NUMBER:=0;
      vr_retxml               XMLType;
      VR_DTDEMISS             DATE:=NULL;
      
      -- Variavel de auto-incremento
      vr_cdcadead tbead_inscricao_participante.idcadast_ead%TYPE;
      
      vr_nrcpfptp tbead_inscricao_participante.nrcpf_particip%TYPE;
     
      -- Tratamento de erros
      vr_exc_saida            EXCEPTION;
      vr_exc_login_saida      EXCEPTION;
      vr_xml_pgto_temp        VARCHAR2(32726) := '';
      
      vr_script_curl VARCHAR2(1000); --> Script CURL
      vr_comand_curl VARCHAR2(4000); --> Comando montado do envio ao curl
      vr_typ_saida  VARCHAR2(3);    --> Saída de erro
      
    BEGIN
      
      -- Verifica o tipo de acao que sera executada
      CASE pr_cddopcao
        
        WHEN 'I' THEN -- Inclusao
          BEGIN --  Verifica se existe registro na base com os campos chaves (cooper, conta e email)
            SELECT idcadast_ead, dtdemiss
              INTO VR_EXISTE, VR_DTDEMISS
              FROM tbead_inscricao_participante
             WHERE cdcooper         = pr_cdcooper AND 
                   nrdconta         = pr_nrdconta AND 
                   dsemail_particip = pr_dsemlptp AND 
                   nmlogin_particip = pr_nmlogptp;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 VR_EXISTE:=0;
                 VR_DTDEMISS:=NULL;
          END;
          
          BEGIN --  Verifica se existe registro na base com o mesmo valor de login
            SELECT idcadast_ead
              INTO VR_EXISTE_LOGIN
              FROM tbead_inscricao_participante
             WHERE nmlogin_particip = pr_nmlogptp;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 VR_EXISTE_LOGIN:=0;
          END;
          
          BEGIN 
            vr_nrcpfptp := pr_nrcpfptp; 
            IF pr_inpessoa = 2 AND pr_idseqttl > 1 AND nvl(vr_nrcpfptp,0) = 0 THEN
              rw_crapsnh := NULL;
              --> Buscar CPF da pessoa que possui acesso IB da conta PJ
              OPEN cr_crapsnh(pr_cdcooper  =>pr_cdcooper,
                              pr_nrdconta  =>pr_nrdconta,
                              pr_idseqttl  =>pr_idseqttl);
              FETCH cr_crapsnh INTO rw_crapsnh;
              CLOSE cr_crapsnh;
              vr_nrcpfptp := rw_crapsnh.nrcpfcgc;
            END IF;
                      
            -- Informa duplicidade caso exista registro e participante ativo 
            IF VR_EXISTE > 0 AND VR_DTDEMISS IS NULL THEN
              RAISE dup_val_on_index; 
            
            -- Informa que login existe na base   
            ELSIF VR_EXISTE_LOGIN > 0 AND VR_EXISTE = 0 THEN
              RAISE vr_exc_login_saida;
            
            -- Reativa participante existente e excluido
            ELSIF VR_EXISTE > 0 AND VR_DTDEMISS IS NOT NULL THEN
              
              UPDATE tbead_inscricao_participante
                 SET nmparticip       = pr_nmextptp,
                     nrcpf_particip   = vr_nrcpfptp,
                     nrfone_particip  = pr_nrfonptp,
                     dtdemiss         = ''
               WHERE cdcooper         = pr_cdcooper AND
                     nrdconta         = pr_nrdconta AND
                     dsemail_particip = pr_dsemlptp AND
                     nmlogin_particip = pr_nmlogptp;
                     
              -- Buscar script para conexão curl
              vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_PARAM_CURL');

              -- Preparar o comando de conexão e envio ao curl
              vr_comand_curl := vr_script_curl
                    || ' -nmAcao '           || 'atualizar'
                    || ' -nmCooperado '      || '\"'||pr_nmextptp||'\"'
                    || ' -nmEmail '          || pr_dsemlptp
                    || ' -nmLogin '          || pr_nmlogptp;
                  			
              -- Chama procedure de envio e recebimento via curl
              GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
                  						 
              -- Se ocorreu erro dar RAISE
              IF (vr_dscritic IS NOT NULL) THEN
                RAISE vr_exc_saida;
              END IF;
            
            -- Efetua a inclusao do participante
            ELSE 
            
              -- Buscar a informação de Sequencia da TBEAD
              OPEN cr_ead_seq();                 
              FETCH cr_ead_seq INTO rw_ead_seq;
              
              -- Codigo do proximo cooperado
              vr_cdcadead := rw_ead_seq.idcadast_ead;
  			       
              INSERT INTO tbead_inscricao_participante 
              (
                idcadast_ead,
                cdcooper,
                nrdconta,
                inpessoa,
                tpvinculo_pj,
                idseqttl,
                nmparticip,
                nrcpf_particip,
                dsemail_particip,
                nmlogin_particip,
                nrfone_particip,
                dtadmiss 
              ) VALUES (
                vr_cdcadead,
                pr_cdcooper,
                pr_nrdconta,
                pr_inpessoa,
                pr_invclopj,
                pr_idseqttl,
                pr_nmextptp,
                vr_nrcpfptp,
                pr_dsemlptp,
                pr_nmlogptp,
                pr_nrfonptp,
                SYSDATE
              );
              
              -- Fecha o cursor
              CLOSE cr_ead_seq;
              
              -- Busca informacao do inscrito
              OPEN  cr_inscricao(pr_idcadast => vr_cdcadead);                 
              FETCH cr_inscricao INTO rw_inscricao;

              -- Caso encontre registro
              IF cr_inscricao%FOUND THEN
              
                -- Buscar script para conexão curl
                vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_PARAM_CURL');

                -- Preparar o comando de conexão e envio ao curl
                vr_comand_curl := vr_script_curl
                      || ' -nmAcao '           || 'incluir'
                      || ' -nmCooperado '      || '\"'||pr_nmextptp||'\"'
                      || ' -nmEmail '          || pr_dsemlptp 
                      || ' -nmLogin '          || pr_nmlogptp 
                      || ' -nrConta '          || pr_nrdconta 
                      || ' -nrCooperativa '    || pr_cdcooper
                      || ' -nrCooperativaPA '  || rw_inscricao.codcoop_cdagenci;
                			
                -- Chama procedure de envio e recebimento via curl
                GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                                           ,pr_typ_saida   => vr_typ_saida
                                           ,pr_des_saida   => vr_dscritic);
                						 
                -- Se ocorreu erro dar RAISE
                IF (vr_dscritic IS NOT NULL) THEN
                   -- Fecha o cursor
                   CLOSE cr_inscricao;
                   RAISE vr_exc_saida;
                END IF;
                
              END IF;

              -- Fecha o cursor
              CLOSE cr_inscricao;
                          
            END IF;
                          
          -- Verifica se houve problema na insercao de registros
          EXCEPTION
             WHEN vr_exc_saida THEN
                  RAISE vr_exc_saida; 
             WHEN dup_val_on_index THEN
                  vr_dscritic := 'Este e-mail já está registrado em outro participante. Favor utilizar outro endereço de e-mail.';
                  RAISE vr_exc_saida;
             WHEN vr_exc_login_saida THEN
                  vr_dscritic := 'Este nome de Usuário/Login já existe. Favor utilizar outro.';
                  RAISE vr_exc_saida;
             WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao inserir o Participante';
                  RAISE vr_exc_saida;
          END;
        
        WHEN 'C' THEN -- Consulta
          
          -- Monta documento XML
          dbms_lob.createtemporary(pr_retxml, TRUE);
          dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
          
          -- Insere o cabeçalho do XML
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '<raiz>');
          
          -- Loop sobre os incritos no EAD
          FOR rw_ead IN cr_ead(pr_cdcooper
                              ,pr_nrdconta) LOOP
            
              gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                     ,pr_texto_completo => vr_xml_pgto_temp
                                     ,pr_texto_novo     => '<participantes>'
                                                        || '<cdcadead>'||rw_ead.idcadast_ead||'</cdcadead>'
                                                        || '<inpessoa>'||rw_ead.inpessoa||'</inpessoa>'
                                                        || '<invclopj>'||rw_ead.tpvinculo_pj||'</invclopj>'
                                                        || '<idseqttl>'||rw_ead.idseqttl||'</idseqttl>'
                                                        || '<nmextptp>'||rw_ead.nmparticip||'</nmextptp>'
                                                        || '<nrcpfptp>'||rw_ead.nrcpf_particip||'</nrcpfptp>'
                                                        || '<dsemlptp>'||rw_ead.dsemail_particip||'</dsemlptp>'
                                                        || '<nrfonptp>'||rw_ead.nrfone_particip||'</nrfonptp>'
                                                        || '<nmlogptp>'||rw_ead.nmlogin_particip||'</nmlogptp>'
                                                        || '<dtadmiss>'||TO_CHAR(rw_ead.dtadmiss,'DD/MM/YYYY')||'</dtadmiss>'
                                                        || '</participantes>');
                 
          END LOOP;
          
          -- Encerrar a tag raiz
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '</raiz>'
                                 ,pr_fecha_xml      => TRUE);
          
        WHEN 'A' THEN -- Alteracao
          BEGIN
            vr_nrcpfptp := pr_nrcpfptp; 
            IF pr_inpessoa = 2 AND pr_idseqttl > 1 AND nvl(vr_nrcpfptp,0) = 0 THEN
              rw_crapsnh := NULL;
              --> Buscar CPF da pessoa que possui acesso IB da conta PJ
              OPEN cr_crapsnh(pr_cdcooper  =>pr_cdcooper,
                              pr_nrdconta  =>pr_nrdconta,
                              pr_idseqttl  =>pr_idseqttl);
              FETCH cr_crapsnh INTO rw_crapsnh;
              CLOSE cr_crapsnh;
              vr_nrcpfptp := rw_crapsnh.nrcpfcgc;
            END IF;  
          
            -- Atualizacao de registro
            UPDATE tbead_inscricao_participante
               SET nmparticip      	= pr_nmextptp,
                   dsemail_particip = pr_dsemlptp,
                   nrcpf_particip   = vr_nrcpfptp,
                   nrfone_particip  = pr_nrfonptp
             WHERE idcadast_ead     = pr_cdcadead;
             
            -- Busca informacao do inscrito
            OPEN  cr_inscricao(pr_idcadast => pr_cdcadead);                 
            FETCH cr_inscricao INTO rw_inscricao;

            -- Caso encontre registro
            IF cr_inscricao%FOUND THEN
              
              -- Buscar script para conexão curl
              vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_PARAM_CURL');

              -- Preparar o comando de conexão e envio ao curl
              vr_comand_curl := vr_script_curl
                    || ' -nmAcao '           || 'atualizar'
                    || ' -nmCooperado '      || '\"'||rw_inscricao.nmparticip||'\"'
                    || ' -nmEmail '          || rw_inscricao.dsemail_particip
                    || ' -nmLogin '          || rw_inscricao.nmlogin_particip;
              			
              -- Chama procedure de envio e recebimento via curl
              GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                                         ,pr_typ_saida   => vr_typ_saida
                                         ,pr_des_saida   => vr_dscritic);
              						 
              -- Se ocorreu erro dar RAISE
              IF (vr_dscritic IS NOT NULL) THEN
                RAISE vr_exc_saida;
              END IF;

            END IF;

            -- Fecha o cursor
            CLOSE cr_inscricao;

          -- Verifica se houve problema na atualizacao do registro
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              -- Descricao do erro na insercao de registros
              vr_dscritic := 'Problema ao atualizar o Participante.';
              RAISE vr_exc_saida;
          END;
        
        WHEN 'E' THEN -- Exclusao               
          BEGIN
            
            -- Atualizacao de registro para exclusao no sistema
            UPDATE tbead_inscricao_participante
               SET dtdemiss = SYSDATE
             WHERE idcadast_ead = pr_cdcadead;
             
            -- Busca informacao do inscrito
            OPEN  cr_inscricao(pr_idcadast => pr_cdcadead);                 
            FETCH cr_inscricao INTO rw_inscricao;

            -- Caso encontre registro
            IF cr_inscricao%FOUND THEN
              
              -- Buscar script para conexão curl
              vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_PARAM_CURL');

              -- Preparar o comando de conexão e envio ao curl
              vr_comand_curl := vr_script_curl
                    || ' -nmAcao '           || 'excluir'
                    || ' -nmLogin '          || rw_inscricao.nmlogin_particip;
              			
              -- Chama procedure de envio e recebimento via curl
              GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
              						 
              -- Se ocorreu erro dar RAISE
              IF (vr_dscritic IS NOT NULL) THEN
                -- Fecha o cursor
                CLOSE cr_inscricao;
                RAISE vr_exc_saida;
              END IF;

            END IF;

            -- Fecha o cursor
            CLOSE cr_inscricao;
            
          EXCEPTION
            WHEN vr_exc_saida THEN
              RAISE vr_exc_saida;
            WHEN OTHERS THEN
              -- Descricao do erro na exclusao de registros
              vr_dscritic := 'Problema ao excluir o Participante.';
              RAISE vr_exc_saida;
          END;
          
        WHEN 'L' THEN -- Limite de Inscricoes               
          
          -- Busca as informacoes de limite de incricao
          OPEN cr_crapcop(pr_cdcooper);
          FETCH cr_crapcop INTO rw_crapcop;
          -- Se nao encontrar
          IF cr_crapcop%NOTFOUND THEN
             -- Gera critica
             CLOSE cr_crapcop;
             vr_dscritic := 'Não foi localizado a cooperativa: '||pr_cdcooper;
             RAISE vr_exc_saida;
          END IF;
          -- Apenas fecha cursor
          CLOSE cr_crapcop;
          
          -- Monta documento XML
          dbms_lob.createtemporary(pr_retxml, TRUE);
          dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);
          
          -- Insere o cabeçalho do XML
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '<raiz>');
          
          -- Insere a informacao do total por cooperativa
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '<cooperativa>'
                                                    || '<qtdparticippf>'||rw_crapcop.nr_particip_pf||'</qtdparticippf>'
                                                    || '<qtdparticippj>'||rw_crapcop.nr_particip_pj||'</qtdparticippj>'
                                                    || '</cooperativa>');
                 
          -- Encerrar a tag raiz
          gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                                 ,pr_texto_completo => vr_xml_pgto_temp
                                 ,pr_texto_novo     => '</raiz>'
                                 ,pr_fecha_xml      => TRUE);
                     
      END CASE;
      
      -- Registra as informações no sistema
      COMMIT;
      
      EXCEPTION
        WHEN vr_exc_saida THEN
          ROLLBACK;
          pr_dscritic := vr_dscritic;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          vr_retxml := XMLType.createXML('<Root><DSMSGERR>' || pr_dscritic || '</DSMSGERR></Root>');
        WHEN OTHERS THEN
          ROLLBACK;
          pr_dscritic := 'Erro geral em crappri: ' || SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          vr_retxml := XMLType.createXML('<Root><DSMSGERR>' || pr_dscritic || '</DSMSGERR></Root>');
   
      -- Converter o XML
      pr_retxml := vr_retxml.getClobVal();
    
 END pc_tbead_inscricao_cooperado;
 
 PROCEDURE pc_envio_parametro_curl(pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
   
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_envio_parametro_curl
  --  Sistema  : EAD
  --  Sigla    : CRED
  --  Autor    : Jonathan - RKAM
  --  Data     : Novembro/2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar informacao de PA e Situacao da Conta para o EAD como parâmetro
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
 
  -- Cursor sobre a tabela de limite de inscritos
  CURSOR cr_ead IS
    SELECT 
      ead.cdcooper,
      ass.cdagenci,
      ead.nmlogin_particip,
      'coop' || LPAD(ead.cdcooper, 4, 0) || '-P' || LPAD(ass.cdagenci, 4, 0) AS codcoop_cdagenci,
      alt.dsaltera,
      ead.dtdemiss
    FROM 
      tbead_inscricao_participante ead 
      INNER JOIN crapass ass ON 
            ass.cdcooper = ead.cdcooper AND 
            ass.nrdconta = ead.nrdconta 
      INNER JOIN crapalt alt ON 
            alt.cdcooper = ead.cdcooper AND 
            alt.nrdconta = ead.nrdconta 
      INNER JOIN crapdat dat ON 
            dat.cdcooper = ead.cdcooper AND 
            dat.dtmvtoan = alt.dtaltera
    WHERE 
      ead.dtdemiss IS NULL;
  rw_ead cr_ead%ROWTYPE;
    
  BEGIN
  
    DECLARE
      vr_nm_acao  VARCHAR2(8);    --> Saída de erro    
      vr_script_curl VARCHAR2(1000); --> Script CURL
      vr_comand_curl VARCHAR2(4000); --> Comando montado do envio ao curl
      vr_typ_saida  VARCHAR2(3);    --> Saída de erro
      vr_dscritic   VARCHAR2(4000); --> descricao do erro
      vr_exc_saida  EXCEPTION; --> Excecao prevista 
    BEGIN
      -- Buscar script para conexão FTP
      vr_script_curl := gene0001.fn_param_sistema('CRED',0,'EAD_PARAM_CURL');
        
      -- Loop sobre os incritos no EAD
      FOR rw_ead IN cr_ead LOOP
        
        -- Verifica se a altarecao do dia foi de PA ou demissao
        IF instr(rw_ead.dsaltera, 'PA') <> 0 OR instr(rw_ead.dsaltera, 'demissao') <> 0 THEN 
          
          IF instr(rw_ead.dsaltera, 'demissao') <> 0 THEN
            vr_nm_acao := 'excluir';
          ELSIF instr(rw_ead.dsaltera, 'PA') <> 0 THEN
            vr_nm_acao := 'dtaltera';   
          END IF;
        
          -- Preparar o comando de conexão e envio ao FTP
          vr_comand_curl := vr_script_curl
                        || ' -nmAcao '           || vr_nm_acao
                        || ' -nmLogin '          || rw_ead.nmlogin_particip
                        || ' -nrCooperativaPA '  || rw_ead.codcoop_cdagenci;
                        
          -- Chama procedure de envio e recebimento via ftp
          GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_curl
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => pr_dscritic);
                                     
          -- Se ocorreu erro dar RAISE
          IF (vr_typ_saida <> NULL OR vr_typ_saida <> '') THEN
            vr_dscritic := vr_typ_saida;
            RAISE vr_exc_saida;
          END IF;
          
          -- Se acao for de demissao - exclui cooperado da base
          IF instr(rw_ead.dsaltera, 'demissao') <> 0 THEN
          
            UPDATE tbead_inscricao_participante 
               SET dtdemiss = SYSDATE
             WHERE nmlogin_particip = rw_ead.nmlogin_particip;
          
          END IF;    
        
        END IF;                                     
                   
      END LOOP;
      
    -- Registra as informações no sistema
    COMMIT;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        ROLLBACK;
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina WPGD0190.pc_envio_parametro_curl --> '||SQLERRM;
    END;
      
 END pc_envio_parametro_curl;
 
-----------------------------------------------------                       
END WPGD0190;
/

