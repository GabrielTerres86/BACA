CREATE OR REPLACE PROCEDURE CECRED.pc_crps607 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                             ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN

/* ..........................................................................
    
   Programa: pc_crps607                    Antigo: Fontes/crps607.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Oliver
   Data    : Agosto/2011.                  Ultima atualizacao: 29/11/2017

   Dados referentes ao programa:

   Frequencia: Semanal. Solicitacao 70 / Ordem 2 / Cadeia Paralela.
               Roda toda segunda-feira.
                
   Objetivo  : Litar seguros novos, cancelados e renovados do tipo CASA na
               ultima semana. Emite relatorio 607.

   Alteracoes: 22/05/2012 - Alterado busca na crapseg para não trazer seguros
                            com a data de contratação e cancelamento iguais
                            (Guilherme Maba).
                            
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele). 
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                         
               13/05/2014 - Ajuste na busca de seguros (Douglas)
               
               29/01/2015 - Inclusão do campo de operador no relatorio crrl607
                            SD 248221 (Odirlei-AMcom).
                            
               06/02/2015 - Alterado para exibir o operador que cancelou o seguro no
                            relatorio crrl607 SD 251771 (Odirlei-Amcom)              
                             
               23/04/2015 - Conversão Progress -> Oracle - Alisson (AMcom)             					

               17/06/2015 - Ajuste para enviar arquivo lst via email, conforme na versão progress
                            SD297992 (Odirlei-Amcom)
                             
               29/11/2017 - Ajustado o cursor cr_crapseg para que o partition by de situação seja feito
                            por SEGURADORA e SITUAÇÃO, para que as informações sejam agrupadas 
                            corretamente (Douglas - Chamado 803460)
    .............................................................................*/          

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'crps607';

      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_sair   EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.dsemlcof
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      --Selecionar Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT crapass.dtadmiss
              ,crapass.inpessoa
              ,crapass.nrcpfcgc
              ,crapass.cdagenci
              ,crapass.nmprimtl
        FROM crapass 
        WHERE crapass.cdcooper = pr_cdcooper       
        AND   crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%rowtype;  
      
      --Selecionar Seguradoras
      CURSOR cr_crapcsg (pr_cdcooper IN crapcsg.cdcooper%type) IS
        SELECT crapcsg.cdsegura
              ,crapcsg.nmsegura
        FROM crapcsg
        WHERE crapcsg.cdcooper = pr_cdcooper;

      --Selecionar Operadores
      CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%type) IS
        SELECT  crapope.cdoperad
               ,crapope.nmoperad
        FROM crapope
        WHERE crapope.cdcooper = pr_cdcooper;

      --Selecionar Seguros
      CURSOR cr_crapseg (pr_cdcooper IN crapope.cdcooper%type
                        ,pr_tpseguro IN crapseg.tpseguro%type
                        ,pr_cdsitseg IN crapseg.cdsitseg%type
                        ,pr_dtiniref IN DATE
                        ,pr_dtfimref IN DATE) IS
        SELECT crapseg.cdcooper
              ,crapseg.nrdconta
              ,crapseg.cdsegura
              ,crapseg.tpseguro
              ,crapseg.cdsitseg
              ,crapseg.dtcancel
              ,crapseg.qtparcel
              ,crapseg.qtprepag
              ,crapseg.cdoperad
              ,crapseg.cdopecnl
              ,crapseg.nrctrseg
              ,crapseg.tpplaseg
              ,crapseg.vlpreseg
              ,crapseg.dtinivig
              ,crapseg.dtfimvig
              ,row_number() over (partition by crapseg.cdsegura
                                  order by crapseg.cdsegura
                                          ,crapseg.cdsitseg
                                          ,crapseg.nrdconta
                                          ,crapseg.cdagenci) nrseqseg 
              ,count(*) over (partition by crapseg.cdsegura) nrtotseg                                          
              ,row_number() over (partition by crapseg.cdsegura, crapseg.cdsitseg                                          
                                  order by crapseg.cdsegura
                                          ,crapseg.cdsitseg
                                          ,crapseg.nrdconta
                                          ,crapseg.cdagenci) nrseqsit 
              ,count(*) over (partition by crapseg.cdsegura, crapseg.cdsitseg) nrtotsit 
        FROM crapseg      
        WHERE  crapseg.cdcooper = pr_cdcooper     
        AND    crapseg.tpseguro = pr_tpseguro               
        AND    crapseg.cdsitseg < pr_cdsitseg                
        AND    ((crapseg.dtmvtolt >= pr_dtiniref AND crapseg.dtmvtolt <= pr_dtfimref)  OR
                (crapseg.dtcancel >= pr_dtiniref AND crapseg.dtcancel <= pr_dtfimref)
               ) 
        AND    /* Comparacao de datas apenas quando a data de cancelamento nao for nula */
               ((crapseg.dtmvtolt <> crapseg.dtcancel AND crapseg.dtcancel IS NOT NULL) OR 
                crapseg.dtcancel IS NULL )
        ORDER BY crapseg.cdsegura
                ,crapseg.cdsitseg
                ,crapseg.nrdconta
                ,crapseg.cdagenci;
        
      ------------------------------- VETORES ---------------------------------
      
      --Cadastro Operadores
      TYPE typ_tab_crapope IS TABLE OF crapope.nmoperad%type INDEX BY crapope.cdoperad%type;
      vr_tab_crapope typ_tab_crapope;  
      
      --Cadastro Seguradoras
      TYPE typ_tab_crapcsg IS TABLE OF crapcsg.nmsegura%type INDEX BY PLS_INTEGER;
      vr_tab_crapcsg typ_tab_crapcsg;  
      ------------------------------- VARIAVEIS -------------------------------

      vr_des_xml   clob;
      vr_nmdireto  varchar2(1000);
      vr_nmarqimp  varchar2(1000);
      vr_string    varchar2(1000);
      vr_dsmail    varchar2(1000);
      vr_dsassunto varchar2(1000);
      vr_nmoperad  varchar2(100);
      vr_nmopecnl  varchar2(100);
      vr_dsprepag  varchar2(100);
      vr_dsrefere  varchar2(100);
      vr_dsseguro  varchar2(100);
      vr_dspropos  varchar2(100);
      vr_dsqtprop  varchar2(100);
      vr_dstotpre  varchar2(100);
      vr_dstexto   varchar2(32767);
      vr_dtiniref  DATE;
      vr_dtfimref  DATE;
      vr_flgregis  BOOLEAN:= FALSE;
      vr_nmresseg  crapcsg.nmsegura%type;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      --Data de Referencia  
      vr_dtiniref:= (rw_crapdat.dtmvtoan - to_number(to_char(rw_crapdat.dtmvtoan,'D'))) + 2;
      vr_dtfimref:= rw_crapdat.dtmvtoan;
      vr_dsrefere:= to_char(vr_dtiniref,'DD/MM/YYYY')||' - '||to_char(vr_dtfimref,'DD/MM/YYYY');

      -- Inicializar o CLOB do relatorio
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- Escreve o cabecalho do XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><raiz>');
      
      --Limpar tabela Operadores
      vr_tab_crapope.DELETE;
      
      --Carregar tabela de Operadores
      FOR rw_crapope IN cr_crapope (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapope(rw_crapope.cdoperad):= rw_crapope.nmoperad;
      END LOOP;  
      
      --Limpar tabela Seguradoras
      vr_tab_crapcsg.DELETE;
     
      --Carregar tabela de Seguradoras
      FOR rw_crapcsg IN cr_crapcsg (pr_cdcooper => pr_cdcooper) LOOP
        vr_tab_crapcsg(rw_crapcsg.cdsegura):= rw_crapcsg.nmsegura;
      END LOOP;  

      -- Efetua um loop sobre os seguros
      FOR rw_crapseg IN cr_crapseg (pr_cdcooper => pr_cdcooper
                                   ,pr_tpseguro => 11
                                   ,pr_cdsitseg => 4
                                   ,pr_dtiniref => vr_dtiniref
                                   ,pr_dtfimref => vr_dtfimref) LOOP
          
        --Selecionar Associado
        OPEN cr_crapass (pr_cdcooper => rw_crapseg.cdcooper
                        ,pr_nrdconta => rw_crapseg.nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrou
        IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor  
          CLOSE cr_crapass;
          vr_cdcritic:= 9;
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          --Escrever no LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
          --Proximo Registro
          CONTINUE;
        ELSE
          --Fechar Cursor  
          CLOSE cr_crapass;
        END IF;

        --Primeira Ocorrencia da Seguradora
        IF rw_crapseg.nrseqseg = 1 THEN
          --Nome resumido Seguradora
          IF vr_tab_crapcsg.EXISTS(rw_crapseg.cdsegura) THEN
            vr_nmresseg:= vr_tab_crapcsg(rw_crapseg.cdsegura);
          ELSE  
            vr_nmresseg:= NULL;
          END IF;  
          --Descriçao do Seguro
          IF rw_crapseg.tpseguro = 11 THEN
            vr_dsseguro:= '** SEGURO RESIDENCIAL **';
          ELSE
            vr_dsseguro:= NULL;
          END IF; 
          --Escrever no XML
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<seg nmresseg="'||vr_nmresseg||'" '||
                                                             'dsrefere="'||vr_dsrefere||'" '||
                                                             'dsseguro="'||vr_dsseguro||'">'); 
        END IF;
        
        --Primeira Ocorrencia da Situacao
        IF rw_crapseg.nrseqsit = 1 THEN
          IF rw_crapseg.cdsitseg = 1 THEN
            vr_dspropos:= 'SEGUROS NOVOS'; 
            vr_dsqtprop:= 'QUANTIDADE DE PROPOSTAS NOVAS:';
            vr_dstotpre:= 'TOTAL DOS NOVOS PREMIOS:';   
          ELSIF rw_crapseg.cdsitseg = 2 OR rw_crapseg.dtcancel IS NOT NULL THEN
            vr_dspropos:= 'SEGUROS CANCELADOS'; 
            vr_dsqtprop:= 'QUANTIDADE DE CANCELAMENTOS:';
            vr_dstotpre:= 'TOTAL DOS PREMIOS CANCELADOS:';   
          ELSIF rw_crapseg.cdsitseg = 3 THEN
            vr_dspropos:= 'SEGUROS RENOVADOS'; 
            vr_dsqtprop:= 'QUANTIDADE DE RENOVADOS:';
            vr_dstotpre:= 'TOTAL DOS NOVOS PREMIOS:';   
          ELSE 
            vr_dspropos:= NULL;    
          END IF;  
          --Escrever no XML
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<sit cdsitseg="'||rw_crapseg.cdsitseg||'" '||
                                                             'dspropos="'||vr_dspropos||'" '||
                                                             'dsqtprop="'||vr_dsqtprop||'" '||
                                                             'dstotpre="'||vr_dstotpre||'">');
        END IF;
           
        --Tem Parcelas 
        IF rw_crapseg.qtparcel > 0 THEN
          vr_dsprepag:= lpad(rw_crapseg.qtprepag,3,' ')||'/'||to_char(rw_crapseg.qtparcel,'fm00');
        ELSE
          vr_dsprepag:= lpad(rw_crapseg.qtprepag,3,' ');
        END IF;    
        
        /* Buscar nome do operador*/
        IF rw_crapseg.cdoperad IS NOT NULL AND vr_tab_crapope.EXISTS(rw_crapseg.cdoperad) THEN
          vr_nmoperad:= vr_tab_crapope(rw_crapseg.cdoperad);
        ELSE
          vr_nmoperad:= NULL;
        END IF;

        /* Buscar nome do operador Cancelamento */
        IF rw_crapseg.cdopecnl IS NOT NULL AND vr_tab_crapope.EXISTS(rw_crapseg.cdopecnl) THEN
          vr_nmopecnl:= vr_tab_crapope(rw_crapseg.cdopecnl);
        ELSE
          vr_nmopecnl:= NULL;
        END IF;
        
        --Seguros Cancelados
        IF rw_crapseg.cdsitseg = 2 THEN
          vr_string:= '<conta>'||
                         '<nrdconta>'|| to_char(rw_crapseg.nrdconta,'fm9999g990g0') ||'</nrdconta>'||   
                         '<nrctrseg>'|| to_char(rw_crapseg.nrctrseg,'fm999g999g990') ||'</nrctrseg>'||   
                         '<tpplaseg>'|| to_char(rw_crapseg.tpplaseg,'fm990') ||'</tpplaseg>'||   
                         '<cdagenci>'|| to_char(rw_crapass.cdagenci,'fm990') ||'</cdagenci>'||   
                         '<nmprimtl>'|| substr(rw_crapass.nmprimtl,1,19) ||'</nmprimtl>'||   
                         '<vlpreseg>'|| to_char(rw_crapseg.vlpreseg,'fm999g999g990d00') ||'</vlpreseg>'||   
                         '<dsprepag>'|| substr(vr_dsprepag,1,6) ||'</dsprepag>'||   
                         '<dtinivig>'|| to_char(rw_crapseg.dtinivig,'DD/MM/RRRR') ||'</dtinivig>'||   
                         '<dtfimvig>'|| to_char(rw_crapseg.dtfimvig,'DD/MM/RRRR') ||'</dtfimvig>'||   
                         '<dtcancel>'|| to_char(rw_crapseg.dtcancel,'DD/MM/RRRR') ||'</dtcancel>'||   
                         '<nmoperad>'|| substr(vr_nmoperad,1,12) ||'</nmoperad>'||   
                         '<nmopecnl>'|| substr(vr_nmopecnl,1,12) ||'</nmopecnl>'||   
                      '</conta>';   
          
        ELSE  
          vr_string:= '<conta>'||
                         '<nrdconta>'|| to_char(rw_crapseg.nrdconta,'fm9999g990g0') ||'</nrdconta>'||   
                         '<nrctrseg>'|| to_char(rw_crapseg.nrctrseg,'fm999g999g990') ||'</nrctrseg>'||   
                         '<tpplaseg>'|| to_char(rw_crapseg.tpplaseg,'fm990') ||'</tpplaseg>'||   
                         '<cdagenci>'|| to_char(rw_crapass.cdagenci,'fm990') ||'</cdagenci>'||   
                         '<nmprimtl>'|| substr(rw_crapass.nmprimtl,1,22) ||'</nmprimtl>'||   
                         '<vlpreseg>'|| to_char(rw_crapseg.vlpreseg,'fm999g999g990d00') ||'</vlpreseg>'||   
                         '<dsprepag>'|| substr(vr_dsprepag,1,6) ||'</dsprepag>'||   
                         '<dtinivig>'|| to_char(rw_crapseg.dtinivig,'DD/MM/RRRR') ||'</dtinivig>'||   
                         '<dtfimvig>'|| to_char(rw_crapseg.dtfimvig,'DD/MM/RRRR') ||'</dtfimvig>'||   
                         '<dtcancel></dtcancel>'||   
                         '<nmoperad>'|| substr(vr_nmoperad,1,21) ||'</nmoperad>'||   
                         '<nmopecnl></nmopecnl>'||   
                      '</conta>';   
        END IF;
                  
        --Escrever no XML
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,vr_string);
        
        --Ultimo Registro da Situacao
        IF rw_crapseg.nrseqsit = rw_crapseg.nrtotsit THEN  
          --Escrever no XML
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</sit>');
        END IF;
        --Ultimo Registro da Seguradora
        IF rw_crapseg.nrseqseg = rw_crapseg.nrtotseg THEN  
          --Escrever no XML
          gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</seg>');
        END IF;
        --Marcar que processou
        vr_flgregis:= TRUE;

      END LOOP; /* Fim FOR EACH crapseg */

        
      /************************ GERAR RELATORIO CRRL604 *************************/ 
      
      --Se encontrou informacoes
      IF vr_flgregis THEN
        
        -- Busca do diretorio base da cooperativa
        vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => null); 

        -- Nome Arquivo Impressao
        vr_nmarqimp:= vr_nmdireto||'/rl/crrl607.lst';

        -- Finaliza o no principal
        gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</raiz>',true);

        -- Buscar Email padrao envio
        vr_dsmail:= GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL607_EMAIL');
        --Se nao Encontrou
        IF vr_dsmail IS NULL THEN
          vr_dscritic:= 'Email padrao para envio de seguros nao cadastrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;  
        
        -- Assunto do Email
        vr_dsassunto:= 'RESUMO DOS SEGUROS - '||rw_crapcop.nmrescop;

        -- Chamada do iReport para gerar o arquivo de saida
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,               --> Cooperativa conectada
                                    pr_cdprogra  => vr_cdprogra,               --> Programa chamador
                                    pr_dtmvtolt  => rw_crapdat.dtmvtolt,       --> Data do movimento atual
                                    pr_dsxml     => vr_des_xml,                --> Arquivo XML de dados (CLOB)
                                    pr_dsxmlnode => '/raiz/seg/sit/conta',     --> No base do XML para leitura dos dados
                                    pr_dsjasper  => 'crrl607.jasper',          --> Arquivo de layout do iReport
                                    pr_dsparams  => NULL,                      --> Imprimir Msg
                                    pr_dsarqsaid => vr_nmarqimp,               --> Arquivo final
                                    pr_flg_gerar => 'N',                       --> Nao gerar o arquivo na hora
                                    pr_qtcoluna  => 132,                       --> Quantidade de colunas
                                    pr_sqcabrel  => 1,                         --> Sequencia do cabecalho
                                    pr_flg_impri => 'S',                       --> Chamar a impress?o (Imprim.p)
                                    pr_nrcopias  => 1,                         --> Numero de copias
                                    pr_nmformul  => '132col',                  --> Nome Formulario
                                    pr_dsmailcop => vr_dsmail,                 --> Email de Destino
                                    pr_dsassmail => vr_dsassunto,              --> Assunto Email
                                    pr_dscormail => 'Arquivo em anexo.',       --> Corpo do Email
                                    pr_dsextmail => 'lst',                     --> Extensao do arquivo anexado ao email
                                    pr_flgremarq => 'N',                       --> Remover Arquivo apos copia/email
                                    pr_fldosmail => 'S',                       --> converter arquivo antes de mandar via email
                                    pr_fldoscop  => 'S',                       --> converter arquivo de copia
                                    pr_dspathcop => vr_nmdireto||'/converte',        --> Diretorio de Copia do arquivo
                                    pr_des_erro  => vr_dscritic);              --> Saida com erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      END IF; --flgregis
                            
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;
    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps607;
/
