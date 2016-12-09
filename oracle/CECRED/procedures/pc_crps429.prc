CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS429(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_flgresta IN PLS_INTEGER --> Flag padrao para utilizacao de restart
                                      ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execucao
                                      ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                      ,pr_dscritic OUT VARCHAR2) AS --> Descricao da Critica

  /*** Campo saldo ci listado no relatorio crrl006_99.lst nao confere com o
  relatorio crrl400.lst rodado pelo programa crps429.p que lista o saldo
  da conta investimento. Motivo = crrl006 trabalha em cima do saldo em conta
  corrente do cooperado, entao se o mesmo nao possuir saldos nos campos
  crapsld e nenhum emprestimo aberto tipo micro credito o programa crps005
  despreza o cooperado e passa para o proximo. Ja o crps429 lista todos os
  saldos parados la, independente se o cooperado tem saldo em conta corrente
  ou nao. ***/
  /* ............................................................................
   
     Programa: pc_crps429     Antigo: Fontes/crps429.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Edson
     Data    : Dezembro/2004                       Ultima atualizacao: 28/09/2016
  
     Dados referentes ao programa:
  
     Frequencia: Mensal (Batch).
     Objetivo  : Atende a solicitacao .
                 Emitir saldo quinzenal das contas investimento (400).
  
     Alteracoes: 20/01/2005 - Alterada a periodicidade para DIARIA (Edson).
  
                 17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                  
                 26/08/2010 - Criar registro na crapprb com o saldo total
                              da conta investimento. Tarefa 34651 (Henrique)
                              
                 20/12/2010 - Alterado relatorio para exibir ordenado por PAC
                              e pelo numero da conta (Henrique).
                              
                 26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                             (Guilherme)     
                             
                 09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                              a escrita será PA (André Euzébio - Supero). 
                              
                 24/01/2014 - Incluir VALIDATE crapprb (Lucas R.)
                 
                 27/08/2014 - Conversão Progress >> Oracle PL/SQL (Jéssica DB1)
				 
				 08/10/2014 - Ajuste no cursor cr_crapsli para incluir valores 
				              negativos como era efetuado no Progress (Daniel)
                              
                 01/09/2015 - Inclusão da solititação do Projeto 214: Criação do
                              arquivo AAMMDD_CTAINVST.TXT (Vanessa)
                              
                 21/12/2015 - Ajuste na data da reversão para rw_crapdat.dtmvtopr 
                              ao invés de (rw_crapdat.dtmvtolt + 1) para o arquivo 
                              AAMMDD_CTAINVST.TXT - vr_tab_inf_arquivo (Vanessa)
                         
			     28/09/2016 - Alteração do diretório para geração de arquivo contábil.
                              P308 (Ricardo Linhares).                      
                              
  ............................................................................ */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  --Constantes
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS429';

  --Variaveis para retorno de erro
  vr_cdcritic   INTEGER := 0;
  vr_dscritic   VARCHAR2(4000);
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  vr_qtdsaldo NUMBER := 0;
  vr_vlsddisp NUMBER;
  vr_nrdconta PLS_INTEGER;

  vr_cdagenci crapass.cdagenci%TYPE;
  vr_vldisppf crapsli.vlsddisp%TYPE;
  vr_vldisppj crapsli.vlsddisp%TYPE;
  vr_vltotapf crapsli.vlsddisp%TYPE;
  vr_vltotapj crapsli.vlsddisp%TYPE;
  vr_nomarqui VARCHAR2(200); 
 -- vr_vlaplica NUMBER;

  -- Variáveis para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);
  vr_dircon VARCHAR2(200);
  vr_arqcon VARCHAR2(200);
  vc_dircon CONSTANT VARCHAR2(30) := 'arquivos_contabeis/ayllos'; 
  vc_cdacesso CONSTANT VARCHAR2(24) := 'ROOT_SISTEMAS';
  vc_cdtodascooperativas INTEGER := 0;    
  
  -- Comando completo
  vr_dscomando         VARCHAR2(4000);
  -- Saida da OS Command
  vr_typ_saida         VARCHAR2(4000);
  
  -- Variaveis para os XMLs e relatórios
  vr_clobxml CLOB;  -- Clob para conter o XML de dados
  vr_infoarq CLOB;
  vr_cabearq_normal  VARCHAR2(1000);
  vr_cabearq_reverso VARCHAR2(1000);
  
  
  ------------------------------Temp-Table tt-cta-bndes---------------------

  TYPE typ_tab_cta_bndes IS RECORD (nrdconta   PLS_INTEGER
                                   ,vlsddisp   NUMBER);
                                   
  TYPE typ_cta_bndes IS TABLE OF typ_tab_cta_bndes INDEX BY BINARY_INTEGER;
    
  /* Instância da tabela */
  vr_tab_cta_bndes typ_cta_bndes;
  
  ------------------------------Temp-Table tt-inf_arquivo---------------------
  
  TYPE typ_tab_inf_arquivo IS RECORD (cdagenci  PLS_INTEGER
                                      ,vldisppf  NUMBER
                                      ,vldisppj  NUMBER);
                           
  TYPE typ_inf_arquivo IS TABLE OF typ_tab_inf_arquivo INDEX BY PLS_INTEGER;
    
  /* Instância da tabela */
  vr_tab_inf_arquivo typ_inf_arquivo;
  
  ------------------------------- CURSORES ---------------------------------

  -- Buscar os dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) is
    SELECT crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl,
           crapcop.nrctactl
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- Busca dos saldos de aplicação
  CURSOR cr_crapsli(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT sli.cdcooper,
           sli.nrdconta,
           ass.nmprimtl,
           ass.cdagenci,
           ass.inpessoa,
           sli.dtrefere,
           sli.vlsddisp
      FROM crapsli sli
          ,crapass ass
     WHERE ass.cdcooper = sli.cdcooper
       AND ass.nrdconta = sli.nrdconta
       AND sli.cdcooper = pr_cdcooper
       AND sli.vlsddisp <> 0
       AND sli.dtrefere = rw_crapdat.dtultdia
     ORDER BY ass.cdagenci
             ,sli.nrdconta;
  
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                           ,pr_desdados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
  END;
 
  ---------------------------------------
  -- Inicio Bloco Principal PC_CRPS429
  ---------------------------------------
BEGIN

  --Limpar parametros saida
  pr_cdcritic := NULL;
  pr_dscritic := NULL;
  vr_vldisppf := 0;
  vr_vldisppj := 0;
  vr_vltotapf := 0;
  vr_vltotapj := 0;
  vr_cdagenci := 0; 
 -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop
    INTO rw_crapcop;
  -- Verificar se existe informação, e gerar erro caso não exista
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE cr_crapcop;
    -- Gerar exceção
    vr_cdcritic := 651;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(SYSDATE,
                                                          'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> ' || vr_dscritic);
    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_crapcop;
  END IF;

  -- Buscar calendario da Cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN 
    CLOSE btch0001.cr_crapdat;  
    -- Gerar exceção
    vr_cdcritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(SYSDATE,
                                                          'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> ' || vr_dscritic);
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;
  
   
  -- Preparar o CLOB para armazenar as infos do arquivo
  dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
  pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');
  
  -- Varredura dos saldos de aplicação
  FOR rw_crapsli in cr_crapsli(pr_cdcooper) LOOP
    
    vr_qtdsaldo := vr_qtdsaldo + 1;
    
    vr_nrdconta := rw_crapsli.nrdconta;
          
    -- Somente na virada do mês
    IF to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtopr, 'mm') THEN
      vr_vlsddisp := vr_vlsddisp + rw_crapsli.vlsddisp;
      IF vr_tab_cta_bndes.EXISTS(vr_nrdconta) THEN
        vr_tab_cta_bndes(vr_nrdconta).vlsddisp := vr_tab_cta_bndes(vr_nrdconta).vlsddisp + rw_crapsli.vlsddisp;
      ELSE
        vr_tab_cta_bndes(vr_nrdconta).vlsddisp := rw_crapsli.vlsddisp;
        vr_tab_cta_bndes(vr_nrdconta).nrdconta := rw_crapsli.nrdconta;
      END IF;
    END IF;
    
    -- Enviar o registro para o relatório
    pc_escreve_clob(vr_clobxml,'<saldos>'
                             ||'  <cdagenci>'||rw_crapsli.cdagenci||'</cdagenci>'
                             ||'  <nrdconta>'||gene0002.fn_mask_conta(rw_crapsli.nrdconta)||'</nrdconta>'
                             ||'  <nmprimtl>'||rw_crapsli.nmprimtl||'</nmprimtl>'
                             ||'  <vlsddisp>'||rw_crapsli.vlsddisp||'</vlsddisp>'
                             ||'</saldos>');
                             
                             
    -- Geração do arquivo AAMMDD_CTAINVST.TXT  DIÁRIO
    
    IF vr_cdagenci != rw_crapsli.cdagenci THEN       
       vr_cdagenci := rw_crapsli.cdagenci;
       vr_vldisppf := 0;
       vr_vldisppj := 0;
   END IF;   
       
   IF rw_crapsli.inpessoa = 1 THEN
       vr_vldisppf := vr_vldisppf + rw_crapsli.vlsddisp;
       vr_tab_inf_arquivo(vr_cdagenci).vldisppf := vr_vldisppf;
       vr_vltotapf:= vr_vltotapf + rw_crapsli.vlsddisp;
   ELSE
       vr_vldisppj := vr_vldisppj + rw_crapsli.vlsddisp;
       vr_tab_inf_arquivo(vr_cdagenci).vldisppj := vr_vldisppj;
       vr_vltotapj:= vr_vltotapj + rw_crapsli.vlsddisp;
   END IF;
       
   --Armazena o totalizador
   vr_tab_inf_arquivo(9999).vldisppf := vr_vltotapf;
   vr_tab_inf_arquivo(9999).vldisppj := vr_vltotapj;
                               
  
    
  END LOOP;
  
  pc_escreve_clob(vr_clobxml,'</raiz>');
    
                           
  IF (to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtopr, 'mm')) AND
     (vr_vlsddisp <> 0) THEN
     
      BEGIN
        INSERT INTO crapprb (cdcooper,
                             dtmvtolt,
                             nrdconta,
                             cdorigem,
                             cddprazo,
                             vlretorn)
        VALUES (3,
                rw_crapdat.dtmvtolt,
                rw_crapcop.nrctactl,
                1,
                90,
                vr_vlsddisp);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapprb: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      IF vr_tab_cta_bndes.COUNT > 0 THEN
      
        vr_nrdconta := vr_tab_cta_bndes.first;
        
        LOOP    
          
          IF  vr_tab_cta_bndes(vr_nrdconta).vlsddisp > 0  THEN
              BEGIN
                INSERT INTO crapprb (cdcooper,
                                     dtmvtolt,
                                     nrdconta,
                                     cdorigem,
                                     cddprazo,
                                     vlretorn)
                VALUES (pr_cdcooper,
                        rw_crapdat.dtmvtolt,
                        vr_nrdconta,
                        1,
                        0,
                        vr_tab_cta_bndes(vr_nrdconta).vlsddisp);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir crapprb: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;        
          
          END IF;
          
          EXIT WHEN vr_tab_cta_bndes.LAST = vr_nrdconta;
                  
          -- Buscar o proximo
          vr_nrdconta := vr_tab_cta_bndes.next(vr_nrdconta);    
        END LOOP;
      
      END IF;
        
  END IF;

  -- Definição do diretório onde o relatório será gerado
  vr_nom_diretorio := gene0001.fn_diretorio('c', -- /usr/coop
                                            pr_cdcooper,
                                              'rl');
    
  
  -- Solicita o relatório usando o XML
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper, --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra, --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                              pr_dsxml     => vr_clobxml, --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/raiz/saldos', --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl400.jasper', --> Arquivo de layout do iReport
                              pr_dsparams  => 'PR_QTDREGIS##'||vr_qtdsaldo, --> Array de parametros diversos
                              pr_dsarqsaid => vr_nom_diretorio || '/crrl400.lst', --> Arquivo final
                              pr_flg_gerar => 'S', --> Gerar o arquivo na hora
                              pr_qtcoluna  => 80, --> Qtd colunas do relatório (80,132,234)
                              pr_sqcabrel  => 1, --> Sequencia do relatorio (cabrel 1..5)  
                              pr_flg_impri => 'S', --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '80col', --> Nome do formulário para impressão
                              pr_nrcopias  => 1, --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic); --> Saída com erro

  dbms_lob.close(vr_clobxml);
  dbms_lob.freetemporary(vr_clobxml);

  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;  
  
  
  IF vr_tab_inf_arquivo.COUNT > 0 THEN
     -- Preparar o CLOB para armazenar as infos do arquivo final
     dbms_lob.createtemporary(vr_infoarq, TRUE, dbms_lob.CALL);
     dbms_lob.open(vr_infoarq, dbms_lob.lob_readwrite);
      
     -- Preparar o CLOB para armazenar as infos por PA PF
     dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
     dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);      
     
     --Cabeçalho Pessoa Fisica Normal e reverso
     vr_cabearq_normal  := '70'||TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||',4292,4112,'|| REPLACE(TO_CHAR(vr_tab_inf_arquivo(9999).vldisppf,'fm99999999d00'),',','.') ||',1434,Conta Investimento Pessoas Fisicas'||chr(10);
     vr_cabearq_reverso := '70'||TO_CHAR((rw_crapdat.dtmvtopr),'YYMMDD')||','||TO_CHAR(rw_crapdat.dtmvtopr ,'DDMMYY')||',4112,4292,'|| REPLACE(TO_CHAR(vr_tab_inf_arquivo(9999).vldisppf,'fm99999999d00'),',','.') ||',1434,Reversao Conta Investimento Pessoas Fisicas'||chr(10);
     
     vr_cdagenci :=  vr_tab_inf_arquivo.first;
    
     --Percorre para pegar AS informações por PA PF      
     WHILE vr_cdagenci IS NOT NULL LOOP
           IF vr_cdagenci <> 9999 AND vr_tab_inf_arquivo(vr_cdagenci).vldisppf > 0  THEN
              pc_escreve_clob(vr_clobxml,LPAD(vr_cdagenci,3,0)||','||REPLACE(TO_CHAR(vr_tab_inf_arquivo(vr_cdagenci).vldisppf,'fm99999999d00'),',','.')||chr(10));
           END IF;
           -- buscar proximo
           vr_cdagenci := vr_tab_inf_arquivo.next(vr_cdagenci);     
     END LOOP;
     
      --Percorre Novamente para pegar AS informações por PA PF  
     vr_cdagenci :=  vr_tab_inf_arquivo.first;    
     
     WHILE vr_cdagenci IS NOT NULL LOOP
           IF vr_cdagenci <> 9999 AND vr_tab_inf_arquivo(vr_cdagenci).vldisppf > 0  THEN
              pc_escreve_clob(vr_clobxml,LPAD(vr_cdagenci,3,0)||','||REPLACE(TO_CHAR(vr_tab_inf_arquivo(vr_cdagenci).vldisppf,'fm99999999d00'),',','.')||chr(10));
           END IF;
           -- buscar proximo
           vr_cdagenci := vr_tab_inf_arquivo.next(vr_cdagenci);     
     END LOOP;
     
     IF vr_tab_inf_arquivo(9999).vldisppf > 0 THEN
         --Escreve as informações no arquivo final e na ordem correta Pessoa Fisica
         pc_escreve_clob(vr_infoarq,vr_cabearq_normal);
         pc_escreve_clob(vr_infoarq,vr_clobxml);
         pc_escreve_clob(vr_infoarq,vr_cabearq_reverso);
         pc_escreve_clob(vr_infoarq,vr_clobxml);
        
         --Limpa o CLOB 
         dbms_lob.close(vr_clobxml);
         dbms_lob.freetemporary(vr_clobxml);
     END IF;
     -- Preparar o CLOB para armazenar as infos por PA PJ
     dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
     dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
    
    --Cabeçalho Pessoa Juridica Normal e reverso 
    vr_cabearq_normal  := '70'||TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD')||','||TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYY')||',4292,4120,'|| REPLACE(TO_CHAR(vr_tab_inf_arquivo(9999).vldisppj,'fm99999999d00'),',','.') ||',1434,Conta Investimento Pessoas Juridicas'||chr(10);
    vr_cabearq_reverso := '70'||TO_CHAR(rw_crapdat.dtmvtopr,'YYMMDD')||','||TO_CHAR(rw_crapdat.dtmvtopr,'DDMMYY')||',4120,4292,'|| REPLACE(TO_CHAR(vr_tab_inf_arquivo(9999).vldisppj,'fm99999999d00'),',','.') ||',1434,Reversao Conta Investimento Pessoas Juridicas'||chr(10);
    
    vr_cdagenci :=  vr_tab_inf_arquivo.first;
    
    --Percorre para pegar AS informações por PA PJ      
    WHILE vr_cdagenci IS NOT NULL LOOP
        IF vr_cdagenci <> 9999 AND vr_tab_inf_arquivo(vr_cdagenci).vldisppj > 0 THEN
           pc_escreve_clob(vr_clobxml, LPAD(vr_cdagenci,3,0)||','||REPLACE(TO_CHAR(vr_tab_inf_arquivo(vr_cdagenci).vldisppj,'fm99999999d00'),',','.')||chr(10));
        END IF; 
        -- buscar proximo
        vr_cdagenci := vr_tab_inf_arquivo.next(vr_cdagenci);     
    END LOOP;
    
    --Percorre Novamente para pegar AS informações por PA PJ 
    vr_cdagenci :=  vr_tab_inf_arquivo.first;
         
    WHILE vr_cdagenci IS NOT NULL LOOP
        IF vr_cdagenci <> 9999 AND vr_tab_inf_arquivo(vr_cdagenci).vldisppj > 0 THEN 
           pc_escreve_clob(vr_clobxml, LPAD(vr_cdagenci,3,0)||','||REPLACE(TO_CHAR(vr_tab_inf_arquivo(vr_cdagenci).vldisppj,'fm99999999d00'),',','.')||chr(10));
        END IF; 
        -- buscar proximo
        vr_cdagenci := vr_tab_inf_arquivo.next(vr_cdagenci);     
    END LOOP;
    
    IF vr_tab_inf_arquivo(9999).vldisppj > 0 THEN
        --Escreve as informações no arquivo final e na ordem correta Pessoa Juridica
        pc_escreve_clob(vr_infoarq,vr_cabearq_normal);
        pc_escreve_clob(vr_infoarq,vr_clobxml);
        pc_escreve_clob(vr_infoarq,vr_cabearq_reverso);
        pc_escreve_clob(vr_infoarq,vr_clobxml);
    END IF;
    
    -- Definição do diretório onde o relatório será gerado
    vr_nom_diretorio := gene0001.fn_diretorio('c', -- /usr/coop
                                              pr_cdcooper,
                                              'contab');
                                              
    --Define o nome do arquivo                                        
    vr_nomarqui := TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD') ||'_CTAINVST.txt';
    
    --gera o arquivo                                          
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_infoarq       --> Blob com os dados
                                 ,pr_caminho  => vr_nom_diretorio --> Diretório para saída
                                 ,pr_arquivo  => vr_nomarqui      --> Nome do arquivo de saída
                                 ,pr_des_erro => vr_dscritic);
    
     -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        -- Gerar exceção
        vr_cdcritic := 0;
        RAISE vr_exc_saida;
      END IF;
      
     -- Busca o diretório para contabilidade
     vr_dircon := gene0001.fn_param_sistema('CRED', vc_cdtodascooperativas, vc_cdacesso);
     vr_dircon := vr_dircon || vc_dircon;
     vr_arqcon := TO_CHAR(rw_crapdat.dtmvtolt,'YYMMDD') ||'_'||LPAD(TO_CHAR(pr_cdcooper),2,0)||'_CTAINVST.txt';

     -- Ao final, converter o arquivo para DOS e enviá-lo a pasta micros/<dsdircop>/contab
     vr_dscomando := 'ux2dos '||vr_nom_diretorio||'/'||vr_nomarqui||' > '||
                                vr_dircon||'/'||vr_arqcon||' 2>/dev/null';
    
    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
    
    
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_fimprg;
    END IF;
                                 
    --Limpa e libera os CLOBs
    dbms_lob.close(vr_infoarq);
    dbms_lob.freetemporary(vr_infoarq);
    dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);    
    
  END IF;  
  
  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;
  
    
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  
COMMIT;

EXCEPTION

  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
     
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,
                                 pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
    
    END IF;
  
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
  
END PC_CRPS429;
/
