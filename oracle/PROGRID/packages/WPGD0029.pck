CREATE OR REPLACE PACKAGE PROGRID.WPGD0029 is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0029
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Avaliações.
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Rotina para envio de email da avaliação
  PROCEDURE pc_envia_email_avaliacao( pr_idevento      IN crapadp.idevento%TYPE --> Id do evento 
                                     ,pr_cdcoptel      IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa 
                                     ,pr_cdagenci      IN crapage.cdagenci%TYPE --> Codigo da Agencia 
                                     ,pr_dtanoage      IN crapppc.dtanoage%TYPE --> Ano Agenda 
                                     ,pr_nrseqdig      IN crapadp.nrseqdig%TYPE --> Sequencial do evento
                                     ,pr_cdevento      IN crapadp.cdevento%TYPE --> codigo do evento
                                     ,pr_dsdemail      IN VARCHAR2              --> Lista de emails destino

                                     ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro       OUT VARCHAR2);           --> Descricao do Erro
    
END WPGD0029;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0029 IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0029
  --  Sistema  : PROGRID
  --  Sigla    : WPGD
  --  Autor    : Odirlei - AMcom
  --  Data     : Agosto/2016.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Avaliações.
  --
  -- Alteracoes: 
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Rotina para envio de email da avaliação
  PROCEDURE pc_envia_email_avaliacao( pr_idevento      IN crapadp.idevento%TYPE --> Id do evento 
                                     ,pr_cdcoptel      IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa 
                                     ,pr_cdagenci      IN crapage.cdagenci%TYPE --> Codigo da Agencia 
                                     ,pr_dtanoage      IN crapppc.dtanoage%TYPE --> Ano Agenda 
                                     ,pr_nrseqdig      IN crapadp.nrseqdig%TYPE --> Sequencial do evento
                                     ,pr_cdevento      IN crapadp.cdevento%TYPE --> codigo do evento
                                     ,pr_dsdemail      IN VARCHAR2              --> Lista de emails destino

                                     ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro       OUT VARCHAR2) IS         --> Descricao do Erro

  
    /* ..........................................................................
    --
    --  Programa : pc_envia_email_avaliacao
    --  Sistema  : Progrid
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Enviar de email da avaliação
    --
    --  Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................*/
    
      ---------->> CURSORES <<------------ 
      --> Buscar nome agencia e coop
      CURSOR cr_crapage IS
        SELECT cop.nmrescop,
               age.nmresage
          FROM crapcop cop
              ,crapage age
         WHERE cop.cdcooper = age.cdcooper
           AND cop.cdcooper = pr_cdcoptel
           AND age.cdagenci = pr_cdagenci;          
      rw_crapage cr_crapage%ROWTYPE;
      
      --> Buscar dados cecred
      CURSOR cr_crapcop_c IS
        SELECT cop.nmrescop,
               cop.nmextcop,
               cop.nmcidade,
               cop.cdufdcop,
               cop.dsendweb
          FROM crapcop cop
         WHERE cop.cdcooper = 3;
      rw_crapcop_c cr_crapcop_c%ROWTYPE;
      
      --> Buscar facilitadores
      CURSOR cr_gnapfep(pr_idevento  crapcdp.idevento%TYPE,
                        pr_cdcooper  crapcdp.cdcooper%TYPE,
                        pr_cdagenci  crapcdp.cdagenci%TYPE,
                        pr_dtanoAge  crapcdp.dtanoage%TYPE,
                        pr_cdevento  crapcdp.cdevento%TYPE ) IS
        SELECT gnapfep.nmfacili
          FROM crapcdp
              ,gnappdp
              ,gnfacep
              ,gnapfep
         WHERE crapcdp.idevento = pr_idevento
           AND crapcdp.cdcooper = pr_cdcoptel
           AND crapcdp.cdagenci = pr_cdagenci
           AND crapcdp.dtanoage = pr_dtanoAge
           AND crapcdp.tpcuseve = 1 /* direto */
           AND crapcdp.cdevento = pr_cdevento
           AND crapcdp.cdcuseve = 1 /* honorários */
              /* proposta do evento */
           AND gnappdp.idevento = crapcdp.idevento
           AND gnappdp.cdcooper = 0
           AND gnappdp.nrcpfcgc = crapcdp.nrcpfcgc
           AND gnappdp.nrpropos = crapcdp.nrpropos
              --> Localiza e trata facilitador 
           AND gnfacep.idevento = gnappdp.idevento
           AND gnfacep.cdcooper = 0
           AND gnfacep.nrcpfcgc = Gnappdp.nrcpfcgc
           AND gnfacep.nrpropos = Gnappdp.nrpropos
           AND gnapfep.idevento = gnfacep.idevento
           AND gnapfep.cdcooper = 0
           AND gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
           AND gnapfep.cdfacili = gnfacep.cdfacili;
      rw_gnapfep cr_gnapfep%ROWTYPE;
      
      
      --> Buscar dados do evento
      CURSOR cr_crapadp IS
        SELECT crapadp.dtinieve
              ,crapadp.dtfineve
              ,crapadp.nrmeseve
              ,crapadp.idevento
              ,crapedp.tpevento
              ,crapedp.nmevento
              ,crapadp.cdagenci
              ,crapadp.cdevento
              ,crapadp.dshroeve
              ,' LOCAL: '|| crapldp.dslocali dslocali
          FROM crapadp
              ,crapedp
              ,crapldp
         WHERE crapedp.idevento    = crapadp.idevento
           AND crapedp.cdcooper    = crapadp.cdcooper
           AND crapedp.dtanoage    = crapadp.dtanoage
           AND crapedp.cdevento    = crapadp.cdevento
           AND crapldp.idevento(+) = crapadp.idevento
           AND crapldp.cdcooper(+) = crapadp.cdcooper
           AND crapldp.cdagenci(+) = crapadp.cdagenci
           AND crapldp.nrseqdig(+) = crapadp.cdlocali
           AND crapadp.idevento    = pr_idevento
           AND crapadp.cdcooper    = pr_cdcoptel
           AND crapadp.nrseqdig    = pr_nrseqdig;
           
      rw_crapadp cr_crapadp%ROWTYPE;
           
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      -- Tratamento de erros
      vr_exc_erro     EXCEPTION;
      
      -- Variaveis de log
      vr_cdcooper   crapcop.cdcooper%TYPE;
      vr_cdoperad   crapope.cdoperad%TYPE;
      vr_nmdatela   VARCHAR2(100);
      vr_nmdeacao   VARCHAR2(100);
      vr_idcokses   VARCHAR2(100);
      vr_cddopcao   VARCHAR2(100);
      vr_idsistem   INTEGER;
      vr_emailPGD   VARCHAR2(200);
      
      vr_nmarqpdf   VARCHAR2(500);      

      -- Variáveis locais
      vr_dsassunt   VARCHAR2(4000); 
      vr_dsdcorpo   VARCHAR2(4000); 
      vr_dspereve   VARCHAR2(4000); 
      
    BEGIN
    
      prgd0001.pc_extrai_dados_prgd (pr_xml      => pr_retxml
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
        RAISE vr_exc_erro;
      END IF;  
      
      IF TRIM(pr_dsdemail) IS NULL THEN
        vr_dscritic := 'Email não informado.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Gerar relatorio PDF das avaliações
      wpgd0041.pc_gera_relatorio_forn ( pr_idevento   => pr_idevento,   --> indicador de evento
                                        pr_cdcooper   => pr_cdcoptel,   --> Codigo da cooperativa
                                        pr_cdAgenci   => pr_cdAgenci,   --> Codigo da agencia
                                        pr_dtanoage   => pr_dtanoage,   --> Ano agenda
                                        pr_nrseqdig   => pr_nrseqdig,   --> Sequencial unico do evento
                                        pr_tpdavali   => 1,             --> Tipo de avaliações
                                        pr_cdevento   => pr_cdevento,   --> Codigo de evento
                                        pr_tprelato   => 0,             --> Tipo de agrupamento 0-Todos 
                                        pr_idsessao   => vr_idcokses,   --> Id da sessao
                                        pr_nmarqpdf   => vr_nmarqpdf,   --> Retorna pdf gerado
                                        pr_cdcritic   => vr_cdcritic,
                                        pr_dscritic   => vr_dscritic);
      
      -- Verifica se houve critica
      IF TRIM(vr_dscritic) IS NOT NULL OR
         nvl(vr_cdcritic,0) > 0 THEN
        RAISE vr_exc_erro;
      END IF;      
      
      --> Buscar dados do evento
      OPEN cr_crapadp;
      FETCH cr_crapadp INTO rw_crapadp;
      CLOSE cr_crapadp;
      
      OPEN cr_crapage;
      FETCH cr_crapage INTO rw_crapage;
      CLOSE cr_crapage;
      
      --> Buscar dados cecred
      OPEN cr_crapcop_c;
      FETCH cr_crapcop_c INTO rw_crapcop_c;
      CLOSE cr_crapcop_c;
      
      
      rw_gnapfep := NULL;
      --> Buscar facilitadores
      OPEN cr_gnapfep(pr_idevento  => pr_idevento,
                      pr_cdcooper  => pr_cdcoptel,
                      pr_cdagenci  => pr_cdagenci,
                      pr_dtanoAge  => pr_dtanoAge,
                      pr_cdevento  => rw_crapadp.cdevento);
      FETCH cr_gnapfep INTO rw_gnapfep;
      CLOSE cr_gnapfep;
      
      vr_emailPGD := gene0001.fn_param_sistema (pr_nmsistem => 'CRED', 
                                                pr_cdcooper => pr_cdcoptel, 
                                                pr_cdacesso => 'EMAIL_OQS_PROGRID');
      
      vr_dsassunt := 'Avaliação do Evento '||rw_crapadp.nmevento;
      
      --> definir periodo do evento
      IF rw_crapadp.dtfineve - rw_crapadp.dtinieve > 0 THEN
        vr_dspereve := 'entre os dias'||to_char(rw_crapadp.dtinieve,'DD/MM/RRRR')||' e '|| to_char(rw_crapadp.dtfineve,'DD/MM/RRRR');
      ELSE
        vr_dspereve := 'no dia '||to_char(rw_crapadp.dtinieve,'DD/MM/RRRR');
      END IF;
      
      ---> Montar corpo email
      vr_dsdcorpo := 'Olá '||rw_gnapfep.nmfacili||'<br><br>'||
                     'Segue, para sua apreciação, a avaliação do evento '||rw_crapadp.nmevento||
                     ', realizado '|| vr_dspereve ||', '|| rw_crapadp.dshroeve ||
                     ' na cooperativa '||rw_crapage.nmrescop ||' - '|| rw_crapage.nmresage ||' - '|| pr_cdagenci ||'.'||
                     '<br><br>'||
                     'Estamos à disposição.<br><br>'||
                     'Atenciosamente,<br>'||
                     'Governança Cooperativa e Organização do Quadro Social <br>
                     _________________________________________________________<br>'||
                     Initcap(rw_crapcop_c.nmextcop) || '<br>'||rw_crapcop_c.dsendweb ||'<br>'||
                     rw_crapcop_c.nmcidade ||' - '|| rw_crapcop_c.cdufdcop;
      
      -- Enviar email
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcoptel
                                ,pr_cdprogra        => 'WPGD0029'
                                ,pr_des_destino     => pr_dsdemail
                                ,pr_des_assunto     => vr_dsassunt
                                ,pr_des_corpo       => vr_dsdcorpo
                                ,pr_des_anexo       => vr_nmarqpdf
                                ,pr_des_nome_reply  => 'Organizacao do Quadro Social - Cecred'
                                ,pr_des_email_reply => vr_emailPGD
                                ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);

      -- Se houver erros
      IF vr_dscritic IS NOT NULL THEN
        -- Gera critica
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
      END IF;              

     COMMIT;         
    EXCEPTION
      WHEN vr_exc_erro THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0020A: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_envia_email_avaliacao;
  
  
END WPGD0029;
/
