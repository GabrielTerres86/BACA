CREATE OR REPLACE PROCEDURE CECRED.pc_crps461 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps461     (Fontes/crps461.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Diego
     Data    : Janeiro/2006.                     Ultima atualizacao: 31/07/2017
          
     Dados referentes ao programa:

     Frequencia: Diario (Batch).
     Objetivo  : Atende a solicitacao 5.(Exclusivo)
                 Gera arquivo com informacoes gerenciais. 
                 - Gera Relatorio no ultimo dia do mes.
                   
     Alteracao : 09/03/2006 - Acerto no campo quantidade cooperados (Diego).
       
                 12/05/2006 - Consertado numero de lancamentos (Diego).
       
                 01/04/2008 - Alterado envio de email para BO b1wgen0011
                              (Sidnei - Precise)
                              
                            - Alterado para incluir e-mail denis@cecred.coop.br
                              (Gabriel).
                   
                 18/06/2008 - Incluida coluna com a situacao do PAC (Gabriel).
                   
                 15/10/2008 - Incluida coluna com Desconto de Titulo (Diego).
                   
                 18/12/2008 - Incluir e-mail da Rosangela (Gabriel).
                   
                 16/10/2009 - Retirar e-mail da Rosangela (Mirtes).
                   
                 06/03/2010 - Incluir e-mail da Priscila e do Ricardo (Gabriel).
                   
                 22/06/2011 - Incluir e_mail do Allan (Magui).
                   
                 04/09/2012 - Modificado nome do arquivo 
                            - Incluido e-mail ana.teixeira@cecred.coop.br (Diego).
                              
                 16/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                              a escrita será PA (André Euzébio - Supero).
                              
                 27/03/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)             

                 02/08/2016 - Inclusao insitage 3 como ativo. (Jaison/Anderson)
                                
                 31/07/2017 - Padronizar as mensagens - Chamado 721285
                              Tratar os exception others - Chamado 721285
                              Eliminar exception vr_exc_fimprg
                              ( Belli - Envolti )                   

  ............................................................................ */


    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS461';

    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Busca cadastro com informacoes gerenciais
    CURSOR cr_crapger (pr_cdcooper crapger.cdcooper%TYPE,
                       pr_dtrefere crapger.dtrefere%TYPE)IS
      SELECT *
        FROM crapger
       WHERE crapger.cdcooper = pr_cdcooper
         AND crapger.dtrefere = pr_dtrefere
         AND crapger.cdempres = 0
         AND crapger.cdagenci > 0;
    
    -- Busca informacoes detalhadas para os relatorios gerenciais da intranet
    CURSOR cr_gninfpl (pr_cdcooper crapger.cdcooper%TYPE,
                       pr_dtmvtolt gninfpl.dtmvtolt%TYPE)IS
      SELECT *
        FROM gninfpl
       WHERE gninfpl.dtmvtolt = pr_dtmvtolt
         AND gninfpl.cdcooper = pr_cdcooper;
         
    -- ler Tabela que contem os saldos de caixas
    CURSOR cr_gnsldcx (pr_cdcooper gninfpl.cdcooper%TYPE,
                       pr_dtpridia gninfpl.dtmvtolt%TYPE,
                       pr_dtultdia gninfpl.dtmvtolt%TYPE)IS
      SELECT *
        FROM gnsldcx
       WHERE gnsldcx.dtmvtolt >= pr_dtpridia
         AND gnsldcx.dtmvtolt <= pr_dtultdia
         AND gnsldcx.cdcooper = pr_cdcooper;
         
    -- ler informacoes gerenciais acumuladas
    CURSOR cr_crapacc (pr_cdcooper crapacc.cdcooper%TYPE,
                       pr_dtrefere crapacc.dtrefere%TYPE)IS
      SELECT *
        FROM crapacc
       WHERE crapacc.dtrefere = pr_dtrefere
         AND crapacc.cdempres = 0
         AND crapacc.tpregist = 1
         AND crapacc.cdagenci > 0
         AND crapacc.cdlanmto = 0
         AND crapacc.cdcooper = pr_cdcooper;
         
    -- ler os totais de emprestimo por linha de credito
    CURSOR cr_gnlcred (pr_cdcooper gnlcred.cdcooper%TYPE,
                       pr_dtmvtolt gnlcred.dtmvtolt%TYPE)IS
      SELECT *
        FROM gnlcred
       WHERE gnlcred.dtmvtolt = pr_dtmvtolt
         AND gnlcred.cdcooper = pr_cdcooper;
         
    -- Buscar agencias da coop
    CURSOR cr_crapage (pr_cdcooper gnlcred.cdcooper%TYPE)IS
      SELECT cdcooper,
             cdagenci,
             insitage
        FROM crapage 
       WHERE crapage.cdcooper = pr_cdcooper;
         
         
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    --Temptable para armazenar dados para o relatorio
    TYPE typ_rec_dados IS RECORD
         (cdcooper  gninfpl.cdcooper%TYPE,
          dtmvtolt  gninfpl.dtmvtolt%TYPE,
          cdagenci  gninfpl.cdagenci%TYPE,
          insitage  VARCHAR(12),
          qtassoci  crapger.qtassoci%TYPE,
          qtfuncio  NUMBER,
          nrlancam  INTEGER,
          depvista  NUMBER,
          sldordca  gninfpl.vlrdca30%TYPE,
          poupprga  gninfpl.vltotppr%TYPE,
          vlcapita  gninfpl.vldcotas%TYPE,
          vldsdfin  gnsldcx.vldsdfin%TYPE,
          vlemprst  gnlcred.vlemprst%TYPE,
          chespeci  gninfpl.vltotlim%TYPE,
          desccheq  gninfpl.vltotdsc%TYPE,
          vldsctit  gninfpl.vltottit%TYPE,
          somatori  NUMBER);
          
    TYPE typ_tab_dados IS TABLE OF typ_rec_dados
      INDEX BY VARCHAR2(18); -- cdcooper(5) cdagenci(5) dtmvtolt(8)
    
    vr_tab_dados typ_tab_dados;
    
    -- TempTable para armazenar as informações da agencia
    TYPE typ_tab_crapage IS TABLE OF cr_crapage%ROWTYPE
      INDEX BY PLS_INTEGER;
    vr_tab_crapage typ_tab_crapage;

    ------------------------------- VARIAVEIS -------------------------------
    -- Variáveis para armazenar as informações em XML
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    vr_dsdireto        VARCHAR2(100);
    -- nomer do arquivo de saida
    vr_nmarqimp        VARCHAR2(500); 
    -- variaveis de controle
    vr_dtultdia        DATE;
    vr_dtpridia        DATE;
    
    vr_idxdados VARCHAR2(30);
    vr_dsemail_dest VARCHAR2(2000);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_xml);
    END;
    
  --
  PROCEDURE pc_processa
    IS
  BEGIN   
    -- busca diretorio
    vr_dsdireto :=  gene0001.fn_diretorio(pr_tpdireto => 'C'
                                         ,pr_cdcooper => rw_crapcop.cdcooper);
                                         
	  -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL); 

    -- define nome do arquivo
    vr_nmarqimp := 'crps461_'||rw_crapcop.cdcooper||'.txt';
      
    -- Leitura da PL/Table e geração do arquivo XML
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    
    -- Montar Cabecalho
    pc_escreve_xml('Data;Cooperativa;PA;Situacao PA;Qtd.Cooperados;Qtd.Funcionarios;Lancamentos;'||
                   'Saldo Medio Dep.Vista;Saldos RDCA;Saldo Poup Program.;Saldo Capital;Saldo Medio Caixa;'||
                   'Saldo Emprestimos;Ch.Especial Utilizado;Desc.Cheques Utilizado;Desc.Titulos Utilizado;Dep.A Prazo;'||chr(10));
                 
    /* Pega ultimo dia do mes, indiferente de ser util ou nao */           
    vr_dtultdia := last_day(rw_crapdat.dtmvtolt);
    vr_dtpridia := trunc(rw_crapdat.dtmvtolt,'MM');
    
    -- carregar temptable de agencias
    FOR rw_crapage IN cr_crapage(pr_cdcooper) LOOP
      vr_tab_crapage(rw_crapage.cdagenci) := rw_crapage;
    END LOOP;
    
    -- Busca cadastro com informacoes gerenciais
    FOR rw_crapger IN cr_crapger (pr_cdcooper => pr_cdcooper,
                                  pr_dtrefere => vr_dtultdia) LOOP
      -- definir index
      vr_idxdados := lpad(rw_crapger.cdcooper,5,'0')|| to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')
                   ||lpad(rw_crapger.cdagenci,5,'0'); 

      -- verificar se registro já existe             
      IF NOT vr_tab_dados.exists(vr_idxdados) THEN
        -- criar registro
        vr_tab_dados(vr_idxdados).cdcooper := rw_crapger.cdcooper;
        vr_tab_dados(vr_idxdados).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_dados(vr_idxdados).cdagenci := rw_crapger.cdagenci;

        -- gravar informação da agencia se localizou
        IF vr_tab_crapage.exists(rw_crapger.cdagenci) THEN
          vr_tab_dados(vr_idxdados).insitage :=( CASE vr_tab_crapage(rw_crapger.cdagenci).insitage 
                                                 WHEN 0 THEN ' Implantacao'
                                                 WHEN 1 THEN ' Ativo'
                                                 WHEN 3 THEN ' Ativo'
                                                 ELSE ' Inativo'
                                                 END);
        END IF;
      END IF;
      
      vr_tab_dados(vr_idxdados).qtassoci := rw_crapger.qtassoci;
                         
    END LOOP; -- Fim loop rw_crapger

    -- Busca informacoes detalhadas para os relatorios gerenciais da intranet
    FOR rw_gninfpl IN cr_gninfpl(pr_cdcooper => pr_cdcooper,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      -- definir index
      vr_idxdados := lpad(rw_gninfpl.cdcooper,5,'0')|| to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')
                   ||lpad(rw_gninfpl.cdagenci,5,'0'); 

      -- verificar se registro já existe             
      IF NOT vr_tab_dados.exists(vr_idxdados) THEN
        -- criar registro
        vr_tab_dados(vr_idxdados).cdcooper := rw_gninfpl.cdcooper;
        vr_tab_dados(vr_idxdados).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_dados(vr_idxdados).cdagenci := rw_gninfpl.cdagenci;
        -- gravar informação da agencia se localizou
        IF vr_tab_crapage.exists(rw_gninfpl.cdagenci) THEN
          vr_tab_dados(vr_idxdados).insitage :=( CASE vr_tab_crapage(rw_gninfpl.cdagenci).insitage 
                                                 WHEN 0 THEN ' Implantacao'
                                                 WHEN 1 THEN ' Ativo'
                                                 WHEN 3 THEN ' Ativo'
                                                 ELSE ' Inativo'
                                                 END);
        END IF;
      END IF;
      
      -- atribuir dados
      vr_tab_dados(vr_idxdados).sldordca := rw_gninfpl.vlrdca30 + rw_gninfpl.vlrdca60;
      vr_tab_dados(vr_idxdados).poupprga := rw_gninfpl.vltotppr;
      vr_tab_dados(vr_idxdados).vlcapita := rw_gninfpl.vldcotas;
      vr_tab_dados(vr_idxdados).chespeci := rw_gninfpl.vltotlim;
      vr_tab_dados(vr_idxdados).desccheq := rw_gninfpl.vltotdsc;
      vr_tab_dados(vr_idxdados).vldsctit := rw_gninfpl.vltottit;
      
    END LOOP; -- fim gninfpl
    
    -- ler Tabela que contem os saldos de caixas
    FOR rw_gnsldcx IN cr_gnsldcx (pr_cdcooper => pr_cdcooper,
                                  pr_dtpridia => vr_dtpridia,
                                  pr_dtultdia => vr_dtultdia )LOOP
      -- definir index
      vr_idxdados := lpad(rw_gnsldcx.cdcooper,5,'0')|| to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')
                   ||lpad(rw_gnsldcx.cdagenci,5,'0'); 
      
      -- verificar se registro já existe             
      IF NOT vr_tab_dados.exists(vr_idxdados) THEN
        -- criar registro
        vr_tab_dados(vr_idxdados).cdcooper := rw_gnsldcx.cdcooper;
        vr_tab_dados(vr_idxdados).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_dados(vr_idxdados).cdagenci := rw_gnsldcx.cdagenci;
        
        -- gravar informação da agencia se localizou
        IF vr_tab_crapage.exists(rw_gnsldcx.cdagenci) THEN
          vr_tab_dados(vr_idxdados).insitage :=( CASE vr_tab_crapage(rw_gnsldcx.cdagenci).insitage 
                                                 WHEN 0 THEN ' Implantacao'
                                                 WHEN 1 THEN ' Ativo'
                                                 WHEN 3 THEN ' Ativo'
                                                 ELSE ' Inativo'
                                                 END);
        END IF;
               
        
        vr_tab_dados(vr_idxdados).vldsdfin := rw_gnsldcx.vldsdfin;
      ELSE
        vr_tab_dados(vr_idxdados).vldsdfin := nvl(vr_tab_dados(vr_idxdados).vldsdfin,0) + rw_gnsldcx.vldsdfin;  
      END IF;                                               
                                  
    END LOOP; -- Fim loop gnsldcx
    
    -- ler informacoes gerenciais acumuladas  
    FOR rw_crapacc IN cr_crapacc(pr_cdcooper => pr_cdcooper,
                                 pr_dtrefere => vr_dtultdia) LOOP
      
      -- definir index
      vr_idxdados := lpad(rw_crapacc.cdcooper,5,'0')|| to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')
                   ||lpad(rw_crapacc.cdagenci,5,'0'); 
      
      -- verificar se registro já existe             
      IF NOT vr_tab_dados.exists(vr_idxdados) THEN
        -- criar registro
        vr_tab_dados(vr_idxdados).cdcooper := rw_crapacc.cdcooper;
        vr_tab_dados(vr_idxdados).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_dados(vr_idxdados).cdagenci := rw_crapacc.cdagenci;
        
        -- gravar informação da agencia se localizou
        IF vr_tab_crapage.exists(rw_crapacc.cdagenci) THEN
          vr_tab_dados(vr_idxdados).insitage :=( CASE vr_tab_crapage(rw_crapacc.cdagenci).insitage 
                                                 WHEN 0 THEN ' Implantacao'
                                                 WHEN 1 THEN ' Ativo'
                                                 WHEN 3 THEN ' Ativo'
                                                 ELSE ' Inativo'
                                                 END);
        END IF;
               
        vr_tab_dados(vr_idxdados).nrlancam := rw_crapacc.qtlanmto;
      ELSE
        vr_tab_dados(vr_idxdados).nrlancam := nvl(vr_tab_dados(vr_idxdados).nrlancam,0) + rw_crapacc.qtlanmto;  
      END IF;                                               
    
    END LOOP;-- Fim Loop crapacc
    
    -- ler os totais de emprestimo por linha de credito
    FOR rw_gnlcred IN cr_gnlcred( pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
    
      -- definir index
      vr_idxdados := lpad(rw_gnlcred.cdcooper,5,'0')|| to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')
                   ||lpad(rw_gnlcred.cdagenci,5,'0'); 
      
      -- verificar se registro já existe             
      IF NOT vr_tab_dados.exists(vr_idxdados) THEN
        -- criar registro
        vr_tab_dados(vr_idxdados).cdcooper := rw_gnlcred.cdcooper;
        vr_tab_dados(vr_idxdados).dtmvtolt := rw_crapdat.dtmvtolt;
        vr_tab_dados(vr_idxdados).cdagenci := rw_gnlcred.cdagenci;
        
        -- gravar informação da agencia se localizou
        IF vr_tab_crapage.exists(rw_gnlcred.cdagenci) THEN
          vr_tab_dados(vr_idxdados).insitage :=( CASE vr_tab_crapage(rw_gnlcred.cdagenci).insitage 
                                                 WHEN 0 THEN ' Implantacao'
                                                 WHEN 1 THEN ' Ativo'
                                                 WHEN 3 THEN ' Ativo'
                                                 ELSE ' Inativo'
                                                 END);
        END IF;
      END IF;  
      
      vr_tab_dados(vr_idxdados).vlemprst := rw_gnlcred.vlemprst;  
      
    END LOOP; -- Fim loop gnlcred
    
    -- ler tabela de dados para gerar o arquivo
    vr_idxdados := vr_tab_dados.first;
    -- enquanto encontrar indice, faz
    WHILE vr_idxdados IS NOT NULL LOOP
      -- calcular valores
      vr_tab_dados(vr_idxdados).vldsdfin := vr_tab_dados(vr_idxdados).vldsdfin / rw_crapdat.qtdiaute;
      vr_tab_dados(vr_idxdados).somatori := nvl(vr_tab_dados(vr_idxdados).sldordca,0) + nvl(vr_tab_dados(vr_idxdados).poupprga,0);

      -- escrever linhas
      pc_escreve_xml( to_char(vr_tab_dados(vr_idxdados).dtmvtolt,'DD/MM/RRRR') ||';'||
                      to_char(vr_tab_dados(vr_idxdados).cdcooper,'99999')||';'||
                      lpad(vr_tab_dados(vr_idxdados).cdagenci,3,' ') ||';'||
                      RPAD(vr_tab_dados(vr_idxdados).insitage,12,' ') ||';'||
                      lpad(to_char(nvl(vr_tab_dados(vr_idxdados).qtassoci,0),'fm999G990'),7,' ') ||';'||
                      lpad(to_char(nvl(vr_tab_dados(vr_idxdados).qtfuncio,0),'fm999G990'),7,' ') ||';'||
                      lpad(to_char(nvl(vr_tab_dados(vr_idxdados).nrlancam,0),'fm99G999G990'),10,' ') ||';'||
                      lpad(to_char(nvl(vr_tab_dados(vr_idxdados).depvista,0),'fm999G990D00'),10,' ') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).sldordca,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).poupprga,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).vlcapita,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).vldsdfin,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).vlemprst,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).chespeci,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).desccheq,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).vldsctit,0),'999G999G999G990D00MI') ||';'||
                      to_char(nvl(vr_tab_dados(vr_idxdados).somatori,0),'99G999G999G990D00') 
                      ||';'||chr(10));
                      
      -- buscar proximo
      vr_idxdados := vr_tab_dados.next(vr_idxdados);
    END LOOP;
    
    -- Descarregar o buffer
    pc_escreve_xml(' ',TRUE);
    
    -- buscar emails de destino
    vr_dsemail_dest := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                                 pr_cdcooper => pr_cdcooper, 
                                                 pr_cdacesso => 'CRPS461_EMAIL');

	  -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper               --> Cooperativa conectada
                                       ,pr_cdprogra  => vr_cdprogra               --> Programa chamador
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/arq/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'N'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'S'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => vr_dsdireto||'/salvar/'   --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => vr_dsemail_dest           --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => 'Informacoes Gerenciais ' --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro

	  -- Retorna nome do módulo e ação logado - Chamado 721285 31/07/2017
		GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv);
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      RAISE vr_exc_saida;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 04/08/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      vr_dscritic := 'pc_processa com erro: ' || SQLERRM;
      RAISE vr_exc_saida;
  END pc_processa;
  --

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
    -- Quando for data para não processar não vai gerar Log - Chamado 721285 - 04/08/2017
    /*  Se proximo data de movimento estiver no mes Atual */ 
    IF to_char(rw_crapdat.dtmvtopr,'MM') <> to_char(rw_crapdat.dtmvtolt,'MM') THEN
      pc_processa;
    END IF;    
    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Ajustada chamada para buscar a descrição da critica - 04/08/2017 - Chamado 721285
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 31/07/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END pc_crps461;
/
