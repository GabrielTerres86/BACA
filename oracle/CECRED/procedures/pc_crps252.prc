CREATE OR REPLACE PROCEDURE CECRED.pc_crps252 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_cdprogra IN VARCHAR2                --> Nome do programa
                                              ,pr_stprogra IN OUT PLS_INTEGER         --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps252 (Fontes/crps252.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Tiago Machado Flor
       Data    : Setembro/2015                     Ultima atualizacao: 15/09/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atende a solicitacao 1.
                   Integrar arquivos de DOC's/Depositos do BANCOOB .
                   Emite relatorio 205.

       Alteracoes: 04/01/1999 - Alterado para tratar tipo de documento 07 (Edson).
   
               12/01/1999 - Criado historico 319 para os documentos com tipo 7
                            (Deborah).
                            
               17/06/1999 - Criado historico 339 para creditos de seguro saude
                            sul america (Odair)

               18/06/1999 - Alterar relatorio (Odair).

               24/11/1999 - Passar a integrar arquivos de DEPOSITO ENTRE COOP.
                            (Odair)

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               14/04/2000 - Utilizar o numero da agencia do crapcop (Edson).

               26/05/2000 - Tratar tabela CNVBANCOOB (Odair)
               
               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               12/12/2000 - Consistir dados dos DOC's  "D" (Eduardo).

               24/01/2001 - Comparar somente 3 posicoes no nome do arquivo 
                            (Deborah)

               20/03/2001 - Acerto na numeracao dos lotes (Deborah).
               
               15/05/2001 - Conferir a data de referencia dos arquivos da 
                            compensacao Bancoob. (Ze Eduardo).
                            
               06/06/2001 - Atualizar novos campos do craplcm para
                            atender circular 3030 (Margarete).

               23/08/2002 - Alterar para o script/compefora (Margarete).
                
               16/09/2002 - Comparar o cpf se o tipo de doc for 4 (Ze Eduardo).
                            line = 527.

               20/01/2003 - Mostrar os CPF quando der a critica 301 (Deborah)

               07/02/2003 - Tratar restituicao de IRenda (Deborah).

               09/05/2003 - Tratar depositos em cheques (Edson).
               
               19/09/2003 - Imprimir CPF (Fernando).

               13/02/2004 - Nao aceitar valor Maior ou Igual a 5000(Mirtes) 
                   
               22/04/2004 - Rejeitar Doc Bancoob exceto Receita Federal. (Ze)

               10/05/2004 - Rejeiar Doc.Bancoob quando Credifiesc(Mirtes).
               
               30/06/2005 - Alimentado campo cdcooper  das tabelas craprej,
                            craplot, craplcm e crapdpb (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               17/05/2007 - Acerto no CREATE craplot e Totais (Ze).

               06/06/2007 - Tratar DOC E nos mesmo modelo do DOC C (Ze).

               04/07/2007 - Manda email para karina, joice e tavares qdo nao
                            existe arquivo para ser integrado (Elton).

               27/08/2007 - Retirado envio email(Guilherme).

               11/09/2007 - Incluir TEC Bancoob (Ze).

               09/04/2008 - Alterado para nao gerar criticas, quando for DOC "D"
                            e a conta ter mais de uma titularidade (Elton).

               15/09/2008 - Inserido no-error no assign da linha 549, caso
                            ocorrorer erro, gerar log em proc_batch.log
                            (Gabriel).

               18/01/2010 - Incluida validacao para TECs recebidas pela COMPE
                            (Elton).

               08/12/2010 - Condicoes Transferencia de PAC e novo relat 203_99
                            (Guilherme/Supero)
                            
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)             
               
               09/12/2011 - Excluído e-mail: - fabiano@viacredi.coop.br (Tiago).
               
               04/04/2012 - Nao integrar DOC Bancoob (exceto TEC) a partir de
                            02/05/2012 - conforme Trf. 46080 (Ze). 
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               20/12/2012 - Adaptacao para Migracao AltoVale (Ze).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/10/2013 - Retirado o "new" e comentarios de teste (Adriano).
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
               
               17/01/2014 - Inclusao de VALIDATE craprej, craplot, craplcm e 
                            crapdpb (Carlos)
               
               01/07/2014 - Substituido e-mail 
                            "juliana.carla@viacredialtovale.coop.br"
                            para
                            "suporte@viacredialtovale.coop.br"  (Daniele).
               
               10/03/2015 - Alterado para que todos registro entrem na condicao
                            de DOC NAO ACEITO - 798 (SD174586 - Tiago).
                            
               18/09/2015 - Conversao de crps252.p(Progress) para Oracle (Tiago).
               
               20/02/2017 - #551202 Log de início, erros e fim da execução do programa (Carlos)
               
               15/09/2017 - #753383 O programa estava sobrescrevendo o caminho do integra para 
                            o diretório da cooperativa no momento que gerava o relatório da
                            primeira integração (Carlos)

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT VARCHAR2(40) := pr_cdprogra;

      vr_dsdireto   VARCHAR2(200);
      vr_dsdircop   VARCHAR2(200);
      vr_dsdirarq   VARCHAR2(200);                                     --> Caminho e nome do arquivo      
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv      
      vr_listarq    VARCHAR2(4000);
      vr_tabarqs    gene0002.typ_split;      
      vr_tab_linhas gene0009.typ_tab_linhas;
      vr_indice     PLS_INTEGER;
      vr_indice2    PLS_INTEGER;
      vr_dtlibera   DATE;
      vr_qtddiaut   PLS_INTEGER;
      vr_dstextab   craptab.dstextab%TYPE;

      vr_cdbancob   VARCHAR2(3);
      vr_cdageban   VARCHAR2(20);
      vr_nmarqdep   VARCHAR2(200);
      vr_nmarqdoc   VARCHAR2(200);
      vr_nmarqimp   VARCHAR2(200);
      vr_dtauxili   DATE;
      vr_contareg   PLS_INTEGER;
      vr_tpdedocs   VARCHAR2(1);
      --vr_tipdocto   PLS_INTEGER;
      vr_cdpesqbb   VARCHAR2(50);
      vr_cdhistor   PLS_INTEGER;

      vr_flgrejei   PLS_INTEGER;
      vr_flgrej99   PLS_INTEGER;
      vr_vlcredit   NUMBER(25,2);
      vr_qtcompln   INTEGER;
      vr_vlcompcr   NUMBER(25,2);
      vr_qtregrec   INTEGER;
      vr_vlregrec   NUMBER(25,2);
      
      vr_dshistor   craprej.dshistor%TYPE;
      vr_nrdolote   craplot.nrdolote%TYPE;
      vr_flagstco   PLS_INTEGER;
      vr_cdempres   PLS_INTEGER;
      flg_nmarqdoc  PLS_INTEGER;
      flg_dpcheque  PLS_INTEGER;
      flg_detalhes  PLS_INTEGER;
      vr_stsnrcal   BOOLEAN;
      vr_inpessoa   PLS_INTEGER;

      vr_dscpfcgc   VARCHAR2(18);

      vr_des_xml    CLOB;            -- Dados do XML
      vr_Bufdes_xml VARCHAR2(32000); -- Dados relatorio

      vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;

      --Variaveis pertencentes ao layout d(DETAIL) do arquivo
      lt_d_cdcmpdst   NUMBER(3);
      lt_d_nrcodban   NUMBER(3);
      lt_d_nragedst   NUMBER(4);
      lt_d_dvagedst   VARCHAR2(1); 
      lt_d_nrctbdst   NUMBER(13);
      lt_d_nrdocmto   NUMBER(6);
      lt_d_vldocmto   NUMBER(18,2);
      lt_d_nmdestin   VARCHAR2(40);
      lt_d_cpfcgcds   NUMBER(14); 
      lt_d_tpctadst   NUMBER(2); 
      lt_d_cdfinali   NUMBER(2);
      lt_d_atributo   VARCHAR2(11);
      lt_d_cdcmpori   NUMBER(3);
      lt_d_nrbanori   NUMBER(3);
      lt_d_nrageori   NUMBER(4);
      lt_d_dvageori   VARCHAR2(1); 
      lt_d_nrctarem   NUMBER(13);
      lt_d_nmaprese   VARCHAR2(40);
      lt_d_cpfcgcap   NUMBER(14);
      lt_d_tpoctaap   NUMBER(2);
      lt_d_ufbancap   VARCHAR2(2); 
      lt_d_tipdocto   NUMBER(1);
      lt_d_controle   VARCHAR2(6); 
      lt_d_dtmvtolt   DATE; 
      lt_d_verarqui   NUMBER(7);
      lt_d_indocorr   NUMBER(3);
      lt_d_cdmotdev   NUMBER(2);
      lt_d_nrsequen   NUMBER(6);


      -- Tratamento de erros
      vr_des_erro   VARCHAR2(4000);
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dscriti2   crapcri.dscritic%TYPE;
      vr_typ_saida  VARCHAR2(4000); 

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.cdagebcb
              ,cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT *
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_craptco(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN craptco.nrdconta%TYPE) IS
        SELECT 1
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcooper
           AND tco.nrctaant = pr_nrdconta
           AND tco.tpctatrf = 1
           AND tco.flgativo = 1
           AND ROWNUM = 1; --pegar apenas uma linha

      CURSOR cr_craptrf(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN craptco.nrdconta%TYPE) IS
        SELECT *
          FROM craptrf
         WHERE craptrf.cdcooper = pr_cdcooper AND
               craptrf.nrdconta = pr_nrdconta AND
               craptrf.tptransa = 1;
               
      rw_craptrf cr_craptrf%ROWTYPE;         
      
      CURSOR cr_craplot(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplot.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
        SELECT craplot.rowid, craplot.* 
          FROM craplot 
         WHERE craplot.cdcooper = pr_cdcooper AND
               craplot.dtmvtolt = pr_dtmvtolt AND
               craplot.cdagenci = pr_cdagenci AND
               craplot.cdbccxlt = pr_cdbccxlt AND
               craplot.nrdolote = pr_nrdolote;
               
      rw_craplot cr_craplot%ROWTYPE;         
      
      CURSOR cr_craplcm(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                       ,pr_cdagenci IN craplcm.cdagenci%TYPE
                       ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                       ,pr_nrdolote IN craplcm.nrdolote%TYPE
                       ,pr_nrdctabb IN craplcm.nrdconta%TYPE
                       ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT *
          FROM craplcm 
         WHERE craplcm.cdcooper = pr_cdcooper   AND
               craplcm.dtmvtolt = pr_dtmvtolt   AND
               craplcm.cdagenci = pr_cdagenci   AND
               craplcm.cdbccxlt = pr_cdbccxlt   AND
               craplcm.nrdolote = pr_nrdolote   AND
               craplcm.nrdctabb = pr_nrdctabb   AND
               craplcm.nrdocmto = pr_nrdocmto;
               
      rw_craplcm cr_craplcm%ROWTYPE;         
      
      CURSOR cr_craprej(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtrefere IN DATE) IS
        SELECT *
          FROM craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.dtrefere = TO_CHAR(pr_dtrefere,'DD/MM/RRRR')
         ORDER BY rej.nrdconta;           
         
      CURSOR cr_craprej_999(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtrefere IN DATE) IS
        SELECT *
          FROM craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.dtrefere = TO_CHAR(pr_dtrefere,'DD/MM/RRRR')
           AND rej.cdcritic = 999
         ORDER BY rej.nrdconta;           
         
             
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      --------------------------- SUBROTINAS INTERNAS --------------------------
      PROCEDURE gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdprogra IN VARCHAR2
                        ,pr_indierro IN PLS_INTEGER
                        ,pr_cdcritic IN crapcri.cdcritic%TYPE
                        ,pr_dscritic IN crapcri.dscritic%TYPE) IS
      BEGIN

          -- Buscar a descrição
        vr_dscriti2 := TRIM(gene0001.fn_busca_critica(pr_cdcritic, pr_dscritic));
        
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => TO_CHAR(sysdate,'hh24:mi:ss')||' - '
                                                   || pr_cdprogra || ' --> '
                                                   || vr_dscriti2 || ' (' || TO_CHAR(pr_indierro) || ')'
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => pr_cdprogra);
        
      EXCEPTION
        WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Problemas com geracao de Log';
            RAISE vr_exc_saida;
      END gera_log;
      
      PROCEDURE inserir_rejeitados(pr_cdcooper IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                                  ,pr_dtrefere IN crapdat.dtmvtolt%TYPE
                                  ,pr_dshistor IN craprej.dshistor%TYPE
                                  ,pr_nrdocmto IN craprej.nrdocmto%TYPE
                                  ,pr_vllanmto IN craprej.vllanmto%TYPE
                                  ,pr_nrseqdig IN craprej.nrseqdig%TYPE
                                  ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE
                                  ,pr_indebcre IN craprej.indebcre%TYPE
                                  ,pr_vldaviso IN craprej.vldaviso%TYPE                                 
                                  ,pr_cdcritic IN OUT crapcri.cdcritic%TYPE
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
      BEGIN
        INSERT 
          INTO craprej(dtrefere ,nrdconta
                      ,dshistor ,nrdocmto
                      ,vllanmto ,nrseqdig
                      ,cdpesqbb ,cdcooper
                      ,indebcre ,cdcritic
                      ,vldaviso)
          VALUES(TO_CHAR(pr_dtrefere,'DD/MM/RRRR'),pr_nrdconta
                ,pr_dshistor ,pr_nrdocmto
                ,pr_vllanmto ,pr_nrseqdig
                ,pr_cdpesqbb ,pr_cdcooper
                ,pr_indebcre ,pr_cdcritic
                ,pr_vldaviso);
                
          pr_cdcritic := 0;
          pr_dscritic := NULL;
      EXCEPTION
        WHEN OTHERS THEN          
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao inserir registro na tabela craprej';
      END inserir_rejeitados;
      
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                               pr_fimarq    IN BOOLEAN default false) IS
      BEGIN
        --Verificar se ja atingiu o tamanho do buffer, ou se é o final do xml
        IF length(vr_Bufdes_xml) + length(pr_des_dados) > 31000 OR pr_fimarq THEN
          --Escrever no arquivo XML
          dbms_lob.writeappend(vr_des_xml,length(vr_Bufdes_xml||pr_des_dados),vr_Bufdes_xml||pr_des_dados);
          vr_Bufdes_xml := null;
        ELSE
          --armazena no buffer
          vr_Bufdes_xml := vr_Bufdes_xml||pr_des_dados;
        END IF;
      END pc_escreve_xml;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Início de execução do programa
      cecred.pc_log_programa(PR_DSTIPLOG   => 'I', 
                             PR_CDPROGRAMA => vr_cdprogra, 
                             pr_cdcooper   => pr_cdcooper,
                             PR_IDPRGLOG   => vr_idprglog);

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS252'
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
                               ,pr_cdprogra => 'CRPS252'
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_nmsubdir => 'integra');
      
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdireto 
                                ,pr_pesq     => '3' || TO_CHAR(rw_crapcop.cdagebcb,'fm0000') || '%.RT%'  
                                ,pr_listarq  => vr_listarq 
                                ,pr_des_erro => vr_des_erro);      
                                
      --Ocorreu um erro no lista_arquivos
      IF TRIM(vr_des_erro) IS NOT NULL THEN
         vr_cdcritic := 0;
         vr_dscritic := vr_des_erro;
         RAISE vr_exc_saida;
      END IF;  
      
      --Nao encontrou nenhuma arquivo para processar
      IF TRIM(vr_listarq) IS NULL THEN
         vr_cdcritic := 182;
         vr_dscritic := NULL;
         RAISE vr_exc_fimprg;
      END IF;  
      
      vr_tabarqs := gene0002.fn_quebra_string(pr_string => vr_listarq, pr_delimit => ',');
      
      IF vr_tabarqs.count = 0 THEN
         vr_cdcritic := 182;
         vr_dscritic := NULL;
         RAISE vr_exc_fimprg;
      END IF;  
      
      --Calcula data de liberacao dos depositos em cheque (5 dias uteis)
      vr_dtlibera := rw_crapdat.dtmvtolt - 1;
      vr_qtddiaut := 1;
      
      WHILE vr_qtddiaut < 5 LOOP
        vr_dtlibera := vr_dtlibera + 1;        
        vr_dtlibera := gene0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper
                                                  ,pr_dtmvtolt => vr_dtlibera
                                                  ,pr_tipo     => 'P');                                             
        vr_qtddiaut := vr_qtddiaut + 1;
      END LOOP;
      
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => rw_crapcop.cdcooper
                                               ,pr_cdacesso => 'CNVBANCOOB'
                                               ,pr_tpregist => 001);
                                
      IF TRIM(vr_dstextab) IS NULL THEN
         vr_cdcritic := 472;
         vr_dscritic := NULL;
         RAISE vr_exc_fimprg;        
      END IF;
      
      vr_cdbancob := '756';
      vr_cdageban := rw_crapcop.cdagebcb;
      vr_nmarqdoc := SUBSTR(vr_dstextab,17,6);
      vr_nmarqdep := SUBSTR(vr_dstextab,24,3);      
     
      --no programa original (PROGRESS) existia um parametro glb_nmtelant
      --que se fosse COMPEFORA pegava dtmvtoan mais na conversao passa a
      --pegar somente dtmvtolt
      vr_dtauxili := rw_crapdat.dtmvtolt;
      
      FOR vr_indice IN vr_tabarqs.FIRST..vr_tabarqs.LAST LOOP --ARQUIVOS
      
        vr_flgrejei := 0;
        vr_vlcredit := 0;
        vr_qtcompln := 0;
        vr_vlcompcr := 0;
        vr_contareg := 0;
        
        
        --Limpar a craprej 
        BEGIN
          DELETE 
            FROM craprej rej
           WHERE rej.cdcooper = pr_cdcooper
             AND rej.dtrefere = TO_CHAR(vr_dtauxili,'DD/MM/RRRR');
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Problemas na exclusao da craprej (Rejeitados)';
            RAISE vr_exc_saida;
        END;  
                                               
        gene0009.pc_importa_arq_layout(pr_nmlayout   => 'DCR615'
                                      ,pr_dsdireto   => vr_dsdireto
                                      ,pr_nmarquiv   => vr_tabarqs(vr_indice)
                                      ,pr_dscritic   => vr_dscritic
                                      ,pr_tab_linhas => vr_tab_linhas);
                                               
                                               
        IF TRIM(vr_dscritic) IS NOT NULL THEN          
                    
           vr_dscritic := vr_dscritic || ' , Arquivo: ' || vr_tabarqs(vr_indice);
           
           gera_log(pr_cdcooper => rw_crapcop.cdcooper
                   ,pr_cdprogra => vr_cdprogra
                   ,pr_indierro => 1
                   ,pr_cdcritic => 0
                   ,pr_dscritic => vr_dscritic);
                   
           CONTINUE; --Prox arquivo
        END IF;        
        
        FOR vr_indice2 IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO
          
          IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN --Problemas com importacao do layout
             vr_dscritic := vr_tab_linhas(vr_indice2)('$ERRO$').texto || ' , Arquivo: ' || vr_tabarqs(vr_indice);
             
             gera_log(pr_cdcooper => rw_crapcop.cdcooper
                     ,pr_cdprogra => vr_cdprogra
                     ,pr_indierro => 2
                     ,pr_cdcritic => 0
                     ,pr_dscritic => vr_dscritic);
             
             -- efetuar rollback e ir para prox arquivo
             ROLLBACK;
                     
             EXIT; --Prox arquivo        
          END IF;  
        
          vr_contareg := vr_contareg + 1; --Conta qtd de linhas do arquivo
        
          --INICIO validacoes HEADER
          IF vr_indice2 = vr_tab_linhas.FIRST THEN --Pegar primeira linha do arquivo
            
             IF vr_tab_linhas(vr_indice2)('$LAYOUT$').texto = 'H' THEN --Confirmando que eh o HEADER
             
                --Validacoes do HEADER do arquivo  *********************************
                vr_cdcritic := 0;
                vr_dscritic := '';
                
                IF vr_tab_linhas(vr_indice2)('CONTROLE').texto <> '00000000000000000000' THEN
                   vr_cdcritic := 468;
                   vr_dscritic := '';
                END IF;             
             
                IF vr_nmarqdep <> SUBSTR(vr_tab_linhas(vr_indice2)('NMARQUIV').texto,1,3) AND
                   vr_nmarqdoc <> vr_tab_linhas(vr_indice2)('NMARQUIV').texto THEN
                   vr_cdcritic := 173;
                   vr_dscritic := '';
                END IF;

                IF vr_dtauxili <> vr_tab_linhas(vr_indice2)('DTMVTOLT').data THEN
                   vr_cdcritic := 013;
                   vr_dscritic := '';                  
                END IF;  

                IF TO_NUMBER(vr_cdbancob) <> vr_tab_linhas(vr_indice2)('NROBANCO').numero THEN
                   vr_cdcritic := 057;
                   vr_dscritic := '';                  
                END IF;
                
                IF vr_cdcritic > 0 THEN
                   --criticar e ir para o proximo arquivo
                   gera_log(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_indierro => 3
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => NULL);                  
                  
                   ROLLBACK;
                   
                   EXIT;
                END IF;  
                
                IF vr_tab_linhas(vr_indice2)('NMARQUIV').texto = vr_nmarqdoc THEN
                   flg_nmarqdoc := 1;
                ELSE
                   flg_nmarqdoc := 0;
                   
                   IF vr_tab_linhas(vr_indice2)('NMARQUIV').texto = 'DEC001' THEN
                      flg_dpcheque := 0;
                   ELSE
                      flg_dpcheque := 1;
                   END IF;
                END IF;
             
                CONTINUE; -- Prox linha
             ELSE
                --Nao encontrou o Header do arquivo
                --criticar e ir para o proximo arquivo rollback
                vr_dscritic := 'Header do arquivo nao encontrado' || ' , Arquivo: ' || vr_tabarqs(vr_indice);
                 
                gera_log(pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_indierro => 4
                        ,pr_cdcritic => 0
                        ,pr_dscritic => vr_dscritic);
                
                ROLLBACK;
                         
                EXIT; -- Prox arquivo                        
             END IF;             
             
          END IF;  --Fim validacoes HEADER
          
          --INICIO validacoes TRAILER
          IF vr_indice2 = vr_tab_linhas.LAST THEN --Pegar ultima linha do arquivo
            
             IF vr_tab_linhas(vr_indice2)('$LAYOUT$').texto = 'T' THEN --Confirmando que eh o TRAILER
          
                vr_cdcritic := 0;
                vr_dscritic := '';            
            
                IF vr_tab_linhas(vr_indice2)('CONTROLE').texto = '99999999999999999999' THEN
                                    
                   IF vr_tab_linhas(vr_indice2)('NRSEQUEN').numero <> vr_contareg THEN
                      vr_cdcritic := 504;
                      vr_dscritic := ''; 
                   END IF;
            
                   IF vr_tab_linhas(vr_indice2)('VLRTOTAL').numero <> vr_vlcredit THEN
                      vr_cdcritic := 505;
                      vr_dscritic := ''; 
                   END IF;

                   IF vr_cdcritic > 0 THEN
                      --criticar e ir para o proximo arquivo rollback                       
                      gera_log(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_indierro => 5
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
                      ROLLBACK;
                      
                      EXIT;
                   END IF;
                   
                   inserir_rejeitados(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => 999999999
                                     ,pr_dtrefere => vr_dtauxili
                                     ,pr_dshistor => ''
                                     ,pr_nrdocmto => 0
                                     ,pr_vllanmto => vr_tab_linhas(vr_indice2)('VLRTOTAL').numero
                                     ,pr_nrseqdig => vr_tab_linhas(vr_indice2)('NRSEQUEN').numero
                                     ,pr_cdpesqbb => ''
                                     ,pr_indebcre => 0
                                     ,pr_vldaviso => 0
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);                
                
                   IF vr_cdcritic > 0 OR
                      TRIM(vr_dscritic) IS NOT NULL THEN
                      RAISE vr_exc_saida;
                   END IF;
                   
                END IF;
                
                CONTINUE; -- Prox linha
             ELSE
                vr_dscritic := 'Trailer do arquivo nao encontrado' || ' , Arquivo: ' || vr_tabarqs(vr_indice);
                   
                gera_log(pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdprogra => vr_cdprogra
                        ,pr_indierro => 6
                        ,pr_cdcritic => 0
                        ,pr_dscritic => vr_dscritic);
            
                ROLLBACK;
                
                EXIT; --Criticar e ir pro prox arquivo rollback                  
             END IF;
          
          END IF;  --FIM validacoes TRAILER

          -- ######### VALIDACOES DOS REGISTROS DE DETALHE ####### 
          IF vr_tab_linhas(vr_indice2)('$LAYOUT$').texto = 'D' THEN --Confirmando que eh o DETAIL

             vr_cdcritic := 0;
             vr_dscritic := '';

             --Variaveis com os valores do que foi importado do layout
             lt_d_cdcmpdst := vr_tab_linhas(vr_indice2)('CDCMPDST').numero;
             lt_d_nrcodban := vr_tab_linhas(vr_indice2)('NRCODBAN').numero;
             lt_d_nragedst := vr_tab_linhas(vr_indice2)('NRAGEDST').numero;
             lt_d_dvagedst := vr_tab_linhas(vr_indice2)('DVAGEDST').texto;
             lt_d_nrctbdst := vr_tab_linhas(vr_indice2)('NRCTBDST').numero;
             lt_d_nrdocmto := vr_tab_linhas(vr_indice2)('NRDOCMTO').numero;
             lt_d_vldocmto := vr_tab_linhas(vr_indice2)('VLDOCMTO').numero;
             lt_d_nmdestin := vr_tab_linhas(vr_indice2)('NMDESTIN').texto;
             lt_d_cpfcgcds := vr_tab_linhas(vr_indice2)('CPFCGCDS').numero;
             lt_d_tpctadst := vr_tab_linhas(vr_indice2)('TPCTADST').numero;
             lt_d_cdfinali := vr_tab_linhas(vr_indice2)('CDFINALI').numero;
             lt_d_atributo := vr_tab_linhas(vr_indice2)('ATRIBUTO').texto;
             lt_d_cdcmpori := vr_tab_linhas(vr_indice2)('CDCMPORI').numero;
             lt_d_nrbanori := vr_tab_linhas(vr_indice2)('NRBANORI').numero;
             lt_d_nrageori := vr_tab_linhas(vr_indice2)('NRAGEORI').numero;
             lt_d_dvageori := vr_tab_linhas(vr_indice2)('DVAGEORI').texto;
             lt_d_nrctarem := vr_tab_linhas(vr_indice2)('NRCTAREM').numero;
             lt_d_nmaprese := vr_tab_linhas(vr_indice2)('NMAPRESE').texto;
             lt_d_cpfcgcap := vr_tab_linhas(vr_indice2)('CPFCGCAP').numero;
             lt_d_tpoctaap := vr_tab_linhas(vr_indice2)('TPOCTAAP').numero;
             lt_d_ufbancap := vr_tab_linhas(vr_indice2)('UFBANCAP').texto;
             lt_d_tipdocto := vr_tab_linhas(vr_indice2)('TIPDOCTO').numero;
             lt_d_controle := vr_tab_linhas(vr_indice2)('CONTROLE').texto;
             lt_d_dtmvtolt := vr_tab_linhas(vr_indice2)('DTMVTOLT').data;
             lt_d_verarqui := vr_tab_linhas(vr_indice2)('VERARQUI').numero;
             lt_d_indocorr := vr_tab_linhas(vr_indice2)('INDOCORR').numero;
             lt_d_cdmotdev := vr_tab_linhas(vr_indice2)('CDMOTDEV').numero;
             lt_d_nrsequen := vr_tab_linhas(vr_indice2)('NRSEQUEN').numero;

             IF lt_d_nragedst = vr_cdageban AND
                lt_d_nrcodban = vr_cdbancob THEN
                vr_vlcredit := vr_vlcredit + lt_d_vldocmto;
             END IF;

             --NRBANORI - NRAGEORI DVAGEORI - NMAPRESE
             vr_cdpesqbb := SUBSTR(vr_tab_linhas(vr_indice2)('$LINHA$').texto,121,3) || '-' ||
                            SUBSTR(vr_tab_linhas(vr_indice2)('$LINHA$').texto,124,5) || '-' ||
                            SUBSTR(vr_tab_linhas(vr_indice2)('$LINHA$').texto,142,40);
                
             CASE lt_d_tipdocto
               WHEN 2 THEN
                  vr_tpdedocs := 'A';
               WHEN 3 THEN
                 vr_tpdedocs := 'B';
               WHEN 4 THEN
                 vr_tpdedocs := 'C';
               WHEN 5 THEN 
                 vr_tpdedocs := 'D';
               WHEN 6 THEN
                 vr_tpdedocs := 'E'    ;
               ELSE
                 vr_tpdedocs := TO_CHAR(lt_d_tipdocto);
             END CASE;
             
             OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => lt_d_nrctbdst);
            
             FETCH cr_crapass INTO rw_crapass;
          
             -- Caso nao encontre a conta cria uma linha na tabela de rejeitados                
             IF cr_crapass%NOTFOUND THEN
                --Fecha cursor critica e cria tabela rejeitados
                CLOSE cr_crapass;
                
                vr_cdcritic := 999;
                
                inserir_rejeitados(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => lt_d_nrctbdst
                                  ,pr_dtrefere => vr_dtauxili
                                  ,pr_dshistor => lt_d_nmdestin
                                  ,pr_nrdocmto => lt_d_nrdocmto
                                  ,pr_vllanmto => lt_d_vldocmto
                                  ,pr_nrseqdig => lt_d_nrsequen
                                  ,pr_cdpesqbb => vr_cdpesqbb
                                  ,pr_indebcre => vr_tpdedocs
                                  ,pr_vldaviso => lt_d_cpfcgcds                                  
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);                
                
                IF vr_cdcritic > 0 OR
                   TRIM(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;
                          
                CONTINUE; --Proxima linha do arquivo                
             END IF;
             
             CLOSE cr_crapass;
             
             --Verificar coops migradas
             IF pr_cdcooper = 1 OR
                pr_cdcooper = 2 THEN
                
                vr_flagstco := 0; --Se achar tco muda pra 1
                
                FOR rw_craptco IN cr_craptco(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => rw_crapass.nrdconta) LOOP

                  vr_cdcritic := 999;
                  inserir_rejeitados(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => lt_d_nrctbdst
                                    ,pr_dtrefere => vr_dtauxili
                                    ,pr_dshistor => lt_d_nmdestin
                                    ,pr_nrdocmto => lt_d_nrdocmto
                                    ,pr_vllanmto => lt_d_vldocmto
                                    ,pr_nrseqdig => lt_d_nrsequen
                                    ,pr_cdpesqbb => vr_cdpesqbb
                                    ,pr_indebcre => vr_tpdedocs
                                    ,pr_vldaviso => lt_d_cpfcgcds                                    
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);                
                  
                  IF vr_cdcritic > 0 OR
                     TRIM(vr_dscritic) IS NOT NULL THEN
                     RAISE vr_exc_saida;
                  END IF;
                  
                  vr_flagstco := 1; --Achou tco
                            
                  EXIT; --Sai do loop                
                                            
                END LOOP;
                
                IF vr_flagstco = 1 THEN
                   CONTINUE; -- Proxima linha do arquivo
                END IF;   
             END IF;
                
             IF rw_crapass.cdsitdtl IN (2,4,5,6,7,8) THEN
                
                OPEN cr_craptrf(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => rw_crapass.nrdconta);
                                  
                FETCH cr_craptrf INTO rw_craptrf;
                   
                IF cr_craptrf%FOUND THEN
                   CLOSE cr_craptrf;
                   lt_d_nrctbdst := rw_craptrf.nrsconta;
                END IF;   
                                      
             END IF;
                
             IF flg_nmarqdoc = 1 THEN
                IF lt_d_cdfinali = 14 THEN
                   vr_cdhistor := 97;
                ELSE                   
                  IF lt_d_cdfinali = 50 AND 
                     lt_d_tipdocto = 2  THEN 
                     vr_cdhistor := 519;
                  ELSE
                     vr_cdhistor := 319;   
                  END IF;                                     
                END IF;    
                   
                IF SUBSTR(lt_d_nmaprese,1,21) = 'SUL AMERICA AETNA SEG' THEN
                   vr_cdhistor := 339;
                END IF;                     
             ELSE
                IF flg_dpcheque = 1 THEN
                   vr_cdhistor := 445;
                ELSE
                   vr_cdhistor := 345;
                END IF;        
             END IF;               

             IF (lt_d_tipdocto IN (4,6,9) OR
                 (lt_d_cdfinali = 50 AND lt_d_tipdocto = 2)) THEN
                IF NOT (lt_d_cpfcgcds = rw_crapass.nrcpfcgc OR
                        lt_d_cpfcgcds = rw_crapass.nrcpfstl OR
                        lt_d_cpfcgcds = rw_crapass.nrcpfttl) THEN
                   vr_cdcritic := 301;
                END IF;        
             END IF;

             IF lt_d_tipdocto = 5 THEN
                IF lt_d_cpfcgcds = lt_d_cpfcgcap THEN
                   IF rw_crapass.nrcpfcgc <> lt_d_cpfcgcds THEN
                      vr_cdcritic := 301;
                   END IF;
                ELSE                
                   IF ((lt_d_cpfcgcds = rw_crapass.nrcpfcgc)   OR
                       (lt_d_cpfcgcds = rw_crapass.nrcpfstl))  AND
                      ((lt_d_cpfcgcap = rw_crapass.nrcpfcgc)   OR
                       (lt_d_cpfcgcap = rw_crapass.nrcpfstl))  THEN
                      NULL;
                   ELSE     
                      vr_cdcritic := 301;
                   END IF;                   
                END IF;  
             END IF;
             
             IF TO_NUMBER(NVL(TRIM(SUBSTR(vr_tab_linhas(vr_indice2)('$LINHA$').texto,230,11)),0)) > 0 THEN
                vr_cdcritic := 513;
             END IF;  
             
             IF rw_crapdat.dtmvtolt >= TO_DATE('05/02/2012','DD/MM/RRRR') THEN
                vr_cdcritic := 798; --todos detalhes caindo aqui, rejeitando todos
             END IF;
             
             IF vr_cdcritic > 0 THEN
                
                vr_dshistor := NULL;
                
                IF vr_cdcritic = 301 THEN
                   vr_dshistor := lt_d_nmdestin 
                                  || ' CPF Remetente ' || TO_CHAR(lt_d_cpfcgcap)
                                  || ' CPF Destinatario ' || TO_CHAR(lt_d_cpfcgcds);
                END IF;  
                
                inserir_rejeitados(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => lt_d_nrctbdst
                                  ,pr_dtrefere => vr_dtauxili
                                  ,pr_dshistor => NVL(vr_dshistor, lt_d_nmdestin)
                                  ,pr_nrdocmto => lt_d_nrdocmto
                                  ,pr_vllanmto => lt_d_vldocmto
                                  ,pr_nrseqdig => lt_d_nrsequen
                                  ,pr_cdpesqbb => vr_cdpesqbb
                                  ,pr_indebcre => vr_tpdedocs
                                  ,pr_vldaviso => lt_d_cpfcgcds                
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);                
                  
                IF vr_cdcritic > 0 OR
                   TRIM(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;
                
                CONTINUE; --Proximo registro
             END IF;  
             
             vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                      ,pr_nmsistem => 'CRED'
                                                      ,pr_tptabela => 'GENERI'
                                                      ,pr_cdempres => 0
                                                      ,pr_cdacesso => 'NUMLOTEBCO'
                                                      ,pr_tpregist => 001);
                                      
             IF TRIM(vr_dstextab) IS NULL THEN
                vr_cdcritic := 472;
                vr_dscritic := NULL;
                RAISE vr_exc_saida;        
             END IF;
             
             vr_nrdolote := TO_NUMBER(vr_dstextab);
             
             LOOP
             
               OPEN cr_craplot(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_cdagenci => 1
                              ,pr_cdbccxlt => 756
                              ,pr_nrdolote => vr_nrdolote);
                              
               FETCH cr_craplot INTO rw_craplot;
               
               IF cr_craplot%NOTFOUND THEN
                  CLOSE cr_craplot;
                  vr_nrdolote := rw_craplot.nrdolote;
                  EXIT;                  
               END IF; 
               
               vr_nrdolote := vr_nrdolote + 1;
               
             END LOOP;
             
             BEGIN
               INSERT 
                 INTO craplot(dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,cdcooper)
               VALUES(rw_crapdat.dtmvtolt
                     ,1
                     ,756
                     ,vr_nrdolote
                     ,1
                     ,rw_crapcop.cdcooper)
                RETURNING ROWID, dtmvtolt, cdagenci, cdbccxlt, nrdolote 
                     INTO rw_craplot.rowid, rw_craplot.dtmvtolt, rw_craplot.cdagenci, 
                          rw_craplot.cdbccxlt , rw_craplot.nrdolote;
             EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Problemas ao criar lote ' || TO_CHAR(vr_nrdolote);
                 RAISE vr_exc_saida;
             END;
            
            OPEN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdagenci => 1
                           ,pr_cdbccxlt => 756
                           ,pr_nrdolote => vr_nrdolote
                           ,pr_nrdctabb => lt_d_nrctbdst
                           ,pr_nrdocmto => lt_d_nrdocmto);
                           
            FETCH cr_craplcm INTO rw_craplcm;           
            
            IF cr_craplcm%FOUND THEN
               vr_cdcritic := 92;
               vr_dscritic := NULL;
               RAISE vr_exc_saida; 
            END IF;
            
            BEGIN
              INSERT 
                INTO craplcm(dtmvtolt, cdagenci, 
                             cdbccxlt, nrdolote, 
                             nrdconta, nrdocmto, 
                             cdhistor, nrseqdig, 
                             vllanmto, nrdctabb, 
                             cdpesqbb, cdbanchq, 
                             cdcmpchq, cdagechq, 
                             nrctachq, sqlotchq, 
                             cdcooper, nrdctitg)
                VALUES(rw_craplot.dtmvtolt ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt ,rw_craplot.nrdolote
                      ,lt_d_nrctbdst       ,lt_d_nrdocmto
                      ,vr_cdhistor         ,lt_d_nrsequen
                      ,lt_d_vldocmto       ,lt_d_nrctbdst
                      ,lt_d_nmaprese       ,lt_d_nrbanori
                      ,lt_d_cdcmpori       ,lt_d_nrageori
                      ,lt_d_nrctarem       ,lt_d_nrsequen
                      ,rw_crapcop.cdcooper ,TO_CHAR(lt_d_nrctbdst,'fm00000000'));
                    
              UPDATE craplot
                 SET craplot.qtinfoln = NVL(craplot.qtinfoln,0) + 1
                    ,craplot.qtcompln = NVL(craplot.qtcompln,0) + 1
                    ,craplot.vlinfocr = NVL(craplot.vlinfocr,0) + lt_d_vldocmto
                    ,craplot.vlcompcr = NVL(craplot.vlcompcr,0) + lt_d_vldocmto
                    ,craplot.nrseqdig = lt_d_nrsequen
               WHERE craplot.rowid = rw_craplot.rowid;
              
              vr_qtcompln     := vr_qtcompln + 1;
              vr_vlcompcr     := vr_vlcompcr + lt_d_vldocmto;
              
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Problemas ao criar lancamento';
                RAISE vr_exc_saida;
            END;                   
            
            vr_cdcritic := 0;
            
            IF flg_dpcheque = 1 THEN
               BEGIN
                 INSERT
                   INTO crapdpb(dtmvtolt, cdagenci,
                                cdbccxlt, nrdolote,
                                nrdconta, dtliblan,
                                cdhistor, nrdocmto,
                                vllanmto, inlibera,
                                cdcooper)
                   VALUES(rw_craplot.dtmvtolt
                         ,rw_craplot.cdagenci
                         ,rw_craplot.cdbccxlt
                         ,rw_craplot.nrdolote
                         ,rw_craplcm.nrdconta
                         ,vr_dtlibera
                         ,rw_craplcm.cdhistor
                         ,rw_craplcm.nrdocmto
                         ,rw_craplcm.vllanmto
                         ,1
                         ,rw_crapcop.cdcooper);
               EXCEPTION
                 WHEN OTHERS THEN
                    vr_dscritic := 'Problemas na criacao de registro da tabela crapdpb';
                    RAISE vr_exc_saida;
               END;               
            END IF;

            inserir_rejeitados(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => lt_d_nrctbdst
                              ,pr_dtrefere => vr_dtauxili
                              ,pr_dshistor => NVL(vr_dshistor, lt_d_nmdestin)
                              ,pr_nrdocmto => lt_d_nrdocmto
                              ,pr_vllanmto => lt_d_vldocmto
                              ,pr_nrseqdig => lt_d_nrsequen
                              ,pr_cdpesqbb => vr_cdpesqbb
                              ,pr_indebcre => vr_tpdedocs
                              ,pr_vldaviso => lt_d_cpfcgcds            
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);                
                  
            IF vr_cdcritic > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
               RAISE vr_exc_saida;
            END IF;
            
          ELSE
            --Problemas com layout de arquivo            
            vr_cdcritic := 513;
            vr_dscritic := NULL;
            RAISE vr_exc_saida;            
          END IF;
        
        END LOOP;

        vr_nmarqimp := 'crrl205_' || TO_CHAR(vr_indice,'fm00') || '.lst';
        vr_cdempres := 11;

        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_Bufdes_xml := null;
        -- Inicilizar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
        
        flg_detalhes := 0;
        
        FOR rw_craprej IN cr_craprej(pr_cdcooper => pr_cdcooper
                                    ,pr_dtrefere => vr_dtauxili) LOOP

          IF flg_detalhes = 0 THEN
             flg_detalhes := 1; --existe detalhe
             pc_escreve_xml('<detalhe nmarquiv="integra/'||vr_tabarqs(vr_indice)||'" '||
                            'dtmvtolt="'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||'" '||
                            'cdagenci="1" cdbccxlt="756" nrdolote="'||nvl(vr_nrdolote,0)||'" '||
                            'tplotmov="1">');
          END IF;        

          IF rw_craprej.nrdconta < 999999999 THEN
            
             IF rw_craprej.cdcritic > 0 THEN
                
                vr_flgrejei := 1;
                vr_cdcritic := rw_craprej.cdcritic;
             
                IF vr_cdcritic = 999 THEN
                  
                   IF rw_crapcop.cdcooper = 2 THEN
                      vr_dscritic := 'Rejeitado - Associado VIACREDI'; 
                   ELSE
                      vr_dscritic := 'Rejeitado - Associado ALTOVALE'; 
                   END IF;
                   
                ELSE
                   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);  
                END IF;
                
             END IF;

             IF nvl(rw_craprej.vldaviso,0) > 0 THEN
                gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_craprej.vldaviso
                                           ,pr_stsnrcal => vr_stsnrcal
                                           ,pr_inpessoa => vr_inpessoa);
                                           
                vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                        ,pr_inpessoa => vr_inpessoa);
             ELSE
                vr_dscpfcgc := '';
             END IF;   

             pc_escreve_xml('<linha>');
             pc_escreve_xml('<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta => rw_craprej.nrdconta) || '</nrdconta>');
             pc_escreve_xml('<nrdocmto>' || gene0002.fn_mask_contrato(pr_nrcontrato => rw_craprej.nrdocmto) || '</nrdocmto>');
             pc_escreve_xml('<dshistor>' || SUBSTR(rw_craprej.dshistor,1,25) || '</dshistor>');
             pc_escreve_xml('<vllanmto>' || nvl(rw_craprej.vllanmto,0) || '</vllanmto>');
             pc_escreve_xml('<indebcre>' || nvl(rw_craprej.indebcre,0) || '</indebcre>');
             pc_escreve_xml('<cdpesqbb>' || SUBSTR(rw_craprej.cdpesqbb,1,35) || '</cdpesqbb>');             
             pc_escreve_xml('<dscpfcgc>' || SUBSTR(vr_dscpfcgc,1,18) || '</dscpfcgc>');
             pc_escreve_xml('<dscritic>' || SUBSTR(vr_dscritic,1,30) || '</dscritic>');
             pc_escreve_xml('</linha>');
                      
          ELSE

            IF flg_detalhes = 1 THEN
               pc_escreve_xml('</detalhe>');
            END IF;
            
            pc_escreve_xml('<total>');
            pc_escreve_xml('<qtregrec>' || TO_CHAR( (rw_craprej.nrseqdig - 2) ) || '</qtregrec>');
            pc_escreve_xml('<qtregint>' || TO_CHAR( vr_qtcompln ) || '</qtregint>');
            pc_escreve_xml('<vlregrec>' || TO_CHAR( rw_craprej.vllanmto ) || '</vlregrec>');
            pc_escreve_xml('<vlregint>' || TO_CHAR( vr_vlcompcr ) || '</vlregint>');
            pc_escreve_xml('<vlregrej>' || TO_CHAR( rw_craprej.vllanmto - vr_vlcompcr ) || '</vlregrej>');
            pc_escreve_xml('<qtregrej>' || TO_CHAR( (rw_craprej.nrseqdig - 2) - vr_qtcompln ) || '</qtregrej>');            
            pc_escreve_xml('</total>');
            
          END IF;  

        END LOOP;                            
           
        pc_escreve_xml('</raiz>',TRUE);

        --Gera relatorio
        vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => null); 

        --  Salvar copia relatorio para "/rlnsv"
        vr_dsdireto_rlnsv := vr_dsdircop || '/rlnsv';
              
        vr_dsdirarq := vr_dsdircop || '/rl/'||vr_nmarqimp;
        
        -- Submeter o relatório 205
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => 'CRPS252'                            --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/detalhe/linha'                --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl205.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                                 --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                                  --> 132 colunas
                                   ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                   ,pr_cdrelato  => '205'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                   ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                   ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
        --gerar relatorio 205_99_xx ################################
        dbms_lob.createtemporary(vr_des_xml, TRUE);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        vr_Bufdes_xml := null;
        -- Inicializar as informações do XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
        pc_escreve_xml('<detalhe nmarquiv="integra/'||vr_tabarqs(vr_indice)||'" '||
                       'dtmvtolt="'||TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||'" '||
                       'cdagenci="1" cdbccxlt="756" nrdolote="'||nvl(vr_nrdolote,0)||'" '||
                       'tplotmov="1">');
                       
        vr_flgrej99 := 0;
        
        FOR rw_craprej IN cr_craprej_999(pr_cdcooper => pr_cdcooper
                                        ,pr_dtrefere => vr_dtauxili) LOOP

          vr_flgrejei := 1;
          vr_flgrej99 := 1;
          vr_cdcritic := rw_craprej.cdcritic;
                  
          IF rw_crapcop.cdcooper = 2 THEN
             vr_dscritic := 'Rejeitado - Associado VIACREDI'; 
          ELSE
             vr_dscritic := 'Rejeitado - Associado ALTOVALE'; 
          END IF;
          
          IF nvl(rw_craprej.vldaviso,0) > 0 THEN
             gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => rw_craprej.vldaviso
                                        ,pr_stsnrcal => vr_stsnrcal
                                        ,pr_inpessoa => vr_inpessoa);
                                           
             vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_craprej.vldaviso
                                                     ,pr_inpessoa => vr_inpessoa);
          ELSE
             vr_dscpfcgc := '';
          END IF;   

          pc_escreve_xml('<linha>');
          pc_escreve_xml('<nrdconta>' || gene0002.fn_mask_conta(pr_nrdconta => rw_craprej.nrdconta) || '</nrdconta>');
          pc_escreve_xml('<nrdocmto>' || gene0002.fn_mask_contrato(pr_nrcontrato => rw_craprej.nrdocmto) || '</nrdocmto>');
          pc_escreve_xml('<dshistor>' || SUBSTR(rw_craprej.dshistor,1,25) || '</dshistor>');
          pc_escreve_xml('<vllanmto>' || nvl(rw_craprej.vllanmto,0) || '</vllanmto>');
          pc_escreve_xml('<indebcre>' || nvl(rw_craprej.indebcre,0) || '</indebcre>');
          pc_escreve_xml('<cdpesqbb>' || SUBSTR(rw_craprej.cdpesqbb,1,35) || '</cdpesqbb>');             
          pc_escreve_xml('<dscpfcgc>' || SUBSTR(vr_dscpfcgc,1,18) || '</dscpfcgc>');
          pc_escreve_xml('<dscritic>' || SUBSTR(vr_dscritic,1,30) || '</dscritic>');
          pc_escreve_xml('</linha>');
          
          vr_qtregrec := nvl(vr_qtregrec,0) + 1;
          vr_vlregrec := nvl(vr_vlregrec,0) + nvl(rw_craprej.vllanmto,0);

        END LOOP;

        --pro caso de nao haver linhas deve criar pelo menos
        --uma tag para o jasper se achar
        IF vr_flgrej99 = 0 THEN
          pc_escreve_xml('<linha/>');
        END IF;

        pc_escreve_xml('</detalhe>');
        pc_escreve_xml('<total>');
        pc_escreve_xml('<qtregrec>' || TO_CHAR( nvl(vr_qtregrec,0) ) || '</qtregrec>');
        pc_escreve_xml('<qtregint>' || TO_CHAR( 0 ) || '</qtregint>');
        pc_escreve_xml('<vlregrec>' || TO_CHAR( nvl(vr_vlregrec,0) ) || '</vlregrec>');
        pc_escreve_xml('<vlregint>' || TO_CHAR( 0 ) || '</vlregint>');
        pc_escreve_xml('<vlregrej>' || TO_CHAR( nvl(vr_vlregrec,0) ) || '</vlregrej>');
        pc_escreve_xml('<qtregrej>' || TO_CHAR( nvl(vr_qtregrec,0) ) || '</qtregrej>');            
        pc_escreve_xml('</total>');
           
        pc_escreve_xml('</raiz>',TRUE);

        vr_dsdirarq := vr_dsdircop||'/rl/crrl205_99_'||TO_CHAR(vr_indice,'fm00')||'.lst';

        -- Submeter o relatório 205_99
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                   ,pr_cdprogra  => 'CRPS252'                          --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz/detalhe/linha'                --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl205.jasper'                     --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null                                 --> Sem parâmetros
                                   ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                                  --> 132 colunas
                                   ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 1                                    --> Número de cópias
                                   ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                   ,pr_cdrelato  => '205'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                   ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                   ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
        -- Montar Comando para mover o arquivo lido para o diretório salvar
        vr_comando:= 'mv '|| vr_dsdircop || '/integra/' || vr_tabarqs(vr_indice) || ' ' ||
                             vr_dsdircop || '/salvar';

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
                             
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN        
          vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
        END IF;                

        
        COMMIT; --commit por arquivo processado
      END LOOP;
      
      IF vr_flgrejei = 1 THEN
         vr_cdcritic := 191; --Arquivo integrado com rejeitados
      ELSE
         vr_cdcritic := 190; --Arquivo integrado com sucesso
      END IF;
      
        -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic
                                ,pr_dstiplog     => 'E'
                                ,pr_cdprograma   => vr_cdprogra);
      
      --Limpar a craprej 
      BEGIN
        DELETE 
          FROM craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.dtrefere = TO_CHAR(vr_dtauxili,'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Problemas na exclusao da craprej (Rejeitados)';
          RAISE vr_exc_saida;
      END;        
      
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => 'CRPS252'
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

      -- Fim da execução do programa
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                             PR_CDPROGRAMA => vr_cdprogra, 
                             pr_cdcooper   => pr_cdcooper,
                             PR_IDPRGLOG   => vr_idprglog);

    EXCEPTION
      WHEN vr_exc_fimprg THEN

          -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
        
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic
                                  ,pr_dstiplog   => 'E'
                                  ,pr_cdprograma => vr_cdprogra);

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => 'CRPS252'
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN

          -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        cecred.pc_log_programa(PR_DSTIPLOG      => 'E', 
                               PR_CDPROGRAMA    => vr_cdprogra,
                               pr_cdcooper      => pr_cdcooper,
                               pr_tpexecucao    => 2,
                               pr_tpocorrencia  => 3,
                               pr_cdcriticidade => 1,
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               PR_IDPRGLOG      => vr_idprglog);

        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(pr_cdcooper);

        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        
        cecred.pc_log_programa(PR_DSTIPLOG      => 'E', 
                               PR_CDPROGRAMA    => vr_cdprogra,
                               pr_cdcooper      => pr_cdcooper,
                               pr_tpexecucao    => 2,
                               pr_tpocorrencia  => 2, -- erro não tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => pr_cdcritic,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               PR_IDPRGLOG      => vr_idprglog);
        
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps252;
/
