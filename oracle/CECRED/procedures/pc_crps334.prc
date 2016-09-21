CREATE OR REPLACE PROCEDURE CECRED.pc_crps334(pr_cdcooper  IN craptab.cdcooper%TYPE,
                                       pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                       pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                       pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
/* ............................................................................

   Programa: PC_CRPS334 (Antigo Fontes/crps334.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Dezembro/2002.                     Ultima atualizacao: 31/10/2013

   Dados referentes ao programa:

   Frequencia : Diario.
   Objetivo   : Atende a solicitacao 002.
                Listar as novas matriculas.
                Emite relatorio 280.
               
   Alteracoes: 14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               09/09/2013 - Nova forma de chamar as agASncias, de PAC agora 
                            a escrita serA? PA (AndrA© EuzA©bio - Supero).
                            
               31/10/2013 - Alterado totalizador de 99 para 999. (Reinert)
                            
               23/02/2015 - Conversão Progress >> Oracle PL/SQL (Vanessa).
............................................................................. */

   DECLARE
    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    
     -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);     

      -- Variáveis locais do bloco
      vr_xml_clobxml   CLOB;
      vr_des_xml       VARCHAR(32600) := NULL;
      vr_xml_des_erro  VARCHAR2(4000);
    
      -- Variáveis do cprs
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS334';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
        
      vr_qtdtotreg NUMBER   := 0; 
      vr_idxrel    INTEGER DEFAULT 0;  
      
      ---temptable para armazenar informações para o relatorio
      TYPE typ_tab_reg_relat IS RECORD
          (cdcooper crapass.cdcooper%TYPE,
           cdagenci crapass.cdagenci%TYPE,
           nrdconta crapass.nrdconta%TYPE,
           nrmatric crapass.nrmatric%TYPE,
           nmprimtl crapass.nmprimtl%TYPE,
           nmoperad crapass.nmprimtl%TYPE
           );
                      
      TYPE typ_tab_relat IS
       TABLE OF typ_tab_reg_relat
       INDEX BY PLS_INTEGER; 
      vr_tab_relat typ_tab_relat;
      
     ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrctactl
              ,cop.dsdircop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
   
      --Cursor que busca as novas matriculas
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE,
                        pr_cdoperad IN crapneg.cdoperad%TYPE) IS
         SELECT nmoperad,
                cdoperad
           FROM crapope 
          WHERE crapope.cdcooper = pr_cdcooper     AND
                crapope.cdoperad = pr_cdoperad; 
       rw_crapope cr_crapope%ROWTYPE;
       
       --Cursor que busca as agencias 
       CURSOR cr_crapage(pr_cdcooper IN crapope.cdcooper%TYPE) IS
         SELECT age.cdagenci,
                age.nmextage
           FROM crapage age 
          WHERE age.cdcooper = pr_cdcooper
       ORDER BY age.cdagenci ASC; 
       rw_crapage cr_crapage%ROWTYPE;
      
      CURSOR cr_crapneg(pr_cdcooper IN craptab.cdcooper%TYPE,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
       SELECT /*index (NEG CRAPNEG##CRAPNEG6)*/ 
              neg.cdcooper,
              ass.cdagenci,
              neg.cdoperad,
              neg.nrdconta,
              ass.nrmatric,
              ass.nmprimtl
         FROM crapneg neg,
              crapass ass 
        WHERE neg.cdcooper = pr_cdcooper  AND
              neg.dtiniest = pr_dtmvtolt  AND
              neg.cdhisest = 0            AND
              ass.cdcooper = neg.cdcooper AND
              ass.nrdconta = neg.nrdconta
         ORDER BY  ass.nrmatric ;
      rw_crapneg cr_crapneg%ROWTYPE;
     
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      -- Se nao encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
     
      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel nao for 0
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
     
      FOR rw_crapneg IN cr_crapneg(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
         --Busca o nome do operador
         OPEN cr_crapope(pr_cdcooper => rw_crapneg.cdcooper,
                         pr_cdoperad => rw_crapneg.cdoperad);
                      
         FETCH cr_crapope INTO rw_crapope;
           
          vr_idxrel := vr_idxrel + 1;
          vr_tab_relat(vr_idxrel).cdcooper := rw_crapneg.cdcooper;
          vr_tab_relat(vr_idxrel).cdagenci := rw_crapneg.cdagenci;
          vr_tab_relat(vr_idxrel).nrmatric := rw_crapneg.nrmatric;
          vr_tab_relat(vr_idxrel).nrdconta := rw_crapneg.nrdconta;
          vr_tab_relat(vr_idxrel).nmprimtl := rw_crapneg.nmprimtl;
          vr_tab_relat(vr_idxrel).nmoperad := NVL(rw_crapope.nmoperad,' ');
            
         CLOSE cr_crapope; 
      END LOOP;
      
       -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/micros
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => 'rl'); 
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
                                               
      --Gera o Relatorio Geral 999
      vr_idxrel := vr_tab_relat.first;    
      
      -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      
      -- Adiciona a linha ao XML 
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                             ,pr_texto_completo => vr_des_xml
                             ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?>'||chr(10)
                                                ||'<crrl280>'||chr(10));
          
      WHILE vr_idxrel IS NOT NULL LOOP         
          -- Adiciona a linha ao XML 
          gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                                  ,pr_texto_completo => vr_des_xml
                                  ,pr_texto_novo     =>'<matricula>'
                                             ||chr(10)||'<cdagenci>'||TRIM(vr_tab_relat(vr_idxrel).cdagenci) ||'</cdagenci>'
                                             ||chr(10)||'<nrmatric>'||TRIM(gene0002.fn_mask(vr_tab_relat(vr_idxrel).nrmatric,'zzzz.zzz'))||'</nrmatric>'
                                             ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(vr_tab_relat(vr_idxrel).nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                                             ||chr(10)||'<nmprimtl>'||TRIM(vr_tab_relat(vr_idxrel).nmprimtl) ||'</nmprimtl>'
                                             ||chr(10)||'<nmoperad>'||TRIM(vr_tab_relat(vr_idxrel).nmoperad) ||'</nmoperad>'
                                             ||chr(10)||'</matricula>'); 
           
            vr_idxrel    := vr_tab_relat.next(vr_idxrel);
            vr_qtdtotreg := vr_qtdtotreg + 1;
        
      END LOOP;
      
      -- Adiciona a linha ao XML 
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                             ,pr_texto_completo => vr_des_xml
                             ,pr_texto_novo     =>'<total>'||vr_qtdtotreg||'</total></crrl280>'
                             ,pr_fecha_xml      => TRUE);  
     
          
        -- Submeter o relatório 215
      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper                  --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl280/matricula'                           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl280.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdireto||'/crrl280_999.lst'      --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                                  --> 234 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '280'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);
          
      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
         RAISE vr_exc_saida;
      END IF;	
          
    
      --gera os relatorios por PA
      FOR rw_crapage IN cr_crapage(pr_cdcooper => rw_crapcop.cdcooper) LOOP
          
          vr_qtdtotreg := 0;
          vr_idxrel := vr_tab_relat.first;
          
           -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
          -- Adiciona a linha ao XML 
          gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                                  ,pr_texto_completo => vr_des_xml
                                  ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?>'||chr(10)
                                                    ||'<crrl280>'||chr(10));
          
          WHILE vr_idxrel IS NOT NULL LOOP 
            
             IF rw_crapage.cdagenci = vr_tab_relat(vr_idxrel).cdagenci THEN                      
                -- Adiciona a linha ao XML 
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                                       ,pr_texto_completo => vr_des_xml
                                       ,pr_texto_novo     =>'<matricula>'
                                                 ||chr(10)||'<cdagenci>'||TRIM(vr_tab_relat(vr_idxrel).cdagenci) ||'</cdagenci>'
                                                 ||chr(10)||'<nrmatric>'||TRIM(gene0002.fn_mask(vr_tab_relat(vr_idxrel).nrmatric,'zzzz.zzz'))||'</nrmatric>'
                                                 ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(vr_tab_relat(vr_idxrel).nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                                                 ||chr(10)||'<nmprimtl>'||TRIM(vr_tab_relat(vr_idxrel).nmprimtl) ||'</nmprimtl>'
                                                 ||chr(10)||'<nmoperad>'||TRIM(vr_tab_relat(vr_idxrel).nmoperad) ||'</nmoperad>'
                                                 ||chr(10)||'</matricula>');                              
                
                vr_qtdtotreg := vr_qtdtotreg + 1;
              END IF;  
              vr_idxrel    := vr_tab_relat.next(vr_idxrel);
          END LOOP;
         
          -- Adiciona a linha ao XML 
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                                 ,pr_texto_completo => vr_des_xml
                                 ,pr_texto_novo     =>'<total>'||vr_qtdtotreg||'</total></crrl280>'
                                 ,pr_fecha_xml      => TRUE );  
        
          
          IF vr_qtdtotreg > 0 THEN
            -- Submeter o relatório 280
            gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper                  --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                       ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                       ,pr_dsxmlnode => '/crrl280/matricula'                           --> Nó base do XML para leitura dos dados
                                       ,pr_dsjasper  => 'crrl280.jasper'                     --> Arquivo de layout do iReport
                                       ,pr_dsparams  => NULL                                 --> Sem parâmetros
                                       ,pr_dsarqsaid => vr_dsdireto||'/crrl280_'||LPAD(rw_crapage.cdagenci,3,0)||'.lst'   --> Arquivo final com o path
                                       ,pr_qtcoluna  => 80                                  --> 234 colunas
                                       ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                       ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                       ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                       ,pr_nrcopias  => 1                                    --> Número de cópias
                                       ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                       ,pr_cdrelato  => '280'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                       ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                       ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
          END IF;                              
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_xml_clobxml);
          dbms_lob.freetemporary(vr_xml_clobxml);
          -- Verifica se ocorreram erros na geração do XML
          IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := vr_xml_des_erro;
            -- Gerar exceção
             RAISE vr_exc_saida;
          END IF;	
      END LOOP;
    
    
      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
        RAISE vr_exc_saida;
      ELSE
        -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
        -- Salvar informações atualizadas
        COMMIT;
      END IF;   
   
    
     EXCEPTION
      
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
        
       
      WHEN vr_exc_saida THEN

        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

     WHEN OTHERS THEN

        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;
               
      END;
END pc_crps334;
/

