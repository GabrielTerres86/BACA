CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS659
                                       (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* ...............................................................................

   Programa: PC_CRPS659                       Antigo: Fontes/crps659.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Douglas
   Data    : Outubro/2013.                  Ultima atualizacao: 11/01/2016

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Limpeza e finalizacao do processo diario
               Roda na ultima cadeia exclusiva do processo diario
               Solicitacao: 64 - Ordem de Execucao: 1

   Alteracoes:
              06/01/2014 - Conversão Progress >> Oracle PL/SQL ( Renato - Supero)
              
              02/06/2014 - Alteracao no envio de email para os casos de convenios
                           com debito automatico; enviar um email por convenio,
                           com intervalo de ausencia de arquivos de 20 ou mais dias.
                           Verificar o descrito acima sempre na quarta-feira, rodando
                           na Cecred. (Chamado 139154) - (Fabricio)
													 
				      05/06/2014 - Correção para zerar sequencial do campo crapmat.qtassmes 
							             mensalmente (SD. 158046 e 164325) - (Lucas Lunelli)
                     
              11/07/2014 - Correção para zerar as sequenciais dos campos crapmat.qtdemmes (Desligados) 
							             e crapmat.qtadesmes(Readmitidos) mensalmente (SD. 174388) - (Vanessa Klein)
                           
              23/07/2015 - Reinicialização dos campos de baixa de PJ e PF 
                          (Projeto 186 - Separação PF/PJ - Marcos - Supero)
                    
              04/01/2016 - Ajuste na leitura da tabela crapsqu para utilizar UPPER nos campos VARCHAR
                           pois será incluido o UPPER no indice desta tabela - SD 375854
                           (Adriano).       
                           
              11/01/2016 - Ajuste na leitura da tabela crapsqu para utilizar UPPER nos campos VARCHAR
                           pois será incluido o UPPER no indice desta tabela - SD 375854
                           (Adriano).  
                                             
  ................................................................................*/

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Buscar todos as Contra-Ordens ativas
  CURSOR cr_crapcor(pr_dtmvtolt DATE) IS
    SELECT to_number(substr(crapcor.nrcheque,1,(LENGTH(crapcor.nrcheque)-1))) nrcheque
         , crapcor.cdbanchq
         , crapcor.cdagechq
         , crapcor.nrctachq
         , crapcor.rowid  idregist
      FROM crapcor
     WHERE crapcor.cdcooper = pr_cdcooper
       AND crapcor.dtvalcor = pr_dtmvtolt
       AND crapcor.flgativo = 1;

  -- Busca os registros de folhas de cheque emitidas para o cooperado
  CURSOR cr_crapfdc(pr_cdbanchq    crapfdc.cdbanchq%TYPE
                   ,pr_cdagechq    crapfdc.cdagechq%TYPE
                   ,pr_nrctachq    crapfdc.nrctachq%TYPE
                   ,pr_nrcheque    crapfdc.nrcheque%TYPE) IS
    SELECT crapfdc.rowid      idregist
         , crapfdc.incheque
      FROM crapfdc
     WHERE crapfdc.cdcooper = pr_cdcooper
       AND crapfdc.cdbanchq = pr_cdbanchq
       AND crapfdc.cdagechq = pr_cdagechq
       AND crapfdc.nrctachq = pr_nrctachq
       AND crapfdc.nrcheque = pr_nrcheque;

  -- Buscar o registro de execução da CRPS377
  CURSOR cr_crapprg(pr_cdprogra crapprg.cdprogra%TYPE) IS
    SELECT crapprg.inctrprg
      FROM crapprg
     WHERE crapprg.cdcooper = pr_cdcooper
       AND crapprg.cdprogra = pr_cdprogra
       AND crapprg.nmsistem = 'CRED';

  -- Buscar por feriado conforme data do parametro
  CURSOR cr_crapfer(pr_dtmvtaux DATE) IS
    SELECT tpferiad
      FROM crapfer
     WHERE crapfer.cdcooper = pr_cdcooper
       AND crapfer.dtferiad = pr_dtmvtaux;

  -- Buscar todas as empresas para a cooperativa
  CURSOR cr_crapemp IS
    SELECT tpdebcot
         , tpdebemp
         , tpdebppr
         , tpdebseg
         , cdempres
         , ROWID idregist
      FROM crapemp
     WHERE crapemp.cdcooper = pr_cdcooper;

  -- Buscar as datas de controles para geracao da DIMOF(Declaracao de Informacoes sobre Movimentacao Financeira)
  CURSOR cr_crapmof(pr_ultdiame DATE) IS
    SELECT dtiniper
         , dtfimper
         , flgenvio
      FROM crapmof
     WHERE crapmof.cdcooper = pr_cdcooper
       AND crapmof.dtenvpbc = pr_ultdiame;

  -- Buscar informação da tabela CRAPTAB
  CURSOR cr_craptab(pr_nmsistem   craptab.nmsistem%TYPE
                   ,pr_tptabela   craptab.tptabela%TYPE
                   ,pr_cdempres   craptab.cdempres%TYPE
                   ,pr_cdacesso   craptab.cdacesso%TYPE
                   ,pr_tpregist   craptab.tpregist%TYPE) IS
     SELECT craptab.dstextab
       FROM craptab
      WHERE craptab.cdcooper = pr_cdcooper
        AND craptab.nmsistem = pr_nmsistem
        AND craptab.tptabela = pr_tptabela
        AND craptab.cdempres = pr_cdempres
        AND craptab.cdacesso = pr_cdacesso
        AND craptab.tpregist = pr_tpregist;
      
  CURSOR cr_gncontr IS
    SELECT gnconve.cdconven, gnconve.nmempres, MAX(gncontr.dtmvtolt) AS dtmvtolt
      FROM gnconve, gncontr
    WHERE gnconve.cdcooper = gncontr.cdcooper
      AND gnconve.cdconven = gncontr.cdconven
      AND gncontr.tpdcontr = 3
      AND gnconve.flgativo = 1
      AND gnconve.cdhisdeb > 0
    GROUP BY gnconve.cdconven, gnconve.nmempres
    ORDER BY gnconve.cdconven;
		
	-- Busca da sequencia atual
    CURSOR cr_crapsqu(pr_nmtabela   crapsqu.nmtabela%TYPE
		                 ,pr_nmdcampo   crapsqu.nmdcampo%TYPE
										 ,pr_dsdchave   crapsqu.dsdchave%TYPE) IS
      SELECT squ.rowid						 						 
        FROM crapsqu squ
       WHERE UPPER(squ.nmtabela) = UPPER(pr_nmtabela)
         AND UPPER(squ.nmdcampo) = UPPER(pr_nmdcampo)
         AND upper(squ.dsdchave) = UPPER(pr_dsdchave)
         FOR UPDATE;
    rw_crapsqu cr_crapsqu%ROWTYPE;
					
  ------------------------------- REGISTROS -------------------------------
  rw_crapcop     cr_crapcop%ROWTYPE;
  rw_crapfdc     cr_crapfdc%ROWTYPE;
  rw_crapfer     cr_crapfer%ROWTYPE;
  rw_crapmof     cr_crapmof%ROWTYPE;
  rw_gncontr     cr_gncontr%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS659';
  -- Indicador de controle do programa
  vr_inctrprg     crapprg.inctrprg%TYPE;
  -- Data de movimento e mês de referencia
  vr_dtmvtolt     DATE;
  vr_dtmvtopr     DATE;
  vr_ultdiame     DATE;
  -- Endereços de e-mail
  vr_dsdestin     VARCHAR2(500);
  vr_conteudo     VARCHAR2(1000);
  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida    EXCEPTION;
  vr_cdcritic     PLS_INTEGER;
  vr_dscritic     VARCHAR2(4000);

  ---------------------------- ROTINAS INTERNAS ---------------------------
  -- Rotina para gerar taxas as de RDCA
  PROCEDURE pc_gera_taxa_projetada(pr_dtmvtolt  IN DATE
                                  ,pr_dtmvtopr  IN DATE) IS

    -- Cursores
    -- Buscar informações da tabela genérica
    CURSOR cr_craptab IS
      SELECT craptab.tpregist
           , craptab.dstextab
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'CONFIG'
         AND craptab.cdacesso = 'TXADIAPLIC';

    -- Buscar taxas de RDCA
    CURSOR cr_craptrd(pr_prxdttrd craptrd.dtiniper%TYPE
                     ,pr_tptaxrda craptrd.tptaxrda%TYPE
                     ,pr_vlfaixas craptrd.vlfaixas%TYPE) IS
      SELECT 1
        FROM craptrd
       WHERE craptrd.cdcooper = pr_cdcooper
         AND craptrd.dtiniper = pr_prxdttrd
         AND craptrd.tptaxrda = pr_tptaxrda
         AND craptrd.incarenc = 0
         AND craptrd.vlfaixas = pr_vlfaixas;

    -- Buscar a ultima taxa de RDCA, conforme parametros
    CURSOR cr_craptrd_last(pr_tptaxrda craptrd.tptaxrda%TYPE
                          ,pr_vlfaixas craptrd.vlfaixas%TYPE) IS
      SELECT txofidia
           , vltrapli
        FROM craptrd
       WHERE craptrd.cdcooper  = pr_cdcooper
         AND craptrd.tptaxrda  = pr_tptaxrda
         AND craptrd.incarenc  = 0
         AND craptrd.vlfaixas  = pr_vlfaixas
         AND craptrd.txofidia <> 0
       ORDER BY craptrd.progress_recid DESC;

    -- Registro
    TYPE rc_taxas IS RECORD (tptaxrda    NUMBER
                            ,txadical    NUMBER
                            ,vlfaixas    NUMBER);
    TYPE tb_taxas IS TABLE OF rc_taxas INDEX BY BINARY_INTEGER;

    -- Variáveis
    vr_tbtextab    GENE0002.typ_split := GENE0002.typ_split(); -- Inicializa vazio
    vr_auxtaxas    GENE0002.typ_split := GENE0002.typ_split(); -- Inicializa vazio
    vr_tbtaxas     tb_taxas;

    vr_txprodia    craptrd.txprodia%TYPE := 0;
    vr_txofidia    craptrd.txofidia%TYPE;
    vr_vltrapli    craptrd.vltrapli%TYPE;

    vr_vllidtab    VARCHAR2(100);
    vr_dscritic    VARCHAR2(2000);

    vr_contador    NUMBER := 0;
    vr_inregis     NUMBER;
    vr_qtdiaute    NUMBER;

    vr_dtfimper    DATE   := NULL;
    vr_dtmvtaux    DATE   := NULL;
    vr_prxdttrd    DATE   := pr_dtmvtolt + 1; -- próximo dia

  BEGIN

    -- Busca o cadastro da tabela genérica
    FOR rw_craptab IN cr_craptab LOOP

      -- Quebra a string retornada, por ponto-e-vírgula
      vr_tbtextab := GENE0002.fn_quebra_string(pr_string  => rw_craptab.dstextab
                                              ,pr_delimit => ';');

      -- Se retornar informações no registro
      IF vr_tbtextab.COUNT() > 0 THEN
        -- Percorrer as informações de taxas retornadas
        FOR vr_indtaxas IN vr_tbtextab.first..vr_tbtextab.last LOOP
          -- Guarda a informação
          vr_vllidtab := vr_tbtextab(vr_indtaxas);
          -- Contador de controle de indice do registro
          vr_contador := vr_tbtaxas.COUNT() + 1;

          -- Quebra os valores dentro de um registro de memória
          vr_auxtaxas := GENE0002.fn_quebra_string(pr_string  => vr_vllidtab
                                                  ,pr_delimit => '#');

          -- Tipo da taxa
          vr_tbtaxas(vr_contador).tptaxrda := rw_craptab.tpregist;

          -- Se retornar valores
          IF vr_auxtaxas.count() > 0 THEN
            -- Guardar os valores
            vr_tbtaxas(vr_contador).txadical := vr_auxtaxas(2);
            vr_tbtaxas(vr_contador).vlfaixas := vr_auxtaxas(1);
          ELSE
            -- Atribui zero aos campos
            vr_tbtaxas(vr_contador).txadical := 0;
            vr_tbtaxas(vr_contador).vlfaixas := 0;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    -- Verifica se os parametros foram informados
    IF pr_dtmvtolt IS NOT NULL AND
       pr_dtmvtopr IS NOT NULL THEN

      -- Executar a iteração enquanto a condição não for atendida
      WHILE ( vr_prxdttrd <= (pr_dtmvtopr + 5) ) LOOP

        -- Calcular uma data futura conforme parâmetros
        vr_dtfimper := GENE0005.fn_calc_data(pr_dtmvtolt => vr_prxdttrd
                                            ,pr_qtmesano => 1
                                            ,pr_tpmesano => 'M'
                                            ,pr_des_erro => vr_dscritic);

        -- Se retornar critica
        IF vr_dscritic IS NOT NULL THEN
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log     => 2, -- Erro tratado
                                     pr_des_log          => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog         => vr_cdprogra);
        END IF;

        -- Inicializar
        vr_dtmvtaux := vr_prxdttrd;
        vr_qtdiaute := 0;

        -- Verificar a quantidade de dias úteis
        WHILE ( vr_dtmvtaux < vr_dtfimper ) LOOP

          -- Buscar feriado
          OPEN  cr_crapfer(vr_dtmvtaux);
          FETCH cr_crapfer INTO rw_crapfer;

          -- Se não for final de semana e não for feriado
          IF TO_CHAR(vr_dtmvtaux,'D') NOT IN ('1','7') AND cr_crapfer%NOTFOUND THEN
            vr_qtdiaute := vr_qtdiaute + 1;
          END IF;

          vr_dtmvtaux := vr_dtmvtaux + 1;

          CLOSE cr_crapfer;

        END LOOP; -- while

        -- Percorrer o registro de memória de taxas
        FOR vr_indtaxas IN NVL(vr_tbtaxas.FIRST,0)..NVL(vr_tbtaxas.LAST,-1) LOOP
          -- Inicializa
          vr_inregis := NULL;

          -- buscar RDCA
          OPEN  cr_craptrd(vr_prxdttrd                        -- pr_prxdttrd
                          ,vr_tbtaxas(vr_indtaxas).tptaxrda   -- pr_tptaxrda
                          ,vr_tbtaxas(vr_indtaxas).vlfaixas); -- pr_vlfaixas
          FETCH cr_craptrd INTO vr_inregis;
          CLOSE cr_craptrd;

          -- Se encontrar o registro
          IF NVL(vr_inregis,0) = 1 THEN
            CONTINUE; -- Próxima taxa
          END IF;

          -- Buscar o ultimo registro de RDCA
          OPEN  cr_craptrd_last(vr_tbtaxas(vr_indtaxas).tptaxrda
                               ,vr_tbtaxas(vr_indtaxas).vlfaixas);
          FETCH cr_craptrd_last INTO vr_txofidia
                                   , vr_vltrapli;
          -- Se encontrar registro
          IF cr_craptrd_last%FOUND THEN
            vr_txprodia := vr_txofidia;
            vr_vltrapli := vr_vltrapli;
          ELSE
            vr_txprodia := 0;
            vr_vltrapli := 0;
          END IF;
          CLOSE cr_craptrd_last;

          -- Inserir um novo registro na tabela craptrd
          BEGIN

            INSERT INTO craptrd(cdcooper
                               ,tptaxrda
                               ,dtiniper
                               ,dtfimper
                               ,qtdiaute
                               ,vlfaixas
                               ,incarenc
                               ,incalcul
                               ,txprodia
                               ,vltrapli)
                         VALUES(pr_cdcooper   -- cdcooper
                               ,nvl(vr_tbtaxas(vr_indtaxas).tptaxrda,0) -- tptaxrda
                               ,vr_prxdttrd   -- dtiniper
                               ,vr_dtfimper   -- dtfimper
                               ,nvl(vr_qtdiaute,0)   -- qtdiaute
                               ,nvl(vr_tbtaxas(vr_indtaxas).vlfaixas,0) -- vlfaixas
                               ,0             -- incarenc
                               ,0             -- incalcul
                               ,nvl(vr_txprodia,0)   -- txprodia
                               ,nvl(vr_vltrapli,0)); -- vltrapli

          EXCEPTION
            WHEN OTHERS THEN
              -- Define a mensagem de erro
              vr_dscritic := 'Erro ao inserir CRAPTRD: '||SQLERRM;
              -- Registra Log
              btch0001.pc_gera_log_batch(pr_cdcooper         => pr_cdcooper,
                                         pr_ind_tipo_log     => 2, -- Erro tratado
                                         pr_des_log          => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                         pr_nmarqlog         => vr_cdprogra);
              -- Próxima taxa
              CONTINUE;
          END;

        END LOOP; -- vr_tbtaxas

        -- Incrementa a data
        vr_prxdttrd := vr_prxdttrd + 1;

      END LOOP; -- While
    END IF; -- pr_dtmvtolt e pr_dtmvtopr -> IS NOT NULL

  END pc_gera_taxa_projetada;

