CREATE OR REPLACE PACKAGE PROGRID.WPGD0104 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0104                     
  --  Sistema  : Rotinas para tela de Parametros do Progrid
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Setembro/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para Parametros por Cooperativa e Regional.
  --
  -- Alteracoes:
  --
  -- Alteracoes: 12/04/2016 - Correcao no cursor cr_crapage para filtrar apenas agencias
  --                          com a flag (flgdopgd) de utilizacao do Progrid igual a SIM
  --                          (Carlos Rafael Tanholi).  
  --
  --             14/04/2016 - Correcao nas condicoes de Exclusao de parametros por Cooperativa 
  --                          e na exclusao de parametros por PA e parametros por regional
  --                          para consistir o filtro de ano informado em tela.(Carlos Rafael Tanholi).
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0104
  PROCEDURE pc_WPGD0104(pr_idevento IN crapppc.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembl�ia)	
                       ,pr_abaselec IN INTEGER               --> Aba selecionada(0 = Cooperativa / 1 = Regional / 2 = PA)
                       ,pr_cdcooper IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da cooperativa
                       ,pr_cddregio IN crapppr.cddregio%TYPE --> Codigo da Regional
                       ,pr_dsdregio IN crapreg.dsdregio%TYPE --> Nome da regional
                       ,pr_cdagenci IN crapppa.cdagenci%TYPE --> Codigo do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA
                       ,pr_dtanoage IN crapppc.dtanoage%TYPE --> Ano da Agenda                       
                       ,pr_qtmineve IN crapppa.qtmineve%TYPE --> Qtd minima de dias de eventos
                       ,pr_qtevedia IN crapppc.qtevedia%TYPE --> Qtd dias de evento
                       ,pr_vlaluloc IN crapppc.vlaluloc%TYPE --> Valor do local
                       ,pr_vlporali IN crapppc.vlporali%TYPE --> Valor de alimenta��o
                       ,pr_vlporqui IN crapppc.vlporqui%TYPE --> Valor por KM
                       ,pr_dsemlcto IN crapppc.dsemlcto%TYPE --> Email de contato
                       ,pr_dsemllib IN crapppc.dsemllib%TYPE --> Email de liberacao agenda
                       ,pr_cdeixtem IN crapppe.cdeixtem%TYPE --> Codigo do Eixo Tematico
                       ,pr_dseixtem IN gnapetp.dseixtem%TYPE --> Descricao do Eixo Tematico 
                       ,pr_listagem IN VARCHAR2              --> Listagem de Eixo Tematico (S/N)
                       ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                       ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);           --> Descricao do Erro
 
