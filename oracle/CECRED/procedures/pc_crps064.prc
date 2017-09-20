CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS064" (pr_cdcooper IN crapcop.cdcooper%TYPE
                                         ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                                         ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                         ,pr_infimsol OUT PLS_INTEGER
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                         ,pr_dscritic OUT VARCHAR2) IS
  BEGIN

  /* .............................................................................

   Programa: pc_crps064                          Antigo: Fontes/crps064.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Agosto/93.                          Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 035.
               Encerramento do periodo de apuracao do IPMF.

   Alteracoes: 14/01/97 - Alterado para tratar CPMF (Deborah).

               23/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/07/98 - Tratamento da CPMF para programa que le lcm (Odair)

               24/08/98 - Acertar vlbascpm = 0 (Odair)

               08/09/98 - Acerto na atualizacao da base compensada no crapper
                          (Deborah).

               21/08/03 - Modificar o historico de 005 para 188 (Ze Eduardo).

               28/06/2005 - Alimentado campo cdcooper das tabelas crapipm e
                            craprej (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               08/06/2006 - Alteracao na atualizacao do campo crapper.dtfimper
                            (Julio)

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               22/05/2013 - Conversão Progress -> Oracle - Alisson (AMcom)

               25/07/2013 - Ajustes na chamada da fn_mask_cpf_cnpj para passar o
                            inpessoa (Marcos-Supero)
							
               12/05/2014 - Ajustado update crapsld incluso tratamento com NVL (Daniel).							

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

     ............................................................................. */

     DECLARE

       /* Tipos e registros da pc_crps064 */

       --Definicao do tipo de registro para insert crapipm
       TYPE typ_reg_crapipm IS
         RECORD (dtdebito crapipm.dtdebito%TYPE
                ,indebito crapipm.indebito%TYPE
                ,nrdconta crapipm.nrdconta%TYPE
                ,vlbasipm crapipm.vlbasipm%TYPE
                ,vldoipmf crapipm.vldoipmf%TYPE
                ,cdcooper crapipm.cdcooper%TYPE);

       --Definicao do tipo de registro para insert craprej
       TYPE typ_reg_craprej IS
         RECORD (cdpesqbb craprej.cdpesqbb%TYPE
                ,vllanmto craprej.vllanmto%TYPE
                ,nrdconta craprej.nrdconta%TYPE
                ,cdcooper craprej.cdcooper%TYPE);

       --Definicao do tipo de registro para update crapsld
       TYPE typ_reg_crapsld IS
         RECORD (vlipmfpg crapsld.vlipmfpg%TYPE
                ,vlipmfap crapsld.vlipmfap%TYPE
                ,vlbasipm crapsld.vlbasipm%TYPE
                ,nrdconta crapsld.nrdconta%TYPE
                ,cdcooper crapsld.cdcooper%TYPE);

       --Definicao do tipo de registro para os associados
       TYPE typ_reg_crapass IS
         RECORD (nrcpfcgc crapass.nrcpfcgc%TYPE
                ,nmprimtl crapass.nmprimtl%TYPE
                ,nmsegntl crapttl.nmextttl%TYPE
                ,inpessoa crapass.inpessoa%TYPE);


       --Definicao dos tipos de tabelas de memoria
       TYPE typ_tab_crapipm  IS TABLE OF typ_reg_crapipm INDEX BY PLS_INTEGER;
       TYPE typ_tab_craprej  IS TABLE OF typ_reg_craprej INDEX BY PLS_INTEGER;
       TYPE typ_tab_craprej2 IS TABLE OF typ_reg_craprej INDEX BY VARCHAR2(20);
       TYPE typ_tab_crapass  IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       TYPE typ_tab_crapsld  IS TABLE OF typ_reg_crapsld INDEX BY PLS_INTEGER;

       --Definicao das tabelas de memoria
       vr_tab_crapipm      typ_tab_crapipm;
       vr_tab_craprej      typ_tab_craprej;
       vr_tab_craprej2     typ_tab_craprej2;
       vr_tab_crapsld      typ_tab_crapsld;
       vr_tab_crapass      typ_tab_crapass;
       vr_tab_erro         GENE0001.typ_tab_erro;


       --Cursores da rotina crps064

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       --Selecionar informacoes dos periodos de apuracao
       CURSOR cr_crapper (pr_cdcooper IN crapper.cdcooper%TYPE
                         ,pr_dtfimper IN crapper.dtfimper%TYPE
                         ,pr_infimper IN crapper.infimper%TYPE) IS
         SELECT crapper.dtdebito
               ,crapper.rowid
         FROM crapper
         WHERE crapper.cdcooper  = pr_cdcooper
         AND   crapper.dtfimper  < pr_dtfimper
         AND   crapper.infimper  = pr_infimper;

       --Selecionar informacoes do saldo das aplicacoes
       CURSOR cr_crapsld (pr_cdcooper IN crapsld.cdcooper%TYPE) IS
         SELECT crapsld.nrdconta
               ,crapsld.vlbasipm
               ,crapsld.vlipmfap
               ,crapsld.vlipmfpg
         FROM crapsld crapsld
         WHERE crapsld.cdcooper = pr_cdcooper;

       --Selecionar informacoes dos associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT /*+ index (crapass crapass##crapass7) */
                crapass.nrdconta
               ,crapass.nrcpfcgc
               ,crapass.nmprimtl
               ,crapass.inpessoa
               ,crapass.cdcooper
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;

	   --Selecionar informacoes do titular
       CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
	                       ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
         SELECT crapttl.nmextttl
         FROM crapttl
         WHERE crapttl.cdcooper = pr_cdcooper
		   AND crapttl.nrdconta = pr_nrdconta
		   AND crapttl.idseqttl = 2;

       /***** Variaveis RDCA para BO *****/
       vr_cdprogra     VARCHAR2(10);
       vr_cdcritic     INTEGER;

       --Variavel usada para montar o indice da tabela de memoria
       vr_index_crapipm  INTEGER;
       vr_index_craprej  INTEGER;
       vr_index_crapsld  INTEGER;
       vr_index_craprej2 VARCHAR2(20);
       vr_contador       NUMBER:= 0;

       --Variaveis da Crapdat
       vr_dtmvtolt     DATE;
       vr_dtmvtopr     DATE;
       vr_dtmvtoan     DATE;
       vr_dtultdia     DATE;
       vr_qtdiaute     INTEGER;

	     -- Variável para armazenar as informações em XML
       vr_XMLType     XMLType;
       vr_des_xml     CLOB;
       vr_cod_chave   INTEGER;
       vr_erro_clob   VARCHAR2(4000);
       vr_des_chave   VARCHAR2(400);

       --Variaveis para retorno de erro
       vr_des_erro    VARCHAR2(4000);
       vr_des_compl   VARCHAR2(4000);
       vr_dstextab    VARCHAR2(1000);

       --Variavel para arquivo de dados e xml
       vr_nom_direto  VARCHAR2(100);
       vr_nom_arquivo VARCHAR2(100);

       --Variaveis de Totais para o Periodo
       vr_tot_vlbasipm NUMBER:= 0;
       vr_tot_vlipmfap NUMBER:= 0;


       --Variaveis de Excecao
       vr_exc_undo   EXCEPTION;
       vr_exc_saida  EXCEPTION;
       vr_exc_fimprg EXCEPTION;
       vr_exc_pula   EXCEPTION;
       vr_nmextttl   crapttl.nmextttl%TYPE;

       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapipm.DELETE;
         vr_tab_craprej.DELETE;
         vr_tab_crapass.DELETE;
         vr_tab_craprej2.DELETE;
         vr_tab_crapsld.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_des_erro:= 'Erro ao limpar tabelas de memória. Rotina pc_crps323.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END;

	     --Escrever no arquivo CLOB
	     PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
       BEGIN
         --Escrever no arquivo XML
         dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
       END;

	     --Geração do relatório crrl054
       PROCEDURE pc_imprime_crrl054 (pr_des_erro OUT VARCHAR2) IS

         --Constantes
         vr_cdhistor CONSTANT INTEGER:= 188;
         vr_nrdocmto CONSTANT INTEGER:= 999905;

         --Variaveis
         vr_nrdconta crapass.nrdconta%TYPE;
         vr_nmsegntl crapttl.nmextttl%TYPE;

		     --Variavel de Exceção
		     vr_exc_saida EXCEPTION;

	     BEGIN
	       --Inicializar variavel de erro
		     pr_des_erro:= NULL;

         -- Busca do diretório base da cooperativa
         vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
         --Determinar o nome do arquivo que será gerado
         vr_nom_arquivo := 'crrl054';
         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_des_xml, TRUE);
         dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
         -- Inicilizar as informações do XML
         pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl054><contas>');

         --Acessar primeiro registro da tabela de memoria
         vr_index_craprej2:= vr_tab_craprej2.FIRST;
         WHILE vr_index_craprej2 IS NOT NULL  LOOP

           --Determinar a conta para uso no indice
           vr_nrdconta:= vr_tab_craprej2(vr_index_craprej2).nrdconta;

           --verificar se o associado existe
           IF NOT vr_tab_crapass.EXISTS(vr_nrdconta) THEN
             --Montar mensagem de critica
             vr_cdcritic:= 251;
             vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||
                            ' CONTA-REJ = '||vr_nrdconta;
             --Levantar Excecao
             RAISE vr_exc_saida;
           ELSE
             --Se existir segundo titular mostra esse nome
             IF vr_tab_crapass(vr_nrdconta).nmsegntl IS NOT NULL THEN
               --Nome do segundo titular
               vr_nmsegntl:= vr_tab_crapass(vr_nrdconta).nmsegntl;
             ELSE
               --O relatório irá ocultar o nome do segundo titular se enviar o dado = BRANCO
               vr_nmsegntl:= 'BRANCO';
             END IF;

           END IF;

           --Montar tag da conta para arquivo XML
           pc_escreve_xml
             ('<conta>
                <cdhistor>'||vr_cdhistor||'</cdhistor>
                <nrdconta>'||GENE0002.fn_mask_conta(vr_nrdconta)||'</nrdconta>
                <nrdocmto>'||To_Char(vr_nrdocmto,'fm999g999g999')||'</nrdocmto>
                <nrcpfcgc>'||GENE0002.fn_mask_cpf_cnpj(vr_tab_crapass(vr_nrdconta).nrcpfcgc,vr_tab_crapass(vr_nrdconta).inpessoa)||'</nrcpfcgc>
                <nmprimtl>'||vr_tab_crapass(vr_nrdconta).nmprimtl||'</nmprimtl>
                <nmsegntl>'||vr_nmsegntl||'</nmsegntl>
                <vllanmto>'||To_Char(vr_tab_craprej2(vr_index_craprej2).vllanmto,'fm999g999g999g990d00')||'</vllanmto>
             </conta>');
           --Encontrar o proximo registro da tabela de memoria
           vr_index_craprej2:= vr_tab_craprej2.NEXT(vr_index_craprej2);
         END LOOP;

         --Finalizar tag detalhe
         pc_escreve_xml('</contas></crrl054>');

         --Efetuar solicitação de geração de relatório --
         gene0002.pc_solicita_relato (pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                     ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/crrl054/contas/conta'       --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl054.jasper'    --> Arquivo de layout do iReport
                                     ,pr_dsparams  => NULL                --> Titulo do relatório
                                     ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nom_arquivo||'.lst' --> Arquivo final
                                     ,pr_qtcoluna  => 132                 --> 132 colunas
                                     ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                     ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => NULL                --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 1                   --> Número de cópias
                                     ,pr_flg_gerar => 'N'                 --> gerar PDF
                                     ,pr_des_erro  => vr_des_erro);       --> Saída com erro
         -- Testar se houve erro
         IF vr_des_erro IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_saida;
         END IF;

         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_des_xml);
         dbms_lob.freetemporary(vr_des_xml);

	     EXCEPTION
	       WHEN vr_exc_saida THEN
		       pr_des_erro:= vr_des_erro;
         WHEN OTHERS THEN
           pr_des_erro:= 'Erro ao imprimir relatório crrl054. '||sqlerrm;
	     END;

     ---------------------------------------
     -- Inicio Bloco Principal pc_crps064
     ---------------------------------------
     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS064';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS064'
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a cooperativa esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_des_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
         --Atribuir a data do movimento
         vr_dtmvtolt:= rw_crapdat.dtmvtolt;
         --Atribuir a proxima data do movimento
         vr_dtmvtopr:= rw_crapdat.dtmvtopr;
         --Atribuir a data do movimento anterior
         vr_dtmvtoan:= rw_crapdat.dtmvtoan;
         --Atribuir a quantidade de dias uteis
         vr_qtdiaute:= rw_crapdat.qtdiaute;
         --Ultimo dia do mes anterior
         vr_dtultdia:= rw_crapdat.dtultdma;
       END IF;

       -- Validações iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 1
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);
       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       --Carregar tabela de memoria de associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP

         --Popular vetor de memoria
         vr_tab_crapass(rw_crapass.nrdconta).nrcpfcgc:= rw_crapass.nrcpfcgc;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl;
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa;

		 IF rw_crapass.inpessoa = 1 THEN
		    
	       OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
		                    ,pr_nrdconta => rw_crapass.nrdconta);

		   FETCH cr_crapttl INTO vr_nmextttl;

		   IF cr_crapttl%FOUND THEN
		     
		     vr_tab_crapass(rw_crapass.nrdconta).nmsegntl:= vr_nmextttl;

		   END IF;

		   CLOSE cr_crapttl;

	     END IF;

       END LOOP;

       --Pesquisar todos os associados
       FOR rw_crapper IN cr_crapper (pr_cdcooper => pr_cdcooper
                                    ,pr_dtfimper => rw_crapdat.dtmvtopr
                                    ,pr_infimper => 1) LOOP
         --Zerar total base ipmf
         vr_tot_vlbasipm:= 0;
         --Zerar total ipmf apurado
         vr_tot_vlipmfap:= 0;

         --Pesquisar todos os saldos
         FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP

           --Se o valor base ipmf for positivo e valor ipmf apurado maior ou igual a zero
           IF Nvl(rw_crapsld.vlbasipm,0) > 0 AND Nvl(rw_crapsld.vlipmfap,0) >= 0 THEN
             --Inserir imposto
             vr_index_crapipm:= vr_tab_crapipm.Count+1;
             vr_tab_crapipm(vr_index_crapipm).dtdebito:= rw_crapper.dtdebito;
             vr_tab_crapipm(vr_index_crapipm).indebito:= 1;
             vr_tab_crapipm(vr_index_crapipm).nrdconta:= rw_crapsld.nrdconta;
             vr_tab_crapipm(vr_index_crapipm).vlbasipm:= rw_crapsld.vlbasipm;
             vr_tab_crapipm(vr_index_crapipm).vldoipmf:= rw_crapsld.vlipmfap;
             vr_tab_crapipm(vr_index_crapipm).cdcooper:= pr_cdcooper;

             --Atualizar tabela saldo diario
             vr_index_crapsld:= vr_tab_crapsld.Count+1;
             vr_tab_crapsld(vr_index_crapsld).vlipmfpg:= Nvl(rw_crapsld.vlipmfpg,0) + Nvl(rw_crapsld.vlipmfap,0);
             vr_tab_crapsld(vr_index_crapsld).vlipmfap:= 0;
             vr_tab_crapsld(vr_index_crapsld).vlbasipm:= 0;
             vr_tab_crapsld(vr_index_crapsld).nrdconta:= rw_crapsld.nrdconta;
             vr_tab_crapsld(vr_index_crapsld).cdcooper:= pr_cdcooper;

           ELSE

             --Se valor ipmf apurado for negativo
             IF Nvl(rw_crapsld.vlipmfap,0) < 0 THEN

               vr_index_craprej:= vr_tab_craprej.Count+1;
               vr_tab_craprej(vr_index_craprej).nrdconta:= rw_crapsld.nrdconta;
               vr_tab_craprej(vr_index_craprej).vllanmto:= (rw_crapsld.vlipmfap * -1);
               vr_tab_craprej(vr_index_craprej).cdpesqbb:= vr_cdprogra;
               vr_tab_craprej(vr_index_craprej).cdcooper:= pr_cdcooper;

               --Popular tabela de memoria usada pelo relatorio crrl054 (ordenado por conta
               --Incrementar contador
               vr_contador:= Nvl(vr_contador,0) + 1;
               --Inserir rejeitado
               vr_index_craprej2:= LPad(rw_crapsld.nrdconta,10,'0')||LPad(vr_contador,10,'0');
               vr_tab_craprej2(vr_index_craprej2).nrdconta:= rw_crapsld.nrdconta;
               vr_tab_craprej2(vr_index_craprej2).vllanmto:= (rw_crapsld.vlipmfap * -1);
               vr_tab_craprej2(vr_index_craprej2).cdpesqbb:= vr_cdprogra;
               vr_tab_craprej2(vr_index_craprej2).cdcooper:= pr_cdcooper;

             END IF;

             --Acumular total base ipmf
             vr_tot_vlbasipm:= Nvl(vr_tot_vlbasipm,0) + Nvl(rw_crapsld.vlbasipm,0);
             --Acumular total ipmf apurado
             vr_tot_vlipmfap:= Nvl(vr_tot_vlipmfap,0) + Nvl(rw_crapsld.vlipmfap,0);
             --Atualizar tabela saldo diario
             vr_index_crapsld:= vr_tab_crapsld.Count+1;
             vr_tab_crapsld(vr_index_crapsld).vlipmfap:= 0;
             vr_tab_crapsld(vr_index_crapsld).vlbasipm:= 0;
             vr_tab_crapsld(vr_index_crapsld).nrdconta:= rw_crapsld.nrdconta;
             vr_tab_crapsld(vr_index_crapsld).cdcooper:= pr_cdcooper;

           END IF;
         END LOOP; --rw_crapsld

         --Atualizar tabela de periodos
         BEGIN
           UPDATE crapper SET crapper.vlrbscps = crapper.vlrbscps + vr_tot_vlbasipm
                             ,crapper.vlrcpcps = crapper.vlrcpcps + vr_tot_vlipmfap
                             ,crapper.infimper = 2
           WHERE crapper.rowid = rw_crapper.ROWID;
         EXCEPTION
           WHEN OTHERS THEN
             vr_des_erro:= 'Erro ao atualizar tabela crapper. '||SQLERRM;
             RAISE vr_exc_saida;
         END;
       END LOOP; --rw_crapper

       --Inserir dados da crapipm na tabela em um unico momento
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crapipm SAVE EXCEPTIONS
           INSERT INTO crapipm (dtdebito
                               ,indebito
                               ,nrdconta
                               ,vlbasipm
                               ,vldoipmf
                               ,cdcooper)
           VALUES              (vr_tab_crapipm(idx).dtdebito
                               ,vr_tab_crapipm(idx).indebito
                               ,vr_tab_crapipm(idx).nrdconta
                               ,vr_tab_crapipm(idx).vlbasipm
                               ,vr_tab_crapipm(idx).vldoipmf
                               ,vr_tab_crapipm(idx).cdcooper);
       EXCEPTION
         WHEN OTHERS THEN
         -- Gerar erro
          vr_des_erro := 'Erro ao inserir na tabela crapipm. '||
                         SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_saida;
       END;

       --Inserir dados da craprej na tabela em um unico momento
       BEGIN
         FORALL idx IN INDICES OF vr_tab_craprej SAVE EXCEPTIONS
           INSERT INTO craprej (vllanmto
                               ,cdpesqbb
                               ,nrdconta
                               ,cdcooper)
           VALUES              (vr_tab_craprej(idx).vllanmto
                               ,vr_tab_craprej(idx).cdpesqbb
                               ,vr_tab_craprej(idx).nrdconta
                               ,vr_tab_craprej(idx).cdcooper);
       EXCEPTION
         WHEN OTHERS THEN
         -- Gerar erro
          vr_des_erro := 'Erro ao inserir na tabela craprej. '||
                         SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_saida;
       END;

       --Atualizar dados da crapsld em um unico momento
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crapsld SAVE EXCEPTIONS
           UPDATE crapsld SET vlipmfpg = NVL(vr_tab_crapsld(idx).vlipmfpg,0)
                             ,vlipmfap = NVL(vr_tab_crapsld(idx).vlipmfap,0)
                             ,vlbasipm = NVL(vr_tab_crapsld(idx).vlbasipm,0)
           WHERE  crapsld.nrdconta = vr_tab_crapsld(idx).nrdconta
           AND    crapsld.cdcooper = vr_tab_crapsld(idx).cdcooper;
       EXCEPTION
         WHEN OTHERS THEN
         -- Gerar erro
          vr_des_erro := 'Erro ao inserir na tabela craprej. '||
                         SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
          RAISE vr_exc_saida;
       END;

       --Se existir rejeicao
       IF vr_tab_craprej2.Count > 0 THEN
         --Executar procedure geração relatorio chamado
         --ESTORNOS DE DEBITOS DA CPMF A LANCAR (crrl054)
         pc_imprime_crrl054 (pr_des_erro => vr_des_erro);
         --Se retornou erro
	       IF vr_des_erro IS NOT NULL THEN
	         --Levantar Exceção
		       RAISE vr_exc_saida;
	       END IF;
       END IF;

       --Zerar tabelas de memoria auxiliar
       pc_limpa_tabela;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       --Salvar informacoes no banco de dados
       COMMIT;

       --Retonar flag SIM para final solicitacao
       pr_infimsol:= 1;

     EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_des_erro );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;
      WHEN vr_exc_saida THEN
         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_des_erro IS NULL THEN
          -- Buscar a descrição
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_des_erro;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

         --Zerar tabela de memoria auxiliar
         pc_limpa_tabela;

        -- Efetuar rollback
        ROLLBACK;
     END;
   END pc_crps064;
/