BEGIN -- Principal

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra);

  -- Verifica se a cooperativa esta cadastrada
  OPEN  cr_crapcop;
  FETCH cr_crapcop INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  END IF;

  -- Apenas fechar o cursor
  CLOSE cr_crapcop;

  -- Leitura do calendário da cooperativa
  OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO btch0001.rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Guarda a data
    vr_dtmvtolt := btch0001.rw_crapdat.dtmvtolt;
    vr_dtmvtopr := btch0001.rw_crapdat.dtmvtopr;
  END IF;

  -- Fechar o cursor
  CLOSE btch0001.cr_crapdat;

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

  -- Gerar as taxas projetadas de RDCA
  pc_gera_taxa_projetada(vr_dtmvtolt   -- pr_dtmvtolt
                        ,vr_dtmvtopr); -- pr_dtmvtopr

  -- Verifica se é Quarta-Feira e se é cooperativa 3 - Cecred
  IF to_char(vr_dtmvtolt,'D') = '4' AND pr_cdcooper = 3 THEN
    /* Verificar atraso nos arquivos de debito das empresas conveniadas */
    FOR rw_gncontr IN cr_gncontr LOOP

      -- Se encontrar o registro, verifica se o ultimo movimento foi à vinte dias ou mais
      IF cr_gncontr%FOUND AND TRUNC(rw_gncontr.dtmvtolt) <= TRUNC(vr_dtmvtolt - 20) THEN
        -- Monta a mensagem do e-mail
        vr_conteudo :='<b>ATEN'||Chr(38)||'Ccedil;'||Chr(38)||'Atilde;O!</b><br><br>'
                    ||'Voc'||Chr(38)||'ecirc; est'||Chr(38)||'aacute; recebendo este '
                    ||'e-mail para lhe informar que desde o dia <u>'
                    ||to_char(rw_gncontr.dtmvtolt,'DD/MM/YYYY')
                    ||'</u> n'||Chr(38)||'atilde;o recebemos arquivos de d'||Chr(38)||'eacute;bito da '
                    ||'<u>' || rw_gncontr.nmempres || '.</u><br><br>'
                    ||'Este e-mail foi enviado pelo processo batch referente ao dia '
                    ||to_char(vr_dtmvtolt,'DD/MM/YYYY')||'.';

        -- Buscar o parametro com os endereços de e-mail para envio
        vr_dsdestin := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdacesso => 'CRPS659_EMAIL');

        -- Enviar e-mail com o log gerado
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_dsdestin
                                  ,pr_des_assunto     => 'Arquivos de debito - ' || rw_gncontr.nmempres
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);

        -- Verificar se houve erro ao solicitar e-mail
        IF vr_dscritic IS NOT NULL THEN
          -- Não gerar critica
          vr_cdcritic := 0;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
        END IF;
      END IF;
    END LOOP;
  END IF;
	
  /* Remove todas as Contra-Ordens Provisorias ..................... */
  FOR rw_crapcor IN cr_crapcor(vr_dtmvtolt) LOOP
    -- Limpar registro
    rw_crapfdc := NULL;

    -- Busca por folhas de cheques emitidos para o cooperado
    OPEN  cr_crapfdc(rw_crapcor.cdbanchq
                    ,rw_crapcor.cdagechq
                    ,rw_crapcor.nrctachq
                    ,rw_crapcor.nrcheque);
    FETCH cr_crapfdc INTO rw_crapfdc;
    CLOSE cr_crapfdc;

    -- Verificar o indicador do estado do cheque
    IF NVL(rw_crapfdc.incheque,0) IN (1,2) THEN
      BEGIN
        -- Atualizar o indicador do cheque
        UPDATE crapfdc
           SET crapfdc.incheque = 0
         WHERE crapfdc.rowid    = rw_crapfdc.idregist;
      EXCEPTION
        WHEN OTHERS THEN
          -- Definir mensagem de erro
          vr_dscritic := 'Erro ao atualizar CRAPFDC.incheque: '||SQLERRM;
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog     => vr_cdprogra);
          EXIT; -- Sai do Loop
      END;
    END IF;

    BEGIN
      -- Atualizar a situação da contra-ordem para inativa
      UPDATE crapcor
         SET crapcor.flgativo = 0
       WHERE crapcor.rowid    = rw_crapcor.idregist;
    EXCEPTION
      WHEN OTHERS THEN
        -- Definir mensagem de erro
        vr_dscritic := 'Erro ao atualizar CRAPCOR.flgativo: '||SQLERRM;
        -- Registra Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                   pr_nmarqlog     => vr_cdprogra);
        EXIT; -- Sai do Loop
    END;
  END LOOP;
	
  /* FIM Remove todas as Contra-Ordens Provisorias ................. */

  /* Deleta todas as solicitacoes .................................. */
  BEGIN
    DELETE crapsol
     WHERE crapsol.cdcooper = pr_cdcooper
       AND crapsol.dtrefere = vr_dtmvtolt;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao excluir CRAPSOL: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  /* FIM Deleta todas as solicitacoes .............................. */

  /* Elimina capas de lotes de requisicoes ......................... */
  BEGIN
    DELETE craptrq
     WHERE craptrq.cdcooper = pr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao excluir CRAPTRQ: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;
	
  /* FIM Elimina capas de lotes de requisicoes ..................... */

  /* Limpeza do cadastro de admitidos..............................  */
  -- Procedimento mensal
  IF trunc(vr_dtmvtopr,'MM') <> trunc(vr_dtmvtolt,'MM') THEN
    BEGIN
      DELETE crapadm
       WHERE crapadm.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        -- Definir mensagem de erro
        vr_dscritic := 'Erro ao excluir CRAPADM: '||SQLERRM;
        -- Registra Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                   pr_nmarqlog     => vr_cdprogra);
    END;
  END IF;
	
  /* FIM Limpeza do cadastro de admitidos..........................  */

  /*  Limpa registros do BL do sistema caixa on-line ............... */
  BEGIN
    DELETE crapcbl
     WHERE crapcbl.cdcooper = pr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao excluir CRAPCBL: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;
	
  /*  FIM Limpa registros do BL do sistema caixa on-line ........... */

  /* Atualiza campo ref. Verificacao de Pend. COBAN ................ */
  BEGIN
    UPDATE crapage
       SET crapage.vercoban  = 1
     WHERE crapage.cdcooper  = pr_cdcooper
       AND crapage.cdagecbn <> 0;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao atualiar CRAPAGE: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;
	
  /* FIM Atualiza campo ref. Verificacao de Pend. COBAN ............ */

  /*  Verifica se crps377 rodou e limpa as requisicoes Bloquetos B.Brasil ..... */
  -- Buscar o registro de execução da CRPS377
  OPEN  cr_crapprg('CRPS377');
  FETCH cr_crapprg INTO vr_inctrprg;
  -- Se nenhum registro foi encontrado
  IF cr_crapprg%NOTFOUND THEN
    vr_inctrprg := NULL;
  END IF;
  CLOSE cr_crapprg;

  -- Se o programa já está marcado como executado
  IF NVL(vr_inctrprg,0) = 2 THEN
    BEGIN
      DELETE crapreq
        WHERE crapreq.cdcooper = pr_cdcooper
          AND crapreq.insitreq = 2
          AND crapreq.tprequis = 8;
    EXCEPTION
      WHEN OTHERS THEN
        -- Definir mensagem de erro
        vr_dscritic := 'Erro ao excluir CRAPREQ: '||SQLERRM;
        -- Registra Log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratado
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                   pr_nmarqlog     => vr_cdprogra);
    END;
  END IF;
	
  /* FIM Verifica se crps377 rodou e limpa as requisicoes Bloquetos B.Brasil ..... */

  /* Limpeza dos registros com emissao maior que 45 dias */
  BEGIN
    DELETE craptex
     WHERE craptex.dtemiext < (vr_dtmvtolt - 45);
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao excluir CRAPTEX: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  /* FIM Limpeza dos registros com emissao maior que 45 dias */

  /*  Limpeza do arquivo de rejeitados ......................... */
  BEGIN
    DELETE craprej
     WHERE craprej.cdcooper = pr_cdcooper;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao excluir CRAPREJ: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  /*  FIM Limpeza do arquivo de rejeitados ................................ */

  /*  Inicializa o numero de lote para integracao da compensacao .......... */
  BEGIN
    UPDATE craptab
       SET craptab.dstextab  = SUBSTR(TRIM(craptab.dstextab),1,1)||'000'
     WHERE craptab.cdcooper  = pr_cdcooper
       AND craptab.cdacesso IN ('NUMLOTECBB','NUMLOTEBCO','NUMLOTECEF');
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao atualizar CRAPTAB[1]: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  /*  Tabela que controla cadastramento de valores maiores de R$ 100.000 ... */
  BEGIN
    UPDATE craptab
       SET craptab.dstextab  = '0'
     WHERE craptab.cdcooper  = pr_cdcooper
       AND craptab.nmsistem  = 'CRED'
       AND craptab.tptabela  = 'GENERI'
       AND craptab.cdempres  = 0
       AND craptab.cdacesso  = 'CTRMVESCEN'
       AND craptab.tpregist  = 0;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao atualizar CRAPTAB[2]: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  /*  Desmarca tabela de pedido de talonarios .............................. */
  BEGIN
    UPDATE craptab
       SET craptab.dstextab  = '0 0'
     WHERE craptab.cdcooper  = pr_cdcooper
       AND craptab.nmsistem  = 'CRED'
       AND craptab.tptabela  = 'USUARI'
       AND craptab.cdempres  = 11
       AND craptab.cdacesso  = 'EXECPEDTAL'
       AND craptab.tpregist  = 001;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao atualizar CRAPTAB[3]: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;
	
  /* Atualiza tabela controle remessa GPS .................................. */
  BEGIN
    UPDATE craptab
       SET craptab.dstextab  = SUBSTR(craptab.dstextab,1,17)||'01'
     WHERE craptab.cdcooper  = pr_cdcooper
       AND craptab.nmsistem  = 'CRED'
       AND craptab.tptabela  = 'GENERI'
       AND craptab.cdempres  = 00
       AND craptab.cdacesso  = 'HRGUIASGPS'
       AND craptab.tpregist  = 000;
  EXCEPTION
    WHEN OTHERS THEN
      -- Definir mensagem de erro
      vr_dscritic := 'Erro ao atualizar CRAPTAB[4]: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;

  DECLARE
    -- Variáveis restritas ao bloco
    -- Auxiliares para o processamento
    vr_cdacesso   craptab.cdacesso%TYPE;
    vr_tpregist   craptab.tpregist%TYPE;
    vr_cdempres   craptab.cdempres%TYPE;
    vr_tptabela   craptab.tptabela%TYPE;
    -- Datas de avisos e controle de dias uteis
    vr_dtavisos   DATE;
    vr_dtavs001   DATE;
    vr_qtdiasut   NUMBER;
    -- Tratamento de excessão
    vr_exp_erro   EXCEPTION;
  BEGIN
    /*  ------------------------------------------------------------------- */
    /*  Rotinas anuais .................................................... */
    /*  ------------------------------------------------------------------- */
    IF trunc(vr_dtmvtopr,'YYYY') <> trunc(vr_dtmvtolt,'YYYY') THEN
      -- Processar
      FOR vr_inditera IN 1..4 LOOP

        -- Verifica qual registro será processado
        /* Libera tabela de execucao da microfilmagem do capital */
        IF vr_inditera = 1 THEN
          vr_cdacesso := 'EXELIMPCOT';
          vr_tpregist := 001;
          vr_cdcritic := 176; -- Falta tabela de execucao de limpeza - registro 001
					
        /* Libera tabela de execucao da limpeza do capital */
        ELSIF vr_inditera = 2 THEN
          vr_cdacesso := 'EXELIMPCOT';
          vr_tpregist := 002;
          vr_cdcritic := 178; -- Falta tabela de execucao de limpeza - registro 002
					
        /* Libera tabela de execucao da limpeza do cadastro */				
        ELSIF vr_inditera = 3 THEN
          vr_cdacesso := 'EXELIMPCAD';
          vr_tpregist := 001;
          vr_cdcritic := 387; -- Falta tabela de execucao da limpeza do cadastro
					
        /* Libera tabela de execucao da limpeza do crapneg */
        ELSIF vr_inditera = 4 THEN
          vr_cdacesso := 'EXELIMPNEG';
          vr_tpregist := 001;
          vr_cdcritic := 420; -- Falta tabela de execucao da limpeza do crapneg
        END IF;

        -- Realizar a atualização conforme valores setados nas variáveis
        BEGIN
          UPDATE craptab
             SET craptab.dstextab  = '0'
           WHERE craptab.cdcooper  = pr_cdcooper
             AND craptab.nmsistem  = 'CRED'
             AND craptab.tptabela  = 'GENERI'
             AND craptab.cdempres  = 00
             AND craptab.cdacesso  = vr_cdacesso
             AND craptab.tpregist  = vr_tpregist;

          -- Se não encontrou nenhum registro para alterar
          IF SQL%ROWCOUNT = 0 THEN
            RAISE vr_exp_erro;
          ELSE
            -- Limpa a critica
            vr_cdcritic := 0;
          END IF;
        EXCEPTION
          WHEN vr_exp_erro THEN
            RAISE vr_exp_erro;
          WHEN OTHERS THEN
            -- Definir mensagem de erro
            vr_dscritic := 'Erro ao atualizar CRAPTAB[5]: '||SQLERRM;
            -- Registra Log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratado
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                       pr_nmarqlog     => vr_cdprogra);
        END;

      END LOOP; -- 1..4
    END IF; -- Rotinas anuais
		
    /*  ------------------------------------------------------------------- */
    /*  Rotinas mensais ................................................... */
    /*  ------------------------------------------------------------------- */
    IF trunc(vr_dtmvtopr,'MM') <> trunc(vr_dtmvtolt,'MM') THEN
      -- Processar
      FOR vr_inditera IN 1..7 LOOP
        -- Verifica qual registro será processado
        /* Libera tabela de execucao da limpeza para proxima 6a. feira */
        IF vr_inditera = 1 THEN
          vr_cdacesso := 'EXELIMPEZA';
          vr_tpregist := 001;
          vr_cdcritic := 176; -- Falta tabela de execucao de limpeza - registro 001
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
					
        /* Libera tabela de execucao da baixa dos talonarios de demit */
        ELSIF vr_inditera = 2 THEN
          vr_cdacesso := 'EXEBAIXCHQ';
          vr_tpregist := 001;
          vr_cdcritic := 267; -- Falta tabela de execucao de baixa de talonarios
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
					
        /* Libera tabela de execucao da limpeza do cadastro */
        ELSIF vr_inditera = 3 THEN
          vr_cdacesso := 'EXEACOMPTL';
          vr_tpregist := 001;
          vr_cdcritic := 184; -- Falta tabela de execucao do acompanhamento de talonarios
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
					
        /* Libera tabela de execucao da listagem das aplicacoes */
        ELSIF vr_inditera = 4 THEN
          vr_cdacesso := 'EXESOLAPLI';
          vr_tpregist := 001;
          vr_cdcritic := 351; -- Falta tabela de execucao da listagem de aplicacoes a vencer
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
					
        /* Libera tabela de taxa de liquidacao dos emprestimos */
        ELSIF vr_inditera = 5 THEN
          vr_cdacesso := 'TAXATABELA';
          vr_tpregist := 000;
          vr_cdcritic := 396; -- Taxa para liquidacao de emprestimos nao cadastrada
          vr_cdempres := 11;
          vr_tptabela := 'USUARI';
					
        /* Libera tabela de fichas de recadastramento */
        ELSIF vr_inditera = 6 THEN
          vr_cdacesso := 'EXESOLADMI';
          vr_tpregist := 001;
          vr_cdcritic := 433; -- Falta tabela de execucao das fichas de admitidos
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
					
        /*  Libera tabela de execucao do extrato quinzenal */
        ELSIF vr_inditera = 7 THEN
          vr_cdacesso := 'EXEQUINZEN';
          vr_tpregist := 001;
          vr_cdcritic := 571; -- Falta tabela de execucao quinzenal
          vr_cdempres := 00;
          vr_tptabela := 'GENERI';
        END IF;

        -- Realizar a atualização conforme valores setados nas variáveis
        BEGIN
          UPDATE craptab
             SET craptab.dstextab  = '0'
           WHERE craptab.cdcooper  = pr_cdcooper
             AND craptab.nmsistem  = 'CRED'
             AND craptab.tptabela  = vr_tptabela
             AND craptab.cdempres  = vr_cdempres
             AND craptab.cdacesso  = vr_cdacesso
             AND craptab.tpregist  = vr_tpregist;

          -- Se não encontrou nenhum registro para alterar
          IF SQL%ROWCOUNT = 0 THEN
            RAISE vr_exp_erro;
          ELSE
            -- Limpa a critica
            vr_cdcritic := 0;
          END IF;
        EXCEPTION
          WHEN vr_exp_erro THEN
            RAISE vr_exp_erro;
          WHEN OTHERS THEN
            -- Definir mensagem de erro
            vr_dscritic := 'Erro ao atualizar CRAPTAB[6]: '||SQLERRM;
            -- Registra Log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratado
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                       pr_nmarqlog     => vr_cdprogra);
        END;

      END LOOP; -- 1..7
			
      /* Libera tabela de execucao da emissao de cartao chq. esp. */
      BEGIN
        UPDATE craptab
           SET craptab.dstextab  = '0'||SUBSTR(craptab.dstextab,2,11)
         WHERE craptab.cdcooper  = pr_cdcooper
           AND craptab.nmsistem  = 'CRED'
           AND craptab.tptabela  = 'GENERI'
           AND craptab.cdempres  = 00
           AND craptab.cdacesso  = 'EXESOLCART'
           AND craptab.tpregist  = 001;

        -- Se não encontrou nenhum registro para alterar
        IF SQL%ROWCOUNT = 0 THEN
          -- Crítica
          vr_cdcritic := 279; -- Falta tabela de emissao dos cartoes de cheque especial
          RAISE vr_exp_erro;
        END IF;
      EXCEPTION
        WHEN vr_exp_erro THEN
          RAISE vr_exp_erro;
        WHEN OTHERS THEN
          -- Definir mensagem de erro
          vr_dscritic := 'Erro ao atualizar CRAPTAB[7]: '||SQLERRM;
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog     => vr_cdprogra);
      END;
			
      /* Libera a inclusao de novos associados */
      BEGIN
        UPDATE crapmat
           SET crapmat.qtassati = crapmat.qtassati +
                                  crapmat.qtassmes +
                                  crapmat.qtdesmes -
                                  crapmat.qtdemmes
             , crapmat.qtassdem = crapmat.qtassdem +
                                  crapmat.qtdemmes -
                                  crapmat.qtdesmes -
                                  crapmat.qtassbai
             , crapmat.qtassmes = 0
             , crapmat.inincass = 0
             , crapmat.qtdemmes = 0
             , crapmat.qtdesmes = 0
             , crapmat.qtassbai = 0
             , crapmat.qtasbxpf = 0
             , crapmat.qtasbxpj = 0 
         WHERE crapmat.cdcooper  = pr_cdcooper;

        -- Se não encontrou nenhum registro para alterar
        IF SQL%ROWCOUNT = 0 THEN
          -- Crítica
          vr_cdcritic := 194; -- SISTEMA SEM ARQUIVO DE MATRICULAS!!!!
          RAISE vr_exp_erro;
        END IF;
      EXCEPTION
        WHEN vr_exp_erro THEN
          RAISE vr_exp_erro;
        WHEN OTHERS THEN
          -- Definir mensagem de erro
          vr_dscritic := 'Erro ao atualizar CRAPMAT: '||SQLERRM;
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog     => vr_cdprogra);
      END;
						
			-- Buscar o valor atual da sequencia para o campo crapmat.qtassmes - > Admitidos;
      OPEN cr_crapsqu(pr_nmtabela => 'CRAPMAT' ,
			                pr_nmdcampo => 'QTASSMES',
											pr_dsdchave => to_char(pr_cdcooper));											
      FETCH cr_crapsqu INTO rw_crapsqu;			
      -- Se tiver encontrado
      IF cr_crapsqu%FOUND THEN				
				-- Zerar a sequencia
				BEGIN
					UPDATE crapsqu
						 SET nrseqatu = 0 /* Zerar */
						 WHERE ROWID = rw_crapsqu.rowid;
				EXCEPTION
					WHEN OTHERS THEN						
						-- Definir mensagem de erro
						vr_dscritic := 'Erro ao zerar valor de sequence (CRAPSQU) para ' ||
						               'campo CRAPMAT.QTASSMES. Erro --> '||SQLERRM;
						-- Registra Log
						btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
																			 pr_ind_tipo_log => 2, -- Erro tratado
																			 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
																			 pr_nmarqlog     => vr_cdprogra);
          END;
      END IF;
			-- Fecha cursor de valor da sequencia de Admitidos;
			CLOSE cr_crapsqu;
      
      -- Buscar o valor atual da sequencia para zerar o campo crapmat.qtdesmes -> Readmitidos;
      OPEN cr_crapsqu(pr_nmtabela => 'CRAPMAT' ,
			                pr_nmdcampo => 'QTDESMES',
											pr_dsdchave => to_char(pr_cdcooper));											
      FETCH cr_crapsqu INTO rw_crapsqu;			
      -- Se tiver encontrado
      IF cr_crapsqu%FOUND THEN				
				-- Zerar a sequencia
				BEGIN
					UPDATE crapsqu
						 SET nrseqatu = 0 /* Zerar */
						 WHERE ROWID = rw_crapsqu.rowid;
				EXCEPTION
					WHEN OTHERS THEN						
						-- Definir mensagem de erro
						vr_dscritic := 'Erro ao zerar valor de sequence (CRAPSQU) para ' ||
						               'campo CRAPMAT.QTDESMES. Erro --> '||SQLERRM;
						-- Registra Log
						btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
																			 pr_ind_tipo_log => 2, -- Erro tratado
																			 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
																			 pr_nmarqlog     => vr_cdprogra);
          END;
      END IF;
			-- Fecha cursor de valor da sequencia de Readmitidos;
			CLOSE cr_crapsqu;
      
      -- Buscar o valor atual da sequencia para o campo crapmat.qtdemmes -> Desligados;
      OPEN cr_crapsqu(pr_nmtabela => 'CRAPMAT' ,
			                pr_nmdcampo => 'QTDEMMES',
											pr_dsdchave => to_char(pr_cdcooper));											
      FETCH cr_crapsqu INTO rw_crapsqu;			
      -- Se tiver encontrado
      IF cr_crapsqu%FOUND THEN				
				-- Zerar a sequencia
				BEGIN
					UPDATE crapsqu
						 SET nrseqatu = 0 /* Zerar */
						 WHERE ROWID = rw_crapsqu.rowid;
				EXCEPTION
					WHEN OTHERS THEN						
						-- Definir mensagem de erro
						vr_dscritic := 'Erro ao zerar valor de sequence (CRAPSQU) para ' ||
						               'campo CRAPMAT.QTDEMMES. Erro --> '||SQLERRM;
						-- Registra Log
						btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
																			 pr_ind_tipo_log => 2, -- Erro tratado
																			 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
																			 pr_nmarqlog     => vr_cdprogra);
          END;
      END IF;
			-- Fecha cursor de valor da sequencia de Desligados;
			CLOSE cr_crapsqu;
													   
      -- Data aviso - ultimo dia do mês
      vr_dtavisos := LAST_DAY(vr_dtmvtopr);
      vr_dtavs001 := vr_dtavisos;
      vr_qtdiasut := 0;

      LOOP
        -- Quando a variável chegar ou passar de 5, encerra o loop
        EXIT WHEN vr_qtdiasut >= 5;

        -- Buscar o indicado de feriado
        OPEN  cr_crapfer(vr_dtavisos);
        FETCH cr_crapfer INTO rw_crapfer;

        -- Se não for final de semana e não for feriado
        IF TO_CHAR(vr_dtavisos,'D') NOT IN ('1','7') AND cr_crapfer%NOTFOUND THEN
          vr_qtdiasut := vr_qtdiasut + 1;
        END IF;

        -- Se a quantidade de dias úteis é menor que 5
        IF vr_qtdiasut < 5 THEN
          -- Diminuir um dia da data do aviso
          vr_dtavisos := vr_dtavisos - 1;

          -- Se a quantidade de dias úteis for menor que 3
          IF vr_qtdiasut < 3  THEN
            vr_dtavs001 := vr_dtavs001 - 1;
          END IF;
        END IF;

        -- Fechar o cursor
        CLOSE cr_crapfer;

      END LOOP;

      -- Percorrer o cadastro de empresas
      FOR rw_crapemp IN cr_crapemp LOOP
        DECLARE
          -- Variáveis para o escopo atual
          vr_inavscot     crapemp.inavscot%TYPE := NULL;
          vr_dtavscot     crapemp.dtavscot%TYPE := NULL;
          vr_inavsemp     crapemp.inavsemp%TYPE := NULL;
          vr_dtavsemp     crapemp.dtavsemp%TYPE := NULL;
          vr_inavsppr     crapemp.inavsppr%TYPE := NULL;
          vr_dtavsppr     crapemp.dtavsppr%TYPE := NULL;
          vr_inavsseg     crapemp.inavsseg%TYPE := NULL;
          vr_dtavsseg     crapemp.dtavsseg%TYPE := NULL;
        BEGIN
          -- Se o tipo de debito de cotas for igual a 2 ou 3
          IF rw_crapemp.tpdebcot IN (2,3) THEN
            --
            vr_inavscot := 0;
            --
            -- Se o tipo de debito de cotas for igual a 2
            IF rw_crapemp.tpdebcot = 2 THEN
              vr_dtavscot := vr_dtavisos;
            ELSE
              vr_dtavscot := vr_dtavs001;
            END IF;
          END IF;
          -- Se o tipo de debito de emprestimo for igual a 2 ou 3
          IF rw_crapemp.tpdebemp IN (2,3) THEN
            --
            vr_inavsemp := 0;
            --
            -- Se o tipo de debito de emprestimo for igual a 2
            IF rw_crapemp.tpdebemp = 2 THEN
              vr_dtavsemp := vr_dtavisos;
            ELSE
              vr_dtavsemp := vr_dtavs001;
            END IF;
          END IF;
          -- Se o tipo de debito da poupanca programada for igual a 2
          IF rw_crapemp.tpdebppr = 2 THEN
            --
            vr_inavsppr := 0;
            --
            -- Se o código da empresa for igual a 4 ou 6
            IF rw_crapemp.cdempres IN (4,6) THEN
              vr_dtavsppr := vr_dtavisos;
            ELSE
              -- Se código da empresa for 1
              IF rw_crapemp.cdempres = 1 THEN
                vr_dtavsppr := vr_dtavs001;
              END IF;
            END IF;
          END IF;
          -- Se tipo de debito de seguro igual a 2
          IF rw_crapemp.tpdebseg = 2 THEN
            --
            vr_inavsseg := 0;
            --
            -- Se o código da empresa for igual a 4 ou 6
            IF rw_crapemp.cdempres IN (4,6) THEN
               vr_dtavsseg := vr_dtavisos;
            ELSE
              -- Se código da empresa for 1
              IF rw_crapemp.cdempres = 1 THEN
                vr_dtavsseg := vr_dtavs001;
              END IF;
            END IF;
          END IF;

          -- Atualiza a tabela com os valores das variáveis
          UPDATE crapemp
             SET crapemp.inavscot = NVL(vr_inavscot,crapemp.inavscot)
               , crapemp.dtavscot = NVL(vr_dtavscot,crapemp.dtavscot)
               , crapemp.inavsemp = NVL(vr_inavsemp,crapemp.inavsemp)
               , crapemp.dtavsemp = NVL(vr_dtavsemp,crapemp.dtavsemp)
               , crapemp.inavsppr = NVL(vr_inavsppr,crapemp.inavsppr)
               , crapemp.dtavsppr = NVL(vr_dtavsppr,crapemp.dtavsppr)
               , crapemp.inavsseg = NVL(vr_inavsseg,crapemp.inavsseg)
               , crapemp.dtavsseg = NVL(vr_dtavsseg,crapemp.dtavsseg)
           WHERE crapemp.rowid    = rw_crapemp.idregist;

        EXCEPTION
          WHEN OTHERS THEN
            -- Definir mensagem de erro
            vr_dscritic := 'Erro ao atualizar CRAPEMP: '||SQLERRM;
            -- Registra Log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratado
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                       pr_nmarqlog     => vr_cdprogra);
        END;
      END LOOP; -- cr_crapemp
 
      /*  Libera tabela de integracao dos convenios */
      BEGIN
        UPDATE craptab
           SET craptab.dstextab  = to_char(vr_dtavisos,'DD/MM/YYYY')||' 0'
         WHERE craptab.cdcooper  = pr_cdcooper
           AND craptab.nmsistem  = 'CRED'
           AND craptab.tptabela  = 'GENERI'
           AND craptab.cdempres  = 11
           AND craptab.cdacesso  = 'PROCCONVEN'
           AND craptab.tpregist  = 000;

        -- Se não encontrou nenhum registro para alterar
        IF SQL%ROWCOUNT = 0 THEN
          -- Cria o registro na CRAPTAB
          BEGIN
            INSERT INTO craptab(cdcooper
                               ,nmsistem
                               ,tptabela
                               ,cdempres
                               ,cdacesso
                               ,tpregist
                               ,dstextab)
                         VALUES(pr_cdcooper  -- cdcooper
                               ,'CRED'       -- nmsistem
                               ,'GENERI'     -- tptabela
                               ,11           -- cdempres
                               ,'PROCCONVEN' -- cdacesso
                               ,000          -- tpregist
                               ,to_char(vr_dtavisos,'DD/MM/YYYY')||' 0');  -- dstextab
          EXCEPTION
            WHEN OTHERS THEN
              -- Definir mensagem de erro
              vr_dscritic := 'Erro ao inserir CRAPTAB[1]: '||SQLERRM;
              -- Registra Log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, -- Erro tratado
                                         pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                         pr_nmarqlog     => vr_cdprogra);
          END;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Definir mensagem de erro
          vr_dscritic := 'Erro ao atualizar CRAPTAB[8]: '||SQLERRM;
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog     => vr_cdprogra);
      END;
			
      /* Libera tabela de execucao Central de risco BACEN */
      BEGIN
        UPDATE craptab
           SET craptab.dstextab  = '0'||SUBSTR(craptab.dstextab,2)
         WHERE craptab.cdcooper  = pr_cdcooper
           AND craptab.nmsistem  = 'CRED'
           AND craptab.tptabela  = 'USUARI'
           AND craptab.cdempres  = 11
           AND craptab.cdacesso  = 'RISCOBACEN'
           AND craptab.tpregist  = 000;

        -- Se não encontrou nenhum registro para alterar
        IF SQL%ROWCOUNT = 0 THEN
          -- Crítica
          vr_cdcritic := 055; -- Tabela nao cadastrada
          RAISE vr_exp_erro;
        END IF;
      EXCEPTION
        WHEN vr_exp_erro THEN
          RAISE vr_exp_erro;
        WHEN OTHERS THEN
          -- Definir mensagem de erro
          vr_dscritic := 'Erro ao atualizar CRAPTAB[9]: '||SQLERRM;
          -- Registra Log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro tratado
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                     pr_nmarqlog     => vr_cdprogra);
      END;

    END IF; -- Rotinas mensais

  EXCEPTION
    WHEN vr_exp_erro THEN
      -- Se há critica, mas não há descrição
      IF vr_dscritic IS NULL AND vr_cdcritic IS NOT NULL THEN
        -- Busca a descrição da crítica
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
      -- Sai da Rotina
      RETURN;
    WHEN OTHERS THEN
      -- Define a mensagem de erro
      vr_dscritic := 'Erro no processamento: '||SQLERRM;
      -- Registra Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratado
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' --> '|| vr_dscritic,
                                 pr_nmarqlog     => vr_cdprogra);
  END;
	
  /*
  * Envia e-mail ao contador da cooperativa caso ainda nao tenha
  * sido enviado o email referente a DIMOF ao BACEN
  */
  IF to_char(vr_dtmvtolt,'MM') IN ('02','08') AND to_char(vr_dtmvtolt,'DD') > 15  THEN

    -- Define o último dia útil do mês
    vr_ultdiame := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtolt
                                              ,pr_tipo     => 'A');

    -- Buscar as datas de controles para geracao da DIMOF(Declaracao de Informacoes sobre Movimentacao Financeira)
    OPEN  cr_crapmof(vr_ultdiame);
    FETCH cr_crapmof INTO rw_crapmof;
    -- Se encontrar registros
    IF cr_crapmof%FOUND THEN
      -- Se ainda não foi realizado o envio
      IF rw_crapmof.flgenvio = 0 THEN

        -- Buscar o endereço de e-mail
        OPEN  cr_craptab('CRED'       -- pr_nmsistem
                        ,'USUARI'     -- pr_tptabela
                        ,0            -- pr_cdempres
                        ,'EMLCTBCOOP' -- pr_cdacesso
                        ,0);          -- pr_tpregist
        FETCH cr_craptab INTO vr_dsdestin;
        -- Se não encontrar registro
        IF cr_craptab%NOTFOUND THEN
          vr_dsdestin := NULL;
        END IF;
        -- Fecha o cursor
        CLOSE cr_craptab;

        -- Monta o corpo do e-mail
        vr_conteudo := 'Informamos que dia '                       ||
                       TO_CHAR(vr_ultdiame,'DD/MM/YYYY')           ||
                       ' e o prazo final para enviar o arquivo de '||
                       'Declaracao de Informacoes Sobre a '        ||
                       'Movimentacao Financeira (DIMOF) ao '       ||
                       'BACEN referente ao periodo de '            ||
                       TO_CHAR(rw_crapmof.dtiniper,'DD/MM/YYYY')   ||
                       ' ate '                                     ||
                       TO_CHAR(rw_crapmof.dtfimper,'DD/MM/YYYY')   ||
                       '.'||chr(13)||chr(13)||
                       'Cooperativa Central de Credito Urbano'||CHR(13)||
                       'CECRED';

        -- Enviar e-mail com o log gerado
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => vr_cdprogra
                                  ,pr_des_destino     => vr_dsdestin
                                  ,pr_des_assunto     => 'Prazo para enviar arquivo DIMOF ao BACEN'
                                  ,pr_des_corpo       => vr_conteudo
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);

        -- Verificar se houve erro ao solicitar e-mail
        IF vr_dscritic IS NOT NULL THEN
          -- Não gerar critica
          vr_cdcritic := 0;
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
        END IF;  -- Critica
      END IF; -- FLGENVIO
    END IF; -- Datas de controle
  END IF;
	
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informacoes no banco de dados
  COMMIT;
  
EXCEPTION
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
END PC_CRPS659;
/

