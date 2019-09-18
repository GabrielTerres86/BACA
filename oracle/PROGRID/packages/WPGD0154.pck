CREATE OR REPLACE PACKAGE PROGRID.WPGD0154 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0154                     
  --  Sistema  : Rotinas para tela de importação de inscritos - BRC(WPGD0154)
  --  Sigla    : WPGD
  --  Autor    : Márcio Mouts
  --  Data     : 03/12/2018                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Importação de Inscritos - BRC (WPGD0154)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral para listagem de eventos
  PROCEDURE pc_retorna_lista_evento(pr_nmarquivo  IN varchar2         --> Nome do Arquivo
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
  
  -- Rotina geral para retornar o nome do PA
  PROCEDURE pc_retorna_nome_pa(pr_nmarquivo  IN varchar2              --> Nome do Arquivo
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro

  -- Rotina para ler o arquivo e gravar a tabela de inscritos
  PROCEDURE pc_importa_inscritos(pr_nmarquivo  IN varchar2                  --> Nome do Arquivo
                                ,pr_xmllog     IN VARCHAR2                  --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER              --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2                 --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2                 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2);               --> Descricao do Erro

  PROCEDURE pc_retorna_lista_arquivo(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Saida OK/NOK
END WPGD0154;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0154 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0154                     
  --  Sistema  : Rotinas para tela de importação de inscritos - BRC(WPGD0154)
  --  Sigla    : WPGD
  --  Autor    : Márcio Mouts
  --  Data     : 03/12/2018                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Importação de Inscritos - BRC (WPGD0154)
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral para listagem de eventos
  PROCEDURE pc_retorna_lista_evento(pr_nmarquivo  IN varchar2         --> Nome do Arquivo
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      CURSOR cr_crapadp(pr_cdcooper crapage.cdcooper%TYPE
                       ,pr_dtanoage crapadp.dtanoage%TYPE
                       ,pr_cdagenci crapage.cdagenci%TYPE) IS

        select 
             c.nrseqdig,
             ce.nmevento||' - '||c.dtinieve||' - '|| c.dshroeve nmevento
          from 
             crapadp c,
             crapedp ce
         where
             c.idevento = 2
         and c.cdcooper = pr_cdcooper
         and c.dtanoage = pr_dtanoage
         and c.cdagenci = pr_cdagenci
         and c.idstaeve not in(2,4) -- Cancelados e Encerrados
         and ce.idevento = c.idevento
         and ce.cdcooper = c.cdcooper
         and ce.dtanoage = c.dtanoage
         and ce.cdevento = c.cdevento
         and ce.tpevento not in(10,11) -- Eventos EAD
         UNION ALL
        select 
             c.nrseqdig,
             ce.nmevento||' - '||c.dtinieve||' - '|| c.dshroeve nmevento
          from 
             crapadp c,
             crapedp ce
         where
             c.idevento = 2
         and c.cdcooper = pr_cdcooper
         and c.dtanoage = pr_dtanoage
         and c.cdagenci = 0 -- AGO e AGE
         and c.idstaeve not in(2,4) -- Cancelados e Encerrados
         and ce.idevento = c.idevento
         and ce.cdcooper = c.cdcooper
         and ce.dtanoage = c.dtanoage
         and ce.cdevento = c.cdevento
         and ce.tpevento not in(10,11) -- Eventos EAD
         order by 1;
 
      rw_crapadp cr_crapadp%ROWTYPE;
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_contador INTEGER := 0;
            
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;   
      
      vr_cdagenci crapage.cdagenci%TYPE;   
      vr_dtanoage crapadp.dtanoage%TYPE;        

    BEGIN
     prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_nmdeacao => vr_nmdeacao
                                  ,pr_idcokses => vr_idcokses
                                  ,pr_idsistem => vr_idsistem
                                  ,pr_cddopcao => vr_cddopcao
                                  ,pr_dscritic => vr_dscritic);

      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;   
      
      --Extrair o código do PA e o ano, do nome do arquivo recebido como parâmetro 
      vr_cdagenci:= substr(pr_nmarquivo,3,3);
      vr_dtanoage:= substr(pr_nmarquivo,10,4);
           
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_crapadp IN cr_crapadp(vr_cdcooper, vr_dtanoage, vr_cdagenci) LOOP

        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);        
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nrseqdig', pr_tag_cont => rw_crapadp.nrseqdig, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapadp.nmevento, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;
        
      END LOOP;
      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador , pr_des_erro => vr_dscritic);
      
    EXCEPTION
      
      WHEN vr_exc_saida THEN
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

        ROLLBACK;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0154.pc_retorna_lista_evento: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
  END pc_retorna_lista_evento;

  -- Rotina geral para retornar o nome do PA
  PROCEDURE pc_retorna_nome_pa(pr_nmarquivo  IN varchar2              --> Nome do Arquivo
                              ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2)IS          --> Descricao do Erro
 

      CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE
                       ,pr_cdagenci crapage.cdagenci%TYPE) IS

        SELECT c.cdagenci||' - '||c.nmresage nmresage
          FROM crapage c
         WHERE c.cdcooper = pr_cdcooper
           AND c.cdagenci = pr_cdagenci;

      rw_crapage cr_crapage%ROWTYPE;
      

      CURSOR cr_crapadp(pr_progress_recid crapadp.progress_recid%TYPE) IS
        select 
             ce.nmevento nmevento,
             to_char(ca.dtinieve,'dd/mm/yyyy')||' '||ca.dshroeve dtiniev,
             cl.dslocali dslocali
          from 
             crapadp ca,
             crapedp ce,
             crapldp cl
         where
             ca.progress_recid = pr_progress_recid
         and ce.idevento = ca.idevento
         and ce.cdcooper = ca.cdcooper 
         and ce.dtanoage = ca.dtanoage
         and ce.cdevento = ca.cdevento 
         and cl.nrseqdig = ca.cdlocali;
 
      rw_crapadp cr_crapadp%ROWTYPE;      

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;   
      
      vr_cdagenci crapage.cdagenci%TYPE;   
      vr_idassembleia  NUMBER;    
      vr_nmdireto     varchar2(100);
      vr_nmdarqui     varchar2(1000);
      -- Variáveis locais
      vr_contador INTEGER := 0;
      

    BEGIN
     
     prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_nmdeacao => vr_nmdeacao
                                  ,pr_idcokses => vr_idcokses
                                  ,pr_idsistem => vr_idsistem
                                  ,pr_cddopcao => vr_cddopcao
                                  ,pr_dscritic => vr_dscritic);

      --Extrair o código do PA do nome do arquivo recebido como parâmetro
      vr_cdagenci:= substr(trim(pr_nmarquivo),6,3);
      
      OPEN cr_crapage(pr_cdcooper => vr_cdcooper
                     ,pr_cdagenci => vr_cdagenci);

      FETCH cr_crapage INTO rw_crapage ;
      
      IF cr_crapage%NOTFOUND THEN
        CLOSE cr_crapage;
        vr_dscritic := 'Registro de PA não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapage;
      END IF;

      vr_idassembleia  := substr(trim(pr_nmarquivo),10,7);

      OPEN cr_crapadp(vr_idassembleia);

      FETCH cr_crapadp INTO rw_crapadp ;
      
      IF cr_crapadp%NOTFOUND THEN
        CLOSE cr_crapadp;
        vr_dscritic := 'Evento não encontrado.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapadp;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmevento', pr_tag_cont => rw_crapadp.nmevento, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapage.nmresage, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'dtiniev' , pr_tag_cont => rw_crapadp.dtiniev,  pr_des_erro => vr_dscritic);      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'dslocali', pr_tag_cont => rw_crapadp.dslocali, pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador , pr_des_erro => vr_dscritic);    
      
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
        pr_dscritic := 'Erro geral em PC_WPGD0154.pc_retorna_nome_pa: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_retorna_nome_pa;

  -- Rotina para ler o arquivo e gravar a tabela de inscritos
  PROCEDURE pc_importa_inscritos(pr_nmarquivo  IN varchar2                  --> Nome do Arquivo
                                ,pr_xmllog     IN VARCHAR2                  --> XML com informações de LOG
                                ,pr_cdcritic   OUT PLS_INTEGER              --> Código da crítica
                                ,pr_dscritic   OUT VARCHAR2                 --> Descrição da crítica
                                ,pr_retxml     IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                ,pr_nmdcampo   OUT VARCHAR2                 --> Nome do campo com erro
                                ,pr_des_erro   OUT VARCHAR2) IS             --> Descricao do Erro
		
  ---------------------------------------------------------------------------
  --
  --  Programa : pc_importa_inscritos
  --  Sistema  : Ayllos Web
  --  Autor    : Gabriel Marcos
  --  Data     : Setembro/2019                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Importar arquivo atraves da tela Importar arquivos - BRC.
  --
  -- Alteracoes: 18/09/2019 - Criado nova coluna separando o ddd.
  --                          Gabriel Marcos (Mouts) - P484.2
  --
  ---------------------------------------------------------------------------

      CURSOR cr_crapadp(pr_progress_recid crapadp.progress_recid%TYPE) IS
        select 
             *
          from 
             crapadp c
         where
             c.progress_recid = pr_progress_recid;
 
      rw_crapadp cr_crapadp%ROWTYPE;
      
      CURSOR cr_tbevento_pessoa_grupos(pr_cdcooper in crapcop.cdcooper%TYPE,
                                       pr_idpessoa in tbevento_pessoa_grupos.idpessoa%TYPE) is
        select 
               t.nrdconta ,
               c.nmprimtl
          from 
               tbevento_pessoa_grupos t,
               crapass c
         where 
               t.cdcooper = pr_cdcooper 
           and t.idpessoa = pr_idpessoa
           and c.cdcooper = t.cdcooper
           and c.nrdconta = t.nrdconta ;
           
      rw_tbevento_pessoa_grupos cr_tbevento_pessoa_grupos%ROWTYPE;    

      CURSOR cr_crapcem(pr_cdcooper in crapcem.cdcooper%TYPE,
                        pr_nrdconta in crapcem.nrdconta%TYPE) is
        select 
              cc.dsdemail
          from 
              crapcem cc
         where 
              cc.cdcooper = pr_cdcooper 
          and cc.nrdconta = pr_nrdconta
          and cc.idseqttl = 1
          and cc.dtmvtolt = (select 
                                   max(cc2.dtmvtolt)
                               from 
                                   crapcem cc2
                              where 
                                   cc2.cdcooper = cc.cdcooper 
                               and cc2.nrdconta = cc.nrdconta
                               and cc2.idseqttl = cc.idseqttl);
           
      rw_crapcem cr_crapcem%ROWTYPE;

      CURSOR cr_craptfc(pr_cdcooper in crapcem.cdcooper%TYPE,
                        pr_nrdconta in crapcem.nrdconta%TYPE) is
        select 
              c.nrdddtfc,
              c.nrtelefo
          from 
              craptfc c
         where 
              c.cdcooper = pr_cdcooper 
          and c.nrdconta = pr_nrdconta
          and c.idseqttl = 1
          and c.cdseqtfc = (select 
                                   min(c2.cdseqtfc)
                               from 
                                   craptfc c2
                              where 
                                   c2.cdcooper = c.cdcooper 
                               and c2.nrdconta = c.nrdconta
                               and c2.idseqttl = c.idseqttl );
                               
      rw_craptfc cr_craptfc%ROWTYPE;                               
      
      CURSOR cr_crapavt(pr_cdcooper in crapavt.cdcooper%TYPE,
                        pr_nrdconta in crapavt.nrdconta%TYPE,
                        pr_nrcpfcgc in crapavt.nrcpfcgc%TYPE) is
          select 
                ca.nrcpfcgc,
                ca.nrdctato,
                ca.tpctrato,
                ca.nrctremp
           from 
                crapavt ca
          where 
                ca.cdcooper = pr_cdcooper
            and ca.nrdconta = pr_nrdconta 
            and ca.tpctrato = 6
            and ca.nrctremp = 0
            and ca.nrcpfcgc = pr_nrcpfcgc;                       

      rw_crapavt cr_crapavt%ROWTYPE;    
            
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100);
      vr_nmdeacao VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_idsistem INTEGER;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_dserro       varchar2(1000);  
      vr_arquivo_clob clob;   
      vr_texto        varchar2(1000);   
      vr_tabtexto     gene0002.typ_split; 
      vr_arquivo      UTL_FILE.file_type;
      vr_nmdireto     varchar2(100);
      vr_nmdarqui     varchar2(1000);
      vr_dsmotivo     varchar2(1000);      
      vr_sqlerrm      varchar2(1000);      
      vr_conta        tbevento_pessoa_grupos.nrdconta%type;
      vr_email        crapcem.dsdemail%type;
      vr_conta_socio  crapavt.nrdctato%type;
      
      --Variaveis para guardar as informações contidas no arquivo      
      vr_idassembleia  NUMBER;      -- IDassembleia  - ID assembleia da AILOS(idintegracao da assembleia)
      vr_idpessoaint   NUMBER;      -- IDpessoaintegracao - ID pessoa da AILOS (idintegracao da pessoa)
      vr_idpessoasoc   NUMBER;      -- IDpessoasocio - ID pessoa AILOS, quando o sócio tiver  IDpessoapf
      vr_nome          VARCHAR2(150);-- Nome - Nome do Sócio
      vr_cpf           NUMBER;      -- CPF - CPF do Sócio
      vr_telefone      NUMBER;      -- Telefone - Campo comunidade
      vr_tptelefone    NUMBER;      -- Tipotelefone - Campo comunidade
      vr_ddd           NUMBER;      -- DDD
      vr_tppessoa      NUMBER;      -- Tipopessoa - 0 - PF / 1 - PJ
      vr_crianca       VARCHAR2(150);-- Crianca - Campo comunidade
      vr_idvoto        VARCHAR2(1); -- Votou (Y/N) Default = N      
      vr_keypad        NUMBER;
      vr_dhentrada     VARCHAR2(50);
      vr_dhsaida       VARCHAR2(50);      
      vr_grupo         VARCHAR2(50);
      vr_PA            NUMBER;
      vr_tpcadastro    NUMBER;      -- 0 - Cooperado / 1 - Comunidade
      vr_linha_arquivo NUMBER:=0;

      --Variaveis de excecao
      vr_exc_conta  exception;
      vr_exc_insert exception;
      vr_exc_duplic exception;
      vr_exc_risco  exception;

      --Variavel para testes em homol/desenvolvimento
      vr_root_micros varchar2(4000);

    BEGIN
      
      prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                   ,pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_nmdeacao => vr_nmdeacao
                                   ,pr_idcokses => vr_idcokses
                                   ,pr_idsistem => vr_idsistem
                                   ,pr_cddopcao => vr_cddopcao
                                   ,pr_dscritic => vr_dscritic);

      -- Busca o diretorio onde esta os arquivos BRC '/micros/viacredi/'
      vr_nmdireto :=gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
	                                          pr_cdcooper => vr_cdcooper,
                                              pr_cdacesso => 'DIRETORIO_ARQUIVO_BRC');
      vr_nmdarqui:= pr_nmarquivo;
      
      --ambientes de desenvolvimento/homologacao possuem diretorio microsd/microsh por exemplo
      vr_root_micros := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 0, pr_cdacesso => 'ROOT_MICROS');
      vr_nmdireto    := replace(vr_nmdireto,'/micros/',vr_root_micros);
    
      --Abre arquivo a ser importado
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                               pr_nmarquiv => vr_nmdarqui,
                               pr_tipabert => 'R',
                               pr_utlfileh => vr_arquivo,
                               pr_des_erro => vr_dserro);
    
      if vr_dserro is not null then
        vr_dserro := 'Erro ao abrir arquivo';
        raise_application_error(-20001,'Erro ao abrir arquivo - '||vr_dserro);
      end if;
          --Abre arquivo de saida para geracao de logs linha a linha
      dbms_lob.createtemporary(vr_arquivo_clob, TRUE);
      dbms_lob.open(vr_arquivo_clob, dbms_lob.lob_readwrite);

      vr_idassembleia  := substr(vr_nmdarqui,10,7);

      -- Selecionar o evendo a partir do w_idassembleia (progress_recid ) 
      -- para realizar a exclusão das inscrições já existentes no evento
      OPEN cr_crapadp(vr_idassembleia);
      FETCH cr_crapadp INTO rw_crapadp ;
      
      IF cr_crapadp%NOTFOUND THEN
        CLOSE cr_crapadp;
        vr_dscritic := 'Evento não cadastrado = '||vr_idassembleia;
        RAISE vr_exc_saida;
      ELSE
        BEGIN
          DELETE
                crapidp c
          WHERE
                c.idevento = rw_crapadp.idevento
            AND c.cdcooper = rw_crapadp.cdcooper
            AND c.dtanoage = rw_crapadp.dtanoage
            AND c.cdagenci = rw_crapadp.cdagenci
            AND c.cdevento = rw_crapadp.cdevento
            AND c.nrseqeve = rw_crapadp.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir os dados da tabela CRAPIDP! '|| sqlerrm;
            raise vr_exc_saida;          
        END;
        CLOSE cr_crapadp;
      END IF;  
    
      loop
        begin
          vr_dsmotivo := '';
          vr_dserro   := '';
          vr_linha_arquivo:= vr_linha_arquivo+1;

          --Leitura da linha do arquivo
          gene0001.pc_le_linha_arquivo(vr_arquivo,vr_texto);
          vr_texto := trim(translate(translate(vr_texto,chr(10),' '),chr(13),' '));
          vr_texto := trim(replace(vr_texto,'ï»¿',' '));          
          vr_texto := trim(replace(vr_texto,'NULL',' '));                    
          vr_tabtexto := gene0002.fn_quebra_string(vr_texto,';');
        
          for x in 1..vr_tabtexto.count loop
            case
              when x =  1 then vr_idpessoaint   := to_number(vr_tabtexto(x));
              when x =  2 then vr_idpessoasoc   := to_number(vr_tabtexto(x));
              when x =  3 then vr_nome          := vr_tabtexto(x);
              when x =  4 then vr_cpf           := to_number(vr_tabtexto(x));
              when x =  5 then vr_ddd           := to_number(vr_tabtexto(x));
              when x =  6 then vr_telefone      := to_number(vr_tabtexto(x));
              when x =  7 then vr_tptelefone    := to_number(vr_tabtexto(x));
              when x =  8 then vr_tppessoa      := to_number(vr_tabtexto(x));
              when x =  9 then vr_crianca       := vr_tabtexto(x);
              when x = 10 then vr_idvoto        := vr_tabtexto(x);
              when x = 11 then vr_keypad        := to_number(vr_tabtexto(x));
              when x = 12 then vr_dhentrada     := vr_tabtexto(x);
              when x = 13 then vr_dhsaida       := vr_tabtexto(x);
              when x = 14 then vr_grupo         := vr_tabtexto(x);
              when x = 15 then vr_PA            := to_number(vr_tabtexto(x));
              when x = 16 then vr_tpcadastro    := to_number(vr_tabtexto(x));
              else null;
            end case;
          end loop;

        -- Validações dos dados recebidos
        -- Nome
        IF length(vr_nome) > 50 THEN
          vr_dscritic := 'Nome do inscrito não pode ser maior que 50 caracteres! Linha do Arquivo= '||vr_linha_arquivo||'Nome= '||vr_nome;
          RAISE vr_exc_saida;
        END IF;
        -- CPF/CNPJ
        IF length(vr_cpf) > 25 THEN
          vr_dscritic := 'CPF/CNPJ do inscrito não pode ser maior que 25 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' CPF/CNPJ= '||vr_cpf;
          RAISE vr_exc_saida;
        END IF;
        -- Nro do DDD
        IF length(vr_ddd) > 5 THEN
          vr_dscritic := 'Número do DDD não pode ser maior que 5 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' DDD: '||vr_ddd;
          RAISE vr_exc_saida;
        END IF;
        -- Telefone
        IF length(vr_telefone) > 10 THEN
          vr_dscritic := 'Número do Telefone não pode ser maior que 10 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' Telefone: '||vr_telefone;
          RAISE vr_exc_saida;
        END IF;
        -- Tipo de Pessoa
        IF vr_tppessoa NOT IN (0,1) THEN
          vr_dscritic := 'Tipo de Pessoa deve ser igual a 0-PF ou 1-PJ! Linha do Arquivo= '||vr_linha_arquivo||' Tipo de Pessoa = '||vr_tppessoa;
          RAISE vr_exc_saida;
        END IF;
        -- Identificador de Voto
        IF vr_idvoto NOT IN ('Y','N') THEN
          vr_dscritic := 'Identificador de Voto deve ser igual a Y-Yes ou N - No! Linha do Arquivo= '||vr_linha_arquivo||' Identificador de Voto = '||vr_idvoto;
          RAISE vr_exc_saida;
        END IF;
        -- Data de Entrada
        IF length(vr_dhentrada) > 16 THEN
          vr_dscritic := 'Data de Entrada não pode ser maior que 16 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' Data = '||vr_dhentrada;
          RAISE vr_exc_saida;
        END IF;
        BEGIN 
          -- Tratar campo data, forcar exception se vier como nulo
          vr_dhentrada := to_date(substr(nvl(vr_dhentrada,'-'),1,10),'yyyy-mm-dd');
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Formato da Data de Entrada incorreto. Data de Entrada deve estar no formato (AAAA-MM-DD)! Linha do Arquivo = '||vr_linha_arquivo||' Data = '||nvl(vr_dhentrada,'-');
            RAISE vr_exc_saida;
        END;
        -- Data de Saída
        IF length(vr_dhsaida) > 16 THEN
          vr_dscritic := 'Data de Saída não pode ser maior que 16 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' Data = '||vr_dhsaida;
          RAISE vr_exc_saida;
        END IF;
        vr_dhsaida := substr(vr_dhsaida,1,10);        
        IF substr(vr_dhsaida,5,1)||substr(vr_dhsaida,8,1) <> '--' THEN
          vr_dscritic := 'Formato da Data de Saída incorreto. Data de Saída deve estar no formato (AAAA-MM-DD)! Linha do Arquivo= '||vr_linha_arquivo||' Data = '||vr_dhsaida;
          RAISE vr_exc_saida;
        END IF;

        -- Grupo
        IF length(vr_grupo) > 10 THEN
          vr_dscritic := 'Grupo não pode ser maior que 10 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' Grupo = '||vr_grupo;
          RAISE vr_exc_saida;
        END IF;
        -- PA
        IF length(vr_PA) > 5 THEN
          vr_dscritic := 'PA não pode ser maior que 5 caracteres! Linha do Arquivo= '||vr_linha_arquivo||' PA = '||vr_PA;
          RAISE vr_exc_saida;
        END IF;
        -- Tipo de Cadastro
        IF vr_tpcadastro NOT IN (0,1) THEN
          vr_dscritic := 'Tipo de Cadastro deve ser igual a 0-Cooperado ou 1-Comunidade! Linha do Arquivo= '||vr_linha_arquivo||' Tipo de Cadastro = '||vr_tpcadastro;
          RAISE vr_exc_saida;
        END IF;


        -- Se for cooperado 
        IF vr_tpcadastro = 0 THEN  -- Cooperado

          --buscar a conta         
          OPEN cr_tbevento_pessoa_grupos(vr_cdcooper,vr_idpessoaint);

          FETCH cr_tbevento_pessoa_grupos INTO rw_tbevento_pessoa_grupos ;
      
          IF cr_tbevento_pessoa_grupos%NOTFOUND THEN
            CLOSE cr_tbevento_pessoa_grupos;
            vr_dscritic := 'Conta do cooperado não encontrada. IDPessoa = '||vr_idpessoaint||' - '||vr_nome;
            RAISE vr_exc_saida;
          ELSE
            vr_conta := rw_tbevento_pessoa_grupos.nrdconta;
            CLOSE cr_tbevento_pessoa_grupos;
          END IF;  
             
          -- Buscar o e-mail do cooperado
          IF vr_tppessoa = 0 THEN -- Pessoa Física
            
            vr_nome:=rw_tbevento_pessoa_grupos.nmprimtl;          

            -- Buscar o primeiro e-mail cadastrado para a conta da PF          
            OPEN cr_crapcem(vr_cdcooper,vr_conta);
            FETCH cr_crapcem INTO rw_crapcem ;
      
            IF cr_crapcem%NOTFOUND THEN
              CLOSE cr_crapcem;
              --Se não existir e-mail cadastrado grava em branco
              vr_email := '';
            ELSE
              vr_email := rw_crapcem.dsdemail;
              CLOSE cr_crapcem;
            END IF;  
            
            -- Buscar o primeiro telefone cadastrado para a conta da PF          
            OPEN cr_craptfc(vr_cdcooper,vr_conta);
            FETCH cr_craptfc INTO rw_craptfc ;
      
            IF cr_craptfc%NOTFOUND THEN
              CLOSE cr_craptfc;
              --Se não existir telefone cadastrado grava em branco
              vr_ddd      := '';
              vr_telefone := '';
            ELSE
              vr_ddd      := rw_craptfc.nrdddtfc;
              vr_telefone := rw_craptfc.nrtelefo;
              CLOSE cr_craptfc;
            END IF;  
            
          -- Se for pessoa jurídica buscar o primeiro e-mail cadastrado para a conta da PJ
          -- relacionado a conta associada ao CFP do sócio na tabela crapavt
          ELSIF vr_tppessoa = 1 THEN-- Pessoa Jurídica
            -- Buscar conta na crapavt
            OPEN cr_crapavt(vr_cdcooper,vr_conta,vr_cpf);
            FETCH cr_crapavt INTO rw_crapavt ;
      
            IF cr_crapavt%NOTFOUND THEN
              CLOSE cr_crapavt;
              vr_dscritic := 'Dados do sócio não encontrados na tabela CRAPAVT IDPessoa = '||vr_idpessoaint||' - '||vr_nome;
              RAISE vr_exc_saida;
            ELSE
              vr_conta_socio := rw_crapavt.nrdctato;
              CLOSE cr_crapavt;
            END IF;  
           
            --Se o sócio tem conta PF
            IF NVL(vr_conta_socio,0) <> 0 THEN
              OPEN cr_crapcem(vr_cdcooper,vr_conta_socio);
              FETCH cr_crapcem INTO rw_crapcem ;
      
              IF cr_crapcem%NOTFOUND THEN
                CLOSE cr_crapcem;
                --Se não existir e-mail cadastrado grava em branco
                vr_email := '';
              ELSE
                vr_email := rw_crapcem.dsdemail;
                CLOSE cr_crapcem;
              END IF; 
             
              OPEN cr_craptfc(vr_cdcooper,vr_conta_socio);
              FETCH cr_craptfc INTO rw_craptfc ;
      
              IF cr_craptfc%NOTFOUND THEN
                CLOSE cr_craptfc;
                --Se não existir telefone cadastrado grava em branco
                vr_ddd      := '';
                vr_telefone := '';
              ELSE
                vr_ddd      := rw_craptfc.nrdddtfc;
                vr_telefone := rw_craptfc.nrtelefo;
                CLOSE cr_craptfc;
              END IF;  
            END IF;
          END IF;
        ELSE
          vr_email := '';          
          vr_conta := 0;
          --vr_email := '';
        END IF;
      
        BEGIN
          insert into crapidp
                     (progress_recid,
                      idevento,
                      cdcooper,
                      cdagenci,
                      dtanoage,
                      cdevento,
                      nrseqdig,
                      nrdconta,
                      cdgraupr,
                      nminseve,
                      dsdemail,
                      nrdddins,
                      nrtelins,
                      dtpreins,
                      dtconins,
                      dsobsins,
                      cdoperad,
                      idseqttl,
                      idstains,
                      tpinseve,
                      flgdispe,
                      qtfaleve,
                      nrseqeve,
                      cdageins,
                      dtemcert,
                      flginsin,
                      dtaltera,
                      cdopinsc,
                      flgimpor,
                      cdopeori,
                      cdageori,
                      dtinsori,
                      cdcopavl,
                      tpctrato,
                      nrctremp,
                      nrcpfcgc,
                      dtrefatu,
                      nrficpre,
                      idvoto
                      )
               values(null,                                             --progress_recid NUMBER,
                      rw_crapadp.idevento,
                      rw_crapadp.cdcooper,
                      rw_crapadp.cdagenci,
                      rw_crapadp.dtanoage,
                      rw_crapadp.cdevento,
                      crapidp_seq.nextval,                               -- nrseqdig
                      vr_conta,                                          -- nrdconta       NUMBER(10) default 0,
                      5,                                                 -- cdgraupr       NUMBER(5) default 0,
                      vr_nome,                                           -- nminseve       VARCHAR2(50) default ' ',
                      vr_email,                                          -- dsdemail       VARCHAR2(50) default ' ',
                      vr_ddd,                                            -- nrdddins       NUMBER(5) default 0,
                      vr_telefone,                                       -- nrtelins       NUMBER(10) default 0,
                      vr_dhentrada,                                      -- dtpreins       DATE,
                      vr_dhentrada,                                      -- dtconins       DATE,
                      'Carga realizada a partir do programa WPGD0154 - Importação Incrições - BRC', --dsobsins       VARCHAR2(4000) default ' ',
                      vr_cdoperad,                                       -- cdoperad       VARCHAR2(10) default ' ',
                      decode(vr_tpcadastro,1,0,1),                       -- idseqttl       NUMBER(5) default 0,
                      2,                                                 -- idstains       NUMBER(5) default 0,
                      decode(vr_tpcadastro,1,2,1),                       -- tpinseve       NUMBER(5) default 0,
                      1,                                                 -- flgdispe       NUMBER default 0,
                      0,                                                 -- qtfaleve       NUMBER(5) default 0,
                      rw_crapadp.nrseqdig,                               -- nrseqeve       NUMBER(10) default 0,
                      rw_crapadp.cdagenci,                               -- cdageins       NUMBER(5) default 0,
                      null,                                              -- dtemcert       DATE,
                      0,                                                 -- flginsin       NUMBER default 0,
                      null,                                              -- dtaltera       DATE,
                      0,                                                 -- cdopinsc       VARCHAR2(10) default '0',
                      1,                                                 -- flgimpor       NUMBER default 0,
                      vr_cdoperad,                                       -- cdopeori       VARCHAR2(10) default ' ' not null,
                      rw_crapadp.cdagenci,                               -- cdageori       NUMBER(5) default 0 not null,
                      vr_dhentrada,                                      -- dtinsori       DATE,
                      decode(vr_tppessoa,1,rw_crapadp.cdcooper,0),       -- cdcopavl       NUMBER(10) default 0 not null,
                      decode(vr_tppessoa,1,rw_crapavt.tpctrato,0),       -- tpctrato       NUMBER(5) default 0 not null,
                      decode(vr_tppessoa,1,rw_crapavt.nrctremp,0),       -- nrctremp       NUMBER(10) default 0 not null,
                      decode(vr_tppessoa,1,rw_crapavt.nrcpfcgc,0),       -- nrcpfcgc       NUMBER(25) default 0 not null,
                      vr_dhentrada,                                      -- dtrefatu       DATE,
                      0,                                                 -- nrficpre       NUMBER(5) default 0,
                      decode(vr_idvoto,'Y',1,0)
                      );
      EXCEPTION
        when others then
          vr_dscritic := 'Erro ao incluir os dados da tabela CRAPIDP! '|| sqlerrm;          
          raise vr_exc_saida;
      END;  
        exception
          WHEN vr_exc_saida THEN

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

            ROLLBACK;
            raise;            
          when no_data_found then
            -- última linha
          raise;
        when others then
          vr_dsmotivo := 'Erro não identificado - '||sqlerrm;
      end;

    end loop;
    commit;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao  => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => 0, pr_tag_nova => 'dscimporta', pr_tag_cont => 'Importação do arquivo realizada com sucesso!', pr_des_erro => vr_dscritic);
      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => 0 , pr_des_erro => vr_dscritic);    
    

    EXCEPTION
    when no_data_found then
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);

      -- Gerar mensagem para apresentar na tela
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Mensagem>' || 'Arquivo importado com sucesso!' || '</Mensagem></Root>');

      commit;
      
      WHEN vr_exc_saida THEN

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

        ROLLBACK;

      WHEN vr_exc_insert THEN

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

        ROLLBACK;

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0154.pc_importa_inscritos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;

  END pc_importa_inscritos;
  
  ---------------------------
    PROCEDURE pc_retorna_lista_arquivo(pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK

      
    -- PL/Table que vai armazenar os nomes de arquivos a serem processados
    vr_tab_arqtmp       gene0002.typ_split;
    
    -- VARIÁVEIS
    vr_dsdiretorio      VARCHAR2(100);  
    vr_listaarq         VARCHAR2(4000);     --> Lista de arquivos
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    
    -- Variáveis locais
    vr_contador INTEGER := 0;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad crapope.cdoperad%TYPE;
    vr_nmdatela VARCHAR2(100);
    vr_nmdeacao VARCHAR2(100);
    vr_cddopcao VARCHAR2(100);
    vr_idcokses VARCHAR2(100);
    vr_idsistem INTEGER;   
    
    
  BEGIN
     prgd0001.pc_extrai_dados_prgd(pr_xml      => pr_retxml
                                  ,pr_cdcooper => vr_cdcooper
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_nmdeacao => vr_nmdeacao
                                  ,pr_idcokses => vr_idcokses
                                  ,pr_idsistem => vr_idsistem
                                  ,pr_cddopcao => vr_cddopcao
                                  ,pr_dscritic => vr_dscritic);

      -- Verifica se houve critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;       

    -- Busca o diretorio onde esta os arquivos BRC '/micros/viacredi/'
    vr_dsdiretorio :=gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => vr_cdcooper,
                                               pr_cdacesso => 'DIRETORIO_ARQUIVO_BRC');

    -- Listar arquivos
    gene0001.pc_lista_arquivos( pr_path     => vr_dsdiretorio
                               ,pr_pesq     => 'EV_PA%.csv'
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => pr_dscritic);
    -- Se ocorreu erro, cancela o programa
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    
    -- Se possuir arquivos para serem processados
    IF vr_listaarq IS NOT NULL THEN

      --Carregar a lista de arquivos csv na pl/table
      vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarq);

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
            
      -- Leitura da PL/Table e processamento dos arquivos
      FOR ind_arq IN vr_tab_arqtmp.first()..vr_tab_arqtmp.last() LOOP
      
        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);              
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao  => vr_contador, pr_tag_nova => 'nmarquivo', pr_tag_cont => vr_tab_arqtmp(ind_arq), pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;        
      END LOOP; -- Loop dos arquivos
      
    ELSE 
      vr_dscritic := 'Nenhum arquivo encontrado para processamento!';
      RAISE vr_exc_saida;
    END IF;
    
      GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador , pr_des_erro => vr_dscritic);    

  EXCEPTION
    WHEN vr_exc_saida THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;      
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro geral pc_gerar_arquivo_cetip: ' || SQLERRM;
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' ||
                                     pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END pc_retorna_lista_arquivo;
END WPGD0154;
/
