CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS292 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada

  /* ..........................................................................

    Programa: PC_CRPS292                 Antigo: Fontes/crps292.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Margarete/Planner
    Data    : Agosto/2000.                       Ultima atualizacao: 18/12/2013

    Dados referentes ao programa:

    Frequencia: Mensal (Batch - Background).
    Objetivo  : Atende a solicitacao 004.
                Emite relatorio dos associados inativos (rel 242).

    Alteracoes: 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                16/11/2006 - Liberado relatorio INTRANET(Mirtes)

                01/06/2007 - Alterada a mascara do campo 'vlcapmes' para
                             negativo. (Guilherme).

                18/12/2013 - Conversão Progress >> PLSQL (Renato - Supero)
  ....................................................................................... */

  ------------------------------- CURSORES ---------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Listar os cadastros dac cooperativa onde o campo dtdemiss não esteja nulo
  CURSOR cr_crapass(pr_nrdmes IN NUMBER) IS
    SELECT crapass.nrdconta
         , crapass.nrmatric
         , crapass.dtdemiss
         , crapass.nmprimtl
         , crapass.inpessoa
         , crapass.nrcpfcgc
         , CASE pr_nrdmes
	                   WHEN  1 THEN crapcot.vlcapmes##1
                     WHEN  2 THEN crapcot.vlcapmes##2
                     WHEN  3 THEN crapcot.vlcapmes##3
                     WHEN  4 THEN crapcot.vlcapmes##4
                     WHEN  5 THEN crapcot.vlcapmes##5
                     WHEN  6 THEN crapcot.vlcapmes##6
                     WHEN  7 THEN crapcot.vlcapmes##7
                     WHEN  8 THEN crapcot.vlcapmes##8
                     WHEN  9 THEN crapcot.vlcapmes##9
                     WHEN 10 THEN crapcot.vlcapmes##10
                     WHEN 11 THEN crapcot.vlcapmes##11
                     WHEN 12 THEN crapcot.vlcapmes##12
                     ELSE NULL
           END   vlcapmes
      FROM crapcot
         , crapass
     WHERE crapcot.cdcooper = crapass.cdcooper
       AND crapcot.nrdconta = crapass.nrdconta
       AND crapass.dtdemiss IS NOT NULL
       AND crapass.cdcooper = pr_cdcooper -- Cooperativa
     ORDER BY crapass.cdcooper, crapass.nrdconta;

  ------------------------------- REGISTROS -------------------------------
  rw_crapcop cr_crapcop%ROWTYPE;

  ------------------------------- VARIAVEIS -------------------------------
  -- Código do programa
  vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS292';
  -- Data de movimento e mês de referencia
  vr_dtmvtolt     DATE;
  vr_nrmesref     NUMBER;
  vr_dsmesref     VARCHAR2(40);
  -- Diretório para geração do relatóriio
  vr_nom_direto   VARCHAR2(100);
  -- Variável para armazenar as informações em XML
  vr_des_xml      CLOB;

  -- Rolbacks para erros, ignorar o resto do processo e rollback
  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------- PROCEDIMENTOS INTERNOS -----------------------------
  -- Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
    --Escrever no arquivo XML
    dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
  END;

BEGIN

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
    vr_nrmesref := TO_NUMBER(TO_CHAR(vr_dtmvtolt,'MM'));
    vr_dsmesref := gene0001.vr_vet_nmmesano(vr_nrmesref)||'/'||to_char(vr_dtmvtolt,'YYYY');
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

  -- Busca do diretório base da cooperativa
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

  -- Inicilizar as informações do XML
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl242 dsmesref="'||vr_dsmesref||'">');

  -- Percorrer todos os registros de demitidos
  FOR rw_crapass IN cr_crapass(vr_nrmesref) LOOP

    -- Verificar se o valor do capital do mes correspondente é maior que zero
    IF rw_crapass.vlcapmes = 0 THEN
      -- Pula para o próximo registro.
      CONTINUE;
    END IF;

    -- Abrir o nó de demissões
    pc_escreve_xml('<demissao > ');
    -- Conta
    pc_escreve_xml('<nrdconta>'||GENE0002.fn_mask_conta(pr_nrdconta => rw_crapass.nrdconta)||'</nrdconta>');
    -- Matricula
    pc_escreve_xml('<nrmatric>'||GENE0002.fn_mask_matric(pr_nrmatric=> rw_crapass.nrmatric)||'</nrmatric>');
    -- Data de demissão
    pc_escreve_xml('<dtdemiss>'||to_char(rw_crapass.dtdemiss,'DD/MM/YYYY')||'</dtdemiss>');
    -- Nome titular
    pc_escreve_xml('<nmprimtl>'||SUBSTR(rw_crapass.nmprimtl,0,40)||'</nmprimtl>');
    -- CPF/CNPJ
    pc_escreve_xml('<nrcpfcgc>'||GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc
                                                          ,pr_inpessoa => rw_crapass.inpessoa)||'</nrcpfcgc>');
    -- Valor de Capital
    pc_escreve_xml('<vlcapmes>'||to_char(rw_crapass.vlcapmes,'FM999G999G990D00')||'</vlcapmes>');
    -- Fecha o nodo de demissões
    pc_escreve_xml('</demissao>');
  END LOOP;  -- cr_crapass

  -- Fecha o nodo de demissões e o do XML
  pc_escreve_xml('</crrl242>');

  -- Efetuar solicitação de geração de relatório --
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                             ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                             ,pr_dtmvtolt  => vr_dtmvtolt         --> Data do movimento atual
                             ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                             ,pr_dsxmlnode => '/crrl242/demissao' --> Nó base do XML para leitura dos dados
                             ,pr_dsjasper  => 'crrl242.jasper'    --> Arquivo de layout do iReport
                             ,pr_dsparams  => 'PR_DSMESREF##'||vr_dsmesref  --> Enviar como parâmetro apenas o valor maior deposito
                             ,pr_dsarqsaid => vr_nom_direto||'/crrl242.lst' --> Arquivo final com código da agência
                             ,pr_qtcoluna  => 132                 --> 132 colunas
                             ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_1.i}
                             ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                             ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                             ,pr_nrcopias  => 1                   --> Número de cópias
                             ,pr_flg_gerar => 'N'                 --> gerar PDF
                             ,pr_des_erro  => vr_dscritic);       --> Saída com erro

   -- Liberando a memória alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

   -- Testar se houve erro
   IF vr_dscritic IS NOT NULL THEN
     -- Gerar exceção
     RAISE vr_exc_saida;
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
END pc_crps292;
/