END WPGD0104;
/
CREATE OR REPLACE PACKAGE BODY PROGRID.WPGD0104 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : WPGD0104
  --  Sistema  : Rotinas para tela de Recursos
  --  Sigla    : WPGD
  --  Autor    : Jean Michel
  --  Data     : Setembro/2015.                   Ultima atualizacao: 14/04/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para tela de Recursos.
  --
  -- Alteracoes: 12/04/2016 - Correcao no cursor cr_crapage para filtrar apenas agencias
  --                          com a flag (flgdopgd) de utilizacao do Progrid igual a SIM
  --                          (Carlos Rafael Tanholi).  
  --
  --             14/04/2016 - Correcao nas condicoes de Exclusao de parametros por Cooperativa 
  --                          e na exclusao de parametros por PA e parametros por regional
  --                          para consistir o filtro de ano informado em tela.(Carlos Rafael Tanholi).
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Rotina geral de insert, update, select e delete da tela WPGD0104
  PROCEDURE pc_wpgd0104(pr_idevento IN crapppc.idevento%TYPE --> Identificador de Evento(1 - Progrid / 2 - Assembl�ia)	
                       ,pr_abaselec IN INTEGER               --> Aba selecionada(0 = Cooperativa / 1 = Regional / 2 = PA)
                       ,pr_cdcooper IN crapppc.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_nmrescop IN crapcop.nmrescop%TYPE --> Nome da cooperativa
                       ,pr_cddregio IN crapppr.cddregio%TYPE --> Codigo da Regional
                       ,pr_dsdregio IN crapreg.dsdregio%TYPE --> Nome da regional
                       ,pr_cdagenci IN crapppa.cdagenci%TYPE --> Codigo do PA
                       ,pr_nmresage IN crapage.nmresage%TYPE --> Nome do PA
                       ,pr_dtanoage IN crapppc.dtanoage%TYPE --> Ano da Agenda                       
                       ,pr_qtmineve IN crapppa.qtmineve%TYPE --> Qtd minima de dias de eventos
                       ,pr_qtevedia IN crapppc.qtevedia%TYPE --> Qtd dias de evento
                       ,pr_vlaluloc IN crapppc.vlaluloc%TYPE --> Valor do local
                       ,pr_vlporali IN crapppc.vlporali%TYPE --> Valor de alimenta��o
                       ,pr_vlporqui IN crapppc.vlporqui%TYPE --> Valor por KM
                       ,pr_dsemlcto IN crapppc.dsemlcto%TYPE --> Email de contato
                       ,pr_dsemllib IN crapppc.dsemllib%TYPE --> Email de liberacao agenda                       
                       ,pr_cdeixtem IN crapppe.cdeixtem%TYPE --> Codigo do Eixo Tematico 
                       ,pr_dseixtem IN gnapetp.dseixtem%TYPE --> Descricao do Eixo Tematico 
                       ,pr_listagem IN VARCHAR2              --> Listagem de Eixo Tematico (S/N)
                       ,pr_nriniseq IN PLS_INTEGER           --> Registro inicial para pesquisa
                       ,pr_qtregist IN PLS_INTEGER           --> Quantidade de registros por pesquisa
                       ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                       ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                       ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro

      -- CURSORES                 
      -- Consulta de eventos por cooperativa
      CURSOR cr_crapppc IS
             SELECT ppc.idevento
                   ,ppc.cdcooper
                   ,cop.nmrescop
                   ,ppc.qtevedia
                   ,ppc.cdoperad
                   ,ppc.cdprogra
                   ,ppc.dtatuali 
                   ,ppc.dsemlcto 
                   ,ppc.dsemllib 
                   ,ppc.dtanoage 
                   ,ppc.vlaluloc
                   ,ppc.vlporali
                   ,ppc.vlporqui 
                   ,ROW_NUMBER() OVER(ORDER BY ppc.dtanoage DESC, cop.nmrescop ASC) nrdseque           
              FROM crapppc ppc
                  ,crapcop cop
             WHERE ppc.cdcooper = cop.cdcooper 
               AND ppc.idevento = NVL(pr_idevento,idevento)
               AND ppc.cdcooper = NVL(pr_cdcooper,ppc.cdcooper)
               AND ppc.dtanoage = NVL(pr_dtanoage,dtanoage)
               AND (cop.nmrescop LIKE('%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL)
          ORDER BY ppc.dtanoage DESC, cop.nmrescop ASC;

      rw_crapppc cr_crapppc%ROWTYPE;
         
      -- Consulta de eventos por regional
      CURSOR cr_crapppr IS
        SELECT ppr.idevento
              ,ppr.cdcooper
              ,cop.nmrescop
              ,ppr.cddregio
              ,reg.dsdregio
              ,ppr.qtevedia
              ,ppr.cdoperad
              ,ppr.cdprogra
              ,ppr.dtatuali 
              ,ppr.dtanoage 
              ,ppr.vlaluloc
              ,ppr.vlporali
              ,ROW_NUMBER() OVER(ORDER BY ppr.cdcooper, ppr.cddregio,ppr.dtanoage) nrdseque              
         FROM crapppr ppr
             ,crapcop cop
             ,crapreg reg
        WHERE ppr.cdcooper = cop.cdcooper
          AND cop.cdcooper = reg.cdcooper
          AND ppr.cddregio = reg.cddregio
          AND ppr.idevento = NVL(pr_idevento,idevento)
          AND ppr.cdcooper = NVL(pr_cdcooper,ppr.cdcooper)
          AND ppr.cddregio = NVL(pr_cddregio,ppr.cddregio)
          AND ppr.dtanoage = NVL(pr_dtanoage,dtanoage)
          AND (cop.nmrescop LIKE('%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL)
          AND (reg.dsdregio LIKE('%' || UPPER(pr_dsdregio) || '%') OR pr_dsdregio IS NULL)
          ORDER BY ppr.dtanoage DESC, cop.nmrescop asc, reg.dsdregio ASC;

      rw_crapppr cr_crapppr%ROWTYPE;
    
      -- Consulta de eventos por PA
      CURSOR cr_crapppa IS
        SELECT ppa.idevento
              ,ppa.cdcooper
              ,cop.nmrescop
              ,ppa.cdagenci
              ,age.nmresage
              ,ppa.qtmineve
              ,ppa.cdoperad
              ,ppa.cdprogra
              ,ppa.dtatuali
              ,ppa.dtanoage 
              ,ppa.vlaluloc
              ,ppa.vlporali 
              ,ROW_NUMBER() OVER(ORDER BY ppa.dtanoage DESC, cop.nmrescop ASC,TRIM(age.nmresage) ASC) nrdseque
         FROM crapppa ppa
             ,crapcop cop
             ,crapage age
        WHERE ppa.cdcooper = cop.cdcooper
          AND cop.cdcooper = age.cdcooper
          AND ppa.cdagenci = age.cdagenci
          AND ppa.idevento = NVL(pr_idevento,ppa.idevento)
          AND ppa.cdcooper = NVL(pr_cdcooper,ppa.cdcooper)
          AND ppa.cdagenci = NVL(pr_cdagenci,ppa.cdagenci)
          AND ppa.dtanoage = NVL(pr_dtanoage,dtanoage)
          AND (cop.nmrescop LIKE('%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL)
          AND (age.nmresage LIKE('%' || UPPER(pr_nmresage) || '%') OR pr_nmresage IS NULL)
     ORDER BY ppa.dtanoage DESC, cop.nmrescop ASC, TRIM(age.nmresage) ASC;

      rw_crapppa cr_crapppa%ROWTYPE;
     -- Consulta de eventos por Eixo
      CURSOR cr_crapppe IS
        SELECT ppe.idevento
              ,ppe.dtanoage
              ,ppe.cdcooper
              ,cop.nmrescop
              ,ppe.cdeixtem
              ,etp.dseixtem
              ,ppe.qtmineve
              ,ppe.cdoperad
              ,ppe.cdprogra
              ,ppe.dtatuali
              ,ROW_NUMBER() OVER(ORDER BY ppe.dtanoage DESC, ppe.cdcooper ASC,  etp.dseixtem ASC) nrdseque
         FROM crapppe ppe
             ,crapcop cop
             ,gnapetp etp 
        WHERE ppe.cdcooper = cop.cdcooper
          AND ppe.cdeixtem = etp.cdeixtem
          AND ppe.idevento = NVL(pr_idevento,ppe.idevento)
          AND ppe.cdcooper = NVL(pr_cdcooper,ppe.cdcooper)
          AND ppe.cdeixtem = NVL(pr_cdeixtem,ppe.cdeixtem)
          AND ppe.dtanoage = NVL(pr_dtanoage,ppe.dtanoage)
          AND (cop.nmrescop LIKE('%' || UPPER(pr_nmrescop) || '%') OR pr_nmrescop IS NULL)
          AND (etp.dseixtem LIKE('%' || UPPER(pr_dseixtem) || '%') OR pr_dseixtem IS NULL)
        ORDER BY ppe.dtanoage DESC, cop.nmrescop ASC,  etp.dseixtem ASC;

      rw_crapppe cr_crapppe%ROWTYPE;
  
      -- Consulta de PA por cooperativas
      CURSOR cr_crapage IS
        SELECT age.cdcooper
              ,age.cdagenci 
         FROM crapage age
        WHERE age.cdcooper = NVL(pr_cdcooper,age.cdcooper)
          AND (age.cdagenci = pr_cdagenci OR pr_cdagenci = 0)
          AND age.cdagenci NOT IN(90,91)
          AND age.flgdopgd = 1          
      ORDER BY age.cdcooper, age.nmresage;
      
      rw_crapage cr_crapage%ROWTYPE;
    
      -- Consulta Eixo Tematico
      CURSOR cr_gnapetp IS
        SELECT etp.idevento
              ,etp.cdcooper
              ,etp.cdeixtem
              ,etp.dseixtem
              ,etp.flgativo
          FROM gnapetp etp
         WHERE etp.flgativo = 1;

      rw_gnapetp cr_gnapetp%ROWTYPE;

      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE := 1;
      vr_cdoperad crapope.cdoperad%TYPE := '1';
      vr_nmdatela VARCHAR2(100):='WPGD0104';
      vr_nmdeacao VARCHAR2(100) := 'A';
      vr_idcokses VARCHAR2(100) := '';
      vr_cddopcao VARCHAR2(100) := 'A';
      vr_idsistem INTEGER;

      -- Vari�veis locais
      vr_contador PLS_INTEGER := 0;
      vr_totregis PLS_INTEGER := 0;

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
      
      IF pr_listagem = 'N' THEN
        -- Verifica qual aba foi selecionada
        IF pr_abaselec = 0 THEN -- Cooperativa

          -- Verifica o tipo de acao que sera executada
          CASE vr_cddopcao

            WHEN 'A' THEN -- Alteracao

              BEGIN
                UPDATE crapppc
                   SET crapppc.qtevedia = pr_qtevedia
                      ,crapppc.vlaluloc = pr_vlaluloc
                      ,crapppc.vlporali = pr_vlporali
                      ,crapppc.vlporqui = pr_vlporqui
                      ,crapppc.dsemlcto = pr_dsemlcto
                      ,crapppc.dsemllib = pr_dsemllib
                      ,crapppc.dtatuali = SYSDATE
                      ,cdcopope = vr_cdcooper   
                 WHERE crapppc.cdcooper = pr_cdcooper
                   AND crapppc.dtanoage = pr_dtanoage;

                 IF SQL%ROWCOUNT = 0 THEN
                     BEGIN
                        INSERT INTO
                            crapppc(idevento
                                   ,dtanoage
                                   ,qtevedia
                                   ,vlaluloc
                                   ,vlporali
                                   ,vlporqui
                                   ,cdcooper
                                   ,cdoperad
                                   ,cdprogra
                                   ,dtatuali
                                   ,dsemlcto
                                   ,dsemllib
                                   ,cdcopope  
                            )VALUES(pr_idevento
                                   ,pr_dtanoage
                                   ,pr_qtevedia
                                   ,pr_vlaluloc
                                   ,pr_vlporali
                                   ,pr_vlporqui
                                   ,pr_cdcooper
                                   ,vr_cdoperad
                                   ,vr_nmdatela
                                   ,SYSDATE
                                   ,pr_dsemlcto
                                   ,pr_dsemllib
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

            WHEN 'C' THEN -- Consulta
              -- Criar cabe�alho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

              FOR rw_crapppc IN cr_crapppc LOOP
                     
                IF ((pr_nriniseq <= rw_crapppc.nrdseque)AND (rw_crapppc.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                   
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapppc.idevento                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapppc.cdcooper                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapppc.nmrescop                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsemlcto', pr_tag_cont => rw_crapppc.dsemlcto                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsemllib', pr_tag_cont => rw_crapppc.dsemllib                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtevedia', pr_tag_cont => rw_crapppc.qtevedia                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapppc.cdoperad                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crapppc.cdprogra                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapppc.dtanoage                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => TO_CHAR(rw_crapppc.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlaluloc', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppc.vlaluloc,'fm999G990D00'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlporali', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppc.vlporali,'fm999G990D00'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlporqui', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppc.vlporqui,'fm999G990D00'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);
                  vr_contador := vr_contador + 1;
                END IF;

                vr_totregis := vr_totregis +1;

              END LOOP;

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

            WHEN 'E' THEN -- Exclusao

              BEGIN
                DELETE FROM crapppc WHERE crapppc.cdcooper = pr_cdcooper AND crapppc.dtanoage = pr_dtanoage;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir registro. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;

          END CASE;

        ELSIF pr_abaselec = 1 THEN -- Regional

          -- Verifica o tipo de acao que sera executada
          CASE vr_cddopcao
            WHEN 'A' THEN -- Alteracao

              BEGIN
                UPDATE crapppr
                   SET crapppr.qtevedia = pr_qtevedia
                      ,crapppr.vlaluloc = pr_vlaluloc
                      ,crapppr.vlporali = pr_vlporali
                      ,crapppr.cdcopope = vr_cdcooper  
                      ,crapppr.dtatuali = SYSDATE 
                 WHERE crapppr.cdcooper = pr_cdcooper
                   AND crapppr.cddregio = pr_cddregio
                   AND crapppr.dtanoage = pr_dtanoage;

                IF SQL%ROWCOUNT = 0 THEN
                  BEGIN
                    INSERT INTO
                        crapppr(idevento
                               ,dtanoage
                               ,qtevedia
                               ,vlaluloc
                               ,vlporali
                               ,cdcooper
                               ,cddregio
                               ,cdoperad
                               ,cdprogra
                               ,dtatuali
                               ,cdcopope)
                         VALUES(pr_idevento
                               ,pr_dtanoage
                               ,pr_qtevedia
                               ,pr_vlaluloc
                               ,pr_vlporali
                               ,pr_cdcooper
                               ,pr_cddregio
                               ,vr_cdoperad
                               ,vr_nmdatela
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

            WHEN 'C' THEN -- Consulta
              -- Criar cabe�alho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

              FOR rw_crapppr IN cr_crapppr LOOP
                    
                IF ((pr_nriniseq <= rw_crapppr.nrdseque)AND (rw_crapppr.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                    
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapppr.idevento                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapppr.dtanoage                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapppr.cdcooper                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapppr.nmrescop                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cddregio', pr_tag_cont => rw_crapppr.cddregio                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dsdregio', pr_tag_cont => rw_crapppr.dsdregio                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtevedia', pr_tag_cont => rw_crapppr.qtevedia                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapppr.cdoperad                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crapppr.cdprogra                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => to_char(rw_crapppr.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlaluloc', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppr.vlaluloc,'fm999G999D90'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlporali', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppr.vlporali,'fm999G999D90'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);
                  vr_contador := vr_contador + 1;
                END IF;

                vr_totregis := vr_totregis +1;

              END LOOP;

              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

            WHEN 'E' THEN -- Exclusao
              BEGIN
                DELETE FROM crapppr WHERE crapppr.cdcooper = pr_cdcooper AND crapppr.cddregio = pr_cddregio AND crapppr.dtanoage = pr_dtanoage;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao excluir registro. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
          END CASE;
        ELSIF pr_abaselec = 2 THEN -- PA

          -- Verifica o tipo de acao que sera executada
          CASE vr_cddopcao
            WHEN 'A' THEN -- Alteracao
              -- Verifica se foram selecionados todos os PA's
              IF pr_cdagenci = 0 THEN

                -- Loop sobre os PA's
                FOR rw_crapage IN cr_crapage LOOP

                  -- Atualiza registro
                  BEGIN
                    UPDATE crapppa
                       SET crapppa.qtmineve = pr_qtmineve
                          ,crapppa.vlaluloc = pr_vlaluloc
                          ,crapppa.vlporali = pr_vlporali
                          ,crapppa.cdoperad = vr_cdoperad
                          ,crapppa.dtatuali = SYSDATE
                          ,crapppa.cdcopope = vr_cdcooper 
                     WHERE crapppa.idevento = pr_idevento
                       AND crapppa.cdcooper = pr_cdcooper
                       AND crapppa.cdagenci = rw_crapage.cdagenci
                       AND crapppa.dtanoage = pr_dtanoage;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Problema ao atualizar registro CRAPPPA, PA: ' || TO_CHAR(rw_crapage.cdagenci) || '. Erro: ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  IF SQL%ROWCOUNT = 0 THEN    
                    -- Insere registro
                    BEGIN
                      INSERT INTO
                          crapppa(qtmineve
                                 ,vlaluloc
                                 ,vlporali
                                 ,dtanoage
                                 ,idevento
                                 ,cdcooper
                                 ,cdagenci
                                 ,cdoperad
                                 ,cdprogra
                                 ,dtatuali
                                 ,cdcopope
                          )VALUES(pr_qtmineve
                                 ,pr_vlaluloc
                                 ,pr_vlporali
                                 ,pr_dtanoage
                                 ,pr_idevento
                                 ,pr_cdcooper
                                 ,rw_crapage.cdagenci
                                 ,vr_cdoperad
                                 ,vr_nmdatela
                                 ,SYSDATE
                                 ,vr_cdcooper);

                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Problema ao inserir registro CRAPPPA, PA: ' || TO_CHAR(rw_crapage.cdagenci) || '. Erro: ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;

                  END IF;

                END LOOP;
                    
              ELSE

                -- Atualiza registro
                BEGIN
                  UPDATE crapppa
                     SET crapppa.qtmineve = pr_qtmineve
                        ,crapppa.vlaluloc = pr_vlaluloc
                        ,crapppa.vlporali = pr_vlporali
                        ,crapppa.cdoperad = vr_cdoperad
                        ,crapppa.dtatuali = SYSDATE
                        ,crapppa.cdcopope = vr_cdcooper 
                   WHERE crapppa.idevento = pr_idevento
                     AND crapppa.cdcooper = pr_cdcooper
                     AND crapppa.cdagenci = pr_cdagenci
                     AND crapppa.dtanoage = pr_dtanoage;
              		
                  IF SQL%ROWCOUNT = 0 THEN    
                    -- Insere registro
                    BEGIN
                      INSERT INTO
                          crapppa(qtmineve
                                 ,vlaluloc
                                 ,vlporali
                                 ,dtanoage
                                 ,idevento
                                 ,cdcooper
                                 ,cdagenci
                                 ,cdoperad
                                 ,cdprogra
                                 ,dtatuali
                                 ,cdcopope
                          )VALUES(pr_qtmineve
                                 ,pr_vlaluloc
                                 ,pr_vlporali
                                 ,pr_dtanoage
                                 ,pr_idevento
                                 ,pr_cdcooper
                                 ,pr_cdagenci
                                 ,vr_cdoperad
                                 ,vr_nmdatela
                                 ,SYSDATE
                                 ,vr_cdcooper);

                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Problema ao inserir registro CRAPPPA, PA: ' || TO_CHAR(rw_crapage.cdagenci) || '. Erro: ' || SQLERRM;
                        RAISE vr_exc_saida;
                    END;

                  END IF;
    
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao atualizar registro CRAPPPA. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;

              END IF;

            WHEN 'C' THEN -- Consulta
              -- Criar cabe�alho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

              FOR rw_crapppa IN cr_crapppa LOOP
                 
                IF ((pr_nriniseq <= rw_crapppa.nrdseque)AND (rw_crapppa.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                       
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapppa.idevento                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapppa.dtanoage                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapppa.cdcooper                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapppa.nmrescop                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdagenci', pr_tag_cont => rw_crapppa.cdagenci                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmresage', pr_tag_cont => rw_crapppa.nmresage                       , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtmineve', pr_tag_cont => rw_crapppa.qtmineve                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapppa.cdoperad                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdprogra', pr_tag_cont => rw_crapppa.cdprogra                       , pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => to_char(rw_crapppa.dtatuali,'dd/mm/yyyy') , pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlaluloc', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppa.vlaluloc,'fm999G999D90'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlporali', pr_tag_cont => replace(replace(replace(TO_CHAR(rw_crapppa.vlporali,'fm999G999D90'),'.','#'),',','.'),'#',','),pr_des_erro => vr_dscritic);
                  vr_contador := vr_contador + 1;
                END IF;

                vr_totregis := vr_totregis +1;

              END LOOP;
             
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

            WHEN 'E' THEN -- Exclusao
              -- Verifica se foram selecionados todos os PA's
              IF pr_cdagenci = 0 THEN

                -- Efetua a exclus�o de registros
                BEGIN
                  DELETE crapppa WHERE crapppa.cdcooper = pr_cdcooper AND crapppa.dtanoage = pr_dtanoage;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao excluir registro CRAPPPA. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;

              ELSE

                -- Efetua a exclus�o de registros
                BEGIN
                  DELETE crapppa WHERE crapppa.cdcooper = pr_cdcooper AND crapppa.cdagenci = pr_cdagenci AND crapppa.dtanoage = pr_dtanoage;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Problema ao excluir registro CRAPPPA. Erro: ' || SQLERRM;
                    RAISE vr_exc_saida;
                END;

              END IF;
          END CASE;
        ELSIF pr_abaselec = 3 THEN -- EIXO

          -- Verifica o tipo de acao que sera executada
          CASE vr_cddopcao
            WHEN 'A' THEN -- Alteracao

              -- Atualiza registro
              BEGIN
                UPDATE crapppe
                   SET crapppe.idevento = pr_idevento
                      ,crapppe.dtanoage = pr_dtanoage
                      ,crapppe.cdcooper = pr_cdcooper
                      ,crapppe.cdeixtem = pr_cdeixtem
                      ,crapppe.qtmineve = pr_qtmineve
                      ,crapppe.cdoperad = vr_cdoperad
                      ,crapppe.cdprogra = vr_nmdatela
                      ,crapppe.dtatuali = SYSDATE
                      ,crapppe.cdcopope = vr_cdcooper     
                 WHERE crapppe.idevento = pr_idevento
                   AND crapppe.cdcooper = pr_cdcooper
                   AND crapppe.dtanoage = pr_dtanoage
                   AND crapppe.cdeixtem = pr_cdeixtem;
              		
                IF SQL%ROWCOUNT = 0 THEN    
                  -- Insere registro
                  BEGIN
                    INSERT INTO
                        crapppe(idevento
                               ,dtanoage
                               ,cdcooper
                               ,cdeixtem
                               ,qtmineve
                               ,cdoperad
                               ,cdprogra
                               ,dtatuali
                               ,cdcopope
                        )VALUES(pr_idevento
                               ,pr_dtanoage
                               ,pr_cdcooper
                               ,pr_cdeixtem
                               ,pr_qtmineve
                               ,vr_cdoperad
                               ,vr_nmdatela
                               ,SYSDATE
                               ,vr_cdcooper);

                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Problema ao inserir registro CRAPPPE. Erro: ' || SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                END IF;
    
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao atualizar registro CRAPPPE. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
              
            WHEN 'C' THEN -- Consulta
              -- Criar cabe�alho do XML
              pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?><Dados/>');

              FOR rw_crapppe IN cr_crapppe LOOP
                 
                IF ((pr_nriniseq <= rw_crapppe.nrdseque)AND (rw_crapppe.nrdseque <= (pr_nriniseq + (pr_qtregist - 1)))) THEN
                       
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
                  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_crapppe.idevento, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtanoage', pr_tag_cont => rw_crapppe.dtanoage, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_crapppe.cdcooper, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmrescop', pr_tag_cont => rw_crapppe.nmrescop, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem', pr_tag_cont => rw_crapppe.cdeixtem, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem', pr_tag_cont => rw_crapppe.dseixtem, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtmineve', pr_tag_cont => rw_crapppe.qtmineve, pr_des_erro => vr_dscritic);  
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdoperad', pr_tag_cont => rw_crapppe.cdoperad, pr_des_erro => vr_dscritic);
                  GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtatuali', pr_tag_cont => rw_crapppe.dtatuali, pr_des_erro => vr_dscritic);  
                  vr_contador := vr_contador + 1;
                END IF;

                vr_totregis := vr_totregis +1;

              END LOOP;
             
              GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);

            WHEN 'E' THEN -- Exclusao
              -- Efetua a exclus�o de registros
              BEGIN
                DELETE crapppe WHERE crapppe.cdcooper = pr_cdcooper AND crapppe.cdeixtem = pr_cdeixtem AND crapppe.dtanoage = pr_dtanoage;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Problema ao excluir registro CRAPPPE. Erro: ' || SQLERRM;
                  RAISE vr_exc_saida;
              END;
          END CASE;
        END IF;
        
      ELSE

        vr_contador := 0;

        -- Criar cabe�alho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        FOR rw_gnapetp IN cr_gnapetp LOOP
                     
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idevento', pr_tag_cont => rw_gnapetp.idevento, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdcooper', pr_tag_cont => rw_gnapetp.cdcooper, pr_des_erro => vr_dscritic);  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdeixtem', pr_tag_cont => rw_gnapetp.cdeixtem, pr_des_erro => vr_dscritic);
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dseixtem', pr_tag_cont => rw_gnapetp.dseixtem, pr_des_erro => vr_dscritic);  
          GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'flgativo', pr_tag_cont => rw_gnapetp.flgativo, pr_des_erro => vr_dscritic);  

          vr_contador := vr_contador + 1;
        END LOOP;

        GENE0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => vr_totregis , pr_des_erro => vr_dscritic);
      END IF;
  
      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PC_WPGD0104: ' || SQLERRM;

        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_wpgd0104;
                    
END WPGD0104;
/
