CREATE OR REPLACE PROCEDURE CECRED.pc_crps266(pr_cdcooper  IN craptab.cdcooper%TYPE,
                                       pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                       pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                       pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
/* ............................................................................

   Programa: PC_CRPS266 (Antigo Fontes/crps266.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/99                        Ultima alteracao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Emitir listagem dos lancamentos de transferencia de mesma 
               titularidade sem cobranca de CPMF.
               Atende a solicitacao 02.
               Gera relatorio 215.
               Exclusividade 2 (Paralelo).

   Alteracao : 19/07/99 - Alterado para chamar a rotina de impressao (Edson).

               14/08/2000 - Alterado para na leitura do historico 303, testar
                            tambem o valor do lancamento (Edson).

               28/10/2004 - Tratar conta integracao (Margarete).

               08/06/2005 - Incluidos Tipos de Conta 17 e 18(Mirtes).

               05/01/2006 - Cancelar impressao para Coope 1 (Magui).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               25/05/2007 - Retirado vinculacao imprim.p ao codigo da
                            cooperativa(Guilherme).
               
               09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               18/02/2015 - Conversão Progress >> Oracle PL/SQL (Vanessa).

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                      crapass, crapttl, crapjur (Adriano - P339).

			         24/04/2017 - Substituida validacao "cdtipcta in (1,2..)" pela categoria
                            da conta. PRJ366 (Lombardi).


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
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS266';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
        
      vr_flgsitua  VARCHAR2(10);
      vr_dstipcta  VARCHAR2(200);
      vr_cdcatego  crapass.cdtipcta%TYPE;
      vr_nrcpfcgc  crapass.nrcpfcgc%TYPE;
      vr_nrcpfstl  crapttl.nrcpfcgc%TYPE;
      vr_nmtitula  VARCHAR2(200);
      
      vr_dstipcta2 VARCHAR2(200);
      vr_nmtitula2 VARCHAR2(200);
      vr_cdcatego2 crapass.cdtipcta%TYPE;
      vr_nrcpfcgc2 crapass.nrcpfcgc%TYPE;
      vr_nrcpfstl2 crapttl.nrcpfcgc%TYPE;
      vr_nrdconta2 craplcm.nrdconta%TYPE;
      
      
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
   
      --Cursor que busca os lancamentos com historico passado pelo parametro
      CURSOR cr_craplcm(pr_cdcooper IN craptab.cdcooper%TYPE,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                        pr_cdhistor IN craplcm.cdhistor%TYPE) IS
         SELECT /*index (lcm CRAPLCM##CRAPLCM4)*/ 
                lcm.cdcooper,
                ass.cdagenci,
                lcm.dtmvtolt,
                lcm.nrdconta,
                lcm.nrdocmto,
                lcm.vllanmto,
                ass.nmprimtl,
                ass.cdcatego,
                ass.nrcpfcgc,
				ass.inpessoa,
                tip.dstipcta 
           FROM craplcm lcm
               ,crapass ass
               ,craptip tip
          WHERE  lcm.cdcooper = ass.cdcooper  AND
                 lcm.nrdconta = ass.nrdconta  AND
                 tip.cdcooper = ass.cdcooper  AND
                 tip.cdtipcta = ass.cdtipcta  AND                 
                 lcm.cdcooper = pr_cdcooper   AND
                 lcm.dtmvtolt = pr_dtmvtolt   AND 
                 lcm.cdhistor = pr_cdhistor
          ORDER BY lcm.nrdconta ASC;
       rw_craplcm cr_craplcm%ROWTYPE;
       
      --Cursor que busca os lancamentos com historico 303
      CURSOR cr_craplcm2(pr_cdcooper IN craptab.cdcooper%TYPE,
                         pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                         pr_nrdocmto IN craplcm.nrdocmto%TYPE,
                         pr_vllanmto IN craplcm.vllanmto%TYPE) IS
         SELECT /*index (lcm CRAPLCM##CRAPLCM4)*/ 
                lcm.cdcooper,
                lcm.nrdconta,
                ass.nmprimtl,
                ass.cdcatego,
                ass.nrcpfcgc,
				ass.inpessoa,
                tip.dstipcta 
           FROM craplcm lcm
               ,crapass ass
               ,craptip tip
          WHERE  lcm.cdcooper = ass.cdcooper  AND
                 lcm.nrdconta = ass.nrdconta  AND
                 tip.cdcooper = ass.cdcooper  AND
                 tip.cdtipcta = ass.cdtipcta  AND       
                 lcm.cdcooper = pr_cdcooper   AND
                 lcm.dtmvtolt = pr_dtmvtolt   AND 
                 lcm.cdhistor = 303           AND 
                 lcm.nrdocmto = pr_nrdocmto   AND 
                 lcm.vllanmto = pr_vllanmto;
       rw_craplcm2 cr_craplcm2%ROWTYPE;
            
	   CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
	                    ,pr_nrdconta crapttl.nrdconta%TYPE)IS
	   SELECT ttl.nrcpfcgc
	     FROM crapttl ttl
		WHERE ttl.cdcooper = pr_cdcooper 
		  AND ttl.nrdconta = pr_nrdconta
		  AND ttl.idseqttl = 2;
	   rw_crapttl cr_crapttl%ROWTYPE;
            
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
       
       -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      
      -- Adiciona a linha ao XML 
      gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                             ,pr_texto_completo => vr_des_xml
                             ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?>'||chr(10)
                             ||'<crrl215  dtmvtolt="' || TO_CHAR(rw_crapdat.dtmvtolt,'dd/mm/yyyy')||'">'
                             ||'<tipocaixa>'||chr(10));

        -- Tipo Caixa
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_cdhistor => 104) LOOP
                
            vr_dstipcta := rw_craplcm.dstipcta;
            vr_nmtitula := rw_craplcm.nmprimtl;
            vr_cdcatego := rw_craplcm.cdcatego; 
            vr_nrcpfcgc := rw_craplcm.nrcpfcgc;
            vr_nrcpfstl := 0;

			IF rw_craplcm.inpessoa = 1 THEN

			  OPEN cr_crapttl(pr_cdcooper => rw_craplcm.cdcooper
			                 ,pr_nrdconta => rw_craplcm.nrdconta);

			  FETCH cr_crapttl INTO rw_crapttl;

			  IF cr_crapttl%FOUND THEN

			    vr_nrcpfstl := rw_crapttl.nrcpfcgc;

			  END IF;

			  CLOSE cr_crapttl;

			END IF;
                
            FOR rw_craplcm2 IN cr_craplcm2(pr_cdcooper => rw_crapcop.cdcooper,
                                           pr_dtmvtolt => rw_craplcm.dtmvtolt,
                                           pr_nrdocmto => rw_craplcm.nrdocmto,
                                           pr_vllanmto => rw_craplcm.vllanmto) LOOP
                  
                vr_flgsitua := 'CORRETO';
                vr_dstipcta2 := rw_craplcm2.dstipcta;
                vr_nmtitula2 := rw_craplcm2.nmprimtl;
                vr_cdcatego2 := rw_craplcm2.cdcatego;
                vr_nrcpfcgc2 := rw_craplcm2.nrcpfcgc;
                vr_nrcpfstl2 := 0;
                vr_nrdconta2 := rw_craplcm2.nrdconta;
                      
				IF rw_craplcm2.inpessoa = 1 THEN

				  OPEN cr_crapttl(pr_cdcooper => rw_craplcm2.cdcooper
								 ,pr_nrdconta => rw_craplcm2.nrdconta);

				  FETCH cr_crapttl INTO rw_crapttl;

				  IF cr_crapttl%FOUND THEN

					vr_nrcpfstl2 := rw_crapttl.nrcpfcgc;

				  END IF;

				  CLOSE cr_crapttl;

				END IF;
                      
                IF(vr_cdcatego = 1 AND vr_cdcatego2 IN(2,3)) THEN
                   vr_flgsitua := 'ERRADO'; -- individual para conjunta 
                ELSIF(vr_cdcatego = 1 AND vr_cdcatego2 = 1) THEN
                        
                   IF vr_nrcpfcgc <> vr_nrcpfcgc2 THEN
                      vr_flgsitua := 'ERRADO'; -- individual para individual diferente
                   END IF;
                ELSIF vr_cdcatego  IN(2,3) THEN
                   IF vr_cdcatego2 = 1 THEN
                            
                      IF(vr_nrcpfcgc2 <> vr_nrcpfcgc AND vr_nrcpfcgc2 <> vr_nrcpfstl) THEN
                         vr_flgsitua := 'ERRADO'; /* conjunta para individual */
                      END IF;
                   ELSE
                         
                      IF((vr_nrcpfcgc <> vr_nrcpfcgc2 AND vr_nrcpfcgc <> vr_nrcpfstl2) OR
                         (vr_nrcpfstl <> vr_nrcpfcgc2 AND vr_nrcpfstl <> vr_nrcpfstl2))THEN
                          vr_flgsitua := 'ERRADO'; 
                      END IF;                            
                   END IF; 
                END IF;                      
                  
            END LOOP;
                    
            -- Adiciona a linha ao XML 
            gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                                    ,pr_texto_completo => vr_des_xml
                                    ,pr_texto_novo     =>'<caixa>'
                                    ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_craplcm.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                                    ||chr(10)||'<nmprimtl>'||TRIM(vr_nmtitula) ||'</nmprimtl>'
                                    ||chr(10)||'<dstipcta>'||TRIM(vr_dstipcta) ||'</dstipcta>'
                                    ||chr(10)||'<nrdconta2>'||TRIM(gene0002.fn_mask(vr_nrdconta2,'zzzz.zzz.z'))||'</nrdconta2>'
                                    ||chr(10)||'<nmprimtl2>'||TRIM(vr_nmtitula)||'</nmprimtl2>'
                                    ||chr(10)||'<dstipcta2>'||TRIM(vr_dstipcta2) ||'</dstipcta2>'
                                    ||chr(10)||'<flgsitua>'||TRIM(vr_flgsitua) ||'</flgsitua>'                         
                                    ||chr(10)||'</caixa>');  
          
        END LOOP;
        
     -- Adiciona a linha ao XML finalizando caixa e iniciando doc
     gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                            ,pr_texto_completo => vr_des_xml
                            ,pr_texto_novo     =>'</tipocaixa>'||chr(10)
                            ||'<tipodoc>'||chr(10));
        -- Tipo Doc
        FOR rw_craplcm IN cr_craplcm(pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                     pr_cdhistor => 103) LOOP
                
              -- Adiciona a linha ao XML 
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                                     ,pr_texto_completo => vr_des_xml
                                     ,pr_texto_novo     =>'<doc>'
                                     ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_craplcm.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                                     ||chr(10)||'<nmprimtl>'||TRIM(rw_craplcm.nmprimtl) ||'</nmprimtl>'
                                     ||chr(10)||'<dstipcta>'||TRIM(rw_craplcm.dstipcta ) ||'</dstipcta>'
                                     ||chr(10)||'<cdagenci>'||TRIM(rw_craplcm.cdagenci)||'</cdagenci>'                                                       
                                     ||chr(10)||'</doc>');
                                  
                                     
        END LOOP;
         
       -- Adiciona a linha ao XML 
       gene0002.pc_escreve_xml(pr_xml         => vr_xml_clobxml 
                           ,pr_texto_completo => vr_des_xml
                           ,pr_texto_novo     =>'</tipodoc>'||chr(10)||'</crrl215>'
                           ,pr_fecha_xml      => TRUE);
      
      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
         vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
         RAISE vr_exc_saida;
      END IF;
      
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => 'rl'); 
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
      
      

      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper                  --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl215'                           --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl215.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdireto||'/crrl215.lst'         --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 234 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '215'                                --> Código fixo para o relatório (nao busca pelo sqcabrel)
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
END pc_crps266;
/

