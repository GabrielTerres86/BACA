CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS675 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada	
  BEGIN
				
/* ..........................................................................

       Programa: pc_crps675
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Março/2014.                     Ultima atualizacao: 02/06/2015

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 40, Ordem 2.
                   Gerar arquivo de retorno de Débito em conta das faturas (Bancoob/CABAL).

       Alteracoes: 13/08/2014 - Ajuste para converter arquivo para DOS ao final da criação
                                (Odirlei/AMcom)
                                
                   22/08/2014 - Alteração da busca do diretorio do bancoob e remover
                                arquivo TMP(Odirlei/AMcom)   
                                
                   15/09/2014 - Retirar 1 fixo e utilizar o valor da tabela crapscb (Renato/Supero)          

                   07/10/2014 - Adicionar o indice do arquivo, antes de montar e enviar (Renato/Supero)
                   
                   09/01/2015 - Alterado para gerar arquivo TMP fora da pasta envia,
                                e no final mover para a envia SD241651 (Odirlei-AMcom)
                             
                   16/01/2015 - Ajuste para que não seja enviado arquivo quando nenhum registro for 
                                encontrado pelo programa. ( Renato - Supero )          
                                
                   02/06/2015 - #292314 Retirada do filtro ass.dtdemiss is null do cursor cr_craplcm (Carlos)
                   
                   30/07/2015 - Retirado cursor da lcm e incluida o cr_paga_fatura para o loop
                                principal do programa (Tiago/Rodrigo).
    ............................................................................ */

    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS675';       --> Código do programa
      vr_dsdireto   VARCHAR2(2000);                                    --> Caminho para gerar
			vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_nmrquivo   VARCHAR2(2000);                                    --> Nome do arquivo
      vr_dsheader   VARCHAR2(2000);                                    --> HEADER  do arquivo
      vr_dsdetarq   VARCHAR2(2000)  := 0;                              --> DETALHE do arquivo
      vr_dstraile   VARCHAR2(2000);                                    --> TRAILER do arquivo
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX
      vr_vlrtotdb   craplcm.vllanmto%TYPE := 0;                        --> Somatório do Valor de Débito Automático
      vr_contador   PLS_INTEGER := 0;                                  --> Contador de linhas de Registro
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      vr_nrseqarq   crapscb.nrseqarq%TYPE;
      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000); 
      
      -- Comando completo
      vr_dscomando VARCHAR2(4000); 
      -- Saida da OS Command
      vr_typ_saida VARCHAR2(4000);
      
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca listagem das cooperativas
      CURSOR cr_crapcol IS
       SELECT cop.cdcooper
       FROM crapcop cop
      WHERE cop.cdcooper <> 3;

      -- Cursor genérico de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

      -- Cursor genérico de calendário da Cooperativa em operação
      rw_crapdatc btch0001.cr_crapdat%ROWTYPE;
			
      --Cursor que retorna um resumo com aas somas dos lancamentos por fatura
      CURSOR cr_paga_fatura(pr_cdcooper    IN crapcop.cdcooper%TYPE
                           ,pr_dtpagamento IN DATE)  IS
        SELECT fat.cdcooper, fat.nrdconta,
               ass.nrcpfcgc, fat.dtvencimento,
               fat.nrcontrato, fat.nrconta_cartao,
               fat.vlpagodia
          FROM tbcrd_fatura fat, crapass ass 
         WHERE fat.cdcooper = pr_cdcooper 
           AND fat.dtref_pagodia = pr_dtpagamento
           AND fat.vlpagodia > 0
           AND fat.cdcooper = ass.cdcooper 
           AND fat.nrdconta = ass.nrdconta
        ORDER BY fat.nrdconta;                           
        
           /*
        SELECT fat.cdcooper, fat.nrdconta, ass.nrcpfcgc,
               fat.dtvencimento, fat.nrcontrato, 
               fat.nrconta_cartao, SUM(pag.vlpagamento) vlpagamento
          FROM tbcrd_fatura fat, 
               tbcrd_pagamento_fatura pag,
               crapass ass
         WHERE fat.idfatura = pag.idfatura 
           AND fat.cdcooper = ass.cdcooper 
           AND fat.nrdconta = ass.nrdconta
           AND fat.cdcooper = pr_cdcooper        
           AND pag.dtpagamento = pr_dtpagamento
           AND pag.vlpagamento > 0
         GROUP BY fat.cdcooper, fat.nrdconta , 
                  ass.nrcpfcgc, fat.dtvencimento, 
                  fat.nrcontrato, fat.nrconta_cartao   
         ORDER BY fat.nrdconta;      
      */
      
      -- Informações arquivo bancoob
      CURSOR cr_crapscb IS 
        SELECT crapscb.dsdirarq
             , crapscb.nrseqarq
          FROM crapscb
         WHERE crapscb.tparquiv = 8; -- Arquivo DAUR
      rw_crapscb cr_crapscb%ROWTYPE;
      
    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
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
     
      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      IF cr_crapscb%NOTFOUND  THEN
        vr_dscritic := 'Registro crapscb não encontrado!';      
        CLOSE cr_crapscb;  
         --levantar excecao
        RAISE vr_exc_saida; 
      END IF;  
      CLOSE cr_crapscb;  
        
      -- Defeni o sequencial do arquivo, adicionando 1 ao ultimo enviado
      vr_nrseqarq := NVL(rw_crapscb.nrseqarq,0) + 1;
      
      -- buscar caminho de arquivos do Bancoob/CABAL
      vr_dsdireto := rw_crapscb.dsdirarq;
      vr_direto_connect := vr_dsdireto;

      -- monta nome do arquivo
      vr_nmrquivo := 'DAUR756.' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '.' || 
			                             TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMMDD')  || '.CCB';			

      -- criar handle de arquivo de Saldo Disponível dos Associados
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect  --> Diretorio do arquivo
                              ,pr_nmarquiv => 'TMP_'||vr_nmrquivo        --> Nome do arquivo
                              ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                              ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);      --> erro
      -- em caso de crítica
      IF vr_dscritic IS NOT NULL THEN
        -- levantar excecao
        RAISE vr_exc_saida;
      END IF;
			
			-- Contador de Registro
			vr_contador := 1;

      -- monta HEADER do arquivo
      vr_dsheader := 'DAUR'                                       ||
                     '0'                                          ||
										 '756'                                        ||
                     TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0'))     ||
                     TO_CHAR(rw_crapdat.dtmvtolt,'DDMMYYYY')      ||										 
                     lpad(vr_nrseqarq,6,'0')                      || -- Renato (Supero) - 07/10/2014 - Utilizar o próximo sequencial
										 lpad(nvl(vr_contador,0),6,'0')               ;
										 
      -- escrever HEADER do arquivo
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsheader);

      -- Executa LOOP para cada Cooperativa
      FOR rw_crapcol IN cr_crapcol LOOP	
				
        -- Leitura do calendario da cooperativa do LOOP
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcol.cdcooper);
        FETCH btch0001.cr_crapdat INTO rw_crapdatc;
        
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

        FOR rw_paga_fatura IN cr_paga_fatura(pr_cdcooper    => rw_crapcol.cdcooper,
					                                   pr_dtpagamento => rw_crapdat.dtmvtolt) LOOP

          -- Contador de Registro
			    vr_contador := vr_contador + 1;
          
					-- monta registro de DETALHE
					vr_dsdetarq := ('DAUR'                                          /* Retorno                       */         ||
					                '1'                                             /* Pgto Automático	             */         ||
													lpad(rw_paga_fatura.nrconta_cartao,13,'0')      /* Conta CABAL                   */         ||
													lpad(nvl(rw_paga_fatura.nrcpfcgc,0),11,'0')     /* CPF                           */         ||
													'0000000'                                       /* Filler                        */         ||
													lpad(rw_paga_fatura.nrdconta,12,'0')            /* Conta/DV                      */         ||
													'000000000'                                     /* Filler                        */         ||
													'000000000000'                                  /* Filler                        */         ||
													lpad(nvl((rw_paga_fatura.vlpagodia * 100),0),12,'0') /* Valor do Débito               */    ||
													TO_CHAR(rw_paga_fatura.dtvencimento,'DDMMYYYY') /* Data Venc. Fatura             */         ||
                          lpad(vr_contador,6,'0')                         /* Sequencial do Registro        */         );
																																				
          -- grava registro de DETALHE no arquivo
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdetarq);
					
					-- Somatório do valor de Débitos Automáticos
					vr_vlrtotdb := vr_vlrtotdb + rw_paga_fatura.vlpagodia;
          
          
        END LOOP;        
        
      END LOOP;
			
			-- Contador de Registro
      vr_contador := vr_contador + 1;

      -- monta TRAILER do arquivo
      vr_dstraile := ('DAUR'                                    /* Retorno        */      ||
                      '9'                                       /* Trailer        */      ||
                      lpad('0',16,'0')                          /* Filler         */      ||
                      lpad(nvl((vr_vlrtotdb * 100),0),16,'0')   /* Soma Vlr. Deb. */      ||
                      lpad(nvl(vr_contador,0),6,'0')            /* Seq. Registro  */      );

      -- escrever TRAILER do arquivo
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dstraile);

      -- fechar o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> handle do arquivo aberto;			
      
      /* Delete arquivo se contador de linhas possuir apenas 2 registros (header e trailer). */
      IF  vr_contador <= 2 THEN
								
				vr_comando:= 'rm ' || vr_direto_connect || '/TMP_'||vr_nmrquivo || ' 2> /dev/null';			
				--Executar o comando no unix
				GENE0001.pc_OScommand(pr_typ_comando => 'S'
														 ,pr_des_comando => vr_comando
														 ,pr_typ_saida   => vr_typ_saida
														 ,pr_des_saida   => vr_dscritic);
													 
				IF vr_typ_saida = 'ERR' THEN
					RAISE vr_exc_saida;
				END IF;
				
				vr_dscritic := 'Nenhum movimento encontrado para a data.';
				RAISE vr_exc_fimprg;				
			END IF;
      
      -- Executa comando UNIX para converter arq para Dos
      vr_dscomando := 'ux2dos ' || vr_direto_connect|| '/TMP_'||vr_nmrquivo||' > ' 
                                || vr_direto_connect|| '/envia/' ||vr_nmrquivo || ' 2>/dev/null';
                                    
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                               
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Remover arquivo tmp
      vr_dscomando := 'rm ' || vr_direto_connect|| '/TMP_'||vr_nmrquivo;
                                  
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                             
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;
      
			-- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
			BEGIN
				UPDATE crapscb
				   SET nrseqarq = vr_nrseqarq
					   , dtultint = SYSDATE
				 WHERE crapscb.tparquiv = 8; -- Arquivo DAUR - Debito em cota das faturas

			-- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
			EXCEPTION
				WHEN OTHERS THEN
					-- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
					vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
					RAISE vr_exc_saida;
			END;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      COMMIT;

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
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
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
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;

    END;
		
END PC_CRPS675;
/

