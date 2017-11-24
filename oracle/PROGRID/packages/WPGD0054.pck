CREATE OR REPLACE PACKAGE PROGRID.WPGD0054 is
 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0054
  --  Sistema  : Rotinas para tela de Envio de Sugestoes
  --  Sigla    : WPGD
  --  Autor    : Vanessa
  --  Data     : Outubro/2015.                   Ultima atualizacao: 11/04/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Seleção de Eventos.
  --
  -- Alteracoes: 11/04/2016 - Correcao na consistencia sobre o cadastro de email de contato na tela
  --                          de parametros do Progrid, na pc_envia_sugestao apresentando mensagem 
  --                          ao usuario conforme especificacao da tela WPGD0054. (Carlos Rafael Tanholi)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0054
  PROCEDURE pc_envia_sugestao(pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Cooperativa
                             ,pr_dtanoage       IN crapppc.dtanoage%TYPE --> Ano Agenda
                             ,pr_txsugest       IN VARCHAR2              --> Texto
                             ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                             ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro       OUT VARCHAR2);           --> Descricao do Erro

  PROCEDURE pc_crapsde(pr_cddopcao        IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                       ,pr_idevento       IN crapsde.idevento%TYPE              
                       ,pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Cooperativa
                       ,pr_dtanoage       IN crapppc.dtanoage%TYPE --> Ano Agenda
                       ,pr_cdevento       IN VARCHAR2              --> Texto
                       ,pr_nrocoeve       IN crapsde.nrocoeve%TYPE
                       ,pr_dtdesaja       IN crapsde.dsdatsug%TYPE
                       ,pr_hrinicio       IN VARCHAR2
                       ,pr_dtopcio1       IN crapsde.dsdatop1%TYPE
                       ,pr_dtopcio2       IN crapsde.dsdatop2%TYPE
                       ,pr_dsobserv       IN crapsde.dsobserv%TYPE
                       ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                       ,pr_flatueap       IN INTEGER               --> Sinaliza que deve atualizar crapeap  
                       ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro       OUT VARCHAR2);
