CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS015 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS015                      Antigo: Fontes/CRPS015.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                       Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 004.
               Emite relatorio dos associados admitidos no mes (19) e
               etiquetas com o numero de matricula dos mesmos (20).

   Alteracao : 23/12/98 - Alterar relatorio de atendimento (Odair)
 
               29/12/1999 - Nao gerar mais pedido de impressao (Edson).

               26/10/2000 - Ajustar o lay-out do rel. 20 para imprimir na laser
                            Alterar o nome do formulario (glb_nmformul) 
                            Salto de pagina a cada 20 display

               28/05/2002 - Ajuste na paginacao. (Deborah).

               10/12/2002 - Nao imprimir mais as etiquetas de matricula 
                            (Deborah).
                            
               06/07/2005 - Retirado campo do estado civil e incluido campo
                            de integralizacao de capital (Evandro).

               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapadm (Diego).
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               19/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               31/10/2007 - Alterado nmdsecao(crapass) para crapttl.nmdsecao
                            (Guilherme).           
                              
               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao CDEMPRES (Kbase).
                          
               30/11/2010 - 001 / Alterado Format "x(40)" para Format "x(50)" 
                            (Danielle/Kbase)

               25/04/2011 - Ajuste de aumento nos formatos de bairro e cidade
                            (Gabriel).            

               31/10/2013 - Remover geracao do crrl020 - Softdesk 103210
                            (Lucas R.)
                            
               18/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
               
			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).
               
     ............................................................................. */

     DECLARE

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
         FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       
       --Selecionar Admissoes
       CURSOR cr_crapadm (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapadm.nrdconta
         FROM crapadm
         WHERE crapadm.cdcooper = pr_cdcooper
         ORDER BY crapadm.cdcooper,crapadm.nrmatric;
     
       --Selecionar Historicos
       CURSOR cr_craphis (pr_cdcooper IN craphis.cdcooper%TYPE) IS
         SELECT craphis.cdhistor
               ,craphis.inhistor
               ,craphis.indebcre
               ,craphis.dshistor 
         FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper;     

       --Selecionar informacoes do titular
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                         ,pr_nrdconta IN crapttl.nrdconta%type
                         ,pr_idseqttl IN crapttl.idseqttl%type) IS
         SELECT crapttl.nmextttl
               ,crapttl.nrcpfcgc
               ,crapttl.cdempres
               ,crapttl.cdturnos
         FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
         AND   crapttl.nrdconta = pr_nrdconta
         AND   crapttl.idseqttl = pr_idseqttl;
       rw_crapttl cr_crapttl%ROWTYPE;
         
       --Selecionar dados Pessoa Juridica
       CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                         ,pr_nrdconta IN crapjur.nrdconta%type) IS
         SELECT crapjur.nmextttl
               ,crapjur.cdempres
         FROM crapjur
         WHERE crapjur.cdcooper = pr_cdcooper
         AND   crapjur.nrdconta = pr_nrdconta;
       rw_crapjur cr_crapjur%ROWTYPE;
       
       -- Busca dos dados do associado
       CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapass.nrdconta
               ,crapass.nmprimtl
               ,crapass.vllimcre
               ,crapass.nrcpfcgc
               ,crapass.inpessoa
               ,crapass.cdcooper
               ,crapass.cdagenci
               ,crapass.dtadmiss
               ,crapass.nrmatric
               ,crapass.tpdocptl
               ,crapass.nrdocptl
               ,crapass.dtnasctl
               ,crapass.dsnacion
               ,crapass.dsproftl
         FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
         AND   crapass.nrdconta = pr_nrdconta;
       rw_crapass cr_crapass%ROWTYPE;

       --Selecionar Lancamentos Cota Capital
       CURSOR cr_craplct (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE
                         ,pr_dtadmiss IN crapdat.dtmvtolt%TYPE) IS
         SELECT /*+ INDEX (craplct craplct##craplct2) */ craplct.cdhistor
               ,nvl(SUM(nvl(craplct.vllanmto,0)),0) vllanmto
         FROM craplct 
         WHERE craplct.cdcooper = pr_cdcooper            
         AND   craplct.nrdconta = pr_nrdconta 
         AND   trunc(craplct.dtmvtolt,'MM') = pr_dtadmiss
         GROUP BY craplct.cdhistor;      

       --Selecionar Endereco Cooperador
       CURSOR cr_crapenc (pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
         SELECT crapenc.dsendere
               ,crapenc.nrendere
               ,crapenc.nmbairro
               ,crapenc.nrcepend
               ,crapenc.nmcidade
               ,crapenc.cdufende
         FROM crapenc
         WHERE crapenc.cdcooper = pr_cdcooper      
         AND   crapenc.nrdconta = pr_nrdconta  
         AND   crapenc.idseqttl = 1                 
         AND   crapenc.cdseqinc = 1;
       rw_crapenc cr_crapenc%ROWTYPE;               

       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS015';
       vr_nmarqimp CONSTANT VARCHAR2(20):= 'crrl019.lst'; 
       
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Tabela de Memoria de Historicos
       vr_tab_craphis CADA0001.typ_tab_craphis;
       
       --Variaveis Locais
       vr_vltotcap     NUMBER;
       vr_vlcapita     NUMBER;
       vr_cdempres     INTEGER;
       vr_nrcpfcgc     VARCHAR2(20);
       vr_caminho      VARCHAR2(100);
       vr_dsendres     VARCHAR2(200);
       vr_des_xml      CLOB;
       
       --Variaveis para retorno de erro
       vr_cdcritic     INTEGER:= 0;
       vr_dscritic     VARCHAR2(4000);

       --Variaveis de Excecao
       vr_exc_saida    EXCEPTION;
       vr_exc_fimprg   EXCEPTION;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_craphis.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS015.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_limpa_tabela;
       
       --Procedure para Inicializar os CLOBs
       PROCEDURE pc_inicializa_clob IS
       BEGIN
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);  
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps015.pc_inicializa_clob. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_inicializa_clob;

       --Procedure para Finalizar os CLOBs
       PROCEDURE pc_finaliza_clob IS
       BEGIN
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);            
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao finalizar CLOB. Rotina pc_crps015.pc_finaliza_clob. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_finaliza_clob;

       
       --Escrever no arquivo CLOB
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Se foi passada infomacao
         IF pr_des_dados IS NOT NULL THEN
           --Escrever no Clob do relatorio
           dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
       END pc_escreve_xml;
     
     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS015
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;  
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       /*  Carrega tabela de indicadores de historicos  */
       FOR rw_craphis IN cr_craphis (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_craphis(rw_craphis.cdhistor).cdhistor:= rw_craphis.cdhistor;
         vr_tab_craphis(rw_craphis.cdhistor).inhistor:= rw_craphis.inhistor;
         vr_tab_craphis(rw_craphis.cdhistor).indebcre:= rw_craphis.indebcre;
         vr_tab_craphis(rw_craphis.cdhistor).dshistor:= rw_craphis.dshistor; 
       END LOOP;
              
       --Buscar Diretorio padrao Relatorios para a cooperativa
       vr_caminho:= lower(gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop/Win12
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'rl'));
       --Se nao encontrou
       IF vr_caminho IS NULL THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Diretorio padrao da cooperativa não encontrado!';
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;  
       
       --Criar Clob para relatorio
       pc_inicializa_clob;
       
       --Criar tag xml do totalizador
       pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl019><contas>');
           
       --Zerar Totalizador
       vr_vltotcap:= 0;

       --Percorrer Admissoes
       FOR rw_crapadm IN cr_crapadm (pr_cdcooper => pr_cdcooper) LOOP
         --Selecionar Dados Associado
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapadm.nrdconta);
         FETCH cr_crapass INTO rw_crapass;
         --Se nao encontrou associado
         IF cr_crapass%NOTFOUND THEN
           vr_cdcritic:= 9;
           vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic)||
                         gene0002.fn_mask(rw_crapadm.nrdconta,'zzzz.zzz.9');
           --Fechar Cursor
           CLOSE cr_crapass;
           --Levantar Excecao
           RAISE vr_exc_saida;
         END IF;
         --Fechar Cursor
         CLOSE cr_crapass;
        
         --Inicializar variaveis
         vr_vlcapita:= 0;
         vr_cdempres:= 0; 
        
         --Formatar Cpf/cnpj
         vr_nrcpfcgc:= gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa);

         /* calculo do valor de integralizacao de capital no mes da admissao */
        
         --Selecionar Lancamentos Cota Capital
         FOR rw_craplct IN cr_craplct (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapass.nrdconta
                                      ,pr_dtadmiss => trunc(rw_crapass.dtadmiss,'MM')) LOOP
           --Se Encontrou Historico
           IF vr_tab_craphis.EXISTS(rw_craplct.cdhistor) AND 
              vr_tab_craphis(rw_craplct.cdhistor).indebcre = 'C' THEN
             --Acumular Valor Capital
             vr_vlcapita:= nvl(vr_vlcapita,0) + nvl(rw_craplct.vllanmto,0);
             --Acumular Total Capital
             vr_vltotcap:= nvl(vr_vltotcap,0) + nvl(rw_craplct.vllanmto,0); 
           END IF;                             
         END LOOP;
         --Selecionar Endereco Cooperador
         OPEN cr_crapenc (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta);
         FETCH cr_crapenc INTO rw_crapenc;
         --Se Encontrou
         IF cr_crapenc%FOUND THEN
           --Se o numero endereco for zero joga null
           IF rw_crapenc.nrendere = 0 THEN
             rw_crapenc.nrendere:= NULL;
           END IF;  
           --montar Endereco
           vr_dsendres:= SUBSTR(rw_crapenc.dsendere,1,29) ||' '||
                         TRIM(gene0002.fn_mask(rw_crapenc.nrendere,'ZZZ.ZZZ'));
         END IF;  
         --Fechar Cursor
         CLOSE cr_crapenc;                  

         /* Nome do titular que fez a transferencia */
         OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_idseqttl => 1);
         --Posicionar no proximo registro
         FETCH cr_crapttl INTO rw_crapttl;
         --Se encontrou
         IF cr_crapttl%FOUND THEN
           --Codigo Empresa
           vr_cdempres:= rw_crapttl.cdempres;  
           --Escrever Dados da Conta no Arquivo
           pc_escreve_xml
              ('<conta>
                <nrdconta>'||GENE0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                <nrmatric>'||GENE0002.fn_mask(rw_crapass.nrmatric,'ZZZ.ZZ9')||'</nrmatric>
                <nmprimtl>'||SUBSTR(rw_crapass.nmprimtl,1,50)||'</nmprimtl>
                <nrcpfcgc>'||vr_nrcpfcgc||'</nrcpfcgc>                
                <tpdocptl>'||gene0002.fn_mask(rw_crapass.tpdocptl,'ZZ')||'</tpdocptl>
                <nrdocptl>'||SUBSTR(rw_crapass.nrdocptl,1,15)||'</nrdocptl>
                <dtnasctl>'||to_char(rw_crapass.dtnasctl,'DD/MM/YYYY')||'</dtnasctl>                                                                
                <dsnacion>'||SUBSTR(rw_crapass.dsnacion,1,13)||'</dsnacion>                                                                
                <dsproftl>'||SUBSTR(rw_crapass.dsproftl,1,20)||'</dsproftl>
                <cdempres>'||gene0002.fn_mask(vr_cdempres,'ZZZ99')||'</cdempres>
                <cdturnos>'||gene0002.fn_mask(rw_crapttl.cdturnos,'99')||'</cdturnos>
                <dsendres>'||SUBSTR(gene0007.fn_caract_acento(vr_dsendres),1,37)||'</dsendres>
                <nmbairro>'||SUBSTR(rw_crapenc.nmbairro,1,40)||'</nmbairro>
                <nrcepend>'||gene0002.fn_mask(rw_crapenc.nrcepend,'99.999.999')||'</nrcepend>
                <nmcidade>'||SUBSTR(rw_crapenc.nmcidade,1,25)||'</nmcidade>
                <cdufende>'||SUBSTR(rw_crapenc.cdufende,1,2)||'</cdufende> 
                <vlcapita>'||to_char(vr_vlcapita,'fm999g999g999g990d00')||'</vlcapita>                                                               
                </conta>');
         ELSE
           /** Lista o nome da empresa **/
           OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta);
           FETCH cr_crapjur INTO rw_crapjur;
           --Se Encontrou
           IF cr_crapjur%FOUND THEN
             --Codigo Empresa
             vr_cdempres:= rw_crapjur.cdempres;
           END IF;
           --Fechar Cursor
           CLOSE cr_crapjur;
           --Escrever Dados da Conta no Arquivo
           pc_escreve_xml
             ('<conta>
                <nrdconta>'||GENE0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                <nrmatric>'||GENE0002.fn_mask(rw_crapass.nrmatric,'ZZZ.ZZ9')||'</nrmatric>
                <nmprimtl>'||SUBSTR(rw_crapass.nmprimtl,1,50)||'</nmprimtl>
                <nrcpfcgc>'||vr_nrcpfcgc||'</nrcpfcgc>                
                <tpdocptl>'||gene0002.fn_mask(rw_crapass.tpdocptl,'ZZ')||'</tpdocptl>
                <nrdocptl>'||SUBSTR(rw_crapass.nrdocptl,1,15)||'</nrdocptl>
                <dtnasctl>'||to_char(rw_crapass.dtnasctl,'DD/MM/YYYY')||'</dtnasctl>                                                                
                <dsnacion>'||SUBSTR(rw_crapass.dsnacion,1,13)||'</dsnacion>                                                                
                <dsproftl>'||SUBSTR(rw_crapass.dsproftl,1,20)||'</dsproftl>
                <cdempres>'||gene0002.fn_mask(vr_cdempres,'ZZZ99')||'</cdempres>
                <cdturnos></cdturnos>
                <dsendres>'||SUBSTR(gene0007.fn_caract_acento(vr_dsendres),1,37)||'</dsendres>
                <nmbairro>'||SUBSTR(rw_crapenc.nmbairro,1,40)||'</nmbairro>
                <nrcepend>'||gene0002.fn_mask(rw_crapenc.nrcepend,'99.999.999')||'</nrcepend>
                <nmcidade>'||SUBSTR(rw_crapenc.nmcidade,1,25)||'</nmcidade>
                <cdufende>'||SUBSTR(rw_crapenc.cdufende,1,2)||'</cdufende> 
                <vlcapita>'||to_char(vr_vlcapita,'fm999g999g999g990d00')||'</vlcapita>                                                               
             </conta>');
         END IF;
         --Fechar Cursor
         CLOSE cr_crapttl;
       END LOOP;

       --Fechar tag xml do relatorio
       pc_escreve_xml('</contas></crrl019>');

       --Solicitar geracao do arquivo por agencia
       gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                  ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                  ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                  ,pr_dsxmlnode => '/crrl019/contas/conta'  --> Nó base do XML para leitura dos dados
                                  ,pr_dsjasper  => 'crrl019.jasper'    --> Arquivo de layout do iReport
                                  ,pr_dsparams  => NULL                --> Titulo do relatório
                                  ,pr_dsarqsaid => vr_caminho||'/'||vr_nmarqimp --> Arquivo final
                                  ,pr_qtcoluna  => 132                 --> 132 colunas
                                  ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                  ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                  ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                  ,pr_nrcopias  => 1                   --> Número de cópias
                                  ,pr_flg_gerar => 'N'                 --> gerar PDF
                                  ,pr_des_erro  => vr_dscritic);       --> Saída com erro
                                      
       --Se ocorreu erro
       IF vr_dscritic IS NOT NULL THEN
         --Levantar Excecao
         RAISE vr_exc_saida;
       END IF;
         
       -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);       
                                 
       --Limpar Memoria alocada pelo Clob
       pc_finaliza_clob;
       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;
                                
       --Salvar informacoes no banco de dados
       COMMIT;
       
       
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao da critica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Se foi gerada critica para envio ao log
         IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;
         -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS015;
/

