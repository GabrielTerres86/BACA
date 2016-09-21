CREATE OR REPLACE PROCEDURE CECRED.pc_crps170(pr_cdcooper  IN craptab.cdcooper%TYPE,
                                       pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                       pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                       pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
/* ..........................................................................

   Programa: PC_CRPS170 (Antigo Fontes/crps170.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/96.                        Ultima atualizacao: 17/05/2010

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 039.
               Listar o valor a cobrar referente tarifa de credito de ferias.

   Alteracoes: 28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               03/02/99 - Tratar historico 310 (Odair)

               19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               03/02/2000 - Gerar pedido de impressao (Deborah).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapacc (Diego).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               23/01/2009 - Alteracao cdempres (Diego).
               
               17/05/2010 - Tratar crapacc.cdempres com 9999 (Diego).
                                         
               26/02/2015 - Conversão Progress >> Oracle PL/SQL (Vanessa).
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
      vr_xml_des_erro  VARCHAR2(4000);      
      vr_des_xml       VARCHAR(32600) := NULL;
   
    
      -- Variáveis do cprs
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS170';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
        
      vr_vltarifa  NUMBER   := 0;
      vr_dstarifa  VARCHAR(10);
      vr_vlcobrar  NUMBER   := 0;
      vr_dscobrar  VARCHAR(50);
      vr_tot_vlcobrar NUMBER   := 0;
      vr_tot_qtlanmto NUMBER   := 0;
      vr_dtrefere DATE;
      
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
   
      --Cursor que busca as Informacoes Gerenciais
      CURSOR cr_crapacc(pr_cdcooper IN crapope.cdcooper%TYPE,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
         SELECT crapacc.cdcooper,
                crapacc.qtlanmto,
                LPAD(crapacc.cdempres,5,0) AS cdempres,
                NVL(crapemp.nmresemp,'EMPRESA NAO CADASTRADA') AS dsempres
           FROM crapacc
           LEFT JOIN crapemp ON
              crapemp.cdcooper = crapacc.cdcooper  AND
              crapemp.cdempres = crapacc.cdempres
        WHERE crapacc.cdcooper = pr_cdcooper  AND
              crapacc.dtrefere = pr_dtmvtolt  AND
              crapacc.cdlanmto IN (105,310)   AND
              crapacc.cdagenci = 0            AND
              crapacc.cdempres > 0            AND
              crapacc.cdempres < 9999  ; 
       rw_crapacc cr_crapacc%ROWTYPE;
       
       --Cursor que busca as Tarifas
       CURSOR cr_craptab(pr_cdcooper IN crapope.cdcooper%TYPE,
                         pr_cdempres IN crapacc.cdempres %TYPE) IS
         SELECT /*index (TAB CRAPTAB##CRAPTAB1)*/ 
                dstextab 
           FROM craptab tab
          WHERE tab.cdcooper = pr_cdcooper  AND
                tab.nmsistem = 'CRED'       AND
                tab.tptabela = 'USUARI'     AND
                tab.cdempres = pr_cdempres  AND
                tab.cdacesso = 'VLTARIF105' AND
                tab.tpregist = 1; 
       rw_craptab cr_craptab%ROWTYPE;
      
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
      
      vr_dtrefere := LAST_DAY(ADD_MONTHS(rw_crapdat.dtmvtolt,-1));
      
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/micros
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => 'rl'); 
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
          
       -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_xml_clobxml, TRUE);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      
      -- Adiciona a linha ao XML 
      gene0002.pc_escreve_xml(pr_xml         => vr_xml_clobxml 
                              ,pr_texto_completo => vr_des_xml
                              ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?>'||chr(10)
                              ||'<crrl133 dtmesref="'||TRIM(Upper(to_char(vr_dtrefere,'Month/YYYY')))||'">');
                   
        FOR rw_crapacc IN cr_crapacc(pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtolt => vr_dtrefere) LOOP
           vr_vltarifa := 0;
           --Busca as tarifas
           OPEN cr_craptab(pr_cdcooper => rw_crapacc.cdcooper,
                           pr_cdempres => rw_crapacc.cdempres);
                      
           FETCH cr_craptab INTO rw_craptab;
           -- Se nao encontrar
           IF cr_craptab%NOTFOUND THEN
              vr_vltarifa := 0;              
              -- Fechar o cursor
              CLOSE cr_craptab;
             
           ELSE
              vr_vltarifa := rw_craptab.dstextab;
              -- Fechar o cursor
              CLOSE cr_craptab;             
           END IF;
           
           --Calcula os valores
           vr_vlcobrar := vr_vltarifa * rw_crapacc.qtlanmto;
           vr_tot_vlcobrar := vr_tot_vlcobrar + vr_vlcobrar;
           vr_tot_qtlanmto := vr_tot_qtlanmto + rw_crapacc.qtlanmto;
                    
                      
           IF vr_vltarifa > 0 THEN
              vr_dstarifa := to_char(vr_vltarifa,'fm9g990d00');
           ELSE
              vr_dstarifa := '';
           END IF;
           
           IF vr_vlcobrar > 0 THEN
             vr_vlcobrar := vr_vlcobrar;
             vr_dscobrar := to_char(vr_vlcobrar,'fm9g990d00');
           ELSE
             vr_dscobrar := '';
           END IF;
           
           -- Adiciona a linha ao XML
            gene0002.pc_escreve_xml(pr_xml    => vr_xml_clobxml
                                   ,pr_texto_completo => vr_des_xml 
                                   ,pr_texto_novo     =>'<tarifas>'
                                   ||chr(10)||'<cdempres>'||TRIM(rw_crapacc.cdempres) ||'</cdempres>'
                                   ||chr(10)||'<dsempres>'||TRIM(rw_crapacc.dsempres) ||'</dsempres>'
                                   ||chr(10)||'<qtlanmto>'||TRIM(rw_crapacc.qtlanmto)||'</qtlanmto>'
                                   ||chr(10)||'<vltarifa>'||TRIM(vr_dstarifa)||'</vltarifa>'
                                   ||chr(10)||'<vlcobrar>'||TRIM(vr_dscobrar)||'</vlcobrar>'
                                   ||chr(10)||'</tarifas>'); 
                   
       END LOOP;
       
       -- Adiciona a linha ao XML 
       gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                              ,pr_texto_completo => vr_des_xml
                              ,pr_texto_novo     => '<total>'
                              ||chr(10)||'<tot_vlcobrar>'||(to_char(vr_tot_vlcobrar,'fm9g990d00')) ||'</tot_vlcobrar>'
                              ||chr(10)||'<tot_qtlanmto>'||(vr_tot_qtlanmto) ||'</tot_qtlanmto>'
                              ||chr(10)||'</total></crrl133>'
                              ,pr_fecha_xml => TRUE);
                            
      -- Submeter o relatório 133
      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper                  --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                           --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl133/tarifas'                           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl133.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdireto||'/crrl133.lst'         --> Arquivo final com o path
                                 ,pr_qtcoluna  => 80                                  --> 234 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '133'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
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
END pc_crps170;
/

