CREATE OR REPLACE PROCEDURE CECRED.pc_crps647 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    /* .............................................................................

      Programa: pc_crps647    (Fontes/crps647.p)
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autora  : Lucas R.
      Data    : Setembro/2013                        Ultima atualizacao: 04/09/2015

      Dados referentes ao programa:

      Frequencia: Diario (Batch).
      Objetivo  : Integrar Arquivos de debitos de consorcios enviados pelo SICREDI.
                  Emite relatorio 661.

      Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                               a glb_cdcritic <> 0 antes do return. (Lucas R.)
                                 
                  10/12/2013 - Alterado crapndb.dtmvtolt para armazenar data de 
                               vencimneto do debito, (aux_setlinha,45,8).
                             - Substituido glb_dtmvtoan por glb_dtmvtolt (Lucas R.)
                               
                  11/12/2013 - Ajustes na gravacao da crapndb para gravar posicao
                               70,60 (Lucas R.)
                                 
                  14/01/2014 - Alteracao referente a integracao Progress X 
                               Dataserver Oracle 
                               Inclusao do VALIDATE ( Andre Euzebio / SUPERO)       
                                 
                  20/01/2014 - Na critica 182 substituir NEXT por 
                               "RUN fontes/fimprg.p RETURN".
                             - Mover IF  glb_cdcritic <> 0 THEN RETURN para logo apos
                               o run fontes/iniprg.p. (Lucas R.)
                                 
                  12/02/2014 - Ajustes para importar arquivo de debito automatico
                               junto com o de consorcios - Softdesk 128107 (Lucas R)
                                 
                  18/02/2014 - Alterado craptab.cdacesso = "LOTEINT031" para
                               craptab.cdacesso = "LOTEINT032" - Softdesk 131871 
                               (Lucas R.)
                                 
                  04/04/2014 - Retirado craptab do LOTEINT032 e substituido por
                               aux_nrdolote = 6650.
                             - Na craplau adicionado ao create o campo cdempres 
                               (Lucas R)
                                 
                  23/05/2014 - incluido nas consultas da craplau
                               craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                                 
                  03/10/2014 - Alterado lo/proc_batch para log/proc_message.log
                               (Lucas R./Elton)             
                                 
                  24/03/2015 - Criada a function verificaUltDia e chamada sempre
                               que for criado um registro na crapndb ou craplau
                               (SD245218 - Tiago)
                                 
                  30/03/2015 - Alterado gravacao da crapass.cdagenci quando nao 
                               encontrar PA, na critica 961 (Lucas R. #265513)
                                 
                  08/04/2015 - Adicionado a data na frente do log do proc_message
                               (Tiago).   
                  
                  20/04/2015 - Conversão Progress -> Oracle (Odirlei -AMcom)      
                  
                  06/05/2015 - Retirado a gravacao do campo nrcrcard na tabela
                               craplau pois havia problemas de conversao com os 
                               dados que estavam vindo do arquivo FUT e este dado
                               acabava nao sendo usado posteriormente
                               SD282057 (Tiago/Fabricio).		       

                  04/09/2015 - Incluir validacao caso o cooperado esteja demitido 
                               (Lucas Ranghetti #324974)
                                 
                  28/09/2015 - incluido nas consultas da craplau
                               craplau.dsorigem <> "CAIXA" (Lombardi).
    ............................................................................ */
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS647';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrctasic
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Buscar tributos do convenio SICREDI.
    CURSOR cr_crapscn (pr_cdempres crapscn.cdempres%TYPE) IS
      SELECT crapscn.dsnomcnv,
             crapscn.cdempres
        FROM crapscn 
       WHERE crapscn.cdempres = pr_cdempres;
    rw_crapscn cr_crapscn%ROWTYPE;
    
    -- Buscar dados associado.
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrctacns crapass.nrctacns%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.cdagenci,
             crapass.dtdemiss
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrctacns = pr_nrctacns;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar autorizacoes de debito em conta
    CURSOR cr_crapatr (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_cdrefere crapatr.cdrefere%TYPE,
                       pr_cdhistor crapatr.cdhistor%TYPE,
                       pr_cdempres crapatr.cdempres%TYPE) IS
      SELECT crapatr.nrdconta,
             crapatr.dtfimatr,
             crapatr.nmfatura,
             crapatr.ddvencto,
             crapatr.dtiniatr,
             crapatr.rowid
        FROM crapatr
       WHERE crapatr.cdcooper = pr_cdcooper
         AND crapatr.nrdconta = pr_nrdconta
         AND crapatr.cdrefere = pr_cdrefere
         AND crapatr.cdhistor = pr_cdhistor
         AND crapatr.cdempres = pr_cdempres;
    rw_crapatr cr_crapatr%ROWTYPE;
    
    -- Buscar dados Consorcios
    CURSOR cr_crapcns (pr_cdcooper crapcns.cdcooper%TYPE,
                       pr_nrctrato crapcns.nrctrato%TYPE,
                       pr_nrcpfcgc crapcns.nrcpfcgc%TYPE) IS
      SELECT crapcns.nrdconta,
             crapcns.tpconsor,
             crapcns.rowid
        FROM crapcns
       WHERE crapcns.cdcooper = pr_cdcooper
         AND crapcns.nrctrato = pr_nrctrato
         AND crapcns.nrcpfcgc = pr_nrcpfcgc;
    rw_crapcns cr_crapcns%ROWTYPE;
    
    -- Buscar dados de lançamento automatico
    CURSOR cr_craplau (pr_cdcooper craplau.cdcooper%TYPE,
                       pr_dtrefere craplau.dtmvtopg%TYPE,
                       pr_nrdconta craplau.nrdconta%TYPE,
                       pr_cdrefere craplau.nrdocmto%TYPE,
                       pr_cdhistor craplau.cdhistor%TYPE) IS
      SELECT craplau.nrdconta
        FROM craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.dtmvtopg = pr_dtrefere
         AND craplau.nrdconta = pr_nrdconta
         AND craplau.nrdocmto = pr_cdrefere
         AND craplau.cdhistor = pr_cdhistor
         AND craplau.insitlau <> 3;
    rw_craplau cr_craplau%ROWTYPE;
    
    -- Buscar dados de lançamento automatico
    CURSOR cr_craplau2 (pr_cdcooper craplau.cdcooper%TYPE,
                        pr_dtmvtolt craplau.dtmvtolt%TYPE,
                        pr_cdagenci craplau.cdagenci%TYPE,
                        pr_cdbccxlt craplau.cdbccxlt%TYPE,
                        pr_nrdolote craplau.nrdolote%TYPE,
                        pr_nrdconta craplau.nrdconta%TYPE,
                        pr_nrdocmto craplau.nrdocmto%TYPE) IS
      SELECT craplau.nrdconta
        FROM craplau
       WHERE craplau.cdcooper = pr_cdcooper
         AND craplau.dtmvtolt = pr_dtmvtolt
         AND craplau.cdagenci = pr_cdagenci
         AND craplau.cdbccxlt = pr_cdbccxlt
         AND craplau.nrdolote = pr_nrdolote
         AND craplau.nrdconta = pr_nrdconta
         AND craplau.nrdocmto = pr_nrdocmto;
    rw_craplau2 cr_craplau2%ROWTYPE;
    -- Buscar lote
    CURSOR cr_craplot (pr_cdcooper craplot.cdcooper%TYPE,
                       pr_dtmvtolt craplot.dtmvtolt%TYPE,
                       pr_cdagenci craplot.cdagenci%TYPE,
                       pr_cdbccxlt craplot.cdbccxlt%TYPE,
                       pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT craplot.dtmvtolt, 
             craplot.dtmvtopg, 
             craplot.cdagenci,
             craplot.cdbccxlt, 
             craplot.cdbccxpg, 
             craplot.cdhistor,
             craplot.nrdolote, 
             craplot.cdoperad, 
             craplot.tplotmov,
             craplot.nrseqdig,
             craplot.rowid
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = pr_cdbccxlt
         AND craplot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Temp table para armazenar comandos para serem executados ao final do programa
    -- qnd todas as alterações forem commitadas
    TYPE typ_tab_comando IS TABLE OF VARCHAR2(4000)
         INDEX BY PLS_INTEGER; 
    vr_tab_comando typ_tab_comando;
    
    -- temp table para armazenar dados para o relatorio
    TYPE typ_rec_relato IS RECORD 
         (  cdcooper crapcop.cdcooper%TYPE
           ,nrdconta crapcns.nrdconta%TYPE
           ,cdrefere VARCHAR2(25)
           ,vlparcns crapcns.vlparcns%TYPE
           ,nrctacns crapcns.nrctacns%TYPE
           ,dtdebito DATE
           ,cdcritic INTEGER
           ,dscritic VARCHAR2(2000)
           ,tpdebito INTEGER /*  (1 – consorcio 2 – débito automatico) */
           ,nmempres VARCHAR2(500)
           ,cdagenci INTEGER); 
   TYPE typ_tab_relato IS TABLE OF typ_rec_relato
        INDEX BY PLS_INTEGER;
        
   -- temptable para dados ordenados     
   TYPE typ_tab_relato_ord IS TABLE OF typ_rec_relato
        INDEX BY VARCHAR2(40); -- cdcritic(5) + nrdconta(10) + nrctacns(10) + seq(6) 
   vr_tab_relato_ord typ_tab_relato_ord;
        
   -- temptable possui duas camadas para facilitar a quebra por tipo de debito
   TYPE typ_relato IS TABLE OF typ_tab_relato
        INDEX BY PLS_INTEGER;
   vr_tab_relato typ_relato;
    
    ------------------------------- VARIAVEIS -------------------------------
    -- execeptions
    vr_exc_arq        EXCEPTION;
    vr_exc_prox_linha EXCEPTION;
    
    -- Tratamento de arquivo
    vr_input_file    utl_file.file_type;
    vr_setlinha      VARCHAR2(300);
    vr_nmarqimp      VARCHAR2(300);

    -- Lista de arquivos
    vr_tab_nmarquiv  gene0002.typ_split;
    vr_list_arquivos VARCHAR2(10000);
    vr_typ_said      VARCHAR2(100);
    
    -- Caminho dos arquivos Sicredi
    vr_caminho_arq     VARCHAR2(200);
    vr_caminho_arq_rec VARCHAR2(200);
    vr_nmarqmov        VARCHAR2(200);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml         CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_nom_direto  VARCHAR2(100);
    
    -- Variaveis de controle
    vr_flgrejei        BOOLEAN;
    vr_flgdupli        BOOLEAN;
    vr_digitmes        VARCHAR2(5);
    vr_nrdolote        NUMBER;
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_fcrapatr        BOOLEAN;
    vr_fcrapcns        BOOLEAN;
    vr_fcraplau        BOOLEAN;
    vr_fcraplot        BOOLEAN;
    vr_contareg        NUMBER;
    vr_dtmvtolt        DATE;
    vr_qtdlau          NUMBER;
    vr_qtdatr          NUMBER;
    vr_geraerro        BOOLEAN := FALSE;
    
    -- Dados do arquivo
    vr_tpregist        VARCHAR2(5);
    vr_vldebito        NUMBER;
    vr_dtrefere        DATE;
    vr_dtdebito        DATE;
    vr_cdrefere        VARCHAR2(30);
    vr_nmempres        rw_crapscn.dsnomcnv%TYPE;
    vr_cdempres        rw_crapscn.cdempres%TYPE;
    vr_tpdebito        NUMBER;      
    vr_cdhistor        NUMBER;
    vr_vllanaut        NUMBER;
    vr_cdseqtel        VARCHAR2(70);
    
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
      
    -- função para retornar proximo dia util se for ultimo dia do ano
    FUNCTION fn_verificaUltDia ( pr_cdcooper IN INTEGER, 
                                 pr_dtrefere IN DATE) RETURN DATE IS
    BEGIN   
      -- Verificar se é o ultimo dia do ano
      IF pr_dtrefere = last_day(add_months(TRUNC( rw_crapdat.dtmvtolt,'RRRR'),11)) THEN
        -- buscar o proximo dia util
        RETURN gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, 
                                           pr_dtmvtolt => pr_dtrefere + 1, 
                                           pr_tipo     => 'P');
              
      END IF;
      -- senao retorna a data que foi passada como parametro
      RETURN pr_dtrefere;
    END fn_verificaUltDia;
  
    -- criar registro de critica para relatorio
    PROCEDURE pc_registro_relato( pr_cdcooper crapass.cdcooper%TYPE
                                 ,pr_nrdconta crapass.nrdconta%TYPE
                                 ,pr_nrctacns crapass.nrctacns%TYPE
                                 ,pr_cdrefere VARCHAR2
                                 ,pr_vlparcns NUMBER
                                 ,pr_dtdebito DATE
                                 ,pr_cdcritic PLS_INTEGER
                                 ,pr_dscritic VARCHAR2 DEFAULT NULL
                                 ,pr_nmempres rw_crapscn.dsnomcnv%TYPE
                                 ,pr_tpdebito PLS_INTEGER
                                 ,pr_cdagenci crapass.cdcooper%TYPE) IS 
                                 
      vr_dscritic VARCHAR2(4000);
      vr_idx      PLS_INTEGER;
      
    BEGIN
    
      -- Temptable possui duas camadas para facilitar a quebra por tipo de debito
      -- Definir index 
      IF vr_tab_relato.exists(pr_tpdebito)THEN
        vr_idx := vr_tab_relato(pr_tpdebito).count;
      ELSE  
        vr_idx := 0;
      END IF;
      
      IF pr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      ELSE
        vr_dscritic := pr_dscritic;
      END IF;
      
      IF (NOT vr_geraerro) AND (trim(vr_dscritic) IS NOT NULL) THEN
        vr_geraerro := TRUE;
      END IF;  
      
      -- incluir informações
      vr_tab_relato(pr_tpdebito)(vr_idx).cdcooper := pr_cdcooper;
      vr_tab_relato(pr_tpdebito)(vr_idx).nrdconta := pr_nrdconta;
      vr_tab_relato(pr_tpdebito)(vr_idx).nrctacns := pr_nrctacns;
      vr_tab_relato(pr_tpdebito)(vr_idx).cdrefere := pr_cdrefere;
      vr_tab_relato(pr_tpdebito)(vr_idx).vlparcns := pr_vlparcns;
      vr_tab_relato(pr_tpdebito)(vr_idx).dtdebito := pr_dtdebito;
      vr_tab_relato(pr_tpdebito)(vr_idx).cdcritic := pr_cdcritic;
      vr_tab_relato(pr_tpdebito)(vr_idx).dscritic := vr_dscritic;
      vr_tab_relato(pr_tpdebito)(vr_idx).nmempres := pr_nmempres;
      vr_tab_relato(pr_tpdebito)(vr_idx).tpdebito := pr_tpdebito;
      vr_tab_relato(pr_tpdebito)(vr_idx).cdagenci := pr_cdagenci;
      
              
    END pc_registro_relato;
    
    -- Procedimento para geração do relatorio 661
    PROCEDURE pc_rel_661 IS
    
      vr_flgfirst     BOOLEAN;
      vr_tot_qtdrejei NUMBER;
      vr_tot_vlpareje NUMBER;
      vr_tot_qtdreceb NUMBER;
      vr_tot_vlparceb NUMBER;
      vr_tot_qtdinteg NUMBER;
      vr_tot_vlpainte NUMBER;
      vr_idx          VARCHAR2(40);
      
    BEGIN
    
      /* inicia variaveis dos totais como zero */
      vr_flgfirst     := TRUE;
      vr_tot_qtdrejei := 0;
      vr_tot_vlpareje := 0;
      vr_tot_qtdreceb := 0;
      vr_tot_vlparceb := 0;
      vr_tot_qtdinteg := 0;
      vr_tot_vlpainte := 0;
      
      vr_nmarqimp := 'crrl661.lst';
      -- limpar temptable
      vr_tab_relato_ord.delete;
      
      -- Reordenar temptable
      FOR i IN vr_tab_relato(1).first..vr_tab_relato(1).last LOOP
        -- Definir novo index
        vr_idx := lpad(vr_tab_relato(1)(i).cdcritic, 5,'0') || lpad(vr_tab_relato(1)(i).nrdconta,10,'0')||
                  lpad(vr_tab_relato(1)(i).nrctacns,10,'0') || lpad(vr_tab_relato_ord.count,6,'0');
        -- guardar dados ordenado          
        vr_tab_relato_ord(vr_idx) := vr_tab_relato(1)(i);
        
      END LOOP;
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz relato="661" >
                                                            <arquivo dsarquiv="'||vr_nmarqmov||'">');
      
      -- varrer temptable com os dados para o relatorio
      vr_idx := vr_tab_relato_ord.first;
      WHILE vr_idx IS NOT NULL LOOP
        
        /* recebidos */
        vr_tot_qtdreceb := vr_tot_qtdreceb + 1;
        vr_tot_vlparceb := vr_tot_vlparceb + vr_tab_relato_ord(vr_idx).vlparcns;

        /* rejeitados nao considera a critica 739 pois e de cancelamento de debitos */
        IF vr_tab_relato_ord(vr_idx).cdcritic NOT IN(0,739)THEN 
          vr_tot_qtdrejei := vr_tot_qtdrejei + 1;
          vr_tot_vlpareje := vr_tot_vlpareje + vr_tab_relato_ord(vr_idx).vlparcns;
        ELSE  
          /* Integrados */
          vr_tot_qtdinteg := vr_tot_qtdinteg + 1;
          vr_tot_vlpainte := vr_tot_vlpainte + vr_tab_relato_ord(vr_idx).vlparcns;
        END IF;  
        
        pc_escreve_xml('<registro>
                          <nrdconta> '||gene0002.fn_mask_conta(vr_tab_relato_ord(vr_idx).nrdconta) ||' </nrdconta>
                          <nrctacns> '||gene0002.fn_mask_conta(vr_tab_relato_ord(vr_idx).nrctacns) ||' </nrctacns>
                          <cdrefere> '||vr_tab_relato_ord(vr_idx).cdrefere                         ||' </cdrefere>
                          <vlparcns> '||vr_tab_relato_ord(vr_idx).vlparcns                         ||' </vlparcns>
                          <dtdebito> '||to_char(vr_tab_relato_ord(vr_idx).dtdebito,'DD/MM/RRRR')   ||' </dtdebito>
                          <dscritic> '||vr_tab_relato_ord(vr_idx).dscritic                         ||' </dscritic>
                        </registro>');
      
        vr_idx := vr_tab_relato_ord.next(vr_idx);
      END LOOP;
      
      -- Incluir informações dos totalizadores
      pc_escreve_xml('<totais>
                          <tot_qtdreceb>'|| vr_tot_qtdreceb ||' </tot_qtdreceb>
                          <tot_qtdinteg>'|| vr_tot_qtdinteg ||' </tot_qtdinteg>
                          <tot_qtdrejei>'|| vr_tot_qtdrejei ||' </tot_qtdrejei>
                          <tot_vlparceb>'|| vr_tot_vlparceb ||' </tot_vlparceb>
                          <tot_vlpainte>'|| vr_tot_vlpainte ||' </tot_vlpainte>
                          <tot_vlpareje>'|| vr_tot_vlpareje ||' </tot_vlpareje>
                     </totais>');
                     
      -- terminar xml e descarregar buffer               
      pc_escreve_xml('</arquivo></raiz>',TRUE);
      
      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/arquivo/registro'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl661.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml); 
      
    END pc_rel_661;
    
    -- Procedimento para geração do relatorio 673
    PROCEDURE pc_rel_673 IS
    
      vr_flgfirst     BOOLEAN;
      vr_tot_qtdrejei NUMBER;
      vr_tot_vlpareje NUMBER;
      vr_tot_qtdreceb NUMBER;
      vr_tot_vlparceb NUMBER;
      vr_tot_qtdinteg NUMBER;
      vr_tot_vlpainte NUMBER;
      vr_idx          VARCHAR2(40);
      
    BEGIN
    
      /* inicia variaveis dos totais como zero */
      vr_flgfirst     := TRUE;
      vr_tot_qtdrejei := 0;
      vr_tot_vlpareje := 0;
      vr_tot_qtdreceb := 0;
      vr_tot_vlparceb := 0;
      vr_tot_qtdinteg := 0;
      vr_tot_vlpainte := 0;
      
      vr_nmarqimp := 'crrl673.lst';
      -- limpar temptable
      vr_tab_relato_ord.delete;
      
      -- Reordenar temptable
      FOR i IN vr_tab_relato(2).first..vr_tab_relato(2).last LOOP
        -- Definir novo index
        vr_idx := lpad(vr_tab_relato(2)(i).cdcritic, 5,'0') || lpad(vr_tab_relato(2)(i).cdagenci, 5,'0') ||
                  lpad(vr_tab_relato(2)(i).nrdconta,10,'0') || lpad(vr_tab_relato(2)(i).nrctacns,10,'0') || 
                  lpad(vr_tab_relato_ord.count,6,'0');
        -- guardar dados ordenado          
        vr_tab_relato_ord(vr_idx) := vr_tab_relato(2)(i);
        
      END LOOP;
      
      -- Inicializar o CLOB
      vr_des_xml := NULL;
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := NULL;
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz relato="673" >
                                                            <arquivo dsarquiv="'||vr_nmarqmov||'">');
      
      -- varrer temptable com os dados para o relatorio
      vr_idx := vr_tab_relato_ord.first;
      WHILE vr_idx IS NOT NULL LOOP
        
        /* recebidos */
        vr_tot_qtdreceb := vr_tot_qtdreceb + 1;
        vr_tot_vlparceb := vr_tot_vlparceb + vr_tab_relato_ord(vr_idx).vlparcns;

        /* rejeitados nao considera a critica 739 pois e de cancelamento de debitos */
        IF vr_tab_relato_ord(vr_idx).cdcritic NOT IN(0,739)THEN 
          vr_tot_qtdrejei := vr_tot_qtdrejei + 1;
          vr_tot_vlpareje := vr_tot_vlpareje + vr_tab_relato_ord(vr_idx).vlparcns;
        ELSE  
          /* Integrados */
          vr_tot_qtdinteg := vr_tot_qtdinteg + 1;
          vr_tot_vlpainte := vr_tot_vlpainte + vr_tab_relato_ord(vr_idx).vlparcns;
        END IF;  
        
        pc_escreve_xml('<registro>
                          <cdagenci> '||vr_tab_relato_ord(vr_idx).cdagenci                         ||' </cdagenci>
                          <nrdconta> '||gene0002.fn_mask_conta(vr_tab_relato_ord(vr_idx).nrdconta) ||' </nrdconta>
                          <nrctacns> '||gene0002.fn_mask_conta(vr_tab_relato_ord(vr_idx).nrctacns) ||' </nrctacns>
                          <nmempres> '||substr(vr_tab_relato_ord(vr_idx).nmempres,1,20)            ||' </nmempres>
                          <cdrefere> '||vr_tab_relato_ord(vr_idx).cdrefere                         ||' </cdrefere>
                          <vlparcns> '||vr_tab_relato_ord(vr_idx).vlparcns                         ||' </vlparcns>
                          <dtdebito> '||to_char(vr_tab_relato_ord(vr_idx).dtdebito,'DD/MM/RRRR')   ||' </dtdebito>
                          <dscritic> '||vr_tab_relato_ord(vr_idx).dscritic                         ||' </dscritic>
                        </registro>');
      
        vr_idx := vr_tab_relato_ord.next(vr_idx);
      END LOOP;
      
      -- Incluir informações dos totalizadores
      pc_escreve_xml('<totais>
                          <tot_qtdreceb>'|| vr_tot_qtdreceb ||' </tot_qtdreceb>
                          <tot_qtdinteg>'|| vr_tot_qtdinteg ||' </tot_qtdinteg>
                          <tot_qtdrejei>'|| vr_tot_qtdrejei ||' </tot_qtdrejei>
                          <tot_vlparceb>'|| vr_tot_vlparceb ||' </tot_vlparceb>
                          <tot_vlpainte>'|| vr_tot_vlpainte ||' </tot_vlpainte>
                          <tot_vlpareje>'|| vr_tot_vlpareje ||' </tot_vlpareje>
                     </totais>');
                     
      -- terminar xml e descarregar buffer               
      pc_escreve_xml('</arquivo></raiz>',TRUE);
      
      -- Efetuar solicitação de geração de relatório --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/arquivo/registro' --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl661.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Sem parametros
                                 ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 4                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_flg_gerar => 'N'                 --> gerar PDF
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml); 
      
    END pc_rel_673;

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
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
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

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    vr_nrdolote := 6650;

    /* Monta digito do Mes para nome o arquivo SICREDI */
    IF TO_CHAR(rw_crapdat.dtmvtolt,'MM') = 10 THEN
      vr_digitmes := 'O';
    ELSIF TO_CHAR(rw_crapdat.dtmvtolt,'MM') = 11 THEN
      vr_digitmes := 'N';
    ELSIF TO_CHAR(rw_crapdat.dtmvtolt,'MM') = 12 THEN
      vr_digitmes := 'D';
    ELSE
      vr_digitmes := TO_NUMBER(TO_CHAR(rw_crapdat.dtmvtolt,'MM'));
    END IF;  

    vr_nmarqmov := '0'||RPAD('0', 4 - LENGTH(rw_crapcop.nrctasic)) ||
                   TRIM(SUBSTR(rw_crapcop.nrctasic,1,4))           ||
                   vr_digitmes || to_char(rw_crapdat.dtmvtolt,'DD')||'.FUT';
                          
    -- Caminho dos arquivos
    vr_caminho_arq := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_658_RECEBE');
    -- busca o diretorio padrao dos arquivos recebidos e processados
    vr_caminho_arq_rec := gene0001.fn_param_sistema('CRED', pr_cdcooper, 'DIR_658_RECEBIDOS');
    
    -- Retorna a lista dos arquivos
    gene0001.pc_lista_arquivos(pr_path     => vr_caminho_arq
                              ,pr_pesq     => vr_nmarqmov
                              ,pr_listarq  => vr_list_arquivos
                              ,pr_des_erro => vr_dscritic);

    -- Testar saida com erro
    IF vr_list_arquivos IS NULL THEN
      
      -- Tentar buscar com nome em lowercase
      gene0001.pc_lista_arquivos(pr_path     => vr_caminho_arq
                                ,pr_pesq     => lower(vr_nmarqmov)
                                ,pr_listarq  => vr_list_arquivos
                                ,pr_des_erro => vr_dscritic);
      
      IF vr_list_arquivos IS NULL THEN                        
        -- Gerar exceção
        vr_cdcritic := 182;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                       ' Arquivo esperado: '||vr_nmarqmov;
        RAISE vr_exc_fimprg;
      END IF;
      
    END IF;
    
    -- Verifica se retornou arquivos
    IF vr_list_arquivos IS NOT NULL THEN
      -- Listar os arquivos em um array
      vr_tab_nmarquiv := gene0002.fn_quebra_string(pr_string  => vr_list_arquivos, pr_delimit => ','); 
    END IF;
    
    -- ler os arquivos listados
    FOR i IN vr_tab_nmarquiv.first..vr_tab_nmarquiv.last LOOP
      vr_cdcritic := 0;
      vr_vldebito := 0;
    
      vr_flgrejei := FALSE;
      vr_flgdupli := FALSE;
      
      --Abrir o arquivo lido e percorrer as linhas do mesmo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq       --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_tab_nmarquiv(i)  --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro

      -- Verifica se ocorreram problemas na abertura do arquivo
      IF trim(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      vr_contareg := 0;
      
      -------> VALIDAR ARQUIVO <-------
      WHILE TRUE LOOP
        --Controle de Fluxo
        BEGIN
          BEGIN
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --se deu erro de no_data_found é pq não tem mais linhas no arquivo, sair do loop
              raise vr_exc_arq; /* Proximo Arquivo */
          END;
          
          /* somatoria da quantidade de registros no arquivo */
          vr_contareg := vr_contareg + 1;
          
          -- validar data apenas na primeira linha
          IF vr_contareg = 1 THEN
            -- Validar data de referencia
            BEGIN
              vr_dtrefere := TO_DATE(SUBSTR(vr_setlinha,66,8),'RRRRMMDD');
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 13;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
                RAISE vr_exc_arq;                                        
            END;
          END IF;
          
          vr_tpregist := SUBSTR(vr_setlinha,1,1);
    
          IF vr_tpregist NOT IN ('A','C','D','E','Z') THEN
            vr_cdcritic := 468;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_nmarqlog     => 'proc_message' 
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                           || vr_cdprogra || ' --> '
                                                           || vr_dscritic );
             
            vr_cdcritic := 0;
            RAISE vr_exc_prox_linha;
          END IF;
          
          -- se for tipo é e não for primeira linha 
          IF vr_tpregist = 'A' 
             AND vr_contareg <> 1 THEN
            vr_cdcritic := 468;
            -- abortar processo do arquivo
            RAISE vr_exc_arq;
          ELSIF vr_tpregist = 'E' THEN
            vr_vldebito := vr_vldebito + (TO_NUMBER(SUBSTR(vr_setlinha,53,15)) / 100);
            
            BEGIN
              vr_dtrefere := TO_DATE(SUBSTR(vr_setlinha,45,8),'RRRRMMDD');
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 13;
                -- abortar processo do arquivo
                RAISE vr_exc_arq;
            END;   
          -- verificar ultima linha do arquivo      
          ELSIF vr_tpregist = 'Z' THEN
            IF vr_contareg <> TO_NUMBER(SUBSTR(vr_setlinha,2,6)) THEN
              vr_cdcritic := 504;
              -- abortar processo do arquivo
              RAISE vr_exc_arq;            
            ELSIF vr_vldebito <> (to_number(SUBSTR(vr_setlinha,08,17)) / 100) THEN
              vr_cdcritic := 505;
              -- abortar processo do arquivo
              RAISE vr_exc_arq;
            END IF;
          END IF;
        
        EXCEPTION
          WHEN vr_exc_saida THEN
            --Sair do programa
            RAISE vr_exc_saida;
          WHEN vr_exc_prox_linha THEN
            NULL;
          WHEN vr_exc_arq THEN
            --Verificar se arquivo está aberto
            IF utl_file.is_open(vr_input_file) THEN
              --Fechar Arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            END IF;
            --Sair do loop
            EXIT;
        END;  
      END LOOP; -- Fim loop Leitura do arquivo
      
      IF nvl(vr_cdcritic,0) <> 0 AND vr_cdcritic <> 484 THEN
        -- Gera arquivo erro e nao importa para recebidos 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic); 
        
        -- incluir comando na temptable, para ser executado no final
        vr_tab_comando(vr_tab_comando.count) := 'mv '||vr_caminho_arq||'/'|| vr_tab_nmarquiv(i)||' '||
                                                 vr_caminho_arq||'/err'||vr_tab_nmarquiv(i);
                                                 
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'proc_message'
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic ||' err'||vr_tab_nmarquiv(i) );                                         
        RAISE vr_exc_saida;
      END IF;
      
      /************************************************************************/
      /************************ INTEGRA ARQUIVO RECEBIDO **********************/
      /************************************************************************/
      vr_dscritic := gene0001.fn_busca_critica(219);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- sucesso
                                ,pr_nmarqlog     => 'proc_message'
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic ||' recebe/'||vr_tab_nmarquiv(i));
    
      vr_dscritic := NULL;
      vr_cdcritic := 0;
    
      --Abrir o arquivo lido e percorrer as linhas do mesmo
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_arq       --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_tab_nmarquiv(i)  --> Nome do arquivo
                              ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro

      -- Verifica se ocorreram problemas na abertura do arquivo
      IF trim(vr_dscritic) IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;     
      
      -------> PROCESSAR LINHAS <-------
      WHILE TRUE LOOP
        --Controle de Fluxo
        BEGIN
          BEGIN
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              --se deu erro de no_data_found é pq não tem mais linhas no arquivo, sair do loop
              raise vr_exc_arq; /* Proximo Arquivo */
          END;
          
          vr_tpregist := SUBSTR(vr_setlinha,1,1);
          vr_cdcritic := 0;

          IF vr_tpregist IN ('E','D','C') THEN
            vr_cdrefere := SUBSTR(vr_setlinha,2,25);
            
            -- buscar tributo
            OPEN cr_crapscn (pr_cdempres => TRIM(SUBSTR(vr_setlinha,148,10)));
            FETCH cr_crapscn INTO rw_crapscn;
            IF cr_crapscn%FOUND THEN
              vr_nmempres := rw_crapscn.dsnomcnv;
              vr_cdempres := rw_crapscn.cdempres;
            ELSE
              vr_nmempres := NULL;
              vr_cdempres := NULL;
            END IF;
            CLOSE cr_crapscn;
            
            IF TRIM(SUBSTR(vr_setlinha,148,10)) = 'J5' THEN /* Consorcios */
              vr_tpdebito := 1;
              vr_cdhistor := 1230;
            ELSE
              vr_tpdebito := 2;
              vr_cdhistor := 1019;
            END IF;
            
            -- Buscar dados associado.
            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrctacns => SUBSTR(vr_setlinha,31,14));
            FETCH cr_crapass INTO rw_crapass;
            
            IF cr_crapass%NOTFOUND THEN
              CLOSE cr_crapass;
              vr_nrdconta := 0;
              BEGIN
                
                vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                
                INSERT INTO crapndb
                            ( crapndb.dtmvtolt
                             ,crapndb.nrdconta
                             ,crapndb.cdhistor
                             ,crapndb.flgproce
                             ,crapndb.dstexarq
                             ,crapndb.cdcooper)
                     VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                             ,vr_nrdconta                            -- crapndb.nrdconta 
                             ,vr_cdhistor                            -- crapndb.cdhistor 
                             ,0 -- FALSE                             -- crapndb.flgproce
                             ,'F' ||SUBSTR(vr_setlinha, 2,66) || '15'                 ||
                              SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                              SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                              SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                             ,pr_cdcooper);                          -- crapndb.cdcooper       
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              /* nao existe conta consorcio */
              vr_cdcritic := 961;
                        
              -- criar registro de critica para relatorio
              pc_registro_relato( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                 ,pr_cdrefere => vr_cdrefere
                                 ,pr_vlparcns => (CASE vr_tpregist
                                                    WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                    ELSE 0
                                                  END)
                                 ,pr_dtdebito => (CASE vr_tpregist
                                                    WHEN 'E' THEN vr_dtrefere
                                                    ELSE NULL
                                                  END)   
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_nmempres => vr_nmempres
                                 ,pr_tpdebito => vr_tpdebito
                                 ,pr_cdagenci => 0); /* nao precisa ter agencia
                                                        quando nao encontra associado */
            
              RAISE vr_exc_prox_linha;  
            ELSE /* se achou conta na crapass */
              -- armazenar conta para utilizar em seguida
              vr_nrdconta := rw_crapass.nrdconta;
              
              /* Caso o cooperado esteja demitido */
              IF rw_crapass.dtdemiss IS NOT NULL THEN              
                BEGIN
                    
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                    
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '15'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                 
                /* Associado nao cadastrado */
                vr_cdcritic := 09;
                            
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (CASE vr_tpregist
                                                      WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                      ELSE 0
                                                    END)
                                   ,pr_dtdebito => (CASE vr_tpregist
                                                      WHEN 'E' THEN vr_dtrefere
                                                      ELSE NULL
                                                    END)   
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci); 
                
                RAISE vr_exc_prox_linha;
              END IF;              
              -- fechar o cursor aberto anteriormente
              CLOSE cr_crapass;
            END IF;

            /* nao e consorcio <> J5 */
            IF  TRIM(SUBSTR(vr_setlinha,148,10)) <> 'J5' THEN
              -- Buscar autorizacoes de debito em conta
              OPEN cr_crapatr (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => vr_nrdconta,
                               pr_cdrefere => to_number(vr_cdrefere),
                               pr_cdhistor => 1019,
                               pr_cdempres => TRIM(SUBSTR(vr_setlinha,148,10)));
              FETCH cr_crapatr INTO rw_crapatr;
              vr_fcrapatr := cr_crapatr%FOUND; -- guardar se encontrou ou não o registro
              CLOSE cr_crapatr;
              -- senao encontrar registro
              IF NOT vr_fcrapatr THEN
                BEGIN
                    
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                    
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '30'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                
                /* 484 - Contrato nao encontrado. */
                vr_cdcritic := 484;
                            
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (CASE vr_tpregist
                                                      WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                      ELSE 0
                                                    END)
                                   ,pr_dtdebito => (CASE vr_tpregist
                                                      WHEN 'E' THEN vr_dtrefere
                                                      ELSE NULL
                                                    END)   
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
                
                RAISE vr_exc_prox_linha;  
              END IF;
            ELSE  /* se for consorcios J5 */  
              -- Buscar dados Consorcios
              OPEN cr_crapcns (pr_cdcooper => pr_cdcooper,
                               pr_nrctrato => SUBSTR(vr_setlinha,2,8),
                               pr_nrcpfcgc => SUBSTR(vr_setlinha,10,14));
              FETCH cr_crapcns INTO rw_crapcns;
              vr_fcrapcns := cr_crapcns%FOUND;
              CLOSE cr_crapcns;
              
              IF NOT vr_fcrapcns THEN
                BEGIN  
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                    
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '30'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                
                /* 484 - Contrato nao encontrado. */
                vr_cdcritic := 484;
                            
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (CASE vr_tpregist
                                                      WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                      ELSE 0
                                                    END)
                                   ,pr_dtdebito => (CASE vr_tpregist
                                                      WHEN 'E' THEN vr_dtrefere
                                                      ELSE NULL
                                                    END)   
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
                
                RAISE vr_exc_prox_linha; 
              ELSE
                vr_cdcritic := 0;
                CASE rw_crapcns.tpconsor
                  WHEN 1 THEN /* MOTO */
                    vr_cdhistor := 1230; 
                  WHEN 2 THEN /* AUTO */
                    vr_cdhistor := 1231;
                  WHEN 3 THEN /* PESADOS */
                    vr_cdhistor := 1232;
                  WHEN 4 THEN /* IMOVEIS */
                    vr_cdhistor := 1233;
                  WHEN 5 THEN /* SERVICOS */
                    vr_cdhistor := 1234;
                END CASE;
                
                -- Atualizar contrato
                BEGIN
                  UPDATE crapcns
                     SET crapcns.nrdaviso = TO_NUMBER(SUBSTR(vr_setlinha,89,11)),
                         crapcns.nrboleto = TO_NUMBER(SUBSTR(vr_setlinha,70, 9))
                   WHERE crapcns.rowid = rw_crapcns.rowid;  
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar contrato crapcns (rowid:'||rw_crapcns.rowid||'): '||SQLERRM;
                    RAISE vr_exc_saida;   
                END;
              END IF; --FIM IF NOT vr_fcrapcns THEN       
            END IF; 
          END IF; --Fim IF tpregist = "E,C,D"
          
          IF vr_tpregist = 'E' THEN
            
            BEGIN
              vr_dtdebito := TO_DATE(SUBSTR(vr_setlinha,45,8),'RRRRMMDD');
              vr_dtrefere := TO_DATE(SUBSTR(vr_setlinha,45,8),'RRRRMMDD');
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 13;
            END;
            
            IF (vr_dtrefere+30) < rw_crapdat.dtmvtolt THEN
              vr_cdcritic := 13;
            END IF;
            
            IF vr_cdcritic = 13 THEN
              BEGIN  
                vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                    
                INSERT INTO crapndb
                            ( crapndb.dtmvtolt
                             ,crapndb.nrdconta
                             ,crapndb.cdhistor
                             ,crapndb.flgproce
                             ,crapndb.dstexarq
                             ,crapndb.cdcooper)
                     VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                             ,vr_nrdconta                            -- crapndb.nrdconta 
                             ,vr_cdhistor                            -- crapndb.cdhistor 
                             ,0 -- FALSE                             -- crapndb.flgproce
                             ,'F' ||SUBSTR(vr_setlinha, 2,66) || '13'                 ||
                              SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                              SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                              SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                             ,pr_cdcooper);                          -- crapndb.cdcooper       
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
                
              /* 13 - data invalida */
              vr_cdcritic := 13;
                            
              -- criar registro de critica para relatorio
              pc_registro_relato( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta
                                 ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                 ,pr_cdrefere => vr_cdrefere
                                 ,pr_vlparcns => (CASE vr_tpregist
                                                    WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                    ELSE 0
                                                  END)
                                 ,pr_dtdebito => (CASE vr_tpregist
                                                    WHEN 'E' THEN vr_dtrefere
                                                    ELSE NULL
                                                  END)   
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_nmempres => vr_nmempres
                                 ,pr_tpdebito => vr_tpdebito
                                 ,pr_cdagenci => rw_crapass.cdagenci);
                
              RAISE vr_exc_prox_linha;
            END IF; -- Fim cdcritic = 13
            
            /* codigo do movimento 0 = inclusao/1 = cancelamento */
            IF  to_number(SUBSTR(vr_setlinha,158,1)) = 0 THEN
              -- Buscar dados de lançamento automatico
              OPEN cr_craplau (pr_cdcooper => pr_cdcooper,
                               pr_dtrefere => vr_dtrefere,
                               pr_nrdconta => vr_nrdconta,
                               pr_cdrefere => vr_cdrefere,
                               pr_cdhistor => vr_cdhistor);
              FETCH cr_craplau INTO rw_craplau;
              vr_fcraplau := cr_craplau%FOUND;
              CLOSE cr_craplau;
              
              -- se encontrou lançamento
              IF vr_fcraplau THEN
                BEGIN  
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                      
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '04'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                  
                /* 092 - Lancamento ja existe */
                vr_cdcritic := 092;
                              
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (CASE vr_tpregist
                                                      WHEN 'E' THEN (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                                      ELSE 0
                                                    END)
                                   ,pr_dtdebito => (CASE vr_tpregist
                                                      WHEN 'E' THEN vr_dtrefere
                                                      ELSE NULL
                                                    END)   
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
                
                vr_flgdupli := TRUE;
                vr_cdcritic := 0;
                RAISE vr_exc_prox_linha;
              END IF;
              
              -- Buscar lote
              OPEN cr_craplot (pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_cdagenci => 1,
                                 pr_cdbccxlt => 100,
                                 pr_nrdolote => vr_nrdolote);
              FETCH cr_craplot INTO rw_craplot;
              vr_fcraplot := cr_craplot%FOUND;
              CLOSE cr_craplot;
              
              -- se nao encontrou o lote deve criar
              IF NOT vr_fcraplot THEN
                BEGIN
                  INSERT INTO craplot
                              (craplot.dtmvtolt
                              ,craplot.dtmvtopg
                              ,craplot.cdagenci
                              ,craplot.cdbccxlt
                              ,craplot.cdbccxpg
                              ,craplot.cdhistor
                              ,craplot.nrdolote
                              ,craplot.cdoperad
                              ,craplot.tplotmov
                              ,craplot.tpdmoeda
                              ,craplot.cdcooper)
                       VALUES( rw_crapdat.dtmvtolt -- craplot.dtmvtolt
                              ,rw_crapdat.dtmvtopr -- craplot.dtmvtopg
                              ,1                   -- craplot.cdagenci
                              ,100                 -- craplot.cdbccxlt
                              ,11                  -- craplot.cdbccxpg
                              ,vr_cdhistor         -- craplot.cdhistor
                              ,vr_nrdolote         -- craplot.nrdolote
                              ,1                   -- craplot.cdoperad
                              ,12                  -- craplot.tplotmov
                              ,1                   -- craplot.tpdmoeda
                              ,pr_cdcooper)        -- craplot.cdcooper
                     RETURNING craplot.dtmvtolt, craplot.dtmvtopg, craplot.cdagenci,
                               craplot.cdbccxlt, craplot.cdbccxpg, craplot.cdhistor,
                               craplot.nrdolote, craplot.cdoperad, craplot.tplotmov,
                               craplot.rowid
                          INTO rw_craplot.dtmvtolt, rw_craplot.dtmvtopg, rw_craplot.cdagenci,
                               rw_craplot.cdbccxlt, rw_craplot.cdbccxpg, rw_craplot.cdhistor,
                               rw_craplot.nrdolote, rw_craplot.cdoperad, rw_craplot.tplotmov,
                               rw_craplot.rowid;   
        
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                END;
              END IF; -- Fim IF NOT vr_fcraplot
              
              -- Buscar dados de lançamento automatico
              OPEN cr_craplau2 (pr_cdcooper => pr_cdcooper,
                                pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                pr_cdagenci => rw_craplot.cdagenci,
                                pr_cdbccxlt => rw_craplot.cdbccxlt,
                                pr_nrdolote => vr_nrdolote,
                                pr_nrdconta => vr_nrdconta,
                                pr_nrdocmto => vr_cdrefere);
              FETCH cr_craplau2 INTO rw_craplau2;
              -- se localizou o lançamento
              IF cr_craplau2%FOUND THEN
                /* 103 - Lancamento automatico ja efetuado. */
                vr_cdcritic := 103;
                              
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                   ,pr_dtdebito => vr_dtrefere
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
                
                vr_cdcritic := 0;
                CLOSE cr_craplau2;
                RAISE vr_exc_prox_linha;
              ELSE
                CLOSE cr_craplau2;
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                   ,pr_dtdebito => vr_dtrefere
                                   ,pr_cdcritic => 0
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
              END IF; -- FIM IF cr_craplau2%FOUND THEN
              
              vr_vllanaut := SUBSTR(vr_setlinha,53,15);
              vr_cdseqtel := SUBSTR(vr_setlinha,70,60);
              
              -- atualizar valores na craplot
              BEGIN
                  UPDATE craplot
                     SET craplot.nrseqdig = craplot.nrseqdig + 1,
                         craplot.qtcompln = craplot.qtcompln + 1,
                         craplot.qtinfoln = craplot.qtinfoln + 1,
                         craplot.vlcompdb = craplot.vlcompdb + (vr_vllanaut / 100),
                         craplot.vlcompcr = 0,
                         craplot.vlinfodb = craplot.vlcompdb + (vr_vllanaut / 100),
                         craplot.vlinfocr = 0
                   WHERE craplot.rowid = rw_craplot.rowid
               RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;  
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar craplot(rowid = '||rw_craplot.rowid||'): '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              
              -- Gravar lançamento automatico
              BEGIN
                vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, vr_dtrefere);
                INSERT INTO craplau 
                            (craplau.cdcooper
                            ,craplau.dtmvtopg
                            ,craplau.cdagenci
                            ,craplau.cdbccxlt
                            ,craplau.cdbccxpg
                            ,craplau.cdhistor
                            ,craplau.dtmvtolt
                            ,craplau.insitlau
                            ,craplau.nrdconta
                            ,craplau.nrdctabb
                            ,craplau.nrdolote
                            ,craplau.nrseqdig
                            ,craplau.tpdvalor
                            ,craplau.vllanaut
                            ,craplau.nrdocmto                            
                            ,craplau.cdseqtel
                            ,craplau.cdempres
                            ,craplau.dscedent
                            ,craplau.dttransa
                            ,craplau.hrtransa)
                     VALUES (pr_cdcooper            -- craplau.cdcooper
                            ,vr_dtmvtolt            -- craplau.dtmvtopg
                            ,rw_craplot.cdagenci    -- craplau.cdagenci
                            ,rw_craplot.cdbccxlt    -- craplau.cdbccxlt
                            ,rw_craplot.cdbccxpg    -- craplau.cdbccxpg
                            ,vr_cdhistor            -- craplau.cdhistor
                            ,rw_craplot.dtmvtolt    -- craplau.dtmvtolt
                            ,1                      -- craplau.insitlau
                            ,vr_nrdconta            -- craplau.nrdconta
                            ,vr_nrdconta            -- craplau.nrdctabb
                            ,rw_craplot.nrdolote    -- craplau.nrdolote
                            ,rw_craplot.nrseqdig    -- craplau.nrseqdig
                            ,1                      -- craplau.tpdvalor
                            ,vr_vllanaut / 100      -- craplau.vllanaut
                            ,vr_cdrefere            -- craplau.nrdocmto
                            ,vr_cdseqtel            -- craplau.cdseqtel
                            ,vr_cdempres            -- craplau.cdempres
                            ,vr_nmempres            -- craplau.dscedent
                            ,rw_crapdat.dtmvtolt    -- craplau.dttransa
                            ,gene0002.fn_busca_time);    -- craplau.hrtransa   
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir craplau: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
              
            ELSE  /* CANCELAMENTO */
              BEGIN
                UPDATE craplau
                   SET craplau.dtdebito = rw_crapdat.dtmvtolt,
                       craplau.insitlau = 3
                 WHERE craplau.cdcooper = pr_cdcooper
                   AND craplau.dtmvtopg = vr_dtrefere
                   AND craplau.nrdconta = vr_nrdconta
                   AND craplau.nrdocmto = vr_cdrefere
                   AND craplau.insitlau <> 3;
                   
                vr_qtdlau := SQL%ROWCOUNT;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar craplau(nrdconta = '||vr_nrdconta||
                                                          ' nrdocmto = '||vr_cdrefere||'): '||SQLERRM;
                  RAISE vr_exc_saida; 
              END;   
              
              -- Verificar se conseguiu alterar algum registro
              IF nvl(vr_qtdlau,0) > 0 THEN                
                BEGIN  
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                      
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '99'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                  
                /* 739 - Lancamento de Debito Cancelado. */
                vr_cdcritic := 739;
                              
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                   ,pr_dtdebito => vr_dtrefere
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
                
              ELSE -- Senão alterou nenhum registro
                BEGIN  
                  vr_dtmvtolt := fn_verificaUltDia(pr_cdcooper, rw_crapdat.dtmvtopr);
                      
                  INSERT INTO crapndb
                              ( crapndb.dtmvtolt
                               ,crapndb.nrdconta
                               ,crapndb.cdhistor
                               ,crapndb.flgproce
                               ,crapndb.dstexarq
                               ,crapndb.cdcooper)
                       VALUES ( vr_dtmvtolt                            -- crapndb.dtmvtolt
                               ,vr_nrdconta                            -- crapndb.nrdconta 
                               ,vr_cdhistor                            -- crapndb.cdhistor 
                               ,0 -- FALSE                             -- crapndb.flgproce
                               ,'F' ||SUBSTR(vr_setlinha, 2,66) || '97'                 ||
                                SUBSTR(vr_setlinha, 70,60) || lpad(' ',16,' ')          ||
                                SUBSTR(vr_setlinha,140, 2) ||SUBSTR(vr_setlinha,148,10) ||
                                SUBSTR(vr_setlinha,158, 1) ||'  '      -- crapndb.dstexarq                
                               ,pr_cdcooper);                          -- crapndb.cdcooper       
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir crapndb: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                  
                /* 501 - Lancamento nao encontrado no craplau. */
                vr_cdcritic := 501;
                              
                -- criar registro de critica para relatorio
                pc_registro_relato( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                                   ,pr_cdrefere => vr_cdrefere
                                   ,pr_vlparcns => (to_number(SUBSTR(vr_setlinha,53,15)) / 100)
                                   ,pr_dtdebito => vr_dtrefere
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_nmempres => vr_nmempres
                                   ,pr_tpdebito => vr_tpdebito
                                   ,pr_cdagenci => rw_crapass.cdagenci);
              
              END IF;-- FIM IF nvl(vr_qtdlau,0) > 0              
            END IF;
            -- proximo registro
            continue;    
          ELSIF  vr_tpregist = 'C' THEN
            -- criar registro de critica para relatorio
            pc_registro_relato( pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                               ,pr_cdrefere => vr_cdrefere
                               ,pr_vlparcns => 0
                               ,pr_dtdebito => NULL
                               ,pr_cdcritic => 0
                               ,pr_dscritic => SUBSTR(vr_setlinha,45,40)
                               ,pr_nmempres => vr_nmempres
                               ,pr_tpdebito => vr_tpdebito
                               ,pr_cdagenci => rw_crapass.cdagenci);
                               
            IF vr_fcrapatr AND SUBSTR(vr_setlinha,158,1) <> '1'   THEN
              -- atualizar data fim da autorizacao de debito em conta
              BEGIN 
                UPDATE crapatr
                   SET crapatr.dtfimatr = crapatr.dtiniatr
                 WHERE crapatr.rowid = rw_crapatr.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar crapatr: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;  
            END IF;            
            -- processar proximo registro
            continue;
            -- Fim do registro "C"
            
          ELSIF vr_tpregist = 'D' THEN  
            -- criar registro de critica para relatorio
            pc_registro_relato( pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_nrdconta
                               ,pr_nrctacns => SUBSTR(vr_setlinha,31,14)
                               ,pr_cdrefere => SUBSTR(vr_setlinha,45,25)
                               ,pr_vlparcns => 0
                               ,pr_dtdebito => NULL
                               ,pr_cdcritic => 0
                               ,pr_nmempres => vr_nmempres
                               ,pr_tpdebito => vr_tpdebito
                               ,pr_dscritic => SUBSTR(vr_setlinha,70,60)
                               ,pr_cdagenci => rw_crapass.cdagenci);
                               
            IF TRIM(SUBSTR(vr_setlinha,148,10)) <> 'J5' THEN 
              IF SUBSTR(vr_setlinha,158,1) = 1 THEN
                IF rw_crapatr.dtfimatr IS NULL THEN
                  -- atualizar data fim da autorizacao de debito em conta
                  BEGIN 
                    UPDATE crapatr
                       SET crapatr.dtfimatr = rw_crapdat.dtmvtolt
                     WHERE crapatr.rowid = rw_crapatr.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar crapatr: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF;  
              ELSIF SUBSTR(vr_setlinha,158,1) = 0 THEN
                -- Atualizar data fim da autorizacao de debito em conta
                BEGIN 
                  UPDATE crapatr
                     SET crapatr.dtfimatr = NULL -- Tirar cancelamento
                   WHERE crapatr.cdcooper = pr_cdcooper
                     AND crapatr.nrdconta = vr_nrdconta
                     AND crapatr.cdhistor = 1019
                     AND crapatr.cdrefere = SUBSTR(vr_setlinha, 45, 25);
                     
                     vr_qtdatr := SQL%ROWCOUNT;
                     
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar crapatr: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                 
                -- se não alterou nenhum registro, deve criar novo
                IF vr_qtdatr = 0 THEN
                  BEGIN
                    INSERT INTO crapatr 
                                 ( crapatr.nrdconta
                                  ,crapatr.cdrefere
                                  ,crapatr.cddddtel
                                  ,crapatr.cdhistor
                                  ,crapatr.ddvencto
                                  ,crapatr.dtiniatr
                                  ,crapatr.dtultdeb
                                  ,crapatr.nmfatura
                                  ,crapatr.dtfimatr
                                  ,crapatr.cdcooper)
                          VALUES ( rw_crapatr.nrdconta       -- crapatr.nrdconta
                                  ,SUBSTR(vr_setlinha,45,25) -- crapatr.cdrefere  
                                  ,0                         -- crapatr.cddddtel  
                                  ,vr_cdhistor               -- crapatr.cdhistor  
                                  ,rw_crapatr.ddvencto       -- crapatr.ddvencto  
                                  ,rw_crapatr.dtiniatr       -- crapatr.dtiniatr  
                                  ,NULL                      -- crapatr.dtultdeb  
                                  ,rw_crapatr.nmfatura       -- crapatr.nmfatura  
                                  ,rw_crapatr.dtfimatr       -- crapatr.dtfimatr  
                                  ,pr_cdcooper);             -- crapatr.cdcooper  
          
                  END;
                END IF;
                 
                -- Encerrar autorizacao de debito em conta atual
                BEGIN 
                  UPDATE crapatr
                     SET crapatr.dtfimatr = rw_crapdat.dtmvtolt
                   WHERE crapatr.rowid = rw_crapatr.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar crapatr: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
                 
                -- Verifica se existe lancamento automatico para a fatura e atualiza o numero
                BEGIN
                  UPDATE craplau
                     SET craplau.nrdocmto =  SUBSTR(vr_setlinha,45,25)
                   WHERE craplau.cdcooper = pr_cdcooper
                     AND craplau.nrdconta = rw_crapatr.nrdconta
                     AND craplau.dtmvtolt >= rw_crapdat.dtmvtolt
                     AND craplau.nrdocmto = SUBSTR(vr_setlinha, 2, 25)
                     AND craplau.insitlau = 1
                     AND craplau.dsorigem NOT IN ('CAIXA','INTERNET','TAA','PG555','CARTAOBB','BLOQJUD','DAUT BANCOOB');
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar craplau(nrdconta = '||rw_crapatr.nrdconta||'): '||SQLERRM;
                    RAISE vr_exc_saida;
                END;
              END IF; -- Fim IF SUBSTR(vr_setlinha,158,1) = 0 
            END IF;
             
            -- Proximo registro
            continue;
            -- Fim do registro "D"
          END IF; --Fim IF tpregist = E
          
          /* Critica de lancamento ja existente */
          IF vr_flgdupli THEN
            -- 740 - Lancamento de Debito ja Existente.
            vr_dscritic := gene0001.fn_busca_critica(740);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'proc_message'
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' --> recebe/'||  vr_tab_nmarquiv(i));
          END IF;
          
          -- se nao houver erro importa arquivo e exibe critica 190
          IF NOT vr_geraerro THEN
            -- incluir comando na temptable, para ser executado no final
            vr_tab_comando(vr_tab_comando.count) := 'mv '||vr_caminho_arq     ||'/'|| vr_tab_nmarquiv(i)||' '||
                                                           vr_caminho_arq_rec ||'/'|| vr_tab_nmarquiv(i);
                                                           
            -- 190 - ARQUIVO INTEGRADO COM SUCESSO
            vr_dscritic := gene0001.fn_busca_critica(190);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'proc_message'
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' --> recebe/'||  vr_tab_nmarquiv(i));
                                                                                                      
          ELSE -- se houver erro importa arquivo e exibe critica 191
            -- incluir comando na temptable, para ser executado no final
            vr_tab_comando(vr_tab_comando.count) := 'mv '||vr_caminho_arq     ||'/'|| vr_tab_nmarquiv(i)||' '||
                                                           vr_caminho_arq_rec ||'/'|| vr_tab_nmarquiv(i);
                                                           
            -- 191 - ARQUIVO INTEGRADO COM REJEITADOS
            vr_dscritic := gene0001.fn_busca_critica(191);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => 'proc_message'
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic || ' --> recebe/'||  vr_tab_nmarquiv(i));
          END IF;
          
      EXCEPTION
          WHEN vr_exc_saida THEN
            --Sair do programa
            RAISE vr_exc_saida;
          WHEN vr_exc_prox_linha THEN
            NULL;
          WHEN vr_exc_arq THEN
            --Verificar se arquivo está aberto
            IF utl_file.is_open(vr_input_file) THEN
              --Fechar Arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            END IF;
            --Sair do loop
            EXIT;
        END;  
      END LOOP; -- Fim loop Leitura do arquivo
          
    END LOOP; -- Fim loop arquivos
    
    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
    IF vr_tab_relato.exists(1) THEN
      pc_rel_661; /* Consorcios */
    END IF;
    
    IF vr_tab_relato.exists(2) THEN
      pc_rel_673; /* Importacao de debitos */
    END IF;
    
    
    -- executar comandos no sistema operacional identificados no processo
    FOR i IN vr_tab_comando.first..vr_tab_comando.last LOOP
      
      gene0001.pc_OScommand_Shell(pr_des_comando => vr_tab_comando(i)
                                  ,pr_typ_saida   => vr_typ_said
                                  ,pr_des_saida   => vr_dscritic);
      -- Testar erro
      IF vr_typ_said = 'ERR' THEN
        -- O comando shell executou com erro, gerar log e sair do processo
        vr_dscritic := 'Erro ao executar comando:'||vr_dscritic;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'proc_message'
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
    
    END LOOP;
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
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
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
  END pc_crps647;
/