END WPGD0054;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0054 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0054
  --  Sistema  : Rotinas para tela de Envio de Sugestoes
  --  Sigla    : WPGD
  --  Autor    : Vanessa
  --  Data     : Outubro/2015.                   Ultima atualizacao: 02/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Seleção de Eventos.
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0054
  PROCEDURE pc_envia_sugestao(pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                             ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Agencia
                             ,pr_dtanoage       IN crapppc.dtanoage%TYPE --> Ano Agenda
                             ,pr_txsugest       IN VARCHAR2              --> Texto
                             ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                             ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro       OUT VARCHAR2) IS         --> Descricao do Erro

  
   -- Consulta de eventos por cooperativa
      CURSOR cr_crapppc IS
             SELECT ppc.idevento
                   ,ppc.cdcooper
                   ,ppc.qtevedia
                   ,ppc.cdoperad
                   ,ppc.cdprogra
                   ,ppc.dtatuali 
                   ,ppc.dsemlcto  
                   ,ppc.dtanoage 
                   ,ppc.vlaluloc
                   ,ppc.vlporali
                   ,ppc.vlporqui                             
              FROM crapppc ppc                 
             WHERE ppc.cdcooper = pr_cdcooper
               AND ppc.dtanoage = pr_dtanoage;

      rw_crapppc cr_crapppc%ROWTYPE;    
      
      CURSOR cr_crapage IS
             SELECT age.cdagenci
                   ,age.nmresage
               FROM crapage age
              WHERE age.cdcooper = NVL(pr_cdcooper,age.cdcooper)
                AND age.cdagenci = NVL(pr_cdagenci,age.cdagenci);
      rw_crapage cr_crapage%ROWTYPE;  
      
      CURSOR cr_crapope IS
             SELECT ope.cdoperad
                    ,ope.nmoperad
               FROM crapope ope
              WHERE ope.cdcooper = NVL(pr_cdcooper,ope.cdcooper)
                AND ope.cdoperad = NVL(pr_cdoperad,ope.cdoperad);
      rw_crapope cr_crapope%ROWTYPE; 
      
      CURSOR cr_crapcop IS
             SELECT cop.nmrescop
               FROM crapcop cop
              WHERE cop.cdcooper = NVL(pr_cdcooper,cop.cdcooper);
      rw_crapcop cr_crapcop%ROWTYPE;    
             
       -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100):='wpgd0104';
      vr_nmdeacao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idsistem INTEGER;
      -- controle de registro na crapppc        
      vr_controle BOOLEAN DEFAULT FALSE;

      -- Variáveis locais
       vr_conteudo   VARCHAR2(4000); 

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
  
      OPEN cr_crapage;
      FETCH cr_crapage INTO rw_crapage;
      CLOSE cr_crapage;
      
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
     
      OPEN cr_crapope;
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;
    
      FOR rw_crapppc IN cr_crapppc LOOP

         vr_controle := TRUE;
         
         IF trim(rw_crapppc.dsemlcto) = '' OR rw_crapppc.dsemlcto IS NULL THEN
            vr_dscritic := 'Email para envio da sugestão não cadastrado. Favor solicitar o cadastro e enviar novamente';
            RAISE vr_exc_saida;       
                  
         ELSE --Envia email 
             vr_conteudo := '<b>Agenda:</b>      '|| pr_dtanoage ||'
                             <br><b>Cooperativa:</b> '|| pr_cdcooper ||  ' - ' || rw_crapcop.nmrescop ||'
                             <br><b>PA:</b>          '|| rw_crapage.cdagenci ||' - ' || rw_crapage.nmresage ||'
                             <br><b>Operador:</b>    '|| rw_crapope.cdoperad ||' - ' || rw_crapope.nmoperad||'
                             <br><b>Sugestão:</b><br>'|| REPLACE(pr_txsugest,'#br','<br>') ||'.';
                             
                               
             gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                        ,pr_cdprogra        => 'INTERNET'
                                        ,pr_des_destino     => rw_crapppc.dsemlcto
                                        ,pr_des_assunto     => 'Sugestão: Tela de Seleção de Eventos'
                                        ,pr_des_corpo       => vr_conteudo
                                        ,pr_des_anexo       => NULL--> nao envia anexo, anexo esta disponivel no dir conf. geracao do arq.
                                        ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);

              -- Se houver erros
              IF vr_dscritic IS NOT NULL THEN
                -- Gera critica
                vr_cdcritic := 0;
                RAISE vr_exc_saida;
              END IF;

             
         END IF;   
        
      END LOOP;
      
      IF vr_controle = FALSE THEN
        vr_dscritic := 'Email para envio da sugestão não cadastrado. Favor solicitar o cadastro e enviar novamente.';
        RAISE vr_exc_saida;               
      END IF;

     COMMIT;         
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
        pr_dscritic := 'Erro geral em PC_WPGD0054: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_envia_sugestao;
  
  PROCEDURE pc_crapsde(pr_cddopcao        IN VARCHAR2              --> Tipo de acao que sera executada (A - Alteracao / C - Consulta / E - Exclur / I - Inclur)
                       ,pr_idevento       IN crapsde.idevento%TYPE              
                       ,pr_cdcooper       IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_cdagenci       IN crapage.cdagenci%TYPE --> Codigo da Cooperativa
                       ,pr_dtanoage       IN crapppc.dtanoage%TYPE --> Ano Agenda
                       ,pr_cdevento       IN VARCHAR2              --> Texto
                       ,pr_nrocoeve       IN crapsde.nrocoeve%TYPE
                       ,pr_dtdesaja       IN crapsde.dsdatsug%TYPE
                       ,pr_hrinicio       IN VARCHAR2
                       ,pr_dtopcio1       IN crapsde.dsdatop1%TYPE
                       ,pr_dtopcio2       IN crapsde.dsdatop2%TYPE
                       ,pr_dsobserv       IN crapsde.dsobserv%TYPE
                       ,pr_cdoperad       IN crapppc.cdoperad%TYPE
                       ,pr_flatueap       IN INTEGER               --> Sinaliza que deve atualizar crapeap  (1- atualiza,0-nao)
                       ,pr_xmllog         IN VARCHAR2              --> XML com informações de LOG
                       ,pr_cdcritic       OUT PLS_INTEGER          --> Código da crítica
                       ,pr_dscritic       OUT VARCHAR2             --> Descrição da crítica
                       ,pr_retxml         IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo       OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro       OUT VARCHAR2) IS
                               
        
      CURSOR cr_crapsde IS
             SELECT sde.cdcooper
                   ,sde.cdagenci
                   ,sde.dtanoage
                   ,sde.idevento
                   ,sde.cdevento
                   ,sde.nrocoeve
                   ,sde.dsdatsug
                   ,sde.hrsugini
                   ,sde.dsdatop1
                   ,sde.dsdatop2
                   ,sde.dsobserv 
               FROM crapsde sde
              WHERE sde.idevento = pr_idevento
                AND sde.cdcooper = pr_cdcooper
                AND sde.cdagenci = pr_cdagenci
                AND sde.dtanoage = pr_dtanoage
                AND sde.cdevento = pr_cdevento;
                   
      rw_crapsde cr_crapsde%ROWTYPE; 
      
      --> Buscar a quantidade de eventos
      CURSOR cr_crapsde_count IS
             SELECT count(sde.cdcooper)                   
               FROM crapsde sde
              WHERE sde.idevento = pr_idevento
                AND sde.cdcooper = pr_cdcooper
                AND sde.cdagenci = pr_cdagenci
                AND sde.dtanoage = pr_dtanoage
                AND sde.cdevento = pr_cdevento;   
      
       CURSOR cr_gnpapgd IS
             SELECT pgd.lsmesint
                   ,pgd.lsmeseve 
               FROM gnpapgd pgd
              WHERE pgd.idevento = pr_idevento
                AND pgd.cdcooper = pr_cdcooper
                AND pgd.dtanoage = pr_dtanoage;
                   
      rw_gnpapgd cr_gnpapgd%ROWTYPE;    
             
       -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_nmdatela VARCHAR2(100):='wpgd0104';
      vr_nmdeacao VARCHAR2(100);
      vr_idcokses VARCHAR2(100);
      vr_cddopcao VARCHAR2(100);
      vr_idsistem INTEGER;

      -- Variáveis locais
      vr_conteudo   VARCHAR2(4000);
      vr_contador PLS_INTEGER := 0;
      vr_lsmesint VARCHAR2(4000) := '';
      vr_lsmeseve VARCHAR2(4000) := '';
      vr_nrocoeve INTEGER;  
      vr_atualiza INTEGER;    
      vr_qtocoeve INTEGER;
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
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
       
         -- Verifica o tipo de acao que sera executada
         CASE pr_cddopcao 
          WHEN 'E' THEN -- Exibe 
           
              pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');
              
              FOR rw_crapsde IN cr_crapsde LOOP
                                                                                                                 
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapsde.idevento, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapsde.dtanoage, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapsde.cdcooper, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrocoeve', pr_tag_cont => rw_crapsde.nrocoeve, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdatsug', pr_tag_cont => rw_crapsde.dsdatsug, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'hrsugini', pr_tag_cont => rw_crapsde.hrsugini, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdatop1', pr_tag_cont => rw_crapsde.dsdatop1, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdatop2', pr_tag_cont => rw_crapsde.dsdatop2, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsobserv', pr_tag_cont => rw_crapsde.dsobserv, pr_des_erro => vr_dscritic);
                  
                  vr_contador := vr_contador + 1;   
              END LOOP;
              
              OPEN cr_gnpapgd;
              FETCH cr_gnpapgd INTO rw_gnpapgd;
             
              
              IF cr_gnpapgd%FOUND THEN
                 GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                 GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'lsmeseve', pr_tag_cont => rw_gnpapgd.lsmeseve, pr_des_erro => vr_dscritic);
                 GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'lsmesint', pr_tag_cont => rw_gnpapgd.lsmesint, pr_des_erro => vr_dscritic);
                
              END IF;
              CLOSE cr_gnpapgd; 
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_contador , pr_des_erro => vr_dscritic);
           WHEN 'I' THEN -- Inclui e altera
               BEGIN
                UPDATE crapsde sde
                   SET dsdatsug = pr_dtdesaja
                      ,hrsugini = pr_hrinicio
                      ,dsdatop1 = pr_dtopcio1
                      ,dsdatop2 = pr_dtopcio2
                      ,dsobserv = pr_dsobserv
                      ,cdoperad = pr_cdoperad
                      ,dtatuali = SYSDATE
                      ,cdcopope = vr_cdcooper               
                  WHERE sde.idevento = pr_idevento
                    AND sde.cdcooper = pr_cdcooper
                    AND sde.cdagenci = pr_cdagenci
                    AND sde.dtanoage = pr_dtanoage
                    AND sde.cdevento = pr_cdevento
                    AND sde.nrocoeve = pr_nrocoeve;

                 IF SQL%ROWCOUNT = 0 THEN
                     BEGIN
                        INSERT INTO
                            crapsde(idevento
                                   ,cdcooper
                                   ,dtanoage
                                   ,cdevento
                                   ,cdagenci
                                   ,nrocoeve
                                   ,dsdatsug
                                   ,hrsugini
                                   ,dsdatop1
                                   ,dsdatop2
                                   ,dsobserv
                                   ,cdoperad
                                   ,cdprogra
                                   ,dtatuali
                                   ,cdcopope 
                            )VALUES(pr_idevento
                                   ,pr_cdcooper
                                   ,pr_dtanoage
                                   ,pr_cdevento
                                   ,pr_cdagenci
                                   ,pr_nrocoeve
                                   ,pr_dtdesaja
                                   ,pr_hrinicio
                                   ,pr_dtopcio1
                                   ,pr_dtopcio2
                                   ,pr_dsobserv
                                   ,pr_cdoperad
                                   ,'WPGD0054'
                                   ,SYSDATE
                                   ,vr_cdcooper);
                                 
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir registro. Erro: ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                 END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atulizar registro. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
           WHEN 'D' THEN -- Deleta
             BEGIN
              vr_atualiza := (pr_nrocoeve+1);   
             /* SELECT COUNT(0) INTO vr_nrocoeve 
                      FROM crapsde sde  
                  WHERE sde.idevento = pr_idevento
                    AND sde.cdcooper = pr_cdcooper
                    AND sde.cdagenci = pr_cdagenci
                    AND sde.dtanoage = pr_dtanoage
                    AND sde.cdevento = pr_cdevento;*/
              DELETE crapsde sde
                WHERE sde.idevento = pr_idevento
                    AND sde.cdcooper = pr_cdcooper
                    AND sde.cdagenci = pr_cdagenci
                    AND sde.dtanoage = pr_dtanoage
                    AND sde.cdevento = pr_cdevento
                    AND sde.nrocoeve = pr_nrocoeve;
              
              -- Atualizar o sequencial da tabela crapsde
              OPEN cr_crapsde_count;
              FETCH cr_crapsde_count INTO vr_qtocoeve;
              CLOSE cr_crapsde_count;
             
              --> atualizar apartir do registro excluido
              FOR vr_nrconatu IN pr_nrocoeve..vr_qtocoeve LOOP                      
                  UPDATE crapsde sde
                     SET sde.nrocoeve = vr_nrconatu
                   WHERE sde.idevento = pr_idevento
                     AND sde.cdcooper = pr_cdcooper
                     AND sde.cdagenci = pr_cdagenci
                     AND sde.dtanoage = pr_dtanoage
                     AND sde.cdevento = pr_cdevento
                     AND sde.nrocoeve = vr_atualiza;
                     vr_atualiza := vr_atualiza +1;
              END LOOP;
              
            EXCEPTION
              WHEN OTHERS THEN
                -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao excluir a Sugestão.'||sqlerrm ;
                RAISE vr_exc_saida;
            END;
              
           END CASE;
           
           --> se for inclusao ou deleção
           -- é necessario atualizar o Eventos da agenda progrid
           IF pr_cddopcao IN ('I','D') AND pr_flatueap = 1 THEN
             vr_qtocoeve := 0;
             
             -- buscar quantidade total
             OPEN cr_crapsde_count;
             FETCH cr_crapsde_count INTO vr_qtocoeve;
             CLOSE cr_crapsde_count;
             
             BEGIN
               UPDATE crapeap eap
                  SET eap.qtocoeve = nvl(vr_qtocoeve,0)
                WHERE eap.idevento = pr_idevento
                  AND eap.cdcooper = pr_cdcooper
                  AND eap.dtanoage = pr_dtanoage
                  AND eap.cdevento = pr_cdevento 
                  AND eap.cdagenci = pr_cdagenci;
             EXCEPTION 
               WHEN OTHERS THEN
                 -- Descricao do erro na exclusao de registros
                vr_dscritic := 'Erro ao atualizar a Eventos da agenda progrid.'||sqlerrm ;
                RAISE vr_exc_saida;
             END;
           
           END IF;           
              
       COMMIT;         
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
            pr_dscritic := 'Erro geral em PC_WPGD0054: ' || SQLERRM;

            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                                                                           
  
  END pc_crapsde;
END WPGD0054;
/
